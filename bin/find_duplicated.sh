#!/bin/sh
# find_duplicated.sh — find duplicate files by size, then content hash.
#
# Usage: find_duplicated.sh [DIR] [--size SPEC]
#
#   DIR          directory to scan (default: .)
#   --size SPEC  only inspect files matching find(1)'s -size SPEC (e.g. +4k)
#
# Duplicates are reported as groups: a `-- <hash>` header followed by the
# matching paths, one per line.
#
# Portability notes:
#   * Works with BSD (macOS) and GNU userland. GNU tools (gfind/gstat) are
#     auto-detected when present, but the script never relies on shell aliases
#     — a non-interactive `sh` does not expand them.
#   * Filenames containing a newline are not supported.
#   * Hashing pass worker count: DOTFILES_FIND_DUP_JOBS (default: nproc).
set -eu

# --- arguments ---------------------------------------------------------------
dir='.'
size_spec=''
while [ "$#" -gt 0 ]; do
    case "$1" in
        --size)
            shift
            [ "$#" -gt 0 ] || { echo "find_duplicated.sh: --size requires a value" >&2; exit 1; }
            size_spec=$1
            ;;
        -h|--help)
            sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        -*)
            echo "find_duplicated.sh: unknown option: $1" >&2
            exit 1
            ;;
        *)
            dir=$1
            ;;
    esac
    shift
done

[ -d "$dir" ] || { echo "find_duplicated.sh: not a directory: $dir" >&2; exit 1; }

# --- resolve tools -----------------------------------------------------------
pick() {
    for _c in "$@"; do
        if command -v "$_c" >/dev/null 2>&1; then
            command -v "$_c"
            return 0
        fi
    done
    return 1
}

FIND=$(pick gfind find) || { echo "find_duplicated.sh: find not found" >&2; exit 1; }

TAB=$(printf '\t')
if GSTAT=$(pick gstat); then
    STAT=$GSTAT
    STAT_FLAG=-c
    STAT_FMT="%s${TAB}%n"
elif stat -f '%z' . >/dev/null 2>&1; then
    STAT=stat
    STAT_FLAG=-f
    STAT_FMT="%z${TAB}%N"
elif stat -c '%s' . >/dev/null 2>&1; then
    STAT=stat
    STAT_FLAG=-c
    STAT_FMT="%s${TAB}%n"
else
    echo "find_duplicated.sh: stat(1) has neither -f nor -c" >&2
    exit 1
fi

# Digest command; only the first whitespace-separated field is used, so all of
# these yield the bare hex digest.
if command -v md5sum >/dev/null 2>&1; then
    HASH_CMD='md5sum'
elif command -v md5 >/dev/null 2>&1; then
    HASH_CMD='md5 -r'
elif command -v shasum >/dev/null 2>&1; then
    HASH_CMD='shasum -a 256'
else
    echo "find_duplicated.sh: no digest tool (md5sum/md5/shasum)" >&2
    exit 1
fi

# Worker count for the hashing pass.
JOBS=${DOTFILES_FIND_DUP_JOBS:-}
if [ -z "$JOBS" ]; then
    JOBS=$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)
fi

# --- pass 1: group by size; keep only paths whose size collides --------------
# Candidates are written to a NUL-separated temp file (readable by xargs -0),
# so filenames with spaces survive. \034 is used as the awk record separator
# because BSD awk cannot emit a literal NUL via printf, but tr can translate.
candidates=$(mktemp "${TMPDIR:-/tmp}/find_duplicated.XXXXXX") || exit 1
hash_list=$(mktemp "${TMPDIR:-/tmp}/find_duplicated.XXXXXX") || exit 1
trap 'rm -f "$candidates" "$hash_list"' EXIT HUP INT TERM

set -- "$dir" \( -name .git -o -name '@eaDir' \) -prune -o -type f ! -empty
[ -n "$size_spec" ] && set -- "$@" -size "$size_spec"

"$FIND" "$@" -exec "$STAT" "$STAT_FLAG" "$STAT_FMT" {} + |
awk -F"$TAB" '
    {
        size = $1
        path = $0
        sub("^[^" FS "]*" FS, "", path)
        count[size]++
        group[size] = group[size] path sprintf("%c", 28)
    }
    END { for (s in count) if (count[s] > 1) printf "%s", group[s] }
' |
tr '\034' '\000' > "$candidates"

# --- pass 2: hash candidates in parallel -------------------------------------
# The inner script runs in a child `sh` and reads $HASH_CMD from the
# environment prefix set below, hence the intentional single quotes.
# shellcheck disable=SC2016
HASH_CMD="$HASH_CMD" xargs -0 -P "$JOBS" -n 1 sh -c '
    [ -n "$1" ] || exit 0
    h=$($HASH_CMD -- "$1" 2>/dev/null | cut -d" " -f1) || exit 0
    [ -n "$h" ] && printf "%s\t%s\n" "$h" "$1"
' sh < "$candidates" > "$hash_list"

# --- pass 3: print duplicate groups ------------------------------------------
sort "$hash_list" |
awk -F"$TAB" '
    {
        hash = $1
        path = $0
        sub("^[^" FS "]*" FS, "", path)
    }
    hash == prev {
        if (!open) { print "-- " hash; print prev_path; open = 1 }
        print path
        next
    }
    { prev = hash; prev_path = path; open = 0 }
'

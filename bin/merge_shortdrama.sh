#!/bin/sh
# merge_shortdrama.sh — merge one or more short-drama directories into single video files.
#
# Usage:
#   merge_shortdrama.sh DRAMA [DRAMA2 ...] [--out OUT_DIR] [OPTIONS]
#             merge the listed drama folders (one call, many dramas).
#   merge_shortdrama.sh SRC_DIR --scan [--out OUT_DIR] [OPTIONS]
#             scan SRC and merge every "（N集）" folder under it.
#
#   DRAMA     one or more drama folders, e.g.
#             ".../117.魏家逆子成首辅折桂篇（64集）".
#   SRC_DIR   with --scan (positionals still accepted here, exactly one).
#   --out     output directory for every merged file. Default: each merged
#             file lands next to its own drama folder. The merged file is
#             always MP4 (+faststart), whatever the episodes' extensions.
#
# Options:
#   --scan     scan mode: walk every "（N集）" folder under SRC_DIR.
#   --dry-run  only print the merge plan, do not write files.
#   --force    overwrite an already existing output file.
#   --single   merge (copy) even when the folder holds a single episode file.
#
# Skipping: when the merged output file already exists it is skipped by
# default; pass --force to rebuild it. A drama folder whose episodes do not
# all share the same video codec (h264 vs hevc mixes) is rejected with a
# count report — a lossless (-c copy) merge across codec switches is not
# possible; transcode first, then re-run. Audio is held to the same rule:
# episodes that mix audio codec / sample rate / channel count, or that mix
# audio-bearing with audio-less episodes, are rejected as well — the
# mpeg-ts intermediate silently drops packets whose audio parameters
# differ from the first episode's (a channel-count change loses a whole
# episode's sound). An episode whose own audio starts early/late relative
# to its video is kept verbatim (the merge is lossless) but reported as a
# warning, since that offset comes from the source file, not the merge.
#
# How episodes are recognized (auto-detected, most specific first):
#   第N集 / 第N話 / 第N回      e.g. 第1集.mp4, 第007集.mp4, 第12话慕兰之战.mp4
#   EPnn / Episode nn          e.g. EP05.mp4, Episode 07.mp4
#   Enn after Sxx              e.g. S01E05.mp4
#   plain leading number       e.g. 01.mp4, 189 4K.mp4
#   fallback: first number     e.g. 37 修复版.mp4
# Fullwidth digits (０-９) are normalized. Within 1..N the script warns about
# missing or extra episode numbers compared to the "（N集）" declared count.
#
# Merging is a two-step lossless remux (see below) instead of a plain concat
# demuxer: each episode mp4 carries its own zero-based timestamps and edit
# lists, so naive stream-copy concat breaks seeking (long stalls) and drifts
# A/V sync. Step 1 copies each episode into mpeg-ts (-c copy, packets are not
# re-encoded) with per-stream bitstream filter and fresh monotonic timestamps
# and without edit lists; step 2 concatenates the TS segments and remuxes to
# mp4 (-c copy) with -movflags +faststart so the moov index sits at the file
# head for instant seeking/dragging. If the plain merge fails the script
# retries once with generated PTS, then gives up on that folder with an error.
#
# Portability notes:
#   * Runs under /bin/sh on macOS; relies on perl (shipped with macOS) for
#     UTF-8-aware filename parsing, and on ffmpeg for the actual merge.
#   * AppleDouble junk (._*) and non-video files are ignored.
#   * Filenames containing a newline or NUL are not supported.
set -eu

# --- arguments ---------------------------------------------------------------
drama_dirs=""
n_dirs=0
out=""
dry=0
force=0
single=0
scan=0
while [ "$#" -gt 0 ]; do
    case "$1" in
        --scan)
            scan=1
            ;;
        --out|-o)
            [ "$#" -ge 2 ] || { echo "merge_shortdrama.sh: --out 需要一个目录参数" >&2; exit 2; }
            out=$2
            shift
            ;;
        --dry-run|-n)
            dry=1
            ;;
        --force|-f)
            force=1
            ;;
        --single)
            single=1
            ;;
        -h|--help)
            sed -n '2,45p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        -*)
            echo "merge_shortdrama.sh: unknown option: $1" >&2
            sed -n '4,6p' "$0" | sed 's/^# \{0,1\}//' >&2
            exit 2
            ;;
        *)
            drama_dirs="${drama_dirs}${1}
"
            n_dirs=$((n_dirs + 1))
            ;;
    esac
    shift
done
drama_dirs=${drama_dirs%?}   # drop the trailing newline added by the catcher

if [ "$scan" = "1" ]; then
    if [ "$n_dirs" -eq 0 ]; then
        echo "merge_shortdrama.sh: --scan 需要提供源目录参数" >&2
        sed -n '4,6p' "$0" | sed 's/^# \{0,1\}//' >&2
        exit 2
    fi
    if [ "$n_dirs" -gt 1 ]; then
        echo "merge_shortdrama.sh: --scan 模式只需要一个源目录" >&2
        exit 2
    fi
    src=$drama_dirs
    if [ ! -d "$src" ]; then
        echo "merge_shortdrama.sh: source directory does not exist: $src (网盘/迅雷卷未挂载?)" >&2
        exit 1
    fi
else
    if [ "$n_dirs" -eq 0 ]; then
        echo "merge_shortdrama.sh: 请指定至少一个短剧目录, 或使用 --scan SRC_DIR 扫描全部短剧" >&2
        sed -n '4,6p' "$0" | sed 's/^# \{0,1\}//' >&2
        exit 2
    fi
    while IFS= read -r d; do
        if [ ! -d "$d" ]; then
            echo "merge_shortdrama.sh: 短剧目录不存在: $d (网盘/迅雷卷未挂载?)" >&2
            exit 1
        fi
    done <<EOF
$drama_dirs
EOF
fi
if [ "$dry" = "0" ] && ! command -v ffmpeg >/dev/null 2>&1; then
    echo "merge_shortdrama.sh: ffmpeg not found in PATH" >&2
    exit 1
fi

tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/merge_shortdrama.XXXXXX")
trap 'rm -rf "$tmpdir"' EXIT

tab=$(printf '\t')
# Byte-transparent parsing: perl source and stdin are both raw UTF-8 bytes,
# so no -C flags are used (they double-encode on some perl builds).
PERL_PARSE='
    my %by   = ();
    my %dup  = ();
    my $reext = qr/\.(mp4|mkv|mov|avi|wmv|flv|webm|m4v|mpg|mpeg|ts)$/i;
    while (defined(my $p = <STDIN>)) {
        $p =~ s/\0\z//;
        next unless length $p;
        next if $p =~ m{(^|/)\._};              # AppleDouble / Finder junk
        next unless $p =~ $reext;
        my ($stem) = $p =~ m{([^/]+)\.[^.]+$};
        next unless defined $stem && length $stem;
        (my $s = $stem) =~ s/^\s+//;
        $s =~ s/\s+$//;
        $s =~ s/\xEF\xBC([\x90-\x99])/ord($1) - 0x90/ge;   # ０-９ -> 0-9
        my $n;
        if    ($s =~ /第\s*([0-9]+)\s*[集话回話]/)              { $n = $1; }
        elsif ($s =~ /[Ee][Pp]\s*([0-9]{1,4})\s*$/)             { $n = $1; }
        elsif ($s =~ /(?:^|[^A-Za-z0-9])[Ee](?:pisode)?\s*([0-9]{1,4})(?![0-9])/) { $n = $1; }
        elsif ($s =~ /^([0-9]{1,4})(?![0-9])/)                  { $n = $1; }
        else {
            ($n) = $s =~ /([0-9]+)/;
        }
        next unless defined $n;
        $n += 0;
        if (exists $by{$n}) {
            $dup{$n} = 1;
            $by{$n} = $p if length($p) < length($by{$n});   # prefer the shorter path
        } else {
            $by{$n} = $p;
        }
    }
    for my $num (sort { $a <=> $b } keys %by) {
        print "$num", "\t", $by{$num}, "\n";
    }
    if (%dup) {
        printf STDERR "    注意: %d 个集号存在多份重名/同集文件, 每个集号取路径较短的一份\n", scalar keys %dup;
    }
'
ok=0
skipped=0
failed=0
planned=0

# merge_one DIR — merge a single drama folder; updates the global counters.
merge_one() {
    d=$1
    d=${d%/}
    base=${d##*/}
    case $base in
        .*|'*') return 0 ;;
    esac

    declared=$(printf '%s' "$base" | sed -n 's/.*[（(]\([0-9][0-9]*\)集[）)].*/\1/p')
    if [ "$scan" = "1" ] && [ -z "$declared" ]; then
        return 0
    fi

    : > "$tmpdir/eps.tsv"
    find "$d" -type f -print0 | perl -0 -e "$PERL_PARSE" >> "$tmpdir/eps.tsv" || true

    n_eps=$(LC_ALL=C grep -c '' "$tmpdir/eps.tsv" || true)
    if [ "$n_eps" -eq 0 ]; then
        echo "跳过: $base — 目录中没有视频文件"
        skipped=$((skipped + 1))
        return 0
    fi
    if [ "$n_eps" -eq 1 ] && [ "$single" = "0" ]; then
        echo "跳过: $base — 只找到 1 个视频文件 (需要 --single 才合并)"
        skipped=$((skipped + 1))
        return 0
    fi

    # The merge always produces MP4: step 2 remuxes to mp4 with +faststart,
    # and ffmpeg picks the muxer from this extension. Deriving it from the
    # first episode's extension made the output container flip between mp4
    # and matroska depending on episode order (and silently dropped
    # faststart for matroska).
    outdir=${out:-$(dirname "$d")}
    out_file="$outdir/${base}.mp4"

    missing=""
    over=""
    echo "短剧: $base"
    if [ -n "$declared" ]; then
        missing=$(awk -F'\t' -v total="$declared" '{n[$1+0]=1}
            END{m=""; c=0; for(i=1;i<=total;i++) if(!(i in n)) {c++;
                if(c<=10) m=m sprintf("%d ", i)}
            if(c>0) printf "缺失集号: %s%s(共 %d 个)", m, (c>10?"... ":""), c}' "$tmpdir/eps.tsv")
        over=$(awk -F'\t' -v total="$declared" '$1+0>total{printf "%d ", $1}' "$tmpdir/eps.tsv")
        echo "  集数: 实际 $n_eps 段 (目录声明 ${declared} 集)"
        [ -n "$missing" ] && echo "  $missing"
        [ -n "$over" ] && echo "  超出声明范围的集号: $over"
    else
        echo "  集数: 实际 $n_eps 段 (目录名未含（N集）标记, 按文件名数字排序)"
    fi

    if [ -e "$out_file" ] && [ "$force" = "0" ]; then
        echo "  已存在, 跳过: $out_file (使用 --force 覆盖)"
        skipped=$((skipped + 1))
        return 0
    fi
    echo "  输出: $out_file"

    if [ "$dry" = "1" ]; then
        planned=$((planned + 1))
        return 0
    fi

    mkdir -p "$outdir"

    # One video codec must apply to every episode for a lossless merge.
    # Mixed-h264/hevc drama folders (re-ripped subsets etc.) are rejected.
    # Audio parameters are held to the same rule further below.
    nc_h264=0
    nc_hevc=0
    nc_other=0
    nc_other_name=""
    a_noaudio=0
    a_profiles=""
    while IFS="$tab" read -r num path; do
        c=$(ffprobe -v error -select_streams v:0 \
                -show_entries stream=codec_name -of csv=p=0 "$path" 2>/dev/null | head -1)
        case "$c" in
            h264) nc_h264=$((nc_h264 + 1)) ;;
            hevc) nc_hevc=$((nc_hevc + 1)) ;;
            "")
                [ -z "$nc_other_name" ] && nc_other_name="无法读取"
                nc_other=$((nc_other + 1))
                ;;
            *)
                [ -z "$nc_other_name" ] && nc_other_name="$c"
                nc_other=$((nc_other + 1))
                ;;
        esac
        # tr -d ',': some streams (ac3) make ffprobe's csv writer emit a
        # trailing empty field.
        ac=$(ffprobe -v error -select_streams a:0 \
                -show_entries stream=codec_name -of csv=p=0 "$path" 2>/dev/null | head -1 | tr -d ',')
        if [ -z "$ac" ]; then
            a_noaudio=$((a_noaudio + 1))
        else
            ar=$(ffprobe -v error -select_streams a:0 -show_entries stream=sample_rate \
                    -of csv=p=0 "$path" 2>/dev/null | head -1 | tr -d ',')
            ah=$(ffprobe -v error -select_streams a:0 -show_entries stream=channels \
                    -of csv=p=0 "$path" 2>/dev/null | head -1 | tr -d ',')
            a_profiles="${a_profiles}${ac} ${ar}Hz ${ah}ch
"
            # A source-level A/V offset is preserved verbatim by a lossless
            # merge; surface it so the offending episode is obvious.
            vst=$(ffprobe -v error -select_streams v:0 -show_entries stream=start_time \
                    -of csv=p=0 "$path" 2>/dev/null | head -1 | tr -d ',')
            ast=$(ffprobe -v error -select_streams a:0 -show_entries stream=start_time \
                    -of csv=p=0 "$path" 2>/dev/null | head -1 | tr -d ',')
            avdiff=$(awk -v v="$vst" -v a="$ast" 'BEGIN {
                    if (v !~ /^-?[0-9.]+$/ || a !~ /^-?[0-9.]+$/) exit 1
                    d = a - v; if (d < 0) d = -d
                    if (d > 0.05) printf "%+.3f", a - v
                }' || true)
            if [ -n "$avdiff" ]; then
                echo "  注意: 第 $num 集源文件音画起始错位 ${avdiff}s (音频相对视频), 无损合并会原样保留"
            fi
        fi
    done < "$tmpdir/eps.tsv"
    if [ "$nc_h264" -gt 0 ] && [ "$nc_hevc" -gt 0 ]; then
        echo "  跳过: 集数间视频编码不一致 (h264 × $nc_h264 集, hevc × $nc_hevc 集)"
        echo "        无损 (-c copy) 拼接要求全部同一编码, 混合编码需先统一转码。"
        failed=$((failed + 1))
        return 0
    fi
    if [ "$nc_other" -gt 0 ]; then
        echo "  跳过: 有 $nc_other 集视频编码为 ${nc_other_name} (非 h264/hevc), 无法与其余集无损拼接"
        echo "        可用 --scan 对照各集排查, 混编短剧需先统一转码。"
        failed=$((failed + 1))
        return 0
    fi

    # Audio uniformity matters as much as video uniformity: the mpeg-ts
    # intermediate silently drops packets whose audio parameters differ
    # from the first episode's (a channel-count change loses a whole
    # episode's sound), and a codec mix only surfaces as a cryptic
    # aac_adtstoasc error at the final remux.
    if [ "$a_noaudio" -gt 0 ] && [ "$a_noaudio" -lt "$n_eps" ]; then
        echo "  跳过: $a_noaudio/$n_eps 集没有音频轨, 与有音频的集混拼会在合并文件中留下静默空洞"
        echo "        请剔除无音频的集, 或统一补齐音轨后重试。"
        failed=$((failed + 1))
        return 0
    fi
    if [ "$a_noaudio" -eq 0 ]; then
        a_uniq=$(printf '%s' "$a_profiles" | LC_ALL=C sort -u | grep -c . || true)
        if [ "$a_uniq" -gt 1 ]; then
            echo "  跳过: 集数间音频参数不一致 (无损拼接要求与视频编码一样完全统一):"
            printf '%s' "$a_profiles" | LC_ALL=C sort | uniq -c | sed 's/^/        /'
            echo "        声道数变化会被 TS 中间层静默丢弃整集音频, 采样率/编码混杂也会在部分播放器中错位; 需先统一转码。"
            failed=$((failed + 1))
            return 0
        fi
    fi

    # Detect the video codec so the TS conversion applies the right BSF.
    vbsf_flag=""
    if [ "$nc_hevc" -gt 0 ]; then
        vbsf_flag="-bsf:v hevc_mp4toannexb"
    elif [ "$nc_h264" -gt 0 ]; then
        vbsf_flag="-bsf:v h264_mp4toannexb"
    fi

    # Step 1: copy each episode into mpeg-ts, rebuilding monotonic timestamps.
    : > "$tmpdir/all.ts"
    : > "$tmpdir/err.txt"
    n_seg=0
    while IFS="$tab" read -r num path; do
        if ! ffmpeg -hide_banner -loglevel error -nostdin -fflags +genpts \
                -i "$path" -map 0:v:0 -map 0:a:0? \
                -c copy $vbsf_flag -avoid_negative_ts make_zero \
                -f mpegts - >> "$tmpdir/all.ts" 2>>"$tmpdir/err.txt"; then
            rm -f "$out_file"
            echo "  合并失败 (第 $num 段 TS 转封装出错, 已删除残缺输出), 错误:" >&2
            sed -n '1,5p' "$tmpdir/err.txt" >&2
            failed=$((failed + 1))
            return 0
        fi
        n_seg=$((n_seg + 1))
    done < "$tmpdir/eps.tsv"

    # Step 2: concatenate the TS segments and remux to mp4 (copy, no re-encode).
    if ! ffmpeg -hide_banner -loglevel error -nostdin \
            -i "$tmpdir/all.ts" \
            -c copy -bsf:a aac_adtstoasc -avoid_negative_ts make_zero \
            -movflags +faststart -y "$out_file" 2>>"$tmpdir/err.txt"; then
        rm -f "$out_file"
        echo "  合并失败 (TS 拼接回封装 mp4 出错, 已删除残缺输出), 错误:" >&2
        sed -n '1,5p' "$tmpdir/err.txt" >&2
        failed=$((failed + 1))
        return 0
    fi
    echo "  已合并 $n_seg 段 (无损重封装 + faststart)"
    ok=$((ok + 1))
    return 0
}

if [ "$scan" = "1" ]; then
    for d in "$src"/*/; do
        [ -d "$d" ] || continue
        merge_one "$d"
    done
else
    while IFS= read -r d; do
        merge_one "$d"
    done <<EOF
$drama_dirs
EOF
fi

if [ "$dry" = "1" ]; then
    echo "完成 (dry-run): 计划合并 $planned 个短剧, 跳过 $skipped 个。"
else
    echo "完成: 合并成功 ${ok}, 跳过 ${skipped}, 失败 ${failed} (共 $n_dirs 个短剧)。输出目录: ${out:-与各短剧目录同级}"
fi

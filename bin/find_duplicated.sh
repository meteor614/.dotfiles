#!/bin/sh

find_opt="! -path '*/@eaDir*' ! -path '*/.git/*'"
find_size_opt=""
#find_size_opt="-size +4k"
dir="."
if [ x$1 != x ]; then
    dir="$1"
fi
if [ x$2 == x-size ] && [ x$3 != x ]; then
    find_size_opt="-size $3"
    echo "find_size_opt: ${find_size_opt}"
fi

type parallel >/dev/null 2>&1 || alias parallel='xargs -P 16'
type gfind >/dev/null 2>&1 && alias find='gfind'
type guniq >/dev/null 2>&1 && alias uniq='guniq'
md5sum=md5sum
type gmd5sum >/dev/null 2>&1 && md5sum='gmd5sum'

find "${dir}" ${find_opt} ${find_size_opt} -not -empty -type f -printf "%s\n" | sort -rn |uniq -d | parallel -I{} -n1 find "${dir}" ${find_opt} -type f -size {}c -print0 | parallel -0 $md5sum -b | sort | uniq -w32 --all-repeated=separate | cut -b 35-

#find "${dir}" ${find_opt} ${find_size_opt} -not -empty -type f -printf "%s\n" | sort -rn |uniq -d | parallel -I{} -n1 find "${dir}" ${find_opt} -type f -size {}c -print0 | parallel -0 "xxd -l 16 -ps {} | awk -v v={} '{print \$0\"  \"v}'" | sort | uniq -w32 -D | cut -b 35- | parallel $md5sum -b | sort | uniq -w32 --all-repeated=separate | cut -b 35-

#find ! -path '*/@eaDir*' -not -empty -type f -printf "%s\n" | sort -rn |uniq -d | parallel -I{} -n1 find ! -path '*/@eaDir*' -type f -size {}c -print0 | parallel -0 md5sum | sort | uniq -w32 --all-repeated=separate | cut -b 36-

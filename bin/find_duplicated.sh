#!/bin/sh

find_opt="! -path '*/@eaDir/*' ! -path '*/.git/*'"
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

find "${dir}" ${find_opt} ${find_size_opt} -not -empty -type f -printf "%016s\t%h/%f\n" | grep -v '/@eaDir/' | sort -rn -k1 | uniq -w16 -D | cut -f2 | parallel -P 16 $md5sum -b | sort | uniq -w32 --all-repeated=separate | cut -b 35-


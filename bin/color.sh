#!/bin/bash

cs="31:33:35:32"
if [ x$1 != x ]; then
    cs="$1"
fi
#awk 'BEGIN{split("33:31",c,/:/)}{printf "\033[%sm%s\033[0m\n", c[NR % length(c) + 1], $0}'
awk "BEGIN{split(\"$cs\",c,/:/)}{printf \"\033[%sm%s\033[0m\n\", c[NR % length(c) + 1], \$0}"

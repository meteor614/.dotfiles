#!/bin/bash

org_cmd="$0 $@"
ARGS=`getopt -o "ie:t:v:c:h" -l "ignore-case,regexp:,context:,invert-match:cmd:help" -n "$0" -- "$@"`
 
eval set -- "${ARGS}"

grep_cmd="grep -w Running"
grep_opts=''
ctx_opt=''
shell_cmd='/bin/bash'

while true; do
    case "${1}" in
        -i|--ignore-case)
        shift;
        grep_opts="${grep_opts} -i"
        ;;
        -t|--context)
        shift;
        if [[ -n "${1}" ]]; then
            ctx_opt="--context=$1"
            shift;
        fi
        ;;
        -v|--invert-match)
        shift;
        if [[ -n "${1}" ]]; then
            grep_cmd="${grep_cmd}|grep ${grep_opts} -v $1"
            shift;
        fi
        ;;
        -e|--regexp)
        shift;
        if [[ -n "${1}" ]]; then
            grep_cmd="${grep_cmd}|grep ${grep_opts} -e $1"
            shift;
        fi
        ;;
        -c|--cmd)
        shift;
        if [[ -n "${1}" ]]; then
            shell_cmd="$1"
            shift;
        fi
        ;;
        -h|--help)
        shift;
        echo "usage:"
        echo "  $0 pods_name [node_patten ...] [-e/-v node_patten]... [-i] [-t context]"
        echo "      pods_name                               Specify kubectl pods name"
        echo "      -e pattern, --regexp=pattern            Specify a pattern used during the search"
        echo "      -v pattern, --invert-match=pattern      Selected nodes are those not matching any of the specified patterns"
        echo "      -i, --ignore-case                       Perform case insensitive matching"
        echo "      -t ctx, --context=ctx                   kubectl context"
        echo "      -c cmd, --cmd=cmd                       command line to exec"
        exit
        ;;
        --)
        shift;
        break;
        ;;
    esac
done

pods_patten="$1"
shift
for v in $@; do
    grep_cmd="grep $v | ${grep_cmd}"
done
cmd="kubectl get pods -n \"${pods_patten}\" ${ctxopt} | $grep_cmd | awk '{printf \" \"\$1}'"
echo $cmd
nodes=`eval $cmd`
arr=($nodes)
if [ l${#arr[@]} == l0 ];then
    kubectl config get-contexts
    echo "node ${node_patten} not found, try to contexts use command: "
    kubectl config get-contexts |grep '^ '|awk "{print \"\t$org_cmd -t \"\$1}"
    exit
fi
echo "connecting $nodes"
#xpanes -c "kubectl ${ctxopt} exec -it -n ${pods_patten} {} -- ${shell_cmd}" $nodes
xpanes -c "kubectl ${ctxopt} exec -it -n ${pods_patten} {} -- ${shell_cmd} ; read -n 1; exit" $nodes


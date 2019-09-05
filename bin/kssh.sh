#!/bin/sh

if [ $# -lt 2 ];then
    echo "usage: $0 pods_patten node_patten [context]"
    echo "   $0 auto fetch-fetch-"
    exit
fi
if [ $# -eq 3 ];then
    ctxopt="--context=$3"
else
    ctxopt=""
fi
pods_patten="$1"
node_patten="$2"
nodes=`kubectl get pods -n "${pods_patten}" ${ctxopt}|grep "${node_patten}"|grep 'Running'|awk '{printf " "$1}'`
arr=($nodes)
if [ l${#arr[@]} == l0 ];then
    kubectl config get-contexts
    #echo "node ${node_patten} not found, try to contexts use command: kubectl config use-context NAME"
    #kubectl config get-contexts |grep '^ '|awk '{print "\tkubectl config use-context "$1}'
    echo "node ${node_patten} not found, try to contexts use command: "
    kubectl config get-contexts |grep '^ '|awk "{print \"\t$0 $1 $2 \"\$1}"
    exit
fi
echo "connecting $nodes"
xpanes -c "kubectl ${ctxopt} exec -it -n ${pods_patten} {} -- /bin/bash" $nodes

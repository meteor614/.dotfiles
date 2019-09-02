#!/bin/sh

if [ $# -ne 2 ];then
    echo "usage: $0 pods_patten node_patten"
    echo "   $0 auto fetch-fetch-"
    exit
fi
pods_patten="$1"
node_patten="$2"
nodes=`kubectl get pods -n "${pods_patten}"|grep "${node_patten}"|grep 'Running'|awk '{printf " "$1}'`
#echo "connecting $nodes"
xpanes -c "kubectl exec -it -n ${pods_patten} {} -- /bin/bash" $nodes

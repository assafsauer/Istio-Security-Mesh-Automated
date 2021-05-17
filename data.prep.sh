#!/bin/bash

namespace=default
# get pod selectors from namespace
kubectl get deployment -owide -n $namespace |  awk '{print $8}' |grep -v SELECTOR |sed 's/^.*=//' > pod.selector.list

# get IP from namespace
kubectl get pod --selector=$line -n $namespace -owide |  awk '{print $6}' | grep -v NAME  |grep -v IP > ip.list

# merge selectors and ips to one file 
paste pod.selector.list ip.list  > pod.selector.ip.list

# replace all the ips in file.txt to app selectors
while IFS= read -r line; do   app=$(echo $line | awk '{print $1}')  ; ip=$(echo $line | awk '{print $2}') ; sed -i "s/$ip/$app/g" file.txt ; let "a++"; done <  pod.selector.ip.list


sed 's/^[^ ]* //' file.txt | awk '{$4=$4=""; print $0}' | awk '!seen[$0]++' |  grep -v '\([0-9]\+\.\)\{3\}[0-9]\+'  > uniqe.list
# sed 's/^[^ ]* //' file.txt | awk '{$4=$4=""; print $0}' | awk '!seen[$0]++' |  grep -v '\([0-9]\+\.\)\{3\}[0-9]\+' | tr -s '[:blank:]' ',' > uniqe.list




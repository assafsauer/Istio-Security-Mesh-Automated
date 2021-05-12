#!/bin/bash

namespace=default

# get pod list
kubectl get pods -n $namespace |  awk '{print $1}' | grep -v NAME > pods.list

# activate ISTIO log on each POD 
while IFS= read -r line; do  echo $line; kubectl logs $line  -c istio-proxy -n  $namespace  >>  logs.istio; let "a++"; done < pods.list

#  convert to CSV
cat logs.istio | tr -s '[:blank:]' ',' |grep 'POST\|GET' > logs.csv


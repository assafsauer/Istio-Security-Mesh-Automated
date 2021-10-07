#!/bin/bash

namespace=wiz
istioingress=35.204.232.183
frontend=web:80


# get pod list
kubectl get pods -n $namespace |  awk '{print $1}' | grep -v NAME > pods.list


# activate ISTIO log on each POD 
while IFS= read -r line; do  echo $line; kubectl logs $line  -c istio-proxy -n  $namespace  >>  logs.istio; let "a++"; done < pods.list

# change all the ISTIO ingress ip with the web service (in the logs the ingress is IP and not POD name).
cat logs.istio | sed  "s/${istioingress}/${frontend}/g" |sed 's/"//g' > logs.istio-2


#### cleanup of the logs 
cat logs.istio-2 |grep 'POST\|GET' |grep -v PassthroughCluster | grep -v "HTTP/1.0"|  awk  {'print $2" "$3" "$17'}| grep -E ':[0-9]' | sed -e 's/,\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}//g' | tr -d '"' |sed 's/:[0-9]*//' |  grep -E -o -v "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" > final.auth.log

rm manifest/auth/*.yaml

#### remove last folder from the path
cat final.auth.log |sed 's?^\(.*\)/.* \(.*\)$?\1/ \2?' > final.auth.log-2


#### remove another last folder from the path
cat final.auth.log-2 |sed 's?^\(.*\)/.* \(.*\)$?\1/ \2?' > final.auth.log-3


#### remove another last folder from the path
cat final.auth.log-3 |sed 's?^\(.*\)/.* \(.*\)$?\1/ \2?' > final.auth.log-4

sort final.auth.log-4 |uniq | grep -v " / " | grep -v "//" |uniq > final.auth.log-5


#### create policies

a=1
while IFS="" read -r line 
do
  method=$(echo $line | awk '{print $1}') 
  path=$(echo $line | awk '{print $2}' | sed 's/\"//')
  pod=$(echo $line | awk '{print $3}')

cat <<EOF > manifest/auth/auth.$pod.$a.yaml
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: auth.$pod$a
spec:
  selector:
    matchLabels:
      app: $pod
  action: ALLOW 
  rules:
  - to:
    - operation:
        methods: ["$method"]
        paths: ["$path*"]
EOF
  let "a++"
done < final.auth.log-5

#!/bin/bash

mkdir networkpolicies 
while IFS="" read -r line 
do
  destpod=$(echo $line | awk '{print $1}')  ; port=$(echo $line | awk '{print $2}')  
  port=$(echo $line | awk '{print $2}')
  srcpod=$(echo $line | awk '{print $3}')
cat <<EOF > networkpolicies/netp.$destpod.$srcpod.$port.yaml 
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: netp.$destpod.$srcpod.$port 
spec:
  podSelector:
    matchLabels:
      app: $destpod 
  ingress:
    - from:
      - podSelector:
          matchLabels:
            app: $srcpod
      ports:
        - protocol: TCP
          port: $port
EOF
  let "a++"
done < uniqe.list

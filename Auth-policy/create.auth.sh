#!/bin/bash
istioingress=10.9.0.22
frontend=frontend

# clean file and filter uniqe rules
cat logs.csv |sed 's/,/ /g' | sed "s/:.*//" | sed 's/\/\//\//g'|  awk '!seen[$0]++' | awk '{if (NR!=1) {print}}'  > auth.log
cat  auth.log |sed  "s/${istioingress}/${frontend}/g" |sed 's/"//g' > final.auth.log 


a=1
mkdir authorizations 
while IFS="" read -r line 
do
  method=$(echo $line | awk '{print $1}') 
  path=$(echo $line | awk '{print $2}' | sed 's/\"//')
  pod=$(echo $line | awk '{print $3}')

cat <<EOF > authorizations/auth.$pod.$a.yaml
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
done < final.auth.log

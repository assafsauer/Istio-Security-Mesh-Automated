# Automation for Service Mesh Authorizationand and Network policies.  

####  the combination of Networkpolices and Authorization policies might be the ultimate approach for securing microservices!   however , manually configuring it is almost infeasible (specialy when there are hundreds of services and containers involved).  the idea behind this repository is to provide full automation for  Microsegmentation and Authorization with minimum probability of human errors and false postivie.  
as results , even if a hacker get access to a privileged POD , he still authrized only for a specific http method (L7) and for a specific Service and port (L4).. This leaves him with a very limited options to impact/compromise other services.

#### #### please note that the repository is stil underconstruction.   AuthorizationPolicy policy tested and proved to be reliable. i still need to improve the networkpolicies identification. ####

![Test Image 1](https://github.com/assafsauer/Istio-Security-Mesh-Automated/blob/main/diagram-3.png) 

#### so , how does it works? <br/>
1) the script aggregate the envoy access logs from all pods in a namespace to a centralized  log <br/>
2) than , it is parsing the log to extract only the relevant ifnormation , for example: <br/>

*final AuthorizationPolicy logs: <br/>
POST /hipstershop.AdService/ adservice <br/>
POST /hipstershop.CartService/ cartservice <br/>
POST /hipstershop.ProductCatalogService/ productcatalogservice <br/>
POST /hipstershop.CurrencyService/ currencyservice <br/>
POST /hipstershop.ShippingService/ shippingservice <br/>


*final Networkpolices logs: <br/>
ad,9555,frontend <br/>
cart,7070,frontend <br/>
cart,7070,checkoutservice <br/>
productcatalog,3550,checkoutservice <br/>
currency,7000,checkoutservice <br/>

3) based on the final logs , the script will create the following policies in yaml format: 

```diff
AuthorizationPolicy: each app (both backend and external ingress) will be restricted by HTTP method and folders

root@jump-5:/home/sauer/Istio-Security-Mesh-Automated/Auth-policy# cat authorizations/auth.adservice.1.yaml 
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: auth.adservice1
spec:
  selector:
    matchLabels:
      app: adservice
  action: ALLOW 
  rules:
  - to:
    - operation:
        methods: ["POST"]
        paths: ["/hipstershop.AdService/*"]
```

```diff    
Networkpllicies: each service will be microsegment for ingress traffic 

kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: netp.ad.frontend.9555 
spec:
  podSelector:
    matchLabels:
      app: ad 
  ingress:
    - from:
      - podSelector:
          matchLabels:
            app: frontend
      ports:
        - protocol: TCP
          port: 9555
```
####  The diagram below illustrate the flow

#![Test Image 1](https://github.com/assafsauer/Istio-sec-automation/blob/main/istio%20diagram%202.png) 

![image](https://user-images.githubusercontent.com/22165556/120425247-26d14580-c36e-11eb-89f3-4d3c965f35f3.png)


```diff
### Notes: ###

1) the code is aggrigating/parsing the default structure of Encoy access log , Customising the istio access logs , might damage the script.
Envoy official Access logging document: 
https://www.envoyproxy.io/docs/envoy/latest/configuration/observability/access_log/usage#default-format-string

2) kubectil is mandatory for the script execution. 

3) install:
pip3 install networkx
pip3 install pandas
pip3 install pexpect --upgrade --ignore-installed pexpect
pip3 install pyvis

4) for the moment MTLS and Networkpolicies are not supported, you need to disable MTLS by appying PeerAuthentication to the namespace:

apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: disable
spec:
  mtls:
    mode: DISABLE 

5) the repository is stil underconstruction.   AuthorizationPolicy policy tested and proved to be reliable. i still need to improve the networkpolicies identification
```

**##### automating Networkpolices is simple of that:** 
```diff

git clone 

kubectl apply -f demoapp/

edit your namespace in create.istio.logs.sh and data.prep.sh
namespace=default


browse the app , or run traffic generator 

/home/sauer/Istio-Security-Mesh-Automated# cd Net-policies/

python3 netp-main.py

kubectl apply -f networkpolicies/ -n default

as Restuls:


root@jump-5:/home/sauer/istio2# kubectl get networkpolicies
NAME                                             POD-SELECTOR         AGE
netp.ad.frontend.9555                            app=ad               6s
netp.cart.checkoutservice.7070                   app=cart             6s
netp.cart.frontend.7070                          app=cart             6s
netp.checkout.frontend.5050                      app=checkout         6s
netp.currency.checkoutservice.7000               app=currency         6s
netp.currency.frontend.7000                      app=currency         6s
netp.email.checkoutservice.5000                  app=email            6s
netp.payment.checkoutservice.50051               app=payment          6s
netp.productcatalog.checkoutservice.3550         app=productcatalog   6s
netp.productcatalog.frontend.3550                app=productcatalog   6s
netp.productcatalog.recommendationservice.3550   app=productcatalog   6s
netp.recommendation.frontend.8080                app=recommendation   6s
netp.shipping.checkoutservice.50051              app=shipping         6s
netp.shipping.frontend.50051                     app=shipping         6s
```


**##### automating Authorization Policy is simple of that:** 
```diff
/home/sauer/Istio-Security-Mesh-Automated# cd Auth-policy/

add your namespace to "create.istio.logs.sh" (namespace=default)

edit "create.auth.sh" and add your ISTIOingress IP and your frontend POD Selector (the POD that ISTIO VirtualService pointing to)
istioingress=10.9.0.22
frontend=frontend


python3 auth-main.py

kubectl apply -f authorizations/

as Restuls:

root@jump-5:/home/sauer/Istio-Security-Mesh-Automated/Auth-policy# kubectl get AuthorizationPolicy
NAME                           AGE
auth.adservice1                6m21s
auth.cartservice2              6m21s
auth.checkoutservice8          6m21s
auth.currencyservice4          6m21s
auth.emailservice7             6m20s
auth.frontend10                6m20s
auth.frontend12                6m20s
auth.frontend13                6m20s
auth.frontend14                6m20s
auth.frontend9                 6m20s
auth.paymentservice6           6m20s
auth.productcatalogservice3    6m20s
auth.recommendationservice11   6m20s
auth.shippingservice5          6m20s
root@jump-5:/home/sauer/Istio-Security-Mesh-Automated/Auth-policy# 
```
```diff
Create Diagram:
python3 diagram.py
cp AssafNetworkGraph.html /var/www/html/
chmod 775 /var/www/html/*
```

![image](https://user-images.githubusercontent.com/22165556/119303148-8be9b480-bc65-11eb-9e79-e6175aa4815b.png)



```diff

Test results (HEAD METHOD Forbidden for frontend , blocked by policy auth.frontend11)

apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: auth.frontend11
spec:
  selector:
    matchLabels:
      app: frontend
  action: ALLOW 
  rules:
  - to:
    - operation:
        methods: ["GET"]
        paths: ["/product/*"]

root@jump-5:/home/sauer/Istio-Security-Mesh-Automated/Auth-policy# curl -i --request HEAD -H 'Cache-Control: no-cache'  http://10.9.0.36/product/66VCHSJNUP
Warning: Setting custom HTTP method to HEAD with -X/--request may not work the 
Warning: way you want. Consider using -I/--head instead.
HTTP/1.1 200 OK
set-cookie: shop_session-id=115c5b9b-4928-40c3-8e82-4d36bcadaf27; Max-Age=172800
date: Sat, 22 May 2021 10:49:49 GMT
content-type: text/html; charset=utf-8
x-envoy-upstream-service-time: 70
server: istio-envoy
transfer-encoding: chunked


root@jump-5:/home/sauer/Istio-Security-Mesh-Automated/Auth-policy# kubectl create -f authorizations/
authorizationpolicy.security.istio.io/auth.169.254.169.25415 created
authorizationpolicy.security.istio.io/auth.adservice1 created
authorizationpolicy.security.istio.io/auth.cartservice2 created
authorizationpolicy.security.istio.io/auth.checkoutservice8 created
authorizationpolicy.security.istio.io/auth.currencyservice4 created
authorizationpolicy.security.istio.io/auth.emailservice7 created
authorizationpolicy.security.istio.io/auth.frontend11 created
authorizationpolicy.security.istio.io/auth.frontend12 created
authorizationpolicy.security.istio.io/auth.frontend13 created
authorizationpolicy.security.istio.io/auth.frontend14 created
authorizationpolicy.security.istio.io/auth.frontend9 created
authorizationpolicy.security.istio.io/auth.paymentservice6 created
authorizationpolicy.security.istio.io/auth.productcatalogservice3 created
authorizationpolicy.security.istio.io/auth.recommendationservice10 created
authorizationpolicy.security.istio.io/auth.shippingservice5 created
root@jump-5:/home/sauer/Istio-Security-Mesh-Automated/Auth-policy# 
root@jump-5:/home/sauer/Istio-Security-Mesh-Automated/Auth-policy# 


root@jump-5:/home/sauer/Istio-Security-Mesh-Automated/Auth-policy# curl -i --request HEAD -H 'Cache-Control: no-cache'  http://10.9.0.36/product/66VCHSJNUP
Warning: Setting custom HTTP method to HEAD with -X/--request may not work the 
Warning: way you want. Consider using -I/--head instead.
HTTP/1.1 403 Forbidden
content-length: 19
content-type: text/plain
date: Sat, 22 May 2021 10:50:24 GMT
server: istio-envoy
x-envoy-upstream-service-time: 0

```

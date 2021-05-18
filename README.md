# Automation for Service Mesh Authorizationand and Networkplicies.  

####  the combination of Networkpolices and Authorization policies might be the ultimate approach for securing microservices!   however , manually configuring it is almost infeasible (specialy when there are hundreds of services and containers involved).  the idea behind this repository is to provide full automation for  Microsegmentation and Authorization with minimum probability of human errors and false postivie.    as results , even if a hacker get access to a privileged POD , he still authrized only for a specific http method (L7) for a specific Service and port (L4).. This will leave him with very limited options to impact other services.

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

![Test Image 1](https://github.com/assafsauer/Istio-sec-automation/blob/main/istio%20diagram%202.png) 



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

```

**##### automating Networkpolices is simple of that:** 
```diff

git clone 

kubectl apply -f demoapp/

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




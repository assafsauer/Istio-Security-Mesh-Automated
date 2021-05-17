#  Automation of Networkpolicies and Authorization for Microservice applications

the combination of Networkpolices and Authorization policies might be the ultimate approach for securing microservices! <br/>
however , manually configuring it is almost infeasible (specialy when there are hundreds of services and containers involved). <br/>
The idea behind this repository is to automate Microsegmentation and Authorization with minimum probability of human error and false postivie.   <br/>

```diff
functionlty:  
1) automate Network Policie based on the access logs  
2) automate Authorization policies based on the access logs  
```
![Test Image 1](https://github.com/assafsauer/Istio-sec-automation/blob/main/istio%20diagram%202.png) 



```diff
Notes:
1) the code is aggrigating/parsing the default structure of Encoy access log , Customising the istio access logs , might damage the script.
Envoy official Access logging document: 
https://www.envoyproxy.io/docs/envoy/latest/configuration/observability/access_log/usage#default-format-string

2) kubectil is mandatory for the script execution. 

```

**##### automating Networkpolices is simple of that:** 
```diff

kubectl apply -f demoapp/

browse the app , or run traffic generator 

python3 Istio-log-processing.py

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

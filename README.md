# Istio-sec-automation


the combination of Networkpolices and Authorization policies might be the ultimate approach for securing/isolting microservices.
however , Manually building such a configuraiton is almost infeasible,  specialy  when there hunderds of services involved..
The idea behind this repository is to automate Microsegmentation/networkpolicies and ISTIO Authorization based on ISTIO Logs.

plan: 

1) automate Network Policie based on ISTIO logs (completed) 
2) automate Authorization policies based on ISTIO logs (under construction)
3) Create Traffic Generator based on the traffic logs for automating tests (under construction)


**##### automating Networkpolices is simple of that:** 
 
python3 Istio-log-processing.py

kubectl apply -f networkpolicies/ -n default

as Restuls:

```diff
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

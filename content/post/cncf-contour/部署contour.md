---
layout:     post 
slug:      "getting-started-with-contour"
title:      "contour部署"
subtitle:   ""
description: ""
date:       2024-04-04
author:     "梁远鹏"
image: "img/banner-pexels.jpg"
published: false
tags:
    - cncf
    - gateway
    - contour
    - kubernetes
categories: 
    - cloudnative
---    

# helm部署  

```shell
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install contour bitnami/contour -n projectcontour --set replicaCount=1 --create-namespace  
```


```
oem@lan:~/repo/git/kubekey$ k get po -n contour
NAME                              READY   STATUS    RESTARTS   AGE
contour-contour-89cb6fdf6-p7pnq   1/1     Running   0          100s
contour-envoy-jdhqd               1/2     Running   0          101s
```


```shell
kubectl apply -f https://projectcontour.io/examples/httpbin.yaml
kubectl get po,svc,ing -l app=httpbin
```


```shell
kubectl patch ingress httpbin -p '{"spec":{"ingressClassName": "contour"}}'
```


```shell
# If using YAML
$ kubectl -n projectcontour port-forward service/envoy 8888:80

# If using Helm
$ kubectl -n projectcontour port-forward service/my-release-contour-envoy 8888:80

# If using the Gateway provisioner
$ kubectl -n projectcontour port-forward service/envoy-contour 8888:80
```


In a browser or via curl, make a request to http://local.projectcontour.io:8888 (note, local.projectcontour.io is a public DNS record resolving to 127.0.0.1 to make use of the forwarded port). You should see the httpbin home page.

Congratulations, you have installed Contour, deployed a backend application, created an Ingress to route traffic to the application, and successfully accessed the app with Contour!

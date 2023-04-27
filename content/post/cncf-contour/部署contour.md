---
layout:     post 
slug:      "contour-deploy"
title:      "contour部署"
subtitle:   ""
description: ""
date:       2021-12-29
author:     "梁远鹏"
image: "img/banner-pexels.jpg"
published: false
tags:
    - cncf
    - gateway
    - contour
categories: 
    - cloudnative
---    

# helm部署  

helm repo add bitnami https://charts.bitnami.com/bitnami

helm install contour bitnami/contour -n contour --set replicaCount=1 --create-namespace  



```
oem@lan:~/repo/git/kubekey$ k get po -n contour
NAME                              READY   STATUS    RESTARTS   AGE
contour-contour-89cb6fdf6-p7pnq   1/1     Running   0          100s
contour-envoy-jdhqd               1/2     Running   0          101s
```


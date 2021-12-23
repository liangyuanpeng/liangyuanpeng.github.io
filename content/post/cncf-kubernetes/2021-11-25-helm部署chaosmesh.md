---
layout:     post 
slug:      "deploy-chaosmesh-with-helm"
title:      "helm部署chaosmesh"
subtitle:   ""
description: ""
date:       2021-11-25
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1635353670/hugo/banner/pexels-helena-lopes-2253275.jpg"
published: true
tags:
    - cncf 
    - tech
    - chaosmesh
    - kubernetes
    - helm
categories: [ kubernetes ]
---

# 

```
helm repo add chaos-mesh https://charts.chaos-mesh.org
```

```
helm install chaos-mesh chaos-mesh/chaos-mesh -n=chaos-testing --version 2.0.4
``` 

```shell
lan@lan:~$ k get po -n chaos-testing
NAME                                        READY   STATUS              RESTARTS   AGE
chaos-controller-manager-5f7c8c4569-prc5s   0/1     ContainerCreating   0          40s
chaos-daemon-bz859                          0/1     ContainerCreating   0          40s
chaos-dashboard-5f7b6b9b6b-ml22l            0/1     ContainerCreating   0          40s

```

# 最后的最后  

本文其实就是按照官方文档操作了一边,就让chaosmesh部署起来了.  

编写本篇文时,参照的文档是2.0.4版本.

https://chaos-mesh.org/docs/production-installation-using-helm/

#  注意
本文还在持续创作当中,敬请期待.

---
layout:     post 
slug:   "more-type-for-build-kind-node"
title:      "构建kind-node镜像的更多选择"
subtitle:   ""
description: ""  
date:       2024-05-28
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: false
tags: 
    - kubernetes
    - cncf
    - kind
    - kubernetes-sigs
categories: 
    - kubernetes
---


Kind 构建的node镜像,多架构?

```shell
runner@fv-az1247-794:~/kind$ time kind build node-image v1.29.4
Detected build type: "release"
Building using release "v1.29.4" artifacts
Starting to build Kubernetes
Downloading "https://dl.k8s.io/v1.29.4/kubernetes-server-linux-amd64.tar.gz"
Finished building Kubernetes
Building node image ...
Building in container: kind-build-1716818556-1578232663
Image "kindest/node:latest" build completed.

real    2m12.434s
user    0m7.132s
sys     0m3.011s
```

```shell
runner@fv-az1247-794:~$ ls -allh kubernetes-server-linux-amd64.tar.gz
-rw-r--r-- 1 runner docker 365M Apr 16 21:40 kubernetes-server-linux-amd64.tar.gz
```

文件有300多兆

这是在github action 上的时间.还是比较快的

也可以直接指定 url.

```shell
runner@fv-az1247-794:~/kind$ kind build node-image --type url https://dl.k8s.io/v1.29.4/kubernetes-server-linux-amd64.tar.gz
Building using URL: "https://dl.k8s.io/v1.29.4/kubernetes-server-linux-amd64.tar.gz"
Starting to build Kubernetes
Downloading "https://dl.k8s.io/v1.29.4/kubernetes-server-linux-amd64.tar.gz"
```

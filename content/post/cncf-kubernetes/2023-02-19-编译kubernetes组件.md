---
layout:     post 
slug:      "compile-kubernetes"
title:      "编译kubernetes组件"
subtitle:   ""
description: ""
date:       2023-02-19
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1635353670/hugo/banner/pexels-helena-lopes-2253275.jpg"
published: true
wipnote: true
tags:
    - k8s
    - kubernetes
    - cncf
    - golang
categories: [ kubernetes ]
---

# 

kubernetes 发展到了今天(2023-02-19),编译 kubernetes 已经是一件很简单的事情,唯一的门槛就是需要有适合的内存资源以及编译需要用到的 registry.k8s.io 中的镜像.


# 编译

## 解决 registry.k8s.io 镜像问题

由于有 lank8s.cn 服务,因此这个问题已经不再是问题,不过是动动手指头将 registry.k8s.io 修改为 registry.lank8s.cn 就可以了.

```shell
KUBE_BUILD_PLATFORMS=linux/amd64  make all WHAT=cmd/kube-apiserver   GOFLAGS=-v GOGCFLAGS="-N -l"
```

```shell
KUBE_BUILD_PLATFORMS=linux/amd64 make quick-release
```

```shell

```

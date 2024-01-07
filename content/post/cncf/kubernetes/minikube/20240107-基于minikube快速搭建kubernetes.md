---
layout:     post 
slug:      "quickstart-kubernetes-with-minkube"
title:      "基于minikube快速搭建kubernetes"
subtitle:   ""
description: "基于minikube快速搭建kubernetes. "
date:       2024-01-07
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags:
    - kubernetes
    - CloudNative
    - lank8s.cn
    - kubeadm
    - cncf
    - minikube
categories: 
    - kubernetes
---

# 本文实现目标 

本文主要使用 minikube 快速部署一个单机的 kubernetes.

# 总结  

到目前为止基于 minikube 使用国内网络轻松部署起一个 kubernetes 了,`lank8s.cn`是我个人在维护的一个`registry.gcr.io`镜像的代理,还有一个`gcr.lank8s.cn`可以代替`gcr.io`来拉取镜像.  

详情可以看看[lank8s.cn服务](https://liangyuanpeng.com/post/service-lank8s.cn/)
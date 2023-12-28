---
layout:     post 
slug:      "question-list-of-kubernetes"
title:      "[长期更新]kubernetes问题列表记录"
subtitle:   ""
description: "kubernetes问题列表记录,欢迎投稿."
date:       2023-05-04
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags:
    - k8s
    - cncf
    - kubernetes
categories: 
    - cloudnative
    - kubernetes
---


# 说明

本文主要收集常见场景下 kubernetes 遇到的一些常见问题,欢迎对本文进行投稿你认为好的场景或问题.

## 如何保证 sidecar 先于 app 容器销毁

通过信号方式
TODO 完善展开


# 将kubeconfig文件转换成证书文件

对于我来说主要的场景是将默认的管理员 kubeconfig 内容转换成证书文件,然后放在 nginx/envoy 来代理 kubernetes 请求,减少双向证书认证带来的繁琐.

```shell
kubectl config view --minify --flatten -o json | jq ".clusters[0].cluster.\"certificate-authority-data\"" | sed 's/\"//g' | base64 --decode >> ca.crt 
kubectl config view --minify --flatten -o json | jq ".users[0].user.\"client-certificate-data\"" | sed 's/\"//g' | base64 --decode >> client.crt 
kubectl config view --minify --flatten -o json | jq ".users[0].user.\"client-key-data\"" | sed 's/\"//g' | base64 --decode >> client.key 
```

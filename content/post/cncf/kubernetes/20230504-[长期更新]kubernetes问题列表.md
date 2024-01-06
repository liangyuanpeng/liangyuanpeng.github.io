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


# IP固定的研究环境

目前在我个人的研究环境下,我经常是使用备份好的 Etcd 数据来恢复某些特定场景的 kubernetes 集群,但有一个问题是新的虚拟机 hostname 和 IP 可能和备份数据中的 kubernetes hostname 和 IP 是不一样的,这时候就需要使用创建虚拟网卡,然后将 kubernetes 服务绑定到虚拟网卡的IP上,但这只设计到单节点的集群,还没有多节点的需求.

这适用于 kubeadm 和 K3s 来恢复 kubernetes 的场景.
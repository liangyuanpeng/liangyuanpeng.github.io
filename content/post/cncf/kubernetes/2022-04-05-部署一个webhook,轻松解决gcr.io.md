---
layout:     post 
slug:      "resolve-gcr.io-with-webhook-of-repalcer"
title:      "部署一个webhook,轻松解决gcr.io"
subtitle:   ""
description: ""
date:       2022-04-05
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags:
    - lank8scn 
    - tech
    - kubernetes
categories: [ kubernetes ]
---

# ⚠这个 webhook 当前已经不再推荐使用⚠

⚠这个 webhook 当前已经不再推荐使用⚠

⚠推荐的做法是设置镜像仓库镜像,参考 [kind(containerd) 的配置](https://liangyuanpeng.com/post/cncf-kubernetes/run-k8s-with-kind/#%E5%90%84%E7%B1%BB%E7%8E%AF%E5%A2%83%E7%9A%84%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6)⚠


# 前言  

`lank8s.cn` 已经正常运营几年了，目前可以看到每天都有人在使用 `gcr.lank8s.cn` 来拉取 `gcr.io` 的镜像,避免了墙带来的困扰,不过当需要拉取的不同的镜像多了之后可能会显得有些繁琐，每次都需要手动的将 `gcr.io` 修改为 `gcr.lank8s.cn` ,作为软件工程师那必须懂得为自己减少不必要的工作量,于是 `replacer` 这个 Mutating Webhook 就出现了.

其实我已经使用`replacer`有一段时间了,每次使用 `Kubekey` 创建一个新的K8S实验环境时,都会配置一个addon来自动化的安装`replacer`(没错,你可以用 `Helm` 来安装这个 webhook),不过拖着这篇文章的产出，但是现在是时候了!  

# 部署  

## yaml方式  

```shell
git clone git@github.com:liangyuanpeng/replacer.git
cd replacer
kubectl create namespace replacer
kubectl apply -f deploy -n replacer
```  

很快你就会看到在 replacer 这个 namespace 下有一个 Deployment 部署好了,因为默认是使用ghcr.io的镜像,因此如果拉取镜像太慢的话可以把 `ghcr.io`修改为 `ghcr.lank8s.cn` 来加速拉取镜像.  

同时这个库下有一个测试的yaml,在部署好webhook后可以试试测试的效果:   

```shell
kubectl apply -f deploy/test/kube-proxy-deployment.yaml
```  

这是一个使用了`k8s.gcr.io/kube-proxy:v1.10.1`镜像的 Deployment,正常的话就可以看到对应的Pod已经  running 了.

[github.com:liangyuanpeng/replacer.git](github.com:liangyuanpeng/replacer.git)也是 `replacer` 的源代码库,做的事情非常简单,就是收到 Webhook 请求后将`gcr.io`镜像仓库修改为`gcr.lank8s.cn`,可以作为一个 Mutating Webhook 的入门学习资料,感兴趣的同学可以看一看.

## Helm Chart

```
helm repo add lyp https://liangyuanpeng.github.io/charts
helm install replacer lyp/replacer -n replacer --create-namespace
```  

Helm 部署的方式也非常简单,两行命令就可以了,不过这里没有提供测试的文件,可能需要另外拉取镜像验证一下.  

同样的,默认的镜像是 `ghcr.io` 的,如果拉取速度太慢的话可以把镜像仓库修改为 `ghcr.lank8s.cn`.  

```
helm install replacer -n replacer yp/replacer --set waitfor.image.repository=ghcr.lank8s.cn/liangyuanpeng/waitfor --set replacer.image.repository=ghcr.lank8s.cn/liangyuanpeng/replacer  --create-namespace
```

# 总结  

可以看到整个过程非常的简单,不仅如此,Webhook 本身做的事情也非常的简单,这里 Webhook 起到的作用更多的是自动化,如果你没了解过 `gcr.lank8s.cn`,那么可以移步[https://github.com/lank8s](https://github.com/lank8s) 祝你镜像拉取愉快!
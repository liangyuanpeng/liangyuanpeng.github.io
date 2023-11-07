---
layout:     post 
slug:      "proxy-kube-apiserver"
title:      "反向代理kube-apiserver的请求"
subtitle:   ""
description: ""
date:       2022-01-17
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: false
wipnote: true
tags:
    - kubernetes 
    - cncf
categories: [ kubernetes ]
---  


本文会介绍在 L7 中转发下面两种方式的请求以及 L4 转发. 

1. 默认的使用证书的 kubectl 请求  
2. 使用 token 的 kubectl 请求  

L4 比较简单处理,但是 L7 处理和平时处理不太一样,因为 kubectl 默认请求都是带证书信息的,我已经尝试过在 L7 转发默认的 kubectl 发出的请求,但是 kube-apiserver 却提示没有权限.  

我使用 curl 的方式直接请求 kube-apiserver 的`6443`端口,发现是可以正常返回数据的,足够证明证书是没有问题的并且权限足够.

# 注意  

本文还在持续创作当中,将会在[部署一个完整带SSL的etcd](https://liangyuanpeng.com)和[单独部署一个kube-apiserver](https://liangyuanpeng.com/)后开始正式编写.

```
https://liangyuanpeng.com/post/deploy-full-ssl-etcd
https://liangyuanpeng.com/post/deploy-kube-apiserver-only-with-etcd
```
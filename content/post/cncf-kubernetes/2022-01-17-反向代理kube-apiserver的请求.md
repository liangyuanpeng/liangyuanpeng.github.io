---
layout:     post 
slug:      "proxy-kube-apiserver"
title:      "反向代理kube-apiserver的请求"
subtitle:   ""
description: ""
date:       2022-01-17
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1635353670/hugo/banner/pexels-helena-lopes-2253275.jpg"
published: true
wipnote: true
tags:
    - kubernetes 
    - cncf
categories: [ kubernetes ]
---  


本文会介绍在L7中转发下面两种方式的请求以及L4转发. 

1. 默认的使用证书的kubectl请求  
2. 使用token的kubectl请求  

L4比较简单处理,但是L7处理和平时处理不太一样,因为kubectl默认请求都是带证书信息的,我已经尝试过在L7转发默认的kubectl发出的请求,但是kube-apiserver却提示没有权限.  

我使用curl的方式直接请求kube-apiserver的6443端口,发现是可以正常返回数据的,足够证明证书是没有问题的并且权限足够.

# 注意  

本文还在持续创作当中,将会在[部署一个完整带SSL的etcd](https://liangyuanpeng.com/post/function-cncf/deploy-full-ssl-etcd)和[单独部署一个kube-apiserver](https://liangyuanpeng.com/post/cncf-kubernetes/deploy-kube-apiserver-only-with-etcd)后开始正式编写.
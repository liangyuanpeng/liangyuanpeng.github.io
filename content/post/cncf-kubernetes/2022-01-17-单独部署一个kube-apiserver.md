---
layout:     post 
slug:      "deploy-kube-apiserver-only-with-etcd"
title:      "单独部署一个kube-apiserver"
subtitle:   ""
description: ""
date:       2022-01-17
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1635353670/hugo/banner/pexels-helena-lopes-2253275.jpg"
published: false
tags:
    - kubernetes 
    - cncf
categories: [ kubernetes ]
---
 
虽然标题是`"单独部署"`,但是更严谨的说法应该是单独部署`kube-apiserver`而不部署其他k8s组件,因为`kube-apiserver`部署依赖于`etcd`,因此我们还需要一个已经部署好的`etcd`.  

你可以通过文章[部署一个完整带SSL的etcd](https://liangyuanpeng.com/post/function-cncf/deploy-full-ssl-etcd)的指引来部署一个本篇文章会使用到的etcd.

# 注意 

本文还在持续创作当中.

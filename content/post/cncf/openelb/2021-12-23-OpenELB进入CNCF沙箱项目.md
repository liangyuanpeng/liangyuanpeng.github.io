---
layout:     post 
slug:      "openelb-cncf-sanbox"
title:      "OpenELB进入CNCF沙箱项目"
subtitle:   ""
description: ""
date:       2021-12-23
author:     "梁远鹏"
image: "img/banner-pexels.jpg"
published: true
tags:
    - cncf
    - openelb
categories: [ cloudnative ]
---    

# OpenELB是什么  

在 Kubernetes 的世界中有三中 service类型,ClusterIP、NodePort 和 LoadBalancer.  

而 LoadBalancer 类型一般情况下只有云厂商才会提供这种类型的 service,那么在我们的虚拟机,裸机中想使用 LoadBalancer 类型的 service 的话怎么办呢?这时候就可以用上 OpenELB 了.  

OpenELB 提供了用户在虚拟机,裸机上使用 LoadBalancer 类型 service 的机会,并且能够提供和云上相同的体验.  

这能够更好的在本地测试 LoadBalancer 类型的业务.

# 恭喜OpenELB  

OpenELB 项目宣布进入 CNCF 沙箱项目,首先恭喜 OpenELB 项目.  

OpenELB 项目从 commit 来看开始于2019年二月份,发展到现在也接近两年了,虽然还是比较年轻的项目,但是仍然值得期待未来的发展,KubeSphere 社区也正在计划将内置 OpenELB 的支持,搭上 KubeSphere 这条大船.

现在上云已经基本上是一个大家选择服务部署或者说架构方向的一种方式了,而有时将一些测试放在本地来做对于成本来说也是一种较好的选择.   

如果你正处于在云上使用 LoadBalancer service 服务于生产环境而又希望能够在本地对 LoadBalancer service 做足够的测试,那么可以尝试一下 OpenELB.

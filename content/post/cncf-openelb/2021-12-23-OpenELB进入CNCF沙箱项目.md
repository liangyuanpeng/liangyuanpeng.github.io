---
layout:     post 
slug:      "openelb-cncf-sanbox"
title:      "OpenELB进入CNCF沙箱项目"
subtitle:   ""
description: ""
date:       2021-12-23
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612709780/hugo/blog.github.io/pexels-matt-hardy-2568001.jpg"
published: true
tags:
    - cncf
    - openelb
categories: [ CLOUDNATIVE ]
---    

# OpenELB是什么  

在Kubernetes的世界中有三中service类型,ClusterIP、NodePort和LoadBalancer.  

而LoadBalancer类型一般情况下只有云厂商才会提供这种类型的service,那么在我们的虚拟机,裸机中想使用LoadBalancer类型的service的话怎么办呢?这时候就可以用上OpenELB了.  

OpenELB提供了用户在虚拟机,裸机上使用LoadBalancer类型service的机会,并且能够提供和云上相同的体验.  

这能够更好的在本地测试LoadBalancer类型的业务.

# 恭喜OpenELB  

OpenELB项目宣布进入CNCF沙箱项目,首先恭喜OpenELB项目.  

OpenELB项目从commit来看开始于2019年二月份,发展到现在也接近两年了,虽然还是比较年轻的项目,但是仍然值得期待未来的发展,KubeSphere社区也正在计划将内置OpenELB的支持,搭上KubeSphere这条大船.

现在上云已经基本上是一个大家选择服务部署或者说架构方向的一种方式了,而有时将一些测试放在本地来做对于成本来说也是一种较好的选择.   

如果你正处于在云上使用LoadBalancer service服务于生产环境而又希望能够在本地对LoadBalancer service做足够的测试,那么可以尝试一下OpenELB.

# 注意  
本文还在持续创作当中
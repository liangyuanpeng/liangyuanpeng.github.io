---
layout:     post 
slug:      "k8s-multi-tenancy-guide"
title:      "Kubernetes多租户–最佳实践指南"
subtitle:   ""
description: "随着Kubernetes的使用范围不断扩大，Kubernetes多租户成为越来越多的组织感兴趣的话题。但是，由于Kubernetes本身并不是多租户系统，因此正确实现多租户会带来一些挑战"
date:       2021-04-14
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612767214/hugo/blog.github.io/pexels-shuxuan-cao-4719637.jpg"
published: true
tags:
    - kubernetes 
    - k8s
    - CloudNative
categories: 
    - kubernetes
---  

# 前言  

随着Kubernetes的使用范围不断扩大，Kubernetes多租户成为越来越多的组织感兴趣的话题。但是，由于Kubernetes本身并不是多租户系统，因此想要实现多租户会带来一些挑战。

在本文中，我将描述这些挑战以及如何克服这些挑战，以及一些适用于Kubernetes多租户的有用工具。 在此之前，我将解释Kubernetes多租户实际上意味着什么，软多租户和硬多租户之间的区别是什么以及为什么这是当前如此重要的主题。  

# 什么是kubernetes多租户  

kubernetes的多租户意味着多个用户共享同一个集群和控制平面,工作负载或者应用.这和只有一个用户使用一整个集群正好相反.  

有几种类型不同的多租户方式,从软多租户到硬多租户.  

# 软多租户  

软多租户是多租户的一种方式,这种方式没有严格的隔离不同的租户,工作负载或应用.因此这种方式适用于守信用和已知的租户(不会滥用资源的租户,例如同一个组织下的工程师)是一种合适的解决方案.用户之间的隔离主要专注于预防事故上,并且无法防止一个租户对另一个租户发起攻击.  

对于kubernetes而言,软多租户一般是某个租户简单的与kubernetes的namespace相关联.  

# 硬多租户  


# 注意 本文还处于创作阶段,将会尽快完善
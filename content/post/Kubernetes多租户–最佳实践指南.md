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

软多租户是多租户的一种方式,这种方式没有严格的隔离不同的租户,工作负载或应用.因此这种方式适用于守信任和已知的租户(不会滥用资源的租户,例如同一个组织下的工程师)是一种合适的解决方案.用户之间的隔离主要专注于预防事故上,并且无法防止一个租户对另一个租户发起攻击.  

对于kubernetes而言,软多租户一般是某个租户简单的与kubernetes的namespace相关联.  

# 硬多租户   

硬性多租户可以做到更严格的租户隔离,可以防止恶意行为给其他租户造成负面影响.所以除了受信任的租户外,还能够用与不信任的租户,例如很多unconnected users和人员来自不同的组织.   

为了在kubernetes中实现硬多租户,你需要对namespace或[virtual Clusters (vClusters)](https://loft.sh/blog/introduction-into-virtual-clusters-in-kubernetes/) 设置更多高级的配置项.

# 软多租户 VS 硬多租户  

# 多租户kubernetes的局限性  

实现了多租户后你的kubernetes集群就会存在了一些限制.因为和单租户集群的用户相比,多租户中的租户在技术上会存在某些限制,例如基于namespace实现的多租户限制一个示例是租户无法使用CRD,无法安装使用了RBAC的helm chart或者更改集群的某些配置(例如kubernetes版本).

使用虚拟集群(virtual clusters)可以减轻这些限制,因为租户可以访问vClusters中集群范围的设置和资源.和namespace方式相比,vClusters对租户来说更像是真实的集群,这就是为什么基于vClusters的多租户也是一种多租户的形式,相对来说这种方式更接近于单租户.  

# 为什么要做kubernetes多租户

你可能会问为什么kubernetes多租户是有意义的,为什么不能只用很多单租户集群呢?  

理论上讲可以用很多单租户集群方式而不是共享的多租户集群.现在很多公司已经是这么操作了,例如为开发人员提供访问kubernetes的权限(单独的kubernetes开发环境集群).但是这种方式效率很低,而且成本也大,尤其是在大规模的情况下.  

当团队在使用kubernetes并且开放给更多的工程师使用的时候,很多团队就会意识到这一点:虽然在kubernetes一开始的测试试验阶段给每个租户/用户创建一个集群很简单而且成本不高,但是如果每个开发人员在项目后期都拥有一个自己的集群的话会成为一个巨大的问题.突然间kubernetes集群数量达到数十个、数百个甚至数千个,这些集群都需要开销(公有云提供商的集群开销到后期非常重要),并且需要有效的将这些资源管理起来不是一件简单的事情.  

在这个阶段下有一个多租户的系统的好处大于这个系统的复杂度,管理一个或几个K8S集群会变得很容易,共享集群在资源利用方面也会更加有效,减少了资源冗余.  

关于这部分详细内容可以参考我的文章,这篇文章主要比较了[单集群和共享集群的的开发模式](https://loft.sh/blog/individual_kubernetes_clusters_vs-_shared_kubernetes_clusters_for_development/).  


# kubernetes多租户系统实现的挑战  

kubernetes多租户系统实现会遇到下面三个挑战:  

## 用户管理  
## 公平的资源共享  
## 隔离  

# 可用的解决方案  

## kiosk 
[kiosk](https://github.com/loft-sh/kiosk)是开源的kubernetes多租户扩展,它被设计为任何kubernetes集群的轻量级、可插拔和可自定义的解决方案，以简单的方式解决了一些多租户的难题。包括用户账号分离，用户级别的资源消耗限制以及 

## Loft  
[Loft](https://loft.sh/)  

# 总结  
随着kubernetes的采用率进一步向上发展和kubernetes单租户模型日益充满困难,kubernetes多租户已经成为了很多组织面临的挑战之一.

在实现kubernetes的多租户时，你需要确认是否需要硬多租户或软多租户是否已经能够满足。但不管怎么说你需要解决三个主要问题:怎么样去管理用户/租户,怎么样限制资源的使用以及如何隔离资源.限制有几个工具例如dex,kiosk和loft能够帮助你更轻松地建立kubernetes多租户机制.

# 注意 本文还处于创作阶段,将会尽快完善  

本文翻译至[kubernetes-multi-tenancy-best-practices-guide](https://loft.sh/blog/kubernetes-multi-tenancy-best-practices-guide/)
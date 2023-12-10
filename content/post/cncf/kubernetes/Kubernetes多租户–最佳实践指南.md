---
layout:     post 
slug:      "k8s-multi-tenancy-guide"
title:      "Kubernetes多租户–最佳实践指南"
subtitle:   ""
description: "随着Kubernetes的使用范围不断扩大，Kubernetes多租户成为越来越多的组织感兴趣的话题。但是，由于Kubernetes本身并不是多租户系统，因此正确实现多租户会带来一些挑战"
date:       2021-04-14
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags:
    - kubernetes 
    - k8s
    - CloudNative
    - 翻译
categories: 
    - kubernetes
---  

# 前言  

随着 Kubernetes 的使用范围不断扩大，Kubernetes 多租户成为越来越多的组织感兴趣的话题。但是，由于 Kubernetes 本身并不是多租户系统，因此想要实现多租户会带来一些挑战。

在本文中，我将描述这些挑战以及如何克服这些挑战，以及一些适用于 Kubernetes 多租户的有用工具。 在此之前，我将解释 Kubernetes 多租户实际上意味着什么，软多租户和硬多租户之间的区别是什么以及为什么这是当前如此重要的主题。  

# 什么是kubernetes多租户  

kubernetes 的多租户意味着多个用户共享同一个集群和控制平面,工作负载或者应用.这和只有一个用户使用一整个集群正好相反.  

有几种类型不同的多租户方式,从软多租户到硬多租户.  

# 软多租户  

软多租户是多租户的一种方式,这种方式没有严格的隔离不同的租户,工作负载或应用.因此这种方式适用于守信任和已知的租户(不会滥用资源的租户,例如同一个组织下的工程师)是一种合适的解决方案.用户之间的隔离主要专注于预防事故上,并且无法防止一个租户对另一个租户发起攻击.  

对于 kubernetes 而言,软多租户一般是某个租户简单的与 kubernetes 的 namespace 相关联.  

# 硬多租户   

硬性多租户可以做到更严格的租户隔离,可以防止恶意行为给其他租户造成负面影响.所以除了受信任的租户外,还能够用与不信任的租户,例如很多 unconnected users和人员来自不同的组织.   

为了在 kubernetes 中实现硬多租户,你需要对 namespace 或[virtual Clusters (vClusters)](https://loft.sh/blog/introduction-into-virtual-clusters-in-kubernetes/) 设置更多高级的配置项.

# 软多租户 VS 硬多租户  

软多租户和硬多租户虽然听起来是截然不同的对立面,但实际上他们是同一目标的不同实现.甚至有人认为 kubernetes 中不可能做到完美的硬多租户,因为 kubernetes 的设计方式是一个集中的控制平面始终会被租户引入潜在的漏洞并且共享这些问题.  

通常硬多租户会被更看好(因为它可以更好的用于各种租户),而软多租户则更容易实现.

# 多租户kubernetes的局限性  

实现了多租户后你的 kubernetes 集群就会存在了一些限制.因为和单租户集群的用户相比,多租户中的租户在技术上会存在某些限制,例如基于 namespace 实现的多租户限制一个示例是租户无法使用 CRD,无法安装使用了 RBAC 的 helm chart 或者更改集群的某些配置(例如 kubernetes 版本).

使用虚拟集群(virtual clusters)可以减轻这些限制,因为租户可以访问 vClusters 中集群范围的设置和资源.和 namespace 方式相比,vClusters 对租户来说更像是真实的集群,这就是为什么基于 vClusters 的多租户也是一种多租户的形式,相对来说这种方式更接近于单租户.  

# 为什么要做kubernetes多租户

你可能会问为什么 kubernetes 多租户是有意义的,为什么不能只用很多单租户集群呢?  

理论上讲可以用很多单租户集群方式而不是共享的多租户集群.现在很多公司已经是这么操作了,例如为开发人员提供访问 kubernetes 的权限(单独的 kubernetes 开发环境集群).但是这种方式效率很低,而且成本也大,尤其是在大规模的情况下.  

当团队在使用 kubernetes 并且开放给更多的工程师使用的时候,很多团队就会意识到这一点:虽然在 kubernetes 一开始的测试试验阶段给每个租户/用户创建一个集群很简单而且成本不高,但是如果每个开发人员在项目后期都拥有一个自己的集群的话会成为一个巨大的问题.突然间 kubernetes 集群数量达到数十个、数百个甚至数千个,这些集群都需要开销(公有云提供商的集群开销到后期非常重要),并且需要有效的将这些资源管理起来不是一件简单的事情.  

在这个阶段下有一个多租户的系统的好处大于这个系统的复杂度,管理一个或几个K8S集群会变得很容易,共享集群在资源利用方面也会更加有效,减少了资源冗余.  

关于这部分详细内容可以参考我的文章,这篇文章主要比较了[单集群和共享集群的的开发模式](https://loft.sh/blog/individual_kubernetes_clusters_vs-_shared_kubernetes_clusters_for_development/).  


# kubernetes多租户系统实现的挑战  

kubernetes 多租户系统实现会遇到下面三个挑战:  

## 用户管理  

挑战:大部分公司已经为他们的工程师提供了用户管理系统.可以在 Github、微软、谷歌或其他任何服务中.由于用户不应该在第二个地方或更多地方管理多次,所以你需要为你的 kubernetes 系统开启单点登录.  

解决方案: 使用 CNCF 沙箱项目 Dex,你可以为租户提供单点登录功能.Dex 是一个提供了 OIDC 和 OAuth2 功能的程序,包含了 LDAP 和 SAML 在内的各种身份认证,因此可以在很多用户管理系统中使用.所以,Dex 是一个可以为 kubernetes 多租户系统很好的解决用户管理挑战的选项.

## 公平的资源共享  

挑战:由于所有租户共享相同的基础资源,即网络和计算资源.第二个挑战是确保租户之间能够公平地共享可用资源.这一点很重要,因为你不会希望某个租户消耗了全部资源或者消耗了过多的资源(有意或无意)导致其他租户出现异常情况.所以需要保证所有的租户都有相对应的资源限制.  

解决方案:租户的资源使用能够通过 kubernetes 的 Resource Quotas 被 kubernetes 原生限制,由于如果为这些资源开启了限制用户必须指定 CPU 和内存限制,因此也可以用 LimitRanges 来设置一些智能的默认值.

## 隔离  

挑战:第三个挑战是将不同的租户彼此隔离.这样可以防止租户之间相互干扰.如文章上所述,这个隔离的程度取决于你是使用硬租户还是软租户、系统是否只提供给受信任的租户使用以及系统是否能够免收平台系统本身程序的错误.

解决方案:把 kubernetes namespace 作为租户的基本隔离处理,另外 vClusters 提供了比 namespace 更多的隔离,同时让租户拥有更多的灵活性.隔离租户的另一个考虑因素是网络流量:网络策略默认情况下应该已经配置了拒绝所有流量并且仅允许同一命名空间的流量,容器的公网流量还有DNS的请求流量.这让租户攻击或者干扰其他租户变得更加地困难.

# 可用的解决方案  

已经存在的一些有用的解决方案去帮助你构建 kubernetes 多租户平台.除了前面提到的 Dex 还有 kiosk 和 loft.

## kiosk 
[kiosk](https://github.com/loft-sh/kiosk)是开源的 kubernetes 多租户扩展,它被设计为任何 kubernetes 集群的轻量级、可插拔和可自定义的解决方案，以简单的方式解决了一些多租户的难题。包括用户账号分离，用户级别的资源消耗限制以及用于安全租户隔离和自助服务 namespace 初始化的 namespace 模版.kiosk 虽然没有内置用户管理功能,但也是构建多租户系统非常好的方式.   

尽管 kiosk 在几个月前才发布，但它已经包含在 AWS 针对多租户的 EKS 最佳实践指南中。您可以在这里找到使用 EKS 设置 kiosk 的详细指南。

## Loft  
[Loft](https://loft.sh/)是一个基于 kiosk 实现,提供全方位的多租户解决方案.Loft 能够安装在任何 kubernetes 集群上,能够让租户按需创建 namespace 和虚拟集群(virtual Clusters).它关注用户管理(包括单点登录)和用户隔离,并且让集群管理员可以设置使用限制,因此文章上述提到的一些多租户问题都能够处理.Loft 还提供了一些额外的功能,例如休眠模式,通过关闭没有使用的 namespace 和 virtual Clusters 来降低云计算成本.  

Loft 是一个有免费套餐的商业产品,同时也包含在[EKS最佳实践多租户指南](https://aws.github.io/aws-eks-best-practices)(我看了一下,链接已经404,因此链接替换成 EKS 最佳实践首页)当中.虽然它最初专注于多租户开发案例,但也可以用在生产案例,例如[集群分片](https://loft.sh/use-cases/kubernetes-cluster-sharding)或者是[在共享集群里面运行产品的多个实例](https://loft.sh/use-cases/cloud-native-managed-products).

# 总结  
随着 kubernetes 的采用率进一步向上发展和 kubernetes 单租户模型日益充满困难,kubernetes 多租户已经成为了很多组织面临的挑战之一.

在实现 kubernetes 的多租户时，你需要确认是否需要硬多租户或软多租户是否已经能够满足。但不管怎么说你需要解决三个主要问题:怎么样去管理用户/租户,怎么样限制资源的使用以及如何隔离资源.限制有几个工具例如 Dex,kiosk 和 loft 能够帮助你更轻松地建立 kubernetes 多租户机制.

本文翻译至[kubernetes-multi-tenancy-best-practices-guide](https://loft.sh/blog/kubernetes-multi-tenancy-best-practices-guide/)
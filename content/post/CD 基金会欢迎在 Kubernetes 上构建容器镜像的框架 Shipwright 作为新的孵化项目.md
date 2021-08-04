---
layout:     post 
slug:      "cdf-new-project-shipwright"
title:      "CDF(持续交付基金会)欢迎基于k8s构建容器镜像的框架Shipwright作为新的孵化项目"
subtitle:   "Simplified approach for building container images, built on Tekton"
description: "基于 Tekton 构建容器镜像的简单方法"
date:       2021-08-04
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612709780/hugo/blog.github.io/pexels-matt-hardy-2568001.jpg"
published: false
tags:
    - cdf 
    - foundation
    - devops
    - kubernetes
categories: [ TECH ]
---    

---

> 说明: 本文将使用CDF作为持续交付基金会简称.

> 基于 Tekton 构建容器镜像的简单方法

旧金山,2021年8月3日---CDF是一个开源软件基金会,致力于提高全世界软件安全性和快速交付的能力,今天宣布Shipwright成为CDF的一个孵化项目.  

可靠、安全和高效的构建容器镜像是现代云原生交付管道(能力?)越来越重要的功能.借助Shipwright,开发人员可以不需要容器相关的知识就可以定义出一个最小化的yaml,从而获得一个简单的构建容器的方法.Shipwright是基于Tekton的(当前的一个CDF项目).  

Shipwright的Github地址和安装说明在 https://github.com/shipwright-io/build 

红帽的高级软件工程师主管和Shipwright的贡献者Jason Hall是这样说的:"对于Shipwright社区来说,加入CDF基金会是一个非常重要的里程碑.作为CDF创始项目之一的Tekton的联合创始人之一,我相信进入CDF对于Shipwright达到v1来说是正确的.更重要的一点是在此基础上超越v1". "我们相信Shipwright会成为持续交付生态系统中的一个重要工具,Shipwright希望只做好一件事:构建容器镜像.这不是瑞士军刀,而是锤子."  

Shipwright是基于多年来开发和运营作为Red Hat OpenShift 平台中的Red Hat OpenShift Builds的经验,IBM Cloud Code Engine团队也做出了贡献.Shipwright还支持IBM Cloud Code Engine容器镜像的构建.

CDF执行董事Tracy Miranda表达了这样的看法:"Shipwright专注于做好一件事:构建容器镜像.开发者需要良好的工具来构建云原声应用,而Shipwright是这工具集中优秀的补充.因为Shipwright可以很好的集成Tekton,而Tekton是CDF创始项目以及发展最快的项目之一，因此Shipwright加入CDF对于和Tekton更紧密的合作是绝对有意义的." "我们很高兴可以和Shipwright可以进行密切的合作以及帮助他们构建项目和扩展用户社区.欢迎Shipwright社区!"  

CDF提供了广泛的服务来支持开源项目,而项目一般以孵化项目开始.这适用于那些实现了广泛采用并且有增长计划的项目.项目接受CDF TOC(技术监督委员会)的培训并且积极发展他们的贡献者社区,项目治理和文档等等.  
关于将开源持续交付项目引入CDF的详细资料可以在[这里](https://github.com/cdfoundation/toc/blob/master/PROJECT_LIFECYCLE.md#project-proposal-requirements)找到.  


TOC主席 Dan Lorenc：TOC热烈欢迎Shipwright加入到CDF.我们已经为项目过度到孵化项目做好准备,而今天这个宣布是一个重要的里程碑,欢迎!  

Shipwright每周举办会议，欢迎所有用户，贡献者，维护人员以及任何对项目感兴趣的人。[Shipwright贡献指南和社区会议](https://github.com/shipwright-io/community/blob/main/CONTRIBUTING.md)

# 其他CD基金会资源  

[加入CDF](https://cd.foundation/members/join/)
[联系CDF](https://cd.foundation/about/contact/)  
[CDF项目](https://cd.foundation/projects/)  
[CDF FAQ](https://github.com/cdfoundation/faq)
[CDF推特](https://twitter.com/CDeliveryfdn)
[CDF博客](https://cd.foundation/news/blog/) 

# 关于CDF
CDF是一个供应商中立的开源软件基金会,致力于提高全世界软件安全性和快速交付的能力
...TODO

# 关于Shipwright
Shirpwright是一个基于k8s的开放可扩展的容器镜像构建框架,声明式并且可重用构建策略来构建容器镜像.Shipwright是建立在Tekton之上的,利用它的优点功能来简化持续交付的复杂度.Shipwright支持Kaniko,Cloud Native Buildpacks, Buildah等工具.官网是:https://shipwright.io

# 商标 
Linux 基金会拥有注册商标并使用商标。 有关 Linux 基金会的商标列表，请参阅我们的商标使用页面：https://www.linuxfoundation.org/trademark-usage。 Linux 是 Linus Torvalds 的注册商标。  

# 原文  

翻译自[CD Foundation Welcomes Shipwright, Framework for Building Container Images on Kubernetes, As New Incubating Project](https://cd.foundation/blog/2021/08/03/cd-foundation-shipwright-announcement/)


# 转载声明  

本文转载至CDF中文本地化SIG，欢迎和关注公众号:Jenkins-Community(TODO 公众号二维码/官网)
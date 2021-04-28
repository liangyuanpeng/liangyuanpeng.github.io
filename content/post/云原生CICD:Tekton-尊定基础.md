---
layout:     post 
slug:      "cloudnative-cicd-tekton"
title:      "云原生CICD:Tekton-尊定基础"
subtitle:   ""
description: "使用Tekton Pipelines启动Kubernetes上的云原生CI / CD的最简单方法…"
date:       2021-04-27
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612744351/hugo/blog.github.io/pexels-bruno-cervera-6032877.jpg"
published: true
tags:
    - tekton
    - cdf
    - kubernetes
    - CI/CD
categories: 
    - CloudNative
---    

众所周知,严谨的项目都需要CI/CD而且我敢肯定这不需要什么解释.在做技术选型时有很多工具、平台和解决方案可以选择.你可以选Jenkins,Travis,CircleCI,Bamboo等其他工具.但是如果你要为kubernetes之上的云原生应用构建一个CI/CD,那么在做技术选型时要确保CI/CD也可以实现云原生的方式.  

[Tekton](https://tekton.dev/)是一个kubernetes原生的CICD,因此在这篇文章我们会开始讨论如何用Tekon构建CICD.首先以Tekton的介绍、安装和自定义的结构开始我们在kubernetes上构建云原生CICD Tekon的旅程.  

所有的资源文件都在 https://github.com/MartinHeinz/tekton-kickstarter  


# Tekon是什么?(为什么选择Tekon)  

如标题和介绍所述,Tekon是一个最初由谷歌开发的云原生的CICD工具,在Knative中作为pipelines存在.在kubernetes中以CRD的方式运行,例如Pipeline或Task,它们的生命周期被Tekton Controller管理.因为Tekton以kubernetes原生方式运行所以可以用它来无缝管理/构建/部署任何也部署在kubernetes之上的应用或资源.  

这说明用Tekon非常合适管理kubernetes的工作负载(workloads),但是为什么不选择其他更加流行的工具呢?  

常用的一些CI/CD解决方案,例如Jenkins, Travis or Bamboo都不是kubernetes原生的或者kubernetes集成度还不够.在这样的前提下就使得部署,运维和管理CI/CD工具本身以及用这样的CI/CD工具去部署任何kubernetes应用变得困难和烦恼.另一方面,Tekton可以很容易地作为kubernetes operator和其他容器不是在一起,每一个Tekton pipeline只是另一种kubernetes资源,管理方式和Pod或Deployments相同.  

这也让Tekton可以很好的和GitOps搭配使用.



# 注意 本文还在翻译当中  

[原文在这里](https://itnext.io/cloud-native-ci-cd-with-tekton-laying-the-foundation-a377a1b59ac0)

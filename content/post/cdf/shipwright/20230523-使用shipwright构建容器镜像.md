---
layout:     post 
slug:      "quick-start-shipwright"
title:      "shipwright快速入门"
subtitle:   ""
description: ""
date:       2023-05-23
author:     "梁远鹏"
image: "/img/banner/743a4e9227e1f14cb24a1eb6db29e183.jpg"
published: false
tags:
    - cdf
    - shipwright
categories: [ cloudnative ]
---    

# 

shipwright 是由红帽开源并且捐赠给 CDF的一个基于 tekton 之上的容器镜像框架，将各种镜像构建方式抽象成 K8S CRD 对象，提供统一的使用体验。底层构建在 tekton 之上，目前是 CDF 孵化项目。

# 目前支持的构建方式

- buildpacks
- buildkit
- ko
- kaniko
- s2i
- builddah

主要有三个对象：

- BuildStrategy
- Build
- BuildRun

# 关系

基本上，每一个 BuildRun 对应一个 TaskRun

# 用例

## openfunction

openfunction 是...

openfunction 使用 shipwright 构建容器镜像


## OpenShift Builds?



# 参考
https://blog.csdn.net/CCqwas/article/details/123585067
---
layout:     post 
slug:      "k8s-validating-admission-policy-with-crdparam-lua"
title:      "K8S内置准入校验CRD参数配合lua起飞"
subtitle:   ""
description: ""
date:       2023-01-11
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
wipnote: true
tags:
    - k8s
    - cncf
    - k8s-1.26
    - kubernetes
    - cel
categories: 
    - cloudnative
---

# 前言  

k8s 1.26 推出了内置的准入校验机制,只需要使用 CEL 表达式就可以完成基本的准入校验逻辑,而高级功能包含将参数动态化,可以使用 CRD 资源的某个字段作为参数,可以看看这篇文章了解一下:[用cel表达式来实现k8s准入校验](https://liangyuanpeng.com/post/k8s-admissionregistration-with-cel/)  

而本文基于 CRD+Lua 则将 CRD 字段参数再次提升了一个等级，可以达到使用 Lua 基于 K8S API 的数据来做到动态编程的效果,意味着你可以使用 Lua 来处理 K8S 的 API 数据达到任何你想要的内容.

# 敬请期待

这个项目也会开源在 github 上,可以关注 https://github.com/liangyuanpeng 来跟踪最新进展.



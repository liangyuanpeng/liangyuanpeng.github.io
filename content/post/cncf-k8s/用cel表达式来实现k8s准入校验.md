---
layout:     post 
slug:      "k8s-admissionregistration-with-cel"
title:      "用cel表达式来实现k8s准入校验"
subtitle:   ""
description: ""
date:       2023-01-09
author:     "梁远鹏"
image: "img/post-bg-2015.jpg"
published: true
tags:
    - k8s
    - cncf
    - k8s-1.26
categories: [ CloudNative ]
---

# 前言  

在 K8S 1.26 版本以前,达到 K8S 准入校验策略效果的方式有两种：
1. 自己实现 K8S webook
2. 直接使用 CNCF 项目中以 K8S 策略展开的项目,例如`OPA`、`kyverno`.

这些都是K8S非默认的内容,K8S只负责将流量转发到对应的 webhook,具体是怎样一个逻辑判断是在外部处理的.而现在 K8S 支持了一种内置的准入校验方式，使用 CEL 表达式来完成 webhook 的校验逻辑，在一定程度上替代了外部 webhook,一些常见的比较简单的校验内容可以直接使用 CEL 表达式来完成,比如校验当前资源使用的镜像是否是内网地址的镜像,如果不是则校验不通过.

参考资料：官方博客 https://kubernetes.io/blog/2022/12/20/validating-admission-policies-alpha/

# 注意

本文还在持续创作中

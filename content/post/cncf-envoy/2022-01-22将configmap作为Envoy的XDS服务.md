---
layout:     post 
slug:      "envoy-file-xds-with-reload-configmap"
title:      "将热更新configmap作为Envoy的XDS服务"
subtitle:   ""
description: ""
date:       2022-01-22
author:     "梁远鹏"
image: "img/post-bg-2015.jpg"
published: false
tags:
    - envoy 
    - cncf
    - kubernetes
categories: [ kubernetes ]
---

# 

在使用Envoy的过程中时常会需要对接XDS用作流量的动态管理，那么如何以低成本的方式实现这个效果呢?  

ConfigMap你值得拥有,本质上还是使用文件作为Envoy的XDS服务实现,只不过将文件的内容以ConfigMap管理起来了.  

原理也很简单,在Envoy容器旁启动一个SideCar,这个SideCar的唯一作用就是监听到文件变化之后做一个`mv`的操作,触发Envoy来重新加载最新的XDS规则文件.  

这样就可以做到了动态的管理Envoy规则并且基本上没有上手难度.毕竟在kubernetes之上谁还不会操作一个ConfigMap呢?
 
实践的过程发现使用inotify监听文件时如果监听modify事件的话文件内容更新了,但是却没有触发监控事件,这是为什么呢?这与configmap将内容更新到pod中的机制有关.后续会有一篇文章来专门讲解一下这个原理.

# 注意

本文还在持续创作中

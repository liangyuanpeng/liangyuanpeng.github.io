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
    - xds
categories: [ kubernetes ]
---

# 

在使用 Envoy 的过程中时常会需要对接 XDS 用作流量的动态管理，那么如何以低成本的方式实现这个效果呢?  

ConfigMap 你值得拥有,本质上还是使用文件作为 Envoy 的 XDS 服务实现,只不过将文件的内容以 ConfigMap 管理起来了.  

原理也很简单,在 Envoy 容器旁启动一个 SideCar,这个 SideCar 的唯一作用就是监听到文件变化之后做一个`mv`的操作,触发Envoy来重新加载最新的XDS规则文件.  

这样就可以做到了动态的管理 Envoy 规则并且基本上没有上手难度.毕竟在 kubernetes 之上谁还不会操作一个 ConfigMap 呢?
 
实践的过程发现使用 inotify 监听文件时如果监听 modify 事件的话文件内容更新了,但是却没有触发监控事件,这是为什么呢?这与 configmap 将内容更新到 pod 中的机制有关.后续会有一篇文章来专门讲解一下这个原理.


另一个问题是配置文件通过 configmap 挂载到 pod 之后，是只读的，无法做修改，因此直接对挂载的配置文件做 `mv envoy.yaml envoy.yaml_bak && mv envoy.yaml_bak envoy.yaml` 是不可行的,本文的思路是用一个 initContainer 将 configmap 挂载的配置文件复制到另一个有读写权限的目录，然后后续每次 configmap 更新时都将文件复制到这个有读写权限的目录来做 mv 操作,进而最终达到让 Envoy 基于静态文件更新配置的效果.

# 注意

本文还在持续创作中

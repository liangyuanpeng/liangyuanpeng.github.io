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


其中Build和BuildRun的关系正如 Tekton 中 Task 和 TaskRun 的关系一样。也就是 Build 对象负责镜像构建动作的一些定义，而 BuildRun 是容器镜像构建的真正入口，创建了一个 BuildRun 对象时才会真正的开始容器镜像的构建。

## BuildStrategy

BuildStrategy也就是构建策略，也就是通过什么方式来进行容器镜像的构建,目前支持以下几种构建策略:xxxxxx,


## Build

定义了镜像构建相关的一些上下文信息，主要是以下几个内容：

Source Code：需要构建的容器镜像所对应的源码。
Output image：构建容器镜像后的去处，例如镜像名称 版本，镜像label以及推送容器镜像所需要的认证信息等。
Build Strategy：使用哪一种容器镜像构建策略来执行，也就是上述的 BuildStrategy 对象。

还有一些其他内容：

构建容器镜像时需要的参数，例如 ko构建参数 xxxx
构建容器镜像时需要特定的持久化空间(volume),这个必须是构建策略支持传递 volume 并且支持重写，否则将会在 buildRun 时失败。 例如 ko 的volume支持重写，而 buildpacks 的 volume 不支持重写。 甚至有的构建策略 没有可以传递的 volume。
镜像构建完成后的一些清理工作，例如 镜像构建成功后多久清理 build/buildRun，最多保持多少个 build/buildRun 记录。

## BuildRun

只有创建了BuildRun对象才是真正开始容器镜像的构建，需要声明使用哪一个 Build 对象来执行。

还有一些其他内容：
构建容器镜像时需要的参数，例如 ko构建参数 xxxx
构建容器镜像时需要特定的持久化空间(volume),这个必须是构建策略支持传递 volume 并且支持重写，否则将会在 buildRun 时失败。 例如 ko 的volume支持重写，而 buildpacks 的 volume 不支持重写。 甚至有的构建策略 没有可以传递的 volume。
镜像构建完成后的一些清理工作，例如 镜像构建成功后多久清理 build/buildRun，最多保持多少个 build/buildRun 记录。

这部分内容如果 Build 对象也声明了那么会以 BuildRun 对象声明的内容为准，也就是会覆盖 Build 对象的声明。


# 关系

基本上，每一个 BuildRun 对应一个 TaskRun

# 用例

## openfunction

openfunction 是...

openfunction 使用 shipwright 构建容器镜像


## OpenShift Builds?


# 总结

基本上 shipwright 专注于容器镜像构建这一件事情上，上述讲述了 shipwright 最核心的内容，同时shipwright还有一个正在开发中的 triggers 组件，用于更好的集成？ 例如 github webhook来触发容器镜像构建，实际的场景是有的，例如PR合并后开始构建对应的容器镜像。

实现了 Tekton CustomRun，可以直接作为 Tekton Task 运行在 TaskRun 和 pipeline 当中。

## 更多的想象空间

未来还会支持

- Build 对象之间的 trigger，例如 当容器镜像A构建完成后开始构建容器镜像B， (镜像AB之间可能有一些依赖关系)
- 容器镜像构建完成后利用cosign为容器镜像签名



# 参考
https://blog.csdn.net/CCqwas/article/details/123585067
---
layout:     post 
slug:      "quick-k8s-dev-with-flux-and-kind"
title:      "基于flux和kind快速搭建k8s环境"
subtitle:   ""
description: ""
date:       2023-04-03
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags:
    - fluxcd 
    - cncf
    - kubernetes
    - gitops
    - kind
categories: 
    - cloudnative
---

# 目前,这只是一个简单的笔记

总是需要各种特定的 K8S 研究环境，而部署各种环境的方式又不一致,有 yamls 方式的 有 helm 方式的，因此需要保证这两种方式都能够通过某种方式快速的应用起来。对于 helm 来说很简单，argoCD 和 FluxCD 都支持。因此可以满足没有 git 的情况下快速搭建基于 helm 部署的 K8S 研究环境。但是对于 yaml 文件的 K8S 研究环境来说就不行了，例如我自己编写了一些 yaml 文件，希望下次能够快速搭建一个基于这些 yaml 文件的 K8S 环境。


当然可以写一个 shell 脚本来跑 kubectl apply，但是这样的环境并不是只有一个，也不是固定不变的，因此这个 shell 脚本需要一直迭代，因此这个解决方案也不适合。

最近正在寻找基于 Kind 快速搭建特定 K8S 环境的解决方案,在尝试 Flux 的时发现 Flux 有个  OCIRegistry 的资源从OCI注册中心来处理 资源文件，在这里 https://github.com/fluxcd/source-controller/blob/main/docs/spec/v1beta2/ocirepositories.md#artifact 看了一下描述，还是需要 git 地址,因此这看起来就不是我想要的东西。

在 slack 问了一下，立刻有大佬回答了，并且 Flux project 的 maintainer Hidde Beydals 给了一个用于 Flux 搭配 Kind 搭建本地开发环境的 github 仓库 https://github.com/stefanprodan/flux-local-dev，看起来就是我需要的。不禁的感慨 开源真是一个伟大的东西，在某些时间你想做的事情很有可能已经有其他人做了并且将所有内容开放了出来，即使不是完全适合，也可以在这个开放内容的基础上修改一下来适配自己的需求。


---
layout:     post 
slug:      "compile-kubernetes"
title:      "编译kubernetes组件"
subtitle:   ""
description: ""
date:       2023-02-19
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
wipnote: true
tags:
    - k8s
    - kubernetes
    - cncf
    - golang
categories: [ kubernetes ]
---

# 

kubernetes 发展到了今天(2023-02-19),编译 kubernetes 已经是一件很简单的事情,唯一的门槛就是需要有适合的内存资源以及编译需要用到的 registry.k8s.io 中的镜像.


# 编译

## 解决 registry.k8s.io 镜像问题

由于有 lank8s.cn 服务,因此这个问题已经不再是问题,不过是动动手指头将 registry.k8s.io 修改为 registry.lank8s.cn 就可以了.

```shell
KUBE_BUILD_PLATFORMS=linux/amd64  make all WHAT=cmd/kube-apiserver   GOFLAGS=-v GOGCFLAGS="-N -l"
```

```shell
KUBE_BUILD_PLATFORMS=linux/amd64 make quick-release
```

```shell

```

有一些依赖的容器镜像可以在 `build/dependencies.yaml` 这个文件中找到,例如编译时需要使用到 `registry.k8s.io/build-image/kube-cross` 这个镜像,可以在这个文件中看到如下内容:

```yaml
...
  - name: "registry.k8s.io/kube-cross: dependents"
    version: v1.31.0-go1.22.3-bullseye.0
...
```

表示需要使用到 `registry.k8s.io/build-image/kube-cross:v1.31.0-go1.22.3-bullseye.0`,还有一些其他会用到的容器镜像,稍后我会整理列出来.

---
layout:     post 
slug:   "more-ways-to-build-kind-node"
title:      "构建kind-node镜像的更多选择"
subtitle:   ""
description: ""  
date:       2024-05-28
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags: 
    - kubernetes
    - cncf
    - kind
    - kubernetes-sigs
categories: 
    - kubernetes
---

# 简介

在 [PR](https://github.com/kubernetes-sigs/kind/pull/3614) 合并之前, Kind 构建一个自定义的 kubernetes 节点镜像至少有两个步骤(Kind命令自动完成):

1. 使用 kubernetes 源码构建二进制文件 (假设已经下载好 kubernetes 源码)
2. Kind 开始基于构建好的二进制文件进行构建容器镜像.

而在 [PR](https://github.com/kubernetes-sigs/kind/pull/3614) 合并之后,构建一个特定 kubernetes 版本的 Kind 节点,可以直接指定已经构建好的二进制文件(本地文件系统或者是直接从官方地址下载!),极大的增加了便利性,并且减少了不必要的二进制文件构建所需要的时间.

这一些都要感谢 [@dims](https://github.com/dims) 以及 Kind 维护者对 PR 的 review 以及允许合并!!

该功能将会出现在 Kind 0.24.0, 估计是几个月后的事情了,如果你想尝试一下但又不想构建 Kind 命令,可以从下面地址下载官方已经构建好的最新的Kind命令: 

- https://kind.sigs.k8s.io/dl/latest/linux-amd64.tgz    amd64 架构
- https://kind.sigs.k8s.io/dl/latest/linux-arm64.tgz    arm64 架构

这是 Kind 仓库的 main 分支构建的,在 Kind 的 CI 中使用.

# 开始尝试

接下来在 github action 上使用 kind 基于官方发布的 v1.29.4 版本构建一个 Kind 节点镜像,看看需要多久:

```shell
lan@lank8s.cn:~/kind$ time kind build node-image v1.29.4
Detected build type: "release"
Building using release "v1.29.4" artifacts
Starting to build Kubernetes
Downloading "https://dl.k8s.io/v1.29.4/kubernetes-server-linux-amd64.tar.gz"
Finished building Kubernetes
Building node image ...
Building in container: kind-build-1716818556-1578232663
Image "kindest/node:latest" build completed.

real    2m12.434s
user    0m7.132s
sys     0m3.011s
```

可以看到,只需要2分钟就构建了一个特定 kubernetes 版本的 Kind 节点镜像!!简直不能再快了!!

看了下发布的二进制文件有多大,原来也就300多兆:

```shell
lan@lank8s.cn:~$ ls -allh kubernetes-server-linux-amd64.tar.gz
-rw-r--r-- 1 runner docker 365M Apr 16 21:40 kubernetes-server-linux-amd64.tar.gz
```

也可以直接指定 url,如果你想从一些特定镜像源或者是公司内部地址下载的话就很有用了:

```shell
lan@lank8s.cn:~/kind$ kind build node-image --type url https://dl.k8s.io/v1.29.4/kubernetes-server-linux-amd64.tar.gz
Building using URL: "https://dl.k8s.io/v1.29.4/kubernetes-server-linux-amd64.tar.gz"
Starting to build Kubernetes
Downloading "https://dl.k8s.io/v1.29.4/kubernetes-server-linux-amd64.tar.gz"
```


如果不指定的话,默认使用的 type 为 url,会从官方的 dl.k8s.io 下载对应版本的二进制文件,并且可以指定对应的架构,下面是一个指定架构为 arm64, kubernetes 版本为 v1.30.1 的 kind 构建节点镜像的命令:

```shell
lan@lank8s.cn:~/work/lanactions/lanactions/kind$ bin/kind build node-image --arch arm64 v1.30.1
Detected build type: "release"
Building using release "v1.30.1" artifacts
Starting to build Kubernetes
Downloading "https://dl.k8s.io/v1.30.1/kubernetes-server-linux-arm64.tar.gz"
```

简直不要太方便!!

# 容我再说两句话

如果在这么方便的情况下你仍然不想自己动手构建镜像,那么你可以直接使用我已经构建好的容器镜像: https://github.com/liangyuanpeng/kubernetes/pkgs/container/kindest%2Fnode

基本格式为: `ghcr.io/liangyuanpeng/kindest/node:{kind_version}:{k8s_version}`, 例如 `ghcr.io/liangyuanpeng/kindest/node:v0.23.0-v1.31.0-alpha.2` ,当然也有不包含 kind 版本格式的容器镜像,例如:`ghcr.io/liangyuanpeng/kindest/node:v1.31.0-alpha.2`

上述容器镜像构建都是通过 github action 自动化进行构建的,包含了测试版本的 kubernetes (Kind 官方发布的 kindest/node 不包含测试版本的kubernetes).

如果有疑问或者问题都可以在下方添加评论.

# 注意点

Kind 命令行构建的容器镜像不支持多架构的,但可以尝试自己手动构建.

1. 构建 amd64 的镜像
2. 构建 arm64 的镜像
3. 使用 docker manifest 命令来构建一个多架构容器镜像.

# 人工智能推荐

如果你需要将一些容器镜像一起打包到 kindest/node 镜像里面,那么可以参考我给 Xline 提交的 PR:[Add github action to run e2e test with kubernetes cluster.](https://github.com/xline-kv/Xline/pull/696/files)

基本上就是将构建好的 Xline 内置到自定义构建的 kindest/node 容器镜像内,然后在 CI 中可以直接使用内置的 xline 容器镜像而不需要再下载 xline 镜像了,下面贴出对应的 Dockerfile:

```Dockerfile
ARG K8S_VERSION

FROM kindest/node:${K8S_VERSION}

RUN mkdir /tmp/kind
COPY xline.tar /tmp/kind/
RUN ( containerd -l warning & ) && ctr -n k8s.io images import --no-unpack /tmp/kind/*.tar
RUN rm /tmp/kind/*.tar
```

---
layout: post
slug: "quick-start-shipwright"
title: "shipwright快速入门"
subtitle: ""
description: ""
date: 2023-05-23
author: "梁远鹏"
image: "/img/banner/743a4e9227e1f14cb24a1eb6db29e183.jpg"
published: false
tags:
- cdf
- shipwright
  categories: [ cloudnative ]
--- 

# 
shipwright 是由红帽开源并且捐赠给 CDF的一个基于 tekton 之上的容器镜像框架，将各种镜像构建方式抽象成 K8S CRD 对象，提供统一的使用体验,在使用时不需要关心内部的一些具体细节，底层构建在 tekton 之上，目前是 CDF 孵化项目。

shipwright 的核心价值观是 简单性，灵活性以及安全性。

简单性意味着项目提供了镜像构建的直观且统一的用户体验，因此用户不必关心底层的一些内部具体细节。

灵活性意味着shipwright封装了镜像构建的这一过程的同时提供了一些方式满足用户的需求，例如Parameters API和volumes参数等等。

shipwright 的安全性始于构建策略API中内置的透明的 pod 安全上下文？特权容器和root容器， shipwright 本身发布的镜像使用cosign签名并且社区使用 trivy 来检测镜像漏洞。

https://shipwright.io/blog/2022/10/25/bringing-shipwright-to-beta-and-beyond/

# 关系

一个 BuildRun 对应一个 TaskRun

# 主要内容

主要有三个对象：

- BuildStrategy
- Build
- BuildRun


其中 Build 和BuildRun的关系正如 Tekton 中 Task 和 TaskRun 的关系一样。也就是 Build 对象负责镜像构建动作的一些定义，而 BuildRun 是容器镜像构建的真正入口，创建了一个 BuildRun 对象时才会真正的开始容器镜像的构建。接下来了解一下三个对象主要负责的内容时什么:


## BuildStrategy

BuildStrategy 也就是构建策略，也就是通过什么方式来进行容器镜像的构建。

目前支持的构建策略:
- buildpacks
- buildkit
- ko
- kaniko
- s2i
- builddah

基本上是覆盖了常见的几种镜像构建方式,如果有一些特殊的镜像策略要扩展的话也可以通过定义一个BuildStrategy对象来执行自定义的shell的方式来达到目的。

## Build

定义了镜像构建相关的一些上下文信息，主要是以下几个内容：

Source Code：需要构建的容器镜像所对应的源码。
Output image：构建容器镜像后的去处，例如镜像名称 版本，镜像label以及推送容器镜像所需要的认证信息等。
Build Strategy：使用哪一种容器镜像构建策略来执行，也就是上述的 BuildStrategy 对象。

还有一些其他内容：

构建容器镜像时需要的参数，例如 ko 构建需要传递一些 go build 相关的参数。
构建容器镜像时需要特定的持久化空间(volume),这个必须是构建策略支持传递 volume 并且支持重写，否则将会在 buildRun 时失败。 例如 ko 的volume支持重写，而 buildpacks 的 volume 不支持重写。 甚至有的构建策略没有可以传递的 volume。具体情况取决于实际需求，大部分情况下不需要关心 volume 这一块。 （构建缓存在shipwright是怎么样的，例如构建java应用，似乎更多的是编译缓存 而不是镜像构建缓存。）
镜像构建完成后的一些清理工作，例如 镜像构建成功后多久清理 build/buildRun，最多保持多少个 build/buildRun 记录。

todo： jib 方式的构建策略?

## BuildRun

只有创建了BuildRun对象才是真正开始容器镜像的构建，需要声明使用哪一个 Build 对象来执行。

BuildRun对象同样支持构建对象的其他一些内容：
构建容器镜像时需要的参数，例如 ko构建参数 xxxx , ko version, target-platform
构建容器镜像时需要特定的持久化空间(volume),这个必须是构建策略支持传递 volume 并且支持重写，否则将会在 buildRun 时失败。 例如 ko 的volume支持重写，而 buildpacks 的 volume 不支持重写。 甚至有的构建策略 没有可以传递的 volume。
镜像构建完成后的一些清理工作，例如 镜像构建成功后多久清理 build/buildRun，最多保持多少个 build/buildRun 记录。

这部分内容如果 Build 对象也声明了那么会以 BuildRun 对象声明的内容为准，也就是会覆盖 Build 对象的声明。


# 简单尝试一下

选择 ko 方式进行容器镜像构建，ko是xxxxx

容器镜像仓库选择 dockerhub，你也可以自己部署一个  distribution/zot 作为本地的容器镜像仓库。

首先需要部署 shipwright，由于基于tekton，因此需要先部署 tekton，

tekton
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.44.0/release.yaml
shipwright
kubectl apply -f https://github.com/shipwright-io/build/releases/download/nightly/nightly-2023-05-24-1684904969.yaml

先 apply 对应的镜像构建策略

kubectl apply -f https://github.com/shipwright-io/build/releases/download/v0.10.0/sample-strategies.yaml

// git clone https://github.com/shipwright-io/build.git
// kubectl apply -f build/samples/buildstrategy/ko


```yaml
---
apiVersion: shipwright.io/v1alpha1
kind: Build
metadata:
  name: ko-build
  annotations:
    build.shipwright.io/build-run-deletion: "false"
spec:
  paramValues:
    - name: go-flags
      value: "-v -mod=vendor -ldflags=-w"
    - name: go-version
      value: "1.19"
    - name: package-directory
      value: ./cmd/shipwright-build-controller
  source:
   url: https://github.com/shipwright-io/build
  strategy:
    name: ko
    kind: ClusterBuildStrategy
  output:
    image: lypgcs/shipwright-build
    credentials:
      name: push-secret
```

源码地址写的是 github.com,如果你的访问速度比较慢的话可以将 github.com 修改为 gitee.com,有我创建的用于同步代码的 shipwright-io 组织。

目前不支持一次构建镜像推送到多个tag，例如 nightly 场景，构建了镜像 aaaa/bbb:20230524 以及 aaaa/bbb:latest


等待构建中....


```shell
lan@lan:~/server/cdf/shipwright$ k get po
NAME                                  READY   STATUS            RESTARTS   AGE
ko-buildrun-tz7bm-pod                 0/4     Completed         0          8m
lan@lan:~/server/cdf/shipwright$ shp buildrun list
NAME                            STATUS          AGE
ko-buildrun                     Succeeded       8m
```

可以看到镜像已经构建完成了并且推送到了容器镜像仓库。
TODO image from registry.


看一下ko构建策略中 buildRun 创建出来的 taskRun 都有什么容器:

k get pod ko-buildrun-tz7bm-pod -o jsonpath={.spec.containers[*].name}
step-source-default step-prepare step-build-and-push step-image-processing

可以看到主要有四个容器,而如果你尝试 buildpacks 构建策略时会发现只有三个容器，因此不同的构建策略默认的容器数量可能是不一样的。


k get pod buildpack-nodejs-buildrun-76jnw-pod -o jsonpath={.spec.containers[*].name}
step-source-default step-prepare step-build-and-push



接下来丰富一下 Build/BuildRun 对象，希望构建时为镜像添加一些 label/annotations

再次观察，可以看到 pod 内的容器从 3个 变成了 4个。

ko 构建策略中创建出来的 pod 依然是 4 个容器，而 buildpacks 构建策略创建出来的 pod 的容器数量从3变成了4.

step-source-default step-prepare step-build-and-push
-->
step-source-default step-prepare step-build-and-push step-image-processing


很明显这是利用了 tekton task 灵活组装的能力，当需要更多的能力时只需要添加对应的 task 就可以了。  ？？？ 需要这句话，可以从 taskRun 的角度看看，如果需要的话可以加上。

稍等一下...


```shell
lan@lan:~/server/cdf/shipwright$ k get po
NAME                                  READY   STATUS      RESTARTS   AGE
ko-dztz4-7gjxr-pod                    0/4     Completed   0          19m
ko-zrfps-4z4zp-pod                    0/4     Completed   0          41m
```

好了，现在镜像构建完成了，使用 oras 命令查看一下镜像是否已经有刚才设置的  label/annotations 信息了。


查看镜像的 labels 信息:
```shell
lan@lan:~/server/cdf/shipwright$ oras manifest fetch index.docker.io/lypgcs/shipwright-trigger:test-labeled | jq .annotations
{
  "org.opencontainers.image.base.digest": "sha256:90d72025de22146c02d80fd4712cc9de828ec279bc107d7b4561f42e71687b0a",
  "org.opencontainers.image.base.name": "registry.access.redhat.com/ubi9/ubi-minimal:latest",
  "org.opencontainers.image.source": "https://github.com/liangyuanpeng",
  "org.opencontainers.image.url": "https://github.com/liangyuanpeng"
}
```

查看镜像的 annotations 信息:
```shell
lan@lan:~/server/cdf/shipwright$ oras manifest fetch-config index.docker.io/lypgcs/shipwright-trigger:test-labeled | jq .config.Labels
{
  "architecture": "x86_64",
  "build-date": "2023-05-03T08:55:50",
  "com.redhat.component": "ubi9-minimal-container",
  "com.redhat.license_terms": "https://www.redhat.com/en/about/red-hat-end-user-license-agreements#UBI",
  "description": "This is my cool image",
  "maintainer": "liangyuanpeng",
  "name": "ubi9-minimal",
  "release": "484",
  "summary": "Provides the latest release of the minimal Red Hat Universal Base Image 9.",
  "url": "https://access.redhat.com/containers/#/registry.access.redhat.com/ubi9-minimal/images/9.2-484",
  "vendor": "Red Hat, Inc.",
  "version": "9.2"
}
```

可以看到镜像包含了刚才设置的 labels 和 annotations。


# 用例

## openfunction

openfunction 是...

openfunction 使用 shipwright 构建容器镜像


## OpenShift Builds?

# triggers 组件

shipwright triggers 组件希望将shipwright连接到更庞大的生态系统，例如通过和 CDEvents，ArgoCD集成等等。

# 总结

基本上 shipwright 专注于容器镜像构建这一件事情上，上述讲述了 shipwright 最核心的内容，同时shipwright还有一个正在开发中的 triggers 组件，用于更好的集成？ 例如 github webhook来触发容器镜像构建，实际的场景是有的，例如PR合并后开始构建对应的容器镜像。

实现了 Tekton CustomRun，可以直接作为 Tekton Task 运行在 TaskRun 和 pipeline 当中，因此可以在一个更大的 pipeline 中结合 shipwright 提供的容器镜像构建能力完成更多的玩法。

类似于，当某个 Tekton Task 完成时开始构建镜像，然后当构建镜像完成之后使用 cosign 或其他工具为容器镜像签名，以完善企业内的软件供应链安全。

## 更多的想象空间

当前的 shipwright triggers 还处于早期阶段，不过已经可以作为 Tekton CustomRun 完美的结合在 Tekton Pipeline/Task 当中了。

未来shipwright trigger 本身还会支持一些构建镜像相关的功能，而不是让用户去操作 Tekton，从而提供给好的用户体验。

- Build 对象之间的 trigger，例如 当容器镜像A构建完成后开始构建容器镜像B， (镜像AB之间可能有一些依赖关系)
- 容器镜像构建完成后利用cosign为容器镜像签名


# 参考
https://blog.csdn.net/CCqwas/article/details/123585067

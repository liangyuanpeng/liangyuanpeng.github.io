---
layout:     post 
slug:      "k8s-rollout-with-openkruise"
title:      "使用kruise-rollout进行灰度发布"
subtitle:   "使用kruise-rollout进行灰度发布"
description: " "
date:       2023-03-16
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612744351/hugo/blog.github.io/pexels-bruno-cervera-6032877.jpg"
published: false
tags:
    - kubernetes
    - CloudNative
    - OpenKruise
    - cncf
categories: 
    - kubernetes
---  

# 前提

- kubernetes
- helm
- kubectl-kruise  

## 安装 kubectl-kruise

TODO 提供release页面地址,
可以使用kruise发布页面来下载二进制,也可以使用 krew 命令来安装 kubectl-kruise,

```shell
krew install kruise
```

# 部署 kruise rollouts

使用 helm 来部署 openkruise rollouts,

```shell
helm repo add openkruise https://openkruise.github.io/charts/
helm install kruise-rollout openkruise/kruise-rollout --version 0.3.0
```



# 

由于 openKruise 是以旁路的方式来做到灰度发布的效果，因此会有一些可见性的问题，例如当一个人讲 openkruise rollouts 应用到一个 deployment 后，第二个人不知道这个情况,当他去升级 deployment (其他资源也是一样的道理) 时会发现在 apply 后应用没有任何反应.


第二个是与 gitops 可能的冲突，在 git 仓库中存放的 deployment 资源文件与实际不一样,
TODO 测试一下， 对 kruise rollouts 是否有影响.

好处是无侵入性,不需要修改原有的 Deployment 资源就可以得到灰度发布等功能.

一个鲜明的对比是 Argo Rollouts 使用了一个新的CRD资源来实现 Deployment 的灰度发布,也就是说对于存量应用,只有将 Deployment 资源修改为具备灰度发布功能的 argo rollouts crd 资源才行.

TODO 自动化升级时,暂停了 1.再继续 2.回滚

openkruise 的回滚是依靠原有资源自有的回滚机制? 与 Argo Rollouts 对比.


灰度发布依靠pod资源来换流量, 这是K8S service机制决定的，需要有pod才会分到部分流量.

另一个是与ingress controller集成,直接在L7路由层将流量分发到对应版本的 pod,不需要资源换流量,例如达到 20% 的流量分到 podA,80%的流量分到 podB.
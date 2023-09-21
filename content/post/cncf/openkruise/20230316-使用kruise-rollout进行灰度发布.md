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

可以从workload的annotations中查看是否有 `rollouts.kruise.io/xxx`的annotation,如果有则说明当前workload被kruise rollout引用,反之则没有.

好处是无侵入性,不需要修改原有的 Deployment 资源就可以得到灰度发布等功能.

一个鲜明的对比是 Argo Rollouts 使用了一个新的CRD资源来实现 Deployment 的灰度发布,也就是说对于存量应用,只有将 Deployment 资源修改为具备灰度发布功能的 argo rollouts crd 资源才行.

TODO 自动化升级时,暂停了 1.再继续 2.回滚

openkruise 的回滚是依靠原有资源自有的回滚机制? 与 Argo Rollouts 对比.


# 

尝试一下使用 kruise rollout 进行灰度发布,这里选择的 workload 是 deployment.


1. kubectl apply deploy.yaml
2. kubectl patch deployment busybox -p '{"spec":{"template":{"spec":{"containers":[{"name":"busybox", "env":[{"name":"VERSION", "value":"version-2"}]}]}}}}'
3. kubectl kruise rollout approve rollout/busybox -n default

查看一下当前 deployment 的状态, kubectl get deploy,可以看到 deployment 的 UP-TO-DATE 字段变成了1,与 rollout 对象的`spec.strategy.canary.steps.replicas`是对应的,除非进行了版本回滚或批准继续灰度发布,否则不会更新,这就是 openkruise rollout 做的"手脚",让新版本的 deployment 暂时不会将更新内容应用到所有副本.对于不同的 workload 处理方式不同,有兴趣的可以看看其他的 openkruise rollout 对 workload 是如何处理的.

使用以下命令来通过汇总环境变量查看对应pod 版本的数量:
```shell
lan@yunhorn:~$ kubectl get pod -o=jsonpath='{range .items[*].spec.containers[*].env[*]}{.name}{"="}{.value}{"\n"}{end}' | sort | uniq -c | sort -rn
      9 VERSION=version-5
      1 VERSION=version-2
```

根据上述 kruise rollout 的配置文件,第一阶段灰度发布会升级一个pod,因此可以看到比例是`1:9`.

这里我们批准灰度发布,进行第二阶段灰度发布.


```shell
lan@yunhorn:~$ kubectl get pod -o=jsonpath='{range .items[*].spec.containers[*].env[*]}{.name}{"="}{.value}{"\n"}{end}' | sort | uniq -c | sort -rn
      5 VERSION=version-5
      5 VERSION=version-2
```  

由于第二阶段设置的灰度发布数量是50%,因此当前显示版本信息为各占50%.到目前为止已经升级了一半的pod了.

由于第二阶段灰度发布设置的是暂停60s,因此等待60s后会自动进行第三阶段的灰度发布.你也可以将这个时间设置得更短一点用于测试.

此时再来看看pod的版本信息:

```shell
lan@yunhorn:~$ kubectl get pod -o=jsonpath='{range .items[*].spec.containers[*].env[*]}{.name}{"="}{.value}{"\n"}{end}' | sort | uniq -c | sort -rn
     10 VERSION=version-2
```  

可以看到 10个pod都已经完成了升级,并且是一个渐进式的升级过程,逐步的将部分流量分发到升级后的pod,发现问题可随时回滚.

现在说一下回滚的操作,kruise rollout 是不提供回滚能力的,因此如果你需要回滚则按照对应 workload 回滚方式进行操作,一些可能适用的方法:

1. kubectl apply 原有yaml
2. kubectl patch 将更新的内容patch回去
3. kubectl edit 将更新内容修改回去
4. 使用kubectl rollout 命令回滚

# 多版本发布

kruise rollout 允许进行多版本发布,例如原有版本是v1,首先进行灰度发布v2,当发布到第二阶段v2版本pod达到50%时开始灰度发布版本v3,kruise rollout 将会重新开始进行灰度发布的步骤,也就是第一阶段,将发布一个v3版本的po,会将一个v2 pod 升级为 v3 pod,再继续第二阶段时将会发布50%的v3 pod,而v2 pod都被v3 pod代替,因此数量为0.

TODO 画图.


# HPA兼容

如果你同时使用了HPA和kruise rollout,那么建议 kruise rollout 中的replicas 字段设置为百分比而不是具体的副本数,从而让应用在 HPA 进行扩容或缩容时也能让应用进行对应的响应.

对于使用了 KEDA 来进行扩容或缩容的情况来说也是如此.

TODO ingress controller集成

#

灰度发布依靠pod资源来换流量, 这是K8S service机制决定的，需要有pod才会分到部分流量.

另一个是与ingress controller集成,直接在L7路由层将流量分发到对应版本的 pod,不需要资源换流量,例如达到 20% 的流量分到 podA,80%的流量分到 podB.
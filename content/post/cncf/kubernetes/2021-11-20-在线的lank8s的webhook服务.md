---
layout:     post 
slug:      "deploy-lank8s-webhook-for-k8s.gcr.io"
title:      "部署在线的lank8s webhook之后,不再为k8s.gcr.io/gcr.io镜像苦恼"
subtitle:   ""
description: ""
date:       2021-11-20
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags:
    - cncf 
    - tech
    - k8s
    - kubernetes
categories: [ kubernetes ]
---

# ⚠这个在线webhook当前已经不再提供使用⚠

⚠这个在线webhook当前已经不再提供使用⚠

⚠推荐的做法是设置镜像仓库镜像,参考 [kind(containerd) 的配置](https://liangyuanpeng.com/post/run-k8s-with-kind/)⚠


# 什么是lank8s webhook  

前提: 使用这项在线服务需要保证kubernetes所在的机器是联网状态.

lank8s webhook是一项在线的webook服务,唯一的作用就是将本地集群中的`deployments/daemonsets/statefulsets`,镜像的`k8s.gcr.io`替换为`lank8s.cn`,不再为墙外镜像苦恼.    

马上将会支持替换`gcr.io`镜像为`gcr.lank8s.cn`.

# 会影响速度吗?  

经过测试,基本上是在毫秒甚至微妙级别,和部署在集群中差别不大.

# 在本地kubernetes集群部署webhook配置  

```yaml
apiVersion: admissionregistration.k8s.io/v1beta1
kind: MutatingWebhookConfiguration
metadata:
  name: lanwebhook
webhooks:
  - name: lanwebhook.lank8s.cn
    clientConfig:
      url: "https://lank8s.cn/mutate"
    rules:
      - operations: [ "CREATE" ]
        apiGroups: ["apps", ""]
        apiVersions: ["v1"]
        resources: ["deployments","daemonsets","statefulsets"]
```  

这是一个最简的配置,你也可以根据具体情况扩展这个配置文件,例如加上限制某个namespace才启用这个`MutatingWebhook`.    

# 试用  

接下来试着通过这个在线的webhook部署一下gcr.io的镜像,镜像使用收集k8s监控数据时经常用到的`k8s.gcr.io/metrics-server/metrics-server`镜像.具体可以来看[部署metrics-server,把kubectl top用起来](https://liangyuanpeng.com/post/deploy-metrics-server-for-kubectl-top/)

# 注意  

- 请不要将这项服务使用在线上环境(防止发生未知事故),在开发环境和测试环境愉快使用.  
- 很快会开源 webhook 并且手把手教你部署在本地集群,线上环境应将 webhook 部署在集群内.
- 当前 lank8s webhook 只对`Deployment`有效,很快将会对`Daemonsets`和`Statefulsets`提供支持.



---
layout:     post 
slug:      "deploy-lank8s-webhook-for-k8s.gcr.io"
title:      "部署lank8s webhook之后,不再为k8s.gcr.io镜像苦恼"
subtitle:   ""
description: ""
date:       2021-11-20
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1635353670/hugo/banner/pexels-helena-lopes-2253275.jpg"
published: true
tags:
    - cncf 
    - tech
    - k8s
    - kubernetes
categories: [ kubernetes ]
---

# 什么是lank8s webhook  

前提: 使用这项在线服务需要保证kubernetes所在的机器是联网状态.

lank8s webhook是一项在线的webook服务,唯一的作用就是将本地集群中的`deployments/daemonsets/statefulsets`,镜像的`k8s.gcr.io`替换为`lank8s.cn`,不再为墙外镜像苦恼.    

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

# 注意  

- 请不要将这项服务使用在线上环境(防止发生未知事故),在开发环境和测试环境愉快使用.  
- 很快会开源webhook并且手把手教你部署在本地集群,线上环境应将webhook部署在集群内.
- 当前lank8s webhook只对`Deployment`有效,很快将会对`Daemonsets`和`Statefulsets`提供支持.
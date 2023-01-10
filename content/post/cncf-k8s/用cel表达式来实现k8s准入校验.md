---
layout:     post 
slug:      "k8s-admissionregistration-with-cel"
title:      "用cel表达式来实现k8s准入校验"
subtitle:   ""
description: ""
date:       2023-01-09
author:     "梁远鹏"
image: "img/post-bg-2015.jpg"
published: true
tags:
    - k8s
    - cncf
    - k8s-1.26
categories: [ CloudNative ]
---

# 前言  

在 K8S 1.26 版本以前,达到 K8S 准入校验策略效果的方式有两种：
1. 自己实现 K8S webook
2. 直接使用 CNCF 项目中以 K8S 策略展开的项目,例如`OPA`、`kyverno`.

这些都是 K8S 非默认的内容,K8S只负责将流量转发到对应的 webhook,具体是怎样一个逻辑判断是在外部处理的.而现在 K8S 支持了一种内置的准入校验方式，使用 CEL 表达式来完成 webhook 的校验逻辑，在一定程度上替代了外部 webhook,一些常见的比较简单的校验内容可以直接使用 CEL 表达式来完成,比如校验当前资源使用的镜像是否是内网地址的镜像,如果不是则校验不通过.

# 准备环境

```shell
wget https://github.com/kubernetes-sigs/kind/releases/download/v0.17.0/kind-linux-amd64
wget https://storage.googleapis.com/kubernetes-release/release/v1.26.0/bin/linux/amd64/kubectl
mv kind-linux-amd64 kind && chmod +x kind && mv kind /usr/local/bin
chmod +x kubectl && mv kubectl /usr/local/bin
cp /usr/local/bin/kubectl /usr/local/bin/k
kind create cluster  --config dev/k8s/1.26/kindconfig/kind.yaml --image kindest/node:v1.26.0@sha256:691e24bd2417609db7e589e1a479b902d2e209892a10ce375fab60a8407c7352
k label namespace   default  environment=test
```

注意 kind 创建集群时需要指定 1.26的 image,否则默认会使用 1.25.3 版本.

另一个注意点是需要开启 ValidatingAdmissionPolicy 这个功能以及开启 admissionregistration.k8s.io/v1alpha1 API.

kind 配置文件如下:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
featureGates:
  "ValidatingAdmissionPolicy": true
runtimeConfig:
  "api/alpha": "true"
```

# 示例

例如希望限制一个 Deployment 的最大副本数,如果是自己开发 webhook,那么你至少需要编写代码,测试代码,部署 webhook.而对于使用`OPA`或`kyverno`,你至少需要了解对应的语法使用.

现在呢,你只需要添加一个带有 CEL 表达式的 K8S 配置就能够做到这样的效果.


```yaml
apiVersion: admissionregistration.k8s.io/v1alpha1
kind: ValidatingAdmissionPolicy
metadata:
  name: "demo-policy.example.com"
spec:
  matchConstraints:
    resourceRules:
    - apiGroups:   ["apps"]
      apiVersions: ["v1"]
      operations:  ["CREATE", "UPDATE"]
      resources:   ["deployments"]
  validations:
    - expression: "object.spec.replicas <= 5"
```  

这个策略配置看着也非常的直观,匹配 apps/v1 版本的 deployment 资源的 create 和 update 操作,并且只有当副本数`<=5`的情况下才能操作成功.

上述是策略的配置,还需要一个`ValidatingAdmissionPolicyBinding`资源表示上述策略的校验范围.

```yaml
apiVersion: admissionregistration.k8s.io/v1alpha1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: "demo-binding-test.example.com"
spec:
  policy: "demo-policy.example.com"
  matchResources:
    namespaceSelector:
    - key: environment,
      operator: In,
      values: ["test"]
```

上述示例配置表示,将校验策略应用到含有`environment=test`标签的 namespace 下,也就是在这些匹配的 namespace 下的所有 apps/v1 版本的 deployment 资源都会被校验副本数是否`<=5`.

我们还可以做到更强大的效果，将 CEL 表达式中的校验条件作为参数传递进来，比如将另一个CRD的资源字段作为最大副本数的值.

```yaml
apiVersion: admissionregistration.k8s.io/v1alpha1
kind: ValidatingAdmissionPolicy
metadata:
  name: "demo-policy.example.com"
spec:
  paramKind:
    apiVersion: rules.example.com/v1 # 需要有一个这样的CRD资源
    kind: ReplicaLimit
  matchConstraints:
    resourceRules:
    - apiGroups:   ["apps"]
      apiVersions: ["v1"]
      operations:  ["CREATE", "UPDATE"]
      resources:   ["deployments"]
  validations:
    - expression: "object.spec.replicas <= params.maxReplicas"
```  

从上述配置中可以看到,最大副本数从`5`变成了CRD资源的`maxReplicas`字段,从而让这个策略更加的灵活.

然后我们再定义一个策略绑定,并且应用到一个不同的条件(也就是说,一个策略能够被多个策略绑定所应用):

```yaml
apiVersion: admissionregistration.k8s.io/v1alpha1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: "demo-binding-production.example.com"
spec:
  policy: "demo-policy.example.com"
  paramsRef:
    name: "demo-params-production.example.com"
  matchResources:
    namespaceSelector:
    - key: environment,
      operator: In,
      values: ["production"]
---
apiVersion: rules.example.com/v1
kind: ReplicaLimit
metadata:
  name: "demo-params-production.example.com"
maxReplicas: 100
```

上述配置我们为`environment=production`的 namespace 应用了最大副本数为100的策略限制,然后我们还可以再写一份配置,将最大副本数应用到另一个环境,例如:

```yaml
apiVersion: admissionregistration.k8s.io/v1alpha1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: "demo-binding-dev.example.com"
spec:
  policy: "demo-policy.example.com"
  paramsRef:
    name: "demo-params-dev.example.com"
  matchResources:
    namespaceSelector:
    - key: environment,
      operator: In,
      values: ["dev"]
---
apiVersion: rules.example.com/v1
kind: ReplicaLimit
metadata:
  name: "demo-params-dev.example.com"
maxReplicas: 2
```

为`environment=dev`的 namespace 的资源限制了最大副本数为2.

apply失败:
```shell
The deployments "envoy" is invalid: : ValidatingAdmissionPolicy 'demo-policy.example.com' with binding 'demo-binding-test.example.com' denied request: failed expression: object.spec.replicas <= 5
```

可以从提示中看到,apply envoy 这个 deployment 的时候失败了,失败的策略是 `object.spec.replicas <= 5`


参考资料：官方博客 https://kubernetes.io/blog/2022/12/20/validating-admission-policies-alpha/

# TODO

我们来修改一下让策略变成 含有`environment=test`标签的 namespace 下所有 pod 的镜像资源必须是内网地址.

# 注意

本文还在持续创作中

---
layout:     post 
slug:      "question-list-of-kubernetes"
title:      "[长期更新]kubernetes问题列表记录"
subtitle:   ""
description: "kubernetes问题列表记录,欢迎投稿."
date:       2023-05-04
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags:
    - k8s
    - cncf
    - kubernetes
categories: 
    - cloudnative
    - kubernetes
---


# 说明

本文主要收集常见场景下 kubernetes 遇到的一些常见问题,欢迎对本文进行投稿你认为好的场景或问题.

## 如何保证 sidecar 先于 app 容器销毁

通过信号方式,目前 kubernetes 已经拥有正式的 sidecar container 功能了,可以都介绍一下.
TODO 完善展开


# 将 kubeconfig 文件转换成证书文件

对于我来说主要的场景是将默认的管理员 kubeconfig 内容转换成证书文件,然后放在 nginx/envoy 来代理 kubernetes 请求,减少双向证书认证带来的繁琐.

```shell
kubectl config view --minify --flatten -o json | jq ".clusters[0].cluster.\"certificate-authority-data\"" | sed 's/\"//g' | base64 --decode >> ca.crt 
kubectl config view --minify --flatten -o json | jq ".users[0].user.\"client-certificate-data\"" | sed 's/\"//g' | base64 --decode >> client.crt 
kubectl config view --minify --flatten -o json | jq ".users[0].user.\"client-key-data\"" | sed 's/\"//g' | base64 --decode >> client.key 
```


# IP 固定的研究环境

目前在我个人的研究环境下,我经常是使用备份好的 Etcd 数据来恢复某些特定场景的 kubernetes 集群,但有一个问题是新的虚拟机 hostname 和 IP 可能和备份数据中的 kubernetes hostname 和 IP 是不一样的,这时候就需要使用创建虚拟网卡,然后将 kubernetes 服务绑定到虚拟网卡的 IP 上,但这只设计到单节点的集群,还没有多节点的需求.

这适用于 kubeadm 和 K3s 来恢复 kubernetes 的场景.

# 使用dynamicClient创建资源的时候报错 the server could not find the requested resource

下面是一个关键部分的 golang 代码.

```golang
		gvr := schema.GroupVersionResource{Group: "argoproj.io", Version: "v1alpha1", Resource: "Workflow"}
		gvk := schema.GroupVersionKind{Group: "argoproj.io", Version: "v1alpha1", Kind: "Workflow"}

		obj := &unstructured.Unstructured{}
		dec := yaml.NewDecodingSerializer(unstructured.UnstructuredJSONScheme)

		dec.Decode([]byte(data), &gvk, obj)

		_, err = dynamicClient.
			Resource(gvr).
			Namespace("default").Create(context.TODO(), obj, metav1.CreateOptions{})
```

可以看到主要是想使用 dynamicClient 客户端来创建 argo workflow 的 `Workflow` 资源,但是得到了`the server could not find the requested resource`的错误.

原因是因为 gvr 填写 Resource 时填得不对,正确的是`workflows`资源,而不是`Workflow`,将其更新为下面的样子就没问题了.

```golang
gvr := schema.GroupVersionResource{Group: "argoproj.io", Version: "v1alpha1", Resource: "workflows"}
```

Workflow 是 Kind,而 workflows 才是对应的 Resource,这是需要注意的一个地方.


# ValidatingAdmissionPolicy 验证可选项

```yaml
...
  validations:
  - expression: "!object.spec.template.spec.containers.exists_one(c, c.image.startsWith('registry.lank8s.cn/'))"
    message: "container image is not approve with start with registry.lank8s.cn"
  - expression: "!object.spec.template.spec.initContainers.exists_one(c, c.image.startsWith('registry.lank8s.cn/'))"
    message: "initContainers image is not approve with start with registry.lank8s.cn"
...
```

例如上述的 cel 表达式是希望禁止在集群内使用 registry.lank8s.cn 这个域名的容器镜像,但如果没有定义 initContainer 容器的话,这时候会报错,提示不存在 initContainers 这个字段:


```shell
$ kubectl apply -f sts.yaml 
The statefulsets "tools" is invalid: : ValidatingAdmissionPolicy 'vap2' with binding 'vapb2' denied request: expression '!object.spec.template.spec.initContainers.exists_one(c, c.image.startsWith('registry.lank8s.cn/'))' resulted in error: no such key: initContainers
```

可以首先判断是否定义了 initContainer,如果没有定义则通过 cel 表达式:

```yaml
...
  validations:
  - expression: "!object.spec.template.spec.containers.exists_one(c, c.image.startsWith('registry.lank8s.cn/'))"
    message: "container image is not approve with start with registry.lank8s.cn"
  - expression: "!has(object.spec.template.spec.initContainers) || !object.spec.template.spec.initContainers.exists_one(c, c.image.startsWith('registry.lank8s.cn/')) "
...
```

也可以判断 initContainers 这个数组的长度,如果长度小于0,则 cel 表达式通过:

```yaml
...
  validations:
  - expression: "!object.spec.template.spec.containers.exists_one(c, c.image.startsWith('registry.lank8s.cn/'))"
    message: "container image is not approve with start with registry.lank8s.cn"
  - expression: "size(object.spec.template.spec.initContainers)<=0 || !object.spec.template.spec.initContainers.exists_one(c, c.image.startsWith('registry.lank8s.cn/'))"
    message: "initContainers image is not approve with start with registry.lank8s.cn"
...
```

# ValidatingAdmissionPolicy 中 cel 的类型检查

例如希望根据 StatefulSet 的副本数做一些判断逻辑,填写了下面这样的表达式:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: vap2
spec:
...
  validations:
  - expression: "object.replicas > 1" # should be "object.spec.replicas > 1"
    message: "must be replicated"
    reason: Invalid
...
```

上述 yaml 是可以正常 apply 的,但是在 ValidatingAdmissionPolicy 资源的 status 中会提示一些错误信息,可以通过 kubectl describe 命令来检查:


```shell
$ kubectl describe ValidatingAdmissionPolicy vap2
Name:         vap2
Namespace:    
Labels:       <none>
Annotations:  <none>
API Version:  admissionregistration.k8s.io/v1
Kind:         ValidatingAdmissionPolicy
Metadata:
  Creation Timestamp:  2024-05-20T06:51:48Z
  Generation:          4
  Resource Version:    20075
  UID:                 d8d1e433-40b2-4f75-ade1-48edf20c1eb0
Spec:
  Audit Annotations:
    Key:               high-replica-count
    Value Expression:  'StatefulSets spec.replicas set to ' + string(object.spec.replicas)
  Failure Policy:      Fail
  Match Constraints:
    Match Policy:  Equivalent
    Namespace Selector:
    Object Selector:
    Resource Rules:
      API Groups:
        apps
      API Versions:
        v1
      Operations:
        CREATE
        UPDATE
      Resources:
        statefulsets
      Scope:  *
  Validations:
    Expression:          object.replicas > 1
    Message:             must be replicated
    Reason:              Invalid
    Expression:          object.spec.replicas > 20
    Message Expression:  'StatefulSets spec.replicas set to ' + string(object.spec.replicas)
    Expression:          !object.spec.template.spec.containers.exists_one(c, c.image.startsWith('registry.lank8s.cn/'))
    Message:             container image is not approve with start with registry.lank8s.cn
    Expression:          !has(object.spec.template.spec.initContainers) || !object.spec.template.spec.initContainers.exists_one(c, c.image.startsWith('registry.lank8s.cn/')) 
    Message:             initContainers image is not approve with start with registry.lank8s.cn
Status:
  Observed Generation:  4
  Type Checking:
    Expression Warnings:
      Field Ref:  spec.validations[0].expression
      Warning:    apps/v1, Kind=StatefulSet: ERROR: <input>:1:7: undefined field 'replicas'
 | object.replicas > 1
 | ......^

Events:  <none>
```

可以从上述 describe 的内容清晰的看到,有一个 type checking 的告警信息,`apps/v1, Kind=StatefulSet: ERROR: <input>:1:7: undefined field 'replicas'` 没有在 StatefulSet 这个类型中找到 object.replicas 这样结构的字段.

这很方便的可以帮助用户提前发现,但类型检查目前来说也有一些限制(1.30):

- 不支持通配符,如果 spec.matchConstraints.resourceRules 中 `apiGroups`, `apiVersions` 或 `resources` 中任意一个有 "*" 的表达式,那么不会进行类型检查
- 类型检查只会检查一个 ValidatingAdmissionPolicy 资源中的前 10 个资源,防止 ValidatingAdmissionPolicy 指定了太多资源造成了过多的计算.
- 类型检查不会影响策略行为,也就是只会发出一个告警信息,即使有错误也不会中断策略检查.
- 类型检查不适用于CRD,包括匹配的 CRD 资源以及作为传参的 CRD 资源, CRD 资源会在未来版本支持.

上述描述信息基本上在[官方文档](https://kubernetes.io/docs/reference/access-authn-authz/validating-admission-policy/#type-checking)都可以查到.

# 我可以部署一个 kubernetes 社区的 testgrid 服务吗?

可以的,目前 testgrid 已经支持自己部署 testgrid 服务,但有一个缺点是必须要使用 GCP: https://github.com/GoogleCloudPlatform/testgrid/issues/489

## testgrid 的好处

很多 kubernetes 生态项目都会使用 prow 机器人来帮助项目做项目治理相关的事情,例如使用 `/lgtm` 和 `/approve` 和对 PR 进行 review 以及合并.

而 kubernetes 还会使用 prowjob 来做项目 CI,并且利用 [testgrid](https://testgrid.k8s.io/) 来监控 CI 的总体情况,从而发现一些不稳定的测试(Flaky Test),而 kubernetes 使用 prow 但并不一定会用 prowjob 来跑 CI,因为 prowjob 需要有自己的 CI 机器,这可能是一笔不小的经济负担,因此会选择使用 github action 来做 CI,但 github action 对于定时任务的监控没有 testgrid 来得直观.



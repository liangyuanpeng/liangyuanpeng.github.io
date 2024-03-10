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


# 将kubeconfig文件转换成证书文件

对于我来说主要的场景是将默认的管理员 kubeconfig 内容转换成证书文件,然后放在 nginx/envoy 来代理 kubernetes 请求,减少双向证书认证带来的繁琐.

```shell
kubectl config view --minify --flatten -o json | jq ".clusters[0].cluster.\"certificate-authority-data\"" | sed 's/\"//g' | base64 --decode >> ca.crt 
kubectl config view --minify --flatten -o json | jq ".users[0].user.\"client-certificate-data\"" | sed 's/\"//g' | base64 --decode >> client.crt 
kubectl config view --minify --flatten -o json | jq ".users[0].user.\"client-key-data\"" | sed 's/\"//g' | base64 --decode >> client.key 
```


# IP 固定的研究环境

目前在我个人的研究环境下,我经常是使用备份好的 Etcd 数据来恢复某些特定场景的 kubernetes 集群,但有一个问题是新的虚拟机 hostname 和 IP 可能和备份数据中的 kubernetes hostname 和 IP 是不一样的,这时候就需要使用创建虚拟网卡,然后将 kubernetes 服务绑定到虚拟网卡的IP上,但这只设计到单节点的集群,还没有多节点的需求.

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

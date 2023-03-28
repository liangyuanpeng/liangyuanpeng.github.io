---
layout:     post 
slug:      "registry-mirrors-for-containerd"
title:      "为containerd配置仓库镜像"
subtitle:   ""
description: ""
date:       2023-01-12
author:     "梁远鹏"
image: "img/post-bg-2015.jpg"
published: true
tags:
    - containerd 
    - cncf
    - kind
    - kubernetes
categories: 
    - cloudnative
---

# 前言    

containerd 的仓库镜像功能是很有用的功能,特别是国内无法访问 gcr.io 和 k8s.gcr.io 以及 registry.k8s.io 这些镜像仓库的情况下.

K3S 和 Kind 都提供了比较简单的方式来为内置的 containerd 配置仓库镜像.

# K3S   

下面列出关键部分,也就是配置镜像代理加速部分,至于 K3S 的部署不在本位内容范围内,修改好配置后重启下 K3S 就可以生效了.

```yaml
root@k3sm3:~# cat >> /etc/rancher/k3s/registries.yaml <<EOF
mirrors:
  "k8s.gcr.io":
    endpoint:
    - "https://lank8s.cn"
    - "https://k8s.lank8s.cn"
  "gcr.io":
    endpoint:
    - "https://gcr.lank8s.cn"
  "ghcr.io":
    endpoint:
    - "https://ghcr.lank8s.cn"
  "registry.k8s.io":
    endpoint:
    - "https://registry.lank8s.cn"
EOF
root@k3sm3:~# systemctl restart k3s
```

# Kind  

官方文档地址: https://kind.sigs.k8s.io/docs/user/local-registry/

有可能你使用以下命令会失效,是由于 Kind 的不断发展会导致下面字段 apiVersion 不再是 kind.x-k8s.io/v1alpha4 版本,而是更好的版本,本文使用的 Kind 版本是 `kind v0.17.0 go1.19.2 linux/amd64`.

kind.config 
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."gcr.io"]
    endpoint = ["https://gcr.lank8s.cn"]
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."k8s.gcr.io"]
    endpoint = ["https://k8s.lank8s.cn"]
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."registry.k8s.io"]
    endpoint = ["https://registry.lank8s.cn"]
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."ghcr.io"]
    endpoint = ["https://ghcr.lank8s.cn"]
```

执行以下命令用于初始化 K8S 集群.

```shell
oem@lan:~/repo/git/liangyuanpeng.github.io/content/post/cncf-containerd$ kind create cluster --config kind.config 
Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.25.0) 🖼 
 ✓ Preparing nodes 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind
```  

# 校验效果

K8S 测试环境准备好之后就可以部署一个容器来试试镜像拉取的效果.

deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: distroless
  labels:
    app: distroless
spec:
  selector:
    matchLabels:
      app: distroless
  replicas: 1
  revisionHistoryLimit: 1
  template:
    metadata:
      labels:
        app: distroless
    spec:
      containers:
        - name: envoy
          image: gcr.io/distroless/static:nonroot
```

执行以下命令来部署上述的 Deployment 资源.
```shell
kubectl apply -f deployment.yaml
```

这里提供了一个　yaml 用于部署　Deployment 来拉取 `gcr.io/distroless/static:nonroot` 镜像,如果配置生效的话那么在无法访问　`gcr.io` 的情况下可以看到容器会成功拉取到镜像,最后　Pod　的状态是 `CrashLoopBackOff` 是由于容器无法启动的问题.

# 本文更友好

使用一个 `gcr.io` / `registry.k8s.io` 中可以正常运行的一个容器,欢迎投稿.

# 关于 lank8s.cn

关于 lank8s.cn 可以通过 [lank8s.cn服务](https://liangyuanpeng.com/post/cncf-kubernetes/service-lank8s.cn/) 或 [Lank8s Github组织](https://github.com/lank8s) 了解更多.


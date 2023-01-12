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
categories: [ CloudNative ]
---

# 前言    

containerd 的仓库镜像功能是很有用的功能,特别是国内无法访问 gcr.io 和 k8s.gcr.io 以及registry.k8s.io 这些镜像仓库的情况下.

其他用到 containerd 的地方,K3S 和 Kind 都提供了比较简单的方式来为内置的 containerd 配置仓库镜像.

# K3S   

```yaml
root@ip-172-31-13-117:~# cat >> /etc/rancher/k3s/registries.yaml <<EOF
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
configs:
  "gcr.io":
    auth:
      username: admin # this is the registry username
      password: Harbor12345 # this is the registry password
EOF
systemctl restart k3s

```

# Kind  

官方文档地址: https://kind.sigs.k8s.io/docs/user/local-registry/


```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."gcr.io"]
    endpoint = ["https://gcr.lank8s.cn"]
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."k8s.gcr.io"]
    endpoint = ["https://k8s.lank8s.cn"]
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."ghcr.io"]
    endpoint = ["https://ghcr.lank8s.cn"]
```
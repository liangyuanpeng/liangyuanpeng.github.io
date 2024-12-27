---
layout:     post 
title:      "容器checkpoint"
subtitle:   "容器checkpoint"
description: " "
date:       2024-12-25
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: false
tags:
    - kubernetes
    - containerd
    - crio
categories: 
    - kubernetes

# 

https://github.com/checkpoint-restore/criu

https://kubernetes.io/zh-cn/docs/reference/node/kubelet-checkpoint-api/
https://kubernetes.io/blog/2022/12/05/forensic-container-checkpointing-alpha/


可能遇到的错误

 checkpointing of default/webserver/webserver failed (rpc error: code = Unknown desc = checkpoint/restore support not available)

 底层的CRI运行时不支持.


使用 containerd v2.0.1 时,报错提示找不到 criu 命令

```shell
curl -X POST "https://192.168.66.2:10250/checkpoint/kube-system/kube-scheduler-lank8slocal/kube-scheduler" --insecure --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt --key /etc/kubernetes/pki/apiserver-kubelet-client.key
checkpointing of kube-system/kube-scheduler-lank8slocal/kube-scheduler failed (rpc error: code = Unknown desc = CRIU binary not found or too old (<31600). Failed to checkpoint container "5d3928c0cbf48fd9bff326003f64173e4e0bac23395616692aa68ad334ca62fd": failed to check for criu version: exec: "criu": executable file not found in $PATH)
```
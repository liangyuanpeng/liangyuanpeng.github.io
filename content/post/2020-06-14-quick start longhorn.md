---
layout:     post 
title:      "longhorn helloworld"
subtitle:   ""
description: "前后端分离已经是大趋势，服务器端只需要关注自己的接口逻辑实现，而不需要关注前端的页面跳转，这一部分交由前端处理。常见的就是React应用或vue应用"
date:       2020-04-16
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1544363191/hugo/blog.github.io/743a4e9227e1f14cb24a1eb6db29e183.jpg"
published: false
tags:
    - Longhorn
    - Kubernetes 
    - k8s
    - CloudNative
categories: 
    - CloudNative
---

## 前言

## FAQ

1. 需要提前安装open-iscsi

```
[root@devmaster helmrepo]# kubectl logs -f  -n longhorn-system longhorn-manager-8smtj
time="2020-06-14T07:35:39Z" level=error msg="Failed environment check, please make sure you have iscsiadm/open-iscsi installed on the host"
time="2020-06-14T07:35:39Z" level=fatal msg="Error starting manager: Environment check failed: Failed to execute: nsenter [--mount=/host/proc/932/ns/mnt --net=/host/proc/932/ns/net iscsiadm --version], output , stderr, nsenter: failed to execute iscsiadm: No such file or directory\n, error exit status 1"
```


```
Debian/Ubuntu
sudo apt-get install open-iscsi
Redhat/Centos/Suse
yum install iscsi-initiator-utils
```
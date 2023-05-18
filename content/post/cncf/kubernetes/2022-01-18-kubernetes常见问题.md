---
layout:     post 
slug:      "kubernetes-qa"
title:      "kubernetes常见问题"
subtitle:   ""
description: ""
date:       2022-01-18
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags:
    - kubernetes
    - cncf 
categories: [ kubernetes ]
---    

# 声明  

本文会持续的更新,将在使用kubernetes过程中遇到的问题都收集起来.欢迎投稿加入你遇到的问题 :)

# 跨版本升级

## service-account-issuer is a required flag, --service-account-signing-key-file and --service-account-issuer are required flags  

版本v1.19.16升级到v1.23.x,二进制kube-apiserver升级后启动失败,提示`service-account-issuer is a required flag, --service-account-signing-key-file and --service-account-issuer are required flags`,原因就是在新版本中添加了新参数而旧版本没有这个参数.  

## only zero is allowed  

版本v1.19.16升级到v1.23.x,二进制kube-apiserver升级后启动失败,
```
E0118 00:40:00.935698    8504 run.go:120] "command failed" err="invalid port value 8080: only zero is allowed"
```  

参数`--insecure-port`只允许设置为`0`.  

这个还没注意到更新点,如果希望使用非tls端口要怎么做呢?  

# Volume挂载问题 

## configmap内容更新后,在pod中对应文件的修改时间没有变化  

这与configmap的更新机制有关

# 性能优化

## 将单独的资源存储到单独的etcd服务内

常见的是 将 event 内容存储到单独的 etcd 服务内, kube-apiserver 的 etcd-servers-overrides 参数支持将某个单独资源存储到特定的 etcd 服务内,下面是一个将 k8s event 存储到单独的 etcd 服务内的示例:

```shell
...
--etcd-servers-overrides=/events#https://127.0.0.1:2379
...
```

# 温馨提示 

本文持续更新
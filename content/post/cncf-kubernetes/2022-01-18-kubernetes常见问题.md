---
layout:     post 
slug:      "kubernetes-qa"
title:      "kubernetes常见问题"
subtitle:   ""
description: ""
date:       2022-01-18
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612709780/hugo/blog.github.io/pexels-matt-hardy-2568001.jpg"
published: true
tags:
    - kubernetes
    - cncf 
categories: [ kubernetes ]
---    

# 声明  

本文会持续的更新,将在使用kubernetes过程中遇到的问题都收集起来.欢迎投稿加入你遇到的问题.

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

# 温馨提示 

本文持续更新
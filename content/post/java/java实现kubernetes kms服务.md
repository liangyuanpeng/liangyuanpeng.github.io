---
layout:     post 
slug:      "impl-kubernetes-kms-service-with-java"
title:      "java实现kubernetes kms服务"
subtitle:   ""
description: "java实现kubernetes的kms grpc服务,实现数据加密"  
date:       2023-09-04
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: false
tags: 
    - kubernetes
    - java
    - kms
    - grpc
categories: 
    - cloudnative
---



kubernetes kms plugin 要求 KMS 服务需要有一个本地的 socket,而 grpc-java 目前似乎不支持 unix socket.

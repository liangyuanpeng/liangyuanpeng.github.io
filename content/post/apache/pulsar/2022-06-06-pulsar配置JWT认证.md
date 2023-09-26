---
layout:     post 
slug:      "deploy-pulsar"
title:      "部署去ZK后的Apache Pulsar"
subtitle:   ""
description: " "
date:       2022-06-06
author:     "梁远鹏"
image: "/img/banner/743a4e9227e1f14cb24a1eb6db29e183.jpg"
published: true
wipnote: true
tags:
    - CloudNative
    - pulsar
    - apache
categories: 
    - TECH
---

# 前言 

本文基本上是按照[官方文档](https://pulsar.apache.org/docs/next/security-jwt/)来实践的,非常简单.

首先要明确我们需要做的几件事情：

1. 生成 token 并且配置 Pulsar broker 开启 Token 认证.
2. 配置 Pulsar broker 开启自身需要用到的客户端认证( Broker 会调用 RestFul API).
3. 配置 Pulsar-admin 命令行使用的 Token 与 Broker 进行通信.
4. 使用 [https://github.com/pulsar-sigs/pulsar-client](https://github.com/pulsar-sigs/pulsar-client) 来收发消息,验证生产者和消费者.


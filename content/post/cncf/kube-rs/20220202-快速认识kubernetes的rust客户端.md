---
layout:     post 
slug:      "quick-start-kubernetes-client-rust"
title:      "快速认识kubernetes的rust客户端"
subtitle:   ""
description: ""
date:       2022-02-02
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags:
    - rust 
    - cncf
    - kube-rs
    - kubernetes
categories: [ kubernetes ]
---

# 介绍  

[kube-rs](https://github.com/kube-rs/kube-rs)目前是 CNCF 的沙箱项目,有一个官方的 controller 实现示例[controller-rs](https://github.com/kube-rs/controller-rs).  

还有一个 Rust 实现的 Operator 框架相关的项目是[krator](https://github.com/krator-rs/krator),Rust已经开始在云原生领域开始发力,前景我是很看好的.

本文会以查看 pod 的 log 为例,看看在 rust 的客户端中的代码是怎样的.  

# 伪代码讲解  

## 初始化客户端  

```rust
let client = Client::try_default().await?;
```  

## 拿到namespace下的所有pod  

```rust
let pods: Api<Pod> = Api::namespaced(client, &namespace);
```  

## 拿到pod中对应容器的日志  

```rust
let mut logs = pods
        .log_stream(&mypod, &LogParams {
            container: Some("container".to_owned()),  //指定容器名称
            follow: true,  //是否持续监听日志
            tail_lines: Some(1),  //tail 行数
            ..LogParams::default()
        })
        .await?
        .boxed();
```  

## 查看日志  

```rust
while let Some(line) = logs.try_next().await? {
        println!("{:?}", String::from_utf8_lossy(&line));
    }
```  

完整的例子在[log_stream.rs](https://github.com/kube-rs/kube-rs/blob/bf3b248f0c96b229863e0bff510fdf118efd2381/examples/log_stream.rs)  

# 总结  

虽然`kube-rs`在最近才进入 CNCF,但是其实已经被不少项目正式采用了,例如 CNCF 中的[krator](https://github.com/krator-rs/krator)、[krustlet](https://github.com/krustlet/krustlet)以及 linkerd2 中的[policy-controller](https://github.com/linkerd/linkerd2/tree/main/policy-controller).完整的项目采用列表可以在[kube-rs 采用者](https://github.com/kube-rs/website/blob/main/docs/adopters.md)找到.

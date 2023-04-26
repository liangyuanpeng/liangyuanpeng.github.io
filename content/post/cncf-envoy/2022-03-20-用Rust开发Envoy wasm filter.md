---
layout:     post 
slug:      "ennoy-wasm-filter-with-rust"
title:      "用Rust开发Envoy wasm filter"
subtitle:   ""
description: ""
date:       2022-03-20
author:     "梁远鹏"
image: "img/banner-pexels.jpg"
published: true
wipnote: true
tags:
    - envoy 
    - cncf
    - rust
categories: 
    - cloudnative
---

# 

# 目标  

用WASM filter实现`WWW-Authenticate`认证,并且`支持配置`域名白名单和URL白名单.  

# 了解envoy-wasm-rust-sdk例子  

首先非常感谢`tetratelabs`的相关工作,因为我们是基于[envoy-wasm-rust-sdk](https://github.com/tetratelabs/envoy-wasm-rust-sdk)来开发这样的一个WASM filter的,这个开源仓库提供了三个示例并且都配有相应的docker-comose.yaml,可以非常方便的看到示例的效果.  

有三个这样的示例:

- 日志记录器
- http过滤器
- network过滤器   

如果在这之前你已经看过这个项目的示例,那么看本文会很轻松,如果没有看过那我会推荐你先看一遍这篇文章,接着试一试[envoy-wasm-rust-sdk](https://github.com/tetratelabs/envoy-wasm-rust-sdk)的`http-filter`示例,最后再回来看一遍这篇文章,效果会更好.

## 示例项目结构

在本文中我们了解`http过滤器`这个示例就可以了,因为后续内容都是基于这个示例来做修改的.  

首先我们看一下这个示例的项目结构:

```shell
lan@lan:~/repo/git/envoy-wasm-rust-sdk/examples/http-filter$ tree .
.
├── Cargo.toml
├── docker-compose.yaml
├── envoy.yaml
├── README.md
├── src
│   ├── config.rs
│   ├── factory.rs
│   ├── filter.rs
│   ├── lib.rs
│   └── stats.rs
└── wasm
    └── module
        ├── Cargo.toml
        └── src
            └── lib.rs
```

这就是一个典型`lib`类型的`cargo项目`,最终的效果是将项目打包成一个wasm二进制文件.  

在本文中我们主要关注的是`config.rs`和`filter.rs`

## config.rs

`config.rs`主要是和配置相关的内容.  

```rust
...
pub struct SampleHttpFilterConfig {
    #[serde(default)]
    pub param: String,
}
...
impl Default for SampleHttpFilterConfig {
    fn default() -> Self {
        SampleHttpFilterConfig {
            param: String::default(),
        }
    }
}
```

`SampleHttpFilterConfig`是这个filter需要使用到的一些配置,实现了`Default`这个`Trait`,简单理解的话就是说这个`default()`是Rust世界中的无参构造函数,new一个对象时给字段赋值. 

还可以看到这个示例只有一个字符串类型的param字段,这个参数是可以在envoy的配置文件中作为参数传进来的(默认是envoy.yaml).  

这个文件需要了解的内容就这么多:

- 有一个配置对象
- 可以添加字段并且实现`Default`这个`Trait`
- 可以从envoy配置文件配置参数到这个对象对应字段

## filter.rs

接下来了解下`filter.rs`这个文件时干嘛的,看名字可以猜到主要是过滤器需要过滤什么东西(过滤器的逻辑),

## 运行示例,看看效果  

# 开发我们的filter逻辑  

## 实现WWW-Authenticate认证逻辑

## 添加配置参数

## 实现域名白名单

## 实现URL白名单

# 总结

目前 https://github.com/tetratelabs/envoy-wasm-rust-sdk 不再维护,将尝试从 https://github.com/proxy-wasm/proxy-wasm-rust-sdk 开始示例。

到目前为止,我们使用Rust开发了一个支持参数配置的envoy wasm filter.

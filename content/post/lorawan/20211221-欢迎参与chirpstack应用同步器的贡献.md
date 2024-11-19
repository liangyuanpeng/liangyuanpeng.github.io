---
layout:     post 
slug:   "welcome-contribute-chirpstack-application-syncer"
title:      "欢迎参与chirpstack应用同步器的贡献"
subtitle:   ""
description: ""  
date:       2021-12-21
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1543506262/hugo/blog.github.io/apache-rocketMQ-introduction/7046d2bf0d97278682129887309cc1a6.jpg"
published: true
tags: 
    - ChirpStack
    - IOT
    - LoraWan
    - golang
categories: 
    - TECH
---  

# chirpstack-application-syncer  

在两个 chirpstack 服务器之间同步你的 chirpstack application 数据,目前还处于初步实现阶段,预期效果会是下面这样:  

1. 定时请求 chirpostack 服务器A的应用A1的数据和服务器B的应用 B1 的数据  
2. 对比两者之间设备信息的差异  
3. 将服务器A的应用 A1 的设备数据同步到服务器B的应用B1.  

在第三步初步实现只做一个单向同步,即 A1 数据同步到 B1,同时支持两种同步策略:  

- 增量和差异同步(B1 存在 A1 中没有的数据则不处理B1中多出来的数据) 
- 覆盖性同步( B1 数据完全同步和A1一致)

# 使用场景  

有时 chirpstack 服务分为测试服务器和正式服务器,在没有 chripstack-application-sycner 的情况下我们总是需要在测试服务器对设备测试完成后又需要将设备添加到正式服务器,次数多了难免会有些繁琐,因此使用一个程序来自动化同步数据当然是一个好主意!  

# 目前阶段  

目前还在初步实现阶段,如果你对 golang 或 chirpstack application server 感兴趣,赶紧参与进来,不要犹豫了.  

欢迎任何形式的贡献,包括但不限于:  

- 帮忙完善代码测试
- 代码编写帮忙完成功能实现  
- 试用/使用完后编写博客并发布出去
- ...

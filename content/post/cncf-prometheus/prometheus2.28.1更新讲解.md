---
layout:     post 
slug:      "prometheus-v2.28.1-update"
title:      "Prometheus2.28.1更新讲解"
subtitle:   ""
description: "Prometheus作为第二个从CNCF毕业的顶级项目,其成熟程度是毋庸置疑的,甚至推出了另一个CNCF项目OpenMetrics,希望将Prometheus的指标格式演进成为一个行业规范"
date:       2021-07-27
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612744351/hugo/blog.github.io/pexels-bruno-cervera-6032877.jpg"
published: true
tags:
    - prometheus
    - cncf
    - monitor
    - ops
    - metrics
categories: 
    - cloudnative
---  

# 前言  

Prometheus作为第二个从CNCF毕业的顶级项目,其成熟程度是毋庸置疑的,甚至推出了另一个CNCF项目OpenMetrics,希望将Prometheus的指标格式演进成为一个行业规范。  

# 更新总览   

本次更新只修复了三个BUG,但更新内容的重要性不能以BUG修复个数为准,而应该以BUG影响的严重程度为准,一起来看看修复了什么BUG吧.


1. HTTP SD将Content-Type固定判断`application/json`修改为匹配正则,可以允许`application/json;charset=utf-8`这样的header.  [#8981](https://github.com/prometheus/prometheus/pull/8981)

2. 修复从HTTP SD删除抓取目标后没有更新目标组,依然可以看到被删除的目标.  [#9020](https://github.com/prometheus/prometheus/pull/9020)  

3. 完善了kit/log日志级别的处理,github.com/prometheus/exporter-toolkit `v0.5.1`升级为`v0.6.0`.  [#9021](https://github.com/prometheus/prometheus/pull/9021) 
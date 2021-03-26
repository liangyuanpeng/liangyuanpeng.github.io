---
layout:     post 
slug:      "prometheus-v2.26rc.0-feature"
title:      "Prometheus2.26rc.0新特性讲解"
subtitle:   ""
description: "Prometheus作为第二个从CNCF毕业的顶级项目,其成熟程度是毋庸置疑的,甚至推出了另一个CNCF项目OpenMetrics,希望将Prometheus的指标格式演进成为一个行业规范"
date:       2021-03-25
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
    - CloudNative
---  

# 前言  

Prometheus作为第二个从CNCF毕业的顶级项目,其成熟程度是毋庸置疑的,甚至推出了另一个CNCF项目OpenMetrics,希望将Prometheus的指标格式演进成为一个行业规范。  

# prometheus的迭代速度  

prometheus的迭代速度还是很快的,v2.25到v2.26的大版本只有一个多月,小版本的发布得也给力.可以看出社区活跃程度还是很好的.

![prometheus-update](https://res.cloudinary.com/lyp/image/upload/v1616686853/hugo/blog.github.io/prometheus/ea14e284fc63fc009d801274cad03d8.png)

# 注意 本文还处于创作阶段,将会尽快完善
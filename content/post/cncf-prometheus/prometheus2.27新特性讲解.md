---
layout:     post 
slug:      "prometheus-release-v2.27"
title:      "Prometheus2.27新特性讲解"
subtitle:   ""
description: "Prometheus作为第二个从CNCF毕业的顶级项目,其成熟程度是毋庸置疑的,甚至推出了另一个CNCF项目OpenMetrics,希望将Prometheus的指标格式演进成为一个行业规范"
date:       2021-07-28
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612744351/hugo/blog.github.io/pexels-bruno-cervera-6032877.jpg"
published: false
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

 https://hub.fastgit.org/prometheus/prometheus/releases/tag/v2.27.0
 
[FEATURE] Promtool: Retroactive rule evaluation functionality. #7675
[FEATURE] Configuration: Environment variable expansion for external labels. Behind --enable-feature=expand-external-labels flag. #8649
[FEATURE] TSDB: Add a flag(--storage.tsdb.max-block-chunk-segment-size) to control the max chunks file size of the blocks for small Prometheus instances. #8478
[FEATURE] UI: Add a dark theme. #8604
[FEATURE] AWS Lightsail Discovery: Add AWS Lightsail Discovery. #8693
[FEATURE] Docker Discovery: Add Docker Service Discovery. #8629
[FEATURE] OAuth: Allow OAuth 2.0 to be used anywhere an HTTP client is used. #8761
[FEATURE] Remote Write: Send exemplars via remote write. Experimental and disabled by default. #8296
[ENHANCEMENT] Digital Ocean Discovery: Add __meta_digitalocean_vpc label. #8642
[ENHANCEMENT] Scaleway Discovery: Read Scaleway secret from a file. #8643
[ENHANCEMENT] Scrape: Add configurable limits for label size and count. #8777
[ENHANCEMENT] UI: Add 16w and 26w time range steps. #8656
[ENHANCEMENT] Templating: Enable parsing strings in humanize functions. #8682
[BUGFIX] UI: Provide errors instead of blank page on TSDB Status Page. #8654 #8659
[BUGFIX] TSDB: Do not panic when writing very large records to the WAL. #8790
[BUGFIX] TSDB: Avoid panic when mmaped memory is referenced after the file is closed. #8723
[BUGFIX] Scaleway Discovery: Fix nil pointer dereference. #8737
[BUGFIX] Consul Discovery: Restart no longer required after config update with no targets. #8766
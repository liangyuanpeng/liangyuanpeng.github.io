---
layout:     post 
title:      "OpenKruise-clonseset!"
subtitle:   "OpenKruise-clonseset!"
description: " "
date:       2021-02-07
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: false
tags:
    - kubernetes
    - CloudNative
    - OpenKruise
    - cncf
categories: 
    - kubernetes
---  

# 特性  

1. 在缩容时可以指定 pod 进行缩容  
2. 可以添加生命周期钩子,删除 原地升级等操作时触发生命周期钩子,让用户可以做一些自定义操作（比如开关流量、告警等）。
3. 可以自定 pod 进行删除重建并且触发 preDelete hook  
4. 可以执行灰度发布 pod 数量以及灰度发布过程中最大不可用 Pod 数量,并且可以设置优雅等待时间 等待 service 将无用的 pod 从endpoint 删除后继续升级,防止升级太快了 endpoint 还没来得及将旧的 pod 从 endpoint 删除，导致有部分流量失效了(请求到了无效的 pod 上).  
5. 可以根据 pod 的特定标签进行升级打散  
6. 支持 PVC 模版，当 pod 重建升级时同时删除 pvc,如果是原地升级可以继续使用 PVC
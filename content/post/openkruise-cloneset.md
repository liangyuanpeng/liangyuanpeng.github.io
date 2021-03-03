---
layout:     post 
title:      "OpenKruise-clonseset!"
subtitle:   "OpenKruise-clonseset!"
description: " "
date:       2021-02-07
author:     "lyp"
image: "https://res.cloudinary.com/lyp/image/upload/v1612709829/hugo/blog.github.io/pexels-drew-williams-3483967.jpg"
published: false
tags:
    - kubernetes
    - 云原生
    - OpenKruise
categories: 
    - kubernetes
---  

# 特性  

1. 在缩容时可以指定pod进行缩容  
2. 可以添加生命周期钩子,删除 原地升级等操作时触发生命周期钩子,让用户可以做一些自定义操作（比如开关流量、告警等）。
3. 可以自定pod进行删除重建并且触发preDelete hook  
4. 可以执行灰度发布pod数量以及灰度发布过程中最大不可用pod数量,并且可以设置优雅等待时间 等待service将无用的pod从endpoint删除后继续升级,防止升级太快了endpoint还没来得及将旧的pod从endpoint删除，导致有部分流量失效了(请求到了无效的pod上).  
5. 可以根据pod的特定标签进行升级打散  
6. 支持PVC模版，当pod重建升级时同时删除pvc,如果是原地升级可以继续使用PVC
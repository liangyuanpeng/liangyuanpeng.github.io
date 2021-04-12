---
layout:     post 
slug:      "springboot-clear-unuse-metrics"
title:      "清理SpringBoot应用无用的metrics指标"
subtitle:   ""
description: ""
date:       2021-04-07
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612744351/hugo/blog.github.io/pexels-bruno-cervera-6032877.jpg"
published: true
tags:
    - prometheus
    - cncf
    - monitor
    - ops
    - metrics
    - springboot
categories: 
    - CloudNative
---    

# 前言  

上周有个网友问springboot程序的metrics越来越多了,有40W的指标,现在想清除一些没用的metrics,要怎样做呢?!  

当时我看到这个问题觉得挺有意思,因为我的线上程序也有动态metrics,只不过指标没有达到那么大的量,所以我研究了一下这个问题可以怎么样处理.  

# 用什么添加做的动态metrics就先看支不支持删除  

动态创建metrics是直接用的`io.micrometer.core.instrument.MeterRegistry`对象,例如:`registry.gauge(name,tags,valueObject)`.就可以将一个name的gauge类型的metrics添加到registry里面了,收集metrics时就可以看到这个新增的metrics了.  

于是看看这个对象还有什么删除相关的方法:  

首先尝试的时`delete`方法,发现没有类似的方法:  
![metrics-try-delete-method](https://res.cloudinary.com/lyp/image/upload/v1618206141/hugo/blog.github.io/prometheus/springboot/metrics-try-delete-method.png)
  
然后试试`remove`,可以发现有两个remove方法可以用,分别传入`ID对象`和`metrics对象`,但如果需要全部清理呢?有没有类似List的clear方法呢?  

再试试`clear`方法,发现是有这个方法的,并且我先测试了一遍,看看`clear`方法是否能够达到预期(清除metrics).  

# 实操测试

于是我一顿操作:  
1. 写一个API接口,接口内容是执行`meterRegistry.clear();`
2. 启动springboot程序  
3. 浏览器看看`/actuator/prometheus`接口返回的内容  
4. 调用清理metrics的接口,也就是第一步写的接口  
5. 再次浏览器看看`/actuator/prometheus`接口返回的内容    

清理metrics前的接口内容:  
![https://res.cloudinary.com/lyp/image/upload/v1618206795/hugo/blog.github.io/prometheus/springboot/clear-metrics-before.png](https://res.cloudinary.com/lyp/image/upload/v1618206795/hugo/blog.github.io/prometheus/springboot/clear-metrics-before.png)

清理了metrics后的接口内容:  

![https://res.cloudinary.com/lyp/image/upload/v1618206795/hugo/blog.github.io/prometheus/springboot/clear-metrics-after.png](https://res.cloudinary.com/lyp/image/upload/v1618206795/hugo/blog.github.io/prometheus/springboot/clear-metrics-after.png)  

可以看到调用接口后metrics清除了信息.  

方法有效✔, 可以给网友回复了.  

# 网友实操不行  

![clear-method-for-metrics](https://res.cloudinary.com/lyp/image/upload/v1618206456/hugo/blog.github.io/prometheus/springboot/clear-method-for-metrics.png)  

网友说没这个方法? 咋回事?!  


# 注意  
本文还在创作当中,将会尽快发布!


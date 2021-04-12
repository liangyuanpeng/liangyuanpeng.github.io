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

![metrics-try-remove-method](https://res.cloudinary.com/lyp/image/upload/v1618206239/hugo/blog.github.io/prometheus/springboot/metrics-try-remove-method.png)  


再试试`clear`方法,发现是有这个方法的,并且我先测试了一遍,看看`clear`方法是否能够达到预期(清除metrics).   

![metrics-try-clear-method](https://res.cloudinary.com/lyp/image/upload/v1618206238/hugo/blog.github.io/prometheus/springboot/metrics-try-clear-method.png)

# 实操测试

于是我一顿操作:  
1. 写一个API接口,接口内容是执行`meterRegistry.clear();`
2. 启动springboot程序  
3. 浏览器看看`/actuator/prometheus`接口返回的内容  
4. 调用清理metrics的接口,也就是第一步写的接口  
5. 再次浏览器看看`/actuator/prometheus`接口返回的内容    

清理metrics前的接口内容:  
![clear-metrics-before](https://res.cloudinary.com/lyp/image/upload/v1618206795/hugo/blog.github.io/prometheus/springboot/clear-metrics-before.png)

清理了metrics后的接口内容:  

![clear-metrics-after](https://res.cloudinary.com/lyp/image/upload/v1618206795/hugo/blog.github.io/prometheus/springboot/clear-metrics-after.png)  

可以看到调用接口后metrics清除了信息.  

方法有效✔, 可以给网友回复了.  

# 网友实操不行  

![clear-method-for-metrics](https://res.cloudinary.com/lyp/image/upload/v1618206456/hugo/blog.github.io/prometheus/springboot/clear-method-for-metrics.png)  

网友说没这个方法? 咋回事?!  

点进clear源码看了一下,方法说明描述得很清楚,1.2.0版本发布的方法,而网友用的版本低于1.2.0,因此没有这个方法.  
```java
/**
     * Clear all meters.
     * @since 1.2.0
     */
    @Incubating(since = "1.2.0")
    public void clear() {
        meterMap.keySet().forEach(this::remove);
    }
```

# 能不能根据根据某些标签来删除特定的metrics  

![clear-metrics-from-tags](https://res.cloudinary.com/lyp/image/upload/v1618212053/hugo/blog.github.io/prometheus/springboot/clear-metrics-from-tags.png)

当然可以!  

![metrics-registry-find-tags.png](https://res.cloudinary.com/lyp/image/upload/v1618212255/hugo/blog.github.io/prometheus/springboot/metrics-registry-find-tags.png)  

可以看到每一个metrics的tag列表都可以拿得到,那就好办了,通过标签对比筛选出自己想要删除的metrics,然后用`remove`方法删除就可以了.

# 总结  

当程序有动态新增metrics时就要考虑无用metrics清除的机制,如果metrics数量太多的话就会影响到业务应用.


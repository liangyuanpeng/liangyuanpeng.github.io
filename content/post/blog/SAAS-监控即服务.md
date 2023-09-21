---
layout:     post 
slug:      "metrics-as-a-service"
title:      "metrics托管服务即将发布"
subtitle:   ""
description: "在云原生时代,每时每刻都有metrics被prometheus定时抓取.."
date:       2021-03-11
# date: {{ dateFormat "2006-01-02" .Date }}
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: false
tags:
    - metrics
    - prometheus
    - SAAS
categories: 
    - CloudNative
---  

# 前言  

现在很多人都在使用静态博客来记录自己的内容，但动态博客依然还有很多存在，也许永远也不会消失。最近几年一个基于SpringBoot编写的Blog正在慢慢变得火热起来，那就是Halo，而Java编写的其他博客或其他系统也不少,这些系统都像烟囱一样部署在各自的服务器上。  

一般人们不会专门为了自己的一个小网站专门去部署监控的内容，毕竟在大流量来临之前没必要去花这些功夫，但是了解自己线上系统运行情况还是非常需要有一个监控存在的。  

#  产品介绍  

用户只需要暴露标准的prometheus exporter给平台抓取metrics即可，然后可以在专属的Grafana页面看到自己的程序运行时情况，下面以JVM程序为例给个图：   

![metrics-jvm](https://res.cloudinary.com/lyp/image/upload/v1615419259/hugo/blog.github.io/saas/prometheus/metrics-jvm.png)  

如果没有明白这有什么用那么举一个例子来说明一下,比如你有一个博客,而这个博客是通过Nginx(或其他web服务器)对外公布的,当nginx出了问题导致网站不可访问时你只有打开页面后才能知道是否能够访问,而对接了我们这个平台后平台会定时拉取Nginx的metrics信息,当Nginx metrics信息抓取不到时就会发`邮件/钉钉通知/飞书通知等`来告诉你网站出故障了.  

JVM或者Redis都是相同的道理,可以指定某个指标超过阀值就触发告警,比如Reids key突然暴增(网站被攻击了),平台立即发出通知,不需要你再手动确认当前运行情况.

## 支持的exporter类型  

1. JVM Micrometer exporter
2. Node exporter  
3. Redis exporter  
4. Nginx exporter  

#  产品定价   


|  |  天使用户|  基础版   | 高级版  |
|  ----|  ----|  ----  | ----  |
| 价格 | 50/年| 69/年  | 待定/年 |
| metrics应用数 | 3| 3  | 待定 |
| 数据保存 | 两个月| 两个月  | 一年 |
| Node Exporter | 将会支持| 将会支持  | 将会支持 |
| Redis Exporter | 将会支持| 将会支持  | 将会支持 |
| Nginx Exporter | √| √  | √ |
| Apache Exporter | 将会支持| 将会支持  | 将会支持 |
| Tomcat Exporter | 将会支持| 将会支持  | 将会支持 |
| 邮件告警 | √| √ | √ |
| 钉钉告警 | ×| ×  | √ |
|独立Prometheus实例 | ×| × | √ |
|独立Grafana实例 | ×| × | √ |
|存储空间 | 待定| 待定 | 待定 |
|自定义Grafana DashBoard id | 待定| 待定 | 待定 |
|自定义Metrics抓取间隔 | ×| × | √ |
|Prometheus自定义远程数据存储 | ×| × | √ |
|部署节点 | 香港| 香港 | 香港 |    


现在我们正在寻找天使用户`50名`,可拥有以`50元`(!平均一个月4快1毛!)购买基础版的永久账号,如果你有想法请联系我们!可以直接在下面评论也可以发邮件给我,甚至是加我的微信联系我(请备注Metrics托管服务天使用户).  

除了基础版和高级版还计划会推出一个尊享版,可完全掌控的Prometheus实例、Grafana实例和AlertManager实例,当然数据存储依然是另算了.  

我们还将计划支持Apache、tomcat等exporter,由于基础版只支持3个exporter数,如果您希望在基础版使用更多exporter可付费支持,每增加一个exporter将需要付费12元/年,平均一个月只需1块钱.

如果使用了[Halo即服务](https://liangyuanpeng.com/post/halo-as-a-service/)，则可免费享用基础版.


# 小提示  
基础版支持`3个`Metrics应用,因此可以和自己的小伙伴一起购买一个服务,平摊下来一个月一块多…白嫖✔

# 特别说明  

随着产品的完善,基础版价格可能会在`69~109`波动,如果你有需求但产品还没提供能力,可以联系我们咨询进度.毫无疑问的一点是提前付费将会加速我们的开发进度.  


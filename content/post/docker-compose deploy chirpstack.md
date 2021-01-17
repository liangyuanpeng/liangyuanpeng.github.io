---
layout:     post 
title:      "deploy ChirpStack from docker-compose"
subtitle:   ""
description: "docker-compose部署chirpstack"
date:       2021-01-17
author:     "LanLiang"
image: "https://res.cloudinary.com/lyp/image/upload/v1544363191/hugo/blog.github.io/743a4e9227e1f14cb24a1eb6db29e183.jpg"
published: true
tags:
    - ChirpStack
    - Docker-compose 
    - IOT
    - Docker
categories: 
    - CloudNative
---

## 前言

## FAQ


# 前提

本文使用`docker-compose`来部署`ChirpStack`，请确保已经含有以下环境：  

1. Git(非必须，可以先下载源码)  
2. Docker  
3. Docker-compose

# 关于LoraWan Server  

在讲LoraWan Server之前需要先了解一下LoraWan协议，LoraWan是一种物联网远距离传输协议。引用一句官方的介绍是这样的：LoRaWAN开放规范是基于LoRa技术的低功耗广域网（LPWAN）协议。   

协议栈也引用官方的图：
![https://www.semtech.com/uploads/images/what-LoRa-table-illustration-web.gif](https://www.semtech.com/uploads/images/what-LoRa-table-illustration-web.gif)  


数据是如何从传感器发送到服务器并且被相应的应用处理的呢？可以看下下面的图，依然是来自官方：

![https://www.semtech.com/uploads/images/Semtech-LoRaWAN-Diagram-NetworkArchitecture-Vert.png](https://www.semtech.com/uploads/images/Semtech-LoRaWAN-Diagram-NetworkArchitecture-Vert.png)

 最上面的是传感器，然后通过LoraWan协议将数据传输给了网关，网关通过网络传输到网络服务器(NS),NS将数据分发给对应的应用服务器(AS)。  
 
 举个栗子：一个智慧厕所当中的洗手液盒和纸巾盒里面都装有LoraWan的传感器，并且是由两个厂商分别提供设备。他们分别将余量数据(还剩下多少皂液/还剩下多少纸巾)上传到了(当然包含了网关传输的部分)网络服务器,网络服务器就将纸巾盒的数据分发给纸巾盒厂商的应用服务器，将皂液盒的数据分发给皂液盒厂商的应用服务器。  
 
 这样在大家都遵循LoraWan协议的前提下就达到了厂商中立的情况，哪一种设备不好我都可以找符合LoraWan规范的厂商进行替代，不需要担心厂商锁定的问题。  
 
在这个过程中，网络服务器就起着一个相当重要的作用了，下面来看看当前有哪一些开源的网络服务器。

# 开源的LoraWan Server
当前开源的LoraWan Server主要有三个：  
1. [chirpstack](https://www.chirpstack.io/)  
2. [lorawan-server](https://github.com/gotthardp/lorawan-server)  
3. [ttn](https://github.com/TheThingsNetwork/ttn)  

其中`chirpStack`和`ttn`是Golang实现,`lorawan-server`是Erlang实现.  

我只接触过前两者，本文只讲述chirpStack,也是我司正在使用的LoraWanServer技术栈，尝试过`ttn`的部署,上手简易度没有chirpStack好,所以没有再继续研究`ttn`.  

# 部署ChirpStack  

ChirpStack的部署相当简单，这里使用`docker-compose`部署作为例子。  


1. 下载源码 
```
> git clone https://github.com/brocaar/chirpstack-docker.git
```  

2. 用`docker-compose`部署  
```
> cd chirpstack-docker  
> docker-compose up -d
```  

下面是我执行部署命令后的一个输出:  
```
[root@node123 chirpstack-docker]# docker-compose up -d
WARNING: The Docker Engine you're using is running in swarm mode.

Compose does not use swarm mode to deploy services to multiple nodes in a swarm. All containers will be scheduled on the current node.

To deploy your application across the swarm, use `docker stack deploy`.

Creating network "chirpstack-docker_default" with the default driver
Creating chirpstack-docker_chirpstack-gateway-bridge_1     ... done
Creating chirpstack-docker_chirpstack-geolocation-server_1 ... done
Creating chirpstack-docker_chirpstack-network-server_1     ... done
Creating chirpstack-docker_mosquitto_1                     ... done
Creating chirpstack-docker_redis_1                         ... done
Creating chirpstack-docker_chirpstack-application-server_1 ... done
Creating chirpstack-docker_postgresql_1                    ... done
```  

现在打开`IP:8080`应该就可以看到ChirpStack自带的Application Server的页面了，我这里的IP是`192.168.3.123`, 打开后可以看到登陆页面：   

![](http://www.yunhorn.com:30000/server/index.php?s=/api/attachment/visitFile/sign/86f7fdcb423d070de13a9a1fdbc03e58&showdoc=.jpg)  

默认的帐号密码是`admin/admin`,能够登陆就已经说明部署成功了。  

![](http://www.yunhorn.com:30000/server/index.php?s=/api/attachment/visitFile/sign/306de6398a40e8db5f71acf3a81fad86&showdoc=.jpg)  

当然这个时候还不能接收传感器数据的(指的是网络服务器的配置问题),默认的用的频段是`EU868`,我们在国内需要使用`CN_470_510`,修改`configuration/chirpstack-network-server/chirpstack-network-server.toml`文件中的`network_server.band`为`CN_470_510`   
```
[network_server.band]
name="CN_470_510"
```  

将下面的`network_server.network_settings`配置注释掉:  
```
[network_server.network_settings]

#  [[network_server.network_settings.extra_channels]]
#  frequency=867100000
#  min_dr=0
#  max_dr=5

#  [[network_server.network_settings.extra_channels]]
#  frequency=867300000
#  min_dr=0
#  max_dr=5

#  [[network_server.network_settings.extra_channels]]
#  frequency=867500000
#  min_dr=0
#  max_dr=5

#  [[network_server.network_settings.extra_channels]]
#  frequency=867700000
#  min_dr=0
#  max_dr=5

#  [[network_server.network_settings.extra_channels]]
#  frequency=867900000
#  min_dr=0
#  max_dr=5`
```

再重启一下服务器就可以了，网络服务器的配置工作就做完了。当然一个完整的数据走向还需要在服务器上创建应用、创建设备、创建网关、在网关配置网络服务器相关的内容、传感器发起数据。  

本文仅讲述网络服务器ChirpStack的配置。
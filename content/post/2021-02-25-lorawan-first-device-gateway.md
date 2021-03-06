---
layout:     post 
title:      "LoraWan的第一个网关与设备"
subtitle:   ""
description: "LoRa联盟规定了MAC层的通讯协议，只有在设备（GW、MOTE）共同遵守的MAC层协议的前提下，不同硬件厂商的设备才能互相接入。"  
date:       2021-02-05
author:     "lyp"
image: "https://res.cloudinary.com/lyp/image/upload/v1543506262/hugo/blog.github.io/apache-rocketMQ-introduction/7046d2bf0d97278682129887309cc1a6.jpg"
published: true
tags: 
    - ChirpStack
    - IOT
    - LoraWan
categories: 
    - IOT
---

# LoraWan数据走向    

可以先看一下下面的数据图

![](https://res.cloudinary.com/lyp/image/upload/v1612512099/hugo/blog.github.io/lorawan/first-device-gateway/123.png)  

从节点到网关是通过无线传输，也就是lora协议。LoraWan网关接收到数据后将其转化为网络数据通过MQTT/UDP发送给服务器。


# 开始配置 

## 创建NS
登陆到dashboard后首先创建一个network-server,由于我已经创建过，因此显示了已经存在的数据。

![](https://res.cloudinary.com/lyp/image/upload/v1612512151/hugo/blog.github.io/lorawan/first-device-gateway/2.png)  

会切换到新增ns的页面  

![](https://res.cloudinary.com/lyp/image/upload/v1612512429/hugo/blog.github.io/lorawan/first-device-gateway/3.png)

如果是docker-compose部署的则填写`chirpstack-network-server:8000`,如果修改了NS的端口，这里的8000端口也需要修改。  

## 创建service-profile

![](https://res.cloudinary.com/lyp/image/upload/v1612512435/hugo/blog.github.io/lorawan/first-device-gateway/4.png)

名称可随意填写，network-server的填写是一个下拉列表，会显示刚才创建的NS,只填写两个带`*`的必填项就可以了，填写完后点击右下角按钮提交。 

## 创建device-profile  

![](https://res.cloudinary.com/lyp/image/upload/v1612512444/hugo/blog.github.io/lorawan/first-device-gateway/5.png)  

![](https://res.cloudinary.com/lyp/image/upload/v1612512612/hugo/blog.github.io/lorawan/first-device-gateway/6.1.png)

这个页面主要的信息是`LoRaWAN MAC version`这个字段  

创建完后在device-profile的列表点击进入刚才创建的device-profile，需要更新一下内容，允许OTAA功能。  

![](https://res.cloudinary.com/lyp/image/upload/v1612512446/hugo/blog.github.io/lorawan/first-device-gateway/6.png)
 
![](https://res.cloudinary.com/lyp/image/upload/v1612512447/hugo/blog.github.io/lorawan/first-device-gateway/7.png)

如果你需要classB则可以点击右边classB的选项，勾上即可，classC同理。  

到目前为止配置的内容基本上已经完成了，接下来就是添加网关和设备了。
 
## 添加网关信息  

![](https://res.cloudinary.com/lyp/image/upload/v1612512450/hugo/blog.github.io/lorawan/first-device-gateway/8.png)  

主要的信息就是网关ID以及network-server profile  

![](https://res.cloudinary.com/lyp/image/upload/v1612512447/hugo/blog.github.io/lorawan/first-device-gateway/9.png)  

网关的ID以瑞科的网关为例  

![](https://res.cloudinary.com/lyp/image/upload/v1612512463/hugo/blog.github.io/lorawan/first-device-gateway/10.png)  

如果没有找到网关ID找相关的`网关产品的技术支持`帮忙即可。 接下来开始添加设备。  

## 创建应用 

在添加设备之前需要创建应用，而设备是放在应用之下的，这样做的原因主要是用来对设备进行分类。比如A类型的传感器放在一个应用下，B类型的传感器放在另一个应用下。亦或者是根据场地进行分类，总而言之，应用是`ChirpStack`设计用来对数据的隔离的，这是`ChirpStack`的概念，不属于`LoraWan`的范畴。  

![](https://res.cloudinary.com/lyp/image/upload/v1612512479/hugo/blog.github.io/lorawan/first-device-gateway/11.png) 

![](https://res.cloudinary.com/lyp/image/upload/v1612512479/hugo/blog.github.io/lorawan/first-device-gateway/12.png)

创建完必填的内容后点击右下角按钮确认创建。  

然后在应用列表就可以看到刚才创建的应用了，点击`应用名称`进去，开始创建设备。

![](https://res.cloudinary.com/lyp/image/upload/v1612512479/hugo/blog.github.io/lorawan/first-device-gateway/13.png) 

## 添加设备  

![](https://res.cloudinary.com/lyp/image/upload/v1612512479/hugo/blog.github.io/lorawan/first-device-gateway/14.png)

依然是填写完必填项后点击右下角按钮确认添加。  

![](https://res.cloudinary.com/lyp/image/upload/v1612512478/hugo/blog.github.io/lorawan/first-device-gateway/15.png)

重要的是`devEUI`,这是`lora模块`上的ID,务必填写正确。  

填写完后会跳转到设备信息页面，继续填写`APPKEY`  

![](https://res.cloudinary.com/lyp/image/upload/v1612512478/hugo/blog.github.io/lorawan/first-device-gateway/16.png) 

填写完成后点击右下角按钮确认。  

到目前为止网关和设备都添加完了，只需要在网关配置一下数据上传的内容，将网关接收到的数据上传到`LoraWan Server`就可以了。(`网关配置内容具体情况找网关产品技术支持帮忙`)  

设备的信息中有一个`DEVICE DATA`,可以在`LoraWan Server`上查看设备上传到服务器的数据。  

`注意：设备没有数据时不会显示内容.`  

![](https://res.cloudinary.com/lyp/image/upload/v1612512478/hugo/blog.github.io/lorawan/first-device-gateway/17.png)

![](https://res.cloudinary.com/lyp/image/upload/v1612512479/hugo/blog.github.io/lorawan/first-device-gateway/18.png)  

到目前为止数据都走通了，从设备发送数据到网关，网关将数据上传到服务器，服务器查看到数据。


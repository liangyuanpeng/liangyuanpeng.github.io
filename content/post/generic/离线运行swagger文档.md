---
layout:     post 
slug:      "swagger-api-offline"
title:      "离线运行swagger文档"
subtitle:   ""
description: ""  
date:       2021-04-13
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612746030/hugo/blog.github.io/pexels-eva-elijas-5949232.jpg"
published: true
tags: 
    - kubesphere
    - swagger
    - docker
categories: 
    - TECH
---

# 前言

在社区群看到有人希望能够将 kubesphere 的文档自己搭一个环境跑起来使用,我想了下这个需求应该是实际使用确实会碰到的,比如某些公司内部网络规则禁止了一些网站或者只允许某些网站.  

在这样的情况下自己搭建一个 API 文档网站还是很有必要的.  

# 动起来

我首先去 kubesphere 的 API 网址看了下有没有提供下载文档 json 文件.  

提醒: kubesphere API 文档地址是[https://kubesphere.io/api/kubesphere/](https://kubesphere.io/api/kubesphere/)

[upl-image-preview url=https://kubesphere.com.cn/forum/assets/files/2021-04-13/1618290575-306140-image.png]

按钮还是很明显的,将文件下载下来.  

API 文档既然可以以文件的方式下载下来,那肯定可以再以某种方式加载,然后提供访问.  

去 swagger-ui 的官方库看了看文档,找到了加载自定义 json 的方式,  

地址是: [https://github.com/swagger-api/swagger-ui/blob/master/docs/usage/installation.md](https://github.com/swagger-api/swagger-ui/blob/master/docs/usage/installation.md)  

执行的 docker 命令如下:  

```shell
docker run -it -d --name swagger -p 80:8080 -e SWAGGER_JSON=/doc/kubesphere.json -v {文档文件目录}:/doc swaggerapi/swagger-ui
```  

上述命令中假定 swagger 文件名为`kubesphere.json`,如果你的文件叫其他名字,记得修改成真实文件名.


接着就可以通过访问本机本机 IP 来看 kubesphere 的 API 文档了.  

# 总结

总的来说就两步:  

1. 下载 swagger API 文档  
2. 用`swaggerapi/swagger-ui`容器把文档跑起来.

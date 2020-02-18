---
layout:     post 
title:      "不用安装docker也能构建docker镜像"
subtitle:   ""
description: "构建java的docker镜像,用jib,简单粗暴.."  
date:       2020-02-18
author:     "lan"
image: "https://res.cloudinary.com/lyp/image/upload/v1582044225/hugo/blog.github.io/devops/jib/apple-code-coding-computer-574069.jpg"
published: true
tags: 
    - docker
    - jib
    - java
    - maven
categories: 
    - 容器
---


# 前提

1. [docker](https://www.docker.com/get-started)  
2. 容器镜像仓库  

 这里举例可以公用的两个  
 [dockerhub](https://hub.docker.com/)  
 [阿里云容器镜像服务](https://cr.console.aliyun.com/cn-beijing/instances/repositories)  

## 前言  

本文主要介绍的是google开源的一个java领域的docker构建工具jib.  

目前在[github](https://github.com/GoogleContainerTools/jib)上的start有8.5k,fork有784,是一款非常方便的java领域docker构建工具.  

亮点是不需要Docker daemon,意味着即使本地没有安装docker也能通过jib构建docker镜像,并且可以构建符合[OCI](https://github.com/opencontainers/image-spec)规范的镜像.  

官方支持三种方式:  
1. [maven插件](https://github.com/GoogleContainerTools/jib/blob/master/jib-maven-plugin)  
2. [grade插件](https://github.com/GoogleContainerTools/jib/blob/master/jib-gradle-plugin)  
3. [jib代码库](https://github.com/GoogleContainerTools/jib/tree/master/jib-core)  

本文使用的是springboot项目通过maven插件的方式进行讲述.  

讲一下第三种,jib代码库,这种方式可以用于自研平台构建java的docker服务.

## 配置pom.xml  

添加下面这段标准标签到文件中  
```
<build>
    <plugins>
      ...
      <plugin>
        <groupId>com.google.cloud.tools</groupId>
        <artifactId>jib-maven-plugin</artifactId>
        <version>2.0.0</version>
        <configuration>
          <from>
					  <image>registry.cn-hangzhou.aliyuncs.com/dragonwell/dragonwell8:8.1.1-GA_alpine_x86_64_8u222-b67</image>
					</from>
          <to>
            <image>imageName</image>
          </to>
        </configuration>
      </plugin>
      ...
    </plugins>
  </build>
```  

上述内容配置了一个结果镜像名称``imageName``,也就是最终构建成的docker镜像地址,包含``容器仓库地址/镜像名称:版本号``例如``registry.cn-beijing.aliyuncs.com/lyp/lanbox:v1.0``,如果仓库地址不填则默认为[dockerhub](https://hub.docker.com/).  

另外还配置了一个基础镜像``registry.cn-hangzhou.aliyuncs.com/dragonwell/dragonwell8:8.1.1-GA_alpine_x86_64_8u222-b67``,可以认为等同于Dockerfile中的From语句.  

如果基础镜像或目标镜像需要账号密码的话,在from标签或to标签添加一个认证信息即可,有三种方式:  
1. 配置在docker的配置文件中  
2. 配置在maven的setting.xml中
3. 直接在pom.xml文件配置  

本文使用第三种,即在from标签或to标签下添加一个用于认证信息的auth标签,例如:   
``` 
<from>
  ...
  <auth>
    <username>kafeidou</username>
    <password>kafeidou</password>
  <auth>
  ...
</from>  
```  

也可以方便的通过环境变量的方式进行配置:  
```
<from>
  ...
  <auth>
    <username>${env.REGISTRY_FROM_USERNAME}</username>
    <password>${env.REGISTRY_FROM_PASSWORD}</password>
  <auth>
  ...
</from> 
```  

其中``${env.}``这一部分是固定的,后面跟着实际环境变量.  

还可以通过系统属性的方式:  
```
mvn compile jib:build \
    -Djib.to.image=myregistry/myimage:latest \
    -Djib.to.auth.username=kafeidou \
    -Djib.to.auth.password=kafeidou
```  

在进行构建时通过参数方式传递认证信息,是不是很方便呢?  

继续看``configuration``下的标签有``container``配置:  
这个标签主要配置目标容器相关的内容,比如:  
1. appRoot -> 放置应用程序的根目录,用于war包项目  
2. args -> 程序额外的启动参数.  
3. environment -> 用于容器的环境变量  
4. format -> 构建OCI规范的镜像  
5. jvmFlags -> JVM参数  
6. mainClass -> 程序启动类  
7. ports -> 容器开放端口  
...  
还有其他内容具体可以参考[container](https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin#container-object).  

有一个注意点是阿里的容器镜像服务不支持OCI镜像,所以如果选择使用阿里的容器镜像服务记得将OCI格式取消,默认是取消的.  

另外,JVM参数可以通过环境变量配置动态内容,所以不需要计划将所有启动参数写死在``jvmFlags``标签里面.  

例如启动容器时指定使用G1回收器,``docker run -it -e JAVA_TOOL_OPTIONS="-XX:+UseG1GC" -d  registry.cn-beijing.aliyuncs.com/lyp/lanbox:v1.0``.

完整的一个例子可以在github上查看并下载[https://github.com/FISHStack/hello-spring-cloud](https://github.com/FISHStack/hello-spring-cloud),欢迎多多交流.
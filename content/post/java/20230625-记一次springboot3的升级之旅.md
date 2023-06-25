---
layout:     post 
slug:      "write-note-for-upgrade-to-springboot3"
title:      "记一次springboot3的升级之旅"
subtitle:   ""
description: "记一次springboot3的升级之旅"
date:       2023-06-25
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
wip: true
tags:
    - java
    - springboot3
categories: 
    - cloudnative
---


# 说明

springboot3 宣布将最低支持 jdk17,从框架上推动 java 用户来升级 jdk,太酷啦!! 虽然这种操作很有可能引来群怒,但对于springboot3的这波操作来说,我很认同,如果你的项目依然使用 jdk8 而不使用 jdk17,那么你继续使用 springboot2.x 就可以了,和最新技术说拜拜.而对于想要体验新技术的人则建议使用 springboot3,框架语法也会使用新版本语法,而不是被 jdk8 所限制.

在你的项目中升级 springboot3 总得有一个值得升级的动力,对于我们项目来说,最值得期待的是 springboot3 支持 graalvm,同时 graalvm 也是 springboot3 的一个重大特性,非常值得一试.升级的目的主要是希望能够节省内存开销,虽然可以将多个项目丢到 Tomcat 中运行, Tomcat 也支持热更新,因此可以独立部署对应的微小服务,但我更推崇云原生不可变设施的理念,将每个服务打包成独立的容器镜像显然是更好的.

本文记录从 springboot2.4x.x 升级到 springboot3.1.0 过程中遇到的问题.

大部分都是一些 javax.servlet 到 jakarta.servlet 的变更导致的.

另一些则是 spring6 弃用了一些内容导致了变更.

还在持续解决问题当中,先抛出一些问题和解决方案尝鲜 :)


# 遇到的问题

## 找不到 javax.servlet 

这是因为 javax 已经捐赠给了 eclipse 基金会,已经更名为 jakarta,而 springboot3 使用到了而已。虽然说在升级过程中会遇到这个问题，但其实这个变更与springboot3 关联性不大,即使你不使用 springboot3,也可能会遇到这个问题.

## 初始化 ServletRegistrationBean 失败

这里会有两个可能出现的问题:

由于项目中使用到了 Druid 连接池,因此这里使用到的对象是 StatViewServlet.

第一个问题是实例化ServletRegistrationBean时传参失败,需要将 StatViewServlet 强转为 jakarta.servlet .

```shell
ServletRegistrationBean servletRegistrationBean = new ServletRegistrationBean(new StatViewServlet(),"/druid/*");
```

第二个问题是 StatViewServlet 这个对象内部还是使用 javax.servlet,导致失败,这种情况需要等对应的依赖包升级到使用 jakarta.servlet 的版本才行.

目前将 druid 包从 druid-spring-boot-starter 更新为 druid-spring-boot-3-starter, 是否解决还有待确认.


## class file for org.apache.hc.client5.http.classic.HttpClient not found

为 RestTemplate 对象设置 RequestFactory 时使用到了 HttpComponentsClientHttpRequestFactory 对象,为其设置 httpClient 时报错了,提示需要HttpClient 类型而我传参提供的是  CloseableHttpClient 类型的,这里简单起见我是直接不设置这个 httpClient 了,因为我使用的也是默认值,没有特别的参数设置. 如果你想要传递准确的类型的话点进去 spring 框架里面看看这个接口都有哪些内部的实现就好了,没有的话再查下资料看看哪些对象实现了这个接口.

```java
CloseableHttpClient httpClient = httpClientBuilder.build();
HttpComponentsClientHttpRequestFactory factory = new HttpComponentsClientHttpRequestFactory();
factory.setHttpClient(httpClient);
```

## cannot access javax.servlet.http.HttpServletRequest

这种错误就是升级 javax.servlet 后带来的,依赖包依然在使用 javax.servlet,而传参却是 jakarta.servlet, 这种情况就需要等待依赖包支持 jakarta.servlet.


```java
public static final boolean isMultipartContent(javax.servlet.http.HttpServletRequest request) {
    return !"POST".equalsIgnoreCase(request.getMethod()) ? false : FileUploadBase.isMultipartContent(new ServletRequestContext(request));
}
```

我这里的错误是由 commons-fileupload 1.5 中的 ServletFileUpload 对象引起的.

解决方案: TDB 

1.5 是 2023 年最新版本了.

看了下项目源码似乎有 commons-fileupload2,但在中央仓库没有找到对应的包. TODO 去社区问问

## CommonsMultipartFile 对象没有了

spring6 删除了这个对象,需要使用另外的方法代替,spring6没有提供替换参考.

解决方案: TDB

## WebSecurityConfigurerAdapter 对象没有了

spring6 删除了这个对象.



解决方案: TDB

## javax.mail

解决方案: javax.mail 更新为 jakarta.mail


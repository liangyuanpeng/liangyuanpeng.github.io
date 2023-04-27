---
layout:     post 
slug:   "ballerina-hello-world"
title:      "云原生编程语言ballerina:hello-world"
subtitle:   ""
description: "随着云原生的发展,业务规模的壮大,yml的维护会越来越复杂,这时候提高效能的工具或语言就应运而生了,ballerina便是其一."
date:       2020-01-01
author:     "梁远鹏"
image: "img/banner-pexels.jpg"
published: true
tags:
    - CloudNative
    - 编程语言
    - ballerina
    - k8s
    - docker
categories: 
    - cloudnative
---

## 前言
Ballerina是一款完全开源的编译时强类型语言,愿景是让云原生时代的程序员轻松编写出想要的的软件.  
开源地址:[https://github.com/ballerina-platform/ballerina-lang](https://github.com/ballerina-platform/ballerina-lang)

## Example 
  
# 下载对应平台的包进行安装  
[https://ballerina.io/downloads/](https://ballerina.io/downloads/)  

这里使用的是在ubuntu环境下安装，下载好deb包后，进行安装  

```
lan@lan-machine:~$ sudo dpkg -i ballerina-linux-installer-x64-1.1.0.deb 
[sudo] password for lan: 
Selecting previously unselected package ballerina-1.1.0.
(Reading database ... 187196 files and directories currently installed.)
Preparing to unpack ballerina-linux-installer-x64-1.1.0.deb ...
Unpacking ballerina-1.1.0 (1.1.0) ...
Setting up ballerina-1.1.0 (1.1.0) ...
lan@lan-machine:~$ ballerina version
jBallerina 1.1.0
Language specification 2019R3
Ballerina tool 0.8.0
```
可以看到安装的ballerina的版本是1.1.0

### Hello World Main

1. 创建ballerina目录以及进入到ballerina目录下，这一步骤不是必须的，但为了文件整理，建议这样处理
```
lan@lan-machine:/disk/note$ mkdir ballerina && cd ballerina
lan@lan-machine:/disk/note/ballerina$
```
2. 创建hello-world.bal文件并写入hello-world print对应代码    
``
lan@lan-machine:/disk/note/ballerina$ touch hello-world.bal
``
```
import ballerina/io;
public function main() {
    io:println("Hello, World!");
}
``` 
3. 运行hello-world

```
lan@lan-machine:/disk/note/ballerina$ ballerina run hello-world.bal 
Compiling source
        hello-world.bal

Generating executables
Running executables

Hello, World!  
```
可以看到，已经成功输入 Hello World,最简单的一个例子完成了。

### Hello World Service

第二个hello-world的例子是启动一个监听9090端口的http服务器
1. 创建hello-world-service.bal文件并写入对应的代码

``
lan@lan-machine:/disk/note/ballerina$ touch hello-world-service.bal
``
```
import ballerina/http;
import ballerina/log;
service hello on new http:Listener(9090) {

    resource function sayHello(http:Caller caller, http:Request req) {

        var result = caller->respond("Hello, World!");

        if (result is error) {
            log:printError("Error sending response", result);
        }
    }
}
```
1. 运行hello-world-service.bal
```
lan@lan-machine:/disk/note/ballerina$ ballerina run hello-world-service.bal
Compiling source
        hello-world-service.bal

Generating executables
Running executables

[ballerina/http] started HTTP/WS listener 0.0.0.0:9090

lan@lan-machine:~$ curl http://localhost:9090/hello/sayHello
Hello, World!
```
其中路径的组成是这样的，
1. http:Listener(9090) 构成监听端口9090,也就是localhost:9090
2. service hello 构成第一个路径
3. resource function sayHello 构成第二个路径
   
完整的组成之后就是http://localhost:9090/hello/sayHello

### Hello World Paraller
第三个hello-world的例子是异步任务的执行

1. 创建hello-world-paraller.bal文件并写入对应代码  
``
lan@lan-machine:/disk/note/ballerina$ touch hello-world-paraller.bal
``
```
import ballerina/io;
public function main() {
    worker w1 {
        io:println("Hello, World! #m");
    }

    worker w2 {
        io:println("Hello, World! #n");
    }
    worker w3 {
        io:println("Hello, World! #k");
    }
}
```
1. 运行hello-world-paraller.bal 文件
```
lan@lan-machine:/disk/note/ballerina$ ballerina run hello-world-paraller.bal
Compiling source
        hello-world-paraller.bal

Generating executables
Running executables

Hello, World! #m
Hello, World! #n
Hello, World! #k
lan@lan-machine:/disk/note/ballerina$ 
lan@lan-machine:/disk/note/ballerina$ 
lan@lan-machine:/disk/note/ballerina$ ballerina run hello-world-paraller.bal
Compiling source
        hello-world-paraller.bal

Generating executables
Running executables

Hello, World! #n
Hello, World! #m
Hello, World! #k
```
可以看到每次打印的顺序并不是一样的

### Hello World Client
最后一个hello-world的例子是http客户端请求

1. 创建hello-world-client.bar文件并写入对应代码
``
lan@lan-machine:/disk/note/ballerina$ touch hello-world-client.bal
``
```
import ballerina/http;
import ballerina/io;
public function main() {
    http:Client clientEP = new ("http://www.mocky.io");

    var resp = clientEP->get("/v2/5ae082123200006b00510c3d/");

    if (resp is http:Response) {
        var payload = resp.getTextPayload();
        if (payload is string) {

            io:println(payload);
        } else {

            io:println(payload.detail());
        }
    } else {

        io:println(resp.detail());
    }
}
```
2. 运行hello-world-client.bal文件
```
lan@lan-machine:/disk/note/ballerina$ ballerina run hello-world-client.bal
Compiling source
        hello-world-client.bal

Generating executables
Running executables
```
Hello World

例子中是请求 ``http://www.mocky.io/v2/5ae082123200006b00510c3d/`` 并将结果打印出来  

更多的example可以在[官网](https://ballerina.io/v1-1/learn/by-example/)找到




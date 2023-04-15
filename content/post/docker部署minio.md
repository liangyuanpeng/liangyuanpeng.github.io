---
layout:     post 
slug:      "deploy-minio"
title:      "docker部署minio"
subtitle:   ""
description: "MinIO是Apache V2许可下的100％开源的对象存储服务器，兼容S3。具有高可用高性能且云原生"  
date:       2020-01-16
author:     "梁远鹏"
image: "img/banner-pexels.jpg"
published: true
tags: 
    - 存储
    - Middleware
    - CloudNative
    - minio
    - docker
categories: 
    - TECH
---


# 前提

1. [docker](https://www.docker.com/get-started)

## docker部署  

docker部署minio非常简单，只需要两条命令即可完成minio服务器的部署。

```
docker pull minio/minio
docker run -p 9000:9000 minio/minio server /data
```
下面是两条命令的执行结果

```
docker run -p 9000:9000 minio/minio server /data/minio

[root@localhost ~]# docker pull minio/minio
Using default tag: latest
latest: Pulling from minio/minio
89d9c30c1d48: Already exists 
1bc2fea8f5b3: Pull complete 
c3bfea9d8980: Pull complete 
Digest: sha256:10daad6aff2e8d5db5700eaa1ee148835aaed8c761c607fcbeb4a62caa1ac640
Status: Downloaded newer image for minio/minio:latest
docker.io/minio/minio:latest

[root@localhost minio]# docker run -p 9000:9000 minio/minio server /data/minio
Endpoint:  http://172.17.0.4:9000  http://127.0.0.1:9000

Browser Access:
   http://172.17.0.4:9000  http://127.0.0.1:9000

Object API (Amazon S3 compatible):
   Go:         https://docs.min.io/docs/golang-client-quickstart-guide
   Java:       https://docs.min.io/docs/java-client-quickstart-guide
   Python:     https://docs.min.io/docs/python-client-quickstart-guide
   JavaScript: https://docs.min.io/docs/javascript-client-quickstart-guide
   .NET:       https://docs.min.io/docs/dotnet-client-quickstart-guide
Detected default credentials 'minioadmin:minioadmin', please change the credentials immediately using 'MINIO_ACCESS_KEY' and 'MINIO_SECRET_KEY'

```

到这里为止minio服务器就已经部署完成了，打开对应IP:9000就可以看到minio的登陆页面。  
默认帐号:minioadmin  
默认密码:minioadmin  

![https://res.cloudinary.com/lyp/image/upload/v1579187421/hugo/blog.github.io/minio/login-web.png](https://res.cloudinary.com/lyp/image/upload/v1579187421/hugo/blog.github.io/minio/login-web.png)

这是最新版本的minio情况，旧一点版本的minio的默认帐号密码不是这个，不管怎样都会在启动minio server的时候在控制台显示出来，这个不是问题。



## minio web简单操作  

minio dashboard  
![https://res.cloudinary.com/lyp/image/upload/v1579187807/hugo/blog.github.io/minio/dashboard.png](https://res.cloudinary.com/lyp/image/upload/v1579187807/hugo/blog.github.io/minio/dashboard.png)  

minio 可操作的按钮  
![https://res.cloudinary.com/lyp/image/upload/v1579188074/hugo/blog.github.io/minio/button.png](https://res.cloudinary.com/lyp/image/upload/v1579188074/hugo/blog.github.io/minio/button.png)  

1. 第一个按钮是上传文件  
2. 第二个按钮是创建bucket,在服务器上的表现就是创建文件夹  

创建的第一个bucket  
![https://res.cloudinary.com/lyp/image/upload/v1579188657/hugo/blog.github.io/minio/firstBucket.png](https://res.cloudinary.com/lyp/image/upload/v1579188657/hugo/blog.github.io/minio/firstBucket.png)  

上传的第一个文件  
![https://res.cloudinary.com/lyp/image/upload/v1579188643/hugo/blog.github.io/minio/firstImg.png](https://res.cloudinary.com/lyp/image/upload/v1579188643/hugo/blog.github.io/minio/firstImg.png)  

分享文件按钮  
![https://res.cloudinary.com/lyp/image/upload/v1579189664/hugo/blog.github.io/minio/shareButton.png](https://res.cloudinary.com/lyp/image/upload/v1579189664/hugo/blog.github.io/minio/shareButton.png)  

分享文件,配置过期时间
![https://res.cloudinary.com/lyp/image/upload/v1579189665/hugo/blog.github.io/minio/shareObject.png](https://res.cloudinary.com/lyp/image/upload/v1579189665/hugo/blog.github.io/minio/shareObject.png)  

默认的过期时间是5天，时间到后，链接就失效了。  

## CLI mc
minio web的简单操作就这么多，还可以通过官方的CLI工具``mc``来操作  

### macOS  
#### Homebrew
Install mc packages using [Homebrew](https://brew.sh/)  
```
brew install minio/stable/mc
mc --help
```  

### GNU/Linux  
#### Binary Download  
Platform | Architecture |  URL  
-|-|-  
GNU/Linux | 64-bit Intel | https://dl.min.io/client/mc/release/linux-amd64/mc
&nbsp;  | 64-bit PPC | https://dl.min.io/client/mc/release/linux-ppc64le/mc  

```
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
./mc --help
```

### Microsoft Windows  
#### Binary Download  

Platform | Architecture | URL  
- | - | -  
Microsoft Windows | 64-bit Intel | https://dl.min.io/client/mc/release/windows-amd64/mc.exe  

```
mc.exe --help
```
还有更详情的可以到官网的[客户端指南](https://docs.min.io/docs/minio-client-quickstart-guide.html)查看,还包含其他客户端，包括javascript、java、python、golang、.net、Hashkell.

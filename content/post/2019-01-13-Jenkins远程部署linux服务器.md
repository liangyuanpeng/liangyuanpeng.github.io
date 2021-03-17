---
layout:     post 
slug:   "remote deploy of jenkins for linux application"
title:      "Jenkins远程部署Linux服务器"
subtitle:   ""
description: "发展到一定程度后自动化部署会成为必不可少的一部分，目前Jenkins是插件丰富且最流行的工具。"
date:       2019-01-13
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1544363191/hugo/blog.github.io/743a4e9227e1f14cb24a1eb6db29e183.jpg"
published: true
tags:
    - Jenkins
    - Ops
    - CI/CD
    - nginx
    - linux
categories: 
    - DevOps
---

## 前言
之前在Jenkins上也有一些使用经验了，但是都是使用团队配置好的Jenkins，自己只需要管自己的项目以及执行构建即可，这一次自己尝试了一下配置Jenkins的远程部署Linux服务器以及应用。  

> 执行过程如下：  
> 
> 1. Jenkins拉取代码  
> 2. 本地构建打包  
> 3. 连接远程服务器  
> 4. 上传打包应用  
> 5. 到相应目录解压应用内容以及重启正在运行的应用。

## 插件

远程部署过程中在本地操作远程服务器使用的插件是``publish over ssh``  
在``系统管理``中找到``插件管理``

点击``插件管理``  

![](https://res.cloudinary.com/lyp/image/upload/v1547996027/hugo/blog.github.io/devops/jenkins/Snipaste_2019-01-20_22-53-09.png)  

搜索``publish over ssh``


![](https://res.cloudinary.com/lyp/image/upload/v1547394382/hugo/blog.github.io/devops/jenkins/Snipaste_2019-01-13_23-46-13.png)  

笔者这里没有搜索出来是因为已经安装过了  

安装完成后回到刚才的``系统管理``的页面，往下拉会看到一个``系统设置``,点击进到``系统设置``页面。  
![](https://res.cloudinary.com/lyp/image/upload/v1547394524/hugo/blog.github.io/devops/jenkins/Snipaste_2019-01-13_23-48-08.png)  
  
往下拉，会看到``SSH Servers``相关的配置  

![](https://res.cloudinary.com/lyp/image/upload/v1547996667/hugo/blog.github.io/devops/jenkins/Snipaste_2019-01-20_23-04-16.png)    

笔者是使用密码的方式进行ssh服务器，在``Passphrase``填写对应的密码即可,还有其他四项内容如下：  


1. ``Name``是给sshserver自定义一个名称
2. ``Hostname``是ssh服务器的地址
3. ``Username``是ssh服务器的用户名
4. ``Remote Directory``是需要上传文件到服务器的远程目录  

填写基本信息完成后可以点击``Test Configuration``测试下是否连接正常,信息都正确后点击应用``Apply``，一个ssh服务器就配置好了，剩下的就是要在项目配置的时候使用已填的ssh服务器进行操作。


项目的代码拉取，命名，构建这里都略过，直接看项目远程部署部分的配置。   

首先，在构建完成后的行动中选择``Send build artifacts over SSH``

![](https://res.cloudinary.com/lyp/image/upload/v1547997179/hugo/blog.github.io/devops/jenkins/Snipaste_2019-01-20_23-12-48.png)

填写相对应的远程操作

![](https://res.cloudinary.com/lyp/image/upload/v1547997030/hugo/blog.github.io/devops/jenkins/Snipaste_2019-01-20_23-09-55.png)

上述图中展示的是笔者将``target``目录下的所有war包都打包到远程服务器``tomcat``下的``webapps/ROOT``目录下，然后``解压war包``，``睡10S``，``执行重启脚本``  

这里详细讲解下： 
 
- ``Source files`` 需要打包的文件  
- ``Remove prefix`` 需要去除的前缀路径
- ``Remote directory`` 文件上传的远程服务器目录，这里的目录是之前远程服务器设置的``Remote directory``目录的相对目录  

也就是说笔者这里设置的目录实际上等于之前服务器设置的目录``/usr/local/apache-tomcat-8.5.37``加上这里设置的目录``/webapps/ROOT``，连起来就是``/usr/local/apache-tomcat-8.5.37/webapps/ROOT``  

- ``Exec command``在远程服务器上执行的命令  

远程部署linux服务器的相关配置到这里就完成了，开始愉快的自动化远程部署之旅吧!




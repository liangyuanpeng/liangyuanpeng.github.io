---
layout:     post 
title:      "Jenkins远程部署Linux服务器"
subtitle:   ""
description: "发展到一定程度后自动化部署会成为必不可少的一部分，目前Jenkins是插件丰富且最流行的工具。"
date:       2019-01-13
author:     "lyp"
image: "https://res.cloudinary.com/lyp/image/upload/v1544363191/hugo/blog.github.io/743a4e9227e1f14cb24a1eb6db29e183.jpg"
published: false
tags:
    - Jenkins
    - 部署
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
在系统管理中找到插件管理
![](https://res.cloudinary.com/lyp/image/upload/v1547394171/hugo/blog.github.io/devops/jenkins/Snipaste_2019-01-13_23-41-59.png)

![](https://res.cloudinary.com/lyp/image/upload/v1547394317/hugo/blog.github.io/devops/jenkins/Snipaste_2019-01-13_23-45-03.png)  

搜索``publish over ssh``


![](https://res.cloudinary.com/lyp/image/upload/v1547394382/hugo/blog.github.io/devops/jenkins/Snipaste_2019-01-13_23-46-13.png)  

我这里没有搜索出来是因为已经安装过了  

安装完成后回到刚才的``系统管理``的页面，往下拉会看到一个``系统设置``,点击进到``系统设置``页面。  
![](https://res.cloudinary.com/lyp/image/upload/v1547394171/hugo/blog.github.io/devops/jenkins/Snipaste_2019-01-13_23-41-59.png)  
  
往下拉，会看到``SSH Servers``相关的配置  

![](https://res.cloudinary.com/lyp/image/upload/v1547394317/hugo/blog.github.io/devops/jenkins/Snipaste_2019-01-13_23-45-03.png)  






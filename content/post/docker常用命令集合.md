---
layout:     post 
slug:      "deploy-command"
title:      "docker常用命令集合"
subtitle:   ""
description: "记录docker常用命令"
date:       2020-02-09
author:     "lyp"
image: "https://res.cloudinary.com/lyp/image/upload/v1544363190/hugo/blog.github.io/19375a83fc004035fb1102a4551f2287.jpg"
published: true
tags:
    - Docker
    - Note
categories: 
    - CloudNative
---

## 停止一台机器上的所有容器

``
docker stop `docker ps -qa`
``

## 根据特定关键字删除镜像
``
docker rmi `docker images | grep NAME`
``


# 本文有新内容时将持续更新

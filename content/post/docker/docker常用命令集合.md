---
layout:     post 
slug:      "deploy-command"
title:      "docker常用命令集合"
subtitle:   ""
description: "记录docker常用命令"
date:       2020-02-09
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags:
    - docker
    - Note
categories: 
    - cloudnative
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

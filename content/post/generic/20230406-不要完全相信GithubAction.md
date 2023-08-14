---
layout:     post 
slug:      "do-not-totally-believe-github-action"
title:      "不要完全相信GithubAction"
subtitle:   ""
description: "不要完全相信GithubAction,当他失效时你需要有备用手段."  
date:       2023-04-06
author:     "梁远鹏"
image: "img/banner/tolgahang_The_sky_suddenly_darkened_and_lightning_struck_with_t_87bfe445-a272-486a-9961-5f424dcca429.png"
published: true
showtoc: false
tags: 
    - githubaction
categories: 
    - TECH
---

# 长话短说

![](/img/github/github-action-always-queue.png)

突然我的博客项目的 github action 一直处于一个排队的状态,以至于我无法更新博客的 algolia 索引,虽然对我的影响其实微乎其微,但我确实不太喜欢这种感觉,我的 github action 基本上几十秒就可以完成,甚至使用的频率也不是很高.

所做的事情也非常简单:

1. hugo build 检查是否博客能够正常build
2. 构建并更新 algolia 索引
3. 更新 github page


正因为做的事情很简单,所以我正计划添加 Azure Pipelines 作为博客项目的第二个 CI.
---
layout:     post 
slug:   "auto-build-algolia-index"
title:      "自动构建algolia索引"
subtitle:   ""
description: ""
date:       2021-03-12
author:     "梁远鹏"
image: "/img/banner/tolgahang_The_sky_suddenly_darkened_and_lightning_struck_with_t_87bfe445-a272-486a-9961-5f424dcca429.png"
published: true
tags:
    - Algolia
    - CI/CD
    - Blog
    - github
    - githubaction
categories: 
    - cloudnative
---

# 前言  

相信来到这里的朋友都已经知道 algolia 是什么了, algolia 在静态博客领域作为搜索解决方案已经非常主流了,而每次写完博客/文章后都需要自己手动生成索引并上传到 algolia 确实是很繁琐,本文将提供一个机遇Github Action 自动化构建 algolia 索引的解决方案.  

# 原理  

每次创建/更新完md文件后提交到仓库,仓库会触发 Github Action 的执行.  

Github Action 主要做两件事:  

1. 执行 hugo 命令生成静态文件以及 algolia 索引文件( hexo 等其他静态博客也类似),如果你使用的是 hexo 等其他静态博客,可能需要多一个操作来执行相关命令生成 algolia 索引文件.  
2. 通过安装了 `atomic-algolia` 命令的 docker 容器来将索引文件上传到algolia官网.  

# 配置  

配置的主要内容就是使用容器来将 algolia 索引文件上传,命令如下:  

```shell
docker run --rm -e ALGOLIA_ADMIN_KEY=${{ secrets.ALGOLIA_ADMIN_KEY }} -e ALGOLIA_INDEX_FILE=/public/algolia.json -e ALGOLIA_APP_ID=${{ secrets.ALGOLIA_APP_ID }} -e ALGOLIA_INDEX_NAME=${{ secrets.ALGOLIA_INDEX_NAME }} -v $PWD/public:/public registry.cn-shenzhen.aliyuncs.com/lan-k8s/ubuntu:algolia atomic-algolia
```  

其中相关的参数是放在了 Github Action 的 secrets 当中.  

完整的配置可以看看我是如何配置的[https://github.com/liangyuanpeng/liangyuanpeng.github.io/blob/source/.github/workflows/hugo.yml](https://github.com/liangyuanpeng/liangyuanpeng.github.io/blob/source/.github/workflows/hugo.yml).

有人问过我这个用于生成 algolia 索引的容器镜像 Dockerfile 在哪里,这个我后来找了一下,还真没找到,不过制作一下应该不会太难,找一个基础镜像然后把 atomic-algolia 命令打包进去就可以了.

如果有好心网友制作了并且能够达到这个效果的话欢迎留言投稿你的 Dockerfile.

亦或者是给出制作这个容器镜像的相关博客地址也是OK的.
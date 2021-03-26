---
layout:     post 
slug:   "auto-build-algolia-index"
title:      "自动构建algolia索引"
subtitle:   ""
description: ""
date:       2021-03-12
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1544363191/hugo/blog.github.io/743a4e9227e1f14cb24a1eb6db29e183.jpg"
published: true
tags:
    - Algolia
    - CI/CD
    - Blog
    - Github
    - GithubAction
categories: 
    - CloudNative
---

# 前言  

相信来到这里的朋友都已经知道algolia是什么了,algolia在静态博客领域作为搜索解决方案已经非常主流了,而每次写完博客/文章后都需要自己手动生成索引并上传到algolia确实是很繁琐,本文将提供一个机遇Github Action自动化构建algolia索引的解决方案.  

# 原理  

每次创建/更新完md文件后提交到仓库,仓库会触发Github Action的执行.  

Github Action主要做两件事:  

1. 执行hugo命令生成静态文件以及algolia索引文件(hexo等其他静态博客也类似),如果你使用的是hexo等其他静态博客,可能需要多一个操作来执行相关命令生成algolia索引文件.  
2. 通过安装了`atomic-algolia`命令的docker容器来将索引文件上传到algolia官网.  

# 配置  

配置的主要内容就是使用容器来将algolia索引文件上传,命令如下:  

```shell
docker run --rm -e ALGOLIA_ADMIN_KEY=${{ secrets.ALGOLIA_ADMIN_KEY }} -e ALGOLIA_INDEX_FILE=/public/algolia.json -e ALGOLIA_APP_ID=${{ secrets.ALGOLIA_APP_ID }} -e ALGOLIA_INDEX_NAME=${{ secrets.ALGOLIA_INDEX_NAME }} -v $PWD/public:/public registry.cn-shenzhen.aliyuncs.com/lan-k8s/ubuntu:algolia atomic-algolia
```  

其中相关的参数是放在了Github Action的secrets当中.  

完整的配置可以看看我是如何配置的[https://github.com/liangyuanpeng/liangyuanpeng.github.io/blob/source/.github/workflows/hugo.yml](https://github.com/liangyuanpeng/liangyuanpeng.github.io/blob/source/.github/workflows/hugo.yml).
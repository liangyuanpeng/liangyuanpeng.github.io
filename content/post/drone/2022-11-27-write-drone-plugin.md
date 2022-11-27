---
layout:     post 
title:      "write-drone-plugin"
subtitle:   ""
description: ""
date:       2022-11-27
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1544363191/hugo/blog.github.io/743a4e9227e1f14cb24a1eb6db29e183.jpg"
published: false
tags:
    - drone
    - cicd
categories: 
    - TECH
---

# 前言 

本文会编写一个名叫 drone-cache-oras 的 drone plugin,主要是用于将缓存存储到 OCI 镜像仓库当中,其中会以 oras 库来操作.
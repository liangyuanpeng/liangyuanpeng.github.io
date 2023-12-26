---
layout:     post 
slug:   "helpful-github-action"
title:      "githubaction常用记录"
subtitle:   ""
description: ""
date:       2023-05-05
author:     "梁远鹏"
image: "img/banner/Chinese_mythology_theme_dragon_and_army_magnificent_scenery__c7a68137-62c6-4f33-b5dd-b39934ca86cd.png"
published: true
wipnote: true
tags:
    - ghaction
    - ci
categories: 
    - TECH
---

# 前言 

记录有用的 github action 知识，欢迎投稿:)

## 可重用的github action

这个应该是比较常见的，抽离共同的内容到一个 github action，传递参数执行不同的内容，比较常规的是构建特定版本镜像和构建 latest 版本镜像。

主要分为两部分：

### 被调用方


被调用自然就是重用的 github action，只需要声明是 workflow_call 就可以了,这样就能够被直接应用到 github action 当中,另一个相似的是 workflow_dispatch，能够以 API 的方式调用 github action。

```yaml
...
on:
  workflow_call:
    inputs:
      tag:
        description: 'image tag'
        required: true
        type: string
    secrets:
      DOCKERHUB_USER_NAME:
        description: 'DOCKERHUB_USER_NAME'
        required: true
      DOCKERHUB_TOKEN:
        description: 'DOCKERHUB_TOKEN'
        required: true
...
```

上述是一个简单的示例，当被另一个 github action  调用时，必须提供一个 tag 传参 以及 DOCKERHUB_USER_NAME 和 DOCKERHUB_TOKEN 的 secret，用于构建特定版本的镜像以及 push 镜像。


### 调用方

调用时比较简单，直接使用 uses 关键字就可以了:

```yaml
...
jobs:
  call_karmada_release_latest:
      uses: {owner}/{repo}/.github/workflows/karmada_release.yaml@main
      with:
        tag: latest
      secrets:
        DOCKERHUB_USER_NAME: ${{ secrets.DOCKERHUB_USER_NAME }}
        DOCKERHUB_TOKEN: ${{ secrets.DOCKERHUB_TOKEN }}
...
```

上述是一个简单的例子，传递 latest 参数并且将需要的 secrets 传递到重用的 github action。


TODO output 以及和可重用 github action 的结合使用。
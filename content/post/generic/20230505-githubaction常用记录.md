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

记录有用的 github action 知识或问题，欢迎投稿:)

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

## 下载github action artifact

正常情况是在页面点击 github action 的 artifact 来下载,而网络不好的情况下这种方式就很难受了,这时可以通过请求 github api 的方式在一台网络良好的机器(无可视化界面/服务器)上下载 artifact了,文档在这里->https://docs.github.com/en/rest/actions/artifacts?apiVersion=2022-11-28#download-an-artifact

### 使用 curl 请求原始API

```shell
curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer <YOUR-TOKEN>" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/OWNER/REPO/actions/artifacts/ARTIFACT_ID/zip
```

只需要填写四个参数即可: `API TOKEN` `OWNER` `REPO`以及`ARTIFACT_ID`.

### 使用 gh 命令

```shell
gh run download -R {OWNER}/{REPO} {RUN_ID} -n {ARTIFACT_NAME}
```

## 被 github action 限制

我正在使用 github action 来构建 kubernetes kind node 容器镜像,正常使用了一段时间,某天突然不行了,github action workflow 总是被 cancel,最后在 Summary 看到如下提示:

```shell
build-kindnode- / release-release-1.28
Received request to deprovision: The request was cancelled by the remote provider.
build-kindnode- / release-master
Received request to deprovision: The request was cancelled by the remote provider.
build-kindnode- / release-release-1.30
Received request to deprovision: The request was cancelled by the remote provider.
```

快速 google 了一番,发现 2023 年也有人遇到过这个问题, [Github action job is cancled by remote provider.](https://github.com/actions/runner-images/issues/7897),github 官方的人表示是因为使用的内存/CPU太多了.

但是我构建kubernetes kind node容器镜像应该也不会超过资源限制呀. (:


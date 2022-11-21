---
layout:     post 
title:      "drone-quickstart"
subtitle:   ""
description: ""
date:       2022-11-08
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

drone 已经被 Harness 收购.

Drone 本身非常地轻量,非常适合中小型公司,很轻易的就能够搭建起一套完整的 CICD 流程.


# 使用的 drone runner

本文主要介绍使用drone-docker-runner.

# 配置语法介绍

drone支持以下几种配置:

- jsonnet
- starlark
- yaml

本文将会介绍 yaml 和 jsonnet 两种配置.


## 使用yaml配置  

yaml 配置作为默认的使用方式,了解甚至熟练运用是必要的,即使是使用 jsonnet 配置也需要了解 yaml 配置的内容,因为最终的内容都是使用 yaml,而 jsonnet 是让编写配置文件的人员能够拥有更灵活的 yaml 配置编写能力.

## 使用jsonnet配置  

虽然支持 jsonnet,但是似乎无法支持多个 jsonnet 文件.

例如在基本的 jsonnet 配置文件 `.drone.jsonnet` 中引用另一个 jsonnet 文件:


```
local trivyci = import 'pipeline-trivy.jsonnet';
```

使用命令`drone jsonnet --format --stdout` 能够正常解析,但是当 push 更改到代码仓库后,drone server 报错了:

```
RUNTIME ERROR: couldn't open import "pipeline-trivy.libsonnet": no match locally or in the Jsonnet library paths .drone.jsonnet:1:17-50 thunk <trivyci> from <$> .drone.jsonnet:236:18-25 thunk <trivyciamd64> from <$> .drone.jsonnet:243:3-15 thunk from <$> During manifestation
```

# 支持的源码服务提供商

- Github
- Gitee
- GitLab
- Gogs
- Gitea
- bitbucket-cloud
- bitbucket-server

有人提了个 [issue](https://github.com/harness/drone/issues/3251) 希望支持 coding.net,不过个人认为可能希望渺茫.

# 支持的数据库

- Postgres
- MySQL
- sqlite 

默认情况下使用 sqlite 作为数据存储.

# 日志存储

默认情况下,Drone 把日志存储在数据库中,但也提供了将日志存储到 S3 或任何兼容 S3 协议的服务.

## 对接s3存储日志

基本上，你需要配置为 drone-server 服务配置以下环境变量用于开启 s3 日志存储功能:

- DRONE_S3_ENDPOINT=你的s3服务地址
- DRONE_S3_BUCKET=存储日志的bucket
- AWS_ACCESS_KEY_ID=账号
- AWS_SECRET_ACCESS_KEY=密码
- AWS_DEFAULT_REGION=us-east-1
- AWS_REGION=us-east-1

# 一些缺点或限制

1. 触发 CI 事件有限

例如无法通过 labeled/issue_comment 的事件触发,如果希望基于 Drone 做 CICD 相关的机器人,可能不是很方便,无法向 K8S 社区一样,在 issue 中添加类似 /ok-to-test 的评论来触发 CI.

2. 原生不支持通过修改的 path 来触发 CI

例如只希望提交中有 *.go 或 *.java 文件更新时才会触发 CI. 这在当前的 Drone 无法直接支持.

meltwater 的开源项目[drone-convert-pathschanged](https://github.com/meltwater/drone-convert-pathschanged)能够做到这样的效果,例如:

仅当某些文件更新时才会触发整个 pipeline.
```
trigger:
  paths:
    include:
    - README.md
```

仅当某些文件有更新时才会触发 step.
```
---
kind: pipeline
name: readme

steps:
- name: message
  image: busybox
  commands:
  - echo "README.md was changed”
  when:
    paths:
      include:
      - README.md
```

不过似乎支持的平台和 drone 支持的平台不是一致的,例如在发布本文时还不支持 gitea.


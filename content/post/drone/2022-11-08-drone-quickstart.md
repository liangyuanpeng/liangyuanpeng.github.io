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

### 了解基础概念

#### Triggers

触发时机,表示通过哪一种机制来触发对应的 CI,目前共有以下 8种:

1. By Branch
2. By Event
3. By Reference
4. By Status  
5. By Status
6. By Target
7. By Cron
8. By Action

##### By Branch

根据代码 push 的分支来触发,例如以下示例为当 master 分支代码更新时触发:

```yaml
kind: pipeline
type: docker
name: default

steps:
- name: build
  image: golang
  commands:
  - go build

trigger:
  branch:
  - master
```  

也可以使用表达式:

```yaml
trigger:
  ref:
  - refs/heads/master
  - refs/heads/**
  - refs/pull/*/head
```  

或者是仅包含某些分支或排除某些分支的情况下触发:

```yaml
trigger:
  branch:
    include:
    - master
    - feature/*
```

```yaml
trigger:
  branch:
    exclude:
    - master
    - feature/*
```


##### By Event

根据事件类型来触发:

```yaml
trigger:
  event:
  - cron
  - custom
  - push
  - pull_request
  - tag
  - promote
  - rollback
```

当任意分支 push 更新时或任意 PR 更新时:

```yaml
trigger:
  event:
  - push
  - pull_request
```  

同样的,也可以排除某些事件:  
```yaml
trigger:
  event:
    exclude:
    - pull_request
```  

需要注意的一点是,By Event 不能和 By Branch 一起工作,事件触发与分支无关.

##### By Reference

根据 git 引用来触发:

```yaml
trigger:
  ref:
  - refs/heads/feature-*
  - refs/tags/*
```  

包含分支和 tag,事件同样是包含 include 和 exclude 语法.  


##### By Repository

只在某些代码仓库才触发 CI.一般是用于限制只在主仓库而不在 fork 的仓库跑 CI 时使用.  


```yaml
trigger:
  repo:
    include:
    - liangyuanpeng/waitfor
    - liangyuanpeng/replacer
```  

上述示例配置表明当有内容更新且代码仓库是 `liangyuanpeng/waitfor` 或 `liangyuanpeng/replacer` 时才触发 CI.

##### By　Status

根据 Pipieline 的执行状态来触发另一个 pipeline,例如当 CI 失败时发送 slack 通知或钉钉/飞书通知.


```yaml
trigger:
  status:
  - failure
```


##### By Target

根据 CI 的部署环境来触发 CI,只适用与升级和回滚事件.  


```yaml
trigger:
  target:
    include:
    - staging
    - production
```

```yaml
trigger:
  target:
    exclude:
    - production
```

##### By Cron

通过定时任务来触发,因此配置这个类时主动触发类型是不管用的.

```yaml
trigger:
  event:
  - cron
  cron:
  - nightly
```  

示例是每晚构建,需要注意的一点是需要先在对应 repo 的设置里面创建了 Cron Job,然后在配置文件中(例如 .drone.yml)才能够使用.

默认情况下有四种定时任务可以选择:

1. @hourly 每小时
2. @daily 每天
3. @weekly 每周
4. @monthly 每月
5. @yearly 每年

另一个注意的点是 drone 的 cron 任务不保证准确性,有一个 drone server 的配置参数: `DRONE_CRON_INTERVAL` 表示多久处理一次定时任务队列,由于 Drone 的设计理念是创建一个安全高效的 cron 调度程序,防止用户使系统过载,所以无法保证高准确性的.

示例配置:
```
DRONE_CRON_INTERVAL=10m
```  

配置 10 分钟处理一次定时任务队列,具体情况可以自己测试一下.

##### By Action

根据相关操作来触发,

例如仅在打开 PR 时触发:

```yaml
trigger:
  event:
  - pull_request
  action:
  - opened
```  


```yaml
trigger:
  event:
  - pull_request
  action:
    exclude:
    - synchronized
```

PR 事件除了同步以外的所有操作都执行 CI

TODO: 都有哪一些 action?

#### Platform

这个主要是用来给 CI 筛选合适的 Runner的.

例如针对同一份代码,在 amd 和 arm 架构的测试是不一样的,或者是某个 repo 希望单独使用某一类 Runner,这时候就可以使用 platform 相关的参数来为 CI 选择 Runner.

```yaml
kind: pipeline
type: docker
name: default

platform:
  os: linux
  arch: amd64

steps:
- name: build
  image: golang
  commands:
  - go build
```

当需要选择 arm64 架构的 runner 时则编写下面这样的配置来选择 runner:
```yaml
...
platform:
  os: linux
  arch: arm64
...
```

#### Steps  

https://docs.drone.io/pipeline/docker/syntax/steps/#privileged-mode

这是整个 CI 中最重要的概念,整个 CI 中具体所执行的内容都是在 step 当中执行的,由于 Drone 的设计理念是基于 Docker 容器的,因此每一个 step 都是一个单独的容器,下面是一个简单示例:

```yaml
kind: pipeline
type: docker
name: default

steps:
- name: backend
  image: golang
  commands:
  - go build

- name: frontend
  image: node
  commands:
  - npm install
```  

默认情况下,step 之间是并行的关系,因此上述配置的执行情况是会同时执行.

##### Commands

commands 是用来配置需要在容器中执行的命令,也就是 CI 所做的具体事情.

注意:这会覆盖容器默认的 entrypoint.

##### Environment

环境变量的设置与 Docker 容器的环境变量设置是一致的,因此如果已经了解如何为 Docker 容器设置环境变量,那么在这里也会很容易理解:

```yaml
steps:
- name: backend
  image: golang
  environment:
    GOOS: linux
    GOARCH: amd64
  commands:
  - go build
```  

使用 environment 关键字,然后每一个环境变量配置都是 key/value 的格式,这个环境变量是给每一个单独的 step 配置的,因此如果你有两个 step 都有相同的环境变量,那么你需要单独为每一个 step 都配置一次.

##### Plugins

插件其实也是一个容器,可以理解为是一个特殊的 step,因此使用方式与 step 是一致的.

```yaml
- name: notify
  image: plugins/slack
  settings:
    webhook: https://hooks.slack.com/services/...
```

drone 有一个插件中心,可以在 https://plugins.drone.io/ 查看都有什么插件.

TODO: 介绍 settings 的使用.

##### Conditions

Conditions 是针对 step 的触发条件,通过 when 关键字来使用.

```yaml

steps:
- name: backend
  image: golang
  commands:
  - go build
  when:
    branch:
    - master
```   

上述示例表示只在当前分支是 master 时才会执行这个 step,更常见的使用方式是当整个 pipeline 成功或失败时发送 slack或钉钉/飞书等消息通知,下面一个示例:

```yaml
- name: notify
  image: plugins/slack
  settings:
    webhook: https://hooks.slack.com/services/...
  when:
    status:
    - failure
    - success
```  

当 pipeline 失败时发送 slack 通知.如果是希望成功时也触发则添加一个 `- success` 即可.  


##### Failure

当某个 step 失败时整个 pipeline 的结果也是失败,如果希望当某个 step 失败时不影响整个 pipeline 的结果,那么可以为 step 添加`Failure` 处理.

```yaml
steps:
- name: backend
  image: golang
  failure: ignore
  commands:
  - go build
```  

上述配置表示当执行 `go build` 失败后,整个 pipeline 的结果依然是成功的. 有下面几个选项可以选择:

- failure: ""
- failure: "fail"
- failure: "fail-fast"
- failure: "fast"
- failure: "always"
- failure: "ignore"  


##### Detach

detach 是将当前 step 的任务设置为后台运行,只要 step 开始运行就会处理下一个 step,目标用例是启动一些其他 step 需要使用到的后台服务或者守护进程.下面是一个简单示例:

```yaml
steps:
- name: backend
  image: golang
  detach: true
  commands:
  - go build
  - go run main.go -http=:3000
```  

上述配置会启动一个端口为 3000 的 http 服务,如果不配置`detach:true` 那么整个 pipeline 可能不会无法主动结束,直到超时.因为这一个 step 一直是处于运行的状态.  


##### Privileged Mode

特权模式,这就是就是 Docker 容器的 `--privileged` 参数,将 step 对应的容器升级为特权模式的容器.

需要注意的是这个配置只能在受信任的 drone repo 中才能够使用,需要在 repo -> Settings -> General -> Project Settings -> Trusted 配置打开.

#### Services

TODO 私有镜像

https://docs.drone.io/pipeline/docker/syntax/images/

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

例如无法通过 labeled/issue_comment 的事件触发,如果希望基于 Drone 做 CICD 相关的机器人,可能不是很方便,无法向 K8S 社区一样,在 issue 中添加类似 /ok-to-test 的评论来触发 CI. 也无法当给 PR 添加标签时触发 CI,例如给 PR 添加了 approved 标签时触发 CI 检查测试是否通过,如果通过则让机器人合并这个 RP,但是目前 drone 不会处理这个标签事件, 因此也没有办法做到这一点.

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


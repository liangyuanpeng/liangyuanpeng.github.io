---
layout:     post 
slug:      "tekton-quickstart"
title:      "Tekton快速入门"
subtitle:   ""
description: ""
date:       2022-11-06
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612744351/hugo/blog.github.io/pexels-bruno-cervera-6032877.jpg"
published: false
tags:
    - tekton
    - cdf
    - cicd
categories: 
    - CloudNative
---    

# 前言

- 足够灵活，可以任意组合 pipeline/task,将部分通用的内容抽象出来
- 动态申请/释放资源,需要执行到对应的task/pipeline时才需要启动一个pod，并且执行完成后可以立刻释放资源
- 基于K8S之上
- 基于 tekton triggers 与其他工具进行结合
- tekton catalog，可以在 artifacthub上查询其他人制作的通用的 task/pipeline


# 开始第一个taskrun

git clone pipeline
k create -f examples/v1beta1/taskruns/step-script.yaml


# tekton slack的问题

## https://tektoncd.slack.com/archives/CK3HBG7CM/p1684834262873519

Is the affinity-assistant smart enough to check the access mode of a PVC and work out if it needs to schedule every pod on the same node or not. E.g. If I use a ReadWriteMany volume will all pods still be scheduled to the same node?

## https://tektoncd.slack.com/archives/CK3HBG7CM/p1684218077071439

Hi all, I was wondering how I could make a pipeline stop if a certain condition is met without having it fail. So a pipeline with steps A B C and D, if a certain condition is met in A, just say "OK" and do not perform B C & D.
I figured I could put B C & D in a conditional block but this becomes a bit messy (I think), especially when you consider finally blocks and whatnot.
Is there an option I'm missing?
Thanks a bunch!

---
layout:     post 
slug:      "pod-disruption-budgets"
title:      "pod-disruption-budgets"
subtitle:   ""
description: ""
date:       2023-03-25
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612709640/hugo/blog.github.io/pexels-taryn-elliott-4909166.jpg"
published: true
tags:
    - kubernetes
    - cncf
    - 翻译
categories: 
    - kubernetes
---

您有没有经历过 Kubernetes 工作负载由于节点维护或故障而受到干扰的沮丧？当节点进行维护或发生故障时，运行在它们上面的 pod 将被终止并重新调度到其他节点上。这可能会导致可用性降低，潜在的数据丢失或停机时间。但请不要担心，因为有一个强大的 Kubernetes 功能可以帮助您管理干扰并保持高可用性——Pod Disruption Budgets（PDB）。

今天，我们将详细探讨 PDB，包括它们是什么、为什么它们很重要以及如何有效使用它们。

管理挑战和切换到 PDB
当管理具有多个节点和工作负载的 Kubernetes 集群时，在节点维护或故障期间确保高可用性可能会很具有挑战性。如果没有适当的管理，运行负载的干扰可能会导致停机时间或数据丢失，这可能会对企业造成巨大的损失。

在过去，管理节点维护或故障期间对工作负载的干扰需要手动干预。这涉及监视集群的故障，手动将工作负载移动到健康的节点，并确保在任何时候都有最少数量的 pod 可用。这个过程耗时且容易出错，导致停机时间更长和数据丢失。

随着 Kubernetes 中 Pod Disruption Budgets 的引入，管理节点维护或故障期间的干扰并在此期间保持高可用性变得更加容易和自动化。

# 原文

英文原文来自 https://medium.com/geekculture/kubernetes-pod-disruption-budgets-pdb-b74f3dade6c1
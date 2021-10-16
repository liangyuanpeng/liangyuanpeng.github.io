---
layout:     post 
slug:      "kubesphere-gateway-with-contour"
title:      "KubeSphere使用Contour Ingress作为项目网关"
subtitle:   ""
description: ""
date:       2021-10-16
author:     "梁远鹏"
image: "img/post-bg-2015.jpg"
published: true
tags:
    - contour 
    - cncf
    - kubesphere
categories: [ CloudNative ]
---

# 前言

# 注意

目前kubesphere基于Nginx Ingress实现网关，3.2将会重构网关这部分，从而做到使用其他ingress项目作为kubesphere的网关，本文将会在3.2发布后尝试使用CNCF项目的Contour作为kubesphere网关.  

kubesphere 网关这部分内容可以看看这个issue的讨论. [[Proposal]Refactor KubeSphere gateway with CRD](https://github.com/kubesphere/kubesphere/issues/3055)

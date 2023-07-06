---
layout:     post 
slug:      "etcd-as-a-kubernetes-sig"
title:      "将Etcd作为一个kubernetes sig来运作"
subtitle:   ""
description: ""
date:       2023-06-30
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: false
tags:
    - kubernetes 
    - cncf
    - etcd
    - kubernetes-sigs
categories: 
    - cloudnative
---

# 说明


做出这个决定的本质原因是 Etcd 的贡献者/维护人员过少,因此希望将 Etcd 作为一个 kubernetes sig 来运作


https://github.com/etcd-io/etcd/issues/15875


# 你都用etcd做了什么?

https://www.surveymonkey.com/r/etcdusage23

可以在官网https://etcd.io/docs/v3.5/integrations/#projects-using-etcd 看到，不少的知名项目都使用了 etcd，例如 Apache Pulsar,Apache APISIX.

如果在你的项目中也将 etcd 用到了非 kubernetes 场景中,方便的话请帮助填写一下用户问卷,这对 etcd 社区很有帮助,感谢! 同时问卷中已经声明,只有 CNCF/etcd 相关人员可以见到调查问卷的情况,从而帮助保护你的隐私.



# 其他想法

这让我想起 Apache Bookkeeper 也曾经历过类似的事情,由于 Apache Bookkeeper 处于一个相对底层的位置(作为 Pulsar 的存储层),因此贡献者相对较少,即使 19年 Streamnative 做过几次 Bookkeeper 的技术分享,似乎也没有泛起什么水花.

# Xline

[Xline](https://github.com/xline-kv/Xline) 是一个兼容 Etcd API 的用于元数据管理的 KV 存储，目标是基于 CURP 协议实现跨云/跨数据中心管理元数据，由 datenlord 开源并捐赠到CNCF,目前是 CNCF sandbox 项目.
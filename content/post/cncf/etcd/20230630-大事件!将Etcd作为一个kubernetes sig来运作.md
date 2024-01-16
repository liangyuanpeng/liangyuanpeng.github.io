---
layout:     post 
slug:      "etcd-as-a-kubernetes-sig"
title:      "将Etcd作为一个kubernetes sig来运作"
subtitle:   ""
description: ""
date:       2023-06-30
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags:
    - kubernetes 
    - cncf
    - etcd
    - kubernetes-sigs
categories: 
    - cloudnative
---

# 说明


在我看来,做出这个决定的本质原因是 Etcd 的贡献者/维护人员过少,因此希望将 Etcd 作为一个 kubernetes sig 来运作,以此来降低维护人员的维护程度以及通过 kubernetes sig 来吸引贡献者.

这同样也意味着 etcd 社区希望引入 kubernetes 社区的一些治理模式,以此来增加 etcd 社区活跃度.


完整的 issue 讨论在这里: https://github.com/etcd-io/etcd/issues/15875

整个讨论中,很多大佬也发表了自己的想法,例如 etcd 前维护者,kubernetes SIG API Machinery 的联合主席以及etcd的一些现任维护者.

## etcd sig 是什么

etcd sig 相关的初步设计的谷歌文档在这里: https://docs.google.com/document/d/1KFrLeKyHvNDv4b0GswYU3_zbeSATgCanT5dzCID4oJY/edit

其中这个 sig 的负责内容如下:

- 在etcd-io组织下开发etcd和其他存储库
- Kubernetes 打包的 etcd 镜像的维护
- 指定、测试和改进隐式 Kubernetes-ETCD 合约

不包括的内容: etcd 中存储的数据结构归 SIG API Machinery 所有


### 领导
椅子和技术主管
本杰明·王 (@ahtr)，VMware
Marek Siarkowicz (@serathius)，谷歌
### Chairs （期待）
我们不会为 SIG 的成立提名专门的主席。 然而，我们将积极激励现有的社区成员增加他们的贡献，以便他们能够在未来填补这些角色。

## etcd sig 注意事项

https://docs.google.com/document/d/1tqjOxU7hhiQiUi_w6Fr5CWSCOzQIoc49kysB4bDx59o/edit

etcd SIG-ify 的注意事项
作者：马雷克·西亚科维奇
状态：审查
评论：[x]ptabor@github.com、[x]ahrtr@github.com、[x]spzala@github.com、[x]h.mitake@gmail.com
最后更新：2023 年 6 月 30 日
创建时间：2023 年 6 月 30 日


正如 The Case for SIG-ifying ETCD 和 ETCD 作为 kubernetes SIG 中提出的那样，etcd 项目正在致力于治理变革，以使其更接近 Kubernetes 组织。 为了确保清晰，本文档将讨论我们想要引入 etcd 项目的具体更改，以及我们想要保持不变的内容。

首先要明确的是，SIG 化的目标不是将 etcd 项目捐赠给 Kubernetes，也不是改变项目目标只为 Kubernetes 服务。 etcd 项目的目标是利用 Kubernetes 构建的经验、基础设施和流程来服务 etcd 社区和所有 etcd 用户。 我们希望获得 CNCF 尚未准备好提供的关键支持。
不该做的事
让我们从我们不想改变的事情开始吧。 如果这只是一个项目捐赠，其中一些事情可能看起来很自然，但是由于我们没有看到 etcd 社区有任何好处，所以我们不会这样做。 以下列出了自 SIG etcd 创建以来不会发生的事情，我们认为它们将来不应该发生：
不要将 etcd 项目捐赠给 Kubernetes 组织
不要将 etcd 存储库移至 Kubernetes 组织
不要将项目仅专注于 Kubernetes 用例，更多内容请参阅 SIG etcd 章程和愿景
该做的
Kubernetes 社区构建了很多我们想要利用的很棒的东西。 我们希望能够减少 etcd 维护者和社区的辛劳，让项目更加自我可持续，让每个人都专注于让 etcd 为每个人带来好处。 以下是我们希望发生的事情的列表：
创建一个 SIG etcd 来代表 Kubernetes 社区中的 etcd 兴趣。 这将有助于利用 Kubernetes 的声誉吸引更多人加入该项目。
TODO：获得 Kubernetes Steering 批准 SIG 所需的事项列表
调整 Kubernetes 的治理并将决策权委托给 SIG-etcd，具体来说：
取代当前基于维护者的治理模型，该模型效率低下并且可能导致群体思维。 相反，请使用 Kubernetes 的 SIG 治理模型，该模型需要积极的领导并将技术和组织角色分开。 SIG 治理的详细信息。
向 etcd 项目引入审批者角色。 这将进一步分离贡献者的责任并增加代码库所有权的粒度。 它还将使贡献者更有利于成为特定领域的专家。 现有维护者将根据其活动转移到审批者角色。
结合 etcd 和 Kubernetes 社区的努力，并将结果提供给所有人。 这将有助于避免重复工作并提高项目的整体质量。 重复工作的一些示例：etcd 镜像、etcd-Kubernetes 合约、etcd-proxy/K8s 监视缓存。
调整类似于 Kubernetes 的增强建议和生产准备情况审核的流程。 利用 Kubernetes 社区的经验使 etcd 成熟用于生产。 etcd 社区不太擅长对功能进行分级并使其可用于生产（上下文、未分级功能列表）。
使用 Kubernetes 发布机制来确保安全且经过审核的发布过程。 当前发布 etcd 的过程是在维护者拥有的笔记本电脑上手动完成的（上下文）。 这是一个安全风险，如果维护人员的笔记本电脑受到威胁，可能会导致灾难性的情况。
利用 Kubernetes 的安全响应来帮助分类和解决 etcd 安全漏洞。 相比之下，对 etcd 安全电子邮件 security@etcd.io 的访问权限丢失，并且一年多以来没有人阅读它。
也许的
利用 https://github.com/kubernetes/org 管理成员资格和权限。 目前，这是由 etcd 维护人员手动完成的，没有任何监督和审计。 这是一个安全风险，如果维护人员的笔记本电脑受到威胁，可能会导致灾难性的情况。

# 进展

目前已经在 kubernetes/community 中申请 etcd sigs 见 PR: https://github.com/kubernetes/community/pull/7372


# 你都用etcd做了什么?



可以在官网 https://etcd.io/docs/v3.5/integrations/#projects-using-etcd 看到，不少的知名项目都使用了 etcd，例如 Apache Pulsar,Apache APISIX.

如果在你的项目中也将 etcd 用到了非 kubernetes 场景中,方便的话请帮助填写一下[用户问卷](https://www.surveymonkey.com/r/etcdusage23),这对 etcd 社区很有帮助,感谢! 同时问卷中已经声明,只有 CNCF/etcd 相关人员可以见到调查问卷的情况,从而帮助保护你的隐私.


# 其他想法

这让我想起 Apache Bookkeeper 也曾经历过类似的事情,由于 Apache Bookkeeper 处于一个相对底层的位置(作为 Pulsar 的存储层),因此贡献者相对较少,即使 19年 Streamnative 做过几次 Bookkeeper 的技术分享,似乎也没有泛起什么水花.

# Xline

[Xline](https://github.com/xline-kv/Xline) 是一个兼容 Etcd API 的用于元数据管理的 KV 存储，目标是基于 CURP 协议实现跨云/跨数据中心管理元数据，由 datenlord 开源并捐赠到CNCF,目前是 CNCF sandbox 项目.

目前 Xline-kv 组织下共有两个项目, Xline 和 Xline Operator, 都是用 Rust 语言开发,对于 Rust 语言感兴趣的同学可以了解一下.

我对其发展前景持看好态度,但由于是 Rust 语言开发,因此道路可能比较坎坷(社区相对go社区小,门槛比 golang 高 相关库不够丰富)

NOTE: Xline Operator 已经使用 Go 来重新开发了.

## 开始使用 Xline

目前我基于 Kind 搭建的 kubernetes 研究环境已经用上 Xline 了,如果你也想体验只需要将 kube-apiserver 中指向 etcd 的地址修改为 xline 的地址就可以了,也可以将部分数据存储到 Xline 中来浅尝一下,例如通过 `etcd-servers-overrides: /events#http://172.18.0.2:2379` 参数把 event 数据单独存储到 Xline 中,而 k8s 中的其他数据依然存储到 etcd 中.
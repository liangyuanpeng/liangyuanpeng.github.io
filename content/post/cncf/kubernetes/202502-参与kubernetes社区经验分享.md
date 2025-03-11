---
layout:     post 
slug:      "share-experience-to-opensource-of-kubernets"
title:      "参与kubernetes社区经验分享"
subtitle:   ""
description: "加入任何开源社区都可能让人望而生畏，尤其是像 Kubernetes 这样的大型社区"
date:       2025-02-18
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags:
    - kubernetes 
    - cncf
    - k8s
    - k8s-sigs
    - k8s-csi
categories: [ kubernetes ]
---

# 注意

该文章只是一些碎片经验的分享,并不是成章的一篇博客.

# kubernetes-csi 社区 PR 注意事项

[chore: update go to 1.23.6](https://github.com/kubernetes-csi/external-snapshot-metadata/pull/122)

上述是我提交的一个更新项目 go 版本到 1.23.6 的 PR,其中涉及两部分,第一部分是项目使用到的 go 版本,也就是 go.mod 的内容,第二部分是构建容器镜像时使用到的 go 版本(同时也是 prow job 中会使用到的 go 版本).

而 prow job 使用到的 go 版本是放在了 prow.sh 里面指定的,这个文件有点特殊,这是从仓库 [csi-release-tools](https://github.com/kubernetes-csi/csi-release-tools) 同步过来的,说明在这里: https://github.com/kubernetes-csi/csi-release-tools?tab=readme-ov-file#sharing-and-updating

也就是 kubernetes-csi 组织下的大部分项目用到的 release 和 prow job 相关的内容都是从这里同步的,而不是手动修改项目仓库中的 prow.sh.

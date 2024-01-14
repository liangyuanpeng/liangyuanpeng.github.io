---
layout:     post 
slug:      "deprecation-warnings-in-containerd-getting-ready-for-2.0"
title:      "containerd 中的弃用警告 - 为 2.0 做好准备!"
subtitle:   ""
description: "containerd 中的弃用警告 - 为 2.0 做好准备!"
date:       2024-01-14
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags:
    - containerd 
    - cncf
    - kubernetes
categories: 
    - cloudnative
---

# 前言    

containerd 2.0 将是自 2017 年 12 月首次稳定发布 1.0 以来，containerd 的第一个大版本. 经过了六年的开发,测试和完善, 作为许多托管容器产品的默认容器运行时的 containerd,2.0 将会揽括我们在大规模构建和运用 containerd 时所积累到的经验. 因此 2.0 将会带来一些核心内容的重大重构(CRI 以及 容器镜像管理),新功能(sandbox 插件,transfer 插件以及容器镜像校验插件),改进完善(更优的用户命名空间,NRI更新)以及删除了一些已经弃用的功能.

删除功能(重大更新)可能会很难处理,在某些情况下,你的使用场景可能依赖于正在删除的弃用功能,而在另一种情况下,你甚至可能不知道你用到了这些被弃用的功能.对于某些功能的删除和迁移会很简单,但有时候可能很难对弃用功能做一些迁移.

为了帮助你了解已经弃用的功能以及被删除功能之间的依赖性,我们添加了一些新的 crt deprecations list 命令(backed by new data in containerd's `introspection` service Server API)).命令可以针对已经弃用的功能返回一些使用的基本情况的警告,这些功能可能会在未来被 containerd 删除.而每个警告都会提示以下内容:

- 正在删除什么内容
- 对于这个功能的迁移建议是什么
- 上一次使用这个功能的时间

下面是这个命令行的一个简单示例效果:

```shell
# ctr deprecations list
ID                                               LAST OCCURRENCE                   MESSAGE    
io.containerd.deprecation/pull-schema-1-image    2023-12-29T01:17:21.672915093Z    Schema 1 images are deprecated since containerd v1.7 and removed in containerd v2.0. Since containerd v1.7.8, schema 1 images are identified by the "io.containerd.image/converted-docker-schema1" label.
```

为了可读性, `ctr deprecations list` 命令还支持使用`--format=json`标志来返回 json 格式的数据.

可以在[containerd官网](https://containerd.io/releases/#deprecated-features)找到全部的功能删除和迁移的建议,[完整的功能弃用警告](https://github.com/containerd/containerd/issues/9312)发布在 containerd [1.6.27](https://github.com/containerd/containerd/releases/tag/v1.6.27) 和 [1.7.12](https://github.com/containerd/containerd/releases/tag/v1.7.12) 中.我们建议在更新到 2.0 之前先更新到 containerd 1.6.27 和 1.7.12 并将其用于生产环境.


# 注

本文翻译自[Deprecation Warnings in containerd - Getting Ready for 2.0!](https://samuel.karp.dev/blog/2024/01/deprecation-warnings-in-containerd-getting-ready-for-2.0/)
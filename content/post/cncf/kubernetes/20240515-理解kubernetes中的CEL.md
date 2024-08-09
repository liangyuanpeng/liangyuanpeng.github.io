---
layout:     post 
slug:      "understand-cel-of-kubernetes"
title:      "理解kubernetes中的CEL"
subtitle:   ""
description: "理解kubernetes中的CEL"
date:       2024-05-15
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: false
tags:
    - kubernetes 
    - cncf
    - k8s
    - cel
    - kep
categories: [ kubernetes ]
---

> 


baseOptsWithoutStrictCost 变量, 这里加载了 kubernetes 扩展的 cel lib,也可以在这里看到 cel 是在哪一个 kubernetes 版本中引入的.


```golang
envSet, err := baseEnvSet.Extend(environment.VersionedOptions{
```

baseEnvSet.Extend 是一个核心点,很多地方都用到了,用于扩展一个EnvSet,注释说到该EnvSet 未变异? ( This EnvSet is not mutated.) 没理解什么意思

基于 cel.env.Extend 方法, TODO: 用cel 来跑个demo试试扩展自己的cel环境.

apiservercel.NewDeclTypeProvider 也是一个核心的内容, 基于openAPI的与CEL兼容的类型 DeclType

TODO 查看tekton中的cel?

```golang
combined := cel.Lib(&envLoader{
		envOpts:  envOpts,
		progOpts: progOpts,
	})
```

添加额外的库.





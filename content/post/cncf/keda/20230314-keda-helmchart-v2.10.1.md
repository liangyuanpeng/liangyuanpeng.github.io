---
layout:     post 
slug:   "keda-helmchart-release-with-v2.10.1"
title:      "keda-helmchart发布v2.10.1"
subtitle:   ""
description: ""  
date:       2023-03-14
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1543506262/hugo/blog.github.io/apache-rocketMQ-introduction/7046d2bf0d97278682129887309cc1a6.jpg"
published: true
tags: 
    - keda
    - cncf
    - kubernetes
categories: 
    - kubernetes
---

# keda helm chart 发布v2.10.1


# 长话短说
```shell
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
helm install keda kedacore/keda --version 2.10.1 -n keda --create-namespace
```

# 新内容

- 提供了对`podLabels`在 webhook Deployment 中的配置 ([#404](https://github.com/kedacore/charts/pull/404/files) 🎉 贡献者 [@pari-](https://github.com/pari-))
- 为`cert-manager`证书配置支持时间的完整单位 ( [#402](https://github.com/kedacore/charts/pull/402) 🎉 贡献者[JorTurFer](https://github.com/JorTurFer))  

## Bug修复/修改  

- 修复了环境变量`POD_NAMESPACE`没有添加到 deployment 的问题 ([#405](https://github.com/kedacore/charts/pull/405) 🎉 贡献者 [michemache](https://github.com/michemache))
- 强制执行  kubernetes v1.24 或更高版本,以至于和 [KEDA集群兼容性](https://keda.sh/docs/2.10/operate/cluster/#kubernetes-compatibility)保持一致.  

## 重大变化  

无.

---
# 新贡献者  

- [pari-](https://github.com/pari-) 在为PR[#404](https://github.com/kedacore/charts/pull/404)做出了他的第一个贡献.
- [michemache](https://github.com/michemache) 为PR[#405](https://github.com/kedacore/charts/pull/405) 做出了他的第一个贡献.

完整更新日志: https://github.com/kedacore/charts/compare/v2.10.0...v2.10.1
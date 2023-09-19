---
layout:     post 
slug:      "impl-kubernetes-operator-with-java"
title:      "用java开发一个kubernetes operator"
subtitle:   ""
description: "java开发一个kubernetes operator"  
date:       2023-09-11
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: false
tags: 
    - kubernetes
    - java
    - springboot3
    - operator-sdk
    - cncf
    - quarkus
categories: 
    - cloudnative
---



云原生领域基本上都是 GO 在领导,而 JAVA 作为一款顶级流行语言,也在云原生领域不断发展,就 kubernetes operator 而言,已经有一个 java 语言的 operator sdk 了,目前是作为 CNCF 项目 operator framework (operator-sdk) 的子项目存在. 仓库位于 https://github.com/operator-framework/java-operator-sdk, 简称为 josdk (java operator sdk).

其还扩展了几个生态项目,例如 springboot3 的 starter : https://github.com/operator-framework/josdk-spring-boot-starter

目前很火的 Quarkus 也有一个相关的生态项目, https://github.com/quarkiverse/quarkus-operator-sdk  , 基于 quarkus 来开发 kubernetes operator.

本文来尝试使用 JOSDK 来开发一个 kubernetes operator.


目前有几个流行项目已经基于 JOSDK 来开发 operator 了:

- Keycloak 目前是 CNCF 孵化级别的项目,[Keycloak operator](https://github.com/keycloak/keycloak/tree/main/operator) 是官方开源的基于 Quarkus 和 JOSDK. 开发的 Operator.
- strimzi 目前是 CNCF 孵化级别的 kafka operator 的项目,不是基于 JOSDK 开发的,但子项目[Strimzi Access operator](https://github.com/strimzi/kafka-access-operator) 是基于 JOSDK 开发,还有另一个子项目 [Strimzi Schema Registry Operator](https://github.com/shangyuantech/strimzi-registry-ksql-operator) 也是基于 JOSDK 开发.
- [Apache Flink Kubernetes operator](https://github.com/apache/flink-kubernetes-operator) 是 Apache Flink 官方开发的 operator.
- [kaap](https://github.com/datastax/kaap)是datastax 开源的一个 pulsar operator


Strimzi   cncf 项目
flink 
pulsar
Keycloak operator: the official Keycloak operator, built with Quarkus and JOSDK.   cncf


参考:
- https://kubernetes.io/zh-cn/blog/2019/11/26/develop-a-kubernetes-controller-in-java/

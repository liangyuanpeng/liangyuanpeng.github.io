---
layout:     post 
slug:      "deploy-pulsar"
title:      "部署去ZK后的Apache Pulsar"
subtitle:   ""
description: " "
date:       2021-05-22
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612709780/hugo/blog.github.io/pexels-matt-hardy-2568001.jpg"
published: true
wipnote: true
tags:
    - CloudNative
    - pulsar
categories: 
    - TECH
---

# 前言  

记录我的终端更新笔记 :(

# 当我们在说元数据中心的时候我们在说什么  

Bookkeeper 和 Pulsar Broker 都有各自的元数据中心,并且都有自己的元数据中心接口,默认都是ZK.  

要实现Pulsar去Zookeeper化的话意味着Pulsar Broker和Bookkeeper都需要拥有这样的能力. Bookkeeper 本身有etcd 元数据中心接口的实现,但是Pulsar Broker也实现了BK的元数据中心接口,我们这里讨论的 Bookkeeper 对接etcd 也是使用 Pulsar Broker 自身实现的 Bookkeeper 元数据接口.而不是 Bookkeeper 自带的 etcd 元数据接口实现.  

基本上有了这样的框架之后,后续 Pulsar 如果要发展自己的元数据中心会相对比较顺利.

本文示例会以 Pulsar 2.10.0 这个版本,其中配套的 Bookkeeper 版本是4.14.4,这个版本的 Bookkeeper 的autoRecovery 逻辑中依然是直接连接了 Zookeeper,因此需要启动时需要在 bookkeeper.conf 中把  autoRecoveryDaemonEnabled 设置为 false.

# 部署   

部署相关的yaml都可以在[pulsar-sigs/deploy-files](https://github.com/pulsar-sigs/deploy-files)中找到.  

首先将仓库clone到本地：  

```
git clone https://github.com/pulsar-sigs/deploy-files.git
cd deploy-files
```  

以下docker-compose和kubernetes部署方式都会以这个仓库的文件作为基础.

## docker-compose

## kubernetes  

```shell
$ cd kubernetes
$ kubectl apply -f .
service/bk created
service/bknp created
statefulset.apps/bk created
statefulset.apps/busybox created
service/etcd created
service/etcdnp created
statefulset.apps/etcd created
deployment.apps/pulsar-consumer created
job.batch/pulsar-init created
deployment.apps/pulsar-producer created
service/pulsar created
service/pulsarnp created
statefulset.apps/pulsar created
statefulset.apps/pulsarctl created
serviceaccount/pulsar created
role.rbac.authorization.k8s.io/pulsar created
clusterrole.rbac.authorization.k8s.io/pulsar created
rolebinding.rbac.authorization.k8s.io/pulsar created
clusterrolebinding.rbac.authorization.k8s.io/pulsar created
```

耐心等待一段时间后所有Pod都会处于Running状态.
```shell
$ kubectl get po
NAME                               READY   STATUS      RESTARTS   AGE
bk-0                               1/1     Running     0          2m38s
etcd-0                             1/1     Running     0          2m38s
pulsar-0                           1/1     Running     0          2m37s
pulsar-consumer-77f96bbf9d-bwspx   1/1     Running     1          2m38s
pulsar-init-gs5f4                  0/1     Completed   0          2m38s
pulsar-producer-9b46f7455-ndtsq    1/1     Running     1          2m37s
pulsarctl-0                        1/1     Running     0          2m38s
```  


假设这时候所有的Pod都已经启动在Running了,我们可以看一下pulsar-client consumer这个pod,他会不断的消费pulsar topic的消息,正常的话可以看到不断的有日志打印出来.

```shell
$ kubectl logs -f pulsar-consumer-77f96bbf9d-bwspx
...
2022/05/22 11:11:55 consume message: topic is persistent://public/default/lan-partition-0 , topic key is : and payload is :hello 
2022/05/22 11:11:56 consume message: topic is persistent://public/default/lan-partition-0 , topic key is : and payload is :hello 
```  

可以看到不断的会有log打印, 这时基于 `etcd` 元数据中心的 `pulsar` 已经处于正常的工作状态了.

# 笔记  

1. function worker会使用到Dlog，直接连接的ZK. 
2. 有状态的pulsar function会使用到BK的table service,而table service似乎也是连接ZK.

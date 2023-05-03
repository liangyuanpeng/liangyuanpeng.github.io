---
layout:     post 
slug:      "oxia-is-next-pulsar-metadata"
title:      "下一代pulsar元数据存储Oxia"
subtitle:   ""
description: "简单来说呢 oxia 是一个基于 kubernetes 的可扩展的元数据存储和协调系统,设计的目标是为了成为Apache Pulsar 的关键组件,也就是元数据中心,取代Zookeeper/Etcd."
date:       2023-05-03
author:     "梁远鹏"
image: "/img/banner/743a4e9227e1f14cb24a1eb6db29e183.jpg"
published: true
wipnote: true
tags:
    - CloudNative
    - pulsar
    - oxia
    - kubernetes
    - chaosmesh
categories: 
    - TECH
---

# Oxia 是什么?

简单来说呢 oxia 是一个 streamnative 开源的基于 kubernetes 的可扩展的元数据存储和协调系统,设计的目标是为了成为Apache Pulsar 的关键组件,也就是元数据中心,取代Zookeeper/Etcd.  

集群模式下依赖于 kubernetes,同时也提供 standalone 模式的启动方式,也就是可以脱离 kubernetes 直接单进程启动的方式。

# 验证系统正确性

由于 Oxia 是希望作为 Apache Pulsar 的核心组件元数据中心存在,那么正确性是非常重要的,因此校验服务的分布式逻辑正确性是必须的,Oxia 使用三种方式来做测试:

## TLA

## Maelstrom / Jepsen 测试

## Chaos Mesh

由于 Oxia 基于 kubernetes 实现,因此很容易就想到使用基于 kubernetes 的混沌工程来做测试,目前在 CNCF 项目列表中有 Chaosmesh 这三个项目是混沌工程的,而 Oxia 选择使用 Chaos Mesh.

Oxia 使用了 Chaosmesh 来验证系统在注入故障后的正确性,以及针对注入故障后降级的性能是否合适.

# 简单食用一下!  

## 编译oxia

可以简单的通过两种方式启动:

- 通过源码编译出二进制
- 通过已经发布的 docker 容器镜像

这里使用编译源码构建二进制的方式:

```
git clone git@github.com:streamnative/oxia.git
cd oxia
make
```

编译成功后`oxia`二进制文件会出现在`bin`目录下.

## 启动oxia服务

```shell
lan@lan:~/oxia$ bin/oxia standalone
May  3 09:35:38.181877 INF Starting Oxia standalone config={"DataDir":"./data/db","InMemory":false,"InternalServiceAddr":"","MetricsServiceAddr":"0.0.0.0:8080","NotificationsRetentionTime":3600000000000,"NumShards":1,"PublicServiceAddr":"0.0.0.0:6648","WalDir":"./data/wal","WalRetentionTime":3600000000000}
May  3 09:35:38.186955 INF Created leader controller component=leader-controller namespace=default shard=0 term=-1
May  3 09:35:38.188805 INF Leader successfully initialized in new term component=leader-controller last-entry={"offset":"-1","term":"-1"} namespace=default shard=0 term=0
May  3 09:35:38.189097 INF Applying all pending entries to database commit-offset=-1 component=leader-controller head-offset=-1 namespace=default shard=0 term=0
May  3 09:35:38.189151 INF Started leading the shard component=leader-controller head-offset=-1 namespace=default shard=0 term=0
May  3 09:35:38.190240 INF Started Grpc server bindAddress=[::]:6648 grpc-server=public
May  3 09:35:38.190386 INF Serving Prometheus metrics at http://localhost:8080/metrics
```

## 使用oxia客户端读写数据

编译出来的 oxia 二进制文件中包含了客户端的逻辑,可以使用 `oxia client`进入客户端模式:

```shell
lan@lan:~/oxia$ bin/oxia client put -k /hello -v world
{"version":{"version_id":0,"created_timestamp":1683106558058,"modified_timestamp":1683106558058,"modifications_count":0}}
lan@lan:~/oxia$ bin/oxia client get -k /hello
{"binary":false,"value":"world","version":{"version_id":0,"created_timestamp":1683106558058,"modified_timestamp":1683106558058,"modifications_count":0}}
```

## oxia 压测

除了普通的客户端之外,oxia 二进制还包含了压测的功能:

```shell
lan@lan:~/oxia$ bin/oxia perf --rate 10000
May  3 09:39:09.376491 INF Starting Oxia perf client config={"BatchLinger":5000000,"KeysCardinality":1000,"MaxRequestsPerBatch":1000,"Namespace":"default","ReadPercentage":80,"RequestRate":10000,"RequestTimeout":30000000000,"ServiceAddr":"localhost:6648","ValueSize":128}
May  3 09:39:19.380180 INF Stats - Total ops: 10994.9 ops/s - Failed ops:    0.0 ops/s
                        Write ops 2197.9 w/s  Latency ms: 50%   8.9 - 95%  24.5 - 99%  38.9 - 99.9%  38.9 - max   38.9
                        Read  ops 8797.0 r/s  Latency ms: 50%   5.2 - 95%  15.4 - 99%  29.6 - 99.9%  29.6 - max   29.6
May  3 09:39:29.379691 INF Stats - Total ops: 9996.8 ops/s - Failed ops:    0.0 ops/s
                        Write ops 1999.6 w/s  Latency ms: 50%   8.8 - 95%  13.1 - 99%  27.0 - 99.9%  27.0 - max   27.0
                        Read  ops 7997.2 r/s  Latency ms: 50%   4.5 - 95%   7.2 - 99%  15.5 - 99.9%  15.5 - max   15.5
May  3 09:39:39.380111 INF Stats - Total ops: 10001.3 ops/s - Failed ops:    0.0 ops/s
                        Write ops 2001.7 w/s  Latency ms: 50%   8.8 - 95%  13.5 - 99%  25.5 - 99.9%  25.5 - max   25.5
                        Read  ops 7999.6 r/s  Latency ms: 50%   4.6 - 95%   7.1 - 99%  15.1 - 99.9%  15.1 - max   15.1
```  

上述通过 oxia 命令行本身提供的client模式来使用了一下,你也可以使用官方提供的 go client 来通过代码了解oxia。 [Go 客户端文档](https://github.com/streamnative/oxia/blob/main/docs/go-api.md) 

# 最后说两句

上述只是简单的试用了一下 oxia 单机版,oxia 还提供了通过 helm 和 operator 的方式部署在 kubernetes 之上,后续有可能会在本文更新这部分内容。

oxia 的设计目标是成为 apache pulsar 的关键组件之一，但就目前还说还在早期，oxia 本身还没有 GA 不谈，另一个重要的点是将组件应用到 apache pulsar 中还需要 java 客户端，而目前 oxia 还没有 java 客户端。

但就oxia 的研发团队来看，oxia 还是很有前景的，由 apache pulsar 的 PMC 之一 merlimat 主导，并且设计目标就是为了 apache pulsar 而存在。
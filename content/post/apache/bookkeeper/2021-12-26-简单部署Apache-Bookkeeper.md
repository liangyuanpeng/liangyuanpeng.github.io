---
layout:     post 
slug:      "simple-deploy-for-apache-bookkeeper"
title:      "简单部署Apache-Bookkeeper"
subtitle:   ""
description: ""
date:       2021-12-26
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612709780/hugo/blog.github.io/pexels-matt-hardy-2568001.jpg"
published: true
wipnote: true
tags:
    - bookkeeper
    - zookeeper
    - apache
categories: [ TECH ]
---    

# 前言  

# 开始部署  

由于 Apache bookkeeper(本文后续简称为BK)需要使用元数据服务中心,当前支持 Zookeeper 和 Etcd,本文将会分别介绍使用 zookeeper+bookkeeper 部署和 etcd+bookkeeper 的部署,值得注意的是本文介绍的都是单机部署而不是集群.  

会介绍三种部署方式:  

1. 单独部署 bookkeeper 和 zookeeper  
2. 单独部署 bookkeeper 和 etcd  
3. 部署一个嵌入式用于开发的本地 bookkeeper


## zookeeper+bookkeeper  

### 下载需要的软件包 

1. zookeeper/etcd  
2. bookkeeper 
     
下载命令可以用下面的两条命令分别下载以及解压 zookeeper 和 bookkeeper:  

```shell
wget https://dlcdn.apache.org/zookeeper/zookeeper-3.7.0/apache-zookeeper-3.7.0-bin.tar.gz  
tar -xvf apache-zookeeper-3.7.0-bin.tar.gz
```  

```shell
wget https://dlcdn.apache.org/bookkeeper/bookkeeper-4.14.0/bookkeeper-server-4.14.0-bin.tar.gz  
tar -xvf bookkeeper-server-4.14.0-bin.tar.gz
```


#### 启动zookeeper  

```shell
$ cd apache-zookeeper-3.7.0-bin
$ bin/zkServer.sh start conf/zoo_sample.cfg  
ZooKeeper JMX enabled by default
Using config: conf/zoo_sample.cfg
Starting zookeeper ... STARTED
```  
`logs目录`下会生成一个`zookeeper-{username}-server-{hostname}.out`这样格式的日志.我这里的日志名是`zookeeper-oem-server-lan.out`  

查看日志是否正常:   
```shell
$ tail -22f logs/zookeeper-oem-server-lan.out  
...
2021-12-26 21:41:41,749 [myid:] - INFO  [ProcessThread(sid:0 cport:2181)::PrepRequestProcessor@137] - PrepRequestProcessor (sid:0) started, reconfigEnabled=false
2021-12-26 21:41:41,750 [myid:] - INFO  [main:RequestThrottler@75] - zookeeper.request_throttler.shutdownTimeout = 10000
2021-12-26 21:41:41,759 [myid:] - INFO  [main:ContainerManager@84] - Using checkIntervalMs=60000 maxPerMinute=10000 maxNeverUsedIntervalMs=0
2021-12-26 21:41:41,759 [myid:] - INFO  [main:ZKAuditProvider@42] - ZooKeeper audit is disabled.

```  

日志一切正常,也可以看下端口号是否正常被进程占用了,如果确定 Zookkeeper 是启动正常的可以省略这部分:   
```shell  
$ lsof -i:2181
COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
java    24342  oem   58u  IPv6 173956      0t0  TCP *:2181 (LISTEN)

```  

端口查看也是正常的.部署 Zookeeper 的部分就完成了.

#### 启动bookkeeper  

执行`bin/bookkeeper bookie 1`来启动 Bookkeeper 发现报错了:  

```shell
2021-12-26 22:01:54,802 - INFO  - [main:BookieNettyServer@424] - Shutting down BookieNettyServer
2021-12-26 22:01:54,822 - ERROR - [main:Main@228] - Failed to build bookie server
org.apache.bookkeeper.bookie.BookieException$MetadataStoreException: Failed to get cluster instance id
	at org.apache.bookkeeper.discover.ZKRegistrationManager.getClusterInstanceId(ZKRegistrationManager.java:428)
```  

这是因为需要先初始化元数据,执行`bin/bookkeeper shell metaformat`:   

```shell
22:02:39,898 INFO  Socket connection established, initiating session, client: /192.168.3.123:46676, server: node123/192.168.3.123:2281
22:02:40,037 INFO  Session establishment complete on server node123/192.168.3.123:2281, sessionid = 0x100216aac630001, negotiated timeout = 16000
22:02:40,043 INFO  ZooKeeper client is connected now.
22:02:40,761 INFO  Successfully formatted BookKeeper metadata
22:02:40,892 INFO  Session: 0x100216aac630001 closed
22:02:40,892 INFO  EventThread shut down for session: 0x100216aac630001
```  

然后再次尝试启动 Bookkeeper 就可以启动成功了:  

执行:`bin/bookkeeper bookie 1`   

```shell
2021-12-26 22:04:01,472 - INFO  - [BookieJournal-3181:JournalChannel@157] - Opening journal /tmp/bk-txn-dev-bin/current/17df9d84aba.txn
2021-12-26 22:04:01,732 - INFO  - [BookKeeperClientScheduler-OrderedScheduler-0-0:NetworkTopologyImpl@426] - Adding a new node: /default-rack/192.168.3.123:3181
2021-12-26 22:04:02,014 - INFO  - [vert.x-eventloop-thread-0:VertxHttpServer$2@84] - Starting Vertx HTTP server on port 8081
2021-12-26 22:04:02,315 - INFO  - [main:VertxHttpServer@91] - Vertx Http server started successfully
2021-12-26 22:04:02,315 - INFO  - [main:ComponentStarter@86] - Started component bookie-server.
```

## localbookie方式部署  

这种方式主要是用于本地开发环境.

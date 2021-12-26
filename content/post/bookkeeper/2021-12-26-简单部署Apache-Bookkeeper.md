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
tags:
    - bookkeeper
    - zookeeper
categories: [ TECH ]
---    

# 前言  

# 开始部署  

由于apache bookkeeper(本文后续简称为BK)需要使用元数据服务中心,当前支持zookeeper和etcd,本文将会分别介绍使用zookeeper+bookkeeper部署和etcd+bookkeeper的部署,值得注意的是本文介绍的都是单机部署而不是集群.


## zookeeper+bookkeeper  

### 下载需要的软件包 

1. zookeeper/etcd  
2. bookkeeper 
     
下载命令可以用下面的两条命令分别下载以及解压zookeeper和bookkeeper:  
```
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
```log
$ tail -22f logs/zookeeper-oem-server-lan.out  
...
2021-12-26 21:41:41,749 [myid:] - INFO  [ProcessThread(sid:0 cport:2181)::PrepRequestProcessor@137] - PrepRequestProcessor (sid:0) started, reconfigEnabled=false
2021-12-26 21:41:41,750 [myid:] - INFO  [main:RequestThrottler@75] - zookeeper.request_throttler.shutdownTimeout = 10000
2021-12-26 21:41:41,759 [myid:] - INFO  [main:ContainerManager@84] - Using checkIntervalMs=60000 maxPerMinute=10000 maxNeverUsedIntervalMs=0
2021-12-26 21:41:41,759 [myid:] - INFO  [main:ZKAuditProvider@42] - ZooKeeper audit is disabled.

```  

日志一切正常,也可以看下端口号是否正常被进程占用了,如果确定ZK是启动正常的可以省略这部分:   
```shell  
$ lsof -i:2181
COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
java    24342  oem   58u  IPv6 173956      0t0  TCP *:2181 (LISTEN)

```  

端口查看也是正常的.部署zookeeper的部分就完成了.

#### 启动bookkeeper  


## zookeeper+etcd



# 注意  
本文还在持续创作当中
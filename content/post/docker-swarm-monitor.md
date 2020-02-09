---
layout:     post 
title:      "部署docker swarm集群监控"
subtitle:   ""
description: "docker swarm在容器编排的战争中已经输给了K8S，但是在小规模团队或人力有限的情况下，使用docker swarm进行容器编排还是不错的。"
date:       2020-02-09
author:     "lyp"
image: "https://res.cloudinary.com/lyp/image/upload/v1544363190/hugo/blog.github.io/19375a83fc004035fb1102a4551f2287.jpg"
published: true
tags:
    - Docker
    - Docker Swarm
categories: 
    - 容器
    - 容器编排
---

# 前提  
1. Docker  

## 前言  
现在Docker Swarm已经彻底输给了K8S,但是现在K8S依然很复杂，上手难度较Docker Swarm高，如果是小规模团队且需要容器编排的话，使用Docker Swarm还是适合的。  

目前Docker Swarm有一个问题一直没有解决，如果业务需要知道用户的请求IP,则Docker Swarm满足不了要求。目前部署在Docker Swarm内的服务,无法获取到用户的请求IP。  

具体可以看看这个ISSUE->[Unable to retrieve user's IP address in docker swarm mode](https://github.com/moby/moby/issues/25526)  

## 整体思路  
思路整体来说是使用Influxdb+Grafana+cadvisor,其中``cadvisor``负责数据的收集，每一台节点都部署一个cadvisor服务,Influxdb负责数据的存储,Grafana负责数据的可视化。  

## 演示环境  
主机 | IP
-|-
master(manager) | 192.168.1.60 
node1(worker) | 192.168.1.61 
node2(worker) | 192.168.1.62 

## 初始化Docker Swarm  

在master机器上初始化集群,运行  
``docker swarm init --advertise-addr {MASTER-IP}``
```
[root@master ~]# docker swarm init --advertise-addr 192.168.1.60

Swarm initialized: current node (138n5rwjz83y8goyzepp1cdo7) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-67je7chylnpyt0s4k1ee63rhxgh0qijiah9gadvcr7i6uab909-535nf6qu6v7b8dscc0plghr9j 192.168.1.60:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions

```

在node节点运行提示的命令加入到集群中  
``
docker swarm join --token SWMTKN-1-67je7chylnpyt0s4k1ee63rhxgh0qijiah9gadvcr7i6uab909-535nf6qu6v7b8dscc0plghr9j 192.168.1.60:2377
``  
manager节点初始化集群后，都会有这样一个提示，这个的命令只是给个示例，实际命令需要根据初始化集群后的真实情况来运行。

```
[root@node1 ~]#  docker swarm join --token SWMTKN-1-67je7chylnpyt0s4k1ee63rhxgh0qijiah9gadvcr7i6uab909-535nf6qu6v7b8dscc0plghr9j 192.168.1.60:2377
This node joined a swarm as a worker.
```
```
[root@node2 ~]#  docker swarm join --token SWMTKN-1-67je7chylnpyt0s4k1ee63rhxgh0qijiah9gadvcr7i6uab909-535nf6qu6v7b8dscc0plghr9j 192.168.1.60:2377
This node joined a swarm as a worker.
```

## 在master机器上查看当前的node节点  
``
docker node ls
``
```
[root@master ~]# docker node ls
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
138n5rwjz83y8goyzepp1cdo7 *   master              Ready               Active              Leader              18.09.8
q03by75rqur63lx36cmordf11     node1               Ready               Active                                  18.09.8
6shdf5ej4b5u7x877bg9nyjk3     node2               Ready               Active 
```
到目前为止集群已经搭建完成了，接下来开始部署服务  

## 在Docker Swarm部署监控服务  
 ``
 docker stack deploy -c docker-compose-monitor.yml monitor
 ``  

 ```
[root@master ~]# docker stack deploy -c docker-compose-monitor.yml monitor
Creating network monitor_default
Creating service monitor_influx
Creating service monitor_grafana
Creating service monitor_cadvisor
 ```  

 ``docker-compose-monitor.yml``文件内容  
 ```
 version: '3'
 
services:
  influx:
    image: influxdb
    volumes:
      - influx:/var/lib/influxdb
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager
 
  grafana:
    image: grafana/grafana
    ports:
      - 0.0.0.0:80:3000
    volumes:
      - grafana:/var/lib/grafana
    depends_on:
      - influx
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager
 
  cadvisor:
    image: google/cadvisor
    hostname: '{{.Node.Hostname}}'
    command: -logtostderr -docker_only -storage_driver=influxdb -storage_driver_db=cadvisor -storage_driver_host=influx:8086
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:rw
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    depends_on:
      - influx
    deploy:
      mode: global
 
volumes:
  influx:
    driver: local
  grafana:
    driver: local
 ```  
 [下载docker-compose-monitor.yml](https://res.cloudinary.com/lyp/raw/upload/v1581252602/hugo/blog.github.io/docker/docker-compose-monitor.yml)  


## 查看服务的部署情况  

``
docker service ls
``

```
[root@master ~]# docker service ls
ID                  NAME                MODE                REPLICAS            IMAGE                    PORTS
qth4tssf2sm1        monitor_cadvisor    global              3/3                 google/cadvisor:latest   
p2vbxe7ic175        monitor_grafana     replicated          1/1                 grafana/grafana:latest   *:80->3000/tcp
von1rpeqq7vj        monitor_influx      replicated          1/1                 influxdb:latest  
```  

到目前为止，服务已经部署完成了，三台机器各自部署一个``cadvisor``,在master节点部署了``grafana``和``influxdb``  

## 为cadvisor配置influxdb数据库  

查看一下master机器上的服务  
``
docker ps
``
```
[root@master ~]# docker ps
CONTAINER ID        IMAGE                    COMMAND                  CREATED             STATUS              PORTS               NAMES
55965fdf13a3        grafana/grafana:latest   "/run.sh"                3 hours ago         Up 3 hours          3000/tcp            monitor_grafana.1.l9uh0ov7ltk7q2yollmk4x1v9
0bf544c7d81c        google/cadvisor:latest   "/usr/bin/cadvisor -…"   3 hours ago         Up 3 hours          8080/tcp            monitor_cadvisor.138n5rwjz83y8goyzepp1cdo7.l53vufoivp0oe8tyy14nh0jof
3ce050f0483e        influxdb:latest          "/entrypoint.sh infl…"   3 hours ago         Up 3 hours          8086/tcp            monitor_influx.1.vraeh8ektium1j1jd27qvq1au
[root@master ~]# 
```  

可以看到是符合预期的，接下来进一步查看``cadvisor``容器的日志  
``
docker logs -f 0bf544c7d81c
``
```
[root@master ~]# docker logs -f 0bf544c7d81c
W0209 09:32:15.730951       1 manager.go:349] Could not configure a source for OOM detection, disabling OOM events: open /dev/kmsg: no such file or directory
E0209 09:33:15.783705       1 memory.go:94] failed to write stats to influxDb - {"error":"database not found: \"cadvisor\""}
E0209 09:34:15.818661       1 memory.go:94] failed to write stats to influxDb - {"error":"database not found: \"cadvisor\""}
E0209 09:35:16.009312       1 memory.go:94] failed to write stats to influxDb - {"error":"database not found: \"cadvisor\""}
E0209 09:36:16.027113       1 memory.go:94] failed to write stats to influxDb - {"error":"database not found: \"cadvisor\""}
E0209 09:37:16.107051       1 memory.go:94] failed to write stats to influxDb - {"error":"database not found: \"cadvisor\""}
E0209 09:38:16.215684       1 memory.go:94] failed to write stats to influxDb - {"error":"database not found: \"cadvisor\""}
E0209 09:39:16.305772       1 memory.go:94] failed to write stats to influxDb - {"error":"database not found: \"cadvisor\""}

```
可以看到现在一直是在报错的，因为目前的``influx``容器中没有``cadvisor``这样的数据库存在，接下来我们进入``influx``容器并创建对应的``cadvisor``数据库,在master机器上执行以下命令即可。

``
docker exec `docker ps | grep -i influx | awk '{print $1}'` influx -execute 'CREATE DATABASE cadvisor'
``  


当然，也可以分步骤执行
1. 找到influxdb的容器
2. 进入到influxdb容器内并登陆influx
3. 创建数据库  

这里就不演示了。  

## 配置grafana  

到目前为止，数据已经在收集了，并且数据存储在``influxdb``中。接下来配置grafana将数据进行可视化。  

因为docker-compose-monitor.yml文件内给grafna配置的端口是80,这里直接访问master机器的IP就可以访问到grafana,在浏览器打开``192.168.1.60``.  
grafana  
默认的帐号是``admin``  
默认的密码是``admin``  
首次登陆后会提示修改密码，新密码继续设置为``admin``也没关系。  

登陆成功后开始设置数据源  

### 配置数据源  

1. 打开左边菜单栏进入数据源配置页面
![](https://res.cloudinary.com/lyp/image/upload/v1581251657/hugo/blog.github.io/docker/config_source1.png)  
2. 添加新的数据源,我这里是添加过了,所以会有一个influxdb的数据源显示。  
![](https://res.cloudinary.com/lyp/image/upload/v1581251657/hugo/blog.github.io/docker/config_source2.png)  
3. 选择influxdb类型的数据源  
![](https://res.cloudinary.com/lyp/image/upload/v1581251656/hugo/blog.github.io/docker/config_source3.png)  
4. 填写influxdb对应的信息,Name填写``influx``,因为待会要用到一个grafana模版,所以这里叫influx名字,URL填``http://influx:8086``,这个也不是固定的,本次``docker-compose-monitor.yml``文件内``influxdb``的容器名叫``influx``,端口开放出来的为8086(``默认``),所以这里填``influx:8086``  
![](https://res.cloudinary.com/lyp/image/upload/v1581251945/hugo/blog.github.io/docker/config_source4.png)  

到目前为止，数据源相关的内容已经配置完成了。  

### 配置grafana视图模版  

这里使用模版只是为了演示效果，如果模版的样式不太满意，可以研究下grafana自行调整。  

1. 首先打开grafana的dashboard市场下载模版[https://grafana.com/grafana/dashboards/4637/reviews](https://grafana.com/grafana/dashboards/4637/reviews)  
![](https://res.cloudinary.com/lyp/image/upload/v1581252257/hugo/blog.github.io/docker/download_grafana_temp.png)  
2. 选中dashboard菜单,选中import进行导入
![](https://res.cloudinary.com/lyp/image/upload/v1581251657/hugo/blog.github.io/docker/import_dashboard.png)  
3. 打开dashboard就已经可以看到dashboard模版的内容了.  
![](https://res.cloudinary.com/lyp/image/upload/v1581251656/hugo/blog.github.io/docker/grafana_for_cadvisor.png)  

## 总结  
一个基本的Docker Swarm集群监控就搭建完成了  

还有更高级的也许后面会更新一篇blog进行讲述.例如当某个值(CPU)达到某个阀值，发送钉钉或者slack消息进行告警  

只要明白思路，实操基本上没有什么问题。
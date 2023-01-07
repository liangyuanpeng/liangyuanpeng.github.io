---
layout:     post 
slug:      "envoy-file-xds-with-reload-configmap"
title:      "将热更新configmap作为Envoy的XDS服务"
subtitle:   ""
description: ""
date:       2022-01-22
author:     "梁远鹏"
image: "img/post-bg-2015.jpg"
published: true
tags:
    - envoy 
    - cncf
    - kubernetes
    - xds
categories: [ kubernetes ]
---

# 

在使用 Envoy 的过程中时常会需要对接 XDS 用作流量的动态管理，那么如何以低成本的方式实现这个效果呢?  

ConfigMap 你值得拥有,本质上还是使用文件作为 Envoy 的 XDS 服务实现,只不过将文件的内容以 ConfigMap 管理起来了.  

原理也很简单,在 Envoy 容器旁启动一个 SideCar,这个 SideCar 的唯一作用就是监听到文件变化之后做一个`mv`的操作,触发Envoy来重新加载最新的XDS规则文件.  

这样就可以做到了动态的管理 Envoy 规则并且基本上没有上手难度.毕竟在 kubernetes 之上谁还不会操作一个 ConfigMap 呢?
 
实践的过程发现使用 inotify 监听文件时如果监听 modify 事件的话文件内容更新了,但是却没有触发监控事件,这是为什么呢?这与 configmap 将内容更新到 pod 中的机制有关.后续会有一篇文章来专门讲解一下这个原理.


另一个问题是配置文件通过 configmap 挂载到 pod 之后，是只读的，无法做修改，因此直接对挂载的配置文件做 `mv envoy.yaml envoy.yaml_bak && mv envoy.yaml_bak envoy.yaml` 是不可行的,本文的思路是用一个 initContainer 将 configmap 挂载的配置文件复制到另一个有读写权限的目录，然后后续每次 configmap 更新时都将文件复制到这个有读写权限的目录来做 mv 操作,进而最终达到让 Envoy 基于静态文件更新配置的效果.


envoy-deploy.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: envoy
  labels:
    app: envoy
spec:
  selector:
    matchLabels:
      app: envoy
  replicas: 1
  template:
    metadata:
      labels:
        app: envoy
    spec:
      volumes:
        - name: envoy-config
          configMap:
            name: envoy-configmap
        - name: configs
          emptyDir: {}
      initContainers:
        - name: busybox
          image: busybox:1.35.0
          volumeMounts:
            - name: configs
              mountPath: /tmp
            - name: envoy-config
              mountPath: /configs
          command: 
          - /bin/sh
          - -c 
          - cat /configs/cds.yaml > /tmp/cds.yaml && cat /configs/envoy.yaml > /tmp/envoy.yaml && cat /configs/inotify.sh >  /tmp/inotify.sh  && cat /configs/lds.yaml > /tmp/lds.yaml
      containers:
        - name: envoy
          image: envoyproxy/envoy-dev:latest
          imagePullPolicy: IfNotPresent
          volumeMounts:
            - name: configs
              mountPath: /tmp
          ports:
            - name: admin
              containerPort: 19000
          command: 
            - /bin/sh
            - -c
            - envoy -c /tmp/envoy.yaml
        - name: inotify
          image: twocows/inotifywait:0.1
          imagePullPolicy: IfNotPresent
          volumeMounts:
            - name: configs
              mountPath: /tmp
            - name: envoy-config
              mountPath: /configs
          command: 
            - /bin/sh
            - -c
            - sh /tmp/inotify.sh /configs
---
apiVersion: v1
kind: Service
metadata:
  name: envoy
  labels:
    app: envoy
spec:
  ports:
    - name: admin
      port: 19000
  type: ClusterIP
  selector:
    app: envoy
---
apiVersion: v1
kind: Service
metadata:
  name: envoynp
  labels:
    app: envoy
spec:
  ports:
    - port: 19000
      name: admin
      nodePort: 30060
  type: NodePort
  selector:
    app: envoy
```

envoy-configmap.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: envoy-configmap
data:
  envoy.yaml: |
    node:
      id: id_1
      cluster: test

    dynamic_resources:
      cds_config:
        path_config_source:
          path: /tmp/cds.yaml
      lds_config:
        path_config_source:
          path: /tmp/lds.yaml

    admin:
      address:
        socket_address:
          address: 0.0.0.0
          port_value: 19000
      
  cds.yaml: |
    resources:
    - "@type": type.googleapis.com/envoy.config.cluster.v3.Cluster
      name: example_proxy_cluster
      type: STRICT_DNS
      load_assignment:
        cluster_name: example_proxy_cluster
        endpoints:
        - lb_endpoints:
          - endpoint:
              address:
                socket_address:
                  address: service1
                  port_value: 8080

  lds.yaml: |
    resources:
    - "@type": type.googleapis.com/envoy.config.listener.v3.Listener
      name: listener_0
      address:
        socket_address:
          address: 0.0.0.0
          port_value: 10002
      filter_chains:
      - filters:
          name: envoy.filters.network.http_connection_manager
          typed_config:
            "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
            stat_prefix: ingress_http
            http_filters:
            - name: envoy.filters.http.router
              typed_config:
                "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
            route_config:
              name: local_route
              virtual_hosts:
              - name: local_service
                domains:
                - "*"
                routes:
                - match:
                    prefix: "/"
                  route:
                    cluster: example_proxy_cluster

  inotify.sh: |
    #!/bin/bash
    /usr/bin/inotifywait -mrq --format '%f' -e create,close_write,delete $1  | while read line
    do
        if [ -f $1/$line ];then
            echo $line
            cat $1/$line > /tmp/$line
            mv /tmp/$line /tmp/$line'_bak'
            mv /tmp/$line'_bak' /tmp/$line
        else
            echo "2"
        fi
    done
```

# 注意

本文还在持续创作中

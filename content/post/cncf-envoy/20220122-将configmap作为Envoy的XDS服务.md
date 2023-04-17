---
layout:     post 
slug:      "envoy-file-xds-with-reload-configmap"
title:      "将热更新configmap作为Envoy的XDS服务"
subtitle:   ""
description: ""
date:       2022-01-22
author:     "梁远鹏"
image: "img/banner-pexels.jpg"
published: true
tags:
    - envoy 
    - cncf
    - kubernetes
    - xds
categories: [ kubernetes ]
---

# 前言 

由于实验基于kubernetes,因此你首先需要有一个kubernetes环境,这里推荐使用 Kind 命令来搭建.见[用kind搭建k8s集群环境](https://liangyuanpeng.com/post/cncf-kubernetes/run-k8s-with-kind/)

## 前提
- kubernetes

# 为什么选择configmap

在使用 Envoy 的过程中时常会需要对接 XDS 用作流量的动态管理，那么如何以低成本的方式实现这个效果呢?  

ConfigMap 你值得拥有,本质上还是使用文件作为 Envoy 的 XDS 服务实现,只不过将文件的内容以 ConfigMap 管理起来了.

# 原理

原理也很简单,在 Envoy 容器旁启动一个 SideCar,这个 SideCar 的唯一作用就是监听到文件变化之后做一个`mv`的操作,触发Envoy来重新加载最新的 XDS 规则文件.

这样就可以做到了动态的管理 Envoy 规则并且基本上没有上手难度.毕竟在 kubernetes 之上谁还不会操作一个 ConfigMap 呢?
 
# 遇到的问题

## inotify 监听 modify 失败  

实践的过程发现使用 inotify 监听文件时如果监听 modify 事件的话文件内容更新了,但是却没有触发监控事件,这是为什么呢?这与 configmap 将内容更新到 pod 中的机制有关.后续会有一篇文章来专门讲解一下这个原理.

## configmap 挂载文件只读  

另一个问题是配置文件通过 configmap 挂载到 pod 之后，是只读的，无法做修改，因此直接对挂载的配置文件做 `mv envoy.yaml envoy.yaml_bak && mv envoy.yaml_bak envoy.yaml` 是不可行的,本文的思路是用一个 initContainer 将 configmap 挂载的配置文件复制到另一个有读写权限的目录，然后后续每次 configmap 更新时都将文件复制到这个有读写权限的目录来做 mv 操作,进而最终达到让 Envoy 基于静态文件更新配置的效果.


# 开始尝试!

我将所有内容都揉在了一个 yaml 内,因此如果你对此感到不适可以拆分成多个单独的 yaml 文件 :)

对于 service,我使用 NodePort 暴露,只是为了更方便的测试,通过 Envoy admin 接口查看修改的内容是否生效.  

开始部署 Envoy 到 kubernetes.

将下面展示的内容保存为 Envoy.yaml 并且执行命令应用:
```shell
kubectl apply -f envoy.yaml
```

或使用我整理好的在线文件:
```shell
kubectl apply -f https://liangyuanpeng.com/files/envoy-file-xds-with-reload-configmap/envoy.yaml
```

envoy.yaml
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
  revisionHistoryLimit: 5
  template:
    metadata:
      labels:
        app: envoy
    spec:
      volumes:
        - name: envoy-config
          configMap:
            name: envoy
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
          image: envoyproxy/envoy:v1.25.1
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
          resources:
            requests:
              memory: "10Mi"
              cpu: "10m"
            limits:
              memory: "512Mi"
              cpu: "800m"
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
      nodePort: 31900
  type: NodePort
  selector:
    app: envoy

---

apiVersion: v1
kind: ConfigMap
metadata:
  name: envoy
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
          port_value: 10001
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
            echo $1/$line
            cat $1/$line > /tmp/$line
            mv /tmp/$line /tmp/$line'_bak'
            mv /tmp/$line'_bak' /tmp/$line
        else
            echo "2"
        fi
    done
```

等待 Envoy pod 启动,运行起来后请求 Envoy admin 接口查看当前 Envoy 监听的端口号:
```shell
lan@lan:~$ curl -X GET http://localhost:31900/listeners?format=text
listener_0::0.0.0.0:10001
```

可以看到,当前 Envoy 监听 10001 端口号,这是 Envoy lds 的内容决定的,也就是上述 ConfigMap 内容中的:
```yaml

  lds.yaml: |
    resources:
    - "@type": type.googleapis.com/envoy.config.listener.v3.Listener
      name: listener_0
      address:
        socket_address:
          address: 0.0.0.0
          port_value: 10001
      ...
```

现在将 10001 修改为 10002,然后将更新应用到 kubernetes 当中:
```shell
kubectl apply -f envoy.yaml
```

如果你使用的是在线文件,那么直接使用 `kubectl edit configmap envoy` 来修改内容,保存后即可.这样就无需在本地操作文件.

使用命令 `kubectl logs -f {podname}` 查看 Envoy pod 的日志,等待一会后如果你也看到以下类似的日志,那么说明 Envoy xds(lds) 的内容更新已经动态修改成功了.

```shell
...
[2023-03-23 07:38:48.937][13][info][config] [source/extensions/listener_managers/listener_manager/listener_manager_impl.cc:858] all dependencies initialized. starting workers
[2023-03-23 07:40:06.556][13][info][upstream] [source/extensions/listener_managers/listener_manager/lds_api.cc:79] lds: add/update listener 'listener_0'
[2023-03-23 07:40:06.561][13][info][upstream] [source/common/upstream/cds_api_helper.cc:32] cds: add 1 cluster(s), remove 0 cluster(s)
[2023-03-23 07:40:06.561][13][info][upstream] [source/common/upstream/cds_api_helper.cc:69] cds: added/updated 0 cluster(s), skipped 1 unmodified cluster(s)
[2023-03-23 07:40:06.566][13][info][upstream] [source/common/upstream/cds_api_helper.cc:32] cds: add 1 cluster(s), remove 0 cluster(s)
[2023-03-23 07:40:06.566][13][info][upstream] [source/common/upstream/cds_api_helper.cc:69] cds: added/updated 0 cluster(s), skipped 1 unmodified cluster(s)
[2023-03-23 07:40:06.574][13][info][upstream] [source/common/upstream/cds_api_helper.cc:32] cds: add 1 cluster(s), remove 0 cluster(s)
[2023-03-23 07:40:06.574][13][info][upstream] [source/common/upstream/cds_api_helper.cc:69] cds: added/updated 0 cluster(s), skipped 1 unmodified cluster(s)
```

这时候再查看一下 Envoy listener 的内容:

```shell
lan@lan:~$ curl -X GET http://localhost:31900/listeners?format=text
listener_0::0.0.0.0:10002
```

可以看到 Envoy 监听的端口号从 10001 更新为了 10002,这里做的演示是一个更新操作,你也可以尝试做以下测试:

- 新增/删除操作 lds.yaml 内容
- 新增/修改/删除操作 cds.yaml 内容

对于 CDS 的内容,可以从 Envoy admin 接口中的 `/clusters` 中查看:

```shell
lan@lan:~$ curl -X GET http://localhost:31900/clusters
example_proxy_cluster::observability_name::example_proxy_cluster
example_proxy_cluster::default_priority::max_connections::1024
example_proxy_cluster::default_priority::max_pending_requests::1024
example_proxy_cluster::default_priority::max_requests::1024
example_proxy_cluster::default_priority::max_retries::3
example_proxy_cluster::high_priority::max_connections::1024
example_proxy_cluster::high_priority::max_pending_requests::1024
example_proxy_cluster::high_priority::max_requests::1024
example_proxy_cluster::high_priority::max_retries::3
example_proxy_cluster::added_via_api::true
```

# 总结

到目前为止,你已经拥有了一个基于 configmap 的 envoy xds,因此可以轻松的使用其他工具或程序来修改configmap,达到动态灵活的效果.如果你对这篇文章有任何疑问,欢迎和我进行交流.

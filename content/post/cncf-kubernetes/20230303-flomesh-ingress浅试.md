---
layout:     post 
slug:   "flomesh-ingress-quickstart"
title:      "flomesh-ingress浅试"
subtitle:   ""
description: ""  
date:       2023-03-03
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1543506262/hugo/blog.github.io/apache-rocketMQ-introduction/7046d2bf0d97278682129887309cc1a6.jpg"
published: true
tags: 
    - flomesh
    - fsm
    - kubernetes
categories: 
    - kubernetes
---

# 

# 前提  

在开始之前,你需要以下前提准备.

对于本文来说使用的 K8S 环境是基于 Kind 来搭建的,因此将 Kind 命令写在前提内,但是如果你使用了其他工具搭建 K8S 或已经有 K8S 集群了,那么这是非必须的.

- helm v3
- kubernetes 集群 
- Kind (用于搭建 K8S 环境,非必须)  

## 版本信息

本文基于以下环境信息

- kubernetes v1.26.0
- fsm helm chart fsm-0.2.3 

## Kind 配置文件

对于 Kind 的配置,这里贴出本文所使用的配置文件,同时也提供一个在线地址,因此你可以直接[下载配置文件](https://liangyuanpeng.com/files/kind/v1alpha4/kind.yaml)来使用.

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."gcr.io"]
    endpoint = ["https://gcr.lank8s.cn"]
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."k8s.gcr.io"]
    endpoint = ["https://k8s.lank8s.cn"]
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."registry.k8s.io"]
    endpoint = ["https://registry.lank8s.cn"]
```

# 部署  


## 部署fsm

首先使用 helm 安装 fsm:  

```shell
helm repo add fsm https://charts.flomesh.io
helm install fsm fsm/fsm --namespace flomesh --create-namespace
```

顺利的话可以看到 flomesh 这个 namespace 下所有的 pod 都运行起来了.

```shell
oem@lan:~$ k get po -n flomesh                                                                                                                                          
NAME                                READY   STATUS    RESTARTS   AGE
fsm-ingress-pipy-65958fd9d6-v46vl   1/1     Running   0          3h15m
fsm-manager-9c7665764-8wcvv         1/1     Running   0          3h15m
fsm-repo-89cb68547-kv94n            1/1     Running   0          3h15m
```

## 创建ingress


使用在线文件:
```shell
kubectl apply -f https://liangyuanpeng.com/files/flomesh-ingress-quickstart/ingress.yaml
```

使用下述文件,自行保存下述内容到文件中然后应用:
```shell
kubectl apply -f ingress.yaml
```

ingress.yaml
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: httpbin
  labels:
    app: httpbin
    controller: pipy
spec:
  ingressClassName: pipy
  rules:
    - host: lan.local
      http:
        paths:
          - path: /ip
            pathType: Exact
            backend:
              service:
                name: httpbin
                port:
                  number: 80
          - path: /
            pathType: Prefix
            backend:
              service:
                name: httpbin
                port:
                  number: 80
```

## 部署后端服务httpbin  

使用在线文件:
```shell
kubectl apply -f https://liangyuanpeng.com/files/exampleapp/httpbin.yaml
```

使用下述文件,自行保存下述内容到文件中然后应用:
```shell
kubectl apply -f httpbin.yaml
```

httpbin.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: httpbin
  name: httpbin
spec:
  replicas: 3
  selector:
    matchLabels:
      app: httpbin
  template:
    metadata:
      labels:
        app: httpbin
    spec:
      containers:
        - image: docker.io/kennethreitz/httpbin
          name: httpbin
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: httpbin
  name: httpbin
spec:
  ports:
    - port: 80
      protocol: TCP
      targetPort: 80
  selector:
    app: httpbin
  sessionAffinity: None
  type: ClusterIP
```

# 测试一下!

首先恭喜,你已经安装了 flomesh ingress controller 和 httpbin.

你可以检查一下目前所有 pod 是否都已经准备就绪了:

检查 httpbin 相关内容:
```shell
oem@lan:~$ kubectl get po,svc,ing -l app=httpbin
NAME                           READY   STATUS    RESTARTS      AGE
pod/httpbin-749b466b9c-5m54z   1/1     Running   0             7s
pod/httpbin-749b466b9c-7vgh6   1/1     Running   1 (73m ago)   10h
pod/httpbin-749b466b9c-86cgc   1/1     Running   0             7s

NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/httpbin   ClusterIP   10.96.201.220   <none>        80/TCP    11h

NAME                                CLASS   HOSTS       ADDRESS   PORTS   AGE
ingress.networking.k8s.io/httpbin   pipy    lan.local             80      11h
```

正常来说你会看到上述三个内容:
- 3 个准备就绪的 httpbin 的 pod
- 一个带有 80 端口号的 httpbin svc
- 一个匹配 lan.local 域名并且匹配端口号 80 的一个 ingress


检查 flomesh ingress 相关内容:
```shell
oem@lan:~$ kubectl get po -n flomesh
NAME                                READY   STATUS    RESTARTS      AGE
fsm-ingress-pipy-65958fd9d6-v46vl   1/1     Running   1 (75m ago)   14h
fsm-manager-9c7665764-8wcvv         1/1     Running   1 (75m ago)   14h
fsm-repo-89cb68547-kv94n            1/1     Running   1 (75m ago)   14h
```  

正常来说你会看到以下准备就绪的 pod (只检查了 pod 资源):
- fsm-ingress-pipy
- fsm-manager
- fsm-repo

接下来使用`kubectl port-forward` 来暴露流量进行测试:

```shell
kubectl -n flomesh port-forward service/fsm-ingress-pipy-controller 8888:80
```

来测试一下访问效果:

```shell
oem@lan:~$ curl -H "host: lan.local" localhost:8888/ip 
{
  "origin": "10.244.0.4"
}
oem@lan:~$ curl -H "host: lan.local" localhost:8888/headers
{
  "headers": {
    "Accept": "*/*", 
    "Connection": "keep-alive", 
    "Content-Length": "0", 
    "Host": "lan.local", 
    "User-Agent": "curl/7.81.0"
  }
}
```  

如果你也在使用上述示例命令后也能看到类似的结果,那么恭喜你已经成功部署了一个后端应用服务,创建了 ingress 并且基于 flomesh ingress controller 来将流量路由到了后端应用服务.

注意上述示例中为请求添加了 `host: lan.local` 的 header,与 ingress 中 host 设定的值是一致的,如果你希望使用其他值需要修改成一样的内容.


# 下一步

在2023年的今天, Gateway API 还处于一个 v1beta1 的版本,但是诸多的 ingress controller 都纷纷跟进,实现了 Gateway API,但是从[Gateway API官网](https://gateway-api.sigs.k8s.io/implementations/)看到 fsm 还不支持 Gateway API,显示的状态是 work in progress,意味着开发中,但目前不支持.  

期待 fsm 支持 Gateway API 的那一天,然后就可以进行下一步:基于 Gateway API 尝试 FSM 流量管理.
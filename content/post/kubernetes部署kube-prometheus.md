---
layout:     post 
slug:      "kubernetes-deploy-kube-prometheus"
title:      "kubernetes部署kube-prometheus"
subtitle:   ""
description: " "
date:       2021-04-06
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612709780/hugo/blog.github.io/pexels-matt-hardy-2568001.jpg"
published: true
tags:
    - kubernetes
    - cloudnative
    - k8s
    - kubeprometheus
    - prometheus
categories: 
    - kubernetes
---  

# 如何部署kube-prometheus  
本文使用[https://github.com/prometheus-operator/kube-prometheus](https://github.com/prometheus-operator/kube-prometheus)进行部署kube-prometheus  

部署的prometheus版本为`2.25.0`  

# 开始部署kube-prometheus

## 下载仓库  

```shell
git clone https://github.com.cnpmjs.org/prometheus-operator/kube-prometheus.git
```  

## 部署CRD  

```shell
cd kube-prometheus
kubectl create -f manifests/setup
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
kubectl create -f manifests/
```  

## 观察部署情况  
```shell
$ watch kubectl get po -n monitoring
NAME                                   READY   STATUS              RESTARTS   AGE
alertmanager-main-0                    0/2     ContainerCreating   0          33s
alertmanager-main-1                    0/2     ContainerCreating   0          33s
alertmanager-main-2                    0/2     ContainerCreating   0          33s
blackbox-exporter-56bc9d4987-qswrj     3/3     Running             0          44s
grafana-c7b7b49b7-kl5c7                0/1     Running             0          37s
kube-state-metrics-79b955f5d6-kwwl6    0/3     ContainerCreating   0          35s
node-exporter-pwkzt                    2/2     Running             0          32s
node-exporter-x9vt9                    2/2     Running             0          31s
prometheus-adapter-85797fb6c8-27qsd    0/1     ContainerCreating   0          22s
prometheus-k8s-0                       0/2     ContainerCreating   0          16s
prometheus-k8s-1                       0/2     ContainerCreating   0          16s
prometheus-operator-5c4b65f789-mgzpn   2/2     Running             0          49s
```  

可以看到等一会后所有pod就部署完成了.  

# 简单体验部署后的效果

## 查看prometheus前端页面  

```shell
kubectl --namespace monitoring port-forward svc/prometheus-k8s 9090 --address 0.0.0.0
```    

然后在页面打开`http://宿主IP:9090` 进入到prometheus页面  
![prometheus](https://res.cloudinary.com/lyp/image/upload/v1617766065/hugo/blog.github.io/prometheus/prometheus.png)

## 查看Grafana页面  
```shell
kubectl --namespace monitoring port-forward svc/grafana 3000 --address 0.0.0.0
```  
在页面打开`http://宿主IP:3000` 进入到grafana页面  
![grafana](https://res.cloudinary.com/lyp/image/upload/v1617766066/hugo/blog.github.io/prometheus/grafana.png)

## 查看AlertManager  
```shell
kubectl --namespace monitoring port-forward svc/alertmanager-main 9093 --address 0.0.0.0
```  

在页面打开`http://宿主IP:9093` 进入到alertmanager页面  
![grafana](https://res.cloudinary.com/lyp/image/upload/v1617766065/hugo/blog.github.io/prometheus/alertmanager.png)

# 自定义修改kube-prometheus参数  

本文使用yaml文件的方式部署,所以修改参数都可以在yaml文件中进行修改.  

默认kube-prometheus存储数据是24h并且没有持久化,如果pod重启了数据就没有了.  

这里演示一下修改存储的时间:  
```shell
vim manifests/prometheus-prometheus.yaml
```  
在spec下加上`retention: 2w`就可以将数据存储为两周.  

同时下面的示例也加了一个prometheus远程写请求的配置,将数据写到支持prometheus远程写API的一个地址.

```yaml
spec:
  retention: 2w
  remoteWrite:
    - name: remotexx
      url: http://xxx/api/v1/write
```  

如果需要将数据持久化可以使用storageClass,一般我是习惯使用longhorn,以下面伪配置为例:  
```yaml
spec:
  storage:
    volumeClaimTemplate:
      spec:
        storageClassName: longhorn
```  

上述数据持久化配置可能不完整,仅供参考.

# 总结  

总的来说kube-prometheus需要注意的问题是,默认存储24h并且没有持久化,千万记得修改这部分配置,否则可能会引发数据丢失问题.  

本文的部署步骤基本上就是按照官方文档操作了一遍,注意:随着时间的推移和kube-prometheus的演进,按照本文使用最新版本部署可能会出现部署失败的问题,归根结底是因为kube-prometheus最新版本部署内容或步骤发生了一些变化,因此建议首先阅读官方文档.  

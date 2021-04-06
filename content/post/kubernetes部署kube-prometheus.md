---
layout:     post 
slug:      "kubernetes-deploy-kube-prometheus"
title:      "kubernetes部署kube-prometheus"
subtitle:   ""
description: " "
date:       2021-04-06
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612709780/hugo/blog.github.io/pexels-matt-hardy-2568001.jpg"
published: false
tags:
    - kubernetes
    - cloudnative
    - k8s
    - kubeprometheus
    - prometheus
categories: 
    - kubernetes
---  

# 什么是kube-prometheus  
本文使用[https://github.com/prometheus-operator/kube-prometheus](https://github.com/prometheus-operator/kube-prometheus)进行部署kube-prometheus

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
watch kubectl get po -n monitoring
```  

可以看到等一会后所有pod就部署完成了.  

# 简单体验部署后的效果

## 查看prometheus前端页面  

```shell
kubectl --namespace monitoring port-forward svc/prometheus-k8s 9090
```  

## 查看Grafana页面  
```shell
kubectl --namespace monitoring port-forward svc/grafana 3000
```

## 查看AlertManager  
```shell
kubectl --namespace monitoring port-forward svc/alertmanager-main 9093
```  

# 自定义修改kube-prometheus参数  

本文使用yaml文件的方式部署,所以修改参数都可以在yaml文件中进行修改.

# 注意 本文还处于创作阶段,将会尽快完善
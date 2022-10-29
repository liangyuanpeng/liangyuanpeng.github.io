---
layout:     post 
slug:      "k8s-cd-argo-deploy"
title:      "k8s部署云原生CD引擎Argo"
subtitle:   ""
description: ""
date:       2022-01-20
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612744351/hugo/blog.github.io/pexels-bruno-cervera-6032877.jpg"
published: true
tags:
    - argo
    - cncf
    - kubernetes
    - argocd
    - CI/CD
categories: 
    - kubernetes
---    

# 

# 部署Argo CD

## 安装Argo CD

```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```  

如果下载访问有问题可以改一下地址,是我个人学习使用的一个代理github文件的下载地址.将`raw.githubusercontent.com`修改为`raw.lank8s.cn`就可以了.  

```shell
kubectl apply -n argocd -f https://raw.lank8s.cn/argoproj/argo-cd/stable/manifests/install.yaml
```

## 下载ArgoCD命令行  

```shell
wget https://github.com/argoproj/argo-cd/releases/download/v2.2.3/argocd-linux-amd64
mv argocd-linux-amd64 argocd
chmod +x argocd
mv argocd-linux-amd64 /usr/local/bin
```  

## 访问Argo CD的页面

### 使用Load Balancer类型的service访问  

需要把argocd-server这个service修改为LoadBalancer类型:  
```shell
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```  

### 使用ingress来访问  

这里我推荐使用Contour  

### 使用kubectl直接转发端口号  
```shell
kubectl port-forward svc/argocd-server -n argocd 8080:443
```  

# 通过CLI修改默认密码  

初始密码是自动生成的,可以用下面的命令查看初始密码是什么:   
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
 
使用`admin`账号和上面的密码登陆ArgoCD server:   
```
argocd login <ARGOCD_SERVER>
``` 

修改密码:   
```
argocd account update-password
```

# 创建一个Application  

首先从上面三种方式中选择一种来暴露service,本文使用的是kubectl转发的方式.  

访问IP:PORT
 
https://victoriametrics.github.io/helm-charts/



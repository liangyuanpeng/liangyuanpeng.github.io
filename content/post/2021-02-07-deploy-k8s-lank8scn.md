---
layout:     post 
title:      "kubeadm配合短域名lank8s.cn部署kubernetes"
subtitle:   ""
description: "本文主要使用kubeadm快速部署一个单机的kubernetes,其中镜像仓库使用lank8s.cn,当然也可以使用其他地址,lank8s.cn主要优势是短域名,好记. "
date:       2021-02-07
author:     "lyp"
image: "https://res.cloudinary.com/lyp/image/upload/v1612709640/hugo/blog.github.io/pexels-taryn-elliott-4909166.jpg"
published: true
tags:
    - kubernetes
    - 云原生
    - lank8s.cn
    - kubeadm
categories: 
    - kubernetes
---

# 本文实现目标 

本文主要使用kubeadm快速部署一个单机的kubernetes,其中镜像仓库使用lank8s.cn,当然也可以使用其他地址,lank8s.cn主要优势是短域名,好记.  

# 前提  

本文内容不包括讲述docker安装,因此需要自行先安装好docker。  

# 安装kubectl、kubelet、kubeadm  

1. 添加国内源 

```
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
```

2. 配置安装的kubernetes版本,本文使用v1.18.6 

```
export KUBE_VERSION=1.18.6 
```  

3. 开始安装  

```
yum install -y kubectl-${KUBE_VERSION} kubelet-${KUBE_VERSION} kubeadm-${KUBE_VERSION}

```  

# 开始部署kubernetes

1. 关闭swap
todo

2. 开始kubeadm安装kubernetes  

```
kubeadm init --kubernetes-version=v1.18.6 --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/12 --image-repository=lank8s.cn
```  

通过`--image-repository`指定镜像的地址就可以达到不需要翻墙的    效果(默认镜像需要拉取谷歌镜像仓库的地址,需要翻墙).  

顺利的话就可以看到部署成功的信息:  
```
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.3.239:6443 --token 9ptsuq.tfgal9ly5j268dr5 \
    --discovery-token-ca-cert-hash sha256:9eca63e1388d1fdf7cea63fc58bc8232bf26322e2094ea276f67f53057e54d9c
```  

复制提示中的三行命令,分别执行：  

```
mkdir -p $HOME/.kube  
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```  

3. 查看一下当前pod的情况,正常的话只有两个coredns的pod处于pending的状态,其他pod处于running状态.  

```
[root@installk8s ~]# kubectl get po -A
NAMESPACE     NAME                                 READY   STATUS    RESTARTS   AGE
kube-system   coredns-5c579bbb7b-6gm9j             0/1     Pending   0          71s
kube-system   coredns-5c579bbb7b-r4wk5             0/1     Pending   0          71s
kube-system   etcd-installk8s                      1/1     Running   0          80s
kube-system   kube-apiserver-installk8s            1/1     Running   0          80s
kube-system   kube-controller-manager-installk8s   1/1     Running   0          80s
kube-system   kube-proxy-tkmc7                     1/1     Running   0          72s
kube-system   kube-scheduler-installk8s            1/1     Running   0          81s
```  

这是因为CNI插件需要另外部署,本文使用kube-flannel,部署文件可以从kube-flannel的官方github仓库下载,不过可能会由于版本问题引起的冲突,这里推荐使用与本文一致的[kube-flannel文件](https://res.cloudinary.com/lyp/raw/upload/v1612710643/hugo/blog.github.io/kubernetes/kube-flannel.yml).  

4. 部署kube-flannel  

```kubectl apply -f kube-flannel.yml```

可以用watch命令查看pod的动态部署情况  
```
watch kubectl get po -A
```  

5.  

# kubernetes hell world!  

部署一个两个实例的nginx服务
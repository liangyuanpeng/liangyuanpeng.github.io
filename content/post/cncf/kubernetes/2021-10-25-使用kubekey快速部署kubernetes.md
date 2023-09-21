---
layout:     post 
slug:      "deploy-kubernetes-with-kubekey"
title:      "使用kubekey快速部署kubernetes"
subtitle:   ""
description: "使用kubekey快速部署kubernetes."
date:       2021-10-25
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags:
    - tech
    - kubernetes
    - golang
    - kubekey
categories: [ kubernetes ]
---

# 前言  

Kubekey 是青云研发并开源的一款快速部署 kubernetes 的工具,并且它也是下一代安装kubesphere的工具,使用 kubekey 你可以很轻松的就部署一套 kubernetes/kubespher 环境,我的体验是简直不要太简单了!

本文主要讲述的内容是用 kubekey 快速部署 kubernets 单节点,多节点部署的文章会在下一篇出现,敬请期待吧.

# 编写部署配置文件走起  

首先用 kk 命令创建一个默认的配置文件:  

```shell
[root@lan1 temp]# kk create config
[root@lan1 temp]# ls
config-sample.yaml
[root@lan1 temp]# cat config-sample.yaml 
apiVersion: kubekey.kubesphere.io/v1alpha1
kind: Cluster
metadata:
  name: sample
spec:
  hosts:
  - {name: kk1, address: 172.16.0.2, internalAddress: 172.16.0.2, user: ubuntu, password: Qcloud@123}
    etcd:
    - node1
    master: 
    - node1
    worker:
    - node1
  controlPlaneEndpoint:
    ##Internal loadbalancer for apiservers 
    #internalLoadbalancer: haproxy

    domain: lb.kubesphere.local
    address: ""
    port: 6443
  kubernetes:
    version: v1.19.8
    clusterName: cluster.local
  network:
    plugin: calico
    kubePodsCIDR: 10.233.64.0/18
    kubeServiceCIDR: 10.233.0.0/18
  registry:
    registryMirrors: []
    insecureRegistries: []
  addons: []
```  

修改其中的节点相关信息为自己实际的节点信息,可以看一我修改后我的配置文件:
```shell
[root@lan1 ~]# cat config-sample.yaml 
apiVersion: kubekey.kubesphere.io/v1alpha1
kind: Cluster
metadata:
  name: lan
spec:
  hosts:
  - {name: kk1, address: 192.168.3.152, internalAddress: 10.0.2.11, user: root, password: 123,port: 111}
  roleGroups:
    etcd:
    - kk1
    master: 
    - kk1
    worker:
    - kk1
  controlPlaneEndpoint:

    domain: lb.kubesphere.local
    address: ""
    port: 6443
  kubernetes:
    version: v1.19.8
    clusterName: cluster.local
  network:
    plugin: calico
    kubePodsCIDR: 10.233.64.0/18
    kubeServiceCIDR: 10.233.0.0/18
  registry:
    registryMirrors: []
    insecureRegistries: []
```  

我部署的是 1.19.8 版本的 kubernetes,CNI 使用的是 kubekey 默认的 calico.  

# 开始部署  

在部署前设置一下环境变量:  

```shell
export KKZONE=cn
```  

因为默认情况下 kk 是去 Github 上下载二进制文件(kubectl/kubelet/kubeadm...)以及去 dockerhub 下载容器镜像,设置了上面这个环境变量之后呢下载二进制文件就会去青云下载二进制文件以及去阿里镜像仓库下载需要的镜像,在网络方面的使用国内的东西很是很有必要的.  

接下来开始部署:  

```shell
[root@lan1 tmp]# kk create cluster -f config-sample.yaml -y
INFO[11:40:08 EDT] Downloading Installation Files               
INFO[11:40:08 EDT] Downloading kubeadm ...                      
INFO[11:40:10 EDT] Downloading kubelet ...                      
INFO[11:40:11 EDT] Downloading kubectl ...                      
INFO[11:40:11 EDT] Downloading helm ...                         
INFO[11:40:11 EDT] Downloading kubecni ...                      
INFO[11:40:12 EDT] Downloading etcd ...                         
INFO[11:40:12 EDT] Downloading docker ...                       
INFO[11:40:12 EDT] Downloading crictl ...                       
INFO[11:40:12 EDT] Configuring operating system ...             
[kk0 192.168.3.152] MSG:
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-arptables = 1
...
INFO[11:40:24 EDT] Installing Container Runtime ...             
INFO[11:40:26 EDT] Start to download images on all nodes        
[kk2] Downloading image: registry.cn-beijing.aliyuncs.com/kubesphereio/pause:3.2
[kk0] Downloading image: registry.cn-beijing.aliyuncs.com/kubesphereio/pause:3.2
[kk2] Downloading image: registry.cn-beijing.aliyuncs.com/kubesphereio/kube-proxy:v1.19.8
[kk0] Downloading image: registry.cn-beijing.aliyuncs.com/kubesphereio/kube-apiserver:v1.19.8
...
INFO[11:42:41 EDT] Creating etcd service                        
Push /root/repo/git/tmp/kubekey/v1.19.8/amd64/etcd-v3.4.13-linux-amd64.tar.gz to 192.168.3.152:/tmp/kubekey/etcd-v3.4.13-linux-amd64.tar.gz   Done
INFO[11:42:45 EDT] Starting etcd cluster   
...
```  

kubekey 就会完成安装 docker/containerd,所有需要的二进制文件并且开始用 kubeadm 部署 kubernetes,一键部署简直不要太舒服了!  

接下来只需要耐心等待就可以了.  

# 部署完成,检查pod情况  

当你看到的时候已经成功部署完了,看一下 Pod 的情况:  

```shell
[root@kk1 ~]# kubectl get po -A
NAMESPACE     NAME                                      READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-d75c96f46-dqq4z   1/1     Running   0          37m
kube-system   calico-node-hkpq9                         1/1     Running   0          37m
kube-system   coredns-867b49865c-qtjrz                  1/1     Running   0          37m
kube-system   coredns-867b49865c-vmsgs                  1/1     Running   0          37m
kube-system   kube-apiserver-kk1                        1/1     Running   0          37m
kube-system   kube-controller-manager-kk1               1/1     Running   0          37m
kube-system   kube-proxy-x7722                          1/1     Running   0          37m
kube-system   kube-scheduler-kk1                        1/1     Running   0          37m
kube-system   nodelocaldns-8hh5d                        1/1     Running   0          37m
```  

可以看到,所有 Pod 都正常运行了,可以愉快的用 kubernetes 了.

# 注意点

1. `internalAddress`需要填绑定网卡的 IP 地址,etcd 会用到这个地址,否则在部署 etcd 的时候会失败.  

2. 记得设置环境变量`KKZONE=cn`,否则在下载二进制文件的时候可能会非常慢!  

3. 不要太快享受,要慢慢享受.

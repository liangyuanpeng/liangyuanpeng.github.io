---
layout:     post 
title:      "搭建Kubernetes v1.17.4"
subtitle:   ""
description: "由于logstash内存占用较大,灵活性相对没那么好,ELK正在被EFK逐步替代."  
date:       2020-03-31
author:     "lan"
image: "https://res.cloudinary.com/lyp/image/upload/v1581932131/hugo/blog.github.io/you-got-this-lighted-signage-2740954.jpg"
published: false
tags: 
    - docker
    - cadvisor
    - kafka
    - fluentd
    - elasticsearch
categories: 
    - 中间件
---


# 前言  
由于logstash内存占用较大,灵活性相对没那么好,ELK正在被EFK逐步替代.其中本文所讲的EFK是Elasticsearch+Fluentd+Kfka,实际上K应该是Kibana用于日志的展示,这一块不做演示,本文只讲述数据的采集流程.  

# 前提

1. [docker](https://www.docker.com/get-started)  


# 配置国内源  

```
oem@oem-VirtualBox:~$ sudo cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF
```

添加安装源密钥
```
oem@oem-VirtualBox:~$ gpg --keyserver keyserver.ubuntu.com --recv-keys BA07F4FB
gpg: keybox '/home/oem/.gnupg/pubring.kbx' created

gpg: /home/oem/.gnupg/trustdb.gpg: trustdb created
gpg: key 6A030B21BA07F4FB: public key "Google Cloud Packages Automatic Signing Key <gc-team@google.com>" imported
gpg: Total number processed: 1
gpg:               imported: 1
oem@oem-VirtualBox:~$ 
oem@oem-VirtualBox:~$ gpg --export --armor BA07F4FB | sudo apt-key add -
OK
oem@oem-VirtualBox:~$ 
```  

# 安装基础

oem@oem-VirtualBox:~$ export KUBELET_VERSION=1.17.4-00
oem@oem-VirtualBox:~$ apt install -y kubelet=${KUBELET_VERSION} kubeadm=${KUBELET_VERSION} kubectl=${KUBELET_VERSION}
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following NEW packages will be installed:
  kubeadm kubectl kubelet
0 upgraded, 3 newly installed, 0 to remove and 273 not upgraded.
Need to get 36.0 MB of archives.
After this operation, 195 MB of additional disk space will be used.
Get:1 https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial/main amd64 kubelet amd64 1.17.4-00 [19.2 MB]
Get:2 https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial/main amd64 kubectl amd64 1.17.4-00 [8,741 kB]
Get:3 https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial/main amd64 kubeadm amd64 1.17.4-00 [8,064 kB]
Fetched 36.0 MB in 4s (10.0 MB/s)    
Selecting previously unselected package kubelet.
(Reading database ... 251239 files and directories currently installed.)
Preparing to unpack .../kubelet_1.17.4-00_amd64.deb ...
Unpacking kubelet (1.17.4-00) ...
Selecting previously unselected package kubectl.
Preparing to unpack .../kubectl_1.17.4-00_amd64.deb ...
Unpacking kubectl (1.17.4-00) ...
Selecting previously unselected package kubeadm.
Preparing to unpack .../kubeadm_1.17.4-00_amd64.deb ...
Unpacking kubeadm (1.17.4-00) ...
Setting up kubelet (1.17.4-00) ...
Setting up kubectl (1.17.4-00) ...
Setting up kubeadm (1.17.4-00) ...

验证安装后
```
oem@oem-VirtualBox:~$ kubelet --version
Kubernetes v1.17.4
```

设置软件不随着系统更新而更新
```
apt-mark hold kubelet kubeadm kubectl
 systemctl enable kubelet
```

# 开始初始化k8s

```
oem@oem-VirtualBox:~$ sudo kubeadm init --kubernetes-version=v1.17.4 --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/12 --ignore-preflight-errors=Swap --image-repository=lank8s.cn
W0331 23:18:32.323549   30891 validation.go:28] Cannot validate kube-proxy config - no validator is available
W0331 23:18:32.324086   30891 validation.go:28] Cannot validate kubelet config - no validator is available
[init] Using Kubernetes version: v1.17.4
[preflight] Running pre-flight checks
        [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
        [WARNING Swap]: running with swap on is not supported. Please disable swap
error execution phase preflight: [preflight] Some fatal errors occurred:
        [ERROR NumCPU]: the number of available CPUs 1 is less than the required 2
[preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
To see the stack trace of this error execute with --v=5 or higher
```

需要关闭swap
```
sudo swapoff -a
```

---我没禁用---
禁用Selinux
apt install selinux-utils
setenforce 0

然后就安装成功了
```
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
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

kubeadm join 192.168.3.178:6443 --token 3f58kb.dn3bqe9a2agke88m \
    --discovery-token-ca-cert-hash sha256:43ebed910da919cef79c41a7d83dcc93743172649de3105c2246bc9453c1f63e 
```

按照指引执行命令
```
To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

查看一下目前的状态
```
oem@oem-VirtualBox:~$ kubectl get pods -n kube-system 
NAME                                     READY   STATUS    RESTARTS   AGE
coredns-5f95894dcf-2srtl                 0/1     Pending   0          67s
coredns-5f95894dcf-56njs                 0/1     Pending   0          67s
etcd-oem-virtualbox                      1/1     Running   0          79s
kube-apiserver-oem-virtualbox            1/1     Running   0          79s
kube-controller-manager-oem-virtualbox   1/1     Running   0          79s
kube-proxy-6qpv9                         1/1     Running   0          67s
kube-scheduler-oem-virtualbox            1/1     Running   0          79s
```

可以看到coredns没有启动 需要应用CNI插件

```
oem@oem-VirtualBox:~$ kubectl apply -f kube-flannel-v0.11.0-amd64.yml 
podsecuritypolicy.policy/psp.flannel.unprivileged created
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.apps/kube-flannel-ds-amd64 created
daemonset.apps/kube-flannel-ds-arm64 created
daemonset.apps/kube-flannel-ds-arm created
daemonset.apps/kube-flannel-ds-ppc64le created
daemonset.apps/kube-flannel-ds-s390x created
```

```
oem@oem-VirtualBox:~$ kubectl get pods -n kube-system 
NAME                                     READY   STATUS     RESTARTS   AGE
coredns-5f95894dcf-2srtl                 0/1     Pending    0          4m30s
coredns-5f95894dcf-56njs                 0/1     Pending    0          4m30s
etcd-oem-virtualbox                      1/1     Running    0          4m42s
kube-apiserver-oem-virtualbox            1/1     Running    0          4m42s
kube-controller-manager-oem-virtualbox   1/1     Running    0          4m42s
kube-flannel-ds-amd64-9brv9              0/1     Init:0/1   0          2m48s
kube-proxy-6qpv9                         1/1     Running    0          4m30s
kube-scheduler-oem-virtualbox            1/1     Running    0          4m42s
```

需要quay.io的镜像 要梯子
配置文件 quay.io	改成 lank8s.cn  继续拉取

等一会再次查看 已经全部pod都启动完成了
```
oem@oem-VirtualBox:~$ kubectl get pods -n kube-system  
NAME                                     READY   STATUS    RESTARTS   AGE
coredns-5f95894dcf-2srtl                 1/1     Running   0          14m
coredns-5f95894dcf-56njs                 1/1     Running   0          14m
etcd-oem-virtualbox                      1/1     Running   0          14m
kube-apiserver-oem-virtualbox            1/1     Running   0          14m
kube-controller-manager-oem-virtualbox   1/1     Running   0          14m
kube-flannel-ds-amd64-ndd4m              1/1     Running   0          7m52s
kube-proxy-6qpv9                         1/1     Running   0          14m
kube-scheduler-oem-virtualbox            1/1     Running   0          14m
```

至此 K8S 搭建完成
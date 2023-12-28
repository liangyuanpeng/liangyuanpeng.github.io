---
layout:     post 
slug:      "kubeadm-deploy-kubernetes-lank8scn"
title:      "kubeadm配合短域名lank8s.cn部署kubernetes"
subtitle:   ""
description: "本文主要使用kubeadm快速部署一个单机的kubernetes,其中镜像仓库使用lank8s.cn,当然也可以使用其他地址,lank8s.cn主要优势是短域名,好记. "
date:       2021-02-07
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags:
    - kubernetes
    - CloudNative
    - lank8s.cn
    - kubeadm
    - cncf
categories: 
    - kubernetes
---

# 本文实现目标 

本文主要使用 kubeadm 快速部署一个单机的 kubernetes,其中镜像仓库使用 lank8s.cn,当然也可以使用其他地址, lank8s.cn 主要优势是短域名,好记.  

# 前提  

本文内容不包括讲述 docker 安装,因此需要自行先安装好 docker。  

# 安装kubectl、kubelet、kubeadm  

1. 添加国内源 

```shell
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

2. 配置安装的 kubernetes 版本,本文使用 v1.18.6 

```shell
export KUBE_VERSION=1.18.6 
```  

3. 开始安装  

```shell
yum install -y kubectl-${KUBE_VERSION} kubelet-${KUBE_VERSION} kubeadm-${KUBE_VERSION}

```  

# 开始部署kubernetes

1. 关闭swap
todo

2. 开始 kubeadm 安装 kubernetes  

```shell
kubeadm init --kubernetes-version=v1.18.6 --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/12 --image-repository=lank8s.cn
```  

通过`--image-repository`指定镜像的地址就可以达到不需要翻墙的    效果(默认镜像需要拉取谷歌镜像仓库的地址,需要翻墙).  

顺利的话就可以看到部署成功的信息:  
```shell
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

```shell
mkdir -p $HOME/.kube  
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```  

3. 查看一下当前 pod 的情况,正常的话只有两个 coredns 的 pod 处于 pending 的状态,其他pod处于 running 状态.  

```shell
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

这是因为 CNI 插件需要另外部署,本文使用 kube-flannel,部署文件可以从 kube-flannel 的官方 github 仓库下载,不过可能会由于版本问题引起的冲突,这里推荐使用与本文一致的[kube-flannel文件](https://res.cloudinary.com/lyp/raw/upload/v1612710643/hugo/blog.github.io/kubernetes/kube-flannel.yml).  

4. 部署kube-flannel  

```shell  

kubectl apply -f kube-flannel.yml  

```  

可以用 watch 命令查看 pod 的动态部署情况  
```  
watch kubectl get po -A
```    

过一会就全部运行起来了. 

# kubernetes hell world!  

## 注意  

此时只有一个 master 节点,master 节点默认是有污点的(无法部署服务),如果希望在 master 节点部署服务的话需要给 master 节点去除污点:  

首先用`kubectl get node`查看你的 node 名,然后用`kubectl taint node {NODENAME} node-role.kubernetes.io/master-`给对应节点去除 master 污点.  

##  部署一个nginx服务  

nginx-deployment.yaml:   

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: nginx
spec:
    replicas: 1
    selector:
        matchLabels:
          app: nginx
    template:
        metadata:
            labels:
                app: nginx
        spec:
            containers:
            - name: nginx
              image: nginx:1.21.3
              imagePullPolicy: IfNotPresent
              ports:
                - containerPort: 80
              resources:
                requests:
                    memory: "256Mi"
                    cpu: "100m"
                limits:
                    memory: "512Mi"
                    cpu: "800m"
```  

nginx-svc.yaml:  
```yaml
apiVersion: v1
kind: Service
metadata:
    name: nginx
spec:
    selector:
        app: nginx
    type: NodePort
    ports:
        - name: http
          protocol: TCP
          port: 80
          targetPort: 80
```  

执行命令应用:  
```shell
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-svc.yaml
```  

使用`kubectl get pod`和`kubectl get svc`就可以分别看到对应的 pod 和 service 运行起来了.  

service 使用的是 NodePort 类型,因此这暴露了一个宿主机端口号来访问 Nginx 服务,我这里显示的端口号是 30460,因此我通过这个端口来访问 Nginx:  
```shell
...
nginx                           NodePort    10.97.211.40    <none>        80:30460/TCP
...
```  

可以通过浏览器访问`IP:30460`,也可以直接用 curl 在 linux 系统上直接访问,我这里使用 curl 来访问:   

执行`curl localhost:30460`得到下面的结果:
```shell
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```  

# 总结  

到目前为止就用 kubeadm 使用国内网络轻松部署起一个 kubernetes 了,`lank8s.cn`是我个人在维护的一个`registry.gcr.io`镜像的代理,还有一个`gcr.lank8s.cn`可以代替`gcr.io`来拉取镜像.  

详情可以看看[lank8s.cn服务](https://liangyuanpeng.com/post/service-lank8s.cn/)
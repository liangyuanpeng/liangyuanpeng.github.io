---
layout:     post 
slug:      "kubernetes-qa"
title:      "kubernetes常见问题"
subtitle:   ""
description: ""
date:       2022-01-18
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612709780/hugo/blog.github.io/pexels-matt-hardy-2568001.jpg"
published: true
tags:
    - kubernetes
    - cncf 
categories: [ kubernetes ]
---    

# 声明  

本文会持续的更新,将在使用 kubernetes 过程中遇到的问题都收集起来.欢迎投稿加入你遇到的问题.  

可以在下方的联系方式中找到我的微信,对你加我微信表示欢迎,不论是投稿还是关注我的技术动态. :)

# 跨版本升级

## service-account-issuer is a required flag, --service-account-signing-key-file and --service-account-issuer are required flags  

版本 v1.19.16 升级到 v1.23.x,二进制 kube-apiserver 升级后启动失败,提示`service-account-issuer is a required flag, --service-account-signing-key-file and --service-account-issuer are required flags`,原因就是在新版本中添加了新参数而旧版本没有这个参数.  

## only zero is allowed  

版本 v1.19.16 升级到 v1.23.x,二进制 kube-apiserver 升级后启动失败,
```
E0118 00:40:00.935698    8504 run.go:120] "command failed" err="invalid port value 8080: only zero is allowed"
```  

参数`--insecure-port`只允许设置为`0`.  

这个还没注意到更新点,如果希望使用非tls端口要怎么做呢?  

# Volume挂载问题 

## configmap内容更新后,在pod中对应文件的修改时间没有变化  

这与configmap的更新机制有关  

# 删除资源发生terminating卡住

TODO

# kubeconfig相关

## 将kubeconfig的内容转换成证书文件

convert.sh
```shell
#!/bin/bash

# Parse kubeconfig file
kubeconfig_file="$1"
server=$(kubectl config view --raw --minify | grep server | awk '{print $2}')
ca_cert_data=$(kubectl config view --raw --minify | grep certificate-authority-data | awk '{print $2}')
client_cert_data=$(kubectl config view --raw --minify | grep client-certificate-data | awk '{print $2}')
client_key_data=$(kubectl config view --raw --minify | grep client-key-data | awk '{print $2}')

# Decode certificate data
echo "$ca_cert_data" | base64 -d > ca.crt
echo "$client_cert_data" | base64 -d > client.crt
echo "$client_key_data" | base64 -d > client.key

# Generate client certificate
openssl pkcs12 -export -out client.pfx -inkey client.key -in client.crt -certfile ca.crt -passout pass:

echo "Successfully converted kubeconfig to certificate"
```

上述脚本文件其实是我让 chatGPT 写出来的,可以看到有一些多余的内容,例如接收第一个参数传递给`kubeconfig_file`变量,但是实际上是没有使用到的.  

```shell
server=$(kubectl config view --raw --minify | grep server | awk '{print $2}')
```  

从配置文件中找到`kube-apiserver`的地址,但是实际上这个变量也没有用到.  

但是从需求上来说这不影响,能够满足需求:也就是将`kubeconfig`的内容转换成证书文件,最终你可以使用`curl`带上证书的方式请求`kube-apiserver`.

在使用上述脚本生成证书文件后可以使用以下命令来达到这个效果:
```shell
curl --cert ./client.crt --key client.key --cacert ca.crt https://127.0.0.1:6443/metrics
```  

其中`apiserver`的地址用的是 `127.0.0.1:6443` 如果你的 `apiserver` 地址不是这个,那么需要修改为你实际使用的 `apiserver` 地址.  


# 一些小脚本

日常会用到的小脚本,也许你有其他不一样的需求但是脚本可能通用,希望可以帮到你.  

也欢迎投稿你在云原生领域用到的一些小脚本,如果达到一定规模的话可以弄成一个单独的博客来公布这些小脚本,并且带上署名(肯定的!).

## 创建N个secret

创建一万个 secret ,对我来说需求是压测一下 kube-apiserver,看看N个 secret 可以占用多少内存.

```shell
#!/bin/bash

# 循环10000次
for i in {1..10000}
do
  # 随机生成16个字符的字符串
  secret=$(openssl rand -base64 12 | tr -dc 'a-z0-9' | head -c 16)

  # 创建secret并将结果输出到控制台
  kubectl create secret generic ${secret} --from-literal=key1=value1 --from-literal=key2=value2 --from-literal=key3=value3
  echo "Secret created: ${secret}"
done
```  

## 查看某个namespace下所有pod使用到的容器镜像

```shell
lan@lan:~$ kubectl get pods --all-namespaces -o jsonpath="{..image}" |tr -s '[[:space:]]' '\n' |sort |uniq 
busybox:latest
docker.io/kindest/kindnetd:v20221004-44d545d1
docker.io/kindest/local-path-provisioner:v0.0.22-kind.0
docker.io/library/busybox:latest
docker.io/openkruise/kruise-rollout:v0.3.0
openkruise/kruise-rollout:v0.3.0
registry.k8s.io/coredns/coredns:v1.9.3
registry.k8s.io/etcd:3.5.6-0
registry.k8s.io/kube-apiserver:v1.26.0
registry.k8s.io/kube-controller-manager:v1.26.0
registry.k8s.io/kube-proxy:v1.26.0
registry.k8s.io/kube-scheduler:v1.26.0
```

上述命令列出了所有 namespace 的所有 pod 所使用到的容器镜像.如果你需要某个 namespace 下所有 pod 使用到的容器镜像,只需要指定 namespace 即可,例如查看 default 这个 namespace 下所以后pod 使用的容器镜像:`kubectl get pods -n default -o jsonpath="{..image}" |tr -s '[[:space:]]' '\n' |sort |uniq `

# 一些好用的镜像  

欢迎投稿你在云原生领域用到的一些工具容器镜像,如果达到一定规模的话可以弄成一个单独的博客来公布这些好用的工具容器镜像,并且带上署名(肯定的!).

TODO ubuntu 工具镜像
replacer
waitfor

# 温馨提示 

本文持续更新
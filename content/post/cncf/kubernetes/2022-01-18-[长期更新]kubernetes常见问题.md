---
layout:     post 
slug:      "kubernetes-qa"
title:      "[长期更新]kubernetes常见问题"
subtitle:   ""
description: "[长期更新]kubernetes常见问题"
date:       2022-01-18
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags:
    - kubernetes
    - cncf 
categories: [ kubernetes ]
---    

# 声明  

本文会持续的更新,将在使用 kubernetes 过程中遇到的问题都收集起来.欢迎投稿加入你遇到的问题 :)

# 跨版本升级

## service-account-issuer is a required flag, --service-account-signing-key-file and --service-account-issuer are required flags  
 
版本 v1.19.16 升级到 v1.23.x,二进制 kube-apiserver 升级后启动失败,提示`service-account-issuer is a required flag, --service-account-signing-key-file and --service-account-issuer are required flags`,原因就是在新版本中添加了新参数而旧版本没有这个参数.  

## only zero is allowed  

版本 v1.19.16 升级到 v1.23.x,二进制 kube-apiserver 升级后启动失败,

```shell
E0118 00:40:00.935698    8504 run.go:120] "command failed" err="invalid port value 8080: only zero is allowed"
```  

参数`--insecure-port`只允许设置为`0`.  

这个还没注意到更新点,如果希望使用非 tls 端口要怎么做呢?  

# Volume挂载问题 

## configmap内容更新后,在pod中对应文件的修改时间没有变化  

这与 configmap 的更新机制有关

# 性能优化

## 将单独的资源存储到单独的etcd服务内

常见的是 将 event 内容存储到单独的 etcd 服务内, kube-apiserver 的 etcd-servers-overrides 参数支持将某个单独资源存储到特定的 etcd 服务内,下面是一个将 k8s event 存储到单独的 etcd 服务内的示例:

```yaml
...
    apiServer:
      extraArgs:
        etcd-servers-overrides: /events#http://172.18.0.2:14379
...
```

但是目前这个参数还不支持 CRD 资源,也就是无法将CRD单独存放在另一个 etcd 当中, 2023 年有一个 issue 再次开始讨论 CRD 存储的问题: [Consider providing separate etcd destination for CRDs](https://github.com/kubernetes/kubernetes/issues/118858),之所以说是再次是因为这个功能在设计之初就考虑到了这个问题,但是觉得这不是一个长期的解决方案,所以没有给予支持.(来源于[这个评论](https://github.com/kubernetes/kubernetes/issues/118858#issuecomment-1607388089),可能不是最准确的原因)

我尝试将 openkruise 的资源存储到单独的 etcd 当中,无意外的失败了:

首先将 openkruise 的资源前缀设置到单独的 etcd:

```yaml
...
    apiServer:
      extraArgs:
        etcd-servers-overrides: /events#http://172.18.0.2:14379,/apps.kruise.io#http://172.18.0.2:14379,/apiregistration.k8s.io#http://172.18.0.2:14379,/apiextensions.k8s.io#http://172.18.0.2:14379
...
```

接着安装 openkruise:

```shell
helm repo add openkruise https://openkruise.github.io/charts/
helm install kruise openkruise/kruise
```

最后检查 etcd 中的数据,发现只有 events 的数据而没有 openkruise 的资源数据:

```shell
lan@lan:lan$ etcdctl --endpoints http://172.18.0.2:14379 get --keys-only --prefix /dev/20230903/0545 | grep kruise
/dev/20230903/0545/events/kruise-system/kruise-controller-manager-7f8545cc8d-65n9l.178152709997b7d2
/dev/20230903/0545/events/kruise-system/kruise-controller-manager-7f8545cc8d-65n9l.178152714719c69c
/dev/20230903/0545/events/kruise-system/kruise-controller-manager-7f8545cc8d-65n9l.178152718a317cc7
/dev/20230903/0545/events/kruise-system/kruise-controller-manager-7f8545cc8d-65n9l.1781527239c04f94
/dev/20230903/0545/events/kruise-system/kruise-controller-manager-7f8545cc8d-65n9l.178152730a49d607
/dev/20230903/0545/events/kruise-system/kruise-controller-manager-7f8545cc8d-65n9l.178152730c45ce14
/dev/20230903/0545/events/kruise-system/kruise-controller-manager-7f8545cc8d-65n9l.178152731c6cc974
/dev/20230903/0545/events/kruise-system/kruise-controller-manager-7f8545cc8d-65n9l.178152731cc1b7ce
/dev/20230903/0545/events/kruise-system/kruise-controller-manager-7f8545cc8d-65n9l.1781527396de678c
/dev/20230903/0545/events/kruise-system/kruise-controller-manager-7f8545cc8d-hfnf4.17815270a2d0c70f
/dev/20230903/0545/events/kruise-system/kruise-controller-manager-7f8545cc8d-hfnf4.1781527146fed632
/dev/20230903/0545/events/kruise-system/kruise-controller-manager-7f8545cc8d-hfnf4.178152718a340d05
/dev/20230903/0545/events/kruise-system/kruise-controller-manager-7f8545cc8d-hfnf4.178152723a9533cc
/dev/20230903/0545/events/kruise-system/kruise-controller-manager-7f8545cc8d-hfnf4.17815273093ee98a
/dev/20230903/0545/events/kruise-system/kruise-controller-manager-7f8545cc8d-hfnf4.178152730a49f4e3
/dev/20230903/0545/events/kruise-system/kruise-controller-manager-7f8545cc8d-hfnf4.1781527316a96450
/dev/20230903/0545/events/kruise-system/kruise-controller-manager-7f8545cc8d-hfnf4.178152731ca5eb79
/dev/20230903/0545/events/kruise-system/kruise-controller-manager-7f8545cc8d.17815270986bde82
/dev/20230903/0545/events/kruise-system/kruise-controller-manager-7f8545cc8d.17815270a1f7e4fa
/dev/20230903/0545/events/kruise-system/kruise-controller-manager.178152708f55c786
/dev/20230903/0545/events/kruise-system/kruise-daemon-fdcng.17815270a1abe4ee
/dev/20230903/0545/events/kruise-system/kruise-daemon-fdcng.17815270f4e6b6bf
/dev/20230903/0545/events/kruise-system/kruise-daemon-fdcng.178152727d0770f9
/dev/20230903/0545/events/kruise-system/kruise-daemon-fdcng.1781527309cb67f6
/dev/20230903/0545/events/kruise-system/kruise-daemon-fdcng.178152730c3637e3
/dev/20230903/0545/events/kruise-system/kruise-daemon-fdcng.1781527346d02b51
/dev/20230903/0545/events/kruise-system/kruise-daemon.17815270987a6344
/dev/20230903/0545/events/kruise-system/kruise-manager.1781527382771328
/dev/20230903/0545/events/kruise-system/kruise-manager.1781527382772e1c
```

# Kubelet 相关

## 获取当前集群各个节点 kubelet 配置情况

```shell
kubectl get --raw "/api/v1/nodes/{nodename}/proxy/configz" | jq .
```
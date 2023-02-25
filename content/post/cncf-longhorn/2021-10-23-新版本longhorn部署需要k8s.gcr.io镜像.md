---
layout:     post 
slug:      "deploy-new-longhorn-lank8s.cn"
title:      "新版本longhorn部署需要k8s.gcr.io镜像"
subtitle:   ""
description: "在之前，longhorn的部署是不涉及k8s.gcr.io的镜像的,但是在现在新版本当中,csi相关的镜像都是直接使用k8s.gcr.io中的镜像."
date:       2021-10-23
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1635090321/hugo/banner/pexels-anna-shvets-4587998.jpg"
published: true
tags:
    - longhorn 
    - cncf
categories: [ kubernetes ]
---

# 前言  

在之前，longhorn的部署是不涉及k8s.gcr.io的镜像的,但是在现在新版本当中,csi相关的镜像都是直接使用k8s.gcr.io中的镜像.

# 淡定  

不要慌,这时候可以使用短域名镜像代理`lank8s.cn`来代替k8s.gcr.io.只需要将k8s.gcr.io修改为`lank8s.cn`就可以了，其他都不变.

# 前提  

记得先安装`open-iscsi`,否则部署时会遇到`failed environment check, please make sure you have iscsiadm/open-iscsi installed on the host`    

- Debian/Ubuntu  

`sudo apt-get install open-iscsi`  

- Redhat/Centos/Suse  

`yum install iscsi-initiator-utils`

一般情况下只需要安装这一个东西,具体可以去下面给出的官方文档地址看.

# 部署

按照[官网文档](https://longhorn.io/docs/1.2.2/deploy/install/install-with-helm/)一步一步做,走起.   


```shell
1. helm repo add longhorn https://charts.longhorn.io
2. helm repo update
3. kubectl create namespace longhorn-system 
4. helm install longhorn longhorn/longhorn --namespace longhorn-system  
```

现在已经通过helm chart部署起来了，等待一会看看情况，不出意外的话会因为拉取镜像部署失败.  

```shell
[root@lan1 ~]#  kubectl get pod -n longhorn-system
NAME                                        READY   STATUS              RESTARTS   AGE
csi-attacher-75588bff58-qrbfg               0/1     ImagePullBackOff    0          4m46s
csi-attacher-75588bff58-r77n8               0/1     ImagePullBackOff    0          4m46s
csi-attacher-75588bff58-t944p               0/1     ImagePullBackOff    0          4m46s
csi-provisioner-669c8cc698-2p22g            0/1     ImagePullBackOff    0          4m46s
csi-provisioner-669c8cc698-d6md5            0/1     ErrImagePull        0          4m46s
csi-provisioner-669c8cc698-ppktl            0/1     ImagePullBackOff    0          4m46s
csi-resizer-5c88bfd4cf-d822s                0/1     ContainerCreating   0          4m46s
csi-resizer-5c88bfd4cf-j9n27                0/1     ContainerCreating   0          4m46s
csi-resizer-5c88bfd4cf-sl92r                0/1     ContainerCreating   0          4m46s
csi-snapshotter-69f8bc8dcf-9rf7c            0/1     ContainerCreating   0          4m45s
csi-snapshotter-69f8bc8dcf-pnrt8            0/1     ContainerCreating   0          4m45s
csi-snapshotter-69f8bc8dcf-sssnb            0/1     ContainerCreating   0          4m45s
engine-image-ei-d4c780c6-9525q              1/1     Running             0          4m55s
instance-manager-e-a39ce34c                 1/1     Running             0          4m55s
instance-manager-r-71c5e3f3                 1/1     Running             0          4m54s
longhorn-csi-plugin-8s25k                   0/2     ContainerCreating   0          4m45s
longhorn-driver-deployer-75f68555c9-mhb8j   1/1     Running             0          5m24s
longhorn-manager-6dbsn                      1/1     Running             0          5m10s
longhorn-ui-75ccbd4695-92cj2                1/1     Running             0          5m24s
```

果然失败了，describe一下看看原因: 
```shell
[root@lan1 ~]# kubectl describe pod -n longhorn-system csi-attacher-75588bff58-qrbfg
...
  Warning  Failed     36s                 kubelet            Error: ErrImagePull
  Normal   BackOff    36s                 kubelet            Back-off pulling image "k8s.gcr.io/sig-storage/csi-attacher:v3.2.1"
  Warning  Failed     36s                 kubelet            Error: ImagePullBackOff
  Normal   Pulling    24s (x2 over 5m2s)  kubelet            Pulling image "k8s.gcr.io/sig-storage/csi-attacher:v3.2.1"
```

可以看到,pod从k8s.gcr.io拉取镜像失败了,这时候只需要可以helm upgrade一下将k8s.gcr.io都修改为`lank8s.cn`就可以了.

下面是helm upgrade更新longhorn的命令:
```shell
helm upgrade longhorn longhorn/longhorn --namespace longhorn-system --set image.csi.attacher.repository=lank8s.cn/sig-storage/csi-attacher --set image.csi.provisioner.repository=lank8s.cn/sig-storage/csi-provisioner --set image.csi.nodeDriverRegistrar.repository=lank8s.cn/sig-storage/csi-node-driver-registrar --set image.csi.resizer.repository=lank8s.cn/sig-storage/csi-resizer --set image.csi.snapshotter.repository=lank8s.cn/sig-storage/csi-snapshotter --set persistence.defaultClassReplicaCount=1 --set csi.attacherReplicaCount=1  --set csi.provisionerReplicaCount=1  --set csi.resizerReplicaCount=1  --set csi.snapshotterReplicaCount=1
```  

为了最简部署多了一些设置副本数为1的设置,如果希望使用默认的副本数的话可以用下面的helm upgrade命令:  
```shell
helm upgrade longhorn longhorn/longhorn --namespace longhorn-system --set image.csi.attacher.repository=lank8s.cn/sig-storage/csi-attacher --set image.csi.provisioner.repository=lank8s.cn/sig-storage/csi-provisioner --set image.csi.nodeDriverRegistrar.repository=lank8s.cn/sig-storage/csi-node-driver-registrar --set image.csi.resizer.repository=lank8s.cn/sig-storage/csi-resizer --set image.csi.snapshotter.repository=lank8s.cn/sig-storage/csi-snapshotter
```

执行命令,等一会看看部署的情况，正常的话应该都running了:  
```shell
[root@lan1 ~]# kubectl  get pod -n longhorn-system
NAME                                        READY   STATUS             RESTARTS   AGE
csi-attacher-6d74f5876-w4snx                1/1     Running            0          2m41s
csi-provisioner-dc6b54764-58zcx             1/1     Running            0          2m38s
csi-resizer-6779c54465-mbtp9                1/1     Running            0          2m35s
csi-snapshotter-8ccc478c7-pw6s8             1/1     Running            0          2m32s
engine-image-ei-d4c780c6-n52pq              1/1     Running            0          4m39s
instance-manager-e-6a94c075                 1/1     Running            0          4m39s
instance-manager-r-b7ec2a58                 1/1     Running            0          4m38s
longhorn-csi-plugin-bzf8r                   1/2     ImagePullBackOff   0          4m26s
longhorn-driver-deployer-78964dfc64-57wnw   1/1     Running            0          3m3s
longhorn-manager-mbpmv                      1/1     Running            0          4m58s
longhorn-ui-75ccbd4695-5zhzd                1/1     Running            0          4m58s
```  

奇怪,longhorn-csi-plugin的pod没部署起来，而且报的是拉取镜像失败的错误,用kubectl describe看一下拉取的镜像有没有对不对,确认下是不是设置错误或者拼写错误.  

```
[root@lan1 ~]# kubectl  get pod -n longhorn-system
...
Events:
  Type     Reason     Age                   From               Message
  ----     ------     ----                  ----               -------
  Normal   Scheduled  14m                   default-scheduler  Successfully assigned longhorn-system/longhorn-csi-plugin-bzf8r to lan1
  Normal   Pulled     10m                   kubelet            Container image "longhornio/longhorn-manager:v1.2.2" already present on machine
  Normal   Created    10m                   kubelet            Created container longhorn-csi-plugin
  Normal   Started    10m                   kubelet            Started container longhorn-csi-plugin
  Warning  Failed     8m14s (x3 over 10m)   kubelet            Failed to pull image "k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.3.0": rpc error: code = Unknown desc = Error response from daemon: Get "https://k8s.gcr.io/v2/": net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
  Normal   BackOff    7m36s (x6 over 10m)   kubelet            Back-off pulling image "k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.3.0"
  Normal   Pulling    7m24s (x4 over 13m)   kubelet            Pulling image "k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.3.0"
  Warning  Failed     7m9s (x4 over 10m)    kubelet            Error: ErrImagePull
  Warning  Failed     3m42s (x20 over 10m)  kubelet            Error: ImagePullBackOff
```

可以看到依然是拉取k8s.gcr.io的镜像去了,确认了一下命令没有问题,不确定哪里的问题,只好卸载longhorn再install.

设置副本数版本:  
```shell
helm uninstall longhorn -n longhorn-system
helm install longhorn longhorn/longhorn --namespace longhorn-system --set image.csi.attacher.repository=lank8s.cn/sig-storage/csi-attacher --set image.csi.provisioner.repository=lank8s.cn/sig-storage/csi-provisioner --set image.csi.nodeDriverRegistrar.repository=lank8s.cn/sig-storage/csi-node-driver-registrar --set image.csi.resizer.repository=lank8s.cn/sig-storage/csi-resizer --set image.csi.snapshotter.repository=lank8s.cn/sig-storage/csi-snapshotter --set persistence.defaultClassReplicaCount=1 --set csi.attacherReplicaCount=1  --set csi.provisionerReplicaCount=1  --set csi.resizerReplicaCount=1  --set csi.snapshotterReplicaCount=1
```


不设置副本数版本:  
```shell
helm uninstall longhorn -n longhorn-system
helm install longhorn longhorn/longhorn --namespace longhorn-system --set image.csi.attacher.repository=lank8s.cn/sig-storage/csi-attacher --set image.csi.provisioner.repository=lank8s.cn/sig-storage/csi-provisioner --set image.csi.nodeDriverRegistrar.repository=lank8s.cn/sig-storage/csi-node-driver-registrar --set image.csi.resizer.repository=lank8s.cn/sig-storage/csi-resizer --set image.csi.snapshotter.repository=lank8s.cn/sig-storage/csi-snapshotter
```  

这时候再看下pod,所有pod都起来了.   
```shell
[root@lan1 ~]# k get po  -n longhorn-system
NAME                                        READY   STATUS    RESTARTS   AGE
csi-attacher-6d74f5876-lvpdn                1/1     Running   0          63s
csi-provisioner-dc6b54764-mw9c8             1/1     Running   0          63s
csi-resizer-6779c54465-jbl4p                1/1     Running   0          62s
csi-snapshotter-8ccc478c7-hbpqp             1/1     Running   0          61s
engine-image-ei-d4c780c6-pqb9d              1/1     Running   0          75s
instance-manager-e-e16c3ce8                 1/1     Running   0          75s
instance-manager-r-307de21a                 1/1     Running   0          74s
longhorn-csi-plugin-77t5v                   2/2     Running   0          61s
longhorn-driver-deployer-78964dfc64-ls24l   1/1     Running   0          97s
longhorn-manager-tkmvx                      1/1     Running   0          97s
longhorn-ui-75ccbd4695-c9rn6                1/1     Running   0          97s
```  

后面就可以愉快的使用longhorn存储数据了.

# 后续 

后续会实现一个webhook,效果是部署webhook后会部署/更新阶段将`k8s.gcr.io`替换为`lank8s.cn`,这样就减少了人工成本,不再需要去修改部署helm chart时的命令或者去修改yaml了.  

当部署了这样的一个webhook之后,就可以像以前一样使用简短的命令就可以愉快的使用longhorn了,例如:`helm install longhorn -n longhorn-system`,一起期待吧!

# 更新:在线webhook服务 

目前在线的webhook服务已经上线,只需要在k8s集群部署一个webhook配置,就可以使用在线webhook自动化的修改`gcr.lank8s.io`为`lank8s.cn`了,告别手动时代!  

点击[在线的lank8s的webhook服务](https://liangyuanpeng.com/post/deploy-lank8s-webhook-for-k8s.gcr.io/)查看怎么使用.

# 更新:看看国内如何拉取gcr.io和registry.k8s.io镜像的

[传送门:国内环境拉取gcr和k8s镜像](https://liangyuanpeng.com/post/cncf-k8s/pull-gcr-k8s-image-with-lank8s/)
---
layout:     post 
slug:      "k8s-deploy-longhorn"
title:      "kubernetes部署longhorn"
subtitle:   ""
description: ""
date:       2021-04-09
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1618108844/hugo/banner/pexels-roxanne-minnish-4654652.jpg"
published: true
tags:
    - Longhorn
    - kubernetes 
    - k8s
    - CloudNative
    - cncf
categories: 
    - cloudnative
---

# 前言  
longhorn 是 rancher 公司开源并贡献给 CNCF 的一个开源分布式存储项目,可用来作为 kubernetes 的 CSI 存储.  

本文介绍 helm 和 yaml 两种方式部署 longhorn 并部署一个有状态服务 Gogs 应用.  

官方文档: [https://longhorn.io/docs/1.1.0/deploy/install/install-with-kubectl/](https://longhorn.io/docs/1.1.0/deploy/install/install-with-kubectl/)

# 安装要求  

1. open-iscsi
2. kubernetes 1.16+  官方推荐1.17+ (本文使用1.18.8)  
3. curl、findmnt、grep、awk、blkid、lsblk.  在编写本文时没有显示的去安装这些工具,也许是机器已经具备相关环境.  
4. 启用了`mount propagation`.  本文部署没有显示启用这个功能,也没有遇到相关问题.  

# helm部署longhorn
## 添加longhorn的helm repo
```shell
 helm repo add longhorn https://charts.longhorn.io
```  

## 使用helm部署longhorn:  
```shell
helm install longhorn longhorn/longhorn --namespace longhorn-system
```  

## 查看部署情况

部署中:  
```shell  
$ watch kubectl get po -n longhorn-system
NAME                                        READY   STATUS     RESTARTS   AGE
longhorn-driver-deployer-76c8fd69fb-fvtg7   0/1     Init:0/1   0          27s
longhorn-manager-l2mrs                      0/1     Running    0          27s
longhorn-ui-78547884d8-zb2sc                1/1     Running    0          27s
```

最终部署完成的效果:  
```shell  
$ kubectl get po -n longhorn-system
NAME                                        READY   STATUS    RESTARTS   AGE          
csi-attacher-74db7cf6d9-djzd2               1/1     Running   0          81s          
csi-attacher-74db7cf6d9-lcxbb               1/1     Running   0          81s          
csi-attacher-74db7cf6d9-rdxls               1/1     Running   0          81s          
csi-provisioner-d444fb7c9-6545x             1/1     Running   0          78s          
csi-provisioner-d444fb7c9-96n9g             1/1     Running   0          78s          
csi-provisioner-d444fb7c9-k7ks7             1/1     Running   0          78s          
csi-resizer-58458969c9-64fnz                1/1     Running   0          73s          
csi-resizer-58458969c9-cdqj2                1/1     Running   0          72s          
csi-resizer-58458969c9-fhvg4                1/1     Running   0          72s          
csi-snapshotter-6d856448d-4n2nk             1/1     Running   0          69s          
csi-snapshotter-6d856448d-p4mbz             1/1     Running   0          69s          
csi-snapshotter-6d856448d-pm7kx             1/1     Running   0          69s          
engine-image-ei-cf743f9c-xjl5k              1/1     Running   0          115s         
instance-manager-e-296a3f7e                 1/1     Running   0          115s         
instance-manager-r-40e113e5                 1/1     Running   0          115s         
longhorn-csi-plugin-pnj85                   2/2     Running   0          67s          
longhorn-driver-deployer-76c8fd69fb-fvtg7   1/1     Running   0          2m28s          
longhorn-manager-l2mrs                      1/1     Running   0          2m28s          
longhorn-ui-78547884d8-zb2sc                1/1     Running   0          2m28s
```

查看storageClass:
```shell
$ kubectl get storageclass
NAME                 PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
longhorn (default)   driver.longhorn.io   Delete          Immediate           true                   2m23s
```  

另外也可以使用`helm list -n longhorn-system`来查看helm中的资源,这里不再演示.  

接下来部署一个`StatefulSet`资源来试试通过`longhron storageClass`自动化创建PV和PVC的效果.演示应用使用Gogs.

# yaml方式部署longhorn  

yaml的方式部署的话就一行代码的事  

```shell
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.1.0/deploy/longhorn.yaml
```    

如果github网络问题无法下载可以试试这个地址:[https://res.cloudinary.com/lyp/raw/upload/v1617962359/hugo/blog.github.io/cncf/longhorn1.1.yaml](https://res.cloudinary.com/lyp/raw/upload/v1617962359/hugo/blog.github.io/cncf/longhorn1.1.yaml)

效果和helm部署是一样的,除了helm list看不到资源外(helm list只能看到通过helm方式部署的资源)

# 部署Gogs    

## 创建yaml文件gogs.yaml  

文件内容如何:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: gogs
  labels:
    app: gogs
spec:
  serviceName: gogs
  volumeClaimTemplates:
    - metadata:
        name: gogs-data
      spec:
        storageClassName: longhorn
        accessModes: [ "ReadWriteOnce" ]
        resources:
          requests:
            storage: 5Gi
  updateStrategy:
    type: RollingUpdate
  replicas: 1
  selector:
    matchLabels:
      app: gogs
  template:
    metadata:
      labels:
        app: gogs
    spec:
      containers:
      - name: gogs
        image: gogs/gogs:0.12
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 3000
          name: gogs
        - containerPort: 22
          name: ssh
        volumeMounts:
        - name: gogs-data
          mountPath: /data

---
apiVersion: v1
kind: Service
metadata:
  name: gogs
spec:
  type: NodePort
  ports:
  - name: gogs
    protocol: TCP
    port: 3000
    targetPort: 3000
    nodePort: 30026
  - name: ssh
    protocol: TCP
    port: 22
    targetPort: 22
    nodePort: 30022
  selector:
    app: gogs
```  

开始部署:  
```shell
kubectl apply -f  gogs.yaml
```  

一切正常的话可以看到 gogs 的 pod 已经 `running` 状态了:  
```shell
$ k get po
NAME                                  READY   STATUS    RESTARTS   AGE
gogs-0                                1/1     Running   0          3h49m
```  

我这里是已经部署好了,因此 AGE 显示时间比较长. 再来看看 PV 和 PVC  

```shell
$ k get pvc
NAME               STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
gogs-data-gogs-0   Bound    pvc-3078b16e-4d20-48f2-a32e-6fc6b14bb266   5Gi        RWO            longhorn       3h50m
$ k get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                      STORAGECLASS   REASON   AGE
pvc-3078b16e-4d20-48f2-a32e-6fc6b14bb266   5Gi        RWO            Delete           Bound    default/gogs-data-gogs-0   longhorn                3h50m
```  

可以看到 PV 和 PVC 都已经处于正常的使用状态了.说明 longhorn storageClass 是 working 的.

# FAQ

## 需要提前安装open-iscsi

如果没有提前安装好 open-iscsi 可能会报下面的错误:
```shell
[root@devmaster helmrepo]# kubectl logs -f  -n longhorn-system longhorn-manager-8smtj
time="2020-06-14T07:35:39Z" level=error msg="Failed environment check, please make sure you have iscsiadm/open-iscsi installed on the host"
time="2020-06-14T07:35:39Z" level=fatal msg="Error starting manager: Environment check failed: Failed to execute: nsenter [--mount=/host/proc/932/ns/mnt --net=/host/proc/932/ns/net iscsiadm --version], output , stderr, nsenter: failed to execute iscsiadm: No such file or directory\n, error exit status 1"
...
```

下面给出几个系统安装 iscsi 工具的命令:  
Debian/Ubuntu:
```shell
sudo apt-get install open-iscsi
```

Redhat/Centos/Suse:  
```shell
yum install iscsi-initiator-utils
```
---
layout:     post 
title:      "使用helm部署longhorn在kubernetes上"
subtitle:   ""
description: ""
date:       2020-04-16
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1544363191/hugo/blog.github.io/743a4e9227e1f14cb24a1eb6db29e183.jpg"
published: false
tags:
    - Longhorn
    - kubernetes 
    - k8s
    - CloudNative
categories: 
    - CloudNative
---

# 前言  

# 添加longhorn的helm repo
```shell
[root@kube232 ~]# helm repo add longhorn https://charts.longhorn.io
"longhorn" has been added to your repositories
```

部署中:  
```shell
NAME                                        READY   STATUS     RESTARTS   AGE
longhorn-driver-deployer-76c8fd69fb-fvtg7   0/1     Init:0/1   0          27s
longhorn-manager-l2mrs                      0/1     Running    0          27s
longhorn-ui-78547884d8-zb2sc                1/1     Running    0          27s
```

最终部署完成的效果:  
```shell
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

```shell
[root@kube232 ~]# k get storageclass
NAME                 PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
longhorn (default)   driver.longhorn.io   Delete          Immediate           true                   2m23s
```

# FAQ

1. 需要提前安装open-iscsi

```
[root@devmaster helmrepo]# kubectl logs -f  -n longhorn-system longhorn-manager-8smtj
time="2020-06-14T07:35:39Z" level=error msg="Failed environment check, please make sure you have iscsiadm/open-iscsi installed on the host"
time="2020-06-14T07:35:39Z" level=fatal msg="Error starting manager: Environment check failed: Failed to execute: nsenter [--mount=/host/proc/932/ns/mnt --net=/host/proc/932/ns/net iscsiadm --version], output , stderr, nsenter: failed to execute iscsiadm: No such file or directory\n, error exit status 1"
```


```
Debian/Ubuntu
sudo apt-get install open-iscsi
Redhat/Centos/Suse
yum install iscsi-initiator-utils
```
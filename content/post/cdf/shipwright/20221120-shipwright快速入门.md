---
layout:     post 
slug:      "quick-start-shipwright"
title:      "shipwright快速入门"
subtitle:   ""
description: ""
date:       2022-11-20
author:     "梁远鹏"
image: "/img/banner/743a4e9227e1f14cb24a1eb6db29e183.jpg"
published: false
tags:
    - cdf
    - shipwright
categories: [ cloudnative ]
---    

# 什么是shipwright

https://github.com/shipwright-io/build

# 开始部署

## 部署 tekton 组件

由于 shipwright-build 基于 tekton,因此需要首先部署 tekton.

只需要部署 tekton pipeline 就可以了:

```shell
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.44.0/release.yaml
```


## 部署 shipwright 组件

```shell
kubectl apply -f https://github.com/shipwright-io/build/releases/download/v0.11.0/release.yaml
```

# 

需要注意的是 shipwright build 中例子从 github.com 获取源代码,因此如果你有更快的地址可以批量替换。另一个需要替换的是镜像的 output 地址，也就是你希望镜像 push 到哪个地方。


```shell
#!/bin/bash

DIRECTORY="/tmp/shipwright/samples"

find "$DIRECTORY" -type f | while read FILE ; do
    echo "$FILE"
    # TODO run zot at local?
    sed -i 's/github.com/proxy.lank8s.cn\/gh/g' $FILE

    sed -i 's/image-registry.openshift-image-registry.svc:5000/192.168.3.87:5000/g' $FILE
    sed -i 's/build-examples/liangyuanpeng/g' $FILE
done
```

同时还需要修改 buildpack buildrun 里面的文件,我把地址修改为了我本地的 distribution 容器.

```yaml
...
  output:
    image: 192.168.3.87:5000/liangyuanpeng/taxi-app
...
```

如果你也是使用本地容器镜像仓库,那么你也需要部署一个容器镜像仓库,我这里使用docker部署:

```shell
docker run -it -d --name distribution -p 5000:5000 distribution/distribution:2.8.1
```

由于用的是 buildpacks 方式打包镜像,因此需要一个builder,默认的builder有2GB，提前下载到本地比较好:

```
docker pull docker-image paketobuildpacks/builder:full
```


最后 apply buildrun 文件,然后使用 shp 命令来查看 buildrun 日志,看到最后几行类似的内容就是成功了:
```shell
...
  Generating SBOM for /tmp/layers/paketo-buildpacks_npm-install/launch-modules
      Completed in 2ms


Paketo Buildpack for Node Start 1.0.7
  Assigning launch processes:
    web (default): node app.js

===> EXPORTING
Warning: Platform requested deprecated API '0.4'
Reusing layers from image '192.168.3.87:5000/liangyuanpeng/taxi-app@sha256:5a055edb8aba701ff52eb7c1d6a961743ef58bc0dd3e6cb5fa3e1600f5c2c5f8'
...
```

一步一步理解表示的意思.

可以看到在镜像仓库中已经有对应的容器镜像存在了.
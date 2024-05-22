---
layout:     post 
slug:   "use-cri-o-container-runtime-with-kind"
title:      "使用crio作为kind的容器运行时"
subtitle:   ""
description: ""  
date:       2024-05-22
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags: 
    - kubernetes
    - cncf
    - cri-o
    - kind
    - kubernetes-sigs
categories: 
    - kubernetes
---


> 译者: 梁远鹏

在本文中,我将演示如何基于特定的 kubernetes 版本和 `cri-o` 运行时构建[kind的node镜像](https://kind.sigs.k8s.io/docs/design/node-image/)

# 构建基础镜像

为了构建基础镜像,我们需要 kind 的源码:

```shell
$ git clone git@github.com:kubernetes-sigs/kind.git
$ cd kind/images/base
$ make quick
./../../hack/build/init-buildx.sh
docker buildx build  --load --progress=auto -t gcr.io/k8s-staging-kind/base:v20240508-19df3db3 --pull --build-arg GO_VERSION=1.21.6  .
### ... some output here
```

这个 `gcr.io/k8s-staging-kind/base:v20240508-19df3db3` 镜像是我们的[基础镜像](https://kind.sigs.k8s.io/docs/design/base-image/),我们会使用这个镜像来构建 kind node 镜像.

# 构建 kind node 镜像

在开始构建 kind node 镜像之前,我们需要将 kubernetes 源码放置在 `$GOPATH`

```shell
$ mkdir -p "$GOPATH"/src/k8s.io/kubernetes
$ K8S_VERSION=v1.30.0
$ git clone --depth 1 --branch ${K8S_VERSION} https://github.com/kubernetes/kubernetes.git "$GOPATH"/src/k8s.io/kubernetes
```

现在让我们开始构建 kind node 镜像:

```shell
$ kind build node-image --base-image gcr.io/k8s-staging-kind/base:v20240508-19df3db3
Starting to build Kubernetes
+++ [0508 15:41:04] Verifying Prerequisites....
+++ [0508 15:41:04] Building Docker image kube-build:build-14d7110ae1-5-v1.30.0-go1.22.2-bullseye.0
+++ [0508 15:42:49] Creating data container kube-build-data-14d7110ae1-5-v1.30.0-go1.22.2-bullseye.0
+++ [0508 15:42:50] Syncing sources to container
+++ [0508 15:42:54] Running build command...
+++ [0508 15:42:46] Building go targets for linux/arm64
    k8s.io/kubernetes/cmd/kube-apiserver (static)
    k8s.io/kubernetes/cmd/kube-controller-manager (static)
    k8s.io/kubernetes/cmd/kube-proxy (static)
    k8s.io/kubernetes/cmd/kube-scheduler (static)
    k8s.io/kubernetes/cmd/kubeadm (static)
    k8s.io/kubernetes/cmd/kubectl (static)
    k8s.io/kubernetes/cmd/kubelet (non-static)
+++ [0508 15:45:16] Syncing out of container
+++ [0508 15:45:22] Building images: linux-arm64
+++ [0508 15:45:22] Starting docker build for image: kube-apiserver-arm64
+++ [0508 15:45:22] Starting docker build for image: kube-controller-manager-arm64
+++ [0508 15:45:22] Starting docker build for image: kube-scheduler-arm64
+++ [0508 15:45:22] Starting docker build for image: kube-proxy-arm64
+++ [0508 15:45:22] Starting docker build for image: kubectl-arm64
+++ [0508 15:45:32] Deleting docker image registry.k8s.io/kubectl-arm64:v1.30.0
+++ [0508 15:45:32] Deleting docker image registry.k8s.io/kube-scheduler-arm64:v1.30.0
+++ [0508 15:45:35] Deleting docker image registry.k8s.io/kube-proxy-arm64:v1.30.0
+++ [0508 15:45:35] Deleting docker image registry.k8s.io/kube-controller-manager-arm64:v1.30.0
+++ [0508 15:45:40] Deleting docker image registry.k8s.io/kube-apiserver-arm64:v1.30.0
+++ [0508 15:45:40] Docker builds done
Finished building Kubernetes
Building node image ...
Building in container: kind-build-1715175957-1495463435
Image "kindest/node:latest" build completed.
```

经过上述操作,我们已经得到了一个 kind node 的容器镜像:`kindest/node:latest`,接下来会开始将 cri-o 安装到这个 kind node 镜像中,首先编写一个 Dockerfile,主要是基于 `kindest/node:latest` 来安装 `cri-o`

```Dockerfile
FROM kindest/node:latest

ARG CRIO_VERSION
ARG PROJECT_PATH=prerelease:/$CRIO_VERSION

RUN echo "Installing Packages ..." \
    && apt-get clean \
    && apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    software-properties-common vim gnupg \
    && echo "Installing cri-o ..." \
    && curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/$PROJECT_PATH/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/$PROJECT_PATH/deb/ /" | tee /etc/apt/sources.list.d/cri-o.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get --option=Dpkg::Options::=--force-confdef install -y cri-o \
    && sed -i 's/containerd/crio/g' /etc/crictl.yaml \
    && systemctl disable containerd \
    && systemctl enable crio
```

现在可以真正开始构建一个包含了 [prerelease:v1.30](https://github.com/cri-o/packaging/blob/main/README.md#prereleases) 版本的 `cri-o` 的 kind node 镜像:

```shell
$ CRIO_VERSION=v1.30
$ docker build --build-arg CRIO_VERSION=$CRIO_VERSION -t kindnode/crio:$CRIO_VERSION .
```

到目前为止我们已经构建好了一个内置安装了 cri-o 的 kind node 容器镜像,可以使用下面的 kind 配置文件来启动一个 kubernetes 集群:

kind-crio.yaml
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      criSocket: unix:///var/run/crio/crio.sock
  - |
    kind: JoinConfiguration
    nodeRegistration:
      criSocket: unix:///var/run/crio/crio.sock
- role: worker
  kubeadmConfigPatches:
  - |
    kind: JoinConfiguration
    nodeRegistration:
      criSocket: unix:///var/run/crio/crio.sock
```

# 创建 kind kubernetes 集群

开始创建使用 cri-o 的 kubernetes 集群!

```shell
$ kind create cluster --image kindnode/crio:$CRIO_VERSION --config ./kind-crio.yaml
Creating cluster "kind" ...
 ✓ Ensuring node image (kindnode/crio:v1.30) 🖼
 ✓ Preparing nodes 📦 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
 ✓ Joining worker nodes 🚜
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Have a question, bug, or feature request? Let us know! https://kind.sigs.k8s.io/#community 🙂
```

无惊无险,一个使用 cri-o 容器运行时的 kubernetes 集群启动好了!

# 部署示例

现在来部署一个简单的示例应用看看效果!!  [kubectl apply -f httpbin.yaml](https://github.com/istio/istio/blob/master/samples/httpbin/httpbin.yaml)

httpbin.yaml
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: httpbin
---
apiVersion: v1
kind: Service
metadata:
  name: httpbin
  labels:
    app: httpbin
    service: httpbin
spec:
  ports:
  - name: http
    port: 8000
    targetPort: 8080
  selector:
    app: httpbin
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpbin
spec:
  replicas: 1
  selector:
    matchLabels:
      app: httpbin
      version: v1
  template:
    metadata:
      labels:
        app: httpbin
        version: v1
    spec:
      serviceAccountName: httpbin
      containers:
      - image: docker.io/kong/httpbin
        imagePullPolicy: IfNotPresent
        name: httpbin
        # Same as found in Dockerfile's CMD but using an unprivileged port
        command:
        - gunicorn
        - -b
        - 0.0.0.0:8080
        - httpbin:app
        - -k
        - gevent
        env:
        # Tells pipenv to use a writable directory instead of $HOME
        - name: WORKON_HOME
          value: /tmp
        ports:
        - containerPort: 8080
```

使用 kubectl port-forward 转发一下 httpbin 的 service,以便可以直接使用端口号访问:

```shell
$ kubectl port-forward svc/httpbin 8000:8000 -n default

Forwarding from 127.0.0.1:8000 -> 8080
Forwarding from [::1]:8000 -> 8080
```

现在,在另一个命令行窗口访问一下 http bin 服务:

```shell
curl -X GET localhost:8000/get
{
  "args": {}, 
  "headers": {
    "Accept": "*/*", 
    "Host": "localhost:8000", 
    "User-Agent": "curl/8.4.0"
  }, 
  "origin": "127.0.0.1", 
  "url": "http://localhost:8000/get"
}
```

成功! 顺利走完整个流程,从应用部署到应用访问都没有问题.  😄

# 一些参考

- [如何将cri-o运行时与kind结合使用](https://gist.github.com/aojea/bd1fb766302779b77b8f68fa0a81c0f2)
- [kind node 节点镜像](https://kind.sigs.k8s.io/docs/design/node-image/)


原文地址: [Use CRI-O Container Runtime with KIND](https://rkiselenko.dev/blog/crio-in-kind/#build-node-image)
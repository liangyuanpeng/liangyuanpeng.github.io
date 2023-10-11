---
layout:     post 
slug:      "know-what-kapp-controller"
title:      "初识kapp-controller"
subtitle:   ""
description: ""
date:       2023-03-04
author:     "梁远鹏"
image: "img/post-bg-2015.jpg"
published: false
tags:
    - carvel 
    - cncf
    - kapp-controller
categories: [ kubernetes ]
---


# 前言    

# 前提

- kapp

你需要首先下载 kapp 命令行

# 部署 

```shell
kubectl apply -f https://github.com/carvel-dev/kapp-controller/releases/latest/download/release.yml
```

```shell
kapp deploy -a default-ns-rbac -f https://raw.githubusercontent.com/carvel-dev/kapp-controller/develop/examples/rbac/default-ns.yml
```

simple-app.yaml
```yaml
apiVersion: kappctrl.k14s.io/v1alpha1
kind: App
metadata:
  name: simple-app
  namespace: default
spec:
  serviceAccountName: default-ns-sa
  fetch:
  - git:
      url: https://github.com/vmware-tanzu/carvel-simple-app-on-kubernetes
      ref: origin/develop
      subPath: config-step-2-template
  template:
  - ytt: {}
  deploy:
  - kapp: {}
```

kubectl apply -f simple-app.yaml


```shell
oem@lan:~$ kubectl get app simple-app
NAME         DESCRIPTION           SINCE-DEPLOY   AGE
simple-app   Reconcile succeeded   16s            17s
```

package.yaml
```yaml
apiVersion: data.packaging.carvel.dev/v1alpha1
kind: Package
metadata:
  name: simple-app.corp.com.1.0.0
spec:
  refName: simple-app.corp.com
  version: 1.0.0
  releaseNotes: |
        Initial release of the simple app package
  template:
    spec:
      fetch:
      - imgpkgBundle:
          image: index.docker.io/k8slt/kctrl-example-pkg@sha256:8ffa7f9352149dba1d539d0006b38eda357917edcdd39b82497a61dab2c27b75
      template:
      - ytt:
          paths:
          - config/
      - kbld:
          paths:
          - .imgpkg/images.yml
          - '-'
      deploy:
      - kapp: {}
  valuesSchema:
    openAPIv3:
      title: simple-app.corp.com values schema
      examples:
      - svc_port: 80
        app_port: 80
        hello_msg: stranger
      properties:
        svc_port:
          type: integer
          description: Port number for the service.
          default: 80
          examples:
          - 80
        app_port:
          type: integer
          description: Target port for the application.
          default: 80
          examples:
          - 80
        hello_msg:
          type: string
          description: Name used in hello message from app when app is pinged.
          default: stranger
          examples:
          - stranger
```

package-repository.yaml
```yaml
apiVersion: packaging.carvel.dev/v1alpha1
kind: PackageRepository
metadata:
  name: simple-package-repository
  namespace: default
spec:
  fetch:
    imgpkgBundle:
      image: k8slt/corp-com-pkg-repo:1.0.0
```

package-install.yaml
```yaml
apiVersion: packaging.carvel.dev/v1alpha1
kind: PackageInstall
metadata:
  name: pkg-demo
  namespace: default
spec:
  serviceAccountName: default-ns-sa
  packageRef:
    refName: simple-app.corp.com
    versionSelection:
      constraints: 1.0.0
```


https://carvel.dev/kapp-controller/

# 注意 

本文还在持续创作当中

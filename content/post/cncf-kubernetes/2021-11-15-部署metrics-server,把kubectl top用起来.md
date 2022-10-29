---
layout:     post 
slug:      "deploy-metrics-server-for-kubectl-top"
title:      "部署metrics-server,把kubectl top用起来"
subtitle:   ""
description: ""
date:       2021-11-15
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1635353670/hugo/banner/pexels-helena-lopes-2253275.jpg"
published: true
tags:
    - cncf 
    - tech
    - k8s
    - kubernetes
categories: [ kubernetes ]
---

# 在部署metrics-server之前使用kubectl top

# 部署metrics-server  

## yaml部署

yaml文件如下:  
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-view: "true"
  name: system:aggregated-metrics-reader
rules:
- apiGroups:
  - metrics.k8s.io
  resources:
  - pods
  - nodes
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - nodes
  - nodes/stats
  - namespaces
  - configmaps
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server-auth-reader
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: extension-apiserver-authentication-reader
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server:system:auth-delegator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:metrics-server
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  ports:
  - name: https
    port: 443
    protocol: TCP
    targetPort: https
  selector:
    k8s-app: metrics-server
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  strategy:
    rollingUpdate:
      maxUnavailable: 0
  template:
    metadata:
      labels:
        k8s-app: metrics-server
    spec:
      containers:
      - args:
        - --cert-dir=/tmp
        - --secure-port=443
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --metric-resolution=15s
        image: k8s.gcr.io/metrics-server/metrics-server:v0.5.1
        imagePullPolicy: IfNotPresent
        livenessProbe:
          failureThreshold: 3
          httpGet:
            path: /livez
            port: https
            scheme: HTTPS
          periodSeconds: 10
        name: metrics-server
        ports:
        - containerPort: 443
          name: https
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /readyz
            port: https
            scheme: HTTPS
          initialDelaySeconds: 20
          periodSeconds: 10
        resources:
          requests:
            cpu: 100m
            memory: 200Mi
        securityContext:
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
        volumeMounts:
        - mountPath: /tmp
          name: tmp-dir
      nodeSelector:
        kubernetes.io/os: linux
      priorityClassName: system-cluster-critical
      serviceAccountName: metrics-server
      volumes:
      - emptyDir: {}
        name: tmp-dir
---
apiVersion: apiregistration.k8s.io/v1
kind: APIService
metadata:
  labels:
    k8s-app: metrics-server
  name: v1beta1.metrics.k8s.io
spec:
  group: metrics.k8s.io
  groupPriorityMinimum: 100
  insecureSkipTLSVerify: true
  service:
    name: metrics-server
    namespace: kube-system
  version: v1beta1
  versionPriority: 100

```  

直接用这个yaml部署的话是国内会部署失败的,因为镜像使用了`k8s.gcr.io`,而国内访问不了.  

这时候只需要把`k8s.gcr.io`修改为`lank8s.cn`,再次部署这个yaml就可以了!  

如果部署`k8s.gcr.io`的镜像容器多了,每次都去修改的话就会很繁琐,这时候可以部署一个webhook来自动化这个过程(将`k8s.gcr.io`修改为`lank8s.cn`).现在lank8s.cn提供了一个在线的webhook在开发测试环境使用,马上会手把手教你部署一个webhook在本地集群.  

你可以这样体验一下在线的webhook:  
```yaml
apiVersion: admissionregistration.k8s.io/v1beta1
kind: MutatingWebhookConfiguration
metadata:
  name: lanwebhook
webhooks:
  - name: lanwebhook.lank8s.cn
    clientConfig:
      url: "https://lank8s.cn/mutate"
    rules:
      - operations: [ "CREATE" ]
        apiGroups: ["apps", ""]
        apiVersions: ["v1"]
        resources: ["deployments","daemonsets","statefulsets"]
```  

使用上面内容创建一个webhook-conf.yaml,然后create/apply.  

```shell
kubectl apply -f webhook-conf.yaml
```  

完美拉取`k8s.gcr.io`镜像!

## Helm 部署

```
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade --install metrics-server metrics-server/metrics-server -n kube-system --set image.repository=lank8s.cn/metrics-server/metrics-server

```

# kubectl top原理  

测试PR

# 什么是lank8s.cn  

lank8s.cn是我个人在长久维护的一个免费`k8s.gcr.io`镜像代理服务,也就是说k8s.gcr.io有什么镜像就可以通过lank8s.cn拉取什么镜像.  

另一个`gcr.io`仓库也有对应的`gcr.lank8s.cn`,不一样的是`gcr.lank8s.cn`是以收费方式推出的服务,这是希望分担一下我在`lank8s.cn`上服务器,域名等费用的经济压力.  

但是`gcr.lank8s.cn`也有部分免费镜像提供支持,例如/google_samples的镜像,/kubebuilder的镜像,/istio-release的镜像.  

详细内容请查看:[https://github.com/lank8s](https://github.com/lank8s)

# 注意  

本文还在持续创作当中.
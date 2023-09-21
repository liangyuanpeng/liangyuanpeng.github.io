---
layout:     post 
slug:      "quickstart-with-envoy-gateway"
title:      "快速开始Envoy-gateway"
subtitle:   ""
description: ""
date:       2023-03-02
author:     "梁远鹏"
image: "img/post-bg-2015.jpg"
published: true
wipnote: true
tags:
    - envoy 
    - cncf
    - kubernetes
    - envoy-gateway
    - k8s-gateway-api
categories: [ kubernetes ]
---

# 


https://github.com/envoyproxy/gateway

https://gateway.envoyproxy.io/v0.3.0/user/quickstart.html


# 

```shell
kubectl apply -f https://github.com/envoyproxy/gateway/releases/download/v0.3.0/install.yaml
kubectl wait --timeout=5m -n envoy-gateway-system deployment/envoy-gateway --for=condition=Available
```

```shell
kubectl apply -f https://github.com/envoyproxy/gateway/releases/download/v0.3.0/quickstart.yaml
```


```shell
export ENVOY_SERVICE=$(kubectl get svc -n envoy-gateway-system --selector=gateway.envoyproxy.io/owning-gateway-namespace=default,gateway.envoyproxy.io/owning-gateway-name=eg -o jsonpath='{.items[0].metadata.name}')
kubectl -n envoy-gateway-system port-forward service/${ENVOY_SERVICE} 8888:80
```


```shell
curl --verbose --header "Host: www.example.com" http://localhost:8888/get
```


```shell
lan@lan:~/server/kind$ curl --verbose --header "Host: www.example.com" http://localhost:8888/get
*   Trying 127.0.0.1:8888...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 8888 (#0)
> GET /get HTTP/1.1
> Host: www.example.com
> User-Agent: curl/7.68.0
> Accept: */*
> 
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< content-type: application/json
< x-content-type-options: nosniff
< date: Thu, 06 Apr 2023 09:57:59 GMT
< content-length: 426
< x-envoy-upstream-service-time: 0
< server: envoy
< 
{
 "path": "/get",
 "host": "www.example.com",
 "method": "GET",
 "proto": "HTTP/1.1",
 "headers": {
  "Accept": [
   "*/*"
  ],
  "User-Agent": [
   "curl/7.68.0"
  ],
  "X-Envoy-Expected-Rq-Timeout-Ms": [
   "15000"
  ],
  "X-Forwarded-Proto": [
   "http"
  ],
  "X-Request-Id": [
   "3ff09959-f2fc-4918-8f30-6624fb3e8379"
  ]
 },
 "namespace": "default",
 "ingress": "",
 "service": "",
 "pod": "backend-7f6b74f5b7-zsq24"
* Connection #0 to host localhost left intact
```


# know it

gatewayClass
gateway
httproute
backend -->  deployment svc cm sa ...



# cleanup

```shell
kubectl delete -f https://github.com/envoyproxy/gateway/releases/download/v0.3.0/quickstart.yaml --ignore-not-found=true
kubectl delete -f https://github.com/envoyproxy/gateway/releases/download/v0.3.0/install.yaml --ignore-not-found=true
```

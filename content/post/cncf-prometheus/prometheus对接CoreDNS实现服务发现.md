---
layout:     post 
slug:      "prometheus-coredns-sd"
title:      "prometheus对接CoreDNS实现服务发现"
subtitle:   ""
description: " "
date:       2021-03-23
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612709780/hugo/blog.github.io/pexels-matt-hardy-2568001.jpg"
published: true
wipnote: true
tags:
    - coredns
    - prometheus
    - cncf
    - CloudNative
    - etcd
categories: 
    - CloudNative
---  

# 启动etcd  

```shell
[root@localhost etcd-v3.2.32-linux-amd64]# ./etcd --listen-peer-urls="http://0.0.0.0:2380" --listen-client-urls="http://0.0.0.0:2379" --advertise-client-urls="http://0.0.0.0:2379"
2021-04-07 16:03:31.438164 W | pkg/flags: unrecognized environment variable ETCD_VER=v3.2.32
2021-04-07 16:03:31.438308 I | etcdmain: etcd Version: 3.2.32
2021-04-07 16:03:31.438321 I | etcdmain: Git SHA: 7dc07f2a9
2021-04-07 16:03:31.438331 I | etcdmain: Go Version: go1.12.17
```

coredns配置文件
```
liangyuanpeng.com {
    etcd {
        path /skydns
        endpoint http://192.168.3.181:2379
    }
    prometheus
    cache
    loadbalance
}

. {
    forward . 8.8.8.8:53 8.8.4.4:53
    cache
}
```    

为了更好的查看效果,建议把下面配置给注释掉:  
```shell
. {
    forward . 8.8.8.8:53 8.8.4.4:53
    cache
}
```  

这样一来,当没有查询到数据时就不会再从8888和8844去检查dns了.

启动coredns
```shell
[root@node123 hades]# coredns -conf corefile-etcd-plugin 
skydns.local.:53
.:53
CoreDNS-1.8.3
linux/amd64, go1.16, 4293992
```  

设置DNS A记录:   
```shell
./etcdctl set /skydns/com/liangyuanpeng/www/ '{"host":"192.168.3.152"}'
```  

# 注意 etcd API版本使用v3

查看Etcd中的数据:  
```shell
./etcdctl get /skydns/ --prefix=true --keys-only=true
```
正常的情况下会看到刚才设置进去的key.

查看DNS是否设置成功  
```shell
[root@node123 ~]# dig @192.168.3.123 www.liangyuanpeng.com

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.4 <<>> @192.168.3.123 www.liangyuanpeng.com
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 35705
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.liangyuanpeng.com.         IN      A

;; ANSWER SECTION:
www.liangyuanpeng.com.  265     IN      A       192.168.3.152

;; Query time: 0 msec
;; SERVER: 192.168.3.123#53(192.168.3.123)
;; WHEN: Wed Apr 07 04:20:28 EDT 2021
;; MSG SIZE  rcvd: 87
```  

可以看到成功将DNS `www.liangyuanpeng.com`解析成了`192.168.3.152`,也就是前面设置到etcd中的内容

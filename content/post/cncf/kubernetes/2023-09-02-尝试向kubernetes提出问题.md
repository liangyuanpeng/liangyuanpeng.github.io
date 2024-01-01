---
layout:     post 
slug:      "try-to-ask-question-to-kubernetes-for-source"
title:      "尝试向kubernetes提出问题"
subtitle:   ""
description: ""
date:       2023-09-02
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
wip: true
tags:
    - kubernetes
    - cncf 
    - etcd
    - golang
categories: [ kubernetes ]
---    

# 声明  

本文会持续的更新,提出一些问题用于研究 kubernetes 原理/源码.欢迎投稿加入你感兴趣的问题 :)

类似的文章有:
- [pulsar源码系列](https://liangyuanpeng.com/post/list-of-source-with-pulsar)
- [bookeeper源码系列](https://liangyuanpeng.com/post/list-of-source-with-bookeeper)

# etcd 当中存储了 kubernetes 什么数据?

(有可能会单独整理成一篇文章,但目前只是一个回答)

这个问题的部分背景:  

- 当我和朋友说我在研究 kubernetes 时他问我 kubernetes 的数据存储在哪里,怎么存储的
- [获取 Kubernetes 集群 1.24 中 etcd 数据部分显示乱码](https://github.com/etcd-io/jetcd/issues/1202)
- [当我使用 watch 功能时,响应值中包含一些乱码,这正常吗?如何修复乱码?](https://github.com/etcd-io/jetcd/issues/1185)

接下来进入正文.

kubernetes 的数据以 `/registry` 开头存储在 etcd 当中,如果直接查询 etcd 中的数据会发现数据是对人不友好的.这是因为默认情况下存储进去的数据默认是以 protobuf 二进制的方式存储的,因此数据是没办法直接看的,另一个情况是使用了数据加密,也就是在存储到 etcd 之前 kube-apiserver 对数据进行了加密,这时候也是无法直接查看数据的,但这个回答不包括加密的情况,可能会在后续单独文章中来介绍,如果你对数据加密感兴趣,可以看看[Kubernetes 中允许允许用户编辑的持久 API 资源数据的所有 API 都支持静态加密](https://kubernetes.io/zh-cn/docs/tasks/administer-cluster/encrypt-data/)

由于 kubernetes 当中只有 kube-apiserver 与 etcd 进行通讯,因此尝试从 kube-apiserver 找到一些线索: 有一个 `--storage-media-type` 参数是标识数据存储的格式,默认情况下是 `application/vnd.kubernetes.protobuf`,可选的值有: `application/json`, `application/yaml`以及`application/vnd.kubernetes.protobuf`.

因此如果想研究 kubernetes 在 etcd 的数据,我的建议是 用 Kind 创建一个 kubernetes,然后给 kube-apiserver 添加启动参数 `--storage-media-type=application/json`, 这样就可以在 etcd 轻松的看到 kube-apiserver 存储到 etcd 的是什么数据了.

下面是一个 service 的数据(由于我修改了默认的存储前缀,因此不是以 /registry 开头):

```shell
# etcdctl --endpoints http://172.18.0.2:14379 get /dev/20230902/0952/services/specs/kube-system/kube-dns
/dev/20230902/0952/services/specs/kube-system/kube-dns
{
    "kind":"Service",
    "apiVersion":"v1",
    "metadata":{
        "name":"kube-dns",
        "namespace":"kube-system",
        "uid":"5a81d246-ffb1-440a-aa8e-d3ebca7c1dec",
        "creationTimestamp":"2023-09-02T12:04:29Z",
        "labels":{
            "k8s-app":"kube-dns",
            "kubernetes.io/cluster-service":"true",
            "kubernetes.io/name":"CoreDNS"
        },
        "annotations":{
            "prometheus.io/port":"9153",
            "prometheus.io/scrape":"true"
        },
        "managedFields":[
            {
                "manager":"kubeadm",
                "operation":"Update",
                "apiVersion":"v1",
                "time":"2023-09-02T12:04:29Z",
                "fieldsType":"FieldsV1",
                "fieldsV1":{
                    "f:metadata":{
                        "f:annotations":{
                            ".":{

                            },
                            "f:prometheus.io/port":{

                            },
                            "f:prometheus.io/scrape":{

                            }
                        },
                        "f:labels":{
                            ".":{

                            },
                            "f:k8s-app":{

                            },
                            "f:kubernetes.io/cluster-service":{

                            },
                            "f:kubernetes.io/name":{

                            }
                        }
                    },
                    "f:spec":{
                        "f:clusterIP":{

                        },
                        "f:internalTrafficPolicy":{

                        },
                        "f:ports":{
                            ".":{

                            },
                            "k:{\"port\":53,\"protocol\":\"TCP\"}":{
                                ".":{

                                },
                                "f:name":{

                                },
                                "f:port":{

                                },
                                "f:protocol":{

                                },
                                "f:targetPort":{

                                }
                            },
                            "k:{\"port\":53,\"protocol\":\"UDP\"}":{
                                ".":{

                                },
                                "f:name":{

                                },
                                "f:port":{

                                },
                                "f:protocol":{

                                },
                                "f:targetPort":{

                                }
                            },
                            "k:{\"port\":9153,\"protocol\":\"TCP\"}":{
                                ".":{

                                },
                                "f:name":{

                                },
                                "f:port":{

                                },
                                "f:protocol":{

                                },
                                "f:targetPort":{

                                }
                            }
                        },
                        "f:selector":{

                        },
                        "f:sessionAffinity":{

                        },
                        "f:type":{

                        }
                    }
                }
            }
        ]
    },
    "spec":{
        "ports":[
            {
                "name":"dns",
                "protocol":"UDP",
                "port":53,
                "targetPort":53
            },
            {
                "name":"dns-tcp",
                "protocol":"TCP",
                "port":53,
                "targetPort":53
            },
            {
                "name":"metrics",
                "protocol":"TCP",
                "port":9153,
                "targetPort":9153
            }
        ],
        "selector":{
            "k8s-app":"kube-dns"
        },
        "clusterIP":"10.96.0.10",
        "clusterIPs":[
            "10.96.0.10"
        ],
        "type":"ClusterIP",
        "sessionAffinity":"None",
        "ipFamilies":[
            "IPv4"
        ],
        "ipFamilyPolicy":"SingleStack",
        "internalTrafficPolicy":"Cluster"
    },
    "status":{
        "loadBalancer":{

        }
    }
}
```

# kubernetes 的 resourceVersion 是什么?

TODO:   

1. kubectl 命令展示 resourceVersion
2. 查看 etcd 中对应的数据,如何找到与 resourceVersion 对应的数据(就是 etcd 的 ModRevision)
3. 开发 operator 时可能会碰到的与 resourceVersion 相关的问题: 并发修改资源

说明 resourceVersion 不是和数据一起存储在 etcd 里面的,而是直接使用了 etcd kv 的 ModRevision 字段.
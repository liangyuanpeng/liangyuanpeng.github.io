---
layout:     post 
slug:      "cloudnative-ci-of-argo-workflow"
title:      "argoworkflow云原生流水线引擎"
subtitle:   ""
description: ""
date:       2022-01-20
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
wipnote: true
tags:
    - argo
    - argo-workflow
    - cncf
    - kubernetes
    - CI/CD
categories: 
    - kubernetes
---    


# Argo workflow 是什么

Argo Workflow 是一个云原生的工作流引擎,基于kubernetes来做编排任务.其中主要的CRD对象有几个:

- Workflow
- WorkflowTemplate
- CronWrokflow

## Workflow

每一个 step 就是一个pod中的容器,最基础的pod都会有两个容器,一个是argoproj/argoexec容器,另一个则是step中需要使用的容器,也就是实际执行内容的容器,只有当需要执行对应的 step 时才会创建出对应的 pod,因此和 Tekton一样,也是对资源的申请和释放具有很好的利用性.

而我们在执行代码测试的过程中经常会有一些依赖服务要怎么在 argo workflow 中实现呢?

argo workflow 为每一个step提供了 sidecars 参数,可以配置你需要的依赖容器,例如 DID,etcd,Redis和Mysql等等.

另一个比较常见的是 并行版本/参数测试,例如跑测试时,希望让同一份代码基于多个版本的etcd服务做测试,那么 argo workflow 也提供了 withItems 的方式来实现这个功能.

还有一个常见的需求是希望保持编译缓存,例如java应用编译产物希望在下一个CI中继续应用,避免每次都去下载一些重复的jar,argo workflow 通过 volume 功能来实现这部分内容. 也可以通过 artifact 功能实现,例如上传到 s3,需要时再进行下载.

TODO 并行测试时 如何处理这个编译产物缓存?
根据文件唯一性来确认编译缓存是否更改,对于并行测试来说编译缓存可能是一样的,例如只更新了代码而没有更新pom.xml 那么缓存依赖是一样的. 对于pom.xml更改了 也就是编译缓存变更了 那么可以先更新编译缓存 然后再跑并行测试,但这是具体的业务内容了.

TODO workflow template 处理这些缓存? 例如 setup-java, setup-rust, 避免每个人都要做类似的事情:缓存编译产物

TODO 控制并行度, https://argoproj.github.io/argo-workflows/synchronization/


## WorkflowTemplate



WorkflowTemplate 是最重要的对象了,基本上绝大部分时间你都是和它在打交道.

WorkflowTemplate和Template:
.....todo


### 有三种template??

https://argoproj.github.io/argo-workflows/variables/#all-templates

- step template
- task template
- http template

## CronWorkflow

# 尝试一下!

## 一个默认的简单workflow

当创建 workflowTemplate 时会有一个默认的 workflowTemplate,来看一下这个 workflowTemplate 做了什么事情.

默认创建的 workflowTemplate 只有一个步骤,  而这个步骤做的唯一一件事情就是打印传参 `message`,

```yaml
ttlStrategy:
    secondsAfterCompletion: 300
  podGC:
    strategy: OnPodCompletion
```

## 让我们靠近生产多一点

接下来编写一个更接近生产的workflow,它会包含以下内容:

- 传递参数
- CI矩阵
- 日志存储 artifact
- volume传递编译缓存
- 通过 artifact 下载源码
- 为CI配置环境变量
- 为CI配置依赖服务(sidecar)
- 设置/使用特别bucketName s3 artifact


# 与 Tekton 的对比

在简单尝试后能够看到最明显的一个区别是 argo workflow 的UI 能够展现出比较直观的 CI 顺序效果. TODO 确认一下, 看看 tekton dashboard

另一个是 argo workflow 中提供了一些 tekton 所没有的功能,在我看来这些也都是比较酷和实用的功能,例如 action 操作,可以直接创建 k8s 对象以及 对 K8s 对象 get,等待k8s对象某个字段完成.

https://github.com/argoproj/argo-workflows/blob/master/examples/k8s-wait-wf.yaml


另一个是 argo workflow 可以暂停流水线, todo 确认tekton 能否暂停流水线,然后需要手动继续.

Tekton 提供的内容处于更底层的位置,而 Argo Workflow 提供了很多上层功能,可以很方便的应用起来.


# 写在最后

到目前为止,我们了解了 Argo Workflow 的强大特性以及与Tekton的一个简单对比,实际在企业内应该选择Argo Workflow 还是 Tekton 还是需要根据业务特点以及实际验证一些测试后才能决定.但总的来说,Argo Workflow 在直接使用上会比 Tekton 更容易上手以及可以基于 UI 更直观的看到 CI 之间的依赖关系.

# argo workflow todo

- [ ] 持久化workflow  https://argoproj.github.io/argo-workflows/workflow-archive/
- [x] git clone workflow template,自带的artifact功能可以直接使用git clone了。
- [ ] pack workflow template
- [ ] oras workflow template
- [ ] 注入sidecar,有什么用? https://argoproj.github.io/argo-workflows/sidecar-injection/
- [ ] 为CI选择特定的节点 https://argoproj.github.io/argo-workflows/fields/#nodeselector
- [ ] maven cache workflow template
- [ ] 默认支持step级别缓存? https://argoproj.github.io/argo-workflows/memoization/#using-memoization
- [ ] 一个workflow需要另一个workflow并行跑的话,应该要用 action create 来创建另一个workflow 并且在后面的step使用 action get 来等待创建的workflow 执行完成(如果需要)


https://zhuanlan.zhihu.com/p/79741277   update tekton proxy


## 备份

kubectl get wf,cwf,cwft,wftmpl -A -o yaml > backup.yaml

似乎同样适用于Tekton,因为这只是把CRD对象对应的yaml文件导出来.

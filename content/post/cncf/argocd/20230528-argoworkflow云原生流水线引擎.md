
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

根据文件唯一性来确认编译缓存是否更改,对于并行测试来说编译缓存可能是一样的,例如只更新了代码而没有更新pom.xml 那么缓存依赖是一样的. 对于pom.xml更改了 也就是编译缓存变更了 那么可以先更新编译缓存 然后再跑并行测试,当然这是具体的业务内容了.

## WorkflowTemplate

WorkflowTemplate 是最重要的对象了,基本上绝大部分时间你都是和它在打交道，但是在刚认识 argo workflow 时需要注意区分的一点是 workflowTemplate 和 template，这在我刚入门时也造成了一点困惑，接下来讲一下这两个的区别：

workflowTemplate是argo workflow 中实现的CRD对象，而template则是对象内的一个字段，实际执行内容都是在 template 中定义的，一个 workflowTemplate 至少要包含一个 template。 workflowTemplate 需要将一个 template 配置为entrypoint，也就是流水线的起点，在这个 template 的steps 中又可以应用多个相同或不同的 template,接下来从官方一个默认的 workflowTemplate 来看一下实际的yaml是怎么样的。

### 一个默认的简单workflowTemplate

当创建 workflowTemplate 时会有一个默认的 workflowTemplate,来看一下这个 workflowTemplate 做了什么事情.

```yaml
metadata:
  name: lovely-dragon
  namespace: default
  labels:
    example: 'true'
spec:
  workflowMetadata:
    labels:
      example: 'true'
  entrypoint: argosay
  arguments:
    parameters:
      - name: message
        value: hello argo
  templates:
    - name: argosay
      inputs:
        parameters:
          - name: message
            value: '{{workflow.parameters.message}}'
      container:
        name: main
        image: argoproj/argosay:v2
        command:
          - /argosay
        args:
          - echo
          - '{{inputs.parameters.message}}'
  ttlStrategy:
    secondsAfterCompletion: 300
  podGC:
    strategy: OnPodCompletion
```

默认创建的 workflowTemplate 只有一个 template 并且它做的唯一一件事情就是打印传参 `message`。

需要注意的是 默认的 workflow 中设置了 podGC和workflowTTL，一旦pod执行完成了就会删除pod，并且由于默认没有配置日志持久化，这时候去查看日志的话只会看到空白，为了方便研究和测试，可以将条件设置为 workflowOnSuccess，当workflow顺利执行结束才会去删除pod，然后在流水线的最后设置一个一定失败的step来保证pod不会被删除。注意:实际应用时请正确设置日志持久化。

```yaml
  ttlStrategy:
    secondsAfterCompletion: 300
  podGC:
    strategy: OnPodCompletion
```

### DAG 有向无环图

在 Tekton 中，DAG 的表示可以直接理解为 Pipeline。在整个流水线的过程中，可以串行或并行地执行 Tekton Task 并且任务起点与终点不会形成一个闭环。

除了 steps template 之外，Argo WorkflowTemplate 同样支持 DAG，以 dag template 的方式存在，可以让用户更好的维护复杂的工作流。

这里基于一个官方文档的示例来简单了解一下argo workflow dag template：  

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: dag-diamond-
spec:
  entrypoint: diamond
  templates:
  - name: echo
    inputs:
      parameters:
      - name: message
    container:
      image: alpine:3.7
      command: [echo, "{{inputs.parameters.message}}"]
  - name: diamond
    dag:
      tasks:
      - name: A
        template: echo
        arguments:
          parameters: [{name: message, value: A}]
      - name: B
        dependencies: [A]
        template: echo
        arguments:
          parameters: [{name: message, value: B}]
      - name: C
        dependencies: [A]
        template: echo
        arguments:
          parameters: [{name: message, value: C}]
      - name: D
        dependencies: [B, C]
        template: echo
        arguments:
          parameters: [{name: message, value: D}]
```

可以看到工作流的入口template为diamond，由于只有任务A没有顺序依赖，因此一开始只会执行任务A，任务A成功执行后开始同时执行任务B和任务C，最终任务B和任务C都顺利执行完后开始执行任务D。可以看到dependencies是一个数组传参，因此也可以将上述示例修改为任务D只需要等待任务C顺利执行后就开始执行。

### 支持K8S资源操作

接下来看一个官方例子：等待 workflow。

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: k8s-wait-wf-
spec:
  entrypoint: k8s-wait-wf
  templates:
  - name: k8s-wait-wf
    steps:
    - - name: create-wf
        template: create-wf
    - - name: wait-wf
        template: wait-wf
        arguments:
          parameters:
          - name: wf-name
            value: '{{steps.create-wf.outputs.parameters.wf-name}}'

  - name: create-wf
    resource:
      action: create
      manifest: |
        apiVersion: argoproj.io/v1alpha1
        kind: Workflow
        metadata:
          generateName: sleep-
        spec:
          entrypoint: sleep
          templates:
          - name: sleep
            container:
              image: alpine:latest
              command: [sleep, "20"]
    outputs:
      parameters:
      - name: wf-name
        valueFrom:
          jsonPath: '{.metadata.name}'

  - name: wait-wf
    inputs:
      parameters:
      - name: wf-name
    resource:
      action: get
      successCondition: status.phase == Succeeded
      failureCondition: status.phase in (Failed, Error)
      manifest: |
        apiVersion: argoproj.io/v1alpha1
        kind: Workflow
        metadata:
          name: {{inputs.parameters.wf-name}}
```

可以看到，Argo Workflow 原生支持直接在流水线中创建K8S对象，并且根据对象的字段来控制流水线的执行。上述的示例效果是在 step1 中创建一个 workflow，然后在 step2 中等待创建的 workflow 执行完成。

这个在 resource 操作在流水线需要处理一些K8s资源时会是一个很有用的功能。

## CronWorkflow

```yaml
metadata:
  name: sparkly-tiger
  namespace: default
  labels:
    example: 'true'
spec:
  workflowMetadata:
    labels:
      example: 'true'
  schedule: '* * * * *'
  workflowSpec:
    entrypoint: argosay
    arguments:
      parameters:
        - name: message
          value: hello argo
    templates:
      - name: argosay
        inputs:
          parameters:
            - name: message
              value: '{{workflow.parameters.message}}'
        container:
          name: main
          image: argoproj/argosay:v2
          command:
            - /argosay
          args:
            - echo
            - '{{inputs.parameters.message}}'
    ttlStrategy:
      secondsAfterCompletion: 300
    podGC:
      strategy: OnPodCompletion
```

# 尝试一下!



## 靠近生产多一点

接下来编写一个更接近生产的workflow,它会包含以下内容:

- 传递参数
- CI矩阵
- 通过 artifact 下载源码
- 为CI配置环境变量
- 为CI配置依赖服务(sidecar)

- 设置/使用特别bucketName s3 artifact
- 工件存储 artifact
- volume传递编译缓存


# 与 Tekton 的对比

系统架构上来说，Tekton 做得更好，整体架构比较清晰，但从用户的角度上来说 Argo Workflow 更容易上手使用。

在简单尝试后能够看到最明显的一个区别是 argo workflow 的UI 能够展现出比较直观的 CI 顺序效果.

另一个是 argo workflow 中提供了一些 tekton 默认所没有的功能,在我看来这些也都是比较酷和实用的功能,例如：

- action 操作,可以直接创建 k8s 对象以及 对 K8s 对象 get,等待k8s对象某个字段完成.
- artifact 功能，例如和s3打交道，这在流水线中是很常见的需求，但Tekton本身并没有提供。
- 归档日志和workflow。

argo workflow 的文档建设也比 Tekton 更好。

https://github.com/argoproj/argo-workflows/blob/master/examples/k8s-wait-wf.yaml

总的来说 Tekton 提供的内容处于更底层的位置,而 Argo Workflow 提供了很多上层功能,可以很方便的应用起来.


# 备份

kubectl get wf,cwf,cwft,wftmpl -A -o yaml > backup.yaml

似乎同样适用于Tekton,因为这只是把CRD对象对应的yaml文件导出来.


# 写在最后

到目前为止,我们了解了 Argo Workflow 的强大特性以及与Tekton的一个简单对比,实际在企业内应该选择Argo Workflow 还是 Tekton 还是需要根据业务特点以及实际验证一些测试后才能决定.但总的来说,Argo Workflow 在直接使用上会比 Tekton 更容易上手以及可以基于 UI 更直观的看到 CI 之间的依赖关系.

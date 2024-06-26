---
layout:     post 
slug:      "sofarpc-right-down"
title:      "转|SOFARPC优雅关闭剖析"
subtitle:   ""
description: "众所周知，在微服务架构下面，当应用需要进行新功能升级发布，或者异常关闭重启的时候，我们会对应用的进程进行关闭，而在关闭之前，我们希望做一些诸如关闭数据库连接，等待处理任务完成等操作，这个就涉及到我们本文中的优雅关闭功能。假如应用没有支持优雅停机，则会带来譬如数据丢失，交易中断、文件损坏以及服务未下线等情况。"  
date:       2018-12-12
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1543506262/hugo/blog.github.io/apache-rocketMQ-introduction/7046d2bf0d97278682129887309cc1a6.jpg"
published: true
tags:
    - rpc
    - sofa 
    - sofastack
    - Middleware
categories: 
    - TECH
---


# 前言

众所周知，在微服务架构下面，当应用需要进行新功能升级发布，或者异常关闭重启的时候，我们会对应用的进程进行关闭，而在关闭之前，我们希望做一些诸如关闭数据库连接，等待处理任务完成等操作，这个就涉及到我们本文中的优雅关闭功能。假如应用没有支持优雅停机，则会带来譬如数据丢失，交易中断、文件损坏以及服务未下线等情况。

微服务的优雅停机需要遵循"注销发布服务 → 通知注销服务 → 更新服务清单 → 开启请求屏蔽 → 调用销毁业务服务 → 检查所有请求是否完成 → 超时强制停机"应用服务停机流程。

SOFARPC 提供服务端/客户端优雅关闭功能特性，用来解决 kill PID，应用意外自动退出譬如 `System.exit()` <span data-type="color" style="color:rgb(47, 47, 47)"><span data-type="background" style="background-color:rgb(255, 255, 255)">退出 JVM</span></span>，使用脚本或命令方式停止应用等使用场景，避免<span data-type="color" style="color:rgb(47, 47, 47)"><span data-type="background" style="background-color:rgb(255, 255, 255)">服务版本迭代上线</span></span>人工干预的工作量，提高微服务架构的服务高可靠性。

本文<span data-type="color" style="color:rgb(38, 38, 38)"><span data-type="background" style="background-color:rgb(255, 255, 255)">将从进程的优雅关闭，SOFARPC 应用服务优雅关闭流程，Netty 的优雅停机等方面出发详细剖析 。</span></span>

# 进程优雅关闭

### Kill 结束进程

在 Linux上，kill 命令发送指定的信号到相应进程，不指定信号则默认发送 SIGTERM(15) 终止指定进程。如果无法终止，可以发送 SIGKILL(9) 来强制结束进程。kill 命令信号共有64个信号值，其中常用的是：

2(SIGINT：中断，<span data-type="color" style="color:rgb(0, 0, 0)"><span data-type="background" style="background-color:rgb(255, 255, 255)">Ctrl+C</span></span>)。  
15(SIGTERM：终止，默认值)。  
9(SIGKILL：强制终止)。  

这里我们重点说一下15和9的情况。
`kill PID/kill -15 PID` 命令系统发送 <span data-type="color" style="color:rgb(0, 0, 0)"><span data-type="background" style="background-color:rgb(255, 255, 255)">SIGTERM 进程信号给响应的应用程序，当应用程序接收到 SIGTERM 信号，可以进行</span></span>释放相应资源后再停止，此时程序可能仍然继续运行。

而`kill -9 PID` 命令没有给进程遗留善后处理的条件。应用程序将会被直接终止。

对微服务应用而言其效果等同于突然断电，强行终止可能会导致如下几方面问题：

* 缓存数据尚未持久化到磁盘，导致数据丢失；
* 文件写操作正在进行未更新完成，突然退出进程导致文件损坏；
* 线程消息队列尚有接收到的请求消息，未能及时处理，导致请求消息丢失；
* 数据库事务提交，服务端提供给客户端请求响应，消息尚在通信线程发送队列，进程强制退出导致客户端无法接收到响应，此时发起超时重试带来重复更新。

所以支持优雅关闭的前提是关闭的时候，不能被直接 通过发送信号为9的 Kill 来强制结束。当然，其实我们也可以对外统一暴露应用程序管理的 API 来进行控制。本文暂时不做讨论。

## Java 优雅关闭

当应用程序收到信号为15的关闭命令时，可以进行相应的响应，Java 程序的优雅停机通常通过注册 JDK 的 ShutdownHook 来实现，当应用系统接收到退出指令，首先 JVM 标记系统当前处于退出状态，不再接收新的消息，然后逐步处理推积的消息，接着调用资源回收接口进行资源销毁，例如<span data-type="color" style="color:rgb(47, 47, 47)"><span data-type="background" style="background-color:rgb(255, 255, 255)">内存清理、对象销毁等</span></span>，最后各线程退出业务逻辑执行。



![image | center](https://res.cloudinary.com/lyp/image/upload/v1544522249/hugo/blog.github.io/sofa-rpc/%E4%BC%98%E9%9B%85%E5%85%B3%E9%97%AD%E5%89%96%E6%9E%90/1537981880631-12a5ee45-0121-44f5-9ec3-f42ae25c4311.png "")


优雅停机需要超时控制机制，即到达超时时间仍然尚未完成退出前资源回收等操作，则通过停机脚本调用`kill-9 PID`命令强制退出进程。

其中 JVM 优雅关闭的 流程主要的阶段如下图所示：





![image | left](https://res.cloudinary.com/lyp/image/upload/v1544522266/hugo/blog.github.io/sofa-rpc/%E4%BC%98%E9%9B%85%E5%85%B3%E9%97%AD%E5%89%96%E6%9E%90/1538069671200-1ef0957e-65e7-4222-9f1f-22f190687c25.png "")


如图所示，<span data-type="color" style="color:rgb(0, 0, 0)"><span data-type="background" style="background-color:rgb(255, 255, 255)">Java进程优雅退出流程包括如下五个步骤：</span></span>

1. <span data-type="color" style="color:rgb(0, 0, 0)"><span data-type="background" style="background-color:rgb(255, 255, 255)">应用进程启动，初始化 Signal 实例；</span></span>
2. <span data-type="color" style="color:rgb(0, 0, 0)"><span data-type="background" style="background-color:rgb(255, 255, 255)">根据操作系统类型，获取指定进程信号；</span></span>
3. 实现 <span data-type="color" style="color:rgb(0, 0, 0)"><span data-type="background" style="background-color:rgb(255, 255, 255)">SignalHandler 接口，实例化并注册到 Signal，当 Java 进程接收到譬如 kill -12 或者 Ctrl+C 命令信号回调其 handle() 方法；</span></span>
4. <span data-type="color" style="color:rgb(0, 0, 0)"><span data-type="background" style="background-color:rgb(255, 255, 255)">SignalHandler 的 handle 回调接口初始化 ShutdownHook 线程，并将其注册到 Runtime 的 ShutdownHook。</span></span>
5. Java 进程接收到终止进程信号，调用 Runtime 的`exit()` 方法退出 JVM <span data-type="color" style="color:rgb(0, 0, 0)"><span data-type="background" style="background-color:rgb(255, 255, 255)">虚拟机，自动检测用户是否注册ShutdownHook 任务，如果有则触发 ShutdownHook 线程执行自定义资源释放等操作。</span></span>

# SOFARPC 优雅关闭

在进程可以进行优雅关闭后，SOFARPC 如何实现<span data-type="color" style="color:rgb(38, 38, 38)"><span data-type="background" style="background-color:rgb(255, 255, 255)">优雅关闭呢？首先 SOFARPC 对于所有可以被优雅关闭的资源设计</span></span><span data-type="color" style="color:rgb(38, 38, 38)"><span data-type="background" style="background-color:rgb(255, 255, 255)"><code>com.alipay.sofa.rpc.base.Destroyable</code></span></span>接口，通过向 JVM 的 ShutdownHook 注册来对这些可被销毁的资源进行优雅关闭，支持销毁前和销毁后操作。

<span data-type="color" style="color:rgb(38, 38, 38)"><span data-type="background" style="background-color:rgb(255, 255, 255)">这里包括两部分：</span></span>

1. <span data-type="color" style="color:rgb(38, 38, 38)"><span data-type="background" style="background-color:rgb(255, 255, 255)">作为服务端</span></span><span data-type="color" style="color:rgb(51, 51, 51)"><span data-type="background" style="background-color:rgb(255, 255, 255)">注册 JDK 的 ShutdownHook </span></span><span data-type="color" style="color:rgb(38, 38, 38)"><span data-type="background" style="background-color:rgb(255, 255, 255)">执行取消服务注册、关闭服务端口等动作</span></span><span data-type="color" style="color:rgb(51, 51, 51)"><span data-type="background" style="background-color:rgb(255, 255, 255)">实现；</span></span>
2. <span data-type="color" style="color:rgb(38, 38, 38)"><span data-type="background" style="background-color:rgb(255, 255, 255)">作为客户端通过实现 DestroyHook 接口逐步处理正在调用的请求关闭服务调用。</span></span>

## 总体设计

<span data-type="color" style="color:rgb(38, 38, 38)"><span data-type="background" style="background-color:rgb(255, 255, 255)">运行时上下文</span></span><span data-type="color" style="color:rgb(51, 51, 51)"><span data-type="background" style="background-color:rgb(255, 255, 255)">注册 JDK 的 ShutdownHook 执行销毁 SOFARPC 运行相关环境实现类似</span></span>发布平台/用户执行`kill PID` 优雅停机。<span data-type="color" style="color:rgb(38, 38, 38)"><span data-type="background" style="background-color:rgb(255, 255, 255)">运行时上下文 RpcRuntimeContext 静态初始化块注册 </span></span>ShutdownHook 函数：

```java
static {
    ...
    // 增加jvm关闭事件
    if (RpcConfigs.getOrDefaultValue(RpcOptions.JVM_SHUTDOWN_HOOK, true)) {
        Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
            @Override 
            public void run() {
                if (LOGGER.isWarnEnabled()) {
                    LOGGER.warn("SOFA RPC Framework catch JVM shutdown event, Run shutdown hook now.");
                }
                destroy(false);
            }
        }, "SOFA-RPC-ShutdownHook"));
    }
}
```

注册本身很简单，重要的是 destroy 方法实际上做的事情非常多。按照先后顺序，大致包含如下几个部分。



![image | left](https://res.cloudinary.com/lyp/image/upload/v1544522290/hugo/blog.github.io/sofa-rpc/%E4%BC%98%E9%9B%85%E5%85%B3%E9%97%AD%E5%89%96%E6%9E%90/1538233199212-5d914a83-fc54-4300-a6dc-ff4734631c66.png "")



<span data-type="color" style="color:rgb(38, 38, 38)"><span data-type="background" style="background-color:rgb(255, 255, 255)">RpcRuntimeContext 销毁服务优雅关闭完整流程：</span></span>

1. 设置 RPC 框架运行状态修改为正在关闭，表示当前线程不再处理 RPC 服务请求；
2. 遍历<span data-type="color" style="color:rgb(38, 38, 38)"><span data-type="background" style="background-color:rgb(255, 255, 255)">运行时上下文</span></span>关闭资源的销毁钩子，进行注册销毁器清理资源前期准备工作；
3. 获取发布的服务配置反注册服务提供者，向指定注册中心批量执行取消服务注册；
4. 检查<span data-type="color" style="color:rgb(38, 38, 38)"><span data-type="background" style="background-color:rgb(255, 255, 255)">当前服务端连接和队列任务，先把队列任务处理完毕，再缓慢</span></span>关闭启动端口；
5. 关闭发布的服务，到注册中心取消服务发布，取消将处理器注册到服务端，清除服务发布配置缓存状态；
6. 关闭调用的服务，断开客户端连接取消服务调用，清除服务订阅配置缓存，到注册中心取消服务订阅；
7. 遍历注册中心配置逐一关闭注册中心，移除指定注册中心配置缓存；
8. 不可复用长连接管理器销毁连接，关闭客户端的公共连接资源，清理不可复用连接缓存；
9. 遍历 RPC 框架上下文已加载的模块，逐步卸载模块譬如负载均衡、链路追踪等；
10. 遍历<span data-type="color" style="color:rgb(38, 38, 38)"><span data-type="background" style="background-color:rgb(255, 255, 255)">运行时上下文</span></span>关闭资源的卸载钩子，进行注册销毁器清理资源后期收尾工作；
11. 清理全部缓存例如应用类加载器缓存、服务类加载器缓存以及方法对象缓存等；
12. 调整 RPC 框架运行状态更新为关闭完毕，<span data-type="color" style="color:rgb(38, 38, 38)"><span data-type="background" style="background-color:rgb(255, 255, 255)">运行时上下文释放资源关闭服务进程。</span></span>

## 作为服务端

总体设计包含非常多的优雅关闭步骤，这里我们再单独介绍一下作为服务端的时候，几个核心步骤的原理和流程，<span data-type="color" style="color:rgb(38, 38, 38)"><span data-type="background" style="background-color:rgb(255, 255, 255)">作为服务端，SOFARPC 关闭服务进程不能直接暴力关闭，而是逐步进行关闭。需要进行如下几个步骤：</span></span>

1. 反注册服务：注册中心工厂获取全部注册中心实例调用 batchUnRegister 方法批量取消服务注册，通知服务消费者监听器更新其服务提供者列表，避免服务消费者继续引用下线服务造成服务调用异常不可用现象。
2. 关闭端口：服务端工厂检查线程池 bizThreadPool 队列是否有正在执行的请求或者队列里有请求，线程组调用 shutdownGracefully 方法缓慢关闭远程服务端口，保证业务线程池队列请求先处理完毕再关闭线程池以及端口。
3. 销毁服务对象：根据发布/订阅服务配置关闭提供/调用的服务，调用 unExport/unRefer 方法进行取消服务发布/订阅，注册中心删除发布/订阅服务配置，清理发布/订阅服务配置缓存，防止产生 RPC 服务发布/订阅服务对象。



![image | center](https://res.cloudinary.com/lyp/image/upload/v1544522315/hugo/blog.github.io/sofa-rpc/%E4%BC%98%E9%9B%85%E5%85%B3%E9%97%AD%E5%89%96%E6%9E%90/1538979225121-bba00c97-6499-4d9a-8302-72f5ba8933ff.png "")


<span data-type="color" style="color:rgb(38, 38, 38)"><span data-type="background" style="background-color:rgb(255, 255, 255)">RpcRuntimeContext 销毁服务配置资源核心实现入口：</span></span>

```java
com.alipay.sofa.rpc.context.RpcRuntimeContext#destroy()
```

## 作为客户端
作为客户端，SOFARPC 通过<span data-type="color" style="color:rgb(38, 38, 38)"><span data-type="background" style="background-color:rgb(255, 255, 255)">实现 DestroyHook 销毁钩子接口提供优雅关闭的钩子，把 GracefulDestroyHook 关闭钩子注册到长连接管理器销毁客户端连接方法。客户端优雅关闭连接实际上是 </span></span>Cluster 的关闭，关闭调用的服务实现入口：

```java
com.alipay.sofa.rpc.client.AbstractCluster#destroy()
```

<span data-type="color" style="color:rgb(38, 38, 38)"><span data-type="background" style="background-color:rgb(255, 255, 255)">GracefulDestroyHook 钩子优雅关闭连接整体流程：</span></span>

* 销毁前准备断连：获取当前 Client 正在发送的调用数量和服务消费方断连超时时间配置，检查是否有正在调用的服务请求并且当前运行时上下文时间未到达指定超时时间，满足准备条件则当前线程<span data-type="color" style="color:rgb(79, 79, 79)"><span data-type="background" style="background-color:rgb(255, 255, 255)">睡眠10秒；</span></span>
* 销毁时释放资源：关闭重连线程 reconThread，关闭客户端长连接，清空当前存活+重试的客户端列表，多线程执行销毁已经建立的客户端长连接，逐步处理正在调用的服务请求并且下线服务调用请求操作。



![image | left](https://res.cloudinary.com/lyp/image/upload/v1544522335/hugo/blog.github.io/sofa-rpc/%E4%BC%98%E9%9B%85%E5%85%B3%E9%97%AD%E5%89%96%E6%9E%90/1538211227977-c08a44f7-a880-44bd-9059-18658cfff064.png "")


其中 GracefulDestroyHook 优雅关闭钩子销毁前准备断连操作：



![image | left](https://res.cloudinary.com/lyp/image/upload/v1544522355/hugo/blog.github.io/sofa-rpc/%E4%BC%98%E9%9B%85%E5%85%B3%E9%97%AD%E5%89%96%E6%9E%90/1538199225950-5c251e8f-50ad-4936-b71f-2b8ab5cb98f3.png "")


是一个自旋检查的操作。

# Netty 优雅关闭

SOFARPC 在关闭自身 RpcServer 的时候，也会关闭启动的 Netty 服务端。这时候就涉及到 Netty 的优雅关闭。

N<span data-type="color" style="color:rgb(0, 0, 0)"><span data-type="background" style="background-color:rgb(255, 255, 255)">etty 作为高性能的异步 NIO 通信框架，负责各种通信协议的接入，解析和调度，SOFABolt 是</span></span><span data-type="color" style="color:rgb(36, 41, 46)"><span data-type="background" style="background-color:rgb(255, 255, 255)">基于 Netty 最佳实践的轻量、易用、高性能、易扩展的通信框架。当微服务应用进程优雅停机，</span></span><span data-type="color" style="color:rgb(0, 0, 0)"><span data-type="background" style="background-color:rgb(255, 255, 255)">作为基础通信框架的 Netty 需要考虑优雅停机控制，主要原因包括以下几方面因素</span></span>：

1. 尽快释放 NIO 线程，清理对象句柄资源；
2. 使用 flush 批量发送消息，需要发送积攒在通信队列等待发送的消息；
3. 正在进行 read 和 write 的消息需要继续处理；
4. NioEventLoop 线程调度器配置的定时任务需要执行或者清理。

这里是 Netty底层的实现逻辑，我们只要知道在关闭 Server的时候，需要进行相应的方法调用即可。



![image | center](https://res.cloudinary.com/lyp/image/upload/v1544522376/hugo/blog.github.io/sofa-rpc/%E4%BC%98%E9%9B%85%E5%85%B3%E9%97%AD%E5%89%96%E6%9E%90/1538140798221-eb8e6c9f-5f0a-4a4f-88d0-8cb989c2b57a.png "")



可以看到

1. 设置 <span data-type="color" style="color:rgb(47, 47, 47)"><span data-type="background" style="background-color:rgb(255, 255, 255)">NioEventLoop </span></span>线程状态修改为 ST\_SHUTTING\_DOWN，表示当前线程不再处理请求消息；
2. 确认关闭操作：将通信队列等待发送或者正在发送的消息发送完毕，把已经到期或者关闭超时之前到期的定时任务执行结束，把用户自定义注册到 <span data-type="color" style="color:rgb(47, 47, 47)"><span data-type="background" style="background-color:rgb(255, 255, 255)">NioEventLoop </span></span>线程的 ShutdownHook 关闭钩子执行完成；
3. 清理资源操作：把<span data-type="color" style="color:rgb(47, 47, 47)"><span data-type="background" style="background-color:rgb(255, 255, 255)">注册到</span></span>多路复用器 Selector <span data-type="color" style="color:rgb(47, 47, 47)"><span data-type="background" style="background-color:rgb(255, 255, 255)">的 Channel </span></span>释放，持有多路复用器 Selector 去注册和关闭，通信队列和定时任务清空取消，<span data-type="color" style="color:rgb(47, 47, 47)"><span data-type="background" style="background-color:rgb(255, 255, 255)">修改 NioEventLoop 线程状态为 ST_TERMINATED 关闭线程</span></span>。

其中，Netty 的优雅停机核心实现入口：

```java
io.netty.channel.EventLoopGroup#shutdownGracefully()
```

# SOFABoot 优雅关闭
一个完整的微服务可能不仅仅包括SOFARPC，还可能会用到各种各样的中间件，也涉及到各种流量调度等行为，所以<span data-type="color" style="color:rgb(38, 38, 38)"><span data-type="background" style="background-color:rgb(255, 255, 255)">优雅关闭是需要和发布平台联动的。如果强制 kill， 那么目前的这些优雅关闭的方案都不会生效。</span></span>

所以在<span data-type="color" style="color:rgb(38, 38, 38)"><span data-type="background" style="background-color:rgb(255, 255, 255)">后续的 </span></span>SOFABoot 版本中我们会增加接收一套完整的运维API，方便发布管控平台进行调用。SOFABoot 接收通过接收「关闭运维指令」而不是单纯依赖<span data-type="color" style="color:rgb(38, 38, 38)"><span data-type="background" style="background-color:rgb(255, 255, 255)"> ShutdownHook 逻辑</span></span>，然后触发各个中间件的优雅关闭行为，其中就包括SOFAPRC的主动反注册服务发布和服务调用等关闭动作<span data-type="color" style="color:rgb(38, 38, 38)"><span data-type="background" style="background-color:rgb(255, 255, 255)">，各个中间件的优雅关闭执行完成后，SOFABoot 进程再退出。</span></span>

# 总结

本文从进程的优雅关闭，到 SOFARPC 的优雅关闭支持，并详细介绍 Netty 优雅关闭的原理。在设计优雅关闭的时候，可以考虑按照如下几个约定来进行实现。

(1)应用能够支持优雅停机   
(2)优先注销注册中心注册的服务实例   
(3)待停机的服务应用的接入点标记拒绝服务   
(4)上游服务支持故障转移因优雅停机而拒绝的服务   
(5)根据实际业务场景提供适当的停机接口。  



----------------
文章转自[【剖析 | SOFARPC 框架】之SOFARPC 优雅关闭剖析](https://www.sofastack.tech)


注意: 由于原文章链接发生变更，因此将链接更新为 sofastack 官网，可在官网查询相关文章.
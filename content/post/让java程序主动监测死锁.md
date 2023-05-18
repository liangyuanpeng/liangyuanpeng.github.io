---
layout:     post 
slug:      "java_daed_lock_healthcheck"
title:      "让java程序主动监测死锁"
subtitle:   ""
description: "你要偷偷学会让程序主动监测死锁,然后惊艳所有人!"
date:       2021-04-14
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags:
    - jvm 
    - metrics
categories: 
    - TECH
---  

# 前言  

SpringBoot2.x 引入了 Micrometer,重点支持了 tag,而 tag 是 prometheus 和 influxdb 这类新兴监控存储相关中间件天然特性.  

而本文主要讲述检测程序中是否有死锁发生,这部分使用的是 dropwizard-metrics 的 metrics-healthchecks 来实现的.  

# 死锁检测配置  

首先引入对应的包依赖,maven:  

```xml
  <dependency>
            <groupId>io.dropwizard.metrics</groupId>
            <artifactId>metrics-healthchecks</artifactId>
            <version>4.1.19</version>
  </dependency>
  <dependency>
            <groupId>io.dropwizard.metrics</groupId>
            <artifactId>metrics-jvm</artifactId>
            <version>4.1.19</version>
  </dependency>
```   

```java
String healthCheckName = "thread_dead_lock";
HealthCheckRegistry healthCheckRegistry = new HealthCheckRegistry();
healthCheckRegistry.register(healthCheckName,new ThreadDeadlockHealthCheck());  
healthCheckRegistry.runHealthCheck(healthCheckName).isHealthy();
```  

这样就加入了一个死锁检测,每次运行`healthCheckRegistry.runHealthCheck(healthCheckName).isHealthy()`时就可以知道当前程序是否有死锁了.

```java
    protected  final ScheduledThreadPoolExecutor SCHEDULE_EXECUTOR = new ScheduledThreadPoolExecutor(1);
    public io.micrometer.core.instrument.MeterRegistry meterRegistry;
...
            AtomicInteger current = new AtomicInteger(healthCheckRegistry.runHealthCheck(healthCheckName).isHealthy()?1:0);
            SCHEDULE_EXECUTOR.scheduleAtFixedRate(()->{
                if(meterRegistry.find(healthCheckName).gauge()==null){
                    meterRegistry.gauge(healthCheckName,current);
                }else{
                    HealthCheck.Result result = healthCheckRegistry.runHealthCheck(healthCheckName);
                    if(!result.isHealthy()){
                        log.error("run healthCheck:"+result.getMessage());
                    }
                    current.set(result.isHealthy()?1:0);
                }
            },0,30, TimeUnit.SECONDS);
```  

这样就可以定时检测程序中是否有死锁存在,如果有,`thread_dead_lock`这个 metrics 会显示为0.也可以通过`HealthCheck.Result result`这个对象,把死锁相关信息打印在程序 log 中,这样可以将信息收集到专门的日志系统去.比如 Elasticsearch.  

# 原理 

需要配置的内容和编写的代码并不多,只需要少量代码就可以做到检测程序死锁了.那么这一切是如何做到的呢?一起来看一下.  

首先从最外面的入口点进源码看看逻辑.  

点进`ThreadDeadlockHealthCheck`类看看有什么代码,可以看到只有很少的代码,有一个重写的`check`方法:  

```java
public class ThreadDeadlockHealthCheck extends HealthCheck {
    private final ThreadDeadlockDetector detector;

    /**
     * Creates a new health check.
     */
    public ThreadDeadlockHealthCheck() {
        this(new ThreadDeadlockDetector());
    }

    /**
     * Creates a new health check with the given detector.
     *
     * @param detector a thread deadlock detector
     */
    public ThreadDeadlockHealthCheck(ThreadDeadlockDetector detector) {
        this.detector = detector;
    }

    @Override
    protected Result check() throws Exception {
        final Set<String> threads = detector.getDeadlockedThreads();
        if (threads.isEmpty()) {
            return Result.healthy();
        }
        return Result.unhealthy(threads.toString());
    }
}

```  

从`getDeadlockedThreads`方法名可以看明白这个方法是获取当前死锁线程集合.点进去看看是如何获取的.感觉离原理越来越近了.  

```java
public Set<String> getDeadlockedThreads() {
        final long[] ids = threads.findDeadlockedThreads();
        if (ids != null) {
            final Set<String> deadlocks = new HashSet<>();
            for (ThreadInfo info : threads.getThreadInfo(ids, MAX_STACK_TRACE_DEPTH)) {
                final StringBuilder stackTrace = new StringBuilder();
                for (StackTraceElement element : info.getStackTrace()) {
                    stackTrace.append("\t at ")
                            .append(element.toString())
                            .append(String.format("%n"));
                }

                deadlocks.add(
                        String.format("%s locked on %s (owned by %s):%n%s",
                                info.getThreadName(),
                                info.getLockName(),
                                info.getLockOwnerName(),
                                stackTrace.toString()
                        )
                );
            }
            return Collections.unmodifiableSet(deadlocks);
        }
        return Collections.emptySet();
    }
```  

点进去后发现是通过`final long[] ids = threads.findDeadlockedThreads();`获取到死锁的线程 id 数字,看看`threads`变量是一个什么东西.  

```java 
private final ThreadMXBean threads;
```  

可以看到这是 ThreadMXBean 提供的方法,而这个类是`java.lang.management`包下的.这个包是JDK提供的一些用于检测 JVM 状态的 API 类.可以拿到当前 JVM 的内存,GC,线程,class 等各种信息.  

我们这里是用的其中一种MXBean类:ThreadMXBean,来获取线程相关的信息.感兴趣的可以自己去研究下,例如获取内存信息的一个类:`MemoryMXBean`,这里不展开讲述.  

细心的同学可以发现我们目前已经拿到了死锁线程的ID数组,如果数组有内容其实就说明当前程序有发生死锁.

后面的逻辑是拿一些死锁线程具体的信息,例如线程名,锁名,锁持有者.  

因此对于没有接入或不希望接入`dropwizard.metrics`的同学来说,完全可以自己实现一个检测程序是否有死锁的逻辑.    

# 总结  

对于当前没有检测死锁的程序来说,发生死锁时所产生的未知影响是很大的.而如果程序能够自己定时检测是否有死锁并且发生时能够快速的发出警告,很大程度上可以避免一些不必要的损失.  

如果你的程序当前还没有死锁检测,赶紧偷偷加上监控死锁的逻辑,然后惊艳所有人!!!

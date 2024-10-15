---
layout:     post 
slug:      "jib-springboot-docker-maven"
title:      "不用安装docker也能构建docker镜像"
subtitle:   ""
description: "构建java的docker镜像,用jib,简单粗暴.."  
date:       2020-02-18
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags: 
    - docker
    - jib
    - java
    - maven
    - container
    - springboot
categories: 
    - cloudnative
---


# 前提

1. [docker](https://www.docker.com/get-started)  
2. 容器镜像仓库  

 这里举例可以公用的两个  
 [dockerhub](https://hub.docker.com/)  
 [阿里云容器镜像服务](https://cr.console.aliyun.com/cn-beijing/instances/repositories)  

## 前言  

本文主要介绍的是 google 开源的一个 java 领域的 docker 构建工具jib.  

目前在[github](https://github.com/GoogleContainerTools/jib)上的 start 有 8.5k,fork 有 784,是一款非常方便的 java 领域 docker 构建工具.  

亮点是不需要 Docker daemon,意味着即使本地没有安装 docker 也能通过 jib 构建 docker 镜像,并且可以构建符合[OCI](https://github.com/opencontainers/image-spec)规范的镜像.  

官方支持三种方式:  
1. [maven插件](https://github.com/GoogleContainerTools/jib/blob/master/jib-maven-plugin)  
2. [grade插件](https://github.com/GoogleContainerTools/jib/blob/master/jib-gradle-plugin)  
3. [jib代码库](https://github.com/GoogleContainerTools/jib/tree/master/jib-core)  

本文使用的是 springboot 项目通过 maven 插件的方式进行讲述.  

讲一下第三种,Jib 代码库,这种方式可以用于自研平台构建 java 的 Docker 服务.

## 配置pom.xml  

添加下面这段标准标签到文件中  

```xml
<build>
    <plugins>
      ...
      <plugin>
        <groupId>com.google.cloud.tools</groupId>
        <artifactId>jib-maven-plugin</artifactId>
        <version>2.0.0</version>
        <configuration>
          <from>
					  <image>registry.cn-hangzhou.aliyuncs.com/dragonwell/dragonwell8:8.1.1-GA_alpine_x86_64_8u222-b67</image>
					</from>
          <to>
            <image>imageName</image>
          </to>
        </configuration>
      </plugin>
      ...
    </plugins>
  </build>
```  

上述内容配置了一个结果镜像名称`imageName`,也就是最终构建成的 docker 镜像地址,包含`容器仓库地址/镜像名称:版本号`例如`registry.cn-beijing.aliyuncs.com/lyp/lanbox:v1.0`,如果仓库地址不填则默认为[dockerhub](https://hub.docker.com/).  

另外还配置了一个基础镜像`registry.cn-hangzhou.aliyuncs.com/dragonwell/dragonwell8:8.1.1-GA_alpine_x86_64_8u222-b67`,可以认为等同于 Dockerfile 中的 From 语句.  

如果基础镜像或目标镜像需要账号密码的话,在 from 标签或 to 标签添加一个认证信息即可,有三种方式:  

1. 配置在 docker 的配置文件中  
2. 配置在 maven 的 setting.xml 中
3. 直接在 pom.xml 文件配置  

本文使用第三种,即在 from 标签或 to 标签下添加一个用于认证信息的 auth 标签,例如:   
``` xml
<from>
  ...
  <auth>
    <username>lank8scn</username>
    <password>lank8scn</password>
  <auth>
  ...
</from>  
```  

也可以方便的通过环境变量的方式进行配置:  
```xml
<from>
  ...
  <auth>
    <username>${env.REGISTRY_FROM_USERNAME}</username>
    <password>${env.REGISTRY_FROM_PASSWORD}</password>
  <auth>
  ...
</from> 
```  

其中``${env.}`这一部分是固定的,后面跟着实际环境变量.  

还可以通过系统属性的方式:  
```shell
mvn compile jib:build \
    -Djib.to.image=ghcr.io/liangyuanpeng/lank8scn:latest \
    -Djib.to.auth.username=lank8scn \
    -Djib.to.auth.password=lank8scn
```  

在进行构建时通过参数方式传递认证信息,是不是很方便呢?  

继续看`configuration`下的标签有`container`配置:  
这个标签主要配置目标容器相关的内容,比如:  
1. appRoot -> 放置应用程序的根目录,用于 War 包项目  
2. args -> 程序额外的启动参数.  
3. environment -> 用于容器的环境变量  
4. format -> 构建 OCI 规范的镜像  
5. jvmFlags -> JVM 参数  
6. mainClass -> 程序启动类  
7. ports -> 容器开放端口  
...  

还有其他内容具体可以参考[container](https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin#container-object).  

有一个注意点是阿里的容器镜像服务不支持 OCI 镜像,所以如果选择使用阿里的容器镜像服务记得将 OCI 格式取消,默认是取消的.  

另外,JVM 参数可以通过环境变量配置动态内容,所以不需要计划将所有启动参数写死在`jvmFlags`标签里面.  

例如启动容器时指定使用 G1 回收器,`docker run -it -e JAVA_TOOL_OPTIONS="-XX:+UseG1GC" -d  registry.cn-beijing.aliyuncs.com/lyp/lanbox:v1.0`.  

所有配置项完成后运行 mvn 命令`mvn compile jib:build` 开始构建 docker 镜像.  

如果看到类似这样的信息说明就成功了:  
```shell
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  42.598 s
[INFO] Finished at: 2020-02-18T23:30:53+08:00
[INFO] ------------------------------------------------------------------------
```

完整的一个例子可以在 GitHub 上查看并下载[https://github.com/FISHStack/hello-spring-cloud](https://github.com/FISHStack/hello-spring-cloud),欢迎多多交流.


# 目前我还将Jib用于存储和下载

将 Rocksdb 生成的文件打包成容器镜像,上传到容器镜像仓库, 在下一次使用时再使用 Jib 下载容器镜像，然后解压出来使用。

目前是两个用处:
- 当做缓存持久化,需要时将内容下载下来做缓存预热
- CI 中下载 Rocksdb 的文件,用来跑测试逻辑 ( rocksdb 作为一个数据库)
- 将一个常用文件(例如 trivy )打包成容器镜像,然后使用 JIB 来下载容器镜像.(可以使用 ORAS 来完成这件事,但目前 gitea 和 阿里云容器镜像仓库个人版不支持 OCI)

# 小技巧

目前我们有 CI 流程需要在 JIB 构建完成容器镜像后将这个信息回复到对应 PR 里面,方便测试和开发使用,其实 JIB 会在构建镜像完成之后在 target 目录下生成三个镜像相关的文件: `jib-image.digest` `jib-image.id`以及`jib-image.json`,其中 `jib-image.json` 就包括了容器镜像的名称以及 Tag 信息,足够使用了.

下面是一个 `jib-image.json` 文件的示例内容:

```json
{
    "image":"ghcr.io/liangyuanpeng/lank8scn:v1",
    "imageId":"sha256:f06986bb766f81463b6f9f891797787f4ea0d4fb8308e6ae286c2f05e2e77a85",
    "imageDigest":"sha256:6467366239c971f6a0fa0eb80bb478637ec9730993524045f4b9258f22b47e5c",
    "tags":[
        "v1"
    ]
}
```

下面是一个简单的示例测试代码,用于测试 springboot 应用的启动是否成功,大部分都是可以通用的.
```java

    @Data
    static class JibContainerObj implements Serializable {
        private String image;
        private String imageId;
        private String imageDigest;
        private boolean imagePushed;
        private List<String> tags = Collections.emptyList();
        public JibContainerObj(){

        }
    }

    @Test
    public void testStart() throws IOException {
        boolean checkContainer = Boolean.valueOf(System.getProperty("lan.containers.check", "false"));
        if(!checkContainer){
            return;
        }
        int containerCheckPort = Integer.valueOf(System.getProperty("lan.containers.check.port", "8042"));
        String imgpath = System.getProperty("lan.containers.jib.imgpath", "/jib-image.json");
        String img = System.getProperty("lan.containers.jib.img", "");

        if(StringUtils.isBlank(img) && StringUtils.isBlank(imgpath)){
            return;
        }
        if(StringUtils.isBlank(img)){
            ObjectMapper objectMapper = new ObjectMapper();
            InputStream inputStream = getClass().getResourceAsStream(imgpath);
            Assertions.assertNotNull(inputStream);
            JibContainerObj jibContainerObj = objectMapper.readValue(inputStream, new TypeReference<JibContainerObj>(){});
            log.info("jibContainerObj:{}",jibContainerObj);
            img =jibContainerObj.getImage();
        }

        log.info("begin testing container for:{}",img);
        Map map = Maps.newHashMap();
        map.put("logging.config","classpath:logback-dev.xml");
        GenericContainer container = new GenericContainer<>(DockerImageName.parse(img))
                .waitingFor(new HttpWaitStrategy()
                        .forPath("/actuator/prometheus")
                        .forPort(containerCheckPort)
                        .forStatusCode(200))
                .withEnv(map)
                .withExposedPorts(8042);
        container.start();

    }
```

如果你的 springboot 版本大于 2.3,我会推荐你使用 `/actuator/liveness` 和 `/actuator/readiness` 来代替 `/actuator/prometheus` 路径进行测试.

开启 liveness 和 readiness 需要如下配置:

```yaml
management:
  endpoint:
    health:
      probes:
        enabled: true
  health:
    livenessstate:
      enabled: true
    readinessstate:
      enabled: true
```

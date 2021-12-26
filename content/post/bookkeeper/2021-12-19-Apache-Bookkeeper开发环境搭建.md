---
layout:     post 
slug:      "apache-bookkeeper-env-for-dev"
title:      "Apache-Bookkeeper开发环境搭建"
subtitle:   ""
description: ""
date:       2021-12-19
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612709780/hugo/blog.github.io/pexels-matt-hardy-2568001.jpg"
published: true
tags:
    - bookkeeper
categories: [ TECH ]
---    

# 打包BK  

```
mvn package -DsipTests=true
```  

顺利的话就成功的打包好了.  

```log
[INFO] Apache BookKeeper :: Tests :: Backward Compatibility :: Test upgrade between yahoo custom version and current SUCCESS [  0.373 s]
[INFO] Apache BookKeeper :: Tests :: Backward Compatibility :: Test Bouncy Castle Provider load non FIPS version SUCCESS [  0.484 s]
[INFO] Apache BookKeeper :: Tests :: Integration .......... SUCCESS [  0.013 s]
[INFO] Apache BookKeeper :: Tests :: Integration :: Smoke test SUCCESS [  0.547 s]
[INFO] Apache BookKeeper :: Tests :: Integration :: Standalone test SUCCESS [  0.289 s]
[INFO] Apache BookKeeper :: Tests :: Integration :: Cluster test SUCCESS [  0.667 s]
[INFO] Apache BookKeeper :: Tests :: Bash Scripts Test .... SUCCESS [  5.297 s]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  09:55 min
[INFO] Finished at: 2021-12-26T20:57:56+08:00
[INFO] ------------------------------------------------------------------------
```  

我这里是第一次打包,包含下载依赖花费了近10分钟.

## 可能会出现的问题

### 提示没有g++  

```log
[ERROR] Failed to execute goal com.github.maven-nar:nar-maven-plugin:3.5.2:nar-compile (default-nar-compile) on project circe-checksum: NAR: Compile failed: Could not launch g++: java.io.IOException: Cannot run program "g++" (in directory "/home/oem/repo/git/bookkeeper/circe-checksum/src/main"): error=2, No such file or directory -> [Help 1]
[ERROR] 
[ERROR] To see the full stack trace of the errors, re-run Maven with the -e switch.
[ERROR] Re-run Maven using the -X switch to enable full debug logging.

```  

直接用命令安装g++即可,   

ubuntu:
```shell
sudo apt install -y g++
```  

# 注意  
本文还在持续创作当中
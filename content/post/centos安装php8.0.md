---
layout:     post 
slug:      "centos-install-php"
subtitle:   "centos安装php8.0"
title:   "centos安装php8.0"
description: " "
date:       2021-03-23
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags:
    - ops
    - php
categories: 
    - TECH
---  

# 动机  

之前一直没有接触PHP的经验,需要安装PHP是由于要搭建`Flarum`论坛,找了一圈,类似这种论坛的实现都是PHP做的,虽然PHP是世界上最好的语言,但我不太需要,很是无语,记录下来方便以后回头来看,我也是接触了世界上最好的语言的人了.  

# 安装方式  

安装方式和一般软件安装一样,要么是自己编译安装要么是使用系统管理命令安装(`yum/apt`),这里用yum来安装.  

# 查看一下可安装的PHP版本  

执行以下命令:  
```shell
yum repolist all |grep php
```  

预期应该是返回可安装的PHP列表,但是我得到的确实一个提示:  
```
Repodata is over 2 weeks old. Install yum-cron? Or run: yum makecache fast
```  

原因是`镜像源过时了`,执行命令`yum makecache fast`即可.

如果还是没有查到PHP软件列表可以执行下两条命令加一下阿里源  
```shell
yum install epel-release -y
yum -y install https://mirrors.aliyun.com/remi/enterprise/remi-release-7.rpm
```  

```shell
remi-php74                          Remi's PHP 7.4 RPM repositor disabled
remi-php74-debuginfo/x86_64         Remi's PHP 7.4 RPM repositor disabled
remi-php74-test                     Remi's PHP 7.4 test RPM repo disabled
remi-php74-test-debuginfo/x86_64    Remi's PHP 7.4 test RPM repo disabled
remi-php80                          Remi's PHP 8.0 RPM repositor disabled
remi-php80-debuginfo/x86_64         Remi's PHP 8.0 RPM repositor disabled
remi-php80-test                     Remi's PHP 8.0 test RPM repo disabled
remi-php80-test-debuginfo/x86_64    Remi's PHP 8.0 test RPM repo disabled
```  

# 开始安装  

设置安装php8  
```shell
yum-config-manager --enable remi-php80
```  

安装相关依赖  
```shell
yum install  php-cli php-fpm php-mysqlnd php-zip php-devel php-gd php-mbstring php-curl php-xml php-pear php-bcmath php-json php-redis  --skip-broken -y
```  

校验当前PHP版本  
```
$ php --version
PHP 8.0.3 (cli) (built: Mar  2 2021 16:37:06) ( NTS gcc x86_64 )
Copyright (c) The PHP Group
Zend Engine v4.0.3, Copyright (c) Zend Technologies
```  

可以看到已经成功安装了PHP8.0了
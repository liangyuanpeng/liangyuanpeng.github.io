---
layout:     post 
title:      "deploy-bbs-flarum"
subtitle:   "部署轻论坛flarum"
description: " "
date:       2021-03-23
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: false
tags:
    - flarum
    - php
categories: 
    - TECH
---  


# 获取compose.phar 安装文件  

```shell
wget https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -O - -q | php -- --quiet
```  

```shell
[root@izj6c43cmod4v5uxuv12eaz flarum]# composer.phar create-project flarum/flarum . --stability=beta
Do not run Composer as root/super user! See https://getcomposer.org/root for details
Continue as root/super user [yes]? yes
Creating a "flarum/flarum" project at "./"
Installing flarum/flarum (v0.1.0-beta.16)
  - Downloading flarum/flarum (v0.1.0-beta.16)
  - Installing flarum/flarum (v0.1.0-beta.16): Extracting archive
Created project in /usr/local/flarum/.
Loading composer repositories with package information
Updating dependencies
Lock file operations: 118 installs, 0 updates, 0 removals
...
63 package suggestions were added by new dependencies, use `composer suggest` to see details.
Generating autoload files
65 packages you are using are looking for funding.
Use the `composer fund` command to find out more!
```  

创建flarum项目
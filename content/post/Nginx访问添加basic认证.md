---
layout:     post 
slug:      "nginx-basic-auth"
title:      "Nginx访问添加basic认证"
subtitle:   "Nginx访问添加basic认证"
description: " "
date:       2021-03-15
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612744351/hugo/blog.github.io/pexels-bruno-cervera-6032877.jpg"
published: false
tags:
    - nginx
categories: 
    - cloudnative
---  

# 配置文件

在server节点下添加配置  
```conf
server{
    ...
    auth_basic "请输入用户和密码"; # 验证时的提示信息
    auth_basic_user_file /etc/nginx/password; # 认证文件
    ...
}
```  

# 使用httpdpasswd生成帐号密码
```shell
[root@node123 ~]# htpasswd -c password admin
New password: 
Re-type new password: 
Adding password for user admin
[root@node123 ~]# cat password 
admin:$apr1$q8i4QEgQ$C.wCufSYdQivIJ0Vixk4T.
```

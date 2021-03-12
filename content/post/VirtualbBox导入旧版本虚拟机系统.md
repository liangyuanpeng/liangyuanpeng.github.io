---
layout:     post 
slug:      "virtualbox-imported-old-vm-system"
title:      "VirtualbBox导入旧版本虚拟机系统"
subtitle:   "VirtualbBox导入旧版本虚拟机系统"
description: " "
date:       2021-02-08
author:     "lyp"
image: "https://res.cloudinary.com/lyp/image/upload/v1612746030/hugo/blog.github.io/pexels-eva-elijas-5949232.jpg"
published: true
tags:
    - devops
    - 虚拟机
categories: 
    - DevOps
---

# 动机  

由于VirtualBox自动更新了导致打开了VirtualBox后之前的虚拟机都没显示出来了，需要重新找回之前的虚拟机。 

更新后的VirtualBox虚拟机是6.0版本。

# 找到旧版本虚拟机文件  

首先需要知道旧版本虚拟机都放在电脑的哪些地方，这里我使用的是Everything,这是我一贯使用的windows搜索软件，非常好用，可以去了解下。  

![search](https://res.cloudinary.com/lyp/image/upload/v1612746824/hugo/blog.github.io/other/everything-search-vbox.jpg)  

在windows上搜索`*.vbox`，找出旧版本虚拟机文件的位置  

# 注册旧版本虚拟机 

![registry](https://res.cloudinary.com/lyp/image/upload/v1612746921/hugo/blog.github.io/other/virtualbox-registry.jpg)

找到`VirtualBox->控制->注册`,会弹出文件选择框,找到对应的`vbox`文件,点击确定就可以了,旧版本虚拟机就注册成功了.
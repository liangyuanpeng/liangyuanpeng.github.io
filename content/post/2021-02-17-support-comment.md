---
layout:     post 
title:      "给hugo博客添加评论功能"
subtitle:   ""
description: "静态博客不像动态博客一样想要什么功能就写个代码实现，但是折腾一番还是可以满足日常需求的。"  
date:       2021-02-17
author:     "lyp"
image: "https://res.cloudinary.com/lyp/image/upload/v1543506262/hugo/blog.github.io/apache-rocketMQ-introduction/7046d2bf0d97278682129887309cc1a6.jpg"
published: true
tags: 
    - Hugo
    - 博客
    - 评论
    - utterances
categories: 
    - Tech
---  

# 缘由  

静态博客不像动态博客一样想要什么功能就写个代码实现，但是折腾一番还是可以满足日常需求的。本文主要讲述使用`utterances`给静态博客实现评论功能。  

# 了解utterances  

`utterances`是一款基于Github Issue的Github工具,优点主要是无广告、加载快、配置简单，轻量开源!由于我没有使用过其他评论工具的经验，因此只讲述一下`utterances`自身的优点，具体对比情况无法给出，但是看到有的博主表示之前使用`disqus`,但是广告多，加载也比较慢，体验了一把`utterances` 后，马上切换到`utterances`。相信`utterances`足够让我使用很久了。  

# 安装utterances  

由于`utterances`是一款Github App，因此[安装utterances](https://github.com/apps/utterances)非常简单，只需要授权特定repo权限给`utterances`就可以了,注意一个点：授权的这个repo必须是public的，可以选择多个repo，但是建议选择一个就可以了，也比较安全。  

给出我授权的repo作为参考，我是选择博客的repo作为`utterances`评论的存放点(在博客评论的内容都会以issue的形式发布在repo下).  

![https://res.cloudinary.com/lyp/image/upload/v1613534108/hugo/blog.github.io/blogfeature/blog11.png](https://res.cloudinary.com/lyp/image/upload/v1613534108/hugo/blog.github.io/blogfeature/blog11.png)  

到目前为止`utterances`就已经安装好了，接下来是需要在博客将评论的客户端显示出来。  

# 配置utterances评论显示  

可以配置在你希望显示评论的地方，这里给出一个简单的实现：配置在footer.html的顶部(显示在每篇文章的底部).  

![https://res.cloudinary.com/lyp/image/upload/v1613535215/hugo/blog.github.io/blogfeature/blog12.png](https://res.cloudinary.com/lyp/image/upload/v1613535215/hugo/blog.github.io/blogfeature/blog12.png)   

![https://res.cloudinary.com/lyp/image/upload/v1613535402/hugo/blog.github.io/blogfeature/blog13.png](https://res.cloudinary.com/lyp/image/upload/v1613535402/hugo/blog.github.io/blogfeature/blog13.png)

把具体的仓库改成自己授权给utterances的仓库即可。  

```
<script src="https://utteranc.es/client.js"
repo="liangyuanpeng/liangyuanpeng.github.io"
issue-term="title"
theme="github-light"
crossorigin="anonymous"
async>
</script>  
```    

这是当前最简单的方式，更优雅的方式是以配置文件的方式实现，例如：  

html中的配置模板
```
{{ if .Site.Params.utteranc.enable }}
<script src="https://utteranc.es/client.js"
repo="{{ .Site.Params.utteranc.repo }}"
issue-term="{{ .Site.Params.utteranc.issueTerm }}"
theme="{{ .Site.Params.utteranc.theme }}"
crossorigin="anonymous"
async>
</script>
{{ end }}
```  

配置文件中的配置项：  
```
## 配置 utteranc评论,教程参考 https://utteranc.es/
[params.utteranc]
  enable = false
  repo = "liangyuanpeng/liangyuanpeng.github.io" ##换成自己得
  issueTerm = "title"
  theme = "github-light"
```  

这样的话需要修改仓库或者主题都可以很方便的修改一下配置文件就可以了，同时也可以选择不开启评论。  

评论显示的主题有多种，具体可以在[utterances官方](https://utteranc.es/?installation_id=14775258&setup_action=install)查看，这里给出当前时间点的一个列表：   

1. github-light
2. github-dark
3. github-dark-orange
4. icy-dark
5. dark-blue
6. photon-dark  
7. preferred-color-scheme
8. boxy-light  

映射到issue也有几种方式:  

1. pathname
2. url
3. title
4. og:title
5. issue-number
6. specific-term  

我选择的是title的方式，对应评论会以文章标题作为issue的标题创建在对应仓库下。    

到目前为止，给hugo静态博客添加评论的功能已经做好了，不需要服务器就可以拥有评论功能，实用!



---
layout:     post 
slug:      "hugo-slug-url"
title:      "Hugo博客SEO优化-URL和标题区分开"
subtitle:   "Hugo博客SEO优化-URL和标题区分开"
description: " "
date:       2021-03-11
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612744351/hugo/blog.github.io/pexels-bruno-cervera-6032877.jpg"
published: true
tags:
    - Hugo
    - Blog
categories: 
    - TECH
---  

# 前言  

Hugo博客默认情况下你的`md`文件是什么名字那么在网站上点击对应博客时URL就显示什么,但是我们将URL复制发给别人时中文就会显示一串看不懂的内容,并且不确定中文对SEO的影响,因此最好URL还是显示简短的英文就好。  

# 解决方案  

## md文件名不带中文  

文件名不带中文那么URL不就不会显示中文了吗？这样是可以解决这个问题,但是在我们写了很多篇博客之后我们希望找到某一篇具体的博客时就不太好找了，一看`md`文件列表,全是英文或数字,毕竟我们的母语不是英语,这是一个很大的问题。如果你可以接受的话可以这样做,但是如果你希望有更好的方案，比如md文件是中文但是URL显示英文,那么就看看下一个方案吧.  

## slug  

只需要在顶部加一个slug参数就可以处理这个问题.  

```yaml
layout:     post 
slug:      "openkruise-column"
title:      "OpenKruise专栏介绍"
subtitle:   "OpenKruise专栏介绍"
description: " "
date:       2021-02-07
author:     "梁远鹏"
```

例如上面这样一个配置的例子,title是`OpenKruise专栏介绍`,slug是`openkruise-column`,那么在URL中博客的地址就是`域名/.../openkruise-column`,这样就达到了我们想要的效果.

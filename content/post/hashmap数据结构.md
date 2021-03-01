---
layout:     post 
title:      "理解HashMap"
subtitle:   ""
description: "从名字上看就知道HashMap是基于Hash算法实现的一种map，一般称之为散列表(hash table)"
date:       2019-01-02
author:     "lyp"
image: "https://res.cloudinary.com/lyp/image/upload/v1544363190/hugo/blog.github.io/19375a83fc004035fb1102a4551f2287.jpg"
published: false
tags:
    - HashMap
    - Map 
    - Hash
    - 数据结构
    - java
categories: 
    - 中间件
---

## 前言
从名字上看就知道HashMap是基于Hash算法实现的一种map，一般称之为散列表(hash table)。  

## 实现理解

hashmap内部实现的数据结构是数组+单链表，一般称数组的每一个元素为一个bucket(hash桶)。  


![](https://res.cloudinary.com/lyp/image/upload/v1546398133/hugo/blog.github.io/data-structure/map/hashmap1.png)

那么hashmap添加元素的流程是怎么样的呢?  
```
map.put("a","hello");  
```  

 首先计算元素"a"的一个hash值，在根据(table.length - 1) & hash计算出元素"a"在数组中的下标，如果该下标位置没有元素，则将元素放入对应的bucket中，如果这个bucket有元素了，则将新添加的元素放入该下标位置的链表的尾部





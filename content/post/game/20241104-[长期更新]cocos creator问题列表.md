---
layout:     post 
slug:      "cocos-creator"
title:      "[长期更新]cocos creator问题列表"
subtitle:   ""
description: "cocos creator 问题列表,欢迎投稿."
date:       2024-11-04
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags:
    - typescript
    - cocos creator
categories: 
    - TECH
---


# 说明

本文主要收集 cocos creator 遇到的一些常见问题,欢迎对本文进行投稿你认为好的场景或问题.

# 问题来了


## Can not load the scene 'main' because it was not in the build settings before playing.

需要在 cocos creator 中选中对应的 main 场景.


# 抖音小游戏

## 抖音小游戏免费提供的KV云存储数据导出

给官方提了工单,回复是可以导出,但进一步想咨询一下文档的地址却得不到回复了.


# typescript

## TypeError: Cannot read properties of undefined (reading 'xxx')

```typescript

private static _instance: RequestManager;

public static get instance () {
        if (this._instance) {
            return this._instance;
        }
        console.log("request manager init...")
        this._instance = new RequestManager();
    }
```

如上述所示,实现 RequestManager 一个单例,每次用的时候直接使用 `instance`,但由于这里没有 return 对应的变量,因此在使用 `instance` 方法的时候就会报错,解决方案是 return 对应变量就可以了.

```diff

private static _instance: RequestManager;

public static get instance () {
        if (this._instance) {
            return this._instance;
        }
        console.log("request manager init...")
        this._instance = new RequestManager();
+++        return this._instance;
    }
```


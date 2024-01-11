---
layout:     post 
slug:      "kubernetes-kep-2340-ConsistentListFromCache"
title:      "kubernetes-kep-2340-ConsistentListFromCache"
subtitle:   ""
description: "kubernetes-kep-2340-ConsistentListFromCache"
date:       2023-12-29
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: false
wip: true
tags:
    - k8s
    - kubernetes
    - cncf
    - golang
    - kep
categories: 
    - kubernetes
---

# 注意

目前还只是一篇笔记,查看源码理解中,欢迎一起交流.

# KEP-2340-ConsistentListFromCache 是什么

https://github.com/kubernetes/enhancements/tree/master/keps/sig-api-machinery/2340-Consistent-reads-from-cache

# 笔记

首先看一下用到 ConsistentListFromCache 的都有哪一些地方:

- kube-features.go  定义功能开关
- cacher.go

```golang
func shouldDelegateList(opts storage.ListOptions) bool {
    ...
    consistentListFromCacheEnabled := utilfeature.DefaultFeatureGate.Enabled(features.ConsistentListFromCache)
    ...
}
```

- watch_cache.go

```golang
func (w *watchCache) WaitUntilFreshAndList(ctx context.Context, resourceVersion uint64, matchValues []storage.MatchValue) (result []interface{}, rv uint64, index string, err error) {
	if utilfeature.DefaultFeatureGate.Enabled(features.ConsistentListFromCache) && w.notFresh(resourceVersion) {
		w.waitingUntilFresh.Add()
		err = w.waitUntilFreshAndBlock(ctx, resourceVersion)
		w.waitingUntilFresh.Remove()
	} else {
		err = w.waitUntilFreshAndBlock(ctx, resourceVersion)
	}
    ...
}
```

- list_work_estimator.go

```golang
func shouldListFromStorage(query url.Values, opts *metav1.ListOptions) bool {
	resourceVersion := opts.ResourceVersion
	match := opts.ResourceVersionMatch
	consistentListFromCacheEnabled := utilfeature.DefaultFeatureGate.Enabled(features.ConsistentListFromCache)
    ...
}
```


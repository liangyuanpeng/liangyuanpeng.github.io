---
layout:     post 
slug:      "victoriaMetrics-config-note-long-term"
title:      "[长期更新]victoriaMetrics常见配置或问题"
subtitle:   "[长期更新]victoriaMetrics常见配置或问题"
description: " "
date:       2024-01-07
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags:
    - victoriaMetrics
categories: 
    - cloudnative
---  

# 说明

本文主要收集常见场景下 victoriaMetrics 配置以及遇到的一些常见问题,欢迎对本文进行投稿你认为好的场景配置或问题.

# victoriaMetrics 从已有数据中启动报错 FATAL: incomplete vmrestore run; run vmrestore again or remove lock file

在我的 victoriaMetrics pod 通过备份好的数据启动时报错了.

```shell
lan@lan:~/lan/$ k logs vmetrics-lan
Defaulted container "vmetrics" out of: vmetrics, tools, restore (init)
2024-01-07T03:41:07.619Z        info    VictoriaMetrics/lib/logger/flag.go:12   build version: victoria-metrics-20231212-224619-tags-v1.96.0-0-g304fe0565
2024-01-07T03:41:07.620Z        info    VictoriaMetrics/lib/logger/flag.go:13   command-line flags
2024-01-07T03:41:07.620Z        info    VictoriaMetrics/app/victoria-metrics/main.go:70 starting VictoriaMetrics at ":8428"...
2024-01-07T03:41:07.620Z        info    VictoriaMetrics/app/vmstorage/main.go:108       opening storage at "victoria-metrics-data" with -retentionPeriod=1
2024-01-07T03:41:07.620Z        panic   VictoriaMetrics/lib/storage/storage.go:191      FATAL: incomplete vmrestore run; run vmrestore again or remove lock file "/victoria-metrics-data/restore-in-progress"
panic: FATAL: incomplete vmrestore run; run vmrestore again or remove lock file "/victoria-metrics-data/restore-in-progress"

goroutine 1 [running]:
github.com/VictoriaMetrics/VictoriaMetrics/lib/logger.logMessage({0xbd5869, 0x5}, {0xc00007eb80, 0x75}, 0x1?)
        github.com/VictoriaMetrics/VictoriaMetrics/lib/logger/logger.go:301 +0xa91
github.com/VictoriaMetrics/VictoriaMetrics/lib/logger.logLevelSkipframes(0x1, {0xbd5869, 0x5}, {0xc147ba?, 0xc0000ee2c0?}, {0xc0002116f0?, 0xbc10c0?, 0xc0000c40d0?})
        github.com/VictoriaMetrics/VictoriaMetrics/lib/logger/logger.go:141 +0x1a5
github.com/VictoriaMetrics/VictoriaMetrics/lib/logger.logLevel(...)
        github.com/VictoriaMetrics/VictoriaMetrics/lib/logger/logger.go:133
github.com/VictoriaMetrics/VictoriaMetrics/lib/logger.Panicf(...)
        github.com/VictoriaMetrics/VictoriaMetrics/lib/logger/logger.go:129
github.com/VictoriaMetrics/VictoriaMetrics/lib/storage.MustOpenStorage({0xbdf9a0?, 0xbd5302?}, 0x983fd98910000, 0x0, 0x0)
        github.com/VictoriaMetrics/VictoriaMetrics/lib/storage/storage.go:191 +0x52d
github.com/VictoriaMetrics/VictoriaMetrics/app/vmstorage.Init(0xd915d0)
        github.com/VictoriaMetrics/VictoriaMetrics/app/vmstorage/main.go:111 +0x51e
main.main()
        github.com/VictoriaMetrics/VictoriaMetrics/app/victoria-metrics/main.go:74 +0x30e
```

一番检查后发现,备份数据是空的,但是 vmrestore 没有报错,只是写了一个文件锁,然后永远无法结束.

vmrestore 命令是这样的:

```shell
vmrestore-prod -src=fs:///tmp/data -storageDataPath=/opt/lan/vmetrics
```

其中 /tmp/data 是我下载好备份数据后解压数据的一个目录,但是备份的数据有问题导致解压后这个目录是空的,没有任何内容,但 vmrestore-prod 命令也没有任何错误提示… 因此导致数据恢复一直是进行中的状态,而 victoria-metrics 检测到数据目录有文件锁,也就是 `/victoria-metrics-data/restore-in-progress`,因此它认为目前还在进行数据恢复,所以一直启动失败.

最后解决是按照提示把`/victoria-metrics-data/restore-in-progress`删除掉,接着把正确的备份数据准备好就可以了.
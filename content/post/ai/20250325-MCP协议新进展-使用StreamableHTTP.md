---
layout:     post 
title:      "MCP协议新进展: 使用 Streamable HTTP 替换当前的 HTTP+SSE 实现。"
slug:      "replace-http-sse-with-new-streamable-http-transport"
subtitle:   ""
description: "MCP协议新进展: 使用 Streamable HTTP 替换当前的 HTTP+SSE 实现。"
date:       2025-03-25
author:     "梁远鹏"
image: "/img/banner/stargazing_1.jpeg"
published: true
tags:
    - mcp
    - ai
    - sse
    - streamable
categories: 
    - TECH
---

# 概述

## 什么是 MCP

官方简介:
>MCP 是一个开放协议，它标准化了应用程序如何为大语言模型（LLMs）提供上下文信息。可以把 MCP 想象成 AI 应用中的 USB Type-C 接口。就像 USB Type-C 为各种设备和配件提供了标准化的连接方式一样，MCP 为 AI 模型与不同数据源和工具之间提供了标准化的连接方式。

## 为什么需要MCP？
官方简介:
>MCP 帮助你在 LLMs 之上构建智能体和复杂的工作流。LLMs 经常需要与数据和工具进行集成，而 MCP 提供了：
>- 不断增长的预建集成列表，利用生态系统不断发展的内容让你的 LLM 可以直接接入
>- 灵活切换不同 LLM 服务提供商的自由度
>- 在基础设施内保护数据安全的最佳实践

## 该提案的基本内容

[Anthropics](https://www.anthropic.com) 公司的 [@jspahrsummers](http://github.com/jspahrsummers) 在 MCP 规范仓库提交了一个 PR, 提议使用 Streamable HTTP 替换 HTTP+SSE 作为 MCP 的底层传输协议。目前该 PR 才刚在周一(2025/03/17)提交，目前还没有被合并, 感兴趣的可以关注一下 PR： [RFC Replace HTTP+SSE with new "Streamable HTTP" transport](https://github.com/modelcontextprotocol/specification/pull/206)。

主要改动如下：
- 删除 API 端点 /sse
- 所有 MCP 客户端都应该使用新的 /message 端点与 MCP 服务端进行通信
- 所有 MCP 客户端请求都可以在服务器端将请求升级为 SSE 用于 request 和 notifications 两种数据类型
- MCP 服务器端可以用 session ID 来建立持久化连接
- MCP 客户端可以发起一个空的请求到 /message 来建立一个 SSE 连接

这种设计方式可以使 MCP 服务器端无状态化(没有 SSE 长连接)并且可以向后兼容(如果需要 SSE 的话仍然可以建立 SSE 连接).

# 为什么提议替换

当前的 MCP 实现是基于 HTTP+SSE 的，这种方式有一些缺点：
- 不支持可恢复性(任务终端后需要重新开始)
- MCP 服务器端需要一直保持长连接可用
- 只能通过 SSE 发送数据，而不能通过 HTTP 请求发送

# 提议的改动好处

- MCP 服务器端可以无状态化，不需要一直保持长连接
- 普通的 HTTP API 请求可以用来发送数据，不需要额外的 SSE 长连接
- 保持基础设施兼容性,所有内容都只有 HTTP,因此可以和原有的基础设施兼容
- 向后兼容性,保持原有的 SSE 连接方式,不影响现有的 MCP 客户端
- 灵活的升级路径,服务器可以在需要 SSE 的时候选择升级 HTTP 请求为 SSE

# 应用场景示例

## 无状态的 MCP 服务器

可以实现无状态的 MCP 服务器，不需要一直保持长连接。

例如，一个仅提供LLM工具且不依赖其他功能的服务器可以这样实现：

1. 始终确认初始化（但无需持久化任何状态）
2. 任何收到的 ToolListRequest 都返回单个 JSON-RPC 响应
3. 处理 CallToolRequest 时，执行工具并等待其完成，然后发送单个 CallToolResponse 作为 HTTP 响应体

## 支持流的无状态 MCP 服务器

完全无状态且不支持长连接的服务器仍可利用流式设计。

例如，在工具调用期间发送进度通知：

1. 当收到 CallToolRequest 的 POST 请求时，服务器表明响应将使用 SSE,这样可以升级 HTTP 请求为 SSE 流。
2. 服务器开始执行工具
3. 在执行期间，服务器通过 SSE 发送任意数量的 ProgressNotification
4. 工具执行完成后，服务器通过 SSE 发送 CallToolResponse
5. 服务器关闭 SSE 流

## 有状态的 MCP 服务器

有状态服务器的实现与当前非常相似。主要区别在于服务器需要生成 session ID，客户端需要在每个请求中回传该 ID。

服务器可以使用 session ID 进行粘性路由或消息总线路由——即在水平扩展部署中，POST 消息可能到达任何服务器节点，因此必须使用Redis 等中间件将消息路由到现有会话。

# 为什么不使用 WebSocket

核心团队深入讨论了将 WebSocket 作为主要远程传输（而不是SSE）的可能性，并计划对其应用类似的工作以实现可断开和可恢复。我们最终决定暂不采用 WebSocket，原因如下：

1. 如果希望以"RPC 式"使用 MCP（例如，仅暴露基本工具的无状态 MCP 服务器），使用 WebSocket 会带来大量不必要的操作和网络开销。
2. 在浏览器中，无法附加头部（如 Authorization ），且与 SSE 不同，第三方库无法在浏览器中从头重新实现 WebSocket。
3. 只有 GET 请求可以透明地升级为 WebSocket（其他 HTTP 方法不支持升级），这意味着 POST 端点需要某种两步升级过程，增加了复杂性和延迟。
4. 我们也避免在规范中将 WebSocket 作为附加选项，因为我们希望限制 MCP 官方指定的传输协议数量，以避免客户端和服务器之间的组合兼容性问题。（但这并不阻止社区采用非标准的 WebSocket 传输。）


本提案不排除未来进一步探索 WebSocket 作为传输协议的可能性，但目前我们认为 HTTP+SSE 足以满足当前需求。

# 最后

这个提案更改很大程度上简化了 MCP 服务器的实现,意味着我们甚至可以将 MCP 服务器部署在 serverl 环境中,例如 vercel functions 或 cloudflare worker,并且向后兼容,值得关注.

我觉得值得一提的一点是:该提案才刚提交 PR 还没有合并,就已经有中文文章在各种营销 Anthropics 宣布了 xxxx,但实际情况是在 PR 合并之前任何改变都是可能的,所以大家在看到这类文章的时候可以稍微冷静一下,也侧面的说明了 MCP 社区的关注度很高.

更新:本文发布时 PR 已经合并了!

后续我也会持续关注这个提案的进展,并分享到我的微信公众号.

## 最后的最后

我让我的 AI 员工们开发了一个微信小程序,并且我将它上线了,欢迎围观👇

![](/img/wechat/miniproblem/miniproblem_wallpaper.jpeg)

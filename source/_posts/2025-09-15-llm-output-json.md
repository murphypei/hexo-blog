---
title: 让 LLM 输出规范 JSON 的方法
date: 2025-09-15 14:20:00
update: 2025-09-15 14:20:00
categories: LLM
tags: [LLM, JSON, 结构化输出, API, schema]
---

在现代 AI 应用开发中，让大语言模型（LLM）生成结构化的 JSON 数据是一个关键需求。无论是构建 API 服务、数据处理流水线，还是与现有系统集成，结构化输出都是必不可少的。本文将深入探讨多种让 LLM 生成规范 JSON 的方法，从基础技巧到高级工程实践。

<!-- more -->

### 为什么需要结构化输出？

在实际应用中，我们经常需要 LLM 的输出能够被程序直接解析和使用，而不是仅仅作为文本供人类阅读。结构化的 JSON 输出具有以下优势：

- **可解析性**：程序可以直接解析和处理 JSON 数据
- **类型安全**：明确的字段类型和结构规范
- **可验证性**：可以通过 Schema 验证数据完整性
- **易集成**：与现有系统和 API 无缝集成

### 方法一：提示词 + JSON format

这是最常用的让模型输出 JSON 格式的方法了。首先就是 prompt 中声明要输出 JSON，配合一些样例 few shot，然后呢，类似 Azure、Gemini 这类的大模型调用接口，都有类似 response_format 可以指定输出 JSON 格式。

模式如下：
JSON 提示词描述 + JSON 样例（Few shot）+ JSON response_format 来约束大模型的 JSON 输出。

如何用比较好地用提示词描述 JSON 字段呢？网络上比较好的实践是用 Typescript 或者 Yaml 格式描述（LLM生成Json结构化数据的几种方案，个人目前认为最好的方式依然是`TypeScript约束Prompt + Yaml格），当然简单地就直接用列表描述就好。可以参考这篇文章：https://juejin.cn/post/7325429835387404307

**需要注意的点**：
* 1. 这个方法不能百分百保证。笔者在 gemini 2.5 pro，指定了 response_format 为 JSON，prompt 给了 few shot，在大型的 JSON 生成的时候，一样会失败。但是 gemini 2.5 pro 指定 json schema，生成成功率大幅度提高。
* 2. 对于没有 json schema 参数的接口，few show 中的 json 样例非常重要。

再说一下这些 API 提供的 JSON response format，本质是一个 Constrained Decoding，即在预测下一字符时，把不符合 JSON 格式的丢掉，基本在高级模型可以非常稳定地输出 JSON 格式，所以还是会有一些极端 case 导致解码失败，或者解码后不是完整的 JSON 格式。

### 方法二：Function call

本质和方法一其实是一样的...

### 方法三：后处理

三个臭皮匠顶个诸葛亮，大模型输出的 JSON 不完美，那就做善后处理。笔者最开始用 GPT-4 生成 JSON 的时候，写了很多后处理的函数，包括：去掉 ```、修复转移错误、轻微语法问题等等。这些案例现在网上有很多，可以自行参考。

### 方法四：大模型修复

在方法三的基础上，让大模型自己纠正输出的 JSON，其实比单独 JSON 解码要简单的多，大模型自己也能做好。但是这个方法的前提是，第一个模型输出的 JSON 内容是基本正确的，如果内容是错误的，后面的模型也很难纠正。

### 结语

总结下来就是，一套基本可用的链路就是：prompt + few shot / json schema + response formt + 后处理，这是 API 接口调用常规用法。笔者日常项目体验，目前比较强的模型基本这套链路能处理的生成 JSON 的规模已经很大了。


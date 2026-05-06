---
type: og-module
module: {{MODULE_SLUG}}
schema: 1
last_synced_commit: ""
---

# {{MODULE_NAME}}

<!-- 一段话：本模块覆盖什么、不覆盖什么。 -->

## 功能

<!--
  每个功能一行。按用户使用顺序排（入口在前），不要按字母排。
  子功能链接到自己的 index.md。
-->

| 功能 | 类型 | 路径 |
|------|------|------|
| {{FEATURE_NAME}} | UI | [{{FEATURE_SLUG}}.md]({{FEATURE_SLUG}}.md) |
|  | 逻辑 |  |

## 跨模块依赖

<!--
  本模块向哪些其他模块读取状态 / 写入状态 / 触发副作用？
  方向要明确。例如：
  - Profile 从 AuthState 读取用户对象（由 Login 写入）。
  - Notifications 触发密码重置深链。
  控制在 5 条以内；超过 5 条往往说明模块边界不合理。
-->

- TODO

## 模块级不变量

<!--
  可选。本模块所有功能都必须遵守的属性。例如：
  - 本模块所有功能都需要登录态。
  - 所有写操作走 AuthService，禁止裸 HTTP。
-->

- TODO

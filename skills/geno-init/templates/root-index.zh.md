---
type: og-root
schema: 1
last_synced_commit: ""
---

# {{PROJECT_NAME}} 功能树

> 由 [OpenGeno](https://github.com/web-abin/OpenGeno) 维护。
> AI 在改动用户可见行为之前必须先读这份索引；
> 改动行为之后必须更新对应的功能文档。

## 模块

<!--
  每个一级模块占一行，描述限一句话。
  新增模块时，同步从 templates/module-index.zh.md 创建 feat-tree/<module>/index.md
-->

| 模块 | 说明 | 路径 |
|------|------|------|
| {{MODULE_NAME}} | {{ONE_LINE_DESCRIPTION}} | [{{MODULE_SLUG}}/]({{MODULE_SLUG}}/index.md) |

## 不在文档树范围内的内容

下列内容**不**在文档树中记录，因为它们是横切基础设施而不是用户可见的功能。
它们应该写在代码注释、ADR 或 CLAUDE.md 里，不进文档树：

- 国际化 / 翻译
- 数据埋点、用户行为分析、A/B 实验
- 构建工具、CI/CD、发版脚本
- 异常上报（Sentry、Crashlytics 等）
- 日志
- 纯工具方法、纯样式 widget
- 主题原语（颜色、字体 token）

## 约定

- 模块和功能 slug 一律用 `kebab-case`。
- 一个流程的多个子步骤放进同一个子目录下，子目录有自己的 `index.md`。
- 跨功能依赖在每份 L3 文档的「跨功能链路」一节中用相对路径声明。

---
type: og-feature
kind: logic
feature: {{FEATURE_SLUG}}
module: {{MODULE_SLUG}}
schema: 1
code:
  - {{CODE_PATH_1}}
last_synced_commit: ""
last_reviewed: {{TODAY}}
---

# {{FEATURE_NAME}}

<!-- 一段话：本逻辑做什么、产出什么、由谁触发。 -->

## 触发条件

<!-- 这段逻辑在什么时候运行？事件触发、定时、手动调用…… -->

- TODO

## 输入

<!-- 消费哪些数据？数据来源和形态。 -->

- TODO

## 输出

<!-- 产出 / 修改 / 发送什么？ -->

- TODO

## 逻辑流程

<!--
  按编号写步骤；分支多用 mermaid flowchart。
  描述行为，不要描述实现。不要写镜像源码结构的伪代码。
-->

1. TODO

## 状态

<!--
  可选。如果本逻辑维护了一个状态机，描述各状态及转移。
-->

- TODO

## 失败模式

| 失败 | 检测方式 | 恢复策略 |
|------|----------|----------|
| TODO | TODO | TODO |

## 不变量

<!--
  可选。永远必须满足的属性。便于回归发现。例如：
  - "Token 永远不以明文写盘"
  - "前一次刷新未结束时不会发起新刷新"
-->

- TODO

## 跨功能链路

- TODO

## 关联代码

- {{CODE_PATH_1}}

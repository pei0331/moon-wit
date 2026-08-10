# Moon ELK：Eclipse Layout Kernel 的 MoonBit 移植

## 1. 项目名称与仓库地址

- 项目名称：Moon ELK（Eclipse Layout Kernel 的 MoonBit 移植）
- GitHub 仓库：https://github.com/moonbit-community/moon_elk.git
- 参赛者：布丁大魔王　联系方式：1234567890

## 2. 项目简介

Moon ELK 将 Eclipse Layout Kernel（ELK）的核心图布局能力移植到 MoonBit 生态，提供一个可复用的自动布局引擎。项目面向需要在 MoonBit 中构建或处理图结构的库作者、工具开发者与应用开发者，提供 ElkGraph 图模型、JSON 导入导出、布局选项解析、布局算法调度，以及多种常用布局算法的 MoonBit 实现。

## 3. 项目方向与适用场景

**方向**：MoonBit 图布局基础库 / 可视化基础设施。

**适用场景**：流程图、数据流图、状态机、建模工具、IDE 插件、低代码编辑器和可视化分析工具。项目以 JSON 输入输出与 MoonBit API 为主要交付接口，可方便接入 Web、CLI、IDE 与渲染场景。

## 4. 拟实现的核心功能

- **图模型**：ElkGraph 风格的节点、边、端口、标签、层级节点与布局属性；
- **JSON 互操作**：ELK JSON 格式的导入、导出与 pretty print，便于与 elkjs 或现有 ELK 工具链交换数据；
- **统一入口**：`new_elk_engine().layout(...)`，按 `elk.algorithm` 分发算法；
- **布局算法**：Layered、Force、Stress、Radial、MrTree、RectPacking、Spore、Fixed、Box、Random、Vertiflex；
- **选项解析**：方向、间距、端口约束、节点尺寸、边路由及算法特定配置；
- **辅助模块**：算法元数据、服务注册、布局校验与调试辅助；
- **文本格式**：Graph Text / ELK Text 解析与转换的基础实现；
- **对照测试**：与 elkjs / ELK 参考实现对照的差异测试、随机用例与迁移记录；
- **测试规模**：不少于 300 个 MoonBit 测试文件，核心回归测试持续保持通过；
- **示例文档**：README 覆盖 JSON 布局、图模型构建、JSON 导入导出与算法选择。

## 5. 移植说明

本项目为**移植项目**，参考 Eclipse Layout Kernel（ELK）：

- 原项目名称：Eclipse Layout Kernel（ELK）
- 来源链接：https://github.com/eclipse-elk/elk
- 原项目许可证：Eclipse Public License 2.0
- 本项目许可证：Eclipse Public License 2.0（与原项目一致）

**与原项目的差异与简化**：

- 使用 MoonBit 原生包结构、类型系统和测试方式组织代码，不复刻 Java 插件工程结构；
- 优先实现可在 MoonBit 中独立运行的核心布局能力，弱化 Eclipse UI、OSGi、SWT/JFace 等桌面插件依赖；
- 对 Graphviz、libavoid、disco、topdownpacking 等暂不完整支持的算法保留兼容入口和错误行为，作为后续扩展范围；
- 将 Java 的异常、集合类型、继承层级和服务发现机制进行 MoonBit 化改写。

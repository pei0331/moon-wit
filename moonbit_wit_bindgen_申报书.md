# MoonBit WIT Bindgen：Wasm Component Model 接口绑定生成器

## 1. 项目名称与仓库地址

- 项目名称：moon-wit（MoonBit WIT Bindgen）
- GitHub 仓库：https://github.com/pei0331/moon-wit
- 参赛者：pei0331　联系方式：18115151290

## 2. 项目简介

moon-wit 是面向 MoonBit 的 Wasm Component Model 接口绑定生成器。它读取 WIT（WebAssembly Interface Types）1.0 规范文件，解析出 `interface` / `world` / `resource` / `record` / `variant` 等类型定义，并生成类型安全的 MoonBit 导入 / 导出绑定代码。核心交付是一套 CLI 工具 `moon-wit`：输入 `.wit` 文件，输出可直接 `moon build` 的 MoonBit 包，是 Wasm Component 互操作在 MoonBit 侧的基础设施。

## 3. 项目方向与适用场景

**方向**：MoonBit 工具链增强 + WebAssembly 应用，产出的是开发者工具而非业务库，天然避免与 mooncakes 上的运行时库重复。

**适用场景**：任何需要在 MoonBit 中与 Wasm Component Model 互操作的场景——组件间调用、WASI 高层接口封装、多语言组件协作。项目以 `moon-wit` CLI 为主要交付接口，后续所有 Wasm Component 项目都可依赖它生成绑定。

## 4. 选题价值与不重复性说明

- **社区现状**：MoonBit 当前 Wasm 生态仍停留在"手动导出函数"或基础 WASI preview1 阶段，社区没有公开的 wit-bindgen 工具或 WIT 解析库；Wasm Component Model / WIT 作为下一代 Wasm 互操作标准，属官方工具链明确要补全、但门槛较高、黑客松参赛者极少触碰的能力。
- **不重复性**：产出为开发者工具与基础设施，不与 mooncakes 上已有的运行时库重复；验收基于 Bytecode Alliance 维护的公开 WIT 规范与官方测试套件，标准客观、可度量，不存在"功能是否完整"的主观争议。

## 5. 项目现有基础说明

- 已调研 Rust `wit-bindgen` 与 Go `wasm-tools-go` 的实现，确认其核心逻辑可适配 MoonBit 的类型系统与模式匹配；
- 已完成 MoonBit 代码生成能力验证，确认可通过宏 / 模板生成类型安全的胶水代码。

## 6. 本次计划开发或新增的内容

- **WIT 1.0 核心子集解析器**：支持 `interface`、`world`、`resource`、`record`、`variant`，错误携带行 / 列定位；
- **MoonBit 代码生成后端**：自动生成类型安全的导入 / 导出绑定，含 `resource` 生命周期管理；
- **CLI 工具 `moon-wit`**：集成到 MoonBit 构建流程；
- **合规性验证**：基于官方 WIT testsuite 编写测试，覆盖 30+ 边界场景，并提供端到端集成测试；
- **文档**：README（含快速开始、WIT 语法映射表）、2 个完整 Component 交互示例、CLI 使用手册。

## 7. 项目预期目标和技术路线

- **目标**：产出可将 `.wit` 文件转换为可用 MoonBit 包的 CLI 工具，并通过官方测试套件验证。
- **技术路线**：WIT 文本解析 → AST 构建 → MoonBit 代码生成模板 → CLI 封装 → 合规测试 → 文档与示例。

## 8. 开发计划（4 周冲刺，适配 8 月 24 日报名截止）

| 阶段 | 时间 | 核心任务 | 交付物 | 关键检查点 |
| --- | --- | --- | --- | --- |
| P0：规范研读与原型 | 8.9-8.15 | 1. 精读 WIT 1.0 规范<br>2. 实现最小化 WIT Parser<br>3. 验证代码生成可行性 | WIT AST 定义；可解析简单 `.wit` 文件的原型 | ✅ 能否正确解析官方 hello-world.wit |
| P1：核心绑定生成 | 8.16-8.22 | 1. 实现 record/variant/resource 生成<br>2. 构建 MoonBit 模板引擎<br>3. 添加错误定位 | 完整代码生成器；基础生成结果验证 | ✅ 生成的代码可通过 moon build |
| P2：CLI 与测试 | 8.23-8.29 | 1. 封装 moon-wit CLI<br>2. 跑通官方 testsuite<br>3. 编写集成示例 | 可用的 CLI 二进制；测试报告 | ✅ 通过 >80% 官方测试用例 |
| P3：文档与提交 | 8.30-9.5 | 1. 完善 README 与示例<br>2. 录制演示视频<br>3. 整理申报材料 | 终版仓库；申报书定稿 | ✅ 材料完整性自查 |

## 9. 原创性、合规与 AI 使用边界说明

- **原创性**：本项目为**原生实现**，从零编写，不直接移植 Rust `wit-bindgen` 代码；若参考其设计，在代码注释中标注 `Design inspired by bytecodealliance/wit-bindgen`。许可证：Apache-2.0。
- **AI 使用边界**：AI 仅用于辅助生成测试用例与文档润色；WIT 解析器与代码生成模板必须手写，避免因 AI 幻觉导致规范偏离。
- **范围控制**：首版仅实现 WIT 1.0 核心子集（interface / world / resource / record / variant），不追求全规范覆盖，确保周期内可交付可用版本。
- **查重二次确认**：开发前已在 GitHub / MoonBit 论坛检索 `wit`、`component-model`、`bindgen`，未发现 MoonBit 侧同类项目；若后续发现类似工作，将在申报书中明确说明本次实现的 WIT 子集范围与代码生成策略的差异。

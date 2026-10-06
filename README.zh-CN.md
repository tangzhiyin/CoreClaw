<p align="center">
  <img src="assets/CoreClaw.png" width="100%" alt="CoreClaw 横幅">
</p>

# CoreClaw

[English](README.md) | [简体中文](README.zh-CN.md)

CoreClaw 是一款运行在 iPhone 和 iPad 上的本地优先 AI 助手应用。本 README 记录项目持续更新、问题修复、版本变更和重要开发说明。

## 2026 年 10 月 6 日更新

### 仅前台语音与构建号 63

- 将主应用和 Live Activity Widget 更新到版本 `1.7.0`，构建号为 `63`，保留现有 Bundle Identifier 和持久化用户数据。
- 移除 `audio` 后台模式、LiveLand 持续处理任务注册及后台 GPU 权限。
- 保留前台语音输入、LIVE 对话、LiveLand、摄像头辅助和音频播放。
- 退回主屏幕、切换到其他 App 或锁屏时，会停止麦克风采集、语音播放和当前语音会话。返回后不会自动恢复监听，需要重新开启会话。
- 在等待推理清理之前立即停止音频，并阻止等待中的权限请求、模型加载或中断恢复流程重新启动已结束的会话。
- 系统权限弹窗等短暂的非活跃状态，不会单独触发语音会话结束。
- 保留后台模型下载，以及打开 App 的 Widget 和快捷指令入口。
- 更新英文、简体中文和日文麦克风用途说明，并同步 App 内及本地网站信息，说明语音仅在前台运行。

### 当前权限与隐私信息

- 权限入口在系统弹窗前使用 **继续**，是否授权由用户选择；拒绝后，不依赖该权限的功能仍然可用。
- 通讯录、相机和定位用途说明在三种支持语言中明确所需信息，并提供具体使用例子。
- App 内及本地网站隐私政策说明 HealthKit、本地存储、网页和图片衍生搜索查询、地址查询、可选远程模型、数据保留和删除方式。
- 本地优先不等于完全离线：模型下载、网页搜索、地址查询和可选远程推理会使用网络服务。

以上记录描述本地开发构建。发布本 README 不代表发布应用、上传 TestFlight／App Store 构建，或部署本地修改的网站页面。

## 2026 年 9 月 8 日更新

### 1.7.0 版本与运行资源优化

- 将主应用和 Live Activity Widget 更新到版本 `1.7.0`，构建号为 `61`，保留 Bundle Identifier 和持久化用户数据。
- 在接收网页数据时执行实际字节上限，包括分块响应，不再先完整下载无限大小的正文再裁剪。
- 取消单个网络请求时及时停止传输，不影响共享会话中的其他请求；超大网页和 HTTP 失败会返回明确错误。
- 将定时聊天序列化和原子磁盘写入移出主线程，排队保存时仅保留每个会话的最新快照。
- 为主动保存、读取历史和删除会话保留有序写入屏障，避免旧快照覆盖新数据或恢复已删除的聊天。
- 为每次定位独立管理定位器和超时，保留同时请求权限的所有等待者，并在完成或取消时停止定位工作。
- 为地址查询设置五秒上限，失败时明确显示原因，同时保留有效坐标。
- 流式取消时停止并等待 MLX Token 生成任务结束，再清理中断或因内存、温度限制而停止的 KV 缓存，并在回答中明确说明过热停止原因。

### iPhone 15 网页搜索滚动

- 拖动和惯性滚动期间延迟更新聊天界面，滚动停止后一次性显示最新完整内容。
- 模型生成、工具结果和消息保存继续进行，不会丢失滚动期间完成的回答。
- 流式阶段使用轻量纯文本，完成后恢复 Markdown 和可点击来源；即使最终文本没有变化，也会恢复格式。
- 避免在测量标签尺寸时修改布局，用户开始滚动时取消等待中的键盘自动滚动。
- 在手势取消、离开页面、应用生命周期变化和切换会话时恢复界面更新。

## 2026 年 9 月 3 日更新

### 定位聊天修复

- 将现有的手动定位权限连接到真正可供聊天调用的 `location-current` 工具。
- 新增当前位置坐标、精度、时间以及 Apple 反向地理编码的地点详情。
- 为用户主动提出的当前位置和附近请求新增 Location Skill，不会在无关对话中读取位置。
- 为定位请求增加取消、12 秒超时以及明确的拒绝、受限和不可用结果。

### 联网搜索资源优化

- 复用一个有明确边界的临时网络会话，避免为每个提供商和网页重复创建会话。
- 根据设备内存限制单主机连接数、响应处理大小和证据网页并发数量。
- 将串行回退尝试从六个来源减少到相关性最高的三个来源。
- 在查询变体、网页下载、证据提取和回退抓取路径中增加取消检查。

## TestFlight

CoreClaw 现已在 TestFlight 上提供：**[加入 CoreClaw Beta 测试](https://testflight.apple.com/join/83pVSbzt)**。

## 应用界面

<p align="center">
  <img src="assets/phoneai-ui-2026-08-27.png" width="360" alt="CoreClaw 深灰色 iPhone 聊天界面">
</p>

## 2026 年 9 月 2 日更新

### 1.6.0 版本

- 将主应用和 Live Activity Widget 更新到版本 `1.6.0`，构建号为 `60`。
- 新增完整的简体中文 README，涵盖英文 README 中的全部项目信息和更新历史。

### 网页搜索滚动稳定性与 1.5.6 版本

- 将包含大量链接的网页搜索回答所使用的嵌套可选择文本视图，替换为轻量的链接感知标签。
- 保留来源链接的点击能力，同时避免文本选择和内部滚动手势与聊天滚动发生竞争。
- 避免重复执行 TextKit 交互工作，修复滚动网页搜索结果时可能卡死、崩溃和导致设备发热的问题。
- 将主应用和 Live Activity Widget 更新到版本 `1.5.6`，构建号为 `53`。

### 标准版 iPhone 运行稳定性

- 为标准版 iPhone 14–17 硬件增加统一运行配置，根据可用物理内存而不是不稳定的机型名称进行判断。
- 降低 6 GB 设备上的输出、图片预处理、推测解码和流式刷新压力。
- 增加温度感知输出限制；如果设备达到临界温度，停止 MLX 生成。
- iOS 报告内存压力时清理长回答渲染缓存，降低长对话期间卡死或被 jetsam 终止的可能性。

### 持久化本地示例训练

- 在 **设置 → Agent** 中新增 **本地示例训练**，用户可以通过“输入和期望回答”示例教导本地模型。
- 通过把相关用户示例注入本地推理上下文，让训练保持私密并完全在设备端进行。
- 将训练示例独立保存在 Application Support 中，而不是修改下载的基础模型。
- 在正常 TestFlight、App Store 应用更新和模型替换后保留本地训练数据。
- 明确说明这是基于示例的上下文学习，因为当前 LiteRT 和 MLX 推理运行时未提供受支持的设备端权重训练或 LoRA 训练 API。

### 用户主动请求定位权限

- 在应用的权限设置中新增“位置”。
- 通过用户主动触发的系统弹窗申请 **使用 App 期间** 的定位授权。当前设置入口使用 **继续**，替代最初的 **请求** 文案。
- 新增本地化定位用途说明，以及权限被拒绝后前往系统设置恢复的路径。
- 保留现有 Bundle Identifier，使 iOS 在正常应用更新后继续保留用户的授权选择。

### 图片自动网页搜索

- 为图片请求新增自动网页增强。
- CoreClaw 先在本地分析图片，再使用用户问题和本地视觉摘要执行搜索。
- 原始图片不会上传给搜索提供商；只有生成的文本查询会进入现有网页搜索管线。

## 2026 年 8 月 30 日更新

### 未安装模型时允许发送文本与 1.5.5 版本

- 未安装可用模型时，文本输入框和发送操作仍然可用。
- 将提交的文本保留为用户消息，并在对话中提醒用户先下载模型。
- 在兼容模型可用之前，图片和音频提交仍保持禁用。
- 继续区分“缺少模型”和“模型已安装但仍在加载”两种状态。
- 将主应用和 Live Activity Widget 更新到版本 `1.5.5`，构建号为 `52`。

## 2026 年 8 月 29 日更新

### CoreClaw 项目完整更名

- 在源代码、用户可见元数据、权限说明、文档、网站内容和 CI 配置中统一使用应用名称 `CoreClaw`。
- 重命名主应用、Live Activity Widget、本地推理引擎、Core 测试模块、macOS 网关目标和 Swift 符号。
- 将 Xcode 项目重命名为 `CoreClaw.xcodeproj`，工作区重命名为 `CoreClaw.xcworkspace`，共享应用 Scheme 重命名为 `CoreClaw`。
- 将主应用产品重命名为 `CoreClaw.app`，扩展产品重命名为 `CoreClawLiveActivityWidget.appex`。
- 为 `CoreClaw` Target 重新生成 CocoaPods 集成，并更新本地 Swift Package 模块路径。
- 保留已注册的应用和 Widget Bundle Identifier，使现有 TestFlight 和 App Store 安装可以继续原位更新。
- 确认更名后的 Core 和 Gateway 测试套件通过。
- 确认从更名后的工作区成功完成 `1.5.4 (51)` Xcode Release 构建。

## 2026 年 8 月 28 日更新

### TestFlight 反馈与 1.5.3 版本

- 在 **设置 → 通用** 底部新增 **发送反馈** 项。
- 点击反馈项会打开 CoreClaw TestFlight 页面，Beta 测试用户可在该页面向开发者发送反馈。
- 将应用版本更新为 `1.5.3`。
- 将构建号更新为 `50`。
- 同步主应用与 Live Activity Widget 的版本和构建元数据。

### 主屏幕 App Icon 适配

- 让 CoreClaw 主屏幕 App Icon 适配 Apple 系统提供的 Liquid Glass 外观，同时保持应用内界面不变。

### 并发回答隔离

- 修复多个请求完成顺序不一致时，较早的延迟回答覆盖较新回答的问题。
- 将流式更新和完成回调绑定到每条助手消息不可变的 UUID，而不是可变数组索引。
- 将基于 UUID 的回答所有权扩展到标准生成、多模态回答、图片追问、规划器完成、工具回退和先前上下文回答。
- 让聊天渲染器为每条独立助手消息创建单独回答块，而不是合并连续回答。
- 当较早请求晚于较新请求完成时，仍在对话中保留每个已完成回答。
- 新增覆盖消息所有权和独立回答渲染的回归契约。

## 2026 年 8 月 27 日更新

### 完整 CoreClaw 迁移

- 在应用 Target、Live Activity Widget、Xcode 项目、工作区、共享 Scheme、Swift Package、测试、文件、文件夹、产品、文档、网站和 CI 工作流中，将应用从 PhoneClaw 重命名为 CoreClaw。
- 将主应用产品重命名为 `CoreClaw.app`，扩展重命名为 `CoreClawLiveActivityWidget.appex`。
- 将应用 Bundle Identifier 更新为 `com.yokotox.phoneai`。
- 将 Widget Bundle Identifier 更新为 `com.yokotox.phoneai.LiveActivityWidget`。
- 重命名 URL Scheme、Bonjour 服务、后台标识符、持久化标识符、Package 模块和测试模块。
- 将公开仓库和 GitHub Pages 链接更新为：
  - <https://github.com/tangzhiyin/CoreClaw>
  - <https://tangzhiyin.github.io/CoreClaw/>
- 保留之前的远程仓库作为旧版 Git Remote，同时将 `tangzhiyin/CoreClaw` 设为主要 Origin。

### 私有本地 Skill 处理

- 从公开 Git 仓库中移除 `Skills/Library/crisp/`。
- 将私有本地 Skill 目录加入 `.gitignore`。
- 在本地工作副本中保留三个 Skill 文件。
- 从每个构建后的 App Bundle 中明确移除私有 Skill 目录，确保其不会通过 TestFlight 分发。
- 移除要求全新 Clone 中必须存在这些私有文件的公开契约测试。
- 确认 GitHub 仓库在私有 Skill 路径下不包含任何文件。

### 上下文长度可靠性

- 修复可能中断正常用户问题的错误“上下文过长”故障。
- 新增对旧对话历史和已完成工具证据的渐进删除与摘要。
- 当普通 Prompt 超过安全上下文预算时，使用紧凑 System Prompt 恢复模式。
- 新增超大输入压缩，在缩短中间部分的同时保留用户请求的开头和最新细节。
- 工具 Schema 过大时改用直接回答回退，而不是终止对话。
- 只有在所有恢复阶段后请求仍无法容纳时，才执行最终安全拒绝。
- 新增覆盖恢复行为的 Token 预算和源代码契约测试。

### 内置默认 AI 模型

- 新增在 Release 和 TestFlight Archive 中把 Gemma 4 E2B 直接打包到 `CoreClaw.app` 的支持。
- 让内置模型在全新安装后立即成为可用默认模型，无需单独在应用内下载。
- 打包模型前执行精确的 2,588,147,712 字节完整性检查。
- 本地 E2B 文件缺失时让 Archive 明确失败，避免意外上传不包含默认模型的 TestFlight 构建。
- 保持 Debug 构建轻量，并为没有本地模型的源码构建保留现有应用内下载器作为回退。
- 不把 2.59 GB 模型二进制文件上传到 GitHub；Release 构建者在 Archive 前把 `gemma-4-E2B-it.litertlm` 放入已忽略的 `Models/` 目录。

### Simulator 模型加载诊断

- 诊断确认下载后的 Gemma 4 E2B 加载失败是 iOS Simulator 运行时限制，而不是模型文件损坏。
- 确认完整的 2,588,147,712 字节模型能通过 LiteRT 容器解析，随后才在 Simulator Metal Shader 编译器处失败。
- 新增即时、本地化说明，明确 LiteRT 本地推理需要实体 iPhone。
- 将该故障分类为后端不可用，使界面显示真实原因，而不是通用模型加载错误。

### Xcode Package 解析修复

- 修复由 CoreClaw DerivedData 损坏引起的 MLX、WhisperKit、Numerics、Tokenizers 和 MarkdownUI 模块同时缺失的问题。
- 仅替换过期的 CoreClaw 构建缓存，并重新生成 Swift Package 依赖图。
- 恢复在 Xcode 常规 DerivedData 路径中的签名 Simulator 构建。
- 让 Gemma 打包和私有 Skill 移除脚本具备依赖感知能力，解决最后两个 Xcode Build Phase 问题。
- 为已忽略的 `Models/` 目录新增受 Git 跟踪的占位元数据，使增量构建能够检测本地模型新增而不公开模型权重。
- 恢复导致 Clean 和 Build 在 Target 编译前失败的 Xcode PIF 传输卡死会话。
- 重启 CoreClaw 构建服务会话，并确认完整 Clean 后的签名 Simulator Build 成功。

### 深灰色视觉更新

- 使用统一深灰色配色替换之前的浅色瓷白和铜色配色。
- 更新主聊天界面、设置、Skill 管理器、文本、边框、按钮、卡片和聊天气泡以使用新配色。
- 将空聊天中心标记替换为小型低对比度 iPhone 轮廓，其中包含 AI 闪光和节点元素。
- 降低默认和深色 App Icon 的亮度、饱和度和对比度。
- 保持两个 App Icon 均为无 Alpha 通道的 1024×1024 RGB PNG 文件。
- 在本 README 中新增当前深灰色聊天界面的 Simulator 截图。

### 发布元数据

- 通过公开邀请链接将 CoreClaw 发布到 TestFlight：<https://testflight.apple.com/join/83pVSbzt>。
- 将应用版本更新为 `1.5.0`。
- 将构建号更新为 `47`。
- 同步主应用和 Live Activity Widget 的版本与构建号。
- 移除可能影响 Archive 验证的嵌入式扩展版本不匹配警告。

## 2026 年 8 月 26 日更新

### 构建与兼容性修复

- 更新过时的 Xcode 26 和 Foundation Models API。
- 移除不受支持、仅用于 Preview 的语言模型执行器。
- 重构超过 Swift 编译器类型检查限制的 LiteRT 多模态闭包。
- 移除缺失的 OpenJTalk 资源引用并恢复 CocoaPods 集成。
- 修正过期的 LIVE 和 LiveLand 测试。
- 使用条件编译隔离实体设备和 Simulator 的 ASR/TTS 实现。
- 将 Piper Plus Header 和 Library 限制为受支持的设备 SDK 构建。
- 修复缺少 Simulator Slice 的 Framework 在 Simulator 上的构建。
- 移除引用之前绝对仓库路径的过期 SwiftPM 模块缓存。
- 通过恢复 CocoaPods 工作区配置修复 Yams Module Map 故障。
- 更新 MLX Metal Shader 设置，消除已知 C++ 语言警告。
- 让自定义运行时复制和重新签名 Build Phase 具备依赖感知能力。
- 当兼容平台 Slice 不可用时，确保可选 LiteRT 组件被正常跳过。

### 网页搜索可靠性

- 将网页搜索提供商从串行执行改为并发执行。
- 增加严格的请求和资源超时，防止搜索无限挂起。
- 禁止等待不可用的网络连接。
- 限制自动查询变体数量，使搜索延迟保持有界。
- 增加对中国大陆和国际网络的提供商覆盖。
- 新增 Bing、Bing News、DuckDuckGo、Google News 和 Baidu News 来源。
- 新增 RSS 和挑战页面验证，使被拦截的提供商页面返回明确失败，而不是空结果。
- 新增并发、超时、区域提供商、时效性处理和有依据回答结构的契约覆盖。

### 应用身份与图标工作

- 将剩余 Kellyvv 身份引用替换为 Crisp。
- 新增简化的 iPhone 与 AI App Icon，并分别提供默认和深色外观。
- 在 CoreClaw 迁移准备期间移除所有剩余 PhoneClaw 路径和内容变体。

### GitHub 与 CI

- 新增并修复用于 iOS 构建和 GitHub Pages 的 GitHub Actions 工作流。
- 配置 CI 使用 Xcode 26.4.1 和 iOS 26 SDK。
- 为 CoreClaw 仓库更新 Pages 部署基础路径。
- 将本地工作 Rebase 到最新远程历史，不执行 Force Push。
- 审计可发布目录树中的凭据、生成产物、旧身份路径和私有 Skill 文件。

## 当前项目配置

此表描述本地开发配置，不代表已发布新版本。

| 项目 | 值 |
|---|---|
| 应用 | CoreClaw |
| 版本 | 1.7.0 |
| 构建号 | 63 |
| 语音运行方式 | 仅前台；退到后台后返回不会自动恢复监听 |
| 后台模型下载 | 保留 |
| 主应用 Bundle ID | `com.yokotox.phoneai` |
| Widget Bundle ID | `com.yokotox.phoneai.LiveActivityWidget` |
| Xcode 工作区 | `CoreClaw.xcworkspace` |
| 共享 Scheme | `CoreClaw` |
| 最低 iOS 版本 | iOS 17 |
| 主仓库 | <https://github.com/tangzhiyin/CoreClaw> |

## 从源代码构建

```bash
git clone https://github.com/tangzhiyin/CoreClaw.git
cd CoreClaw
pod install
open CoreClaw.xcworkspace
```

请始终打开 `CoreClaw.xcworkspace`，不要打开 `CoreClaw.xcodeproj`，因为应用使用 CocoaPods 依赖。

在 Xcode 中：

1. 选择 `CoreClaw` Target。
2. 打开 **Signing & Capabilities**。
3. 选择正确的 Apple Developer Team。
4. 确认已启用自动签名。
5. 选择一台 iPhone、Simulator 或通用 iOS 设备。
6. 构建或 Archive 应用。

模型权重有意保存在 Release 和 TestFlight App Bundle 之外。应用会把模型下载到：

```text
Documents/models/
```

这个持久化应用数据目录可以在正常 App Store 和 TestFlight 更新后保留。已忽略的仓库 `Models/` 目录中的本地开发权重不会复制到 Release Archive。

## 已完成验证

### 2026 年 10 月 6 日 — 1.7.0（63）

- 前台语音、权限、LIVE 和 Widget 回归：29 项定向测试通过。
- Debug iOS Simulator 与未签名 Release iOS 设备构建：通过。
- Release 产物核对：主应用和 Widget 均为 `1.7.0 (63)`，不含后台音频及持续处理任务声明，已打包本地化麦克风说明。
- 新的签名 Archive、上传和实体设备验证属于后续独立步骤；上述检查不表示已发布到 App Store 或 TestFlight。

### 早期验证记录

以下记录对应早期开发构建，并非新的 `1.7.0 (63)` 签名归档。

- Debug iOS 设备构建：通过。
- Debug iOS Simulator 构建：通过。
- Release iOS 设备构建：通过。
- 未签名 Archive：通过。
- 原生 Xcode 工作区构建：无错误或警告通过。
- CoreClaw Core 测试：113 项通过。
- CoreClaw Gateway 测试：3 项通过。
- App Icon 验证：两个图标均为无 Alpha 通道的 1024×1024 RGB PNG 文件。

## 仓库隐私说明

`Skills/Library/crisp/` 下的私有本地 Skill 文件有意排除在 Git、公开 GitHub 仓库和构建后的 App Bundle 之外。

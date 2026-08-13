# Never Miss Golf

[English](README.md) | **简体中文**

当你抵达自己保存的球场后，通过 Apple Watch 的轻触提醒，别忘了开始 Golf 体能训练。

<p align="center">
  <img src="iOS/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png" width="180" alt="Never Miss Golf App 图标">
</p>

## 工作方式

1. 在 iPhone 上手动保存一至三个高尔夫球场的中心位置。
2. 由 iOS 在本机监测这些已保存的区域。
3. 满足停留条件后，在 iPhone 或配对的 Apple Watch 上收到本地提醒。
4. 选择 **打开 Workout**、**不是今天** 或 **延后 10 分钟**。
5. 如果选择继续，打开 Apple 内置的 Workout 体验，并由你亲自开始 Golf。

完整流程留在本机：**保存球场 → 本机区域监测 → 本地通知 → 用户确认后跳转 Workout**。

## 产品边界

Never Miss Golf **不能**静默启动或控制 Apple 内置的 Workout App。提醒与跳转仍需要用户操作，Golf 体能训练也必须由用户在 Apple Workout 中亲自开始。

本仓库同样不会创建第三方 `HKWorkoutSession`，不会启用 HealthKit，也不会读取或写入健康数据。

## 隐私模型

- 无账号、无商业服务器。
- 无分析、广告或第三方 SDK。
- 不上传位置，也不保存持续 GPS 历史。
- 已保存球场的中心位置只保存在 iPhone 的 App 容器中。
- 最多保存三个由用户手动选择的球场。
- 不提供距离、记分、挥杆分析或社交功能。

数据边界详见 [PRIVACY.md](PRIVACY.md)。

## 系统要求

- iOS 17 或更高版本
- watchOS 10 或更高版本
- 如需验证完整通知流程，需要一台已配对的 iPhone 与 Apple Watch
- 当前稳定版 Xcode
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

## 安装

```sh
brew install xcodegen
git clone https://github.com/Lewisdai78/never-miss-golf-open-source.git
cd never-miss-golf-open-source
xcodegen generate
open NeverMissGolf.xcodeproj
```

在 Xcode 中：

1. 为 iOS 和 watchOS targets 选择你自己的开发团队。
2. 如有需要，将 `org.nevermissgolf` 替换为你自己控制的反向域名命名空间。
3. 确保 iPhone 和 Watch 的 Bundle Identifier 与 `WKCompanionAppBundleIdentifier` 保持一致。
4. 除非你有意构建另一种产品，并已单独审查其数据模型，否则不要添加 HealthKit。

随后选择真实且已配对的 iPhone 与 Apple Watch，安装两个 App，并按照 [TESTING.md](TESTING.md) 中的首次运行清单进行验证。

## 验证

在 Windows 或 PowerShell 7 中：

```powershell
./scripts/validate_project.ps1
./scripts/scan_public_release.ps1
```

在 macOS 上，还需要生成 Xcode 项目，并在 Xcode 中运行 `NeverMissGolfTests`。区域监测和通知路由必须通过真实配对设备测试；模拟器不能作为完整流程已经通过的充分证据。详见 [TESTING.md](TESTING.md)。

## 仓库结构

```text
Shared/   数据模型、通知协议与提醒状态机
iOS/      本地存储、权限、区域监测、通知与界面
Watch/    Watch 通知入口与 Workout 跳转
Config/   iOS 与 watchOS 的 Info.plist 文件
Tests/    状态机测试
scripts/  隐私与公开发布的静态检查
docs/     产品网站源码
```

## 项目状态

这是一个非商业个人原型和参考实现，不是医疗或安全产品。后台投递、通知路由和 Apple 内置 Workout 体验均由 Apple 控制；实际行为可能受到权限、专注模式、设备状态、连接情况和 OS 版本影响。

本仓库不宣称已经通过 App Store 审核，也不保证后台提醒在所有情况下都能送达。

## 贡献与安全

欢迎贡献。在提交 Issue 或 Pull Request 前，请先阅读 [CONTRIBUTING.md](CONTRIBUTING.md)。请勿提交真实球场坐标、位置历史、签名材料、设备标识符或个人截图。

如需报告敏感安全问题，请按照 [SECURITY.md](SECURITY.md) 的说明使用 GitHub 私密漏洞报告功能。

## 许可证

本项目使用 [Apache License 2.0](LICENSE)。“Never Miss Golf”及其视觉标识仅作为项目描述性标识；本许可证不授予任何 Apple 商标权，也不代表本项目与 Apple Inc. 存在关联。

Apple、iPhone、Apple Watch 和 Workout 是 Apple Inc. 的商标。本项目为独立项目，未经 Apple 认可，也与 Apple 无附属关系。

由 [@Lewisdai78](https://github.com/Lewisdai78) 构建。

# Never Miss Golf 真机测试手册

所有结果必须记录设备、OS、授权、iPhone 状态、Watch 状态、步骤、预期、观察与脱敏证据。Xcode 模拟位置不算后台可靠性证据。

## Gate A — 工程与状态机

- [ ] `xcodegen generate` 成功。
- [ ] iOS、watchOS target 均能编译。
- [ ] `NeverMissGolfTests` 全部通过。
- [ ] Signing 中没有 HealthKit capability。
- [ ] App 没有网络请求或第三方 SDK。

## Gate B — 不去球场的通知链路

### B1：通知到 Watch

前置：iPhone 与 Watch 配对并连接；Watch App 已安装；Watch 解锁；iPhone 锁定；通知允许；Focus 关闭。

1. 保存一个测试球场。
2. 点击“3 秒后发送测试提醒”。
3. 立刻锁定 iPhone。
4. 观察 Watch 是否出现系统触感和通知。
5. 展开通知，确认三个动作完整。

通过：Watch 收到提醒；标题、正文和动作正确。记录实际延迟。

### B2：打开 Apple 内置 Golf

1. 在 B1 的 Watch 通知上点击“打开 Workout”。
2. 观察 Never Miss Golf Watch App 是否前台启动。
3. 观察是否切换到 Apple 内置 Workout。
4. 确认内容是 Golf。
5. 等待，不点击开始。

通过：内置 Workout 显示 Golf；等待期间没有 workout 自动开始。

重复：相同设备/OS 连续执行 3 次；3 次都成功才通过。

### B3：通知路由对照

分别测试：

- iPhone 解锁、Watch 解锁。
- iPhone 锁定、Watch 解锁。
- iPhone 锁定、Watch 锁定。
- Watch 与 iPhone 断连。
- Focus 开启。
- Never Miss Golf 的 Watch 通知关闭。

记录通知落点和是否有手腕触感。产品不能把“通知已排程”写成“Watch 已震动”。

## Gate C — 三个动作互斥

- [ ] “打开 Workout”才可能进入 Apple Workout。
- [ ] “不是今天”不打开 Workout，并抑制本次到访。
- [ ] “延后10分钟”不打开 Workout，只再安排一次提醒。
- [ ] 重复点击不会创建重复 pending reminders。
- [ ] 退出球场时 dwell/snooze/test reminder 被取消。

## Gate D — 真实地理围栏

依次测试：

1. App 前台进入。
2. App 后台进入。
3. iPhone 锁屏进入。
4. App 被系统终止后进入。
5. 用户强制退出后进入（单独记录，不预设会成功）。
6. iPhone 重启并首次解锁后进入。
7. Precise Location 关闭。
8. 无网络/飞行模式。

场景：步行进入、驾车经过、clubhouse、练习场、提前到达、触发前离开、触发后离开、边界往返。

通过标准：只能基于真实覆盖报告；事件/提醒延迟必须记录，不能写成实时保证。

## Gate E — 删除与权限撤销

- [ ] 删除一个球场同时移除 monitor 和提醒。
- [ ] 删除所有本机数据后没有 saved course、visit state 或 pending notification。
- [ ] Always 降级为 When In Use 后 UI 明确显示后台提醒不具备权限。
- [ ] 通知撤销后测试提醒不会被声称已显示。

## 停止条件

以下任一项发生就停止扩展，保留普通 reminder：

- Watch foreground action → Watch App → `openInWorkoutApp()` 无法连续 3 次成功。
- 只能打开 Workout 通用列表，无法稳定带到 Golf。
- Watch 提醒在主要使用状态下经常落到 iPhone，手腕触感价值不足。
- 需要私有 API、后台自定义 haptic 或第三方 workout session 才能满足承诺。
- 两次真实到访均因误报或延迟失去提醒价值。


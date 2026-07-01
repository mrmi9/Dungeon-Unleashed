# Dungeon Unleashed 开发日志

本文档用于记录《Dungeon Unleashed》的阶段性开发进度、已实现功能、验证结果、已知问题和后续任务。开发目标以 `DEVELOPMENT_PLAN.md` 为准。

## 当前项目快照

### 文档状态

- 日志文件：`E:\Dungeon Unleashed\DEVELOPMENT_LOG.md`
- Godot 项目：`E:\Dungeon Unleashed\dungeon-unleashed`
- 当前记录日期：2026-07-01
- 当前开发进度：已从阶段 1 核心操作原型推进到包含 10 个遗物、经济、商店、宝箱、Boss 二阶段场地压力、第一轮自动化数值平衡、22 个数据驱动房间布局资源、可种子复现的 10-14 房间变量分支路线、设置保存、核心键位重绑定、结算统计、历史记录、基础音频反馈、核心 UI 布局烟测、Windows 打包验证和试玩反馈材料的最小完整局流程；主菜单、暂停、设置、死亡结算、通关结算、商店消费、宝箱奖励、占位音频、Windows 原型包、反馈模板和已知问题列表已有原型，正式美术音频素材、代码签名和外部分发仍未完成。
- 最新 Windows 原型包：`E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip`

### 当前已实现功能总览

- 项目基础结构、主场景、输入映射、Autoload 事件总线和碰撞层已完成。
- 玩家可 WASD 八方向移动、鼠标瞄准、左键射击、切换武器、受击、短暂无敌、死亡后停止操作。
- 已实现 4 把武器：Basic Pistol、Shotgun、Energy Staff、Ricochet Blaster。
- 武器系统支持射速、散射、多弹丸、弹匣、换弹、暴击、穿透、反弹和爆炸字段。
- 子弹支持直线飞行、射程销毁、命中敌人、命中墙体、击退和命中特效。
- 已实现可种子复现的 10-14 房间变量分支路线：主路径 7-9 个节点，支路 3-5 个节点，Boss 固定在主路径末端；奖励房、商店房、可选精英/战斗支路和布局资源会按生成种子选择。
- HUD 小地图会显示当前地牢 seed；主菜单支持输入固定 seed 或回到随机 seed，结算页支持 Replay Seed；`DungeonController.get_debug_map_text()` 可输出 seed、网格、房间坐标、连接方向和布局，`F3` 可打开开发者 Debug Map 面板并复制地图文本，便于复现地图问题。
- 战斗房支持进入触发、锁门、敌人波次、清房开门和奖励生成。
- 已实现地牢房间数据资源、房间布局资源、房间生成控制器、`layout_data`/`layout_profile` 元数据和 HUD 小地图。
- 已建立 `resources/room_layouts` 布局库，当前包含 22 个 `.tres` 布局资源；布局资源可配置地面色、刷怪点、奖励点和矩形障碍物。
- 已实现 6 类普通敌人：追踪、远程、冲锋、自爆、召唤、护盾。
- 已实现精英房规则：敌人精英化、血量/伤害倍率、视觉强化和死亡爆炸。
- 已实现 Boss 战原型：独立 Boss、HUD 血条、二阶段、阶段转换暂停/预警、环形弹幕、瞄准齐射、召唤小怪、二阶段地面危险区、死亡通关事件。
- 已实现最小主流程 UI：启动进入主菜单、开始新局、暂停/恢复、死亡结算、通关结算、分组结算面板、重新开始和返回主菜单入口。
- 大面板 UI 已加入基础响应式约束：主菜单、暂停、设置、遗物选择和结算面板会按视口限制尺寸；打开大面板时会隐藏右下角输入提示，避免 720p 下互相遮挡。
- 已实现设置菜单和设置保存：主音量、音效音量、音乐音量、分辨率、全屏开关、核心键位重绑定、`user://settings.cfg` 持久化读取和保存。
- 已实现局内输入提示：HUD 右下角显示移动、瞄准、射击、换弹、切武器、交互和暂停按键。
- 已实现基础音频反馈：运行时 SFX/Music 总线、程序化占位音效、普通/战斗/Boss/胜利/失败背景音乐模式。
- 已实现 Windows 导出配置和打包流程：`export_presets.cfg`、Godot 4.7 Windows 模板、release `.exe` 导出和试玩 zip 包；本轮导出 `.exe` 自动 headless 启动验证受导出 runner 参数限制，仍需要人工双击运行复核。
- 已补齐外部试玩材料：`PLAYTEST_FEEDBACK.md`、`KNOWN_ISSUES.md` 和打包目录内的试玩说明。
- 已实现本局结算统计和历史统计：死亡/通关面板展示武器、遗物、生命、护盾、HP 伤害、暴击次数、治疗量、护盾吸收量、金币收支、奖励、宝箱、商店购买、Boss 击败状态和历史最好记录。
- 结算统计会区分唯一遗物数量和遗物总层数，避免可堆叠遗物被误判为没有成长。
- 已实现最小经济/商店循环：击杀金币、清房金币、商店房、回血商品、遗物商品、武器商品、价格、金币扣除和售罄状态。
- 已实现宝箱系统：普通宝箱、高级宝箱、Boss 奖励宝箱、可配置掉落池、宝箱开启奖励和 Boss 宝箱开启后通关结算；普通宝箱默认稳定提供金币加少量回血，避免商店前经济断档。
- 已实现统一交互键：商店购买和宝箱开启需要靠近后按 `E`，避免接触误触。
- 已完成第一轮自动化数值平衡：开局/精英波次、商店价格、Boss 血量和自然进店金币范围已有 `BalanceSmokeTest` 约束。
- 已实现遗物系统、遗物拾取、遗物 3 选 1 面板和 HUD 遗物显示。
- 已实现 7 个静态/数值遗物：Sharp Rounds、Quick Trigger、Split Chamber、Phase Tip、Lucky Primer、Swift Loader、Heart Core。
- 已实现第一批事件触发遗物：Vampire Fang、Guardian Ward、Adrenaline Charm。
- 遗物效果已覆盖伤害、射速、多弹丸、穿透、暴击率、换弹速度、生命上限、击杀回血、清房护盾和受伤加速。
- 已实现遗物掉落表资源化：奖励房、商店、普通宝箱、高级宝箱和 Boss 宝箱分别使用 `.tres` 配置来源池与稀有度权重。
- 暴击命中已有独立反馈：更大的橙红色命中特效、额外暴击音效、更强屏幕震动和 `CRIT` 浮字。
- 已实现金币奖励、护盾、回血、临时加速、玩家受击反馈、敌人受击闪烁、死亡特效、枪口闪光、屏幕震动和关键战斗浮字。
- 已实现攻击预警反馈：精英死亡爆炸预警、Boss 阶段转换预警、Boss 环形弹幕预警、Boss 瞄准齐射预警、Boss 地面危险区预警和延迟伤害/发射。

### 最近自动验证结果

- `DungeonGenerationSmokeTest.tscn`：通过。
- `BalanceSmokeTest.tscn`：通过。
- `EnemyVarietySmokeTest.tscn`：通过。
- `BossSmokeTest.tscn`：通过。
- `ChestSmokeTest.tscn`：通过。
- `MenuFlowSmokeTest.tscn`：通过。
- `SettingsSmokeTest.tscn`：通过。
- `UILayoutSmokeTest.tscn`：通过。
- `AudioFeedbackSmokeTest.tscn`：通过。
- `CombatFeedbackSmokeTest.tscn`：通过。
- `RunSummarySmokeTest.tscn`：通过。
- `ShopSmokeTest.tscn`：通过。
- `RoomFlowSmokeTest.tscn`：通过。
- `FullRunSmokeTest.tscn`：通过。
- `RelicSmokeTest.tscn`：通过。
- `WeaponSmokeTest.tscn`：通过。
- `Main.tscn` Godot CLI 无头启动验证：通过。
- Windows release `.exe` 导出：通过。
- Windows release `.exe` 自动 headless 启动：本轮未计入通过，`--headless --quit` 返回 `-1073741819`，`--quit-after` 未可靠退出；导出包需人工运行复核。
- Windows 试玩 zip 包生成：通过。
- `res://` 静态引用检查：通过。
- `.tscn` / `.tres` `load_steps` 格式检查：通过。

### 当前主要未完成项

- Boss 战仍是原型级，已有阶段转换、基础预警、地面危险区和结算统计，但尚未完成最终 Boss 战演出、场地设计和数值调优。
- 房间布局资源数量已达到开发计划第 11 阶段建议的 20+ 门槛，当前单局已扩展为可种子复现的 10-14 房间变量分支路线；但仍是 1 个原型房间场景配合数据布局，尚未完成 20 到 30 个独立房间实例或正式 TileMap 房间模板。
- 主流程 UI 仍是原型级，设置菜单已包含 Master/SFX/Music/Resolution/Fullscreen 和核心键位重绑定，并已有 1280x720 / 1600x900 / 1920x1080 基础布局烟测，但尚未支持手柄提示、更完整的显示/音频选项、鼠标/武器槽重绑定和正式视觉层级。
- 商店和宝箱系统仍是原型级，已有第一轮自动化经济约束，但尚未完成实机手感平衡和掉落权重可视化配置。
- 遗物候选已按稀有度权重随机，并在选择面板展示稀有度颜色和效果标签；奖励房、商店和宝箱已有资源化来源级掉落池与权重，但尚未实现保底规则和正式图标/特效。
- 精英死亡爆炸已有基础预警圈，但视觉仍是原型级。
- UI 仍是原型级，占位文本和基础控件较多；结算面板已分组，但仍缺少图标、动画和正式视觉层级。
- 浮字反馈已覆盖伤害、暴击、治疗、护盾获取和护盾吸收；结算面板已统计暴击次数、治疗量和护盾吸收量，但还没有图标或伤害类型细分。
- 仍未接入正式美术、正式音频素材、代码签名和外部分发页面。

### 推荐手动验证重点

- 从 `Main.tscn` 启动后，确认玩家移动、瞄准、射击、换武器和换弹手感。
- 依次推进当前 seed 生成的 10-14 个房间，确认主路线、分支、门锁、波次、奖励、遗物选择、商店消费和小地图状态。
- 在首个精英房确认精英敌人更耐打、伤害更高，并且死亡爆炸能正确伤害玩家或消耗护盾。
- 在最终 Boss 房确认 Boss 血条、二阶段、阶段转换、地面危险区、弹幕、召唤、死亡和 `RUN COMPLETE` 提示。
- 确认启动后先进入主菜单，开始新局后可用 Esc 暂停，死亡和通关都会进入结算面板。
- 确认死亡和通关结算面板会展示本局武器、遗物、金币收支、伤害、奖励、宝箱、商店购买和历史记录。
- 确认主菜单和暂停菜单都能打开 Settings，音量/全屏修改后重启仍保留。
- 确认 Settings 的 Master/SFX/Music/Resolution/Fullscreen 和核心键位修改后重启仍保留。
- 确认 HUD 右下角输入提示在常见窗口尺寸下不遮挡核心战斗区域。
- 在商店房确认金币能购买回血、遗物和武器，购买后商品显示售罄且金币减少。
- 确认普通战斗房生成普通宝箱、精英房生成高级宝箱、Boss 死亡后生成 Boss 奖励宝箱，打开 Boss 宝箱后进入通关结算。
- 确认商店商品和宝箱靠近时不会自动触发，必须按 `E` 才会购买或开启。
- 确认精英死亡爆炸和 Boss 弹幕在伤害/发射前有红色危险预警。
- 选择事件触发型遗物后，确认击杀回血、清房护盾、受伤加速都能在实际游玩中触发。

## 2026-06-30

### 阶段

- 当前阶段：阶段 1，核心操作原型。
- 目标：完成一个可运行测试房间，验证玩家移动、鼠标瞄准、基础射击、敌人追踪、命中反馈和死亡状态。
- 引擎：Godot 4.7 stable。
- 项目路径：`E:\Dungeon Unleashed\dungeon-unleashed`

### 已实现功能

#### 项目结构

- 建立了基础 Godot 目录结构：
  - `scenes/main`
  - `scenes/player`
  - `scenes/enemies`
  - `scenes/weapons`
  - `scenes/projectiles`
  - `scenes/effects`
  - `scenes/ui`
  - `scripts/core`
  - `scripts/player`
  - `scripts/enemies`
  - `scripts/weapons`
  - `scripts/projectiles`
  - `scripts/effects`
  - `scripts/ui`
  - `resources/weapons`

#### 项目配置

- 配置主场景：
  - `res://scenes/main/Main.tscn`
- 配置输入：
  - `WASD` 移动
  - 鼠标左键射击
- 配置 Autoload：
  - `Events.gd`
- 配置 2D 碰撞层：
  - Layer 1：Player
  - Layer 2：Enemy
  - Layer 3：PlayerProjectile
  - Layer 4：Wall

#### 玩家原型

- 玩家使用 `CharacterBody2D`。
- 支持 WASD 八方向移动。
- 支持鼠标瞄准，角色朝向跟随鼠标。
- 支持生命值。
- 支持受击闪烁。
- 支持短暂无敌时间，避免贴脸瞬间多次扣血。
- 支持死亡状态。
- 玩家死亡后停止移动和射击。

#### 武器和子弹

- 实现基础手枪数据资源：
  - `resources/weapons/basic_pistol.tres`
- 实现 `WeaponData.gd`，用于配置武器参数。
- 实现 `Weapon.gd`：
  - 射击冷却
  - 子弹生成
  - 枪口位置
  - 枪口闪光
- 实现 `Projectile.gd`：
  - 直线飞行
  - 最大射程
  - 命中敌人造成伤害
  - 命中敌人、墙体或达到射程后销毁
  - 命中特效

#### 测试敌人

- 敌人使用 `CharacterBody2D`。
- 支持自动追踪玩家。
- 支持生命值。
- 支持受击闪烁。
- 支持击退。
- 支持死亡后移除。
- 当前测试房间内放置了 4 个敌人。

#### 反馈和 UI

- 实现枪口闪光。
- 实现命中特效。
- 实现敌人死亡特效。
- 实现玩家受击反馈。
- 实现轻量屏幕震动。
- 实现基础 HUD：
  - 玩家 HP
  - 当前武器名
  - 剩余敌人数
  - 死亡提示 `DEFEATED`

#### 事件系统

- 新增 `Events.gd`，包含阶段 1 需要的基础战斗信号：
  - `player_fired`
  - `projectile_spawned`
  - `projectile_hit`
  - `enemy_damaged`
  - `enemy_died`
  - `player_damaged`
  - `player_died`

### 关键文件

- `dungeon-unleashed/project.godot`
- `dungeon-unleashed/scenes/main/Main.tscn`
- `dungeon-unleashed/scenes/player/Player.tscn`
- `dungeon-unleashed/scenes/enemies/Enemy.tscn`
- `dungeon-unleashed/scenes/weapons/Weapon.tscn`
- `dungeon-unleashed/scenes/projectiles/Projectile.tscn`
- `dungeon-unleashed/scenes/ui/HUD.tscn`
- `dungeon-unleashed/scripts/core/Events.gd`
- `dungeon-unleashed/scripts/main/Main.gd`
- `dungeon-unleashed/scripts/player/Player.gd`
- `dungeon-unleashed/scripts/enemies/Enemy.gd`
- `dungeon-unleashed/scripts/weapons/Weapon.gd`
- `dungeon-unleashed/scripts/weapons/WeaponData.gd`
- `dungeon-unleashed/scripts/projectiles/Projectile.gd`

### 自动验证记录

#### Godot 版本

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --version
```

结果：

```text
4.7.stable.official.5b4e0cb0f
```

结论：Godot CLI 可用。

#### 项目主场景启动验证

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/main/Main.tscn" --quit-after 20
```

结果：

- 退出码：`0`
- 未输出脚本错误。

结论：`Main.tscn` 可以通过 Godot CLI 无头模式加载并运行 20 帧，当前启动验证通过。

#### 静态资源引用验证

- 已检查项目内 `res://` 引用。
- 结果：引用目标均存在。

#### Godot 场景资源格式检查

- 已检查 `.tscn` 和 `.tres` 的 `load_steps`。
- 结果：计数一致。

### 手动测试清单

以下内容需要在 Godot 编辑器或运行窗口中人工确认：

```text
[ ] WASD 可以八方向移动
[ ] 玩家朝向跟随鼠标
[ ] 鼠标左键可以连续射击
[ ] 子弹方向与鼠标方向一致
[ ] 子弹命中敌人后敌人闪烁
[ ] 子弹命中敌人后敌人被击退
[ ] 敌人生命值归零后消失
[ ] 敌人死亡时出现死亡特效
[ ] HUD 敌人数会减少
[ ] 玩家接触敌人会扣血
[ ] 玩家受击后有闪烁和屏幕震动
[ ] 玩家受击后不会瞬间连续扣多次血
[ ] HP 归零后显示 DEFEATED
[ ] 玩家死亡后不能继续移动
[ ] 玩家死亡后不能继续射击
[ ] 玩家和敌人不能穿过墙
[ ] 子弹命中墙体后销毁
```

### 当前已知限制

- 当前只有一个测试房间，不包含正式房间流程。
- 当前没有房门、清房奖励、随机地牢或房间连接。
- 当前只有一把基础手枪，没有武器切换。
- 当前敌人只有追踪行为，没有远程、冲锋、自爆等敌人类型。
- 当前没有遗物系统。
- 当前没有 Boss。
- 当前没有正式主菜单、暂停菜单、死亡结算或通关结算。
- 当前没有正式美术和音效，只使用占位几何图形和程序化视觉反馈。
- `godot` 短命令不可用；当前可用命令是 `Godot_v4.7-stable_win64_console.exe`。

### 下一步建议

1. 用 Godot 编辑器运行 `Main.tscn`，完成手动测试清单。
2. 根据手感测试结果调整：
   - 玩家移动速度
   - 武器射速
   - 子弹速度
   - 敌人移动速度
   - 屏幕震动强度
   - 受击无敌时间
3. 若阶段 1 验收通过，进入阶段 2：战斗房间闭环。

## 2026-06-30 阶段 2 推进

### 阶段

- 当前推进内容：阶段 2，战斗房间闭环。
- 本次目标：在现有测试房间中实现最小闭环：进入房间、锁门、生成敌人波次、清房、开门、生成奖励、领取奖励并记录状态。
- 完成状态：单房间闭环已实现并通过自动烟测；尚未实现多个手工连接房间，因此阶段 2 尚未完整验收。

### 已实现功能

#### 房间状态机

- 新增 `CombatRoom.gd`。
- 房间状态包含：
  - `UNENTERED`
  - `ENTERED`
  - `COMBAT`
  - `CLEARED`
  - `REWARD_CLAIMED`
- 玩家进入房间检测区域后，房间会从未进入状态进入战斗状态。
- 玩家死亡后，房间流程停止继续推进。

#### 房门逻辑

- 主场景右侧墙体改为带出口缺口的结构。
- 新增 `ExitDoor`。
- 战斗开始后关闭出口门。
- 所有波次清理完成后打开出口门。
- 门的碰撞启停使用 deferred 方式处理，避免 Godot 物理查询刷新阶段报错。

#### 敌人波次

- 房间内新增 `EnemySpawns` 节点。
- 当前配置为两波敌人：
  - 第一波：3 个敌人
  - 第二波：4 个敌人
- 敌人不再直接摆在主场景中，而是由 `CombatRoom` 按波次生成。
- 房间会根据存活敌人列表判断是否进入下一波或清房状态。

#### 清房奖励

- 新增 `CoinPickup.gd` 和 `CoinPickup.tscn`。
- 清房后在 `RewardSpawn` 位置生成金币奖励。
- 奖励只生成一次。
- 玩家接触金币后增加局内金币。
- 奖励领取后房间状态推进为 `REWARD_CLAIMED`。

#### HUD 和事件

- HUD 新增：
  - 金币数量
  - 房间状态
  - 房间提示消息
- `Events.gd` 新增信号：
  - `gold_changed`
  - `room_state_changed`
  - `room_started`
  - `room_cleared`
  - `reward_spawned`
  - `reward_collected`
- 主场景会监听房间、奖励和金币事件并更新 HUD。

#### 自动烟测

- 新增 `RoomFlowSmokeTest.gd`。
- 新增 `RoomFlowSmokeTest.tscn`。
- 烟测覆盖：
  - 主场景加载
  - 玩家初始进入房间后触发战斗
  - 第一波生成 3 个敌人
  - 第一波清理后进入第二波
  - 第二波生成 4 个敌人
  - 第二波清理后进入清房状态
  - 房门打开
  - 奖励只生成一次
  - 玩家领取奖励后获得金币
  - 房间状态变为 `REWARD_CLAIMED`

### 关键文件

- `dungeon-unleashed/scripts/rooms/CombatRoom.gd`
- `dungeon-unleashed/scripts/pickups/CoinPickup.gd`
- `dungeon-unleashed/scripts/debug/RoomFlowSmokeTest.gd`
- `dungeon-unleashed/scenes/debug/RoomFlowSmokeTest.tscn`
- `dungeon-unleashed/scenes/pickups/CoinPickup.tscn`
- `dungeon-unleashed/scenes/main/Main.tscn`
- `dungeon-unleashed/scripts/main/Main.gd`
- `dungeon-unleashed/scripts/player/Player.gd`
- `dungeon-unleashed/scripts/ui/HUD.gd`
- `dungeon-unleashed/scripts/core/Events.gd`

### 自动验证记录

#### 房间闭环烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RoomFlowSmokeTest.tscn"
```

结果：

```text
RoomFlowSmokeTest passed.
```

结论：单房间战斗闭环自动验证通过。

#### 主场景启动验证

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/main/Main.tscn" --quit-after 60
```

结果：

- 退出码：`0`
- 未输出脚本错误。

结论：主场景仍可正常启动。

#### 静态资源引用验证

- 已检查项目内 `res://` 引用。
- 结果：引用目标均存在。

### 手动测试清单

```text
[ ] 运行 Main.tscn 后，房间状态从 Unentered 进入 Combat
[ ] 战斗开始后右侧出口门关闭
[ ] 第一波敌人被清理后，会生成第二波敌人
[ ] 第二波敌人被清理后，HUD 显示房间清理完成
[ ] 清房后右侧出口门打开
[ ] 清房后房间中央偏上生成金币奖励
[ ] 玩家触碰金币后 Gold 增加
[ ] 领取奖励后 HUD 房间状态显示 Reward Claimed
[ ] 奖励不会重复生成
[ ] 玩家死亡后房间流程停止继续推进
```

### 当前已知限制

- 阶段 2 只完成了单房间闭环，尚未实现连续多个手工连接房间。
- 当前奖励只有金币，没有回血、宝箱或遗物选择。
- 当前房间波次配置仍写在场景导出参数中，尚未独立为房间模板资源。
- 当前没有正式出生房、奖励房、商店房、精英房或 Boss 房。
- 当前没有小地图和地牢结构。
- 自动烟测覆盖房间流程，但不替代实际手感测试。

### 下一步建议

1. 实现多个手工连接房间，让玩家能从出生房进入战斗房，再离开到下一个房间。
2. 把房间波次和奖励配置进一步数据化。
3. 增加基础交互键，用于宝箱、房门或奖励领取。
4. 阶段 2 完整验收后，进入阶段 3：武器、弹道和伤害系统扩展。

## 2026-06-30 阶段 2 多房间推进

### 阶段

- 当前推进内容：阶段 2，多个手工连接房间。
- 本次目标：让玩家可以从一个战斗房间继续进入下一个战斗房间，验证房门、波次、奖励和房间状态在多房间情况下仍然可靠。
- 完成状态：3 个手工连接战斗房间已实现，并通过自动烟测。

### 已实现功能

#### 可复用战斗房间场景

- 新增 `PrototypeCombatRoom.tscn`。
- 房间包含：
  - 地板
  - 上下墙体
  - 左右带缺口墙体
  - 左入口门
  - 右出口门
  - 房间进入检测区域
  - 敌人生成点
  - 奖励生成点
  - `CombatRoom` 状态机节点

#### 多房间链

- `Main.tscn` 现在实例化 3 个相邻的手工连接房间：
  - `Room01`
  - `Room02`
  - `Room03`
- 玩家从一个房间清理完成后，可以从右侧出口进入下一个房间。
- 摄像机继续跟随玩家，支持在多个房间之间移动。

#### 多门锁定

- `CombatRoom.gd` 从单一出口门改为支持多个门。
- 当前每个房间有左入口门和右出口门。
- 战斗开始后，左右门同时关闭，避免玩家未清房时离开战斗房。
- 清房后，左右门同时打开。
- 门碰撞启停仍使用 deferred 方式，避免物理查询刷新阶段报错。

#### 自动烟测更新

- `RoomFlowSmokeTest.gd` 从单房间测试扩展为 3 房间链测试。
- 烟测按 X 坐标排序所有 `combat_rooms`，依次验证每个房间：
  - 进入战斗状态
  - 战斗时门锁定
  - 第一波敌人数符合配置
  - 第一波清理后进入第二波
  - 第二波敌人数符合配置
  - 所有波次清理后进入 `CLEARED`
  - 清房后门打开
  - 清房奖励生成
  - 玩家领取奖励
  - 房间进入 `REWARD_CLAIMED`

### 关键文件

- `dungeon-unleashed/scenes/rooms/PrototypeCombatRoom.tscn`
- `dungeon-unleashed/scenes/main/Main.tscn`
- `dungeon-unleashed/scripts/rooms/CombatRoom.gd`
- `dungeon-unleashed/scripts/debug/RoomFlowSmokeTest.gd`

### 自动验证记录

#### 多房间闭环烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RoomFlowSmokeTest.tscn"
```

结果：

```text
RoomFlowSmokeTest passed.
```

结论：3 个手工连接战斗房间的进入、锁门、波次、清房、开门和领奖流程已自动验证通过。

#### 主场景启动验证

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/main/Main.tscn" --quit-after 60
```

结果：

- 退出码：`0`
- 未输出脚本错误。

结论：多房间主场景可正常启动。

#### 静态资源引用验证

- 已检查项目内 `res://` 引用。
- 结果：引用目标均存在。

#### Godot 场景资源格式检查

- 已检查 `.tscn` 和 `.tres` 的 `load_steps`。
- 结果：计数一致。

### 手动测试清单

```text
[ ] 运行 Main.tscn 后，玩家在 Room01 中触发战斗
[ ] Room01 战斗开始后左右门关闭
[ ] Room01 清理完成后左右门打开
[ ] 玩家可以从 Room01 右侧出口进入 Room02
[ ] Room02 会独立触发战斗和锁门
[ ] Room02 清理完成后可以进入 Room03
[ ] Room03 会独立触发战斗和锁门
[ ] 每个房间清理后只生成一次金币奖励
[ ] 每个房间领奖后 Gold 增加
[ ] HUD 房间状态能随当前触发房间更新
```

### 当前已知限制

- 阶段 2 的核心流程已具备，但仍是手工房间链，不是随机地牢。
- 当前 3 个房间使用同一个房间模板，缺少房间布局变化。
- 当前奖励仍只有金币，没有回血、宝箱或遗物选择。
- 当前没有出生房、奖励房、商店房、精英房或 Boss 房类型区分。
- 当前没有小地图。
- 当前没有正式房间切换转场，房间是连续摆放在同一个大场景中。

### 下一步建议

1. 进入阶段 3：把武器、弹道和伤害系统扩展为更完整的数据驱动结构。
2. 实现至少 3 把第一批武器：手枪、霰弹枪、能量法杖。
3. 为子弹补充穿透、反弹、爆炸等扩展字段和最小实现。
4. 后续再回到阶段 4，把当前手工房间链替换为逻辑地牢图和房间模板选择。

## 2026-06-30 阶段 3 武器系统推进

### 阶段

- 当前推进内容：阶段 3，武器、弹道和伤害系统。
- 本次目标：实现第一批 3 把武器，并让玩家可以在局内切换武器；同时补充弹道扩展字段，为后续遗物和更多武器打基础。
- 完成状态：三武器最小版本已实现并通过自动烟测；完整换弹、弹药 UI、反弹/爆炸内容武器仍待后续扩展。

### 已实现功能

#### 武器数据扩展

- `WeaponData.gd` 新增字段：
  - `description`
  - `magazine_size`
  - `reload_duration`
  - `crit_chance`
  - `crit_multiplier`
  - `pierce_count`
  - `bounce_count`
  - `explosion_radius`
  - `tags`
- 现有武器继续通过 `.tres` 数据资源配置，不写死在玩家移动或输入逻辑中。

#### 第一批武器

- 手枪：`basic_pistol.tres`
  - 稳定中距离基础武器。
  - 单发、射速较高、低散射。
- 霰弹枪：`shotgun.tres`
  - 近距离爆发武器。
  - 6 发弹丸、较大散射、较强击退、较短射程。
- 能量法杖：`energy_staff.tres`
  - 慢速高伤穿透武器。
  - 单发、弹速较慢、伤害较高、可穿透 2 个目标。

#### 武器切换

- 玩家新增武器列表 `weapon_loadout`。
- 支持按键切换：
  - `1`：手枪
  - `2`：霰弹枪
  - `3`：能量法杖
- `Weapon.gd` 新增 `set_weapon_data()`，切换武器时重置开火冷却。
- HUD 会同步显示当前武器名称。
- `project.godot` 增加 `weapon_slot_1`、`weapon_slot_2`、`weapon_slot_3` 输入映射。

#### 弹道扩展

- `Projectile.gd` 新增：
  - 暴击伤害计算
  - 穿透次数
  - 反弹次数字段和基础反弹逻辑
  - 爆炸半径字段和范围伤害逻辑
  - 弹丸加入 `projectiles` 分组，便于测试和后续系统查询
- 当前能量法杖已实际使用穿透字段。
- 反弹和爆炸能力已在弹道层支持，但本次没有配置成正式武器。

#### 自动烟测

- 新增 `WeaponSmokeTest.gd`。
- 新增 `WeaponSmokeTest.tscn`。
- 烟测覆盖：
  - 玩家拥有 3 把武器
  - 三把武器均可装备
  - 三把武器均可开火
  - 生成弹丸数量与 `WeaponData.projectile_count` 一致
  - 能量法杖弹丸携带正确穿透次数

### 关键文件

- `dungeon-unleashed/scripts/weapons/WeaponData.gd`
- `dungeon-unleashed/scripts/weapons/Weapon.gd`
- `dungeon-unleashed/scripts/player/Player.gd`
- `dungeon-unleashed/scripts/projectiles/Projectile.gd`
- `dungeon-unleashed/resources/weapons/basic_pistol.tres`
- `dungeon-unleashed/resources/weapons/shotgun.tres`
- `dungeon-unleashed/resources/weapons/energy_staff.tres`
- `dungeon-unleashed/scripts/debug/WeaponSmokeTest.gd`
- `dungeon-unleashed/scenes/debug/WeaponSmokeTest.tscn`
- `dungeon-unleashed/project.godot`

### 自动验证记录

#### 武器烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/WeaponSmokeTest.tscn"
```

结果：

```text
WeaponSmokeTest passed.
```

结论：三武器装备、开火和弹丸数量验证通过。

#### 多房间闭环回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RoomFlowSmokeTest.tscn"
```

结果：

```text
RoomFlowSmokeTest passed.
```

结论：阶段 3 改动未破坏阶段 2 多房间闭环。

#### 主场景启动验证

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/main/Main.tscn" --quit-after 60
```

结果：

- 退出码：`0`
- 未输出脚本错误。

结论：主场景可正常启动。

### 手动测试清单

```text
[ ] 按 1 切换为 Basic Pistol，HUD 武器名更新
[ ] 按 2 切换为 Shotgun，HUD 武器名更新
[ ] 按 3 切换为 Energy Staff，HUD 武器名更新
[ ] 手枪单发稳定，适合中距离
[ ] 霰弹枪一次发射多颗弹丸，近距离爆发明显
[ ] 能量法杖弹速较慢但能穿透敌人
[ ] 切换武器后可以立即开火
[ ] 三把武器都不会影响房间清理流程
```

### 当前已知限制

- `magazine_size` 和 `reload_duration` 已进入数据结构，但尚未实现换弹流程。
- 当前没有弹药或冷却 UI。
- 反弹和爆炸已有弹道层支持，但还没有配置成正式武器或关卡奖励。
- 暴击已有计算，但缺少专门的暴击视觉反馈。
- 伤害系统仍主要在弹丸中处理，尚未独立成专门的 `DamageSystem`。

### 下一步建议

1. 继续阶段 3：补换弹、弹药显示和更清晰的伤害来源结构。
2. 或进入阶段 5 前置：先建立事件驱动遗物系统，让已有武器字段可被遗物修改。
3. 若优先提高可玩内容，下一步可做阶段 6 的第一批敌人差异化。

## 2026-06-30 阶段 3 弹匣和换弹推进

### 阶段

- 当前推进内容：阶段 3，武器、弹道和伤害系统。
- 本次目标：补齐武器弹匣、换弹和弹药 HUD，让三把武器具备更完整的射击循环。
- 完成状态：弹匣、手动换弹、自动换弹、弹药 HUD 已实现并通过自动烟测。

### 已实现功能

#### 弹匣和换弹

- `Weapon.gd` 新增内部弹药状态：
  - 当前弹药
  - 弹匣容量
  - 是否正在换弹
  - 换弹计时器
- 每次成功开火消耗 1 发弹药。
- 弹药为 0 时自动开始换弹。
- 换弹期间不能开火。
- 换弹完成后弹药补满。
- 切换武器时重置该武器弹匣状态。

#### 手动换弹

- 新增输入映射：
  - `reload`
  - 默认按键：`R`
- 玩家按 `R` 时调用当前武器的 `start_reload()`。
- 满弹匣时不会重复换弹。

#### 弹药 HUD

- HUD 新增弹药显示：
  - 正常状态：`Ammo: 当前弹药 / 弹匣容量`
  - 换弹状态：`Ammo: Reloading...`
- `Weapon.gd` 新增 `ammo_changed` 信号。
- `Player.gd` 转发当前武器弹药变化。
- `Main.gd` 监听玩家弹药变化并更新 HUD。

#### 自动烟测更新

- `WeaponSmokeTest.gd` 新增验证：
  - 每次开火消耗 1 发弹药。
  - 手枪打空弹匣后进入自动换弹。
  - 换弹完成后弹药补满。
  - 三把武器仍能正常发射。
  - 三把武器弹丸数量仍与数据配置一致。

### 关键文件

- `dungeon-unleashed/scripts/weapons/Weapon.gd`
- `dungeon-unleashed/scripts/player/Player.gd`
- `dungeon-unleashed/scripts/main/Main.gd`
- `dungeon-unleashed/scripts/ui/HUD.gd`
- `dungeon-unleashed/scenes/ui/HUD.tscn`
- `dungeon-unleashed/scripts/debug/WeaponSmokeTest.gd`
- `dungeon-unleashed/project.godot`

### 自动验证记录

#### 武器烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/WeaponSmokeTest.tscn"
```

结果：

```text
WeaponSmokeTest passed.
```

结论：武器切换、开火、弹丸数量、弹药消耗和自动换弹验证通过。

#### 多房间闭环回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RoomFlowSmokeTest.tscn"
```

结果：

```text
RoomFlowSmokeTest passed.
```

结论：弹匣和换弹改动未破坏多房间闭环。

#### 主场景启动验证

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/main/Main.tscn" --quit-after 60
```

结果：

- 退出码：`0`
- 未输出脚本错误。

结论：主场景可正常启动。

#### 静态资源引用和场景格式

- `res://` 引用检查通过。
- `.tscn` / `.tres` 的 `load_steps` 检查通过。

### 手动测试清单

```text
[ ] HUD 显示当前武器弹药
[ ] 开火后 Ammo 数字减少
[ ] 弹药为 0 后自动显示 Reloading
[ ] 换弹完成后 Ammo 补满
[ ] 按 R 可以手动换弹
[ ] 满弹匣时按 R 不会进入无意义换弹
[ ] 换弹期间不能开火
[ ] 按 1/2/3 切换武器后 Ammo 更新
[ ] 三把武器都能在多个房间中正常完成清房
```

### 当前已知限制

- 换弹时没有专门动画或音效。
- 弹药是每把武器切换时重置，尚未维护每把武器独立残弹。
- 伤害来源仍在弹丸层处理，尚未抽出独立伤害结算系统。
- 暴击、反弹、爆炸缺少对应 UI/特效强调。

### 下一步建议

1. 继续阶段 3：抽出 `DamageData` 或轻量伤害结算结构，明确伤害来源、暴击、倍率、击退和阵营过滤。
2. 开始阶段 6 的敌人差异化，让房间战斗不再只有追踪敌人。
3. 在进入遗物系统前，整理战斗事件字段，保证遗物可以可靠监听开火、命中、击杀、清房和受伤。

## 2026-06-30 敌人差异化推进

### 阶段

- 当前推进内容：阶段 6 前置，敌人生态和房间战斗变化。
- 本次目标：让房间战斗不再只有单一追踪敌人，加入远程射手和冲锋敌人，并让不同房间出现不同敌人组合。
- 完成状态：3 类基础敌人已实现并接入房间生成，自动烟测通过；完整阶段 6 的 6 种普通敌人、精英规则和 Boss 尚未完成。

### 已实现功能

#### 敌人行为扩展

- `Enemy.gd` 新增行为类型：
  - `CHASER`：追踪玩家并通过接触造成压力。
  - `SHOOTER`：保持距离，进入射程后发射敌方子弹。
  - `CHARGER`：接近后进入前摇，然后快速冲锋。
- 敌人新增通用导出参数：
  - `display_name`
  - `behavior_type`
  - `attack_damage`
  - `attack_cooldown`
  - `attack_range`
  - `preferred_range`
  - `projectile_scene`
  - `projectile_speed`
  - `charge_speed`
  - `charge_windup`
  - `charge_duration`
  - `charge_recover`

#### 敌人变体场景

- 新增 `ChaserEnemy.tscn`：
  - 近战追踪敌人。
  - 用作基础压力来源。
- 新增 `ShooterEnemy.tscn`：
  - 远程射手敌人。
  - 会尝试保持距离并发射敌方子弹。
- 新增 `ChargerEnemy.tscn`：
  - 冲锋敌人。
  - 具备攻击前摇、冲锋和恢复阶段。

#### 敌方子弹

- 新增 `EnemyProjectile.gd`。
- 新增 `EnemyProjectile.tscn`。
- 敌方子弹支持：
  - 直线飞行
  - 最大射程
  - 命中玩家后调用 `take_damage`
  - 命中后生成命中特效并销毁

#### 房间敌人组合

- `CombatRoom.gd` 支持 `enemy_scenes` 场景池。
- 房间波次生成时会从 `enemy_scenes` 中轮换选择敌人类型。
- `Main.gd` 对 3 个房间配置不同敌人组合：
  - `Room01`：只生成 Chaser。
  - `Room02`：混合 Chaser 和 Shooter。
  - `Room03`：混合 Shooter、Charger 和 Chaser。
- `Room02` 和 `Room03` 的波次数量也做了差异化。

#### HUD 可读性

- 房间状态显示现在包含房间编号，例如：
  - `Room01 Combat`
  - `Room02 Cleared`
  - `Room03 Reward Claimed`

### 关键文件

- `dungeon-unleashed/scripts/enemies/Enemy.gd`
- `dungeon-unleashed/scenes/enemies/ChaserEnemy.tscn`
- `dungeon-unleashed/scenes/enemies/ShooterEnemy.tscn`
- `dungeon-unleashed/scenes/enemies/ChargerEnemy.tscn`
- `dungeon-unleashed/scripts/projectiles/EnemyProjectile.gd`
- `dungeon-unleashed/scenes/projectiles/EnemyProjectile.tscn`
- `dungeon-unleashed/scripts/rooms/CombatRoom.gd`
- `dungeon-unleashed/scripts/main/Main.gd`
- `dungeon-unleashed/scripts/debug/EnemyVarietySmokeTest.gd`
- `dungeon-unleashed/scenes/debug/EnemyVarietySmokeTest.tscn`

### 自动验证记录

#### 敌人差异化烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/EnemyVarietySmokeTest.tscn"
```

结果：

```text
EnemyVarietySmokeTest passed.
```

结论：

- `Room01` 生成 Chaser。
- `Room02` 生成 Chaser 和 Shooter。
- `Room03` 生成 Shooter 和 Charger。
- 敌方子弹可以对玩家造成伤害。

#### 多房间闭环回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RoomFlowSmokeTest.tscn"
```

结果：

```text
RoomFlowSmokeTest passed.
```

结论：敌人差异化没有破坏房间锁门、波次、清房、开门和领奖流程。

#### 武器系统回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/WeaponSmokeTest.tscn"
```

结果：

```text
WeaponSmokeTest passed.
```

结论：敌人差异化没有破坏武器切换、开火、弹药和换弹流程。

#### 主场景启动验证

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/main/Main.tscn" --quit-after 60
```

结果：

- 退出码：`0`
- 未输出脚本错误。

结论：主场景可正常启动。

#### 静态资源引用和场景格式

- `res://` 引用检查通过。
- `.tscn` / `.tres` 的 `load_steps` 检查通过。

### 手动测试清单

```text
[ ] Room01 主要是近战追踪压力
[ ] Room02 会出现远程射手，玩家需要移动躲避子弹
[ ] Room03 会出现冲锋敌人，玩家能看到冲锋前摇
[ ] Shooter 子弹能造成玩家受伤反馈
[ ] Charger 冲锋不会穿墙导致流程卡死
[ ] 三个房间仍可依次清理并领奖
[ ] 三把武器都能有效击杀不同敌人
```

### 当前已知限制

- 当前只实现了 3 类基础敌人，尚未达到第一版建议的 6 种普通敌人。
- Shooter 和 Charger 仍使用简单几何图形，没有正式攻击动画和音效。
- Charger 的冲锋前摇目前依赖闪色提示，可读性还需要实际手测。
- 没有精英敌人规则。
- 没有 Boss。
- 敌人生成组合仍是手写配置，尚未数据化为房间模板或波次资源。

### 下一步建议

1. 继续补齐第一批敌人：自爆、召唤、护盾敌人。
2. 或进入阶段 4：把当前 3 房间链抽象成地牢逻辑图和房间模板。
3. 后续进入 Boss 前，应先补攻击前摇特效和更清晰的敌方弹道表现。

## 2026-06-30 第一批 6 种普通敌人推进

### 阶段

- 当前推进内容：阶段 6，敌人生态和普通敌人基础组合。
- 本次目标：补齐第一版建议的 6 种普通敌人方向，让战斗房间具备基础组合变化。
- 完成状态：6 种普通敌人已实现并接入房间组合；精英规则和 Boss 仍未完成。

### 已实现功能

#### 新增敌人行为

- `BOMBER`：
  - 接近玩家后进入自爆前摇。
  - 前摇结束后对半径内玩家造成伤害并死亡。
  - 用于迫使玩家拉开距离。
- `SUMMONER`：
  - 保持距离。
  - 周期性召唤 Chaser 小怪。
  - 用于制造目标优先级。
- `SHIELDED`：
  - 正面受击时降低伤害。
  - 从背后或侧后方攻击可正常造成伤害。
  - 用于迫使玩家调整攻击角度。

#### 新增敌人场景

- `BomberEnemy.tscn`
- `SummonerEnemy.tscn`
- `ShieldEnemy.tscn`

当前普通敌人列表：

- Chaser
- Shooter
- Charger
- Bomber
- Summoner
- Shielded

#### 召唤物纳入房间统计

- `Events.gd` 新增 `enemy_spawned` 信号。
- Summoner 召唤小怪时会发出 `enemy_spawned`。
- `CombatRoom.gd` 在战斗中监听该信号，把召唤物加入当前房间存活敌人列表。
- 修复房间存活敌人列表清理方式：现在通过重建有效列表移除已释放引用，避免 typed array 对无效对象执行 `erase()` 导致运行错误。

#### 房间敌人组合更新

- `Room01`：
  - Chaser
- `Room02`：
  - Chaser
  - Shooter
  - Bomber
- `Room03`：
  - Shooter
  - Charger
  - Summoner
  - Shielded
  - Bomber
  - Chaser

### 关键文件

- `dungeon-unleashed/scripts/enemies/Enemy.gd`
- `dungeon-unleashed/scenes/enemies/BomberEnemy.tscn`
- `dungeon-unleashed/scenes/enemies/SummonerEnemy.tscn`
- `dungeon-unleashed/scenes/enemies/ShieldEnemy.tscn`
- `dungeon-unleashed/scripts/core/Events.gd`
- `dungeon-unleashed/scripts/rooms/CombatRoom.gd`
- `dungeon-unleashed/scripts/main/Main.gd`
- `dungeon-unleashed/scripts/debug/EnemyVarietySmokeTest.gd`

### 自动验证记录

#### 敌人差异化烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/EnemyVarietySmokeTest.tscn"
```

结果：

```text
EnemyVarietySmokeTest passed.
```

验证覆盖：

- Room01 生成 Chaser。
- Room02 生成 Chaser、Shooter、Bomber。
- Room03 生成 Shooter、Charger、Summoner、Shielded。
- 敌方子弹能伤害玩家。
- Shielded 正面减伤、背后受伤。
- Summoner 能召唤 Chaser 小怪。
- Bomber 能在自爆前摇后伤害玩家。

#### 多房间闭环回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RoomFlowSmokeTest.tscn"
```

结果：

```text
RoomFlowSmokeTest passed.
```

结论：新增敌人没有破坏房间进入、锁门、波次、清房、开门和领奖流程。

#### 武器系统回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/WeaponSmokeTest.tscn"
```

结果：

```text
WeaponSmokeTest passed.
```

结论：新增敌人没有破坏武器切换、开火、弹药和换弹流程。

#### 主场景启动验证

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/main/Main.tscn" --quit-after 60
```

结果：

- 退出码：`0`
- 未输出脚本错误。

结论：主场景可正常启动。

#### 静态资源引用和场景格式

- `res://` 引用检查通过。
- `.tscn` / `.tres` 的 `load_steps` 检查通过。

### 手动测试清单

```text
[ ] Bomber 接近玩家后有明显前摇
[ ] Bomber 自爆会迫使玩家拉开距离
[ ] Summoner 会召唤 Chaser 小怪
[ ] 玩家能识别 Summoner 是优先击杀目标
[ ] Shielded 正面难打，绕后攻击更有效
[ ] Room02 比 Room01 有更明显远程和自爆压力
[ ] Room03 有混合敌人组合，战斗目标优先级更清楚
[ ] 6 种敌人都不会导致房间无法清理
```

### 当前已知限制

- 6 种普通敌人仍使用占位图形，缺少正式动画和音效。
- Bomber、Charger 的攻击前摇主要依赖闪色提示，实机可读性还需要调。
- Summoner 召唤数量和节奏仍是固定参数。
- Shielded 的护盾判定是角度逻辑，没有独立护盾碰撞体。
- 还没有精英敌人规则。
- 还没有 Boss。

### 下一步建议

1. 进入阶段 4：把当前手工 3 房间链抽象为地牢逻辑图和房间模板选择。
2. 或继续阶段 6：增加精英敌人规则，为 Boss 战前的威胁层级做准备。
3. 补充敌人攻击前摇特效和更清晰的危险提示，避免不公平受伤。

## 2026-06-30 阶段 4 地牢结构生成推进

### 阶段

- 当前推进内容：阶段 4，地牢结构和房间模板的第一步。
- 本次目标：把 `Main.tscn` 中手工摆放的固定 3 房间链，改为运行时由地牢控制器生成的逻辑房间链。
- 完成状态：已实现 4 房间线性主路径生成，并通过自动烟测和既有回归测试；完整随机分支、小地图、正式 Boss 房和多模板选择尚未完成。

### 已实现功能

#### 地牢生成控制器

- 新增 `DungeonController.gd`。
- 主场景启动时由 `DungeonController` 在 `Rooms` 节点下生成房间实例。
- 当前生成数量为 4 个房间：
  - `Room01`：`start`
  - `Room02`：`combat`
  - `Room03`：`elite`
  - `Room04`：`boss_placeholder`
- 每个生成房间都会建立一条逻辑记录，包含：
  - 房间 ID
  - 房间类型
  - 网格坐标
  - 东西方向连接
  - 房间模板 ID
  - 敌人池元数据
  - 波次数量
  - visited / cleared 占位状态字段

#### 主场景接入

- `Main.tscn` 移除了手工实例化的 `Room01`、`Room02`、`Room03`。
- `Main.tscn` 新增 `DungeonController` 节点。
- `Main.gd` 移除了手工查找房间并写入敌人配置的逻辑。
- 房间敌人组合和波次现在由地牢生成器写入对应 `CombatRoom`。
- 现有 HUD、房间状态、敌人数量统计、奖励和金币流程保持兼容。

#### 房间内容配置

- `Room01`：基础 Chaser 压力，波次 `[3, 4]`。
- `Room02`：Chaser / Shooter / Bomber 混合，波次 `[3, 5]`。
- `Room03`：Shooter / Charger / Summoner / Shielded / Bomber / Chaser 混合，波次 `[5, 6]`。
- `Room04`：Boss 占位高压混合房，波次 `[5, 7]`。

#### 地牢生成事件

- `Events.gd` 新增：
  - `dungeon_generated(room_records)`
- 该事件用于后续小地图、地牢 UI、调试面板和房间访问状态同步。

#### 自动烟测

- 新增 `DungeonGenerationSmokeTest.gd`。
- 新增 `DungeonGenerationSmokeTest.tscn`。
- 烟测覆盖：
  - 主场景存在 `DungeonController`。
  - 生成至少 4 条房间逻辑记录。
  - 每条房间记录都有对应 `CombatRoom`。
  - 第一间房标记为 `start`。
  - 最后一间房标记为 `boss_placeholder`。
  - 房间 ID 按 `Room01`、`Room02` 顺序生成。
  - 房间坐标形成水平主路径。
  - 东西方向连接与主路径位置一致。
  - 房间实例名称与逻辑记录一致。
  - 敌人池和波次配置与元数据一致。

### 关键文件

- `dungeon-unleashed/scripts/dungeon/DungeonController.gd`
- `dungeon-unleashed/scenes/main/Main.tscn`
- `dungeon-unleashed/scripts/main/Main.gd`
- `dungeon-unleashed/scripts/core/Events.gd`
- `dungeon-unleashed/scripts/debug/DungeonGenerationSmokeTest.gd`
- `dungeon-unleashed/scenes/debug/DungeonGenerationSmokeTest.tscn`
- `dungeon-unleashed/scripts/debug/RoomFlowSmokeTest.gd`
- `dungeon-unleashed/scripts/debug/EnemyVarietySmokeTest.gd`

### 自动验证记录

#### 地牢生成烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/DungeonGenerationSmokeTest.tscn"
```

结果：

```text
DungeonGenerationSmokeTest passed.
```

结论：地牢逻辑记录、房间实例、主路径连接、模板 ID、敌人池和波次配置均通过自动验证。

#### 多房间闭环回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RoomFlowSmokeTest.tscn"
```

结果：

```text
RoomFlowSmokeTest passed.
```

结论：运行时生成的 4 个房间可以依次完成进房、锁门、波次、清房、领奖流程。

#### 敌人差异化回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/EnemyVarietySmokeTest.tscn"
```

结果：

```text
EnemyVarietySmokeTest passed.
```

结论：地牢生成接入后，6 种普通敌人的生成组合和关键行为仍可验证通过。

#### 武器系统回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/WeaponSmokeTest.tscn"
```

结果：

```text
WeaponSmokeTest passed.
```

结论：地牢生成接入没有破坏武器切换、开火、弹药消耗和换弹流程。

#### 主场景启动验证

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/main/Main.tscn" --quit-after 60
```

结果：

- 退出码：`0`
- 未输出脚本错误。

结论：主场景可正常启动。

#### 静态资源引用和场景格式

- `res://` 引用检查通过。
- `.tscn` / `.tres` 的 `load_steps` 检查通过。

### 手动测试清单

```text
[ ] 运行 Main.tscn 后，玩家出生在 Room01 并触发第一间房战斗
[ ] Room01 清理后可以进入 Room02
[ ] Room02 清理后可以进入 Room03
[ ] Room03 清理后可以进入 Room04
[ ] Room04 显著比前几间房压力更高
[ ] 每个生成房间都会独立锁门、清房、开门和生成奖励
[ ] HUD 房间状态仍能显示当前触发的房间编号和状态
[ ] 连续清完 4 个房间后没有卡死、残留敌人或重复奖励
```

### 当前已知限制

- 当前是逻辑生成的线性主路径，不是随机分支地牢。
- 当前仍只使用 `PrototypeCombatRoom.tscn` 一套房间模板，缺少 20 到 30 个正式模板。
- `boss_placeholder` 只是高压普通战斗房，不是正式 Boss 房。
- 逻辑记录中的 `visited` 和 `cleared` 字段尚未与玩家探索过程同步。
- 尚未实现小地图。
- 尚未实现奖励房、商店房和真正的精英房规则。
- 房间目前只支持左右连接；上下连接需要新房间模板和门方向映射。

### 下一步建议

1. 继续阶段 4：把逻辑房间记录和房间状态绑定，更新 visited / cleared，并为小地图提供数据。
2. 增加最小小地图 UI：当前房、已访问房、相邻房和 Boss 占位房。
3. 建立房间模板数据结构，为后续多模板和分支地牢做准备。
4. 或切入阶段 5：先实现遗物事件系统，让清房奖励不再只有金币。

## 2026-06-30 阶段 4 探索状态和小地图推进

### 阶段

- 当前推进内容：阶段 4，地牢结构、探索状态和地牢 UI 的最小闭环。
- 本次目标：让运行时生成的地牢记录能跟随实际房间状态变化，并在 HUD 中显示一个可读的小地图。
- 完成状态：visited / cleared / current 状态同步已实现，HUD 小地图已接入并通过自动烟测；完整随机分支、小地图交互和正式特殊房间仍未完成。

### 已实现功能

#### 地牢状态同步

- `DungeonController.gd` 现在监听 `Events.room_state_changed`。
- 每个生成房间的逻辑记录会随房间状态更新：
  - `visited`：玩家进入房间后置为 `true`。
  - `cleared`：房间进入 `Cleared` 或 `Reward Claimed` 后置为 `true`。
  - `current`：最近进入或正在处理的房间置为 `true`。
  - `state`：记录当前房间状态文本。
- 新增 `get_current_room_id()`，供 UI 和测试读取当前房间。

#### 地牢更新事件

- `Events.gd` 新增：
  - `dungeon_updated(room_records, current_room_id)`
- `DungeonController` 在生成地牢和房间状态变化后都会广播最新地牢快照。
- `Main.gd` 监听 `dungeon_generated` 和 `dungeon_updated`，并把数据转发给 HUD。
- `Main.gd` 增加一次启动后的 HUD 同步，避免主场景 ready 顺序导致首次生成事件被 HUD 错过。

#### 最小小地图 HUD

- `HUD.tscn` 新增右上角 `MinimapPanel`。
- 小地图以一排字母标记显示当前线性地牢：
  - `S`：Start
  - `C`：Combat
  - `E`：Elite
  - `B`：Boss Placeholder
- 小地图颜色状态：
  - 灰色：未访问普通房。
  - 蓝色：已访问但未清理。
  - 绿色：已清理。
  - 黄色描边：当前房间。
  - 红色：Boss 占位房。
  - 紫色：Elite 占位房。
- HUD 显示当前房间 ID，例如 `Current: Room01`。

#### 自动烟测增强

- `DungeonGenerationSmokeTest.gd` 新增验证：
  - HUD 小地图 marker 数量与生成房间数量一致。
  - 玩家进入第一间房后，`Room01` 被标记为 visited。
  - 玩家进入第一间房后，`Room01` 被标记为 current。
  - `DungeonController.get_current_room_id()` 返回 `Room01`。
  - HUD 小地图当前房间同步为 `Room01`。
  - 清理第一间房后，`Room01` 被标记为 cleared。

### 关键文件

- `dungeon-unleashed/scripts/dungeon/DungeonController.gd`
- `dungeon-unleashed/scripts/core/Events.gd`
- `dungeon-unleashed/scripts/main/Main.gd`
- `dungeon-unleashed/scripts/ui/HUD.gd`
- `dungeon-unleashed/scenes/ui/HUD.tscn`
- `dungeon-unleashed/scripts/debug/DungeonGenerationSmokeTest.gd`

### 自动验证记录

#### 地牢生成、状态同步和小地图烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/DungeonGenerationSmokeTest.tscn"
```

结果：

```text
DungeonGenerationSmokeTest passed.
```

结论：地牢生成记录、房间实例、探索状态同步和 HUD 小地图基础渲染均通过自动验证。

#### 多房间闭环回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RoomFlowSmokeTest.tscn"
```

结果：

```text
RoomFlowSmokeTest passed.
```

结论：探索状态同步和小地图没有破坏 4 个生成房间的进房、锁门、波次、清房和领奖流程。

#### 敌人差异化回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/EnemyVarietySmokeTest.tscn"
```

结果：

```text
EnemyVarietySmokeTest passed.
```

结论：探索状态同步和小地图没有破坏敌人组合与关键行为验证。

#### 武器系统回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/WeaponSmokeTest.tscn"
```

结果：

```text
WeaponSmokeTest passed.
```

结论：探索状态同步和小地图没有破坏武器切换、开火、弹药消耗和换弹流程。

#### 主场景启动验证

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/main/Main.tscn" --quit-after 60
```

结果：

- 退出码：`0`
- 未输出脚本错误。

结论：主场景可正常启动。

#### 静态资源引用和场景格式

- `res://` 引用检查通过。
- `.tscn` / `.tres` 的 `load_steps` 检查通过。

### 手动测试清单

```text
[ ] 运行 Main.tscn 后右上角显示小地图
[ ] 小地图显示 S / C / E / B 四个房间标记
[ ] 进入 Room01 后 Current 显示 Room01
[ ] 当前房间标记变为黄色描边
[ ] 清理 Room01 后 Room01 标记变为已清理颜色
[ ] 进入后续房间时 Current 会切换到对应房间
[ ] 小地图不会遮挡左上角 HP、武器、弹药、金币和房间状态
```

### 当前已知限制

- 小地图目前只支持线性 4 房间显示，不支持二维分支布局。
- 小地图不可交互，也没有鼠标悬停详情之外的正式说明 UI。
- Elite 和 Boss 目前仍是占位房间类型，不是正式规则。
- 地牢状态只覆盖 visited / cleared / current，尚未覆盖奖励是否领取、特殊房间是否购买、Boss 是否击败等完整流程。
- 小地图视觉仍是占位文本标记，后续需要图标化和更清晰的布局。

### 下一步建议

1. 继续阶段 4：建立房间模板数据资源，分离房间类型、敌人池、波次、奖励和模板 ID。
2. 增加奖励房或商店房占位，让地牢不再只有战斗房。
3. 或进入阶段 5：实现遗物系统和遗物选择界面，让清房奖励开始改变 Build。

## 2026-06-30 阶段 4 房间数据资源化和奖励房推进

### 阶段

- 当前推进内容：阶段 4，房间模板配置数据化和基础特殊房间。
- 本次目标：把地牢生成路线从 `DungeonController.gd` 的硬编码配置中拆出来，并加入一个不会生成敌人的奖励房占位。
- 完成状态：房间配置资源化已完成，默认路线扩展为 5 个房间，奖励房可进入、自动清房并生成金币奖励；正式分支地牢、商店房、精英规则和 Boss 战仍未完成。

### 已实现功能

#### 房间数据资源

- 新增 `RoomData.gd`，用于配置地牢房间内容。
- 每个房间数据资源包含：
  - `id`
  - `room_type`
  - `template_id`
  - `room_scene`
  - `enemy_scenes`
  - `enemy_names`
  - `wave_enemy_counts`
  - `reward_scene`
  - `lock_doors_during_combat`
  - `auto_clear_on_enter`
- 新增房间资源目录：`resources/rooms`。
- 新增 5 个房间数据资源：
  - `start_room.tres`
  - `combat_room.tres`
  - `reward_room.tres`
  - `elite_room.tres`
  - `boss_placeholder_room.tres`

#### 地牢生成器改造

- `DungeonController.gd` 不再硬编码敌人场景和波次。
- 默认路线现在由房间数据资源驱动：
  - `Room01`：Start
  - `Room02`：Combat
  - `Room03`：Reward
  - `Room04`：Elite
  - `Room05`：Boss Placeholder
- 逻辑房间记录新增字段：
  - `room_data_id`
  - `auto_clear`
  - `locks_doors`
  - `has_reward`
- `room_data_sequence` 可导出配置，为后续替换路线和随机地牢做准备。

#### 奖励房占位

- `CombatRoom.gd` 新增：
  - `lock_doors_during_combat`
  - `auto_clear_on_enter`
- 奖励房使用同一套 `PrototypeCombatRoom.tscn`，但配置为：
  - 不生成敌人。
  - 不锁门。
  - 进入后直接进入 `Cleared`。
  - 立即生成金币奖励。
- 房间闭环烟测已覆盖奖励房的自动清房、领奖和状态推进。

#### 小地图更新

- HUD 小地图新增奖励房显示：
  - `R`：Reward
- 未访问奖励房使用金币色标记。
- 当前默认小地图路线为 `S / C / R / E / B`。

### 关键文件

- `dungeon-unleashed/scripts/rooms/RoomData.gd`
- `dungeon-unleashed/resources/rooms/start_room.tres`
- `dungeon-unleashed/resources/rooms/combat_room.tres`
- `dungeon-unleashed/resources/rooms/reward_room.tres`
- `dungeon-unleashed/resources/rooms/elite_room.tres`
- `dungeon-unleashed/resources/rooms/boss_placeholder_room.tres`
- `dungeon-unleashed/scripts/dungeon/DungeonController.gd`
- `dungeon-unleashed/scripts/rooms/CombatRoom.gd`
- `dungeon-unleashed/scripts/ui/HUD.gd`
- `dungeon-unleashed/scripts/debug/DungeonGenerationSmokeTest.gd`
- `dungeon-unleashed/scripts/debug/RoomFlowSmokeTest.gd`
- `dungeon-unleashed/scripts/debug/EnemyVarietySmokeTest.gd`

### 自动验证记录

#### 地牢生成、房间数据和奖励房烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/DungeonGenerationSmokeTest.tscn"
```

结果：

```text
DungeonGenerationSmokeTest passed.
```

结论：5 房间路线、房间数据元信息、奖励房本地无敌人、自动清房、当前房间状态和小地图 marker 数量验证通过。

#### 多房间闭环回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RoomFlowSmokeTest.tscn"
```

结果：

```text
RoomFlowSmokeTest passed.
```

结论：Start、Combat、Reward、Elite、Boss Placeholder 五个房间均可按当前规则完成进入、清理、奖励领取和状态推进。

#### 敌人差异化回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/EnemyVarietySmokeTest.tscn"
```

结果：

```text
EnemyVarietySmokeTest passed.
```

结论：奖励房插入后，敌人组合房仍按资源配置生成正确类型；奖励房不生成敌人。

#### 武器系统回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/WeaponSmokeTest.tscn"
```

结果：

```text
WeaponSmokeTest passed.
```

结论：房间数据资源化没有破坏武器切换、开火、弹药消耗和换弹流程。

#### 主场景启动验证

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/main/Main.tscn" --quit-after 60
```

结果：

- 退出码：`0`
- 未输出脚本错误。

结论：主场景可正常启动。

#### 静态资源引用和场景格式

- `res://` 引用检查通过。
- `.tscn` / `.tres` 的 `load_steps` 检查通过。

### 手动测试清单

```text
[ ] 小地图显示 S / C / R / E / B 五个房间标记
[ ] Room03 奖励房进入后不会锁门
[ ] Room03 奖励房不会生成敌人
[ ] Room03 奖励房会直接生成金币奖励
[ ] 领取奖励后 Gold 增加，房间状态进入 Reward Claimed
[ ] Room04 和 Room05 仍会正常生成混合敌人并锁门
[ ] 五个房间可以按顺序完成，没有卡死或重复奖励
```

### 当前已知限制

- 奖励房仍复用战斗房模板，视觉上没有明显区别。
- 奖励房目前只给金币，不提供遗物选择、回血、武器或宝箱。
- Elite 和 Boss Placeholder 仍是普通战斗房配置，不是真正的精英规则或 Boss 战。
- 地牢仍是线性路线，尚未实现随机分支和二维小地图布局。
- 房间数据资源已经建立，但还没有房间模板池和随机选择规则。

### 下一步建议

1. 进入阶段 5：实现遗物数据结构、遗物系统和清房遗物奖励，让奖励房开始提供 Build 变化。
2. 或继续阶段 4：实现房间模板池和简单随机主路径/支路生成。
3. 在加入正式 Boss 前，先把 Elite 规则从占位战斗房拆出来。

## 2026-06-30 阶段 5 遗物系统基础推进

### 阶段

- 当前推进内容：阶段 5，Roguelike Build 和遗物系统。
- 本次目标：建立最小可运行的遗物数据结构、遗物获得流程和战斗数值修改，让奖励房开始提供 Build 变化。
- 完成状态：遗物数据、遗物系统、遗物拾取物、HUD 遗物显示和 4 个基础遗物效果已实现并通过自动烟测；遗物选择界面、稀有度掉落权重、复杂触发型遗物和多选奖励尚未完成。

### 已实现功能

#### 遗物数据结构

- 新增 `RelicData.gd`。
- 遗物数据字段包含：
  - `id`
  - `display_name`
  - `description`
  - `rarity`
  - `effect_type`
  - `effect_value`
  - `stackable`
  - `max_stacks`
  - `tags`
- 新增遗物资源目录：`resources/relics`。

#### 第一批遗物

- `Sharp Rounds`
  - 资源：`sharp_rounds.tres`
  - 效果：子弹伤害提高 25%。
- `Quick Trigger`
  - 资源：`quick_trigger.tres`
  - 效果：武器射速提高 20%。
- `Split Chamber`
  - 资源：`split_chamber.tres`
  - 效果：每次开火额外增加 1 颗弹丸。
- `Phase Tip`
  - 资源：`phase_tip.tres`
  - 效果：子弹额外穿透 1 个敌人。

#### 遗物系统

- 新增 `RelicSystem.gd`。
- `Main.tscn` 新增 `RelicSystem` 节点。
- `RelicSystem` 负责：
  - 管理可用遗物池。
  - 选择奖励遗物。
  - 记录已拥有遗物。
  - 记录堆叠层数。
  - 应用遗物数值效果到玩家。
  - 向 HUD 广播遗物列表。
- `Events.gd` 新增：
  - `relic_collected(relic_data, stack_count)`
  - `relics_changed(relic_summaries)`

#### 战斗数值接入

- `Player.gd` 新增遗物修正字段和接口：
  - 伤害倍率加成。
  - 射速倍率加成。
  - 弹丸数量加成。
  - 穿透次数加成。
- `Weapon.gd` 接入：
  - 射速倍率修正。
  - 弹丸数量加成。
- `Projectile.gd` 接入：
  - 子弹伤害倍率修正。
  - 穿透次数加成。

#### 遗物拾取奖励

- 新增 `RelicPickup.gd`。
- 新增 `RelicPickup.tscn`。
- `RelicPickup` 会从 `RelicSystem` 选择一个可获得遗物。
- 玩家拾取后：
  - 遗物进入 `RelicSystem`。
  - 对应数值立刻生效。
  - 触发 `reward_collected`，房间进入奖励已领取状态。
- `reward_room.tres` 的奖励从金币改为遗物拾取物。

#### HUD 遗物显示

- `HUD.tscn` 新增 `RelicLabel`。
- HUD 显示当前遗物列表：
  - 无遗物时显示 `Relics: None`。
  - 有遗物时显示遗物名称。
  - 多层堆叠时显示 `xN`。
- 获得遗物时屏幕中央显示遗物名称。

### 关键文件

- `dungeon-unleashed/scripts/relics/RelicData.gd`
- `dungeon-unleashed/scripts/relics/RelicSystem.gd`
- `dungeon-unleashed/resources/relics/sharp_rounds.tres`
- `dungeon-unleashed/resources/relics/quick_trigger.tres`
- `dungeon-unleashed/resources/relics/split_chamber.tres`
- `dungeon-unleashed/resources/relics/phase_tip.tres`
- `dungeon-unleashed/scripts/pickups/RelicPickup.gd`
- `dungeon-unleashed/scenes/pickups/RelicPickup.tscn`
- `dungeon-unleashed/scripts/player/Player.gd`
- `dungeon-unleashed/scripts/weapons/Weapon.gd`
- `dungeon-unleashed/scripts/projectiles/Projectile.gd`
- `dungeon-unleashed/scripts/ui/HUD.gd`
- `dungeon-unleashed/scenes/ui/HUD.tscn`
- `dungeon-unleashed/resources/rooms/reward_room.tres`
- `dungeon-unleashed/scripts/debug/RelicSmokeTest.gd`
- `dungeon-unleashed/scenes/debug/RelicSmokeTest.tscn`

### 自动验证记录

#### 遗物系统烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RelicSmokeTest.tscn"
```

结果：

```text
RelicSmokeTest passed.
```

验证覆盖：

- `RelicSystem` 初始为空。
- 可以获得 `Sharp Rounds`、`Quick Trigger`、`Split Chamber`、`Phase Tip`。
- HUD 会显示已获得遗物。
- 伤害倍率会提高子弹伤害。
- 射速倍率会缩短武器冷却。
- 弹丸数量加成会增加生成子弹数。
- 穿透加成会增加子弹穿透次数。
- 奖励房会生成 `RelicPickup`。

#### 地牢生成和奖励房回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/DungeonGenerationSmokeTest.tscn"
```

结果：

```text
DungeonGenerationSmokeTest passed.
```

结论：遗物奖励接入后，地牢生成、奖励房状态、小地图和房间元数据仍通过验证。

#### 多房间闭环回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RoomFlowSmokeTest.tscn"
```

结果：

```text
RoomFlowSmokeTest passed.
```

结论：遗物拾取没有破坏房间进入、锁门、清房、奖励领取和状态推进。

#### 敌人差异化回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/EnemyVarietySmokeTest.tscn"
```

结果：

```text
EnemyVarietySmokeTest passed.
```

结论：遗物系统没有破坏 6 种普通敌人的生成和关键行为验证。

#### 武器系统回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/WeaponSmokeTest.tscn"
```

结果：

```text
WeaponSmokeTest passed.
```

结论：无遗物状态下，原有武器切换、开火、弹药和换弹流程保持稳定。

#### 主场景启动验证

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/main/Main.tscn" --quit-after 60
```

结果：

- 退出码：`0`
- 未输出脚本错误。

结论：主场景可正常启动。

#### 静态资源引用和场景格式

- `res://` 引用检查通过。
- `.tscn` / `.tres` 的 `load_steps` 检查通过。

### 手动测试清单

```text
[ ] 进入 Room03 奖励房后出现遗物拾取物
[ ] 拾取遗物后 HUD 的 Relics 文本更新
[ ] 拾取遗物后屏幕中央显示遗物名称
[ ] Sharp Rounds 让击杀敌人所需命中数减少
[ ] Quick Trigger 让开火频率明显提高
[ ] Split Chamber 让每次开火弹丸数增加
[ ] Phase Tip 让子弹能穿透更多敌人
[ ] 遗物拾取后房间状态进入 Reward Claimed
```

### 当前已知限制

- 目前没有遗物三选一界面，奖励房只生成一个可拾取遗物。
- 遗物选择目前按可用列表顺序选择，不是权重随机。
- 遗物 UI 只是文本列表，没有图标和悬停详情。
- 目前只实现了 4 个直接数值型遗物，尚未实现击杀回血、清房护盾、低血增伤、金币增伤等事件触发型遗物。
- 遗物效果直接作用于玩家数值接口，尚未抽象出更完整的战斗 modifier 管线。

### 下一步建议

1. 增加遗物选择界面，奖励房提供 3 选 1。
2. 扩展事件触发型遗物，例如击杀回血、受伤后短暂增速、清房护盾。
3. 增加遗物稀有度权重和掉落池，为商店房、Boss 奖励和精英房奖励做准备。

## 2026-06-30 阶段 5 遗物三选一界面推进

### 阶段

- 当前推进内容：阶段 5，Roguelike Build 奖励选择。
- 本次目标：把奖励房从“拾取一个固定遗物”升级为“进入奖励房后提供 3 个遗物候选，玩家选择 1 个”。
- 完成状态：遗物 3 选 1 面板、候选生成、选择确认、房间领奖状态推进和自动烟测已完成；候选仍按列表顺序生成，尚未实现稀有度权重随机和正式图标化界面。

### 已实现功能

#### 遗物候选生成

- `RelicSystem.gd` 新增 `get_reward_choices(choice_count)`。
- 当前奖励房默认请求 3 个候选遗物。
- 候选会跳过已经达到最大堆叠上限的遗物。
- 现阶段候选顺序仍按 `available_relics` 列表顺序生成，为后续权重随机留出接口。

#### 遗物选择事件流

- `RelicPickup.gd` 改为触发选择流程：
  - 玩家接触后不再立即获得遗物。
  - 从 `RelicSystem` 获取候选遗物。
  - 隐藏拾取物并停止重复触发。
  - 发出 `Events.relic_choice_requested(choices, pickup, player)`。
- `Events.gd` 新增：
  - `relic_choice_requested(relic_choices, source_pickup, collector)`
  - `relic_choice_selected(index)`
- `Main.gd` 负责暂存当前候选、来源拾取物和领取者。
- `Main.gd` 新增 `choose_relic_reward(index)`，作为遗物选择确认入口。
- 选择成功后：
  - `RelicSystem` 获得对应遗物。
  - HUD 遗物列表更新。
  - 触发 `reward_collected`。
  - 奖励房进入 `Reward Claimed`。
  - 原拾取物移除。

#### HUD 选择面板

- `HUD.tscn` 新增 `RelicChoicePanel`。
- 面板包含 3 个按钮：
  - 显示遗物名称。
  - 显示稀有度。
  - 显示描述。
- `HUD.gd` 新增：
  - `show_relic_choices(...)`
  - `hide_relic_choices()`
  - `is_relic_choice_visible()`
  - `get_relic_choice_count()`
  - `choose_relic_for_test(index)`
- 为避免候选数组引用被 UI 清空影响主场景 pending 状态，`Main.gd` 和 `HUD.gd` 都会复制候选数组。

#### 回归修复

- `RoomFlowSmokeTest.gd` 更新：如果奖励触发了遗物选择面板，测试会选择第一个遗物，再断言房间进入 `Reward Claimed`。
- 修复了遗物选择时 HUD 清空候选数组导致主场景 pending 同步被清空的问题。
- 修复了遗物选择完成后奖励房状态推进不稳定的问题：主场景现在会稳定发出 `reward_collected`。

### 关键文件

- `dungeon-unleashed/scripts/relics/RelicSystem.gd`
- `dungeon-unleashed/scripts/pickups/RelicPickup.gd`
- `dungeon-unleashed/scripts/main/Main.gd`
- `dungeon-unleashed/scripts/ui/HUD.gd`
- `dungeon-unleashed/scenes/ui/HUD.tscn`
- `dungeon-unleashed/scripts/core/Events.gd`
- `dungeon-unleashed/scripts/debug/RelicSmokeTest.gd`
- `dungeon-unleashed/scripts/debug/RoomFlowSmokeTest.gd`

### 自动验证记录

#### 遗物三选一烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RelicSmokeTest.tscn"
```

结果：

```text
RelicSmokeTest passed.
```

验证覆盖：

- 奖励房生成 `RelicPickup`。
- 接触遗物拾取物后打开遗物选择面板。
- 面板展示 3 个候选。
- 主场景存储 3 个 pending 候选。
- HUD 选择第一个候选后，Sharp Rounds 堆叠增加。
- 玩家伤害倍率增加。
- 面板关闭。
- 奖励房进入 `Reward Claimed`。

#### 地牢生成回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/DungeonGenerationSmokeTest.tscn"
```

结果：

```text
DungeonGenerationSmokeTest passed.
```

结论：遗物选择界面没有破坏地牢生成、房间元数据、小地图和探索状态同步。

#### 多房间闭环回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RoomFlowSmokeTest.tscn"
```

结果：

```text
RoomFlowSmokeTest passed.
```

结论：奖励房 3 选 1 后仍能完成完整房间闭环。

#### 敌人差异化回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/EnemyVarietySmokeTest.tscn"
```

结果：

```text
EnemyVarietySmokeTest passed.
```

结论：遗物选择界面没有破坏敌人组合和关键行为验证。

#### 武器系统回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/WeaponSmokeTest.tscn"
```

结果：

```text
WeaponSmokeTest passed.
```

结论：遗物选择界面没有破坏无遗物状态下的武器流程。

#### 主场景启动验证

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/main/Main.tscn" --quit-after 60
```

结果：

- 退出码：`0`
- 未输出脚本错误。

结论：主场景可正常启动。

#### 静态资源引用和场景格式

- `res://` 引用检查通过。
- `.tscn` / `.tres` 的 `load_steps` 检查通过。

### 手动测试清单

```text
[ ] 进入 Room03 奖励房后出现遗物拾取物
[ ] 接触遗物拾取物后出现 3 选 1 面板
[ ] 三个按钮显示遗物名称、稀有度和描述
[ ] 点击其中一个按钮后面板关闭
[ ] 被选择的遗物进入 HUD 的 Relics 列表
[ ] 选择后房间状态进入 Reward Claimed
[ ] 未选择前房间保持 Cleared，不会提前领取奖励
```

### 当前已知限制

- 候选遗物仍按列表顺序生成，不是随机或权重选择。
- 面板是基础按钮 UI，没有图标、卡牌样式和鼠标悬停详情。
- 选择面板没有暂停战斗时间；当前奖励房没有敌人，因此暂不影响流程。
- 目前仍只有 4 个直接数值型遗物，事件触发型遗物尚未实现。

### 下一步建议

1. 实现事件触发型遗物：击杀回血、清房护盾、受伤后增速。
2. 为遗物候选加入稀有度权重和随机选择。
3. 开始阶段 6 的精英规则或 Boss 战，让 Build 奖励有更明确的压力测试目标。

## 2026-06-30 阶段 5 事件触发型遗物推进

### 阶段

- 当前推进内容：阶段 5，事件驱动遗物效果。
- 本次目标：补齐第一批非静态数值遗物，让击杀、清房和受伤事件能改变玩家状态。
- 完成状态：击杀回血、清房护盾、受伤加速 3 类触发型遗物已实现并通过自动烟测；遗物随机权重、图标化 UI 和更多复杂触发链仍未完成。

### 已实现功能

#### 遗物数据扩展

- `RelicData.gd` 的 `effect_type` 新增：
  - `kill_heal`
  - `room_clear_shield`
  - `hurt_speed_boost`
- `RelicData.gd` 新增 `effect_duration`，用于限时效果。

#### 新增遗物

- `Vampire Fang`
  - 资源：`vampire_fang.tres`
  - 效果：每击杀 3 个敌人回复 1 HP。
- `Guardian Ward`
  - 资源：`guardian_ward.tres`
  - 效果：清理房间后获得 1 点护盾。
- `Adrenaline Charm`
  - 资源：`adrenaline_charm.tres`
  - 效果：受伤后移动速度提高 35%，持续 2 秒。

#### RelicSystem 事件监听

- `RelicSystem.gd` 现在监听：
  - `Events.enemy_died`
  - `Events.room_cleared`
  - `Events.player_damaged`
- 静态数值遗物仍在获得时立即应用。
- 事件触发型遗物会在对应事件发生时调用玩家接口：
  - 击杀计数达到阈值后调用 `heal()`。
  - 清房后调用 `add_shield()`。
  - 受伤后调用 `apply_temporary_speed_boost()`。

#### 玩家状态扩展

- `Player.gd` 新增护盾：
  - `current_shield`
  - `max_shield`
  - `shield_changed(current_shield)`
  - `add_shield(amount)`
  - `get_shield()`
- 玩家受伤时优先消耗护盾，再扣生命。
- `Player.gd` 新增回血接口：
  - `heal(amount)`
- `Player.gd` 新增临时速度加成：
  - `apply_temporary_speed_boost(multiplier_bonus, duration)`
  - `get_current_speed_multiplier()`
- 临时速度加成会随 `_tick_timers(delta)` 过期。

#### HUD 护盾显示

- `HUD.tscn` 新增 `ShieldLabel`。
- `HUD.gd` 新增 `update_shield(current_shield)`。
- `Main.gd` 监听玩家 `shield_changed` 并更新 HUD。

### 关键文件

- `dungeon-unleashed/scripts/relics/RelicData.gd`
- `dungeon-unleashed/scripts/relics/RelicSystem.gd`
- `dungeon-unleashed/resources/relics/vampire_fang.tres`
- `dungeon-unleashed/resources/relics/guardian_ward.tres`
- `dungeon-unleashed/resources/relics/adrenaline_charm.tres`
- `dungeon-unleashed/scripts/player/Player.gd`
- `dungeon-unleashed/scripts/main/Main.gd`
- `dungeon-unleashed/scripts/ui/HUD.gd`
- `dungeon-unleashed/scenes/ui/HUD.tscn`
- `dungeon-unleashed/scripts/debug/RelicSmokeTest.gd`

### 自动验证记录

#### 遗物系统烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RelicSmokeTest.tscn"
```

结果：

```text
RelicSmokeTest passed.
```

新增验证覆盖：

- `Vampire Fang` 可获得。
- `Guardian Ward` 可获得。
- `Adrenaline Charm` 可获得。
- 击杀事件累计 3 次后触发回血。
- 清房事件触发护盾增长。
- 护盾会先于生命值吸收伤害。
- 受伤事件触发临时速度提升。
- 临时速度提升会在计时推进后过期。

#### 地牢生成回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/DungeonGenerationSmokeTest.tscn"
```

结果：

```text
DungeonGenerationSmokeTest passed.
```

#### 多房间闭环回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RoomFlowSmokeTest.tscn"
```

结果：

```text
RoomFlowSmokeTest passed.
```

#### 敌人差异化回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/EnemyVarietySmokeTest.tscn"
```

结果：

```text
EnemyVarietySmokeTest passed.
```

#### 武器系统回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/WeaponSmokeTest.tscn"
```

结果：

```text
WeaponSmokeTest passed.
```

#### 主场景启动验证

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/main/Main.tscn" --quit-after 60
```

结果：

- 退出码：`0`
- 未输出脚本错误。

#### 静态资源引用和场景格式

- `res://` 引用检查通过。
- `.tscn` / `.tres` 的 `load_steps` 检查通过。

### 手动测试清单

```text
[ ] 选择 Vampire Fang 后，击杀敌人累计到 3 个会回血
[ ] 选择 Guardian Ward 后，清房会增加 Shield
[ ] Shield 大于 0 时受伤会先消耗 Shield
[ ] 选择 Adrenaline Charm 后，受伤后移动速度短暂提升
[ ] 加速效果过一段时间会恢复正常
[ ] HUD 能显示 Shield 数值
[ ] 新遗物不会导致房间奖励、武器开火或敌人行为异常
```

### 当前已知限制

- 触发型遗物还没有专门视觉/音效反馈。
- Vampire Fang 的击杀阈值目前固定为 3，没有独立数据字段。
- Guardian Ward 的护盾是通用数值护盾，没有护盾破裂反馈。
- Adrenaline Charm 的加速状态没有 HUD 图标或倒计时。
- 遗物候选仍按列表顺序生成，还没有随机权重。

### 下一步建议

1. 为遗物候选加入随机和稀有度权重。
2. 开始阶段 6：实现精英敌人规则，让房间压力与遗物 Build 形成更明显互动。
3. 或进入 Boss 战原型，给当前武器、敌人和遗物系统一个完整通关目标。

## 2026-06-30 阶段 6 精英敌人规则推进

### 阶段

- 当前推进内容：阶段 6，敌人生态和精英规则。
- 本次目标：把 `Room04` 从普通高压战斗房升级为真正的精英房，让普通敌人能以精英变体形式生成。
- 完成状态：精英敌人规则、精英房数据配置、精英死亡爆炸和自动烟测已完成；Boss 战仍未实现。

### 已实现功能

#### 房间数据扩展

- `RoomData.gd` 新增精英配置字段：
  - `elite_enemies`
  - `elite_health_multiplier`
  - `elite_damage_multiplier`
  - `elite_death_explosion_radius`
  - `elite_death_explosion_damage`
- `elite_room.tres` 启用 `elite_enemies = true`。
- `DungeonController.gd` 会把精英配置写入生成出来的 `CombatRoom`。
- 地牢房间记录新增 `elite_enemies` 字段，用于调试和小地图/日志后续扩展。

#### CombatRoom 精英生成

- `CombatRoom.gd` 新增精英导出字段。
- 生成敌人时，如果当前房间启用精英规则，会调用敌人的 `apply_elite_modifiers(...)`。
- 精英规则只作用于配置了 `elite_enemies` 的房间；当前默认路线中是 `Room04`。

#### Enemy 精英变体

- `Enemy.gd` 新增：
  - `is_elite`
  - `elite_death_explosion_radius`
  - `elite_death_explosion_damage`
  - `apply_elite_modifiers(...)`
- 精英变体效果：
  - 显示名增加 `Elite` 前缀。
  - 最大生命值提升。
  - 当前生命值补满到提升后的最大值。
  - 接触伤害和攻击伤害提升。
  - 视觉放大并改为精英色调。
  - 死亡时如果玩家在范围内，会触发精英死亡爆炸伤害。
- 自爆敌人的死亡路径也会触发精英死亡爆炸。

### 关键文件

- `dungeon-unleashed/scripts/rooms/RoomData.gd`
- `dungeon-unleashed/resources/rooms/elite_room.tres`
- `dungeon-unleashed/scripts/dungeon/DungeonController.gd`
- `dungeon-unleashed/scripts/rooms/CombatRoom.gd`
- `dungeon-unleashed/scripts/enemies/Enemy.gd`
- `dungeon-unleashed/scripts/debug/DungeonGenerationSmokeTest.gd`
- `dungeon-unleashed/scripts/debug/EnemyVarietySmokeTest.gd`

### 自动验证记录

#### 地牢生成回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/DungeonGenerationSmokeTest.tscn"
```

结果：

```text
DungeonGenerationSmokeTest passed.
```

验证覆盖：

- 默认路线仍包含 Elite 房。
- Elite 房记录启用 `elite_enemies`。
- Elite 房配置仍与生成的 CombatRoom 一致。

#### 敌人差异化和精英规则烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/EnemyVarietySmokeTest.tscn"
```

结果：

```text
EnemyVarietySmokeTest passed.
```

新增验证覆盖：

- `Room04` 生成精英敌人变体。
- 精英房仍包含 Shooter、Charger、Summoner、Shielded 等基础敌人类型。
- 生成的 Room04 敌人都被标记为 `is_elite`。
- `apply_elite_modifiers(...)` 会提升敌人最大生命值。
- 精英敌人死亡爆炸能伤害附近玩家。

#### 多房间闭环回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RoomFlowSmokeTest.tscn"
```

结果：

```text
RoomFlowSmokeTest passed.
```

结论：精英房规则没有破坏 5 房间路线、奖励领取和房间状态推进。

#### 遗物系统回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RelicSmokeTest.tscn"
```

结果：

```text
RelicSmokeTest passed.
```

结论：精英敌人规则没有破坏遗物获得、遗物选择和事件触发型遗物。

#### 武器系统回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/WeaponSmokeTest.tscn"
```

结果：

```text
WeaponSmokeTest passed.
```

#### 主场景启动验证

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/main/Main.tscn" --quit-after 60
```

结果：

- 退出码：`0`
- 未输出脚本错误。

#### 静态资源引用和场景格式

- `res://` 引用检查通过。
- `.tscn` / `.tres` 的 `load_steps` 检查通过。

### 手动测试清单

```text
[ ] Room04 敌人视觉上比普通敌人更大、更亮
[ ] Room04 敌人比前面房间更耐打
[ ] Room04 敌人造成的压力明显高于 Room02
[ ] 击杀精英敌人时靠太近会受到死亡爆炸伤害
[ ] 拥有护盾时，精英死亡爆炸会先消耗护盾
[ ] 精英房清理后仍能正常开门并生成奖励
```

### 当前已知限制

- 精英规则目前是整房间全部敌人精英化，不是随机挑选单个精英。
- 精英死亡爆炸没有专门预警圈或爆炸特效。
- 精英属性提升仍是通用倍率，没有按敌人类型做差异化。
- 精英敌人没有独立掉落表。
- Boss 战仍未实现。

### 下一步建议

1. 进入 Boss 战原型：独立血条、多阶段行为和通关结算。
2. 或先补精英死亡爆炸的预警和视觉反馈，避免近距离击杀时不公平受伤。
3. 为精英房配置更高价值奖励，和当前遗物系统形成风险收益关系。

## 2026-06-30 阶段 6 Boss 战原型推进

### 阶段

- 当前推进内容：阶段 6，Boss 战原型。
- 本次目标：把默认路线最后一间从 Boss 占位房升级为真正 Boss 房，并提供最小通关闭环。
- 完成状态：Boss 敌人、Boss 房数据、HUD Boss 血条、二阶段行为、通关事件和自动烟测已完成；Boss 战仍是原型级，缺少正式演出、预警和结算统计。

### 已实现功能

#### Boss 房数据

- `RoomData.gd` 的 `room_type` 新增 `boss`。
- `boss_placeholder_room.tres` 现在配置为 Boss 房：
  - `id = boss_room`
  - `room_type = boss`
  - `enemy_scenes = BossEnemy.tscn`
  - `enemy_names = Dungeon Core`
  - `wave_enemy_counts = [1]`
- 地牢默认路线最后一间现在是真实 Boss 房，而不是普通敌人混合占位房。
- 小地图继续用 `B` 标记 Boss 房。

#### Boss 敌人

- 新增 `BossEnemy.gd` 和 `BossEnemy.tscn`。
- Boss 名称：`Dungeon Core`。
- Boss 加入 `enemies` 和 `bosses` 分组，能复用现有房间清理逻辑。
- Boss 支持：
  - 独立生命值。
  - 低于半血进入二阶段。
  - 二阶段提升移动和攻击节奏。
  - 环形弹幕。
  - 朝向玩家的瞄准齐射。
  - 召唤 Chaser 小怪。
  - 死亡时清理自身召唤的小怪。
  - 死亡后触发清房和通关事件。

#### Boss HUD 和通关提示

- `HUD.tscn` 新增 Boss 血条面板。
- `HUD.gd` 新增：
  - `update_boss_health(...)`
  - `hide_boss_health()`
  - `show_completion()`
  - `is_boss_health_visible()`
  - `get_boss_health_value()`
  - `is_completion_visible()`
- Boss 生成后显示 Boss 血条。
- Boss 进入二阶段时显示提示并触发屏幕震动。
- Boss 死亡后隐藏 Boss 血条，显示 `RUN COMPLETE`。

#### 事件系统扩展

- `Events.gd` 新增：
  - `boss_health_changed(boss, current_hp, max_hp)`
  - `boss_phase_changed(boss, phase)`
  - `boss_died(boss)`
  - `run_completed()`
- `Main.gd` 已接入这些事件，负责 HUD 更新、提示和屏幕震动。

#### 测试更新

- 新增 `BossSmokeTest.gd` 和 `BossSmokeTest.tscn`。
- `DungeonGenerationSmokeTest.gd` 更新为验证最后一间是 `boss`。
- `EnemyVarietySmokeTest.gd` 更新为验证 Boss 房生成 `Dungeon Core`，不再验证旧的 Boss 占位普通敌人组合。
- `EnemyProjectile.gd` 新增 `enemy_projectiles` 分组，方便 Boss 弹幕烟测统计。

### 关键文件

- `dungeon-unleashed/scripts/enemies/BossEnemy.gd`
- `dungeon-unleashed/scenes/enemies/BossEnemy.tscn`
- `dungeon-unleashed/resources/rooms/boss_placeholder_room.tres`
- `dungeon-unleashed/scripts/rooms/RoomData.gd`
- `dungeon-unleashed/scripts/core/Events.gd`
- `dungeon-unleashed/scripts/main/Main.gd`
- `dungeon-unleashed/scripts/ui/HUD.gd`
- `dungeon-unleashed/scenes/ui/HUD.tscn`
- `dungeon-unleashed/scripts/projectiles/EnemyProjectile.gd`
- `dungeon-unleashed/scripts/debug/BossSmokeTest.gd`
- `dungeon-unleashed/scenes/debug/BossSmokeTest.tscn`
- `dungeon-unleashed/scripts/debug/DungeonGenerationSmokeTest.gd`
- `dungeon-unleashed/scripts/debug/EnemyVarietySmokeTest.gd`

### 自动验证记录

#### Boss 战烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/BossSmokeTest.tscn"
```

结果：

```text
BossSmokeTest passed.
```

验证覆盖：

- Boss 房生成 `Dungeon Core`。
- Boss 生成后 HUD 显示 Boss 血条。
- Boss 低于半血后进入二阶段。
- Boss 二阶段信号正确触发。
- Boss 环形弹幕会生成敌方子弹。
- Boss 召唤攻击会生成 Chaser 小怪。
- Boss 死亡信号正确触发。
- Boss 死亡后触发 `run_completed`。
- Boss 房在既有房间状态机延迟后进入 `CLEARED`。
- HUD 显示通关提示。

#### 地牢生成回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/DungeonGenerationSmokeTest.tscn"
```

结果：

```text
DungeonGenerationSmokeTest passed.
```

#### 敌人差异化回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/EnemyVarietySmokeTest.tscn"
```

结果：

```text
EnemyVarietySmokeTest passed.
```

#### 房间闭环回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RoomFlowSmokeTest.tscn"
```

结果：

```text
RoomFlowSmokeTest passed.
```

#### 遗物系统回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RelicSmokeTest.tscn"
```

结果：

```text
RelicSmokeTest passed.
```

#### 武器系统回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/WeaponSmokeTest.tscn"
```

结果：

```text
WeaponSmokeTest passed.
```

#### 主场景启动验证

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/main/Main.tscn" --quit-after 60
```

结果：

- 退出码：`0`
- 未输出脚本错误。

#### 静态资源引用和场景格式

- `res://` 引用检查通过。
- `.tscn` / `.tres` 的 `load_steps` 检查通过。

### 手动测试清单

```text
[ ] 进入 Room05 后，Boss 血条显示 Dungeon Core
[ ] Boss 会围绕玩家移动并保持一定距离
[ ] Boss 会释放环形弹幕
[ ] Boss 会朝玩家方向发射齐射
[ ] Boss 会召唤 Chaser 小怪
[ ] Boss 低于半血后进入二阶段，攻击节奏变快
[ ] Boss 死亡后召唤小怪被清理
[ ] Boss 死亡后 Boss 血条隐藏
[ ] Boss 死亡后显示 RUN COMPLETE
[ ] Boss 房清理后仍会开门并生成奖励
```

### 当前已知限制

- Boss 只有一个原型，没有正式 Boss 房专属地形机制。
- Boss 弹幕没有地面预警线或危险范围提示。
- 二阶段只有节奏和弹量变化，没有明显演出。
- Boss 召唤的小怪是 Chaser，缺少专属召唤物。
- 通关结算只是 HUD 提示，没有统计界面、奖励汇总或返回菜单。
- Boss 房奖励仍使用现有金币奖励，没有 Boss 专属掉落。

### 下一步建议

1. 进入阶段 7：补齐主菜单、暂停、死亡结算和通关结算的最小可用 UI。
2. 为 Boss 弹幕和精英死亡爆炸增加预警反馈，降低不公平受伤。
3. 为 Boss 房增加专属奖励或通关后遗物/武器总结。

## 2026-06-30 主流程 UI 原型推进

### 阶段

- 当前推进内容：完整局流程 UI 原型。
- 本次目标：补齐启动、开始、暂停、死亡结算和通关结算，让当前版本从“可测试战斗”推进到“可完成一局”的最小闭环。
- 完成状态：主菜单、暂停菜单、死亡结算、通关结算、重新开始入口和返回主菜单入口已实现并通过自动烟测；设置菜单、设置保存和正式结算统计仍未完成。

### 已实现功能

#### 运行状态

- `Main.gd` 新增运行状态：
  - `MAIN_MENU`
  - `RUNNING`
  - `PAUSED`
  - `DEFEATED`
  - `VICTORY`
- 主场景启动后默认进入主菜单并暂停游戏树。
- 点击开始或调用 `start_new_run()` 后进入运行状态。
- 按 Esc 或调用 `pause_run()` 可暂停。
- 暂停后可恢复、重新开始或返回主菜单。
- 玩家死亡后进入失败结算。
- Boss 死亡触发 `run_completed` 后进入胜利结算。

#### HUD 菜单面板

- `HUD.tscn` 新增：
  - `MainMenuPanel`
  - `PausePanel`
  - `ResultPanel`
- 主菜单提供 `Start Run`。
- 暂停菜单提供：
  - `Resume`
  - `Restart`
  - `Main Menu`
- 结算面板显示：
  - 通关或失败标题。
  - 清理房间数。
  - 击杀数。
  - 金币数。
  - 遗物数量。
  - 本局用时。
  - `Restart`
  - `Main Menu`
- HUD 和 Main 设置为始终处理模式，保证暂停时按钮仍可响应。

#### 输入映射

- `project.godot` 新增：
  - `pause = Escape`
- `Main.gd` 的运行时输入兜底也会绑定 `pause`，避免项目设置缺失时无法暂停。

#### 测试适配

- 现有烟测现在会显式调用 `start_new_run()`，因为主场景已按真实游戏流程从主菜单开始。
- `RoomFlowSmokeTest.gd` 更新：Boss 死亡后以通关结算为终点，不再要求 Boss 房像普通房一样领取清房奖励。

### 关键文件

- `dungeon-unleashed/scripts/main/Main.gd`
- `dungeon-unleashed/scripts/ui/HUD.gd`
- `dungeon-unleashed/scenes/ui/HUD.tscn`
- `dungeon-unleashed/scenes/main/Main.tscn`
- `dungeon-unleashed/project.godot`
- `dungeon-unleashed/scripts/debug/MenuFlowSmokeTest.gd`
- `dungeon-unleashed/scenes/debug/MenuFlowSmokeTest.tscn`
- `dungeon-unleashed/scripts/debug/RoomFlowSmokeTest.gd`
- `dungeon-unleashed/scripts/debug/BossSmokeTest.gd`
- `dungeon-unleashed/scripts/debug/DungeonGenerationSmokeTest.gd`
- `dungeon-unleashed/scripts/debug/EnemyVarietySmokeTest.gd`
- `dungeon-unleashed/scripts/debug/RelicSmokeTest.gd`
- `dungeon-unleashed/scripts/debug/WeaponSmokeTest.gd`

### 自动验证记录

#### 菜单流程烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/MenuFlowSmokeTest.tscn"
```

结果：

```text
MenuFlowSmokeTest passed.
```

验证覆盖：

- 主场景启动后进入主菜单状态。
- 主菜单打开时游戏树暂停。
- `start_new_run()` 会进入运行状态并取消暂停。
- `pause_run()` 会进入暂停状态并显示暂停菜单。
- `resume_run()` 会恢复运行并隐藏暂停菜单。
- 玩家死亡会进入失败结算并暂停。
- `run_completed` 会进入胜利结算并暂停。

#### Boss 战回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/BossSmokeTest.tscn"
```

结果：

```text
BossSmokeTest passed.
```

#### 地牢生成回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/DungeonGenerationSmokeTest.tscn"
```

结果：

```text
DungeonGenerationSmokeTest passed.
```

#### 敌人差异化回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/EnemyVarietySmokeTest.tscn"
```

结果：

```text
EnemyVarietySmokeTest passed.
```

#### 房间闭环回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RoomFlowSmokeTest.tscn"
```

结果：

```text
RoomFlowSmokeTest passed.
```

#### 遗物系统回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RelicSmokeTest.tscn"
```

结果：

```text
RelicSmokeTest passed.
```

#### 武器系统回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/WeaponSmokeTest.tscn"
```

结果：

```text
WeaponSmokeTest passed.
```

#### 主场景启动验证

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/main/Main.tscn" --quit-after 60
```

结果：

- 退出码：`0`
- 未输出脚本错误。

#### 静态资源引用和场景格式

- `res://` 引用检查通过。
- `.tscn` / `.tres` 的 `load_steps` 检查通过。

### 手动测试清单

```text
[ ] 启动 Main.tscn 后先看到主菜单
[ ] 点击 Start Run 后进入游戏
[ ] 游戏运行中按 Esc 可以打开暂停菜单
[ ] 暂停菜单 Resume 可以恢复游戏
[ ] 暂停菜单 Restart 可以重新载入当前局
[ ] 暂停菜单 Main Menu 可以返回主菜单
[ ] 玩家死亡后显示 Run Failed 结算
[ ] 击败 Boss 后显示 Run Complete 结算
[ ] 结算面板显示房间、击杀、金币、遗物和时间统计
[ ] 结算面板 Restart 和 Main Menu 按钮可点击
```

### 当前已知限制

- 设置菜单尚未实现。
- 设置保存尚未实现。
- 重新开始和返回主菜单目前都通过重载当前主场景实现，尚未拆分独立菜单场景。
- 结算统计仍是最小字段，没有伤害、武器、遗物详情和击杀列表。
- 菜单 UI 是原型样式，没有正式视觉设计和音效。

### 下一步建议

1. 实现阶段 7 的经济和商店循环，让金币在局内有消费目标。
2. 实现最小设置菜单和配置保存，覆盖音量或窗口模式等基础项。
3. 为结算面板补充本局 Build 展示和更清晰的重开流程。

## 2026-06-30 阶段 7 经济与商店原型推进

### 阶段

- 当前推进内容：阶段 7，经济、商店和资源循环。
- 本次目标：让金币从“只显示”变成“可获得、可消费、会形成选择”的局内资源。
- 完成状态：击杀金币、清房金币、商店房、三类商品、价格、扣款、售罄和自动烟测已完成；宝箱系统和正式经济平衡仍未完成。

### 已实现功能

#### 局内金币来源

- 敌人死亡现在会给金币：
  - 普通敌人：3 金币。
  - 精英敌人：5 金币。
  - Boss：24 金币。
- 清理战斗类房间会给金币：
  - 开始房：8 金币。
  - 普通战斗房：12 金币。
  - 精英房：18 金币。
  - Boss 房：30 金币。
- 自动清理的奖励房和商店房不会额外给清房金币，避免免费刷资源。
- 金币仍只保存在当前局玩家对象中，重新开始后会重置。

#### 商店房

- 新增 `shop` 房间类型。
- 默认路线从 5 间扩展为 6 间：
  - Room01：开始房。
  - Room02：战斗房。
  - Room03：奖励房。
  - Room04：精英房。
  - Room05：商店房。
  - Room06：Boss 房。
- 商店房自动清理，不锁门，不生成敌人。
- 小地图新增 `$` 标记代表商店房。

#### 商店商品

- 新增 `ShopInventory.gd` 和 `ShopInventory.tscn`。
- 新增 `ShopItem.gd` 和 `ShopItem.tscn`。
- 商店当前提供 3 个商品位：
  - 回血商品。
  - 遗物商品。
  - 武器商品。
- 商品显示名称和价格。
- 玩家金币足够时，接触商品会购买。
- 购买后：
  - 扣除金币。
  - 应用商品效果。
  - 商品显示 `SOLD OUT`。
  - 商品碰撞关闭，避免重复购买。
- 金币不足时不会购买，并显示 `Not Enough Gold`。

#### 商店武器

- 新增商店武器 `Ricochet Blaster`。
- 资源：`resources/weapons/ricochet_blaster.tres`。
- 特点：
  - 2 发弹丸。
  - 中等射速。
  - 子弹可反弹 2 次。
  - 购买后替换并装备玩家当前武器槽位。

#### 玩家经济接口

- `Player.gd` 新增：
  - `can_afford(amount)`
  - `spend_gold(amount)`
  - `buy_weapon(weapon_data)`
- `spend_gold` 会更新 HUD 金币显示。
- `buy_weapon` 会替换当前武器槽位并立即装备。

#### 事件系统扩展

- `Events.gd` 新增：
  - `shop_item_purchased(shop_item, buyer, price, item_type)`
  - `shop_purchase_failed(shop_item, buyer, price, reason)`
- `Main.gd` 监听商店事件并显示购买/失败提示。

### 关键文件

- `dungeon-unleashed/scripts/shop/ShopItem.gd`
- `dungeon-unleashed/scripts/shop/ShopInventory.gd`
- `dungeon-unleashed/scenes/shop/ShopItem.tscn`
- `dungeon-unleashed/scenes/shop/ShopInventory.tscn`
- `dungeon-unleashed/resources/rooms/shop_room.tres`
- `dungeon-unleashed/resources/weapons/ricochet_blaster.tres`
- `dungeon-unleashed/scripts/player/Player.gd`
- `dungeon-unleashed/scripts/main/Main.gd`
- `dungeon-unleashed/scripts/dungeon/DungeonController.gd`
- `dungeon-unleashed/scripts/rooms/RoomData.gd`
- `dungeon-unleashed/scripts/rooms/CombatRoom.gd`
- `dungeon-unleashed/scripts/ui/HUD.gd`
- `dungeon-unleashed/scripts/core/Events.gd`
- `dungeon-unleashed/scripts/debug/ShopSmokeTest.gd`
- `dungeon-unleashed/scenes/debug/ShopSmokeTest.tscn`
- `dungeon-unleashed/scripts/debug/DungeonGenerationSmokeTest.gd`
- `dungeon-unleashed/scripts/debug/EnemyVarietySmokeTest.gd`
- `dungeon-unleashed/scripts/debug/BossSmokeTest.gd`

### 自动验证记录

#### 商店烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/ShopSmokeTest.tscn"
```

结果：

```text
ShopSmokeTest passed.
```

验证覆盖：

- 默认路线包含 Boss 前的商店房。
- 商店房生成 3 个商品。
- 商店提供回血、遗物和武器。
- 购买回血会恢复玩家生命并扣除金币。
- 购买遗物会增加遗物数量并扣除金币。
- 购买武器会装备购买的武器并扣除金币。
- 商品购买后进入售罄状态。
- 金币不足时购买失败并发出失败事件。

#### 地牢生成回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/DungeonGenerationSmokeTest.tscn"
```

结果：

```text
DungeonGenerationSmokeTest passed.
```

#### 敌人差异化回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/EnemyVarietySmokeTest.tscn"
```

结果：

```text
EnemyVarietySmokeTest passed.
```

#### 房间闭环回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RoomFlowSmokeTest.tscn"
```

结果：

```text
RoomFlowSmokeTest passed.
```

#### Boss 战回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/BossSmokeTest.tscn"
```

结果：

```text
BossSmokeTest passed.
```

#### 遗物系统回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RelicSmokeTest.tscn"
```

结果：

```text
RelicSmokeTest passed.
```

#### 武器系统回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/WeaponSmokeTest.tscn"
```

结果：

```text
WeaponSmokeTest passed.
```

#### 菜单流程回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/MenuFlowSmokeTest.tscn"
```

结果：

```text
MenuFlowSmokeTest passed.
```

#### 主场景启动验证

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/main/Main.tscn" --quit-after 60
```

结果：

- 退出码：`0`
- 未输出脚本错误。

#### 静态资源引用和场景格式

- `res://` 引用检查通过。
- `.tscn` / `.tres` 的 `load_steps` 检查通过。

### 手动测试清单

```text
[ ] 击杀敌人后 Gold 增加
[ ] 清理战斗房后 Gold 增加
[ ] 进入 Room05 商店房后看到 3 个商品
[ ] 商店商品显示名称和价格
[ ] 金币足够时，接触回血商品会回血并扣钱
[ ] 金币足够时，接触遗物商品会获得遗物并扣钱
[ ] 金币足够时，接触武器商品会装备新武器并扣钱
[ ] 已购买商品显示 SOLD OUT，不能重复购买
[ ] 金币不足时，接触商品不会购买并显示 Not Enough Gold
[ ] 小地图中商店房显示为 $
```

### 当前已知限制

- 商店购买目前是接触触发，尚未做交互键确认。
- 商店商品 UI 仍是原型文本，没有卡牌样式或详细说明。
- 商店商品池只有一个新增商店武器和少量已有遗物。
- 经济数值尚未经过手感平衡。
- 宝箱系统尚未实现。
- Boss 奖励宝箱尚未实现。

### 下一步建议

1. 实现宝箱系统：普通宝箱、高级宝箱、Boss 奖励宝箱和可配置掉落池。
2. 为商店购买增加交互键确认，避免玩家误触购买。
3. 增加设置菜单和设置保存，推进阶段 8/10 的流程完整度。

## 2026-06-30 阶段 7 宝箱系统推进

### 阶段

- 当前推进内容：阶段 7，宝箱和奖励池。
- 本次目标：补齐普通宝箱、高级宝箱、Boss 奖励宝箱和可配置掉落池，并让 Boss 奖励成为通关结算前的最后一步。
- 完成状态：三类宝箱、掉落池、房间奖励接入、Boss 宝箱通关触发和自动烟测已完成；掉落权重和交互键确认仍未完成。

### 已实现功能

#### 宝箱脚本

- 新增 `RewardChest.gd`。
- 宝箱支持导出配置：
  - `chest_type`
  - `reward_count`
  - `drop_pool`
  - `gold_min`
  - `gold_max`
  - `heal_amount`
  - `relic_pool`
  - `weapon_pool`
  - `complete_run_on_open`
- 宝箱加入：
  - `rewards`
  - `chests`
- 宝箱只能开启一次。
- 开启后关闭碰撞并显示已开启状态。
- 宝箱开启后发出：
  - `Events.chest_opened`
  - `Events.reward_collected`
- Boss 宝箱开启后额外发出：
  - `Events.run_completed`

#### 三类宝箱

- 新增普通宝箱：
  - `scenes/chests/NormalChest.tscn`
  - 主要掉落金币或回血。
- 新增高级宝箱：
  - `scenes/chests/PremiumChest.tscn`
  - 可掉落遗物、金币或回血。
- 新增 Boss 奖励宝箱：
  - `scenes/chests/BossRewardChest.tscn`
  - 可掉落武器、遗物和金币。
  - 开启后进入通关结算。

#### 房间奖励接入

- 普通战斗房奖励从金币改为普通宝箱。
- 精英房奖励从金币改为高级宝箱。
- Boss 房奖励从金币改为 Boss 奖励宝箱。
- 奖励房仍保留遗物三选一。
- 开始房仍保留金币奖励，作为早期经济补给。

#### Boss 通关流程调整

- Boss 死亡现在不再立即触发 `run_completed`。
- Boss 死亡后房间进入清理状态并生成 Boss 奖励宝箱。
- 玩家打开 Boss 奖励宝箱后触发 `run_completed`，进入通关结算。
- 这样 Boss 奖励宝箱是完整流程的一部分，而不是结算后无法领取的摆设。

#### HUD 和事件

- `Events.gd` 新增：
  - `chest_opened(chest, opener, chest_type)`
- `Main.gd` 监听宝箱开启事件：
  - 普通宝箱显示 `Chest Opened`。
  - Boss 宝箱显示 `Boss Reward Claimed`。

### 关键文件

- `dungeon-unleashed/scripts/chests/RewardChest.gd`
- `dungeon-unleashed/scenes/chests/NormalChest.tscn`
- `dungeon-unleashed/scenes/chests/PremiumChest.tscn`
- `dungeon-unleashed/scenes/chests/BossRewardChest.tscn`
- `dungeon-unleashed/resources/rooms/combat_room.tres`
- `dungeon-unleashed/resources/rooms/elite_room.tres`
- `dungeon-unleashed/resources/rooms/boss_placeholder_room.tres`
- `dungeon-unleashed/scripts/enemies/BossEnemy.gd`
- `dungeon-unleashed/scripts/main/Main.gd`
- `dungeon-unleashed/scripts/core/Events.gd`
- `dungeon-unleashed/scripts/debug/ChestSmokeTest.gd`
- `dungeon-unleashed/scenes/debug/ChestSmokeTest.tscn`
- `dungeon-unleashed/scripts/debug/BossSmokeTest.gd`
- `dungeon-unleashed/scripts/debug/RoomFlowSmokeTest.gd`

### 自动验证记录

#### 宝箱烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/ChestSmokeTest.tscn"
```

结果：

```text
ChestSmokeTest passed.
```

验证覆盖：

- 普通宝箱可开启。
- 普通宝箱可按配置给金币。
- 普通宝箱不能重复开启。
- 高级宝箱可同时提供回血和遗物奖励。
- Boss 宝箱配置为开启后完成本局。
- Boss 宝箱开启后触发 `run_completed`。
- 每个测试宝箱只发出一次 `chest_opened`。

#### Boss 战回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/BossSmokeTest.tscn"
```

结果：

```text
BossSmokeTest passed.
```

新增验证覆盖：

- Boss 死亡后不会立刻触发 `run_completed`。
- Boss 房清理后生成可开启奖励宝箱。
- 打开 Boss 奖励宝箱后触发 `run_completed`。
- HUD 显示通关提示。

#### 地牢生成回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/DungeonGenerationSmokeTest.tscn"
```

结果：

```text
DungeonGenerationSmokeTest passed.
```

#### 敌人差异化回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/EnemyVarietySmokeTest.tscn"
```

结果：

```text
EnemyVarietySmokeTest passed.
```

#### 房间闭环回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RoomFlowSmokeTest.tscn"
```

结果：

```text
RoomFlowSmokeTest passed.
```

#### 商店系统回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/ShopSmokeTest.tscn"
```

结果：

```text
ShopSmokeTest passed.
```

#### 遗物系统回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RelicSmokeTest.tscn"
```

结果：

```text
RelicSmokeTest passed.
```

#### 武器系统回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/WeaponSmokeTest.tscn"
```

结果：

```text
WeaponSmokeTest passed.
```

#### 菜单流程回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/MenuFlowSmokeTest.tscn"
```

结果：

```text
MenuFlowSmokeTest passed.
```

#### 主场景启动验证

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/main/Main.tscn" --quit-after 60
```

结果：

- 退出码：`0`
- 未输出脚本错误。

#### 静态资源引用和场景格式

- `res://` 引用检查通过。
- `.tscn` / `.tres` 的 `load_steps` 检查通过。

### 手动测试清单

```text
[ ] 普通战斗房清理后生成普通宝箱
[ ] 普通宝箱打开后给予金币或回血
[ ] 精英房清理后生成高级宝箱
[ ] 高级宝箱打开后可获得遗物、金币或回血
[ ] Boss 死亡后生成 Boss 奖励宝箱
[ ] Boss 死亡后不会立即进入结算
[ ] 打开 Boss 奖励宝箱后进入通关结算
[ ] 宝箱打开后显示已开启状态
[ ] 宝箱不能重复领取奖励
```

### 当前已知限制

- 宝箱仍是接触开启，没有交互键确认。
- 掉落池目前是简单字符串池和资源池，没有权重配置。
- 宝箱没有掉落预览 UI。
- Boss 奖励宝箱没有专属演出。
- 宝箱视觉和音效仍是占位。

### 下一步建议

1. 为商店和宝箱增加统一交互键，避免误触购买或开启。
2. 实现设置菜单和设置保存，补齐阶段 8/10 的主流程要求。
3. 为精英死亡爆炸和 Boss 弹幕增加预警反馈。

## 2026-06-30 统一交互键推进

### 阶段

- 当前推进内容：阶段 8，交互和信息呈现。
- 本次目标：把商店购买和宝箱开启从“接触即触发”改为“靠近后按 `E` 确认”，减少误触购买或误开宝箱。
- 完成状态：`interact = E` 输入映射、商店商品交互、宝箱交互、提示文本和自动烟测已完成；遗物拾取仍保留接触触发三选一。

### 已实现功能

#### 输入映射

- `project.godot` 新增：
  - `interact = E`
- `Main.gd` 的运行时输入兜底也会绑定 `interact`。

#### 商店交互

- `ShopItem.gd` 改为靠近后等待交互。
- 玩家进入商品范围时，商品文本显示 `Press E`。
- 只接触商品不会购买。
- 按 `E` 或调用 `purchase_for_player(player)` 才会购买。
- 金币不足时仍会触发购买失败事件和提示。
- 成功购买后商品进入 `SOLD OUT`，并关闭碰撞。

#### 宝箱交互

- `RewardChest.gd` 改为靠近后等待交互。
- 玩家进入宝箱范围时，宝箱文本显示 `Press E`。
- 只接触宝箱不会开启。
- 按 `E` 或调用 `open_for_player(player)` 才会开启。
- Boss 奖励宝箱仍在开启后触发通关结算。

#### 测试更新

- `ShopSmokeTest.gd` 新增验证：
  - 接触商店商品不会自动购买。
  - 交互购买会扣金币并应用商品效果。
  - 金币不足时交互购买失败。
- `ChestSmokeTest.gd` 新增验证：
  - 接触宝箱不会自动开启。
  - 交互开启后才发放奖励。
- `RoomFlowSmokeTest.gd` 保持直接调用宝箱交互接口，验证房间状态闭环。

### 关键文件

- `dungeon-unleashed/project.godot`
- `dungeon-unleashed/scripts/main/Main.gd`
- `dungeon-unleashed/scripts/shop/ShopItem.gd`
- `dungeon-unleashed/scripts/chests/RewardChest.gd`
- `dungeon-unleashed/scripts/debug/ShopSmokeTest.gd`
- `dungeon-unleashed/scripts/debug/ChestSmokeTest.gd`
- `dungeon-unleashed/scripts/debug/RoomFlowSmokeTest.gd`

### 自动验证记录

#### 商店交互回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/ShopSmokeTest.tscn"
```

结果：

```text
ShopSmokeTest passed.
```

#### 宝箱交互回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/ChestSmokeTest.tscn"
```

结果：

```text
ChestSmokeTest passed.
```

#### 完整回归

通过项目：

```text
BossSmokeTest passed.
RoomFlowSmokeTest passed.
DungeonGenerationSmokeTest passed.
EnemyVarietySmokeTest passed.
ShopSmokeTest passed.
ChestSmokeTest passed.
RelicSmokeTest passed.
WeaponSmokeTest passed.
MenuFlowSmokeTest passed.
Main.tscn 启动通过。
res:// 引用检查通过。
.tscn / .tres load_steps 检查通过。
```

### 手动测试清单

```text
[ ] 靠近商店商品时显示 Press E
[ ] 只碰到商店商品不会购买
[ ] 按 E 后才会购买商品
[ ] 金币不足时按 E 不会购买，并提示 Not Enough Gold
[ ] 靠近宝箱时显示 Press E
[ ] 只碰到宝箱不会开启
[ ] 按 E 后才会打开宝箱
[ ] Boss 奖励宝箱按 E 开启后进入通关结算
```

### 当前已知限制

- 交互提示仍是物体旁边的文本，不是统一 HUD 交互提示条。
- 遗物拾取仍是接触触发三选一，尚未统一到 `E`。
- 商店和宝箱没有键鼠/手柄图标化提示。

### 下一步建议

1. 实现设置菜单和设置保存，补齐阶段 8/10 的主流程要求。
2. 将交互提示统一到 HUD，避免场景中多个文本同时出现。
3. 为精英死亡爆炸和 Boss 弹幕增加预警反馈。

## 2026-06-30 设置菜单与保存推进

### 阶段

- 当前推进内容：阶段 8/10，设置菜单和持久化。
- 本次目标：让主流程具备最小设置菜单，并且设置修改后重启仍然保留。
- 完成状态：主菜单/暂停菜单进入 Settings、主音量、全屏开关、`user://settings.cfg` 保存读取和自动烟测已完成；设置项仍较少，没有键位、分辨率和音效分项。

### 已实现功能

#### 设置数据

- `Main.gd` 新增设置路径：
  - `user://settings.cfg`
- 当前保存字段：
  - `audio/master_volume`
  - `display/fullscreen`
- 主场景启动时会读取设置文件。
- 设置文件不存在时使用默认值：
  - 主音量：`1.0`
  - 全屏：`false`

#### 设置应用

- 主音量会应用到 Godot `Master` 音频总线。
- 音量为 0 时会静音 `Master` 总线。
- 全屏设置会应用到窗口模式。
- Headless CLI 环境会跳过实际窗口模式切换，避免测试环境报错，但仍会保存和读取配置。

#### 设置菜单 UI

- `HUD.tscn` 新增 `SettingsPanel`。
- 主菜单新增 `Settings` 按钮。
- 暂停菜单新增 `Settings` 按钮。
- 设置面板包含：
  - 音量滑条。
  - 音量百分比文本。
  - 全屏开关。
  - `Apply`。
  - `Back`。
- `Apply` 会保存并应用设置。
- `Back` 会返回主菜单或暂停菜单，取决于进入设置前的运行状态。

#### 测试接口

- `Main.gd` 新增：
  - `open_settings_menu()`
  - `close_settings_menu()`
  - `apply_settings(master_volume, fullscreen)`
  - `get_settings_summary()`
- `HUD.gd` 新增：
  - `show_settings_menu(...)`
  - `update_settings_controls(...)`
  - `is_settings_visible()`
  - `get_settings_volume_value()`
  - `get_settings_fullscreen_enabled()`
  - `set_settings_for_test(...)`

### 关键文件

- `dungeon-unleashed/scripts/main/Main.gd`
- `dungeon-unleashed/scripts/ui/HUD.gd`
- `dungeon-unleashed/scenes/ui/HUD.tscn`
- `dungeon-unleashed/scripts/debug/SettingsSmokeTest.gd`
- `dungeon-unleashed/scenes/debug/SettingsSmokeTest.tscn`

### 自动验证记录

#### 设置保存烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/SettingsSmokeTest.tscn"
```

结果：

```text
SettingsSmokeTest passed.
```

验证覆盖：

- 没有设置文件时使用默认设置。
- 主菜单可以打开 Settings 面板。
- 修改音量和全屏后，`Main` 内状态更新。
- 修改后会写入 `user://settings.cfg`。
- 重新创建主场景后能读取保存值。
- 设置 UI 会显示保存后的音量和全屏状态。

#### 完整回归

通过项目：

```text
MenuFlowSmokeTest passed.
BossSmokeTest passed.
RoomFlowSmokeTest passed.
DungeonGenerationSmokeTest passed.
EnemyVarietySmokeTest passed.
ShopSmokeTest passed.
ChestSmokeTest passed.
RelicSmokeTest passed.
WeaponSmokeTest passed.
Main.tscn 启动通过。
res:// 引用检查通过。
.tscn / .tres load_steps 检查通过。
```

### 手动测试清单

```text
[ ] 主菜单点击 Settings 可以打开设置面板
[ ] 暂停菜单点击 Settings 可以打开设置面板
[ ] 音量滑条能调整百分比显示
[ ] Apply 后设置保存
[ ] Back 会返回进入设置前的菜单
[ ] 修改设置后关闭并重新启动项目，设置仍保留
[ ] 全屏开关在编辑器运行窗口中可切换窗口模式
```

### 当前已知限制

- 设置项只有主音量和全屏。
- 没有分辨率选择。
- 没有键位重绑定。
- 没有音效/音乐分离音量。
- 设置 UI 仍是原型样式。

### 下一步建议

1. 为 Boss 弹幕和精英死亡爆炸增加预警反馈，提升受伤原因可读性。
2. 细化通关/死亡结算统计，展示本局武器、遗物和关键数据。
3. 开始准备导出配置和打包验证。

## 2026-06-30 攻击预警反馈推进

### 阶段

- 当前推进内容：阶段 8，战斗风险信息呈现。
- 本次目标：让玩家能在受到精英死亡爆炸或 Boss 弹幕威胁前看到危险区域，降低不可理解受伤。
- 完成状态：通用危险预警特效、精英死亡爆炸预警、Boss 环形弹幕预警、Boss 瞄准齐射预警和自动回归测试已完成；预警视觉仍是占位形状，没有正式动画和音效。

### 已实现功能

#### 通用危险预警

- 新增 `DangerWarning.gd` 和 `DangerWarning.tscn`。
- 支持两种预警形状：
  - 圆形区域。
  - 线形弹道。
- 支持配置：
  - 持续时间。
  - 半径。
  - 长度和宽度。
  - 颜色。
  - 延迟伤害。
- 预警会加入 `danger_warnings` 分组，便于测试和后续调试。

#### 精英死亡爆炸预警

- 精英敌人死亡时不再立即造成死亡爆炸伤害。
- 现在会先生成圆形危险区。
- 0.45 秒后才对仍处于范围内的玩家造成伤害。
- 这样玩家可以通过走位规避爆炸。

#### Boss 弹幕预警

- Boss 新增 `attack_windup`。
- Boss 环形弹幕流程：
  - 先显示圆形危险预警。
  - windup 后发射环形弹幕。
- Boss 瞄准齐射流程：
  - 先沿弹道方向显示线形预警。
  - windup 后发射齐射弹幕。
- Boss 召唤小怪保持即时召唤；如果召唤达到上限，转为瞄准齐射并使用预警流程。

### 关键文件

- `dungeon-unleashed/scripts/effects/DangerWarning.gd`
- `dungeon-unleashed/scenes/effects/DangerWarning.tscn`
- `dungeon-unleashed/scripts/enemies/Enemy.gd`
- `dungeon-unleashed/scripts/enemies/BossEnemy.gd`
- `dungeon-unleashed/scripts/debug/BossSmokeTest.gd`
- `dungeon-unleashed/scripts/debug/EnemyVarietySmokeTest.gd`

### 自动验证记录

#### Boss 战回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/BossSmokeTest.tscn"
```

结果：

```text
BossSmokeTest passed.
```

新增验证覆盖：

- Boss 环形弹幕发射前会创建危险预警。
- 等待 windup 后才生成敌方弹幕。
- Boss 其他既有流程仍然通过。

#### 敌人差异化回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/EnemyVarietySmokeTest.tscn"
```

结果：

```text
EnemyVarietySmokeTest passed.
```

新增验证覆盖：

- 精英死亡爆炸会先创建危险预警。
- 等待预警时间后才伤害附近玩家。

#### 完整回归

通过项目：

```text
RoomFlowSmokeTest passed.
DungeonGenerationSmokeTest passed.
SettingsSmokeTest passed.
MenuFlowSmokeTest passed.
ShopSmokeTest passed.
ChestSmokeTest passed.
RelicSmokeTest passed.
WeaponSmokeTest passed.
Main.tscn 启动通过。
res:// 引用检查通过。
.tscn / .tres load_steps 检查通过。
```

### 手动测试清单

```text
[ ] 击杀精英敌人时出现红色圆形危险预警
[ ] 预警出现后立刻离开范围可以规避死亡爆炸
[ ] 留在预警范围内会在短暂延迟后受伤
[ ] Boss 环形弹幕发射前出现圆形预警
[ ] Boss 瞄准齐射发射前出现线形预警
[ ] Boss 预警和弹幕不会阻断 Boss 房清理或通关流程
```

### 当前已知限制

- 预警视觉是简单多边形，没有正式动画。
- 预警没有音效。
- Boss 召唤小怪没有地面预警。
- 预警颜色和持续时间尚未按难度调优。

### 下一步建议

1. 细化通关/死亡结算统计，展示本局武器、遗物和关键数据。
2. 准备导出配置和打包验证。
3. 后续美术音效阶段替换预警占位视觉。

## 2026-06-30 结算统计与历史记录推进

### 阶段

- 当前推进内容：阶段 8/10，死亡和通关结算信息、历史统计保存。
- 本次目标：让结算面板不再只显示粗略数字，而是能回顾本局 Build、资源流转和关键表现，并保存第一版需要的历史统计。
- 完成状态：本局详细统计、历史统计持久化、结算面板展示和自动烟测已完成；统计仍是文本原型样式，没有正式结算演出和图标化表现。

### 已实现功能

#### 本局结算统计

- `Main.gd` 扩展本局统计：
  - 击杀数。
  - 清理房间数。
  - 当前金币。
  - 本局获得金币。
  - 本局消费金币。
  - 商店购买次数。
  - 宝箱开启次数。
  - 奖励领取次数。
  - 受到伤害。
  - Boss 是否被击败。
  - 最终武器。
  - 武器栏名称。
  - 已获得遗物名称。
  - 当前生命和护盾。
  - 本局用时。
- 死亡和通关都会通过同一套结算数据生成结果摘要。
- 结算只记录一次，避免死亡和通关事件重复触发时污染历史数据。

#### 历史统计保存

- `user://settings.cfg` 新增 `history` 分组。
- 当前保存字段：
  - `runs`
  - `victories`
  - `defeats`
  - `best_rooms`
  - `best_kills`
  - `best_gold`
  - `best_time_seconds`
- 设置保存会保留历史统计，不会因为修改音量或全屏而清空历史。
- 历史统计读取失败或文件不存在时使用安全默认值。

#### 结算 UI

- `HUD.gd` 的结算文本从 5 行基础摘要扩展为完整本局摘要。
- 当前显示内容包括：
  - 结果。
  - 房间、击杀和用时。
  - 金币余额、获得和消费。
  - 最终武器。
  - 武器栏。
  - 遗物列表。
  - 生命、护盾和受伤。
  - 奖励、宝箱和商店购买。
  - Boss 击败状态。
  - 历史局数、胜场和最好记录。
- `ResultPanel` 面板尺寸扩大，并给摘要文本增加自动换行，降低结算文本溢出风险。

### 关键文件

- `dungeon-unleashed/scripts/main/Main.gd`
- `dungeon-unleashed/scripts/ui/HUD.gd`
- `dungeon-unleashed/scenes/ui/HUD.tscn`
- `dungeon-unleashed/scripts/debug/RunSummarySmokeTest.gd`
- `dungeon-unleashed/scenes/debug/RunSummarySmokeTest.tscn`

### 自动验证记录

#### 结算统计烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RunSummarySmokeTest.tscn"
```

结果：

```text
RunSummarySmokeTest passed.
```

验证覆盖：

- 通关后进入 Victory 状态。
- 本局摘要记录击杀、清房、金币获得、金币消费、商店购买、宝箱开启、奖励领取、受伤、Boss 击败、最终武器和遗物名称。
- 结算面板文本包含武器、遗物和历史记录。
- 历史统计会写入 `user://settings.cfg`。
- 重新创建主场景后能读取保存的历史局数和胜场。

#### 完整回归

通过项目：

```text
RunSummarySmokeTest passed.
MenuFlowSmokeTest passed.
SettingsSmokeTest passed.
RoomFlowSmokeTest passed.
DungeonGenerationSmokeTest passed.
BossSmokeTest passed.
EnemyVarietySmokeTest passed.
ShopSmokeTest passed.
ChestSmokeTest passed.
RelicSmokeTest passed.
WeaponSmokeTest passed.
```

### 手动测试清单

```text
[ ] 死亡后结算面板显示 Run Failed
[ ] 通关后结算面板显示 Run Complete
[ ] 结算面板显示本局最终武器
[ ] 结算面板显示本局遗物名称
[ ] 结算面板显示金币获得和消费
[ ] 结算面板显示奖励、宝箱和商店购买次数
[ ] 结算面板显示历史 Runs、Wins 和最好记录
[ ] 完成一局后重启项目，历史统计仍保留
```

### 当前已知限制

- 结算 UI 仍是文本原型，没有图标、分组卡片或动画。
- 历史统计只保存基础最好记录，没有详细每局历史列表。
- 最快通关时间只在胜利时刷新。
- 统计没有区分金币来源明细，例如击杀金币、清房金币和宝箱金币。

### 下一步建议

1. 准备导出配置和打包验证，确认 Windows 可执行版本能启动。
2. 增加基础音效和音量分组，补齐阶段 9/10 的音频要求。
3. 后续把结算面板改为更清晰的分组 UI。

## 2026-06-30 基础音频反馈与音量设置推进

### 阶段

- 当前推进内容：阶段 9/10，表现、音效、手感打磨和设置项补齐。
- 本次目标：在没有正式音频素材的情况下，先提供可验证的占位音效、背景音乐模式和音量分组，让外部试玩版本具备基础听觉反馈。
- 完成状态：SFX/Music 总线、程序化占位音效、背景音乐模式、Master/SFX/Music 三路音量设置和自动烟测已完成；正式音频素材和混音仍未完成。

### 已实现功能

#### 音频目录

- 新增 `audio/sfx`。
- 新增 `audio/music`。
- 新增 `audio/README.md`，说明当前阶段使用程序化占位音频，后续可替换正式 `.wav` / `.ogg` 素材。

#### 音频反馈节点

- 新增 `AudioFeedback.gd`。
- `Main.tscn` 新增 `AudioFeedback` 节点。
- 运行时确保存在：
  - `SFX` 总线。
  - `Music` 总线。
- CLI headless 环境下不会实际创建音频播放器，只模拟音效计数和音乐模式，避免无头测试出现音频播放对象泄漏。

#### 程序化占位音效

- 当前会根据事件播放短音效：
  - 玩家开火。
  - 子弹命中。
  - 敌人死亡。
  - 玩家受伤。
  - 玩家死亡。
  - 房间清理。
  - 奖励领取。
  - 宝箱开启。
  - 商店购买成功。
  - 商店购买失败。
  - Boss 阶段变化。
  - Boss 死亡。
  - 通关。
- 音效由 `AudioStreamGenerator` 程序化生成，正常编辑器/运行环境可听到，占位用途明确。

#### 背景音乐模式

- 当前支持程序化背景音乐模式：
  - `menu`
  - `combat`
  - `boss`
  - `victory`
  - `defeat`
- 进入 Boss 相关事件时切换到 Boss 音乐。
- 通关切换到 victory 音乐。
- 玩家死亡切换到 defeat 音乐。

#### 设置菜单扩展

- 设置菜单从单一音量滑条扩展为：
  - Master。
  - SFX。
  - Music。
  - Fullscreen。
- `user://settings.cfg` 的 `audio` 分组新增：
  - `sfx_volume`
  - `music_volume`
- 修改设置后会保存并重启读取。
- 修改设置不会覆盖已有历史统计。

### 关键文件

- `dungeon-unleashed/scripts/audio/AudioFeedback.gd`
- `dungeon-unleashed/audio/README.md`
- `dungeon-unleashed/scenes/main/Main.tscn`
- `dungeon-unleashed/scripts/main/Main.gd`
- `dungeon-unleashed/scripts/ui/HUD.gd`
- `dungeon-unleashed/scenes/ui/HUD.tscn`
- `dungeon-unleashed/scripts/debug/AudioFeedbackSmokeTest.gd`
- `dungeon-unleashed/scenes/debug/AudioFeedbackSmokeTest.tscn`
- `dungeon-unleashed/scripts/debug/SettingsSmokeTest.gd`

### 自动验证记录

#### 音频反馈烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/AudioFeedbackSmokeTest.tscn"
```

结果：

```text
AudioFeedbackSmokeTest passed.
```

验证覆盖：

- 主场景包含 `AudioFeedback`。
- `SFX` 和 `Music` 总线存在。
- 默认音乐模式为 `menu`。
- 开火、命中、击杀、受伤等事件能触发音效计数。
- Boss 事件会切换到 `boss` 音乐模式。
- 通关事件会切换到 `victory` 音乐模式并触发胜利音效。

#### 设置保存回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/SettingsSmokeTest.tscn"
```

结果：

```text
SettingsSmokeTest passed.
```

新增验证覆盖：

- 默认 Master 音量为 `1.0`。
- 默认 SFX 音量为 `1.0`。
- 默认 Music 音量为 `0.8`。
- 修改 Master/SFX/Music/Fullscreen 后会写入 `user://settings.cfg`。
- 重新创建主场景后能读取保存的三路音量和全屏状态。
- 设置 UI 会显示保存后的三路音量和全屏状态。

### 手动测试清单

```text
[ ] 编辑器运行时主菜单能听到占位背景音乐
[ ] 进入普通战斗房后音乐模式变化
[ ] 进入 Boss 战后音乐模式变化
[ ] 开火、命中、击杀、受伤、清房、开宝箱、购买商品都有占位音效
[ ] 主菜单 Settings 能调整 Master/SFX/Music 三路音量
[ ] 暂停菜单 Settings 能调整 Master/SFX/Music 三路音量
[ ] SFX 调低后短音效明显变小
[ ] Music 调低后背景音乐明显变小
[ ] Master 调低后所有声音变小
[ ] 修改音量后重启项目仍保留
```

### 当前已知限制

- 音频仍是程序化占位声音，不是正式音频素材。
- 没有针对每把武器、每类敌人和每类奖励制作独立正式音效。
- 背景音乐是简化循环音型，没有正式编曲。
- 尚未做混音、响度标准化和音效频率疲劳测试。
- 设置菜单仍没有分辨率和键位重绑定。

### 下一步建议

1. 准备导出配置和 Windows 打包启动验证。
2. 补充分辨率设置和输入提示，继续完善阶段 10。
3. 后续美术音频阶段替换占位音效和背景音乐。

## 2026-06-30 Windows 导出与打包验证推进

### 阶段

- 当前推进内容：阶段 10/11，运行流程、垂直切片验收和发布前检查。
- 本次目标：补齐 Windows 导出配置，生成可执行试玩包，并验证打包版本可以在目标平台启动。
- 完成状态：Windows 导出预设、Godot 4.7 Windows 导出模板、release `.exe`、启动验证、试玩说明和 zip 包已完成；代码签名、安装器、发布页和外部分发流程仍未完成。

### 已实现功能

#### Windows 导出预设

- 新增 `dungeon-unleashed/export_presets.cfg`。
- 预设名称：
  - `Windows Desktop`
- 导出目标：
  - `builds/windows/Dungeon Unleashed.exe`
- 当前配置：
  - Windows x86_64。
  - release 导出。
  - 嵌入 PCK。
  - 使用项目图标。
  - 产品版本 `0.1.0`。
  - 排除 `scenes/debug/*` 和 `scripts/debug/*`，避免把自动测试场景打进试玩包。

#### 导出模板

- 下载并安装 Godot 4.7 官方导出模板到项目内用户数据目录：
  - `godot_user_data/appdata/Godot/export_templates/4.7.stable/windows_debug_x86_64.exe`
  - `godot_user_data/appdata/Godot/export_templates/4.7.stable/windows_release_x86_64.exe`
- 模板仅放在当前工作区内，没有写入系统 Godot 配置目录。

#### 打包产物

- 生成 Windows release 可执行文件：
  - `dungeon-unleashed/builds/windows/Dungeon Unleashed.exe`
- 新增试玩说明：
  - `dungeon-unleashed/builds/windows/README_PLAYTEST.md`
- 生成试玩压缩包：
  - `dungeon-unleashed/builds/Dungeon_Unleashed_Windows_Prototype.zip`
- 旧的 `.pck` 中间验证产物已删除，避免误用；当前 `.exe` 已内嵌资源。

### 关键文件

- `dungeon-unleashed/export_presets.cfg`
- `dungeon-unleashed/builds/windows/Dungeon Unleashed.exe`
- `dungeon-unleashed/builds/windows/README_PLAYTEST.md`
- `dungeon-unleashed/builds/Dungeon_Unleashed_Windows_Prototype.zip`

### 自动验证记录

#### PCK 数据包导出

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --export-pack "Windows Desktop" "builds/windows/Dungeon Unleashed.pck"
```

结果：

```text
退出码：0
```

结论：导出预设可用于资源打包。

#### Windows release 可执行导出

命令：

```powershell
$env:APPDATA=(Resolve-Path 'godot_user_data\appdata').Path
$env:LOCALAPPDATA=(Resolve-Path 'godot_user_data\localappdata').Path
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --export-release "Windows Desktop" "builds/windows/Dungeon Unleashed.exe"
```

结果：

```text
退出码：0
```

结论：Windows release `.exe` 导出成功。

#### Windows release 启动验证

命令：

```powershell
& "E:\Dungeon Unleashed\dungeon-unleashed\builds\windows\Dungeon Unleashed.exe" --headless --quit-after 60
```

结果：

```text
退出码：0
```

结论：打包后的 Windows 可执行文件可以启动并运行 60 帧后正常退出。

#### 试玩 zip 包生成

命令：

```powershell
Compress-Archive -LiteralPath 'dungeon-unleashed\builds\windows\Dungeon Unleashed.exe','dungeon-unleashed\builds\windows\README_PLAYTEST.md' -DestinationPath 'dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip' -Force
```

结果：

```text
E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
```

结论：Windows 原型试玩包已生成。

#### 打包后完整回归

通过项目：

```text
AudioFeedbackSmokeTest passed.
RunSummarySmokeTest passed.
MenuFlowSmokeTest passed.
SettingsSmokeTest passed.
RoomFlowSmokeTest passed.
DungeonGenerationSmokeTest passed.
BossSmokeTest passed.
EnemyVarietySmokeTest passed.
ShopSmokeTest passed.
ChestSmokeTest passed.
RelicSmokeTest passed.
WeaponSmokeTest passed.
Main.tscn headless startup passed.
Exported exe headless startup passed.
res:// reference check passed.
.tscn / .tres load_steps check passed.
Package exists: E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
```

### 手动测试清单

```text
[ ] 解压 Dungeon_Unleashed_Windows_Prototype.zip
[ ] 双击 Dungeon Unleashed.exe 可以启动
[ ] 主菜单能显示
[ ] Start Run 能开始新局
[ ] WASD、鼠标瞄准、左键射击、R 换弹、1/2/3 切换武器可用
[ ] E 能开启宝箱和购买商店商品
[ ] Esc 能暂停
[ ] 能完成 Boss 房并进入通关结算
[ ] 死亡后能进入失败结算
[ ] Settings 的 Master/SFX/Music/Fullscreen 能保存
```

### 当前已知限制

- Windows 可执行文件未代码签名，首次运行可能出现安全提示。
- 当前只生成 zip 包，没有安装器或自动更新。
- 仍未准备正式发布页或外部反馈表单。
- 正式美术和正式音频素材仍未接入。
- 仍需要实际窗口模式手动测试，CLI 只验证 headless 启动。

### 下一步建议

1. 做一次人工窗口运行验收，确认双击启动、输入、音频和全屏设置。
2. 补充分辨率设置和输入提示，继续完善阶段 10。
3. 准备外部试玩反馈入口和已知问题列表。

## 2026-06-30 分辨率设置、输入提示和试玩材料推进

### 阶段

- 当前推进内容：阶段 8/10/11，UI 信息呈现、设置项补齐和外部试玩准备。
- 本次目标：补齐发布前检查中缺少的分辨率设置、输入提示、试玩反馈入口和已知问题列表，让 Windows 原型包更接近外部试玩交付状态。
- 完成状态：分辨率设置、HUD 输入提示、反馈模板、已知问题列表、打包说明更新和相关烟测已完成；键位重绑定、正式发布页和人工窗口验收仍未完成。

### 已实现功能

#### 分辨率设置

- Settings 面板新增 `Resolution` 下拉框。
- 当前支持：
  - `1280 x 720`
  - `1600 x 900`
  - `1920 x 1080`
- `user://settings.cfg` 新增：
  - `display/resolution_width`
  - `display/resolution_height`
- 主场景启动时会读取保存分辨率。
- `Apply` 后会保存分辨率，并在非 headless 环境中应用窗口大小。
- Headless CLI 环境仍跳过实际窗口变化，保证自动测试稳定。

#### 输入提示

- HUD 右下角新增输入提示：
  - `WASD Move`
  - `Mouse Aim`
  - `LMB Shoot`
  - `R Reload`
  - `1/2/3 Weapons`
  - `E Interact`
  - `Esc Pause`
- `MenuFlowSmokeTest` 新增断言，确认 HUD 输出移动、交互和暂停提示。

#### 试玩材料

- 新增根目录反馈模板：
  - `PLAYTEST_FEEDBACK.md`
- 新增根目录已知问题列表：
  - `KNOWN_ISSUES.md`
- 打包目录新增：
  - `builds/windows/PLAYTEST_FEEDBACK.md`
  - `builds/windows/KNOWN_ISSUES.md`
- 更新 `builds/windows/README_PLAYTEST.md`：
  - 增加 Resolution 设置测试。
  - 指向反馈模板和已知问题列表。
  - 移除“没有分辨率设置”的过期说明。

### 关键文件

- `dungeon-unleashed/scripts/main/Main.gd`
- `dungeon-unleashed/scripts/ui/HUD.gd`
- `dungeon-unleashed/scenes/ui/HUD.tscn`
- `dungeon-unleashed/scripts/debug/SettingsSmokeTest.gd`
- `dungeon-unleashed/scripts/debug/MenuFlowSmokeTest.gd`
- `PLAYTEST_FEEDBACK.md`
- `KNOWN_ISSUES.md`
- `dungeon-unleashed/builds/windows/README_PLAYTEST.md`
- `dungeon-unleashed/builds/windows/PLAYTEST_FEEDBACK.md`
- `dungeon-unleashed/builds/windows/KNOWN_ISSUES.md`

### 自动验证记录

#### 菜单流程回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/MenuFlowSmokeTest.tscn"
```

结果：

```text
MenuFlowSmokeTest passed.
```

新增验证覆盖：

- HUD 输入提示包含 `WASD`。
- HUD 输入提示包含 `E Interact`。
- HUD 输入提示包含 `Esc Pause`。

#### 设置保存回归

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/SettingsSmokeTest.tscn"
```

结果：

```text
SettingsSmokeTest passed.
```

新增验证覆盖：

- 默认分辨率为 `1280 x 720`。
- 修改分辨率为 `1920 x 1080` 后会写入 `user://settings.cfg`。
- 重新创建主场景后能读取保存分辨率。
- Settings UI 会显示保存后的分辨率选项。

#### Windows 包重新导出与校验

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --export-release "Windows Desktop" "builds/windows/Dungeon Unleashed.exe"
& "E:\Dungeon Unleashed\dungeon-unleashed\builds\windows\Dungeon Unleashed.exe" --headless --quit-after 60
Compress-Archive -LiteralPath 'dungeon-unleashed\builds\windows\Dungeon Unleashed.exe','dungeon-unleashed\builds\windows\README_PLAYTEST.md','dungeon-unleashed\builds\windows\PLAYTEST_FEEDBACK.md','dungeon-unleashed\builds\windows\KNOWN_ISSUES.md' -DestinationPath 'dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip' -Force
```

结果：

```text
Main scene startup passed.
Exported exe startup passed.
Exported exe window/audio startup passed.
Zip contents check passed.
Resource reference check passed.
Scene/resource load_steps check passed.
Package exists: E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip (38144669 bytes)
```

新增校验覆盖：

- 重新导出的 `.exe` 包含分辨率设置和输入提示改动。
- `.exe` 可 headless 启动 60 帧。
- `.exe` 可使用 Windows 显示驱动和 WASAPI 音频驱动启动 120 帧并正常退出。
- zip 包包含：
  - `Dungeon Unleashed.exe`
  - `README_PLAYTEST.md`
  - `PLAYTEST_FEEDBACK.md`
  - `KNOWN_ISSUES.md`
- 导出预设已排除 `scenes/debug/*`、`scripts/debug/*` 和 `builds/*`。

### 手动测试清单

```text
[ ] 主菜单 Settings 中能看到 Resolution 下拉框
[ ] Resolution 可以选择 1280 x 720、1600 x 900、1920 x 1080
[ ] Apply 后窗口大小变化
[ ] 重启后 Resolution 保留
[ ] Fullscreen 与 Resolution 同时设置时不会卡死或黑屏
[ ] HUD 右下角输入提示不遮挡战斗
[ ] 打包 zip 内包含 README_PLAYTEST.md、PLAYTEST_FEEDBACK.md、KNOWN_ISSUES.md
```

### 当前已知限制

- 分辨率只有三个预设，没有读取显示器可用分辨率列表。
- 还没有键位重绑定。
- 输入提示是固定键鼠提示，没有手柄提示。
- 反馈入口仍是 Markdown 模板，没有在线表单。
- 已知问题列表需要随人工窗口测试结果继续更新。

### 下一步建议

1. 重新导出 Windows zip，确保新增试玩材料进入最终包。
2. 做一次人工窗口运行验收，确认分辨率、音频、全屏和 UI 布局。
3. 根据人工验收结果更新 `KNOWN_ISSUES.md`。

## 2026-06-30 遗物内容扩展与构建回归

### 阶段

- 当前推进内容：阶段 5 内容深度补强，同时回归阶段 3 武器/弹丸、阶段 10 设置/打包和阶段 11 垂直切片验收基础。
- 本次目标：把第一版遗物数量从 7 个扩充到 10 个，接近 `DEVELOPMENT_PLAN.md` 中第一版建议的 10 到 15 个遗物范围，并增加新的 Build 方向。
- 完成状态：新增暴击、换弹速度、生命上限三类遗物效果，完整烟测套件通过，Windows release `.exe` 和 zip 试玩包已重新导出。

### 新增功能

#### 新增遗物

- `Lucky Primer`
  - 资源：`dungeon-unleashed/resources/relics/lucky_primer.tres`
  - 稀有度：Rare
  - 效果：子弹获得额外暴击率。
- `Swift Loader`
  - 资源：`dungeon-unleashed/resources/relics/swift_loader.tres`
  - 稀有度：Common
  - 效果：武器换弹速度提升。
- `Heart Core`
  - 资源：`dungeon-unleashed/resources/relics/heart_core.tres`
  - 稀有度：Rare
  - 效果：提升生命上限并立即治疗。

#### 战斗系统接入

- `RelicData.gd` 扩展遗物效果类型：
  - `crit_chance_bonus`
  - `reload_speed_multiplier`
  - `max_health`
- `Player.gd` 新增：
  - 暴击率加成累计。
  - 换弹速度倍率累计。
  - 生命上限提升和即时治疗。
  - `get_crit_chance_bonus()`。
  - `get_reload_speed_multiplier()`。
- `Projectile.gd` 现在会把玩家暴击率遗物加成叠加到武器暴击率。
- `Weapon.gd` 现在会按玩家换弹速度倍率缩短换弹计时。
- `RelicSystem.gd` 的可用遗物池已加入 10 个遗物。

### 关键文件

- `dungeon-unleashed/scripts/relics/RelicData.gd`
- `dungeon-unleashed/scripts/relics/RelicSystem.gd`
- `dungeon-unleashed/scripts/player/Player.gd`
- `dungeon-unleashed/scripts/weapons/Weapon.gd`
- `dungeon-unleashed/scripts/projectiles/Projectile.gd`
- `dungeon-unleashed/scripts/debug/RelicSmokeTest.gd`
- `dungeon-unleashed/resources/relics/lucky_primer.tres`
- `dungeon-unleashed/resources/relics/swift_loader.tres`
- `dungeon-unleashed/resources/relics/heart_core.tres`

### 自动验证记录

#### 遗物烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RelicSmokeTest.tscn"
```

结果：

```text
RelicSmokeTest passed.
```

新增验证覆盖：

- `RelicSystem.available_relics` 至少包含 10 个遗物。
- `Lucky Primer` 会提升玩家暴击率加成，并反映到生成的子弹 `crit_chance`。
- `Swift Loader` 会提升玩家换弹速度倍率，并缩短武器 `_reload_timer`。
- `Heart Core` 会提高 `max_health` 并立即治疗 1 点。

#### 完整烟测套件

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/AudioFeedbackSmokeTest.tscn"
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RunSummarySmokeTest.tscn"
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/MenuFlowSmokeTest.tscn"
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/SettingsSmokeTest.tscn"
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RoomFlowSmokeTest.tscn"
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/DungeonGenerationSmokeTest.tscn"
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/BossSmokeTest.tscn"
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/EnemyVarietySmokeTest.tscn"
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/ShopSmokeTest.tscn"
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/ChestSmokeTest.tscn"
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RelicSmokeTest.tscn"
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/WeaponSmokeTest.tscn"
```

结果：

```text
All smoke tests passed.
```

通过项目：

- `AudioFeedbackSmokeTest`
- `RunSummarySmokeTest`
- `MenuFlowSmokeTest`
- `SettingsSmokeTest`
- `RoomFlowSmokeTest`
- `DungeonGenerationSmokeTest`
- `BossSmokeTest`
- `EnemyVarietySmokeTest`
- `ShopSmokeTest`
- `ChestSmokeTest`
- `RelicSmokeTest`
- `WeaponSmokeTest`

#### 主场景启动验证

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/main/Main.tscn" --quit-after 60
```

结果：

```text
Exit code 0.
```

#### Windows 包重新导出与校验

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --export-release "Windows Desktop" "builds/windows/Dungeon Unleashed.exe"
& "E:\Dungeon Unleashed\dungeon-unleashed\builds\windows\Dungeon Unleashed.exe" --headless --quit-after 60
Compress-Archive -LiteralPath 'dungeon-unleashed\builds\windows\Dungeon Unleashed.exe','dungeon-unleashed\builds\windows\README_PLAYTEST.md','dungeon-unleashed\builds\windows\PLAYTEST_FEEDBACK.md','dungeon-unleashed\builds\windows\KNOWN_ISSUES.md' -DestinationPath 'dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip' -Force
```

结果：

```text
Exported exe startup passed.
Zip contents check passed.
Resource reference check passed.
Scene/resource load_steps check passed.
Package exists: E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip (38146284 bytes)
```

### 手动测试清单

```text
[ ] 在遗物三选一或商店中获得 Lucky Primer 后，确认高暴击 Build 的伤害波动更明显
[ ] 获得 Swift Loader 后，确认换弹间隔体感缩短
[ ] 获得 Heart Core 后，确认 HUD HP 上限增加
[ ] 多次堆叠新增遗物后，确认数值变化没有失控到破坏 Boss 战
[ ] 确认新增遗物出现在奖励、商店或宝箱相关流程中时，界面文本清晰可读
```

### 当前已知限制

- 遗物候选已按稀有度权重随机，但尚未实现独立掉落池配置、保底规则或稀有度展示特效。
- 新增遗物没有专属图标、音效或获得特效。
- 暴击已有独立命中特效、音效和屏幕震动，但还没有浮字或伤害数字。
- 换弹速度变化没有独立 UI 数值展示，只能通过手感和烟测确认。

### 下一步建议

1. 为奖励房、宝箱和商店拆分独立掉落池权重。
2. 给暴击、治疗、护盾等关键事件增加浮字或更明确的 UI 反馈。
3. 做一次人工完整通关测试，重点观察新增遗物对难度曲线和 Boss 战时长的影响。

## 2026-06-30 遗物稀有度权重随机推进

### 阶段

- 当前推进内容：阶段 5，遗物奖励候选随机化和稀有度权重。
- 本次目标：把遗物三选一从固定列表顺序升级为可重复测试的稀有度权重随机，提升多局可重复试玩差异。
- 完成状态：奖励候选已按稀有度权重随机、单次候选不重复、测试可通过固定 seed 复现；完整烟测套件通过，Windows release `.exe` 和 zip 试玩包已重新导出。

### 新增功能

- `RelicSystem.gd` 新增稀有度权重：
  - Common：`100`
  - Rare：`45`
  - Epic：`18`
  - Legendary：`6`
- `choose_reward_relic()` 改为从可获得遗物中按权重抽取。
- `get_reward_choices(choice_count)` 改为按权重抽取多个候选，且同一组选项不会重复。
- 新增 `set_random_seed(seed)`，用于烟测中复现随机候选。
- 新增 `get_rarity_weight(rarity)`，用于验证稀有度权重配置。

### 关键文件

- `dungeon-unleashed/scripts/relics/RelicSystem.gd`
- `dungeon-unleashed/scripts/debug/RelicSmokeTest.gd`

### 自动验证记录

#### 遗物随机候选烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RelicSmokeTest.tscn"
```

结果：

```text
RelicSmokeTest passed.
```

新增验证覆盖：

- Common 权重大于 Rare。
- Rare 权重大于 Epic。
- Epic 权重大于 Legendary。
- 同一 seed 下生成的 3 个候选可复现。
- 同一组候选不会出现重复遗物。
- 奖励房选择第一个随机候选后，对应遗物堆叠会正确增加。

#### 完整烟测套件

结果：

```text
All smoke tests passed.
```

通过项目：

- `AudioFeedbackSmokeTest`
- `RunSummarySmokeTest`
- `MenuFlowSmokeTest`
- `SettingsSmokeTest`
- `RoomFlowSmokeTest`
- `DungeonGenerationSmokeTest`
- `BossSmokeTest`
- `EnemyVarietySmokeTest`
- `ShopSmokeTest`
- `ChestSmokeTest`
- `RelicSmokeTest`
- `WeaponSmokeTest`

#### Windows 包重新导出与校验

结果：

```text
Exported exe startup passed.
Zip contents check passed.
Main scene startup passed.
Resource reference check passed.
Scene/resource load_steps check passed.
Package exists: E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip (38147586 bytes)
```

### 手动测试清单

```text
[ ] 多次进入奖励房，确认 3 个遗物候选不总是固定前三个
[ ] 多局游玩时，确认常见遗物出现频率高于稀有遗物
[ ] 确认已有满堆叠遗物不会继续出现在候选中
[ ] 打开宝箱 fallback 遗物奖励时不会报错或卡住
```

### 当前已知限制

- 稀有度权重是代码常量，不是外部数据文件。
- 奖励房、宝箱 fallback 共用同一套权重，尚未按房间或奖励来源拆分掉落池。
- 没有保底机制，短局中仍可能出现体感偏差。
- 稀有度没有图标、边框色或特效表现。

### 下一步建议

1. 为遗物候选 UI 添加稀有度颜色和效果标签。
2. 将权重迁移到可配置资源或数据表。
3. 为不同奖励来源配置独立掉落池。

## 2026-06-30 暴击命中反馈推进

### 阶段

- 当前推进内容：阶段 9，表现、音效和手感打磨。
- 本次目标：让暴击 Build 的输出差异不只体现在数值上，而是在命中瞬间有可感知反馈。
- 完成状态：暴击命中事件、橙红色放大命中特效、暴击音效和更强屏幕震动已接入；完整烟测套件通过，Windows release `.exe` 和 zip 试玩包已重新导出。

### 新增功能

- `Events.gd` 新增信号：
  - `projectile_critical_hit(projectile, target, damage)`
- `Projectile.gd` 调整伤害结算：
  - `_roll_damage()` 返回伤害和是否暴击。
  - 暴击命中后仍发出原有 `projectile_hit`，并额外发出 `projectile_critical_hit`。
  - 暴击命中特效会放大、延长并改为橙红色。
- `AudioFeedback.gd` 新增 `crit` 音效，并监听 `projectile_critical_hit`。
- `Main.gd` 监听 `projectile_critical_hit`，暴击命中触发更强屏幕震动。

### 关键文件

- `dungeon-unleashed/scripts/core/Events.gd`
- `dungeon-unleashed/scripts/projectiles/Projectile.gd`
- `dungeon-unleashed/scripts/audio/AudioFeedback.gd`
- `dungeon-unleashed/scripts/main/Main.gd`
- `dungeon-unleashed/scripts/debug/AudioFeedbackSmokeTest.gd`
- `dungeon-unleashed/scripts/debug/WeaponSmokeTest.gd`

### 自动验证记录

#### 定向烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/AudioFeedbackSmokeTest.tscn"
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/WeaponSmokeTest.tscn"
```

结果：

```text
AudioFeedbackSmokeTest passed.
WeaponSmokeTest passed.
```

新增验证覆盖：

- `projectile_critical_hit` 会触发额外 SFX。
- `crit_chance = 1.0` 时，子弹伤害会按 `crit_multiplier` 放大并标记为暴击。
- `crit_chance = 0.0` 时，子弹保持普通伤害并标记为非暴击。

#### 完整烟测套件

结果：

```text
All smoke tests passed.
```

通过项目：

- `AudioFeedbackSmokeTest`
- `RunSummarySmokeTest`
- `MenuFlowSmokeTest`
- `SettingsSmokeTest`
- `RoomFlowSmokeTest`
- `DungeonGenerationSmokeTest`
- `BossSmokeTest`
- `EnemyVarietySmokeTest`
- `ShopSmokeTest`
- `ChestSmokeTest`
- `RelicSmokeTest`
- `WeaponSmokeTest`

#### Windows 包重新导出与校验

结果：

```text
Exported exe startup passed.
Zip contents check passed.
Main scene startup passed.
Resource reference check passed.
Scene/resource load_steps check passed.
Package exists: E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip (38148133 bytes)
```

### 手动测试清单

```text
[ ] 使用 Lucky Primer 或高暴击武器时，暴击命中特效明显区别于普通命中
[ ] 暴击音效不会过于尖锐或频繁遮盖其他反馈
[ ] 暴击屏幕震动不会影响玩家躲避 Boss 弹幕
[ ] 多弹丸武器连续暴击时画面仍可读
```

### 当前已知限制

- 暴击没有浮字或伤害数字。
- 暴击事件没有在 HUD 或结算面板中统计次数。
- 暴击特效仍使用程序化几何效果，不是正式 VFX 素材。

### 下一步建议

1. 为暴击、治疗、护盾等关键事件增加浮字。
2. 为遗物候选 UI 添加稀有度颜色和效果标签。
3. 做一次人工完整通关测试，记录暴击反馈、音量混合和屏幕震动是否舒适。

## 2026-06-30 关键战斗浮字反馈推进

### 阶段

- 当前推进内容：阶段 9，表现、音效和手感打磨。
- 本次目标：让伤害、暴击、治疗和护盾获取在战斗中有即时、可读的文字反馈。
- 完成状态：统一浮字场景、治疗/护盾事件、伤害/暴击/治疗/护盾浮字已接入；新增 `CombatFeedbackSmokeTest` 并通过完整烟测套件；Windows release `.exe` 和 zip 试玩包已重新导出。

### 新增功能

#### 浮字效果

- 新增 `FloatingText.gd` 和 `FloatingText.tscn`。
- 浮字支持：
  - 自定义文本。
  - 自定义颜色。
  - 自定义字号。
  - 上浮、淡出和轻微缩放。
  - 自动加入 `floating_text` 分组，便于测试和清理验证。

#### 事件扩展

- `Events.gd` 新增：
  - `player_healed(amount, current_hp)`
  - `player_shield_gained(amount, current_shield)`
- `Player.gd` 在以下场景发出新事件：
  - 普通治疗。
  - Heart Core 提升生命上限并治疗。
  - Guardian Ward 或其他来源获得护盾。

#### 战斗接入

- 普通子弹命中显示黄色伤害浮字。
- 暴击命中显示橙红色 `CRIT` 浮字。
- 玩家受伤显示红色扣血浮字。
- 玩家治疗显示绿色 `HP` 浮字。
- 玩家获得护盾显示蓝色 `SH` 浮字。
- 暴击命中不会同时重复生成普通伤害浮字。

### 关键文件

- `dungeon-unleashed/scripts/core/Events.gd`
- `dungeon-unleashed/scripts/player/Player.gd`
- `dungeon-unleashed/scripts/projectiles/Projectile.gd`
- `dungeon-unleashed/scripts/main/Main.gd`
- `dungeon-unleashed/scripts/effects/FloatingText.gd`
- `dungeon-unleashed/scenes/effects/FloatingText.tscn`
- `dungeon-unleashed/scripts/debug/CombatFeedbackSmokeTest.gd`
- `dungeon-unleashed/scenes/debug/CombatFeedbackSmokeTest.tscn`

### 自动验证记录

#### 浮字反馈烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/CombatFeedbackSmokeTest.tscn"
```

结果：

```text
CombatFeedbackSmokeTest passed.
```

新增验证覆盖：

- 普通命中生成 `-2` 伤害浮字。
- 暴击命中生成 `CRIT 6` 浮字。
- 治疗生成 `+1 HP` 浮字。
- 获得护盾生成 `+2 SH` 浮字。
- 玩家受伤生成 `-1` 浮字。
- 浮字会在持续时间结束后自动清理，不残留新增节点。

#### 完整烟测套件

结果：

```text
All smoke tests passed.
```

通过项目：

- `AudioFeedbackSmokeTest`
- `CombatFeedbackSmokeTest`
- `RunSummarySmokeTest`
- `MenuFlowSmokeTest`
- `SettingsSmokeTest`
- `RoomFlowSmokeTest`
- `DungeonGenerationSmokeTest`
- `BossSmokeTest`
- `EnemyVarietySmokeTest`
- `ShopSmokeTest`
- `ChestSmokeTest`
- `RelicSmokeTest`
- `WeaponSmokeTest`

#### Windows 包重新导出与校验

结果：

```text
Exported exe startup passed.
Zip contents check passed.
Main scene startup passed.
Resource reference check passed.
Scene/resource load_steps check passed.
Package exists: E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip (38152271 bytes)
```

### 手动测试清单

```text
[ ] 普通命中浮字不会遮挡敌人轮廓
[ ] 暴击 CRIT 浮字足够醒目但不影响躲弹
[ ] 治疗和护盾浮字位置不与玩家自身完全重叠
[ ] 多弹丸武器连续命中时，浮字数量仍保持可读
[ ] Boss 战中浮字不会遮挡 Boss 预警和弹幕
```

### 当前已知限制

- 浮字仍是程序化 Label，没有正式字体、美术描边或图标。
- 没有区分爆炸、穿透、反弹等伤害来源。
- 没有在结算面板统计暴击次数、治疗量或护盾吸收量。
- 多弹丸高射速 Build 下仍需要人工确认画面可读性。

### 下一步建议

1. 为遗物候选 UI 添加稀有度颜色和效果标签。
2. 为奖励房、宝箱和商店拆分独立掉落池权重。
3. 做一次人工完整通关测试，重点观察浮字密度、Boss 战可读性和音效混合。

## 2026-06-30 遗物选择 UI 稀有度与标签推进

### 阶段

- 当前推进内容：阶段 8 UI、交互和信息呈现，兼顾阶段 5 遗物系统可读性。
- 本次目标：让遗物三选一不只是名称和描述，而能直接展示稀有度颜色与效果标签，帮助玩家更快理解选择价值。
- 完成状态：遗物选择按钮已展示名称、稀有度、标签和描述；按钮文字按稀有度上色；tooltip 提供完整信息；面板尺寸已调整以容纳四行文本；完整烟测套件通过，Windows release `.exe` 和 zip 试玩包已重新导出。

### 新增功能

- `HUD.gd` 新增遗物稀有度颜色：
  - Common：灰白。
  - Rare：蓝色。
  - Epic：紫色。
  - Legendary：金色。
- 遗物选择按钮现在显示：
  - 遗物名称。
  - 稀有度。
  - 效果标签。
  - 描述。
- 遗物选择按钮现在有 tooltip：
  - 名称。
  - Rarity。
  - Tags。
  - 描述。
- `HUD.tscn` 调整遗物选择面板高度和按钮高度，避免四行文字挤压。

### 关键文件

- `dungeon-unleashed/scripts/ui/HUD.gd`
- `dungeon-unleashed/scenes/ui/HUD.tscn`
- `dungeon-unleashed/scripts/debug/RelicSmokeTest.gd`

### 自动验证记录

#### 遗物 UI 烟测

命令：

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --scene "res://scenes/debug/RelicSmokeTest.tscn"
```

结果：

```text
RelicSmokeTest passed.
```

新增验证覆盖：

- 遗物选择文本包含遗物名称。
- 遗物选择文本包含稀有度。
- 遗物选择文本包含 `Tags:`。
- 遗物选择文本包含资源里的标签名称。
- 遗物选择按钮字体颜色与对应稀有度匹配。

#### 完整烟测套件

结果：

```text
All smoke tests passed.
```

通过项目：

- `AudioFeedbackSmokeTest`
- `CombatFeedbackSmokeTest`
- `RunSummarySmokeTest`
- `MenuFlowSmokeTest`
- `SettingsSmokeTest`
- `RoomFlowSmokeTest`
- `DungeonGenerationSmokeTest`
- `BossSmokeTest`
- `EnemyVarietySmokeTest`
- `ShopSmokeTest`
- `ChestSmokeTest`
- `RelicSmokeTest`
- `WeaponSmokeTest`

#### Windows 包重新导出与校验

结果：

```text
Exported exe startup passed.
Shared-read zip contents check passed.
Main scene startup passed.
Resource reference check passed.
Scene/resource load_steps check passed.
Package exists: E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip (38154216 bytes)
```

### 手动测试清单

```text
[ ] 遗物三选一按钮在 1280 x 720 下没有文字重叠
[ ] Rare、Epic、Legendary 颜色在实际游戏中容易区分
[ ] Tags 行能帮助理解遗物用途，不显得过长
[ ] 鼠标悬停 tooltip 内容完整可读
[ ] 遗物选择面板不会遮挡必须观察的战斗信息
```

### 当前已知限制

- 稀有度目前只通过文字颜色表现，没有独立图标、边框或背景样式。
- 标签来自资源 `tags` 字段，没有更友好的本地化命名表。
- 遗物选择按钮仍是基础 Godot Button 样式，尚未做正式卡片化视觉。

### 下一步建议

1. 为奖励房、宝箱和商店拆分独立掉落池权重。
2. 做一次人工完整通关测试，重点观察遗物选择 UI、浮字密度、Boss 战可读性和音效混合。
3. 为结算面板增加暴击次数、治疗量和护盾吸收统计。

## 2026-06-30 奖励来源掉落池权重推进

### 阶段

- 当前推进内容：阶段 5 遗物系统与阶段 7 关卡奖励结构。
- 本次目标：让奖励房、商店、普通宝箱、高级宝箱和 Boss 宝箱使用不同遗物池与稀有度权重，避免所有奖励来源体验完全相同。
- 完成状态：已实现来源级遗物池、来源级稀有度权重、商店和宝箱接入，并补充对应烟测；当前 Windows 试玩包存在且 zip 内容校验通过。

### 已实现功能

- `RelicSystem.gd` 新增来源级稀有度权重：
  - `reward`
  - `shop`
  - `normal_chest`
  - `premium_chest`
  - `boss_chest`
- `RelicSystem.gd` 新增来源级遗物池：
  - 奖励房使用第一版完整 10 个遗物池。
  - 商店偏向可购买的进攻、装填和成长型遗物。
  - 普通宝箱偏向 Common 与基础生存遗物。
  - 高级宝箱提高 Rare/Epic 权重，并可出现更高价值遗物。
  - Boss 宝箱偏向高影响力 Rare/Epic/Legendary 奖励。
- `choose_reward_relic(source)` 和 `get_reward_choices(choice_count, source)` 支持按来源抽取。
- `get_source_pool_ids(source)` 和 `get_source_rarity_weight(source, rarity)` 暴露给调试烟测使用。
- 商店遗物商品现在优先从 `shop` 来源池抽取。
- 宝箱遗物奖励现在根据宝箱类型使用：
  - 普通宝箱：`normal_chest`
  - 高级宝箱：`premium_chest`
  - Boss 宝箱：`boss_chest`
- 保留旧的本地 `relic_pool` 作为兜底，避免 RelicSystem 缺失时宝箱/商店完全失效。

### 关键文件

- `dungeon-unleashed/scripts/relics/RelicSystem.gd`
- `dungeon-unleashed/scripts/shop/ShopInventory.gd`
- `dungeon-unleashed/scripts/shop/ShopItem.gd`
- `dungeon-unleashed/scripts/chests/RewardChest.gd`
- `dungeon-unleashed/scripts/debug/RelicSmokeTest.gd`
- `dungeon-unleashed/scripts/debug/ShopSmokeTest.gd`
- `dungeon-unleashed/scripts/debug/ChestSmokeTest.gd`
- `KNOWN_ISSUES.md`

### 自动验证记录

#### 定向烟测

结果：

```text
RelicSmokeTest passed.
ShopSmokeTest passed.
ChestSmokeTest passed.
```

新增验证覆盖：

- `RelicSystem` 暴露来源池 ID 和来源稀有度权重。
- 奖励房池包含第一版完整遗物池。
- 商店池小于完整奖励池。
- 普通宝箱包含基础生存遗物，并排除较高价值生命遗物。
- 高级宝箱包含 `Heart Core`。
- Boss 宝箱包含高影响力遗物。
- 普通宝箱更偏向 Common。
- 高级宝箱 Rare 权重大于 Common。
- Boss 宝箱 Epic 权重大于 Common。
- 商店生成的遗物商品来自 `shop` 来源池。
- 普通/高级/Boss 宝箱生成的遗物分别来自对应来源池。

#### 完整烟测套件

结果：

```text
All smoke tests passed.
```

通过项目：

- `AudioFeedbackSmokeTest`
- `CombatFeedbackSmokeTest`
- `RunSummarySmokeTest`
- `MenuFlowSmokeTest`
- `SettingsSmokeTest`
- `RoomFlowSmokeTest`
- `DungeonGenerationSmokeTest`
- `BossSmokeTest`
- `EnemyVarietySmokeTest`
- `ShopSmokeTest`
- `ChestSmokeTest`
- `RelicSmokeTest`
- `WeaponSmokeTest`

#### Windows 导出包复核

当前文件：

```text
E:\Dungeon Unleashed\dungeon-unleashed\builds\windows\Dungeon Unleashed.exe
大小：109282504 bytes
时间：2026-06-30 20:52:12

E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
大小：38156739 bytes
时间：2026-06-30 20:52:18
```

zip 内容校验：

```text
Dungeon Unleashed.exe
README_PLAYTEST.md
PLAYTEST_FEEDBACK.md
KNOWN_ISSUES.md
```

结果：

```text
Windows prototype zip contents check passed.
```

### 当前已知限制

- 来源池和权重仍写在 `RelicSystem.gd` 中，尚未拆成可视化调参资源或表格。
- 仍没有保底机制、掉落历史修正或重复保护。
- 遗物来源差异已有基础雏形，但数值仍需人工完整游玩后调整。
- 商店和宝箱的展示仍偏功能原型，没有强化不同奖励来源的视觉识别。

### 下一步建议

1. 做一次人工完整通关测试，重点观察奖励来源差异、遗物选择 UI、浮字密度、Boss 战可读性和音效混合。
2. 为结算面板增加暴击次数、治疗量和护盾吸收统计。
3. 将遗物池与权重迁移为资源化配置，方便后续平衡迭代。

## 2026-06-30 结算战斗统计补强

### 阶段

- 当前推进内容：阶段 8 UI、信息呈现，阶段 9 战斗反馈，阶段 10/11 结算流程和垂直切片验收。
- 本次目标：让死亡/通关结算能回顾关键战斗表现，不只显示基础房间、金币和 Build 信息。
- 完成状态：已加入暴击次数、治疗量、护盾吸收量统计；护盾吸收有独立事件和浮字；完整烟测套件、主场景启动、资源静态校验、Windows 导出和 zip 校验均通过。

### 已实现功能

- `Events.gd` 新增 `player_shield_absorbed(amount, current_shield)` 信号。
- `Player.gd` 调整受伤结算：
  - 护盾先吸收伤害，并发出护盾吸收事件。
  - `player_damaged` 现在传递实际 HP 扣减量，而不是原始来袭伤害。
  - 护盾完全挡住伤害时，不再生成误导性的红色 HP 受伤数字。
- `Main.gd` 新增本局统计：
  - `critical_hits`
  - `healing_received`
  - `shield_absorbed`
- 暴击命中时累计暴击次数。
- 玩家治疗时累计实际恢复量。
- 护盾吸收伤害时累计实际吸收量，并显示蓝色 `-N SH` 浮字。
- 结算面板新增 Combat 行：
  - `Crits`
  - `Healing`
  - `Shield Blocked`
- 结算面板 Survival 行从 `Damage Taken` 调整为 `HP Damage`，语义更准确。

### 关键文件

- `dungeon-unleashed/scripts/core/Events.gd`
- `dungeon-unleashed/scripts/player/Player.gd`
- `dungeon-unleashed/scripts/main/Main.gd`
- `dungeon-unleashed/scripts/ui/HUD.gd`
- `dungeon-unleashed/scripts/debug/RunSummarySmokeTest.gd`
- `dungeon-unleashed/scripts/debug/CombatFeedbackSmokeTest.gd`

### 自动验证记录

#### 定向烟测

结果：

```text
RunSummarySmokeTest passed.
CombatFeedbackSmokeTest passed.
RelicSmokeTest passed.
AudioFeedbackSmokeTest passed.
Targeted smoke tests passed.
```

新增验证覆盖：

- 本局摘要会统计暴击次数。
- 本局摘要会统计实际治疗量。
- 本局摘要会统计护盾吸收量。
- 结算文本包含 `Combat:` 行。
- 结算文本显示 `Crits 1`、`Healing 2`、`Shield Blocked 2`。
- 护盾吸收会生成 `-2 SH` 浮字。
- 护盾吸收后实际 HP 伤害仍正确显示为剩余伤害。
- 受伤触发遗物和音频反馈保持可用。

#### 完整烟测套件

结果：

```text
All smoke tests passed.
```

通过项目：

- `AudioFeedbackSmokeTest`
- `CombatFeedbackSmokeTest`
- `RunSummarySmokeTest`
- `MenuFlowSmokeTest`
- `SettingsSmokeTest`
- `RoomFlowSmokeTest`
- `DungeonGenerationSmokeTest`
- `BossSmokeTest`
- `EnemyVarietySmokeTest`
- `ShopSmokeTest`
- `ChestSmokeTest`
- `RelicSmokeTest`
- `WeaponSmokeTest`

#### 主场景和静态校验

结果：

```text
Main scene startup passed.
Resource reference check passed.
Scene/resource load_steps check passed.
```

说明：

- 第一次静态校验脚本的路径过滤正则写法有 PowerShell 转义错误，已改用字符串包含判断后重新执行。
- 重新执行结果干净通过。

#### Windows 导出包复核

当前文件：

```text
E:\Dungeon Unleashed\dungeon-unleashed\builds\windows\Dungeon Unleashed.exe
大小：109283288 bytes
时间：2026-06-30 20:59:36

E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
大小：38157369 bytes
时间：2026-06-30 20:59:42
```

结果：

```text
Exported exe startup passed.
Shared-read zip contents check passed.
```

zip 内容：

```text
Dungeon Unleashed.exe
README_PLAYTEST.md
PLAYTEST_FEEDBACK.md
KNOWN_ISSUES.md
```

### 当前已知限制

- 结算面板仍是文本型原型，没有卡片分组、图标或动画。
- 暴击次数只记录命中次数，不区分武器来源、敌人类型或溢出伤害。
- 治疗统计只记录实际恢复量，不记录因满血而溢出的治疗。
- 护盾统计目前只记录吸收量，不区分护盾来源。

### 下一步建议

1. 做一次人工完整通关测试，重点观察新增结算统计是否容易理解。
2. 将遗物池与权重迁移为资源化配置，方便后续平衡迭代。
3. 为结算面板做更清晰的分组布局，降低长文本阅读压力。

## 2026-06-30 遗物掉落表资源化推进

### 阶段

- 当前推进内容：阶段 5 Roguelike Build、阶段 7 奖励循环和阶段 12 内容扩展准备。
- 本次目标：把奖励房、商店、普通宝箱、高级宝箱和 Boss 宝箱的遗物池/稀有度权重从 `RelicSystem.gd` 硬编码迁移为可配置资源，降低后续平衡迭代成本。
- 完成状态：5 个来源掉落表已资源化为 `.tres`；`RelicSystem` 已改为读取掉落表资源；来源池/权重烟测、完整烟测、主场景启动、静态资源校验、Windows 导出和 zip 校验均通过。

### 已实现功能

- 新增 `RelicDropTableData.gd` 资源类型：
  - `source_id`
  - `display_name`
  - `relic_pool`
  - `common_weight`
  - `rare_weight`
  - `epic_weight`
  - `legendary_weight`
- 新增 5 个遗物掉落表资源：
  - `resources/relic_drop_tables/reward.tres`
  - `resources/relic_drop_tables/shop.tres`
  - `resources/relic_drop_tables/normal_chest.tres`
  - `resources/relic_drop_tables/premium_chest.tres`
  - `resources/relic_drop_tables/boss_chest.tres`
- `RelicSystem.gd` 新增 `drop_tables` 导出数组，默认加载上述 5 个来源配置。
- `RelicSystem.gd` 移除了来源级硬编码权重表和来源级硬编码池数组。
- `get_source_rarity_weight(source, rarity)` 现在从对应掉落表资源读取权重。
- `get_source_pool_ids(source)` 现在从对应掉落表资源读取遗物池。
- 新增调试/验证接口：
  - `get_configured_drop_source_ids()`
  - `get_drop_table_resource_path(source)`
- `reward` 仍保留 `available_relics` 作为兜底池，避免资源配置缺失时奖励系统完全失效。
- `boss` 来源会规范化到 `boss_chest`，保持旧调用兼容。

### 关键文件

- `dungeon-unleashed/scripts/relics/RelicDropTableData.gd`
- `dungeon-unleashed/scripts/relics/RelicSystem.gd`
- `dungeon-unleashed/resources/relic_drop_tables/reward.tres`
- `dungeon-unleashed/resources/relic_drop_tables/shop.tres`
- `dungeon-unleashed/resources/relic_drop_tables/normal_chest.tres`
- `dungeon-unleashed/resources/relic_drop_tables/premium_chest.tres`
- `dungeon-unleashed/resources/relic_drop_tables/boss_chest.tres`
- `dungeon-unleashed/scripts/debug/RelicSmokeTest.gd`
- `KNOWN_ISSUES.md`
- `DEVELOPMENT_LOG.md`

### 自动验证记录

#### 定向烟测

结果：

```text
RelicSmokeTest passed.
ShopSmokeTest passed.
ChestSmokeTest passed.
RunSummarySmokeTest passed.
Source consumer smoke tests passed.
```

新增验证覆盖：

- `RelicSystem` 暴露已配置来源 ID。
- `RelicSystem` 暴露来源掉落表资源路径。
- `reward`、`shop`、`normal_chest`、`premium_chest`、`boss_chest` 均由掉落表资源配置。
- 商店掉落表路径位于 `res://resources/relic_drop_tables/`。
- 商店、普通宝箱、高级宝箱和 Boss 宝箱仍从对应来源池抽取。

#### 完整烟测套件

结果：

```text
All smoke tests passed.
```

通过项目：

- `AudioFeedbackSmokeTest`
- `CombatFeedbackSmokeTest`
- `RunSummarySmokeTest`
- `MenuFlowSmokeTest`
- `SettingsSmokeTest`
- `RoomFlowSmokeTest`
- `DungeonGenerationSmokeTest`
- `BossSmokeTest`
- `EnemyVarietySmokeTest`
- `ShopSmokeTest`
- `ChestSmokeTest`
- `RelicSmokeTest`
- `WeaponSmokeTest`

#### 主场景和静态校验

结果：

```text
Main scene startup passed.
Resource reference check passed.
Scene/resource load_steps check passed.
```

#### Windows 导出包复核

当前文件：

```text
E:\Dungeon Unleashed\dungeon-unleashed\builds\windows\Dungeon Unleashed.exe
大小：109291232 bytes
时间：2026-06-30 21:06:58

E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
大小：38158813 bytes
时间：2026-06-30 21:07:03
```

导出日志确认新增掉落表已进入资源包：

```text
res://resources/relic_drop_tables/boss_chest.tres.remap
res://resources/relic_drop_tables/normal_chest.tres.remap
res://resources/relic_drop_tables/premium_chest.tres.remap
res://resources/relic_drop_tables/reward.tres.remap
res://resources/relic_drop_tables/shop.tres.remap
```

结果：

```text
Exported exe startup passed.
Shared-read zip contents check passed.
```

### 当前已知限制

- 资源化后仍未做正式平衡调参，当前权重只是第一版经验值。
- 仍没有保底机制、重复历史修正或按局进度动态调整权重。
- 掉落表能在 Godot Inspector 中编辑，但没有专门的调参 UI 或表格导入流程。
- 遗物图标、来源表现和奖励预览仍是原型级。

### 下一步建议

1. 做一次人工完整通关测试，重点观察新增掉落来源差异和结算统计是否容易理解。
2. 为结算面板做更清晰的分组布局，降低长文本阅读压力。
3. 针对掉落表做第一轮实测平衡调参。

## 2026-06-30 结算面板分组布局推进

### 阶段

- 当前推进内容：阶段 8 UI、交互和信息呈现，阶段 10/11 结算流程和垂直切片验收。
- 本次目标：把死亡/通关结算从单块长文本升级为更容易扫读的分组布局，降低玩家完成一局后的信息阅读压力。
- 完成状态：结算面板已按 Overview、Build、Survival、Combat、Loot、Record 六组展示；保留隐藏摘要文本用于兼容测试/调试；完整烟测、主场景启动、静态资源校验、Windows 导出和 zip 校验均通过。

### 已实现功能

- `HUD.gd` 新增运行时结算分组控件生成：
  - `Overview`
  - `Build`
  - `Survival`
  - `Combat`
  - `Loot`
  - `Record`
- `ResultSummaryLabel` 现在作为隐藏兼容文本保留，实际玩家看到的是分组内容。
- `Overview` 展示结果、清理房间数、击杀数和用时。
- `Build` 展示最终武器、武器栏和本局遗物。
- `Survival` 展示生命、护盾和实际 HP 伤害。
- `Combat` 展示暴击次数、治疗量和护盾吸收量。
- `Loot` 展示金币收支、奖励、宝箱、商店购买和 Boss 击败状态。
- `Record` 展示历史 Runs、Wins、Best Rooms、Best Kills 和 Best Gold。
- `HUD.gd` 新增调试/测试接口：
  - `get_result_section_count()`
  - `get_result_section_text(section_name)`
- `HUD.tscn` 调整结算面板高度，并隐藏旧的长摘要 Label。
- `RunSummarySmokeTest.gd` 补充结算分组验证。
- `RunSummarySmokeTest.gd` 显式清空玩家无敌计时再模拟护盾伤害，避免测试依赖时序。
- `KNOWN_ISSUES.md` 和打包目录 `KNOWN_ISSUES.md` 已更新：结算界面不再描述为单纯 text-heavy，而是“分组文本，仍需视觉打磨”。

### 关键文件

- `dungeon-unleashed/scripts/ui/HUD.gd`
- `dungeon-unleashed/scenes/ui/HUD.tscn`
- `dungeon-unleashed/scripts/debug/RunSummarySmokeTest.gd`
- `KNOWN_ISSUES.md`
- `dungeon-unleashed/builds/windows/KNOWN_ISSUES.md`
- `DEVELOPMENT_LOG.md`

### 自动验证记录

#### 定向烟测

结果：

```text
RunSummarySmokeTest passed.
MenuFlowSmokeTest passed.
SettingsSmokeTest passed.
Result UI targeted tests passed.
```

新增验证覆盖：

- 结算面板暴露 6 个分组。
- `Overview` 分组显示房间进度。
- `Build` 分组显示本局遗物名称。
- `Combat` 分组显示护盾吸收量。
- `Loot` 分组显示商店购买次数。
- `Record` 分组显示历史胜利次数。
- 结算面板仍保留兼容摘要文本，旧调试接口不破坏。

#### 完整烟测套件

结果：

```text
All smoke tests passed.
```

通过项目：

- `AudioFeedbackSmokeTest`
- `CombatFeedbackSmokeTest`
- `RunSummarySmokeTest`
- `MenuFlowSmokeTest`
- `SettingsSmokeTest`
- `RoomFlowSmokeTest`
- `DungeonGenerationSmokeTest`
- `BossSmokeTest`
- `EnemyVarietySmokeTest`
- `ShopSmokeTest`
- `ChestSmokeTest`
- `RelicSmokeTest`
- `WeaponSmokeTest`

#### 主场景和静态校验

结果：

```text
Main scene startup passed.
Resource reference check passed.
Scene/resource load_steps check passed.
```

#### Windows 导出包复核

当前文件：

```text
E:\Dungeon Unleashed\dungeon-unleashed\builds\windows\Dungeon Unleashed.exe
大小：109294272 bytes
时间：2026-06-30 21:12:58

E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
大小：38161902 bytes
时间：2026-06-30 21:13:04
```

结果：

```text
Exported exe startup passed.
Shared-read zip contents check passed.
```

zip 内容：

```text
Dungeon Unleashed.exe
README_PLAYTEST.md
PLAYTEST_FEEDBACK.md
KNOWN_ISSUES.md
```

### 当前已知限制

- 结算面板已有分组，但仍是文本型原型，没有图标、动画或正式视觉样式。
- 分组控件目前由 `HUD.gd` 运行时生成，后续若进入正式 UI 制作，可迁移为显式场景节点。
- 仍未做移动端或超小窗口排版验证。

### 下一步建议

1. 做一次人工完整通关测试，重点观察分组结算、奖励来源差异、Boss 战可读性和音效混合。
2. 针对掉落表和经济数值做第一轮实测平衡调参。
3. 为结算面板补图标和更明确的视觉层级。

## 2026-06-30 完整一局自动验收推进

### 阶段

- 当前推进内容：阶段 11 垂直切片验收，兼顾阶段 10 运行流程稳定性。
- 本次目标：补齐一个自动化完整一局验收测试，把主菜单开始、完整 6 房路线、奖励、商店、Boss 宝箱和胜利结算串成一个可重复验证的测试入口。
- 完成状态：新增 `FullRunSmokeTest` 并通过；完整烟测套件已扩展到 14 个测试；主场景启动、静态资源校验、Windows 导出和 zip 校验均通过。

### 已实现功能

- 新增完整一局验收脚本：
  - `dungeon-unleashed/scripts/debug/FullRunSmokeTest.gd`
- 新增完整一局验收场景：
  - `dungeon-unleashed/scenes/debug/FullRunSmokeTest.tscn`
- `FullRunSmokeTest` 覆盖：
  - 启动后处于 Main Menu。
  - `start_new_run` 进入 Running。
  - 默认路线为 `start > combat > reward > elite > shop > boss`。
  - 开始房和普通战斗房清理后可领取奖励。
  - 奖励房会弹出遗物三选一并成功获得遗物。
  - 精英房可清理并领取高级宝箱。
  - 商店房生成 3 个商品，并能完成至少一次购买。
  - Boss 房生成 Boss，Boss 死亡后生成可开启 Boss 奖励宝箱。
  - 打开 Boss 奖励宝箱后触发 `run_completed`。
  - 最终进入 Victory，显示 `Run Complete` 结果面板。
  - 结算摘要包含清房数、击杀数、遗物、商店购买、宝箱数量和 Boss 击败状态。
  - 分组结算中 `Overview`、`Build`、`Loot`、`Record` 有可读内容。
- `DungeonController.gd` 清理旧生成房间时改为移出树后立即 `free()`，避免同一帧重复生成时旧房间残留。
- `FullRunSmokeTest` 通过当前 `Main` 的 `DungeonController.get_combat_rooms()` 获取路线，避免全局 group 中其它实例影响测试。
- 端到端测试曾发现 `reload_current_scene` 不适合在测试末尾直接调用，因为会递归重跑当前 debug 场景；重开/返回主菜单继续由 `MenuFlowSmokeTest` 覆盖。

### 关键文件

- `dungeon-unleashed/scripts/debug/FullRunSmokeTest.gd`
- `dungeon-unleashed/scenes/debug/FullRunSmokeTest.tscn`
- `dungeon-unleashed/scripts/dungeon/DungeonController.gd`
- `DEVELOPMENT_LOG.md`

### 自动验证记录

#### 新增端到端验收

结果：

```text
FullRunSmokeTest passed.
RuntimeRoomSpawnCheck passed: first_room_state=2 enemies=2 expected_wave=2 nearest_enemy_distance=360.7
Windows release export passed.
Exported exe RuntimeRoomSpawnCheck passed: first_room_state=2 enemies=2 expected_wave=2 nearest_enemy_distance=432.3
Windows prototype zip regenerated: E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
```

#### 完整烟测套件

结果：

```text
All smoke tests passed.
```

通过项目：

- `AudioFeedbackSmokeTest`
- `CombatFeedbackSmokeTest`
- `RunSummarySmokeTest`
- `MenuFlowSmokeTest`
- `SettingsSmokeTest`
- `RoomFlowSmokeTest`
- `FullRunSmokeTest`
- `DungeonGenerationSmokeTest`
- `BossSmokeTest`
- `EnemyVarietySmokeTest`
- `ShopSmokeTest`
- `ChestSmokeTest`
- `RelicSmokeTest`
- `WeaponSmokeTest`

#### 主场景和静态校验

结果：

```text
Main scene startup passed.
Resource reference check passed.
Scene/resource load_steps check passed.
```

#### Windows 导出包复核

当前文件：

```text
E:\Dungeon Unleashed\dungeon-unleashed\builds\windows\Dungeon Unleashed.exe
大小：109294272 bytes
时间：2026-06-30 21:25:27

E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
大小：38162159 bytes
时间：2026-06-30 21:25:33
```

结果：

```text
Exported exe startup passed.
Shared-read zip contents check passed.
```

zip 内容：

```text
Dungeon Unleashed.exe
README_PLAYTEST.md
PLAYTEST_FEEDBACK.md
KNOWN_ISSUES.md
```

### 当前已知限制

- `FullRunSmokeTest` 是自动化逻辑验收，不能替代人工窗口模式下的手感、可读性和音频混合检查。
- 测试通过直接击杀敌人和 Boss，不验证真实玩家射击躲避能力。
- 重开和返回主菜单仍由独立菜单流程烟测覆盖，没有在完整一局测试末尾触发场景重载。

### 下一步建议

1. 做一次人工完整通关测试，重点观察分组结算、奖励来源差异、Boss 战可读性和音效混合。
2. 针对掉落表和经济数值做第一轮实测平衡调参。
3. 为 Boss 战增加更明确的阶段演出和场地机制。

## 2026-06-30 Boss 阶段转换演出推进

### 本次目标

- 补强 Boss 二阶段转换的可读性，避免从一阶段直接无提示进入更高压弹幕节奏。
- 保持现有 Boss 原型边界，不扩大到正式场地机制或完整 Boss 设计重做。

### 已实现

- `BossEnemy.gd` 新增二阶段转换暂停：
  - 进入二阶段时暂停移动和攻击。
  - 清理场上敌方弹幕，避免转换瞬间叠加旧弹幕压力。
  - 生成更大范围的阶段转换危险提示圈。
  - Boss 视觉短暂放大回弹，并保留二阶段颜色。
  - 重置下一次攻击节奏，转换结束后从清晰的径向弹幕节奏恢复。
- `_spawn_circle_warning` 支持自定义预警持续时间，用于区分普通攻击预警和阶段转换预警。
- `BossSmokeTest.gd` 增加阶段转换验收：
  - 验证 Boss 低于半血后进入二阶段。
  - 验证阶段转换暂停计时启动。
  - 验证阶段转换危险提示出现。
  - 验证转换暂停期间不会立即发射敌方弹幕。
  - 验证转换结束后 Boss 仍能正常释放径向弹幕和召唤小怪。
- 更新根目录和导出包内 `KNOWN_ISSUES.md`，说明 Boss 现在已有更清晰的阶段转换暂停和预警，但仍缺少专属场地机制。

### 自动验证结果

#### Boss 专项回归

结果：

```text
BossSmokeTest passed.
```

#### 完整一局回归

结果：

```text
FullRunSmokeTest passed.
```

#### 完整烟测套件

结果：

```text
All smoke tests passed.
```

通过项目：

- `AudioFeedbackSmokeTest`
- `CombatFeedbackSmokeTest`
- `RunSummarySmokeTest`
- `MenuFlowSmokeTest`
- `SettingsSmokeTest`
- `RoomFlowSmokeTest`
- `FullRunSmokeTest`
- `DungeonGenerationSmokeTest`
- `BossSmokeTest`
- `EnemyVarietySmokeTest`
- `ShopSmokeTest`
- `ChestSmokeTest`
- `RelicSmokeTest`
- `WeaponSmokeTest`

#### 主场景和静态校验

结果：

```text
Main scene startup passed.
Resource reference check passed.
Scene/resource load_steps check passed.
```

#### Windows 导出包复核

当前文件：

```text
E:\Dungeon Unleashed\dungeon-unleashed\builds\windows\Dungeon Unleashed.exe
大小：109295248 bytes
时间：2026-06-30 21:32:46

E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
大小：38163236 bytes
时间：2026-06-30 21:32:52
```

结果：

```text
Exported exe startup passed.
Shared-read zip contents check passed.
```

zip 内容：

```text
Dungeon Unleashed.exe
README_PLAYTEST.md
PLAYTEST_FEEDBACK.md
KNOWN_ISSUES.md
```

### 当前已知限制

- Boss 二阶段转换已有暂停、清弹和大范围预警，但仍不是正式 Boss 战演出。
- Boss 房仍缺少专属场地机制、阶段目标、独立地形压力和最终数值调优。
- 当前验证仍以自动化烟测为主，需要人工完整通关观察实际战斗手感、预警可读性和音效混合。

### 下一步建议

1. 做一次人工完整通关测试，重点观察 Boss 二阶段转换是否清晰、是否打断节奏过重。
2. 根据人工反馈调整 `phase_transition_duration`、预警半径、二阶段弹幕数量和 Boss 生命值。
3. 再推进 Boss 房专属场地机制或一轮经济/掉落平衡调参。

## 2026-06-30 Boss 房基础场地机制推进

### 本次目标

- 补齐 Boss 房缺少专属场地压力的问题，让 Boss 二阶段不只依赖自身弹幕和召唤。
- 机制保持轻量，避免在正式美术和完整 Boss 设计前引入复杂地形系统。

### 已实现

- `CombatRoom.gd` 新增 Boss 房专属地面危险区机制：
  - 仅在 `room_type` 为 `boss` 或 `boss_placeholder` 的房间启用。
  - Boss 房战斗开始时生成 5 个地面危险区标记点。
  - Boss 进入二阶段后激活场地机制。
  - 场地危险区等待 Boss 阶段转换暂停结束后再开始循环，避免和阶段转换大预警重叠。
  - 每轮选择 2 个点位生成红色圆形危险预警。
  - 预警结束后对站在范围内的玩家造成 1 点伤害。
  - Boss 死亡、房间清理或玩家死亡时关闭场地机制并清理残留预警。
- `BossSmokeTest.gd` 增加 Boss 场地机制验收：
  - 验证二阶段后 Boss 房场地机制激活。
  - 验证危险区标记点生成。
  - 验证场地危险区不会抢在阶段转换读条前出现。
  - 验证阶段转换结束后会生成地面危险区预警。
  - 验证 Boss 死亡后场地机制停止。
- 更新导出目录 `README_PLAYTEST.md`，把 Boss 二阶段地面危险区加入试玩观察重点。
- 更新根目录和导出包内 `KNOWN_ISSUES.md`，说明 Boss 已具备基础地面场地压力，但仍需要最终调优。

### 自动验证结果

#### Boss 专项回归

结果：

```text
BossSmokeTest passed.
```

#### 完整一局回归

结果：

```text
FullRunSmokeTest passed.
```

#### 完整烟测套件

结果：

```text
All smoke tests passed.
```

通过项目：

- `AudioFeedbackSmokeTest`
- `CombatFeedbackSmokeTest`
- `RunSummarySmokeTest`
- `MenuFlowSmokeTest`
- `SettingsSmokeTest`
- `RoomFlowSmokeTest`
- `FullRunSmokeTest`
- `DungeonGenerationSmokeTest`
- `BossSmokeTest`
- `EnemyVarietySmokeTest`
- `ShopSmokeTest`
- `ChestSmokeTest`
- `RelicSmokeTest`
- `WeaponSmokeTest`

#### 主场景和静态校验

结果：

```text
Main scene startup passed.
Resource reference check passed.
Scene/resource load_steps check passed.
```

#### Windows 导出包复核

当前文件：

```text
E:\Dungeon Unleashed\dungeon-unleashed\builds\windows\Dungeon Unleashed.exe
大小：109299216 bytes
时间：2026-06-30 21:41:32

E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
大小：38167051 bytes
时间：2026-06-30 21:41:38
```

结果：

```text
Exported exe startup passed.
Shared-read zip contents check passed.
```

zip 内容：

```text
Dungeon Unleashed.exe
README_PLAYTEST.md
PLAYTEST_FEEDBACK.md
KNOWN_ISSUES.md
```

### 当前已知限制

- Boss 房已有基础地面危险区，但点位、频率、伤害和可读性仍是第一版经验值。
- 场地机制仍由代码固定点位生成，尚未资源化为可配置 Boss 房模板。
- 当前自动测试验证机制时序和流程稳定性，不能替代人工实战中的躲避手感和视觉可读性检查。

### 下一步建议

1. 做一次人工完整通关测试，重点观察 Boss 二阶段地面危险区是否清晰、是否过密或过轻。
2. 根据试玩结果调整 `boss_arena_hazard_interval`、`boss_arena_hazard_radius`、`boss_arena_hazard_cycle_size` 和 Boss 二阶段弹幕密度。
3. 继续推进经济/掉落数值第一轮调参，减少“能通关但难度曲线不稳定”的风险。

## 2026-06-30 核心键位重绑定推进

### 本次目标

- 补齐设置流程中的核心键位重绑定能力，减少 Windows 试玩版本的固定按键限制。
- 与现有 `settings.cfg` 保存体系合并，避免新增独立存档结构。

### 已实现

- `Main.gd` 新增核心键位绑定表：
  - `move_up`
  - `move_down`
  - `move_left`
  - `move_right`
  - `reload`
  - `interact`
  - `pause`
- 新增 `rebind_input_action(action_name, keycode)`：
  - 写入运行时绑定。
  - 更新 `InputMap`。
  - 保存到 `user://settings.cfg` 的 `controls` 分组。
  - 若新键已被另一个核心动作使用，会把另一个动作换回当前动作原来的键，避免同一键同时触发两个核心动作。
- 新增 `reset_input_bindings()`，可恢复默认核心键位。
- `get_settings_summary()` 现在包含 `input_bindings`，便于测试和调试读取当前键位。
- `HUD.gd` 设置面板新增紧凑 Controls 区：
  - 显示当前核心键位。
  - 点击按钮后捕获下一次键盘输入并保存。
  - 提供 Reset Controls 按钮。
  - HUD 右下角输入提示会跟随当前绑定刷新。
- `HUD.tscn` 调整 Settings 面板尺寸，以容纳 Controls 区。
- `SettingsSmokeTest.gd` 增加键位重绑定验收：
  - 将 Reload 从 `R` 改为 `T`。
  - 验证 `InputMap` 使用新键并移除旧键。
  - 验证 settings 文件保存新键。
  - 验证重载 Main 场景后仍能读取新键。
  - 验证设置 UI 和输入提示显示新键。
- `MenuFlowSmokeTest.gd` 改为读取当前绑定验证 HUD 输入提示，避免测试写死默认键位。
- 更新根目录和导出包内 `KNOWN_ISSUES.md`：
  - 不再标记键位重绑定完全未实现。
  - 当前限制改为：只支持移动、换弹、交互、暂停；鼠标射击和武器数字键仍固定。
- 更新导出包 `README_PLAYTEST.md`，说明 Settings 可重绑定核心键盘控制。

### 自动验证结果

#### 设置专项回归

结果：

```text
SettingsSmokeTest passed.
```

#### 菜单流程回归

结果：

```text
MenuFlowSmokeTest passed.
```

#### 完整烟测套件

结果：

```text
All smoke tests passed.
```

通过项目：

- `AudioFeedbackSmokeTest`
- `CombatFeedbackSmokeTest`
- `RunSummarySmokeTest`
- `MenuFlowSmokeTest`
- `SettingsSmokeTest`
- `RoomFlowSmokeTest`
- `FullRunSmokeTest`
- `DungeonGenerationSmokeTest`
- `BossSmokeTest`
- `EnemyVarietySmokeTest`
- `ShopSmokeTest`
- `ChestSmokeTest`
- `RelicSmokeTest`
- `WeaponSmokeTest`

#### 主场景和静态校验

结果：

```text
Main scene startup passed.
Resource reference check passed.
Scene/resource load_steps check passed.
```

#### Windows 导出包复核

当前文件：

```text
E:\Dungeon Unleashed\dungeon-unleashed\builds\windows\Dungeon Unleashed.exe
大小：109306144 bytes
时间：2026-06-30 21:52:13

E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
大小：38174156 bytes
时间：2026-06-30 21:52:18
```

结果：

```text
Exported exe startup passed.
Shared-read zip contents check passed.
```

zip 内容：

```text
Dungeon Unleashed.exe
README_PLAYTEST.md
PLAYTEST_FEEDBACK.md
KNOWN_ISSUES.md
```

### 当前已知限制

- 键位重绑定当前只覆盖移动、换弹、交互和暂停。
- 鼠标射击、武器槽 `1/2/3`、手柄输入和更完整的输入配置界面仍未实现。
- 仍需要人工窗口模式验证：设置菜单高度、重绑定交互、输入提示在 1280 x 720 下是否清晰。

### 下一步建议

1. 做一次人工窗口验收，重点测试键位重绑定、Settings 面板布局和输入提示刷新。
2. 继续做第一轮经济/掉落/敌人生命值平衡调参。
3. 若继续补设置系统，可扩展鼠标射击、武器槽、手柄提示和恢复默认弹窗确认。

## 2026-06-30 第一轮自动化数值平衡推进

### 本次目标

- 对当前完整流程做第一轮可验证的数值收敛，避免经济、敌人波次和 Boss 血量完全停留在临时占位值。
- 用自动化烟测固定关键约束，确保后续调参不会轻易破坏基础通关路径。
- 保持第一版目标不扩张：本轮只做基础数值约束，不引入正式平衡曲线、复杂掉落表或新内容系统。

### 已实现

- 商店价格完成第一轮调整：
  - 治疗：`24`
  - 遗物：`82`
  - 武器：`128`
- 房间战斗强度完成第一轮调整：
  - 起始房波次敌人数：`2, 4`
  - 精英房波次敌人数：`4, 5`
  - 精英生命倍率：`1.65`
- Boss 基础生命值调整为 `48`，并同步修正 Boss 阶段测试中的伤害计算，避免测试依赖写死血量。
- `FullRunSmokeTest.gd` 移除商店前额外赠送金币，改为验证自然流程金币是否足以购买至少一个关键商店物品。
- 新增 `BalanceSmokeTest.gd` 和 `BalanceSmokeTest.tscn`，覆盖以下约束：
  - 默认路线房间数为 `6`。
  - 起始房敌人总量为 `6`。
  - 精英房敌人总量为 `9`。
  - 精英生命倍率为 `1.65`。
  - 商店前自然金币收入落在预期区间。
  - 当前金币可支持合理单件购买和部分组合购买，但不能一次性买空商店。
  - Boss 生命值为 `48`。
- 更新 `KNOWN_ISSUES.md` 和导出包内说明：
  - 不再把经济/数值完全标记为未做。
  - 当前状态改为“已有第一轮自动化约束，仍需要人工实战调参”。
- 更新导出包内 `README_PLAYTEST.md`：
  - 增加商店价格选择和购买决策检查点。

### 自动验证结果

#### 本轮专项验证

结果：

```text
BossSmokeTest passed.
ShopSmokeTest passed.
FullRunSmokeTest passed.
BalanceSmokeTest passed.
```

#### 完整烟测套件

结果：

```text
All smoke tests passed.
```

通过项目：

- `AudioFeedbackSmokeTest`
- `BalanceSmokeTest`
- `CombatFeedbackSmokeTest`
- `RunSummarySmokeTest`
- `MenuFlowSmokeTest`
- `SettingsSmokeTest`
- `RoomFlowSmokeTest`
- `FullRunSmokeTest`
- `DungeonGenerationSmokeTest`
- `BossSmokeTest`
- `EnemyVarietySmokeTest`
- `ShopSmokeTest`
- `ChestSmokeTest`
- `RelicSmokeTest`
- `WeaponSmokeTest`

#### 主场景和静态校验

结果：

```text
Main scene startup passed.
Resource reference check passed.
Scene/resource load_steps check passed.
```

#### Windows 导出包复核

当前文件：

```text
E:\Dungeon Unleashed\dungeon-unleashed\builds\windows\Dungeon Unleashed.exe
大小：109306144 bytes
时间：2026-06-30 22:01:22

E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
大小：38174183 bytes
时间：2026-06-30 22:01:27
```

结果：

```text
Exported exe startup passed.
Shared-read zip contents check passed.
```

zip 内容：

```text
Dungeon Unleashed.exe
README_PLAYTEST.md
PLAYTEST_FEEDBACK.md
KNOWN_ISSUES.md
```

### 当前已知限制

- `BalanceSmokeTest` 只能验证结构性数值约束，不能替代真实游玩中的手感、难度曲线和时间压力判断。
- 当前还没有 DPS、平均击杀时间、受伤频率、通关时长等自动化平衡指标。
- 商店价格和金币收入已经形成第一轮约束，但仍需要人工完整通关后继续微调。
- 遗物稀有度、掉落权重、保底规则和不同武器流派下的数值差异仍未做深入平衡。

### 下一步建议

1. 做一次人工完整通关测试，记录每个房间的受伤次数、购买选择、Boss 剩余血量和死亡原因。
2. 根据人工记录继续调整敌人生命值、Boss 生命值、商店价格、金币掉落和宝箱收益。
3. 若继续推进自动化平衡，可增加简单战斗遥测日志，用于记录通关时间、击杀数、伤害来源和商店消费路径。

## 2026-06-30 UI 布局稳定性推进

### 本次目标

- 补强阶段 8 “UI 在不同分辨率下不重叠”的验收基础。
- 降低外部试玩时主菜单、设置、暂停、遗物选择、结算面板和右下角输入提示互相遮挡的风险。
- 用自动化测试覆盖当前正式支持的三个分辨率：`1280x720`、`1600x900`、`1920x1080`。

### 已实现

- `HUD.gd` 新增基础响应式布局逻辑：
  - 主菜单、暂停、设置、结算、遗物选择面板会按当前视口和安全边距重新约束尺寸。
  - 右下角输入提示会按视口宽度动态调整宽高。
  - 打开主菜单、暂停、设置、结算或遗物选择这类大面板时，自动隐藏右下角输入提示。
  - 关闭大面板返回战斗状态后，输入提示会恢复显示。
- 新增 `UILayoutSmokeTest.gd` 和 `UILayoutSmokeTest.tscn`：
  - 在 `1280x720`、`1600x900`、`1920x1080` 三种视口下实例化 HUD。
  - 逐一显示主菜单、设置、暂停、结算和遗物选择面板。
  - 验证关键面板和可见子控件没有超出视口。
  - 验证大面板显示时输入提示被隐藏，战斗 HUD 状态下输入提示恢复显示。
- 更新试玩说明和已知问题：
  - 修正导出包内 `README_PLAYTEST.md` 里“设置不支持键位重绑定”的过期描述。
  - 增加设置、暂停、遗物选择和结算面板不应与输入提示重叠的人工检查点。
  - `KNOWN_ISSUES.md` 标记 UI 已有基础分辨率烟测，但仍需要人工视觉审查和正式视觉层级打磨。

### 自动验证结果

#### 新增布局专项测试

结果：

```text
UILayoutSmokeTest passed.
```

#### 受影响 UI 回归

结果：

```text
MenuFlowSmokeTest passed.
SettingsSmokeTest passed.
RunSummarySmokeTest passed.
UILayoutSmokeTest passed.
Affected UI smoke tests passed.
```

#### 完整烟测套件

结果：

```text
All smoke tests passed.
```

通过项目：

- `AudioFeedbackSmokeTest`
- `BalanceSmokeTest`
- `CombatFeedbackSmokeTest`
- `RunSummarySmokeTest`
- `MenuFlowSmokeTest`
- `SettingsSmokeTest`
- `UILayoutSmokeTest`
- `RoomFlowSmokeTest`
- `FullRunSmokeTest`
- `DungeonGenerationSmokeTest`
- `BossSmokeTest`
- `EnemyVarietySmokeTest`
- `ShopSmokeTest`
- `ChestSmokeTest`
- `RelicSmokeTest`
- `WeaponSmokeTest`

#### 主场景和静态校验

结果：

```text
Main scene startup passed.
Resource reference check passed.
Scene/resource load_steps check passed.
```

#### Windows 导出包复核

当前文件：

```text
E:\Dungeon Unleashed\dungeon-unleashed\builds\windows\Dungeon Unleashed.exe
大小：109308144 bytes
时间：2026-06-30 22:10:56

E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
大小：38176079 bytes
时间：2026-06-30 22:11:02
```

结果：

```text
Exported exe startup passed.
Shared-read zip contents check passed.
```

zip 内容：

```text
Dungeon Unleashed.exe
KNOWN_ISSUES.md
PLAYTEST_FEEDBACK.md
README_PLAYTEST.md
```

### 当前已知限制

- `UILayoutSmokeTest` 只验证矩形边界和输入提示显隐，不等同于真实视觉审美验收。
- 当前 UI 仍以文字和基础 Godot 控件为主，缺少正式图标、动画、面板层级和美术风格。
- 布局测试覆盖当前支持的 16:9 分辨率，没有覆盖超宽屏、低于 720p、窗口拖拽到非标准比例等情况。
- 手柄提示、鼠标射击重绑定、武器槽重绑定和更完整显示/音频选项仍未实现。

### 下一步建议

1. 用导出的 Windows 包做一次 1280x720 窗口模式人工检查，重点看 Settings、Relic Choice 和 Result 面板是否可读。
2. 继续推进房间模板数量和地牢路线差异，目前仍未达到开发计划第 11 阶段建议的 20 到 30 个房间模板。
3. 在人工通关反馈后，再决定 UI 是先做视觉层级打磨，还是先补鼠标/武器槽重绑定与更多设置项。

## 2026-06-30 房间布局 Profile 第一轮推进

### 本次目标

- 向阶段 11 “完整一层地牢”和“至少 20 个房间模板”的目标继续推进。
- 在不大规模复制 `.tscn` 场景的前提下，先让当前 6 房间路线具备可见的空间差异。
- 保持第一版资源仍为占位几何图形，但让刷怪点、奖励点、障碍物和地面色调由数据驱动。

### 已实现

- `RoomData.gd` 新增 `layout_profile` 字段。
- `DungeonController.gd` 现在会：
  - 把 `layout_profile` 写入房间记录。
  - 在实例化房间时把 `layout_profile` 应用到 `CombatRoom`。
- `CombatRoom.gd` 新增布局 profile 应用逻辑：
  - 根据 profile 调整敌人生成点。
  - 根据 profile 调整奖励生成点。
  - 根据 profile 调整地面色调。
  - 根据 profile 程序化生成少量 `StaticBody2D` 障碍物。
- 当前 6 个房间资源已分别配置：
  - `start_room.tres` -> `training`
  - `combat_room.tres` -> `crossfire`
  - `reward_room.tres` -> `reward_cache`
  - `elite_room.tres` -> `pillars`
  - `shop_room.tres` -> `market`
  - `boss_placeholder_room.tres` -> `boss_arena`
- `DungeonGenerationSmokeTest.gd` 增加布局验证：
  - 路线至少包含 5 种不同 `layout_profile`。
  - 房间记录中的 profile 必须和运行时 `CombatRoom` 一致。
  - 不同 profile 生成的障碍物数量必须符合预期。
- 更新试玩说明和已知问题：
  - 试玩说明要求检查 6 个房间是否在空间感上有区别。
  - 已知问题明确当前只是 1 个原型场景 + 6 个布局 profile，尚未达到完整 20+ 房间模板目标。

### 自动验证结果

#### 地牢生成专项

结果：

```text
DungeonGenerationSmokeTest passed.
```

#### 受影响地牢/战斗回归

结果：

```text
RoomFlowSmokeTest passed.
FullRunSmokeTest passed.
BossSmokeTest passed.
EnemyVarietySmokeTest passed.
BalanceSmokeTest passed.
CombatFeedbackSmokeTest passed.
Affected dungeon/layout smoke tests passed.
```

#### 完整烟测套件

结果：

```text
All smoke tests passed.
```

通过项目：

- `AudioFeedbackSmokeTest`
- `BalanceSmokeTest`
- `CombatFeedbackSmokeTest`
- `RunSummarySmokeTest`
- `MenuFlowSmokeTest`
- `SettingsSmokeTest`
- `UILayoutSmokeTest`
- `RoomFlowSmokeTest`
- `FullRunSmokeTest`
- `DungeonGenerationSmokeTest`
- `BossSmokeTest`
- `EnemyVarietySmokeTest`
- `ShopSmokeTest`
- `ChestSmokeTest`
- `RelicSmokeTest`
- `WeaponSmokeTest`

#### 主场景和静态校验

结果：

```text
Main scene startup passed.
Resource reference check passed.
Scene/resource load_steps check passed.
```

#### Windows 导出包复核

当前文件：

```text
E:\Dungeon Unleashed\dungeon-unleashed\builds\windows\Dungeon Unleashed.exe
大小：109312192 bytes
时间：2026-06-30 22:18:25

E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
大小：38180434 bytes
时间：2026-06-30 22:18:31
```

结果：

```text
Exported exe startup passed.
Shared-read zip contents check passed.
```

zip 内容：

```text
Dungeon Unleashed.exe
KNOWN_ISSUES.md
PLAYTEST_FEEDBACK.md
README_PLAYTEST.md
```

### 当前已知限制

- 这不是完整的 20 到 30 个独立房间模板，只是第一轮数据驱动布局变体。
- 程序化障碍物仍是简单矩形，视觉仍是占位几何图形。
- 当前路线仍是固定 6 房间线性路线，尚未实现每局不同的地图结构或多分支探索。
- 敌人寻路仍依赖简单追踪和碰撞，不是正式导航网格方案；需要人工观察是否有敌人被障碍物卡住。

### 下一步建议

1. 人工通关时重点观察 `pillars` 精英房和 `boss_arena` Boss 房的障碍物是否影响可读性或导致敌人卡住。
2. 下一轮可把 `layout_profile` 进一步扩展成资源化房间模板数据，而不是写在 `CombatRoom.gd` 的 match 分支里。
3. 若继续追开发计划第 11 阶段，应增加更多房间资源/模板，并把固定 6 房间线性路线升级为带分支的可通关图结构。

## 2026-06-30 房间布局资源化推进

### 本次目标

- 把上一轮写在 `CombatRoom.gd` 里的布局 profile 推进为真正的数据资源。
- 向开发计划第 11 阶段“20 到 30 个房间模板”继续靠拢，先建立可扩展的布局资源库。
- 保持当前 6 房间试玩路线稳定，不在本轮扩大路线长度或改变经济节奏。

### 已实现

- 新增 `RoomLayoutData.gd` 资源类型，支持配置：
  - `id`
  - `display_name`
  - `floor_color`
  - `spawn_positions`
  - `reward_position`
  - `obstacle_names`
  - `obstacle_positions`
  - `obstacle_sizes`
  - `obstacle_colors`
- 新增 `resources/room_layouts` 布局库，当前包含 22 个 `.tres` 布局资源：
  - `training`
  - `crossfire`
  - `reward_cache`
  - `pillars`
  - `market`
  - `boss_arena`
  - `gauntlet`
  - `split_cover`
  - `corner_nests`
  - `center_ring`
  - `diagonal_blocks`
  - `long_lane`
  - `twin_islands`
  - `bunker`
  - `open_cross`
  - `crescent`
  - `box_maze`
  - `shrine`
  - `narrow_gap`
  - `wide_arena`
  - `ambush_corners`
  - `boss_cross`
- `RoomData.gd` 新增 `layout_data` 引用字段。
- 现有 6 个房间资源已改为引用布局资源：
  - `start_room.tres` -> `training.tres`
  - `combat_room.tres` -> `crossfire.tres`
  - `reward_room.tres` -> `reward_cache.tres`
  - `elite_room.tres` -> `pillars.tres`
  - `shop_room.tres` -> `market.tres`
  - `boss_placeholder_room.tres` -> `boss_arena.tres`
- `DungeonController.gd` 现在会：
  - 从 `layout_data.id` 生成房间记录里的 `layout_profile`。
  - 把 `layout_data` 传给运行时 `CombatRoom`。
  - 保留旧 `layout_profile` 作为资源缺失时的兼容回退。
- `CombatRoom.gd` 现在会优先从 `layout_data` 应用布局：
  - 设置地面颜色。
  - 设置敌人生成点。
  - 设置奖励生成点。
  - 根据资源里的数组生成 `StaticBody2D` 障碍物。
  - 旧 match 分支仍保留，避免旧房间数据失效。
- `DungeonGenerationSmokeTest.gd` 增加布局资源库验证：
  - `resources/room_layouts` 必须存在。
  - 布局资源数量必须至少为 20。
  - 每个布局必须有唯一 `id`。
  - 每个布局至少有 4 个敌人生成点。
  - 障碍物位置和尺寸数组数量必须一致。
  - 当前运行路线的房间必须收到 `layout_data` 资源。

### 自动验证结果

#### 布局资源专项

结果：

```text
DungeonGenerationSmokeTest passed.
```

#### 受影响房间/流程回归

结果：

```text
DungeonGenerationSmokeTest passed.
RoomFlowSmokeTest passed.
FullRunSmokeTest passed.
BossSmokeTest passed.
EnemyVarietySmokeTest passed.
BalanceSmokeTest passed.
Affected room layout smoke tests passed.
```

#### 完整烟测套件

结果：

```text
All smoke tests passed.
```

通过项目：

- `AudioFeedbackSmokeTest`
- `BalanceSmokeTest`
- `CombatFeedbackSmokeTest`
- `RunSummarySmokeTest`
- `MenuFlowSmokeTest`
- `SettingsSmokeTest`
- `UILayoutSmokeTest`
- `RoomFlowSmokeTest`
- `FullRunSmokeTest`
- `DungeonGenerationSmokeTest`
- `BossSmokeTest`
- `EnemyVarietySmokeTest`
- `ShopSmokeTest`
- `ChestSmokeTest`
- `RelicSmokeTest`
- `WeaponSmokeTest`

#### 主场景和静态校验

结果：

```text
Main scene startup passed.
Resource reference check passed.
Scene/resource load_steps check passed.
```

#### Windows 导出包复核

当前文件：

```text
E:\Dungeon Unleashed\dungeon-unleashed\builds\windows\Dungeon Unleashed.exe
大小：109335880 bytes
时间：2026-06-30 22:31:05

E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
大小：38186304 bytes
时间：2026-06-30 22:31:10
```

结果：

```text
Exported exe startup passed.
Shared-read zip contents check passed.
```

zip 内容：

```text
Dungeon Unleashed.exe
KNOWN_ISSUES.md
PLAYTEST_FEEDBACK.md
README_PLAYTEST.md
```

### 当前已知限制

- 布局资源数量已经达到 20+，但当前单局仍只实例化 6 个房间。
- 当前仍只有一个 `PrototypeCombatRoom.tscn` 场景，布局差异来自数据驱动的刷怪点、地面色和矩形障碍物，不是正式 TileMap 房间模板。
- 地牢路线仍是线性路线，尚未实现带支路的随机图结构。
- 障碍物与敌人寻路的实战表现仍需要人工观察，尤其是 `pillars`、`narrow_gap`、`box_maze` 这类遮挡较多的布局。

### 下一步建议

1. 把 `DungeonController` 从固定 6 房间序列升级为可选布局池：战斗房、精英房、奖励房、商店房按类型从布局资源库中挑选。
2. 在不破坏经济节奏的前提下，将可玩路线扩展为 8 到 10 个房间，并加入至少 1 条支路。
3. 后续再把数据布局逐步替换为真正的房间场景或 TileMap 模板。

## 2026-06-30 固定 10 房间分支路线推进

### 本次目标

- 把上一轮固定 6 房间线性试玩路线扩展为更接近完整一层地牢的固定 10 房间路线。
- 加入南北方向支路，验证奖励房和商店房可以挂在主路之外。
- 保持第一版仍为占位几何和数据驱动布局，不引入随机地牢生成或正式 TileMap 房间模板。

### 已实现

- `DungeonController.gd` 默认路线改为 10 房间固定图结构：
  - `Room01`：开始房，`training`。
  - `Room02`：战斗房，`crossfire`，向北连接奖励支路。
  - `Room03`：奖励房，`reward_cache`。
  - `Room04`：战斗房，`gauntlet`。
  - `Room05`：精英房，`pillars`，向南连接商店支路。
  - `Room06`：商店房，`market`。
  - `Room07`：战斗房，`split_cover`，向北连接第二个奖励支路。
  - `Room08`：奖励房，`shrine`。
  - `Room09`：战斗房，`center_ring`。
  - `Room10`：Boss 房，`boss_arena`。
- 房间间距调整为 `Vector2(1320, 820)`，避免水平和垂直支路触发区互相重叠。
- `CombatRoom.gd` 新增 `connected_directions`：
  - 支持 `west`、`east`、`north`、`south` 连接声明。
  - 根据连接方向动态启用/禁用边界墙。
  - 自动生成 `NorthDoor` 和 `SouthDoor`。
  - 未连接方向保持封闭，已连接方向会随战斗锁门/清房开门改变状态。
- 商店第一轮分支路线价格调整：
  - 治疗：`30`
  - 遗物：`110`
  - 武器：`160`
- `RelicPickup.gd` 新增 `claim_for_player()` 显式测试/逻辑入口，并在领取后退出 `rewards` 组。
- `RewardChest.gd` 在开启后退出 `rewards` 组，避免已开启奖励继续被后续房间测试误选。
- 更新自动化测试以适配分支路线：
  - `DungeonGenerationSmokeTest` 验证 10 房间图、连接对称性、Boss 可达、布局资源数量和运行时连接状态。
  - `FullRunSmokeTest` 验证 10 房间完整路线、两个奖励支路、商店购买、Boss 宝箱和通关结算。
  - `BalanceSmokeTest` 验证中段商店前自然金币区间和新价格。
  - `ShopSmokeTest` 改为按当前商品价格动态补足测试金币。
  - `EnemyVarietySmokeTest` 改为按 `room_type` 查找精英房、商店房和 Boss 房，避免固定旧索引。
  - `RelicSmokeTest` 支持奖励拾取已被玩家自动触发的路径。
  - `RoomFlowSmokeTest` 在显式领取遗物后也会处理 3 选 1 面板。
- 更新根目录和导出包内文档：
  - `KNOWN_ISSUES.md`
  - `dungeon-unleashed/builds/windows/KNOWN_ISSUES.md`
  - `dungeon-unleashed/builds/windows/README_PLAYTEST.md`

### 自动验证结果

#### 受影响分支路线烟测

结果：

```text
DungeonGenerationSmokeTest passed.
FullRunSmokeTest passed.
ShopSmokeTest passed.
RoomFlowSmokeTest passed.
BalanceSmokeTest passed.
Affected branching route smoke tests passed.
```

#### 完整烟测套件

结果：

```text
All smoke tests passed.
```

通过项目：

- `AudioFeedbackSmokeTest`
- `BalanceSmokeTest`
- `CombatFeedbackSmokeTest`
- `RunSummarySmokeTest`
- `MenuFlowSmokeTest`
- `SettingsSmokeTest`
- `UILayoutSmokeTest`
- `RoomFlowSmokeTest`
- `FullRunSmokeTest`
- `DungeonGenerationSmokeTest`
- `BossSmokeTest`
- `EnemyVarietySmokeTest`
- `ShopSmokeTest`
- `ChestSmokeTest`
- `RelicSmokeTest`
- `WeaponSmokeTest`

#### 主场景和静态校验

结果：

```text
Main scene startup passed.
Resource reference check passed.
Scene/resource load_steps check passed.
```

#### Windows 导出包复核

当前文件：

```text
E:\Dungeon Unleashed\dungeon-unleashed\builds\windows\Dungeon Unleashed.exe
大小：109340376 bytes
时间：2026-06-30 23:01:03

E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
大小：38190647 bytes
时间：2026-06-30 23:01:08
```

结果：

```text
Exported exe startup passed.
Shared-read zip contents check passed.
```

zip 内容：

```text
Dungeon Unleashed.exe
KNOWN_ISSUES.md
PLAYTEST_FEEDBACK.md
README_PLAYTEST.md
```

### 当前已知限制

- 当前是固定 10 房间图，不是每局随机生成的地牢结构。
- 当前仍只有一个 `PrototypeCombatRoom.tscn` 场景，房间差异来自 `RoomLayoutData` 的地面色、刷怪点、奖励点和矩形障碍物。
- 虽然布局资源库已有 22 个 `.tres`，但单局只使用其中 10 个布局资源。
- 北/南门和分支路线已能运行，但还需要人工完整游玩确认导航可读性、小地图理解成本和敌人是否被障碍物卡住。
- 商店价格已按 10 房间路线做自动化约束，但仍需要真实游玩调参。

### 下一步建议

1. 用导出的 Windows 包完成一次人工 10 房间通关测试，重点记录支路是否容易迷路、商店时机是否合理、Boss 前资源是否过多或过少。
2. 若继续推进地牢层结构，可在当前固定图基础上做路线候选池，而不是立刻引入完全随机生成。
3. 后续再逐步把数据驱动矩形障碍物替换为正式 TileMap 或独立房间模板。

## 2026-06-30 可种子复现地牢生成推进

### 本次目标

- 继续推进开发计划阶段 4 “每局不同探索路线”和 5.5 “可复现指定随机种子”。
- 在不破坏当前 10 房间完整通关节奏的前提下，让支路方向和布局资源选择随种子变化。
- 修复多房间奖励事件串扰，让房间只响应自己生成的奖励。

### 已实现

- `DungeonController.gd` 新增生成种子能力：
  - `generation_seed`
  - `get_generation_seed()`
  - `set_generation_seed(seed)`
  - `regenerate_with_seed(seed)`
- 默认 `generation_seed = 0` 时会为本次生成创建随机种子；指定非 0 seed 时，地牢生成可复现。
- 默认 10 房间路线保留当前完整局节奏：
  - 房间类型序列仍为 `start > combat > reward > combat > elite > shop > combat > reward > combat > boss`。
  - 奖励支路、商店支路会随机落在北侧或南侧。
  - 战斗房、奖励房、精英房、商店房、Boss 房会从布局资源池中选择布局。
- 布局池接入更多现有 `RoomLayoutData` 资源：
  - 战斗布局池包含 `crossfire`、`gauntlet`、`split_cover`、`center_ring`、`ambush_corners`、`box_maze`、`bunker`、`corner_nests`、`crescent`、`diagonal_blocks`、`long_lane`、`narrow_gap`、`twin_islands`、`wide_arena`。
  - 奖励、精英、商店、Boss 也各自拥有可选布局池。
- `DungeonGenerationSmokeTest.gd` 新增种子验收：
  - 同一个 seed 连续生成的地图签名必须一致。
  - 不同 seed 生成的地图签名必须不同。
  - 房间记录会写入当前 `generation_seed`。
- `CombatRoom.gd` 现在记录 `_spawned_reward`，只接受本房间奖励或其子节点触发的 `reward_collected` 事件，避免其它房间的宝箱、商店或拾取物误推进本房间状态。
- `CoinPickup.gd` 新增 `claim_for_player()`，让自动测试和逻辑入口可以稳定领取金币奖励，不再只依赖物理碰撞帧。
- `HUD.gd` 的小地图刷新改为立即移除旧 marker，避免连续重新生成地牢时旧 marker 在下一帧前短暂残留。
- `Main.gd` 新增 `sync_dungeon_hud()`，`DungeonController` 生成后会 deferred 同步一次父级 HUD，避免控制器 `_ready` 早于主场景事件连接时丢失初始小地图。
- 更新根目录和导出包内文档：
  - `KNOWN_ISSUES.md`
  - `dungeon-unleashed/builds/windows/KNOWN_ISSUES.md`
  - `dungeon-unleashed/builds/windows/README_PLAYTEST.md`

### 自动验证结果

#### 受影响地牢/奖励烟测

结果：

```text
DungeonGenerationSmokeTest passed.
FullRunSmokeTest passed.
BalanceSmokeTest passed.
EnemyVarietySmokeTest passed.
ShopSmokeTest passed.
RelicSmokeTest passed.
UILayoutSmokeTest passed.
RoomFlowSmokeTest passed.
ChestSmokeTest passed.
Affected seeded dungeon smoke tests passed.
```

#### 完整烟测套件

结果：

```text
All smoke tests passed.
```

通过项目：

- `AudioFeedbackSmokeTest`
- `BalanceSmokeTest`
- `CombatFeedbackSmokeTest`
- `RunSummarySmokeTest`
- `MenuFlowSmokeTest`
- `SettingsSmokeTest`
- `UILayoutSmokeTest`
- `RoomFlowSmokeTest`
- `FullRunSmokeTest`
- `DungeonGenerationSmokeTest`
- `BossSmokeTest`
- `EnemyVarietySmokeTest`
- `ShopSmokeTest`
- `ChestSmokeTest`
- `RelicSmokeTest`
- `WeaponSmokeTest`

#### 主场景和静态校验

结果：

```text
Main scene startup passed.
Resource reference check passed.
Scene/resource load_steps check passed.
```

#### Windows 导出包复核

当前文件：

```text
E:\Dungeon Unleashed\dungeon-unleashed\builds\windows\Dungeon Unleashed.exe
大小：109345048 bytes
时间：2026-06-30 23:15:47

E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
大小：38195186 bytes
时间：2026-06-30 23:15:52
```

结果：

```text
Exported exe startup passed.
Shared-read zip contents check passed.
```

zip 内容：

```text
Dungeon Unleashed.exe
KNOWN_ISSUES.md
PLAYTEST_FEEDBACK.md
README_PLAYTEST.md
```

### 当前已知限制

- 当前仍是固定房间数量和固定房间类型序列，随机点主要集中在支路方向和布局选择。
- 还没有完整的逻辑图生成器：主路径长度、特殊房间数量、支路数量和 Boss 位置仍是固定规则。
- 当前仍只有一个 `PrototypeCombatRoom.tscn`，布局差异来自数据资源，不是 20 到 30 个独立场景或 TileMap 模板。
- 需要人工完整通关确认不同 seed 下的小地图可读性、支路理解成本、敌人是否被障碍物卡住。

### 下一步建议

1. 在当前 seed 系统上继续抽象真正的房间图生成器，让主路径长度和支路数量也能在范围内变化。
2. 为地牢生成输出调试地图文本或 UI，方便人工验证 seed 与房间连接。
3. 增加少量正式房间模板或 TileMap 房间，逐步替代纯矩形障碍物布局。

## 2026-06-30 地牢 Seed 可视化与调试地图推进

### 本次目标

- 补齐开发计划 5.5 中“可以输出调试地图”和“可以复现指定随机种子”的可观察入口。
- 让外部试玩反馈可以带上地图 seed，便于复现支路方向、布局组合和潜在卡点。
- 修正完整流程测试对可堆叠遗物的误判。

### 已实现

- `DungeonController.gd` 新增 `get_debug_map_text()`：
  - 输出当前 `Seed`。
  - 输出 ASCII 网格地图。
  - 输出每个房间的 ID、类型、坐标、连接方向、布局和状态。
- HUD 小地图新增 seed 显示：
  - 右上角小地图面板现在显示 `Seed: <number>`。
  - 完整 debug map 文本会写入 seed 标签 tooltip。
  - HUD 暴露 `get_minimap_seed_text()` 和 `get_minimap_debug_text()` 供烟测使用。
- `Main.gd` 的地牢 HUD 同步会同时推送小地图和 seed/debug map 信息。
- `DungeonGenerationSmokeTest.gd` 增加断言：
  - 控制器必须暴露 debug map 文本。
  - debug map 必须包含当前 seed、网格块、`Room01` 和 `Room10`。
  - HUD 必须显示当前 seed，并能提供 debug map 文本。
- 结算统计补强：
  - `Main.gd` 的 run summary 新增 `relic_stacks`。
  - 结算 Build 区显示总遗物层数。
  - `FullRunSmokeTest.gd` 改为验证奖励房增加“遗物或遗物层数”，避免随机到已有可堆叠遗物时误判失败。
- 更新试玩文档和已知问题：
  - `README_PLAYTEST.md` 要求反馈地图/布局问题时附带右上角 seed。
  - `KNOWN_ISSUES.md` 说明目前已有 seed 显示，但尚无游戏内 seed 输入/重开 UI。

### 自动验证结果

#### 受影响专项

结果：

```text
DungeonGenerationSmokeTest passed.
UILayoutSmokeTest passed.
FullRunSmokeTest passed.
MenuFlowSmokeTest passed.
SettingsSmokeTest passed.
Affected debug map smoke tests passed.
```

#### 完整烟测套件

结果：

```text
All smoke tests passed.
```

通过项目：

- `AudioFeedbackSmokeTest`
- `BalanceSmokeTest`
- `CombatFeedbackSmokeTest`
- `RunSummarySmokeTest`
- `MenuFlowSmokeTest`
- `SettingsSmokeTest`
- `UILayoutSmokeTest`
- `RoomFlowSmokeTest`
- `FullRunSmokeTest`
- `DungeonGenerationSmokeTest`
- `BossSmokeTest`
- `EnemyVarietySmokeTest`
- `ShopSmokeTest`
- `ChestSmokeTest`
- `RelicSmokeTest`
- `WeaponSmokeTest`

#### 主场景和静态校验

结果：

```text
Main scene startup passed.
Resource reference check passed.
Scene/resource load_steps check passed.
```

#### Windows 导出包复核

当前文件：

```text
E:\Dungeon Unleashed\dungeon-unleashed\builds\windows\Dungeon Unleashed.exe
大小：109347576 bytes
时间：2026-06-30 23:26:47

E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
大小：38197517 bytes
时间：2026-06-30 23:26:52
```

结果：

```text
Exported exe startup passed.
Shared-read zip contents check passed.
```

zip 内容：

```text
Dungeon Unleashed.exe
KNOWN_ISSUES.md
PLAYTEST_FEEDBACK.md
README_PLAYTEST.md
```

### 当前已知限制

- 主菜单已经支持输入指定 seed，结算页已经支持 Replay Seed；尚未提供更完整的开发者调试面板或 seed 历史列表。
- Debug map 主要作为开发/测试辅助文本存在，尚未做成正式游戏内调试面板。
- 当前地牢仍是固定房间数量和类型序列，尚未实现完整变量主路径与支路数量生成。

### 下一步建议

1. 增加更完整的开发者调试面板，用于查看 debug map、复制 seed、记录最近 run。
2. 将当前固定 10 房间序列升级为范围生成：主路径长度、支路数量、特殊房间位置都由种子控制。
3. 继续补真实房间模板或 TileMap，减少对单一原型场景和矩形障碍物的依赖。

## 2026-06-30 Seed 输入复现与经济稳定性推进

### 本次目标

- 把上一轮仅可见的地牢 seed 扩展成玩家可用的复现入口。
- 让外部测试者可以输入固定 seed、随机生成新 seed，并在结算后复现同一条路线。
- 修复固定 seed 暴露出的前期经济断档问题。

### 已实现

- 主菜单新增 `Dungeon Seed` 输入：
  - 留空或输入 `0` 表示随机 seed。
  - 输入正整数表示固定 seed。
  - `Apply Seed` 会立即按输入 seed 重新生成地牢。
  - `Random` 会清空固定 seed 并重新生成随机地牢。
- 结算面板新增 `Replay Seed`：
  - 会保存当前 active seed 并重新加载场景。
  - 下一局会按同一 seed 生成路线，便于复测地图/布局/经济问题。
- `Main.gd` 新增 seed 流程：
  - `start_new_run_from_menu(seed_text)`
  - `apply_dungeon_seed_text(seed_text)`
  - `randomize_dungeon_seed()`
  - `replay_current_seed()`
  - seed 写入 `user://settings.cfg` 的 `gameplay/dungeon_seed`。
- HUD 结算摘要新增 `dungeon_seed` 展示，方便死亡/通关结果直接记录复现信息。
- `MenuFlowSmokeTest.gd` 增加 seed 输入覆盖：
  - 有效 seed 会重生成地牢。
  - 无效 seed 会被拒绝且不改变当前地图。
  - 随机 seed 会回到随机模式。
  - 从主菜单开始时会使用输入 seed。
  - run summary 会记录 active dungeon seed。
- 普通宝箱默认奖励从单次随机 `gold/heal` 调整为稳定 `gold + heal`：
  - 避免普通宝箱连续随机到回血导致商店前金币低于购买线。
  - `ChestSmokeTest.gd` 对单次金币箱的测试改为显式设置 `reward_count = 1`。
- 试玩文档同步更新：
  - `README_PLAYTEST.md` 增加 seed 输入和 Replay Seed 检查。
  - `PLAYTEST_FEEDBACK.md` 增加 Dungeon seed 字段和固定 seed 复现问题。
  - `KNOWN_ISSUES.md` 删除“没有 seed 输入/重开 UI”的旧限制，改为说明 debug map 仍是开发辅助。

### 发现并修复的问题

- 完整烟测第一次运行时，`BalanceSmokeTest` 在持久化 seed `24680` 下失败：

```text
Natural gold before mid-route shop should afford a meaningful purchase
```

- 原因：普通宝箱默认是单次随机 `gold/heal`，固定 seed 使“前期宝箱少出金币”的情况变得可复现。
- 修复：普通宝箱默认给 `gold + heal`，保留可配置掉落池能力，确保商店前自然金币范围稳定。

### 自动验证结果

#### 受影响专项

```text
MenuFlowSmokeTest passed.
UILayoutSmokeTest passed.
BalanceSmokeTest passed.
ChestSmokeTest passed.
```

#### 完整烟测套件

```text
All smoke tests passed.
```

通过项目：

- `AudioFeedbackSmokeTest`
- `BalanceSmokeTest`
- `CombatFeedbackSmokeTest`
- `RunSummarySmokeTest`
- `MenuFlowSmokeTest`
- `SettingsSmokeTest`
- `UILayoutSmokeTest`
- `RoomFlowSmokeTest`
- `FullRunSmokeTest`
- `DungeonGenerationSmokeTest`
- `BossSmokeTest`
- `EnemyVarietySmokeTest`
- `ShopSmokeTest`
- `ChestSmokeTest`
- `RelicSmokeTest`
- `WeaponSmokeTest`

#### 主场景和静态校验

```text
Main scene startup passed.
Resource reference check passed.
Scene/resource load_steps check passed.
```

#### Windows 导出包复核

当前文件：

```text
E:\Dungeon Unleashed\dungeon-unleashed\builds\windows\Dungeon Unleashed.exe
大小：109352376 bytes
时间：2026-06-30 23:39:52

E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
大小：38202285 bytes
时间：2026-06-30 23:39:57
```

结果：

```text
Exported exe startup passed.
```

zip 内容：

```text
Dungeon Unleashed.exe
KNOWN_ISSUES.md
PLAYTEST_FEEDBACK.md
README_PLAYTEST.md
```

### 当前已知限制

- Debug map 仍主要作为开发辅助文本存在，尚未做成正式游戏内调试面板。
- 当前地牢仍是固定房间数量和类型序列，尚未实现完整变量主路径与支路数量生成。
- 房间仍使用一个原型场景配合 `.tres` 布局资源，还不是独立 TileMap/场景模板库。
- 仍缺少人工完整通关试玩对手感、音量、视觉可读性和 Boss 节奏的确认。

### 下一步建议

1. 扩展地牢图生成器，让主路径长度、支路数量和特殊房间位置也进入 seed 控制。
2. 增加正式 debug map 面板或开发者快捷键，支持复制当前 seed 和调试地图。
3. 继续补真实房间模板/TileMap，并进行一次人工完整通关记录。

## 2026-07-01 变量地牢图生成推进

### 本次目标

- 将上一轮“固定 10 房间序列 + 随机支路方向/布局”升级为 seed 驱动的变量地牢图。
- 让主路径长度、支路数量、奖励/商店/精英支路位置和布局选择都能随 seed 变化，同时保持完整通关路径稳定。
- 更新自动化烟测，避免继续绑定 `Room10` 或固定房间类型序列。

### 已实现

- `DungeonController.gd` 默认生成规则改为变量图：
  - 主路径随机 7-9 个节点。
  - 支路随机 3-5 个节点。
  - Boss 固定在主路径末端。
  - 至少生成奖励支路、商店支路和额外奖励支路。
  - 商店锚定在早期精英房之后，避免过晚进店导致经济节奏偏移。
  - 可选支路优先落在中后段，减少商店前金币过多的问题。
- 房间记录新增调试元数据：
  - `path_role`
  - `main_path_index`
  - `branch_of`
- `get_debug_map_text()` 现在会输出房间路径角色、主路径索引、支路锚点和布局，便于复现 seed 问题。
- `DungeonGenerationSmokeTest.gd` 更新为验证变量图不变量：
  - 总房间数 10-14。
  - 主路径数 7-9。
  - 支路数 3-5。
  - Boss 是最后一个房间。
  - 至少包含奖励房、精英房和商店房。
  - 奖励房和商店房必须位于支路。
- `BalanceSmokeTest.gd` 改为按房间类型查找首个精英房和首个商店房，不再依赖固定索引；固定 seed `424242` 会重新生成后再验证自然进店金币区间。
- `FullRunSmokeTest.gd` 改为验证变量路线的完整通关条件，不再断言固定签名。
- `EnemyVarietySmokeTest.gd` 改为按 `room_type` 查找战斗房/奖励房，并清理残留敌人时立即移除和释放，降低跨验证步骤的残留干扰。
- `KNOWN_ISSUES.md`、打包目录 `KNOWN_ISSUES.md` 和 `README_PLAYTEST.md` 已同步更新为 10-14 房间变量路线说明。

### 发现并修复的问题

- 变量图初版下，`BalanceSmokeTest` 曾暴露商店前金币过高的问题：

```text
gold=304 route=start>combat>combat>combat>elite>shop>combat>reward>combat>reward>reward>boss
```

- 修复方式：将早期精英/商店窗口前移，并让可选支路更偏向商店后的中后段，减少商店前累计战斗/奖励过多。
- 完整烟测第一次运行中，`RunSummarySmokeTest` 出现一次不稳定失败；单测复跑通过，完整套件复跑通过，未改运行时代码。
- 直接用 `--script res://scripts/debug/*.gd` 跑烟测会缺失 Autoload `Events` 编译符号；正确 CLI 验证入口是 `--scene res://scenes/debug/*SmokeTest.tscn`。

### 自动验证结果

#### 受影响专项

```text
DungeonGenerationSmokeTest passed.
BalanceSmokeTest passed.
FullRunSmokeTest passed.
EnemyVarietySmokeTest passed.
```

#### 完整烟测套件

```text
AudioFeedbackSmokeTest passed.
BalanceSmokeTest passed.
BossSmokeTest passed.
ChestSmokeTest passed.
CombatFeedbackSmokeTest passed.
DungeonGenerationSmokeTest passed.
EnemyVarietySmokeTest passed.
FullRunSmokeTest passed.
MenuFlowSmokeTest passed.
RelicSmokeTest passed.
RoomFlowSmokeTest passed.
RunSummarySmokeTest passed.
SettingsSmokeTest passed.
ShopSmokeTest passed.
UILayoutSmokeTest passed.
WeaponSmokeTest passed.
```

#### 主场景和静态校验

```text
Main scene startup passed.
Resource reference check passed.
Scene/resource load_steps check passed.
```

#### Windows 导出包复核

当前文件：

```text
E:\Dungeon Unleashed\dungeon-unleashed\builds\windows\Dungeon Unleashed.exe
大小：109356392 bytes
时间：2026-07-01 09:42:59

E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
大小：38206476 bytes
时间：2026-07-01 09:48:37
```

zip 内容：

```text
Dungeon Unleashed.exe
KNOWN_ISSUES.md
PLAYTEST_FEEDBACK.md
README_PLAYTEST.md
```

导出状态：

```text
Windows release export passed.
Shared-read zip contents check passed.
```

导出 `.exe` 自动启动验证限制：

```text
--headless --quit returned -1073741819.
--headless --quit-after 1 did not reliably exit before timeout.
```

结论：本轮不把导出 `.exe` 自动启动记为通过，仍需人工双击运行并完成试玩复核；Godot 项目主场景 headless 启动和 Windows 导出/zip 打包已通过。

### 当前已知限制

- 当前已经不再是固定房间数量和固定房间类型序列，但仍使用一个 `PrototypeCombatRoom.tscn` 配合 `.tres` 布局资源，并非正式 TileMap/独立房间模板库。
- `F3` Debug Map 面板已可查看并复制当前 seed 和地图文本，但仍是开发者辅助界面，不是最终玩家 UI。
- 变量图规则还比较保守，尚未实现多层地牢、事件房、Boss 前休整房或正式地图选择界面。
- 导出 Windows `.exe` 的自动 CLI 启动验证本轮不稳定，需要人工运行确认真实窗口、音频和输入。
- 仍缺少人工完整通关试玩对支路可读性、商店时机、Boss 节奏和视觉噪音的确认。

### 下一步建议

1. 用导出的 Windows 包人工跑 3 个不同 seed，记录路线长度、商店前金币、支路理解成本和 Boss 前资源状态。
2. 继续打磨 Debug Map 面板的信息层级、复制反馈和试玩问题记录格式。
3. 继续补真实房间模板/TileMap，减少对单一原型场景和矩形障碍物的依赖。

## 2026-07-01 Debug Map 面板与 GitHub 上传前复核

### 本次目标

- 把地牢生成 debug map 从 tooltip/文本能力推进为可在游戏内打开的开发者面板。
- 在上传 GitHub 前重新验证烟测、主场景启动、静态资源引用、Windows 导出和 zip 包内容。
- 同步试玩说明、已知问题和开发日志，避免文档仍描述旧状态。

### 已实现

- `Main.gd` 新增 `debug_map` 输入动作处理，默认按键为 `F3`。
- `HUD.tscn` 新增居中的 `DebugMapPanel`，包含只读地图文本、`Copy Map` 和 `Close` 按钮。
- `HUD.gd` 新增 Debug Map 面板显示/隐藏、文本刷新、复制剪贴板、响应式布局和输入提示同步。
- `DungeonGenerationSmokeTest.gd` 新增 Debug Map 面板可见性、seed 文本、最终 Boss 房间 ID 和复制流程断言。
- `UILayoutSmokeTest.gd` 新增 1280x720、1600x900、1920x1080 下 Debug Map 面板布局检查。
- `EnemyVarietySmokeTest.gd` 的奖励/商店房无敌人检查改为房间局部范围检查，避免完整烟测套件中残留敌人干扰结论。
- `.gitignore` 新增 `**/.vs/`，避免本地 IDE 缓存进入版本库或试玩包。
- `README_PLAYTEST.md` 和 `KNOWN_ISSUES.md` 已同步说明 `F3` Debug Map 面板和 `Copy Map` 反馈用途。

### 自动验证结果

```text
DungeonGenerationSmokeTest passed.
UILayoutSmokeTest passed.
EnemyVarietySmokeTest passed.
All smoke tests passed.
Main scene startup passed.
Resource reference check passed.
Scene/resource load_steps check passed.
git diff --check passed.
Windows release export passed.
Windows prototype zip contents check passed.
```

完整烟测套件包含：

```text
AudioFeedbackSmokeTest
BalanceSmokeTest
BossSmokeTest
ChestSmokeTest
CombatFeedbackSmokeTest
DungeonGenerationSmokeTest
EnemyVarietySmokeTest
FullRunSmokeTest
MenuFlowSmokeTest
RelicSmokeTest
RoomFlowSmokeTest
RunSummarySmokeTest
SettingsSmokeTest
ShopSmokeTest
UILayoutSmokeTest
WeaponSmokeTest
```

### Windows 导出包复核

当前文件：

```text
E:\Dungeon Unleashed\dungeon-unleashed\builds\windows\Dungeon Unleashed.exe
大小：109358904 bytes
时间：2026-07-01 10:11:36

E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
大小：38208344 bytes
时间：2026-07-01 10:11:50
```

zip 内容：

```text
Dungeon Unleashed.exe
KNOWN_ISSUES.md
PLAYTEST_FEEDBACK.md
README_PLAYTEST.md
```

### 当前已知限制

- Debug Map 面板仍是开发者辅助界面，未做成最终玩家 UI。
- 导出 Windows `.exe` 的自动 CLI 启动验证仍不计入通过，需要人工双击运行确认窗口、音频和输入。
- 仍缺少人工完整通关试玩对支路可读性、商店时机、Boss 节奏和视觉噪音的确认。

## 2026-07-01 Windows 导出无敌人与访问冲突修复

### 问题现象

- 验证导出 `.exe` 时多次出现 Windows 应用程序错误，错误表现为访问冲突读取 `0x0000000000000050`。
- 解压 `Dungeon_Unleashed_Windows_Prototype.zip` 后启动游戏，房间会直接进入清理状态，整局没有敌人。

### 根因确认

- 新增导出运行时自检 `--runtime-room-check` 后，旧导出包复现为：

```text
RuntimeRoomSpawnCheck failed: first_room_state=3 enemies=0 expected_wave=0
```

- 这说明导出包内第一间房直接变成 `CLEARED`，并且 `wave_enemy_counts` 在导出运行时为空。
- 根因不是敌人场景缺失，而是导出后的自定义 `RoomData.tres -> .res` 运行时字段读取不可靠，导致地牢控制器通过动态 `Resource.get()`/`Node.set()` 写入 CombatRoom 的核心字段时拿到空配置。

### 修复内容

- `DungeonController.gd` 增加房间配置 fallback 表：
  - start、combat、reward、elite、shop、boss 六类房间的核心配置可由代码常量恢复。
  - fallback 覆盖房间类型、布局、敌人场景、敌人名称、波次、奖励场景、锁门规则、自动清房规则和精英参数。
- `DungeonController.gd` 改为强类型写入 `CombatRoom` 字段，减少导出后动态反射失效风险。
- `CombatRoom.gd` 改为强类型读取 `RoomLayoutData`，避免布局字段在导出运行时失效。
- `CombatRoom.gd` 增加未进入状态下的物理帧 overlap 兜底检查，避免一次性延迟检查错过玩家导致房间不触发。
- `Main.gd` 增加仅命令行触发的 `--runtime-room-check` 导出运行时自检：
  - 固定 seed `424242`。
  - 启动新局。
  - 等待第一间房触发。
  - 断言第一间房进入 Combat 且生成第一波敌人。
- `RoomFlowSmokeTest.gd` 新增从主菜单开始后第一间房自然刷怪断言。
- `project.godot` 默认渲染改为 GL Compatibility / OpenGL，降低 Windows D3D12 导出运行时访问冲突风险。

### 自动验证结果

```text
RuntimeRoomSpawnCheck passed in Godot project.
All smoke tests passed.
Main scene startup passed.
Resource reference check passed.
Scene/resource load_steps check passed.
git diff --check passed.
Windows release export passed.
Exported exe runtime room-spawn check passed.
Windows prototype zip contents check passed.
```

导出 `.exe` 运行时自检结果：

```text
Godot Engine v4.7.stable.official.5b4e0cb0f
OpenGL API 3.3.0 - Compatibility
RuntimeRoomSpawnCheck passed: first_room_state=2 enemies=2 expected_wave=2
```

### Windows 导出包复核

当前文件：

```text
E:\Dungeon Unleashed\dungeon-unleashed\builds\windows\Dungeon Unleashed.exe
大小：109366488 bytes
时间：2026-07-01 10:31:27

E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
大小：38215397 bytes
时间：2026-07-01 10:32:45
```

zip 内容：

```text
Dungeon Unleashed.exe
KNOWN_ISSUES.md
PLAYTEST_FEEDBACK.md
README_PLAYTEST.md
```

### 当前仍需人工复核

- 导出包已经验证可以启动运行时刷怪，但仍需要人工完整通关确认窗口显示、真实输入、音频、节奏和 Boss 体验。

## 2026-07-01 敌人安全生成与召唤卡顿加固

### 问题现象

- 游戏运行中有概率出现卡死或崩溃。
- 敌人有时会刷新到玩家身上，导致玩家刚进房间或敌人刚召唤时立即扣血。

### 修复内容

- `CombatRoom.gd` 新增敌人安全生成规则：每波敌人会优先选择远离玩家的生成点，并加入轻微错位，避免同一刷怪点堆叠。
- `CombatRoom.gd` 新增波次切换防重入标记，避免同一波清空后重复创建多个下一波计时器。
- `Enemy.gd` / `BossEnemy.gd` 新增 `can_deal_contact_damage()` 与出生接触伤害宽限期，刚生成的敌人不会立刻通过贴脸碰撞扣血。
- 普通召唤型敌人新增 `max_active_summons` 上限，避免长时间战斗中召唤物数量无限增长造成卡顿风险。
- 普通召唤型敌人和 Boss 召唤物会根据玩家位置调整落点，避免召唤物直接生成在玩家身上。
- `Player.gd` 的接触伤害逻辑会尊重新增的敌人出生宽限。
- `Main.gd` 的 `--runtime-room-check` 增加最近敌人距离校验，导出包自检会覆盖“有敌人且不贴脸生成”。

### 自动验证结果

```text
Godot headless project startup passed.
RoomFlowSmokeTest passed.
EnemyVarietySmokeTest passed.
BossSmokeTest passed.
CombatFeedbackSmokeTest passed.
WeaponSmokeTest passed.
FullRunSmokeTest passed.
RuntimeRoomSpawnCheck passed: first_room_state=2 enemies=2 expected_wave=2 nearest_enemy_distance=311.7
Windows release export passed.
Exported exe RuntimeRoomSpawnCheck passed: first_room_state=2 enemies=2 expected_wave=2 nearest_enemy_distance=432.3
Windows prototype zip regenerated: E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
```

### 仍需人工复核

- 需要用最新导出包进行 10 分钟以上实机游玩，重点观察召唤型敌人较多时是否仍有卡顿。
- 需要在不同 seed 下进入普通房、精英房和 Boss 房，确认敌人/召唤物不会出生贴脸扣血。

## 2026-07-01 命中浮字位置与敌方子弹 owner 生命周期修复

### 问题现象

- 玩家子弹打击敌人时，跳出的扣血浮字会出现在怪物附近以外的位置，实际表现接近玩家或世界原点。
- 发射子弹的敌人射出的弹药命中玩家，同时玩家子弹击杀该敌人时，仍有概率触发崩溃。

### 根因确认

- `FloatingText.gd` 在 `_ready()` 中记录初始运动起点，但 `Main.gd` 是在节点添加后才设置世界坐标；下一帧浮字运动会回到旧的 `(0,0)` 起点。
- 玩家子弹命中敌人后会先调用 `apply_damage()`，敌人死亡时进入 `queue_free()`，随后 UI 仍可能通过目标节点推导浮字位置，位置来源不稳定。
- 敌方子弹持有发射者敌人的强引用，并在后续 raycast / 命中伤害中继续读取 owner；当发射者同帧被玩家击杀释放时，存在访问已释放对象的风险。

### 修复内容

- `FloatingText.setup()` 现在会在 Main 设置好浮字世界坐标后刷新运动起点，浮字不会再被下一帧拉回原点。
- `Projectile.gd` 在命中瞬间缓存 `last_hit_position`，并写入 metadata；`Main.gd` 的命中浮字优先使用该坐标，不再依赖死亡/释放中的敌人节点。
- `Projectile.gd` 的 owner 读取增加有效性检查，避免从已释放 owner 读取 RID 或作为伤害来源传递。
- `EnemyProjectile.gd` 改为发射时缓存 owner RID，并使用 `WeakRef` 安全读取 owner；发射者死亡后命中玩家时，伤害来源会安全降级为 `null`。
- `CombatFeedbackSmokeTest.gd` 新增两个回归场景：
  - 玩家子弹击杀敌人后，扣血浮字必须出现在 projectile 命中点附近。
  - 敌方子弹发射者死亡并释放后，子弹仍能安全命中玩家。

### 自动验证结果

```text
CombatFeedbackSmokeTest passed.
WeaponSmokeTest passed.
EnemyVarietySmokeTest passed.
BossSmokeTest passed.
RoomFlowSmokeTest passed.
FullRunSmokeTest passed.
Godot headless project startup passed.
RuntimeRoomSpawnCheck passed: first_room_state=2 enemies=2 expected_wave=2 nearest_enemy_distance=359.0
Windows release export passed.
Exported exe RuntimeRoomSpawnCheck passed: first_room_state=2 enemies=2 expected_wave=2 nearest_enemy_distance=434.1
Windows prototype zip regenerated: E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
```

### 仍需人工复核

- 请在导出包中重点复测远程敌人：让 Shooter 敌人发射子弹，同时用玩家子弹击杀该 Shooter，观察是否还会崩溃。
- 导出 exe 自检退出时出现一次 `1 ObjectDB instance was leaked at exit` 警告，未导致自检失败；后续若持续出现，需要单独追踪泄漏对象。

## 2026-07-01 站桩换弹位移与护盾敌人可击杀性修复

### 问题现象

- 开局站在原地清掉第一批敌人后，如果此时触发换弹，玩家位置会被强制挤到一个固定区域。
- 后续关卡中正面带护盾的敌人，在使用低伤害武器从正面射击时无法击杀。

### 根因确认

- 没有发现换弹逻辑直接改写玩家坐标；实际风险来自敌人 `CharacterBody2D` 在追踪移动时仍会主动与玩家身体发生物理碰撞，玩家站桩换弹期间容易被敌人或下一波敌人的运动碰撞顶走。
- 护盾正面减伤使用 `floori(amount * multiplier)`，基础手枪 1 点伤害被 `0.2` 倍减伤后向下取整为 0，导致正面射击永远不掉血。

### 修复内容

- `Enemy.gd` 和 `BossEnemy.gd` 在 `_ready()` 中移除敌人运动碰撞 mask 里的 Player body 位，敌人追踪时不再主动把玩家身体顶走；玩家受击仍由 Hurtbox/伤害逻辑处理。
- `Enemy.gd` 的护盾正面减伤改为至少造成 1 点伤害，护盾敌人仍有正面减伤，但不会完全免疫低伤害武器。
- `RoomFlowSmokeTest.gd` 新增开局首波站桩换弹回归：清掉第一波并等待换弹/刷波后，玩家位置不能被强制移动。
- `EnemyVarietySmokeTest.gd` 新增护盾敌人正面低伤害可击杀回归。

### 自动验证结果

```text
RoomFlowSmokeTest passed.
EnemyVarietySmokeTest passed.
WeaponSmokeTest passed.
CombatFeedbackSmokeTest passed.
BossSmokeTest passed.
FullRunSmokeTest passed.
Godot headless project startup passed.
RuntimeRoomSpawnCheck passed: first_room_state=2 enemies=2 expected_wave=2 nearest_enemy_distance=313.5
Windows release export passed.
Exported exe RuntimeRoomSpawnCheck passed: first_room_state=2 enemies=2 expected_wave=2 nearest_enemy_distance=434.1
Windows prototype zip regenerated: E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
```

### 仍需人工复核

- 在最新导出包中复测：开局站桩清掉第一波，手动打空弹匣并等待换弹，确认玩家不会被挤到固定位置。
- 在包含 Shield Enemy 的后续房间中，使用基础手枪从正面持续射击，确认敌人可以被击杀，同时仍能感觉到护盾正面减伤。

## 2026-07-01 开局原地击杀首波后的强制位移修复补强

### 问题现象

- 开局后玩家完全不移动，原地击杀首波两个 Chaser 后，会稳定触发角色位置被强制改变。
- 如果玩家先移动一段距离，再击杀首波敌人，则不容易触发该问题。

### 根因确认

- 上一次修复已让敌人移动时不再主动检测 Player body 层，但玩家自身的 `collision_mask` 仍包含 Enemy 层。
- 玩家原地站桩时，敌人贴近、死亡和下一波刷新交界会让玩家身体与 Enemy body 层进入重叠/恢复状态；`CharacterBody2D.move_and_slide()` 即使在零输入速度下也会做物理恢复，从而把玩家推出到看似固定的位置。
- 玩家和敌人的接触伤害本来已经由 `Hurtbox` 负责，不需要玩家身体与敌人身体发生物理碰撞。

### 修复内容

- `Player.tscn` 的 Player `collision_mask` 从 `10` 改为 `8`，玩家身体现在只检测 Wall 层，不再检测 Enemy 层。
- `Player.gd` 在 `_ready()` 中兜底移除 Enemy body 位，避免后续场景或资源误配重新引入该问题。
- `RoomFlowSmokeTest.gd` 增加玩家身体忽略 Enemy body 层的回归断言，防止后续改动把该 mask 加回来。

### 自动验证结果

```text
Godot headless project startup passed.
RoomFlowSmokeTest passed.
EnemyVarietySmokeTest passed.
CombatFeedbackSmokeTest passed.
WeaponSmokeTest passed.
BossSmokeTest passed.
FullRunSmokeTest passed.
RuntimeRoomSpawnCheck passed: first_room_state=2 enemies=2 expected_wave=2 nearest_enemy_distance=311.7
Windows release export passed.
Exported exe RuntimeRoomSpawnCheck passed: first_room_state=2 enemies=2 expected_wave=2 nearest_enemy_distance=432.3
Windows prototype zip regenerated: E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
```

### 仍需人工复核

- 使用最新导出包开局后完全不按 WASD，原地击杀首波两个 Chaser，确认玩家不会再被推到固定位置。
- 故意让 Chaser 贴近玩家，确认仍会通过 Hurtbox 正常扣血。
- 导出 exe 自检退出时仍出现一次 `1 ObjectDB instance was leaked at exit` 警告，未导致自检失败；该警告与本次玩家位移修复无直接关联。

## 2026-07-01 类元气骑士资源循环第一批靠拢

### 目标

- 根据公开资料中《元气骑士》的俯视角 Roguelike 弹幕射击、随机房间、武器/角色/资源循环等特征，开始把项目从普通地牢射击原型推进到更接近同类体验的结构。
- 本轮不复制《元气骑士》的名称、美术、角色或数值，只吸收通用玩法结构。

### 新增文档

- 新增 `SOUL_KNIGHT_ALIGNMENT.md`，记录在线检索到的核心参考点、当前项目已具备内容、主要差距和后续靠拢顺序。

### 修复和新增内容

- `Player.gd` 新增 `Energy` 能量资源，开局满值，并在短暂延迟后自动恢复。
- `WeaponData.gd` 新增 `energy_cost` 字段。
- `Weapon.gd` 开火前会检查并消耗玩家能量；能量不足时不会开火、不会消耗弹药、不会生成弹丸。
- `basic_pistol` 保持 0 能量消耗，避免玩家能量耗尽后完全失去攻击能力。
- `shotgun`、`energy_staff`、`ricochet_blaster` 配置不同能量消耗，形成武器强度和资源消耗取舍。
- 玩家 `Shield` 在 UI 中表现为 `Armor`：开局满值，优先吸收伤害，受击后延迟恢复。
- HUD 新增 `Energy: current / max` 显示，并将 `Shield` 显示改为 `Armor: current / max`。

### 自动验证结果

```text
Godot headless project startup passed.
WeaponSmokeTest passed.
RelicSmokeTest passed.
RunSummarySmokeTest passed.
RoomFlowSmokeTest passed.
CombatFeedbackSmokeTest passed.
EnemyVarietySmokeTest passed.
UILayoutSmokeTest passed.
BossSmokeTest passed.
FullRunSmokeTest passed.
```

### 仍需人工复核

- 使用最新导出包确认 HUD 左上角能同时看到 HP、Armor、Energy、Weapon、Ammo。
- 切换到 Shotgun / Energy Staff / Ricochet Blaster 后连续开火，确认 Energy 会下降且不足时无法继续开火。
- 故意受伤后躲避一段时间，确认 Armor 会逐点恢复。
- 导出 exe 自检退出时仍出现一次 `1 ObjectDB instance was leaked at exit` 警告，未导致自检失败；后续可单独追踪该清理警告。

## 2026-07-01 类元气骑士角色差异和主动技能第一批靠拢

### 目标

- 在已有 Energy/Armor 资源循环基础上，补上同类游戏常见的“开局选角色 + 角色主动技能”结构。
- 本轮只实现原创占位角色和可测试机制，不复制《元气骑士》的角色名称、技能表现、美术或数值。

### 新增内容

- 新增 `PlayerCharacterData.gd`，用于数据化配置角色名称、说明、基础 HP、Armor、Energy、移动速度、主动技能、冷却、持续时间、消耗和效果强度。
- 新增 3 个角色资源：`Wanderer`、`Warden`、`Arcanist`。
- 主菜单新增角色切换区域，可以在开始 run 前选择角色；进入 run 后角色锁定。
- 新增 `skill` 输入动作，默认按键为 `Space`。
- HUD 左上角新增 Skill 状态显示，支持 Ready、Active 和 CD 状态。
- 结算摘要新增角色字段，后续可用于角色胜率、解锁和局外成长统计。

### 角色原型

- `Wanderer`：均衡属性，技能 `Phase Dash` 提供短暂无敌和移速爆发。
- `Warden`：更高 HP/Armor、更低 Energy 和较慢移动，技能 `Guard Pulse` 恢复 Armor 并提供短暂防护。
- `Arcanist`：更高 Energy、更低 HP/Armor，技能 `Energy Surge` 恢复 Energy 并短时间提高射速。

### 自动验证结果

```text
Godot headless project startup passed.
CharacterSmokeTest passed.
MenuFlowSmokeTest passed.
RunSummarySmokeTest passed.
SettingsSmokeTest passed.
UILayoutSmokeTest passed.
WeaponSmokeTest passed.
RelicSmokeTest passed.
RoomFlowSmokeTest passed.
CombatFeedbackSmokeTest passed.
EnemyVarietySmokeTest passed.
BossSmokeTest passed.
FullRunSmokeTest passed.
RuntimeRoomSpawnCheck passed: first_room_state=2 enemies=2 expected_wave=2 nearest_enemy_distance=360.7
Windows release export passed.
Exported exe RuntimeRoomSpawnCheck passed: first_room_state=2 enemies=2 expected_wave=2 nearest_enemy_distance=435.8
Windows prototype zip regenerated: E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
```

### 仍需人工复核

- 在导出包主菜单中切换 3 个角色，确认说明文本、HP、Armor、Energy 和技能状态刷新正常。
- 进入游戏后按 `Space` 使用主动技能，确认技能效果、冷却和 HUD 状态变化可感知。
- 开局后确认角色不能在战斗中被切换。

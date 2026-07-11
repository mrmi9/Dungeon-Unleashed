# Dungeon Unleashed 开发日志

本文档用于记录《Dungeon Unleashed》的阶段性开发进度、已实现功能、验证结果、已知问题和后续任务。开发目标以 `DEVELOPMENT_PLAN.md` 为准。

## 当前项目快照

### 文档状态

- 日志文件：`E:\Dungeon Unleashed\DEVELOPMENT_LOG.md`
- Godot 项目：`E:\Dungeon Unleashed\dungeon-unleashed`
- 当前记录日期：2026-07-11
- 当前开发进度：已从阶段 1 核心操作原型推进到包含 6 个原创角色、35 把武器、40 个遗物、燃烧/减速元素状态链路、近战挡弹/反制链路、蓄力武器释放链路、部署/陷阱武器链路、弹跳/爆炸半径/击退/弹匣/能量专属遗物链路、3 个本局天赋、3 个事件祝福、3 个主线 Boss 变体、经济、商店、宝箱、武器房、治疗补给房、事件房、挑战房、陷阱房、Boss 后天赋选择、事件祝福选择、主菜单局外图鉴/记录入口、Outpost Hall 分页、图鉴详情文本页、Build 路线筛选、图鉴搜索/排序/稀有度筛选、局外永久货币与角色熟练度、Boss 二阶段场地压力、第一轮自动化数值平衡、22 个数据驱动房间布局资源、可种子复现的三层 39-45 房间变量分支路线、设置保存、核心键位重绑定、结算统计、历史记录、基础音频反馈、核心 UI 布局烟测、Windows 打包验证和试玩反馈材料的最小完整局流程；主菜单、暂停、设置、死亡结算、通关结算、商店消费、宝箱奖励、占位音频、Windows 原型包、反馈模板和已知问题列表已有原型，正式美术音频素材、代码签名和外部分发仍未完成。
- 最新 Windows 原型包：`E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip`

### 当前已实现功能总览

- 项目基础结构、主场景、输入映射、Autoload 事件总线和碰撞层已完成。
- 玩家可 WASD 八方向移动、鼠标瞄准、左键射击、切换武器、受击、短暂无敌、死亡后停止操作。
- 已实现 6 个原创角色：Wanderer、Warden、Arcanist、Rift Runner、Emberwright、Field Medic。
- 已实现 35 把武器：原有 30 把基础上新增 Quench Repeater、Furnace Scattergun、Bastion Saw、Rift Bloom 和 Thunder Nest，分别补充减速精准、燃烧霰射、重击挡弹、环形弹跳和传奇部署控场路线。
- 武器系统支持射速、散射、多弹丸、弹匣、换弹、暴击、穿透、反弹、追踪、连锁、爆炸、燃烧/减速状态、近战挡弹字段、蓄力释放字段，以及 field / mine / sentry 三类数据驱动部署行为。
- 子弹支持直线飞行、射程销毁、命中敌人、命中墙体、击退和命中特效。
- 已实现可种子复现的三层 39-45 房间变量分支路线：标准 RunGraph 由 Outer Warrens、Iron Catacombs、Void Foundry 三个 biome 组成，每层主路径 7-9 个节点、支路 6 个节点，并在层末生成各自 Boss。
- 已实现事件房第一版并接入事件祝福：每层生成一个事件分支，玩家按 `E` 触发事件祭坛后消耗 1 点生命，获得金币和 3 选 1 本局祝福；触碰不会自动触发，生命不足时不能触发。
- 已实现挑战房第一版：当某个 biome 生成第 6 个分支时优先放入 `challenge` 分支，使用两波精英化敌人、门锁战斗、高级宝箱奖励和小地图 `T` 标记，作为更高风险的可选收益房。
- 已实现陷阱房第一版：`trap` 分支进房后锁门并生成可读地面危险预警，存活计时结束后清房、给少量清房金币并生成普通宝箱；小地图使用 `X` 标记。
- 已实现 Boss 后本局天赋第一版：非最终 biome 的 Boss 宝箱打开后提供 3 选 1 天赋，天赋会改变本局伤害、射速或生命上限，并进入结算 Build 回顾。
- HUD 小地图会显示当前地牢 seed 和分层标签；主菜单支持输入固定 seed 或回到随机 seed，结算页支持 Replay Seed；`DungeonController.get_debug_map_text()` 可输出 seed、biome 摘要、网格、房间坐标、连接方向和布局，`F3` 可打开开发者 Debug Map 面板并复制地图文本，便于复现地图问题。
- 战斗房支持进入触发、锁门、敌人波次、清房开门和奖励生成。
- 已实现地牢房间数据资源、房间布局资源、房间生成控制器、`layout_data`/`layout_profile` 元数据和 HUD 小地图。
- 已建立 `resources/room_layouts` 布局库，当前包含 22 个 `.tres` 布局资源；布局资源可配置地面色、刷怪点、奖励点和矩形障碍物。
- 已实现 6 类普通敌人：追踪、远程、冲锋、自爆、召唤、护盾。
- 已实现精英房规则：敌人精英化、血量/伤害倍率、视觉强化和死亡爆炸。
- 已实现 3 个主线 Boss 变体：Warrens Gatekeeper、Iron Bulwark、Void Foundry Heart。它们复用 Boss 基础脚本，但使用独立场景、显示名、生命值、弹幕/召唤参数和视觉配色；中间 biome Boss 只产出奖励，最终 biome Boss 奖励宝箱才触发通关结算。
- 已实现最小主流程 UI：启动进入主菜单、开始新局、暂停/恢复、死亡结算、通关结算、分组结算面板、重新开始和返回主菜单入口。
- 局外大厅已从主菜单动态面板推进到 `Outpost Hall` 场景骨架：大厅内可查看历史记录、Data Shards、角色熟练度、角色详情、武器/遗物/天赋/祝福详情摘要与 Build 路线，并能按 Build 路线筛选图鉴，进入开局、训练和设置。
- 大面板 UI 已加入基础响应式约束：主菜单、暂停、设置、局外图鉴、遗物选择和结算面板会按视口限制尺寸；打开大面板时会隐藏右下角输入提示，避免 720p 下互相遮挡。
- 已实现设置菜单和设置保存：主音量、音效音量、音乐音量、分辨率、全屏开关、核心键位重绑定、`user://settings.cfg` 持久化读取和保存。
- 已实现局内输入提示：HUD 右下角显示移动、瞄准、射击、换弹、切武器、交互和暂停按键。
- 已实现基础音频反馈：运行时 SFX/Music 总线、程序化占位音效、普通/战斗/Boss/胜利/失败背景音乐模式。
- 已实现 Windows 导出配置和打包流程：`export_presets.cfg`、Godot 4.7 Windows 模板、release `.exe` 导出和试玩 zip 包；本轮导出 `.exe` 自动 headless 启动验证受导出 runner 参数限制，仍需要人工双击运行复核。
- 已补齐外部试玩材料：`PLAYTEST_FEEDBACK.md`、`KNOWN_ISSUES.md` 和打包目录内的试玩说明。
- 已实现本局结算统计和历史统计：死亡/通关面板展示武器、遗物、生命、护盾、HP 伤害、暴击次数、治疗量、护盾吸收量、金币收支、奖励、宝箱、商店购买、Boss 击败状态和历史最好记录。
- 结算统计会区分唯一遗物数量和遗物总层数，避免可堆叠遗物被误判为没有成长。
- 已实现最小经济/商店循环：击杀金币、清房金币、商店房、回血商品、遗物商品、武器商品、价格、金币扣除和售罄状态。
- 已实现宝箱系统：普通宝箱、高级宝箱、武器宝箱、治疗补给宝箱、Boss 奖励宝箱、可配置掉落池、宝箱开启奖励和 Boss 宝箱开启后通关结算；普通宝箱默认稳定提供金币加少量回血，武器房提供一把可替换武器，治疗补给房提供回血且不提前注入金币，避免商店前经济断档。
- 已实现统一交互键：商店购买和宝箱开启需要靠近后按 `E`，避免接触误触。
- 已完成第一轮自动化数值平衡：开局/精英波次、商店价格、Boss 血量和自然进店金币范围已有 `BalanceSmokeTest` 约束。
- 已实现遗物系统、遗物拾取、遗物 3 选 1 面板和 HUD 遗物显示。
- 已实现 40 个遗物，覆盖伤害、射速、多弹丸、贯穿、暴击、换弹、生命、击杀回血、清房护甲、受伤加速、元素状态、近战挡弹、蓄力、部署物、额外弹跳、爆炸半径、击退倍率、弹匣容量和最大能量等构筑方向。
- 遗物效果已覆盖伤害、射速、多弹丸、穿透、暴击率、换弹速度、生命上限、击杀回血、清房护盾、受伤加速、状态概率、状态伤害、状态持续时间、挡弹半径、挡弹角度、挡弹反制伤害、蓄力伤害、蓄力速度、蓄力额外弹丸、部署物伤害和部署物持续时间。
- 已实现遗物掉落表资源化：奖励房、商店、普通宝箱、高级宝箱和 Boss 宝箱分别使用 `.tres` 配置来源池与稀有度权重。
- 暴击命中已有独立反馈：更大的橙红色命中特效、额外暴击音效、更强屏幕震动和 `CRIT` 浮字。
- 已实现金币奖励、护盾、回血、临时加速、玩家受击反馈、敌人受击闪烁、死亡特效、枪口闪光、屏幕震动和关键战斗浮字。
- 已实现攻击预警反馈：精英死亡爆炸预警、Boss 阶段转换预警、Boss 环形弹幕预警、Boss 瞄准齐射预警、Boss 地面危险区预警和延迟伤害/发射。

### 最近自动验证结果

- `DungeonGenerationSmokeTest.tscn`：通过。
- `ChallengeRoomSmokeTest.tscn`：通过。
- `TalentSmokeTest.tscn`：通过。
- `HallArchiveSmokeTest.tscn`：通过。
- `LobbyScreenSmokeTest.tscn`：通过。
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
- Windows release `.exe` 自动 headless 启动：通过，使用 `Start-Process -Wait` 执行 `--headless --quit` 返回 `ExitCode=0`；完整窗口模式手感、音频和节奏仍需人工运行复核。
- Windows 试玩 zip 包生成：通过。
- `res://` 静态引用检查：通过。
- `.tscn` / `.tres` `load_steps` 格式检查：通过。
- 本轮新增局外永久货币和角色熟练度后复测：`HallArchiveSmokeTest.tscn`、`RunSummarySmokeTest.tscn`、`ContentPipelineSmokeTest.tscn`、`CharacterSmokeTest.tscn`、`MenuFlowSmokeTest.tscn`、`UILayoutSmokeTest.tscn`、`FullRunSmokeTest.tscn` 和 `Main.tscn` 无头启动均通过；当前 Godot 4.7 控制台版需要带 `--log-file` 和 `--quit-after` 才能稳定定位 headless 场景问题，否则测试脚本未退出时会留下后台进程。

### 当前主要未完成项

- Boss 战仍是原型级，已有阶段转换、基础预警、地面危险区和结算统计，但尚未完成最终 Boss 战演出、场地设计和数值调优。
- 房间布局资源数量已达到开发计划第 11 阶段建议的 20+ 门槛，当前单局已扩展为可种子复现的三层 39-45 房间变量分支路线；但仍是 1 个原型房间场景配合数据布局，尚未完成 20 到 30 个独立房间实例或正式 TileMap 房间模板。
- 主流程 UI 仍是原型级，设置菜单已包含 Master/SFX/Music/Resolution/Fullscreen 和核心键位重绑定，并已有 1280x720 / 1600x900 / 1920x1080 基础布局烟测，但尚未支持手柄提示、更完整的显示/音频选项、鼠标/武器槽重绑定和正式视觉层级。
- 商店和宝箱系统仍是原型级，已有第一轮自动化经济约束，但尚未完成实机手感平衡和掉落权重可视化配置。
- 遗物候选已按稀有度权重随机，并在选择面板展示稀有度颜色和效果标签；奖励房、商店和宝箱已有资源化来源级掉落池与权重，但尚未实现保底规则和正式图标/特效。
- 精英死亡爆炸已有基础预警圈，但视觉仍是原型级。
- UI 仍是原型级，占位文本和基础控件较多；结算面板已分组，但仍缺少图标、动画和正式视觉层级。
- 局外大厅已有 `Outpost Hall` 独立场景骨架、图鉴/记录入口、分页图鉴、角色详情文本页、武器/遗物/天赋详情文本页、Featured Card 文本详情卡、CodexDetailCard Control 详情卡、详情卡徽标/稀有度色条、Build 路线筛选、搜索/排序/稀有度筛选、永久货币、角色熟练度、角色解锁消费 UI、训练房入口、训练靶场布局、训练 drill 引导、训练目标类型、drill 完成目标、drill 评级、训练徽章记录、训练徽章 token 展示和极轻量熟练度加成第一版，但还没有正式图标素材、多卡片详情布局或完整教程化训练奖励演出。
- 浮字反馈已覆盖伤害、暴击、治疗、护盾获取和护盾吸收；结算面板已统计暴击次数、治疗量和护盾吸收量，但还没有图标或伤害类型细分。
- 仍未接入正式美术、正式音频素材、代码签名和外部分发页面。

## 2026-07-02 类元气骑士内容管线第一批执行

### 目标

- 从“最终构建为类元气骑士体验”的方案开始执行第一块：先补齐角色、武器、遗物等内容资源的元数据接口，为后续三层地牢、局外大厅、解锁、天赋/祝福和更大内容池做准备。
- 本轮不改变现有战斗闭环、不新增正式玩法内容，重点是建立后续扩内容时的资源规范和自动校验。

### 新增和修改内容

- `WeaponData` 新增稀有度、武器分类、推荐距离、掉落权重、解锁 ID、内容定位、辅助瞄准权重、图标 key、音效 key 和弹道表现 key。
- `RelicData` 新增触发事件、掉落权重、解锁 ID、描述数值模板、Build 标签和互斥标签。
- `PlayerCharacterData` 新增角色排序、解锁条件、初始武器 ID、被动 ID、被动说明、大厅摘要、角色定位标签和升级槽数量。
- 现有 8 把武器、10 个遗物和 3 个角色资源已补齐第一版元数据。
- 新增 `RunGraphData`、`BiomeData`、`UnlockData`、`TalentData` 和 `AimAssistController`，作为后续三层地牢、主题层、局外解锁、本局天赋和辅助瞄准的接口基础。
- 新增 `ContentPipelineSmokeTest`，校验内容资源的最小元数据完整性，并验证辅助瞄准接口的目标选择和方向混合行为。

### 自动验证结果

```text
ContentPipelineSmokeTest passed.
WeaponSmokeTest passed.
RelicSmokeTest passed.
CharacterSmokeTest passed.
Main.tscn Godot CLI headless startup passed.
```

### 备注

- 本轮在 Codex 沙箱内运行 Godot 会在项目加载前触发访问冲突；提权运行同一命令可通过，因此本轮 Godot 验证均使用提权运行完成。
- 元数据中的视觉和音频字段暂时使用 key，不引用尚未存在的 `res://art` 或 `res://audio` 资产路径，避免导入器追踪缺失资源。

### 推荐手动验证重点

- 从 `Main.tscn` 启动后，确认玩家移动、瞄准、射击、换武器和换弹手感。
- 依次推进当前 seed 生成的三层 39-45 个房间，确认每层主路线、分支、门锁、波次、奖励、武器房、治疗补给房、陷阱房、遗物选择、商店消费和小地图分层状态。
- 在首个精英房确认精英敌人更耐打、伤害更高，并且死亡爆炸能正确伤害玩家或消耗护盾。
- 在最终 Boss 房确认 Boss 血条、二阶段、阶段转换、地面危险区、弹幕、召唤、死亡和 `RUN COMPLETE` 提示。
- 确认启动后先进入主菜单，开始新局后可用 Esc 暂停，死亡和通关都会进入结算面板。
- 确认死亡和通关结算面板会展示本局武器、遗物、金币收支、伤害、奖励、宝箱、商店购买和历史记录。
- 确认主菜单和暂停菜单都能打开 Settings，音量/全屏修改后重启仍保留。
- 确认 Settings 的 Master/SFX/Music/Resolution/Fullscreen 和核心键位修改后重启仍保留。
- 确认 HUD 右下角输入提示在常见窗口尺寸下不遮挡核心战斗区域。
- 在商店房确认金币能购买回血、遗物和武器，购买后商品显示售罄且金币减少。
- 确认事件房必须按 `E` 才会触发，生命不足时不会消耗或领奖；触发后会扣 1 点生命、发放金币并打开遗物选择。
- 确认普通战斗房生成普通宝箱、精英房生成高级宝箱、Boss 死亡后生成 Boss 奖励宝箱；前两层 Boss 宝箱只给奖励不通关，最终层 Boss 宝箱进入通关结算。
- 确认商店商品和宝箱靠近时不会自动触发，必须按 `E` 才会购买或开启。
- 确认精英死亡爆炸和 Boss 弹幕在伤害/发射前有红色危险预警。
- 选择事件触发型遗物后，确认击杀回血、清房护盾、受伤加速都能在实际游玩中触发。

## 2026-07-02 三层 RunGraph 第一批执行

### 目标

- 把内容管线里新增的 `RunGraphData` 和 `BiomeData` 接入实际地牢生成，让单局从单层 12-15 房间路线升级为接近同类 Roguelike 结构的三层路线。
- 保留现有房间生态、经济窗口和奖励流程，先解决层级结构、分层元数据、Boss 结算门槛和自动化契约。

### 新增和修改内容

- 新增 `resources/biomes/outer_warrens.tres`、`iron_catacombs.tres`、`void_foundry.tres`，分别配置显示名、房间数量范围、分支数量范围、敌人池、Boss 场景和主题 key。
- 新增 `resources/run_graphs/standard_run.tres`，默认由 3 个 biome 组成标准三层路线。
- `DungeonController` 默认按 RunGraph 生成 3 个连续 biome；每层 7-9 个主线房间、5-6 个分支房间，总路线约 36-45 个房间。
- 房间记录新增 `run_graph_id`、`biome_index`、`biome_id`、`biome_name`、`biome_main_path_index`、`enemy_pool`、`is_biome_start`、`is_biome_boss`、`is_final_boss` 和 `boss_reward_completes_run`。
- `CombatRoom` 新增 `complete_run_on_reward`，中间 biome 的 Boss 宝箱不会触发 `run_completed`，最终 biome 的 Boss 宝箱才进入 Victory。
- HUD 小地图按 biome 插入 `L1`、`L2`、`L3` 标签，Debug Map 输出 biome 摘要，结算摘要新增已到达 biome、总 biome、击败 Boss 数和历史最佳 biome。
- `DungeonGenerationSmokeTest`、`FullRunSmokeTest` 和 `BalanceSmokeTest` 升级为三层路线验证；完整通关测试现在会穿过所有 biome，并断言只有最终 Boss 奖励结束跑局。

### 自动验证结果

```text
DungeonGenerationSmokeTest passed.
BalanceSmokeTest passed.
FullRunSmokeTest passed.
```

### 备注

- 本轮仍沿用原型房间场景和布局资源，三层差异目前主要体现在 biome 元数据、敌人池和路线结构；正式视觉主题、专属 Boss 机制和层级音乐仍待后续补齐。
- Godot CLI 在当前 Codex 沙箱内仍会原生崩溃；本轮 Godot 验证继续使用提权 headless 运行完成。

## 2026-07-02 事件房第一批执行

### 目标

- 在三层 RunGraph 基础上补齐第一类事件房，让特殊分支不再只有奖励、商店、武器房和治疗补给房。
- 先实现一个可测试的原创风险收益事件，不引入复杂剧情或正式 UI，确保它能进入房间生成、奖励领取、结算统计和完整通关流程。

### 新增和修改内容

- `RoomData` 新增 `event` 房间类型。
- 新增 `resources/rooms/event_room.tres`，使用 `shrine` 布局和 `EventShrine` 奖励场景。
- 新增 `scenes/events/EventShrine.tscn` 和 `scripts/events/EventShrine.gd`。当前事件为 `Blood Pact`：玩家必须按 `E` 触发，消耗 1 点生命，获得金币和一次遗物选择；触碰不会自动触发，生命不足时拒绝触发。
- `Player.gd` 新增 `sacrifice_health()` 和 `can_sacrifice_health()`，用于不穿过护甲的事件代价。
- `Events.gd` 新增 `special_event_resolved`；`Main.gd` 记录 `events_resolved`，HUD 结算 Loot 分组显示 Events 数量。
- `DungeonController` 每个 biome 分支池加入一个事件房，小地图使用 `!` 标记事件房。
- 新增 `EventRoomSmokeTest`，并扩展 `DungeonGenerationSmokeTest`、`FullRunSmokeTest`、`EnemyVarietySmokeTest`、`RoomFlowSmokeTest`、`RunSummarySmokeTest` 和 `ContentPipelineSmokeTest`。

### 自动验证结果

```text
EventRoomSmokeTest passed.
DungeonGenerationSmokeTest passed.
FullRunSmokeTest passed.
RunSummarySmokeTest passed.
BalanceSmokeTest passed.
EnemyVarietySmokeTest passed.
ContentPipelineSmokeTest passed.
RoomFlowSmokeTest passed.
ChestSmokeTest passed.
Main.tscn Godot CLI headless startup passed.
```

### 备注

- 当前事件房只有一个事件模板，定位是机制入口和测试管线；挑战房第一版已经落地，后续应继续补陷阱房、更多挑战变体，以及更多事件结果和事件权重。
- 事件房目前复用遗物选择 UI，没有做专属事件选择面板；这符合第一批目标，但后续大厅/图鉴和事件内容扩展前应补正式事件 UI。
## 2026-07-02 挑战房第一批执行
### 目标

- 在事件房之后继续扩展特殊房间生态，先补一类可战斗、可奖励、可测试的高风险分支房。
- 保持当前三层 36-45 房间路线范围不变：每个 biome 仍为 5-6 个分支，只有当该层生成第 6 个分支时优先加入挑战房，避免强行拉长单局。

### 新增和修改内容
- `RoomData` 新增 `challenge` 房间类型，并扩展 `layout_profile` 枚举以覆盖当前 22 个布局资源。
- 新增 `resources/rooms/challenge_room.tres`，使用 `PrototypeCombatRoom`、`gauntlet` 初始布局、高级宝箱奖励、两波 `4/6` 敌人和精英化敌人倍率。
- `DungeonController` 新增 `CHALLENGE_ROOM_DATA`、挑战房布局池、RunGraph 分支接入、Debug Map `T` 标记和 biome 敌人池继承；当分支数为 6 时，挑战房作为第 6 个特殊分支优先出现。
- `RunGraphData` 和 `standard_run.tres` 的 `required_room_types` 加入 `challenge`，`ContentPipelineSmokeTest` 同步校验该房型声明。
- HUD 小地图新增挑战房 `T` 标记和橙色未探索颜色；`Main.gd` 为挑战房清房奖励增加 20 金币。
- 新增 `ChallengeRoomSmokeTest`，覆盖挑战房进入战斗、两波精英敌人、清房、高级宝箱打开和房间奖励领取状态；`FullRunSmokeTest`、`BalanceSmokeTest` 同步把 `challenge` 当战斗房处理。

### 自动验证结果

```text
ChallengeRoomSmokeTest passed.
ContentPipelineSmokeTest passed.
DungeonGenerationSmokeTest passed.
FullRunSmokeTest passed.
BalanceSmokeTest passed.
RoomFlowSmokeTest passed.
EventRoomSmokeTest passed.
EnemyVarietySmokeTest passed.
```

### 备注

- 当前挑战房是第一版风险收益机制：只有一种规则，没有挑战词条、倒计时、陷阱或多奖励选择；后续应扩展为多模板、多难度、多奖励池。
- 为了保持路线长度稳定，本轮没有让每层必出挑战房；后续如果实测需要更稳定的挑战节奏，可以把 `branch_count_min` 提到 6 或加入 RunGraph 级别的“全局至少一个挑战房”约束。

## 2026-07-02 Boss 后天赋选择第一批执行
### 目标

- 在三层 Boss 推进基础上补齐第一版“Boss 后成长选择”，让中间 biome Boss 不只是掉落宝箱，也能改变后续 Build。
- 先实现本局 run-scoped 天赋，不引入局外永久成长、复杂祝福剧情或正式图标 UI。

### 新增和修改内容
- 新增 `scripts/talents/TalentSystem.gd`，负责抽取、获得、记录和应用本局天赋；当前天赋效果复用玩家已有的被动数值接口。
- 新增 `resources/talents/steady_hands.tres`、`kinetic_rounds.tres`、`iron_vow.tres`，分别提供射速、伤害和生命上限方向的第一版天赋。
- `Events.gd` 新增 `talent_choice_requested`、`talent_choice_selected`、`talent_collected` 和 `talents_changed` 信号。
- `Main.tscn` 新增 `TalentSystem` 节点；`Main.gd` 在非最终 Boss 宝箱打开后弹出 3 选 1 天赋，最终 Boss 宝箱仍直接进入通关结算。
- HUD 复用原 3 选 1 面板，新增 `show_talent_choices()` 和 `choose_talent_for_test()`；结算 Build 分组新增 Talents 列表。
- `ContentPipelineSmokeTest` 新增天赋资源完整性校验；`FullRunSmokeTest` 断言完整 run 会从非最终 Boss 获取天赋。
- 新增 `TalentSmokeTest`，覆盖 Boss 后天赋请求、HUD 选择面板、天赋获得、玩家属性变化、结算字段和最终 Boss 不再给额外天赋。

### 自动验证结果

```text
TalentSmokeTest passed.
ContentPipelineSmokeTest passed.
FullRunSmokeTest passed.
RoomFlowSmokeTest passed.
RunSummarySmokeTest passed.
BalanceSmokeTest passed.
```

### 备注

- 当前天赋池只有 3 个、全是被动 run-scoped 数值效果；后续应扩展到元素、护甲、近战、召唤、金币和低血等 Build 路线。
- 当前仍复用遗物选择面板，没有正式天赋/祝福图标、专属音效或 Boss 后演出；后续 UI polish 时需要拆出更清晰的天赋面板。

## 2026-07-02 局外大厅图鉴/记录入口第一批执行

### 目标

- 在已有主菜单基础上补齐第一版“战斗外大厅”入口，让玩家在开局前能查看长期记录和当前内容池。
- 本轮先做图鉴/记录面板，不引入永久货币、角色解锁数值或训练房，避免在基础内容池还在快速扩张时过早绑定成长规则。

### 新增和修改内容

- `Main.gd` 新增 `get_hall_summary()`、`open_hall_menu()` 和 `close_hall_menu()`，统一汇总历史记录、角色、武器、遗物和天赋资源。
- `HUD.gd` 在主菜单动态加入 `Archive / Records` 按钮，并新增 `Hall Archive` 面板，展示历史记录、角色技能/属性、武器类型/能量消耗、遗物和天赋摘要。
- Hall Archive 复用现有设置/结算面板的响应式约束；打开该面板时隐藏右下角输入提示，关闭后回到主菜单。
- 新增 `HallArchiveSmokeTest`，覆盖图鉴资源计数、面板文本、主菜单返回，以及完成一局后历史记录持久化并在重新加载后读回。

### 自动验证结果

```text
HallArchiveSmokeTest passed.
MenuFlowSmokeTest passed.
RunSummarySmokeTest passed.
UILayoutSmokeTest passed.
ContentPipelineSmokeTest passed.
FullRunSmokeTest exited with code 0.
Main.tscn Godot CLI headless startup passed.
```

### 备注

- 当前 Hall Archive 是主菜单内的局外大厅第一版，不是正式独立大厅场景；后续应在此基础上加入图鉴过滤、角色详情页、正式训练场景和更完整的视觉层级。
- 当前图鉴直接展示全部已配置内容资源，尚未区分“已发现/未发现”或“已解锁/未解锁”。

## 2026-07-02 局外永久货币与角色熟练度第一批执行

### 目标

- 在 Hall Archive 基础上补上第一版轻量长期结构，让通关或失败后的局外成长有可持久化载体。
- 保持局内金币和局外资源分离：局内 `Gold` 仍只用于单局商店，局外 `Data Shards` 只保存在 meta progression 中，不参与单局购买和平衡。

### 新增和修改内容

- `PlayerCharacterData` 新增 `meta_currency_unlock_cost`、`mastery_level_2_xp` 和 `mastery_level_3_xp`，为后续角色解锁和熟练度阈值做资源化准备。
- `Main.gd` 新增 meta progression 状态：`Data Shards`、累计获得量、角色熟练度 XP 和角色解锁标记，并保存到 `user://settings.cfg` 的 `meta`、`mastery` 和 `character_unlocks` 分组。
- Run 结算时根据到达 biome、清房数、击杀数、Boss 数和胜利状态发放 `Data Shards`，并给当前角色增加熟练度 XP。
- 结算摘要和 Record 分组新增本局获得的永久货币和熟练度 XP；Hall Archive 新增 Meta Progress 区域，并在角色列表显示解锁状态和 Mastery 等级/XP。
- 新增 `unlock_character(character_id)` API，当前 3 个角色仍保持默认解锁，后续可接入锁定角色和消费按钮。
- `HallArchiveSmokeTest` 新增局外货币、熟练度、持久化读回和局内金币隔离断言；`RunSummarySmokeTest` 新增结算面板 meta 奖励断言。

### 自动验证结果

```text
HallArchiveSmokeTest passed.
RunSummarySmokeTest passed.
ContentPipelineSmokeTest passed.
CharacterSmokeTest passed.
MenuFlowSmokeTest passed.
UILayoutSmokeTest passed.
FullRunSmokeTest exited with code 0.
Main.tscn Godot CLI headless startup passed.
```

### 备注

- 当时 meta progression 只记录货币和熟练度，不提供实质数值加成；后续已补极轻量熟练度加成，并继续控制数值膨胀。
- 当时角色解锁 API 已存在但还没有正式消费 UI；本轮后续已接入锁定角色、购买按钮和选择限制。

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

## 2026-07-01 类元气骑士武器形态第一批扩展

### 目标

- 延续公开参考中同类游戏依赖大量武器差异形成单局变化的方向，把当前武器系统从“普通弹丸参数差异”推进到“开火形态差异”。
- 本轮新增原创占位武器和通用武器模式，不复制《元气骑士》的具体武器名称、外观或数值。

### 新增内容

- `WeaponData.gd` 新增 `fire_mode` 字段，支持 `projectile`、`radial`、`melee`。
- `Weapon.gd` 新增环形发射逻辑，支持围绕玩家发射完整一圈弹幕。
- `Weapon.gd` 新增近战扇形扫击逻辑，命中范围内敌人但不生成弹丸。
- 新增 `Arc Blade`：近战扇形武器，低消耗自保。
- 新增 `Nova Core`：环形弹幕武器，适合被包围时清场。
- 新增 `Blast Launcher`：爆炸弹丸武器，适合惩罚聚集敌人。
- 新增 `Laser Lance`：高速高穿透弹丸，适合走位拉直线。
- 宝箱和商店武器池加入新增武器。

### 自动验证结果

```text
Godot headless project startup passed.
WeaponSmokeTest passed.
CharacterSmokeTest passed.
MenuFlowSmokeTest passed.
RunSummarySmokeTest passed.
SettingsSmokeTest passed.
UILayoutSmokeTest passed.
RelicSmokeTest passed.
RoomFlowSmokeTest passed.
CombatFeedbackSmokeTest passed.
EnemyVarietySmokeTest passed.
BossSmokeTest passed.
FullRunSmokeTest passed.
RuntimeRoomSpawnCheck passed: first_room_state=2 enemies=2 expected_wave=2 nearest_enemy_distance=359.0
Windows release export passed.
Exported exe RuntimeRoomSpawnCheck passed: first_room_state=2 enemies=2 expected_wave=2 nearest_enemy_distance=434.1
Windows prototype zip regenerated: E:\Dungeon Unleashed\dungeon-unleashed\builds\Dungeon_Unleashed_Windows_Prototype.zip
```

### 仍需人工复核

- 在宝箱或商店中获得新增武器后，确认近战、环形、爆炸和贯穿武器的实战手感有明显差异。
- 重点观察 `Arc Blade` 的近战范围是否清晰，后续可能需要增加专属挥砍视觉。
- 重点观察 `Nova Core` 是否过强或过弱，后续需要结合敌人包围密度调数值。

## 2026-07-02 局外角色解锁消费 UI 与第四角色

### 目标

- 在已有 Data Shards 和角色解锁存档结构上补齐主菜单消费解锁闭环。
- 新增一个默认锁定的原创角色，验证“预览锁定角色 -> 完成 run 获得永久货币 -> 消费解锁 -> 解锁后开局”的完整流程。

### 新增内容

- 新增 `Rift Runner` 角色资源，定位为高速低护甲机动型角色，解锁成本为 10 Data Shards。
- `Player.gd` 的角色池扩展为 4 个角色：`Wanderer`、`Warden`、`Arcanist`、`Rift Runner`。
- 主菜单允许预览锁定角色，但锁定角色会禁用开始按钮；直接调用开始流程时也会被 `Main.start_new_run()` 拦截。
- HUD 新增动态 `UnlockCharacterButton`，永久货币不足时禁用，足够时可调用 `Main.unlock_selected_character()` 消费解锁。
- `get_character_selection_summary()` 增加 `unlocked`、`unlock_cost` 和 `meta_currency` 字段，供测试和后续大厅详情 UI 复用。

### 自动验证结果

```text
HallArchiveSmokeTest passed.
CharacterSmokeTest passed.
ContentPipelineSmokeTest passed.
MenuFlowSmokeTest passed.
RunSummarySmokeTest passed.
UILayoutSmokeTest passed.
FullRunSmokeTest exited with code 0.
Main.tscn Godot headless startup passed.
```

### 仍需人工复核

- 在窗口模式下确认主菜单新增解锁按钮的位置、禁用状态和提示是否清晰。
- 完整试玩至少两局，确认 Data Shards 解锁节奏不会太快或太慢。
- 后续需要补独立大厅场景和角色详情页，让解锁不只依赖主菜单文字按钮。

## 2026-07-02 训练房入口第一版

### 目标

- 在正式独立大厅场景完成前，先提供一个主菜单可进入的练习入口。
- 训练房用于练习已解锁角色的移动、武器、能量、护甲和主动技能，不应污染正式 Run 的历史、结算或永久货币。

### 新增内容

- `Main.gd` 新增 `Training` 状态和 `start_training_room()` 入口。
- 主菜单 HUD 新增 `Training Room` 按钮，锁定角色选中时会随 Start 一起禁用。
- 训练入口复用当前起始房和已选角色；进入训练会隐藏主菜单、解除暂停并显示 Training 状态。
- `pause_run()` / `resume_run()` 会记住暂停前状态，训练中暂停后能恢复到 `Training`，不会误变成正式 `Running`。
- 训练中触发 `Events.run_completed` 会被忽略，不会进入 Victory、不会暂停、不会写历史或发放 Data Shards。
- 新增 `TrainingRoomSmokeTest`，覆盖训练入口、锁定角色拦截、练习敌人生成、训练暂停恢复和进度隔离。

### 自动验证结果

```text
TrainingRoomSmokeTest passed.
```

### 仍需人工复核

- 窗口模式进入 Training Room，确认按钮位置和主菜单布局没有拥挤。
- 实际练习移动、射击、换武器、技能和能量消耗，确认训练房节奏适合新玩家熟悉操作。
- 后续需要在第一版训练靶场布局基础上继续补更完整的目标类型、操作引导和正式视觉表现。

## 2026-07-02 训练假人与伤害统计第一版

### 目标

- 让训练房不只是进入一间房，而是能提供可重复打击的目标和基础伤害反馈。
- 继续保持训练与正式 Run 隔离，不产生金币、房间清理、历史记录或永久货币收益。

### 新增内容

- 新增 `TrainingDummy` 场景和脚本，假人实现 `apply_damage()`、`is_dead()` 和 `can_deal_contact_damage()`，可被现有子弹和近战扫击命中。
- 训练假人加入 `training_dummy` 组和普通敌人碰撞层，但不会死亡、不会掉落、不会触发房间清理。
- `Main.gd` 在进入 Training 时生成假人，并在命中假人时统计 `hits`、`damage`、`best_hit`。
- HUD 新增训练统计面板，显示 `Hits / Damage / Best`，并提供 `Reset Training` 按钮。
- `reset_training_room()` 会清零训练统计、补满当前角色资源，并重新生成训练假人。
- `TrainingRoomSmokeTest` 扩展为覆盖假人生成、伤害统计、HUD 显示和训练重置。

### 自动验证结果

```text
TrainingRoomSmokeTest passed.
```

### 仍需人工复核

- 实机确认训练假人在窗口模式下的位置是否清晰，是否容易被玩家第一时间发现。
- 用不同武器命中假人，确认子弹、近战、暴击和能量消耗反馈足够直观。
- 后续可继续增加移动靶、护盾靶、Boss 招式练习靶和更细的 DPS/暴击率统计。

## 2026-07-02 角色熟练度轻量加成第一版

### 目标

- 让角色熟练度从“只记录 XP”推进到“有可见但克制的长期成长”。
- 加成必须足够轻，避免破坏单局 Roguelite 的武器/遗物/天赋 Build 权重。

### 新增内容

- 熟练度 L2 提供 `+1 Energy`，L3 额外提供 `+1 Armor`。
- `Player.gd` 新增 `apply_meta_stat_bonus()`，用于在基础角色属性上叠加局外成长。
- `Main.gd` 根据存档里的 mastery 等级应用当前角色加成，并在角色切换、重载和训练重置时重新应用。
- `get_character_selection_summary()` 增加 `mastery_level`、`mastery_xp` 和 `mastery_bonus`。
- `get_meta_progression_summary()` 增加 `character_mastery_bonuses`，为后续独立大厅角色详情页复用。
- 主菜单角色说明会在 L2+ 显示 Mastery 加成，Hall Archive 角色列表新增 `Bonus` 字段。
- 新增 `MasteryBonusSmokeTest`，覆盖多局结算升级、存档重载、属性应用、主菜单说明和 Hall Archive 展示。

### 自动验证结果

```text
MasteryBonusSmokeTest passed.
```

### 仍需人工复核

- 长线试玩中观察 `+1 Energy` / `+1 Armor` 是否过弱或过强；当前刻意保持低膨胀。
- 当前 Chars 页已显示下一等级所需 XP、下一等级奖励和文本进度条；后续需要把这批文本升级为更清晰的详情卡和正式视觉进度条。
- 若后续加入雕像/祝福系统，需避免与熟练度加成叠加成永久数值膨胀。

## 2026-07-02 独立 Outpost Hall 大厅骨架第一版

### 目标

- 把局外大厅从 HUD 内部动态拼出来的档案弹窗，推进到独立可扩展场景。
- 保留现有主流程接口，让后续角色详情页、图鉴分页、训练入口和设置入口可以继续在大厅场景内扩展。

### 新增内容

- 新增 `LobbyScreen.tscn` 和 `LobbyScreen.gd`，作为第一版 Outpost Hall 场景骨架。
- `HUD.gd` 继续暴露 `open_hall_menu()`、`get_hall_summary_text()` 等旧接口，但实际实例化并显示 `LobbyScreen`。
- Outpost Hall 显示当前角色摘要、锁定/可用状态、Data Shards 和内容计数，并复用原 Hall Archive 文本展示历史记录、角色、武器、遗物和天赋。
- Outpost Hall 新增 `Start Run`、`Training`、`Settings`、`Back` 动作入口；锁定角色会同步禁用开局和训练入口。
- 新增 `LobbyScreenSmokeTest`，覆盖大厅场景实例化、档案显示、锁定角色禁用、从大厅进入设置、训练房和正式 Run。

### 自动验证结果

```text
LobbyScreenSmokeTest passed.
HallArchiveSmokeTest passed.
MenuFlowSmokeTest passed.
TrainingRoomSmokeTest passed.
MasteryBonusSmokeTest passed.
```

### 仍需人工复核

- 窗口模式打开 Outpost Hall，确认快速统计、动作按钮和档案滚动区在 720p/1080p 下没有拥挤。
- 后续需要把当前第一版文本分页升级为角色详情、图鉴详情和下一熟练度奖励预览。
- 训练房已有第一版靶场布局、多目标训练假人和 drill 切换，后续应在 Outpost Hall 内补更正式的训练入口展示、更多目标类型和训练结果反馈。

## 2026-07-02 Outpost Hall 分页与角色操作第一版

### 目标

- 让 Outpost Hall 不只是一个独立弹窗，而是开始承担正式大厅职责：角色选择、角色解锁、历史统计和图鉴分页。
- 保留默认完整档案页，兼容现有 `HallArchiveSmokeTest` 和旧的 `get_hall_summary_text()` 测试接口。

### 新增内容

- `LobbyScreen` 新增 `All`、`Records`、`Chars`、`Weapons`、`Relics`、`Talents` 分页按钮。
- 默认 `All` 页仍显示完整旧档案；其他分页只显示对应内容，避免武器、遗物、天赋混在一个长文本列表里。
- `LobbyScreen` 新增 `Previous`、`Next`、`Unlock` 角色操作按钮，可以在大厅内切换角色、查看锁定状态，并在 Data Shards 足够时直接解锁。
- `HUD.gd` 新增大厅内角色操作信号接线和测试读接口，包括当前分页、当前角色文本、解锁按钮文本和解锁按钮禁用状态。
- `Main.gd` 新增 `refresh_hall_menu()`，大厅内切换或解锁角色后会刷新摘要，避免解锁状态和永久货币显示滞后。
- `LobbyScreenSmokeTest` 扩展为覆盖分页切换、分页内容隔离、大厅内选中 Rift Runner、货币不足禁用解锁、完成一局获得 Data Shards 后在大厅内解锁 Rift Runner。

### 自动验证结果

```text
LobbyScreenSmokeTest passed.
HallArchiveSmokeTest passed.
MenuFlowSmokeTest passed.
TrainingRoomSmokeTest passed.
MasteryBonusSmokeTest passed.
UILayoutSmokeTest passed.
Main.tscn headless startup exited with code 0.
```

### 仍需人工复核

- 窗口模式检查 Outpost Hall 新增按钮在 1280x720 下是否仍然清晰，不与档案滚动区挤压。
- 后续应把当前 `Chars` 文本详情升级为正式详情卡，加入图标、筛选和更清晰的视觉进度条。
- 后续应给武器、遗物、天赋分页补筛选、排序和详情卡，不再只依赖文本列表。

## 2026-07-02 Chars 页角色详情与成长预览第一版

### 目标

- 把 Outpost Hall 的 `Chars` 页从单行角色列表推进到可用的角色详情预览。
- 让玩家在大厅中能提前看到下一熟练度目标和奖励，避免只在升级后才知道长期成长内容。

### 新增内容

- `Main.get_hall_summary()` 的角色摘要新增大厅摘要、初始武器 ID/显示名、被动说明、技能冷却/持续/能量消耗、升级槽、下一熟练度等级、所需 XP、剩余 XP 和下一奖励。
- 新增增量熟练度奖励计算：L1 -> L2 显示 `+1 Energy`，L2 -> L3 显示 `+1 Armor`，L3 显示 `Maxed`。
- `LobbyScreen` 的 `Chars` 页保留原列表首行，并追加 `Role`、`Starting Weapons`、`Passive`、`Skill Detail`、`Next Mastery` 和 `Upgrade Slots`。
- 当前选中角色在 `Chars` 页标记为 `Selected`，与大厅内 `Previous` / `Next` 操作保持对应。
- `LobbyScreenSmokeTest` 扩展为覆盖初始武器、被动、下一熟练度 XP、下一奖励和升级槽显示。

### 自动验证结果

```text
LobbyScreenSmokeTest passed.
HallArchiveSmokeTest passed.
MasteryBonusSmokeTest passed.
MenuFlowSmokeTest passed.
TrainingRoomSmokeTest passed.
UILayoutSmokeTest passed.
Main.tscn headless startup exited with code 0.
```

### 仍需人工复核

- 窗口模式检查 `Chars` 页详情文本在 1280x720 下是否过密，必要时拆成卡片或双栏。
- 当前已经有文本进度条和满级状态；后续应升级为正式 UI 进度条和更清晰的满级视觉状态。
- 后续应把武器、遗物、天赋分页也升级为详情卡，不再只依赖文本列表。

## 2026-07-02 角色熟练度进度预览第一版

### 目标

- 让大厅角色详情不只显示“下一等级需要多少 XP”，还要显示当前处于本段进度的哪个位置。
- 明确区分当前已获得奖励和下一等级奖励，降低玩家误读累计奖励的概率。

### 新增内容

- `Main.get_hall_summary()` 的角色摘要新增熟练度段起点、段内当前 XP、段内目标 XP 和段内百分比。
- `LobbyScreen` 的 `Chars` 页新增 `Mastery Progress` 文本进度条，例如 `[------------] 0/40 XP to L2 (0%)`。
- `LobbyScreen` 的 `Chars` 页新增 `Mastery Rewards`，显示 `Current` 与 `Next` 奖励对比。
- 满级角色会显示 `Mastery Progress: Maxed`、`Next Mastery: Maxed` 和 `Next Maxed`。
- `LobbyScreenSmokeTest` 扩展为覆盖未升级进度条、当前/下一奖励对比，以及四局结算后的 L3 满级状态。

### 自动验证结果

```text
LobbyScreenSmokeTest passed.
HallArchiveSmokeTest passed.
MasteryBonusSmokeTest passed.
MenuFlowSmokeTest passed.
TrainingRoomSmokeTest passed.
UILayoutSmokeTest passed.
Main.tscn headless startup exited with code 0.
```

### 仍需人工复核

- 窗口模式检查文本进度条在不同分辨率下是否清晰，必要时改成真实 `ProgressBar`。
- 后续应将角色详情拆为卡片布局，避免 `Chars` 页随着角色数量增加变得过长。

## 2026-07-02 图鉴详情与 Build 路线摘要第一版

### 目标

- 让 `Weapons`、`Relics`、`Talents` 分页从“只列名称和简介”推进到能辅助构筑判断的详情文本页。
- 先复用现有 Outpost Hall 文本区，补齐数据字段和测试契约，为后续正式筛选、排序和详情卡留出稳定数据入口。

### 新增内容

- `Main.get_hall_summary()` 的武器摘要新增掉落权重、内容定位、伤害、射速、多弹丸、散射、开火模式、弹匣、换弹、暴击、贯穿、弹跳和爆炸半径等字段。
- `Main.get_hall_summary()` 的遗物摘要新增效果数值、持续时间、掉落权重、是否可堆叠、最大层数和互斥标签。
- `Main.get_hall_summary()` 的天赋摘要新增触发事件、效果类型、效果数值、持续时间、掉落权重和互斥标签。
- `LobbyScreen` 的武器、遗物、天赋分页新增 `Build Routes` 汇总，按标签统计当前内容池的构筑方向覆盖。
- 武器分页追加 `Stats` 和 `Traits` 详情行；遗物分页追加 `Effect` 和 `Stacking` 详情行；天赋分页追加 `Effect` 和 `Conflicts` 详情行。
- `LobbyScreenSmokeTest` 扩展为覆盖 Build 路线摘要、武器属性行、遗物效果/堆叠行和天赋效果/互斥行。

### 自动验证结果

```text
LobbyScreenSmokeTest passed.
HallArchiveSmokeTest passed.
MenuFlowSmokeTest passed.
MasteryBonusSmokeTest passed.
TrainingRoomSmokeTest passed.
UILayoutSmokeTest passed.
Main.tscn headless startup exited with code 0.
```

### 仍需人工复核

- 窗口模式检查武器、遗物、天赋分页文本在 1280x720 下是否过密，必要时拆成卡片或双栏。
- 后续应加入筛选、排序、图标、稀有度视觉和正式详情卡，而不是长期依赖文本列表。

## 2026-07-02 图鉴 Build 路线筛选第一版

### 目标

- 让 Outpost Hall 的武器、遗物、天赋图鉴开始具备“按构筑路线查找内容”的能力，而不是只能滚动浏览完整文本列表。
- 先按现有资源标签实现稳定的 Build 路线筛选，为后续稀有度筛选、排序、搜索和正式详情卡做铺垫。

### 新增内容

- `LobbyScreen.tscn` 新增 `CodexFilterRow`，包含上一条路线、当前路线、下一条路线和恢复 All 的控件。
- `LobbyScreen.gd` 新增分页独立的筛选状态：`Weapons` 使用武器 `tags`，`Relics` 和 `Talents` 使用 `build_tags`。
- 图鉴文本新增 `Filter` 行和显示数量，例如 `Filter: Close Range (2/8 shown)`。
- `All` 总览页仍显示完整内容，不受当前单页筛选影响；`Records` 和 `Chars` 页会隐藏筛选控件。
- `LobbyScreenSmokeTest` 补充筛选契约：武器 `close_range` 显示 Arc Blade/Shotgun、遗物 `projectile` 显示 Sharp Rounds、天赋 `survival` 显示 Iron Vow，并验证无关条目被隐藏。

### 验证状态

```text
Static inspection completed for LobbyScreen node paths and filter flow.
Godot CLI smoke tests were not executed in this pass because the environment rejected the Godot command with a usage-limit error.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `LobbyScreenSmokeTest.tscn`、`HallArchiveSmokeTest.tscn`、`MenuFlowSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 窗口模式检查新增筛选行在 1280x720 下是否挤压标题或滚动文本；如有拥挤，下一步应缩短按钮文案或改成图标按钮。

## 2026-07-02 Vertical Slice 2 内容池扩容第一步

### 目标

- 向 `Vertical Slice 2` 的内容目标推进：先把武器池从 8 把补到 12 把，把遗物池从 10 个补到 18 个。
- 本轮只使用现有数据字段和效果类型，不新增战斗机制，避免内容扩容同时引入高风险系统改动。

### 新增内容

- 新增 4 把原创武器资源：
  - `Coil Carbine`：中距离精准弹跳 sidearm。
  - `Shatter Fan`：近距离宽角霰射 burst 武器。
  - `Rift Spear`：有额外触及距离的近战突刺。
  - `Orbit Sower`：低频高耗能的环形控场 core。
- 新增 8 个原创遗物资源：
  - `Keen Sights`、`Hollow Needle`、`Scatter Lens`、`Field Rations`。
  - `Bulwark Plate`、`Redline Boots`、`Breach Powder`、`Momentum Coil`。
- `RewardChest`、`ShopInventory` 和 `BossRewardChest` 已接入新增武器池。
- `RelicSystem.available_relics` 与 `reward`、`shop`、`normal_chest`、`premium_chest`、`boss_chest` 5 个遗物掉落表已接入新增遗物。
- `ContentPipelineSmokeTest` 的武器/遗物数量门槛提升为 12 / 18，并加入新增资源 ID 存在性检查。
- `HallArchiveSmokeTest` 的大厅摘要数量门槛提升为 12 / 18，并检查新增武器与遗物会出现在图鉴文本中。

### 验证状态

```text
Static resource count check: 12 weapons, 18 relics.
Static res:// ext_resource path check: all referenced paths resolved.
git diff --check passed with CRLF warnings only.
Godot CLI smoke tests were not executed in this pass because the previous environment attempt was rejected with a usage-limit error.
```

## 2026-07-03 蓄力武器链路第一版

### 目标

- 在 24 武器 / 30 遗物基础上继续推进 Alpha 内容池，下一个稳定门槛提升到 27 武器 / 33 遗物。
- 补齐方案中“蓄力武器”这一类高风险高回报开火形态，让武器池不只依赖射速、散射、状态和近战防守差异。

### 新增和修改内容

- `WeaponData.gd` 新增 `charge` 开火模式，以及 `charge_duration`、`charge_damage_multiplier`、`charge_projectile_speed_multiplier` 和 `charge_projectile_count_bonus` 字段。
- `Weapon.gd` 新增按住开火蓄力、松开发射、取消蓄力、蓄力比例查询和蓄力额外弹丸结算；蓄力期间不消耗弹药/能量，松开后统一结算弹药、能量、冷却和事件。
- `Player.gd` 在 `shoot` 松开时调用 `release_charge()`，并接入 3 类蓄力遗物加成：`charge_damage_multiplier`、`charge_speed_multiplier` 和 `charge_projectile_count_bonus`。
- `Projectile.gd` 的 `launch()` 支持可选蓄力比例，按比例放大弹丸伤害和速度；普通武器继续以默认比例发射，不改变旧武器行为。
- 新增 3 把原创蓄力武器：
  - `Coil Bow`：精准长距蓄力侧重，满蓄力提高单发伤害和弹速。
  - `Storm Capacitor`：蓄力散射核心，满蓄力释放多发弹幕。
  - `Vault Lance`：传奇长距贯穿蓄力激光，定位为高能耗长线清场。
- 新增 3 个原创蓄力遗物：
  - `Draw Weight`：提高蓄力伤害倍率。
  - `Quick Windup`：提高蓄力速度。
  - `Stored Spark`：满蓄力额外释放弹丸。
- `RewardChest`、`ShopInventory`、Boss 宝箱、`RelicSystem.available_relics` 和 5 个遗物掉落表已接入新增武器/遗物。
- `Main.get_hall_summary()` 和 `LobbyScreen` 的武器详情页已展示 `Charge` 字段，图鉴筛选可以按 `charge` 路线找到新增内容。
- `ContentPipelineSmokeTest` 的武器/遗物数量门槛提升为 27 / 33，并校验 `charge` 开火模式、蓄力字段和 `charge` 标签。
- `WeaponSmokeTest` 新增 `Coil Bow` 按住/松开发射断言；`RelicSmokeTest` 新增 3 个蓄力遗物加成断言；`HallArchiveSmokeTest` 和 `LobbyScreenSmokeTest` 同步到新内容计数与图鉴显示契约。

### 验证状态

```text
git diff --check: exit 0, only existing LF-to-CRLF warnings for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Static resource count check: 27 weapons, 33 relics.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
Static charge resource reference check: new charge weapon and relic IDs are referenced from content pools or smoke tests.
Godot CLI smoke tests were not executed in this pass because the previous environment attempt was rejected with a usage-limit error.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`WeaponSmokeTest.tscn`、`RelicSmokeTest.tscn`、`HallArchiveSmokeTest.tscn`、`LobbyScreenSmokeTest.tscn`、`ShopSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察蓄力期间的读条/反馈缺失是否影响理解、`Storm Capacitor` 满蓄力弹丸数量是否过强、`Vault Lance` 能耗和发射节奏是否足够有取舍，以及蓄力遗物叠加后是否压过普通伤害/射速路线。

## 2026-07-03 部署/陷阱武器链路第一版

### 目标

- 在 27 武器 / 33 遗物基础上补齐 Alpha 下限内容池，稳定推进到 30 武器 / 35 遗物。
- 增加一类不同于弹丸、近战和蓄力的轻量部署玩法，让玩家可以用临时场地装置制造控场、延迟爆发和区域压制。

### 新增和修改内容

- `WeaponData.gd` 新增 `deployable` 开火模式，以及部署物持续时间、半径、tick 间隔、预热时间和伤害倍率字段。
- `Weapon.gd` 新增部署物生成路径；部署位置会按目标点和武器射程夹取，并复用现有弹药、能量、冷却和开火事件结算。
- 新增 `DeployableTrap.tscn` / `DeployableTrap.gd`，作为轻量部署运行时：定时扫描半径内敌人，造成伤害、应用状态效果，并记录最近命中数和总命中数元数据。
- 新增 3 把原创部署武器：
  - `Snare Beacon`：减速控场信标，偏向安全站位和拖慢追击。
  - `Ember Mine`：短持续燃烧地雷，偏向延迟爆发。
  - `Sentry Seed`：长半径轻召唤核心，偏向持续节奏压制。
- 新增 2 个原创部署遗物：
  - `Tripwire Amplifier`：提高部署物伤害。
  - `Anchor Spool`：延长部署物持续时间。
- `Player.gd`、`RelicData.gd` 和 `RelicSystem.gd` 接入部署物伤害/持续时间加成；`RewardChest`、`ShopInventory`、Boss 宝箱和 5 个遗物掉落表已接入新增内容。
- `Main.get_hall_summary()` 和 `LobbyScreen` 的武器详情页已展示 `Deploy` 字段，图鉴筛选可以按 `deployable` 路线找到新增武器/遗物。
- `ContentPipelineSmokeTest`、`WeaponSmokeTest`、`RelicSmokeTest`、`HallArchiveSmokeTest` 和 `LobbyScreenSmokeTest` 已同步到 30 武器 / 35 遗物和部署物契约。

### 验证状态

```text
git diff --check: exit 0, only existing LF-to-CRLF warnings for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Static resource count check: 30 weapons, 35 relics.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
Static deployable resource reference check: new deployable weapon and relic IDs are referenced from content pools or smoke tests.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`WeaponSmokeTest.tscn`、`RelicSmokeTest.tscn`、`HallArchiveSmokeTest.tscn`、`LobbyScreenSmokeTest.tscn`、`ShopSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察部署物可读性、敌人站在边缘时的命中反馈、`Ember Mine` 是否过于像普通爆炸武器、`Sentry Seed` 是否需要更像随从而不是大范围陷阱，以及部署遗物叠加后是否压过直接射击路线。

## 2026-07-03 Outpost Hall 图鉴检索与排序第一版

### 目标

- 在已有分页图鉴和 Build 路线筛选基础上，补齐第一版“查找和整理内容池”的能力。
- 让武器、遗物、天赋和祝福页在内容池继续扩张后仍可快速按名称/标签/描述搜索，按稀有度缩小范围，并按名称、稀有度或掉落权重排序。

### 新增和修改内容

- `LobbyScreen.tscn` 新增 `CodexRefinementRow`，包含搜索输入、排序切换、稀有度切换和重置按钮；只在武器/遗物/天赋/祝福页显示，角色页和记录页隐藏。
- `LobbyScreen.gd` 保留原有 `Route` Build 路线筛选，并叠加搜索、稀有度和排序 refinement。
- 搜索会匹配 id、显示名、描述、稀有度、武器分类、推荐距离、内容定位、开火模式、触发事件、效果类型、持续范围、规则文本和标签数组。
- 排序支持 `Name`、`Rarity` 和 `Drop Weight`；稀有度排序按高稀有度优先，掉落权重排序按权重高优先。
- 图鉴页会显示 `Refine: Rarity ... | Search ... | Sort ...` 摘要，方便玩家确认当前列表为什么被缩小。
- `LobbyScreenSmokeTest` 已扩展为覆盖 refinement 控件显示/隐藏、默认状态、部署武器掉落权重排序、武器搜索、武器稀有度筛选、遗物稀有度筛选和遗物搜索。

### 验证状态

```text
git diff --check: exit 0, only existing LF-to-CRLF warnings for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
Static codex refinement reference check: LobbyScreen scene nodes, script APIs, and smoke-test calls are all referenced.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `LobbyScreenSmokeTest.tscn`、`HallArchiveSmokeTest.tscn`、`ContentPipelineSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察新增 refinement 行在 720p 下是否挤压正文区域、搜索输入是否容易理解、排序切换是否需要更明确的下拉菜单，以及稀有度筛选是否应和 Build 路线筛选拆成更正式的详情卡工具栏。

## 2026-07-02 角色池扩展到 6 个第一版

### 目标

- 向 Alpha 目标中的 6 个原创角色推进，同时保持当前角色切换、解锁、熟练度和大厅详情链路不变。
- 只新增两个轻量技能分支，不引入复杂召唤、宠物或全新状态系统，降低未运行 Godot 回归时的风险。

### 新增内容

- 新增 `Emberwright`：爆发输出角色，解锁成本 18 Data Shards，技能 `Overdrive Spark` 短时间提高伤害和射速。
- 新增 `Field Medic`：稳定续航角色，解锁成本 22 Data Shards，技能 `Stabilize` 恢复生命并补少量护甲。
- `PlayerCharacterData` 的 `skill_id` 枚举新增 `overdrive` 和 `stabilize`。
- `Player.gd` 的角色池新增两个角色，并在 `_apply_skill_effect()` 中实现两个新技能分支。
- `CharacterSmokeTest` 扩展为验证 6 角色总数、Rift Runner 锁定、新角色顺序、Emberwright 的伤害/射速增益和 Field Medic 的回血/护甲恢复。
- `ContentPipelineSmokeTest` 的角色数量门槛提升为 6，并检查 6 个角色 ID 均存在。
- `HallArchiveSmokeTest` 的角色数量门槛提升为 6，并检查大厅图鉴能列出 Emberwright 与 Field Medic。

### 验证状态

```text
Static character count check: 6 character resources.
Static character reference check: new character IDs and skill IDs are present in resources, `Player.gd`, `CharacterSmokeTest`, `ContentPipelineSmokeTest` and `HallArchiveSmokeTest`.
Static `res://` reference check: all `.tres` / `.tscn` external resource paths resolved.
`git diff --check` passed with CRLF warnings only.
Godot CLI smoke tests were not executed in this pass because the previous environment attempt was rejected with a usage-limit error.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `CharacterSmokeTest.tscn`、`ContentPipelineSmokeTest.tscn`、`HallArchiveSmokeTest.tscn`、`LobbyScreenSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应检查 Emberwright 的爆发窗口是否过强、Field Medic 是否让路线容错过高，以及两个锁定角色在大厅切换/解锁 UI 中是否清晰。

## 2026-07-02 三层 Boss 变体第一版

### 目标

- 向 Alpha 目标中的 3 个主线 Boss 推进，让三层地牢不再全部复用同一个 `Dungeon Core` 场景。
- 本批仍复用 `BossEnemy.gd` 的二阶段、预警、环形弹幕、瞄准齐射、召唤和奖励流程，只通过独立场景资源拉开显示名、数值、召唤对象、弹幕密度和视觉配色，降低回归风险。

### 新增内容

- 新增 `WarrensGatekeeper.tscn`：Outer Warrens 层尾 Boss，血量较低、移动更快、弹幕更克制，作为第一层读招入口。
- 新增 `IronBulwark.tscn`：Iron Catacombs 层尾 Boss，血量更高、移动更慢、召唤护盾敌人，强调站位压力。
- 新增 `VoidFoundryHeart.tscn`：Void Foundry 最终 Boss，血量和弹幕密度更高，保留 Chaser 召唤以覆盖最终 Boss 召唤测试。
- 三个 `BiomeData` 资源已改为引用各自 Boss 场景；`DungeonController` 的生成记录现在能把三个 Boss 场景映射为正确显示名。
- `ContentPipelineSmokeTest` 新增 Biome/Boss 校验，检查 3 个 biome、各自 Boss 场景、Boss 显示名唯一性和基础数值。
- `DungeonGenerationSmokeTest` 新增三层 Boss 名称顺序断言，确认生成记录中依次出现 `Warrens Gatekeeper`、`Iron Bulwark`、`Void Foundry Heart`。
- `EnemyVarietySmokeTest` 和 `BossSmokeTest` 已从单一 `Dungeon Core` 断言更新为新的第一层/最终层 Boss 契约。

### 验证状态

```text
Static Boss scene count check: 3 biome-specific boss scenes.
Static Boss reference check: biome resources, DungeonController and smoke tests reference the three new Boss names.
Static `res://` reference check: all `.tres` / `.tscn` external resource paths resolved.
`git diff --check` passed with CRLF warnings only.
Godot CLI smoke tests were not executed in this pass because the previous environment attempt was rejected with a usage-limit error.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`DungeonGenerationSmokeTest.tscn`、`EnemyVarietySmokeTest.tscn`、`BossSmokeTest.tscn`、`FullRunSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点检查 Iron Bulwark 召唤护盾敌人是否过度拖慢节奏，以及 Void Foundry Heart 的弹幕密度和最终 Boss 生命值是否仍能在当前 12 武器 / 18 遗物池下稳定击杀。

## 2026-07-02 陷阱房第一版

### 目标

- 继续补齐类同类 Roguelite 的特殊房间生态，让路线里不只有奖励、商店、事件、武器房、治疗补给房和挑战房。
- 第一版陷阱房只做“可读预警 + 生存计时 + 小额奖励”，不引入复杂机关编辑器或 TileMap 机关层，降低对当前原型房间场景的侵入。

### 新增内容

- `RoomData` 新增 `trap` 房间类型。
- 新增 `resources/rooms/trap_room.tres`，复用 `PrototypeCombatRoom` 和 `diagonal_blocks` 布局，奖励为普通宝箱。
- `CombatRoom.gd` 新增 trap 专用危险循环：进房后进入 Combat、锁门、按固定节奏生成 `DangerWarning` 地面危险圈，存活 `trap_survival_duration` 后清房、解锁并生成奖励。
- `DungeonController` 新增 `TRAP_ROOM_DATA`、trap 布局池、Debug Map `X` 标记和生成接入；当前每层固定 6 个分支，第 6 分支在挑战房与陷阱房之间按 biome 交替。
- HUD 小地图新增 trap 的 `X` 标记和橙红色未探索颜色；`Main.gd` 为 trap 清房奖励增加 10 金币。
- 新增 `TrapRoomSmokeTest`，并扩展 `DungeonGenerationSmokeTest`、`EnemyVarietySmokeTest`、`RoomFlowSmokeTest`、`FullRunSmokeTest`、`BalanceSmokeTest` 和 `ContentPipelineSmokeTest` 的 trap 契约。

### 验证状态

```text
Static trap resource/reference check: `trap_room.tres`, `TrapRoomSmokeTest.gd` and `TrapRoomSmokeTest.tscn` exist and are referenced.
Static `res://` reference check: all `.tres` / `.tscn` external resource paths resolved.
`git diff --check` passed with CRLF warnings only.
Godot CLI smoke tests were not executed in this pass because the previous environment attempt was rejected with a usage-limit error.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `TrapRoomSmokeTest.tscn`、`DungeonGenerationSmokeTest.tscn`、`RoomFlowSmokeTest.tscn`、`FullRunSmokeTest.tscn`、`BalanceSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应检查陷阱预警是否足够明显、安全站位是否可读、2.4 秒生存时间是否太短，以及每层固定 6 个分支是否让单局节奏过长。

## 2026-07-02 事件祝福第一版

### 目标

- 把方案中的 `BlessingData` 从空缺推进到可运行的第一版，让事件房不只给金币和遗物，而是形成“献祭换本局规则”的独立奖励层。
- 第一版只做 3 个被动祝福和事件房三选一，不引入雕像、花园、长期解锁或复杂触发器，降低对现有战斗闭环的风险。

### 新增内容

- 新增 `BlessingData.gd` 和 `BlessingSystem.gd`，祝福支持稀有度、持续范围、触发事件、效果类型、数值、Build 标签、互斥标签和规则说明。
- 新增 3 个事件祝福资源：`Deep Cell` 增加能量上限、`Quiet Plate` 增加护甲上限、`Ember Tithe` 提高武器伤害。
- `EventShrine` 的 `Blood Pact` 现在优先请求祝福三选一；没有可选祝福时仍保留遗物选择回退。
- HUD 三选一面板新增 `Choose a Blessing` 类型，支持祝福格式、tooltip、测试选择接口和选择信号。
- `Main` 接入 BlessingSystem、祝福 pending 选择、奖励结算、run summary 的 `blessing_count` / `blessing_names`，并把祝福纳入 Outpost Hall 内容摘要。
- `LobbyScreen` 新增 `Blessings` 图鉴分页，支持 Build Routes、Effect、Rule 和按 `build_tags` 筛选。
- `Player.apply_relic_effect()` 扩展 `max_energy` 和 `max_shield`，让祝福能真实改变本局属性。
- `ContentPipelineSmokeTest`、`EventRoomSmokeTest`、`FullRunSmokeTest`、`RunSummarySmokeTest`、`HallArchiveSmokeTest` 和 `LobbyScreenSmokeTest` 已同步到祝福契约。

### 验证状态

```text
Static blessing resource/reference check completed for BlessingData, BlessingSystem, three blessing resources, Main scene wiring, HUD choice flow, event shrine flow and updated smoke tests.
Static `res://` reference check completed for newly added blessing paths.
Godot CLI smoke tests were not executed in this pass because the previous environment attempt was rejected with a usage-limit error.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`EventRoomSmokeTest.tscn`、`FullRunSmokeTest.tscn`、`RunSummarySmokeTest.tscn`、`HallArchiveSmokeTest.tscn`、`LobbyScreenSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点检查事件房从遗物奖励切到祝福奖励后，路线收益是否仍清晰，`Deep Cell` 的能量上限、`Quiet Plate` 的护甲上限和 `Ember Tithe` 的伤害加成是否过强。

## 2026-07-02 可选弱辅助瞄准接入

### 目标

- 把此前仅作为接口基础的 `AimAssistController` 接入真实玩家射击链路，向同类游戏常见的“移动端/手柄友好”瞄准体验靠拢。
- 保持默认关闭，避免影响当前鼠标精确瞄准；作为设置项逐步验证手感。

### 新增内容

- `Player.gd` 新增辅助瞄准控制器实例、设置同步接口和测试读取接口。
- 玩家开火和朝向现在统一走辅助后的目标点；关闭辅助时仍完全使用鼠标世界坐标。
- 候选目标来自 `enemies` 分组，并过滤无效、排队删除和已死亡目标。
- 实际辅助强度按当前武器的 `aim_assist_priority` 缩放，保留后续按武器手感调参的入口。
- `Main.gd` 新增 `aim_assist_enabled` / `aim_assist_strength` gameplay 设置，支持加载、保存、摘要导出和玩家同步。
- HUD Settings 面板新增 `Aim Assist` 开关和强度滑条，Apply 会连同音量、全屏、分辨率一起保存。
- Settings 面板内容现在会移入内部滚动容器，避免新增设置项后在 720p 窗口中溢出。
- `SettingsSmokeTest` 扩展为验证默认关闭、应用、持久化、重载、UI 回显和玩家同步。
- 新增 `AimAssistSmokeTest`，验证关闭状态、有效目标选择、方向混合和辅助锥外目标过滤。

### 验证状态

```text
Static aim-assist reference check completed for Player, Main, HUD, SettingsSmokeTest and AimAssistSmokeTest.
Godot CLI smoke tests were not executed in this pass because the previous environment attempt was rejected with a usage-limit error.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `AimAssistSmokeTest.tscn`、`SettingsSmokeTest.tscn`、`ContentPipelineSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点检查默认关闭是否无手感变化、0.35 默认强度是否过强，以及散弹/近战/环形弹幕武器在开启辅助后是否仍符合预期。

## 2026-07-02 第二批普通敌人变体

### 目标

- 向 Alpha 目标中的更高敌人生态密度推进，把当前 6 个普通敌人基础行为扩展成 12 个可投放场景变体。
- 本轮不新增 Enemy 行为状态机分支，只通过现有追踪、远程、冲锋、自爆、召唤和护盾行为的参数化组合增加房间战斗差异，降低未跑 Godot 回归时的系统风险。

### 新增内容

- 新增 `RustSkirmisher.tscn`：快速近战追踪敌人，血量低、移动快，强化第一层贴身压力。
- 新增 `EmberMarksman.tscn`：更快射速和更高弹速的远程敌人，用于拉开基础 Shooter 的压制节奏。
- 新增 `IronBreaker.tscn`：高血量、高伤害、慢前摇的重型冲锋敌人，主要服务 Iron Catacombs 的站位压力。
- 新增 `VolatileVessel.tscn`：更快接近、更大爆炸半径的自爆敌人，用于 Void Foundry 的高压组合。
- 新增 `AegisDrone.tscn`：强化血量和正面护盾参数的护盾敌人，增加正面强攻成本。
- 新增 `RiftCaller.tscn`：召唤 `Rust Skirmisher` 的召唤型敌人，限制最大召唤数并提高最小召唤距离，避免贴脸生成。
- `outer_warrens.tres` 敌人池扩为 5 个，新增 `Rust Skirmisher` 和 `Ember Marksman`。
- `iron_catacombs.tres` 敌人池扩为 7 个，新增 `Iron Breaker` 和 `Aegis Drone`。
- `void_foundry.tres` 敌人池扩为 8 个，新增 `Ember Marksman`、`Volatile Vessel` 和 `Rift Caller`。
- `DungeonController.gd` 的 biome 敌人名称解析改为实例化场景读取 `display_name`，新增敌人场景后不再需要更新控制器硬编码映射。
- `ContentPipelineSmokeTest` 新增敌人场景库检查，覆盖 12 个普通敌人显示名、基础数值、行为类型和关键依赖资源。
- `EnemyVarietySmokeTest` 扩展三层 biome 敌人池断言，确认第一层包含轻快近战/远程变体，第二层包含重型冲锋/护盾变体，第三层包含自爆/召唤变体。

### 验证状态

```text
Static enemy scene/reference check completed for six new ordinary enemy variants and three biome pools.
Static `res://` reference check: all `.gd` / `.tscn` / `.tres` / `.godot` references resolved.
`git diff --check` passed with CRLF warnings only.
Godot CLI smoke tests were not executed in this pass because the previous environment attempt was rejected with a usage-limit error.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`EnemyVarietySmokeTest.tscn`、`DungeonGenerationSmokeTest.tscn`、`BalanceSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点检查新增远程敌人的弹速是否过高、Iron Breaker 的冲锋前摇是否足够可读、Volatile Vessel 的爆炸半径是否公平，以及 Rift Caller 在长战斗中是否仍可能造成召唤压力过大。

## 2026-07-02 Alpha 下限普通敌人池

### 目标

- 把普通敌人池从 12 个变体推进到 Alpha 目标下限的 18 个变体。
- 本轮不只新增参数差异，还补充可复用的敌人生态能力：散射弹幕、环绕移动、区域压制、支援治疗和死亡生成小怪。

### 新增通用能力

- `Enemy.gd` 的 `BehaviorType` 新增 `STRAFER`、`ZONER` 和 `SUPPORT`。
- 远程敌人新增 `projectile_count` 和 `projectile_spread_degrees`，支持散射弹幕源。
- 新增死亡生成配置：`death_spawn_scene`、`death_spawn_count` 和 `death_spawn_spacing`，用于死亡惩罚型敌人。
- `ZONER` 会在目标位置生成 `DangerWarning` 圆形危险区，伤害、半径和预警时间由敌人资源配置。
- `SUPPORT` 会周期性治疗范围内受伤敌人，形成明确的优先击杀目标。
- `STRAFER` 会围绕玩家侧向移动并射击，减少所有远程敌人都只后退站桩的问题。

### 新增敌人场景

- `NeedleSkater.tscn`：环绕射击敌人，加入 Outer Warrens 和 Void Foundry。
- `SootSplitter.tscn`：死亡后生成 2 个 `Rust Skirmisher`，加入 Outer Warrens。
- `MireConduit.tscn`：中层区域危险圈敌人，加入 Iron Catacombs。
- `GraveMender.tscn`：中层治疗支援敌人，加入 Iron Catacombs。
- `BarrageTotem.tscn`：终层低机动散射弹幕源，加入 Void Foundry。
- `NullAcolyte.tscn`：终层高威胁区域压制敌人，加入 Void Foundry。

### Biome 接入

- `outer_warrens.tres` 敌人池从 5 个扩到 7 个。
- `iron_catacombs.tres` 敌人池从 7 个扩到 9 个。
- `void_foundry.tres` 敌人池从 8 个扩到 11 个。
- 三层主题差异现在不仅体现在血量/速度参数上，也体现在死亡惩罚、支援、区域压制和弹幕源职责上。

### 验证状态

```text
Static enemy scene/reference check completed for 18 ordinary enemy display names.
ContentPipelineSmokeTest contract now requires at least 18 ordinary enemies and validates STRAFER/ZONER/SUPPORT/death-spawn fields.
EnemyVarietySmokeTest contract now covers barrage spread, zoner danger warnings, support healing and death-spawn minions.
Static `res://` reference check: all `.gd` / `.tscn` / `.tres` / `.godot` references resolved.
`git diff --check` passed with CRLF warnings only.
Godot CLI smoke tests were not executed in this pass because the previous environment attempt was rejected with a usage-limit error.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`EnemyVarietySmokeTest.tscn`、`DungeonGenerationSmokeTest.tscn`、`BalanceSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点检查 Needle Skater 是否过度绕圈导致难以命中，Soot Splitter 死亡生成是否拖慢清房，Mire Conduit / Null Acolyte 的危险圈是否足够可读，以及 Grave Mender 是否让护盾敌人和高血量敌人过于拖节奏。

## 2026-07-02 Alpha 下限精英修饰池

### 目标

- 补齐方案中 Alpha 阶段 `6-9` 种精英修饰的下限，让精英房不再只是“整房间统一倍率 + 死亡爆炸”。
- 保留旧的 `elite_health_multiplier` / `elite_damage_multiplier` fallback，避免破坏已有挑战房、平衡烟测和导出兼容链路。

### 新增内容

- 新增 `EliteModifierData.gd`，字段包括：
  - `id`、`display_name`、`name_prefix`、`description`
  - `role_tags`
  - `health_multiplier`、`damage_multiplier`
  - `move_speed_multiplier`、`attack_cooldown_multiplier`、`projectile_speed_multiplier`
  - `death_explosion_radius`、`death_explosion_damage`
  - `visual_color`、`scale_multiplier`
- 新增 6 个精英修饰资源：
  - `Blazing`：更高伤害、更快节奏和小范围死亡爆炸。
  - `Bulwark`：高血量、低移速的消耗型精英。
  - `Quickened`：高移速、短攻击间隔的压迫型精英。
  - `Volatile`：更大死亡爆炸和中等数值强化。
  - `Sharpshot`：更快攻击节奏和更高弹速，偏远程压力。
  - `Titan`：大体型、高血量、高伤害、慢速的重压型精英。
- `Enemy.gd` 新增 `apply_elite_profile(profile)`，并保留旧的 `apply_elite_modifiers(...)` 接口。
- 精英敌人现在会记录 `elite_modifier_id` 和 `elite_modifier_display_name`，便于烟测、结算或后续图鉴统计读取。
- `CombatRoom.gd` 新增 `elite_modifier_profiles`，精英房/挑战房会按波次和生成顺序轮换修饰。
- `RoomData.gd` 新增 `elite_modifier_profiles` 字段。
- `elite_room.tres` 和 `challenge_room.tres` 已接入 6 个标准精英修饰。
- `DungeonController.gd` 新增 6 个精英修饰 preload，并在 fallback room config 中写入标准精英池，保证导出包读取自定义 `RoomData` 不稳定时仍能使用修饰池。

### 验证状态

```text
ContentPipelineSmokeTest contract now validates at least 6 elite modifier resources and required ids.
EnemyVarietySmokeTest contract now verifies elite profile application and elite room modifier rotation.
ChallengeRoomSmokeTest contract now verifies challenge room modifier pool and per-wave rotation.
Static `res://` reference check: all `.gd` / `.tscn` / `.tres` / `.godot` references resolved.
`git diff --check` passed with CRLF warnings only.
Godot CLI smoke tests were not executed in this pass because the previous environment attempt was rejected with a usage-limit error.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`EnemyVarietySmokeTest.tscn`、`ChallengeRoomSmokeTest.tscn`、`BalanceSmokeTest.tscn`、`FullRunSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点检查 `Titan` / `Bulwark` 是否过度拖慢节奏，`Quickened` 是否造成不可解释贴脸伤害，`Sharpshot` 是否让远程敌人弹速过高，以及多种颜色缩放是否足够可读但不遮挡敌人形态。

## 2026-07-02 Alpha 内容池扩容第二步

### 目标

- 在 12 武器 / 18 遗物基础上继续推进 Alpha 内容池，下一个稳定门槛提升到 18 武器 / 24 遗物。
- 本轮仍只使用现有武器开火模式、武器字段和遗物效果类型，不新增战斗机制，降低未运行 Godot CLI 回归时的系统风险。

### 新增内容

- 新增 6 把原创武器资源：
  - `Pulse Needler`：中距离高速精准 sidearm，偏暴击路线。
  - `Cinder Mortar`：慢速高耗能 launcher，补充更重的爆炸区域压制。
  - `Mirror Sickle`：宽弧近战武器，补充近距离自保和清杂路线。
  - `Storm Fan`：高密度近距 shotgun，偏高风险爆发。
  - `Prism Ray`：长距高辅助优先级 laser，偏贯穿直线清场。
  - `Halo Kernel`：legendary core，释放高耗能环形控场弹幕。
- 新增 6 个原创遗物资源：
  - `Steady Capacitor`、`Gilded Tip`、`Echo Chamber`。
  - `Breakwater Guard`、`Siphon Clasp`、`Kinetic Ram`。
- `RewardChest`、`ShopInventory` 和 `BossRewardChest` 已接入新增武器池。
- `RelicSystem.available_relics` 与 `reward`、`shop`、`normal_chest`、`premium_chest`、`boss_chest` 5 个遗物掉落表已接入新增遗物。
- `ContentPipelineSmokeTest` 的武器/遗物数量门槛提升为 18 / 24，并加入新增资源 ID 存在性检查。
- `HallArchiveSmokeTest` 的大厅摘要数量门槛提升为 18 / 24，并检查新增武器与遗物会出现在图鉴文本中。

### 验证状态

```text
Static resource count check: 18 weapons, 24 relics.
Static new resource reference check: all second-pass weapon and relic IDs are referenced from content pools or smoke tests.
Static `res://` reference check: all `.gd` / `.tscn` / `.tres` / `.godot` references resolved.
`git diff --check` passed with CRLF warnings only.
Godot CLI smoke tests were not executed in this pass because the previous environment attempt was rejected with a usage-limit error.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`HallArchiveSmokeTest.tscn`、`LobbyScreenSmokeTest.tscn`、`RelicSmokeTest.tscn`、`ShopSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 `Halo Kernel` 和 `Storm Fan` 是否过强、`Cinder Mortar` 是否因弹速过慢而手感迟钝、`Echo Chamber` 与其他多弹丸遗物叠加后是否让弹幕密度过高。

## 2026-07-02 元素状态武器链路第一版

### 目标

- 在 18 武器 / 24 遗物基础上继续推进 Alpha 内容池，下一个稳定门槛提升到 21 武器 / 27 遗物。
- 这批不再只做参数差异，先落地一条轻量战斗交互链路：武器命中可挂燃烧或减速，遗物可以强化状态概率、状态伤害和状态持续时间。

### 新增内容

- `WeaponData` 新增状态字段：`status_effect`、`status_chance`、`status_duration`、`status_damage_per_tick`、`status_tick_interval` 和 `status_slow_multiplier`。
- `Projectile.gd` 和 `Weapon.gd` 已接入状态命中：弹丸直击、爆炸溅射和近战扫击都可以调用敌人的 `apply_status_effect(...)`。
- `Enemy.gd` 新增可复用状态容器，当前支持：
  - `burn`：按 tick 对敌人造成持续伤害。
  - `slow`：降低敌人行为移动速度，保留击退速度。
- `Player.gd`、`RelicData.gd` 和 `RelicSystem.gd` 接入 3 类状态遗物效果：`status_chance_bonus`、`status_damage_multiplier`、`status_duration_multiplier`。
- 新增 3 把原创状态武器：
  - `Ember Sprayer`：近距离散射燃烧。
  - `Frost Sickle`：近战扇形减速。
  - `Slag Comet`：爆炸燃烧，对聚集敌人有溅射收益。
- 新增 3 个原创状态遗物：
  - `Volatile Oil`：提高状态概率。
  - `Ember Catalyst`：提高状态伤害。
  - `Lingering Ash`：延长状态持续时间。
- `RewardChest`、`ShopInventory`、Boss 宝箱、`RelicSystem.available_relics` 和 5 个遗物掉落表已接入新增武器/遗物。
- `Main.get_hall_summary()` 和 `LobbyScreen` 的武器详情页已展示状态字段，图鉴筛选可以按 `elemental` / `status` 路线找到新增内容。
- `ContentPipelineSmokeTest` 的武器/遗物数量门槛提升为 21 / 27，并校验状态字段、状态资源 ID 和 burn/slow 参数完整性。
- `WeaponSmokeTest` 新增弹丸燃烧 tick 和近战减速断言；`RelicSmokeTest` 新增 3 个状态遗物加成断言；`HallArchiveSmokeTest` 和 `LobbyScreenSmokeTest` 同步到新内容计数与图鉴显示契约。

### 验证状态

```text
Static resource count check: 21 weapons, 27 relics.
Static status resource reference check: new status weapon and relic IDs are referenced from content pools or smoke tests.
Static `res://` reference check: all `.gd` / `.tscn` / `.tres` / `.godot` references resolved.
`git diff --check` passed with CRLF warnings only.
Godot CLI smoke tests were not executed in this pass because the previous environment attempt was rejected with a usage-limit error.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`WeaponSmokeTest.tscn`、`RelicSmokeTest.tscn`、`HallArchiveSmokeTest.tscn`、`LobbyScreenSmokeTest.tscn`、`ShopSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察燃烧 tick 是否过强、减速是否让近战武器过于安全、状态遗物叠加后是否压过普通伤害/射速路线，以及状态反馈缺少正式视觉时是否足够可读。

## 2026-07-03 近战挡弹武器链路第一版

### 目标

- 在 21 武器 / 27 遗物基础上继续推进 Alpha 内容池，下一个稳定门槛提升到 24 武器 / 30 遗物。
- 补齐方案中“近战挡弹”这一类武器形态，让近战武器不只是即时伤害，而能在弹幕压力下承担防守/反制职责。

### 新增内容

- `WeaponData` 新增挡弹字段：`blocks_projectiles`、`projectile_block_radius`、`projectile_block_arc_degrees` 和 `projectile_block_damage`。
- `Weapon.gd` 的近战扫击现在会扫描 `enemy_projectiles` 分组，按半径和角度清除前方敌方弹丸，并可对被挡弹丸附近敌人造成反制伤害。
- `Player.gd`、`RelicData.gd` 和 `RelicSystem.gd` 新增 3 类挡弹遗物加成：`projectile_block_radius_bonus`、`projectile_block_arc_bonus`、`projectile_block_damage_bonus`。
- 新增 3 把原创挡弹近战武器：
  - `Guard Cleaver`：基础防守近战，稳定清除前方弹丸。
  - `Riposte Saber`：窄角高节奏反制武器，挡弹反击更强。
  - `Bulwark Fan`：宽角防守武器，牺牲节奏换更大挡弹覆盖。
- 新增 3 个原创挡弹遗物：
  - `Parry Grip`：增加近战挡弹半径。
  - `Warding Hinge`：增加近战挡弹角度。
  - `Counterweight Core`：增加挡弹反制伤害。
- `RewardChest`、`ShopInventory`、Boss 宝箱、`RelicSystem.available_relics` 和 5 个遗物掉落表已接入新增武器/遗物。
- `Main.get_hall_summary()` 和 `LobbyScreen` 的武器详情页已展示 `Guard` 字段，图鉴筛选可以按 `guard` 路线找到新增挡弹武器/遗物。
- `ContentPipelineSmokeTest` 的武器/遗物数量门槛提升为 24 / 30，并校验挡弹字段和 `guard` 标签。
- `WeaponSmokeTest` 新增挡弹行为断言：前方敌方弹丸被清除、身后弹丸不受影响、挡弹反制伤害命中附近敌人。
- `RelicSmokeTest` 新增 3 个挡弹遗物加成断言；`HallArchiveSmokeTest` 和 `LobbyScreenSmokeTest` 同步到新内容计数与图鉴显示契约。

### 验证状态

```text
Static resource count check: 24 weapons, 30 relics.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static guard resource reference check: new guard weapon and relic IDs are referenced from content pools or smoke tests.
Godot CLI smoke tests were not executed in this pass because the previous environment attempt was rejected with a usage-limit error.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`WeaponSmokeTest.tscn`、`RelicSmokeTest.tscn`、`HallArchiveSmokeTest.tscn`、`LobbyScreenSmokeTest.tscn`、`EnemyVarietySmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察挡弹半径是否过宽、`Bulwark Fan` 是否让弹幕房过于安全、反制伤害是否压过普通近战伤害，以及缺少正式挥砍/格挡特效时玩家是否能读懂挡弹范围。

## 2026-07-03 训练靶场布局第一版

### 目标

- 把训练房从“进入起始房并生成单个假人”推进到第一版可识别的靶场布局。
- 让玩家进入训练后有稳定站位、近中远三个可打击目标和基础场地分区，为后续训练引导、目标类型选择和正式大厅训练入口做基础。

### 新增和修改内容

- `Main.gd` 将训练房目标从单个 `_training_dummy` 改为 `_training_dummies` 数组，并通过 `TRAINING_DRILLS` 的 `Basics` drill 固定生成第一组三个训练目标。
- 进入训练和重置训练时会调用 `_position_player_for_training()`，把玩家放到训练射击线并清零移动速度，避免复用起始房时站位漂移。
- `_reset_training_stats()` 新增 `targets` 统计字段，HUD 训练面板显示 `Targets / Hits / Damage / Best`。
- `training.tres` 新增安全柱和射击道标线障碍，训练房布局资源不再只是地面色与出生点。
- `TrainingRoomSmokeTest` 扩展为验证训练布局障碍、三目标数量、玩家训练站位、HUD 目标数、命中统计和重置后重新生成三个目标。

### 验证状态

```text
TrainingRoomSmokeTest contract now covers three target dummies, fixed firing-line placement, target-count HUD text, reset respawn, and training layout obstacles.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `TrainingRoomSmokeTest.tscn`、`LobbyScreenSmokeTest.tscn`、`ContentPipelineSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察三个训练目标是否在窗口内清晰可见、玩家初始站位是否合适、训练面板是否遮挡目标，以及安全柱/标线是否会误导玩家以为它们是正式关卡障碍。

## 2026-07-03 训练 drill 引导与目标类型第一版

### 目标

- 在三目标靶场基础上补第一版训练模式选择，让训练房不只验证伤害数字，也能按练习目标切换靶位。
- 保持训练仍然不写入正式 Run 历史、永久货币或角色熟练度。

### 新增和修改内容

- `Main.gd` 新增 `TRAINING_DRILLS`，当前包含 `Basics`、`Movement` 和 `Burst` 三种训练 drill。
- 每个 drill 都配置独立说明和三组训练目标位置/名称：基础距离对比、错位走位追踪、聚集爆发测试。
- 进入训练时默认回到 `Basics`；训练中 `cycle_training_drill()` 会切换到下一 drill、清零统计、重置玩家射击线并重新生成三目标。
- HUD 训练面板新增当前 drill 名称、简短练习目标和 `Next Drill` 按钮；`Reset Training` 保留当前 drill，只清空统计和重生目标。
- `TrainingRoomSmokeTest` 扩展为覆盖 Basics 起始状态、Movement 切换、目标名称变化、切换后统计清零、重置后保留当前 drill。

### 验证状态

```text
TrainingRoomSmokeTest contract now covers drill names, drill guidance, drill cycling, target name changes, stat reset on cycle, and reset preserving the active drill.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `TrainingRoomSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察训练面板在 720p 下是否遮挡靶子、三种 drill 的文字是否足够短，以及 Movement/Burst 靶位是否真的能帮助玩家理解走位和爆发窗口。

## 2026-07-03 Outpost Hall Featured Card 文本详情卡第一版

### 目标

- 在已有长文本图鉴上补第一版详情卡层级，让玩家进入武器、遗物、天赋和祝福页时先看到当前筛选结果的重点条目。
- 本轮先做文本结构，不重排 `LobbyScreen.tscn` 的 Control 树，降低在脏工作区中破坏大厅入口、筛选和搜索状态的风险。

### 新增和修改内容

- `LobbyScreen.gd` 新增 `_format_codex_featured_card()`，按页面类型生成 Featured Card。
- 武器卡聚合名称、稀有度、职业/距离、Build 标签、核心伤害/能量/射速/掉落权重，以及 Status、Guard、Charge、Deploy 特殊机制。
- 遗物卡聚合 Build 标签、触发条件、掉落权重、效果值、持续时间、堆叠规则和互斥标签。
- 天赋和祝福卡聚合作用范围、触发条件、效果值、持续时间、掉落权重和规则/互斥信息。
- Featured Card 跟随当前筛选、搜索、稀有度和排序后的第一项；`All` 总览页仍保持压缩摘要，避免大厅首页继续变长。
- `LobbyScreenSmokeTest` 扩展为覆盖武器/遗物/天赋/祝福 Featured Card、筛选后卡片跟随、搜索后卡片聚焦等契约。

### 验证状态

```text
LobbyScreenSmokeTest contract now covers codex Featured Cards for weapons, relics, talents, and blessings, including route-filtered and search-focused cards.
Static Featured Card contract check: LobbyScreen formatter and smoke-test assertions are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `LobbyScreenSmokeTest.tscn`、`HallArchiveSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 Featured Card 是否让图鉴页更容易浏览，是否在 720p 下挤压列表正文，以及后续如何与 CodexDetailCard 合并为稀有度色条、图标字段和多卡片布局。

## 2026-07-03 Outpost Hall CodexDetailCard Control 详情卡第一版

### 目标

- 将文本 Featured Card 推进为真正的 `Control` 卡片，让图鉴页不只依赖滚动文本列表表达重点条目。
- 先复用现有筛选、搜索、稀有度和排序状态，避免详情卡与正文列表出现不同步的第二套逻辑。

### 新增和修改内容

- `LobbyScreen.tscn` 在图鉴标题和正文滚动列表之间新增 `CodexDetailCard`，包含标题、元信息和正文三段 Label。
- `LobbyScreen.gd` 新增 `is_codex_detail_card_visible()`、`get_codex_detail_title_text()`、`get_codex_detail_meta_text()` 和 `get_codex_detail_body_text()`，供烟测和后续 UI 迭代读取。
- 新增 `_update_codex_detail_card()`，直接复用 `_refine_codex_entries()` 的结果，确保详情卡跟随 Route、搜索、稀有度和排序后的第一项。
- 武器详情卡显示稀有度、类型、距离、Build 标签、伤害、能量、射速、掉落权重和 Status / Guard / Charge / Deploy 机制；遗物、天赋和祝福详情卡显示触发、范围、效果、堆叠/规则和互斥。
- `LobbyScreenSmokeTest` 扩展为覆盖非图鉴页隐藏详情卡、武器/遗物/天赋/祝福页显示详情卡、筛选后标题跟随、搜索后标题聚焦和正文关键字段。

### 验证状态

```text
CodexDetailCard static contract check: scene node, script refresh/getter APIs, and smoke-test assertions are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `LobbyScreenSmokeTest.tscn`、`HallArchiveSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 `CodexDetailCard` 在 720p 下是否挤压列表正文、长标签是否换行合理，以及后续是否需要替换为正式图标素材和多卡片布局。

## 2026-07-03 Outpost Hall 详情卡徽标与稀有度色条第一版

### 目标

- 在已有 `CodexDetailCard` 上补第一版视觉信息层，让玩家不用阅读完整正文也能先识别条目类型和稀有度。
- 继续不引入外部美术素材，先用稳定的 UI 节点和文本徽标锁定数据流，为后续正式图标替换留入口。

### 新增和修改内容

- `LobbyScreen.tscn` 的 `CodexDetailCard` 顶部新增 `CodexDetailVisualRow`，包含稀有度色条、页面类型徽标和稀有度徽标。
- `LobbyScreen.gd` 新增 `get_codex_detail_icon_text()` 和 `get_codex_detail_rarity_badge_text()`，用于烟测确认视觉状态。
- 新增 `_set_codex_detail_visuals()`、`_get_codex_page_icon_token()` 和 `_get_codex_rarity_color()`，将 Weapons / Relics / Talents / Blessings 映射为短徽标，并将 Common / Rare / Epic / Legendary 映射为不同颜色。
- `CodexDetailCard` 标题颜色和稀有度徽标颜色会跟随当前聚焦条目的稀有度；筛选、搜索、稀有度过滤和排序变化后会同步刷新。
- `LobbyScreenSmokeTest` 扩展为覆盖 WPN / REL / TAL / BLS 徽标、Common / Rare / Epic 稀有度徽标，以及武器/遗物稀有度筛选后的详情卡标题同步。

### 验证状态

```text
CodexDetailCard visual contract check: visual row scene nodes, script getter/refresh APIs, and smoke-test assertions are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `LobbyScreenSmokeTest.tscn`、`HallArchiveSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察顶部徽标行在 720p 下是否过密、稀有度颜色是否可读，以及后续是否需要替换为正式图标素材、卡面边框和多卡片布局。

## 2026-07-03 训练目标类型与类型摘要第一版

### 目标

- 把训练房从“同一假人换位置和名称”推进到第一版可区分目标类型，让 Basics / Movement / Burst drill 的练习目标更接近实战职责。
- 保持武器和弹丸命中事件入口不变，只在训练假人侧计算有效伤害和 Burst 连击；本轮增加类型、视觉、轻量移动、护甲减伤、Burst 连击窗口和 HUD 摘要。

### 新增和修改内容

- `TrainingDummy.gd` 新增 `target_type`、`movement_axis`、`movement_distance` 和 `movement_speed`，并提供 `configure()` 与 `get_target_type()`。
- 训练假人会按 `standard`、`mobile`、`armored`、`burst` 显示不同颜色和标签；`mobile` 类型会按配置做轻量往返移动。
- `armored` 类型会按护甲倍率降低有效伤害，并记录 `last_applied_damage` 与 `mitigated_damage`；训练 HUD 统计改为优先使用目标报告的有效伤害。
- `burst` 类型会按 `burst_chain_window` 记录短时间连续命中的当前连击和最佳连击；HUD 在出现连击后显示 `Burst xN`。
- `TRAINING_DRILLS` 的目标数据新增类型：Basics 为 3 个 Standard；Movement 为 2 个 Mobile 和 1 个 Armored；Burst 为 2 个 Burst 和 1 个 Armored。
- `Main.gd` 的训练摘要新增 `target_types`，按当前 drill 汇总类型数量。
- HUD 训练面板新增 `Types ...` 摘要，例如 `Types Armored 1, Mobile 2`。
- `TrainingRoomSmokeTest` 扩展为覆盖 Basics / Movement / Burst 的目标类型分布、HUD 类型摘要、护甲靶有效伤害/减免量、Burst 快速连击、训练重置保留当前 drill 类型和目标数。

### 验证状态

```text
Training target type contract check: TrainingDummy type config, armored effective damage, burst chain window, drill target data, HUD type summary, and smoke-test assertions are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `TrainingRoomSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察移动靶速度是否可读、护甲靶减伤是否容易理解、Burst 连击窗口是否太宽或太窄、类型颜色是否和战斗中敌人/掉落颜色冲突，以及后续是否需要加入 Boss 前摇练习和限时挑战。

## 2026-07-03 训练 drill 目标与完成状态第一版

### 目标

- 让训练房不只显示当前 drill 的说明和统计，还明确告诉玩家本轮练习要完成什么。
- 先做无奖励的本地完成状态，避免训练房影响永久成长、历史记录或局内经济。

### 新增和修改内容

- `TRAINING_DRILLS` 新增 `goal_type`、`goal_text` 和 `goal_required`：Basics 目标是命中全部 3 个目标，Movement 目标是命中 2 个 mobile 目标，Burst 目标是打出 `Burst x2` 连击。
- `Main.gd` 新增训练目标进度状态，记录已命中的目标实例和按类型命中的目标实例，并按当前 drill 计算 `goal_progress` / `goal_required` / `goal_complete`。
- `HUD.gd` 训练面板新增独立 `Goal` 行，未完成时显示 `Goal: ... 0/N`，完成后显示 `Complete: ... N/N`。
- 重置训练会清空目标进度和完成状态，但保留当前 drill。
- `TrainingRoomSmokeTest` 扩展为覆盖 Basics / Movement / Burst 的目标文字、护甲靶不推进 mobile 目标、Burst x2 后完成目标，以及重置后目标状态清空。

### 验证状态

```text
Training drill goal contract check: drill goal data, progress tracking, HUD goal row, and smoke-test assertions are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `TrainingRoomSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察目标行是否过长、完成提示是否明显，以及后续是否要加入训练奖励或更正式的教程步骤。

## 2026-07-03 训练 drill 评级第一版

### 目标

- 在训练目标完成状态之上增加轻量评级，让玩家能看到本轮练习是否只是完成，还是用较少命中高效完成。
- 评级暂不发放奖励，不写入历史记录、局外货币、角色熟练度或局内经济，避免训练房和正式 run 的成长循环混在一起。

### 新增和修改内容

- `Main.gd` 的训练摘要新增 `rating_rank` 和 `rating_text`，当前规则为未完成显示 `Practice`，完成后显示 `Clear`，命中次数不超过目标要求时显示 `Clean`。
- `HUD.gd` 训练面板新增独立 `Rating` 行，并提供 `get_training_rating_text()` 供烟测读取。
- 重置训练会把评级恢复为 `Practice`，切换 drill 后也随统计清零同步恢复。
- `TrainingRoomSmokeTest` 扩展为覆盖 Basics 初始 `Practice`、Movement 未完成保持 `Practice`、Burst 高效完成后 `Clean`，以及重置后恢复 `Practice`。

### 验证状态

```text
Training drill rating contract check: summary rating fields, rating update helper, HUD rating row/getter, and smoke-test assertions are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `TrainingRoomSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察新增 `Rating` 行在 720p 下是否压缩训练面板按钮，`Clean` 判定是否过于严格，以及后续是否把训练反馈接入正式教程步骤或奖励演出。

## 2026-07-03 训练 drill 徽章记录第一版

### 目标

- 把训练评级推进为可回看的局外训练奖励，但仍不发放永久货币、角色熟练度或局内金币。
- 让 Outpost Hall 能展示每个 drill 的最佳训练徽章，为后续正式教程奖励、训练任务和视觉徽章素材预留数据入口。

### 新增和修改内容

- `Main.gd` 新增 `_training_drill_best_ratings`，每个 drill 只保存历史最佳评级；`Clear` 和 `Clean` 会解锁/升级训练徽章，`Practice` 不计入徽章。
- 训练完成目标后会立即尝试升级当前 drill 徽章，并写入 `settings.cfg` 的 `training` 分组；重启后可从 `get_meta_progression_summary()` 读回。
- `get_meta_progression_summary()` 新增 `training_drill_best_ratings`、`training_badge_count` 和 `training_badge_total`，与 Data Shards、角色熟练度和 run history 分离。
- `get_hall_summary()` 新增 `training_drills` 摘要；HUD 旧大厅文本和 `LobbyScreen.gd` 的 All / Records 页都会显示 `Training Badges X/3` 与各 drill 的 `Badge: ...`。
- 训练 HUD 的 `Rating` 行现在同时显示当前评级和历史最佳徽章，例如 `Rating: Practice | Best Clean`。
- `TrainingRoomSmokeTest` 扩展为覆盖 Burst Clean 徽章保存、训练徽章不发永久货币、重置后保留最佳徽章、重启 Main 后持久化读回和大厅显示。
- `HallArchiveSmokeTest` 与 `LobbyScreenSmokeTest` 扩展为覆盖 Fresh 档案的 `Training Badges (0/3)` 展示。

### 验证状态

```text
Training badge contract check: persistent best-rating storage, meta summary fields, hall text, LobbyScreen text, and smoke-test assertions are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `TrainingRoomSmokeTest.tscn`、`HallArchiveSmokeTest.tscn`、`LobbyScreenSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 `Rating: ... | Best ...` 是否过长、Outpost Hall 的 Training Badges 是否占用太多首页空间，以及后续是否需要将文字徽章替换为正式图标、动画和分 drill 奖励说明。

## 2026-07-03 训练徽章 token 与奖励提示第一版

### 目标

- 在训练徽章持久化基础上补第一版可见奖励提示，让玩家完成新徽章时不只看到普通 message，也能在训练面板中看到明确的 `Badge Unlocked` 行。
- 继续不引入正式图标素材，先用稳定 ASCII token 锁定 UI 和数据契约，后续可以替换成正式徽章图标。

### 新增和修改内容

- 训练徽章新增 token 映射：未获得为 `[--]`，`Clear` 为 `[CL]`，`Clean` 为 `[CN]`。
- `Main.gd` 的训练摘要新增 `best_rating_token` 与 `badge_notice_text`；首次获得或升级徽章时写入 `Badge Unlocked: Clean [CN]`。
- HUD 训练面板新增独立 Badge 行：平时显示 `Badge: Clean [CN]`，新徽章产生时显示 `Badge Unlocked: Clean [CN]`。
- Outpost Hall 旧文本摘要和 `LobbyScreen.gd` 的训练徽章列表会显示 `Badge: None [--]`、`Badge: Clear [CL]` 或 `Badge: Clean [CN]`。
- `TrainingRoomSmokeTest` 扩展为覆盖初始 `[--]`、完成后 `Badge Unlocked: Clean [CN]`、重置后 `Badge: Clean [CN]` 和大厅 `[CN]` 展示。
- `HallArchiveSmokeTest` 与 `LobbyScreenSmokeTest` 扩展为覆盖 Fresh 档案的 `[--]` token。

### 验证状态

```text
Training badge token contract check: Main token fields, HUD badge row/getter, LobbyScreen badge token text, and smoke-test assertions are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `TrainingRoomSmokeTest.tscn`、`HallArchiveSmokeTest.tscn`、`LobbyScreenSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察新增 Badge 行是否让训练面板过高、`[CL]` / `[CN]` token 是否足够直观，以及后续替换正式图标时是否需要把 token 映射迁移到资源表。

## 2026-07-03 Armor 安全间隔恢复烟测契约
### 目标

- 把已经存在的 Armor 受击后延迟恢复机制纳入自动化契约，避免后续角色技能、受击反馈、遗物或 UI 改动破坏“护甲先挡伤害，安全间隔后逐点恢复”的基础手感。
- 本轮不改运行时数值，只补烟测和文档口径，后续再处理恢复中提示、音效/视觉反馈和数值调优。

### 新增和修改内容

- `CharacterSmokeTest` 在默认 Wanderer 角色阶段新增 Armor 资源循环断言。
- 烟测先让玩家承受 2 点伤害，确认 Armor 优先吸收伤害，HP 保持不变。
- 烟测推进低于 `shield_recharge_delay` 的时间窗口，确认 Armor 不会在安全间隔前提前恢复。
- 烟测随后推进恢复窗口，确认 Armor 会逐点恢复到上限，并且恢复过程不会改变 HP。
- `SOUL_KNIGHT_ALIGNMENT.md` 已修正当前差距描述，不再沿用旧的 Armor 差距口径。

### 验证状态

```text
Armor recharge contract check: Player runtime recharge fields/helpers, CharacterSmokeTest assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `CharacterSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 Armor 恢复节奏是否过快或过慢、受击后重新开始恢复的间隔是否清晰，以及后续是否需要在 HUD 上加入恢复中提示或音效。

## 2026-07-03 Armor HUD 恢复状态提示第一版
### 目标

- 在已有 Armor 延迟恢复机制和烟测契约基础上，补一个玩家能直接读到的恢复状态提示。
- 先使用现有 HUD 文本锁定数据链路和测试契约，后续再替换成正式图标、恢复读条、闪烁或音效。

### 新增和修改内容

- `Player.gd` 新增 `get_shield_recharge_summary()`，暴露 `full`、`delayed`、`recovering` 和 `stalled` 四类 Armor 恢复状态。
- `HUD.update_shield()` 新增可选恢复状态参数：安全间隔中显示 `Delay Ns`，恢复窗口中显示 `Recovering`，满 Armor 后隐藏状态后缀。
- `HUD.gd` 新增 `get_shield_label_text()`，供烟测读取 Armor HUD 文本。
- `Main.gd` 新增 `_refresh_armor_hud()`，并在帧更新和 `shield_changed` 信号中刷新 Armor 文本，确保倒计时和恢复状态不依赖下一次数值变化。
- `CharacterSmokeTest` 扩展为覆盖受击后的 Delay 文本、恢复窗口中的 Recovering 文本，以及满 Armor 后隐藏恢复提示。
- `SOUL_KNIGHT_ALIGNMENT.md` 已把当前 Armor 差距更新为仍缺音效/动画反馈和数值调优。

### 验证状态

```text
Armor HUD recharge status contract check: Player summary API, HUD formatter/getter, Main refresh path, smoke-test assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `CharacterSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 `Delay Ns` 是否频繁抖动、`Recovering` 是否足够可读，以及后续是否需要替换为图标、环形读条或短促音效。

## 2026-07-03 Energy 不足反馈第一版
### 目标

- 把“能量不足导致武器不能开火”从静默失败推进为可读战斗反馈，避免玩家误以为输入、弹药或武器逻辑失效。
- 继续使用现有 HUD 消息和浮字系统锁定契约，后续再接正式音效、Energy 条闪烁或武器空响。

### 新增和修改内容

- `Events.gd` 新增 `player_energy_insufficient(current_energy, required_energy, source_data)` 信号。
- `Player.gd` 新增 `energy_insufficient_feedback_interval` 和 `_energy_insufficient_feedback_timer`，在武器或技能能量不足时发出节流反馈事件。
- `can_spend_energy_for_weapon()` 和 `spend_energy_for_weapon()` 的失败路径现在都会触发能量不足反馈；技能能量不足也复用同一事件。
- `Main.gd` 监听 `player_energy_insufficient`，显示 `Not Enough Energy current/required` HUD 消息，并在玩家附近生成 `NO ENERGY` 浮字。
- `WeaponSmokeTest` 的能量门槛用例扩展为验证失败开火会产生 `NO ENERGY` 浮字，同时仍不扣弹药、不生成弹丸。
- `SOUL_KNIGHT_ALIGNMENT.md` 已同步更新 Energy 验收口径。

### 验证状态

```text
Energy insufficient feedback contract check: event signal, Player throttled emit path, Main HUD/floating feedback, WeaponSmokeTest assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察按住高耗能武器时 `NO ENERGY` 是否过于频繁、HUD 消息是否遮挡其他提示，以及后续是否需要接入 Energy 条闪烁或空响音效。

## 2026-07-03 Energy HUD Need 状态第一版
### 目标

- 在已有 `Not Enough Energy` 消息和 `NO ENERGY` 浮字基础上，把 Energy 栏自身也变成反馈载体。
- 先用短时文本状态锁定契约，后续再替换为正式闪烁动画、颜色变化或空响音效。

### 新增和修改内容

- `HUD.gd` 新增 Energy 警告计时状态和 `show_energy_warning(required_energy)`。
- Energy 文本现在会在能量不足后短暂显示 `Energy: current / max | Need required`，计时结束后自动回到普通数值。
- `HUD.gd` 新增 `get_energy_label_text()`，供烟测读取 Energy 行文本。
- `Main.gd` 在处理 `player_energy_insufficient` 时同步调用 `show_energy_warning()`，让 Energy 行、HUD 消息和 `NO ENERGY` 浮字一起出现。
- `WeaponSmokeTest` 的能量门槛用例扩展为验证失败开火后 Energy 行包含 `Need`。
- `SOUL_KNIGHT_ALIGNMENT.md` 已同步更新 Energy 验收口径。

### 验证状态

```text
Energy HUD need-state contract check: HUD warning timer/API/getter, Main event hook, WeaponSmokeTest assertion, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 `Need N` 是否足够直观、持续时间是否太短或太长，以及后续是否要把文本状态替换为 Energy 行闪烁和空响音效。

## 2026-07-03 Skill 冷却失败反馈第一版
### 目标

- 把主动技能冷却中的重复按键从静默失败推进为即时可读反馈。
- 先复用现有 HUD 消息和浮字系统，后续再接技能按钮闪烁、失败音效或手柄震动。

### 新增和修改内容

- `Events.gd` 新增 `player_skill_unavailable(skill_name, reason, cooldown_remaining)` 信号。
- `Player.gd` 新增 `skill_unavailable_feedback_interval` 和 `_skill_unavailable_feedback_timer`，在技能冷却中重复使用时发出节流反馈事件。
- `try_use_skill()` 的冷却失败路径现在会触发 `cooldown` 反馈；能量不足仍复用 Energy 不足事件。
- `Main.gd` 监听 `player_skill_unavailable`，显示 `SkillName Cooldown Ns` HUD 消息，并在玩家附近生成 `SKILL CD` 浮字。
- `CharacterSmokeTest` 扩展为验证 Warden 技能冷却中重复使用会失败，并产生 `SKILL CD` 浮字反馈。
- `SOUL_KNIGHT_ALIGNMENT.md` 已同步更新角色技能可读性口径。

### 验证状态

```text
Skill cooldown feedback contract check: event signal, Player throttled cooldown emit path, Main HUD/floating feedback, CharacterSmokeTest assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `CharacterSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 `SKILL CD` 和 HUD 冷却消息是否过于频繁、是否和 Energy 不足反馈抢占注意力，以及后续是否需要技能按钮闪烁或失败音效。

## 2026-07-03 近战扇形挥砍可视反馈第一版
### 目标

- 把近战武器的命中范围从纯逻辑扇形推进为可读的战斗反馈，避免玩家只能通过敌人掉血推断范围。
- 先使用程序化轻量扇形闪光锁定运行时链路和烟测契约，后续再替换为正式刀光、美术贴图和音效。

### 新增和修改内容

- 新增 `dungeon-unleashed/scripts/effects/MeleeSweepFlash.gd` 与 `dungeon-unleashed/scenes/effects/MeleeSweepFlash.tscn`，按半径和角度绘制淡出的扇形挥砍范围。
- `Weapon.gd` 新增 `melee_sweep_flash_scene`，近战分支会用 `weapon_data.projectile_range` 和 `weapon_data.spread_angle` 生成对应可视扇形。
- `WeaponSmokeTest` 的 `Arc Blade` 用例新增可视反馈断言：近战释放后必须出现 `melee_sweep_flash`，且效果半径、角度与 `WeaponData` 保持一致。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新当前武器反馈差距和第五十一批落地记录。

### 验证状态

```text
Melee sweep flash contract check: effect scene/script, Weapon melee spawn path, WeaponSmokeTest assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn`、`CombatFeedbackSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 `Arc Blade`、`Frost Sickle` 和挡弹近战武器的扇形闪光是否过亮、过短或遮挡敌方弹幕，以及后续是否需要按武器稀有度/元素/格挡能力区分颜色与命中反馈。

## 2026-07-03 远程敌人弹道前摇第一版
### 目标

- 把普通/精英远程敌人的发射从“冷却到点立即出弹”推进为可读的短前摇，降低弹幕伤害的突兀感。
- 先复用已有 `DangerWarning` 线形预警锁定战斗反馈链路，后续再替换为正式敌人起手动画、施法特效和音效。

### 新增和修改内容

- `Enemy.gd` 新增 `projectile_attack_windup`、远程发射前摇状态和前摇计时逻辑。
- `SHOOTER` 与 `STRAFER` 行为现在会先调用 `_start_projectile_windup()`，显示弹道预警线，等待前摇结束后再真正生成 `EnemyProjectile`。
- 散射弹幕敌人会按 `projectile_count` 和 `projectile_spread_degrees` 生成多条预警线，让 `Barrage Totem` 这类弹幕源的覆盖角度可读。
- 精英敌人继续复用 `Enemy.gd` 行为，因此精英远程敌人的射击也会获得相同前摇。
- `EnemyVarietySmokeTest` 的 `Barrage Totem` 用例新增两段断言：前摇阶段有 5 条预警且没有弹丸，前摇结束后才生成散射弹幕。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新敌人读招差距和第五十二批落地记录。

### 验证状态

```text
Ranged enemy windup contract check: Enemy projectile windup path, line warning spawn path, EnemyVarietySmokeTest assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `EnemyVarietySmokeTest.tscn`、`CombatFeedbackSmokeTest.tscn`、`BossSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 Shooter、Ember Marksman、Needle Skater 和 Barrage Totem 的预警线是否过短、过亮或与 Boss/陷阱危险区混淆，以及 `0.18s` 前摇是否影响远程敌人压迫感。

## 2026-07-03 冲锋敌人路线预警第一版
### 目标

- 把冲锋敌人的读招从单纯颜色闪烁推进为可读的路线预警，让玩家能提前判断冲锋方向和大致覆盖距离。
- 继续复用 `DangerWarning` 线形预警，先锁定行为链路和烟测契约，后续再替换为正式蓄势动画、脚步/冲锋音效和更细的敌人差异。

### 新增和修改内容

- `Enemy.gd` 的 `CHARGER` 行为在进入 `charge_windup` 时调用 `_spawn_charge_warning()`，生成一条线形冲锋路线预警。
- 路线预警长度按 `charge_speed * charge_duration + 48` 推导，并受 `attack_range` 限制，避免提示范围明显超过实际冲刺压力。
- 该逻辑挂在通用 `Enemy.gd` 行为上，因此普通 `Charger`、重型 `Iron Breaker` 和精英冲锋敌人都会继承。
- `EnemyVarietySmokeTest` 新增 `Charger` 用例：确认冲锋前会生成 `danger_warnings`，且预警阶段敌人仍处于 `_charge_state == 1`。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新敌人读招差距和第五十三批落地记录。

### 验证状态

```text
Charger warning contract check: Enemy charge warning spawn path, EnemyVarietySmokeTest assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `EnemyVarietySmokeTest.tscn`、`CombatFeedbackSmokeTest.tscn`、`BossSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 `Charger` 与 `Iron Breaker` 的路线预警是否和实际冲刺距离一致，预警宽度是否过宽，以及精英加速后是否仍给玩家足够反应时间。

## 2026-07-03 玩家受击 HUD 闪屏反馈第一版
### 目标

- 把玩家实际 HP 受损从浮字、震动和角色闪红推进为 UI 层也能立刻读到的受击警示。
- 先使用运行时 `ColorRect` 覆盖层锁定事件链路和烟测契约，后续再替换为正式 vignette、音效和低血警告。

### 新增和修改内容

- `HUD.gd` 新增 `DamageFlashOverlay` 运行时节点、`show_damage_flash()`、淡出计时和测试 getter。
- `Main.gd` 在 `player_damaged` 且实际 HP 受损时触发 HUD 闪屏。
- `CombatFeedbackSmokeTest` 扩展为覆盖闪屏出现、可见 alpha 和自动消退。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 Armor/受击反馈差距和第五十四批记录。

### 验证状态

```text
Player hurt HUD flash contract check: HUD overlay/timer/getters, Main player_damaged hook, CombatFeedbackSmokeTest assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `CombatFeedbackSmokeTest.tscn`、`EnemyVarietySmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察红色闪屏是否过强、是否遮挡弹幕/预警线，以及是否需要按 HP 低血、Armor 吸收和致命伤区分不同反馈。

## 2026-07-03 低血 HUD 状态提示第一版
### 目标

- 在玩家实际濒危时给出持续可读的 HP HUD 状态，不只依赖一次性受击闪屏和浮字。
- 先使用文本和颜色锁定低血反馈契约，后续再替换或叠加正式边缘 vignette、心跳音效和濒死节奏。

### 新增和修改内容

- `HUD.update_health()` 新增低血阈值判断，当前生命值低于约 35% 且仍存活时，HP 行追加 `LOW` 并切换为红色。
- `HUD.gd` 新增 `get_health_label_text()` 和 `is_low_health_active()`，供烟测读取低血文本和状态。
- `CombatFeedbackSmokeTest` 扩展为覆盖低血提示出现，以及生命恢复到安全区后提示自动清除。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 Armor/受击反馈差距和第五十五批记录。

### 验证状态

```text
Low-health HUD contract check: HUD threshold/text/color state, health label getter, low-health state getter, CombatFeedbackSmokeTest assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `CombatFeedbackSmokeTest.tscn`、`CharacterSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 `LOW` 是否足够明显、是否与 HP 数字过度拥挤，以及后续是否需要把低血反馈扩展为边缘血色、心跳音效或屏幕轻脉冲。

## 2026-07-03 Armor 恢复 HUD 脉冲第一版
### 目标

- 在 Armor 安全间隔恢复时给玩家一个比纯文本更直接的恢复反馈，让护甲资源循环更容易读到。
- 先使用 HUD 颜色脉冲锁定行为契约，后续再替换或叠加正式 Armor 图标闪光、恢复读条和恢复完成音效。

### 新增和修改内容

- `HUD.update_shield()` 记录上一帧 Armor 数值，检测到 Armor 上升时触发短暂亮青色脉冲。
- Armor 脉冲会在 `_process()` 中自动淡回普通蓝色；Armor 下降时会立即取消脉冲，避免受击和恢复反馈混淆。
- `HUD.gd` 新增 `show_armor_recovery_pulse()`、`is_armor_recovery_pulse_active()` 和 `get_shield_label_color_for_test()`。
- `CharacterSmokeTest` 扩展为覆盖自动恢复第一点 Armor 后 HUD 脉冲激活、颜色变亮，以及脉冲持续时间后消退。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 Armor/受击反馈差距和第五十六批记录。

### 验证状态

```text
Armor recovery HUD pulse contract check: HUD previous-armor tracking, pulse timer/color refresh, decrease cancel path, CharacterSmokeTest assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `CharacterSmokeTest.tscn`、`CombatFeedbackSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 Armor 恢复脉冲是否过亮、是否与受击蓝色护甲浮字冲突，以及后续是否需要改成图标/读条而不是文字颜色变化。

## 2026-07-03 Energy 不足 HUD 脉冲第一版
### 目标

- 把 Energy 不足反馈从 `Need N` 文本推进为 Energy 行自身也会短促变亮的可读反馈。
- 继续复用现有 `player_energy_insufficient` 事件和 HUD warning timer，先锁定 UI 反馈契约，后续再接正式空响音效和 Energy 条动画。

### 新增和修改内容

- `HUD.show_energy_warning()` 新增警告持续时间记录，Energy 不足时会触发 Energy 行亮蓝白色脉冲。
- `_refresh_energy_label()` 会根据警告剩余时间把 Energy 行颜色淡回普通蓝色；计时结束或能量已经足够时自动恢复普通颜色。
- `HUD.gd` 新增 `is_energy_warning_active()` 和 `get_energy_label_color_for_test()`，供烟测读取 Energy 警告状态和颜色。
- `WeaponSmokeTest` 扩展为覆盖 Energy 不足开火失败后 warning 激活、Energy 行变亮，以及 warning 持续时间后消退。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 Energy 反馈差距和第五十七批记录。

### 验证状态

```text
Energy warning HUD pulse contract check: HUD warning duration/color refresh, active-state getter, color getter, WeaponSmokeTest assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn`、`CombatFeedbackSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 Energy 行脉冲是否足够明显、是否与 Armor/HP 状态颜色抢占注意力，以及后续是否需要补武器空响音效或 Energy 条局部闪烁。

## 2026-07-03 Skill 冷却失败 HUD 脉冲第一版
### 目标

- 把主动技能冷却失败反馈从 HUD 消息和 `SKILL CD` 浮字推进为 Skill 行自身也有即时视觉提示。
- 继续复用 `player_skill_unavailable` 事件，先锁定 UI 反馈契约，后续再接正式技能按钮动画、失败音效和手柄震动。

### 新增和修改内容

- `HUD.gd` 新增 Skill warning 计时和颜色刷新，技能不可用反馈触发时 Skill 行短暂推向橙色，并自动淡回普通绿色。
- `Main.gd` 在 `player_skill_unavailable` 事件中同步调用 `show_skill_warning()`，让 HUD 消息、`SKILL CD` 浮字和 Skill 行脉冲同时出现。
- `HUD.gd` 新增 `is_skill_warning_active()` 和 `get_skill_label_color_for_test()`，供烟测读取技能失败反馈状态和颜色。
- `CharacterSmokeTest` 扩展为覆盖 Warden 技能冷却中重复使用后 Skill warning 激活、颜色变橙，以及 warning 持续时间后消退。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新技能失败反馈差距和第五十八批记录。

### 验证状态

```text
Skill cooldown HUD pulse contract check: HUD warning timer/color refresh, Main unavailable hook, active-state getter, color getter, CharacterSmokeTest assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `CharacterSmokeTest.tscn`、`WeaponSmokeTest.tscn`、`CombatFeedbackSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 Skill 行脉冲是否和 Energy/Armor 状态颜色区分明确，以及冷却失败连续按键时是否过于闪烁。

## 2026-07-03 Skill Ready HUD 脉冲第一版
### 目标

- 让主动技能从冷却/激活状态回到 Ready 时也有即时 HUD 反馈，避免玩家必须持续盯着倒计时。
- 与冷却失败的橙色 warning 分开处理，Ready 只使用绿色脉冲，并且不在角色切换或初始刷新时误触发。

### 新增和修改内容

- `HUD.update_skill_status()` 新增 Ready 状态记忆：同一技能从非 Ready 回到 Ready 时触发绿色脉冲。
- `HUD.gd` 新增 `show_skill_ready_pulse()`、`is_skill_ready_pulse_active()`、Ready 脉冲计时和 Skill 行统一颜色刷新。
- Skill warning 橙色脉冲优先级高于 Ready 绿色脉冲，避免冷却失败和冷却完成提示混色。
- `CharacterSmokeTest` 扩展为推进 Warden 技能冷却结束，验证 Ready 文本、绿色脉冲激活和持续时间后消退。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新技能状态可读性和第五十九批记录。

### 验证状态

```text
Skill ready HUD pulse contract check: HUD ready-state tracking, skill-change guard, ready pulse timer/color refresh, CharacterSmokeTest assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `CharacterSmokeTest.tscn`、`CombatFeedbackSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察技能 Ready 绿色脉冲是否足够明显，是否需要改为技能按钮闪光或短促提示音。

## 2026-07-03 Ammo 换弹完成 HUD 脉冲第一版
### 目标

- 让自动换弹完成时的 Ammo 状态变化比单纯数字回满更容易读到。
- 先使用 HUD 颜色脉冲锁定换弹完成反馈契约，后续再接正式换弹完成音效、武器槽闪光和弹匣动画。

### 新增和修改内容

- `HUD.update_ammo()` 新增 Reloading 状态记忆，仅在从 Reloading 回到非 Reloading 且弹药大于 0 时触发绿色脉冲。
- `HUD.gd` 新增 `show_ammo_ready_pulse()`、`is_ammo_ready_pulse_active()`、`get_ammo_label_text()` 和 `get_ammo_label_color_for_test()`。
- `WeaponSmokeTest` 扩展为验证手枪自动换弹完成后 Ammo 文本显示满弹、绿色脉冲激活和持续时间后消退。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新武器/换弹反馈差距和第六十批记录。

### 验证状态

```text
Ammo reload-complete HUD pulse contract check: HUD reload-state tracking, ammo pulse timer/color refresh, WeaponSmokeTest assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn`、`CombatFeedbackSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 Ammo 换弹完成脉冲是否足够明显，是否需要改成武器槽闪光、弹匣动画或短促换弹完成音效。

## 2026-07-03 Weapon 行换弹完成脉冲第一版
### 目标

- 让换弹完成反馈从 Ammo 数字行扩展到当前武器 HUD 行，朝正式武器槽闪光靠近一步。
- 在没有独立武器槽图标 UI 前，先用当前 Weapon 行颜色脉冲锁定反馈契约。

### 新增和修改内容

- `HUD.update_ammo()` 检测到从 Reloading 回到非 Reloading 且弹药大于 0 时，会同时触发 Ammo 行和当前 Weapon 行绿色脉冲。
- `set_weapon_name()` 在武器切换时清空 Weapon ready 脉冲，避免旧武器反馈污染新武器显示。
- `HUD.gd` 新增 `show_weapon_ready_pulse()`、`is_weapon_ready_pulse_active()`、`get_weapon_label_text()` 和 `get_weapon_label_color_for_test()`。
- `WeaponSmokeTest` 扩展为验证换弹完成后当前武器名仍显示正确、Weapon 行绿色脉冲激活和持续时间后消退。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新武器反馈差距和第六十一批记录。

### 验证状态

```text
Weapon reload-complete HUD pulse contract check: HUD weapon pulse timer/color refresh, weapon-change reset path, WeaponSmokeTest assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 Weapon 行脉冲是否和 Ammo 行形成清晰联动，是否需要尽快替换为正式武器槽图标闪光、弹匣动画或换弹完成音效。

## 2026-07-03 Weapon Slot 状态条第一版
### 目标

- 把当前武器反馈从纯文本行推进为独立 Weapon Slot UI 雏形，给后续正式武器图标、弹匣动画和槽位切换打基础。
- 继续保持轻量、可测试，不引入尚未存在的正式美术资源。

### 新增和修改内容

- `HUD.tscn` 在左上 HUD 组内新增 `WeaponSlotPanel`，包含武器名、弹匣状态和状态色条。
- `HUD.gd` 将 `set_weapon_name()` 和 `update_ammo()` 同步到 Weapon Slot，正常状态显示 `Ready`，空弹匣显示 `Empty`，换弹中显示 `Reloading`。
- 换弹完成触发 ready 脉冲时，Weapon Slot 状态条会同步从蓝色推向绿色。
- `HUD.gd` 新增 `get_weapon_slot_name_text()`、`get_weapon_slot_status_text()` 和 `get_weapon_slot_bar_color_for_test()`。
- `WeaponSmokeTest` 扩展为验证换弹中 Weapon Slot 显示 `Reloading`，换弹完成后显示当前武器、满弹 `Ready` 和绿色状态条。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新武器反馈差距和第六十二批记录。

### 验证状态

```text
Weapon Slot status bar contract check: HUD scene node, weapon/ammo sync, reload/ready/empty states, ready bar flash, WeaponSmokeTest assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 Weapon Slot 是否挤压左上 HUD、状态条是否足够可读，以及后续是否要改为图标加弹匣分段的正式武器槽。

## 2026-07-03 Weapon Slot 弹匣分段第一版
### 目标

- 让 Weapon Slot 不只显示数字和状态条，也能用弹匣分段表达剩余弹药比例。
- 先使用程序化 ColorRect 分段，避免引入尚未存在的正式图标素材，同时锁定换弹/空弹/满弹的 UI 契约。

### 新增和修改内容

- `HUD.tscn` 在 `WeaponSlotPanel` 内新增 `WeaponSlotMagazineRow`，用于承载动态弹匣分段。
- `HUD.gd` 按武器弹匣大小动态生成弹匣段，最多显示 12 段；超过 12 发的大弹匣按比例映射。
- 弹匣段状态颜色覆盖普通、空弹匣、换弹中和换弹完成 ready 脉冲。
- `HUD.gd` 新增 `get_weapon_slot_magazine_segment_summary_for_test()` 和 `get_weapon_slot_magazine_first_segment_color_for_test()`。
- `WeaponSmokeTest` 扩展为验证手枪换弹中弹匣段为空、换弹完成后弹匣段填满并闪绿。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新武器反馈差距和第六十三批记录。

### 验证状态

```text
Weapon Slot magazine segment contract check: HUD scene row, bounded dynamic segments, reload/empty/ready colors, WeaponSmokeTest assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 12 段上限在高弹匣武器上是否足够可读，是否需要改成图标弹匣、分段补弹动画或更强的换弹完成音效。

## 2026-07-03 Weapon Slot 槽位上下文第一版
### 目标

- 让 Weapon Slot 不只知道当前武器名，也能显示它来自 1/2/3 哪个槽位。
- 为后续三武器槽图标、当前槽高亮和非当前槽预览打基础。

### 新增和修改内容

- `Player.weapon_changed` 扩展为发出武器名、当前槽位序号和总槽位数。
- `Main.gd` 在初始化和武器切换回调中把槽位上下文传给 `HUD.set_weapon_name()`。
- `HUD.set_weapon_name()` 保持默认参数兼容旧调用，同时会保存并显示 `1/3`、`2/3`、`3/3` 槽位上下文。
- Weapon 主文本现在使用 `Weapon X/Y: Name`，Weapon Slot 标题使用 `Slot X/Y  Name`。
- `HUD.gd` 新增 `get_weapon_slot_index_text()`，供烟测读取当前槽位编号。
- `WeaponSmokeTest` 扩展为验证开局 Weapon Slot 显示 `1/3` 和第一把武器名，切到第二把武器后显示 `2/3` 和第二把武器名。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新武器反馈差距和第六十四批记录。

### 验证状态

```text
Weapon Slot index context contract check: Player weapon_changed slot payload, Main forwarding, HUD slot formatting, WeaponSmokeTest assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 `Weapon 1/3` 和 `Slot 1/3` 是否冗余，后续若接正式槽位图标可考虑收敛文本。

## 2026-07-03 Weapon Slot 三槽负载预览第一版
### 目标

- 让 Weapon Slot 同时展示 1/2/3 三个武器槽的简短负载，减少玩家切换武器时的记忆负担。
- 为后续正式三槽图标、当前槽高亮、非当前槽弹药摘要打基础。

### 新增和修改内容

- `HUD.tscn` 在 Weapon Slot 内新增 `WeaponSlotLoadoutRow`，默认展示三把初始武器的短名。
- `HUD.gd` 新增 `update_weapon_loadout()`，维护负载名称数组、生成/复用槽位标签，并高亮当前槽。
- `Main.gd` 在开局初始化和 `weapon_changed` 回调中刷新负载预览；商店换购当前武器后会通过同一回调同步。
- `HUD.gd` 新增 `get_weapon_slot_loadout_text()` 和 `get_weapon_slot_loadout_summary_for_test()`。
- `WeaponSmokeTest` 扩展为验证开局三槽预览、切换到第二把武器后的 active slot。
- `ShopSmokeTest` 扩展为验证购买武器后 HUD 负载预览包含新武器且 active slot 仍指向当前槽。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新武器反馈差距和第六十五批记录。

### 验证状态

```text
Weapon Slot loadout preview contract check: HUD scene row, loadout refresh API, Main forwarding, WeaponSmokeTest switch assertions, ShopSmokeTest purchase assertion, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn`、`ShopSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察三槽短名是否过挤，后续若接正式图标可把文字预览收敛为 tooltip 或仅保留当前武器名。

## 2026-07-03 Weapon Slot 稀有度/类型预览第一版
### 目标

- 把内容管线里的武器稀有度、类型和推荐距离接入 Weapon Slot，让三槽预览不只是名字列表。
- 在正式图标和美术资源接入前，先用短码、颜色和 tooltip 提供可读元数据。

### 新增和修改内容

- `Main.gd` 新增负载摘要输出，给 HUD 传递 `display_name`、`rarity`、`weapon_class` 和 `recommended_range`。
- `HUD.update_weapon_loadout()` 现在兼容字符串、资源和字典输入，并将负载预览内部存为元数据条目。
- Weapon Slot 三槽预览显示稀有度/类型短码，例如 `ST/SI`、`CO/SH`，并按稀有度给槽位文本着色。
- 三槽预览 tooltip 会显示完整武器名、稀有度、武器类型和推荐距离。
- `HUD.gd` 的负载 summary 测试接口新增 `entries`，便于烟测读取稀有度和类型。
- `WeaponSmokeTest` 扩展为验证起始负载预览暴露稀有度/类型元数据和短码。
- `ShopSmokeTest` 扩展为验证购买武器后 HUD 负载预览同步新武器的稀有度和类型。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新武器反馈差距和第六十六批记录。

### 验证状态

```text
Weapon Slot rarity/class preview contract check: Main loadout metadata summaries, HUD loadout entry normalization, rarity/class prefix formatting, WeaponSmokeTest metadata assertions, ShopSmokeTest purchase metadata assertion, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn`、`ShopSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 `ST/SI` 这类短码是否能被玩家理解；若不够直观，后续应改成图标或在设置里只保留 tooltip。

## 2026-07-03 Weapon Slot 当前武器详情行第一版
### 目标

- 让玩家不必理解三槽短码，也能在当前 Weapon Slot 中读到当前武器的稀有度、类型、推荐距离和能耗。
- 把内容管线的 `rarity`、`weapon_class`、`recommended_range` 和 `energy_cost` 更直接地接到局内 HUD。

### 新增和修改内容

- `HUD.tscn` 在 Weapon Slot 内新增 `WeaponSlotMetaLabel`，默认显示 `Starter Sidearm | Mid | E0`。
- `Main.gd` 的负载摘要新增 `energy_cost`，让 HUD 当前武器详情行能显示能耗。
- `HUD.gd` 新增 `_refresh_weapon_slot_meta_label()`，并在武器名变化、负载变化和 Weapon Slot 刷新时同步当前武器详情。
- `HUD.gd` 新增 `get_weapon_slot_meta_text()`，供烟测读取当前武器详情行。
- `WeaponSmokeTest` 扩展为验证当前武器详情行包含稀有度、类型、推荐距离和能耗，并在切换武器后更新。
- `ShopSmokeTest` 扩展为验证购买武器后当前武器详情行同步新武器的稀有度和类型。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新武器反馈差距和第六十七批记录。

### 验证状态

```text
Weapon Slot active metadata line contract check: HUD scene label, Main energy-cost summaries, HUD active metadata refresh, WeaponSmokeTest switch assertions, ShopSmokeTest purchase assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn`、`ShopSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察当前武器详情行是否和三槽短码重复，后续接正式图标后可以收敛为图标加 tooltip。

## 2026-07-03 Weapon Slot 图标/色条/符号第一版
### 目标

- 让 Weapon Slot 不只依赖文字详情行，而是具备正式图标 UI 之前的稳定视觉结构。
- 把当前武器的稀有度、类型和能耗拆成更接近最终 HUD 的色条、类型 token 和能耗符号。

### 新增和修改内容

- `HUD.tscn` 在 Weapon Slot 内新增 `WeaponSlotIdentityRow`，包含 `WeaponSlotRarityStrip`、`WeaponSlotIconLabel`、`WeaponSlotTypeSymbolLabel` 和 `WeaponSlotEnergySymbolLabel`。
- `HUD.gd` 新增 `_refresh_weapon_slot_identity_visuals()`，随当前武器元数据同步稀有度色条、类型 token、类型标签和能耗符号。
- `HUD.gd` 新增 `_format_weapon_class_symbol()`，为常见武器类型生成稳定短 token，作为正式图标素材接入前的契约。
- `HUD.gd` 新增 `get_weapon_slot_visual_summary_for_test()`，供烟测读取当前武器槽的 `icon`、`type`、`energy` 和 `rarity_color`。
- `WeaponSmokeTest` 扩展为验证开局与切换武器后的 Weapon Slot 视觉字段同步。
- `ShopSmokeTest` 扩展为验证购买武器后 Weapon Slot 视觉字段同步新武器。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新武器反馈差距和第六十八批记录。

### 验证状态

```text
Weapon Slot identity visual contract check: HUD scene identity row, HUD visual refresh, class token formatter, WeaponSmokeTest switch assertions, ShopSmokeTest purchase assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn`、`ShopSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 `SI`、`SH`、`ST` 等类型 token 是否足够直观；正式图标接入后可保留 token 作为 tooltip 或调试文本。

## 2026-07-03 Weapon Slot 稀有度边框与当前槽高亮第一版
### 目标

- 让 Weapon Slot 从单纯文本和局部色条推进到具备“当前槽位框体”的正式 UI 雏形。
- 用当前武器稀有度驱动面板边框，让武器槽、稀有度和换弹反馈在同一个视觉区域内闭合。

### 新增和修改内容

- `HUD.gd` 新增运行时 `StyleBoxFlat` 面板样式，给 Weapon Slot 面板提供暗色底和稀有度边框。
- `HUD.gd` 新增 `_setup_weapon_slot_panel_style()` 和 `_refresh_weapon_slot_panel_style()`，根据当前武器稀有度、换弹状态、空弹匣状态和 ready 脉冲刷新边框。
- 多槽负载下 Weapon Slot 面板保持更粗 active border，用于表达当前正在使用的槽位。
- `HUD.gd` 新增 `get_weapon_slot_panel_summary_for_test()`，供烟测读取 active slot、slot total、border color 和 border width。
- `WeaponSmokeTest` 扩展为验证开局、切换武器和换弹完成后的 Weapon Slot 边框契约。
- `ShopSmokeTest` 扩展为验证购买武器后 active border 仍指向当前被替换的槽位，并保留稀有度边框颜色。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新武器反馈差距和第六十九批记录。

### 验证状态

```text
Weapon Slot rarity border contract check: runtime StyleBoxFlat setup, panel style refresh, visual summary getter, WeaponSmokeTest start/switch/reload assertions, ShopSmokeTest purchase assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn`、`ShopSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察边框颜色和状态条颜色是否信息重复；正式 UI 接入后可以保留边框作为稀有度或当前槽二选一的主要提示。

## 2026-07-03 Weapon Slot 切槽脉冲第一版
### 目标

- 让玩家切换武器时能在三槽负载预览和当前 Weapon Slot 面板上读到“刚刚切到的新槽”。
- 在正式武器槽切换动画前，先建立可测试的轻量颜色脉冲契约。

### 新增和修改内容

- `HUD.gd` 新增 `WEAPON_SLOT_SWITCH_PULSE_DURATION`、切槽脉冲计时和 `_update_weapon_slot_switch_pulse()`。
- `set_weapon_name()` 和 `update_weapon_loadout()` 会在 active slot 变化时触发切槽脉冲。
- `_process()` 会推进切槽脉冲淡出，并刷新三槽负载预览和 Weapon Slot 面板边框。
- `_refresh_weapon_slot_loadout_row()` 会在切槽脉冲期间把当前槽文字推向亮黄提示色。
- `_refresh_weapon_slot_panel_style()` 会在切槽脉冲期间把 Weapon Slot 面板边框推向亮黄提示色。
- `HUD.gd` 新增 `is_weapon_slot_switch_pulse_active()` 和 `get_weapon_slot_active_loadout_color_for_test()`。
- `WeaponSmokeTest` 扩展为验证切换武器后切槽脉冲激活、当前槽颜色提亮，并在持续时间后消退。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新武器反馈差距和第七十批记录。

### 验证状态

```text
Weapon Slot switch pulse contract check: switch pulse timer, set_weapon_name/update_weapon_loadout trigger, _process fade, loadout row highlight, panel border highlight, WeaponSmokeTest switch assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn`、`ShopSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察切槽脉冲是否足够短促；如果和换弹完成 ready 脉冲混淆，后续应把切槽动画改成槽框位移或图标弹跳。

## 2026-07-03 Weapon Slot 换弹中弹匣 sweep 第一版
### 目标

- 让换弹中 Weapon Slot 弹匣分段从静态橙色推进到有移动方向感的轻量填装反馈。
- 在正式弹匣填装动画和换弹音效前，先建立可测试的 reload sweep 契约。

### 新增和修改内容

- `HUD.gd` 新增 `WEAPON_SLOT_RELOAD_SWEEP_INTERVAL` 和 `WEAPON_SLOT_SEGMENT_RELOAD_SWEEP_COLOR`。
- `HUD.gd` 新增 `_weapon_slot_reload_sweep_timer` 和 `_weapon_slot_reload_sweep_index`，并在 `_process()` 中仅当武器处于 reloading 且有弹匣段时推进。
- `update_ammo()` 在进入 reloading 时把 sweep 重置到第一个分段，在退出 reloading 时清空 sweep 状态。
- `_refresh_weapon_slot_magazine_segments()` 在 reloading 状态下让当前 sweep 分段使用亮黄色，其余分段保持橙色。
- `get_weapon_slot_magazine_segment_summary_for_test()` 新增 `reload_sweep_active` 和 `reload_sweep_index`。
- `HUD.gd` 新增 `get_weapon_slot_reload_sweep_segment_color_for_test()`，供烟测读取当前高亮分段颜色。
- `WeaponSmokeTest` 扩展为验证换弹中 sweep 激活、高亮分段有效、颜色变亮，并在推进 HUD 时间后移动。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新武器反馈差距和第七十一批记录。

### 验证状态

```text
Weapon Slot reload sweep contract check: reload sweep timer/index, update_ammo reset, _process advancement, reloading segment highlight, WeaponSmokeTest reload assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 sweep 速度是否和实际换弹时长匹配；正式化时应按不同武器 reload duration 做更准确的填装进度条或逐段填充。

## 2026-07-03 Weapon Slot 能耗不足符号脉冲第一版
### 目标

- 让能量不足失败开火时，玩家不只看顶部 Energy 行和浮字，也能在当前 Weapon Slot 的能耗符号上读到反馈。
- 把当前武器的 `E2` 等能耗提示纳入统一战斗反馈规格。

### 新增和修改内容

- `HUD.gd` 新增 `WEAPON_SLOT_ENERGY_WARNING_COLOR`。
- `HUD.gd` 新增 `_refresh_weapon_slot_energy_symbol_color()`，负责按当前武器能耗、Energy warning 状态和剩余计时刷新能耗符号颜色。
- `show_energy_warning()` 触发 Energy warning 时会同步刷新 Weapon Slot 能耗符号。
- `_process()` 推进 Energy warning 计时和 `update_energy()` 更新能量时都会同步刷新能耗符号，避免 warning 消退后颜色残留。
- `HUD.gd` 新增 `get_weapon_slot_energy_symbol_color_for_test()`。
- `WeaponSmokeTest` 扩展为验证能量不足失败开火后 Weapon Slot 能耗符号变亮，并在 warning 消退后恢复普通颜色。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新武器反馈差距和第七十二批记录。

### 验证状态

```text
Weapon Slot energy warning symbol contract check: warning color constant, energy symbol color refresh, show_energy_warning/update_energy/_process synchronization, WeaponSmokeTest energy-gate assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned script/resource/scene references resolve.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察能耗符号脉冲是否和顶部 Energy warning 重复；正式图标接入后应保留一个主反馈、一个辅助反馈。

## 2026-07-03 能量不足空响音效第一版
### 目标

- 让能量不足失败开火不只依赖 HUD 文本、浮字和 Weapon Slot 脉冲，也具备明确的听觉失败反馈。
- 继续补齐统一战斗反馈规格里的 Energy insufficient SFX 链路，为后续正式音频资源替换建立可测试契约。

### 新增和修改内容

- `AudioFeedback.gd` 新增 `energy_empty` 程序化占位 SFX。
- `AudioFeedback` 订阅 `Events.player_energy_insufficient`，在武器或技能能量不足事件触发时自动播放 `energy_empty`。
- `AudioFeedback.gd` 新增 `get_last_sfx_id_for_test()`，供烟测读取最近一次播放的 SFX ID。
- `AudioFeedbackSmokeTest` 扩展为验证 `player_energy_insufficient` 事件会增加 SFX 计数，并将最近播放 ID 设置为 `energy_empty`。
- `WeaponSmokeTest` 扩展为验证真实能量门控失败开火会触发 `energy_empty` SFX。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新能量不足反馈差距和第七十三批记录。

### 验证状态

```text
Energy insufficient SFX contract check: energy_empty SFX branch, player_energy_insufficient event subscription, last-SFX test getter, AudioFeedbackSmokeTest direct event assertions, WeaponSmokeTest energy-gate SFX assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `AudioFeedbackSmokeTest.tscn`、`WeaponSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点听按住高耗能武器时 `energy_empty` 是否过于频繁；正式音效接入后应按武器能耗、弹药状态和失败原因区分空响层次。

## 2026-07-03 武器开火音效 key 分流第一版
### 目标

- 让 30 把武器已经配置的 `fire_sfx_key` 真正进入运行时开火反馈，而不是所有武器共用通用 `shoot`。
- 为后续替换正式音频资源建立稳定接口：资源只负责声明 key，音频系统负责按 key 或武器类别分流。

### 新增和修改内容

- `AudioFeedback._on_player_fired()` 改为读取 `WeaponData.fire_sfx_key`。
- `AudioFeedback.gd` 新增 `_resolve_weapon_fire_sfx_id()`，当武器未配置 `fire_sfx_key` 时按 `weapon_class` 回退到类别占位 SFX。
- `AudioFeedback.gd` 新增 `_try_play_weapon_fire_sfx()`，把 sidearm、shotgun、launcher、laser、melee、staff 和 core 等武器族映射到不同程序化占位音色。
- `AudioFeedbackSmokeTest` 扩展为验证配置 key、类别 fallback 和空武器数据 fallback。
- `WeaponSmokeTest` 扩展为验证真实开火后会触发 SFX，并且最近播放 ID 等于当前武器资源的 `fire_sfx_key`。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新武器反馈差距和第七十四批记录。

### 验证状态

```text
Weapon fire SFX key routing contract check: fire_sfx_key resolver, weapon-class fallback, weapon fire SFX tone mapping, AudioFeedbackSmokeTest routing assertions, WeaponSmokeTest real-fire assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `AudioFeedbackSmokeTest.tscn`、`WeaponSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点听 sidearm、shotgun、launcher、laser、melee、staff 和 core 的占位音色是否可区分；正式音频接入后应保留 `fire_sfx_key` 资源入口。

## 2026-07-03 换弹完成音效第一版
### 目标

- 让换弹完成不只依赖 Ammo/Weapon HUD 绿色脉冲和 Weapon Slot 高亮，也具备明确的听觉 ready 反馈。
- 为后续正式换弹音效或按武器类别拆分 reload SFX 建立统一事件入口。

### 新增和修改内容

- `Events.gd` 新增 `player_weapon_reloaded(weapon_data)` 信号。
- `Weapon._finish_reload()` 在补满弹匣并发出 `ammo_changed` 后，会发出 `player_weapon_reloaded`。
- `AudioFeedback.gd` 新增 `reload_ready` 程序化占位 SFX。
- `AudioFeedback` 订阅 `Events.player_weapon_reloaded`，换弹完成时播放 `reload_ready`。
- `AudioFeedbackSmokeTest` 扩展为验证直接 `player_weapon_reloaded` 事件会增加 SFX 计数，并将最近播放 ID 设置为 `reload_ready`。
- `WeaponSmokeTest` 扩展为验证手枪真实自动换弹完成后会触发 `reload_ready`。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新换弹反馈差距和第七十五批记录。

### 验证状态

```text
Reload-ready SFX contract check: player_weapon_reloaded event signal, Weapon._finish_reload emit path, AudioFeedback reload_ready branch, event subscription, AudioFeedbackSmokeTest direct event assertions, WeaponSmokeTest real reload assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `AudioFeedbackSmokeTest.tscn`、`WeaponSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点听 `reload_ready` 是否与开火音效、`energy_empty` 和 HUD ready 脉冲节奏冲突；后续正式化时应按武器族或资源 key 拆分 reload 音色。

## 2026-07-03 技能不可用音效第一版
### 目标

- 让主动技能冷却中重复使用等失败情况不只依赖 HUD 消息、`SKILL CD` 浮字和 Skill 行橙色脉冲，也具备明确的听觉失败反馈。
- 继续补齐统一战斗反馈规格里的角色技能失败 SFX 链路，为后续正式技能按钮动画和正式音频资源替换建立可测试契约。

### 新增和修改内容

- `AudioFeedback.gd` 新增 `skill_fail` 程序化占位 SFX。
- `AudioFeedback` 订阅 `Events.player_skill_unavailable`，主动技能不可用事件触发时播放 `skill_fail`。
- `AudioFeedbackSmokeTest` 扩展为验证直接 `player_skill_unavailable` 事件会增加 SFX 计数，并将最近播放 ID 设置为 `skill_fail`。
- `CharacterSmokeTest` 扩展为验证 Warden 技能冷却中重复使用后会触发 `skill_fail`。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新技能失败反馈差距和第七十六批记录。

### 验证状态

```text
Skill unavailable SFX contract check: skill_fail SFX branch, player_skill_unavailable event subscription, AudioFeedbackSmokeTest direct event assertions, CharacterSmokeTest real cooldown-fail assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `AudioFeedbackSmokeTest.tscn`、`CharacterSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点听 `skill_fail` 是否和 `energy_empty`、`reload_ready` 形成清晰区分；后续正式化时应按失败原因、角色技能类别和 UI 按钮状态拆分音效层次。

## 2026-07-03 Skill Ready 音效第一版
### 目标

- 让主动技能冷却完成不只依赖 Skill 行 Ready 文本和绿色脉冲，也具备明确的听觉可用提示。
- 为后续正式技能按钮 Ready 动画和正式提示音效建立统一事件入口。

### 新增和修改内容

- `Events.gd` 新增 `player_skill_ready(skill_name)` 信号。
- `Player._tick_timers()` 在技能冷却/激活状态完全回到可用时发出 `player_skill_ready`。
- `AudioFeedback.gd` 新增 `skill_ready` 程序化占位 SFX。
- `AudioFeedback` 订阅 `Events.player_skill_ready`，技能冷却完成时播放 `skill_ready`。
- `AudioFeedbackSmokeTest` 扩展为验证直接 `player_skill_ready` 事件会增加 SFX 计数，并将最近播放 ID 设置为 `skill_ready`。
- `CharacterSmokeTest` 扩展为验证 Warden 技能冷却完成后会触发 `skill_ready`。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 Skill Ready 反馈差距和第七十七批记录。

### 验证状态

```text
Skill ready SFX contract check: player_skill_ready event signal, Player cooldown/active-ready emit path, AudioFeedback skill_ready branch, event subscription, AudioFeedbackSmokeTest direct event assertions, CharacterSmokeTest real cooldown-ready assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `AudioFeedbackSmokeTest.tscn`、`CharacterSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点听 `skill_ready` 是否和 `reload_ready`、`reward`、`victory` 的上扬提示过近；后续正式化时应按角色技能类型和 UI 按钮状态拆分音效层次。

## 2026-07-03 Armor 获得/恢复音效第一版
### 目标

- 让 Armor 自动恢复、技能补甲和遗物补甲不只依赖 HUD 文本、浮字和颜色脉冲，也具备明确的听觉获得反馈。
- 继续补齐统一战斗反馈规格里的 Armor gain SFX 链路，为后续正式护甲音效资源和差异化反馈建立可测试契约。

### 新增和修改内容

- `AudioFeedback.gd` 新增 `armor_gain` 程序化占位 SFX。
- `AudioFeedback` 订阅 `Events.player_shield_gained`，正数 Armor 获得事件触发时播放 `armor_gain`。
- `AudioFeedbackSmokeTest` 扩展为验证直接 `player_shield_gained` 事件会增加 SFX 计数，并将最近播放 ID 设置为 `armor_gain`。
- `CharacterSmokeTest` 扩展为验证 Wanderer 受击后自动恢复第一点 Armor 时会触发 `armor_gain`。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 Armor 恢复反馈差距和第七十八批记录。

### 验证状态

```text
Armor gain SFX contract check: armor_gain SFX branch, player_shield_gained event subscription, positive-amount guard, AudioFeedbackSmokeTest direct event assertions, CharacterSmokeTest real armor-recovery assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `AudioFeedbackSmokeTest.tscn`、`CharacterSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点听 `armor_gain` 是否和 `reward`、`reload_ready` 的上扬提示过近；后续正式化时应按自动恢复、技能补甲、遗物补甲和满甲完成拆分音效层次。

## 2026-07-03 Armor 挡伤音效第一版
### 目标

- 让 Armor 完全或部分吸收伤害时具备区别于 HP 受伤的听觉反馈，避免玩家把“护甲挡住了”误读成“生命被打掉了”。
- 继续补齐统一战斗反馈规格里的 Armor block SFX 链路，为后续正式护甲受击音效和破甲反馈建立可测试契约。

### 新增和修改内容

- `AudioFeedback.gd` 新增 `armor_block` 程序化占位 SFX。
- `AudioFeedback` 订阅 `Events.player_shield_absorbed`，正数 Armor 吸收事件触发时播放 `armor_block`。
- `AudioFeedback._on_player_damaged()` 新增 0 伤害保护，Armor 完全吸收伤害时不再误播 HP `hurt` 音效。
- `AudioFeedbackSmokeTest` 扩展为验证直接 `player_shield_absorbed` 事件会增加 SFX 计数，并将最近播放 ID 设置为 `armor_block`。
- `CharacterSmokeTest` 扩展为验证 Wanderer 小额受击被 Armor 完全吸收时会触发 `armor_block`，而不是 `hurt`。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 Armor 挡伤反馈差距和第七十九批记录。

### 验证状态

```text
Armor block SFX contract check: armor_block SFX branch, player_shield_absorbed event subscription, positive-amount guard, zero-damage player_damaged audio guard, AudioFeedbackSmokeTest direct event assertions, CharacterSmokeTest real armor-absorption assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `AudioFeedbackSmokeTest.tscn`、`CharacterSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点听 `armor_block` 是否足够区别于 HP `hurt`、`armor_gain` 和敌人命中音效；后续正式化时应按挡伤、破甲、无敌期命中和重击拆分音效层次。

## 2026-07-03 HP 治疗音效第一版
### 目标

- 让 HP 恢复不只依赖浮字、HUD 数字和结算统计，也具备区别于 Armor 获得的听觉反馈。
- 继续补齐统一战斗反馈规格里的 HP heal SFX 链路，为后续正式治疗音效资源和来源差异建立可测试契约。

### 新增和修改内容

- `AudioFeedback.gd` 新增 `hp_heal` 程序化占位 SFX。
- `AudioFeedback` 订阅 `Events.player_healed`，正数 HP 治疗事件触发时播放 `hp_heal`。
- `AudioFeedbackSmokeTest` 扩展为验证直接 `player_healed` 事件会增加 SFX 计数，并将最近播放 ID 设置为 `hp_heal`。
- `CharacterSmokeTest` 扩展为验证 Wanderer 直接恢复缺失 HP 时会触发 `hp_heal`。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 HP/Armor 资源反馈差距和第八十批记录。

### 验证状态

```text
HP heal SFX contract check: hp_heal SFX branch, player_healed event subscription, positive-amount guard, AudioFeedbackSmokeTest direct event assertions, CharacterSmokeTest real heal assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `AudioFeedbackSmokeTest.tscn`、`CharacterSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点听 `hp_heal` 是否和 `armor_gain`、`reward`、`skill_ready` 的上扬提示过近；后续正式化时应按治疗房、商店购买、角色技能、遗物回血和低血治疗拆分音效层次。

## 2026-07-05 危险预警音效第一版
### 目标

- 让 Boss 弹幕、精英死亡爆炸、陷阱房、区域危险、远程弹道和冲锋路线等 `DangerWarning` 不只依赖视觉形状，也具备短促听觉预警。
- 为后续正式敌人读招、Boss 前摇和陷阱房音效建立统一事件入口，同时避免多条预警同帧生成时音效过密。

### 新增和修改内容

- `Events.gd` 新增 `danger_warning_started(shape_name, duration, damage)` 信号。
- `DangerWarning.gd` 在 `configure_circle()` 和 `configure_line()` 完成参数设置后发出 `danger_warning_started`。
- `AudioFeedback.gd` 新增 `danger_warning` 程序化占位 SFX。
- `AudioFeedback` 订阅 `Events.danger_warning_started`，危险预警出现时播放 `danger_warning`。
- `AudioFeedback` 新增 `DANGER_WARNING_SFX_COOLDOWN` 和 `_danger_warning_sfx_cooldown`，对密集预警做短冷却。
- `AudioFeedbackSmokeTest` 扩展为验证直接 `danger_warning_started` 事件会增加 SFX 计数，并将最近播放 ID 设置为 `danger_warning`。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新危险预警反馈差距和第八十一批记录。

### 验证状态

```text
Danger warning SFX contract check: danger_warning_started signal, DangerWarning circle/line emit paths, AudioFeedback danger_warning SFX branch, event subscription, cooldown guard, AudioFeedbackSmokeTest direct event assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `AudioFeedbackSmokeTest.tscn`、`BossSmokeTest.tscn`、`EnemyVarietySmokeTest.tscn`、`TrapRoomSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点听 `danger_warning` 是否足够提示即将发生的伤害，又不会在 Boss 散射、陷阱房多点危险和精英死亡爆炸中造成疲劳；后续正式化时应按预警来源拆分音效层次。

## 2026-07-05 低血进入音效第一版
### 目标

- 让 HP 进入低血阈值时不只依赖 HUD `LOW` 文本和红色颜色，也具备明确的听觉风险提示。
- 将低血提示纳入统一战斗反馈规格，并保证只在进入低血边界时触发，避免每次生命刷新都重复播放。

### 新增和修改内容

- `Events.gd` 新增 `player_low_health_warning(current_hp, max_hp)` 信号。
- `Main.gd` 新增 `_was_low_health_active` 状态和 `_sync_low_health_warning_state()`，在 HUD 低血状态从 false 变 true 时发出 `player_low_health_warning`。
- `AudioFeedback.gd` 新增 `low_health` 程序化占位 SFX。
- `AudioFeedback` 订阅 `Events.player_low_health_warning`，进入低血状态时播放 `low_health`。
- `AudioFeedbackSmokeTest` 扩展为验证直接 `player_low_health_warning` 事件会增加 SFX 计数，并将最近播放 ID 设置为 `low_health`。
- `CombatFeedbackSmokeTest` 扩展为验证真实 HP 进入低血阈值后会触发 `low_health`。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 HP/Armor 资源反馈差距和第八十二批记录。

### 验证状态

```text
Low-health SFX contract check: player_low_health_warning signal, Main low-health transition emit path, initial low-health state sync, AudioFeedback low_health SFX branch, event subscription, AudioFeedbackSmokeTest direct event assertions, CombatFeedbackSmokeTest real low-health assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `AudioFeedbackSmokeTest.tscn`、`CombatFeedbackSmokeTest.tscn`、`CharacterSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点听 `low_health` 是否足够区别于 HP `hurt`、`hp_heal` 和 `danger_warning`；后续正式化时应决定它是一次性警报、短循环心跳，还是与低血 vignette 绑定。

## 2026-07-05 低血恢复音效收束第一版
### 目标

- 让 HP 从低血阈值恢复到安全区时不仅清除 HUD `LOW` 文本，也有明确的听觉收束，减少玩家对风险是否解除的判断成本。
- 将低血解除纳入统一战斗反馈规格，并保证死亡时不会误触发恢复音效。

### 新增和修改内容
- `Events.gd` 新增 `player_low_health_recovered(current_hp, max_hp)` 信号。
- `Main.gd` 的 `_sync_low_health_warning_state()` 新增 true -> false 边沿判断，只有 `current_hp > 0` 时才发出 `player_low_health_recovered`。
- `AudioFeedback.gd` 新增 `low_health_recover` 程序化占位 SFX。
- `AudioFeedback` 订阅 `Events.player_low_health_recovered`，离开低血状态时播放 `low_health_recover`。
- `AudioFeedbackSmokeTest` 扩展为验证直接 `player_low_health_recovered` 事件会增加 SFX 计数，并将最近播放 ID 设置为 `low_health_recover`。
- `CombatFeedbackSmokeTest` 扩展为验证真实 HP 从低血恢复到安全区后会触发 `low_health_recover`。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 HP/Armor 资源反馈差距和第八十三批记录。

### 验证状态
```text
Low-health recovery SFX contract check: player_low_health_recovered signal, Main low-health recovery transition emit path, death guard, AudioFeedback low_health_recover SFX branch, event subscription, AudioFeedbackSmokeTest direct event assertions, CombatFeedbackSmokeTest real recovery assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `AudioFeedbackSmokeTest.tscn`、`CombatFeedbackSmokeTest.tscn`、`CharacterSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点听 `low_health_recover` 是否能与 `hp_heal`、`armor_gain` 和 `reward` 区分开；后续正式化时应决定它是低血解除专用提示，还是和低血 vignette 淡出、心跳循环停止绑定。

## 2026-07-05 低血边缘 Vignette 第一版
### 目标

- 让低血状态不只依赖 HUD `LOW` 文本和音效，而是在战斗视野边缘持续提供低强度风险提示。
- 保持受击闪屏优先级更高，低血提示只占边缘，避免遮挡中心弹幕、预警线和敌人读招。

### 新增和修改内容
- `HUD.gd` 新增 `LOW_HEALTH_VIGNETTE_ALPHA`、`LOW_HEALTH_VIGNETTE_EDGE_SIZE` 和 `LOW_HEALTH_VIGNETTE_FADE_SPEED`。
- `HUD.gd` 新增四条运行时 `ColorRect` 边缘遮罩，`z_index` 低于 `DamageFlashOverlay`。
- `HUD.update_health()` 在进入低血时立即显示边缘 vignette，恢复到安全血量后按淡出速度收束。
- `HUD.gd` 新增 `is_low_health_vignette_visible()` 和 `get_low_health_vignette_alpha_for_test()` 测试接口。
- `CombatFeedbackSmokeTest` 扩展为验证低血时边缘 vignette 可见且 alpha 大于 0，恢复并等待淡出后不可见。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 HP/Armor 资源反馈差距和第八十四批记录。

### 验证状态
```text
Low-health vignette contract check: HUD constants, runtime edge overlays, lower z-index than damage flash, update_health state sync, fade-out path, test getters, CombatFeedbackSmokeTest assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `CombatFeedbackSmokeTest.tscn`、`AudioFeedbackSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点看低血边缘 vignette 是否足够提醒风险、是否在高弹幕或 Boss 预警时干扰读招；后续正式化时应接入正式边缘贴图和可配置强度。

## 2026-07-05 低血边缘脉冲与强度分段第一版
### 目标

- 让“刚进入低血”和“接近濒死”在视觉强度上可区分，减少玩家对危险程度的误判。
- 在不遮挡中心战斗区域的前提下，为后续正式心跳节奏和低血视觉资源建立可测试的强度接口。

### 新增和修改内容
- `HUD.gd` 新增 `LOW_HEALTH_VIGNETTE_CRITICAL_RATIO`、`LOW_HEALTH_VIGNETTE_CRITICAL_ALPHA`、`LOW_HEALTH_VIGNETTE_PULSE_ALPHA` 和 `LOW_HEALTH_VIGNETTE_PULSE_SPEED`。
- `HUD.update_health()` 计算当前 HP 比例，并用 `_get_low_health_vignette_target_alpha()` 区分 LOW 阈值和濒死强度。
- `HUD._process()` 在低血期间推进 vignette 脉冲计时，`_refresh_low_health_vignette()` 将目标 alpha 和脉冲叠加为当前显示 alpha。
- `HUD.gd` 新增 `get_low_health_vignette_target_alpha_for_test()`，供烟测读取未叠加脉冲的目标强度。
- `CombatFeedbackSmokeTest` 扩展为先把 HP 降到 LOW 阈值，再降到 1 HP，并验证 1 HP 的目标 alpha 更高。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 HP/Armor 资源反馈差距和第八十五批记录。

### 验证状态
```text
Low-health vignette intensity contract check: critical ratio/alpha constants, pulse alpha/speed constants, HP-ratio target alpha calculation, pulse display alpha path, target-alpha test getter, CombatFeedbackSmokeTest threshold-to-critical assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `CombatFeedbackSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点看 1 HP 时的低血脉冲是否足够紧张但不过曝；后续正式化时应和低血心跳音效统一节奏，并提供可配置强度。

## 2026-07-05 低血心跳节奏音效第一版
### 目标

- 让低血状态具备持续听觉提示，而不是只依赖进入低血的一次性警报。
- 明确低血心跳的启动和停止条件：进入低血后按间隔播放，恢复或死亡后停止。

### 新增和修改内容
- `AudioFeedback.gd` 新增 `LOW_HEALTH_HEARTBEAT_INTERVAL`、`_low_health_heartbeat_active` 和 `_low_health_heartbeat_timer`。
- `AudioFeedback._process()` 在低血心跳激活时推进计时，到点播放 `low_health_heartbeat` 并重置间隔。
- `AudioFeedback.gd` 新增 `low_health_heartbeat` 程序化占位 SFX。
- `Events.player_low_health_warning` 启动 heartbeat，`Events.player_low_health_recovered` 和 `Events.player_died` 停止 heartbeat。
- `AudioFeedback.gd` 新增 `is_low_health_heartbeat_active_for_test()` 和 `get_low_health_heartbeat_timer_for_test()` 测试接口。
- `AudioFeedbackSmokeTest` 扩展为验证低血事件启动 heartbeat、等待间隔后播放 `low_health_heartbeat`，恢复事件停止 heartbeat。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 HP/Armor 资源反馈差距和第八十六批记录。

### 验证状态
```text
Low-health heartbeat SFX contract check: heartbeat interval/state/timer, `_process()` tick path, `low_health_heartbeat` SFX branch, warning/recovery/death start-stop paths, test getters, AudioFeedbackSmokeTest heartbeat assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `AudioFeedbackSmokeTest.tscn`、`CombatFeedbackSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点听 `low_health_heartbeat` 是否足够提醒但不会疲劳；后续正式化时应和低血 vignette 脉冲同步节奏，并按 HP 段调整心跳密度。

## 2026-07-05 低血心跳严重程度变速第一版
### 目标

- 让低血心跳不只是持续响，而是能根据 HP 严重程度加快，区分刚进入低血和接近濒死。
- 保持事件语义清晰：进入低血负责启动 heartbeat，低血内 HP 更新只负责调速，恢复或死亡负责停止。

### 新增和修改内容
- `Events.gd` 新增 `player_low_health_updated(current_hp, max_hp)` 信号。
- `Main._sync_low_health_warning_state()` 在已低血且仍低血时发出 `player_low_health_updated`，进入/恢复边沿仍分别发出 `player_low_health_warning` 和 `player_low_health_recovered`。
- `AudioFeedback.gd` 新增 `LOW_HEALTH_HEARTBEAT_CRITICAL_INTERVAL`、`LOW_HEALTH_HEARTBEAT_LOW_RATIO` 和 `LOW_HEALTH_HEARTBEAT_CRITICAL_RATIO`。
- `AudioFeedback` 新增 `_low_health_heartbeat_interval` 和 `get_low_health_heartbeat_interval_for_test()`，供运行时和烟测读取当前 heartbeat 间隔。
- `AudioFeedback._sync_low_health_heartbeat_interval()` 用当前 HP 比例将 heartbeat interval 从 0.72 秒插值到 0.42 秒；更新后会压缩剩余 timer。
- `AudioFeedback` 订阅 `Events.player_low_health_updated`，只在 heartbeat 已激活时调速，不允许 update 事件单独启动 heartbeat。
- `AudioFeedbackSmokeTest` 扩展为验证直接低血 update 会缩短 heartbeat interval，并继续播放 `low_health_heartbeat`。
- `CombatFeedbackSmokeTest` 扩展为验证真实 HP 从 LOW 阈值降到 1 HP 后会缩短 heartbeat interval。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 HP/Armor 资源反馈差距和第八十七批记录。

### 验证状态
```text
Low-health heartbeat severity contract check: player_low_health_updated signal, Main low-health sustained emit path, AudioFeedback critical interval/ratio constants, dynamic heartbeat interval calculation, timer compression, test getter, AudioFeedbackSmokeTest direct update assertions, CombatFeedbackSmokeTest real HP update assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `AudioFeedbackSmokeTest.tscn`、`CombatFeedbackSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点听 heartbeat 从低血到濒死的加速是否自然；后续正式化时应把视觉 vignette 脉冲速度和音频 heartbeat interval 合并到同一套严重程度模型。

## 2026-07-05 低血音画节奏同步第一版
### 目标

- 让低血视觉 vignette 脉冲速度和音频 heartbeat interval 都由 HP 严重程度驱动，避免音画节奏割裂。
- 为后续抽出共享低血严重程度模型、正式心跳音效和无障碍强度设置建立可测试接口。

### 新增和修改内容
- `HUD.gd` 新增 `LOW_HEALTH_VIGNETTE_CRITICAL_PULSE_SPEED` 和 `_low_health_vignette_pulse_speed`。
- `HUD._process()` 使用 `_low_health_vignette_pulse_speed` 推进低血 vignette 脉冲，而不是固定 `LOW_HEALTH_VIGNETTE_PULSE_SPEED`。
- `HUD._update_low_health_vignette_state()` 在更新目标 alpha 的同时更新 pulse speed，恢复安全血量时重置为默认速度。
- `HUD.gd` 新增 `_get_low_health_vignette_pulse_speed(health_ratio)`，使用与低血 alpha 相同的 LOW/critical ratio 插值。
- `HUD.gd` 新增 `get_low_health_vignette_pulse_speed_for_test()` 测试接口。
- `CombatFeedbackSmokeTest` 扩展为验证真实 HP 从 LOW 阈值降到 1 HP 时，vignette pulse speed 会提升，同时 heartbeat interval 会缩短。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 HP/Armor 资源反馈差距和第八十八批记录。

### 验证状态
```text
Low-health audiovisual rhythm contract check: critical pulse speed constant, dynamic vignette pulse-speed state, `_process()` dynamic pulse advancement, pulse-speed test getter, HP-ratio pulse-speed interpolation, safe reset path, CombatFeedbackSmokeTest critical pulse acceleration assertion, heartbeat interval assertion, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `CombatFeedbackSmokeTest.tscn`、`AudioFeedbackSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应同时观察低血 vignette 脉冲和 heartbeat 加速是否一致；后续正式化时应抽出共享严重程度模型，避免 HUD 和 Audio 各自维护阈值。

## 2026-07-05 共享低血严重程度模型第一版
### 目标

- 把低血 LOW 阈值、critical 阈值和严重程度插值从 HUD/Audio 的重复常量中抽出来，避免音画反馈后续漂移。
- 为正式低血贴图、心跳资源、手柄震动和无障碍强度设置预留统一的严重程度入口。

### 新增和修改内容
- 新增 `scripts/core/LowHealthFeedback.gd`，定义 `LOW_RATIO`、`CRITICAL_RATIO`、`get_health_ratio()`、`get_low_health_threshold()`、`is_low_health()`、`get_critical_weight_from_ratio()`、`interpolate_by_ratio()` 和 `interpolate_by_health()`。
- `HUD.gd` 新增 `LOW_HEALTH_FEEDBACK` preload，并用共享 helper 计算低血状态、HP ratio、vignette target alpha 和 vignette pulse speed。
- `AudioFeedback.gd` 新增 `LOW_HEALTH_FEEDBACK` preload，并用共享 helper 计算 heartbeat interval。
- 移除 `HUD.gd` 本地 `LOW_HEALTH_RATIO` / `LOW_HEALTH_VIGNETTE_CRITICAL_RATIO` 和 `AudioFeedback.gd` 本地 `LOW_HEALTH_HEARTBEAT_LOW_RATIO` / `LOW_HEALTH_HEARTBEAT_CRITICAL_RATIO`。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 HP/Armor 资源反馈差距和第八十九批记录。

### 验证状态
```text
Shared low-health severity contract check: LowHealthFeedback helper, shared LOW/critical ratios, HP ratio, low-health threshold, critical weight, interpolation helpers, HUD helper preload/use, AudioFeedback helper preload/use, removed local duplicate ratio constants, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `CombatFeedbackSmokeTest.tscn`、`AudioFeedbackSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 后续正式化时应考虑把 `LowHealthFeedback` 从静态 helper 升级为可调配置资源，让不同角色、难度或无障碍设置能调整低血反馈强度。

## 2026-07-05 低血反馈强度设置第一版
### 目标

- 把低血红边和心跳提示纳入玩家可调设置，避免程序化占位反馈在实机试玩中对敏感玩家过强。
- 保持默认 100% 不改变现有手感，同时允许 0% 完全关闭低血视觉/听觉反馈。

### 新增和修改内容
- `LowHealthFeedback.gd` 新增 `MIN_FEEDBACK_INTENSITY`、`DEFAULT_FEEDBACK_INTENSITY`、`MAX_FEEDBACK_INTENSITY` 和 `clamp_feedback_intensity()`，统一限制低血反馈强度范围。
- `HUD.gd` 设置面板新增 `Low-Health Feedback` 滑条，Apply 时随音量、分辨率和辅助瞄准一起回传。
- `HUD.set_low_health_feedback_intensity()` 会立即缩放低血 vignette target alpha 和 pulse alpha；强度为 0% 时红边立即隐藏。
- `AudioFeedback.set_low_health_feedback_intensity()` 会缩放 `low_health`、`low_health_heartbeat` 和 `low_health_recover` 占位音量；强度为 0% 时不会启动 heartbeat。
- `Main.gd` 新增 `low_health_feedback_intensity` gameplay 设置，支持默认值、加载、保存、摘要导出，并同步到 HUD 与 AudioFeedback。
- `SettingsSmokeTest` 扩展为验证默认值、应用值、配置文件持久化、重载后 UI 回显，以及 HUD/Audio 同步。
- `AudioFeedbackSmokeTest` 扩展为验证 0% 强度不会触发低血 SFX 或启动 heartbeat。
- `CombatFeedbackSmokeTest` 扩展为验证 0% 强度会隐藏低血 HUD vignette。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 HP/Armor 资源反馈差距和第九十批记录。

### 验证状态
```text
Low-health feedback setting contract check: helper intensity constants/clamp, HUD settings slider/label/getters, Main load/save/summary/apply path, HUD visual intensity scaling, AudioFeedback low-health SFX gating/scaling, SettingsSmokeTest persistence assertions, AudioFeedbackSmokeTest disabled-feedback assertions, CombatFeedbackSmokeTest zero-vignette assertion, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `SettingsSmokeTest.tscn`、`AudioFeedbackSmokeTest.tscn`、`CombatFeedbackSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点检查 25% / 50% / 100% 强度下红边和 heartbeat 是否仍能传达风险，并确认 0% 适合作为无障碍关闭档。

## 2026-07-05 屏幕震动强度设置第一版
### 目标

- 把当前集中在 `Main._add_shake()` 的屏幕震动纳入玩家可调设置，降低试玩中晕动、疲劳和过强反馈的风险。
- 保持默认 100% 不改变现有手感，同时允许 0% 完全关闭 camera shake。

### 新增和修改内容
- `Main.gd` 新增 `DEFAULT_SCREEN_SHAKE_INTENSITY` 和 `_settings_screen_shake_intensity`，并将其纳入设置默认值、加载、保存和摘要导出。
- `Main._add_shake()` 现在会按 `screen_shake_intensity` 缩放所有震动请求；0% 时直接忽略新震动。
- `Main._apply_feedback_settings()` 会在设置改为 0% 时清空当前 `_shake_strength` 和 `camera.offset`，避免残留镜头抖动。
- `HUD.gd` Settings 面板新增 `Screen Shake` 滑条，Apply 时随现有设置一起回传。
- `SettingsSmokeTest` 扩展为验证默认值、应用值、配置文件持久化、重载后 UI 回显和 Main 同步。
- `CombatFeedbackSmokeTest` 扩展为验证 0% 抑制震动，50% 按比例缩放震动强度。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 HP/Armor 资源反馈差距和第九十一批记录。

### 验证状态
```text
Screen-shake setting contract check: Main default/load/save/summary path, `_add_shake()` intensity scaling, zero-intensity shake clearing, HUD settings slider/label/getter, SettingsSmokeTest persistence assertions, CombatFeedbackSmokeTest zero/half intensity assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `SettingsSmokeTest.tscn`、`CombatFeedbackSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点检查 0% / 50% / 100% 下受击、暴击、清房和 Boss 阶段震动是否自然，并判断是否需要按事件类型拆分强度。

## 2026-07-05 受击闪屏强度设置第一版
### 目标

- 把受击红色闪屏纳入玩家可调设置，让关键受击反馈保留可读性的同时降低视觉刺激风险。
- 保持默认 100% 不改变现有反馈，并允许 0% 完全关闭受击闪屏。

### 新增和修改内容
- `Main.gd` 新增 `DEFAULT_DAMAGE_FLASH_INTENSITY` 和 `_settings_damage_flash_intensity`，并纳入设置默认值、加载、保存和摘要导出。
- `Main._apply_gameplay_settings_to_player()` 会把 `damage_flash_intensity` 同步到 HUD。
- `HUD.gd` 新增 `set_damage_flash_intensity()`，按设置缩放 `show_damage_flash()` 的 alpha；0% 会清空当前闪屏并忽略新闪屏。
- `HUD.gd` Settings 面板新增 `Damage Flash` 滑条，Apply 时随现有设置一起回传。
- `SettingsSmokeTest` 扩展为验证默认值、应用值、配置文件持久化、重载后 UI 回显和 HUD 同步。
- `CombatFeedbackSmokeTest` 扩展为验证 0% 会抑制受击闪屏，50% 会按比例缩放闪屏 alpha。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 HP/Armor 资源反馈差距和第九十二批记录。

### 验证状态
```text
Damage-flash setting contract check: Main default/load/save/summary path, HUD sync path, `show_damage_flash()` intensity scaling, zero-intensity flash clearing/suppression, HUD settings slider/label/getter, SettingsSmokeTest persistence assertions, CombatFeedbackSmokeTest zero/half intensity assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `SettingsSmokeTest.tscn`、`CombatFeedbackSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点检查 0% / 50% / 100% 下受击闪屏是否既不遮挡弹幕，也能明确传达 HP 受损。

## 2026-07-05 战斗浮字强度设置第一版

### 目标

- 把伤害、暴击、治疗和护甲浮字纳入玩家可调设置，降低高弹幕或多弹丸场景下的信息噪声。
- 保持默认 100% 不改变现有反馈，并允许 0% 完全关闭战斗浮字，作为可读性和无障碍选项的第一步。

### 新增和修改内容

- `Main.gd` 新增 `DEFAULT_COMBAT_TEXT_INTENSITY` 和 `_settings_combat_text_intensity`，并纳入设置默认值、加载、保存、摘要导出和 Apply 流程。
- `_spawn_floating_text()` 现在会按 `combat_text_intensity` 缩放浮字颜色 alpha；强度为 0% 时直接返回，不生成浮字节点。
- `FloatingText.gd` 新增 `get_text_color()`，`Main.get_floating_text_snapshots()` 会返回浮字颜色，方便自动化验证强度缩放。
- `HUD.gd` Settings 面板新增 `Combat Text` 滑条和 getter，Apply 时随现有音量、显示、辅助瞄准、低血反馈、震屏和受击闪屏设置一起回传。
- `SettingsSmokeTest` 扩展为验证默认值、应用值、配置文件持久化、重载读取和设置 UI 回显。
- `CombatFeedbackSmokeTest` 扩展为验证 0% 抑制战斗浮字，50% 会按比例缩放伤害浮字 alpha。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 HP/Armor 资源反馈差距和第九十三批记录。

### 验证状态

```text
Combat-text setting contract check: Main default/load/save/summary/apply path, `_spawn_floating_text()` zero suppression and alpha scaling, FloatingText color getter, HUD settings slider/label/getter, SettingsSmokeTest persistence assertions, CombatFeedbackSmokeTest zero/half intensity assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `SettingsSmokeTest.tscn`、`CombatFeedbackSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点检查 0% / 50% / 100% 下多弹丸、暴击和 Boss 战浮字密度是否清晰，后续再决定是否按普通伤害、暴击、治疗和护甲拆分独立强度。

## 2026-07-05 Armor 破裂反馈第一版

### 目标

- 让 Armor 从有到无的瞬间具备独立反馈，避免玩家把“护甲被打空”误读成普通挡伤或单纯 HP 受伤。
- 继续复用现有事件、HUD、浮字、震动和程序化音频链路，先锁定可测试契约，后续再替换正式破甲动画和音效资源。

### 新增和修改内容

- `Events.gd` 新增 `player_shield_broken(absorbed_amount, current_shield)`，作为 Armor 归零的独立战斗反馈事件。
- `Player.take_damage()` 在 Armor 吸收伤害后降到 0 时触发破甲事件，同时保留 `player_shield_absorbed` 和后续 HP 伤害事件。
- `Main.gd` 订阅破甲事件后触发更强屏幕震动、HUD `Armor Broken` 消息和 `ARMOR BREAK` 浮字。
- `HUD.gd` 新增 Armor break 脉冲状态和测试接口；破甲时 Armor 行会短暂推向橙色，优先级高于 Armor 恢复脉冲。
- `AudioFeedback.gd` 新增 `armor_break` 程序化占位 SFX，并订阅 `player_shield_broken`。
- `CombatFeedbackSmokeTest` 扩展为验证真实破甲会产生 `ARMOR BREAK` 浮字、HUD Armor break 脉冲，并在持续时间后结束。
- `AudioFeedbackSmokeTest` 扩展为验证破甲事件会播放 `armor_break` SFX。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 HP/Armor 资源反馈差距和第九十四批记录。

### 验证状态

```text
Armor-break feedback contract check: player_shield_broken signal, Player take_damage zero-armor emit path, Main armor-break message/shake/floating text path, HUD armor-break pulse and test getter, AudioFeedback armor_break SFX, CombatFeedbackSmokeTest runtime assertions, AudioFeedbackSmokeTest direct event assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `CombatFeedbackSmokeTest.tscn`、`AudioFeedbackSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点检查 Armor 破裂浮字、橙色 HUD 脉冲和 `armor_break` 占位音效是否足够明显，但不会与 HP 受击闪屏、低血反馈或 Boss 预警抢占注意力。

## 2026-07-05 危险预警轮廓与脉冲可读性第一版

### 目标

- 让 Boss、精英、陷阱和敌人技能的危险预警在弹幕、浮字和场地元素叠加时仍然可读。
- 不改变伤害判定和触发时机，只增强通用 `DangerWarning` 的视觉层级，为后续正式预警动画建立可测试接口。

### 新增和修改内容

- `DangerWarning.gd` 新增通用 `Line2D` 轮廓层，圆形危险区和线形预警都会自动生成外轮廓。
- `_update_pulse()` 现在同时维护填充 alpha 和轮廓 alpha；轮廓会随时间轻微脉冲，并在接近触发时保持更高可见度。
- `DangerWarning.tscn` 新增 `Outline` 节点，所有现有预警来源都会继承该视觉增强。
- `DangerWarning.gd` 新增 `has_readability_outline_for_test()`、`get_visual_alpha_for_test()`、`get_outline_alpha_for_test()` 和 `get_warning_shape_name_for_test()`。
- `BossSmokeTest` 扩展为验证 Boss 阶段转换和环形弹幕预警具备可读轮廓。
- `EnemyVarietySmokeTest` 扩展为验证冲锋路线、散射弹道、区域危险和精英死亡爆炸预警具备可读轮廓。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 Biome/Boss/精英预警差距和第九十五批记录。

### 验证状态

```text
Danger-warning readability contract check: DangerWarning outline node, circle/line outline point generation, fill alpha plus outline pulse update path, outline/alpha test getters, BossSmokeTest boss warning assertions, EnemyVarietySmokeTest enemy warning assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `BossSmokeTest.tscn`、`EnemyVarietySmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点检查 Boss 阶段转换、Boss 环形弹幕、冲锋路线、散射弹道和精英死亡爆炸预警是否足够明显，但不会遮挡真实弹幕或玩家路径判断。

## 2026-07-05 危险预警差异化音效契约第一版

### 目标

- 让危险预警音效不再只有单一 `danger_warning`，先按线形/重威胁拆出稳定程序化占位 key。
- 不扩展事件签名，优先复用 `danger_warning_started(shape_name, duration, damage)`，为后续正式音频资源替换建立更细的接口。

### 新增和修改内容

- `DangerWarning.configure_line()` 新增可选 `warning_damage` 和 `source` 参数，保持旧调用兼容，同时让线形预警也能传递威胁信息。
- `Enemy.gd` 的远程弹道前摇和冲锋路线预警现在会把 `attack_damage` 与自身传给 `DangerWarning`。
- `BossEnemy.gd` 的线形 Boss 预警现在会把 `attack_damage` 与 Boss 来源传给 `DangerWarning`。
- `AudioFeedback.gd` 新增 `danger_warning_line` 和 `danger_warning_heavy` 程序化占位 SFX。
- `AudioFeedback._resolve_danger_warning_sfx_id()` 现在按 `shape_name`、`duration` 和 `damage` 分流：线形优先走 `danger_warning_line`，高伤害或长前摇圆形走 `danger_warning_heavy`，其余保留 `danger_warning`。
- `AudioFeedback.gd` 新增 `get_danger_warning_sfx_id_for_test()`、`reset_danger_warning_sfx_cooldown_for_test()` 和 `get_danger_warning_sfx_cooldown_for_test()`。
- `AudioFeedbackSmokeTest` 扩展为验证默认圆形、线形、长前摇重威胁和高伤害重威胁的 SFX key 分流。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新危险预警音效差距和第九十六批记录。

### 验证状态

```text
Danger-warning differentiated SFX contract check: DangerWarning line damage/source parameters, Enemy/Boss line warning damage forwarding, AudioFeedback danger_warning_line/danger_warning_heavy branches, resolver test getter, cooldown reset test helper, AudioFeedbackSmokeTest direct event assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `AudioFeedbackSmokeTest.tscn`、`EnemyVarietySmokeTest.tscn`、`BossSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点听线形弹道/冲锋、普通圆形危险、Boss 长前摇和高伤害精英/陷阱预警是否能被区分，但不会在密集预警中产生疲劳。

## 2026-07-05 训练奖励 toast 动画第一版

### 目标

- 让训练 drill 获得新徽章时具备独立奖励演出，不再只依赖 `Badge Unlocked` 文本行和普通 HUD message。
- 保持训练奖励不发放 Data Shards、不写入正式 run history、不改变角色熟练度，只增强局外训练循环的反馈层。

### 新增和修改内容

- `HUD.gd` 新增 `TrainingRewardToast` 动态面板，固定在训练面板下方，使用稳定尺寸避免挤压训练统计。
- `HUD.show_training_reward_toast()` 会显示 `TRAINING BADGE` 标题、drill 名、当前最佳评级和徽章 token。
- `_refresh_training_reward_toast()` 增加短淡入、保持、淡出和轻微 scale pulse，作为正式奖励演出前的程序化占位动画。
- `HUD.update_training_stats()` 现在会读取 `badge_notice_text` 自动触发 toast；空 notice 或训练重置会关闭 toast，避免上一轮提示残留。
- `HUD.gd` 新增 `is_training_reward_toast_visible_for_test()`、`get_training_reward_title_text_for_test()`、`get_training_reward_body_text_for_test()` 和 `get_training_reward_toast_alpha_for_test()`。
- `TrainingRoomSmokeTest` 扩展为验证 Burst Clean 徽章解锁后出现奖励 toast，且训练重置后 toast 隐藏。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新局外大厅/训练奖励差距和第九十七批记录。

### 验证状态

```text
Training reward toast contract check: HUD TrainingRewardToast node creation, badge_notice_text trigger path, toast fade/pulse timer path, reset hide path, test getters, TrainingRoomSmokeTest badge-unlock and reset assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `TrainingRoomSmokeTest.tscn`、`LobbyScreenSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察训练 toast 是否能明确表达徽章获得，又不会遮挡训练目标、武器槽和目标读数；后续正式化时应替换为徽章图标、粒子和更完整的奖励回看。

## 2026-07-05 内容资源 icon_key 占位契约第一版
### 目标

- 在不引入外部美术素材的前提下，为角色、武器、遗物、天赋和祝福建立统一图标资源 key 契约。
- 让 Outpost Hall 的图鉴详情卡不仅显示页签徽标，也能拿到当前条目的稳定 `icon_key`，后续正式图标替换时不用重走数据流。

### 新增和修改内容
- `RelicData.gd`、`PlayerCharacterData.gd`、`TalentData.gd` 和 `BlessingData.gd` 新增 `icon_key` 导出字段，对齐既有 `WeaponData.icon_key`。
- `Main.gd` 新增 `_resolve_content_icon_key()`；大厅 summary 会为五类内容输出 `icon_key`，显式资源字段优先，空值时按 `type_id` 稳定派生。
- `LobbyScreen.gd` 新增 `get_codex_detail_icon_key()`，并把当前详情条目的 key 写入 `CodexDetailIconLabel.tooltip_text`。
- `ContentPipelineSmokeTest` 新增资源脚本字段检查和资源级 icon key 解析检查。
- `LobbyScreenSmokeTest` 新增武器、遗物、天赋、祝福详情卡 icon key 断言，并覆盖筛选后详情卡 key 跟随条目切换。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新局外大厅正式图标缺口和第九十八批记录。

### 验证状态
```text
Content icon-key contract check: resource scripts expose icon_key, Main summary resolves explicit/fallback content keys, LobbyScreen detail card exposes tooltip/test getter, ContentPipelineSmokeTest validates key prefixes, LobbyScreenSmokeTest validates detail-card icon keys and filtered entry switching.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`LobbyScreenSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察详情卡页签徽标和 tooltip key 是否足够支撑正式图标替换；后续正式化时需要把 `icon_key` 映射到真实图标 Atlas，并保留缺失资源 fallback。

## 2026-07-05 CodexDetailCard 图标注册表与色块槽第一版
### 目标

- 把上一批的 `icon_key` 从纯数据字段推进为可见 UI 图标槽，减少“有 key 但没有展示承载位”的落差。
- 不引入外部素材，先用统一注册表、类型 token、占位色块和 tooltip 锁定后续正式 Atlas/Texture2D 的替换入口。

### 新增和修改内容
- 新增 `scripts/content/ContentIconRegistry.gd`：
  - `get_icon_type()` 从 `icon_key` 前缀或图鉴页签解析内容类型。
  - `get_type_token()` 统一输出 WPN / REL / TAL / BLS / CHR。
  - `get_placeholder_color()` 为武器、遗物、天赋、祝福和角色返回稳定占位颜色。
  - `get_placeholder_tooltip()` 生成包含显示名、类型和 `icon_key` 的 tooltip。
  - `has_placeholder_icon()` 供内容管线校验当前 key 是否能落到已知类型。
- `LobbyScreen.tscn` 在 `CodexDetailVisualRow` 新增 `CodexDetailIconSwatch`，固定 24x24，作为正式图标素材前的可见占位槽。
- `LobbyScreen.gd` 改为通过 `ContentIconRegistry` 驱动详情卡 icon token、色块颜色和 tooltip，并新增 `get_codex_detail_icon_swatch_color()` / `get_codex_detail_icon_tooltip_text()` 测试接口。
- 移除旧的 `_get_codex_page_icon_token()`，让图标 token 只来自注册表。
- `ContentPipelineSmokeTest` 新增注册表解析检查，覆盖 token、placeholder 识别和非 fallback 色彩。
- `LobbyScreenSmokeTest` 新增详情卡图标色块和 tooltip 断言，覆盖武器、遗物、天赋和祝福页。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新局外大厅图标槽进展和第九十九批记录。

### 验证状态
```text
Codex detail icon-slot contract check: ContentIconRegistry token/color/tooltip helpers, CodexDetailIconSwatch scene node, LobbyScreen registry-driven swatch/token/tooltip path, old page-token helper removal, ContentPipelineSmokeTest registry checks, LobbyScreenSmokeTest icon swatch and tooltip assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`LobbyScreenSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 24x24 色块在 720p 下是否拥挤、色彩是否和稀有度色条混淆；正式素材接入时应把注册表升级为 `icon_key` 到真实贴图或 Atlas region 的映射。

## 2026-07-05 内容图标默认映射资源表第一版
### 目标

- 把 `ContentIconRegistry` 从纯代码前缀解析推进为可编辑资源映射表，让正式 UI 图标接入时不用改大厅代码路径。
- 当前仍不引入真实图标贴图，只先固定 `icon_key -> definition -> token/color/texture_path/atlas_region` 的资源契约。

### 新增和修改内容
- 新增 `ContentIconDefinitionData.gd`：
  - `icon_key`：定义 key，可用于默认类型 key 或未来具体条目 key。
  - `content_type`：weapon / relic / talent / blessing / character。
  - `token`：当前文本徽标 fallback。
  - `placeholder_color`：正式贴图缺失时的色块 fallback。
  - `accessibility_label`：tooltip 和后续无障碍文案入口。
  - `texture_path` / `atlas_region`：正式图标贴图和图集区域预留字段。
- 新增 `ContentIconRegistryData.gd`，集中保存 registry id、版本、fallback 色和 definition 列表。
- 新增 `resources/ui/content_icon_registry.tres` 以及五个默认 definition 资源：
  - `weapon_default.tres`
  - `relic_default.tres`
  - `talent_default.tres`
  - `blessing_default.tres`
  - `character_default.tres`
- `ContentIconRegistry.gd` 现在优先读取 `res://resources/ui/content_icon_registry.tres`；未找到具体 key 时，会按当前 `icon_key` 前缀或页签落回对应类型默认 definition。
- `ContentIconRegistry.gd` 新增 `get_texture_path()`、`get_atlas_region()`、`get_registered_icon_count()`、`has_definition_for_type()` 和 `get_icon_definition()`。
- `ContentPipelineSmokeTest` 扩展为验证默认 registry 资源加载、五类定义完整、texture 路径允许为空、Atlas region placeholder 可读。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新局外大厅图标映射资源表进展和第一百批记录。

### 验证状态
```text
Content icon registry data contract check: ContentIconDefinitionData, ContentIconRegistryData, default registry resource, five default icon definition resources, registry-driven definition lookup, texture_path/atlas_region helpers, ContentPipelineSmokeTest registry completeness assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`LobbyScreenSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 后续正式图标接入时，应先为少量高频条目填入真实 `texture_path` 或 `atlas_region`，确认缺失贴图时仍能稳定回落到当前色块和 token。

## 2026-07-05 默认内容 SVG 图标与详情卡贴图槽第一版
### 目标

- 让内容图标系统不再停留在数据 key 和色块层面，先接入一组原创默认 SVG 资产。
- 保持实现路径可替换：注册表提供 `texture_path`，Lobby 详情卡优先显示 TextureRect，缺失时继续回落到现有色块。

### 新增和修改内容
- 新增 `art/ui/content_icons/default_weapon.svg`：武器默认图标。
- 新增 `art/ui/content_icons/default_relic.svg`：遗物默认图标。
- 新增 `art/ui/content_icons/default_talent.svg`：天赋默认图标。
- 新增 `art/ui/content_icons/default_blessing.svg`：祝福默认图标。
- 新增 `art/ui/content_icons/default_character.svg`：角色默认图标。
- 五个默认 `ContentIconDefinitionData` 资源的 `texture_path` 从空值改为对应 SVG 路径。
- `LobbyScreen.tscn` 在 `CodexDetailVisualRow` 新增 `CodexDetailIconTexture`，固定 24x24，用于显示 registry 指向的贴图。
- `LobbyScreen.gd` 新增：
  - `get_codex_detail_icon_texture_path()`
  - `is_codex_detail_icon_texture_visible()`
  - `_update_codex_detail_icon_texture()`
- `LobbyScreen.gd` 的详情卡视觉刷新现在会先读 `ContentIconRegistry.get_texture_path()` 并尝试 `load()`；加载到 `Texture2D` 时显示 TextureRect，否则显示原有色块 fallback。
- `ContentPipelineSmokeTest` 新增五类默认 icon path 校验，确保路径位于 `res://art/ui/content_icons/default_...` 且 `ResourceLoader.exists()` 为真。
- `LobbyScreenSmokeTest` 新增详情卡 texture path 和 TextureRect 可见性断言。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新图标素材进展和第一百零一批记录。

### 验证状态
```text
Default content SVG icon contract check: five SVG assets under art/ui/content_icons, default icon definition texture_path fields, CodexDetailIconTexture scene node, LobbyScreen texture-first/fallback path, ContentPipelineSmokeTest ResourceLoader path checks, LobbyScreenSmokeTest texture path and visibility assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`LobbyScreenSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 24x24 SVG 在不同缩放下是否清晰，以及 TextureRect 与 token、稀有度色条是否形成清晰层次；后续可把类型级 SVG 迁移到像素风 Atlas，并为高频武器/遗物补具体条目图标。

## 2026-07-05 高频图鉴条目专属 SVG 图标第一版
### 目标

- 在默认类型图标之上，补第一批高频图鉴条目的专属图标，验证 `icon_key` 精确匹配优先于类型 fallback。
- 覆盖大厅最常见浏览路径：默认武器、近战筛选武器、默认遗物、默认天赋和默认祝福。

### 新增和修改内容
- 新增 `art/ui/content_icons/basic_pistol.svg`，绑定 `weapon_basic_pistol`。
- 新增 `art/ui/content_icons/arc_blade.svg`，绑定 `weapon_arc_blade`。
- 新增 `art/ui/content_icons/sharp_rounds.svg`，绑定 `relic_sharp_rounds`。
- 新增 `art/ui/content_icons/steady_hands.svg`，绑定 `talent_steady_hands`。
- 新增 `art/ui/content_icons/deep_cell.svg`，绑定 `blessing_deep_cell`。
- 新增对应五个 `resources/ui/content_icons/*.tres` 条目级 icon definition。
- `resources/ui/content_icon_registry.tres` 的 `definitions` 扩展到十项，并将条目级 definition 排在默认 definition 前，保证具体 key 优先。
- `ContentPipelineSmokeTest` 新增条目专属图标断言：
  - 五个高频 key 必须指向 `art/ui/content_icons/` 下的专属 SVG。
  - 这些 key 不能回落到 `default_` 图标。
  - 未映射 probe key 仍必须回落到默认图标。
- `LobbyScreenSmokeTest` 新增详情卡专属图标路径断言：
  - Basic Pistol -> `basic_pistol.svg`
  - Arc Blade -> `arc_blade.svg`
  - Sharp Rounds -> `sharp_rounds.svg`
  - Steady Hands -> `steady_hands.svg`
  - Deep Cell -> `deep_cell.svg`
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新图标素材进展和第一百零二批记录。

### 验证状态
```text
Item-specific content icon contract check: five item SVG assets, five item ContentIconDefinitionData resources, registry definitions ordered before defaults, ContentPipelineSmokeTest item-specific and fallback assertions, LobbyScreenSmokeTest item texture path assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`LobbyScreenSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察条目级图标与类型默认图标的差异是否足够明显；后续应优先继续补当前图鉴 Featured Card 最常出现的武器、遗物和祝福。

## 2026-07-05 高频图鉴条目专属 SVG 图标第二批
### 目标

- 继续扩大图鉴详情卡的条目级图标覆盖，从默认入口推进到筛选/搜索路径中的高频 Featured Card。
- 优先覆盖当前 smoke 已经验证的部署武器、部署遗物、生存天赋和生存祝福路径。

### 新增和修改内容
- 新增 `art/ui/content_icons/snare_beacon.svg`，绑定 `weapon_snare_beacon`。
- 新增 `art/ui/content_icons/anchor_spool.svg`，绑定 `relic_anchor_spool`。
- 新增 `art/ui/content_icons/iron_vow.svg`，绑定 `talent_iron_vow`。
- 新增 `art/ui/content_icons/quiet_plate.svg`，绑定 `blessing_quiet_plate`。
- 新增对应四个 `resources/ui/content_icons/*.tres` 条目级 icon definition。
- `resources/ui/content_icon_registry.tres` 的 `definitions` 扩展到十四项，条目级 definition 继续排在默认 definition 前。
- `ContentPipelineSmokeTest` 扩展 item icon path 集合，验证第二批条目也不会回落到 `default_` 图标。
- `LobbyScreenSmokeTest` 新增详情卡图标路径断言：
  - Snare Beacon 搜索 -> `snare_beacon.svg`
  - Anchor Spool 部署路线 -> `anchor_spool.svg`
  - Iron Vow 生存天赋路线 -> `iron_vow.svg`
  - Quiet Plate 生存祝福路线 -> `quiet_plate.svg`
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新图标素材进展和第一百零三批记录。

### 验证状态
```text
Second-pass item icon contract check: four item SVG assets, four item ContentIconDefinitionData resources, registry definitions expanded to fourteen entries, ContentPipelineSmokeTest second-pass item path assertions, LobbyScreenSmokeTest filtered/search detail icon assertions, and alignment docs are present.
Static `load_steps` check: all `.tres` / `.tscn` resource step counts match ext/sub resources.
Static `res://` reference check: all scanned project script/resource/scene references resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`LobbyScreenSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察部署类和生存类图标是否足够容易和默认类型图标区分；后续可继续补角色页图标、元素武器图标和更完整的遗物流派图标。

## 2026-07-05 角色选择图标贴图槽第一版
### 目标

- 把内容图标注册表从图鉴详情卡扩展到 Outpost Hall 当前角色选择区，避免角色仍只停留在纯文本显示。
- 先覆盖当前 6 个原创角色的专属 SVG，为后续正式像素角色头像或 Atlas region 接入保留稳定 `character_*` key。

### 新增和修改内容
- `LobbyScreen.tscn` 新增 `CurrentCharacterIconRow`，包含 `CurrentCharacterIconSwatch`、`CurrentCharacterIconTexture` 和 `CurrentCharacterIconLabel`。
- `LobbyScreen.gd` 复用 `ContentIconRegistry` 根据大厅 summary 的 `current_character_id` 反查角色条目，并用角色 `icon_key` 刷新当前角色图标。
- `LobbyScreen.gd` 新增当前角色图标测试接口：`get_current_character_icon_key()`、`get_current_character_icon_texture_path()`、`is_current_character_icon_texture_visible()`、`get_current_character_icon_swatch_color()` 和 `get_current_character_icon_tooltip_text()`。
- `ContentIconRegistry.gd` 调整未命中回退逻辑，优先同类型默认 definition，避免专属 definition 顺序影响 fallback。
- 新增 6 个角色 SVG：`wanderer.svg`、`warden.svg`、`arcanist.svg`、`rift_runner.svg`、`emberwright.svg` 和 `field_medic.svg`。
- 新增对应 6 个 `resources/ui/content_icons/*.tres` 角色 icon definition。
- `resources/ui/content_icon_registry.tres` 的 `definitions` 扩展到二十项。
- `ContentPipelineSmokeTest` 扩展为验证 6 个角色专属 SVG 路径、未映射角色 fallback 和注册表数量。
- `LobbyScreenSmokeTest` 新增默认 Wanderer 图标槽断言，以及连续切换到 Rift Runner 后图标 key/path/visible 状态跟随更新的断言。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新图标素材进展和第一百零四批记录。

### 验证状态
```text
Character selection icon-slot contract check: six character SVG assets, six character ContentIconDefinitionData resources, registry definitions expanded to twenty entries, LobbyScreen current-character icon accessors, ContentPipelineSmokeTest character path/fallback assertions, LobbyScreenSmokeTest Wanderer/Rift Runner icon assertions, and alignment docs are present.
Static `load_steps` check: 222 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 297 scanned project script/resource/scene/import files resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`LobbyScreenSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察角色选择图标在 720p 下是否拥挤，以及当前角色切换时贴图刷新是否足够清晰。

## 2026-07-05 局内三选一奖励按钮图标第一版
### 目标

- 把内容图标注册表从局外大厅继续推进到局内 Build 选择流程，让遗物、Boss 后天赋和事件祝福三选一不再只依赖文字。
- 不改变奖励生成、权重和选择逻辑，只增强按钮视觉信息和测试契约。

### 新增和修改内容
- `HUD.gd` 预加载 `ContentIconRegistry`，并在 `show_relic_choices()`、`show_talent_choices()` 和 `show_blessing_choices()` 中给每个选项按钮设置注册表贴图。
- 选择按钮图标 key 解析规则：
  - 资源显式 `icon_key` 优先。
  - 空值时按当前选择类型和资源 `id` 派生：`relic_<id>`、`talent_<id>`、`blessing_<id>`。
  - 注册表未找到专属 definition 时回退到对应类型默认 SVG。
- 选择按钮 tooltip 会附加注册表图标说明，便于调试和后续无障碍说明复用。
- `HUD.gd` 新增三选一按钮图标测试接口：`get_relic_choice_icon_key()`、`get_relic_choice_icon_texture_path()`、`is_relic_choice_icon_visible()` 和 `get_relic_choice_icon_tooltip_text()`。
- `RelicSmokeTest` 扩展为验证遗物三选一按钮图标 key、注册表路径、可见状态和 tooltip。
- `TalentSmokeTest` 扩展为验证 Boss 后天赋三选一按钮图标由注册表驱动。
- `EventRoomSmokeTest` 扩展为验证事件祝福三选一按钮图标由注册表驱动。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新图标素材进展和第一百零五批记录。

### 验证状态
```text
In-run choice icon contract check: HUD choice buttons resolve explicit/fallback icon keys, use ContentIconRegistry texture paths for relic/talent/blessing choices, expose icon state test getters, and extend RelicSmokeTest/TalentSmokeTest/EventRoomSmokeTest assertions.
Static `load_steps` check: 222 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 297 scanned project script/resource/scene/import files resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `RelicSmokeTest.tscn`、`TalentSmokeTest.tscn`、`EventRoomSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 64px SVG 图标是否挤压三选一按钮文字；如 720p 下过密，下一步应把选择按钮升级为图标列 + 文本列的结构化条目。

## 2026-07-05 小地图特殊房间 icon token 第一版
### 目标

- 提升三层随机地牢的小地图可读性，让特殊房间不再只依赖内部 `room_type` 字母。
- 先锁定稳定 token、房型 label 和 tooltip 契约，后续可替换为正式小地图贴图。

### 新增和修改内容
- `HUD.gd` 的 `_make_minimap_marker()` 现在给每个房间 marker 写入 `room_type`、`room_icon`、`room_label` 和 `room_state` meta。
- 小地图 token 调整为更清晰的房型符号：
  - `S` Start
  - `C` Combat
  - `EL` Elite
  - `CH` Challenge
  - `X` Trap
  - `*` Reward
  - `!` Event
  - `W` Armory
  - `+` Healing
  - `$` Shop
  - `B` Boss
- 小地图 tooltip 改为显示层级、biome 名、房间 ID、玩家可读房型和探索状态，避免直接暴露内部房型 key。
- `HUD.gd` 新增测试接口：`get_minimap_marker_icon_for_type()`、`get_minimap_marker_label_for_type()` 和 `get_minimap_marker_tooltip_for_type()`。
- `DungeonGenerationSmokeTest` 扩展为验证已生成房型的小地图 icon token、房型 label 和 tooltip 语义。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新小地图图标化进展和第一百零六批记录。

### 验证状态
```text
Minimap special-room icon-token contract check: HUD markers expose stable icon tokens, player-facing room labels, stateful tooltips, and DungeonGenerationSmokeTest validates generated room marker semantics.
Static `load_steps` check: 222 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 297 scanned project script/resource/scene/import files resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `DungeonGenerationSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn` 无头启动。
- 实机试玩应重点观察 `EL` / `CH` 这类双字符 token 在 720p 小地图上是否清晰；若过密，下一步应改为正式贴图或图标字体。

## 2026-07-05 当前武器槽注册表贴图第一版

### 目标

- 把内容图标注册表从图鉴、大厅角色和局内三选一按钮继续推进到战斗 HUD 当前武器槽。
- 让当前武器槽可以直接显示注册表 SVG 贴图，同时保留原类型短码作为贴图缺失 fallback。

### 本次改动

- `HUD.tscn` 在 `WeaponSlotIdentityRow` 新增 `WeaponSlotIconTexture`，固定 22x22，承载当前武器注册表贴图。
- `Main.gd` 的 `_get_player_loadout_summaries()` 为每个武器 summary 增加 `id` 和 `icon_key`。
- `HUD.gd` 的当前武器槽刷新逻辑：
  - 规范化 loadout entry 时保留 `id` 和解析后的 `icon_key`。
  - 使用 `ContentIconRegistry.get_texture_path(icon_key, "weapons")` 解析贴图路径。
  - 加载到 `Texture2D` 时显示贴图并隐藏原类型短码；贴图缺失时继续显示短码 fallback。
  - `get_weapon_slot_visual_summary_for_test()` 暴露 `icon_key`、`icon_texture_path`、`icon_texture_visible` 和 `icon_tooltip`。
- `WeaponSmokeTest` 扩展为验证开局 Basic Pistol 使用专属图标、切换武器后 icon key 和贴图路径跟随注册表更新。
- `ShopSmokeTest` 扩展为验证购买武器后，HUD 负载预览和当前槽图标贴图同步新武器。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新当前武器槽图标化进展和第一百零七批记录。

### 验证状态
```text
Current weapon-slot registry icon check: HUD weapon slot resolves icon_key through ContentIconRegistry, exposes texture path/visibility/tooltips for tests, and weapon/shop smoke assertions cover switch and purchase paths.
Static `load_steps` check: 222 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 296 scanned project script/resource/scene/import files resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn`、`ShopSmokeTest.tscn` 和 `UILayoutSmokeTest.tscn`。
- 实机试玩应重点观察 22px 当前武器 SVG 在 720p 下是否清晰，以及贴图隐藏短码后玩家是否仍能快速读出武器类型。

## 2026-07-05 三武器负载预览注册表贴图第一版

### 目标

- 把当前武器槽图标能力继续下沉到三武器负载预览，让玩家不仅知道当前武器，也能通过图标预读 1/2/3 槽内容。
- 保持原有短名、稀有度/类型短码和 tooltip，不让贴图接入破坏已有文字可读性。

### 本次改动

- `HUD.tscn` 把 `WeaponSlotLoadoutRow` 下的 `LoadoutSlot1/2/3` 从纯 Label 改为 `HBoxContainer`，每槽包含：
  - `LoadoutSlotIcon`：14x14 `TextureRect`，显示注册表武器贴图。
  - `LoadoutSlotLabel`：保留原槽位编号、稀有度/类型短码和短名。
- `HUD.gd` 的三槽负载预览逻辑：
  - 缓存每槽的容器、图标和文本 Label。
  - 动态新增槽位时创建同样的图标/文本结构。
  - 每槽通过 `ContentIconRegistry.get_texture_path(icon_key, "weapons")` 加载贴图。
  - 空槽隐藏图标，已有武器加载失败时仍保留文本 fallback。
  - tooltip 附加注册表图标说明和当前 icon key。
- `get_weapon_slot_loadout_summary_for_test()` 新增：
  - `icon_keys`
  - `icon_texture_paths`
  - `icon_texture_visible`
  - `tooltips`
- `WeaponSmokeTest` 扩展为验证开局 slot 1、切换到 slot 2 后的负载预览图标 key、贴图路径和可见状态。
- `ShopSmokeTest` 扩展为验证购买武器后，当前激活负载槽的图标 key、贴图路径和可见状态同步新武器。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新三槽负载预览图标化进展和第一百零八批记录。

### 验证状态
```text
Loadout preview registry icon check: HUD loadout slots render TextureRect + Label controls, expose icon key/path/visibility/tooltips, and WeaponSmokeTest/ShopSmokeTest assert switch and purchase paths.
Static `load_steps` check: 222 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 296 scanned project script/resource/scene/import files resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn`、`ShopSmokeTest.tscn` 和 `UILayoutSmokeTest.tscn`。
- 实机试玩应重点观察 14px 负载槽图标在 720p 下是否足够清楚，三槽图标 + 短名是否过挤。

## 2026-07-05 武器槽图标 ready/switch 脉冲第一版

### 目标

- 让已经接入注册表贴图的武器槽不只是静态图标，而能参与切槽和换弹完成反馈。
- 复用已有 ready/switch 计时器，避免新增一套独立动画状态。

### 本次改动

- `HUD.gd` 新增 `_get_weapon_slot_icon_modulate()` 和 `_refresh_weapon_slot_icon_modulates()`：
  - 当前槽默认白色。
  - 非当前槽降低 alpha，保持三槽预览主次关系。
  - 切换武器时当前图标和激活负载槽图标偏黄。
  - 换弹完成 ready 脉冲时当前图标和激活负载槽图标偏绿。
- `_process()` 中的 `_weapon_ready_pulse_timer` 和 `_weapon_slot_switch_pulse_timer` 刷新现在同步刷新图标颜色。
- `show_weapon_ready_pulse()` 和 `_refresh_weapon_slot_status()` 同步调用图标颜色刷新，确保手动触发和换弹完成路径一致。
- `get_weapon_slot_visual_summary_for_test()` 新增 `icon_modulate`。
- `get_weapon_slot_loadout_summary_for_test()` 新增 `icon_modulates`。
- `WeaponSmokeTest` 扩展为验证：
  - 切换武器后当前武器图标和激活负载槽图标偏黄。
  - 换弹完成后当前武器图标和激活负载槽图标偏绿。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新武器槽图标反馈进展和第一百零九批记录。

### 验证状态
```text
Weapon slot icon pulse check: HUD icon modulates reuse ready/switch timers, visual summaries expose icon_modulate/icon_modulates, and WeaponSmokeTest asserts yellow switch pulse plus green reload-ready pulse.
Static `load_steps` check: 222 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 296 scanned project script/resource/scene/import files resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn` 和 `UILayoutSmokeTest.tscn`。
- 实机试玩应重点观察黄色切槽脉冲和绿色 ready 脉冲是否能被玩家读到，又不会和弹匣段、边框、文字脉冲显得重复。

## 2026-07-05 三槽负载预览槽框第一版

### 目标

- 让三武器负载预览不只依赖图标和短名，而具备可扫描的独立槽框。
- 强化当前槽、非当前槽、切槽和 ready 状态的视觉层级，为后续正式武器槽 UI 打基础。

### 本次改动

- `HUD.tscn` 把 `WeaponSlotLoadoutRow` 下的 `LoadoutSlot1/2/3` 从 `HBoxContainer` 升级为 `PanelContainer`，内部结构为：
  - `LoadoutSlotMargin`
  - `LoadoutSlotContent`
  - `LoadoutSlotIcon`
  - `LoadoutSlotLabel`
- `HUD.gd` 为每个负载槽缓存独立 `StyleBoxFlat`，并在刷新时设置：
  - 暗色背景。
  - 稀有度边框。
  - 当前槽 2px 粗边框。
  - 非当前槽 1px 轻边框。
  - 切槽时当前槽边框偏黄。
  - 换弹完成 ready 时当前槽边框偏绿。
- 动态新增槽位也会创建同样 `PanelContainer + MarginContainer + HBoxContainer` 结构。
- `get_weapon_slot_loadout_summary_for_test()` 新增：
  - `slot_border_colors`
  - `slot_border_widths`
  - `slot_background_colors`
- `WeaponSmokeTest` 扩展为验证开局当前槽粗边框、非当前槽轻边框、切槽黄边框和 ready 绿边框。
- `ShopSmokeTest` 扩展为验证购买武器后当前激活负载槽仍保留可读边框。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新三槽负载预览槽框进展和第一百一十批记录。

### 验证状态
```text
Loadout slot frame check: HUD loadout slots are PanelContainer controls with runtime StyleBoxFlat backgrounds/borders, summaries expose slot border/background fields, and WeaponSmokeTest/ShopSmokeTest assert active/inactive/switch/ready/purchase slot-frame states.
Static `load_steps` check: 222 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 296 scanned project script/resource/scene/import files resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn`、`ShopSmokeTest.tscn` 和 `UILayoutSmokeTest.tscn`。
- 实机试玩应重点观察三槽边框是否在 720p 下过密，当前槽粗边框是否和主武器槽大边框形成清晰层级。

## 2026-07-05 三槽负载弹药摘要第一版

### 目标

- 让三槽负载预览除了图标、槽框和短名之外，还能快速读到弹匣状态。
- 不伪造当前架构不存在的“离手武器独立弹药”；当前槽显示真实 ammo，非当前槽显示容量和能耗。

### 本次改动

- `Main.gd` 的 `_get_player_loadout_summaries()` 新增字段：
  - `magazine_size`
  - `current_ammo`
  - `is_reloading`
  - `is_active`
- 当前槽 summary 会读取 `player.weapon.get_current_ammo()`、`get_magazine_size()` 和 `is_reloading()`。
- 非当前槽 summary 只写 `magazine_size`，`current_ammo` 保持 `-1`，避免暗示它们有独立弹药状态。
- `HUD.gd` 的三槽负载文本追加弹药摘要：
  - 当前槽：`12/12`、`0/12` 或 `RLD`。
  - 非当前槽：`M6/E2` 这类弹匣容量/能耗摘要。
- `HUD.update_ammo()` 会同步当前负载 entry，并刷新 `WeaponSlotLoadoutRow`。
- Tooltip 补充弹药/弹匣/能耗说明，降低短码理解成本。
- `get_weapon_slot_loadout_summary_for_test()` 新增 `ammo_summaries`。
- `WeaponSmokeTest` 扩展为验证开局当前槽真实弹药、非当前槽容量摘要、换弹中 `RLD`、换弹完成满弹摘要。
- `ShopSmokeTest` 扩展为验证购买武器后激活负载槽显示新武器满弹摘要。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新三槽负载弹药摘要进展和第一百一十一批记录。

### 验证状态
```text
Loadout ammo summary check: Main loadout summaries expose current-slot ammo and non-current magazine capacity, HUD loadout labels/tooltips expose ammo_summaries, and WeaponSmokeTest/ShopSmokeTest assert start/reload/reloaded/purchase paths.
Static `load_steps` check: 391 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 296 scanned project script/resource/scene/import files resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn`、`ShopSmokeTest.tscn` 和 `UILayoutSmokeTest.tscn`。
- 实机试玩应重点观察 `M6/E2` 这类非当前槽摘要是否足够直观；若过密，后续可改为图标化弹匣/能耗小徽标。

## 2026-07-05 三槽负载能量可用性提示第一版

### 目标

- 让三槽负载预览不只展示武器能耗，还能告诉玩家当前能量是否足够支撑该槽武器开火。
- 继续强化类《元气骑士》需要的“快速扫一眼就知道能不能切/能不能打”的局内可读性。

### 本次改动

- `HUD.gd` 为每个负载槽新增能量状态：
  - `free`：零能耗武器。
  - `ready`：当前能量足够支付该武器能耗。
  - `blocked`：当前能量不足。
  - `empty`：空槽。
- `update_energy()`、`show_energy_warning()` 和 warning 计时淡出都会刷新 `WeaponSlotLoadoutRow`，避免三槽预览状态滞后于 Energy 行。
- 低能量时，受影响负载槽的文字和背景会轻微偏向警示色；能量恢复后回到 ready/常规颜色。
- 负载槽 tooltip 追加 `Free to fire`、`Energy ready 当前/消耗` 或 `Need N energy`，降低 `E2` 这类短码的理解成本。
- `get_weapon_slot_loadout_summary_for_test()` 新增 `energy_states`、`energy_needs` 和 `label_colors`。
- `WeaponSmokeTest` 扩展为验证开局 free/ready、低能量 blocked、缺口数、tooltip Need、警示色和恢复 ready。
- `ShopSmokeTest` 扩展为验证购买武器后激活负载槽会暴露可用能量状态。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新三槽负载能量可用性提示进展和第一百一十二批记录。

### 验证状态
```text
Loadout energy availability check: HUD loadout slots expose free/ready/blocked/empty energy states, refresh on energy changes and warning fade, and WeaponSmokeTest/ShopSmokeTest assert low-energy blocked plus restored/purchased ready paths.
Static `load_steps` check: 391 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 296 scanned project script/resource/scene/import files resolve (`.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `WeaponSmokeTest.tscn`、`ShopSmokeTest.tscn` 和 `UILayoutSmokeTest.tscn`。
- 实机试玩应重点观察低能量 blocked 槽的橙色提示是否足够明显，又不会和切槽黄脉冲、ready 绿脉冲混淆。

## 2026-07-05 早期武器专属 SVG 图标包第一版

### 目标

- 继续把内容图标从“默认色块/少量高频条目”推进到更多真实条目专属贴图，提升局外图鉴和局内三槽负载的可读性。
- 优先覆盖默认负载和早期武器池，先让玩家最常见的武器不再共用默认武器图标。

### 本次改动

- 新增 8 个原创 64px SVG 武器图标：
  - `shotgun.svg`
  - `energy_staff.svg`
  - `ricochet_blaster.svg`
  - `nova_core.svg`
  - `blast_launcher.svg`
  - `laser_lance.svg`
  - `coil_carbine.svg`
  - `shatter_fan.svg`
- 新增对应 `ContentIconDefinitionData` 资源：
  - `shotgun.tres`
  - `energy_staff.tres`
  - `ricochet_blaster.tres`
  - `nova_core.tres`
  - `blast_launcher.tres`
  - `laser_lance.tres`
  - `coil_carbine.tres`
  - `shatter_fan.tres`
- `content_icon_registry.tres` 接入这 8 个定义，`load_steps` 更新为 30；武器专属 SVG 图标覆盖从 3 个提升到 11 个。
- `ContentPipelineSmokeTest` 将注册表计数门槛提升到 28，并验证新增武器图标都指向 `art/ui/content_icons` 的专属路径。
- `WeaponSmokeTest` 扩展默认三槽负载断言：slot 2 使用 `shotgun.svg`，slot 3 使用 `energy_staff.svg`。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新图标覆盖进展和第一百一十三批记录。

### 验证状态
```text
Early weapon icon pack check: 8 new weapon SVGs and 8 ContentIconDefinitionData resources exist, content_icon_registry load_steps is valid, ContentPipelineSmokeTest covers all new registry paths, and WeaponSmokeTest asserts Shotgun/Energy Staff loadout icons.
Static `load_steps` check: 407 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 304 scanned project script/resource/scene/import files resolve (`.godot/editor` cache excluded).
Static content icon pack check: 8 SVGs and definitions exist.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`WeaponSmokeTest.tscn` 和 `LobbyScreenSmokeTest.tscn`。
- 实机试玩应重点观察新增 8 个 SVG 图标在 14px 负载槽、64px 图鉴详情卡和 720p 窗口下是否仍可识别。

## 2026-07-05 中期武器专属 SVG 图标包第一版

### 目标

- 继续扩大武器专属图标覆盖，让图鉴、奖励、商店和武器槽预览逐步摆脱默认武器图标。
- 优先补中期内容池中形态差异明显的武器，覆盖扇形、激光、核心、喷射、冰刃、爆炸、守御近战和反制近战等方向。

### 本次改动

- 新增 8 个原创 64px SVG 武器图标：
  - `storm_fan.svg`
  - `prism_ray.svg`
  - `halo_kernel.svg`
  - `ember_sprayer.svg`
  - `frost_sickle.svg`
  - `slag_comet.svg`
  - `guard_cleaver.svg`
  - `riposte_saber.svg`
- 新增对应 `ContentIconDefinitionData` 资源：
  - `storm_fan.tres`
  - `prism_ray.tres`
  - `halo_kernel.tres`
  - `ember_sprayer.tres`
  - `frost_sickle.tres`
  - `slag_comet.tres`
  - `guard_cleaver.tres`
  - `riposte_saber.tres`
- `content_icon_registry.tres` 接入这 8 个定义，`load_steps` 更新为 38；武器专属 SVG 图标覆盖从 11 个提升到 19 个。
- `ContentPipelineSmokeTest` 将注册表计数门槛提升到 36，并验证新增中期武器图标都指向 `art/ui/content_icons` 的专属路径。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新图标覆盖进展和第一百一十四批记录。

### 验证状态
```text
Mid-weapon icon pack check: 8 new mid-weapon SVGs and 8 ContentIconDefinitionData resources exist, content_icon_registry load_steps is valid, and ContentPipelineSmokeTest covers all new registry paths.
Static `load_steps` check: 423 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 312 scanned project script/resource/scene/import files resolve (`.godot/editor` cache excluded).
Static mid-weapon icon pack check: 8 SVGs and definitions exist.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`LobbyScreenSmokeTest.tscn` 和 `WeaponSmokeTest.tscn`。
- 实机试玩应重点观察新增近战、喷射、激光和核心类图标在图鉴详情卡中是否能和已有枪械类图标拉开识别差异。

## 2026-07-05 全武器专属 SVG 图标覆盖第一版

### 目标

- 把当前 30 把武器从“部分专属图标 + 默认武器图标 fallback”推进到全武器都有专属 UI 图标。
- 继续保持原创几何占位风格，避免复制参考作品造型；本批解决的是图鉴、奖励、商店和三槽负载预览的可读图标覆盖，不替代正式战斗美术。

### 本次改动

- 新增 11 个原创 64px SVG 武器图标：
  - `bulwark_fan.svg`
  - `cinder_mortar.svg`
  - `coil_bow.svg`
  - `ember_mine.svg`
  - `mirror_sickle.svg`
  - `orbit_sower.svg`
  - `pulse_needler.svg`
  - `rift_spear.svg`
  - `sentry_seed.svg`
  - `storm_capacitor.svg`
  - `vault_lance.svg`
- 新增对应 `ContentIconDefinitionData` 资源：
  - `bulwark_fan.tres`
  - `cinder_mortar.tres`
  - `coil_bow.tres`
  - `ember_mine.tres`
  - `mirror_sickle.tres`
  - `orbit_sower.tres`
  - `pulse_needler.tres`
  - `rift_spear.tres`
  - `sentry_seed.tres`
  - `storm_capacitor.tres`
  - `vault_lance.tres`
- `content_icon_registry.tres` 接入这 11 个定义，`load_steps` 更新为 49；武器专属 SVG 图标覆盖从 19 个提升到 30 个。
- `ContentPipelineSmokeTest` 将注册表计数门槛提升到 47，并验证全部剩余武器图标都指向 `art/ui/content_icons` 的专属路径。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新图标覆盖进展和第一百一十五批记录。

### 验证状态
```text
Full weapon icon coverage check: 11 new SVGs and ContentIconDefinitionData resources exist, content_icon_registry load_steps is 49, and registry definitions count is 47.
Static `load_steps` check: 249 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 323 scanned project script/resource/scene/import files resolve (1006 references, `.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`LobbyScreenSmokeTest.tscn` 和 `WeaponSmokeTest.tscn`。
- 实机试玩应重点观察新增部署、蓄力、长枪、地雷和召唤类图标在 14px 负载槽、64px 图鉴详情卡和 720p 窗口下是否仍可识别。

## 2026-07-05 早期遗物专属 SVG 图标包第一版

### 目标

- 让早期奖励池和原始遗物池中的高频遗物摆脱默认遗物图标，提升奖励三选一、局外图鉴和 Build 路线浏览的可读性。
- 延续当前原创几何占位风格，只解决 UI 图标识别层，不替代后续正式像素图标、动效或音频资源。

### 本次改动

- 新增 8 个原创 64px SVG 遗物图标：
  - `quick_trigger.svg`
  - `split_chamber.svg`
  - `phase_tip.svg`
  - `vampire_fang.svg`
  - `guardian_ward.svg`
  - `adrenaline_charm.svg`
  - `lucky_primer.svg`
  - `swift_loader.svg`
- 新增对应 `ContentIconDefinitionData` 资源：
  - `quick_trigger.tres`
  - `split_chamber.tres`
  - `phase_tip.tres`
  - `vampire_fang.tres`
  - `guardian_ward.tres`
  - `adrenaline_charm.tres`
  - `lucky_primer.tres`
  - `swift_loader.tres`
- `content_icon_registry.tres` 接入这 8 个定义，`load_steps` 更新为 57；遗物专属 SVG 图标覆盖从 2 个提升到 10 个。
- `ContentPipelineSmokeTest` 将注册表计数门槛提升到 55，并验证新增遗物图标都指向 `art/ui/content_icons` 的专属路径。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新图标覆盖进展和第一百一十六批记录。

### 验证状态
```text
Early relic icon pack check: 8 new SVGs and ContentIconDefinitionData resources exist, content_icon_registry load_steps is 57, and registry definitions count is 55.
Static `load_steps` check: 257 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 331 scanned project script/resource/scene/import files resolve (1030 references, `.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`RelicSmokeTest.tscn` 和 `LobbyScreenSmokeTest.tscn`。
- 实机试玩应重点观察新增遗物图标在奖励三选一按钮、图鉴详情卡和搜索/筛选结果中是否能区分射速、多弹、贯穿、回血、护甲、加速、暴击和换弹路线。

## 2026-07-05 扩展遗物专属 SVG 图标包第一版

### 目标

- 继续降低遗物奖励、图鉴详情和 Build 路线筛选中的默认遗物图标占比。
- 优先覆盖第一轮扩展遗物池中的关键路线：暴击、贯穿、多弹丸、击杀回血、清房护甲、受伤加速、伤害和射速。

### 本次改动

- 新增 8 个原创 64px SVG 遗物图标：
  - `keen_sights.svg`
  - `hollow_needle.svg`
  - `scatter_lens.svg`
  - `field_rations.svg`
  - `bulwark_plate.svg`
  - `redline_boots.svg`
  - `breach_powder.svg`
  - `momentum_coil.svg`
- 新增对应 `ContentIconDefinitionData` 资源：
  - `keen_sights.tres`
  - `hollow_needle.tres`
  - `scatter_lens.tres`
  - `field_rations.tres`
  - `bulwark_plate.tres`
  - `redline_boots.tres`
  - `breach_powder.tres`
  - `momentum_coil.tres`
- `content_icon_registry.tres` 接入这 8 个定义，`load_steps` 更新为 65；遗物专属 SVG 图标覆盖从 10 个提升到 18 个。
- `ContentPipelineSmokeTest` 将注册表计数门槛提升到 63，并验证新增扩展遗物图标都指向 `art/ui/content_icons` 的专属路径。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新图标覆盖进展和第一百一十七批记录。

### 验证状态
```text
Expansion relic icon pack check: 8 new SVGs and ContentIconDefinitionData resources exist, content_icon_registry load_steps is 65, and registry definitions count is 63.
Static `load_steps` check: 265 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 339 scanned project script/resource/scene/import files resolve (1054 references, `.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`RelicSmokeTest.tscn` 和 `LobbyScreenSmokeTest.tscn`。
- 实机试玩应重点观察新增扩展遗物图标在奖励三选一、图鉴详情卡和筛选结果里是否能和早期遗物图标拉开识别差异。

## 2026-07-05 中段遗物专属 SVG 图标包第一版

### 目标

- 继续推进 35 遗物池的专属图标覆盖，把中段 Build 路线从默认遗物图标中拆出来。
- 优先覆盖射速、暴击、多弹丸、护甲、吸血、近战伤害和状态流派，让奖励三选一和图鉴筛选更容易扫读。

### 本次改动

- 新增 9 个原创 64px SVG 遗物图标：
  - `steady_capacitor.svg`
  - `gilded_tip.svg`
  - `echo_chamber.svg`
  - `breakwater_guard.svg`
  - `siphon_clasp.svg`
  - `kinetic_ram.svg`
  - `volatile_oil.svg`
  - `ember_catalyst.svg`
  - `lingering_ash.svg`
- 新增对应 `ContentIconDefinitionData` 资源：
  - `steady_capacitor.tres`
  - `gilded_tip.tres`
  - `echo_chamber.tres`
  - `breakwater_guard.tres`
  - `siphon_clasp.tres`
  - `kinetic_ram.tres`
  - `volatile_oil.tres`
  - `ember_catalyst.tres`
  - `lingering_ash.tres`
- `content_icon_registry.tres` 接入这 9 个定义，`load_steps` 更新为 74；遗物专属 SVG 图标覆盖从 18 个提升到 27 个。
- `ContentPipelineSmokeTest` 将注册表计数门槛提升到 72，并验证新增中段遗物图标都指向 `art/ui/content_icons` 的专属路径。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新图标覆盖进展和第一百一十八批记录。

### 验证状态
```text
Mid relic icon pack check: 9 new SVGs and ContentIconDefinitionData resources exist, content_icon_registry load_steps is 74, and registry definitions count is 72.
Static `load_steps` check: 274 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 348 scanned project script/resource/scene/import files resolve (1081 references, `.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`RelicSmokeTest.tscn` 和 `LobbyScreenSmokeTest.tscn`。
- 实机试玩应重点观察新增中段遗物图标在奖励三选一、图鉴详情卡和筛选结果中是否能稳定区分射速/暴击/状态/护甲路线。

## 2026-07-05 全遗物专属 SVG 图标覆盖第一版

### 目标

- 补齐当前 35 个遗物池的剩余专属 UI 图标，让奖励三选一、商店、图鉴详情和 Build 路线筛选不再依赖默认遗物图标。
- 优先完成当前 Alpha 下限内容池的可读图标覆盖；后续再转向正式像素 Atlas、美术 polish 和天赋/祝福图标扩展。

### 本次改动

- 新增 8 个原创 64px SVG 遗物图标：
  - `parry_grip.svg`
  - `warding_hinge.svg`
  - `counterweight_core.svg`
  - `draw_weight.svg`
  - `quick_windup.svg`
  - `stored_spark.svg`
  - `tripwire_amplifier.svg`
  - `heart_core.svg`
- 新增对应 `ContentIconDefinitionData` 资源：
  - `parry_grip.tres`
  - `warding_hinge.tres`
  - `counterweight_core.tres`
  - `draw_weight.tres`
  - `quick_windup.tres`
  - `stored_spark.tres`
  - `tripwire_amplifier.tres`
  - `heart_core.tres`
- `content_icon_registry.tres` 接入这 8 个定义，`load_steps` 更新为 82；遗物专属 SVG 图标覆盖从 27 个提升到 35 个。
- `ContentPipelineSmokeTest` 将注册表计数门槛提升到 80，并验证全部遗物图标都指向 `art/ui/content_icons` 的专属路径。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新图标覆盖进展和第一百一十九批记录。

### 验证状态
```text
Full relic icon coverage check: 8 new SVGs and ContentIconDefinitionData resources exist, content_icon_registry load_steps is 82, and registry definitions count is 80.
Static `load_steps` check: 282 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 356 scanned project script/resource/scene/import files resolve (1105 references, `.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`RelicSmokeTest.tscn` 和 `LobbyScreenSmokeTest.tscn`。
- 实机试玩应重点观察全部遗物专属图标在奖励三选一和图鉴详情卡中是否能稳定区分挡弹、蓄力、部署、生命、状态、暴击、护甲和射速路线。

## 2026-07-05 天赋/祝福专属 SVG 图标补齐第一版

### 目标

- 补齐当前天赋和祝福资源池的最后两个默认图标 fallback，让奖励三选一、Boss 后天赋选择、事件祝福选择和局外图鉴都能使用条目级图标。
- 将当前武器、遗物、天赋、祝福和角色五类核心内容的 UI 图标覆盖推进到完整第一版。

### 本次改动

- 新增 2 个原创 64px SVG 条目图标：
  - `kinetic_rounds.svg`
  - `ember_tithe.svg`
- 新增对应 `ContentIconDefinitionData` 资源：
  - `kinetic_rounds.tres`
  - `ember_tithe.tres`
- `content_icon_registry.tres` 接入这 2 个定义，`load_steps` 更新为 84；注册表定义总数从 80 提升到 82。
- `ContentPipelineSmokeTest` 将注册表计数门槛提升到 82，并验证 `talent_kinetic_rounds` 和 `blessing_ember_tithe` 都指向 `art/ui/content_icons` 的专属路径。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新图标覆盖进展和第一百二十批记录。

### 验证状态
```text
Talent/blessing icon coverage check: 2 new SVGs and ContentIconDefinitionData resources exist, content_icon_registry load_steps is 84, and registry definitions count is 82.
Static `load_steps` check: 284 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 358 scanned project script/resource/scene/import files resolve (1111 references, `.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because the environment currently has a usage-limit blocker.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`TalentSmokeTest.tscn`、`EventRoomSmokeTest.tscn` 和 `LobbyScreenSmokeTest.tscn`。
- 实机试玩应重点观察 Boss 后天赋选择和事件祝福三选一按钮中的新增图标是否能和已有天赋/祝福图标区分。

## 2026-07-05 房间类型 SVG 图标注册表第一版

### 目标

- 把小地图房间 token 从纯文本占位推进到可映射正式贴图的注册表契约。
- 优先覆盖当前三层路线会生成的主要房型，让后续替换为像素 Atlas 或正式 UI 图标时不需要再改 Dungeon/HUD 数据结构。

### 本次改动

- 新增 12 个原创 64px 房间 SVG 图标：
  - `default_room.svg`
  - `room_start.svg`
  - `room_combat.svg`
  - `room_elite.svg`
  - `room_challenge.svg`
  - `room_trap.svg`
  - `room_reward.svg`
  - `room_event.svg`
  - `room_armory.svg`
  - `room_healing.svg`
  - `room_shop.svg`
  - `room_boss.svg`
- 新增对应 `ContentIconDefinitionData` 资源：
  - `room_default.tres`
  - `room_start.tres`
  - `room_combat.tres`
  - `room_elite.tres`
  - `room_challenge.tres`
  - `room_trap.tres`
  - `room_reward.tres`
  - `room_event.tres`
  - `room_armory.tres`
  - `room_healing.tres`
  - `room_shop.tres`
  - `room_boss.tres`
- `ContentIconDefinitionData` 和 `ContentIconRegistry` 新增 `room` 内容类型、默认颜色、`RM` 类型 token 和 `rooms` 页面推断。
- `content_icon_registry.tres` 接入这 12 个定义，`load_steps` 更新为 96；注册表定义总数从 82 提升到 94。
- HUD 小地图 marker 继续显示现有 token，同时在 metadata 和测试访问器中暴露 `room_icon_key` 与 `room_icon_texture_path`。
- `ContentPipelineSmokeTest` 扩展为校验 room 图标注册、专属 SVG 路径和 room fallback；`DungeonGenerationSmokeTest` 扩展为校验每类小地图房间的 token、label、tooltip、icon key 和 SVG 路径。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新图标覆盖进展和第一百二十一批记录。

### 验证状态
```text
Room icon pack check: 12 room SVG files and 12 room ContentIconDefinitionData resources exist, content_icon_registry load_steps is 96, and registry definitions count is 94.
Room definition content_type check: all 12 room_*.tres files declare content_type=room.
Static `load_steps` check: 296 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 370 scanned project script/resource/scene/import files resolve (1147 references, `.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because `godot` is not available on the current PowerShell PATH.
```

### 仍需人工复核

- 恢复 Godot 执行权限后，优先运行 `ContentPipelineSmokeTest.tscn`、`DungeonGenerationSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn`。
- 实机试玩应重点观察小地图在 720p 下是否能承载房间图标替换；后续第 122 批已把 marker 从 Label 升级为 TextureRect + fallback token 结构。

## 2026-07-05 小地图房间 SVG 贴图 marker 第一版

### 目标

- 让第 121 批注册的房间 SVG 不只作为路径和 metadata 存在，而是真正进入 HUD 小地图显示。
- 保留已有小地图测试契约和 token fallback，避免贴图加载失败时房间类型完全不可读。

### 本次改动

- `HUD.gd` 的 `_make_minimap_marker()` 从返回纯 `Label` 改为返回 `PanelContainer` 控件。
- 每个小地图房间 marker 现在包含：
  - `TextureRect`：优先加载 `ContentIconRegistry.get_texture_path(room_icon_key, "rooms")` 指向的 `room_*` SVG。
  - fallback `Label`：贴图缺失时显示原 token。
  - `StyleBoxFlat`：按当前房间、已清理、已访问和未访问状态调整边框、底色和图标透明度。
- 既有 `room_icon`、`room_icon_key`、`room_icon_texture_path`、`room_label`、`room_state` metadata 继续保留。
- 新增 `get_minimap_marker_texture_visible_for_type()` 测试访问器，供烟测确认 SVG 不只是路径存在，而是实际加载并显示。
- `DungeonGenerationSmokeTest` 扩展为要求小地图 marker 暴露 texture visibility，并断言已生成房型的 SVG texture 可见。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新小地图 SVG 贴图进展和第一百二十二批记录。

### 验证状态
```text
Minimap SVG marker contract check: HUD creates PanelContainer/TextureRect/fallback marker controls and DungeonGenerationSmokeTest asserts room texture visibility.
Static `load_steps` check: 296 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 370 scanned project script/resource/scene/import files resolve (1147 references, `.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because `godot` is not available on the current PowerShell PATH.
```

### 仍需人工复核

- 恢复 Godot 执行权限或配置 Godot PATH 后，优先运行 `DungeonGenerationSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn`。
- 实机试玩应重点观察 24x22 小地图 marker 在 720p 下是否过密，当前房间边框是否足够明显，以及双字符房型 fallback 是否仍能在贴图缺失时读清。

## 2026-07-05 Biome 房间视觉主题第一版

### 目标

- 让三层主题层从“敌人池、Boss 和名称不同”继续推进到运行时房间视觉也有第一版差异。
- 先用数据化 tint 管线驱动地板、墙体和障碍颜色，避免在正式地形/TileMap 美术完成前继续停留在单一房间色调。

### 本次改动

- `BiomeData.gd` 新增视觉主题字段：
  - `visual_floor_tint`
  - `visual_wall_color`
  - `visual_obstacle_tint`
  - `visual_accent_color`
  - `visual_tint_strength`
- 三个 Alpha biome 资源写入独立主题：
  - `outer_warrens`：偏荒野/苔色地板和墙体。
  - `iron_catacombs`：偏铁锈/金属暖色墙体和障碍。
  - `void_foundry`：偏紫色虚空/铸炉地板、墙体和 accent。
- `DungeonController.gd` 将 biome 视觉字段写入：
  - 房间 record。
  - biome summary。
  - 运行时 `CombatRoom` 导出属性。
- `CombatRoom.gd` 新增 biome 视觉导出属性和 `get_biome_visual_summary()`。
- `CombatRoom.gd` 在应用 `RoomLayoutData` 时会把布局基础地板色与 biome floor tint 混合；墙体直接使用 biome wall color；动态障碍颜色按 biome obstacle tint 混合。
- `ContentPipelineSmokeTest` 扩展为校验 biome visual color key 唯一、视觉颜色字段存在、tint strength 已启用。
- `DungeonGenerationSmokeTest` 扩展为校验 record、biome summary、runtime `CombatRoom` 三者视觉字段一致，并验证运行时地板颜色等于布局基础色按 biome tint 混合后的结果。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 Biome 视觉主题进展和第一百二十三批记录。

### 验证状态
```text
Biome visual theme contract check: BiomeData/resources, DungeonController, CombatRoom, ContentPipelineSmokeTest, and DungeonGenerationSmokeTest all expose and verify biome visual theme fields.
Static `load_steps` check: 296 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 370 scanned project script/resource/scene/import files resolve (1147 references, `.godot/editor` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because `godot` is not available on the current PowerShell PATH.
```

### 仍需人工复核

- 恢复 Godot 执行权限或配置 Godot PATH 后，优先运行 `ContentPipelineSmokeTest.tscn`、`DungeonGenerationSmokeTest.tscn`、`EnemyVarietySmokeTest.tscn` 和 `Main.tscn`。
- 实机试玩应重点观察三层房间色调是否能被玩家感知，又不会降低弹幕、危险预警、敌人和掉落物的可读性。

## 2026-07-05 Biome 独立布局池第一版

### 目标

- 让三层主题层不只改变敌人池、Boss 和颜色，也能改变普通战斗房间的空间压力。
- 先用现有 `RoomLayoutData` 资源建立每层独立布局池，避免在正式 TileMap 地形资产完成前继续依赖全局随机布局。

### 本次改动

- 三个 Alpha biome 资源新增独立 `layout_pool`：
  - `outer_warrens`：`crossfire`、`open_cross`、`corner_nests`、`wide_arena`。
  - `iron_catacombs`：`bunker`、`narrow_gap`、`split_cover`、`center_ring`。
  - `void_foundry`：`ambush_corners`、`box_maze`、`long_lane`、`twin_islands`。
- `DungeonController.gd` 现在会在普通战斗、精英和挑战房间优先合并当前 Biome 的 `layout_pool`，并在 Biome 池不足时回退到原有全局房型池。
- 奖励、事件、治疗、商店、陷阱和 Boss 房保留专用布局池，避免功能房间识别度被主题布局覆盖。
- 房间 record、biome summary 和 debug map 都会暴露 `biome_layout_pool_ids`，方便复现路线和排查布局选择来源。
- `ContentPipelineSmokeTest` 新增三层布局池资源校验，确认每层包含预期布局 ID 且不重复。
- `DungeonGenerationSmokeTest` 新增布局池传递与使用校验，确认 summary 保留布局池 ID，并要求战斗类房间优先使用当前层布局池。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 Biome 独立布局池进展和第一百二十四批记录。

### 验证状态
```text
Biome layout pool contract check: biome resources, DungeonController, ContentPipelineSmokeTest, and DungeonGenerationSmokeTest expose and verify independent biome layout pools.
Static `load_steps` check: 296 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 370 scanned project script/resource/scene/import files resolve (1159 references, `.godot` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because `godot` is not available on the current PowerShell PATH.
```

### 仍需人工复核

- 恢复 Godot 执行权限或配置 Godot PATH 后，优先运行 `ContentPipelineSmokeTest.tscn`、`DungeonGenerationSmokeTest.tscn` 和 `Main.tscn`。
- 实机试玩应重点观察三层布局压力是否能被玩家感知：外层是否更开阔，中层是否更像掩体/窄口推进，终层是否更偏伏击和长线压迫。

## 2026-07-05 Biome 奖励权重接线第一版

### 目标

- 让 `BiomeData.reward_weight_multiplier` 不再只是资源字段，而是进入实际奖励生成路径。
- 将三层地牢的差异从敌人池、布局池和视觉主题继续推进到奖励曲线，让后层奖励有更高价值倾向。

### 本次改动

- `DungeonController.gd` 将 Biome 奖励倍率写入：
  - 房间 record。
  - biome summary。
  - debug map 文本。
  - 运行时 `CombatRoom`。
- `CombatRoom.gd` 新增 `biome_reward_weight_multiplier` 和 `get_biome_reward_summary()`，并在实例化奖励对象前把 biome id、名称和奖励倍率写入奖励节点。
- `RewardChest.gd` 新增 Biome 奖励配置：
  - 宝箱金币会按 Biome 奖励倍率缩放。
  - 武器池和本地遗物池选择改为按 `drop_weight` 加权。
  - 通过 `RelicSystem.choose_reward_relic(source, multiplier)` 传递 Biome 奖励倍率。
- `ShopInventory.gd` 新增 Biome 奖励配置，商店武器和商店遗物选择会使用当前层奖励倍率。
- `RelicPickup.gd` 新增 Biome 奖励配置，奖励房遗物三选一会调用 `get_reward_choices(choice_count, "reward", multiplier)`。
- `EventShrine.gd` 新增 Biome 奖励配置，事件金币、遗物选择和祝福选择会使用当前层奖励倍率。
- `RelicSystem.gd` 的实际遗物权重现在会乘上 `RelicData.drop_weight`，并用 Biome 倍率提高 rare、epic、legendary 的相对权重。
- `BlessingSystem.gd` 的祝福选择支持兼容的第三个倍率参数，并同样按稀有度层级应用 Biome 奖励倍率。
- `ContentPipelineSmokeTest` 扩展为校验三层 `reward_weight_multiplier` 目标值和路线递增。
- `DungeonGenerationSmokeTest` 扩展为校验 room record、biome summary 和运行时 `CombatRoom` 的奖励倍率一致。
- `ChestSmokeTest`、`ShopSmokeTest`、`EventRoomSmokeTest` 和 `RelicSmokeTest` 扩展为校验宝箱/商店/事件节点继承 Biome 奖励配置，以及遗物权重计算确实包含 `drop_weight` 和 Biome 倍率。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 Biome 奖励权重接线进展和第一百二十五批记录。

### 验证状态
```text
Biome reward multiplier contract check: metadata, CombatRoom bridge, chests, shops, relic pickups, event shrines, relic weighting, and blessing weighting expose and use biome reward multipliers.
Static `load_steps` check: 296 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 370 scanned project script/resource/scene/import files resolve (1159 references, `.godot` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because `godot` is not available on the current PowerShell PATH.
```

### 仍需人工复核

- 恢复 Godot 执行权限或配置 Godot PATH 后，优先运行 `ContentPipelineSmokeTest.tscn`、`DungeonGenerationSmokeTest.tscn`、`ChestSmokeTest.tscn`、`ShopSmokeTest.tscn`、`EventRoomSmokeTest.tscn`、`RelicSmokeTest.tscn` 和 `Main.tscn`。
- 实机试玩应重点观察三层奖励体感：后层是否更容易出现高价值遗物/武器/祝福，但不会让早期局面因为过快膨胀而失衡。

## 2026-07-05 小地图按层展示第一版

### 目标

- 将“三层地牢”在 HUD 小地图上从单行房间串联推进为按 Biome 分段展示。
- 保持已有房间 SVG marker、tooltip 和当前房间高亮，同时让测试能按层校验房间数量。

### 本次改动

- `HUD.gd` 的 `update_minimap()` 现在按 `biome_index` 生成 `MinimapLayer*` 段，每段包含层标题和 `MinimapLayerMarkers` marker 行。
- 小地图 marker 新增 `biome_index` / `biome_name` metadata，并继续保留 `room_type`、`room_icon_key`、`room_icon_texture_path` 和 `room_state` metadata。
- HUD 新增 `get_minimap_biome_layer_count()`、`get_minimap_marker_count_for_biome()`、`get_minimap_biome_layer_text()` 和 `get_minimap_biome_layer_tooltip()` 测试访问器。
- `_get_minimap_marker_for_type()` 改为递归查询 layer 内 marker，保持原有房型图标访问器兼容。
- `DungeonGenerationSmokeTest` 扩展为校验小地图 3 个 Biome 层段、每段房间数和记录一致、层标题/tooltip 包含 Biome 显示名。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新小地图按层展示进展和第一百二十六批记录。

### 验证状态
```text
Layered minimap contract check: HUD groups minimap markers by biome layer and DungeonGenerationSmokeTest verifies layer count, layer labels, tooltips, and per-biome marker counts.
Static `load_steps` check: 296 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 371 scanned project script/resource/scene/import files resolve (1162 references, `.godot` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because `godot` is not available on the current PowerShell PATH.
```

### 仍需人工复核

- 恢复 Godot 执行权限或配置 Godot PATH 后，优先运行 `DungeonGenerationSmokeTest.tscn`、`UILayoutSmokeTest.tscn` 和 `Main.tscn`。
- 实机试玩应重点观察小地图 3 个层段在 720p 下是否过宽；如过宽，下一步应把 `MinimapRow` 外层升级为横向滚动或压缩网格。

## 2026-07-05 结算路线与 Build 快照第一版

### 目标

- 补齐三层地牢结构里的结算记录要求：到达层数、击败 Boss、路线、seed 和主要 Build。
- 让结算 summary 既能给 HUD 展示，也能作为后续历史统计、回放、seed 复现和 Build 统计的稳定数据源。

### 本次改动

- `Main.gd` 的 run summary 新增路线字段：
  - `route_nodes`：生成路线中每个房间的 ID、Biome、房型、主线/分支、状态和 Boss 标记。
  - `route_signature`：按 Biome 压缩后的生成路线签名。
  - `visited_route_signature`：按已访问/已清理/当前房间压缩的实际经过路线签名。
  - `boss_route`：每层 Boss 房、Biome 名称、Boss 显示名和最终 Boss 标记。
- `Main.gd` 的 run summary 新增 Build 字段：
  - `build_route_counts`：从武器 `tags`、遗物/天赋/祝福 `build_tags` 汇总的构筑标签计数。
  - `primary_build_routes` / `primary_build_route_text`：按标签出现次数生成的主要 Build 路线摘要。
- `Main.gd` 现在记录 `defeated_boss_names`，真实 Boss 节点存在时读取 `display_name`，烟测或空节点触发时从路线 Boss 信息回退。
- `RelicSystem.get_relic_summaries()` 新增 `build_tags`、`conflict_tags` 和 `tags`，让遗物构筑方向进入结算统计。
- HUD 结算总览新增到达 Biome 名称、生成路线签名、主要 Build 路线和击败 Boss 名称列表；6 个结果分组保持不变。
- `RunSummarySmokeTest` 扩展为校验 seed、路线节点、三层路线签名、Boss 路线、击败 Boss 名称、Build 标签计数和 HUD 文本。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新结算路线与 Build 快照进展和第一百二十七批记录。

### 验证状态
```text
Run settlement route/build contract check: Main summary, HUD result text, RelicSystem summaries, and RunSummarySmokeTest expose route, boss, seed, reached biome, and primary build fields.
Static `load_steps` check: 296 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 371 scanned project script/resource/scene/import files resolve (1162 references, `.godot` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because `godot` is not available on the current PowerShell PATH.
```

### 仍需人工复核

- 恢复 Godot 执行权限或配置 Godot PATH 后，优先运行 `RunSummarySmokeTest.tscn`、`DungeonGenerationSmokeTest.tscn`、`FullRunSmokeTest.tscn` 和 `Main.tscn`。
- 实机试玩应重点观察结算面板的路线签名是否过长；如果在 720p 结果面板里换行过密，下一步应把路线签名改为可展开详情或单独的 Run Details 分组。

## 2026-07-05 AimAssistController 锁定权重第一版

### 目标

- 补齐规划中 `AimAssistController` 应封装“目标选择、锁定权重和自动瞄准强度”的接口要求。
- 降低弱辅助瞄准在相近目标间频繁切换的风险，同时保持默认关闭和弱辅助定位。

### 本次改动

- `AimAssistController.gd` 新增 `lock_weight`、`_locked_target` 和 `_last_pick_score`。
- `AimAssistController.pick_target()` 现在会：
  - 先按目标角度/距离计算候选评分。
  - 对仍有效的锁定目标叠加 `lock_weight`。
  - 选择新目标后更新锁定目标和最后评分。
- `AimAssistController.gd` 新增 `get_candidate_score()`、`set_locked_target()`、`clear_lock()`、`get_locked_target()` 和 `get_last_pick_score()`。
- `Player.configure_aim_assist()` 新增兼容的 `lock_weight` 参数，并把锁定权重传入子节点 `AimAssistController`。
- `Player.gd` 新增 `get_aim_assist_lock_weight_for_test()`、`set_aim_assist_locked_target_for_test()` 和 `clear_aim_assist_lock_for_test()` 测试访问器。
- `AimAssistSmokeTest` 扩展为校验未锁定时选最佳角度目标、锁定权重保留附近锁定目标、清锁后恢复评分优先。
- `ContentPipelineSmokeTest` 扩展为直接校验 `AimAssistController` 的候选评分、锁定目标、清锁和锁定权重契约。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新 AimAssistController 锁定权重进展和第一百二十八批记录。

### 验证状态
```text
AimAssist lock-weight contract check passed.
Static `load_steps` check: 296 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 371 scanned project script/resource/scene/import files resolve (1162 references, `.godot` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because `godot` is not available on the current PowerShell PATH.
```

### 仍需人工复核

- 恢复 Godot 执行权限或配置 Godot PATH 后，优先运行 `AimAssistSmokeTest.tscn`、`ContentPipelineSmokeTest.tscn`、`SettingsSmokeTest.tscn` 和 `Main.tscn`。
- 实机试玩应重点观察多个敌人密集时的锁定手感；如果目标保持过强，下一步应按武器类型调低 `lock_weight` 或让近战/散射武器使用更低锁定权重。

## 2026-07-05 事件房商人折扣结果第一版

### 目标

- 把事件房从单一 `Blood Pact` 祝福结果推进为可配置的多结果框架。
- 先落地一个可验证的商人折扣事件，让事件房具备“生命代价换后续经济收益”的风险收益选择。

### 本次改动

- `EventShrine.gd` 新增 `reward_mode`，默认继续走 `blessing_choice`，并支持 `relic_choice` 和 `shop_discount`。
- `EventShrine.gd` 新增 `shop_discount_multiplier`、`shop_discount_charges` 和 `get_event_summary()`，方便后续事件数据化和烟测读取。
- 商人折扣事件触发后会消耗生命、发出 `special_event_resolved`，然后通过玩家接口写入一次性商店折扣并结算 `reward_collected`。
- `Player.gd` 新增一次性商店折扣状态、购买价格计算、折扣消耗和摘要读取接口。
- `ShopItem.gd` 新增 `get_purchase_price_for_player()`，购买扣款、失败退款和购买事件金额都使用具体玩家的成交价；折扣只在成功购买后消耗。
- 商店物品靠近显示会在折扣生效时展示折扣价和原价，普通购买路径继续保留原始价格。
- `EventRoomSmokeTest.gd` 新增商人折扣事件覆盖，验证事件结算、折扣状态、折扣成交价和购买后消耗。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新事件房商人折扣进展和第一百二十九批记录。

### 验证状态
```text
Event-shop discount contract check passed.
Static `load_steps` check: 296 `.tres` / `.tscn` files scanned and all resource step counts match ext/sub resources.
Static `res://` reference check: 370 scanned project script/resource/scene/import files resolve (1160 references, `.godot` cache excluded).
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because `godot` is not available on the current PowerShell PATH and no local Godot executable was found under the workspace.
```

### 仍需人工复核

- 恢复 Godot 执行权限或配置 Godot PATH 后，优先运行 `EventRoomSmokeTest.tscn`、`ShopSmokeTest.tscn`、`BalanceSmokeTest.tscn` 和 `Main.tscn`。
- 实机试玩应重点观察折扣事件的提示是否清晰，以及折扣价是否会让第一商店经济窗口过早失去约束。

## 2026-07-05 事件房随机结果池与诅咒武器第一版

### 目标

- 把事件房从“脚本可配置多结果”推进到真实路线会自然出现多结果。
- 补齐规划中的“诅咒换武器”风险收益事件，让特殊房间不再只围绕祝福和经济折扣。

### 本次改动

- `EventShrine.gd` 新增 `event_variant`，支持 `manual`、`blood_pact`、`merchant_oath`、`cursed_weapon` 和 `random`。
- `EventShrine.tscn` 默认配置为 `event_variant = "random"`，实战事件房现在会在 Blood Pact、Merchant Oath 和 Cursed Armory 间选择。
- `EventShrine.gd` 新增 `cursed_weapon_pool` 和 `cursed_weapon_max_health_penalty`；Cursed Armory 触发后会给玩家武器并施加最大生命惩罚。
- `Player.gd` 新增 `apply_event_curse()`、`get_event_curse_summary()` 和本局诅咒重置逻辑，避免事件诅咒污染角色重选或新局。
- `EventRoomSmokeTest.gd` 新增 Cursed Armory 覆盖，验证事件摘要、最大生命惩罚、武器奖励和诅咒记录。
- `FullRunSmokeTest.gd` 改为先读取事件摘要，再按祝福、商人折扣或诅咒武器分别验证结果，适配真实随机事件池。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新事件房随机结果池与第一百三十批记录。

### 验证状态
```text
Cursed/random event final contract check passed.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because `godot` is not available on the current PowerShell PATH and no local Godot executable was found under the workspace.
```

### 仍需人工复核

- 恢复 Godot 执行权限或配置 Godot PATH 后，优先运行 `EventRoomSmokeTest.tscn`、`FullRunSmokeTest.tscn`、`ShopSmokeTest.tscn` 和 `Main.tscn`。
- 实机试玩应重点观察随机事件池是否打断路线节奏；如果 Cursed Armory 在低血状态下过于惩罚，下一步应按层级或当前 HP 调整出现权重。

## 2026-07-05 挑战房变体第一版

### 目标

- 把挑战房从单一精英双波战斗推进为可扩展变体系统。
- 先落地一个机关压力变体，让特殊房间中的高风险房间不只靠敌人数值变化提供差异。

### 本次改动

- `RoomData.gd` 新增 `challenge_variant` 和 `challenge_variant_label`，挑战房资源可声明固定变体或 `random`。
- `challenge_room.tres` 默认改为 `challenge_variant = "random"`，真实路线会在 Elite Gauntlet 与 Hazard Rush 间解析。
- `DungeonController.gd` 在生成阶段按 seed、房间索引和 biome 解析挑战变体，并写入房间 record、Debug Map 和 `CombatRoom` 配置。
- `CombatRoom.gd` 新增 `get_challenge_summary()` 和 `is_challenge_hazard_active()`；Hazard Rush 会在战斗期间复用现有危险预警循环，不使用陷阱房倒计时清场。
- `ChallengeRoomSmokeTest.gd` 扩展为校验 record/runtime 变体一致性，并按变体检查 Hazard Rush 的危险预警是否启动。
- `DungeonGenerationSmokeTest.gd`、`FullRunSmokeTest.gd` 和 `ContentPipelineSmokeTest.gd` 同步补充挑战变体契约。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新挑战房变体进展和第一百三十一批记录。

### 验证状态
```text
Challenge variant contract check passed.
Static load_steps check passed: 296 files scanned.
Static res:// reference check passed: 370 files scanned, 1174 references resolved.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because `godot` is not available on the current PowerShell PATH and no local Godot executable was found under the workspace.
```

### 仍需人工复核

- 恢复 Godot 执行权限或配置 Godot PATH 后，优先运行 `ChallengeRoomSmokeTest.tscn`、`DungeonGenerationSmokeTest.tscn`、`FullRunSmokeTest.tscn` 和 `Main.tscn`。
- 实机试玩应重点观察 Hazard Rush 的预警密度和精英双波叠加是否过压；如果过压，下一步应按 biome 或当前层数降低 hazard cycle size。

## 2026-07-05 事件房短时过载规则第一版

### 目标

- 补齐事件房“临时规则/短时收益”方向，让事件池不只提供长期祝福、经济折扣或诅咒换武器。
- 先落地一个可验证的原创事件结果，为后续限时挑战、雕像祝福或房间规则改写保留玩家侧接口。

### 本次改动

- `Player.gd` 新增 `apply_temporary_combat_rule()`、`get_temporary_rule_summary()` 和短时规则计时清理逻辑。
- 玩家短时规则目前会提高武器伤害和射速，参与 `get_damage_multiplier()` 与 `get_fire_rate_multiplier()`，过期后自动恢复。
- `EventShrine.gd` 新增 `Overclock Trial` 事件变体、`temporary_rule` 奖励模式和短时规则参数。
- `EventShrine.tscn` 的随机事件池现在可自然抽到 Overclock Trial。
- `EventRoomSmokeTest.gd` 新增短时规则事件覆盖，验证事件摘要、事件/奖励信号、倍率提升和过期清理。
- `FullRunSmokeTest.gd` 新增 `temporary_rule` 分支处理，适配真实随机事件池。
- `ContentPipelineSmokeTest.gd` 新增 EventShrine 临时规则接口检查。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新事件房短时过载进展和第一百三十二批记录。

### 验证状态
```text
Temporary event rule contract check passed.
Static load_steps check passed: 296 files scanned.
Static res:// reference check passed: 370 files scanned, 1175 references resolved.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because `godot` is not available on the current PowerShell PATH and no local Godot executable was found under the workspace.
```

### 仍需人工复核

- 恢复 Godot 执行权限或配置 Godot PATH 后，优先运行 `EventRoomSmokeTest.tscn`、`FullRunSmokeTest.tscn`、`ContentPipelineSmokeTest.tscn` 和 `Main.tscn`。
- 实机试玩应重点观察 Overclock Trial 的 18 秒窗口是否足够让玩家主动寻找下一场战斗；如果经常在跑图中浪费，下一步应改为“下一房间生效”或延长持续时间。

## 2026-07-05 事件驱动祝福第一版

### 目标

- 把祝福系统从纯被动加成推进到事件驱动规则，符合“祝福改变本局规则”的目标。
- 先落地一个低风险、可验证的清房触发祝福，避免一次性扩太多触发事件导致难以平衡。

### 本次改动

- 新增 `resources/blessings/afterglow_circuit.tres`，原创祝福 `Afterglow Circuit` 会在清房时恢复能量。
- `BlessingSystem.gd` 接入 `Events.room_cleared`，按 `trigger_event` 应用事件驱动祝福。
- 祝福效果应用层新增 `recover_energy`、`heal`、`gain_shield` 和 `temporary_combat_rule` 的通用映射，并保留原有 passive -> `apply_relic_effect()` 路径。
- `get_blessing_summaries()` 增加 `effect_duration`，让运行时摘要能表达事件触发祝福参数。
- `EventRoomSmokeTest.gd` 新增 `Afterglow Circuit` 覆盖，验证获得祝福、摘要字段和清房回能。
- `ContentPipelineSmokeTest.gd` 将祝福池门槛提升到 4，并要求至少一个事件驱动祝福。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新事件驱动祝福进展和第一百三十三批记录。

### 验证状态
```text
Event-driven blessing contract check passed.
Static load_steps check passed: 297 files scanned.
Static res:// reference check passed: 371 files scanned, 1178 references resolved.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because `godot` is not available on the current PowerShell PATH and no local Godot executable was found under the workspace.
```

### 仍需人工复核

- 恢复 Godot 执行权限或配置 Godot PATH 后，优先运行 `EventRoomSmokeTest.tscn`、`ContentPipelineSmokeTest.tscn`、`FullRunSmokeTest.tscn` 和 `Main.tscn`。
- 实机试玩应重点观察清房回能是否让高能耗武器过早失去资源约束；如果过强，应降低恢复量或限定每个 biome 的触发次数。

## 2026-07-05 事件驱动祝福多触发第一版

### 目标

- 把事件驱动祝福从单一清房触发扩展到击杀和受伤触发，让祝福更接近“改变本局规则”的 Build 系统。
- 给高频触发类祝福补数据化触发间隔，避免击杀祝福每次击杀都触发导致资源循环失控。

### 本次改动

- `BlessingData.gd` 新增 `trigger_interval` 字段，默认每次触发生效，可由资源配置为每 N 次生效。
- `BlessingSystem.gd` 监听 `Events.enemy_died` 和 `Events.player_damaged`，并用每个祝福独立的触发计数处理 `on_kill`、`on_hurt` 和 `on_room_clear`。
- 新增 `spark_dividend.tres`：每 3 次击杀恢复 6 Energy。
- 新增 `brace_current.tres`：玩家受到 HP 伤害后恢复 1 Armor。
- 为 `Afterglow Circuit`、`Spark Dividend` 和 `Brace Current` 新增专属 SVG 图标与 `ContentIconDefinitionData`，并接入 `content_icon_registry.tres`。
- `EventRoomSmokeTest.gd` 新增击杀/受伤触发覆盖，验证击杀触发间隔、第三次击杀回能和受伤回护甲。
- `ContentPipelineSmokeTest.gd` 将祝福池门槛提升到 6，验证 `on_kill` / `on_hurt`、`trigger_interval` 和 97 个图标注册定义。
- `LobbyScreenSmokeTest.gd` 更新祝福图鉴首项和 survival 筛选期望，确认新祝福图标可被详情卡使用。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步更新事件驱动祝福多触发进展和第一百三十四批记录。

### 验证状态
```text
Expanded event-driven blessing contract check passed.
Static load_steps check passed: 302 files scanned.
Static res:// reference check passed: 376 files scanned, 1193 references resolved.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because `godot` is not available on the current PowerShell PATH and no local Godot executable was found under the workspace.
```

### 仍需人工复核

- 恢复 Godot 执行权限或配置 Godot PATH 后，优先运行 `EventRoomSmokeTest.tscn`、`ContentPipelineSmokeTest.tscn`、`LobbyScreenSmokeTest.tscn` 和 `FullRunSmokeTest.tscn`。
- 实机试玩应重点观察 `Spark Dividend` 是否让高耗能武器在群怪房里回能过快，以及 `Brace Current` 是否在连续受击时给玩家过多容错。
## 2026-07-05 祝福触发反馈与结算统计第一版
### 目标

- 把清房、击杀和受伤触发祝福从后台数值变化推进为玩家可读的局内反馈。
- 让死亡/通关结算记录事件祝福实际触发次数，为后续平衡 `Afterglow Circuit`、`Spark Dividend` 和 `Brace Current` 提供统计入口。

### 本次改动

- `Events.gd` 新增 `blessing_triggered` 信号，携带祝福资源、触发事件、效果类型和效果值。
- `BlessingSystem.gd` 在事件驱动祝福效果实际应用成功后才发出 `blessing_triggered`，避免无效触发进入 HUD 和结算统计。
- `Main.gd` 新增本局祝福触发总数与按祝福 ID 统计的触发次数，触发时显示 HUD 消息和战斗浮字。
- `HUD.gd` 的完整结算文本和 Build 分组新增 `Blessing Triggers` 字段。
- `EventRoomSmokeTest.gd` 覆盖清房、击杀和受伤触发信号；`RunSummarySmokeTest.gd` 覆盖 `Afterglow Circuit` 触发后的 summary 和 HUD 文本；`FullRunSmokeTest.gd` 覆盖新 summary 字段存在性。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百三十五批记录。

### 验证状态

```text
Blessing trigger feedback contract check passed.
Static load_steps check passed: 302 files scanned.
Static res:// reference check passed: 377 files scanned, 1195 references resolved.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Godot CLI smoke tests were not executed in this pass because `godot` is not available on the current PowerShell PATH and no local Godot executable was found under the workspace.
```

### 仍需人工复核

- 恢复 Godot 执行权限或配置 Godot PATH 后，优先运行 `EventRoomSmokeTest.tscn`、`RunSummarySmokeTest.tscn`、`FullRunSmokeTest.tscn` 和 `Main.tscn`。
- 实机试玩应重点观察触发浮字是否过频、是否遮挡战斗读招，以及 `Blessing Triggers` 是否足够帮助玩家理解本局构筑收益。

## 2026-07-05 雕像共鸣第一版
### 目标

- 补上类《元气骑士》结构里常见的“雕像/神像式局内增益”位置，但用原创命名、原创效果和项目自己的技能触发规则实现。
- 让雕像成为技能循环的一部分，和现有武器、遗物、祝福、角色技能形成可读 Build，而不是单纯增加一组常驻数值。

### 本次改动

- 新增 `StatueData.gd` 与 `StatueSystem.gd`，支持雕像池、随机候选、获取、叠加计数、技能触发、触发间隔、局内重置和触发统计信号。
- 新增 `bulwark_idol.tres`、`cinder_focus.tres`、`echo_reservoir.tres` 三个原创雕像资源，分别覆盖护甲、生存爆发和能量节奏路线。
- `Events.gd` 新增 `player_skill_used`、`statue_choice_requested`、`statue_choice_selected`、`statue_collected`、`statues_changed` 和 `statue_triggered`，统一雕像选择与触发链路。
- `Player.gd` 在主动技能成功使用后发出 `player_skill_used`；`Main.gd` 接入 `StatueSystem`、三选一、HUD 消息、浮字、Run Summary 和 Hall Summary。
- `EventShrine.gd` 新增 `resonant_statue` / `statue_choice`，事件房可以用金币和生命代价换雕像选择。
- `HUD.gd` 接入雕像三选一、雕像 tooltip、结算 `Statues` 和 `Statue Triggers`；`LobbyScreen.gd` 与 `LobbyScreen.tscn` 新增 `Statues` 图鉴页和详情展示。
- 内容图标管线新增 `statue` 类型、默认雕像图标和 3 个雕像专属 SVG / `ContentIconDefinitionData`，避免图鉴和 HUD 退回通用占位。
- `ContentPipelineSmokeTest.gd`、`LobbyScreenSmokeTest.gd`、`HallArchiveSmokeTest.gd`、`EventRoomSmokeTest.gd`、`RunSummarySmokeTest.gd` 和 `FullRunSmokeTest.gd` 同步覆盖雕像资源、图标、事件房、技能触发和结算字段。
- 修正 `training.tres` 的 `PackedColorArray` 写法和 `snare_beacon.tres` 的 `status` 标签，避免新增内容管线测试被旧资源格式问题阻断。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百三十六批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --import
ContentPipelineSmokeTest passed.
LobbyScreenSmokeTest passed.
HallArchiveSmokeTest passed.
EventRoomSmokeTest passed.
RunSummarySmokeTest passed.
Static load_steps/ext_resource check passed.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
FullRunSmokeTest did not pass: Room13 combat did not clear, Room13 reward was not claimable, and Room15 wave 1 did not spawn configured enemies.
```

### 仍需人工复核

- `FullRunSmokeTest.tscn` 的失败点属于完整路线战斗房稳定性；下一步应先定位 Room13/Room15 的房间状态、敌人生成计数和清房奖励触发条件。
- 实机试玩重点观察雕像触发浮字、三选一可读性、技能/能量循环是否过强，以及 `Statue Triggers` 是否能帮助玩家理解本局构筑收益。

## 2026-07-05 完整路线动态清房与 Biome 布局稳定性修复
### 目标

- 修复雕像接入后暴露的完整路线烟测阻塞，让三层 44 房路线重新能自动跑到胜利结算。
- 让地牢生成更稳定地体现三层 biome 差异，避免战斗房在专属布局还没消耗完时过早抽到通用布局。

### 本次改动

- `FullRunSmokeTest.gd` 的战斗房推进改为按当前房间半径统计敌人，不再用全局敌人数判断当前波次。
- 新增动态波次清理循环，持续击杀当前房间内的死亡生成物和召唤物，修复 Room13 `Hazard Rush` 挑战房中 `SootSplitter` 分裂后残留导致房间无法清理的问题。
- 波次断言从精确等于配置数量改为至少达到配置数量，继续防止欠生成，同时允许召唤敌人在断言前合法产生额外单位。
- `DungeonController.gd` 新增 biome 布局优先选择：战斗、精英、挑战房会先使用当前 biome 专属布局池的未使用布局，耗尽后再回退通用布局。
- `DungeonGenerationSmokeTest.gd` 改为用 record 的 `enemy_pool` 字段验证 Boss 身份，匹配当前 `DungeonController` 的房间记录结构。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百三十七批记录，并把第一百三十六批中的 FullRun 失败标记改为已在本批修复。

### 验证状态

```text
FullRunSmokeTest passed.
DungeonGenerationSmokeTest passed.
ContentPipelineSmokeTest passed.
EventRoomSmokeTest passed.
RunSummarySmokeTest passed.
`git diff --check` passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
Some Godot test processes still print existing RID/ObjectDB/resource leak warnings at exit, but the smoke-test exit codes above were 0.
```

### 仍需人工复核

- 实机试玩应重点观察新的 biome 布局优先策略是否让每层视觉节奏更集中，以及通用布局回退是否仍保留足够房间变化。
- 后续若继续加入会召唤、分裂或延迟死亡的敌人，优先保持 `FullRunSmokeTest` 的动态清房路径通过，再扩展更细的敌人行为断言。

## 2026-07-06 祝福与雕像联动第一版
### 目标

- 把雕像从独立技能触发奖励推进为可被祝福系统读取的 Build 事件。
- 让玩家能形成“技能触发雕像，雕像再触发祝福”的原创能量循环，补强祝福与雕像的长期联动深度。

### 本次改动

- `BlessingData.gd` 的触发枚举新增 `on_statue_triggered`。
- `BlessingSystem.gd` 监听 `Events.statue_triggered`，并复用现有事件祝福触发、间隔计数、玩家效果应用和 `blessing_triggered` 信号链路。
- 新增 `resonance_battery.tres`：史诗祝福 `Resonance Battery`，雕像效果触发时恢复 5 Energy，Build 标签为 `energy/statue/skill/synergy`。
- 新增 `resonance_battery.svg` 和 `resources/ui/content_icons/resonance_battery.tres`，并接入 `content_icon_registry.tres`。
- `ContentPipelineSmokeTest.gd` 将祝福池门槛提升到 7，校验 `on_statue_triggered`、新图标和新祝福 ID。
- `EventRoomSmokeTest.gd` 新增雕像/祝福联动覆盖，验证获得 `Bulwark Idol` 和 `Resonance Battery` 后，使用主动技能会触发雕像，并进一步触发祝福回能。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百三十八批记录，并修正顶部“缺少雕像系统”的过期差距描述。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --import
ContentPipelineSmokeTest passed.
EventRoomSmokeTest passed.
RunSummarySmokeTest passed.
LobbyScreenSmokeTest passed.
FullRunSmokeTest passed.
```

### 仍需人工复核

- 实机试玩应观察 `Resonance Battery` 与 `Echo Reservoir`、高耗能武器、短冷却角色技能叠加时是否回能过强。
- 后续可继续补“事件强化雕像”“角色技能改变雕像触发间隔”等更深联动，但需要保持结算统计和触发浮字可读。

## 2026-07-06 事件房雕像调谐第一版
### 目标

- 把事件房从“给新雕像”推进到“强化已有雕像”，补上类似类 Soul Knight 局内雕像强化的长期 Build 深度，但继续使用项目原创事件、命名和数值规则。
- 保持事件房奖励不落空：玩家已有雕像时走调谐强化，没有雕像时回退为雕像选择。

### 本次改动

- `Events.gd` 新增 `statue_attuned` 信号，用于广播被调谐的雕像资源和新的调谐层数。
- `StatueSystem.gd` 新增调谐计数、`attune_statue()`、`get_attunement_count()`、有效触发间隔和有效效果值摘要；触发雕像时改用调谐后的间隔与效果值。
- 调谐数值当前为：触发间隔每层 -1 且最低为 1；`recover_energy`、`heal`、`gain_shield` 每层 +1；`temporary_combat_rule` 每层 +0.04。
- `EventShrine.gd` 新增 `statue_attunement` 奖励模式和 `Resonance Tuning` 事件变体，并加入随机事件池。
- `EventShrine.gd` 的调谐事件支持 `statue_attunement_target_id`；目标为空时由 `StatueSystem` 选择当前有效触发间隔最高的已拥有雕像进行强化。
- `ContentPipelineSmokeTest.gd` 新增事件神龛调谐接口覆盖。
- `EventRoomSmokeTest.gd` 新增 `Echo Reservoir` 调谐覆盖，验证事件结算、`statue_attuned`、调谐层数、有效触发间隔和有效回能值。
- `FullRunSmokeTest.gd` 新增 `statue_attunement` 事件模式断言，允许完整路线中调谐已有雕像或在无雕像时回退为雕像奖励。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百三十九批记录，并更新特殊房间后续建议。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" "res://scenes/debug/ContentPipelineSmokeTest.tscn"
ContentPipelineSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" "res://scenes/debug/EventRoomSmokeTest.tscn"
EventRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Second run elapsed 234.7s; the first 180s run timed out without failure output.

git diff --check
passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
```

### 仍需人工复核

- 实机试玩应观察 `Echo Reservoir` 调谐到 1 次触发后，配合 `Resonance Battery`、高耗能武器和短冷却角色技能时是否回能过强。
- 后续若继续扩展调谐，应优先补 UI 中的调谐层数展示、事件文案差异和结算统计字段，避免玩家只看到数值变化但不理解来源。

## 2026-07-06 雕像调谐反馈与结算可读性
### 目标

- 让雕像调谐从后台规则变成玩家能感知、能回看、能用于理解 Build 的局内事件。
- 把调谐次数纳入结算统计，和祝福触发、雕像触发一样形成可验证的本局记录。

### 本次改动

- `Main.gd` 监听 `Events.statue_attuned`，在调谐发生时显示 HUD 消息和浮字。
- `Main.gd` 新增 `_statue_attunement_count` 和 `_statue_attunement_counts`，并在新 Run 开始时重置。
- `Main.gd` 的 Run Summary 新增 `statue_attunement_count`、`statue_attunement_counts`，雕像名称会带上调谐层数，例如 `Bulwark Idol +1`。
- `HUD.gd` 的结果全文与 Build 分组新增 `Statue Triggers: N | Attunes: M`。
- `RunSummarySmokeTest.gd` 调谐 `Bulwark Idol` 后再结算，验证调谐后的雕像名称、调谐总数、按雕像调谐统计和 HUD 文本。
- `FullRunSmokeTest.gd` 新增 `statue_attunement_count` summary 字段存在性断言。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百四十批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" "res://scenes/debug/RunSummarySmokeTest.tscn"
RunSummarySmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" "res://scenes/debug/EventRoomSmokeTest.tscn"
EventRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 228.8s.

git diff --check
passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
```

### 仍需人工复核

- 实机试玩应观察调谐浮字和已有雕像触发浮字是否过密，尤其是短冷却角色技能连续触发时是否遮挡战斗读招。
- 后续可继续把调谐层数带入大厅图鉴的“局内规则说明示例”，但大厅静态图鉴不应伪装成当前 Run 状态。

## 2026-07-06 事件房结果回看第一版
### 目标

- 让事件房的风险收益选择进入结算回看，避免玩家只看到事件数量而不知道本局触发过哪些事件结果。
- 为后续更多事件变体和事件平衡复盘建立结构化记录入口。

### 本次改动

- `EventShrine.gd` 的 `get_event_summary()` 新增 `display_name`、`gold_min`、`gold_max`、`biome_id` 和 `biome_name`。
- `Main.gd` 新增 `_event_records`，在 `special_event_resolved` 时记录事件 id、结果 id、显示名、事件变体、奖励模式、生命代价、金币范围和 biome 信息。
- `Main.gd` 的 Run Summary 新增 `event_names` 和 `event_records`，并提供事件记录格式化和深拷贝 helper。
- `HUD.gd` 的结果全文和 Loot 分组新增 `Event Outcomes`，显示事件结果回看文本。
- `RunSummarySmokeTest.gd` 新增事件记录、事件结果文本和 Loot 分组断言。
- `FullRunSmokeTest.gd` 新增三层路线事件结果数量断言，要求每个 biome 的事件房都进入 summary。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百四十一批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" "res://scenes/debug/RunSummarySmokeTest.tscn"
RunSummarySmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" "res://scenes/debug/EventRoomSmokeTest.tscn"
EventRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed about 228s.

git diff --check
passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
```

### 仍需人工复核

- 实机试玩应观察结果页 Loot 分组在三层完整路线后是否过长；如果事件、宝箱和 Boss 记录继续增加，后续需要把结果页改成可滚动或可折叠详情。
- 后续事件变体增加时，应优先补清晰的 `reward_mode` 到结果标签映射，避免 `Event Outcomes` 退回过多内部 id。

## 2026-07-06 结果页滚动承载第一版
### 目标

- 解决完整三层路线后结果页内容变长的问题，让 Build、事件结果、Boss 路线和历史记录不会把操作按钮挤出面板。
- 保留旧 summary 文本接口，避免本次 UI 承载调整破坏已有烟测和调试入口。

### 本次改动

- `HUD.gd` 新增 `ResultScroll` 运行时滚动容器，把 `ResultSections` 放入 `ScrollContainer`。
- `HUD.gd` 保留隐藏的 `ResultSummaryLabel` 兼容文本，`get_result_summary_text()` 仍返回完整摘要。
- `HUD.gd` 新增 `is_result_scroll_available()`、`get_result_scroll_child_name()` 和 `get_result_scroll_minimum_height()` 测试读接口。
- `RunSummarySmokeTest.gd` 验证结果分组进入滚动容器，并检查滚动区域保留可读高度。
- `FullRunSmokeTest.gd` 验证三层完整路线后的结果页仍使用滚动容器承载分组。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百四十二批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" "res://scenes/debug/RunSummarySmokeTest.tscn"
RunSummarySmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 230.2s.

git diff --check
passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
```

### 仍需人工复核

- 实机试玩应确认鼠标滚轮、触控板和键盘焦点在结果页滚动区域内的操作是否顺手。
- 如果后续结果页继续增长，应考虑把 `Event Outcomes`、Boss 路线和 Build 详情拆成可折叠分区，而不是继续增加单屏文本密度。

## 2026-07-06 特殊房间路线回看第一版
### 目标

- 让本局经过的事件、挑战、陷阱、奖励、军械、治疗、精英和商店房进入结算回看，帮助玩家理解完整路线中的风险收益结构。
- 为后续增加更多分支房间、挑战奖励差异和事件平衡复盘建立稳定 summary 字段。

### 本次改动

- `Main.gd` 新增 `_get_special_room_counts()`、`_format_special_room_counts()`、`_get_special_room_types()` 和 `_get_special_room_label()`，按已访问、已清理或当前所在的特殊房间生成统计。
- `Main.gd` 的 Run Summary 新增 `special_room_counts` 和 `special_room_count_text`。
- `HUD.gd` 的隐藏完整结果文本新增 `Special Rooms` 行，Overview 分组同步展示特殊房间路线回看。
- `RunSummarySmokeTest.gd` 新增特殊房间 summary 字段、可读文本和 Overview 分组断言。
- `FullRunSmokeTest.gd` 新增完整三层路线特殊房间计数断言，覆盖事件、挑战、陷阱、奖励、军械、治疗、精英和商店房。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百四十三批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\RunSummarySmokeTest.log" "res://scenes/debug/RunSummarySmokeTest.tscn"
RunSummarySmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 232.1s.

git diff --check
passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
```

### 仍需人工复核

- 实机试玩应确认 Overview 中的 `Special Rooms` 在完整三层路线后仍能快速阅读，不会和 Route 签名、Biome/Boss 信息形成重复噪音。
- 后续如果加入可跳过分支或多选路线，特殊房间计数应继续保持“已访问/已清理”语义，不要误报未进入的生成支路。

## 2026-07-06 结果页详情密度切换第一版
### 目标

- 降低完整三层路线后结果页的初读压力，让玩家可以先看核心路线、Build 和收益，再按需展开全部战斗与历史细节。
- 保留既有完整文本和分组文本接口，避免可读性改动破坏 smoke test、调试入口或后续结算数据复盘。

### 本次改动

- `HUD.gd` 新增 `ResultDetailToggleButton`，默认显示全部六个结果分组，点击后切到 Compact。
- Compact 模式只显示 Overview、Build 和 Loot，隐藏 Survival、Combat 和 Record；隐藏分组文本仍保留在原 label 中。
- `HUD.gd` 新增 `is_result_details_expanded()`、`get_result_detail_toggle_text()`、`toggle_result_detail_mode()`、`is_result_section_visible()` 和 `get_visible_result_section_count()` 测试接口。
- `RunSummarySmokeTest.gd` 新增结果页默认展开、Compact 切换、核心分组保留、细节分组隐藏和隐藏文本保留断言。
- `FullRunSmokeTest.gd` 新增完整路线结算默认展开、Compact 入口和可见分组数量断言。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百四十四批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\RunSummarySmokeTest.log" "res://scenes/debug/RunSummarySmokeTest.tscn"
RunSummarySmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 233.1s.

git diff --check
passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
```

### 仍需人工复核

- 实机试玩应确认 Compact / Details 按钮位置不会挤压 Replay Seed、Restart 和 Main Menu，并且键鼠/手柄焦点顺序仍然顺手。
- 后续若继续增加 Boss 路线、事件详情或 Build 明细，优先把各分组做成独立折叠行，而不是继续只扩大 Compact 白名单。

## 2026-07-06 Boss 路线回看第一版
### 目标

- 让三层地牢的 Boss 路线进入结算核心信息，玩家能在通关或失败后看到每层 Boss 名称、最终 Boss 标记和清理状态。
- 保证 Compact 结果页仍保留三层主线推进信息，而不是只显示房间路线签名和击败 Boss 总数。

### 本次改动

- `HUD.gd` 新增 `_format_boss_route()`，把 `boss_route` summary 字段格式化为 `L1 Boss Cleared | L2 Boss Cleared | L3 Boss Final Cleared` 这类可读文本。
- `HUD.gd` 的隐藏完整结果文本新增 `Boss Route` 行。
- `HUD.gd` 的 Overview 分组新增 `Boss Route`，Compact 模式下也能读到三层 Boss 路线回看。
- `RunSummarySmokeTest.gd` 新增结果全文、Overview 分组和 Compact 模式中的 Boss 路线断言。
- `FullRunSmokeTest.gd` 新增三层 Boss 路线数量、每层 `cleared` 状态、最终 Boss `Final Cleared` 文本和 Compact 保留断言。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百四十五批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\RunSummarySmokeTest.log" "res://scenes/debug/RunSummarySmokeTest.tscn"
RunSummarySmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 230.8s.

git diff --check
passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
```

### 仍需人工复核

- 实机试玩应确认三层 Boss 名称串在 720p 结果页 Overview 中不会过长；如果后续 Boss 名称继续变长，应改为分行或独立可折叠 Boss Route 分组。
- 失败结算需要人工观察 `Pending` / `Seen` 文案是否足够直观，尤其是玩家死在 Boss 房前或 Boss 战中时。

## 2026-07-06 失败结算位置说明第一版
### 目标

- 让死亡结算能说明玩家死在哪一层、哪个房间和什么房间状态，减少“失败原因不可解释”的感觉。
- 保持胜利结算、Boss Route、Compact 结果页和旧 summary 文本接口稳定。

### 本次改动

- `Main.gd` 新增 `_get_run_position_summary()`、`_get_run_position_state()` 和 `_get_run_position_room_label()`。
- Run Summary 新增 `run_position` 和 `run_position_text`，优先使用当前房间，缺失时回退到最后访问或清理过的房间。
- `HUD.gd` 的隐藏完整结果文本和 Overview 分组新增位置行；失败结果显示 `Defeat Point`，其他结果显示 `Run Position`。
- `MenuFlowSmokeTest.gd` 新增真实死亡路径断言，验证失败 summary 记录当前房间、结果全文显示 `Defeat Point`，Overview 分组包含死亡房间 id。
- `RunSummarySmokeTest.gd` 和 `FullRunSmokeTest.gd` 已复跑，确认新增字段不破坏胜利结算回看。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百四十六批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\RunSummarySmokeTest.log" "res://scenes/debug/RunSummarySmokeTest.tscn"
RunSummarySmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 232.4s.

git diff --check
passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
```

### 仍需人工复核

- 实机死亡测试应观察 `Defeat Point` 是否足够醒目，尤其是死在陷阱房、挑战房或 Boss 房时，玩家是否能立刻理解失败位置。
- 后续可继续补“主要伤害来源/最后攻击来源”，但需要先让敌人、陷阱和 Boss 攻击统一携带来源 id，避免用不可靠推断误导玩家。

## 2026-07-06 最后伤害来源回看第一版
### 目标

- 在失败结算已有 `Defeat Point` 的基础上，补充最后一次实际扣 HP 的伤害来源，让玩家更容易理解死亡原因。
- 不改 `Events.player_damaged` 信号签名，避免破坏既有遗物、祝福、音画反馈和测试连接。

### 本次改动

- `Player.gd` 新增 `_last_damage_summary` 和 `get_last_damage_summary()`。
- `Player.take_damage(amount, source)` 在实际扣 HP 时保存最后伤害摘要，包含 `amount`、`source_name`、`source_type` 和可读 `text`。
- `Main.gd` 新增 `_last_damage_record`，在 `player_damaged` 时读取 Player 的最后伤害摘要；Run Summary 新增 `last_damage` 和 `last_damage_text`。
- `HUD.gd` 的隐藏完整结果文本和 Overview 分组新增 `Last Hit`。
- `MenuFlowSmokeTest.gd` 用命名伤害源 `Debug Spike` 造成死亡，验证 summary、结果全文和 Overview 分组都显示最后伤害来源。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百四十七批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\RunSummarySmokeTest.log" "res://scenes/debug/RunSummarySmokeTest.tscn"
RunSummarySmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 231.0s.

git diff --check
passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
```

### 仍需人工复核

- 实机死亡测试应确认 `Last Hit` 对普通敌人、Boss、陷阱/危险区的来源命名是否足够清楚。
- 后续如果要做“死亡原因统计”，应把敌人弹丸、陷阱危险区和 Boss 技能统一带上稳定 `source_id`，而不是只依赖节点名称。

## 2026-07-06 失败原因汇总第一版
### 目标

- 把已有的 `Defeat Point` 和 `Last Hit` 合成为一条更直接的失败原因说明，减少玩家在死亡页自行拼读信息的成本。
- 保持伤害信号和伤害记录入口稳定，只在结算摘要层派生可读字段。

### 本次改动

- `Main.gd` 新增 `_get_defeat_cause_summary()` 和 `_get_defeat_cause_category()`，按最后伤害来源类型归类 Boss、Enemy、Hazard 或 Unknown。
- Run Summary 新增 `defeat_cause` 和 `defeat_cause_text`，记录来源类别、来源名、伤害量、失败位置和可读原因文本。
- `get_run_summary()` 改为按当前 run state 生成 `Defeat`、`Victory` 或 `In Progress` 摘要，避免死亡后的调试摘要仍按进行中结果计算。
- `HUD.gd` 的隐藏完整结果文本和 Overview 分组新增 `Defeat Cause`，Compact 结果页也能看到失败原因。
- `MenuFlowSmokeTest.gd` 将 `Debug Spike` 标记为 enemy，并验证 summary、结果全文和 Overview 分组都显示 `Enemy Debug Spike` 失败原因。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百四十八批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\RunSummarySmokeTest.log" "res://scenes/debug/RunSummarySmokeTest.tscn"
RunSummarySmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 233.4s.

git diff --check
passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
```

### 仍需人工复核

- 实机死亡测试应确认 `Defeat Cause` 在普通敌人、Boss、陷阱和环境危险造成死亡时都足够直观。
- 后续如果要做死亡原因统计或图标化展示，应让敌人弹丸、Boss 技能和陷阱危险区提供稳定 `source_id` 与显示名。

## 2026-07-06 稳定伤害来源标识第一版
### 目标

- 让死亡原因不只是一条可读文本，还能保留稳定来源标识，供后续统计、图标化展示、图鉴链接和复盘筛选复用。
- 覆盖敌方弹丸或危险预警在发射者死亡后才命中玩家的情况，避免来源退化为 Unknown。

### 本次改动

- `Player.gd` 的最后伤害摘要新增 `source_id` 和 `source_scene`，并支持从来源节点的 `get_damage_source_summary()` 读取缓存摘要。
- 伤害来源 id 解析优先使用显式 id，其次使用来源场景文件名，最后回退到显示名或节点名。
- `EnemyProjectile.gd` 在 `launch()` 时缓存 owner 的来源摘要；owner 失效后命中玩家时会把弹丸自身作为摘要载体传入 `take_damage()`。
- `DangerWarning.gd` 在 `configure_circle()` / `configure_line()` 时缓存来源摘要，后续 Boss、精英和危险区伤害可复用同一套来源字段。
- `Main.gd` 的 `defeat_cause` 同步保留 `source_id` 和 `source_scene`，保证失败原因文本与结构化字段一致。
- `CombatFeedbackSmokeTest.gd` 新增敌方弹丸 owner 死亡后仍归因到 `ShooterEnemy` 的断言；`MenuFlowSmokeTest.gd` 新增 `debug_spike` source id 断言。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百四十九批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\CombatFeedbackSmokeTest.log" "res://scenes/debug/CombatFeedbackSmokeTest.tscn"
CombatFeedbackSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\RunSummarySmokeTest.log" "res://scenes/debug/RunSummarySmokeTest.tscn"
RunSummarySmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\EnemyVarietySmokeTest.log" "res://scenes/debug/EnemyVarietySmokeTest.tscn"
EnemyVarietySmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 230.9s.

git diff --check
passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
```

### 仍需人工复核

- 实机死亡测试应确认 `source_id` 对普通敌人、精英前缀、Boss 和陷阱来源的归类符合玩家理解，尤其是精英敌人是否需要显示 base id 与 modifier id。
- 后续如果要做死亡原因统计面板，应把 `source_id` 接入结算历史记录，而不是只保存在单局摘要里。

## 2026-07-06 最近失败原因档案第一版
### 目标

- 把最近一次失败原因从单局结算推进到大厅 Records 页面，让玩家回到大厅后仍能复盘“上一局死因”。
- 独立保存可读文本和结构化来源字段，避免污染现有纯数字 history 统计。

### 本次改动

- `Main.gd` 新增 `_last_defeat_record` 和 `get_last_defeat_summary()`。
- 失败结算记录后，`_record_run_result()` 会把 `defeat_cause`、失败位置、seed、Biome、清房数、击杀数和耗时写入最近失败记录。
- 最近失败记录保存到 ConfigFile 的 `last_defeat` section，并在 Main 初始化时读取；`history` section 仍只保存数字统计。
- Hall Summary 新增 `last_defeat`，供大厅 UI 和测试读取。
- `LobbyScreen.gd` 的 Records 页面在存在记录时显示 `Last Defeat` 行，包含死亡原因、来源 id、seed、Biome、房间和击杀摘要。
- `MenuFlowSmokeTest.gd` 验证真实死亡后记录生成、重载 Main 后持久化读取，以及大厅文本显示 `Enemy Debug Spike`、`Source debug_spike` 和 `Seed 24680`。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百五十批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\RunSummarySmokeTest.log" "res://scenes/debug/RunSummarySmokeTest.tscn"
RunSummarySmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 235.2s.

git diff --check
passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
```

### 仍需人工复核

- 实机大厅 Records 页面应确认 `Last Defeat` 行在 720p 和长房间名/长 Boss 名下仍然可读。
- 后续可把最近失败记录扩展为最近 3-5 局失败列表，或按 `source_id` 聚合为死亡原因统计。

## 2026-07-06 死亡来源统计第一版
### 目标

- 在最近失败原因之外，按 `source_id` 累计玩家死亡来源，让大厅 Records 能显示常见失败原因。
- 继续保持历史统计、最近失败和来源统计三类数据边界清晰，避免把结构化字符串写进纯数字 history。

### 本次改动

- `Main.gd` 新增 `_defeat_source_counts` 和 `get_defeat_source_summary()`。
- 失败结算记录最近失败原因后，同步更新对应来源的死亡次数、最近 run index、最近 seed、Biome、房间和可读失败文本。
- 新增 `_get_defeat_source_records()`，按次数降序、最近 run index 降序和来源名排序输出稳定数组。
- 死亡来源统计保存到 ConfigFile 的 `defeat_sources` section，通过 `source_ids` 列表作为权威索引读取。
- Hall Summary 新增 `defeat_sources`。
- `LobbyScreen.gd` 的 Records 页面新增 `Death Sources` 区块，最多显示前三个来源的 `source_id`、次数、显示名、最近 seed 和最近 Biome。
- `MenuFlowSmokeTest.gd` 验证真实死亡后来源统计生成、重载持久化读取，以及大厅文本显示 `Death Sources` 和 `debug_spike x1`。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百五十一批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\RunSummarySmokeTest.log" "res://scenes/debug/RunSummarySmokeTest.tscn"
RunSummarySmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 233.4s.

git diff --check
passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
```

### 仍需人工复核

- 实机大厅 Records 页面应确认 `Death Sources` 在多个来源和较长来源名下仍然可读。
- 后续可以把来源统计接入图标、筛选或图鉴详情卡，使玩家能从死亡来源跳转查看敌人/Boss/陷阱说明。

## 2026-07-06 死亡来源类型概览第一版
### 目标

- 在具体死亡来源排行之外，给大厅 Records 一个更快读的 Enemy/Boss/Hazard 类型概览。
- 类型概览从已持久化的 `defeat_sources` 派生，避免重复保存导致统计漂移。

### 本次改动

- `Main.gd` 新增 `get_defeat_source_type_summary()`。
- 新增 `_get_defeat_source_type_counts()`，从 `_defeat_source_counts` 聚合 `enemy`、`boss`、`hazard` 和 `unknown` 类型死亡次数。
- Hall Summary 新增 `defeat_source_types`。
- `LobbyScreen.gd` 的 Records 页面新增 `Death Types: Enemy N | Boss N | Hazard N | Unknown N`，放在具体 `Death Sources` 列表前。
- `MenuFlowSmokeTest.gd` 验证真实死亡后类型计数、重载后类型计数，以及大厅文本中的 `Death Types: Enemy 1`。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百五十二批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\RunSummarySmokeTest.log" "res://scenes/debug/RunSummarySmokeTest.tscn"
RunSummarySmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 229.7s.

git diff --check
passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
```

### 仍需人工复核

- 实机大厅 Records 页面应确认 `Death Types` 和 `Death Sources` 连续显示时不会显得过密。
- 后续如果接入图标或筛选，可让 Enemy/Boss/Hazard 类型成为 Records 的快速过滤入口。

## 2026-07-06 敌人伤害来源摘要接口第一版
### 目标

- 把死亡归因字段从 Player/Projectile/Warning 的临时拼装推进到敌人与 Boss 源头对象，减少后续统计、图鉴跳转和 Boss/精英归因时的字段漂移。
- 保持 `source_id` 稳定优先于显示名，同时让精英前缀、Boss 类型和 Boss 阶段成为可扩展的结构化信息。

### 本次改动

- `Enemy.gd` 新增 `source_id` 与 `get_damage_source_summary()`，返回稳定来源 id、显示名、`enemy` 类型、场景路径和精英修饰字段。
- `BossEnemy.gd` 新增 `source_id` 与 `get_damage_source_summary()`，返回稳定来源 id、显示名、`boss` 类型、场景路径和当前 Boss 阶段。
- `EnemyProjectile.gd` 和 `DangerWarning.gd` 在缓存来源摘要时优先调用来源节点的 `get_damage_source_summary()`，再回退到旧的本地拼装逻辑。
- `CombatRoom.gd` 在 `boss_died` 后清理 Boss 房间残留敌人追踪项并推进 `_clear_room()`，修复 Boss 已死亡但房间未清理、奖励箱未生成的边界情况。
- `CombatFeedbackSmokeTest.gd` 验证 Shooter 敌人的来源摘要以及 owner 死亡后弹丸仍保留 `shooter_enemy` 来源。
- `EnemyVarietySmokeTest.gd` 验证精英来源摘要保留 `enemy` 类型、`quickened` 修饰 id 和精英显示名前缀。
- `BossSmokeTest.gd` 验证最终 Boss 暴露 `boss` 类型来源摘要，并覆盖 Boss 死亡后的清房和奖励箱链路。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百五十三批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\CombatFeedbackSmokeTest.log" "res://scenes/debug/CombatFeedbackSmokeTest.tscn"
CombatFeedbackSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\EnemyVarietySmokeTest.log" "res://scenes/debug/EnemyVarietySmokeTest.tscn"
EnemyVarietySmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\BossSmokeTest-fixed.log" "res://scenes/debug/BossSmokeTest.tscn"
BossSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 234.4s.

git diff --check
passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
```

### 仍需人工复核

- 实机死亡归因应确认普通敌人、精英敌人、Boss 弹幕和 Boss 场地预警在结算/Records 文案中都符合玩家直觉。
- 后续可把 `source_id` 与图鉴详情页或敌人/Boss 图标关联，让死亡来源统计能直接跳转到对应威胁说明。

## 2026-07-06 房间危险来源摘要第一版
### 目标

- 让陷阱房、挑战房和 Boss 场地地板危险在死亡归因中拥有稳定来源 id，而不是被归到通用房间场景。
- 保持敌人、Boss、弹丸、预警区和房间 hazard 共用同一套 `get_damage_source_summary()` 接口。

### 本次改动

- `CombatRoom.gd` 新增 `get_damage_source_summary()`，返回 `source_id`、`source_name`、`source_type`、`source_scene`、`room_type`、`biome_id`、`biome_name` 和 `layout_profile`。
- 房间 hazard 根据上下文输出 `trap_room_hazard`、`challenge_room_hazard` 或 `boss_arena_hazard`，默认回退为 `<room_type>_hazard`。
- `DangerWarning` 已有的来源摘要缓存会自动复用 `CombatRoom.get_damage_source_summary()`，因此 trap warning 和 Boss Arena warning 会记录稳定 hazard 来源。
- `TrapRoomSmokeTest.gd` 验证陷阱房对象与实际 danger warning 都暴露 `trap_room_hazard` 和 `Trap Room Hazard`。
- `BossSmokeTest.gd` 验证 Boss 二阶段场地地板 warning 会缓存 `boss_arena_hazard`，与 Boss 本体 `boss` 类型来源分开。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百五十四批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\BossSmokeTest.log" "res://scenes/debug/BossSmokeTest.tscn"
BossSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\DungeonGenerationSmokeTest.log" "res://scenes/debug/DungeonGenerationSmokeTest.tscn"
DungeonGenerationSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 233.7s.

git diff --check
passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
```

### 仍需人工复核

- 实机死亡于陷阱房或 Boss 场地地板危险时，结算和 Records 文案应确认显示为可读的房间 hazard，而不是通用房间名。
- 后续可把 `trap_room_hazard`、`challenge_room_hazard` 和 `boss_arena_hazard` 接入图鉴或 Records 筛选入口。

## 2026-07-06 死亡来源上下文持久化第一版
### 目标

- 让房间 hazard 的死亡归因不止停留在 `source_id/source_type`，还要把房间类型、Biome 和布局上下文一路传到结算、最近失败记录和死亡来源统计。
- 保证大厅 Records 重载后仍能读回这些上下文字段，为后续按房间机制、Biome 或布局复盘死亡原因打基础。
- 让 smoke test 在复用 workspace-local `settings.cfg` 时保持稳定，不受之前测试写入的死亡来源统计影响。

### 本次改动

- `Player.gd` 的 last damage 摘要新增 `source_room_type`、`source_biome_id`、`source_biome_name` 和 `source_layout_profile`，并从来源节点的 `get_damage_source_summary()` 中读取同名或兼容字段。
- `Main.gd` 的 `defeat_cause`、最近失败记录、`defeat_sources` 内存统计和 ConfigFile 读写全部保留这些来源上下文字段。
- `Main.gd` 新增 `reset_run_records_for_test()`，只重置运行历史、最近失败记录和死亡来源统计，不清理文件系统，也不重置设置或元进度。
- `LobbyScreen.gd` 的 Records 死亡来源列表新增 `Type ...` 文案；有房间上下文时会把 `source_type/source_room_type` 合并展示。
- `TrapRoomSmokeTest.gd` 扩展为实际触发陷阱房 danger warning 伤害，并验证 last damage 与 defeat cause 中的 `trap_room_hazard`、`trap`、Biome id 和布局 profile。
- `MenuFlowSmokeTest.gd` 在开始时调用测试重置入口，避免历史死亡来源计数跨运行累加，同时验证普通敌人死亡不会凭空带房间上下文。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百五十五批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\RunSummarySmokeTest.log" "res://scenes/debug/RunSummarySmokeTest.tscn"
RunSummarySmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 230.8s.

git diff --check
passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
```

### 仍需人工复核

- 实机 Records 页应确认 `Type hazard/trap` 这类组合文案在窄窗口和多死亡来源列表下仍然可读。
- 后续可把 `source_room_type`、`source_biome_id` 和 `source_layout_profile` 接入 Records 过滤、图鉴跳转或死亡复盘详情页。

## 2026-07-06 死亡来源上下文展示第一版
### 目标

- 把已经持久化的死亡来源上下文从隐藏字段推进到大厅 Records 可读文案，方便玩家复盘死于哪类房间机制、哪一层和哪套布局。
- 让 `Last Defeat` 和 `Death Sources` 使用同一套上下文格式，避免最近一次死亡和聚合来源统计解释不一致。
- 用真实陷阱死亡路径覆盖重载后 Records 文本，而不是只验证 synthetic defeat cause。

### 本次改动

- `LobbyScreen.gd` 新增 `_format_defeat_source_context_suffix()`，按 `source_room_type`、`source_biome_name/source_biome_id` 和 `source_layout_profile` 生成 `Context Room ... / Biome ... / Layout ...` 后缀。
- `LobbyScreen.gd` 新增 `_format_record_context_token()`，把下划线 id 转为标题化可读文本。
- `Last Defeat` 行现在会在 `Source ...` 后追加上下文；`Death Sources` 排名行会在 `Last Biome ...` 后追加同一套上下文。
- `TrapRoomSmokeTest.gd` 扩展第二段真实陷阱死亡流程：重置运行记录、生成陷阱房、等待 live danger warning、用 warning 致死、验证最近失败记录和死亡来源统计，再重载 Main 打开大厅 Records 检查文案。
- 陷阱死亡归档测试改用类型化 `Array[Resource]` 设置 `room_data_sequence`，并增加房间类型与无敌人断言；这修复了初版测试回退到默认 Shooter 战斗房导致归因成 `shooter_enemy` 的问题。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百五十六批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 232.9s.

git diff --check
passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
```

### 仍需人工复核

- 实机 Records 页应确认长布局名和长 Biome 名不会让 `Last Defeat` 或 `Death Sources` 在 720p 下显得过密。
- 后续可把这些上下文字段变成 Records 页的筛选入口，例如按 Enemy/Boss/Hazard、房间类型或 Biome 查看死亡来源。

## 2026-07-06 死亡来源上下文汇总第一版
### 目标

- 在单条死亡来源上下文之外，给大厅 Records 增加按房间类型、Biome 和布局维度聚合的死亡原因摘要。
- 继续从 `defeat_sources` 派生汇总，不新增独立存档字段，避免来源记录和上下文汇总出现漂移。
- 为后续 Records 筛选入口打基础，例如按 Hazard/Trap、Biome 或布局查看常见死亡原因。

### 本次改动

- `LobbyScreen.gd` 的 Records 页面在 `Death Types` 后新增 `Death Context` 汇总行。
- 新增 `_format_defeat_source_context_breakdown()`，从死亡来源记录中聚合 `source_room_type`、`source_biome_name/source_biome_id` 和 `source_layout_profile`。
- 新增 `_increment_context_count()` 和 `_format_context_count_entries()`，每个维度按死亡次数降序、名称升序显示前三项。
- 汇总文案当前形如 `Death Context: Rooms Trap x1 | Biomes Outer Warrens x1 | Layouts ... x1`，只在存在上下文字段时显示。
- `TrapRoomSmokeTest.gd` 扩展大厅 Records 文本断言，覆盖 `Death Context`、`Rooms Trap x1`、Biome 汇总和 Layout 汇总。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百五十七批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 268.0s.

git diff --check
passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
```

### 仍需人工复核

- 实机 Records 页应确认 `Death Types`、`Death Context` 和 `Death Sources` 连续显示时不会在 720p 下过密。
- 后续可以把 `Death Context` 的三个维度拆成可点击或可切换的 Records 过滤器，而不是只做文本汇总。

## 2026-07-06 死亡记录视图切换第一版
### 目标

- 把 Records 页从单一长文本推进为可切换的死亡记录视图，降低死亡统计信息密度。
- 复用大厅已有过滤控件，不新增场景节点，保持图鉴页 Build Route 过滤和 Records 页 Death View 过滤共用一套按钮交互。
- 让玩家可以分别查看死亡类型、上下文聚合和具体死亡来源排名，为后续 Records 筛选入口打基础。

### 本次改动

- `LobbyScreen.gd` 新增 `RECORD_FILTER_OPTIONS` 和 `_records_filter_index`，当前支持 `all`、`types`、`context`、`sources` 四个 Death View。
- Records 页会显示 `Death View: All/Types/Context/Sources`；`Types` 只显示 Enemy/Boss/Hazard/Unknown 统计，`Context` 只显示房间/Biome/布局聚合，`Sources` 只显示具体来源排名。
- 大厅总览页继续调用完整 Records，不读取 Death View 状态，避免全量总览被单页过滤截断。
- 既有 `Previous/Next/Clear` 过滤按钮在 Records 页切换 Death View，在图鉴页继续切换 Build Route；搜索、排序和稀有度控件仍只在图鉴页显示。
- `LobbyScreen.gd` 新增 Records 专用测试入口：`set_records_filter_for_test()`、`request_previous_records_filter_for_test()`、`request_next_records_filter_for_test()` 和 `request_clear_records_filter_for_test()`。
- `TrapRoomSmokeTest.gd` 扩展为切换四个 Death View，分别验证类型、上下文和来源视图只显示对应死亡信息。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百五十八批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 255.4s.

git diff --check
passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
```

### 仍需人工复核

- 实机 Records 页应确认 `Death View` 控件文本和图鉴 `Route` 控件复用同一排按钮时不会造成语义混淆。
- 后续可把 Death View 从纯文本切换继续推进为真正的筛选列表或卡片详情，例如点选 `Hazard` 后只看 hazard 来源。

## 2026-07-06 死亡来源类型筛选第一版
### 目标

- 在 Records 的 `Context` 和 `Sources` 视图下增加 Source Type 二级筛选，让玩家能只看 Enemy、Boss、Hazard 或 Unknown 来源。
- 继续从现有 `defeat_sources` 派生筛选结果，不新增独立持久化字段。
- 复用大厅现有控件，保证图鉴页过滤逻辑不受 Records 页二级筛选影响。

### 本次改动

- `LobbyScreen.gd` 新增 `RECORD_SOURCE_TYPE_FILTER_OPTIONS` 和 `_records_source_type_filter_index`，支持 `all`、`enemy`、`boss`、`hazard`、`unknown`。
- 新增 `_filter_defeat_source_records_by_type()`，按 `source_type` 过滤死亡来源记录，供 `Context` 和 `Sources` 视图使用。
- `Context` 视图在筛选后无结果时显示 `Death Context: None`；`Sources` 视图无结果时显示 `Death Sources: None`。
- Records 页只有在 `Context` 或 `Sources` Death View 下显示二级 `Source Type` 控件；`All` 和 `Types` 视图隐藏二级筛选，避免类型统计被重复筛选。
- `CodexRefinementRow` 在 Records 页复用为 `Source Type: ...` 控件；切回图鉴页时恢复搜索、排序和稀有度控件。
- `TrapRoomSmokeTest.gd` 扩展 Hazard/Enemy 筛选断言，验证真实陷阱死亡在 Hazard 下保留，在 Enemy 下显示空结果。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百五十九批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 239.9s.

git diff --check
passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
```

### 仍需人工复核

- 实机 Records 页应确认 `Death View` 和 `Source Type` 两层过滤控件在 720p 下仍然易懂，不会和图鉴筛选语义混淆。
- 后续可把 Source Type 筛选结果推进为可点击详情卡，显示对应敌人、Boss 或 hazard 的图鉴说明。

## 2026-07-06 死亡来源详情聚焦第一版
### 目标

- 在 Records 的 `Sources` 视图下补充一个聚焦详情块，让玩家不只看到来源排名，还能快速看懂当前最常见死亡来源的最近一次原因。
- 继续复用现有 `defeat_sources` 持久化记录，不新增配置字段或迁移逻辑。
- 保持 Source Type 筛选语义一致：有匹配来源时显示详情，无匹配来源时只显示空结果。

### 本次改动

- `LobbyScreen.gd` 在 `Sources` Death View 下新增 `Death Source Detail` 文本块，默认取当前筛选后排名第一的死亡来源。
- 新增 `_format_defeat_source_detail()`，展示来源 id、可读名称、类型、累计次数、最近 seed、最近 Biome、上下文后缀和 `Last Cause`。
- 空筛选结果不显示详情块，避免 Enemy 筛选为空时仍展示上一条 hazard 来源。
- `TrapRoomSmokeTest.gd` 扩展真实陷阱死亡后的 Records 断言，覆盖详情块、最近原因、Hazard 筛选保留详情和 Enemy 筛选隐藏详情。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百六十批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 231.7s.

git diff --check
passed with CRLF warnings only for DEVELOPMENT_LOG.md and SOUL_KNIGHT_ALIGNMENT.md.
```

### 仍需人工复核

- 实机 Records 页应确认 `Death Sources` 列表和 `Death Source Detail` 连续显示时在 720p 下不会显得过密。
- 后续可把聚焦详情推进为可交互详情卡，连接到对应敌人、Boss 或房间 hazard 的图鉴/复盘说明。

## 2026-07-06 死亡来源详情卡第一版
### 目标

- 把 `Sources` 视图里的死亡来源复盘从纯文本推进到大厅已有的详情卡形态，减少后续做图标、链接和交互复盘时的返工。
- 继续复用 `defeat_sources`，卡片和文本详情共享当前 Source Type 筛选后的第一条来源记录。
- 空筛选结果不显示卡片，避免玩家在 Enemy 空结果下看到上一条 Hazard 详情。

### 本次改动

- `LobbyScreen.gd` 的 `_update_codex_detail_card()` 新增 Records 分支，`Records + Sources` 时调用 `_update_records_source_detail_card()`。
- 新增 `_get_active_records_detail_source()` 和 `_get_records_defeat_sources()`，让详情卡、Sources 文本和 Source Type 筛选使用同一组聚焦记录。
- 新增 `_set_records_source_detail_visuals()`，为死亡来源详情卡设置稳定 `death_source_<source_id>` icon key、`SRC` 徽标、Source Type badge 和分类颜色。
- 新增 `_format_defeat_source_detail_meta()` 与 `_format_defeat_source_detail_body()`，卡片展示类型上下文、累计次数、最近 seed、最近 Biome、`Last Cause`、上下文和 `Source ID`。
- `TrapRoomSmokeTest.gd` 扩展详情卡断言，覆盖真实陷阱死亡后的标题、徽标、icon key、Hazard badge、meta/body 文本，以及 Hazard/Enemy 筛选下卡片保留/隐藏。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百六十一批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 239.5s.

git diff --check
passed.
```

### 仍需人工复核

- 实机 Records 页应确认详情卡、`Death Sources` 列表和二级 Source Type 控件在 720p 下不会互相挤压。
- 后续可把 `death_source_<source_id>` key 接入正式复盘图标或跳转到敌人/Boss/房间 hazard 的图鉴说明。

## 2026-07-06 死亡来源复盘建议第一版
### 目标

- 让大厅 Records 的死亡来源复盘不仅显示来源和上下文，还给出下一局可执行的规避建议。
- 继续从现有 `defeat_sources` 派生展示内容，不新增存档字段或改动战斗数值。
- 为后续敌人、Boss 和房间 hazard 的复盘说明打基础。

### 本次改动

- `LobbyScreen.gd` 新增 `_format_defeat_source_review_tip()`，按 `source_type` 和 `source_room_type` 派生 Review 文案。
- `Death Source Detail` 文本块新增 `Review` 行，Sources 视图中聚焦来源会直接展示复盘建议。
- Records 来源详情卡正文同步新增 `Review` 行，和文本块共用同一个建议 helper。
- 当前建议覆盖 Hazard/Trap、Challenge hazard、Boss arena hazard、Boss、Enemy 和 Unknown；陷阱房建议强调预警区域、逃生路线和脉冲后穿越。
- `TrapRoomSmokeTest.gd` 扩展断言，验证真实陷阱死亡后的 Sources 文本详情和详情卡正文都包含 trap hazard 复盘建议。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百六十二批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 231.8s.

git diff --check
passed.
```

### 仍需人工复核

- 实机 Records 页应确认 Review 文案不会让详情卡在 720p 下显得过密。
- 后续可把 Review 建议从硬编码文案升级为敌人、Boss 或房间 hazard 数据上的复盘字段。

## 2026-07-06 死亡复盘建议字段管线化第一版
### 目标

- 把死亡复盘建议从大厅 UI 兜底文案推进为伤害来源摘要字段，方便后续敌人、Boss 和房间数据各自声明复盘提示。
- 让 `source_review_tip` 随最后伤害、失败原因、最近死亡记录和死亡来源统计一起持久化。
- 保持旧存档兼容：没有保存建议字段时，大厅继续按来源类型和房间类型推导 Review。

### 本次改动

- `RoomData.gd` 与 `CombatRoom.gd` 新增 `hazard_review_tip`，房间 hazard 的 `get_damage_source_summary()` 会输出 `source_review_tip`。
- `DungeonController.gd` 在应用房间配置时写入 `hazard_review_tip`，并给内置 Challenge、Trap、Boss 房间配置默认复盘建议。
- `Enemy.gd` 和 `BossEnemy.gd` 的伤害来源摘要新增 `source_review_tip`，普通敌人按行为类型给出默认规避建议，Boss 给出读招/护甲恢复建议。
- `Player.gd` 在 last damage 中保留 `source_review_tip`；`Main.gd` 将该字段继续传入 defeat cause、最近死亡记录和 `defeat_sources`，并读写 ConfigFile。
- `LobbyScreen.gd` 的 `_format_defeat_source_review_tip()` 优先使用保存下来的 `source_review_tip`，旧记录缺失时才回退到类型推导。
- `TrapRoomSmokeTest.gd` 扩展字段链路断言，覆盖房间摘要、DangerWarning 缓存、Player last damage、defeat cause、最近死亡记录、死亡来源统计和重载后的持久化读取。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百六十三批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 241.1s.

git diff --check
passed.
```

### 仍需人工复核

- 后续内容数据应把重要敌人、Boss 和特殊房的复盘建议从默认代码继续下沉到具体资源字段。
- 实机 Records 页应确认保存后的 Review 文案在详情卡和文本块中仍然易读。

## 2026-07-06 死亡来源威胁情报第一版

### 目标

- 把大厅 Records 的死亡来源详情从“最近死因 + 规避建议”继续推进为可接图鉴的威胁说明。
- 继续复用现有 `defeat_sources` 数据，不新增存档字段或战斗数值变更。
- 为后续敌人、Boss、房间 hazard 的正式复盘图标和图鉴跳转保留稳定入口。

### 本次改动

- `LobbyScreen.gd` 新增 `_format_defeat_source_threat_intel()`，按 `source_type`、`source_room_type`、`source_id` 和 `source_name` 派生 Threat Intel。
- `Death Source Detail` 文本块新增 `Threat Intel` 行，展示威胁类别、可读前摇、应对方式和稳定 `death_source_<source_id>` key。
- Records 来源详情卡正文同步新增 `Threat Intel` 行，让 `CodexDetailCard` 不只显示最近死因、上下文、Review 和 Source ID。
- Hazard/Trap 会显示 `Room Hazard / Trap | Tell warning lanes | Counter cross after pulse | Codex death_source_trap_room_hazard` 这类结构化说明；Enemy、Boss、Unknown 保持兜底说明。
- `TrapRoomSmokeTest.gd` 扩展真实陷阱死亡后的 Sources 文本和详情卡断言，确认 trap hazard 威胁情报与稳定 death source key 均可见。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百六十四批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 234.1s.
```

### 仍需人工复核

- 实机 Records 页应确认 `Threat Intel`、`Review`、上下文和 `Source ID` 同时出现时，详情卡在 720p 下不会过密。
- 后续可把 `death_source_<source_id>` 从纯文本 key 推进为可点击跳转，连接到敌人、Boss 或房间 hazard 的图鉴说明。

## 2026-07-06 死亡来源威胁情报字段管线化第一版

### 目标

- 把上一批 UI 派生的 Threat Intel 下沉为伤害来源摘要字段，避免后续敌人、Boss 和房间 hazard 的威胁说明继续集中在大厅代码中。
- 让 `source_threat_intel` 随最后伤害、失败原因、最近死亡记录和死亡来源累计统计一起保存与重载。
- 保持旧存档兼容：没有保存威胁情报字段时，大厅继续按来源类型、房间类型和来源 id 推导说明。

### 本次改动

- `RoomData.gd` 和 `CombatRoom.gd` 新增 `hazard_threat_intel`，房间 hazard 的 `get_damage_source_summary()` 会输出 `source_threat_intel`。
- `DungeonController.gd` 在应用房间配置时写入 `hazard_threat_intel`，并给内置 Challenge、Trap 和 Boss 房间配置默认威胁情报。
- `Enemy.gd` 和 `BossEnemy.gd` 的伤害来源摘要新增 `source_threat_intel`；普通敌人按行为类型输出 Ranged Pressure、Charger、Explosion、Support、Shield、Contact 等说明，Boss 输出 Boss Threat。
- `Player.gd` 在 last damage 中保留 `source_threat_intel`；`Main.gd` 将该字段继续传入 defeat cause、最近死亡记录和 `defeat_sources`，并读写 ConfigFile。
- `LobbyScreen.gd` 的 `_format_defeat_source_threat_intel()` 优先使用保存下来的 `source_threat_intel`，缺失时才回退到 UI 派生说明。
- `TrapRoomSmokeTest.gd` 扩展字段链路断言，覆盖房间摘要、DangerWarning 缓存、Player last damage、defeat cause、最近死亡记录、死亡来源统计和重载后的持久化读取。
- `BossSmokeTest.gd`、`CombatFeedbackSmokeTest.gd` 和 `EnemyVarietySmokeTest.gd` 新增 Boss、普通敌人和精英敌人的威胁情报来源摘要断言。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百六十五批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\BossSmokeTest.log" "res://scenes/debug/BossSmokeTest.tscn"
BossSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\CombatFeedbackSmokeTest.log" "res://scenes/debug/CombatFeedbackSmokeTest.tscn"
CombatFeedbackSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\EnemyVarietySmokeTest.log" "res://scenes/debug/EnemyVarietySmokeTest.tscn"
EnemyVarietySmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 235.4s.
```

### 仍需人工复核

- 后续重要敌人、Boss 和特殊房可继续把默认 Threat Intel 下沉到具体资源字段，尤其是 Boss 专属机制和事件/陷阱组合。
- 实机 Records 页应确认保存后的 Threat Intel 与 Review 同屏时仍然易读，必要时把详情卡拆成多行标签或可展开信息。

## 2026-07-06 死亡来源反制 Build 标签第一版

### 目标

- 把死亡来源复盘继续接到现有 Build Route 标签体系，让玩家知道下局可以尝试哪些路线处理同类威胁。
- 复用武器、遗物、天赋、祝福和雕像图鉴中已有的 `build_tags` / `tags` 命名，不新增另一套路线枚举。
- 让反制标签和 Review、Threat Intel 一样随死亡来源记录持久化，避免只在大厅 UI 中临时推导。

### 本次改动

- `RoomData.gd` 和 `CombatRoom.gd` 新增 `hazard_counter_tags`；房间 hazard 的 `get_damage_source_summary()` 会输出 `source_counter_tags`。
- `DungeonController.gd` 在应用房间配置时写入 `hazard_counter_tags`，并给内置 Challenge、Trap 和 Boss 房间配置默认反制标签。
- `Enemy.gd` 和 `BossEnemy.gd` 的伤害来源摘要新增 `source_counter_tags`；普通敌人按行为类型输出 Guard/Line Clear/Precision、Speed/Crowd Control/Close Range、Piercing/Guard/Melee 等反制路线，Boss 输出 Survival/Armor/Damage。
- `Player.gd` 在 last damage 中保留 `source_counter_tags`；`Main.gd` 将该字段继续传入 defeat cause、最近死亡记录和 `defeat_sources`，并以逗号分隔字符串读写 ConfigFile。
- `LobbyScreen.gd` 新增 `Counter Build` 展示，Records 的 `Death Source Detail` 文本块和来源详情卡正文都会显示格式化后的反制路线；旧记录缺失字段时按来源类型和房间类型兜底。
- `TrapRoomSmokeTest.gd` 扩展字段链路断言，覆盖房间摘要、DangerWarning 缓存、Player last damage、defeat cause、最近死亡记录、死亡来源统计、重载后的持久化读取和大厅详情展示。
- `BossSmokeTest.gd`、`CombatFeedbackSmokeTest.gd` 和 `EnemyVarietySmokeTest.gd` 同步覆盖 Boss、普通敌人和精英敌人的反制标签摘要。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百六十六批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\BossSmokeTest.log" "res://scenes/debug/BossSmokeTest.tscn"
BossSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\CombatFeedbackSmokeTest.log" "res://scenes/debug/CombatFeedbackSmokeTest.tscn"
CombatFeedbackSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\EnemyVarietySmokeTest.log" "res://scenes/debug/EnemyVarietySmokeTest.tscn"
EnemyVarietySmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 236.4s.
```

### 仍需人工复核

- 实机 Records 页应确认 `Counter Build` 不会让来源详情卡过密；如果过密，应把标签改为独立 chip 行或可点击筛选入口。
- 后续可把 `Counter Build` 标签做成真正的图鉴筛选跳转，例如从 `Speed` 直接跳到武器/遗物/天赋/祝福中对应路线。

## 2026-07-06 死亡来源反制图鉴推荐第一版

### 目标

- 让死亡来源复盘从“推荐路线标签”继续前进到“推荐具体可查看的图鉴条目”。
- 复用大厅现有 `weapons`、`relics`、`talents`、`blessings` 和 `statues` 摘要，不新增存档字段或单独推荐资源表。
- 保持推荐结果短而可读，避免 Records 详情卡继续膨胀。

### 本次改动

- `LobbyScreen.gd` 新增 `_format_defeat_source_counter_picks()`，会基于当前死亡来源的 `source_counter_tags` 从大厅 summary 里匹配可用内容。
- 武器匹配 `tags`，遗物、天赋、祝福和雕像匹配 `build_tags`，与现有 Build Route 筛选语义保持一致。
- `Death Source Detail` 文本块新增 `Counter Picks` 行；Records 来源详情卡正文同步新增 `Counter Picks` 行。
- 每类内容限制展示少量条目：武器/遗物/天赋/祝福最多 2 个，雕像最多 1 个，避免推荐行过长。
- 旧记录没有保存 `source_counter_tags` 时，仍会先通过 `_get_defeat_source_counter_tags()` 按来源类型和房间类型兜底，再生成推荐。
- `TrapRoomSmokeTest.gd` 扩展真实陷阱死亡后的大厅断言，确认 Sources 文本详情和详情卡正文都显示 `Counter Picks`，并能推荐 `Adrenaline Charm` 与 `Bulwark Idol`。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百六十七批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Elapsed 234.0s.
```

### 仍需人工复核

- 实机 Records 页应确认 `Counter Picks` 在多来源、多标签和 720p 下仍然易读。
- 后续可把推荐条目从纯文本推进为可点击入口，直接跳到对应图鉴分页和 Build Route 筛选。

## 2026-07-06 死亡来源反制路线跳转第一版

### 目标

- 把死亡来源复盘从“展示反制标签和推荐条目”推进到“能直接进入对应图鉴路线”。
- 复用当前大厅图鉴分页和 Build Route 筛选，不新增单独推荐界面或存档字段。
- 让跳转入口只在 `Records + Sources` 的聚焦死亡来源存在可匹配路线时出现，避免空视图和普通图鉴页出现误导按钮。

### 本次改动

- `LobbyScreen.tscn` 的 `CodexDetailCard` 新增 `CounterRouteButton`，默认隐藏，Records 来源详情有路线时显示为类似 `Open Relics -> Speed` 的入口。
- `LobbyScreen.gd` 新增 `open_counter_route()`、`open_counter_route_for_test()`、route 解析和标签/page 回退 helper。
- `Death Source Detail` 文本块和来源详情卡正文新增 `Counter Route` 行，Trap hazard 当前会显示 `Relics -> Speed`。
- 跳转逻辑从当前聚焦死亡来源读取 `source_counter_tags`，优先寻找目标页和目标标签；默认从 `relics` 开始，再回退到 `weapons`、`talents`、`blessings`、`statues`。
- 跳转成功后会切换图鉴分页、套用目标 Build Route，并重置该分页的搜索、排序和稀有度筛选，确保玩家能直接看到匹配内容。
- `TrapRoomSmokeTest.gd` 扩展真实陷阱死亡后的大厅断言，覆盖 `Counter Route` 文本、按钮文案、跳转动作、`Route: Speed` 标签和 `Adrenaline Charm` 匹配结果。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百六十八批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Regression elapsed 342.3s.
```

### 仍需人工复核

- 实机 Records 来源详情卡应确认新增按钮在 720p 和手柄/键鼠操作下不挤压正文可读性。
- 后续可以把 `Counter Picks` 中的具体推荐条目也做成独立可点入口，而不仅是打开首个匹配 Build Route。

## 2026-07-06 死亡来源反制推荐条目跳转第一版

### 目标

- 把死亡来源复盘从“打开反制路线”继续推进到“打开具体推荐图鉴条目”。
- 保持现有 Build Route 筛选语义，让具体条目聚焦仍然落在对应路线下，而不是只做全文搜索。
- 不新增推荐资源表，继续从当前大厅 summary 和 `source_counter_tags` 推导可用条目。

### 本次改动

- `LobbyScreen.tscn` 的来源详情卡新增 `CounterPickButton`，默认隐藏，存在具体推荐时显示为类似 `Open Pick Adrenaline Charm`。
- `LobbyScreen.gd` 新增 `open_counter_pick()`、`open_counter_pick_for_test()`、`_resolve_counter_pick_target()` 和具体推荐格式化 helper。
- `Death Source Detail` 文本块和来源详情卡正文新增 `Counter Focus` 行，Trap hazard 当前会显示 `Relics -> Adrenaline Charm (Speed)`。
- 具体推荐跳转会切换到目标图鉴页，套用目标 Build Route，并把搜索框设置为推荐条目名，从而直接聚焦对应 `CodexDetailCard`。
- 推荐目标解析默认复用反制路线页序：优先遗物，再回退到武器、天赋、祝福、雕像；后续 UI 也可以传入指定 page/tag/name。
- `TrapRoomSmokeTest.gd` 扩展真实陷阱死亡后的大厅断言，覆盖 `Counter Focus` 文本、推荐按钮文案、具体推荐跳转、搜索框和 `Adrenaline Charm` 详情卡聚焦。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百六十九批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Regression elapsed 329.9s.
```

### 仍需人工复核

- 实机 Records 来源详情卡应确认双按钮布局在 720p 下仍然不挤压正文。
- 后续可把 `Counter Picks` 行拆成多个可导航条目，允许玩家在多个推荐之间循环或直接选中某一类内容。

## 2026-07-06 死亡来源反制推荐循环第一版

### 目标

- 让死亡来源复盘不只打开首个推荐条目，而是能在当前来源的多条反制推荐之间循环选择。
- 保持 UI 入口轻量：一个 `Next Pick` 负责切换焦点，`Open Pick` 负责打开当前焦点。
- 推荐池继续从大厅 summary 和 `source_counter_tags` 推导，不新增独立推荐资源表。

### 本次改动

- `LobbyScreen.tscn` 的来源详情卡新增 `CounterPickCycleButton`，默认隐藏，存在多条推荐时显示为类似 `Next Pick 1/N`。
- `LobbyScreen.gd` 新增 `_counter_pick_focus_indexes`，按 `source_id + Source Type` 保存当前推荐焦点。
- `Counter Focus` 文本和 `Open Pick` 按钮会使用当前焦点；点击 `Next Pick` 后只刷新 Records 来源详情，不离开大厅页面。
- 反制推荐目标池新增 `_collect_counter_pick_targets()`，按反制路线页序和来源标签顺序收集可用图鉴项，并按 page/display name 去重。
- `open_counter_pick()` 无参数时打开当前循环焦点；传入 page/tag/name 时仍然精确打开指定条目，保持测试和未来直接选择入口可用。
- `TrapRoomSmokeTest.gd` 扩展真实陷阱死亡后的大厅断言，覆盖 `Next Pick 1/N`、循环后 `Next Pick 2/N`、`Open Pick` 文案更新，以及焦点离开首个 `Adrenaline Charm`。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百七十批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Regression elapsed 326.4s.
```

### 仍需人工复核

- 实机 Records 来源详情卡应确认三按钮布局在 720p 下仍然可读；如果过密，下一步应合并按钮为一行紧凑 controls。
- 后续可把当前循环焦点升级为真正的分组/分类选择，例如先选 Relics、Weapons 或 Statues，再在该类内部循环。

## 2026-07-06 死亡来源反制推荐焦点计数第一版

### 目标

- 让 `Counter Focus` 正文本身显示当前推荐在推荐池中的位置，避免玩家只能从按钮推断还有其它推荐。
- 保持 `Counter Focus`、`Open Pick` 和 `Next Pick` 三者使用同一套推荐池和焦点索引。
- 不改变具体推荐池的收集规则，只改善复盘详情的可读性和导航上下文。

### 本次改动

- `LobbyScreen.gd` 的 `_format_defeat_source_counter_pick_focus()` 现在会读取完整推荐池、当前焦点索引和总数。
- `_format_counter_pick_target()` 新增可选焦点计数参数，多条推荐时输出类似 `1/N Relics -> Adrenaline Charm (Speed)`。
- `Next Pick` 循环后，来源详情文本和来源详情卡正文会同步刷新为 `2/N ...`，与按钮文案保持一致。
- 单条推荐或无推荐时不强制显示冗余计数，继续保持 `Counter Focus` 行短而可读。
- `TrapRoomSmokeTest.gd` 扩展断言，覆盖初始 `Counter Focus: 1/`、循环后的 `Counter Focus: 2/`，以及推荐条目名仍可读。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百七十一批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Regression elapsed 328.2s.
```

### 仍需人工复核

- 实机 Records 来源详情卡应确认 `Counter Focus: 1/N ...` 在长推荐名下仍能换行正常。
- 后续可以把 `Counter Focus` 进一步拆成当前类型、当前条目、当前序号三个 UI label，减少单行文字压力。

## 2026-07-06 死亡来源反制推荐类型切换第一版

### 目标

- 把死亡来源反制推荐从单一长列表推进为“先选推荐类型，再选具体条目”的两层导航。
- 保持当前详情卡的轻量交互：`Next Type` 切换推荐类型，`Next Pick` 在当前类型内切换条目，`Open Pick` 打开当前焦点。
- 不新增推荐资源表，继续从大厅 summary、图鉴页标签和 `source_counter_tags` 推导可用推荐。

### 本次改动

- `LobbyScreen.tscn` 的来源详情卡新增 `CounterPickPageButton`，默认隐藏，多类型推荐可用时显示为类似 `Next Type Relics 1/N`。
- `LobbyScreen.gd` 新增 `_counter_pick_page_focus_indexes`，按 `source_id + Source Type` 保存当前推荐类型页。
- 反制推荐收集拆为 `_collect_counter_pick_targets()` 和 `_collect_counter_pick_targets_for_page()`，让精确跳转仍可跨页解析，而详情卡循环只处理当前类型页内条目。
- `Counter Focus` 和 `Open Pick` 改为读取当前类型页的推荐池；`Next Pick` 不再跨类型混排，`Next Type` 切换后会重置当前条目焦点。
- `TrapRoomSmokeTest.gd` 扩展真实陷阱死亡后的大厅断言，覆盖 `Next Type Relics 1/N`、类型切换后的按钮状态，以及 `Counter Focus` 行离开初始 Relics 推荐。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百七十二批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Regression elapsed 347.2s.
```

### 仍需人工复核

- 实机 Records 来源详情卡应确认四按钮纵向布局在 720p 下仍然可读；如果过密，下一步应合并 `Open Route` / `Open Pick` / `Next Pick` / `Next Type` 为紧凑按钮行。
- 后续可把 `Next Type` 从循环按钮升级为显式类型 segmented control，让玩家能直接点选 Relics、Weapons、Talents、Blessings 或 Statues。

## 2026-07-06 死亡来源反制类型直接选择第一版

### 目标

- 把死亡来源反制推荐类型从“循环切换”推进为“可直接选择”，减少玩家在多类型推荐间来回切换的操作成本。
- 保持上一批的两层导航：先选推荐类型，再在该类型内用 `Next Pick` 选择具体条目。
- 继续复用大厅 summary 和 `source_counter_tags`，不引入独立推荐配置表。

### 本次改动

- `LobbyScreen.tscn` 的来源详情卡新增 `CounterPickTypeRow`，包含 Weapons、Relics、Talents、Bless、Statues 五个分段按钮。
- `LobbyScreen.gd` 新增 `_counter_pick_type_buttons` 接线和 `_set_counter_pick_type_row_state()`，只显示当前死亡来源实际有推荐的类型按钮。
- 当前类型按钮会显示为类似 `[Relics]` 并禁用，其他可用类型按钮可直接点击切换。
- 新增 `_set_counter_pick_page_focus()` 作为直接选择和 `Next Type` 循环共用的入口，切换类型时同步重置当前条目焦点。
- 新增 `request_counter_pick_page_for_test()`、`get_counter_pick_type_button_text()` 和 `is_counter_pick_type_button_visible()` 测试接口。
- `TrapRoomSmokeTest.gd` 扩展真实陷阱死亡后的大厅断言，覆盖初始 `[Relics]`、循环切到其它类型后直接选择回 Relics，以及 `Counter Focus` 恢复到 `Relics -> Adrenaline Charm`。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百七十三批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Regression elapsed 327.1s.
```

### 仍需人工复核

- 实机 Records 来源详情卡应确认五个类型按钮在 720p 下仍能保持单行可读；如过密，下一步应改为短标签或横向滚动。
- 后续可把 `Next Type` 循环按钮降级为键盘/手柄辅助入口，鼠标主路径优先使用类型分段按钮。

## 2026-07-06 死亡来源反制操作紧凑布局第一版

### 目标

- 降低 Records 来源详情卡在 720p 下的纵向占用，避免反制操作继续挤压下方档案正文。
- 保留上一批的路线打开、推荐打开、页内循环和类型选择能力，不因为压缩布局牺牲导航功能。
- 让按钮文案更像正式大厅 controls，优先显示动作和目标，而不是重复长前缀。

### 本次改动

- `LobbyScreen.tscn` 新增 `CounterActionRow`，把 `CounterRouteButton` 和 `CounterPickButton` 并排放置。
- `LobbyScreen.tscn` 新增 `CounterCycleRow`，把 `CounterPickCycleButton` 和 `CounterPickPageButton` 并排放置。
- `LobbyScreen.gd` 更新四个操作按钮的节点路径，适配新的两行 HBox 布局。
- `CounterRouteButton` 文案从 `Open ...` 缩短为 `Route ...`，`CounterPickButton` 文案从 `Open Pick ...` 缩短为 `Pick ...`。
- `CounterPickPageButton` 文案从 `Next Type ...` 缩短为 `Type ...`，类型分段按钮保留直接选择主路径。
- `CodexDetailCard` 最小高度从 276 回落到 248，给 Records 正文区域腾回空间。
- `TrapRoomSmokeTest.gd` 同步更新按钮文案断言，确认紧凑布局仍然能正确暴露路线、推荐条目、页内循环和类型切换状态。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百七十四批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Regression elapsed 327.3s.
```

### 仍需人工复核

- 实机 Records 来源详情卡应确认 `Route Relics -> Speed` 和 `Pick Adrenaline Charm` 在半宽按钮内不会难读；如文本过长，下一步应改为更短标签加 tooltip。
- 后续可把类型分段按钮改成正式图标/短 token，继续压缩 `Weapons/Relics/Talents/Bless/Statues` 的横向占用。

## 2026-07-06 死亡来源反制类型短标签第一版

### 目标

- 进一步压缩 Records 来源详情卡中类型分段按钮的横向占用，降低小窗口或 720p 下的挤压风险。
- 保留类型可理解性：可见按钮用短 token，tooltip 仍提供完整类型名。
- 为后续正式图标或更强视觉 token 留出接口，不把长英文标签硬编码为唯一展示形式。

### 本次改动

- `LobbyScreen.gd` 新增 `_format_counter_pick_type_token()`，把 Weapons、Relics、Talents、Blessings、Statues 映射为 `W/R/T/B/S`。
- `CounterPickTypeRow` 的按钮显示从完整名称改为短 token；当前类型仍使用方括号，例如 Relics 显示为 `[R]`。
- `CounterPickTypeRow` 的 tooltip 继续使用完整类型名，例如 `Current counter type: Relics` 或 `Show counter picks for Relics`。
- `LobbyScreen.tscn` 的五个类型按钮默认文本改为 `W/R/T/B/S`，最小宽度从 58 降到 36。
- 新增 `get_counter_pick_type_button_tooltip_text()` 测试入口，用于验证短 token 没有丢失完整类型说明。
- `TrapRoomSmokeTest.gd` 更新断言，确认 `[R]` active token 和 Relics tooltip 在初始状态、直接选回 Relics 后都存在。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百七十五批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Regression elapsed 329.3s.
```

### 仍需人工复核

- 实机 Records 来源详情卡应确认 `W/R/T/B/S` 短 token 对玩家是否足够直观；如不够，应替换为正式图标或两字母 token。
- 后续可给当前类型按钮增加更明确的颜色或边框状态，减少仅依赖方括号表达 active 状态。

## 2026-07-06 死亡来源反制类型 active 颜色第一版

### 目标

- 让 Records 来源详情卡中的当前反制类型不只依赖 `[R]` 这类文字标记，而是拥有明确的视觉状态。
- 避免当前类型按钮因为 disabled 状态变成默认灰色，导致 active 状态反而弱化。
- 保持短 token 方案不变，只补视觉层级和测试可验证性。

### 本次改动

- `LobbyScreen.gd` 新增 `COUNTER_PICK_TYPE_ACTIVE_COLOR` 和 `COUNTER_PICK_TYPE_INACTIVE_COLOR`，分别用于当前类型和可切换类型。
- `_set_counter_pick_type_row_state()` 现在会为每个类型 token 覆写 `font_color`、`font_hover_color`、`font_pressed_color` 和 `font_disabled_color`。
- 当前类型按钮仍保持 disabled，避免重复点击，但 disabled 字体色被覆写为 active 金色。
- 新增 `get_counter_pick_type_button_font_color_text()` 测试入口，返回当前按钮实际字体色，便于烟测确认视觉状态。
- `TrapRoomSmokeTest.gd` 扩展断言，确认初始 Relics token 和直接选回 Relics 后都使用 `1.00,0.82,0.28` 金色 active 字体色。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百七十六批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Regression elapsed 335.7s.
```

### 仍需人工复核

- 实机 Records 来源详情卡应确认 active 金色和现有标题金色不会造成误读；如视觉层级过重，可改为边框或背景高亮。
- 后续可给 inactive token 增加 hover 背景或 pressed 反馈，让直接选择类型时更接近正式 segmented control。

## 2026-07-06 死亡来源反制类型 pressed 状态第一版

### 目标

- 让 Records 来源详情卡的反制类型 token 不只是文字和颜色状态，而是具备按钮层面的 pressed/toggle 状态。
- 让 `W/R/T/B/S` 这一行更接近正式 segmented control，为后续键鼠、手柄和正式图标化打基础。
- 保持当前类型不可重复点击，避免重复刷新同一类型。

### 本次改动

- `LobbyScreen.gd` 新增 `is_counter_pick_type_button_pressed()` 测试入口，暴露类型按钮当前 pressed 状态。
- `_set_counter_pick_type_row_state()` 现在会把每个类型按钮设为 `toggle_mode = true`，并按当前类型同步 `button_pressed`。
- 当前类型按钮保持 `button_pressed = true` 且 disabled；非当前类型保持 `button_pressed = false` 且可点击。
- `LobbyScreen.tscn` 中五个 `CounterPickType*Button` 默认启用 `toggle_mode`，让场景默认状态和运行时行为一致。
- `TrapRoomSmokeTest.gd` 扩展断言，覆盖初始 Relics pressed、循环到其它类型后 Relics released、直接选回 Relics 后 pressed 恢复。
- `SOUL_KNIGHT_ALIGNMENT.md` 同步新增第一百七十七批记录。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrapRoomSmokeTest.log" "res://scenes/debug/TrapRoomSmokeTest.tscn"
TrapRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed. Regression elapsed 329.5s.
```

### 仍需人工复核

- 实机 Records 来源详情卡应确认 disabled+pressed 的当前类型在默认主题下不会显得不可用；如表现仍弱，应改为自定义 StyleBox 背景。
- 后续可把类型 token 的 active 状态从文字/颜色/pressed 组合升级为小图标加背景色，进一步贴近正式图鉴 UI。

## 2026-07-06 内容管线角色初始武器引用校验第一版

### 目标

- 继续执行类元气骑士方案中的内容池基础建设，把角色初始武器从“只检查列表存在”推进到“检查引用真实存在”。
- 降低后续扩角色、扩武器或重命名资源时出现坏 ID 的风险，避免玩家开局装配缺失。

### 本次改动

- `ContentPipelineSmokeTest.gd` 的 `_verify_characters()` 现在会读取 `resources/weapons` 下的武器 ID 集合。
- 每个角色的 `starting_weapon_ids` 新增逐项校验：ID 不能为空、同一角色内不能重复、必须匹配已有武器资源。
- 新增 `_resource_id_lookup()` helper，为后续解锁、被动、掉落池或图鉴引用校验预留复用入口。
- 本次不改变任何战斗数值、角色资源或 UI 行为，只加固内容管线回归面。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\ContentPipelineSmokeTest.log" "res://scenes/debug/ContentPipelineSmokeTest.tscn"
ContentPipelineSmokeTest passed.

git diff --check
passed.
```

### 仍需人工复核

- 后续新增角色时，应手动确认初始武器组合在玩法上有区分度；本次 smoke test 只保证 ID 完整，不评价搭配手感。
- Godot 退出时仍打印既有 RID/ObjectDB/resource 泄漏告警；本轮目标测试退出码为 0，但泄漏清理可在后续专门处理。

## 2026-07-06 角色初始武器运行时装配第一版

### 目标

- 把 `PlayerCharacterData.starting_weapon_ids` 从静态展示/校验字段推进到真实运行时装配字段。
- 让不同角色的开局三槽武器组合能形成可感知差异，继续靠近类元气骑士的“角色身份 + 初始装备”结构。

### 本次改动

- `Player.gd` 新增 `get_weapon_loadout_ids()`，用于烟测直接读取当前运行时三槽武器 ID。
- `Player.gd` 新增 `_apply_character_starting_loadout()`：角色切换时读取 `starting_weapon_ids`，加载 `resources/weapons/<id>.tres`，重建 `weapon_loadout`，并回到第 1 槽刷新武器。
- `CharacterSmokeTest.gd` 扩展 Wanderer、Warden、Arcanist、Field Medic 的 loadout 断言，验证配置武器进入运行时负载，并确认 HUD 负载摘要显示对应武器。
- 两个旧断言同步收窄到真实契约：skill-ready 只检查音效触发计数，不要求它必须是最后一个音效；Arcanist 回能允许自然回能在同帧叠加。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\CharacterSmokeTest.log" "res://scenes/debug/CharacterSmokeTest.tscn"
CharacterSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\ContentPipelineSmokeTest.log" "res://scenes/debug/ContentPipelineSmokeTest.tscn"
ContentPipelineSmokeTest passed.
```

### 仍需人工复核

- 实机主菜单切换角色时，应确认三槽武器 UI 的变化足够明显，尤其是 Warden 的 `Arc Blade`、Arcanist 的 `Laser Lance` 和 Field Medic 的 `Shatter Fan`。
- 当前运行时从 ID 直接加载武器资源，后续如果引入独立内容数据库或资源索引，应把加载路径统一到同一个内容服务里。

## 2026-07-06 全角色初始装配回归覆盖第一版

### 目标

- 把 6 个角色的初始武器装配都纳入自动回归，而不是只覆盖部分角色。
- 确认主菜单预览、HUD 三槽负载和开局后的 run summary 使用同一套角色装配结果。

### 本次改动

- `CharacterSmokeTest.gd` 新增 Rift Runner 装配断言：`basic_pistol`、`ricochet_blaster`、`arc_blade`，并检查 HUD 显示 `Ricochet Blaster`。
- `CharacterSmokeTest.gd` 新增 Emberwright 装配断言：`basic_pistol`、`blast_launcher`、`coil_carbine`，并检查 HUD 显示 `Blast Launcher`。
- 开始新局后，`CharacterSmokeTest.gd` 现在验证 run summary 的 `loadout` 包含当前角色的武器组合，避免结算 Build 回顾和实际 loadout 脱节。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\CharacterSmokeTest.log" "res://scenes/debug/CharacterSmokeTest.tscn"
CharacterSmokeTest passed.
```

### 仍需人工复核

- 实机确认 Rift Runner 和 Emberwright 虽然默认锁定，但主菜单预览武器变化仍然清晰，不会让玩家误以为已解锁可开局。
- 后续如果锁定角色不应完整展示负载，可把 HUD 预览改成“锁定剪影 + 代表性武器提示”，但当前先保留完整预览以服务图鉴和解锁动机。

## 2026-07-06 角色被动运行时加成第一版

### 目标

- 把 `PlayerCharacterData.passive_id` 从只展示/校验的静态字段推进到真实战斗运行时字段。
- 让 6 个角色在初始武器和主动技能之外，拥有可被烟测验证的轻量身份差异。

### 本次改动

- `Player.gd` 新增角色被动加成状态和 `get_character_passive_summary()`，暴露当前被动 ID、描述和运行时加成摘要。
- `Player.gd` 新增 `_apply_character_passive()` / `_clear_character_passive_bonuses()`，角色切换时先清理旧被动，再按 `passive_id` 应用当前角色加成。
- 被动加成已接入现有运行时 getter：伤害、射速、暴击、装填、移动倍率、弹幕格挡和护甲恢复速率，不新增资源字段或额外配置表。
- `CharacterSmokeTest.gd` 现在验证 6 个角色的被动 ID 和对应运行时效果，并把 Arcanist/Emberwright 的技能结束断言改为回到被动基线。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\CharacterSmokeTest.log" "res://scenes/debug/CharacterSmokeTest.tscn"
CharacterSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\ContentPipelineSmokeTest.log" "res://scenes/debug/ContentPipelineSmokeTest.tscn"
ContentPipelineSmokeTest passed.
```

### 仍需人工复核

- 实机感受 6 个角色的被动差异是否足够可感知；本轮数值先保持保守，避免在未做完整平衡前破坏武器和遗物权重。
- Field Medic 当前先通过护甲恢复速率体现 `triage_kit`，后续如果要更贴近治疗身份，可扩展为清房恢复、拾取治疗增益或低血量触发类被动。
- `ContentPipelineSmokeTest` 退出时仍打印既有 RID/ObjectDB/resource 泄漏告警；本轮目标测试退出码为 0，泄漏清理仍建议作为独立任务处理。

## 2026-07-06 Field Medic 清房恢复被动第一版

### 目标

- 把角色被动从纯倍率继续推进到事件型规则，让 Field Medic 的治疗身份在房间推进节奏中有实际反馈。
- 复用现有 `Events.room_cleared`、治疗和护甲恢复事件链路，不为单个被动新增一套平行机制。

### 本次改动

- `Player.gd` 在 `_ready()` 中连接 `Events.room_cleared`，并新增 `_on_room_cleared_for_passive()`。
- `triage_kit` 现在除护甲恢复速率外，还配置 `room_clear_heal_amount = 1` 和 `room_clear_shield_amount = 1`。
- 清房恢复只在当前被动 ID 为 `triage_kit` 且玩家未死亡时触发，并分别复用 `heal()` 与 `add_shield()`，自然进入 HUD、音效和事件反馈。
- `get_character_passive_summary()` 新增清房恢复参数，`_clear_character_passive_bonuses()` 同步清理，避免切换角色后残留事件型效果。
- `CharacterSmokeTest.gd` 新增 Field Medic 缺血缺甲后触发 `Events.room_cleared` 的断言，确认清房恢复和主动技能治疗互不替代。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\CharacterSmokeTest.log" "res://scenes/debug/CharacterSmokeTest.tscn"
CharacterSmokeTest passed.
```

### 仍需人工复核

- 实机确认 Field Medic 清房恢复不会让前两层容错过高；如果过强，可改成只恢复 HP 或只在低血/破甲后触发。
- 后续可按同一模式继续把其它角色被动推进到事件型效果，例如 Warden 破甲后短暂格挡强化、Rift Runner 清房后短时移速奖励、Emberwright 击杀后短时爆发窗口。

## 2026-07-06 Warden 破甲守势被动第一版

### 目标

- 继续把角色被动从静态倍率推进到事件型规则，让 Warden 的高护甲/近战挡弹身份在破甲瞬间有明确战斗反馈。
- 复用现有护甲破裂信号和近战挡弹 getter，不改受击结算、不新增平行防御系统。

### 本次改动

- `Player.gd` 在 `_ready()` 中连接 `Events.player_shield_broken`，并新增 `_on_player_shield_broken_for_passive()`。
- `armored_core` 新增 `shield_break_guard` 配置：护甲破裂后短时增加近战挡弹半径、挡弹角度和反击伤害。
- `get_projectile_block_radius_bonus()`、`get_projectile_block_arc_bonus()` 和 `get_projectile_block_damage_bonus()` 会在守势窗口激活时叠加临时被动收益。
- `_tick_timers()` 统一衰减守势窗口，`_clear_character_passive_bonuses()` 同步清理持续时间、剩余时间和临时挡弹参数。
- `get_character_passive_summary()` 新增 `shield_break_guard_*` 字段，暴露持续时间、剩余时间、激活状态和临时挡弹参数。
- `CharacterSmokeTest.gd` 新增 Warden 破甲事件断言：触发后挡弹三项参数上升，计时结束后回到基础被动值。
- 同步收窄技能冷却浮动文本断言：检查 `SKILL CD` 文本存在，而不是要求浮动文本总数增加，避免被同一测试内的 `ARMOR BREAK` 文本干扰。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\CharacterSmokeTest.log" "res://scenes/debug/CharacterSmokeTest.tscn"
CharacterSmokeTest passed.
```

### 仍需人工复核

- 实机确认 Warden 破甲后的短时挡弹窗口能被玩家感知，尤其是在 Arc Blade 面对密集弹幕时是否足够清楚。
- 如果窗口过强，可优先降低反击伤害加成；如果不够明显，可增加 HUD/角色身上的短时护盾视觉，而不是继续堆数值。

## 2026-07-06 Rift Runner 清房移速窗口第一版

### 目标

- 继续把角色被动推进到事件型规则，让 Rift Runner 的敏捷身份在清房节奏中形成短时机动奖励。
- 复用现有 `Events.room_cleared` 和临时移速计时，不新增独立移动系统。

### 本次改动

- `phase_footing` 除常驻移速加成外，新增 `room_clear_speed_multiplier_bonus` 和 `room_clear_speed_duration` 参数。
- `_on_room_cleared_for_passive()` 现在按当前 `passive_id` 分发：Rift Runner 触发清房移速，Field Medic 触发清房恢复。
- 清房移速复用 `apply_temporary_speed_boost()`、`_speed_boost_timer` 和 `get_current_speed_multiplier()`，到期后沿现有 `_tick_timers()` 路径回落。
- `get_character_passive_summary()` 新增 `room_clear_speed_multiplier_bonus`、`room_clear_speed_duration`、`room_clear_speed_active` 和 `speed_boost_remaining`。
- 角色切换时新增 `_clear_temporary_speed_boost()` 调用，避免 Rift Runner 的清房速度窗口残留到其它角色。
- `CharacterSmokeTest.gd` 新增 Rift Runner 清房事件断言，确认清房后速度高于常驻被动基线，并在计时结束后回到基线。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\CharacterSmokeTest.log" "res://scenes/debug/CharacterSmokeTest.tscn"
CharacterSmokeTest passed.
```

### 仍需人工复核

- 实机确认清房移速窗口不会让玩家在出门、领奖励或进下一房时产生失控感；如果节奏过快，优先缩短持续时间而不是取消机制。
- 后续可给 Rift Runner 加一个轻量可视反馈，例如脚下短暂残影或 HUD 小图标，避免玩家只通过移动速度变化感知被动。

## 2026-07-06 Emberwright 击杀爆发被动第一版

### 目标

- 继续把角色被动推进到事件型规则，让 Emberwright 的爆发身份在击杀节奏中形成短时伤害/射速窗口。
- 保持事件房临时规则、主动技能和角色被动三条加成链路彼此独立，避免一个效果覆盖另一个效果。

### 本次改动

- `Player.gd` 在 `_ready()` 中连接 `Events.enemy_died`，并新增 `_on_enemy_died_for_passive()`。
- `volatile_focus` 除常驻伤害加成外，新增 `kill_burst_duration`、`kill_burst_damage_multiplier_bonus` 和 `kill_burst_fire_rate_multiplier_bonus` 参数。
- 击杀爆发使用独立 `_passive_kill_burst_*` 状态接入 `get_damage_multiplier()` 和 `get_fire_rate_multiplier()`，不复用 `_temporary_rule_*`。
- `_tick_timers()` 统一衰减击杀爆发计时，`_clear_character_passive_bonuses()` 同步清理持续时间、剩余时间和爆发倍率。
- `get_character_passive_summary()` 新增 `kill_burst_*` 字段，暴露持续时间、剩余时间、激活状态、伤害倍率和射速倍率。
- `CharacterSmokeTest.gd` 新增 Emberwright 击杀事件断言，确认爆发窗口会激活、伤害和射速高于常驻被动基线，并在计时结束后回到基线。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\CharacterSmokeTest.log" "res://scenes/debug/CharacterSmokeTest.tscn"
CharacterSmokeTest passed.
```

### 仍需人工复核

- 实机确认击杀爆发窗口不会和 Emberwright 主动技能叠得过高；如果爆发过强，优先降低击杀窗口射速加成。
- 后续可增加一次轻量视觉反馈，例如击杀后武器或角色短暂发光，让玩家明确知道爆发窗口已触发。

## 2026-07-06 Arcanist 能量消耗 Focus 被动第一版

### 目标

- 继续把角色被动推进到事件型规则，让 Arcanist 的高能量身份在武器能量消耗循环中形成短时操作反馈。
- 把武器能量消耗、主动技能回能、事件房临时规则和击杀爆发保持为独立链路，避免触发条件互相污染。

### 本次改动

- `Player.gd` 在 `spend_energy_for_weapon()` 成功消耗能量后调用 `_trigger_energy_spend_focus_for_passive()`。
- `energy_focus` 除常驻射速/装填加成外，新增 `energy_spend_focus_duration`、`energy_spend_focus_fire_rate_multiplier_bonus` 和 `energy_spend_focus_reload_speed_multiplier_bonus`。
- Focus 窗口使用独立 `_passive_energy_spend_focus_*` 状态接入 `get_fire_rate_multiplier()` 和 `get_reload_speed_multiplier()`。
- `_tick_timers()` 统一衰减 Focus 计时，`_clear_character_passive_bonuses()` 同步清理持续时间、剩余时间和倍率。
- `get_character_passive_summary()` 新增 `energy_spend_focus_*` 字段，暴露持续时间、剩余时间、激活状态、射速倍率和装填倍率。
- `CharacterSmokeTest.gd` 新增 Arcanist 使用 `Energy Staff` 消耗武器能量的断言，确认 Focus 窗口会激活、射速和装填高于常驻被动基线，并在计时结束后回到基线。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\CharacterSmokeTest.log" "res://scenes/debug/CharacterSmokeTest.tscn"
CharacterSmokeTest passed.
```

### 仍需人工复核

- 实机确认 Arcanist 使用高耗能武器时 Focus 窗口不会导致射速过高；如果过强，优先降低射速加成，保留装填手感奖励。
- 后续可把 Focus 状态接入 HUD 小图标或武器高亮，让玩家明确知道“花能量换短时流畅输出”的节奏。

## 2026-07-06 Wanderer 暴击稳定输出被动第一版

### 目标

- 继续把角色被动推进到事件型规则，让 Wanderer 的均衡/稳定身份在暴击节奏中形成短时射速和装填反馈。
- 复用现有暴击事件链路，保持暴击反馈、角色被动、主动技能和其它事件型被动彼此独立。

### 本次改动

- `Player.gd` 在 `_ready()` 中连接 `Events.projectile_critical_hit`，并新增 `_on_projectile_critical_hit_for_passive()`。
- `steady_hands` 除常驻暴击率和装填加成外，新增 `critical_focus_duration`、`critical_focus_fire_rate_multiplier_bonus` 和 `critical_focus_reload_speed_multiplier_bonus`。
- 暴击稳定输出窗口使用独立 `_passive_critical_focus_*` 状态接入 `get_fire_rate_multiplier()` 和 `get_reload_speed_multiplier()`。
- 暴击回调会忽略目标为玩家自身的反馈事件，避免调试烟测或未来敌方暴击事件误触 Wanderer 被动。
- `_tick_timers()` 统一衰减暴击窗口计时，`_clear_character_passive_bonuses()` 同步清理持续时间、剩余时间和倍率。
- `get_character_passive_summary()` 新增 `critical_focus_*` 字段，暴露持续时间、剩余时间、激活状态、射速倍率和装填倍率。
- `CharacterSmokeTest.gd` 新增 Wanderer 暴击事件断言，确认稳定输出窗口会激活、射速和装填高于常驻被动基线，并在计时结束后回到基线。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\CharacterSmokeTest.log" "res://scenes/debug/CharacterSmokeTest.tscn"
CharacterSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\ContentPipelineSmokeTest.log" "res://scenes/debug/ContentPipelineSmokeTest.tscn"
ContentPipelineSmokeTest passed.
```

### 仍需人工复核

- 实机确认 Wanderer 暴击后的短时稳定窗口足够可感知，但不会让高暴击武器形成过强常驻射速收益。
- 后续可把暴击窗口接入轻量 HUD 小图标或武器高亮，让玩家更明确地区分常驻稳定性和暴击后的短时输出奖励。

## 2026-07-06 角色事件型被动 HUD 状态第一版

### 目标

- 提高角色事件型被动的战斗内可读性，让玩家在 HUD 中能看到当前角色被动基线和短时触发窗口。
- 保持 HUD 只消费 Player 暴露的摘要字段，不在 HUD 里复制角色判定或计时逻辑。

### 本次改动

- `HUD.tscn` 新增 `PassiveStatusLabel`，位于 Skill 与 Weapon 状态之间，常态显示当前角色被动名称。
- `HUD.gd` 新增 `update_character_passive_status()`，按 `get_character_passive_summary()` 中的 active/remaining 字段格式化短时窗口文案。
- 当前激活窗口会显示为 `Crit Focus`、`Guard Stance`、`Energy Flow`、`Speed Surge` 或 `Kill Burst` 加剩余秒数；无窗口时回到 `Steady Hands`、`Armored Core`、`Energy Focus`、`Phase Footing`、`Volatile Focus` 或 `Triage Kit` 基线。
- `Main.gd` 新增 `_refresh_passive_status_hud()`，在主循环和角色 HUD 刷新时同步被动摘要，确保倒计时和角色切换都能刷新。
- `CharacterSmokeTest.gd` 扩展各角色已有事件型被动断言，同步检查 HUD 基线和激活文案。
- `UILayoutSmokeTest.gd` 修正 ScrollContainer 校验边界：检查滚动容器在视口内，但不把可滚动内容完整高度误判为溢出。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\CharacterSmokeTest.log" "res://scenes/debug/CharacterSmokeTest.tscn"
CharacterSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\ContentPipelineSmokeTest.log" "res://scenes/debug/ContentPipelineSmokeTest.tscn"
ContentPipelineSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.
```

### 仍需人工复核

- 实机确认左上角 HUD 加入被动状态后不遮挡 720p 战斗视野；如空间过紧，优先把被动状态压缩为图标/短 token，而不是移除反馈。
- 后续可为被动状态增加小图标和轻量闪烁，让触发瞬间比纯文本倒计时更清晰。

## 2026-07-06 角色事件型被动浮字反馈第一版

### 目标

- 把上一轮 HUD 被动状态进一步推进到战斗瞬时反馈，让玩家在触发角色被动时同时获得 HUD 状态和场景浮字提示。
- 建立统一被动触发事件，避免后续角色继续扩展时在 Main、HUD 和 Player 之间散落一次性反馈逻辑。

### 本次改动

- `Events.gd` 新增 `player_passive_triggered(player, passive_id, effect_name, duration)` 信号。
- `Player.gd` 在 `Crit Focus`、`Guard Stance`、`Energy Flow`、`Speed Surge`、`Kill Burst` 和 `Triage Kit` 触发时发出统一信号。
- 带持续时间的窗口在从未激活变为激活时才发反馈，避免连续暴击或连续能量消耗反复刷屏；持续窗口本身仍会刷新计时。
- `Main.gd` 监听 `player_passive_triggered` 后复用 `show_message()` 和 `_spawn_floating_text()`，在玩家上方显示对应被动浮字，并按 `passive_id` 给出区分颜色。
- `CharacterSmokeTest.gd` 扩展为验证各角色事件型被动触发时出现 `CRIT FOCUS`、`GUARD STANCE`、`ENERGY FLOW`、`SPEED SURGE`、`KILL BURST` 和 `TRIAGE KIT` 浮字。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\CharacterSmokeTest.log" "res://scenes/debug/CharacterSmokeTest.tscn"
CharacterSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\CombatFeedbackSmokeTest.log" "res://scenes/debug/CombatFeedbackSmokeTest.tscn"
CombatFeedbackSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\ContentPipelineSmokeTest.log" "res://scenes/debug/ContentPipelineSmokeTest.tscn"
ContentPipelineSmokeTest passed.
```

### 仍需人工复核

- 实机确认被动浮字和伤害/暴击/治疗浮字同时出现时不会遮挡角色周围弹幕判断；如过密，优先降低被动浮字持续时间或偏移高度。
- 后续可把被动触发事件接入轻量音效或图标闪烁，但应继续通过统一 `player_passive_triggered` 事件扩展。

## 2026-07-06 角色事件型被动音效反馈第一版

### 目标

- 让上一轮统一被动触发事件同时驱动音频反馈，补齐“HUD 状态 + 场景浮字 + SFX”的完整触发感知链路。
- 保持音频层只消费 `player_passive_triggered`，不把六个角色的触发条件复制进 `AudioFeedback`。

### 本次改动

- `AudioFeedback.gd` 在 `_connect_events()` 中新增 `Events.player_passive_triggered` 监听。
- 新增 `_resolve_passive_trigger_sfx_id()`，把六个被动 ID 映射到独立程序化占位音效：`passive_focus`、`passive_guard`、`passive_energy`、`passive_speed`、`passive_burst` 和 `passive_support`。
- 新增 `passive_trigger` 回退音效，后续新增角色但暂未配置专属 SFX 时不会静默。
- 新增 `get_passive_trigger_sfx_id_for_test()`，让烟测直接校验被动 ID 到音效 ID 的解析结果。
- `AudioFeedbackSmokeTest.gd` 扩展为逐一发出 `steady_hands`、`armored_core`、`energy_focus`、`phase_footing`、`volatile_focus` 和 `triage_kit` 触发事件，断言 SFX 计数增加且最后播放 ID 正确。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\AudioFeedbackSmokeTest.log" "res://scenes/debug/AudioFeedbackSmokeTest.tscn"
AudioFeedbackSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\CharacterSmokeTest.log" "res://scenes/debug/CharacterSmokeTest.tscn"
CharacterSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\ContentPipelineSmokeTest.log" "res://scenes/debug/ContentPipelineSmokeTest.tscn"
ContentPipelineSmokeTest passed.
```

`ContentPipelineSmokeTest` 退出时仍有既有资源/RID/ObjectDB 清理告警，但退出码为 0。

### 仍需人工复核

- 实机确认六类被动触发音色能被听出差异，且不会和暴击、治疗、护甲破裂等同帧反馈互相抢占。
- 后续接入正式音频素材时，继续保留 `player_passive_triggered` 作为唯一入口，只替换各 `passive_*` ID 对应的实际音频表现。

## 2026-07-06 角色事件型被动 HUD 脉冲第一版

### 目标

- 在已有“HUD 状态 + 场景浮字 + SFX”的基础上，让被动触发瞬间也能在左上角被动状态行产生短促高亮。
- 不新增布局节点，不改变 HUD 占位尺寸，避免小视口下因为被动反馈造成文本跳动或遮挡。

### 本次改动

- `HUD.gd` 新增 `PASSIVE_TRIGGER_PULSE_DURATION`、`PASSIVE_STATUS_TRIGGER_COLOR` 和 `_passive_trigger_pulse_*` 状态。
- 新增 `show_passive_trigger_pulse()`，被动触发时短促提亮 `PassiveStatusLabel`。
- `update_character_passive_status()` 改为记录当前被动状态是否处于激活窗口，并通过 `_refresh_passive_status_color()` 统一处理基线、激活状态和触发脉冲颜色。
- `Main.gd` 在 `_on_player_passive_triggered()` 中调用 `show_passive_trigger_pulse()`，继续通过统一事件把 Player 触发逻辑和 HUD 表现解耦。
- `CharacterSmokeTest.gd` 在 Wanderer 暴击被动链路中新增断言，覆盖被动状态脉冲启动、颜色提亮和计时结束回落。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\CharacterSmokeTest.log" "res://scenes/debug/CharacterSmokeTest.tscn"
CharacterSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.
```

### 仍需人工复核

- 实机确认被动状态行提亮幅度足够可见，但不会和 Skill、Energy、Armor 的提示颜色混淆。
- 后续如果加入正式被动小图标，应复用同一 `show_passive_trigger_pulse()` 入口，而不是从 Player 侧直接操作 HUD。

## 2026-07-06 祝福/雕像触发音效反馈第一版

### 目标

- 把事件祝福和雕像共鸣纳入统一战斗音频反馈，让中等强度规则改写在触发瞬间更容易被玩家感知。
- 保持祝福/雕像系统只负责发事件，音频层只消费事件，不把规则效果复制到 `AudioFeedback`。

### 本次改动

- `AudioFeedback.gd` 在 `_connect_events()` 中新增 `Events.blessing_triggered`、`Events.statue_triggered` 和 `Events.statue_attuned` 监听。
- 新增祝福触发音效分流：`on_room_clear` -> `blessing_clear`，`on_kill` -> `blessing_kill`，`on_hurt` -> `blessing_guard`，`on_statue_triggered` -> `blessing_resonance`，未知事件回退到 `blessing_trigger`。
- 新增雕像音效分流：`on_skill_used` -> `statue_skill`，未知触发回退到 `statue_trigger`，雕像调谐固定使用 `statue_attune`。
- 新增 `get_blessing_trigger_sfx_id_for_test()` 和 `get_statue_trigger_sfx_id_for_test()`，让烟测直接校验事件到音效 ID 的映射。
- `AudioFeedbackSmokeTest.gd` 扩展为覆盖祝福触发、祝福回退、雕像触发、雕像回退和雕像调谐的 SFX 播放。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\AudioFeedbackSmokeTest.log" "res://scenes/debug/AudioFeedbackSmokeTest.tscn"
AudioFeedbackSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\EventRoomSmokeTest.log" "res://scenes/debug/EventRoomSmokeTest.tscn"
EventRoomSmokeTest passed.
```

### 仍需人工复核

- 实机确认祝福触发、雕像触发和雕像调谐的占位音色能被区分，且不会和被动、暴击、护甲破裂等同帧反馈混在一起。
- 后续正式音频素材替换时，保留 `blessing_*`、`statue_*` 这组稳定 ID，不从祝福/雕像系统直接播放音频。

## 2026-07-06 祝福/雕像触发 HUD 规则提示第一版

### 目标

- 在上一轮规则类 SFX 基础上补齐 HUD 状态区反馈，让祝福和雕像触发不仅出现在浮字和中心消息里，也能在左上角状态区短暂留痕。
- 新增反馈必须保持稳定布局，不因为触发而把武器槽、弹药、金币等战斗信息上下挤动。

### 本次改动

- `HUD.tscn` 在 `PassiveStatusLabel` 下方新增常驻 `RuleFeedbackLabel`，默认文本为 `Rule: --`。
- `HUD.gd` 新增 `show_rule_trigger_feedback(kind, display_name, trigger_event, duration)`，用独立计时控制最近一次规则触发提示。
- 规则提示按类型使用颜色：`Blessing` 使用暖色，`Statue` 使用冷色，计时结束后回到 `Rule: --` 和基础灰色。
- `Main.gd` 在 `_on_blessing_triggered()`、`_on_statue_triggered()` 和 `_on_statue_attuned()` 中调用 `show_rule_trigger_feedback()`。
- `EventRoomSmokeTest.gd` 新增 HUD 规则提示断言，覆盖房间清理祝福、技能雕像和雕像调谐，并验证提示会按时回落。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\EventRoomSmokeTest.log" "res://scenes/debug/EventRoomSmokeTest.tscn"
EventRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.
```

### 仍需人工复核

- 实机确认 `RuleFeedbackLabel` 在 720p 下不会让左上角状态区显得过密；如过密，优先改成图标 + 短码，而不是移除规则触发反馈。
- 后续正式 UI 图标落地时，可把该行升级为 Blessing/Statue 小图标槽，继续复用 `show_rule_trigger_feedback()`。

## 2026-07-06 规则触发 HUD 图标反馈第一版

### 目标

- 把上一轮纯文本规则提示升级为“注册图标 + 短码 fallback + 简短文本”的固定 HUD 行，让祝福/雕像触发在状态区更容易被辨认。
- 继续复用 `ContentIconRegistry` 和现有资源 `icon_key`，不为规则提示新增一套并行图标解析逻辑。

### 本次改动

- `HUD.tscn` 将 `RuleFeedbackLabel` 包进 `RuleFeedbackRow`，新增 `RuleFeedbackIconTexture` 和 `RuleFeedbackTokenLabel`，保持行高稳定。
- `HUD.gd` 的 `show_rule_trigger_feedback()` 扩展为接收 `icon_key`，按 `Blessing`/`Statue` 选择 `blessings`/`statues` 注册表页面，优先加载注册贴图，缺贴图时显示类型 token。
- `Main.gd` 在祝福触发、雕像触发和雕像调谐回调中调用 `_resolve_content_icon_key()`，把真实资源图标键传给 HUD。
- `EventRoomSmokeTest.gd` 扩展规则反馈断言，覆盖文本、颜色、图标键、注册贴图路径、图标可见性、fallback token 和计时回落后的清理状态。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\EventRoomSmokeTest.log" "res://scenes/debug/EventRoomSmokeTest.tscn"
EventRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.
```

### 仍需人工复核

- 实机确认图标、短码和文本在 720p 左上角状态区仍然可读，且不会和 `PassiveStatusLabel`、武器槽状态挤在一起。
- 后续替换正式 UI 图标时，优先补齐 `ContentIconRegistry` 资源和贴图，不修改祝福/雕像触发链路。

## 2026-07-06 角色被动 HUD 图标反馈第一版

### 目标

- 把角色被动状态从纯文本升级为“角色图标 + CHR fallback + 被动文本”的固定 HUD 行，让战斗中角色身份和被动状态更直观。
- 继续让 HUD 只消费 `Player.get_character_passive_summary()`，不从 HUD 反查 Player 或角色资源，保持表现层边界清晰。

### 本次改动

- `HUD.tscn` 将 `PassiveStatusLabel` 包进 `PassiveStatusRow`，新增 `PassiveStatusIconTexture` 和 `PassiveStatusTokenLabel`，保持行高稳定。
- `Player.gd` 的 `get_character_passive_summary()` 新增 `character_id`、`display_name` 和 `icon_key`；角色资源未填写 `icon_key` 时回退为 `character_<id>`。
- `HUD.gd` 的 `update_character_passive_status()` 现在会刷新角色图标，优先加载 `ContentIconRegistry` 的 `characters` 页贴图，缺贴图时显示 `CHR` token，并继续保留被动触发脉冲颜色。
- `CharacterSmokeTest.gd` 新增被动状态图标 helper，覆盖默认 Wanderer 和切换 Warden 后的图标键、注册贴图路径、可见性和 fallback token。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\CharacterSmokeTest.log" "res://scenes/debug/CharacterSmokeTest.tscn"
CharacterSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.
```

### 仍需人工复核

- 实机确认左上角 `PassiveStatusRow` 的图标、token 和文本在 720p 下不会和规则反馈行、武器槽状态显得过密。
- 后续给角色补正式头像或职业图标时，只更新 `ContentIconRegistry` 和角色资源 `icon_key`，不改 HUD 刷新链路。

## 2026-07-06 自爆敌人危险圈预警第一版

### 目标

- 补齐 Bomber / Volatile Vessel 这类自爆敌人的前摇可读性，让玩家能在爆炸前看到明确半径，而不是只靠敌人闪色判断。
- 复用现有 `DangerWarning`、预警音效事件和死亡归因链路，不新增一套自爆专用视觉系统。

### 本次改动

- `Enemy.gd` 在 `BOMBER` 行为进入 `_is_self_destructing` 时调用 `_spawn_self_destruct_warning()`。
- `_spawn_self_destruct_warning()` 会在敌人当前位置生成圆形 `DangerWarning`，半径使用 `self_destruct_radius`，持续时间使用 `self_destruct_windup`。
- 自爆预警会把 `attack_damage` 和来源敌人传入 `configure_circle()`，但将预警节点的 `target_group` 清空，因此只承担预警/音频/来源语义，不重复造成伤害。
- 原有 `_self_destruct()` 伤害结算不变，仍在前摇结束后由 Bomber 自身按 `self_destruct_radius` 造成一次伤害并死亡。
- `EnemyVarietySmokeTest.gd` 扩展 Bomber 测试，验证自爆前出现圆形预警、具备可读轮廓、前摇期间不提前掉血，前摇结束后才伤害玩家。
- 同一烟测中把 Barrage Totem 的测试前摇显式拉长，并让精英死亡爆炸测试逐帧保持玩家在爆炸圈内，降低帧率差异导致的误报。

### 验证状态

```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\EnemyVarietySmokeTest.log" "res://scenes/debug/EnemyVarietySmokeTest.tscn"
EnemyVarietySmokeTest passed.
```

### 仍需人工复核

- 实机确认自爆圆形预警在敌人聚集、弹幕和低血红边同时出现时仍然清晰，不会被角色/弹丸遮住。
- 后续正式美术替换时，可给自爆敌人增加更明显的蓄能动画，但伤害半径仍应以 `DangerWarning` 圆形预警为准。

## 2026-07-06 近战挡弹反馈事件与音效第一版

### 目标
- 让 Guard Cleaver 等近战挡弹不只删除敌方弹丸和记录 debug meta，也能进入统一战斗反馈链路。
- 区分“护甲吸收伤害”和“武器主动挡弹”两种语义，便于后续正式音效、浮字或 HUD 图标继续接入。

### 本次改动
- `Events.gd` 新增 `player_projectile_blocked(player, weapon_data, blocked_count, block_position)`。
- `Weapon.gd` 在 `_block_enemy_projectiles()` 成功挡弹后发出该事件，携带挡弹数量、武器数据和挡弹位置。
- `AudioFeedback.gd` 订阅该事件，`blocked_count > 0` 时播放 `projectile_block` 程序化占位音效。
- `AudioFeedbackSmokeTest.gd` 新增直接事件断言，确认最近播放 SFX 为 `projectile_block`。
- 新增 `ProjectileBlockSmokeTest.gd/.tscn`，覆盖 Guard Cleaver 真实挡弹、事件字段、弹丸移除、后方弹丸不受影响和反击伤害。
- `WeaponSmokeTest.gd` 顺手修正一个 Variant 推断警告（`floating_count_before` 显式 `int()`），但未把本批验证绑定到该宽烟测。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\ProjectileBlockSmokeTest.log" "res://scenes/debug/ProjectileBlockSmokeTest.tscn"
ProjectileBlockSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\AudioFeedbackSmokeTest.log" "res://scenes/debug/AudioFeedbackSmokeTest.tscn"
AudioFeedbackSmokeTest passed.
```

### 仍需人工复核
- 实机确认 `projectile_block` 与 `armor_block`、`melee_swing` 的占位音色能区分，且连续挡弹时不会过吵。
- 后续正式化时可把该事件继续接入短浮字、武器槽闪烁或挡弹火花，但不要把表现逻辑塞回 `Weapon.gd`。

## 2026-07-06 近战挡弹浮字反馈第一版

### 目标
- 在上一批挡弹事件和音效基础上，补齐场景位置反馈，让玩家能看出“哪一颗弹被挡掉”。
- 继续保持武器脚本只负责战斗结算和事件发出，视觉反馈由 `Main.gd` 统一消费事件。

### 本次改动
- `Main.gd` 订阅 `Events.player_projectile_blocked`。
- 新增 `_on_player_projectile_blocked()`，仅处理当前玩家自己的挡弹事件；`blocked_count <= 0` 或来源不是当前玩家时直接忽略。
- 成功挡弹时在 `block_position` 附近生成 `BLOCK` / `BLOCK xN` 浮字，并按挡弹数量触发轻量屏幕震动。
- 挡弹浮字复用 `_spawn_floating_text()`，因此继续受 Combat Text 强度设置影响，不新增独立表现开关。
- `CombatFeedbackSmokeTest.gd` 新增 `_verify_projectile_block_feedback_position()`，直接发出挡弹事件并断言浮字出现在挡弹位置附近。
- `CombatFeedbackSmokeTest.gd` 同步加固初始 HP 下限和未暂停断言，避免低血角色在反馈烟测中被打死后让浮字/闪屏计时误报。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\CombatFeedbackSmokeTest.log" "res://scenes/debug/CombatFeedbackSmokeTest.tscn"
CombatFeedbackSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\ProjectileBlockSmokeTest.log" "res://scenes/debug/ProjectileBlockSmokeTest.tscn"
ProjectileBlockSmokeTest passed.
```

### 仍需人工复核
- 实机确认 `BLOCK` 浮字不会和伤害数字、暴击、祝福/雕像浮字在密集弹幕中挤在一起。
- 后续正式化可把挡弹事件继续接入短火花或武器槽闪烁，但仍应保持 `Weapon.gd -> Events -> Main/HUD/Audio` 的单向反馈链路。

## 2026-07-06 近战挡弹火花反馈第一版

### 目标
- 在挡弹音效和 `BLOCK` 浮字基础上，补一层短促位置特效，让玩家更容易读到弹丸被清除的瞬间和位置。
- 保持挡弹火花是统一事件反馈的一部分，不让 `Weapon.gd` 直接生成表现节点。

### 本次改动
- 新增 `ProjectileBlockSpark.gd/.tscn`，使用程序化圆环、内环和放射线绘制挡弹瞬间火花。
- 火花加入 `projectile_block_spark` 分组，短生命周期结束后自动 `queue_free()`。
- `ProjectileBlockSpark.configure(blocked_count)` 会记录挡弹数量，并按数量略微增加放射线数量和扩散半径。
- `Main.gd` 新增 `PROJECTILE_BLOCK_SPARK_SCENE` 和 `_spawn_projectile_block_spark()`，在 `_on_player_projectile_blocked()` 中与 `BLOCK` 浮字一起生成。
- `CombatFeedbackSmokeTest.gd` 的挡弹反馈断言扩展为同时验证浮字和火花位置、挡弹数量以及火花清理。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\CombatFeedbackSmokeTest.log" "res://scenes/debug/CombatFeedbackSmokeTest.tscn"
CombatFeedbackSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\ProjectileBlockSmokeTest.log" "res://scenes/debug/ProjectileBlockSmokeTest.tscn"
ProjectileBlockSmokeTest passed.
```

### 仍需人工复核
- 实机确认火花在密集弹幕、近战扇形闪光和危险预警线同时出现时仍然清晰，但不会盖住敌方弹幕。
- 后续替换正式素材时，可保留 `ProjectileBlockSpark.configure(blocked_count)` 作为统一入口，只替换绘制实现或场景节点。

## 2026-07-06 近战挡弹武器槽脉冲第一版

### 目标
- 让玩家不只在场景位置看到挡弹，也能从当前武器槽读到“这把武器刚刚完成了防守动作”。
- 保持挡弹 HUD 反馈仍由 `player_projectile_blocked` 统一事件驱动，不从 `Weapon.gd` 直接操作 UI。

### 本次改动
- `HUD.gd` 新增 `WEAPON_BLOCK_PULSE_DURATION` 和一组挡弹脉冲颜色常量。
- `HUD.gd` 新增 `_weapon_block_pulse_timer` / `_weapon_block_pulse_duration` 和 `show_weapon_block_pulse()`。
- 挡弹脉冲期间，武器名称、当前负载槽、武器槽边框、图标和状态条会短暂向青色守御反馈过渡；状态行显示 `Guard`。
- `Main.gd` 在 `_on_player_projectile_blocked()` 中调用 `hud.show_weapon_block_pulse()`，与浮字、火花、屏幕震动共用同一个挡弹事件入口。
- `CombatFeedbackSmokeTest.gd` 扩展挡弹反馈断言，验证 HUD 武器挡弹脉冲触发，并确认武器名称和当前负载槽颜色发生变化。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\CombatFeedbackSmokeTest.log" "res://scenes/debug/CombatFeedbackSmokeTest.tscn"
CombatFeedbackSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\ProjectileBlockSmokeTest.log" "res://scenes/debug/ProjectileBlockSmokeTest.tscn"
ProjectileBlockSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.
```

### 仍需人工复核
- 实机确认 `Guard` 状态行和青色武器槽脉冲在连续挡弹时不会过闪，也不会与换弹 ready / 切槽脉冲混淆。
- 后续正式 UI 资源替换时，保留 `show_weapon_block_pulse()` 入口，可把颜色脉冲升级为武器槽短闪、护盾小图标或格挡纹理。

## 2026-07-06 近战挡弹结算统计第一版

### 目标
- 让 Guard / 近战挡弹构筑不只在战斗中有音效、浮字、火花和武器槽脉冲，也能在本局复盘里看到实际挡掉了多少敌方弹丸。
- 把主动挡弹与 Armor 吸收伤害区分展示，避免 `Shield Blocked` 同时承担护甲吸收和武器格挡两种语义。

### 本次改动
- `Main.gd` 新增 `_projectiles_blocked` 本局计数器。
- `_reset_run_stats()` 会清零挡弹计数。
- `_on_player_projectile_blocked()` 在来源为当前玩家、`blocked_count > 0` 且 run 处于 RUNNING 时累加挡弹数量。
- `_build_run_summary()` 新增 `projectiles_blocked` 字段。
- `HUD.gd` 的结果总览文本和 `Combat` 分区新增 `Projectiles Blocked`。
- `RunSummarySmokeTest.gd` 新增直接挡弹事件，验证 summary 字段、结果面板文本和 Combat 分区文本都显示挡弹数量。
- `FullRunSmokeTest.gd` 新增完整路线 summary 字段存在性断言，保证三层通关流程也稳定带出该字段。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\RunSummarySmokeTest.log" "res://scenes/debug/RunSummarySmokeTest.tscn"
RunSummarySmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\ProjectileBlockSmokeTest.log" "res://scenes/debug/ProjectileBlockSmokeTest.tscn"
ProjectileBlockSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\FullRunSmokeTest.log" "res://scenes/debug/FullRunSmokeTest.tscn"
FullRunSmokeTest passed.
```

`FullRunSmokeTest` 首次使用 180 秒超时未完成且日志无错误；改用 300 秒超时重跑通过，用时约 255 秒。

### 仍需人工复核
- 实机确认结果面板 `Combat` 行不会过长；如果在 720p 结果页读起来拥挤，可把 `Projectiles Blocked` 简化为 `Guard Blocks`。
- 后续可继续把挡弹统计纳入 build 路线评分或训练房目标，但不应把 Armor 吸收和武器挡弹合并为同一个数值。

## 2026-07-09 近战挡弹历史最佳记录第一版

### 目标
- 让 Guard / 近战挡弹路线不只在单局结算显示，还能留下历史最佳记录，形成局外长期目标。
- 保持该记录和 Armor 吸收伤害分开，继续用 `projectiles_blocked` 表示武器主动挡弹。

### 本次改动
- `Main.gd` 的 `_record_run_result()` 新增 `best_projectiles_blocked` 更新逻辑。
- `_default_history_stats()` 新增 `best_projectiles_blocked`，旧 settings 缺字段时默认 0，现有 `_load_history_from_config()` / `_write_history_to_config()` 自动覆盖读写。
- `HUD.gd` 的结果总览和 `Record` 分区新增 `Best Guard Blocks`。
- `RunSummarySmokeTest.gd` 扩展历史记录、结果文本、Record 分区和重载 settings 断言，确认挡弹最佳记录可持久化。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\RunSummarySmokeTest.log" "res://scenes/debug/RunSummarySmokeTest.tscn"
RunSummarySmokeTest passed.
```

### 仍需人工复核
- 实机确认结果页 Record 行在 720p 下不会过长；如果拥挤，可把 `Best Guard Blocks` 缩为 `Best Guard`。
- 后续大厅 Records 页可进一步把该字段做成独立 Guard/防守记录卡，但当前先保证 settings 持久化和结果页可见。

## 2026-07-09 大厅 Records 挡弹最佳记录第一版

### 目标
- 把 `best_projectiles_blocked` 从结算页推进到局外大厅 Records，让 Guard / 挡弹构筑有可回看的长期目标。
- 避免继续拉长大厅主记录行，把防守类指标拆成独立 `Defense` 摘要。

### 本次改动
- `LobbyScreen.gd` 的 `_format_records_page()` 新增 `Defense: Best Guard Blocks N` 行。
- Hall All Records 总览和 Records 分页复用同一 Records 文案，因此都会显示挡弹最佳记录。
- `HallArchiveSmokeTest.gd` 在一次真实 run 中触发 `player_projectile_blocked`，通关后重载大厅并断言 `Best Guard Blocks 4`。
- `LobbyScreenSmokeTest.gd` 扩展 Records 分页断言，确认新档案会显示初始 `Best Guard Blocks 0`。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.
```

### 仍需人工复核
- 实机确认 All Records 总览在 720p 下增加一行 `Defense` 后滚动阅读仍然顺手。
- 后续可继续把 Records 页从纯文本推进为分组卡片，但当前先保证持久化数据能被大厅入口稳定读到。

## 2026-07-09 AimAssistController 候选组接口第一版

### 目标
- 让自动瞄准辅助不只服务战斗敌人，也能复用到训练靶、未来手柄输入和移动端目标选择。
- 保持 PC 首发策略不变：默认关闭，开启后仍是弱辅助，但底层接口从 Player 硬编码推进到可配置控制器。

### 本次改动
- `AimAssistController.gd` 新增 `candidate_groups`，默认 `["enemies"]`。
- 新增 `collect_candidates(source_tree)`，按候选组从场景树收集目标，并过滤无效、待删除和 `is_dead()` 为 true 的目标。
- 新增 `pick_target_from_tree(origin, aim_direction, source_tree)`，让调用方可以直接用控制器完成候选收集和目标选择。
- 新增 `set_candidate_groups()` / `get_candidate_groups()`，方便训练房、未来手柄层或移动端输入层切换目标来源。
- `Player.gd` 的 `_get_aim_assist_candidates()` 改为委托控制器收集候选，并补充测试用候选组配置/读取方法。
- `AimAssistSmokeTest.gd` 新增 `training_dummy` 候选组断言，验证非敌人组目标可以被辅助瞄准选中。
- `ContentPipelineSmokeTest.gd` 扩展控制器契约，覆盖自定义候选组、场景树收集和 `pick_target_from_tree()`。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\AimAssistSmokeTest.log" "res://scenes/debug/AimAssistSmokeTest.tscn"
AimAssistSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\ContentPipelineSmokeTest.log" "res://scenes/debug/ContentPipelineSmokeTest.tscn"
ContentPipelineSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\SettingsSmokeTest.log" "res://scenes/debug/SettingsSmokeTest.tscn"
SettingsSmokeTest passed.
```

`ContentPipelineSmokeTest` 退出时仍打印既有 RID/ObjectDB/resource 泄漏提示；本轮测试退出码为 0，泄漏清理仍建议作为独立任务处理。

### 仍需人工复核
- 实机开启 Aim Assist 后确认鼠标瞄准不会被过度吸附，尤其是高射速和近战 Guard 武器。
- 后续可把训练房加入一个“辅助瞄准校准”drill，让玩家在不进正式地牢的情况下调强度。

## 2026-07-09 训练房 Aim Assist 目标层切换第一版

### 目标
- 把上一批 `AimAssistController` 候选组接口接入真实状态流，让训练房使用训练靶目标层，正式战斗仍使用敌人目标层。
- 保持 PC 首发默认策略不变：Aim Assist 仍由设置控制开关和强度，本批只切换目标来源。

### 本次改动
- `Main.gd` 新增 `_apply_aim_assist_candidate_groups_for_state()`。
- `start_new_run()` 会在进入 RUNNING 时把 Aim Assist 候选组设为 `["enemies"]`。
- `start_training_room()` 和 `reset_training_room()` 会把候选组设为 `["training_dummy"]`。
- `_apply_gameplay_settings_to_player()` 在应用 Aim Assist 开关/强度后重新同步当前状态候选组，避免训练房打开设置后掉回默认敌人组。
- `TrainingRoomSmokeTest.gd` 新增进入训练和训练重置后的候选组断言。
- `TrainingRoomSmokeTest.gd` 同步修正 6 角色池下的角色导航：从锁定角色返回 Wanderer 时循环选择，而不是只切换一次。
- `SettingsSmokeTest.gd` 新增非训练状态候选组断言，确认普通状态仍使用 `enemies`，不误用 `training_dummy`。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrainingRoomSmokeTest.log" "res://scenes/debug/TrainingRoomSmokeTest.tscn"
TrainingRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\SettingsSmokeTest.log" "res://scenes/debug/SettingsSmokeTest.tscn"
SettingsSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\AimAssistSmokeTest.log" "res://scenes/debug/AimAssistSmokeTest.tscn"
AimAssistSmokeTest passed.
```

首次运行 `TrainingRoomSmokeTest` 失败在旧测试假设：6 角色池中从 Rift Runner 只切换一次不会回到 Wanderer。已改为循环导航并重跑通过。

### 仍需人工复核
- 实机在训练房开启 Aim Assist 后，确认准星只吸附训练靶，不被其它可能加入 `enemies` 组的测试节点干扰。
- 后续可以在训练 UI 中显示当前 Aim Assist 状态和强度，让训练房成为正式的辅助瞄准校准入口。

## 2026-07-09 训练 HUD Aim Assist 校准状态第一版

### 目标
- 让训练房不只后台切换 Aim Assist 目标层，也能在 HUD 中明确显示当前辅助瞄准开关、强度和目标来源。
- 把训练房推进为可用的 Aim Assist 校准入口，而不是只靠设置页和测试断言确认。

### 本次改动
- `HUD.gd` 的训练面板新增 `training_aim_assist_label`。
- `update_training_stats()` 会显示 `Aim Assist: On/Off XX% | Targets Training`。
- `Main.gd` 新增 `_sync_training_aim_assist_stats()`，在刷新训练 HUD 前写入 `aim_assist_text`、`aim_assist_enabled`、`aim_assist_strength_percent` 和 `aim_assist_target_layer`。
- `_apply_gameplay_settings_to_player()` 在训练状态下应用设置后会刷新训练 HUD，因此训练中保存 Aim Assist 设置会立刻反映到状态行。
- `TrainingRoomSmokeTest.gd` 扩展默认 `Off 35%` / `Targets Training` 断言，并验证训练中应用 `On 70%` 设置后 HUD 状态更新。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrainingRoomSmokeTest.log" "res://scenes/debug/TrainingRoomSmokeTest.tscn"
TrainingRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\SettingsSmokeTest.log" "res://scenes/debug/SettingsSmokeTest.tscn"
SettingsSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.
```

### 仍需人工复核
- 实机确认训练面板新增一行后，在 720p 下不会遮挡训练靶或让上方信息过密。
- 后续可补一个专门的 Aim Assist drill，用移动靶和不同强度档位帮助玩家找到合适设置。

## 2026-07-09 Aim Assist 校准训练 drill 第一版

### 目标
- 把训练房里的 Aim Assist 状态展示推进为实际可练习的校准 drill。
- 让玩家能在同一训练入口里比较辅助瞄准对偏移目标的吸附效果，并把完成结果记录为训练徽章。

### 本次改动
- `Main.gd` 新增 `Aim Assist` drill，包含两个 `assist` 偏移靶和一个 `standard` 直线参考靶。
- 新 drill 复用 `target_type_hits` 目标类型进度，完成条件为命中两个 `assist` 靶。
- `TrainingDummy.gd` 为 `assist` 类型补充独立视觉颜色，便于和普通靶、移动靶、护甲靶、Burst 靶区分。
- `TrainingRoomSmokeTest.gd` 扩展 Aim Assist drill 进入、目标文案、靶类型统计、两次命中完成、Clean 徽章保存、重置和重载后大厅展示断言。
- `LobbyScreenSmokeTest.gd` 和 `HallArchiveSmokeTest.gd` 同步训练徽章总数预期，从 `0/3` 更新到 `0/4`。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrainingRoomSmokeTest.log" "res://scenes/debug/TrainingRoomSmokeTest.tscn"
TrainingRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.
```

### 仍需人工复核
- 实机在训练房开启 Aim Assist 后，确认偏移 assist 靶能清楚体现吸附强度差异。
- 后续可把 Aim Assist drill 加入更明确的强度档位提示，帮助玩家在 Off、低强度和高强度之间快速比较。

## 2026-07-09 Aim Assist 强度档位反馈第一版

### 目标
- 让训练房 Aim Assist 校准不只显示开关和百分比，也能直接读出当前强度档位。
- 为新加入的 Aim Assist drill 提供更明确的 Off/低强度/中强度/高强度对照入口。

### 本次改动
- `Main.gd` 新增 `_get_aim_assist_strength_band()`，统一计算 `Off`、`Light`、`Balanced`、`Strong` 档位。
- `_sync_training_aim_assist_stats()` 现在会写入 `aim_assist_strength_band`，并生成 `Aim Assist: On 70% | Band Strong | Targets Training` 格式的 HUD 文本。
- `HUD.gd` 更新训练面板默认 Aim Assist 文案，保持 summary 缺省值和运行时格式一致。
- `TrainingRoomSmokeTest.gd` 扩展默认 Off 档、设置后 Strong 档、Aim Assist drill 内 summary 字段断言。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrainingRoomSmokeTest.log" "res://scenes/debug/TrainingRoomSmokeTest.tscn"
TrainingRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.
```

### 仍需人工复核
- 实机确认 `Band Strong` 等新增文字在 720p 训练面板中仍然可读，不挤压训练目标和按钮。
- 后续可以把档位反馈接入设置页预览，让玩家不进训练房也能看到当前 Aim Assist 档位。

## 2026-07-09 设置页 Aim Assist 档位预览第一版

### 目标
- 把 Aim Assist 强度档位从训练 HUD 扩展到设置入口，让玩家调整滑条时能直接看到当前档位。
- 为 PC 首发的辅助瞄准选项补齐更清楚的设置反馈，同时继续为未来移动端目标选择保留同一语义。

### 本次改动
- `HUD.gd` 新增 `settings_aim_assist_band_label`，在 Aim Assist 强度滑条旁显示 `Aim Assist Band: Off/Balanced/Strong`。
- `_update_aim_assist_value_label()` 现在会同时刷新百分比、开关状态、滑条可编辑状态和档位预览。
- `Main.get_settings_summary()` 新增 `aim_assist_strength_band` 字段，方便设置摘要、后续大厅设置页和烟测读取。
- `SettingsSmokeTest.gd` 扩展默认 Off、设置页即时 Balanced 预览、应用后 summary 字段、重载后 UI 回显断言。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\SettingsSmokeTest.log" "res://scenes/debug/SettingsSmokeTest.tscn"
SettingsSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.
```

### 仍需人工复核
- 实机确认设置面板新增档位行后，在 720p 下滚动和按钮位置仍然顺手。
- 后续可以把档位预览从纯文本推进为分段控件，让玩家直接选 Light/Balanced/Strong。

## 2026-07-09 设置页 Aim Assist 档位快捷选择第一版

### 目标
- 让玩家在设置页中可以直接选择 Aim Assist 常用强度档位，而不是只能拖动百分比滑条。
- 保持 PC 首发的弱辅助默认方向，同时为未来移动端或手柄目标选择预留清晰的档位语义。

### 本次改动
- `HUD.gd` 在 Aim Assist 设置区新增 `Off / Light / Balanced / Strong` 分段按钮行。
- 预设按钮会同步设置页开关、强度滑条、`Aim Assist Band` 预览和当前按钮高亮。
- 预设值为：`Off` 关闭辅助瞄准并保留 35% 基准，`Light` 为 35%，`Balanced` 为 60%，`Strong` 为 80%。
- `HUD.gd` 新增 `choose_settings_aim_assist_preset_for_test()` 和 `get_settings_aim_assist_active_preset_text()`，用于烟测验证实际控件状态。
- `SettingsSmokeTest.gd` 扩展默认 Off 高亮、选择 Strong 预设、切回 Balanced 保存、重载后 Balanced 回显断言。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\SettingsSmokeTest.log" "res://scenes/debug/SettingsSmokeTest.tscn"
SettingsSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.
```

### 仍需人工复核
- 实机确认设置页新增按钮行后，鼠标点击、键盘焦点和滚动手感仍然顺畅。
- 后续可以把同一档位控件复用到大厅设置页或训练房内的快捷校准面板。

## 2026-07-09 训练房 Aim Assist 快捷校准第一版

### 目标
- 让玩家在训练靶场内就能即时切换 Aim Assist 档位，不必离开训练流程进入设置页。
- 把 Aim Assist drill 推进成更接近实用校准工具的体验：看靶、切档、观察吸附变化可以在同一个面板内完成。

### 本次改动
- `HUD.gd` 的训练面板新增 `Off / Light / Balanced / Strong` 快捷按钮行。
- `Main.gd` 新增 `apply_aim_assist_preset()`，统一应用档位、更新 Player、保存 settings，并刷新训练 HUD。
- 训练房快捷档位复用设置页语义：`Off` 关闭辅助瞄准，`Light` 为 35%，`Balanced` 为 60%，`Strong` 为 80%。
- `TrainingRoomSmokeTest.gd` 扩展默认 Off 高亮、训练中选择 Light、HUD/summary 更新、再切到 Strong 后高亮同步断言。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrainingRoomSmokeTest.log" "res://scenes/debug/TrainingRoomSmokeTest.tscn"
TrainingRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\SettingsSmokeTest.log" "res://scenes/debug/SettingsSmokeTest.tscn"
SettingsSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.
```

### 仍需人工复核
- 实机确认训练面板新增按钮行后，训练靶不被遮挡，鼠标点击按钮和射击校准之间的切换顺手。
- 后续可以把按钮行视觉压缩为正式图标/分段控件，减少训练面板高度占用。

## 2026-07-09 手柄右摇杆瞄准输入入口第一版

### 目标
- 在保持 PC 鼠标瞄准为默认体验的前提下，补上手柄右摇杆瞄准输入入口。
- 让后续手柄按键、移动端虚拟摇杆和 Aim Assist 校准继续复用同一套玩家瞄准方向与吸附逻辑。

### 本次改动
- `Main.gd` 新增固定 `aim_left / aim_right / aim_up / aim_down` 输入动作，并绑定到手柄右摇杆 X/Y 轴。
- 右摇杆瞄准动作不进入键盘重绑定列表，也不写入 settings 的 `controls` 保存区，避免把“手柄输入入口”误做成半成品重绑定功能。
- `Player.gd` 将当前瞄准目标抽象为 `_get_raw_aim_target()`：右摇杆超过死区时生成远距瞄准点，否则继续使用鼠标位置。
- `Player.gd` 增加缺失 `aim_*` 动作保护，独立 Player 测试场景未经过 `Main.gd` 注册输入时会安全回退到鼠标路径。
- `HUD.gd` 将底部输入提示更新为 `Aim Mouse/RS`。
- `SettingsSmokeTest.gd` 增加右摇杆 InputMap 绑定、设置摘要隔离、输入提示和玩家读取右摇杆归一化向量的断言。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\SettingsSmokeTest_right_stick.log" "res://scenes/debug/SettingsSmokeTest.tscn"
SettingsSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\AimAssistSmokeTest_right_stick.log" "res://scenes/debug/AimAssistSmokeTest.tscn"
AimAssistSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrainingRoomSmokeTest_right_stick.log" "res://scenes/debug/TrainingRoomSmokeTest.tscn"
TrainingRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_right_stick.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.
```

首次运行 `AimAssistSmokeTest` 时发现独立 Player 场景没有注册 `aim_*` 动作会产生 InputMap 错误日志；已通过 `_has_controller_aim_actions()` 回退保护修复，并重跑通过。

### 仍需人工复核
- 实机用手柄确认右摇杆方向、死区和鼠标回退符合预期，尤其是释放右摇杆后是否需要保留最后瞄准方向。
- 后续可以继续补手柄射击/换武器/技能按钮映射，以及设置页里的完整 Controller 控制说明。

## 2026-07-09 手柄基础动作默认绑定第一版

### 目标
- 在右摇杆瞄准入口之后，补齐手柄最基本的移动、开火、换武器和常用动作默认绑定。
- 继续保持 PC 键鼠为首发路径，手柄默认绑定只作为 InputMap 入口，不扩展成完整 Controller 设置页。

### 本次改动
- `Main.gd` 在 `_ensure_input_actions()` 中为 `move_left / move_right / move_up / move_down` 增加左摇杆 X/Y 轴绑定。
- `shoot` 保留鼠标左键，同时新增右扳机 RT 轴绑定，并补右肩键 RB 作为开火 fallback。
- `reload / skill / interact / pause` 分别新增 X / A / Y / Start 默认按钮。
- `weapon_slot_1 / weapon_slot_2 / weapon_slot_3` 分别新增 D-pad 左/上/右默认按钮。
- `_bind_joy_button()` 作为 `_bind_key()`、`_bind_mouse_button()`、`_bind_joy_axis()` 的同级默认绑定工具，避免重复添加相同手柄按钮事件。
- `HUD.gd` 底部提示更新为 `Move W/A/S/D/LS` 和 `Shoot LMB/RT`。
- `SettingsSmokeTest.gd` 增加左摇杆、RT/RB、X/A/Y/Start、D-pad 武器槽和提示文本断言。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\SettingsSmokeTest_gamepad_defaults.log" "res://scenes/debug/SettingsSmokeTest.tscn"
SettingsSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_gamepad_defaults.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_gamepad_defaults.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实机用手柄确认 RT/RB 射击、X/A/Y/Start 和 D-pad 武器槽是否符合直觉；如果不顺手，下一步应先做 Controller 布局表而不是继续硬编码。
- 后续可以补“最近一次输入设备”检测，让 HUD 在键鼠和手柄提示之间动态切换，避免底部提示越来越长。

## 2026-07-09 动态输入提示切换第一版

### 目标
- 让第 212/213 批新增的手柄输入入口在 HUD 中更可读，避免底部提示同时塞入键鼠和手柄两套操作。
- 保持 PC 键鼠默认显示，不增加设置项，也不改变当前 InputMap 和 controls 保存结构。

### 本次改动
- `HUD.gd` 新增 `_input_hint_device`，默认值为 `keyboard_mouse`。
- `HUD._input()` 监听输入事件并调用 `_update_input_hint_device_from_event()`：手柄按钮按下或摇杆轴绝对值达到 `0.45` 时切到 `gamepad`，键盘按下、鼠标按下或鼠标移动距离达到 `2.0` 时切回 `keyboard_mouse`。
- `_update_input_hint()` 拆为两套提示：键鼠模式显示 `Move W/A/S/D | Aim Mouse | Shoot LMB`，手柄模式显示 `Move LS | Aim RS | Shoot RT/RB`。
- 新增 `get_input_hint_device_for_test()`、`set_input_hint_device_for_test()` 和 `simulate_input_hint_event_for_test()`，用于烟测验证动态切换路径。
- `SettingsSmokeTest.gd` 更新提示断言：验证默认键鼠提示、手柄提示文案、鼠标移动事件切回键鼠、手柄按钮事件切到手柄，以及键位重绑定后键鼠提示仍显示新按键。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\SettingsSmokeTest_dynamic_input_hint.log" "res://scenes/debug/SettingsSmokeTest.tscn"
SettingsSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_dynamic_input_hint.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_dynamic_input_hint.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实机确认轻微手柄摇杆漂移不会频繁把提示从键鼠切到手柄；如有漂移，应提高阈值或按动作白名单过滤。
- 后续可以补正式 Controller 布局表，让 HUD 提示从硬编码按钮名改为平台/手柄类型可配置文案。

## 2026-07-09 Controller 布局摘要第一版

### 目标
- 把上一批动态手柄提示背后的按钮文案集中成可维护的 Controller 布局表。
- 在不引入完整手柄重绑定的前提下，让设置页能读到当前手柄默认布局，减少玩家只靠底部 HUD 提示理解控制的成本。

### 本次改动
- `HUD.gd` 新增 `CONTROLLER_LAYOUT_ITEMS`，集中描述 `Move LS`、`Aim RS`、`Shoot RT/RB`、`Reload X`、`Skill A`、`Weapons D-Pad`、`Interact Y` 和 `Pause Start`。
- `_update_input_hint()` 的手柄分支改为调用 `_format_controller_layout_hint()`，不再直接硬编码整条手柄提示。
- 设置页新增只读 `Controller` 布局摘要行，文本同样来自 `_format_controller_layout_hint()`。
- 新增 `get_controller_layout_hint_for_test()` 和 `get_settings_controller_layout_text_for_test()`，用于验证 HUD 手柄提示和设置页展示同源。
- `SettingsSmokeTest.gd` 扩展 Controller 布局摘要、手柄 HUD 提示同源和设置页只读布局显示断言。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\SettingsSmokeTest_controller_layout.log" "res://scenes/debug/SettingsSmokeTest.tscn"
SettingsSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_controller_layout.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_controller_layout.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实机确认设置页新增 `Controller` 行在 720p 滚动区域中可读，不会挤压 Aim Assist、反馈强度和键位重绑定控件。
- 后续可以把布局表从 HUD 私有常量推进为 Controller 配置资源，用于平台差异、图标提示和完整手柄重绑定。

## 2026-07-09 ControllerLayout 共享接口第一版

### 目标
- 将 Controller 布局说明从 `HUD.gd` 私有实现提升为可复用输入接口。
- 让 `Main.get_settings_summary()` 也能暴露手柄默认布局，方便后续大厅设置页、Controller 设置页、测试和文档使用同一份数据。

### 本次改动
- 新增 `scripts/input/ControllerLayout.gd`，提供 `get_items()`、`format_hint()` 和 `get_summary()`。
- `ControllerLayout.get_summary()` 暴露 `scheme: default_gamepad`、`hint` 和 `items`。
- `HUD.gd` 删除私有布局常量，改为 preload `ControllerLayout.gd` 并通过 `CONTROLLER_LAYOUT.format_hint()` 生成手柄 HUD 提示和设置页 Controller 摘要。
- `Main.gd` 新增 `CONTROLLER_LAYOUT` preload 和 `get_controller_layout_summary()`，并在 `get_settings_summary()` 中写入 `controller_layout` 字段。
- `SettingsSmokeTest.gd` 增加 settings summary 中 `controller_layout.scheme`、`controller_layout.hint` 和 `controller_layout.items` 的断言。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\SettingsSmokeTest_controller_layout_shared.log" "res://scenes/debug/SettingsSmokeTest.tscn"
SettingsSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_controller_layout_shared.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_controller_layout_shared.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 后续如果需要平台差异或图标提示，应把 `ControllerLayout.gd` 继续推进为 Resource 数据，而不是重新在 HUD 或 Main 中硬编码。
- 实机确认设置页、HUD 和实际手柄输入的说明一致，尤其是 RT/RB 射击 fallback 是否符合玩家预期。

## 2026-07-09 Controller 布局资源化第一版

### 目标
- 将默认 Controller 布局从共享脚本常量继续推进为可编辑 Resource 数据。
- 为后续平台差异、图标化提示和完整手柄重绑定保留数据入口，而不是继续把布局内容写在 HUD 或 Main 代码里。

### 本次改动
- 新增 `scripts/input/ControllerLayoutData.gd`，作为 `Resource` 类型保存手柄布局。
- `ControllerLayoutData` 使用 `scheme`、`item_ids`、`item_labels` 和 `item_controls` 描述布局，并提供 `get_items()`、`format_hint()`、`get_summary()`。
- 新增 `resources/input/default_controller_layout.tres`，写入当前默认布局：`Move LS`、`Aim RS`、`Shoot RT/RB`、`Reload X`、`Skill A`、`Weapons D-Pad`、`Interact Y`、`Pause Start`。
- `ControllerLayout.gd` 改为 preload `default_controller_layout.tres`，并保留 `get_items()`、`format_hint()`、`get_summary()` 静态接口。
- 首次运行时发现 `ControllerLayout.gd` 对新 Resource class 的 typed preload 会在编译期找不到类型；已去掉该类型注解，保留资源加载和接口行为。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\SettingsSmokeTest_controller_layout_resource.log" "res://scenes/debug/SettingsSmokeTest.tscn"
SettingsSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_controller_layout_resource.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_controller_layout_resource.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实机确认 `.tres` 中的默认按钮命名和实际主流 Xbox/通用手柄标注一致；如要支持 PlayStation 或 Switch，应增加独立布局资源而不是复写当前默认布局。
- 后续可以让 ControllerLayout 根据平台或玩家选择加载不同 `.tres`，并将 `item_ids` 与实际 InputMap 绑定校验起来。

## 2026-07-09 Controller 布局动作契约第一版

### 目标
- 将 Controller 布局资源中的显示项和实际 `InputMap` action 建立机器可读关系。
- 让设置摘要、HUD 提示和后续 Controller 设置页不只共享文案，也能验证文案背后确实存在手柄输入绑定。

### 本次改动
- `ControllerLayoutData.gd` 新增 `item_actions`，与 `item_ids / item_labels / item_controls` 按索引对齐。
- `ControllerLayoutData.get_items()` 会把每个 item 的 `actions` 暴露为 `PackedStringArray`。
- `default_controller_layout.tres` 为八个布局项写入动作契约：
  - `Move` -> `move_left,move_right,move_up,move_down`
  - `Aim` -> `aim_left,aim_right,aim_up,aim_down`
  - `Shoot` -> `shoot`
  - `Weapons` -> `weapon_slot_1,weapon_slot_2,weapon_slot_3`
- `SettingsSmokeTest.gd` 新增 `_controller_layout_actions_are_bound()` 和 `_action_has_joy_input()`，遍历 summary 中的 Controller items，确认每个声明 action 都存在且拥有手柄轴或按钮事件。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\SettingsSmokeTest_controller_action_contract.log" "res://scenes/debug/SettingsSmokeTest.tscn"
SettingsSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_controller_action_contract.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_controller_action_contract.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 后续新增不同平台布局资源时，必须同步填写 `item_actions`，否则烟测应阻止“提示存在但动作不可用”的退化。
- 如果未来允许玩家重绑定手柄按钮，`item_actions` 应继续指向语义动作，而具体按钮显示再由绑定配置层解析。

## 2026-07-09 Controller 调参资源化第一版

### 目标
- 将右摇杆瞄准死区、虚拟瞄准距离和输入提示切换阈值从 Player/HUD 常量迁移到 Controller 布局资源。
- 让手柄手感参数、设置摘要和测试校验继续同源，为后续平台差异和完整 Controller 设置页保留数据入口。

### 本次改动
- `ControllerLayoutData.gd` 新增 `aim_deadzone`、`aim_target_distance`、`input_switch_threshold` 和 `mouse_return_threshold`，并通过 `get_tuning_summary()` 写入 summary。
- `default_controller_layout.tres` 写入当前默认调参：`0.22` 瞄准死区、`900.0` 瞄准距离、`0.45` 手柄输入切换阈值、`2.0` 鼠标切回阈值。
- `ControllerLayout.gd` 新增 tuning 访问器。
- `HUD.gd` 的输入提示切换逻辑改为读取 ControllerLayout 阈值。
- `Player.gd` 的右摇杆瞄准死区和目标距离改为读取 ControllerLayout，并暴露测试 getter。
- `SettingsSmokeTest.gd` 使用 summary tuning 构造低于/高于阈值的模拟输入事件，并验证 Player 使用同一份 aim tuning。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\SettingsSmokeTest_controller_tuning.log" "res://scenes/debug/SettingsSmokeTest.tscn"
SettingsSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_controller_tuning.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_controller_tuning.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实机确认 `0.22` 右摇杆死区和 `0.45` 输入切换阈值能过滤常见轻微漂移，同时不会让正常手柄输入感觉迟钝。
- 后续如果做完整 Controller 设置页，应把这些 tuning 字段接到设置 UI，而不是再新增并行常量。

## 2026-07-09 Controller 调参设置页第一版

### 目标
- 将 Controller 布局资源中的关键手感参数开放到设置页，而不是只停留在资源默认值和测试断言中。
- 保持 `.tres` 默认布局、运行时玩家覆盖、配置文件持久化和 Player/HUD 实际读取同源。

### 本次改动
- `ControllerLayout.gd` 新增 tuning override、默认值 getter、clamp helper 和 `configure_tuning()`，`get_summary()` 会返回当前生效 tuning，同时保留默认 tuning 摘要。
- `Main.gd` 新增 `_settings_controller_aim_deadzone` 和 `_settings_controller_input_switch_threshold`，并接入 `apply_settings()`、`get_settings_summary()`、`_load_settings()`、`_save_settings()`、`_save_history()` 和 `_apply_controller_tuning_settings()`。
- `HUD.gd` 在设置页 Controller 区域新增 `Right Stick Deadzone` 和 `Gamepad Hint Switch` 滑条，并把两个值传回 `apply_settings()`。
- `SettingsSmokeTest.gd` 新增 Controller tuning 默认值、UI 标签、设置预览、Apply 后 summary、`settings.cfg`、重载后 UI 和 Player getter 断言。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\SettingsSmokeTest_controller_tuning_settings.log" "res://scenes/debug/SettingsSmokeTest.tscn"
SettingsSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_controller_tuning_settings.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_controller_tuning_settings.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 用实体手柄确认 `Right Stick Deadzone` 0-60% 范围足够覆盖常见漂移，同时不会误导玩家把死区调到过高导致瞄准迟钝。
- 后续如支持 PlayStation/Switch 布局，继续让资源提供默认 tuning，玩家设置只作为 runtime override。

## 2026-07-09 Lobby Objective Board 第一版

### 目标
- 让 Outpost Hall 不只是图鉴和记录页，也能在首屏提示玩家下一局外目标。
- 使用现有局外数据生成短目标，强化角色解锁、熟练度和训练徽章这三条长期循环。

### 本次改动
- `LobbyScreen.gd` 新增 `ObjectiveBoardLabel` 的运行时创建逻辑，插入在 quick stats 下方。
- `LobbyScreen.gd` 新增 `_format_objective_board()`，从 hall summary 推导下一角色解锁目标、当前角色熟练度目标和下一训练徽章目标。
- `HUD.gd` 新增 `get_lobby_objective_board_text()`，供烟测读取大厅目标板。
- `LobbyScreenSmokeTest.gd` 新增目标板断言，覆盖新档默认的解锁、熟练度和训练目标。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_board.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_board.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_board.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_board.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实机查看目标板在 1280x720 下是否仍然不挤压 Action Row 和 Tab Row。
- 后续可以让目标板支持更多目标类型，例如 Boss 首通、Build 路线尝试、未见过的武器/遗物或上次死亡来源反制建议。

## 2026-07-09 Lobby Objective Board 反制建议第一版

### 目标
- 让 Outpost Hall 目标板在玩家失败后给出下一局可执行的反制方向。
- 复用 Records 页已有死亡来源 counter tag 规则，避免目标板和记录详情生成两套不一致的建议。

### 本次改动
- `LobbyScreen.gd` 的 `_format_objective_board()` 会在存在 `last_defeat.has_record` 时优先追加 `_format_last_defeat_counter_goal()`。
- 新增 `_format_last_defeat_counter_goal()`，输出 `Counter <source>: <tags>`，并将 Counter Build 标签压缩为短横向提示。
- `LobbyScreenSmokeTest.gd` 使用合成 `last_defeat` summary 验证陷阱死亡会显示 `Counter Spike Trap: Speed / Survival / Armor`。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_counter.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_counter.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_counter.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_counter.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实际失败一次后确认目标板文案足够短，且死亡来源名称比 source id 更适合玩家阅读。
- 后续可以让目标板的 Counter 目标直接联动到 Records 的 Sources 视图或对应 Build 路线筛选页。

## 2026-07-09 Lobby Objective Counter 路由第一版

### 目标
- 让目标板的失败反制提示不只是静态文字，而是能直接带玩家进入 Records 来源详情。
- 复用现有 Records/Sources 过滤和死亡来源详情卡，避免大厅首屏、记录页和 Counter 详情之间出现重复逻辑。

### 本次改动
- `LobbyScreen.gd` 将 Objective Board 从单个 Label 升级为运行时创建的 `ObjectiveBoardRow`，包含目标文本和 `Review` 按钮。
- 新增 `open_objective_counter()`，当存在 `last_defeat.has_record` 时切到 Records 页、选择 Sources death view，并按 `source_type` 设置来源类型过滤。
- `Review` 按钮只在有上次死亡记录时显示；新档没有失败记录时保持隐藏。
- `LobbyScreenSmokeTest.gd` 新增合成死亡来源、按钮显示、按钮文案、路由到 Sources/Hazard 和 Death Source Detail 展示断言。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_counter_route.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_counter_route.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_counter_route.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_counter_route.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实机确认新增 `Review` 按钮不会在 1280x720 下挤压目标板文本。
- 后续可以把 Review 入口进一步拆成 `Review Source` 和 `Build Route`，分别跳到 Records 来源详情与对应武器/遗物 Build 路线。

## 2026-07-09 Lobby Objective Build Route 第一版
### 目标
- 把 Objective Board 的失败反制入口拆成“查看来源”和“直接构建路线”两条操作路径。
- 让玩家在大厅看到上次失败来源后，可以一键跳到可执行的 Codex build route 过滤页，而不是先进入 Records 再手动找路线。

### 本次改动
- `LobbyScreen.gd` 新增 `ObjectiveBuildRouteButton`，与现有 `Review` 按钮共用 Objective Board 行，仅在 `last_defeat` 能解析出 Counter Route 时显示。
- 新增 `open_objective_build_route()`，直接使用 `_current_summary.last_defeat` 调用 `_resolve_counter_route_target()`，并复用现有 Codex filter/search/sort/rarity 状态写入流程。
- `Build` 按钮 tooltip 会展示解析出的目标路线，例如 `Open Relics -> Speed`。
- `LobbyScreenSmokeTest.gd` 新增 Build 按钮无记录隐藏、有记录显示、tooltip、路由到 `relics`、选择 `Speed` filter，并命中 `Adrenaline Charm` 的断言。
- 测试段末尾复位当前 Codex refinement，避免新路由状态污染后续 Relics 默认页断言。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_build_route.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_build_route.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_build_route.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_build_route.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实机确认 Objective Board 同时显示目标文本、`Review` 和 `Build` 时，在 1280x720 下仍然不挤压按钮或截断关键信息。
- 后续可把 `Build` 再推进到“推荐具体武器/遗物/天赋组合”，但应继续复用现有 Counter Pick 规则，避免新增平行推荐系统。

## 2026-07-09 Lobby Objective Counter Pick 第一版
### 目标
- 把 Objective Board 的失败反制入口继续从路线级引导推进到具体推荐条目。
- 让玩家在大厅看到上次失败来源后，可以一键打开当前最优先的反制物品详情，形成“死亡复盘 -> 反制推荐 -> 重开尝试”的短闭环。

### 本次改动
- `LobbyScreen.gd` 新增 `ObjectiveCounterPickButton`，与 `Review`、`Build` 共用 Objective Board 行，仅在 `_get_focused_counter_pick_target(last_defeat)` 能返回具体推荐时显示。
- 新增 `open_objective_counter_pick()`，直接使用 `_current_summary.last_defeat` 打开当前聚焦的 Counter Pick 推荐。
- `open_counter_pick()` 和 `open_objective_counter_pick()` 现在共用 `_open_counter_pick_target()`，统一写入目标页、route filter、搜索框、排序和稀有度状态。
- `Pick` 按钮保持短文案，tooltip 展示具体推荐和路线，例如 `Adrenaline Charm in Relics -> Speed`。
- `LobbyScreenSmokeTest.gd` 新增无死亡记录隐藏、有推荐时显示、tooltip、点击后 `relics` 页面、`Speed` filter、`Adrenaline Charm` 搜索框和详情卡聚焦断言。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_counter_pick.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_counter_pick.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_counter_pick.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_counter_pick.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实机确认 Objective Board 同时显示目标文本、`Review`、`Build`、`Pick` 时，在 1280x720 下仍然不挤压按钮或目标文本。
- 后续可以把 `Pick` 升级为可循环的目标板推荐入口，但应先控制按钮数量，避免大厅首屏变成 Records 详情卡的复制品。

## 2026-07-09 Lobby Objective Pick 文案第一版
### 目标
- 让大厅 Objective Board 不只在 hover tooltip 中暴露具体反制推荐，而是在首屏目标文本里直接告诉玩家下一局可尝试什么。
- 保持推荐规则单一来源，继续复用 Records/Counter Pick 已有推荐焦点，不新增平行推荐表。

### 本次改动
- `LobbyScreen.gd` 的 `_format_last_defeat_counter_goal()` 现在会调用 `_get_focused_counter_pick_target(last_defeat)`。
- 当存在具体推荐条目时，目标文案从 `Counter Spike Trap: Speed / Survival / Armor` 扩展为 `Counter Spike Trap: Speed / Survival / Armor; Try Adrenaline Charm`。
- 如果没有具体推荐，仍回退到原有 Counter 标签文案，不影响只有路线标签的死亡来源。
- `LobbyScreenSmokeTest.gd` 新增 `Try Adrenaline Charm` 断言，确认具体推荐已经进入目标板可见文本。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_pick_text.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_pick_text.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_pick_text.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_pick_text.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实机查看带有 `Try ...` 的 Objective Board 在 1280x720 下是否仍能保持可读；如果按钮和文案挤压，应优先缩短按钮文案或把目标板拆成两行。
- 后续如果加入目标板推荐循环，需要保证可见文案和 `Pick` 按钮目标始终同步。

## 2026-07-09 Lobby Objective Pick 路线文案第一版
### 目标
- 让 Objective Board 的具体反制推荐不只显示物品名，也能说明该推荐属于哪个图鉴类型和 Build 路线。
- 保持推荐文案短小，避免把大厅目标板扩展成 Records 详情卡。

### 本次改动
- `LobbyScreen.gd` 新增 `_format_counter_pick_objective_hint()`，专门格式化目标板中的具体推荐短文案。
- 推荐文案从 `Try Adrenaline Charm` 调整为 `Try Adrenaline Charm [Relics/Speed]`。
- 该 helper 读取 Counter Pick target 的 `display_name`、`page` 和 `tag`，不重新推导推荐路线。
- `LobbyScreenSmokeTest.gd` 将 Objective Board 断言收紧为 `Try Adrenaline Charm [Relics/Speed]`。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_pick_route_text.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_pick_route_text.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_pick_route_text.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_pick_route_text.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实机确认 `[Relics/Speed]` 这种路线短标记在目标板中足够清晰；如果路线名后续变长，应考虑使用更短的类型 token 或 tooltip 补充。
- 后续如果支持目标板内切换推荐，必须同步刷新 `Try ... [page/tag]` 和 `Pick` 按钮目标。

## 2026-07-09 Lobby Objective Pick 循环第一版
### 目标
- 让 Objective Board 的具体反制推荐不再固定在第一条 Counter Pick，而是能在大厅首屏切换同一死亡来源的多条推荐。
- 保持目标板、`Pick` 按钮 tooltip 和实际打开目标同步，避免玩家看到的推荐和点击后的结果不一致。

### 本次改动
- `LobbyScreen.gd` 新增 `ObjectiveCounterPickCycleButton`，默认文案 `Next`，仅当当前死亡来源存在多条聚焦推荐时显示为 `Next x/N`。
- 新增 `cycle_objective_counter_pick()`，直接使用 `_current_summary.last_defeat` 更新 `_counter_pick_focus_indexes`，然后刷新 Objective Board 文案、Objective 按钮状态和当前归档页。
- 新增 `_get_focused_counter_pick_targets()`，让 Objective 循环和原有 `_get_focused_counter_pick_target()` 共享同一推荐池。
- `LobbyScreenSmokeTest.gd` 新增 `Next 1/N` 可见性、点击后目标板离开 `Try Adrenaline Charm [Relics/Speed]`、仍保留 `Try` 推荐和 `Next 2/N` 断言。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_pick_cycle.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_pick_cycle.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_pick_cycle.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_pick_cycle.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实机确认 Objective Board 同时显示目标文本、`Review`、`Build`、`Pick`、`Next` 时仍能在 1280x720 保持清晰；如果拥挤，应优先把目标板拆为两行。
- 后续如果支持跨类型循环，应同步显示类型变化，避免 `Next` 在玩家心智中只像同类物品循环。

## 2026-07-09 Lobby Objective 跨类型推荐池第一版
### 目标
- 让 Objective Board 的 `Next` 不只在当前类型页内切换，而是能把同一死亡来源的不同反制类型都轮出来。
- 保持 Records 来源详情卡的类型页焦点不变，Objective Board 自己维护大厅级推荐焦点。

### 本次改动
- `LobbyScreen.gd` 新增 `_objective_counter_pick_focus_indexes`，避免 Objective 推荐焦点复用 Records 详情卡的 `_counter_pick_focus_indexes`。
- 新增 `_get_objective_counter_pick_targets()`，跨 `Relics`、`Weapons`、`Talents`、`Blessings`、`Statues` 收集推荐，并按类型轮询顺序组织候选。
- 新增 `_get_objective_counter_pick_target()` 和 `_get_objective_counter_pick_focus_index()`，供目标板文案、`Pick` 按钮和 `Next` 按钮共用。
- `open_objective_counter_pick()`、`cycle_objective_counter_pick()`、Objective tooltip 和 `_format_last_defeat_counter_goal()` 都改为读取 Objective 专用推荐目标。
- `LobbyScreenSmokeTest.gd` 新增循环若干次后必须出现非 `Relics` 推荐类型的断言，防止 `Next` 退回只在遗物池内循环。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_cross_type_pick.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_cross_type_pick.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_cross_type_pick.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_cross_type_pick.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实机观察跨类型循环时 `[Weapons/...]`、`[Talents/...]`、`[Statues/...]` 等短标记是否足够清楚。
- 如果目标板按钮继续增多，应考虑把 Objective Board 拆成文本行和动作行，避免首屏拥挤。

## 2026-07-09 Lobby Objective Next 推荐预览第一版
### 目标
- 让 Objective Board 的 `Next` 不再是盲切按钮，玩家可以在 hover 时看到下一条推荐会切到什么。
- 保持按钮文案短，避免继续拉宽目标板动作区。

### 本次改动
- `LobbyScreen.gd` 新增 `get_objective_counter_pick_cycle_button_tooltip_text()` 测试入口。
- `ObjectiveCounterPickCycleButton` 在可循环时会取 `(当前索引 + 1) % 推荐数` 的目标，并用 `_format_counter_pick_objective_hint()` 生成 `Next pick: Try <item> [<page>/<tag>]`。
- 如果下一条推荐无法格式化，tooltip 回退到泛化的循环说明。
- `LobbyScreenSmokeTest.gd` 新增初始 tooltip 包含 `Next pick:`、路线标记 `[`，以及循环后 tooltip 会更新的断言。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_next_preview.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_next_preview.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_next_preview.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_next_preview.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实机确认 `Next` tooltip 在目标板按钮密集时仍容易触发和阅读。
- 如果未来改为手柄优先，需要把下一条推荐预览移到可聚焦状态说明，而不是只依赖鼠标 hover。

## 2026-07-09 Lobby Objective Next 类型标记第一版
### 目标
- 让 Objective Board 的 `Next` 按钮在非 hover 状态下也能透露下一条推荐的大类。
- 继续保持按钮短小，不把完整推荐名塞进按钮正文。

### 本次改动
- `ObjectiveCounterPickCycleButton` 文案从 `Next x/N` 调整为 `Next x/N <type token>`。
- 类型 token 直接复用 `_format_counter_pick_type_token()`，当前映射为 `W/R/T/B/S`。
- tooltip 仍保留完整下一条推荐预览，按钮正文只显示位置和类型。
- `LobbyScreenSmokeTest.gd` 新增 `_has_counter_type_token()` helper，并断言初始和循环后的 Objective `Next` 文本都带类型 token。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_next_type_token.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_next_type_token.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_next_type_token.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_next_type_token.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实机确认 `Next 1/N W` 这类短文案在目标板动作行里不会显得晦涩；如果需要，可用正式图标替代字母 token。
- 如果目标板后续支持手柄焦点说明，应把完整 `Next pick` 文案接入 focus 状态，而不只依赖 tooltip。

## 2026-07-09 Lobby Objective Pick 类型标记第一版
### 目标
- 让 Objective Board 的 `Pick` 按钮在非 hover 状态下也能显示当前推荐的大类。
- 与 `Next` 的下一条推荐类型标记保持同一套缩写规则，避免当前推荐和下一条推荐的提示语义分裂。

### 本次改动
- `ObjectiveCounterPickButton` 有目标时文案从 `Pick` 调整为 `Pick <type token>`，无目标时继续回退为 `Pick`。
- 当前推荐类型 token 复用 `_format_counter_pick_type_token()`，映射为 `W/R/T/B/S`。
- tooltip 继续显示完整推荐名和路线，按钮正文只显示轻量当前类型提示。
- `LobbyScreenSmokeTest.gd` 新增初始 `Pick R` 断言，并确认点击 `Next` 后 `Pick` 按钮也会保留并更新类型 token。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_pick_type_token.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_pick_type_token.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_pick_type_token.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_pick_type_token.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实机确认 `Pick R`、`Pick W` 这类短文案和 `Next x/N <type token>` 同屏出现时足够清楚。
- 如果后续引入正式分类图标，应优先替换 `Pick` 和 `Next` 的字母 token，而不是继续扩展按钮文字。

## 2026-07-09 Lobby Objective 类型提示标签第一版
### 目标
- 让 Objective Board 的 `Pick R` 和 `Next x/N W` 这类短 token 有可见解释，不只依赖玩家记住字母含义。
- 保持 `Pick` 与 `Next` 按钮短小，同时给当前推荐和下一条推荐提供完整类型名。

### 本次改动
- `LobbyScreen.gd` 新增 `ObjectiveCounterPickTypeLabel`，显示 `Now <type> | Next <type>`。
- 类型标签仅在存在具体 Objective Counter Pick 时显示，无失败记录或无推荐时隐藏。
- 类型标签文本复用 `_format_counter_pick_type_label()`，tooltip 复用 `_format_counter_pick_type_token()`，统一解释 `R/W/T/B/S`。
- `LobbyScreenSmokeTest.gd` 新增无失败记录隐藏、初始 `Now Relics`、下一条类型说明、tooltip token legend 和循环后标签更新断言。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_type_hint.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_type_hint.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_type_hint.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_type_hint.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实机确认 `Now Relics | Next Weapons` 在 1280x720 下不会挤压目标板主文案。
- 后续正式图标落地后，可把该标签压缩为图标加 tooltip，保留当前测试 getter 作为可读性回归入口。

## 2026-07-09 Lobby Objective 动作行拆分第一版
### 目标
- 降低 Objective Board 在显示 `Review/Build/Pick/Next/Now...` 时对主目标文案的横向挤压。
- 保持大厅主目标和失败后反制动作都可读，为后续正式图标和更完整局外引导留空间。

### 本次改动
- `LobbyScreen.gd` 新增 `ObjectiveBoardActionRow`，将反制按钮和类型提示从 `ObjectiveBoardRow` 拆到独立动作行。
- `ObjectiveBoardRow` 只保留 `ObjectiveBoardLabel`，让目标文本拥有完整横向空间。
- 动作行仅在存在 `last_defeat.has_record` 时显示，无失败记录时隐藏。
- 新增 `_get_existing_objective_action_button()` 和 `_get_existing_objective_action_label()`，自动迁移旧父节点下的运行时控件。
- `LobbyScreenSmokeTest.gd` 新增 split layout、无失败记录动作行隐藏、失败记录动作行显示断言。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_action_row.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_action_row.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_action_row.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_action_row.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实机确认两行 Objective Board 在大厅首屏的视觉层级是否足够清楚，尤其是目标文本和动作行的间距。
- 如果后续加入正式分类图标，应优先放入动作行，避免重新挤压主目标文案。

## 2026-07-09 Lobby Objective 进度条第一版
### 目标
- 把 Objective Board 从纯文本目标推进到可视化进度反馈，让局外大厅更接近可重复游玩的主入口。
- 复用现有角色解锁、熟练度和训练徽章数据，不新增平行进度规则。

### 本次改动
- `LobbyScreen.gd` 新增 `ObjectiveProgressRow`，包含 `ObjectiveProgressLabel` 和 `ObjectiveProgressBar`。
- 进度优先级为下一名角色解锁、当前角色熟练度、训练徽章总进度。
- 进度条 tooltip 显示具体数值，例如 `Rift Runner unlock progress: 0/10 Data Shards`。
- `HUD.gd` 新增 `get_lobby_objective_progress_text/value/tooltip_text()` 测试代理。
- `LobbyScreenSmokeTest.gd` 新增初始进度条可见、`Unlock Rift Runner` 优先级、0% 进度和 `0/10 Data Shards` tooltip 断言。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_progress_bar.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_progress_bar.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_progress_bar.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_progress_bar.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实机确认 Objective 进度条在 1280x720 大厅面板里不会压缩下方图鉴内容。
- 后续正式视觉层级落地时，应替换 ProgressBar 默认样式，并保留当前文本/tooltip 契约。

## 2026-07-09 Lobby Objective 进度数值常驻第一版
### 目标
- 让 Objective Progress 的具体数值不只存在于 tooltip，玩家在大厅首屏就能直接读到还差多少。
- 保持上一批进度条派生规则不变，只增强可读性。

### 本次改动
- `LobbyScreen.gd` 新增 `ObjectiveProgressValueLabel`，放在 `ObjectiveProgressBar` 右侧。
- 角色解锁进度显示为 `当前/成本 Data Shards`，熟练度显示为 `当前/需求 XP`，训练徽章显示为 `当前/总数 badges`。
- 数值标签使用固定宽度，降低进度变化时的布局抖动。
- `HUD.gd` 新增 `get_lobby_objective_progress_value_text()` 测试代理。
- `LobbyScreenSmokeTest.gd` 新增初始 `0/10 Data Shards` 常驻文本断言。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_progress_value.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_progress_value.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_progress_value.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_progress_value.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实机确认 `0/10 Data Shards` 这类数值标签和进度条间距足够清楚。
- 后续若进度文本本地化或变长，应优先压缩数值标签宽度策略，而不是隐藏具体数值。

## 2026-07-09 Lobby Objective 进度入口第一版
### 目标
- 让 Objective Progress 不只是显示目标状态，也能直接带玩家去处理目标。
- 复用现有 Characters 页和训练入口，避免新增平行导航逻辑。

### 本次改动
- `LobbyScreen.gd` 新增 `ObjectiveProgressActionButton`，显示在 Objective Progress 行右侧。
- Objective progress summary 新增 `action`、`target_page`、`action_text` 和 `action_tooltip`。
- 角色解锁和熟练度目标显示 `Roster`，点击后打开 Characters 页。
- 训练徽章目标显示 `Train`，点击后触发既有 `training_requested` 信号。
- `LobbyScreenSmokeTest.gd` 新增 Roster 按钮、tooltip、点击后进入 Characters 页并看到 Rift Runner 的断言。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_progress_action.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_progress_action.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_progress_action.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_progress_action.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实机确认 `Roster` 按钮在进度行中是否足够明确；如需更强引导，可改为图标加 tooltip。
- 后续可补训练目标场景下的 `Train` 分支回归，当前自动测试覆盖了解锁目标的 Characters 页路由。

## 2026-07-09 Lobby Objective Train 入口回归第一版
### 目标
- 补齐 Objective Progress `Train` 分支的自动化证据，避免只有 `Roster` 路由被验证。
- 确认当角色解锁和当前熟练度目标都完成后，Objective Progress 能 fallback 到训练徽章目标并进入训练房。

### 本次改动
- `LobbyScreenSmokeTest.gd` 合成一个所有角色已解锁、当前角色熟练度已满、训练徽章未满的大厅 summary。
- 测试断言 Objective Progress 文本变为 `Training Badges`，数值为 `0/4 badges`。
- 测试断言 Objective Progress action 文案为 `Train`，点击后进入 `Training` run state，并隐藏大厅。
- 本批不改运行时代码，只补第二百三十七批训练路由的回归覆盖。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_progress_train_action.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_progress_train_action.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_progress_train_action.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_progress_train_action.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 后续实机确认 `Train` action 是否需要更明确的图标或焦点说明。
- 如果训练徽章目标后续细分到具体 drill，应让 action 直接打开对应 drill，而不是只进入训练房。

## 2026-07-09 Lobby Objective 定向训练入口第一版

### 目标
- 让 Objective Progress 的训练徽章目标不只进入训练房，而是能直接定位到下一项未取得徽章的训练 drill。
- 保持普通 Training Room 入口默认从 Basics 开始，避免破坏已有训练房流程和教学入口。

### 本次改动
- `LobbyScreen.gd` 的 `_get_training_badge_progress()` 现在会读取 `training_drills`，解析第一项 `badge_unlocked == false` 的 drill。
- Objective Progress training summary 新增 `target_drill_id` 和 `target_drill_name`，并把 action tooltip 扩展为下一项缺失训练目标，例如 Movement badge。
- `training_requested` 信号改为携带可选 drill id；普通训练按钮继续发送空字符串。
- `HUD.gd` 的大厅训练回调改为调用 `start_training_room(target_drill_id)`。
- `Main.gd` 的 `start_training_room()` 新增可选 `target_drill_id` 参数，并通过 `_get_training_drill_index_by_id()` 定位 drill；空 id 或无效 id 回退到 Basics。
- `LobbyScreenSmokeTest.gd` 合成 Basics 已拿徽章、Movement 未拿徽章的大厅 summary，断言 Objective `Train` tooltip 预览 Movement，并在点击后直接进入 Movement drill。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_target_training.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrainingRoomSmokeTest_target_training.log" "res://scenes/debug/TrainingRoomSmokeTest.tscn"
TrainingRoomSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_target_training.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_target_training.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_target_training.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.
```

### 仍需人工复核
- 实机确认 Objective `Train` tooltip 中的 drill 名称是否足够明显；如果按钮文案需要更强指向，可后续改为短文案加图标或焦点态说明。
- 后续如果训练 drill 增加分类或难度，应让目标选择从“第一项未完成”升级为“最适合当前玩家状态的一项”。

## 2026-07-09 Lobby Objective 训练目标常驻标签第一版

### 目标
- 让训练徽章 Objective Progress 在非 hover 状态下直接显示下一项缺失训练 drill。
- 保留上一批定向训练入口，不新增新的 drill 选择规则。

### 本次改动
- `LobbyScreen.gd` 的 `_get_training_badge_progress()` 在解析到未完成 drill 时，把进度标签从 `Training Badges` 改为 `Training: <Drill>`。
- 数值文本继续显示 `当前/总数 badges`，tooltip 继续包含完整 drill 目标和 goal 文案。
- `LobbyScreenSmokeTest.gd` 将训练目标断言收紧为 `Training: Movement`，并继续验证 `Train` 入口进入 Movement drill。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_training_label.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_training_label.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_training_label.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_training_label.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrainingRoomSmokeTest_training_label.log" "res://scenes/debug/TrainingRoomSmokeTest.tscn"
TrainingRoomSmokeTest passed.
```

### 仍需人工复核
- 实机确认 `Training: Movement` 和未来 `Training: Aim Assist` 在 1280x720 大厅进度行中是否足够清晰。
- 后续若 drill 名称变长，应优先缩短显示名或增加固定宽度截断策略，避免挤压进度条和动作按钮。

## 2026-07-09 Lobby Objective 训练完成态隐藏第一版

### 目标
- 避免所有训练徽章都完成后，Objective Progress 仍显示 100% 的训练目标和 `Train` action。
- 让大厅 Objective Progress 只呈现仍可推进的局外目标。

### 本次改动
- `LobbyScreen.gd` 的 `_get_training_badge_progress()` 在 `training_drills` 存在、没有未完成 drill、且徽章计数达到总数时返回空 Dictionary。
- 如果旧 summary 缺少 drill 明细但徽章仍未满，仍保留通用 `Training Badges` 进度入口，避免旧数据或不完整 summary 丢失训练引导。
- `LobbyScreenSmokeTest.gd` 新增完成态合成 summary：所有角色已解锁、熟练度目标已完成、全部训练 drill 已拿徽章时，断言 Objective Progress 行和 action 按钮都隐藏。
- 同一测试随后恢复 Basics 已完成、Movement 未完成的 summary，继续验证 `Training: Movement`、`1/4 badges` 和定向进入 Movement drill。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_training_complete_progress.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_training_complete_progress.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_training_complete_progress.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_training_complete_progress.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrainingRoomSmokeTest_training_complete_progress.log" "res://scenes/debug/TrainingRoomSmokeTest.tscn"
TrainingRoomSmokeTest passed.
```

### 仍需人工复核
- 当所有局外目标都完成时，大厅是否需要显示新的长期目标，例如 Build 路线、挑战房或更高阶训练目标；当前先保持 Objective Progress 隐藏，避免误导。
- 后续如果加入训练难度或星级，可把完成态从“隐藏”升级为“显示下一层训练目标”。

## 2026-07-09 Lobby Objective 完成态开局指引第一版

### 目标
- 让 Objective Board 在局外元目标全部完成时，不再把完成项当作仍需推进的目标。
- 将完成态导回下一局复玩指引，贴近大厅作为 run 入口的职责。

### 本次改动
- `LobbyScreen.gd` 的 `_format_next_unlock_goal()` 在角色池已全解锁时返回空目标，不再显示 `Roster complete`。
- `_format_current_mastery_goal()` 在当前角色没有下一熟练度目标时返回空目标，不再显示 `Master ... maxed`。
- `_format_next_training_goal()` 在训练徽章已全完成时返回空目标，不再显示 `Training badges complete`。
- `LobbyScreenSmokeTest.gd` 的完成态 summary 新增 Objective Board 断言：目标板应显示 `Objectives: Start a run and test a new build`，且不包含 `complete` 或 `maxed`。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_complete_board.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_complete_board.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_complete_board.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_complete_board.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrainingRoomSmokeTest_objective_complete_board.log" "res://scenes/debug/TrainingRoomSmokeTest.tscn"
TrainingRoomSmokeTest passed.
```

### 仍需人工复核
- 实机确认完成态目标板的 `Start a run and test a new build` 是否足够明确；后续可考虑配合 Start Run 按钮焦点或推荐 build 标签。
- 如果后续加入周常、挑战或更高阶角色目标，应优先作为新的 active objective，而不是恢复显示完成项。

## 2026-07-09 Lobby Objective 完成态 Start 动作第一版

### 目标
- 让完成态 Objective Board 不只是给出开局文字，也能提供直接行动按钮。
- 保持普通未完成目标状态的动作行隐藏，避免新档大厅信息过载。

### 本次改动
- `LobbyScreen.gd` 新增 `ObjectiveStartRunButton`，放在 Objective 动作行中。
- `_should_show_objective_start_run_action()` 只在没有失败反制、没有解锁目标、没有熟练度目标、没有训练徽章目标时返回 true。
- `_update_objective_buttons()` 现在会在完成态显示动作行和 `Start` 按钮；失败反制状态仍显示 Review/Build/Pick/Next，普通新档仍隐藏动作行。
- Objective Start 复用现有 `start_requested` 信号，不新增平行开局流程。
- `LobbyScreenSmokeTest.gd` 新增完成态动作行、`Start` 文案、tooltip 和反制按钮隐藏断言。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_start_action.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_start_action.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_start_action.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_start_action.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrainingRoomSmokeTest_objective_start_action.log" "res://scenes/debug/TrainingRoomSmokeTest.tscn"
TrainingRoomSmokeTest passed.
```

### 仍需人工复核
- 实机确认完成态 `Start` 动作行是否会和主动作行的 `Start Run` 形成重复感；如果重复感明显，后续可把 Objective Start 改为焦点高亮或推荐 build 标签。
- 后续可进一步让完成态 Start 旁边显示“推荐路线/随机挑战”，把可点击开局推进为更强的重玩动机。

## 2026-07-09 Lobby Objective Start 激活回归第一版

### 目标
- 补齐完成态 Objective Start 的行为级自动化证据。
- 确认该按钮不只是显示出来，而是能真实进入 run 并关闭大厅。

### 本次改动
- `LobbyScreenSmokeTest.gd` 新增一个独立 Main 实例，打开大厅后合成所有局外目标完成的 summary。
- 测试点击 `request_objective_start_run_for_test()`，断言 `get_run_state_name()` 变为 `Running`。
- 测试同时断言大厅隐藏，确认 Objective Start 复用现有开局流程。
- 本批不改运行时代码，只强化第二百四十三批的回归覆盖。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_start_activation.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_start_activation.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_start_activation.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_start_activation.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrainingRoomSmokeTest_objective_start_activation.log" "res://scenes/debug/TrainingRoomSmokeTest.tscn"
TrainingRoomSmokeTest passed.
```

### 仍需人工复核
- 实机确认 Objective Start 点击后的焦点/视觉反馈是否足够自然；当前自动化只验证状态流转。
- 后续如引入推荐 seed 或 build 挑战，应扩展该回归，确认 Objective Start 能携带对应开局参数。

## 2026-07-09 Lobby Objective Start 状态复位回归第一版

### 目标
- 补齐 Objective Start 在不同大厅目标状态之间切换时的隐藏/复位证据。
- 避免完成态 Start 按钮残留到失败反制或训练目标状态。

### 本次改动
- `LobbyScreenSmokeTest.gd` 在上次失败反制 summary 下新增断言：`ObjectiveStartRunButton` 必须隐藏。
- 同一测试在从完成态 summary 切回 `Training: Movement` 训练目标后，断言 Objective 动作行和 Objective Start 都隐藏。
- 本批不改运行时代码，只强化 Objective Start 的状态切换回归覆盖。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_start_reset.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_start_reset.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_start_reset.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_start_reset.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrainingRoomSmokeTest_objective_start_reset.log" "res://scenes/debug/TrainingRoomSmokeTest.tscn"
TrainingRoomSmokeTest passed.
```

### 仍需人工复核
- 实机确认完成态 Start 与失败反制动作切换时视觉上没有跳动感；当前自动化只确认可见性状态。
- 后续若 Objective 动作行承载更多类型，应保持每种状态只显示当前目标真正需要的动作。

## 2026-07-09 Lobby Objective Start 角色提示第一版

### 目标
- 让完成态 Objective Start 不只提示“开始一局”，而是明确显示将用当前选中角色开局。
- 保持 Objective Start 仍复用既有开局流程，不新增并行 start 状态。

### 本次改动
- `LobbyScreen.gd` 新增 `_get_objective_start_run_tooltip()`，从 `_current_summary` 的当前角色条目读取 `display_name`。
- `_update_objective_buttons()` 现在用该 helper 刷新 `ObjectiveStartRunButton` tooltip，正常状态显示类似 `Start a run with Wanderer`。
- `update_character_selection()` 会把当前角色 index 同步回本地 `_current_summary`，并刷新当前角色图标和 Objective Start tooltip，保证大厅内即时切换角色后提示同步更新。
- 当底层 Start 按钮处于禁用状态时，Objective Start tooltip 会显示解锁或选择可用角色的提示。
- `LobbyScreenSmokeTest.gd` 扩展完成态、切换角色态和独立点击态断言，确认 Objective Start tooltip 会从 `Wanderer` 更新到 `Rift Runner`，并在点击前仍包含当前角色名。

### 验证状态
```text
Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\LobbyScreenSmokeTest_objective_start_tooltip.log" "res://scenes/debug/LobbyScreenSmokeTest.tscn"
LobbyScreenSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\HallArchiveSmokeTest_objective_start_tooltip.log" "res://scenes/debug/HallArchiveSmokeTest.tscn"
HallArchiveSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\UILayoutSmokeTest_objective_start_tooltip.log" "res://scenes/debug/UILayoutSmokeTest.tscn"
UILayoutSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\MenuFlowSmokeTest_objective_start_tooltip.log" "res://scenes/debug/MenuFlowSmokeTest.tscn"
MenuFlowSmokeTest passed.

Godot_v4.7-stable_win64_console.exe --headless --path "E:\Dungeon Unleashed\dungeon-unleashed" --log-file "E:\Dungeon Unleashed\tmp_godot\TrainingRoomSmokeTest_objective_start_tooltip.log" "res://scenes/debug/TrainingRoomSmokeTest.tscn"
TrainingRoomSmokeTest passed.
```

Godot 仍会输出项目既有的 `user://..` 目录创建警告，但上述命令退出码均为 0。

### 仍需人工复核
- 实机 hover Objective Start，确认 `Start a run with Wanderer` 这类角色提示在鼠标和手柄焦点下都容易读到。
- 后续如果完成态开局要携带推荐 build、seed 或挑战目标，应继续把这些上下文补进同一个 tooltip，而不是另建平行入口。

## 2026-07-11 35 武器 / 40 遗物内容深度与专属 Build 参数第一版

### 目标
- 完成对齐方案中 `35-40` 武器和 `40+` 遗物的下一档内容门槛。
- 让新增遗物补足已有武器系统仍缺少的弹跳、爆炸、击退、弹匣和能量专属 Build 参数，而不是只增加同效果换名条目。

### 本次改动
- 新增 Quench Repeater、Furnace Scattergun、Bastion Saw、Rift Bloom、Thunder Nest 五把原创武器，武器总数达到 35。
- 新增 Ricochet Gyro、Blast Radius Gauge、Kinetic Bridle、Reserve Drum、Flux Reservoir 五个原创遗物，遗物总数达到 40。
- `RelicData` / `RelicSystem` / `Player` 新增 `bounce_count_bonus`、`explosion_radius_bonus`、`knockback_multiplier`、`magazine_size_bonus` 和 `max_energy` 被动效果链路。
- `Projectile` 将额外弹跳、爆炸半径和击退倍率接入发射快照；`Weapon` 将击退倍率接入近战/挡弹反制，并让弹匣容量读取玩家加成；`DeployableTrap` 同步读取击退倍率；独立负载属性刷新信号会同步 HUD 三槽弹匣容量。
- 新资源已接入 RewardChest、ShopInventory、五类 RelicDropTable、高级宝箱和 Boss 宝箱，确保图鉴可见并能从真实局内来源获得。
- `WeaponSmokeTest` 修复短生命周期反馈依赖慢帧等待的问题，改为在同步事件后立即读取弹丸、挥砍闪光、能量状态与 HUD 脉冲。

### 验证状态
```text
ContentPipelineSmokeTest passed.
RelicSmokeTest passed.
WeaponSmokeTest passed.
ChestSmokeTest passed.
ShopSmokeTest passed.
HallArchiveSmokeTest passed.
LobbyScreenSmokeTest passed.
```

Godot 仍会输出项目既有的 `user://..` 目录创建警告，但上述命令退出码均为 0。

### 仍需人工复核
- 实机比较 Quench Repeater、Furnace Scattergun、Bastion Saw、Rift Bloom 和 Thunder Nest 的输出节奏，确认它们不只是数值差异。
- 重点观察 Reserve Drum 与高弹匣武器、Ricochet Gyro 与狭窄房间、Blast Radius Gauge 与高密度敌群的强度上限。
- 新增 10 个条目当前使用内容图标注册表 fallback，后续应补专属 SVG/Atlas 图标和独立开火/命中音色。

## 2026-07-11 35 武器 / 40 遗物专属图标补齐第一版

### 目标
- 消除上一批新增 5 把武器和 5 个遗物的默认图标 fallback。
- 保持现有 64px 工业奇幻图标语言，并让缩小后的武器槽/奖励按钮仍能区分内容类型和核心效果。

### 本次改动
- 新增 10 个 SVG：Quench Repeater、Furnace Scattergun、Bastion Saw、Rift Bloom、Thunder Nest、Ricochet Gyro、Blast Radius Gauge、Kinetic Bridle、Reserve Drum、Flux Reservoir。
- 武器图标统一使用深蓝黑底、冷青轮廓和琥珀功能信号；遗物图标使用深紫底和紫色轮廓，中央器件直接对应其 Build 参数。
- 新增 10 个 `ContentIconDefinitionData` 资源并接入 `content_icon_registry.tres`，注册表定义数量从 102 提升到 112。
- `ContentPipelineSmokeTest` 新增十个 icon key 的专属路径、非默认 fallback、资源可加载断言，并把注册表数量下限提升到 112。
- 通过 Godot `--headless --editor --quit` 生成标准 SVG 导入元数据；使用 Sharp 将十个 SVG 栅格化为联系表，确认非空、主体边界安全且类别可辨。

### 验证状态
```text
ContentPipelineSmokeTest passed.
WeaponSmokeTest passed.
HallArchiveSmokeTest passed.
LobbyScreenSmokeTest passed.
```

Godot 仍会输出项目既有的 `user://..` 目录创建警告，但上述测试退出码均为 0。

### 仍需人工复核
- 在 1280×720 实机窗口中检查新图标进入 Codex 列表、奖励选择和三武器槽后的清晰度。
- 后续正式像素 Atlas 应保留当前主轮廓语义，避免替换素材后降低 32–64px 尺寸下的识别度。

## 2026-07-11 部署物 Field / Mine / Sentry 行为分化第一版

### 目标
- 解决 Snare Beacon、Ember Mine、Sentry Seed 和 Thunder Nest 运行时全部表现为同一种范围脉冲的问题。
- 让部署/陷阱/轻量召唤路线产生真实目标选择与生命周期差异，并在图鉴中可读。

### 本次改动
- `WeaponData` 新增 `deployable_behavior` 枚举：`field`、`mine`、`sentry`。
- `DeployableTrap` 新增范围目标收集和最近目标选择：Field 周期攻击范围内全部敌人，Sentry 每个 tick 只攻击最近目标，Mine 首次命中范围目标后立即退场。
- 为三类行为增加不同程序化绘制：双环范围场、橙色菱形地雷、带朝向线的哨戒炮台；哨戒锁定最近目标后会同步旋转朝向。
- Snare Beacon / Thunder Nest 配置为 Field，Ember Mine 配置为 Mine，Sentry Seed 配置为 Sentry。
- `Main._summarize_weapons()` 新增行为摘要，`LobbyScreen._format_weapon_deployable()` 将行为名称加入武器详情。
- `ContentPipelineSmokeTest` 校验行为枚举和 `control` / `trap` / `summon` 标签契约；`WeaponSmokeTest` 新增三类行为级断言、哨戒朝向断言，并修正 Guard Cleaver 测试夹具残留旋转导致的偶发误判；Hall/Lobby 烟测确认图鉴出现 `Deploy Field`、`Deploy Mine` 和 `Deploy Sentry`。

### 验证状态
```text
ContentPipelineSmokeTest passed.
WeaponSmokeTest passed.
RelicSmokeTest passed.
HallArchiveSmokeTest passed.
LobbyScreenSmokeTest passed.
```

Godot 仍会输出项目既有的 `user://..` 目录创建警告，但上述测试退出码均为 0。

### 仍需人工复核
- 实机观察 Sentry Seed 的最近目标切换节奏，确认不会在密集敌群中频繁抖动。
- 实机确认 Ember Mine 的触发范围与 0.12 秒布设前摇足够可读，且爆发后立即消失不会显得突兀。
- 后续应为三类行为增加独立布设、锁定、触发和退场音效，并考虑补链式电塔、诱饵或移动随从等新行为。

## 2026-07-11 40 武器 / 45 遗物与 Homing / Chain Build 路线第一版

### 目标
- 达到构建方案中 v1 武器数量上限和遗物数量区间，而不是只复制已有参数组合。
- 补齐此前缺失的追踪弹道和连锁清群两条可由武器、遗物、掉落和图鉴共同表达的 Build 路线。

### 本次改动
- `WeaponData` 新增 `homing_turn_rate`、`homing_radius`、`chain_count`、`chain_radius` 和 `chain_damage_multiplier`。
- `Projectile` 新增按角速度转向最近敌人的追踪逻辑，以及从主目标开始逐跳选择最近未命中敌人的连锁逻辑；连锁伤害会继承击退、状态和命中事件，并生成短暂青色折线。
- 追踪和连锁的玩家遗物加成只在武器自身已配置对应能力时生效，避免多个路线遗物组合后让全部普通弹丸获得隐式能力。
- 新增 Compass Needle、Relay Arc、Lantern Swarm、Undertow Volley、Stormglass Rail，武器总数达到 40。
- 新增 Tracking Vane、Longview Array、Forked Bus、Conduction Mesh、Stormglass Filament，遗物总数达到 45。
- 五类遗物效果已接入 `RelicData`、`RelicSystem` 和 `Player`；新增内容接入 RewardChest、ShopInventory、全部遗物掉落表、Premium Chest 和 Boss Reward Chest。
- `Main` 和 `LobbyScreen` 新增 Homing/Chain 摘要，图鉴会显示转向角速度、索敌半径、连锁目标数、桥接半径和伤害倍率，并支持对应 Build 标签筛选。
- 新增 10 个专属 SVG 和 10 个 `ContentIconDefinitionData`，注册表定义数量提升到 122；Godot 已生成标准 `.svg.import` 元数据。
- `WeaponSmokeTest` 补充追踪转向、角速度上限、连锁跳数、半径和伤害缩放；同时在 Guard Cleaver 测试布置前清除残留敌方弹幕，消除既有夹具偶发计数污染。
- `RelicSmokeTest` 补充五种路线遗物拾取、支持武器增强和普通武器能力门控；内容、宝箱、商店和大厅测试同步更新到 40/45 契约。

### 验证状态
```text
ContentPipelineSmokeTest passed.
WeaponSmokeTest passed.
RelicSmokeTest passed.
ChestSmokeTest passed.
ShopSmokeTest passed.
HallArchiveSmokeTest passed.
LobbyScreenSmokeTest passed.
```

Godot 仍会输出项目既有的 `user://..` 目录创建警告，但上述测试退出码均为 0。

### 仍需人工复核
- 实机观察 Lantern Swarm 的多弹追踪是否在密集敌群中过度集中到同一目标，并据此调节角速度或索敌策略。
- 实机比较 Relay Arc 和 Stormglass Rail 在狭窄/开阔布局中的清群效率，确认连锁半径和伤害倍率不会压制爆炸路线。
- 为五把新武器补独立开火、飞行、追踪锁定和连锁命中音色，并将当前 SVG 轮廓迁移到正式像素 Atlas。

## 2026-07-11 三层 Boss Signature Attack 专属机制第一版

### 目标
- 解决 Warrens Gatekeeper、Iron Bulwark 和 Void Foundry Heart 仅靠生命、速度、弹数和召唤物参数区分的问题。
- 让每层 Boss 至少拥有一招可通过前摇形状、空间应对和 Build 反制清晰识别的专属机制。

### 本次改动
- `BossEnemy` 的攻击循环从三招扩为四招，前三招仍为环形弹幕、瞄准齐射和召唤，第四招按 `signature_attack` 分派专属机制。
- `Pincer Gates` 在目标两侧生成线形预警，从两个独立起点向目标快照发射收束弹幕，强调横向脱离和提前选边。
- `Bastion Lock` 启动蓝色防御窗口，按 `signature_guard_damage_multiplier` 降低受到的伤害，前摇结束后释放环形弹幕，阻止玩家无脑对攻。
- `Void Bloom` 在目标快照位置生成带 Boss 来源信息的圆形伤害预警，并从该位置向外释放弹幕环，强调及时离开中心标记。
- `get_signature_attack_summary()` 暴露机制 ID、显示名、前摇、射弹数、半径、范围、防御倍率、激活状态和使用次数；死亡情报同时返回机制名称、专属复盘建议和反制标签。
- 三个 Boss 场景新增稳定 `source_id` 和专属参数；Void Foundry Heart 的召唤物改为 Null Acolyte，使最终层召唤行为与主题敌人池一致。
- `Main` 将 Signature 显示名接入 Boss 血条标题，HUD 新增测试读取接口。
- 新增 `BossSignatureSmokeTest`，逐个实例化三个 Boss 并直接执行专属招式，验证预警类型、弹幕数量、伤害减免、目标点伤害和来源身份。
- `ContentPipelineSmokeTest` 锁定 Biome 与 Signature 的一一对应；`BossSmokeTest` 验证最终 Boss 的 HUD、Void Bloom、主题召唤、阶段转换、场地危险和奖励结算。

### 验证状态
```text
BossSignatureSmokeTest passed.
BossSmokeTest passed.
ContentPipelineSmokeTest passed.
DungeonGenerationSmokeTest passed.
EnemyVarietySmokeTest passed.
FullRunSmokeTest passed. (338.3s)
```

首次完整 Run 使用 240 秒外层窗口时仅发生命令超时，日志没有断言失败；扩大为 600 秒后同一测试完整通过。Godot 仍会输出项目既有的 `user://..` 目录创建警告。

### 仍需人工复核
- 实机确认 Pincer Gates 两条收束线在窄房布局中仍保留明确逃生侧，不会与墙体形成无解夹角。
- 比较 Bastion Lock 防御窗口和玩家高爆发 Build，确认 0.45 倍伤害不会让战斗拖沓，也不会被多段伤害绕过。
- 观察 Void Bloom 与 Boss Arena 地板危险同时出现时的视觉层级，必要时错开计时或降低同时预警数量。

## 2026-07-11 三层 Biome 像素地板纹理与 TerrainLayer 第一版

### 目标
- 把三层房间表现从纯色 Polygon/tint 推进到真实项目位图资产，同时保持布局和碰撞零改动。
- 建立可继续扩展到墙体、障碍和装饰 Atlas 的 Biome 纹理数据接口。

### 资产生成
- 使用内置 ImageGen 生成三个原创、俯视角、无角色/文字/道具的可重复像素地板源图。
- Outer Warrens 提示方向：深炭绿与灰石板、苔藓缝、稀疏铜质接点；保存为 `art/terrain/outer_warrens_floor.png`。
- Iron Catacombs 提示方向：深枪灰钢板、铆钉、磨损划痕、稀疏铜件与暗橙热栅；保存为 `art/terrain/iron_catacombs_floor.png`。
- Void Foundry 提示方向：紫黑黑曜金属板、几何回路、稀疏青色裂隙与淡洋红节点；保存为 `art/terrain/void_foundry_floor.png`。
- 三图使用 Pillow 最近邻缩放为 512×512 PNG；逐张视觉检查确认类型可辨、主体均匀、无文字水印和明显边缘断裂。

### 本次改动
- `BiomeData` 新增 `visual_floor_texture_path`、`visual_floor_texture_modulate` 和 `visual_floor_texture_opacity`。
- 新增 `BiomeTerrainLayer.gd`，使用 `TEXTURE_FILTER_NEAREST`、`TEXTURE_REPEAT_ENABLED` 和 `draw_texture_rect(..., tile=true)` 绘制 1280×720 地板。
- `PrototypeCombatRoom.tscn` 将原 Floor Polygon 置于 `z_index=-2`，TerrainLayer 位于 `z_index=-1`；墙体、障碍、门和碰撞层保持不变。
- `DungeonController` 在房间记录、Biome 摘要和实例化流程中传递三项纹理字段；`CombatRoom` 在布局底色应用后配置 TerrainLayer，并向测试暴露运行时摘要。
- `ContentPipelineSmokeTest` 校验纹理路径、唯一性、Godot 可加载、512px 尺寸和透明度；`DungeonGenerationSmokeTest` 校验房间元数据与运行时图层一致，并验证重复铺设与最近邻过滤。
- 三张纹理平均 RGB 分别约为 Iron `(43,42,45)`、Warrens `(48,52,51)`、Void `(27,25,44)`，两两平均色距离均大于 12，避免三层仍呈现同一色调。
- `RoomFlowSmokeTest` 将一次性全局击杀改为当前房间半径内的动态波次清理，处理 Soot Splitter 分裂体和召唤物；该策略与现有 `FullRunSmokeTest` 保持一致。

### 验证状态
```text
ContentPipelineSmokeTest passed.
DungeonGenerationSmokeTest passed.
UILayoutSmokeTest passed.
RoomFlowSmokeTest passed. (298.0s)
PNG size/non-empty/color-distance checks passed.
```

`RoomFlowSmokeTest` 首次使用 180 秒窗口时仅发生命令超时；扩大窗口后暴露 Room13 动态分裂体夹具问题，修复动态清理后完整通过。Godot 仍会输出项目既有的 `user://..` 目录创建警告。

### 仍需人工复核
- 在实际 1280×720 游戏窗口中确认 0.82–0.86 透明度不会让地板细节抢过敌人、金币和弹幕。
- 为三层补独立墙体、门、障碍和边角装饰 Atlas，避免当前高质量地板与纯色墙体形成完成度落差。
- 后续正式美术替换应保留当前石板、钢板、虚空回路三种清晰材料语义，并统一像素密度。

## 2026-07-11 三层墙体/障碍 Surface Atlas 与分区铺设第一版

### 目标
- 把固定墙体和布局障碍从纯色 Polygon 推进到每层独立纹理，同时保持碰撞与布局完全不变。
- 建立可继续扩展门、边角和装饰件的 Atlas 数据与运行时采样接口。

### 资产制作
- 新增 `outer_warrens_surface_atlas.svg`：左区为苔痕石墙，右区为铜芯加固石柱。
- 新增 `iron_catacombs_surface_atlas.svg`：左区为铆接钢板，右区为带热栅的重型掩体。
- 新增 `void_foundry_surface_atlas.svg`：左区为紫黑铸板与青色裂线，右区为虚空回路核心。
- 每套 Atlas 为 `512×256`，左右各 `256×256`；采用确定性像素几何、`shape-rendering="crispEdges"`，无文字、角色或第三方资产。
- 使用 Godot `--import` 完成 SVG 纹理导入；另用 Chromium 渲染三张预览逐项检查分区、对比度、材质差异和像素边缘。

### 本次改动
- `BiomeData` 新增 `visual_surface_atlas_path`、墙体/障碍纹理调制色和透明度字段，三个 Biome 资源分别配置独立 Atlas。
- 新增 `BiomeSurfaceVisual.gd`，按 `wall` / `obstacle` 选择固定 Atlas 区域，并使用 `draw_texture_rect_region` 逐块铺设任意尺寸矩形。
- 禁用整张 Atlas 的纹理回绕，手动限制每次源区域，避免左/右分区发生采样串色；继续使用最近邻过滤保持像素边缘。
- `CombatRoom` 为六段边界墙和所有动态 `LayoutObstacles` 添加纹理视觉子节点，原 Polygon 保留为底色与资源降级路径。
- `DungeonController` 在房间定义、房间记录、Biome 摘要和实例化流程中传递五项 Surface Atlas 字段。
- `ContentPipelineSmokeTest` 校验 Atlas 路径唯一性、Godot 可加载、`512×256` 尺寸、调制色和透明度。
- `DungeonGenerationSmokeTest` 校验运行时墙体左区、障碍右区、手动区域铺设、最近邻过滤以及元数据一致性。

### 验证状态
```text
Godot SVG import passed.
ContentPipelineSmokeTest passed.
DungeonGenerationSmokeTest passed. (67.7s verified run)
UILayoutSmokeTest passed.
RoomFlowSmokeTest passed. (353.0s)
Three Atlas preview renders visually inspected.
```

手动分区铺设修改前曾触发一次 `draw_texture_rect_region` 参数顺序解析错误；按 Godot 4.7 签名修正后，内容管线和地牢生成最终复测均通过。Godot 仍可能输出项目既有的 `user://..` 目录创建警告。

### 仍需人工复核
- 在实际 1280×720 游戏窗口中检查墙体与障碍透明度，确保其不会盖过门、弹幕、金币和危险预警。
- 补三层独立门框、墙角、墙脚阴影和破损装饰，解决当前矩形墙段交界处的视觉重复。
- 后续敌人正式像素动画应继续使用比地形更高的明度和轮廓对比，避免复杂地形降低战斗读图速度。

## 2026-07-11 普通敌人关键动作前摇与语义预警第一版

### 目标
- 消除召唤、治疗和盾卫近身动作的瞬时执行，让玩家在效果发生前获得可操作反应窗口。
- 把统一预警从单纯形状/颜色扩展为带用途标识的战斗反馈接口，便于后续音效、无障碍和死亡复盘复用。

### 本次改动
- `DangerWarning` 新增 `warning_purpose` 和测试访问器；`configure_circle` / `configure_line` 仅增加可选尾参数，Boss、房间机关和旧敌人调用保持兼容。
- 普通敌人现有预警补齐 `projectile`、`charge`、`zone`、`self_destruct` 和 `elite_death` 用途。
- `Enemy` 新增 Utility Windup 计时、动作名、方向、待召唤位置、盾击活动和恢复状态，并通过 `get_attack_telegraph_summary()` 暴露运行时摘要。
- Summoner 与 Rift Caller 在前摇开始时计算并冻结安全出生点，为每个位置创建紫色召唤圈；完成后按同一位置生成单位。
- Grave Mender 增加受伤友军检测，只在存在有效治疗目标时显示绿色范围预警并进入前摇；效果完成前不治疗。
- Shielded 与 Aegis Drone 增加短距离盾击：蓝色线形前摇、定向冲刺、恢复停顿；实际伤害继续由 `Player._try_contact_damage()` 统一处理。
- 盾卫死亡复盘提示同步加入“侧移躲盾击后绕背/贯穿”的反制信息。

### 测试更新
- `EnemyVarietySmokeTest` 验证召唤预警数量与冻结位置、前摇前无生成、前摇后生成和召唤上限。
- 支援测试验证绿色 `support` 预警、前摇前不治疗、前摇后恢复生命。
- 盾击测试验证蓝色 `shield_bash` 线形预警、前摇状态、冲刺状态和玩家实际接触受伤。
- Bomber、Charger、Barrage Totem、Zoner 和精英死亡爆炸测试新增对应 `warning_purpose` 断言。

### 验证状态
```text
Godot script import passed.
EnemyVarietySmokeTest passed. (81.1s final verified run)
BossSignatureSmokeTest passed.
CombatFeedbackSmokeTest passed. (15.5s)
ContentPipelineSmokeTest passed.
RoomFlowSmokeTest passed. (308.2s)
```

首次敌人烟测因测试脚本未显式标注盾卫实例类型而解析失败，并在场景未加载后留下 Godot 进程；进程已终止，类型修正后 `--import` 通过。增加盾击真实受伤断言后，Bomber 用例暴露前一用例残留无敌计时；沿用精英爆炸用例的逐帧无敌清理策略完成夹具隔离，最终综合烟测通过。Godot 仍会输出项目既有的 `user://..` 目录创建警告。

### 仍需人工复核
- 观察绿色治疗范围与红橙危险区同时出现时的语义区分，色弱模式不能只依赖色相。
- 调整 Grave Mender 的 300px 治疗圈透明度，避免多支援单位同时施法时遮挡弹幕。
- 比较 Shielded 与 Aegis Drone 的盾击距离、速度和恢复时间，确保前者适合早期教学、后者保留中层压迫感。
- 下一步为召唤、治疗和盾击补正式像素动作帧与独立起手音效，替换当前颜色闪烁主导的表现。

## 2026-07-11 敌人关键动作形状提示与独立起手音第一版

### 目标
- 让召唤、治疗和盾击在色弱环境或多种范围预警叠加时，仍能通过形状快速辨认。
- 将“动作开始”与“危险范围出现”拆成独立事件，使音效和后续正式动画不依赖预警形状推断动作语义。

### 本次改动
- 新增 `EnemyActionCue`：在敌人头顶绘制短生命周期动作标记。召唤使用三枚菱形，治疗使用粗十字，盾击使用随朝向旋转的双箭头；三类提示同时保留独立颜色，但识别不再只依赖色相。
- `Events` 新增 `enemy_action_windup_started(enemy, action_id, duration)`，原 `danger_warning_started` 的参数和监听方式保持不变。
- `Enemy._start_utility_windup()` 统一创建动作提示并发送动作事件；实际召唤、治疗和盾击时序、前摇时间与伤害结算路径不变。
- `AudioFeedback` 新增 `enemy_summon_windup`、`enemy_support_windup`、`enemy_shield_bash_windup` 和通用降级音色，并加入独立 0.12 秒并发冷却，避免同帧大量敌人提示造成音频堆叠。
- `AudioFeedbackSmokeTest` 验证三类动作事件均触发独立 SFX ID；`EnemyVarietySmokeTest` 验证三类头顶提示分别暴露 `diamonds`、`cross`、`chevrons` 形状签名。

### 验证状态
```text
Godot script import passed.
AudioFeedbackSmokeTest passed. (12.7s)
EnemyVarietySmokeTest passed. (56.1s final verified run)
CombatFeedbackSmokeTest passed. (13.1s)
ContentPipelineSmokeTest passed.
```

Godot 仍会输出项目既有的 `user://..` 目录创建警告，不影响上述测试退出码。

### 仍需人工复核
- 在 1280×720 实机战斗中观察多个支援与召唤单位同时施法时，头顶提示是否需要进一步错层或缩小。
- 当前提示是程序化形状层，下一阶段仍需为敌人补正式像素起手帧，并把程序化音色替换为原创采样 SFX。
- 为设置菜单增加色弱预设时，应同时调整危险范围的线型/填充纹样，而不是只替换颜色。

## 2026-07-11 敌人关键动作四帧像素 Atlas 第一版

### 目标
- 将召唤、治疗和盾击从 Polygon 闪色推进为可读的逐帧动作，不改变现有碰撞、前摇和伤害结算。
- 建立敌人动画 Atlas 的统一契约，使后续 PNG 正式美术可以替换纹理而无需重写 AI 状态机。

### 资产与接入
- 新增三套原创 `128×128 / 2×2` 像素 SVG Atlas：`rift_summoner_action_atlas.svg`、`grave_mender_action_atlas.svg`、`shield_sentinel_action_atlas.svg`。
- 每套 Atlas 固定为 `idle`、`anticipation`、`action peak`、`recovery` 四帧；召唤者使用紫黑兜帽与青色符文，治疗者使用骨白陶瓷甲与青色核心，盾卫使用蓝钢本体与前向月牙盾。
- Summoner / Rift Caller、Grave Mender、Shielded / Aegis Drone 五个场景新增 `ActionSprite`，启用 `2×2` 切片和最近邻过滤；原 `Visual` / `ShieldVisual` 保留为纹理缺失时的降级节点，Atlas 正常时隐藏。
- `Enemy` 新增动作 Sprite 运行时摘要和四帧状态驱动：前摇前半为蓄势帧、后半为峰值帧、动作完成后短暂进入恢复帧，再回到待机帧。
- 受击闪烁现在恢复 Sprite 原始 `modulate`，避免 Rift Caller 与 Aegis Drone 的场景调色在第一次闪烁后被重置为纯白。

### 生成与视觉检查
- 按 ImageGen 内置流程尝试生成三套 `2×2` 像素 Atlas，图像服务连续两次超时且没有产生可用新素材；未切换到需要 API Key 的 CLI 降级路径。
- 为保持本批可执行，最终采用可版本控制的确定性 SVG 像素源，并由 Godot 完成纹理导入。
- 使用 Edge Headless 分别渲染三张预览 PNG，人工检查透明背景、四格边界、角色锚点、轮廓差异和动作峰值，无文字、水印或第三方元素。

### 测试更新
- 新增 `EnemyActionAnimationSmokeTest`，验证三套 Atlas 尺寸、五个场景的 Sprite 契约、Polygon 降级隐藏，以及 `0 → 1 → 2 → 3 → 0` 四帧状态循环。
- `ContentPipelineSmokeTest` 要求全部召唤、盾卫和支援敌人配置 `128×128 / 2×2` 最近邻动作 Atlas。
- `EnemyVarietySmokeTest` 在真实召唤、治疗和盾击 AI 前摇中断言动作 Sprite 处于蓄势或峰值帧。

### 验证状态
```text
Godot SVG import passed.
EnemyActionAnimationSmokeTest passed.
ContentPipelineSmokeTest passed.
EnemyVarietySmokeTest passed. (50.8s)
```

Godot 仍会输出项目既有的 `user://..` 目录创建警告；内容管线退出时仍有既有 RID/ObjectDB 释放告警，但测试退出码为 0。

### 仍需人工复核
- 在实际 1280×720 战斗窗口确认 64px 单帧在旋转、受击闪烁和精英调色叠加时仍足够清晰。
- 将四帧动画扩展到射手、冲锋、爆炸、地形控制和 Boss，并为移动补至少两帧步态。
- 最终美术阶段可按同一 `128×128 / 2×2` 契约替换为透明 PNG；当前 SVG 不阻塞状态机和场景接入。

## 2026-07-11 射击/冲锋/自爆/地形控制四帧 PNG Atlas 第一版

### 目标
- 将正式逐帧读招从三类 Utility 敌人扩展到远程射击、冲锋、自爆和地形控制职责。
- 使用项目内透明 PNG 正式素材验证 ImageGen → 色键移除 → Godot 导入 → 场景缩放 → 状态机切帧的完整资产管线。

### 资产生成与处理
- 使用内置 ImageGen 分别生成四套原创 `2×2` 像素 Atlas：锈红机械射手、铁铜楔角冲锋构造体、黑钢高压爆破容器、石铜青色流体导管。
- 四套提示统一要求：右向俯视三分之四构图、待机/蓄势/峰值/恢复四格、固定锚点、无文字/标志/水印、纯色绿幕或品红幕背景。
- 使用 `imagegen` 技能附带的 `remove_chroma_key.py`、Codex 工作区 Pillow 运行时、Border 自动取色、Soft Matte、Despill 完成透明化；未使用外部 API Key 或 CLI 模型降级。
- 最终入库 `marksman_action_atlas.png`、`ram_charger_action_atlas.png`、`volatile_vessel_action_atlas.png`、`terrain_conduit_action_atlas.png`，均为 `1254×1254 RGBA`。
- 透明校验确认四张图角点 alpha 均为 0，主体覆盖率分别约 16.0%、18.6%、23.9%、32.7%；逐张视觉检查未发现整幅色键残留或跨格主体串位。

### 场景与状态机
- Shooter / Ember Marksman / Barrage Totem / Needle Skater 共用射手 Atlas；Charger / Iron Breaker 共用冲锋 Atlas；Bomber / Volatile Vessel 共用高压容器 Atlas；Mire Conduit / Null Acolyte 共用导管 Atlas。
- 十个场景新增最近邻 `ActionSprite`，使用 `0.1` 缩放；`1254 × 0.1 ÷ 2 = 62.7px`，与上一批 64px 单帧契约保持一致。Polygon 继续作为纹理缺失时的降级节点。
- Projectile Windup 前半/后半映射到蓄势/开火峰值，发射后短暂进入恢复帧；冲锋状态 1/2/3 分别映射蓄势/冲刺/刹停；自爆倒计时映射蓄压/临界帧。
- Zoner 在生成危险区时启动与 `zone_warning_duration` 一致的纯视觉施法计时，进入蓄势/峰值/恢复帧；危险区伤害、目标快照和移动策略不变。
- Bomber 的倒计时脉冲现在作用于可见 ActionSprite，不再写入已隐藏 Polygon。

### 测试更新
- `EnemyActionAnimationSmokeTest` 从 3 套 Atlas / 5 个场景扩展到 7 套 Atlas / 15 个非追击场景，并直接验证 Utility、Projectile、Charge、Self Destruct、Zone 的四帧循环。
- `ContentPipelineSmokeTest` 要求所有非 Chaser 普通敌人配置方形偶数尺寸 `2×2` Atlas、最近邻过滤，并将场景缩放后的单帧尺寸锁定在 60–65px。
- `EnemyVarietySmokeTest` 在真实 Barrage Totem、Charger、Bomber 和 Mire Conduit AI 前摇中新增动作帧断言，同时保留弹幕数量、冲锋状态、自爆伤害和危险区语义断言。

### 验证状态
```text
Godot PNG import passed.
EnemyActionAnimationSmokeTest passed.
ContentPipelineSmokeTest passed.
EnemyVarietySmokeTest passed. (54.0s)
```

Godot 仍会输出项目既有的 `user://..` 目录创建警告；内容管线退出时仍有既有 RID/ObjectDB 释放告警，但测试退出码为 0。

### 仍需人工复核
- 在实际战斗窗口比较高细节 PNG 与简化 SVG 敌人的像素密度，必要时统一轮廓宽度和色阶数量。
- Barrage Totem 暂时复用机械射手外形，后续应补独立固定炮台 Atlas；Needle Skater 也应补更轻量的高速轮廓。
- 下一步为 Chaser 系敌人补移动步态，并把三层 Boss 从 Polygon 推进到阶段/专属招式动画。

## 2026-07-11 Chaser 步态与三层 Boss 阶段/招牌技 PNG Atlas 第一版

### 目标
- 补齐追击型普通敌人的移动读感，使其不再只有静态待机轮廓。
- 将三层主 Boss 从 Polygon 主视觉推进到可直接表达普通蓄力、招牌技峰值、阶段转换和二阶段常驻状态的逐帧素材。

### 资产生成与处理
- 使用内置 ImageGen 生成四套原创 `2×2` 像素 Atlas：废料拼装追猎自动机、Warrens Gatekeeper、Iron Bulwark、Void Foundry Heart。
- Chaser 提示帧序为待机、左步、右步、接触突刺；Boss 提示帧序为一阶段待机、普通攻击蓄力、招牌技/转阶段峰值、二阶段狂暴。所有提示均要求固定锚点、俯视三分之四构图、无文字/标志/水印和纯色绿幕或品红幕。
- 使用 `imagegen` 技能附带的 `remove_chroma_key.py`，以 Border 自动取色、Soft Matte、Despill 和强制透明输出完成色键移除；本批使用内置生成模式，未使用外部 API Key 或 CLI 模型。
- 最终入库 `chaser_stride_atlas.png`、`warrens_gatekeeper_action_atlas.png`、`iron_bulwark_action_atlas.png`、`void_foundry_heart_action_atlas.png`，均为 `1254×1254 RGBA`。
- 四张图角点 alpha 均为 0，主体覆盖率约为 13.0%、42.0%、46.0%、31.3%；逐张视觉检查确认四格主体完整、无整幅色键残留。

### 场景与状态机
- Chaser / Rust Skirmisher / Soot Splitter 共用追猎自动机 Atlas，使用最近邻和 `0.1` 缩放，单帧约 62.7px；移动时在左右步之间循环，进入 48px 接触距离后切换突刺帧。
- Warrens Gatekeeper、Iron Bulwark、Void Foundry Heart 分别接入独立 Boss Atlas，使用最近邻和 `0.2` 缩放，单帧约 125.4px；原 `Visual` / `Core` Polygon 保留为纹理缺失降级节点。
- `BossEnemy` 统一驱动四态：一阶段空闲为帧 0，普通径向/瞄准/召唤动作使用帧 1，招牌技和阶段转换使用帧 2，二阶段稳定态使用帧 3。
- 受击闪烁、Bastion Lock 脉冲和阶段缩放现在作用于当前可见 Sprite，并恢复场景原始调色与缩放；弹幕、伤害、AI、碰撞和阶段时序未改动。

### 测试更新
- `EnemyActionAnimationSmokeTest` 新增 Chaser Atlas、三个追击场景和左步/右步/接触突刺断言。
- 新增 `BossActionAnimationSmokeTest`，锁定三套 Boss Atlas 的尺寸、最近邻四格契约、约 128px 世界帧尺寸以及 `0 → 1 → 2 → 3` 语义映射。
- `ContentPipelineSmokeTest` 现要求全部普通敌人都配置动作 Atlas；`BossSignatureSmokeTest` 与 `BossSmokeTest` 分别校验招牌技峰值帧和转阶段/二阶段帧。

### 验证状态
```text
Godot PNG import passed.
EnemyActionAnimationSmokeTest passed.
BossActionAnimationSmokeTest passed.
ContentPipelineSmokeTest passed.
BossSignatureSmokeTest passed.
BossSmokeTest passed. (21.5s)
EnemyVarietySmokeTest passed. (59.3s)
CombatFeedbackSmokeTest passed on unchanged retry. (14.0s)
```

CombatFeedback 首次运行因浮字与 HUD 闪烁固定清理窗口发生调度抖动而失败，未改测试或运行时代码，原样复跑通过。Godot 仍会输出项目既有的 `user://..` 目录创建警告；内容管线退出时仍有既有 RID/ObjectDB 释放告警，但通过运行的退出码为 0。

### 仍需人工复核
- 在实际 1280×720 战斗窗口确认 Chaser 左右步切换速度与移动速度匹配，接触突刺不会因高速追击一闪而过。
- 对比三个 Boss 在弹幕高峰下的轮廓辨识度，必要时降低纹理内部细节并加强招牌技帧的外轮廓差异。
- 下一步优先补 Barrage Totem、Needle Skater 与精英敌人的独立 Atlas，再为每个 Boss 增加第二套专属机制和对应动画状态。

## 2026-07-11 三层 Boss 二阶段第二专属机制第一版

### 目标
- 让三名主线 Boss 的二阶段不再只是移速、弹速、弹数和冷却的数值增强，而是实际进入新的专属攻击循环。
- 保持一阶段四槽攻击循环、原招牌技、阶段停顿和奖励链不变，并让新增机制具备可解释预警、死亡复盘字段和自动化验收。

### 三套原创机制
- Warrens Gatekeeper 新增 `Warren Sweep`：以 Boss 朝向为轴生成三条平行线形预警，随后从三条通道同步释放扫射弹幕，强调横向换道。
- Iron Bulwark 新增 `Iron Quake`：先显示大范围圆形预警，再释放首轮径向弹幕和半角偏移的延迟回声弹幕，强调识别双波节奏。
- Void Foundry Heart 新增 `Rift Cross`：冻结玩家当前位置，以四个方向生成向心线形预警，随后从四臂向交点释放交叉弹幕，强调及时离开交叉中心。

### 攻击循环与可读性
- `BossEnemy` 新增第二专属机制 id、前摇、弹量、半径、范围和使用次数配置；一阶段继续使用四槽循环，二阶段在第五槽执行第二专属机制。
- 三种预警分别写入 `warren_sweep`、`iron_quake`、`rift_cross` 语义用途，并缓存 Boss 来源 id/type，供音频、无障碍和死亡复盘继续扩展。
- 第二专属机制统一使用当前 Boss Atlas 的招牌技/阶段峰值帧，不增加碰撞体或改变现有伤害接口。
- Boss 伤害来源摘要新增第二机制 id 与显示名；HUD 一阶段显示原招牌技，进入二阶段后切换为第二专属机制名，阶段提示同步显示对应名称。

### 测试更新
- 新增 `BossPhaseTwoAttackSmokeTest`，验证三套机制配置、摘要、峰值帧、预警形状/数量/用途、来源身份、弹幕量和二阶段第五攻击槽路由。
- `ContentPipelineSmokeTest` 锁定三个 Biome Boss 与 `Warren Sweep`、`Iron Quake`、`Rift Cross` 的唯一配置关系，并要求可读前摇和有效弹幕参数。
- `BossSmokeTest` 新增最终 Boss 死亡复盘字段与 `Void Bloom → Rift Cross` HUD 标题切换断言。

### 验证状态
```text
Godot script import passed.
BossPhaseTwoAttackSmokeTest passed.
ContentPipelineSmokeTest passed.
BossSignatureSmokeTest passed.
BossActionAnimationSmokeTest passed.
BossSmokeTest passed. (22.0s final verified run)
UILayoutSmokeTest passed.
```

Godot 仍会输出项目既有的 `user://..` 目录创建警告；内容管线退出时仍有既有 RID/ObjectDB 释放告警，但通过运行的退出码为 0。

### 仍需人工复核
- 在实际 1280×720 战斗中确认 Warren Sweep 三线、Iron Quake 双波和 Rift Cross 四臂不会与房间机关或其他危险区叠加到不可读。
- 观察三种机制在不同移动速度、护甲和自动瞄准设置下的反应窗口，必要时分别调整前摇而不是统一缩短。
- 下一步优先补 Barrage Totem、Needle Skater 和六种精英修饰的专属视觉/动作表现，并继续补门框与边角装饰 Atlas。

## 2026-07-11 炮台/高速敌人独立 Atlas 与六类精英动态标识第一版

### 目标
- 消除 Barrage Totem、Needle Skater 复用机械射手外形的问题，让固定弹幕源与高速侧移单位可以从轮廓直接识别。
- 让六种精英修饰不再只依赖名称前缀、缩放和整体彩色，而是具备可叠加在任意普通敌人上的独立动态图形语言。

### 资产生成与处理
- 使用内置 ImageGen 生成两套原创 `1254×1254 / 2×2` 像素 Atlas；未使用外部 API Key 或 CLI 模型路径。
- Barrage Totem 提示集要求暗铁/紫瓷固定炮台，四帧依次为闭合待机、五炮口锁定、五连齐射峰值、开闸冷却；主体覆盖率约 28.9%。
- Needle Skater 提示集要求银钢/青色翼片轻型滑行构造体，四帧依次为滑行待机、侧倾瞄准、针刺开火、横向刹停；第一次生成的开火帧触及中央分隔线，定向缩短针尖和枪口闪光后重新生成，最终主体覆盖率约 8.0%。
- 两套素材均使用官方 `remove_chroma_key.py` 执行 Border 自动取色、Soft Matte、Despill 和强制透明输出；最终四角 alpha 均为 0，各格与中央边界至少保留 95px 空白，并已逐张视觉检查。
- 最终入库 `barrage_totem_action_atlas.png` 与 `needle_skater_action_atlas.png`，场景继续使用最近邻、`0.1` 缩放和约 62.7px 世界帧契约。

### 精英动态视觉
- `EliteModifierData` 新增 `visual_pattern`、`aura_radius`、`pulse_speed` 三项数据字段，六个资源分别配置唯一图形和动画速度。
- 新增无文字 `EliteAura`：Blazing 使用八向火舌，Bulwark 使用六边护板，Quickened 使用三道速度尾迹，Volatile 使用旋转爆破节点，Sharpshot 使用准星刻度，Titan 使用重型分段环。
- Aura 位于敌人主体后方并随敌人移动、旋转和缩放；可见 ActionSprite 使用 32% 精英调色混合，受击闪烁后仍恢复到精英色，而不是写入已隐藏 Polygon。
- 精英数值、攻击冷却、弹速、死亡爆炸、碰撞和掉落规则保持不变。

### 测试与稳定性
- 新增 `EliteVisualSmokeTest`，覆盖六个资源的唯一图形、半径、脉冲速度、重复几何、后置层级、Sprite 调色和动画相位推进。
- `EnemyActionAnimationSmokeTest` 新增两套 Atlas，并验证 Barrage Totem、Needle Skater 引用各自资源和完成四帧循环。
- `ContentPipelineSmokeTest` 要求六个精英资源使用唯一非默认图形，并具备有效半径与动画速度；`EnemyVarietySmokeTest` 在真实 Quickened 精英用例中验证速度尾迹语义。
- `CombatFeedbackSmokeTest` 将固定 `1.25s` 清理等待改为最多 `2.5s` 的真实状态条件等待；`AudioFeedback` 新增按 SFX id 的只读测试计数，移除并发音效下依赖“最后一个声音”的脆弱断言。

### 验证状态
```text
Godot PNG/script import passed.
EliteVisualSmokeTest passed.
EnemyActionAnimationSmokeTest passed.
ContentPipelineSmokeTest passed.
EnemyVarietySmokeTest passed. (64.9s)
CombatFeedbackSmokeTest passed twice consecutively. (14.8s / 15.1s)
AudioFeedbackSmokeTest passed. (14.2s)
```

Godot 仍会输出项目既有的 `user://..` 目录创建警告；内容管线退出时仍有既有 RID/ObjectDB 释放告警，但通过运行的退出码为 0。

### 仍需人工复核
- 在实际精英房中检查六种 Aura 与召唤、治疗、危险区和地形纹理同时出现时的层级清晰度，必要时降低 Aura 填充透明度。
- 比较固定炮台约 63px 的复杂内部细节与普通敌人的像素密度，避免缩放后炮口细节糊成单一紫色块。
- 下一步继续补三层门框/边角装饰 Atlas、原创采样 SFX 和更细的精英机制联动。

## 2026-07-11 六类精英机制差异第一版

### 目标
- 将六种精英修饰从视觉与数值差异扩展为可观察、可规避、可自动验收的战斗机制。
- 保持普通敌人基础职责、掉落链和精英动态标识不变，通过数据驱动特性叠加机制。

### 机制落地
- Blazing 新增周期性 `Scorch Pulse`，先显示火焰脉冲预警，再对范围内玩家造成伤害。
- Bulwark 新增 `Guarded Core`，降低实际承受伤害；Quickened 新增带前摇提示的周期性 `Overclock`。
- Volatile 在半血时进入一次性失稳状态；Sharpshot 在原攻击上追加两条弹道；Titan 获得更强击退抗性与接触压迫。
- 六个 `EliteModifierData` 资源分别配置唯一战斗特性 id，并保留已有 Aura 图形、调色和数值修饰。

### 测试与稳定性
- 新增 `EliteTraitSmokeTest`，覆盖六种特性配置、触发条件、伤害修正、弹道扩展、失稳状态和抗击退行为。
- 稳定 `EnemyVarietySmokeTest` 的炮手、召唤与支援单位状态推进，避免帧时序导致的偶发误判。
- 内容管线、精英视觉、敌人多样性和完整流程回归均通过。

### 验证状态
```text
EliteTraitSmokeTest passed.
ContentPipelineSmokeTest passed.
EliteVisualSmokeTest passed.
EnemyVarietySmokeTest passed. (76.0s)
FullRunSmokeTest passed. (375.2s)
```

Godot 仍会输出项目既有的 `user://..` 目录创建警告；内容管线退出时仍有既有 RID/ObjectDB 释放告警，但通过运行的退出码为 0。

## 2026-07-11 原创 authored SFX 资产管线第一版

### 目标
- 将战斗、角色状态、奖励、事件与 Boss 反馈从运行时程序化占位音调迁移到仓库内可版本化的原创 WAV。
- 保留未知键和资源缺失时的诊断回退，但正式内容事件不得静默依赖回退。

### 资产与管线
- 新增 54 个原创单声道 PCM WAV，覆盖七类武器、命中/暴击/击杀、生命与护甲、危险预警、敌人前摇、祝福/雕像、Boss 和结算反馈。
- `tools/generate_sfx_pack.py` 使用固定种子、振荡器、滤波噪声、包络和逐项参数可重复生成全部文件，不包含第三方录音或其他游戏音频。
- 全部样本为 `16-bit / 44.1 kHz`，时长 `0.10–0.78s`，54 个 SHA-256 均唯一；RMS 检查无静音，峰值 `28835`，无削波。
- 新增 `SfxLibrary`，统一维护正式事件键和 40 把武器自定义 `fire_sfx_key` 到七类武器样本的别名映射。

### 运行时与验收
- `AudioFeedback` 启动时加载全部 authored stream，并复用现有 16 声部上限、SFX bus 与清理队列；headless 模式同样验证资源解析而不访问音频设备。
- 程序化 `_play_tone` 降级为未知键/缺失资源的诊断回退，并暴露来源、解析 sample id、缺失列表和回退次数供测试检查。
- `AudioFeedbackSmokeTest` 锁定 54/54 样本加载、全部当前武器键映射、sidearm 路径解析和正式事件回退次数为 0。
- `ContentPipelineSmokeTest` 对每个武器自动要求非空 `fire_sfx_key`、有效 SFX 映射和可导入 WAV，后续新增武器遗漏音频会直接失败。

### 验证状态
```text
SFX generator deterministic hash check passed.
WAV format/silence/clipping/uniqueness QA passed. (54 files)
Godot WAV/script import passed.
AudioFeedbackSmokeTest passed. (14.8s final run)
AudioFeedbackSmokeTest passed with Windows display + Dummy audio driver. (13.3s)
ContentPipelineSmokeTest passed.
WeaponSmokeTest passed. (54.0s)
CombatFeedbackSmokeTest passed. (11.2s)
```

Godot 内容管线退出时仍会输出项目既有 RID/ObjectDB 释放告警，但通过运行的退出码为 0。正式音乐仍由运行时生成，保留为后续音频锁定任务。

### 仍需人工复核
- 使用实际扬声器/耳机比较七类武器、危险预警与低血量心跳在密集战斗中的响度层级，必要时在注册表增加每类 gain，而不是修改原始事件调用。
- 检查短时间 16 声部饱和时，Boss 前摇和低血量警告是否会被低优先级命中音挤出；后续可在 authored 播放层增加优先级与抢占规则。

## 2026-07-11 原创 authored 音乐与三层 Biome 接线第一版

### 目标
- 替换 `AudioStreamGenerator` 实时音乐，让菜单、三层战斗、Boss 与结算全部使用仓库内原创轨道。
- 激活已存在但未接线的 `BiomeData.music_key`，让三层主题不仅在地形、敌人与奖励上不同，也拥有独立听觉身份。

### 资产与播放层
- 新增 7 条原创立体声 PCM WAV：Menu、Outer Warrens、Iron Catacombs、Void Foundry、Boss、Victory、Defeat。
- `tools/generate_music_pack.py` 以不同 BPM、和声进行、旋律、节奏密度和固定种子生成全部轨道；音符包络在小节边界归零，循环轨道避免明显接缝。
- 全部文件为 `16-bit / 44.1 kHz stereo`，时长 `4.00–10.43s`，7 个 SHA-256 均唯一；峰值 `26869`，无静音或削波，循环边界最大跳变 `153/32767`。
- 新增 `MusicLibrary`，集中维护 7 条轨道、`combat` 兼容别名和菜单/三层/Boss 的循环策略。
- `AudioFeedback` 移除运行时音乐采样生成，改为两台 Music bus 播放器和 `0.45s` 交叉淡化；Victory/Defeat 保持单次播放。

### Biome 数据链
- `biome_music_key` 从 `BiomeData` 进入生成 metadata、Biome summary、房间 record、`CombatRoom` 实例与视觉摘要。
- 普通房间开始时按当前层的 music key 切换；Boss 房覆盖为 Boss 轨道，通关和失败继续使用独立结算轨道。
- 内容管线要求三层 music key 唯一、可映射且对应 WAV 可导入，避免后续主题层静默回退到通用音乐。

### 验证状态
```text
Music generator deterministic hash check passed.
Music WAV format/silence/clipping/uniqueness/loop-edge QA passed. (7 files)
Godot music/script import passed.
AudioFeedbackSmokeTest passed headless. (11.7s)
AudioFeedbackSmokeTest passed with Windows display + Dummy audio driver. (12.3s)
ContentPipelineSmokeTest passed.
DungeonGenerationSmokeTest passed. (52.6s)
SettingsSmokeTest passed. (9.9s)
```

内容管线退出时仍会输出项目既有 RID/ObjectDB 释放告警，但通过运行的退出码为 0。

### 仍需人工复核
- 使用耳机和扬声器完整听取 7 条轨道，确认三层主题辨识度、Boss 压力感、Victory/Defeat 收束感和长时间循环疲劳度。
- 在实际跑图中确认 `0.45s` 交叉淡化不会掩盖房间开战前摇，并对 Music/SFX bus 做最终响度平衡。

## 2026-07-11 三层 Biome 门框与边角装饰 Atlas 第一版

### 目标
- 为三层 Biome 增加独立门框、边角和门槛视觉，使房间差异不再只依赖地板、墙体与障碍纹理。
- 修正南北入口此前移除整段墙体形成 1260px 开口的问题，使视觉门框与实际碰撞通道一致。

### 资产与运行时
- 新增 Outer Warrens、Iron Catacombs、Void Foundry 三套原创 `512x512 / 2x2` SVG trim atlas，每套固定提供竖向门框、横向门框、边角和门槛四个区域。
- 新增 `BiomeRoomTrimVisual`，使用最近邻过滤和 Atlas region 绘制四角及当前房间已连接方向的门框/门槛；组件位置向房间内部收拢，避免 1280x720 视口裁切。
- `BiomeData` 新增 trim atlas 路径、调制色和透明度；`DungeonController` 将字段写入 metadata、Biome summary、房间记录和运行时房间配置。
- `CombatRoom` 新增独立 `BiomeTrimLayer`，并在运行时视觉摘要中暴露资源加载、过滤、区域和绘制数量，供回归测试检查。

### 门体几何修正
- 南北方向从原 1260px 整墙开口改为居中的 `170x42` 门洞。
- 门洞左右保留两段 `595x40` 墙体，并继续接入 Biome Surface Atlas 与静态碰撞；东西方向现有门体逻辑保持不变。

### 验证状态
```text
Godot SVG/script import passed.
ContentPipelineSmokeTest passed.
DungeonGenerationSmokeTest passed. (55.3s)
BiomeTrimSmokeTest passed headless. (screenshot skipped by design)
BiomeTrimSmokeTest passed with Windows/OpenGL. (contact sheet captured and inspected)
RoomFlowSmokeTest passed. (247s)
```

Windows/OpenGL 回归生成了三层 1920x360 联系表，已逐层检查门框、边角、门槛、视口裁切和房间完整性。内容管线退出时仍有项目既有 RID/ObjectDB 释放告警，但通过运行的退出码为 0。

### 仍需人工复核
- 在实际跑图和镜头切换中确认门框不会遮挡敌人、掉落物或交互提示，门洞宽度与玩家/召唤物通行手感一致。
- 在不同显示器和色觉条件下检查三层 trim 与墙体、危险预警的对比度，必要时只调整 Biome 调制色和透明度。

## 2026-07-11 遗物奖励来源保底与稀有度下限第一版

### 目标
- 在保留各来源独立掉落池、稀有度权重、单项 `drop_weight` 和 Biome 奖励倍率的基础上，限制连续低稀有度报价带来的 Build 成形失败。
- 将保底定义为“报价中至少出现一个 Rare+”，而不是自动授予高稀有遗物，继续保留玩家选择与路线取舍。

### 数据契约与运行时
- `RelicDropTableData` 新增 `minimum_rarity`、`pity_group`、`pity_misses_before_guarantee` 和 `pity_minimum_rarity`，每个来源可独立配置硬下限或共享保底组。
- 奖励房与普通宝箱加入 `relic_reward` 共享组：连续 3 组报价均未出现 Rare+ 后，下一组报价至少插入 1 个 Rare+，出现后计数归零。
- Premium Chest 与 Boss Chest 设置 Rare+ 硬下限；Shop 保持独立加权曲线，不推进、触发或重置普通奖励保底。
- `RelicSystem` 对单选和三选一统一按“整组报价”记账；三选一到期时只保证一个槽位，其余槽位继续使用原权重和去重规则。
- 新增来源摘要、共享 miss 计数、报价次数和最近报价诊断；`Main` 开始新 run 时显式清空保底状态。

### 测试与稳定性
- 新增 `RewardPacingSmokeTest`，使用 Rare 权重为 0 的极端表验证跨来源共享 miss、到期插入、报价去重、硬下限、Shop 隔离和 run reset。
- `RelicSmokeTest` 扩展为检查五类生产掉落表的保底组、阈值、硬下限和 Shop 隔离配置。
- `ShopSmokeTest` 将购买后 HUD 弹匣检查从单帧读取改为最多 20 帧的真实条件等待；原断言保留，消除信号调度造成的偶发假失败。

### 验证状态
```text
Godot script/scene import passed.
RewardPacingSmokeTest passed twice.
ContentPipelineSmokeTest passed.
RelicSmokeTest passed.
ChestSmokeTest passed.
ShopSmokeTest passed on unchanged retry, then passed twice after wait stabilization.
EventRoomSmokeTest passed.
DungeonGenerationSmokeTest passed.
FullRunSmokeTest passed. (combined broad-regression command: 316.6s)
```

内容管线与遗物回归退出时仍会输出项目既有 RID/ObjectDB 释放告警，但通过运行的退出码为 0。

### 仍需人工复核
- 通过多组完整 seed 跑图统计 Rare+ 首次暴露房间、每局 Rare/Epic/Legendary 报价数量和实际选择率，必要时调整阈值而不是提高所有高稀有权重。
- 观察普通奖励保底与 Boss/Premium 固定下限叠加后的 Build 强度，避免后期奖励过密导致选择失去区分度。

## 2026-07-12 可复玩 seed 奖励随机流第一版

### 目标
- 修复固定 dungeon seed 只能复现路线、布局和挑战变体，却无法复现商店、宝箱、事件与选择奖励的问题。
- 避免单一全局 RNG 的调用顺序耦合，让不同奖励来源使用稳定命名流；相同操作顺序下 Replay Seed 应复现同一组奖励结果。

### 命名随机流
- 新增纯函数 `RunSeedStreams.derive_seed(run_seed, stream_key)`，使用固定整数混合过程生成正数、非零、可重复的派生 seed。
- `DungeonController` 在每次生成前重置并播种 `relic_rewards`、`talent_rewards`、`blessing_rewards`、`statue_rewards` 四条中央流。
- 四个系统均支持在 `_ready()` 前预配置 seed，避免子节点生命周期中的 `randomize()` 覆盖；`reset_run()` 会清状态并回卷 RNG。
- `RelicSystem` 进一步按 reward/shop/normal_chest/premium_chest/boss_chest 拆分来源子流，普通宝箱抽取不会推进 Shop 遗物流；共享保底计数仍跨 reward 与 normal chest 生效。

### 房间级随机流
- 每个房间 record 新增 `reward_random_seed`，按 run seed 与稳定 `RoomXX` id 派生；运行时 `CombatRoom` 与奖励摘要保留同一字段。
- `CombatRoom` 在奖励实例入树前传递 seed；`EventShrine`、`RewardChest` 和 `ShopInventory` 只在未配置 seed 时随机化。
- Event 的随机变体/金币/诅咒武器、Chest 的掉落类型/金币/武器，以及 Shop 的武器库存均由房间流驱动；Shop 遗物由独立中央 shop 子流驱动。
- `DungeonController.get_run_random_stream_summary()` 暴露 run、系统和房间 seed，便于 Debug Map、自动测试与后续试玩问题复现。

### 测试与验收
- 新增 `SeededRewardSmokeTest`，覆盖纯派生稳定性、四系统 seed 唯一性、每房间 seed 唯一性、系统 reset 回卷、遗物来源隔离、Event/Chest/Shop 实际输出复现、同 seed 再生成一致和异 seed 差异。
- `DungeonGenerationSmokeTest` 扩展为校验系统流数量、房间流数量、record/runtime/summary 的 seed 一致性。

```text
Godot script/scene import passed.
SeededRewardSmokeTest passed twice.
RewardPacingSmokeTest passed.
RelicSmokeTest passed.
TalentSmokeTest passed.
EventRoomSmokeTest passed.
ChestSmokeTest passed.
ShopSmokeTest passed.
MenuFlowSmokeTest passed.
DungeonGenerationSmokeTest passed.
ContentPipelineSmokeTest passed.
FullRunSmokeTest passed. (combined content/full-run command: 265.6s)
```

内容管线和完整 Run 退出时仍有项目既有 RID/ObjectDB 释放告警，但通过运行的退出码为 0。

### 仍需人工复核
- 使用 Windows 构建对同一 seed 执行两次相同路线/交互顺序，记录三层商店、事件、宝箱和选择面板，确认玩家可观察结果一致。
- 当前契约是“同 seed + 同操作顺序”复现，不是录像系统；若未来要求跨操作顺序保持房间奖励完全独立，需要把中央选择流继续细分到 room/offer id。

## 2026-07-12 射击主线程卡顿修复

### 根因与修复
- 专项分段计时确认，弹丸实例化平均约 `0.115 ms`、枪口特效约 `0.013 ms`，均不是明显卡顿来源；真正热点是每次 `ammo_changed` 都让 HUD 重建整行武器槽，并重复解析图标注册表与加载三把武器图标，修复前平均阻塞约 `246 ms`。
- `HUD.update_ammo()` 改为只更新当前武器槽的弹药文字、提示与状态，不再为一次弹药变化重建全部槽位；纹理和静态提示内容按路径/武器身份缓存，保留换枪、装填和状态脉冲时的完整刷新能力。
- `AudioFeedback` 在实际音频模式启动时预建并循环复用 16 个 SFX 播放器，连续射击不再反复创建、挂接和释放 `AudioStreamPlayer` 节点。
- `Player` 每个物理帧只计算一次辅助瞄准结果，角色朝向、普通射击和蓄力释放复用同一目标，避免按住射击时重复遍历候选敌人。

### 性能与回归
- 新增 `FirePerformanceSmokeTest`，覆盖 96 次 authored 枪声、96 次完整射击、固定音效池容量和同步耗时上限。
- 同一 headless 基准中，完整开火从修复前平均约 `247 ms`、最大约 `271 ms`，降至平均 `0.368 ms`、最大 `0.608 ms`；弹药 HUD 同步从约 `246 ms` 降至约 `0.091 ms`。

```text
FirePerformanceSmokeTest passed. (audio max 0.171 ms, fire avg 0.368 ms, fire max 0.608 ms)
AudioFeedbackSmokeTest passed.
AimAssistSmokeTest passed.
CombatFeedbackSmokeTest passed.
WeaponSmokeTest passed.
ContentPipelineSmokeTest passed.
```

相关回归退出时仍可能输出项目既有 RID/ObjectDB 释放告警，但六项测试退出码均为 0。

### 仍需人工复核
- 在 Windows 构建中分别用手枪、霰弹枪和高射速武器持续射击，确认首发、连射、换弹完成和切枪后均无可感知停顿。
- 在敌人密集房间开启高强度辅助瞄准，确认同帧目标复用没有改变锁定方向与蓄力释放落点。

## 2026-07-12 中后程运行时卡顿第二轮修复

### 分段定位
- 新增 `RuntimePerformanceSmokeTest`，在完整 42 房间地牢上分别测量常驻 HUD、稳定拓扑小地图更新、未进入房间轮询和密集战斗文字生成。
- 角色被动 HUD 原本每帧重建 50 余字段摘要，并重复解析角色图标注册表与提示文本，headless 单次平均约 `54.715 ms`。
- 每次房间进入、开战、清理或领奖都会销毁并重建全部 42 个小地图标记及其容器、图标、Label 和 StyleBox，单次平均约 `1166.925 ms`。
- 64 个密集战斗文字同步创建约需 `10 ms`；42 个未进入房间的重叠轮询仅约 `0.022 ms/轮`，不是主尖峰，但属于无必要常驻物理工作。

### 优化实现
- 被动 HUD 的图标说明按图标/角色/提示内容缓存，动态剩余时间以 10 Hz 更新；护甲恢复状态保留逐帧刷新，避免“恢复中”提示延迟。
- 小地图仅在 dungeon 拓扑签名变化时重建；普通房间状态变化复用现有标记，只更新状态真正改变的旧/新当前房和目标房标记。
- 战斗文字预热 24 个节点、最多扩展至 48 个；达到上限时循环复用最早条目，结束后返回池中，不再持续创建和释放 Label 场景。
- `CombatRoom` 依赖 `body_entered` 与一次延迟初始重叠检查，关闭 42 个房间的常驻 `_physics_process` 轮询。

### 性能与回归
```text
RuntimePerformanceSmokeTest passed headless.
  passive HUD: 54.715 ms -> 0.033 ms
  minimap stable update: 1166.925 ms -> 0.119 ms
  combat text: 0.161 ms/item -> 0.080 ms/item, steady pool 0.047 ms/item
RuntimePerformanceSmokeTest passed Windows/OpenGL.
  passive HUD 0.044 ms, minimap 0.137 ms, steady combat text 0.043 ms/item
DungeonGenerationSmokeTest passed.
CombatFeedbackSmokeTest passed.
CharacterSmokeTest passed after preserving immediate Armor status refresh.
WeaponSmokeTest passed.
ContentPipelineSmokeTest passed.
MenuFlowSmokeTest passed. (12.6s)
RoomFlowSmokeTest passed. (65.6s; prior recorded run about 247s)
FullRunSmokeTest passed. (68.8s; prior recorded run 265.6s)
```

部分综合测试退出时仍可能输出项目既有 RID/ObjectDB 释放告警，但以上通过项退出码均为 0。

### 仍需人工复核
- 在 Windows 构建中连续完成多个房间，重点观察进入房间、开战、清房、奖励生成和领奖时的小地图更新是否仍有停顿。
- 使用范围伤害、连锁、霰弹和高射速武器制造密集命中，确认最多 48 条战斗文字的循环复用不会造成不可读的残影或过早替换。
- 进入三层不同 Biome 与 Boss 房，确认信号驱动入口不会漏触发初始波次、陷阱、挑战或 Boss 机制。

## 2026-07-12 简体中文运行时第一版

### 中文化范围
- 新增 `Localization` 自动加载节点并将正式游戏默认区域锁定为 `zh_CN`；代码符号、资源路径、内容 ID 与存档键保持英文，玩家界面统一显示中文。
- 完成 6 个角色、40 件武器、45 件遗物、3 项天赋、7 项祝福、3 座雕像、3 个 Biome、6 类精英词条、敌人、房间布局、宝箱、事件、HUD、大厅、设置、训练和结算文案翻译。
- 玩家工具提示不再暴露内部图标键；按键名 `WASD`、`LMB`、`Esc`、`Start` 保留标准写法，操作说明改为中文。

### 性能与测试
- 中文显示采用节点文本缓存的增量扫描，仅在文本、占位符或工具提示实际变化时重新翻译；双 UI 场景稳定扫描平均耗时从初版约 `14.507 ms` 降至约 `0.597 ms`。
- 新增 `ChineseLocalizationSmokeTest`，检查默认语言、全部内容资源字段、HUD/大厅动态文本、隐藏面板英文残留和 `<2.5 ms` 扫描性能门槛。
- 普通调试场景继续使用英文内部测试契约，正式主场景和中文专项测试启用中文，避免显示语言改动破坏与玩法无关的断言。

```text
ChineseLocalizationSmokeTest passed. (localization scan avg 0.597 ms; live Main/lobby audit passed)
ContentPipelineSmokeTest passed.
WeaponSmokeTest passed.
RelicSmokeTest passed.
LobbyScreenSmokeTest passed.
MenuFlowSmokeTest passed.
UILayoutSmokeTest passed.
RuntimePerformanceSmokeTest passed.
```

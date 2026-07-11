# Dungeon Unleashed 类元气骑士方向对齐记录

## 目标边界

本项目的目标是向《元气骑士》同类体验靠拢：俯视角、房间制、弹幕射击、随机地牢、武器/角色/天赋组合、宝箱/商店/Boss 推进。实现时只参考公开玩法结构，不复制《元气骑士》的角色名、美术、音效、关卡、剧情、数值表或专有表达。

## 在线检索到的核心参考点

公开资料显示，《元气骑士》是由凉屋游戏开发的 Roguelike 像素射击弹幕游戏，玩家使用角色、武器、角色技能和天赋战斗，躲避攻击并推进地牢目标。资料还提到游戏有随机场景、不同怪物、关卡 Boss、陷阱箱子、宝箱房间、商店，以及大厅/地窖/花园等战斗外场景。

参考来源：

- https://zh.wikipedia.org/wiki/%E5%85%83%E6%B0%94%E9%AA%91%E5%A3%AB

## 当前项目已具备的相似基础

- 俯视角 WASD 移动、鼠标瞄准射击。
- 房间进入、锁门、清敌、奖励、下一房推进。
- 多种敌人类型、精英/Boss 基础流程。
- 武器资源、弹丸、暴击、穿透、弹跳、散射。
- 遗物/掉落池/宝箱/商店/金币。
- HUD、死亡/胜利结算、基础音效与反馈。

## 当前主要差距

- 6 个原创角色、主动技能、可选弱辅助瞄准、辅助瞄准锁定权重、3 个主线 Boss 变体、Boss 后本局天赋、事件祝福、清房/击杀/受伤/雕像触发祝福、短时过载事件、雕像共鸣、局外图鉴/记录入口、永久货币、角色熟练度、角色消费解锁、极轻量熟练度加成、独立 Outpost Hall 大厅骨架、图鉴分页、角色详情文本页、武器/遗物/天赋/祝福/雕像详情文本页、Featured Card 文本详情卡、CodexDetailCard Control 详情卡、详情卡徽标/稀有度色条、CodexDetailCard 资源 icon_key 占位契约、图标色块/注册表、默认映射资源表、五类默认 SVG 图标、十二批高频条目/房间图标、角色选择图标贴图槽和 6 个角色专属 SVG、局内奖励/天赋/祝福/雕像三选一按钮图标、小地图房间 SVG 贴图 marker、当前武器槽注册表贴图、三武器负载预览注册表贴图、三槽负载预览槽框、三槽负载弹药摘要、三槽负载能量可用性提示、武器槽图标 ready/switch 脉冲、Build 路线筛选、图鉴搜索/排序/稀有度筛选、训练靶场布局、训练 drill 引导、训练目标类型、drill 完成目标、drill 评级、训练徽章记录、训练徽章 token 展示、训练奖励 toast 动画、死亡来源威胁情报、死亡来源反制 Build 标签和反制图鉴推荐已有第一版，但还缺少更大规模逐条目正式图标贴图素材、正式大厅视觉层级、更完整训练奖励演出、祝福/雕像/事件/角色的更深长期联动等深度。
- 武器池已达到 40 把，覆盖能量消耗、近战、近战挡弹、蓄力释放、Field/Mine/Sentry 部署、环形弹幕、爆炸、贯穿、弹跳、追踪、连锁、霰弹、中距离精准、暴击侧重、重型爆炸、高密度霰射、长距激光、传奇控场和燃烧/减速状态武器第一版；遗物池已达到 45 个，并具备弹跳、爆炸、击退、弹匣、能量、追踪和连锁专属 Build 参数。40 把武器和 45 个遗物都有条目级 64px SVG 图标并接入注册表、图鉴、奖励选择和 HUD 武器槽；近战扇形挥砍、Ammo 换弹完成脉冲、当前武器行换弹完成脉冲、独立武器槽状态条、弹匣分段、换弹中弹匣 sweep、武器槽位编号、三槽负载预览、弹药摘要和能量可用性提示、稀有度/类型短码、当前武器元数据详情行、稀有度色条、类型 token、能耗符号、能耗不足符号脉冲、稀有度边框、当前槽高亮、切槽脉冲、武器槽图标 ready/switch 脉冲和 `fire_sfx_key` 程序化差异开火音效已有轻量反馈；仍缺少正式像素 Atlas、正式音频资源、更完整武器槽图标动画、正式弹匣填装动画和更丰富的稀有度/掉落权重调优。
- HP/Armor 资源反馈已有受击后安全间隔逐点恢复、HUD 文本状态提示、恢复 HUD 脉冲、`hp_heal` / `low_health` / `low_health_heartbeat` / `low_health_recover` / `armor_gain` / `armor_block` / `armor_break` 程序化占位音效、玩家受击 HUD 闪屏、低血 HUD 提示、边缘低血 vignette、濒死强度脉冲、Armor 破裂 HUD 脉冲和专属浮字、共享低血严重程度模型、按 HP 严重程度同步变速的低血音画节奏、低血反馈强度设置、屏幕震动强度设置、受击闪屏强度设置和战斗浮字强度设置第一版，但还缺少正式音效、更完整动画反馈和数值调优。
- 三层地牢结构和 Biome 资源已有第一版，普通敌人池已扩到 18 个变体并达到 Alpha 下限，精英修饰池已有 6 种第一版；Biome 资源已开始驱动房间地板、墙体和障碍 tint 主题，让普通战斗、精英和挑战房优先使用每层独立布局池，将每层 `reward_weight_multiplier` 接入宝箱、商店、奖励房、事件房、遗物和祝福抽取，让 HUD 小地图按 Biome 层段展示，并让结算记录 seed、到达层、Boss 路线、生成路线签名和主要 Build 路线；Boss 弹幕、陷阱、区域危险、精英死亡爆炸、远程敌人弹道和冲锋敌人路线已有带轮廓/脉冲的基础预警，并已按默认、线形和重威胁拆出 `danger_warning` / `danger_warning_line` / `danger_warning_heavy` 程序化占位音效，但每层正式地形资产、Boss 专属机制、敌人动画、精英专属表现和更细的奖励曲线仍偏浅。
- 特殊房间已有武器房、治疗补给房、事件房随机结果池、短时过载事件、挑战房变体和陷阱房第一版，但还缺少更多事件结果、更多挑战规则和更完整的机关组合生态。
- 缺少宠物/随从、完整地图化大厅布局、更丰富的可消费永久成长，以及祝福与雕像/事件/角色的更深长期联动结构。

## 第一批已落地靠拢改动

### 资源循环

- 玩家新增 `Energy` 能量资源。
- `WeaponData` 新增 `energy_cost`，强力武器开火会消耗能量。
- 能量不足时武器不能开火，且不会消耗弹药或生成弹丸；当前已有 `Not Enough Energy` 消息、`NO ENERGY` 浮字、Energy 栏 `Need N` 状态反馈、Energy 行短促亮色脉冲、Weapon Slot 能耗符号脉冲和 `energy_empty` 程序化占位空响。
- 能量会在短暂延迟后自动恢复，用于第一版手感测试。
- 玩家 `Shield` 在 UI 中表现为 `Armor`，开局满值，优先吸收伤害。
- Armor 受击后进入恢复延迟，安全间隔后逐点恢复。

### 保留的现有系统

- 仍保留弹匣/换弹机制，当前阶段将其作为本项目差异化节奏，而不是一次性移除。
- `current_shield` 等内部字段暂时保留，避免破坏遗物、结算和已有测试。

## 第二批已落地靠拢改动

### 角色差异与主动技能

- 新增 `PlayerCharacterData` 角色资源，用数据配置角色名称、说明、生命、护甲、能量、移动速度、技能名、技能说明、冷却、持续时间、能量消耗和技能强度。
- 新增 3 个原创占位角色：`Wanderer`、`Warden`、`Arcanist`，分别覆盖均衡、重甲防守、能量射速三种战斗风格。
- 主菜单新增角色切换按钮，开局前可以切换角色；进入 run 后锁定角色，避免战斗中随意切换破坏单局构筑。
- 新增 `skill` 输入动作，默认 `Space`，角色主动技能在 HUD 中显示 Ready、Active 和 CD 状态。
- 技能冷却中重复使用会显示冷却提示、`SKILL CD` 浮字、Skill 行短促橙色脉冲和 `skill_fail` 占位音效；冷却结束回到 Ready 时 Skill 行会短促绿色脉冲并播放 `skill_ready` 占位音效，避免主动技能状态变化不明显。
- `Wanderer` 技能提供短暂无敌和移速爆发；`Warden` 技能恢复护甲并获得短暂防护；`Arcanist` 技能恢复能量并临时提高射速。
- 结算摘要新增本局角色字段，后续可作为角色胜率、解锁、成就和局外成长的统计入口。

## 第三批已落地靠拢改动

### 武器形态扩展

- `WeaponData` 新增 `fire_mode`，当前支持 `projectile`、`radial`、`melee` 三种开火形态。
- 普通弹丸继续复用穿透、弹跳、爆炸半径、暴击、能量消耗和弹匣配置。
- 环形弹幕武器会围绕玩家发射一圈弹丸，用于处理包围和近距离压力。
- 近战武器使用扇形即时命中，不生成弹丸，并生成轻量扇形挥砍闪光，可作为低消耗自保选项。
- 新增 4 个原创武器资源：`Arc Blade`、`Nova Core`、`Blast Launcher`、`Laser Lance`。
- 宝箱和商店武器池已加入这些新武器，让单局中能出现近战、环形、爆炸、贯穿等不同打法。

## 第四批已落地靠拢改动

### 特殊房间与补给节奏

- 地牢路线从 10-14 房间扩展为 12-15 房间：主路径仍为 7-9 个节点，分支提高到 5-6 个节点。
- 新增 `armory` 武器房，使用独立 `WeaponChest`，打开后从当前武器池中提供一把可替换武器。
- 新增 `healing` 治疗补给房，使用独立 `HealingChest`，打开后恢复生命值但不提供额外金币，避免破坏商店前经济约束。
- HUD 小地图新增 `A` 和 `H` 标记，分别表示武器房和治疗补给房。
- `DungeonGenerationSmokeTest`、`EnemyVarietySmokeTest`、`ChestSmokeTest`、`BalanceSmokeTest` 和 `FullRunSmokeTest` 已覆盖新房间生成、无敌人、宝箱功能、经济不变量和完整路线通关。

## 第五批已落地靠拢改动

### 内容管线元数据

- `WeaponData` 补充稀有度、武器分类、推荐距离、掉落权重、解锁 ID、内容定位、辅助瞄准权重、图标 key、音效 key 和弹道表现 key；其中 `fire_sfx_key` 已接入 `AudioFeedback` 的运行时开火音效分流。
- `RelicData` 补充触发事件、掉落权重、解锁 ID、描述数值模板、Build 标签和互斥标签。
- `PlayerCharacterData` 补充排序、解锁条件、初始武器 ID、被动 ID、被动说明、大厅摘要、角色定位标签和升级槽数量。
- 新增 `RunGraphData`、`BiomeData`、`UnlockData`、`TalentData` 和 `AimAssistController`，作为后续三层地牢、主题层、局外解锁、本局天赋和辅助瞄准的接口基础。
- 新增 `ContentPipelineSmokeTest`，校验现有角色、武器、遗物资源是否具备后续扩内容所需的最小元数据。

## 第六批已落地靠拢改动

### 三层 RunGraph 与主题层

- 新增 `outer_warrens`、`iron_catacombs`、`void_foundry` 三个 `BiomeData` 主题层资源，并用 `standard_three_biome_run` 组成标准三层路线。
- `DungeonController` 默认生成 3 个连续 biome，每层 7-9 个主线房间、6 个分支房间，总路线约 39-45 个房间。
- 每层保留 start、combat、elite、shop、armory、healing、reward、boss 等房间生态；各 biome 可配置不同敌人池和 Boss 场景。
- 中间 biome 的 Boss 奖励宝箱只作为层尾奖励，不触发通关；只有最终 biome 的 Boss 奖励宝箱会进入 Victory 结算。
- 房间记录、Debug Map 和 HUD 小地图补充 `run_graph_id`、`biome_index`、`biome_id`、`biome_name`、最终 Boss 标记和分层标签。
- 结算摘要新增已到达 biome、总 biome 数、击败 Boss 数和历史最佳 biome，便于后续扩展多层失败/胜利统计。
- `DungeonGenerationSmokeTest`、`FullRunSmokeTest` 和 `BalanceSmokeTest` 已升级为三层路线契约，覆盖连接图、分层元数据、中间 Boss 不结算、最终 Boss 结算和第一商店经济窗口。

## 第七批已落地靠拢改动

### 事件房第一版

- 新增 `event` 房间类型和 `event_room.tres`，每个 biome 的分支池会生成一个事件房。
- 新增 `EventShrine` 场景和脚本，当前事件为原创 `Blood Pact`：玩家靠近后必须按 `E` 触发，消耗 1 点生命，获得金币和一次奖励选择；最新版本优先给事件祝福，没有可用祝福时回退为遗物选择。
- `Player` 新增 `sacrifice_health()`，事件房生命代价会绕过护甲，避免被当前 Armor 资源抵消风险。
- `Events` 和 `Main` 新增事件完成统计，结算面板会显示本局完成事件数。
- 小地图新增 `!` 标记和事件房颜色，Debug/生成记录会把事件房作为特殊分支房记录。
- 新增 `EventRoomSmokeTest`，并扩展地牢生成、完整通关、敌人多样性、房间流和结算统计测试，覆盖触碰不触发、生命不足拒绝、事件房不刷敌、三层路线每层一个事件房、完整通关中事件计数进入结算。

## 第八批已落地靠拢改动

### 挑战房第一版
- 新增 `challenge` 房间类型和 `challenge_room.tres`，定位为更高风险、更高收益的可选分支房。
- 标准 RunGraph 仍保持每层 5-6 个分支；当某个 biome 生成第 6 个分支时，优先放入挑战房，避免为了新房型强行拉长单局。
- 挑战房复用现有战斗房运行时，但配置为两波 `4/6` 敌人、精英化敌人倍率、门锁战斗和高级宝箱奖励。
- 挑战房继承当前 biome 的敌人池，使三层主题敌人差异能自然作用到挑战分支。
- 小地图新增 `T` 标记和挑战房颜色；Debug Map、房间记录、清房金币和完整通关测试均能识别 `challenge`。
- 新增 `ChallengeRoomSmokeTest`，并扩展内容管线、完整通关和平衡测试，覆盖挑战房资源声明、战斗流程、精英敌人、高级宝箱、金币节奏和通用房间状态。

## 第九批已落地靠拢改动

### Boss 后本局天赋第一版
- 新增 `TalentSystem` 和 3 个 `TalentData` 资源，当前覆盖射速、伤害和生命上限三条基础 Build 方向。
- 非最终 biome 的 Boss 宝箱打开后会触发 3 选 1 天赋；最终 Boss 宝箱仍直接进入通关结算，避免胜利后多余选择。
- 天赋效果复用玩家已有的被动加成接口，能真实影响后续战斗数值，而不是只进入 UI 文本。
- HUD 复用当前 3 选 1 面板显示 `Choose a Talent`，并在结算 Build 分组记录 Talents 列表。
- 新增 `TalentSmokeTest`，并扩展内容管线、完整通关、房间流、结算和平衡测试，覆盖天赋资源、选择流程、属性变化、结算字段和最终 Boss 不再给额外天赋。

## 第十批已落地靠拢改动

### 局外大厅图鉴/记录入口第一版
- 主菜单新增 `Archive / Records` 入口，作为独立大厅场景完成前的第一版局外大厅入口。
- `Main.get_hall_summary()` 会汇总历史记录、角色、武器、遗物和天赋资源，后续可继续接入解锁状态、发现状态和永久成长。
- HUD 新增 `Hall Archive` 面板，展示运行记录、角色技能/属性、武器类型/能量消耗、遗物 Build 标签和天赋摘要。
- Hall Archive 面板纳入响应式大面板约束，打开时会隐藏输入提示，关闭后回到主菜单。
- 新增 `HallArchiveSmokeTest`，覆盖资源池计数、面板显示、主菜单返回和历史记录持久化读回。

## 第十一批已落地靠拢改动

### 局外永久货币与角色熟练度第一版
- 新增 `Data Shards` 作为局外永久货币，结算时根据到达层数、清房、击杀、Boss 和胜利状态发放，不进入局内金币循环。
- `Main.gd` 将永久货币、累计获得量、角色熟练度 XP 和角色解锁标记保存到 `user://settings.cfg` 的独立分组。
- `PlayerCharacterData` 新增角色解锁成本和熟练度等级阈值字段；现有 3 个角色仍默认解锁，避免破坏当前角色切换流程。
- Hall Archive 新增 Meta Progress 区域，并在角色列表显示 Unlocked、Mastery 等级和 XP。
- 结算 Record 分组显示本局获得的 Data Shards 和角色熟练度 XP。
- 新增/扩展烟测覆盖永久货币持久化、熟练度持久化、局内金币隔离、结算显示和内容管线字段完整性。

## 第十二批已落地靠拢改动

### 角色解锁消费 UI 与第四个原创角色
- 新增第 4 个原创角色 `Rift Runner`，定位为高速低护甲机动型角色，使用 `Rift Step` 短突进技能，解锁成本为 10 Data Shards。
- 主菜单角色切换现在可以预览锁定角色，但锁定角色会禁用 `Start`，并在尝试开始时提示先解锁。
- HUD 在主菜单新增 `Unlock Character` 消费按钮，永久货币足够时可直接解锁当前锁定角色；解锁后按钮变为 `Unlocked`，`Start` 重新可用。
- `Main.get_character_selection_summary()` 现在暴露当前角色的 `unlocked`、`unlock_cost` 和 `meta_currency`，便于后续独立大厅、训练房和角色详情 UI 复用。
- `HallArchiveSmokeTest` 扩展为覆盖锁定显示、货币不足拦截、胜利获得 Data Shards、消费解锁、持久化标记和解锁后可开局。

## 第十三批已落地靠拢改动

### 训练房入口第一版
- 主菜单新增 `Training Room` 入口，作为独立大厅场景完成前的第一版练习入口。
- `Main.gd` 新增 `Training` 运行状态；训练中可以暂停并恢复到 Training，不会被误恢复成正式 Run。
- 训练入口复用当前起始房和已选角色，用于练习移动、开火、技能、能量消耗和基础敌人处理。
- 训练中触发 `run_completed` 不会进入 Victory 结算，也不会写入历史记录、Data Shards 或角色熟练度，避免污染正式进度。
- 锁定角色不能进入训练房，训练按钮会随角色解锁状态禁用或恢复。
- 新增 `Training Dummy` 假人场景、训练伤害统计面板和 `Reset Training` 按钮；训练面板会显示命中次数、累计伤害和最高单次伤害。

## 第十四批已落地靠拢改动

### 角色熟练度轻量加成
- 角色熟练度现在不只记录 XP：L2 提供 `+1 Energy`，L3 额外提供 `+1 Armor`，作为极低膨胀的长期成长第一版。
- 加成由 `Main.gd` 根据存档中的 mastery 等级应用到当前角色，不写回角色资源，避免污染基础数据。
- 主菜单角色说明会在 L2+ 显示当前 Mastery 等级和加成；Hall Archive 角色列表会显示 `Bonus` 字段。
- `get_meta_progression_summary()` 现在包含 `character_mastery_bonuses`，供后续独立大厅角色详情页复用。
- 新增 `MasteryBonusSmokeTest`，覆盖多局结算升级、持久化重载、属性应用、主菜单显示和 Hall Archive 显示。

## 第十五批已落地靠拢改动

### 独立 Outpost Hall 大厅骨架
- 新增 `LobbyScreen.tscn` 和 `LobbyScreen.gd`，把原本动态拼在 HUD 内的 Hall Archive 迁入独立大厅场景骨架。
- Outpost Hall 现在有独立状态区、快速统计、档案滚动区，以及 `Start Run`、`Training`、`Settings`、`Back` 四个动作入口。
- HUD 保留 `open_hall_menu()`、`get_hall_summary_text()` 等旧接口，但实际通过 `LobbyScreen` 显示，降低后续角色详情页和分页图鉴接入成本。
- 锁定角色会同步禁用 Outpost Hall 内的开局和训练入口，避免大厅入口绕过角色解锁规则。
- 新增 `LobbyScreenSmokeTest`，覆盖大厅场景实例化、档案显示、锁定角色禁用、从大厅进入设置、训练房和正式 Run。

## 第十六批已落地靠拢改动

### Outpost Hall 分页与角色操作
- Outpost Hall 新增 `All`、`Records`、`Chars`、`Weapons`、`Relics`、`Talents` 分页，开始把原长文本档案拆成可浏览图鉴入口。
- Outpost Hall 内新增 `Previous`、`Next` 和 `Unlock` 按钮，玩家可以直接在大厅里切换角色、查看锁定状态并消费 Data Shards 解锁角色。
- `Main.gd` 新增 `refresh_hall_menu()`，大厅内切换或解锁角色后会刷新当前摘要，避免图鉴和货币状态滞后。
- `HUD.gd` 新增大厅分页、当前角色和解锁按钮状态的测试读接口，方便后续继续扩展角色详情页。
- `LobbyScreenSmokeTest` 扩展为覆盖分页切换、分页内容隔离、大厅内角色切换、货币不足禁用解锁、真实结算获得 Data Shards 后在大厅内解锁角色。

## 第十七批已落地靠拢改动

### Chars 页角色详情与成长预览
- `Main.get_hall_summary()` 的角色摘要现在包含大厅摘要、初始武器、被动说明、技能参数、升级槽、下一熟练度等级、所需 XP、剩余 XP 和下一奖励。
- `Chars` 页保留原有角色列表首行，同时追加角色用途、初始武器、被动特性、技能消耗/冷却/持续、下一熟练度奖励和升级槽。
- 当前选中角色会在 `Chars` 页标记 `Selected`，让大厅内角色切换和详情预览可以对应起来。
- 下一熟练度奖励使用增量奖励展示，例如 L1 -> L2 只显示 `+1 Energy`，避免玩家误读成累计属性。
- `LobbyScreenSmokeTest` 扩展为覆盖初始武器、被动、下一熟练度 XP、下一奖励和升级槽显示。

## 第十八批已落地靠拢改动

### 角色熟练度进度预览
- `Main.get_hall_summary()` 的角色摘要新增当前熟练度段的起点、已完成 XP、目标 XP 和百分比。
- `Chars` 页新增 `Mastery Progress` 文本进度条，例如 `[------------] 0/40 XP to L2 (0%)`。
- `Chars` 页新增 `Mastery Rewards` 对比，明确显示当前奖励和下一奖励；满级时显示 `Maxed`。
- `LobbyScreenSmokeTest` 扩展为覆盖未升级进度条、当前/下一奖励对比、四局后 L3 满级状态和满级下一奖励显示。

## 第十九批已落地靠拢改动

### 图鉴详情与 Build 路线摘要
- `Main.get_hall_summary()` 的武器摘要新增掉落权重、内容定位、伤害、射速、多弹丸、散射、开火模式、弹匣、换弹、暴击、贯穿、弹跳和爆炸半径等详情字段。
- `Main.get_hall_summary()` 的遗物和天赋摘要新增效果数值、持续时间、掉落权重、堆叠上限和互斥标签等字段，作为后续详情卡与筛选 UI 的数据入口。
- `Weapons`、`Relics`、`Talents` 页新增 `Build Routes` 汇总，按标签统计当前内容池能支持的构筑方向。
- 武器页追加 `Stats` 和 `Traits` 详情行；遗物页追加 `Effect` 与 `Stacking` 详情行；天赋页追加 `Effect` 与 `Conflicts` 详情行。
- `LobbyScreenSmokeTest` 扩展为覆盖武器、遗物、天赋分页的 Build 路线摘要和详情字段显示。

## 第二十批已落地靠拢改动

### 图鉴 Build 路线筛选
- `LobbyScreen.tscn` 新增 `CodexFilterRow`，在 `Weapons`、`Relics`、`Talents` 分页显示当前 Build 路线筛选状态。
- `LobbyScreen.gd` 新增按标签筛选的第一版图鉴逻辑：武器按 `tags` 筛选，遗物和天赋按 `build_tags` 筛选。
- 图鉴详情文本会显示当前 `Filter` 和已显示数量，例如 `Filter: Close Range (2/8 shown)`，便于后续替换为正式详情卡。
- 筛选状态按分页独立保存，`All` 总览页和 `Chars`/`Records` 页不受图鉴筛选影响。
- `LobbyScreenSmokeTest` 已补充筛选断言，覆盖武器 close_range、遗物 projectile 和天赋 survival 三条路线。

## 第二十一批已落地靠拢改动

### Vertical Slice 2 内容池扩容第一步
- 武器池从 8 把扩到 12 把，新增原创武器 `Coil Carbine`、`Shatter Fan`、`Rift Spear` 和 `Orbit Sower`。
- 新增武器全部复用现有 `WeaponData` 字段和既有开火模式，分别补充精准弹跳、近距霰射、长距近战突刺和环形控场方向。
- 遗物池从 10 个扩到 18 个，新增 `Keen Sights`、`Hollow Needle`、`Scatter Lens`、`Field Rations`、`Bulwark Plate`、`Redline Boots`、`Breach Powder` 和 `Momentum Coil`。
- 新遗物使用现有遗物效果类型，覆盖暴击、贯穿、多弹丸、击杀回血、清房护甲、受伤加速、伤害和射速路线，不引入额外效果代码。
- `RewardChest`、`ShopInventory`、Boss 宝箱和 5 个遗物掉落表已接入新内容；`ContentPipelineSmokeTest` 和 `HallArchiveSmokeTest` 的数量门槛提升到 12 武器 / 18 遗物。

## 第二十二批已落地靠拢改动

### 角色池扩展到 6 个
- 角色池从 4 个扩到 6 个，新增原创角色 `Emberwright` 和 `Field Medic`，补齐 Vertical Slice 2 / Alpha 之间的 6 角色目标。
- `PlayerCharacterData` 的技能 ID 增加 `overdrive` 和 `stabilize` 两类轻量技能。
- `Emberwright` 使用 `Overdrive Spark`，短时间提高武器伤害和射速，定位为爆发输出角色。
- `Field Medic` 使用 `Stabilize`，恢复生命和护甲，定位为长路线稳定性角色。
- `Player.gd` 的角色池、技能效果分支、`CharacterSmokeTest`、`ContentPipelineSmokeTest` 和 `HallArchiveSmokeTest` 已同步到 6 角色契约。

## 第二十三批已落地靠拢改动

### 三层 Boss 变体第一版
- 三层地牢从复用单一 `Dungeon Core` Boss，推进为每个 biome 使用独立 Boss 场景。
- Outer Warrens 使用 `Warrens Gatekeeper`，定位为第一层读招压力较低的追击/弹幕混合 Boss。
- Iron Catacombs 使用 `Iron Bulwark`，定位为高血量、低移动、召唤护盾敌人的站位压力 Boss。
- Void Foundry 使用 `Void Foundry Heart`，定位为最终层高弹幕密度和更高生命值 Boss。
- 三个 Boss 仍复用 `BossEnemy.gd` 的基础二阶段、预警、召唤和奖励流程，但通过独立场景参数和视觉颜色拉开层级差异。
- `DungeonController`、`ContentPipelineSmokeTest`、`DungeonGenerationSmokeTest`、`EnemyVarietySmokeTest` 和 `BossSmokeTest` 已同步到 3 Boss 契约。

## 第二十四批已落地靠拢改动

### 陷阱房第一版
- 新增 `trap` 房间类型和 `trap_room.tres`，作为特殊分支房补齐第一版机关压力。
- 陷阱房进入后会锁门、启动地面危险预警循环，玩家存活计时结束后清房并生成普通宝箱。
- 当前每层固定 6 个分支，第 6 个分支在挑战房和陷阱房之间按 biome 交替，保持单局仍在 39-45 房间范围内。
- HUD 小地图新增 `X` 标记和 trap 未探索颜色；Debug Map 和房间记录能识别 `trap`。
- 新增 `TrapRoomSmokeTest`，并扩展地牢生成、敌人多样性、房间流、完整通关、平衡和内容管线测试契约。

## 第二十五批已落地靠拢改动

### 事件祝福第一版
- 新增 `BlessingData` 和 `BlessingSystem`，把祝福从规划接口推进为本局可获得的奖励系统。
- 新增 3 个原创事件祝福：`Deep Cell` 增加能量上限、`Quiet Plate` 增加护甲上限、`Ember Tithe` 提高武器伤害。
- `Blood Pact` 事件房现在优先提供 3 选 1 祝福，形成“献祭生命 -> 金币 + 本局规则增益”的事件回报；没有可用祝福时保留遗物选择回退。
- HUD 三选一面板支持 `Choose a Blessing`，结算 Build 分组记录 Blessings，完整通关摘要记录 `blessing_count` 和 `blessing_names`。
- Outpost Hall 新增 `Blessings` 图鉴分页，显示 Build Routes、Effect、Rule 和按 Build 标签筛选。
- `ContentPipelineSmokeTest`、`EventRoomSmokeTest`、`FullRunSmokeTest`、`RunSummarySmokeTest`、`HallArchiveSmokeTest` 和 `LobbyScreenSmokeTest` 已同步到祝福契约。

## 第二十六批已落地靠拢改动

### 可选弱辅助瞄准接入
- `AimAssistController` 从内容管线接口推进为玩家射击链路的一部分；默认关闭，不改变现有键鼠瞄准手感。
- `Player.gd` 现在会在辅助瞄准开启时，从 `enemies` 分组中筛选距离、角度和存活状态合格的目标，并把射击目标点弱混合到候选敌人方向。
- 实际辅助强度会按当前武器的 `aim_assist_priority` 缩放，方便让精准武器、爆炸武器、近战和控场武器有不同吸附感。
- Settings 面板新增 `Aim Assist` 开关和 `Aim Assist Strength` 滑条，设置保存到 `user://settings.cfg` 的 `gameplay` 分组。
- `Main.gd` 负责加载、应用、保存辅助瞄准设置，并在开局和设置变更时同步到玩家。
- `SettingsSmokeTest` 已覆盖默认值、应用、持久化、重载和玩家同步；新增 `AimAssistSmokeTest` 覆盖关闭状态、候选目标选择和角度过滤。

## 第二十七批已落地靠拢改动

### 第二批普通敌人变体
- 普通敌人池从 6 个基础行为扩展为 12 个场景变体，新增 `Rust Skirmisher`、`Ember Marksman`、`Iron Breaker`、`Volatile Vessel`、`Aegis Drone` 和 `Rift Caller`。
- 新敌人不新增行为分支，而是复用追踪、远程、冲锋、自爆、召唤和护盾 6 类行为，通过血量、速度、攻击间隔、射程、爆炸半径、护盾参数和召唤对象拉开战斗职责。
- `outer_warrens` 的敌人池扩到 5 个，加入快速近战和较快远程压力；`iron_catacombs` 扩到 7 个，加入重型冲锋和强化护盾敌人；`void_foundry` 扩到 8 个，加入更危险的自爆、远程和召唤组合。
- `DungeonController` 的敌人名称解析改为实例化场景读取 `display_name`，后续继续新增敌人时不需要同步维护硬编码映射。
- `ContentPipelineSmokeTest` 新增普通敌人场景库检查，覆盖显示名唯一性、基础数值、行为类型、远程弹丸、自爆半径、召唤场景和 biome 敌人池差异。
- `EnemyVarietySmokeTest` 已扩展到验证三层 biome 敌人池包含新变体，避免后续地牢生成回退到单一基础敌人组合。

## 第二十八批已落地靠拢改动

### Alpha 下限普通敌人池
- 普通敌人池从 12 个变体扩展到 18 个变体，达到方案中 Alpha 目标的 `18-24` 普通敌人下限。
- `Enemy.gd` 新增可复用的敌人能力：散射弹配置、死亡生成小怪、环绕射击移动、区域危险预警和支援治疗。
- 新增 `Needle Skater`：环绕玩家移动并射击，用于打破直线追击/远程站桩节奏。
- 新增 `Soot Splitter`：死亡后生成 `Rust Skirmisher`，补充死亡惩罚和清场优先级。
- 新增 `Mire Conduit`：在玩家位置生成可读危险圈，作为中层地形压制敌人。
- 新增 `Grave Mender`：周期性治疗附近受伤敌人，补充支援/优先击杀职责。
- 新增 `Barrage Totem`：低机动散射弹幕源，增加 Void Foundry 的弹幕压力。
- 新增 `Null Acolyte`：更高伤害、更大范围的终层区域压制敌人。
- 三层 biome 敌人池分别扩展到 7 / 9 / 11 个敌人，并在 `ContentPipelineSmokeTest` 和 `EnemyVarietySmokeTest` 中加入数量、池配置和新行为回归。

## 第二十九批已落地靠拢改动

### Alpha 下限精英修饰池
- 新增 `EliteModifierData`，把精英修饰从单一房间倍率推进为可扩展资源池。
- 新增 6 个精英修饰资源：`Blazing`、`Bulwark`、`Quickened`、`Volatile`、`Sharpshot` 和 `Titan`，达到方案中 Alpha 目标的 `6-9` 精英修饰下限。
- 每个精英修饰配置独立的显示前缀、说明、职责标签、血量倍率、伤害倍率、移速倍率、攻击间隔倍率、弹速倍率、死亡爆炸、颜色和缩放。
- `CombatRoom` 会在精英房和挑战房中轮换 `elite_modifier_profiles`，让同一房间内出现不同精英压力，而不再只生成同一种 `Elite`。
- `DungeonController` 的导出 fallback 也接入标准精英修饰池，避免 Windows 导出时自定义房间资源字段读取不稳定导致精英修饰退回单一倍率。
- `ContentPipelineSmokeTest`、`EnemyVarietySmokeTest` 和 `ChallengeRoomSmokeTest` 已覆盖精英修饰资源完整性、运行时应用、房间轮换和挑战房接入。

## 第三十批已落地靠拢改动

### Alpha 内容池扩容第二步
- 武器池从 12 把扩到 18 把，新增原创武器 `Pulse Needler`、`Cinder Mortar`、`Mirror Sickle`、`Storm Fan`、`Prism Ray` 和 `Halo Kernel`。
- 新武器继续复用现有 `WeaponData` 字段和 `projectile` / `melee` / `radial` 开火模式，补充精准暴击、重型爆炸、宽弧近战、高密度霰弹、长距贯穿激光和传奇环形控场方向。
- 遗物池从 18 个扩到 24 个，新增 `Steady Capacitor`、`Gilded Tip`、`Echo Chamber`、`Breakwater Guard`、`Siphon Clasp` 和 `Kinetic Ram`。
- 新遗物仍只使用现有遗物效果类型，覆盖射速、暴击、多弹丸、清房护甲、击杀回血和伤害路线，不引入额外效果代码。
- `RewardChest`、`ShopInventory`、Boss 宝箱和 5 个遗物掉落表已接入第二批新内容；`ContentPipelineSmokeTest` 和 `HallArchiveSmokeTest` 的数量门槛提升到 18 武器 / 24 遗物。

## 第三十一批已落地靠拢改动

### 元素状态武器链路第一版
- `WeaponData` 新增轻量状态字段，当前支持 `burn` 和 `slow` 两类原创状态效果。
- `Projectile.gd`、`Weapon.gd` 和 `Enemy.gd` 已形成完整命中链路：弹丸直击、爆炸溅射和近战扫击都可以给敌人挂状态；燃烧按 tick 造成持续伤害，减速会降低敌人行为移动速度。
- 武器池从 18 把扩到 21 把，新增原创武器 `Ember Sprayer`、`Frost Sickle` 和 `Slag Comet`，分别补充近距燃烧散射、近战减速和爆炸燃烧收益。
- 遗物池从 24 个扩到 27 个，新增 `Volatile Oil`、`Ember Catalyst` 和 `Lingering Ash`，分别强化状态概率、状态伤害和状态持续时间。
- `RewardChest`、`ShopInventory`、Boss 宝箱、`RelicSystem.available_relics` 和 5 个遗物掉落表已接入状态内容。
- Outpost Hall 武器详情页会展示状态字段，图鉴筛选可以通过 `elemental` 和 `status` 路线找到新增状态武器/遗物。
- `ContentPipelineSmokeTest`、`WeaponSmokeTest`、`RelicSmokeTest`、`HallArchiveSmokeTest` 和 `LobbyScreenSmokeTest` 已同步到 21 武器 / 27 遗物和 burn/slow 状态契约。

## 第三十二批已落地靠拢改动

### 近战挡弹武器链路第一版
- `WeaponData` 新增 `blocks_projectiles`、`projectile_block_radius`、`projectile_block_arc_degrees` 和 `projectile_block_damage`，让近战挡弹可以按武器资源配置。
- `Weapon.gd` 的近战扫击已接入 `enemy_projectiles` 分组：只清除挡弹半径和前方角度内的敌方弹丸，并可对被挡弹丸附近敌人造成反制伤害。
- 武器池从 21 把扩到 24 把，新增原创武器 `Guard Cleaver`、`Riposte Saber` 和 `Bulwark Fan`，分别补充基础防守近战、窄角反制和宽角防守路线。
- 遗物池从 27 个扩到 30 个，新增 `Parry Grip`、`Warding Hinge` 和 `Counterweight Core`，分别强化挡弹半径、挡弹角度和挡弹反制伤害。
- `RewardChest`、`ShopInventory`、Boss 宝箱、`RelicSystem.available_relics` 和 5 个遗物掉落表已接入挡弹内容。
- Outpost Hall 武器详情页会展示 `Guard` 字段，图鉴筛选可以通过 `guard` 路线找到新增挡弹武器/遗物。
- `ContentPipelineSmokeTest`、`WeaponSmokeTest`、`RelicSmokeTest`、`HallArchiveSmokeTest` 和 `LobbyScreenSmokeTest` 已同步到 24 武器 / 30 遗物和近战挡弹契约。

## 第三十三批已落地靠拢改动

### 蓄力武器链路第一版
- `WeaponData` 新增 `charge_duration`、`charge_damage_multiplier`、`charge_projectile_speed_multiplier` 和 `charge_projectile_count_bonus`，并把 `fire_mode` 扩展到 `charge`。
- `Weapon.gd` 支持按住开火进入蓄力、松开后结算弹药/能量/冷却并发射；`Projectile.gd` 会按蓄力比例放大伤害和弹速。
- 武器池从 24 把扩到 27 把，新增原创武器 `Coil Bow`、`Storm Capacitor` 和 `Vault Lance`，分别补充精准蓄力、蓄力散射和传奇长线贯穿路线。
- 遗物池从 30 个扩到 33 个，新增 `Draw Weight`、`Quick Windup` 和 `Stored Spark`，分别强化蓄力伤害、蓄力速度和满蓄力额外弹丸。
- `RewardChest`、`ShopInventory`、Boss 宝箱、`RelicSystem.available_relics` 和 5 个遗物掉落表已接入蓄力内容。
- Outpost Hall 武器详情页会展示 `Charge` 字段，图鉴筛选可以通过 `charge` 路线找到新增蓄力武器/遗物。
- `ContentPipelineSmokeTest`、`WeaponSmokeTest`、`RelicSmokeTest`、`HallArchiveSmokeTest` 和 `LobbyScreenSmokeTest` 已同步到 27 武器 / 33 遗物和蓄力契约。

## 第三十四批已落地靠拢改动

### 部署/陷阱武器链路第一版
- `WeaponData` 新增 `deployable` 开火模式，以及部署物持续时间、半径、tick 间隔、预热时间和伤害倍率字段。
- `Weapon.gd` 新增部署物生成路径，`DeployableTrap` 负责范围 tick 伤害、状态附加和命中统计，形成第一版原创陷阱/轻量召唤运行时。
- 武器池从 27 把扩到 30 把，新增原创武器 `Snare Beacon`、`Ember Mine` 和 `Sentry Seed`，分别补充减速控场、短延迟燃烧地雷和长半径轻召唤节奏。
- 遗物池从 33 个扩到 35 个，新增 `Tripwire Amplifier` 和 `Anchor Spool`，分别强化部署物伤害和持续时间。
- `RewardChest`、`ShopInventory`、Boss 宝箱、`RelicSystem.available_relics` 和 5 个遗物掉落表已接入部署内容。
- Outpost Hall 武器详情页会展示 `Deploy` 字段，图鉴筛选可以通过 `deployable` 路线找到新增部署武器/遗物。
- `ContentPipelineSmokeTest`、`WeaponSmokeTest`、`RelicSmokeTest`、`HallArchiveSmokeTest` 和 `LobbyScreenSmokeTest` 已同步到 30 武器 / 35 遗物和部署物契约。

## 第三十五批已落地靠拢改动

### Outpost Hall 图鉴检索与排序第一版
- `LobbyScreen.tscn` 新增搜索/排序/稀有度 refinement 行，只在武器、遗物、天赋和祝福图鉴页显示。
- `LobbyScreen.gd` 在原有 Build 路线筛选基础上叠加搜索、稀有度筛选和排序，支持按名称、稀有度和掉落权重整理内容池。
- 搜索会匹配名称、描述、稀有度、分类、内容定位、效果类型、规则文本和标签，让扩张后的武器/遗物/天赋/祝福池更容易浏览。
- 图鉴页新增 `Refine` 摘要，明确当前稀有度、搜索词和排序方式。
- `LobbyScreenSmokeTest` 已覆盖 refinement 控件显示/隐藏、默认状态、搜索、稀有度筛选和掉落权重排序。

## 第三十六批已落地靠拢改动

### 训练靶场布局第一版
- `Main.gd` 将训练房从单个假人升级为三目标靶场，分别提供近、中、远距离练习目标。
- 进入训练和重置训练时会把玩家固定到训练射击线，避免复用起始房时角色位置不稳定。
- HUD 训练面板新增目标数量显示，训练统计继续保留命中次数、累计伤害和最高单次伤害。
- `training.tres` 新增安全柱和射击道标线障碍，为后续替换正式训练场景美术和操作引导保留布局入口。
- `TrainingRoomSmokeTest` 已扩展到靶子数量、玩家站位、HUD 目标数、重置后重生和布局障碍契约。

## 第三十七批已落地靠拢改动

### 训练 drill 引导与目标类型第一版
- `Main.gd` 新增 `TRAINING_DRILLS`，当前包含 `Basics`、`Movement` 和 `Burst` 三种原创训练 drill。
- 每个 drill 都配置独立说明和目标位置，用于练习距离对比、错位走位追踪和聚集爆发。
- HUD 训练面板新增当前 drill 名称、简短练习目标和 `Next Drill` 按钮，训练中切换会清零统计并重生当前 drill 的三目标。
- `Reset Training` 保留当前 drill，只负责清空统计、恢复角色资源和重生目标。
- `TrainingRoomSmokeTest` 已覆盖 drill 起始状态、切换、目标名称变化、统计清零和重置保留当前 drill。

## 第三十八批已落地靠拢改动

### Outpost Hall Featured Card 文本详情卡第一版
- `LobbyScreen.gd` 在武器、遗物、天赋和祝福独立页新增 `Featured Card` 文本详情卡。
- Featured Card 会跟随当前 Route、搜索、稀有度和排序后的第一项，先展示当前结果中最值得检查的条目。
- 武器卡聚合核心数值和 Status / Guard / Charge / Deploy 特殊机制；遗物卡聚合触发、效果、堆叠和互斥；天赋/祝福卡聚合作用范围、规则和效果。
- `All` 总览页保持压缩摘要，不显示详情卡，避免大厅首页文本继续膨胀。
- `LobbyScreenSmokeTest` 已覆盖四类图鉴详情卡、筛选后卡片跟随和搜索后卡片聚焦。

## 第三十九批已落地靠拢改动

### Outpost Hall CodexDetailCard Control 详情卡第一版
- `LobbyScreen.tscn` 在图鉴标题和正文滚动列表之间新增 `CodexDetailCard` Control，包含标题、元信息和正文。
- `LobbyScreen.gd` 新增独立详情卡刷新逻辑，复用当前 Route、搜索、稀有度和排序结果，保证卡片与列表聚焦同一个条目。
- 武器卡显示稀有度、类型、距离、Build 标签、伤害、能量、射速和 Status / Guard / Charge / Deploy 机制；遗物、天赋和祝福卡显示触发、范围、效果、规则/堆叠和互斥。
- `LobbyScreenSmokeTest` 已覆盖非图鉴页隐藏详情卡、图鉴页显示详情卡、筛选后标题跟随和搜索后标题聚焦。

## 第四十批已落地靠拢改动

### Outpost Hall 详情卡徽标与稀有度色条第一版
- `CodexDetailCard` 顶部新增稀有度色条、页面类型徽标和稀有度徽标，让图鉴条目先具备基础视觉识别层。
- `LobbyScreen.gd` 新增 WPN / REL / TAL / BLS 类型徽标映射，以及 Common / Rare / Epic / Legendary 的稀有度颜色映射。
- 详情卡标题色、稀有度徽标和色条会跟随当前筛选、搜索、稀有度过滤和排序后的聚焦条目同步变化。
- `LobbyScreenSmokeTest` 已覆盖徽标文本、Common / Rare / Epic 稀有度 badge，以及武器/遗物稀有度筛选后的详情卡同步。

## 第四十一批已落地靠拢改动

### 训练目标类型与类型摘要第一版
- `TrainingDummy` 新增 `standard`、`mobile`、`armored`、`burst` 目标类型入口，类型会影响颜色、标签和可选轻量移动。
- `armored` 目标会降低有效伤害，并暴露本次有效伤害与累计减免量；训练 HUD 统计会记录有效伤害而不是原始弹丸伤害。
- `burst` 目标会按连击窗口记录短时间连续命中的最佳连击，训练 HUD 会显示 `Burst xN`。
- Basics drill 生成 3 个 Standard；Movement drill 生成 2 个 Mobile 和 1 个 Armored；Burst drill 生成 2 个 Burst 和 1 个 Armored。
- HUD 训练面板新增 `Types ...` 摘要，让玩家能直接看到当前 drill 的目标类型构成。
- `TrainingRoomSmokeTest` 已覆盖三种 drill 的目标类型分布、HUD 类型摘要、护甲目标有效伤害、Burst 快速连击、切换 drill 后统计重置和重置训练后保留当前目标类型。

## 第四十二批已落地靠拢改动

### 训练 drill 目标与完成状态第一版
- 每个训练 drill 新增明确完成目标：Basics 命中全部目标，Movement 命中两个 mobile 目标，Burst 打出 `Burst x2` 连击。
- `Main.gd` 会记录已命中的目标实例和按类型命中的目标实例，并为当前 drill 输出 `goal_progress`、`goal_required` 和 `goal_complete`。
- HUD 训练面板新增独立 Goal 行，目标达成后从 `Goal:` 切换为 `Complete:`。
- 重置训练会清空目标进度和完成状态，但保留当前 drill，避免玩家切换练习内容后被强制回到 Basics。
- `TrainingRoomSmokeTest` 已覆盖目标文字、目标进度、Burst 完成状态和重置清空状态。

## 第四十三批已落地靠拢改动

### 训练 drill 评级第一版
- 训练摘要新增 `rating_rank` 和 `rating_text`，将训练反馈从单纯完成状态推进到 Practice / Clear / Clean 三档本地评级。
- 评级规则暂时只看当前 drill 目标和命中次数：目标未完成为 `Practice`，完成目标为 `Clear`，命中次数不超过目标要求时为 `Clean`。
- HUD 训练面板新增独立 Rating 行，重置或切换 drill 后恢复 `Practice`。
- 本批不发放奖励、不写入历史记录、不影响永久货币、角色熟练度或局内经济，保持训练房与正式 run 成长循环隔离。
- `TrainingRoomSmokeTest` 已覆盖初始 Practice、未完成保持 Practice、Burst 高效完成 Clean 和重置恢复 Practice。

## 第四十四批已落地靠拢改动

### 训练 drill 徽章记录第一版
- 训练评级现在会转化为局外可回看的训练徽章：每个 drill 保存历史最佳评级，`Clear` 和 `Clean` 会解锁或升级徽章。
- 训练徽章写入 `settings.cfg` 的独立 `training` 分组，并通过 `get_meta_progression_summary()` 暴露 `training_drill_best_ratings`、`training_badge_count` 和 `training_badge_total`。
- 徽章不发放 Data Shards、不增加角色熟练度、不写入 run history，也不影响局内金币，继续保持训练奖励与正式 run 经济隔离。
- Outpost Hall 的 All / Records 文本页和旧大厅摘要都会显示 `Training Badges X/3` 以及每个 drill 的 `Badge: ...`。
- 训练 HUD 的 Rating 行会同时显示当前评级和历史最佳徽章，例如 `Rating: Practice | Best Clean`。
- `TrainingRoomSmokeTest`、`HallArchiveSmokeTest` 和 `LobbyScreenSmokeTest` 已覆盖徽章保存、持久化读回、大厅显示和 Fresh 档案 0/3 状态。

## 第四十五批已落地靠拢改动

### 训练徽章 token 与奖励提示第一版
- 训练徽章新增稳定 token：未获得 `[--]`，`Clear` `[CL]`，`Clean` `[CN]`，用于在正式图标素材前先固定 UI 契约。
- 训练摘要新增 `best_rating_token` 和 `badge_notice_text`，新徽章产生时训练面板显示 `Badge Unlocked: Clean [CN]`。
- HUD 训练面板新增独立 Badge 行，重置后显示当前历史最佳徽章，例如 `Badge: Clean [CN]`。
- Outpost Hall 的训练徽章列表会显示 token 化状态，例如 `Badge: None [--]` 和 `Badge: Clean [CN]`。
- `TrainingRoomSmokeTest`、`HallArchiveSmokeTest` 和 `LobbyScreenSmokeTest` 已覆盖 `[--]` / `[CN]` 的训练面板、大厅和持久化显示契约。

## 第四十六批已落地靠拢改动

### Armor 安全间隔恢复烟测契约
- `Player` 已有受击后安全间隔逐点恢复 Armor 的运行时链路，本批补上对应烟测契约，避免后续角色、遗物或受击反馈改动误伤基础资源循环。
- `CharacterSmokeTest` 现在会先验证 Wanderer 开局 Armor 可优先吸收小额伤害，HP 不会被穿透扣除。
- 烟测会显式推进低于 `shield_recharge_delay` 的计时窗口，确认 Armor 不会在安全间隔前提前恢复。
- 烟测随后推进恢复窗口，确认 Armor 会逐点恢复到上限，并且恢复过程不会改变 HP。
- 当前差距描述已修正为缺少正式恢复读条、正式音效/视觉反馈和数值调优，恢复提示、`armor_gain` 和 `armor_block` 占位音效已接入 HUD/战斗反馈链路。

## 第四十七批已落地靠拢改动

### Armor HUD 恢复状态提示第一版
- `Player` 新增 `get_shield_recharge_summary()`，向 UI 暴露 Armor 当前是满值、延迟等待、恢复中还是恢复关闭，不让 HUD 直接读取私有计时器。
- `HUD.update_shield()` 现在可接收恢复状态摘要；受击后的安全间隔显示 `Delay Ns`，开始逐点恢复但未满时显示 `Recovering`，满 Armor 后自动回到纯数值。
- `Main.gd` 新增 Armor HUD 刷新入口，并在帧更新与护甲变化信号中同步刷新，让延迟倒计时和恢复状态不依赖下一次数值变化。
- `CharacterSmokeTest` 扩展为覆盖 Delay 文本、Recovering 文本和满 Armor 后隐藏恢复提示。
- 当前剩余差距收敛为更强的正式视觉/音效反馈、恢复读条或闪烁效果，以及实机数值调优。

## 第四十八批已落地靠拢改动

### Energy 不足反馈第一版
- `Events` 新增 `player_energy_insufficient` 信号，让能量不足从静默失败变成统一战斗反馈事件。
- `Player` 在武器或技能能量不足时发出反馈事件，并用 `energy_insufficient_feedback_interval` 做节流，避免按住开火时每帧刷屏。
- `Main.gd` 接入能量不足事件后会显示 `Not Enough Energy current/required` HUD 消息，并在玩家附近生成 `NO ENERGY` 浮字。
- `WeaponSmokeTest` 扩展为覆盖能量不足开火失败时不扣弹药、不生成弹丸，并且会生成 `NO ENERGY` 浮字反馈。
- 当前已接入 `energy_empty` 程序化占位空响，但仍未接入正式 SFX 资源或 Energy 条闪烁动画，后续可继续把这个事件接到正式 HUD 高亮。

## 第四十九批已落地靠拢改动

### Energy HUD Need 状态第一版
- `HUD` 新增短时 Energy 警告状态，能量不足时 Energy 行会从普通 `Energy: current / max` 切换为 `Energy: current / max | Need required`。
- `Main.gd` 在处理 `player_energy_insufficient` 时同步调用 `show_energy_warning()`，让 HUD 能量栏、顶部消息和玩家浮字三层反馈同时出现。
- `HUD` 新增 `get_energy_label_text()`，用于烟测读取 Energy 行文本。
- `WeaponSmokeTest` 扩展为验证能量不足失败开火后 Energy HUD 会显示 `Need`，不只依赖浮字反馈。
- 当前已接入 `energy_empty` 程序化占位空响，但仍未接入正式 UI 动画、正式音效资源或不同武器的失败反馈差异。

## 第五十批已落地靠拢改动

### Skill 冷却失败反馈第一版
- `Events` 新增 `player_skill_unavailable` 信号，让主动技能失败从静默返回变成可复用反馈事件。
- `Player.try_use_skill()` 在技能冷却中会发出 `cooldown` 失败反馈，并用 `skill_unavailable_feedback_interval` 做节流，避免重复按键刷屏。
- `Main.gd` 接入技能不可用事件后会显示 `SkillName Cooldown Ns` HUD 消息，并在玩家附近生成 `SKILL CD` 浮字。
- `CharacterSmokeTest` 扩展为覆盖 Warden 技能进入冷却后再次使用会失败，并且会生成 `SKILL CD` 浮字反馈。
- 当前仍未接入正式技能按钮动画、正式音效或手柄震动，但主动技能冷却失败已经具备可测试的统一反馈接口、Skill 行脉冲和 `skill_fail` 占位音效。

## 第五十一批已落地靠拢改动

### 近战扇形挥砍可视反馈第一版
- 新增 `MeleeSweepFlash` 轻量效果场景，近战释放时按武器 `projectile_range` 和 `spread_angle` 绘制前方扇形闪光。
- `Weapon.gd` 的 `melee` 开火分支现在会在即时伤害与挡弹逻辑旁同步生成可视挥砍范围，让玩家能读到当前近战覆盖区域。
- `WeaponSmokeTest` 扩展 `Arc Blade` 契约：近战不生成弹丸、能造成伤害，同时必须生成一帧以上可见的扇形效果，且半径和角度来自 `WeaponData`。
- 当前仍是程序化占位视觉，后续应继续补正式挥砍贴图、不同近战武器的颜色/刀光差异、命中音效和格挡成功特效。

## 第五十二批已落地靠拢改动

### 远程敌人弹道前摇第一版
- `Enemy.gd` 新增 `projectile_attack_windup`，`SHOOTER` 和 `STRAFER` 行为不再到点立即发射，而是先进入短前摇。
- 前摇期间会复用 `DangerWarning` 生成一条或多条线形弹道预警，散射敌人会按实际散射角生成多条预警线。
- 精英远程敌人复用同一套敌人行为，因此也会继承弹道前摇和预警线，不再只靠颜色/血量区分威胁。
- `EnemyVarietySmokeTest` 扩展 `Barrage Totem` 契约：先看到 5 条弹道预警且没有弹丸，等待前摇结束后才生成散射弹幕。
- 当前仍是程序化线形预警和 `danger_warning_line` 占位音效，后续应继续补敌人动作帧、枪口/施法起手动画和按敌人类型区分的预警颜色/音效。

## 第五十三批已落地靠拢改动

### 冲锋敌人路线预警第一版
- `Enemy.gd` 的 `CHARGER` 行为在进入 `charge_windup` 时会生成线形 `DangerWarning`，标出即将冲刺的路线。
- 预警长度按 `charge_speed * charge_duration` 和 `attack_range` 推导，普通 `Charger`、`Iron Breaker` 以及精英冲锋变体都会复用同一套路线提示。
- 冲锋前摇仍保留原有敌人闪烁反馈，但不再只依赖颜色变化判断冲锋方向。
- `EnemyVarietySmokeTest` 新增 `Charger` 契约：冲锋前必须生成路线预警，并在预警可见时保持 windup 状态。
- 当前仍是程序化线形预警和 `danger_warning_line` 占位音效，后续应继续补脚步/蓄势动画、正式冲锋起步音效和不同重型敌人的路线宽度差异。

## 第五十四批已落地靠拢改动

### 玩家受击 HUD 闪屏反馈第一版
- `HUD.gd` 新增运行时 `DamageFlashOverlay`，玩家实际 HP 受损时短暂显示红色覆盖层并自动淡出。
- `Main.gd` 在 `player_damaged` 事件中同步触发 `show_damage_flash()`，让受击反馈从浮字/震动扩展到 UI 层警示。
- `CombatFeedbackSmokeTest` 扩展为验证受击后闪屏可见、alpha 大于 0，并在持续时间后自动消退。
- 当前仍是程序化红色覆盖层和程序化受击/护甲挡伤占位音效，后续应继续补正式边缘血色 vignette、正式受击音效差异和低血状态差异。

## 第五十五批已落地靠拢改动

### 低血 HUD 状态提示第一版
- `HUD.update_health()` 新增低血阈值判断，当前生命值低于约 35% 且仍存活时，HP 行会追加 `LOW` 并切换为红色。
- 低血状态由 `health_changed` 驱动，因此受击、治疗、角色切换和直接资源刷新都会走同一条 HUD 更新路径。
- `HUD.gd` 新增 `get_health_label_text()` 和 `is_low_health_active()`，让烟测能读取低血文本和状态。
- `CombatFeedbackSmokeTest` 扩展为验证低血提示出现，并在生命恢复到安全区后自动清除。
- 当前仍是文本、颜色提示、程序化边缘 vignette、濒死强度脉冲和 `low_health` / `low_health_heartbeat` / `low_health_recover` / `hp_heal` 程序化占位音效，低血阈值和 critical 权重已抽到 `LowHealthFeedback`，心跳间隔和 vignette 脉冲速度已按 HP 严重程度同步变速，并已支持低血反馈强度设置；后续应继续补正式低血贴图、正式心跳/警报音效和更细的濒死/治疗反馈节奏。

## 第五十六批已落地靠拢改动

### Armor 恢复 HUD 脉冲第一版
- `HUD.update_shield()` 现在会记录上一帧 Armor 数值，检测到 Armor 上升时触发短暂亮青色脉冲。
- 脉冲会随 `_process()` 自动淡回普通 Armor 蓝色；Armor 下降时会立即取消恢复脉冲，避免受击和恢复状态混淆。
- `HUD.gd` 新增 `show_armor_recovery_pulse()`、`is_armor_recovery_pulse_active()` 和 `get_shield_label_color_for_test()`，让反馈具备可测试接口。
- `CharacterSmokeTest` 扩展为验证自动恢复第一点 Armor 后 HUD 脉冲激活、颜色变亮，并在持续时间后消退。
- 当前仍是 HUD 文本颜色脉冲和 `armor_gain` 程序化占位音效，后续应继续补正式恢复读条、Armor 图标闪光和正式恢复完成音效。

## 第五十七批已落地靠拢改动

### Energy 不足 HUD 脉冲第一版
- `HUD.show_energy_warning()` 现在记录警告持续时间，Energy 不足时不仅显示 `Need N`，还会把 Energy 行短暂推向亮蓝白色。
- `_refresh_energy_label()` 会根据警告剩余时间把 Energy 行颜色淡回普通蓝色；能量已经足够或计时结束时自动恢复普通颜色。
- `HUD.gd` 新增 `is_energy_warning_active()` 和 `get_energy_label_color_for_test()`，让 Energy 警告具备可测试状态和颜色接口。
- `WeaponSmokeTest` 扩展为验证能量不足开火失败后 Energy warning 激活、颜色变亮，并在持续时间后消退。
- 当前仍是 HUD 文本颜色脉冲和程序化占位空响，后续应继续补正式武器空响音效、Energy 条正式闪烁动画和不同武器的失败反馈差异。

## 第五十八批已落地靠拢改动

### Skill 冷却失败 HUD 脉冲第一版
- `HUD.gd` 新增 Skill warning 计时和颜色刷新，技能不可用反馈触发时 Skill 行会短暂推向橙色。
- `Main.gd` 在 `player_skill_unavailable` 事件中同步调用 `show_skill_warning()`，让 HUD 消息、`SKILL CD` 浮字和 Skill 行脉冲三层反馈同时出现。
- `HUD.gd` 新增 `is_skill_warning_active()` 和 `get_skill_label_color_for_test()`，让技能失败反馈具备可测试状态和颜色接口。
- `CharacterSmokeTest` 扩展为验证 Warden 技能冷却中重复使用后 Skill warning 激活、颜色变橙，并在持续时间后消退。
- 当前仍是 HUD 文本颜色脉冲和 `skill_fail` 占位音效，后续应继续补正式技能按钮动画、正式失败音效和手柄震动。

## 第五十九批已落地靠拢改动

### Skill Ready HUD 脉冲第一版
- `HUD.update_skill_status()` 现在会记录上一帧技能是否 Ready，仅在同一技能从冷却/激活状态回到 Ready 时触发绿色脉冲。
- 角色切换或初始 HUD 刷新不会触发 Ready 脉冲，避免把选择角色误读成技能冷却完成。
- `HUD.gd` 新增 `show_skill_ready_pulse()` 和 `is_skill_ready_pulse_active()`，并让 Skill warning 橙色脉冲优先于 Ready 绿色脉冲。
- `CharacterSmokeTest` 扩展为推进 Warden 技能冷却结束，验证 Ready 文本、绿色脉冲激活和持续时间后消退。
- 当前仍是 HUD 文本颜色脉冲和 `skill_ready` 占位音效，后续应继续补正式技能按钮 Ready 闪光、正式提示音效和手柄震动。

## 第六十批已落地靠拢改动

### Ammo 换弹完成 HUD 脉冲第一版
- `HUD.update_ammo()` 现在会记录上一帧是否处于 Reloading，仅在从 Reloading 回到非 Reloading 且弹药大于 0 时触发绿色脉冲。
- 切换武器、初始 HUD 刷新或普通开火扣弹不会触发换弹完成脉冲，避免和普通弹药变化混淆。
- `HUD.gd` 新增 `show_ammo_ready_pulse()`、`is_ammo_ready_pulse_active()`、`get_ammo_label_text()` 和 `get_ammo_label_color_for_test()`。
- `WeaponSmokeTest` 扩展为验证手枪自动换弹完成后 Ammo 文本显示满弹、绿色脉冲激活并在持续时间后消退。
- 当前仍是 HUD 文本颜色脉冲，后续应继续补正式换弹完成音效、武器槽闪光和弹匣动画。

## 第六十一批已落地靠拢改动

### Weapon 行换弹完成脉冲第一版
- `HUD.update_ammo()` 在检测到换弹完成时，现在会同时触发 Ammo 行和当前 Weapon 行的绿色 ready 脉冲。
- `set_weapon_name()` 会在武器切换时清空 Weapon 行 ready 脉冲，避免旧武器的换弹完成反馈带到新武器。
- `HUD.gd` 新增 `show_weapon_ready_pulse()`、`is_weapon_ready_pulse_active()`、`get_weapon_label_text()` 和 `get_weapon_label_color_for_test()`。
- `WeaponSmokeTest` 扩展为验证换弹完成后当前武器名仍显示正确、Weapon 行绿色脉冲激活并在持续时间后消退。
- 当前仍是 HUD 文本行闪光，不是最终武器槽 UI；后续应继续补正式武器槽图标、弹匣动画和换弹完成音效。

## 第六十二批已落地靠拢改动

### Weapon Slot 状态条第一版
- `HUD.tscn` 新增 `WeaponSlotPanel`，在当前武器 HUD 区域内显示武器名、弹匣状态和一条状态色条。
- `HUD.gd` 现在会把 `set_weapon_name()` 和 `update_ammo()` 同步到 Weapon Slot：正常状态显示 `Ready`，弹匣为空显示 `Empty`，换弹中显示 `Reloading`。
- 换弹完成触发 ready 脉冲时，Weapon Slot 状态条会同步从蓝色推向绿色，让换弹完成反馈不再只依赖文本颜色。
- `HUD.gd` 新增 `get_weapon_slot_name_text()`、`get_weapon_slot_status_text()` 和 `get_weapon_slot_bar_color_for_test()`，用于烟测读取武器槽 UI 状态。
- `WeaponSmokeTest` 扩展为验证换弹中 Weapon Slot 显示 `Reloading`，换弹完成后显示当前武器、满弹 `Ready` 和绿色状态条。
- 当前仍是文字/色条型武器槽雏形，后续应继续补武器图标、弹匣分段动画、正式换弹完成动画和音效。

## 第六十三批已落地靠拢改动

### Weapon Slot 弹匣分段第一版
- `HUD.tscn` 在 `WeaponSlotPanel` 内新增 `WeaponSlotMagazineRow`，作为后续正式弹匣 UI 的占位承载节点。
- `HUD.gd` 会按武器弹匣大小动态生成弹匣段，最多显示 12 段；大弹匣按比例映射，避免高射速武器把 HUD 撑开。
- 弹匣段会随状态变色：普通状态按剩余弹药填充，空弹匣变红，换弹中变橙，换弹完成 ready 脉冲时已填充段变绿。
- `HUD.gd` 新增 `get_weapon_slot_magazine_segment_summary_for_test()` 和 `get_weapon_slot_magazine_first_segment_color_for_test()`。
- `WeaponSmokeTest` 扩展为验证手枪换弹中弹匣段为空、换弹完成后弹匣段填满并闪绿。
- 当前仍是程序化 ColorRect 分段；后续应继续补正式图标、分段动画、弹匣填装动效和音效。

## 第六十四批已落地靠拢改动

### Weapon Slot 槽位上下文第一版
- `Player.weapon_changed` 现在会随武器名一起发出当前槽位序号和总槽位数，让 UI 能区分 `1/3`、`2/3`、`3/3`。
- `Main.gd` 初始化和武器切换回调都会把槽位上下文传给 HUD，避免开局显示和实际切换路径不一致。
- `HUD.set_weapon_name()` 保持向后兼容，同时会保存槽位序号，并把主 Weapon 行和 Weapon Slot 标题显示为带槽位的格式。
- `HUD.gd` 新增 `get_weapon_slot_index_text()`，供烟测直接读取当前槽位上下文。
- `WeaponSmokeTest` 扩展为验证开局 Weapon Slot 显示 `1/3`，切换到第二把武器后显示 `2/3` 和正确武器名。
- 当前仍是文本槽位编号；后续应继续补 1/2/3 槽位图标和正式当前槽高亮动画。

## 第六十五批已落地靠拢改动

### Weapon Slot 三槽负载预览第一版
- `HUD.tscn` 在 Weapon Slot 内新增 `WeaponSlotLoadoutRow`，显示 1/2/3 三个武器槽的简短名称。
- `HUD.gd` 新增 `update_weapon_loadout()`，维护当前负载名称数组，并高亮当前槽、弱化非当前槽。
- `Main.gd` 在开局初始化和 `weapon_changed` 回调中刷新整套负载预览；商店购买武器替换当前槽后也会通过同一路径同步 HUD。
- `HUD.gd` 新增 `get_weapon_slot_loadout_text()` 和 `get_weapon_slot_loadout_summary_for_test()`。
- `WeaponSmokeTest` 扩展为验证开局三槽预览、切换到第二把武器后的 active slot；`ShopSmokeTest` 扩展为验证购买武器后 HUD 负载预览包含新武器。
- 当前仍是文本短名预览；后续应继续补武器图标、当前槽视觉框、非当前槽弹药摘要和更紧凑的正式布局。

## 第六十六批已落地靠拢改动

### Weapon Slot 稀有度/类型预览第一版
- `Main.gd` 新增负载摘要输出，传递每把武器的 `display_name`、`rarity`、`weapon_class` 和 `recommended_range` 给 HUD。
- `HUD.update_weapon_loadout()` 现在兼容字符串、资源和字典三种输入，并把负载预览升级为元数据条目。
- Weapon Slot 负载短名会带稀有度/类型前缀，例如 `ST/SI`、`CO/SH`，并按稀有度给当前槽和非当前槽着色。
- 负载槽 tooltip 会显示完整武器名、稀有度、类型和推荐距离，作为正式图标前的轻量信息层。
- `WeaponSmokeTest` 扩展为验证起始负载预览暴露稀有度和武器类型元数据；`ShopSmokeTest` 扩展为验证购买武器后 HUD 负载预览同步新武器的稀有度和类型。
- 当前仍是文本短码和 tooltip；后续应继续补正式武器图标、稀有度边框、类型图标和更紧凑的槽位布局。

## 第六十七批已落地靠拢改动

### Weapon Slot 当前武器详情行第一版
- `HUD.tscn` 在 Weapon Slot 内新增 `WeaponSlotMetaLabel`，直接展示当前武器的稀有度、类型、推荐距离和能耗。
- `Main.gd` 的负载摘要现在会把 `energy_cost` 一并传给 HUD，让当前武器详情行能显示 `E0`、`E2` 等能耗提示。
- `HUD.gd` 新增 `_refresh_weapon_slot_meta_label()`，会随开局、切换武器、商店换购和负载刷新同步当前武器元数据。
- `HUD.gd` 新增 `get_weapon_slot_meta_text()`，供烟测读取当前武器详情行。
- `WeaponSmokeTest` 扩展为验证当前武器详情行包含稀有度、类型、推荐距离和能耗，并在切换武器后更新；`ShopSmokeTest` 扩展为验证购买武器后详情行同步新武器稀有度和类型。
- 当前仍是文本详情行；后续应继续补正式武器图标、稀有度边框、能耗图标和更直观的类型符号。

## 第六十八批已落地靠拢改动

### Weapon Slot 图标/色条/符号第一版
- `HUD.tscn` 在 Weapon Slot 内新增 `WeaponSlotIdentityRow`，包含稀有度色条、武器类型 icon token、可读类型标签和能耗符号。
- `HUD.gd` 新增 `_refresh_weapon_slot_identity_visuals()`，会跟随当前负载元数据同步稀有度色条、类型符号和 `E0` / `E2` 等能耗显示。
- `HUD.gd` 新增 `_format_weapon_class_symbol()`，为 `sidearm`、`shotgun`、`staff`、`blade`、`bow`、`trap` 等类型生成稳定短 token，作为正式图标素材前的占位契约。
- `HUD.gd` 新增 `get_weapon_slot_visual_summary_for_test()`，供烟测读取当前武器槽的 icon、type、energy 和 rarity color。
- `WeaponSmokeTest` 扩展为验证开局与切换武器后图标 token、类型符号、能耗符号和稀有度色条契约；`ShopSmokeTest` 扩展为验证购买武器后这些视觉字段同步新武器。
- 当前仍是程序化 token 和色条；后续应继续替换为正式像素图标、当前槽高亮动画、能耗图标和弹匣填装动画。

## 第六十九批已落地靠拢改动

### Weapon Slot 稀有度边框与当前槽高亮第一版
- `HUD.gd` 为 Weapon Slot 面板新增运行时 `StyleBoxFlat`，让当前武器槽具备稳定边框和暗色面板底。
- Weapon Slot 面板边框颜色会跟随当前武器稀有度；换弹中、空弹匣和换弹完成 ready 脉冲会临时混入橙色、红色或绿色反馈。
- 当前武器槽在多槽负载下保持更粗的 active border，让玩家能更快识别当前正在使用的槽位。
- `HUD.gd` 新增 `get_weapon_slot_panel_summary_for_test()`，供烟测读取 active slot、slot total、border color 和 border width。
- `WeaponSmokeTest` 扩展为验证开局、切换武器和换弹完成后的边框契约；`ShopSmokeTest` 扩展为验证购买武器后 active border 仍指向被替换的当前槽。
- 当前仍是程序化边框；后续应继续替换为正式像素边框、当前槽图标框动画、稀有度边框贴图和换弹完成动效。

## 第七十批已落地靠拢改动

### Weapon Slot 切槽脉冲第一版
- `HUD.gd` 新增 Weapon Slot 切槽脉冲计时，当前槽位从 `1/3` 切到 `2/3` 等变化时会短暂高亮新的 active slot。
- 三槽负载预览的当前槽文字会在切槽脉冲期间混入亮黄提示色，帮助玩家读到刚刚切到的武器槽。
- Weapon Slot 面板边框会在切槽脉冲期间短暂混入亮黄边框色，和稀有度边框、换弹 ready 边框共用同一套状态刷新。
- `HUD.gd` 新增 `is_weapon_slot_switch_pulse_active()` 和 `get_weapon_slot_active_loadout_color_for_test()`，供烟测读取切槽动画状态和当前槽颜色。
- `WeaponSmokeTest` 扩展为验证切换武器后切槽脉冲激活、当前槽颜色提亮，并在持续时间后消退。
- 当前仍是程序化颜色脉冲；后续应继续替换为正式槽位切换滑动/弹跳动画、图标框高亮和输入设备震动反馈。

## 第七十一批已落地靠拢改动

### Weapon Slot 换弹中弹匣 sweep 第一版
- `HUD.gd` 新增 Weapon Slot reload sweep 计时，在武器换弹期间持续推进当前高亮弹匣段。
- `WeaponSlotMagazineRow` 的换弹状态不再整排静态橙色，而是用亮黄高亮段在弹匣分段之间移动，表达正在填装。
- 换弹开始时会重置 sweep 到第一个分段；换弹结束或退出 reloading 状态时会清空 sweep 状态，避免残留到 Ready。
- `HUD.gd` 的弹匣 summary 测试接口新增 `reload_sweep_active` 和 `reload_sweep_index`，并新增 `get_weapon_slot_reload_sweep_segment_color_for_test()`。
- `WeaponSmokeTest` 扩展为验证换弹中 sweep 激活、高亮段颜色变亮，并在推进 HUD 时间后移动到下一个分段。
- 当前仍是程序化分段扫光和 `reload_ready` 占位音效；后续应继续替换为正式弹匣填装动画、武器差异化 reload 视觉和正式换弹音效。

## 第七十二批已落地靠拢改动

### Weapon Slot 能耗不足符号脉冲第一版
- `HUD.show_energy_warning()` 现在会同步刷新 Weapon Slot 的能耗符号颜色，让 `E2` 等能耗提示参与能量不足反馈。
- `HUD.gd` 新增 `WEAPON_SLOT_ENERGY_WARNING_COLOR` 和 `_refresh_weapon_slot_energy_symbol_color()`，在能量不足 warning 活跃时把当前武器的能耗符号推向亮黄。
- `update_energy()` 和 warning 计时推进会同步刷新能耗符号颜色，避免能量恢复或 warning 结束后颜色残留。
- `HUD.gd` 新增 `get_weapon_slot_energy_symbol_color_for_test()`，供烟测读取当前武器槽能耗符号颜色。
- `WeaponSmokeTest` 扩展为验证能量不足失败开火后 Weapon Slot 能耗符号变亮，并在 warning 消退后恢复普通颜色。
- 当前仍是文字颜色脉冲和程序化占位空响；后续应继续替换为正式能量图标、正式空响音效和不同能耗等级的差异化失败反馈。

## 第七十三批已落地靠拢改动

### 能量不足空响音效第一版
- `AudioFeedback.gd` 新增 `energy_empty` 程序化占位 SFX，作为能量不足失败开火的专属听觉反馈。
- `AudioFeedback` 现在订阅 `Events.player_energy_insufficient`，让武器或技能能量不足事件自动触发空响，而不需要 `Main.gd` 额外转发。
- `AudioFeedback.gd` 新增 `get_last_sfx_id_for_test()`，供烟测确认具体播放的反馈 ID。
- `AudioFeedbackSmokeTest` 扩展为验证 `player_energy_insufficient` 事件会触发 SFX，并且最后播放 ID 为 `energy_empty`。
- `WeaponSmokeTest` 扩展为验证真实能量门控失败开火会增加 SFX 计数，并使用 `energy_empty` 音效。
- 当前仍是程序化占位音效；后续应继续替换为正式武器空响音效，并按武器能耗等级、武器类型或弹药状态做差异化失败反馈。

## 第七十四批已落地靠拢改动

### 武器开火音效 key 分流第一版
- `AudioFeedback._on_player_fired()` 现在读取 `WeaponData.fire_sfx_key`，成功开火会使用武器资源配置的专属 SFX key，而不是所有武器都播放通用 `shoot`。
- `AudioFeedback.gd` 新增 `_resolve_weapon_fire_sfx_id()`，当武器没有配置 `fire_sfx_key` 时按 `weapon_class` 回退到 `weapon_sidearm_fire`、`weapon_shotgun_fire`、`weapon_launcher_fire`、`weapon_laser_fire`、`weapon_melee_fire`、`weapon_staff_fire` 或 `weapon_core_fire`。
- `AudioFeedback.gd` 新增 `_try_play_weapon_fire_sfx()`，把当前 30 把武器的开火 key 映射到不同程序化占位音色组，先建立听觉差异契约。
- `AudioFeedbackSmokeTest` 扩展为验证配置 key、类别回退和空武器数据的通用 `shoot` fallback。
- `WeaponSmokeTest` 扩展为验证真实开火后会增加 SFX 计数，并使用当前武器的 `fire_sfx_key`。
- 当前仍是程序化占位音色；后续应继续替换为正式音频资源，并按武器族、稀有度和强化状态打磨混音层次。

## 第七十五批已落地靠拢改动

### 换弹完成音效第一版
- `Events.gd` 新增 `player_weapon_reloaded(weapon_data)`，把武器换弹完成从仅有 HUD/Ammo 信号推进为可被全局反馈系统消费的事件。
- `Weapon._finish_reload()` 在补满弹匣并发出 `ammo_changed` 后，会同步发出 `Events.player_weapon_reloaded`。
- `AudioFeedback.gd` 新增 `reload_ready` 程序化占位 SFX，并订阅 `Events.player_weapon_reloaded` 播放换弹完成提示。
- `AudioFeedbackSmokeTest` 扩展为验证直接 `player_weapon_reloaded` 事件会触发 `reload_ready`。
- `WeaponSmokeTest` 扩展为验证手枪真实自动换弹完成后会增加 SFX 计数，并且最近播放 ID 为 `reload_ready`。
- 当前仍是单一程序化占位音效；后续应继续按武器类别或 `reload_sfx_key` 拆分差异化换弹完成音效，并替换正式音频资源。

## 第七十六批已落地靠拢改动

### 技能不可用音效第一版
- `AudioFeedback.gd` 新增 `skill_fail` 程序化占位 SFX，作为主动技能不可用时的听觉失败反馈。
- `AudioFeedback` 现在订阅 `Events.player_skill_unavailable`，让技能冷却中重复使用等失败事件自动触发 `skill_fail`。
- `AudioFeedbackSmokeTest` 扩展为验证直接 `player_skill_unavailable` 事件会触发 SFX，并且最后播放 ID 为 `skill_fail`。
- `CharacterSmokeTest` 扩展为验证 Warden 技能冷却中重复使用后会增加 SFX 计数，并使用 `skill_fail` 音效。
- 当前仍是单一程序化占位音效；后续应继续按失败原因、角色技能类型或正式技能按钮状态拆分差异化音效，并替换正式音频资源。

## 第七十七批已落地靠拢改动

### Skill Ready 音效第一版
- `Events.gd` 新增 `player_skill_ready(skill_name)`，把主动技能冷却完成从 HUD 内部状态推进为可被全局反馈系统消费的事件。
- `Player._tick_timers()` 在技能冷却/激活状态完全回到可用时发出 `Events.player_skill_ready`，避免角色切换或初始刷新误触发。
- `AudioFeedback.gd` 新增 `skill_ready` 程序化占位 SFX，并订阅 `Events.player_skill_ready` 播放技能可用提示。
- `AudioFeedbackSmokeTest` 扩展为验证直接 `player_skill_ready` 事件会触发 SFX，并且最后播放 ID 为 `skill_ready`。
- `CharacterSmokeTest` 扩展为验证 Warden 技能冷却结束后会增加 SFX 计数，并使用 `skill_ready` 音效。
- 当前仍是单一程序化占位音效；后续应继续按角色技能类型、冷却时长或正式技能按钮状态拆分差异化 Ready 音效，并替换正式音频资源。

## 第七十八批已落地靠拢改动

### Armor 获得/恢复音效第一版
- `AudioFeedback.gd` 新增 `armor_gain` 程序化占位 SFX，作为 Armor 自动恢复、技能补甲和遗物补甲的统一听觉反馈。
- `AudioFeedback` 现在订阅 `Events.player_shield_gained`，正数护甲获得事件触发时自动播放 `armor_gain`。
- `AudioFeedbackSmokeTest` 扩展为验证直接 `player_shield_gained` 事件会触发 SFX，并且最后播放 ID 为 `armor_gain`。
- `CharacterSmokeTest` 扩展为验证 Wanderer 受击后自动恢复第一点 Armor 时会增加 SFX 计数，并使用 `armor_gain` 音效。
- 当前仍是单一程序化占位音效；后续应继续区分自动恢复、技能补甲、遗物补甲和满甲完成提示，并替换正式音频资源。

## 第七十九批已落地靠拢改动

### Armor 挡伤音效第一版
- `AudioFeedback.gd` 新增 `armor_block` 程序化占位 SFX，作为 Armor 吸收伤害时的专属听觉反馈。
- `AudioFeedback` 现在订阅 `Events.player_shield_absorbed`，正数护甲吸收事件触发时自动播放 `armor_block`。
- `AudioFeedback._on_player_damaged()` 新增 0 伤害保护，Armor 完全吸收伤害时不再误播 HP `hurt` 音效。
- `AudioFeedbackSmokeTest` 扩展为验证直接 `player_shield_absorbed` 事件会触发 SFX，并且最后播放 ID 为 `armor_block`。
- `CharacterSmokeTest` 扩展为验证 Wanderer 小额受击被 Armor 完全吸收时会增加 SFX 计数，并使用 `armor_block` 而不是 `hurt`。
- 当前仍是单一程序化占位音效；后续应继续按普通挡伤、破甲、满甲硬直、无敌期命中等状态拆分正式音效层次。

## 第八十批已落地靠拢改动

### HP 治疗音效第一版
- `AudioFeedback.gd` 新增 `hp_heal` 程序化占位 SFX，作为 HP 恢复时区别于 Armor 获得的专属听觉反馈。
- `AudioFeedback` 现在订阅 `Events.player_healed`，正数治疗事件触发时自动播放 `hp_heal`。
- `AudioFeedbackSmokeTest` 扩展为验证直接 `player_healed` 事件会触发 SFX，并且最后播放 ID 为 `hp_heal`。
- `CharacterSmokeTest` 扩展为验证 Wanderer 直接恢复缺失 HP 时会增加 SFX 计数，并使用 `hp_heal` 音效。
- 当前仍是单一程序化占位音效；后续应继续按治疗来源、低血治疗、过量治疗和治疗房/商店/角色技能拆分正式音效层次。

## 第八十一批已落地靠拢改动

### 危险预警音效第一版
- `Events.gd` 新增 `danger_warning_started(shape_name, duration, damage)`，把 `DangerWarning` 从纯视觉节点推进为可被全局反馈系统消费的预警事件。
- `DangerWarning.gd` 在 `configure_circle()` 和 `configure_line()` 时发出 `Events.danger_warning_started`，覆盖陷阱、Boss 场地危险、精英死亡爆炸、远程弹道和冲锋路线等现有预警来源。
- `AudioFeedback.gd` 新增 `danger_warning` 程序化占位 SFX，并订阅 `Events.danger_warning_started` 播放短促预警提示。
- `AudioFeedback` 对危险预警音效加入短冷却，避免 Boss 散射或多点地面危险同帧生成时叠出过密音效。
- `AudioFeedbackSmokeTest` 扩展为验证直接 `danger_warning_started` 事件会触发 SFX，并且最后播放 ID 为 `danger_warning`。
- 当前已按默认、线形和重威胁拆出程序化占位音效；后续应继续按圆形地面危险、Boss 阶段、陷阱房、精英死亡爆炸和敌人类型拆分正式音效层次。

## 第八十二批已落地靠拢改动

### 低血进入音效第一版
- `Events.gd` 新增 `player_low_health_warning(current_hp, max_hp)`，把 HUD 低血状态从纯 UI 文本推进为可被音频系统消费的资源风险事件。
- `Main._on_player_health_changed()` 在刷新 HUD 后检测 `is_low_health_active()`，仅在非低血进入低血时发出 `player_low_health_warning`。
- `AudioFeedback.gd` 新增 `low_health` 程序化占位 SFX，并订阅 `Events.player_low_health_warning` 播放低血提示。
- `AudioFeedbackSmokeTest` 扩展为验证直接 `player_low_health_warning` 事件会触发 SFX，并且最后播放 ID 为 `low_health`。
- `CombatFeedbackSmokeTest` 扩展为验证真实 HP 降到低血阈值时会增加 SFX 计数，并使用 `low_health` 音效。
- 当前仍是单一程序化占位音效；后续应继续补正式心跳循环、边缘低血 vignette、致命伤提示和恢复后的视觉收束。

## 第八十三批已落地靠拢改动

### 低血恢复音效收束第一版
- `Events.gd` 新增 `player_low_health_recovered(current_hp, max_hp)`，把低血状态解除也纳入统一战斗反馈事件。
- `Main._sync_low_health_warning_state()` 在 HUD 低血状态从 true 变 false 且玩家仍存活时发出 `player_low_health_recovered`，避免死亡被误判为恢复。
- `AudioFeedback.gd` 新增 `low_health_recover` 程序化占位 SFX，并订阅 `Events.player_low_health_recovered` 播放稳定提示。
- `AudioFeedbackSmokeTest` 扩展为验证直接 `player_low_health_recovered` 事件会触发 SFX，并且最后播放 ID 为 `low_health_recover`。
- `CombatFeedbackSmokeTest` 扩展为验证真实 HP 从低血恢复到安全区时会增加 SFX 计数，并使用 `low_health_recover` 音效。
- 当前仍是一次性程序化占位音效；后续应继续补正式低血心跳循环、恢复后的边缘 vignette 淡出和不同治疗来源的收束音效差异。

## 第八十四批已落地靠拢改动

### 低血边缘 Vignette 第一版
- `HUD.gd` 新增四条运行时 `ColorRect` 边缘遮罩，低血时显示半透明红色边缘提示，层级低于受击闪屏，避免遮挡中心弹幕。
- `HUD.update_health()` 在进入低血时立即显示边缘 vignette，脱离低血后按淡出速度收束。
- `HUD.gd` 新增 `is_low_health_vignette_visible()` 和 `get_low_health_vignette_alpha_for_test()`，让烟测能验证低血视觉状态。
- `CombatFeedbackSmokeTest` 扩展为验证低血时边缘 vignette 可见且 alpha 大于 0，恢复到安全血量并等待淡出后 vignette 不再可见。
- 当前仍是程序化边缘条占位视觉；后续应继续替换为正式低血边缘贴图、心跳节奏联动、不同 HP 段强度变化和可配置的无障碍强度。

## 第八十五批已落地靠拢改动

### 低血边缘脉冲与强度分段第一版
- `HUD.gd` 新增低血 vignette critical ratio、critical alpha、pulse alpha 和 pulse speed，用当前 HP 比例驱动目标强度。
- 低血刚进入时使用较低目标 alpha，HP 接近濒死阈值时提高到 critical alpha，并叠加轻微正弦脉冲。
- `HUD.gd` 新增 `get_low_health_vignette_target_alpha_for_test()`，让烟测能区分当前显示 alpha 和目标强度。
- `CombatFeedbackSmokeTest` 扩展为先把 HP 降到 LOW 阈值，再降到 1 HP，验证濒死状态会提高低血 vignette 目标 alpha。
- 当前仍是程序化脉冲；后续应继续接正式心跳节奏、玩家可配置强度和不同伤害来源触发的短暂冲击层。

## 第八十六批已落地靠拢改动

### 低血心跳节奏音效第一版
- `AudioFeedback.gd` 新增 `LOW_HEALTH_HEARTBEAT_INTERVAL`、`_low_health_heartbeat_active` 和 `_low_health_heartbeat_timer`，在 `_process()` 中按间隔播放低血心跳。
- `AudioFeedback.gd` 新增 `low_health_heartbeat` 程序化占位 SFX，区别于进入低血的一次性 `low_health` 警报。
- `Events.player_low_health_warning` 会启动心跳计时，`Events.player_low_health_recovered` 和 `Events.player_died` 会停止心跳，避免恢复或死亡后继续播放。
- `AudioFeedback.gd` 新增 `is_low_health_heartbeat_active_for_test()` 和 `get_low_health_heartbeat_timer_for_test()`，让烟测能读取持续状态。
- `AudioFeedbackSmokeTest` 扩展为验证进入低血启动 heartbeat、等待间隔后播放 `low_health_heartbeat`，恢复事件停止 heartbeat。
- 当前仍是程序化短音；后续应继续把心跳节奏和低血 vignette 脉冲同步，并替换为正式低血循环/分层音频资源。

## 第八十七批已落地靠拢改动

### 低血心跳严重程度变速第一版
- `Events.gd` 新增 `player_low_health_updated(current_hp, max_hp)`，让低血期间的 HP 变化能继续通知反馈系统。
- `Main._sync_low_health_warning_state()` 在已经处于低血且仍保持低血时发出 `player_low_health_updated`，进入和恢复边沿仍走原有事件。
- `AudioFeedback.gd` 新增 low-health heartbeat critical interval、low ratio 和 critical ratio，用当前 HP 比例把心跳间隔从常规低血的 0.72 秒缩短到濒死的 0.42 秒。
- `AudioFeedback` 订阅 `Events.player_low_health_updated`，只在 heartbeat 已激活时更新间隔，并压缩剩余计时，避免更新事件单独启动 heartbeat。
- `AudioFeedbackSmokeTest` 扩展为验证直接 `player_low_health_updated(1, 10)` 会缩短 heartbeat interval，并继续触发 `low_health_heartbeat`。
- `CombatFeedbackSmokeTest` 扩展为验证真实 HP 从 LOW 阈值降到 1 HP 时会缩短 heartbeat interval。
- 当前仍是程序化节奏调速；后续应继续让视觉 vignette 脉冲频率与音频 heartbeat interval 共用同一套严重程度参数。

## 第八十八批已落地靠拢改动

### 低血音画节奏同步第一版
- `HUD.gd` 新增 `LOW_HEALTH_VIGNETTE_CRITICAL_PULSE_SPEED` 和 `_low_health_vignette_pulse_speed`，让低血边缘脉冲速度不再固定。
- `HUD.update_health()` 继续使用当前 HP 比例更新低血 vignette 状态，并通过 `_get_low_health_vignette_pulse_speed()` 将脉冲速度从普通低血插值到濒死速度。
- `HUD.gd` 新增 `get_low_health_vignette_pulse_speed_for_test()`，让烟测能读取当前视觉脉冲速度。
- `CombatFeedbackSmokeTest` 扩展为验证真实 HP 从 LOW 阈值降到 1 HP 时，低血 vignette 目标 alpha、vignette pulse speed 和 heartbeat interval 会同步朝更紧张方向变化。
- 当前仍是程序化同步；后续应继续抽出共享低血严重程度模型，统一音频 heartbeat、vignette 脉冲、正式心跳资源和无障碍强度设置。

## 第八十九批已落地靠拢改动

### 共享低血严重程度模型第一版
- 新增 `scripts/core/LowHealthFeedback.gd`，集中定义 `LOW_RATIO`、`CRITICAL_RATIO`、低血阈值、HP 比例、critical weight 和按严重程度插值的静态 helper。
- `HUD.gd` 显式 preload `LowHealthFeedback`，低血判断、vignette target alpha 和 vignette pulse speed 改为使用共享 helper。
- `AudioFeedback.gd` 显式 preload `LowHealthFeedback`，heartbeat interval 计算改为使用共享 helper。
- 移除 HUD 和 AudioFeedback 各自维护的 LOW/critical ratio 常量，降低后续正式低血贴图、心跳资源和无障碍强度设置出现音画阈值漂移的风险。
- 当前仍只共享阈值和插值权重；后续可继续把低血反馈参数资源化，让 HUD、Audio、手柄震动和无障碍设置读取同一份配置。

## 第九十批已落地靠拢改动

### 低血反馈强度设置第一版
- `LowHealthFeedback.gd` 新增反馈强度默认值、上下限和夹取 helper，让低血视觉/听觉反馈共用同一套 0-100% 强度范围。
- HUD Settings 面板新增 `Low-Health Feedback` 滑条，默认 100%，Apply 后随其他设置保存到 `user://settings.cfg` 的 `gameplay` 分组。
- `Main.gd` 新增 `low_health_feedback_intensity` 设置读取、保存、摘要导出和同步路径，启动和设置变更时会同步到 HUD 与 AudioFeedback。
- `HUD.set_low_health_feedback_intensity()` 会缩放低血 vignette target alpha 和 pulse alpha；0% 会立即隐藏低血红边。
- `AudioFeedback.set_low_health_feedback_intensity()` 会缩放低血进入、心跳和恢复占位音量；0% 不会播放低血 SFX 或启动 heartbeat。
- `SettingsSmokeTest`、`AudioFeedbackSmokeTest` 和 `CombatFeedbackSmokeTest` 扩展为覆盖持久化、重载、UI 回显、音频禁用和 HUD 红边禁用。
- 当前仍是全局单档强度；后续可继续拆成视觉、音频和手柄震动独立强度，并在正式资源接入后重新调校默认值。

## 第九十一批已落地靠拢改动

### 屏幕震动强度设置第一版
- HUD Settings 面板新增 `Screen Shake` 滑条，默认 100%，Apply 后保存到 `user://settings.cfg` 的 `gameplay` 分组。
- `Main.gd` 新增 `screen_shake_intensity` 设置读取、保存、摘要导出和测试读取接口。
- `Main._add_shake()` 现在统一按屏幕震动强度缩放所有震动来源，包括命中、暴击、受击、清房、Boss 阶段和 Boss 死亡。
- 强度为 0% 时会清空当前 `_shake_strength` 和 camera offset，之后新的震动请求也会被抑制。
- `SettingsSmokeTest` 扩展为覆盖默认值、应用值、配置文件持久化、重载后 UI 回显和 Main 同步。
- `CombatFeedbackSmokeTest` 扩展为验证 0% 会抑制震动、50% 会把请求强度按比例缩放。
- 当前仍是全局单档震动；后续可按事件类型拆分命中/受击/Boss 震动曲线，并接入手柄震动强度。

## 第九十二批已落地靠拢改动

### 受击闪屏强度设置第一版
- HUD Settings 面板新增 `Damage Flash` 滑条，默认 100%，Apply 后保存到 `user://settings.cfg` 的 `gameplay` 分组。
- `Main.gd` 新增 `damage_flash_intensity` 设置读取、保存和摘要导出，启动和设置变更时同步到 HUD。
- `HUD.set_damage_flash_intensity()` 会缩放受击红色闪屏 alpha；0% 会立即清空当前闪屏并抑制新的受击闪屏。
- `SettingsSmokeTest` 扩展为覆盖默认值、应用值、配置文件持久化、重载后 UI 回显和 HUD 同步。
- `CombatFeedbackSmokeTest` 扩展为验证 0% 会关闭受击闪屏、50% 会把受击闪屏 alpha 按比例缩放。
- 当前仍是全局单档红色覆盖层；后续可按伤害来源、护甲破裂、致命伤和治疗后恢复拆分不同视觉反馈。

## 第九十三批已落地靠拢改动

### 战斗浮字强度设置第一版

- `Main.gd` 新增 `combat_text_intensity` gameplay 设置，支持默认值、加载、保存、摘要导出和测试接口。
- `_spawn_floating_text()` 现在会按设置缩放浮字 alpha；0% 会直接抑制伤害、暴击、治疗和护甲浮字生成。
- `FloatingText.gd` 新增文字颜色读取接口，`Main.get_floating_text_snapshots()` 会带出浮字颜色，方便烟测验证强度缩放。
- `HUD.gd` Settings 面板新增 `Combat Text` 滑条，Apply 时随音量、辅助瞄准、低血反馈、震屏和受击闪屏设置一起回传。
- `SettingsSmokeTest` 扩展为验证默认值、应用值、配置文件持久化、重载读取和 UI 回显。
- `CombatFeedbackSmokeTest` 扩展为验证 0% 抑制浮字，50% 会按比例缩放伤害浮字 alpha。
- 当前仍是统一全局浮字强度；后续可继续按 Boss 战、暴击、治疗、护甲和无障碍模式拆分更细的显示策略。

## 第九十四批已落地靠拢改动

### Armor 破裂反馈第一版

- `Events.gd` 新增 `player_shield_broken(absorbed_amount, current_shield)`，把 Armor 从有到无的瞬间纳入统一战斗反馈事件。
- `Player.take_damage()` 在 Armor 吸收伤害后归零时触发破甲事件，保留原有 `player_shield_absorbed` 和 HP 受伤事件语义。
- `Main.gd` 订阅破甲事件后会触发更强震动、显示 `Armor Broken` 消息，并在玩家附近生成 `ARMOR BREAK` 浮字。
- `HUD.gd` 新增 Armor break 脉冲状态，破甲时 Armor 行会短暂推向橙色，优先级高于 Armor 恢复脉冲。
- `AudioFeedback.gd` 新增 `armor_break` 程序化占位 SFX，让 Armor 完全破裂区别于普通挡伤。
- `CombatFeedbackSmokeTest` 扩展为验证真实破甲会出现 `ARMOR BREAK` 浮字和 HUD Armor break 脉冲，并会随时间结束。
- `AudioFeedbackSmokeTest` 扩展为验证破甲事件会播放 `armor_break` SFX。
- 当前仍是程序化颜色/文字/音效反馈；后续可继续接正式破甲碎裂动画、护甲图标破损状态和按伤害来源拆分的破甲音效。

## 第九十五批已落地靠拢改动

### 危险预警轮廓与脉冲可读性第一版

- `DangerWarning.gd` 新增通用 `Line2D` 轮廓层，圆形危险区和线形弹道/冲锋路线都会自动生成外轮廓。
- 预警填充不再单纯快速淡出，轮廓 alpha 会随预警进度轻微脉冲并在触发前保持更高可见度。
- `DangerWarning.tscn` 新增 `Outline` 节点，所有 Boss、精英死亡爆炸、陷阱、区域危险、远程弹道和冲锋路线预警共用同一可读性增强。
- `DangerWarning.gd` 新增测试读取接口，供烟测确认预警具备可读轮廓和 alpha 状态。
- `BossSmokeTest` 扩展为验证阶段转换和环形弹幕预警都具备可读轮廓。
- `EnemyVarietySmokeTest` 扩展为验证冲锋路线、散射弹道、区域危险和精英死亡爆炸预警都继承可读轮廓。
- 当前仍是程序化几何预警；后续可继续替换正式预警动画、按伤害类型/敌人类型分色，并补更明确的起手动作帧。

## 第九十六批已落地靠拢改动

### 危险预警差异化音效契约第一版

- `DangerWarning.configure_line()` 新增可选 `warning_damage` 和 `source` 参数，线形弹道/冲锋路线也会把威胁信息传入 `danger_warning_started`。
- `Enemy.gd` 的远程弹道前摇和冲锋路线预警现在会把 `attack_damage` 与自身作为来源传给 `DangerWarning`。
- `BossEnemy.gd` 的线形 Boss 预警现在同样会把 `attack_damage` 和 Boss 来源传给 `DangerWarning`。
- `AudioFeedback.gd` 新增 `danger_warning_line` 与 `danger_warning_heavy` 程序化占位 SFX，并保留默认 `danger_warning`。
- `AudioFeedback` 现在按 `shape_name`、`duration` 和 `damage` 解析危险预警音效：线形优先走 `danger_warning_line`，高伤害或长前摇圆形走 `danger_warning_heavy`。
- `AudioFeedbackSmokeTest` 扩展为验证默认圆形、线形、长前摇重威胁和高伤害重威胁的 SFX key 分流，并新增危险预警冷却重置测试接口。
- 当前仍是程序化占位音；后续应继续把这些 key 替换为正式资源，并按 Boss 阶段、陷阱房、精英死亡爆炸和敌人类型继续细分混音层次。

## 第九十七批已落地靠拢改动

### 训练奖励 toast 动画第一版

- `HUD.gd` 新增 `TrainingRewardToast` 动态面板，在训练 drill 获得更高徽章时弹出独立奖励提示。
- toast 使用固定尺寸、标题 `TRAINING BADGE`、drill 名、评级文本和徽章 token，避免继续只依赖训练面板中的一行文字。
- toast 具备短暂淡入、保持和淡出，并带轻微 scale pulse，作为正式训练奖励演出前的可测试占位动画。
- `HUD.update_training_stats()` 会消费现有 `badge_notice_text` 自动触发 toast；训练重置或空 notice 会关闭 toast，避免残留上一轮奖励提示。
- `HUD.gd` 新增训练奖励 toast 测试读取接口，供烟测检查可见性、标题、正文和 alpha。
- `TrainingRoomSmokeTest` 扩展为验证 Burst Clean 徽章解锁后出现奖励 toast，且训练重置后 toast 隐藏。
- 当前仍是 HUD toast 占位演出；后续应继续接正式徽章图标、分 drill 奖励说明、粒子/音效收束和 Outpost Hall 内的奖励回看。

## 第九十八批已落地靠拢改动

### 内容资源 icon_key 占位契约第一版
- `RelicData`、`PlayerCharacterData`、`TalentData` 和 `BlessingData` 新增 `icon_key` 导出字段，和既有 `WeaponData.icon_key` 对齐，为正式图标素材接入保留统一入口。
- `Main.gd` 新增 `_resolve_content_icon_key()`，大厅 summary 会为角色、武器、遗物、天赋和祝福输出稳定 `icon_key`；资源显式配置时优先使用资源值，未配置时按 `类型_id` 派生兜底。
- `LobbyScreen.gd` 的 `CodexDetailCard` 继续保留 WPN/REL/TAL/BLS 页签徽标，但会把当前条目的 `icon_key` 写入详情卡 tooltip，并通过 `get_codex_detail_icon_key()` 暴露给烟测。
- `ContentPipelineSmokeTest` 扩展为校验五类内容资源脚本都暴露 `icon_key` 字段，并验证所有现有资源都能解析出对应类型前缀的稳定图标 key。
- `LobbyScreenSmokeTest` 扩展为验证武器、遗物、天赋和祝福详情卡均能读到资源级 `icon_key`，且筛选切换后 key 会跟随当前详情条目变化。
- 当前仍不引入外部美术素材；后续正式图标落地时可以把这些 key 映射到 Atlas/Texture2D，同时保留 token/tooltip 作为调试和无障碍辅助信息。

## 第九十九批已落地靠拢改动

### CodexDetailCard 图标注册表与色块槽第一版
- 新增 `ContentIconRegistry.gd`，集中把 `weapon_`、`relic_`、`talent_`、`blessing_` 和 `character_` 前缀解析为类型 token、占位颜色、tooltip 和 placeholder 状态。
- `LobbyScreen.tscn` 在 `CodexDetailVisualRow` 新增 `CodexDetailIconSwatch` 24x24 色块，让详情卡具备真实图标素材前的固定视觉槽位。
- `LobbyScreen.gd` 改为通过 `ContentIconRegistry` 设置详情卡 token、色块颜色和 tooltip，并暴露 `get_codex_detail_icon_swatch_color()` / `get_codex_detail_icon_tooltip_text()` 供烟测验证。
- 移除旧的 `_get_codex_page_icon_token()`，避免图标 token 来源在后续正式 Atlas 接入时分叉。
- `ContentPipelineSmokeTest` 扩展为验证注册表能解析武器/遗物 token、识别天赋 placeholder icon，并为祝福返回非 fallback 色彩。
- `LobbyScreenSmokeTest` 扩展为验证武器、遗物、天赋和祝福详情卡的图标色块来自注册表，且 tooltip 会携带当前条目的 `icon_key`。
- 当前仍是程序化色块，不是正式图标贴图；下一步正式化时可把 `ContentIconRegistry` 扩展为 `icon_key -> Texture2D/Atlas region` 映射，保留色块作为缺失素材 fallback。

## 第一百批已落地靠拢改动

### 内容图标默认映射资源表第一版
- 新增 `ContentIconDefinitionData.gd` 和 `ContentIconRegistryData.gd`，把图标定义从纯代码常量推进为可编辑资源结构。
- 新增 `resources/ui/content_icon_registry.tres`，集中引用五类默认图标定义：weapon、relic、talent、blessing 和 character。
- 新增 `resources/ui/content_icons/*_default.tres`，每类定义稳定 token、占位颜色、无障碍说明、预留 `texture_path` 和 `atlas_region`。
- `ContentIconRegistry.gd` 现在优先读取默认映射资源；若资源缺失或具体 key 未配置，则继续按 `icon_key` 前缀和页签推断类型，保留可用 fallback。
- 注册表新增 `get_texture_path()`、`get_atlas_region()`、`get_registered_icon_count()`、`has_definition_for_type()` 和 `get_icon_definition()`，为后续正式 Atlas/Texture2D 接入保留测试入口。
- `ContentPipelineSmokeTest` 扩展为验证默认映射表可加载、五类默认定义齐全、空 texture 路径可被接受、Atlas region placeholder 可读取。
- 当前仍没有正式贴图素材；这批完成的是“图标 key -> 可编辑映射资源 -> UI fallback 色块”的中间层，后续只需逐步填入真实贴图路径或 Atlas 区域。

## 第一百零一批已落地靠拢改动

### 默认内容 SVG 图标与详情卡贴图槽第一版
- 新增五个原创默认 SVG 图标：`default_weapon.svg`、`default_relic.svg`、`default_talent.svg`、`default_blessing.svg` 和 `default_character.svg`，放在 `art/ui/content_icons/`。
- 五个默认 `ContentIconDefinitionData` 资源的 `texture_path` 现在指向对应 SVG，让默认映射表不再只是色块和 token。
- `LobbyScreen.tscn` 在详情卡视觉行新增 `CodexDetailIconTexture`，作为正式图标贴图显示槽。
- `LobbyScreen.gd` 新增 `get_codex_detail_icon_texture_path()` 和 `is_codex_detail_icon_texture_visible()`，详情卡会优先加载注册表 `texture_path`；贴图缺失或加载失败时回落到 `CodexDetailIconSwatch` 色块。
- `ContentPipelineSmokeTest` 扩展为验证五类默认 icon path 都指向 `res://art/ui/content_icons/default_...` 且可被 `ResourceLoader` 解析。
- `LobbyScreenSmokeTest` 扩展为验证图鉴详情卡公开注册表贴图路径，并在默认贴图可用时显示 TextureRect。
- 当前仍是类型级默认图标，不是每把武器/每个遗物的专属图标；后续可以逐步为高频条目增加具体 `icon_key` definition，或者把 SVG 替换为像素风 Atlas region。

## 第一百零二批已落地靠拢改动

### 高频图鉴条目专属 SVG 图标第一版
- 新增五个原创条目级 SVG 图标：`basic_pistol.svg`、`arc_blade.svg`、`sharp_rounds.svg`、`steady_hands.svg` 和 `deep_cell.svg`。
- 新增五个条目级 `ContentIconDefinitionData` 资源，分别绑定 `weapon_basic_pistol`、`weapon_arc_blade`、`relic_sharp_rounds`、`talent_steady_hands` 和 `blessing_deep_cell`。
- `content_icon_registry.tres` 的 definitions 从五类默认扩展到十项，并把条目级 definition 放在默认 definition 之前，确保具体 key 优先匹配。
- `ContentPipelineSmokeTest` 扩展为验证这些高频 key 使用条目专属图标而非默认 `default_` 图标，同时继续验证未映射 key 会回落到默认图标。
- `LobbyScreenSmokeTest` 扩展为验证 Basic Pistol、Arc Blade、Sharp Rounds、Steady Hands 和 Deep Cell 的详情卡会显示对应专属 SVG 路径。
- 当前仍是少量高频条目，不是完整内容池图标覆盖；后续可按图鉴访问频率继续补武器、遗物、天赋、祝福和角色专属图标，或迁移到统一像素风 Atlas。

## 第一百零三批已落地靠拢改动

### 高频图鉴条目专属 SVG 图标第二批
- 新增四个原创条目级 SVG 图标：`snare_beacon.svg`、`anchor_spool.svg`、`iron_vow.svg` 和 `quiet_plate.svg`。
- 新增四个条目级 `ContentIconDefinitionData` 资源，分别绑定 `weapon_snare_beacon`、`relic_anchor_spool`、`talent_iron_vow` 和 `blessing_quiet_plate`。
- `content_icon_registry.tres` 的 definitions 从十项扩展到十四项，继续保持条目级 definition 排在默认 definition 前，保证具体 key 优先。
- `ContentPipelineSmokeTest` 扩展为验证第二批高频 key 使用专属 SVG，且未映射 probe key 仍会回落到默认图标。
- `LobbyScreenSmokeTest` 扩展为验证 Snare Beacon 搜索、Anchor Spool 部署路线、Iron Vow 生存路线和 Quiet Plate 生存路线会驱动详情卡切换到对应专属图标。
- 这批继续覆盖图鉴 Featured Card 和筛选/搜索路径中最常出现的条目；后续可继续向角色页、更多武器流派和遗物 Build 路线扩展。

## 第一百零四批已落地靠拢改动

### 角色选择图标贴图槽第一版
- `LobbyScreen.tscn` 在当前角色文本上方新增 `CurrentCharacterIconRow`，包含角色图标贴图槽、色块 fallback 和 `CHR` token。
- `LobbyScreen.gd` 复用 `ContentIconRegistry` 从大厅 summary 的 `current_character_id` 和角色 `icon_key` 解析当前角色图标，并暴露当前角色图标 key、贴图路径、可见状态、色块颜色和 tooltip 测试接口。
- 新增 6 个原创角色 SVG：`wanderer.svg`、`warden.svg`、`arcanist.svg`、`rift_runner.svg`、`emberwright.svg` 和 `field_medic.svg`。
- 新增对应 6 个 `ContentIconDefinitionData` 资源，分别绑定 `character_wanderer`、`character_warden`、`character_arcanist`、`character_rift_runner`、`character_emberwright` 和 `character_field_medic`。
- `ContentIconRegistry.gd` 的未命中回退现在优先同类型默认 definition，避免新增条目级图标后未映射 key 错误落到第一个专属图标。
- `ContentPipelineSmokeTest` 扩展为验证 6 个角色专属图标路径不会回落到 `default_`，同时保留未映射角色/武器 key 回默认图标的约束。
- `LobbyScreenSmokeTest` 扩展为验证默认 Wanderer 和切换后的 Rift Runner 都能驱动当前角色图标槽显示对应专属 SVG。

## 第一百零五批已落地靠拢改动

### 局内三选一奖励按钮图标第一版
- `HUD.gd` 在遗物、Boss 后天赋和事件祝福三类选择面板中复用 `ContentIconRegistry`，给每个选项按钮设置注册表贴图。
- 选择按钮会优先使用资源显式 `icon_key`，空值时按 `relic_<id>`、`talent_<id>` 或 `blessing_<id>` 派生，再由注册表决定专属 SVG 或类型默认 SVG。
- 选择按钮 tooltip 会附加注册表图标说明，保留 display name、稀有度、标签和描述信息的同时暴露当前 icon key。
- `HUD.gd` 新增 `get_relic_choice_icon_key()`、`get_relic_choice_icon_texture_path()`、`is_relic_choice_icon_visible()` 和 `get_relic_choice_icon_tooltip_text()` 测试接口，当前命名沿用既有 relic choice 面板，但覆盖 relic/talent/blessing 三类。
- `RelicSmokeTest` 扩展为验证奖励房遗物三选一按钮的 icon key、注册表贴图路径、可见状态和 tooltip。
- `TalentSmokeTest` 扩展为验证 Boss 后天赋三选一按钮同样由注册表驱动图标。
- `EventRoomSmokeTest` 扩展为验证事件祝福三选一按钮同样由注册表驱动图标。

## 第一百零六批已落地靠拢改动

### 小地图特殊房间 icon token 第一版
- `HUD.gd` 的小地图房间标记从单纯内部 `room_type` 字母，升级为稳定 icon token、玩家可读房型 label 和状态 tooltip。
- Reward、Event、Armory、Healing、Shop、Elite、Challenge、Trap 和 Boss 等房型现在有更明确的 token：例如 `*`、`!`、`W`、`+`、`$`、`EL`、`CH`、`X`、`B`。
- 小地图 tooltip 现在显示 biome、房间 ID、玩家可读房型和状态（Current / Cleared / Visited / Unvisited），减少调试字段直接暴露给玩家。
- `HUD.gd` 新增 `get_minimap_marker_icon_for_type()`、`get_minimap_marker_label_for_type()` 和 `get_minimap_marker_tooltip_for_type()`，供后续把 token 替换为正式贴图时保持测试契约。
- `DungeonGenerationSmokeTest` 扩展为验证已生成房型的小地图 token、房型 label 和 tooltip 语义；这批不改变地牢生成，只增强可读性。

## 第一百零七批已落地靠拢改动

### 当前武器槽注册表贴图第一版
- `HUD.tscn` 在当前武器槽身份行新增 `WeaponSlotIconTexture`，让战斗 HUD 当前武器不再只依赖类型短码。
- `Main.gd` 的玩家武器 loadout summary 现在携带武器 `id` 和 `icon_key`，让 HUD 能沿用和图鉴、奖励选择一致的内容图标契约。
- `HUD.gd` 通过 `ContentIconRegistry.get_texture_path(icon_key, "weapons")` 解析当前武器贴图；加载到 `Texture2D` 时显示贴图并隐藏短码，缺失时保留原类型短码 fallback。
- 当前槽 tooltip 会合并武器名、稀有度、类型、距离、能耗和注册表图标说明，方便调试和后续无障碍文本复用。
- `WeaponSmokeTest` 扩展为验证开局、切换武器后的当前槽 icon key、注册表贴图路径、可见状态和 tooltip。
- `ShopSmokeTest` 扩展为验证购买武器后，HUD 负载预览和当前槽图标贴图同步新武器。

## 第一百零八批已落地靠拢改动

### 三武器负载预览注册表贴图第一版
- `HUD.tscn` 把 `WeaponSlotLoadoutRow` 下的 1/2/3 槽从纯文本 Label 升级为 `HBoxContainer + TextureRect + Label`，每槽都具备 14px 武器图标位。
- `HUD.gd` 的三槽负载刷新现在为每个槽解析 `icon_key -> ContentIconRegistry.get_texture_path(icon_key, "weapons")`，加载成功时显示注册表贴图，文本短名继续保留作为可读 fallback。
- 动态扩展负载槽时也会创建同样的图标/文本结构，避免后续增加第 4 槽或调试槽时回到纯文本路径。
- `get_weapon_slot_loadout_summary_for_test()` 新增 `icon_keys`、`icon_texture_paths`、`icon_texture_visible` 和 `tooltips`，让三槽图标契约可被烟测读取。
- `WeaponSmokeTest` 扩展为验证开局 slot 1、切换到 slot 2 后的三槽预览图标 key、注册表贴图路径和可见状态。
- `ShopSmokeTest` 扩展为验证购买武器后，当前激活的负载槽图标 key、注册表贴图路径和可见状态同步新武器。

## 第一百零九批已落地靠拢改动

### 武器槽图标 ready/switch 脉冲第一版
- `HUD.gd` 新增统一的武器槽图标 `modulate` 计算：当前槽正常白色，非当前槽降低透明度，切槽脉冲偏黄，换弹完成 ready 脉冲偏绿。
- 当前武器大图标和三武器负载预览小图标共用这套颜色反馈，避免文本、边框、弹匣段和图标反馈语义分叉。
- `_process()` 的 ready/switch 计时器刷新现在会同步刷新图标颜色，不需要额外计时器。
- `get_weapon_slot_visual_summary_for_test()` 新增 `icon_modulate`，`get_weapon_slot_loadout_summary_for_test()` 新增 `icon_modulates`，供烟测读取图标脉冲状态。
- `WeaponSmokeTest` 扩展为验证切换武器时当前图标和激活负载槽图标偏黄，换弹完成时当前图标和激活负载槽图标偏绿。

## 第一百一十批已落地靠拢改动

### 三槽负载预览槽框第一版
- `HUD.tscn` 把 `WeaponSlotLoadoutRow` 下的 1/2/3 槽从 `HBoxContainer` 升级为 `PanelContainer`，内部保留 `LoadoutSlotIcon` 和 `LoadoutSlotLabel`，为每槽独立背景和边框留出承载位。
- `HUD.gd` 为每个负载槽创建独立 `StyleBoxFlat`，用暗色底、稀有度边框和当前槽粗边框增强扫描性。
- 当前槽边框会跟随切槽脉冲偏黄、换弹完成 ready 脉冲偏绿，和主武器槽边框、图标、弹匣段反馈保持一致。
- 动态新增负载槽也会走同样 `PanelContainer + MarginContainer + HBoxContainer` 结构，避免未来扩展槽位时回退到纯文本样式。
- `get_weapon_slot_loadout_summary_for_test()` 新增 `slot_border_colors`、`slot_border_widths` 和 `slot_background_colors`，供烟测读取槽框状态。
- `WeaponSmokeTest` 扩展为验证开局当前槽粗边框、非当前槽轻边框、切槽黄边框和 ready 绿边框；`ShopSmokeTest` 扩展为验证购买武器后激活负载槽边框仍可读。

## 第一百一十一批已落地靠拢改动

### 三槽负载弹药摘要第一版
- `Main.gd` 的玩家 loadout summary 新增 `magazine_size`、`current_ammo`、`is_reloading` 和 `is_active` 字段；当前槽写入真实 `Weapon` 节点弹药状态，非当前槽只写容量信息。
- `HUD.gd` 在三槽负载文本中追加短弹药摘要：当前槽显示 `当前弹药/弹匣` 或 `RLD`，非当前槽显示 `M弹匣/E能耗`。
- `HUD.update_ammo()` 会同步当前负载 entry 并刷新三槽预览，让开火、打空、换弹中和换弹完成都能更新当前槽摘要。
- Tooltip 现在补充 `Ammo x/y`、`Reloading` 或 `Magazine x, energy y`，避免只靠短码理解槽位状态。
- 这批不伪造非当前槽独立弹药；当前架构仍是单个 `Weapon` 节点，切槽会重新配置武器数据。未来若改为每槽独立武器实例，可把非当前槽从容量摘要升级为真实离手弹药。
- `get_weapon_slot_loadout_summary_for_test()` 新增 `ammo_summaries`，`WeaponSmokeTest` 覆盖开局、换弹中和换弹完成摘要，`ShopSmokeTest` 覆盖购买武器后满弹摘要。

## 第一百一十二批已落地靠拢改动

### 三槽负载能量可用性提示第一版
- `HUD.gd` 为每个负载槽新增 `free`、`ready`、`blocked`、`empty` 能量状态：零能耗武器标为 `free`，当前能量足够时为 `ready`，不足时为 `blocked`。
- `update_energy()`、`show_energy_warning()` 和 warning 计时淡出都会刷新三槽负载行，让能量恢复或不足提示能立即反映到切槽预览。
- 负载槽 tooltip 补充 `Free to fire`、`Energy ready 当前/消耗` 或 `Need N energy`，低能量时槽文字和背景轻微偏向警示色。
- `get_weapon_slot_loadout_summary_for_test()` 新增 `energy_states`、`energy_needs` 和 `label_colors`，`WeaponSmokeTest` 覆盖低能量 blocked、恢复 ready、tooltip Need 和警示色，`ShopSmokeTest` 覆盖购买武器后的可用能量状态。

## 第一百一十三批已落地靠拢改动

### 早期武器专属 SVG 图标包第一版
- 新增 8 个原创 64px SVG 武器图标：`shotgun`、`energy_staff`、`ricochet_blaster`、`nova_core`、`blast_launcher`、`laser_lance`、`coil_carbine`、`shatter_fan`。
- 新增对应 `ContentIconDefinitionData` 资源，并接入 `content_icon_registry.tres`；注册表专属武器图标从 3 个提升到 11 个，默认三槽负载不再只有 Basic Pistol 有专属贴图。
- `ContentPipelineSmokeTest` 将注册表计数门槛提升到 28，并验证新增武器图标全部走 `art/ui/content_icons` 的专属路径。
- `WeaponSmokeTest` 新增默认负载 slot 2/3 断言，确认 Shotgun 和 Energy Staff 在 HUD 三槽负载预览中使用专属图标。

## 第一百一十四批已落地靠拢改动

### 中期武器专属 SVG 图标包第一版
- 新增 8 个原创 64px SVG 武器图标：`storm_fan`、`prism_ray`、`halo_kernel`、`ember_sprayer`、`frost_sickle`、`slag_comet`、`guard_cleaver`、`riposte_saber`。
- 新增对应 `ContentIconDefinitionData` 资源，并接入 `content_icon_registry.tres`；注册表专属武器图标从 11 个提升到 19 个。
- `ContentPipelineSmokeTest` 将注册表计数门槛提升到 36，并验证新增中期武器图标全部走 `art/ui/content_icons` 的专属路径。
- 这批继续保持 SVG 图标为原创几何风格和占位级视觉，不复制任何参考作品武器造型；后续仍需为剩余武器补齐图标与正式美术。

## 第一百一十五批已落地靠拢改动

### 全武器专属 SVG 图标覆盖第一版
- 新增 11 个原创 64px SVG 武器图标：`bulwark_fan`、`cinder_mortar`、`coil_bow`、`ember_mine`、`mirror_sickle`、`orbit_sower`、`pulse_needler`、`rift_spear`、`sentry_seed`、`storm_capacitor`、`vault_lance`。
- 新增对应 `ContentIconDefinitionData` 资源，并接入 `content_icon_registry.tres`；30 把武器现在都有专属 SVG 图标，注册表定义总数提升到 47。
- `ContentPipelineSmokeTest` 将注册表计数门槛提升到 47，并验证剩余武器图标全部走 `art/ui/content_icons` 的专属路径。
- 这仍是可读 UI 图标层，不等同于战斗内正式动画/像素角色资产；后续仍要补正式武器模型、弹道视觉、音效和手感 polish。

## 第一百一十六批已落地靠拢改动

### 早期遗物专属 SVG 图标包第一版
- 新增 8 个原创 64px SVG 遗物图标：`quick_trigger`、`split_chamber`、`phase_tip`、`vampire_fang`、`guardian_ward`、`adrenaline_charm`、`lucky_primer`、`swift_loader`。
- 新增对应 `ContentIconDefinitionData` 资源，并接入 `content_icon_registry.tres`；遗物专属 SVG 图标覆盖从 2 个提升到 10 个，优先覆盖早期奖励和原始遗物池中的高频条目。
- `ContentPipelineSmokeTest` 将注册表计数门槛提升到 55，并验证新增遗物图标全部走 `art/ui/content_icons` 的专属路径，同时补充未映射遗物 key 回落默认图标的契约。
- 这批继续解决局外图鉴、奖励三选一和 Build 路线扫描中的图标可读性；剩余遗物、天赋和祝福仍需继续补专属图标。

## 第一百一十七批已落地靠拢改动

### 扩展遗物专属 SVG 图标包第一版
- 新增 8 个原创 64px SVG 遗物图标：`keen_sights`、`hollow_needle`、`scatter_lens`、`field_rations`、`bulwark_plate`、`redline_boots`、`breach_powder`、`momentum_coil`。
- 新增对应 `ContentIconDefinitionData` 资源，并接入 `content_icon_registry.tres`；遗物专属 SVG 图标覆盖从 10 个提升到 18 个，覆盖暴击、贯穿、多弹丸、击杀回血、清房护甲、受伤加速、伤害和射速路线。
- `ContentPipelineSmokeTest` 将注册表计数门槛提升到 63，并验证新增扩展遗物图标全部走 `art/ui/content_icons` 的专属路径。
- 这批继续减少奖励三选一和图鉴 Build 路线中的默认遗物图标占比；后续可继续补状态、挡弹、蓄力和部署专精遗物图标。

## 第一百一十八批已落地靠拢改动

### 中段遗物专属 SVG 图标包第一版
- 新增 9 个原创 64px SVG 遗物图标：`steady_capacitor`、`gilded_tip`、`echo_chamber`、`breakwater_guard`、`siphon_clasp`、`kinetic_ram`、`volatile_oil`、`ember_catalyst`、`lingering_ash`。
- 新增对应 `ContentIconDefinitionData` 资源，并接入 `content_icon_registry.tres`；遗物专属 SVG 图标覆盖从 18 个提升到 27 个，覆盖射速、暴击、多弹丸、护甲、吸血、近战伤害、状态概率、状态伤害和状态持续路线。
- `ContentPipelineSmokeTest` 将注册表计数门槛提升到 72，并验证新增中段遗物图标全部走 `art/ui/content_icons` 的专属路径。
- 这批继续提高奖励三选一和图鉴 Build 路线的视觉区分度；剩余遗物主要集中在挡弹、蓄力和部署专精路线。

## 第一百一十九批已落地靠拢改动

### 全遗物专属 SVG 图标覆盖第一版
- 新增 8 个原创 64px SVG 遗物图标：`parry_grip`、`warding_hinge`、`counterweight_core`、`draw_weight`、`quick_windup`、`stored_spark`、`tripwire_amplifier`、`heart_core`。
- 新增对应 `ContentIconDefinitionData` 资源，并接入 `content_icon_registry.tres`；35 个遗物现在都有专属 SVG 图标，注册表定义总数提升到 80。
- `ContentPipelineSmokeTest` 将注册表计数门槛提升到 80，并验证剩余遗物图标全部走 `art/ui/content_icons` 的专属路径。
- 这批完成当前武器池和遗物池的专属 UI 图标覆盖；后续图标工作应转向天赋、祝福、房间、敌人和正式像素/Atlas 美术。

## 第一百二十批已落地靠拢改动

### 天赋/祝福专属 SVG 图标补齐第一版
- 新增 2 个原创 64px SVG 条目图标：`kinetic_rounds` 和 `ember_tithe`。
- 新增对应 `ContentIconDefinitionData` 资源，并接入 `content_icon_registry.tres`；当前 3 个天赋、3 个祝福、6 个角色、30 把武器和 35 个遗物都已有条目级 SVG 图标覆盖，注册表定义总数提升到 82。
- `ContentPipelineSmokeTest` 将注册表计数门槛提升到 82，并验证新增天赋/祝福图标全部走 `art/ui/content_icons` 的专属路径。
- 这批完成当前核心内容条目的 UI 图标覆盖第一版；后续应继续补房间、敌人、Boss、训练和正式像素/Atlas 图标资产。

## 第一百二十一批已落地靠拢改动

### 房间类型 SVG 图标注册表第一版
- 新增 12 个原创 64px 房间类型 SVG 图标，覆盖默认房间、起点、战斗、精英、挑战、陷阱、奖励、事件、武器房、治疗房、商店和 Boss 房。
- `ContentIconRegistry` 支持 `room` content_type，并接入 12 个 `ContentIconDefinitionData` 房间图标定义；注册表定义总数提升到 94。
- HUD 小地图 marker 保留现有 token 显示，同时暴露稳定的 `room_icon_key` 和 `room_icon_texture_path`，为后续正式贴图替换保留数据契约。
- `ContentPipelineSmokeTest` 和 `DungeonGenerationSmokeTest` 扩展为校验房间图标注册、默认 fallback、每类小地图房间 token、label、tooltip、icon key 和 SVG 路径。

## 第一百二十二批已落地靠拢改动

### 小地图房间 SVG 贴图 marker 第一版
- HUD 小地图 marker 从纯 `Label` 升级为 `PanelContainer + TextureRect + fallback Label`，优先显示注册表中的 `room_*` SVG 图标。
- 现有 token、房型 label、状态和 tooltip metadata 保留；当贴图加载失败时仍会显示原 token，避免房间可读性断裂。
- 当前房间、已清理、已访问和未访问状态现在通过 marker 边框、底色和图标透明度区分，为后续正式像素小地图图标提供第一版视觉结构。
- `DungeonGenerationSmokeTest` 扩展为校验小地图房间 SVG texture 可见性，确保图标注册不只停留在路径层面。

## 第一百二十三批已落地靠拢改动

### Biome 房间视觉主题第一版
- `BiomeData` 新增 `visual_floor_tint`、`visual_wall_color`、`visual_obstacle_tint`、`visual_accent_color` 和 `visual_tint_strength`，让三层主题不只停留在敌人池和名称上。
- `outer_warrens`、`iron_catacombs` 和 `void_foundry` 分别配置独立的地板 tint、墙体色、障碍 tint 和 accent 色，形成第一版层级视觉差异。
- `DungeonController` 将 biome 视觉字段写入房间 record、biome summary 和运行时 `CombatRoom` 属性。
- `CombatRoom` 在应用布局时把布局地板色与 biome floor tint 混合，并把墙体、障碍颜色按 biome 主题重染；同时暴露 `get_biome_visual_summary()` 供烟测验证。
- `ContentPipelineSmokeTest` 和 `DungeonGenerationSmokeTest` 扩展为校验 biome 视觉字段完整、唯一 color key、record/runtime/summary 一致，以及地板实际应用 tint 后的颜色。

## 第一百二十四批已落地靠拢改动

### Biome 独立布局池第一版
- `outer_warrens`、`iron_catacombs` 和 `void_foundry` 分别配置 4 个 `RoomLayoutData` 引用，形成外层开阔交火、中层掩体窄口、终层伏击长线压力的第一版布局差异。
- `DungeonController` 在普通战斗、精英和挑战房间优先合并当前 Biome 的 `layout_pool`，并在 Biome 池耗尽后回退到全局房型池。
- 奖励、事件、治疗、商店、陷阱和 Boss 房继续使用专用布局池，避免功能房间因为主题差异降低识别度。
- 房间 record、biome summary 和 debug map 现在暴露 `biome_layout_pool_ids`，便于复现路线和确认某个房间来自哪一层布局配置。
- `ContentPipelineSmokeTest` 和 `DungeonGenerationSmokeTest` 扩展为校验三层布局池资源、summary 保留布局池 ID，以及战斗类房间会优先使用当前层布局池。

## 第一百二十五批已落地靠拢改动

### Biome 奖励权重接线第一版
- `DungeonController` 现在把 `BiomeData.reward_weight_multiplier` 写入房间 record、biome summary、debug map 和运行时 `CombatRoom`。
- `CombatRoom` 生成奖励对象前会把当前层的 biome id、名称和奖励倍率写入宝箱、商店、奖励房遗物拾取和事件神龛。
- `RewardChest`、`ShopInventory`、`RelicPickup` 和 `EventShrine` 都开始暴露 `get_biome_reward_summary()`，并在金币、武器、遗物或祝福选择中使用当前层奖励倍率。
- `RelicSystem` 和 `BlessingSystem` 的实际抽取权重现在会乘上资源自身 `drop_weight`，并用 biome 奖励倍率轻微提高 rare、epic、legendary 的相对权重。
- `ContentPipelineSmokeTest`、`DungeonGenerationSmokeTest`、`ChestSmokeTest`、`ShopSmokeTest`、`EventRoomSmokeTest` 和 `RelicSmokeTest` 扩展为校验 Biome 奖励倍率配置、传递和权重计算。

## 第一百二十六批已落地靠拢改动

### 小地图按层展示第一版
- HUD 小地图从单行串联 marker 调整为按 `biome_index` 生成独立层段，每段包含层标题和本层房间 marker 行。
- 小地图 marker 保留原有 SVG 房间图标、状态颜色、当前房间高亮和 tooltip，同时额外记录 `biome_index` / `biome_name` metadata。
- HUD 新增 `get_minimap_biome_layer_count()`、`get_minimap_marker_count_for_biome()`、`get_minimap_biome_layer_text()` 和 `get_minimap_biome_layer_tooltip()` 测试访问器。
- `DungeonGenerationSmokeTest` 扩展为校验小地图必须渲染 3 个 Biome 层段、每段房间数与生成记录一致，并且层标题/tooltip 保留 Biome 显示名。

## 第一百二十七批已落地靠拢改动

### 结算路线与 Build 快照第一版
- `Main.gd` 的结算摘要新增 `route_nodes`、`route_signature`、`visited_route_signature`、`boss_route`、`defeated_boss_names`、`reached_biome_name`、`build_route_counts`、`primary_build_routes` 和 `primary_build_route_text`。
- 路线快照复用 `DungeonController.get_room_records()`，记录每个生成房间的 ID、Biome、房型、主线/分支、Boss 标记、访问/清理状态和 Boss 显示名。
- 主要 Build 路线从玩家武器 `tags`、遗物/天赋/祝福 `build_tags` 汇总，过滤 starter 标签后按出现次数生成结算用路线摘要。
- `RelicSystem.get_relic_summaries()` 现在暴露遗物 `build_tags`、`conflict_tags` 和 `tags`，让结算和后续统计能识别遗物构筑方向。
- HUD 结算总览新增 `Route`、到达 Biome 名称、Boss 名称列表和 `Build Routes`，保持原有 6 个分组面板结构不变。
- `RunSummarySmokeTest` 扩展为校验结算必须包含 seed、三层路线签名、Boss 路线、击败 Boss 名称、Build 标签计数和 HUD 结果文本。

## 第一百二十八批已落地靠拢改动

### AimAssistController 锁定权重第一版
- `AimAssistController.gd` 新增 `lock_weight`、锁定目标、候选目标评分、清锁和当前锁定目标访问接口，辅助瞄准不再只按每帧角度/距离硬切目标。
- `pick_target()` 会在候选目标仍有效时给当前锁定目标额外评分，减少相近敌人之间的目标抖动；目标失效、离开候选列表或清锁后会回到评分优先。
- `Player.configure_aim_assist()` 新增兼容的 `lock_weight` 参数，现有设置路径仍可只传开关、强度、距离和角度。
- `AimAssistSmokeTest` 扩展为校验 Player 能传递锁定权重、未锁定时选择最佳角度目标、锁定后保持附近锁定目标、清锁后恢复评分选择。
- `ContentPipelineSmokeTest` 扩展为校验 `AimAssistController` 公开候选评分、锁定目标、清锁和锁定权重契约。

## 第一百二十九批已落地靠拢改动

### 事件房商人折扣结果第一版
- `EventShrine` 新增 `reward_mode`，默认仍保留原来的祝福选择，并可配置为 `relic_choice` 或 `shop_discount`。
- 商人折扣事件会在献祭生命后给玩家一次性商店折扣，形成“当前生命风险 -> 后续经济收益”的事件房结果。
- `Player` 新增一次性商店折扣状态和价格计算接口；`ShopItem` 购买时按具体玩家计算成交价，成功购买后才消耗折扣。
- 商店物品靠近显示会展示折扣价和原价，未带折扣时继续显示原始价格，避免破坏现有商店经济契约。
- `EventRoomSmokeTest` 扩展为校验商人折扣事件结算、玩家折扣状态、折扣购买价格和购买后消耗。

## 第一百三十批已落地靠拢改动

### 事件房随机结果池与诅咒武器第一版
- `EventShrine` 新增 `event_variant`，场景默认使用 `random`，可在 `Blood Pact`、`Merchant Oath` 和 `Cursed Armory` 三类原创事件间选择。
- `Cursed Armory` 会在献祭生命后额外降低本局最大生命值，并从事件武器池中给玩家一把武器，形成“诅咒代价换武器”的风险收益结果。
- `Player` 新增事件诅咒摘要，记录事件诅咒 ID、数量和最大生命惩罚，且角色重置时清空本局诅咒。
- `EventRoomSmokeTest` 扩展为强制校验诅咒武器事件；`FullRunSmokeTest` 改为读取事件摘要，按祝福、折扣或诅咒武器分别验证真实随机事件结果。
- 事件房从单一 Blood Pact 推进为实战路线会自然出现多结果的事件池，但仍保留手动锁定变体的测试入口。

## 第一百三十一批已落地靠拢改动

### 挑战房变体第一版
- `RoomData` 和 `CombatRoom` 新增 `challenge_variant` 与 `challenge_variant_label`，挑战房不再只有固定精英 Gauntlet 配置。
- `DungeonController` 会在生成阶段按 seed、房间索引和 biome 解析 `random` 挑战变体，并把结果写入房间 record、Debug Map 和运行时房间配置。
- 当前支持 `Elite Gauntlet` 与 `Hazard Rush` 两种挑战：前者保持纯精英双波战斗，后者在精英战斗期间复用可读危险预警循环施加机关压力。
- `CombatRoom.get_challenge_summary()` 和 `is_challenge_hazard_active()` 暴露挑战变体状态，供调试、烟测和后续 UI 提示复用。
- `ChallengeRoomSmokeTest`、`DungeonGenerationSmokeTest`、`FullRunSmokeTest` 和 `ContentPipelineSmokeTest` 已扩展为校验挑战变体解析、record/runtime 一致性和 Hazard Rush 危险循环。

## 第一百三十二批已落地靠拢改动

### 事件房短时过载规则第一版
- `EventShrine` 新增原创 `Overclock Trial` 事件变体和 `temporary_rule` 奖励模式，随机事件池现在除祝福、商人折扣和诅咒武器外，还能出现“献祭生命换短时战斗规则”的结果。
- `Player` 新增 `apply_temporary_combat_rule()` 和 `get_temporary_rule_summary()`，短时规则会提高武器伤害与射速，并在计时结束后自动清除，不污染后续角色或新局。
- `EventShrine.get_event_summary()` 暴露短时规则 id、伤害加成、射速加成和持续时间，便于完整 Run、调试和后续 UI 提示识别事件结果。
- `EventRoomSmokeTest` 新增强制短时规则覆盖，验证事件摘要、信号、玩家倍率提升和计时过期清理。
- `FullRunSmokeTest` 和 `ContentPipelineSmokeTest` 同步识别 `temporary_rule` 分支，避免真实随机事件池抽到短时规则时被误判。

## 第一百三十三批已落地靠拢改动

### 事件驱动祝福第一版
- 新增原创祝福资源 `Afterglow Circuit`，定位为清房触发的能量 Build 祝福：获得后每次清理房间恢复能量。
- `BlessingSystem` 现在监听 `Events.room_cleared`，并按 `trigger_event` 调用事件驱动祝福效果，不再只支持 `passive` 祝福。
- 祝福效果应用层新增 `recover_energy`、`heal`、`gain_shield` 和 `temporary_combat_rule` 等通用玩家方法映射，后续可继续扩展更多事件触发规则。
- `get_blessing_summaries()` 补充 `effect_duration`，让运行时摘要能完整表达事件触发祝福参数。
- `EventRoomSmokeTest` 新增强制覆盖，验证 `Afterglow Circuit` 的摘要、触发事件和清房回能效果。
- `ContentPipelineSmokeTest` 将祝福池契约升级为至少 4 个祝福，并要求至少存在一个事件驱动祝福。

## 第一百三十四批已落地靠拢改动

### 事件驱动祝福多触发第一版
- `BlessingData` 新增 `trigger_interval`，支持“每 N 次触发才生效”的资源配置，避免击杀类祝福过频触发。
- `BlessingSystem` 现在监听 `enemy_died` 和 `player_damaged`，在清房触发之外补上击杀与受伤触发路径。
- 新增原创祝福 `Spark Dividend`：每 3 次击杀恢复能量，服务高耗能武器和连杀节奏。
- 新增原创祝福 `Brace Current`：受伤后恢复少量护甲，服务生存/护甲 Build。
- 为 `Afterglow Circuit`、`Spark Dividend` 和 `Brace Current` 增加专属 SVG 图标和 `ContentIconDefinitionData`，保持祝福图鉴不回退到默认图标。
- `EventRoomSmokeTest` 扩展为验证击杀触发间隔、第三次击杀回能和受伤回护甲；`ContentPipelineSmokeTest` 和 `LobbyScreenSmokeTest` 同步更新祝福池、注册表和大厅图鉴契约。

## 第一百三十五批已落地靠拢改动

### 祝福触发反馈与结算统计第一版
- `Events.gd` 新增 `blessing_triggered` 信号，统一暴露事件驱动祝福真实生效的祝福资源、触发事件、效果类型和效果值。
- `BlessingSystem.gd` 只在玩家侧效果成功应用后发出触发信号，避免“计数触发但没有实际效果”的结算噪音。
- `Main.gd` 新增本局祝福触发总次数和按祝福 ID 统计的触发次数，并在触发时显示 HUD 消息和短浮字，让清房、击杀、受伤触发不再只是后台数值变化。
- `HUD.gd` 的完整结算文本和 Build 分组新增 `Blessing Triggers`，让玩家能在死亡/通关回顾中看到事件祝福实际发挥次数。
- `EventRoomSmokeTest` 扩展为验证 `afterglow_circuit`、`spark_dividend` 和 `brace_current` 的触发信号、触发事件名和间隔行为；`RunSummarySmokeTest` 与 `FullRunSmokeTest` 同步覆盖新 summary 字段。

## 第一百三十六批已落地靠拢改动

### 雕像共鸣第一版
- 新增原创 `StatueData` 与 `StatueSystem`，把雕像定位为“技能触发的本局共鸣规则”，区别于遗物常驻数值和祝福事件规则。
- 已落地 3 个原创雕像：`Bulwark Idol`（技能后获得 1 Armor）、`Cinder Focus`（技能后短时伤害增益）和 `Echo Reservoir`（每 2 次技能后恢复 Energy）。
- `EventShrine` 新增 `Resonant Statue` / `statue_choice` 事件结果，随机事件池可自然产出雕像三选一。
- HUD 三选一、Outpost Hall 的 `Statues` 图鉴页、Codex 详情卡、内容图标注册表和结算 Build 摘要均已接入雕像。
- `RunSummarySmokeTest` 与 `EventRoomSmokeTest` 已覆盖雕像获取、技能触发、事件选择和结算统计；完整路线曾暴露 Room13/Room15 动态清怪断言问题，已在第一百三十七批修复。

## 第一百三十七批已落地靠拢改动

### 完整路线动态清房与 Biome 布局稳定性修复
- `FullRunSmokeTest` 改为按当前房间半径统计和击杀敌人，并循环清理死亡生成物、召唤物等动态子单位，避免挑战房 `SootSplitter` 分裂后残留导致后续房间被污染。
- 波次断言从“敌人数必须等于配置值”调整为“至少生成配置数量”，保留对欠生成的检查，同时允许召唤敌人在断言前合法产生额外单位。
- `DungeonController` 的战斗、精英和挑战房现在优先消耗当前 biome 的专属布局池，专属布局用完后再回退到通用布局池，强化三层主题差异。
- `DungeonGenerationSmokeTest` 改为读取当前 record 中的 `enemy_pool` 字段验证 Boss 身份，避免继续依赖已不存在的 `enemy_names` 字段。
- `FullRunSmokeTest`、`DungeonGenerationSmokeTest`、`ContentPipelineSmokeTest`、`EventRoomSmokeTest` 和 `RunSummarySmokeTest` 已在本批通过，完整 44 房三层路线重新恢复自动通关验证。

## 第一百三十八批已落地靠拢改动

### 祝福与雕像联动第一版
- `BlessingData` 新增 `on_statue_triggered` 触发枚举，祝福系统现在可以监听雕像共鸣事件。
- `BlessingSystem` 接入 `Events.statue_triggered`，在雕像效果成功触发后可按祝福资源配置继续施加玩家侧效果，并正常发出 `blessing_triggered`。
- 新增原创祝福 `Resonance Battery`：每当雕像效果触发时恢复 5 Energy，明确服务技能/雕像/能量循环 Build。
- 为 `Resonance Battery` 增加专属 SVG 图标、`ContentIconDefinitionData` 和注册表条目，保证事件选择、HUD 和图鉴不会退回默认祝福图标。
- `EventRoomSmokeTest` 已覆盖“获得雕像 + 获得雕像联动祝福 + 使用技能触发雕像 + 祝福回能”的完整链路；`ContentPipelineSmokeTest`、`LobbyScreenSmokeTest`、`RunSummarySmokeTest` 和 `FullRunSmokeTest` 已同步通过。

## 第一百三十九批已落地靠拢改动

### 事件房雕像调谐第一版
- `EventShrine` 新增原创 `Resonance Tuning` / `statue_attunement` 事件结果，随机事件池现在可出现“献祭生命强化已有雕像”的局内抉择。
- `StatueSystem` 新增 `attune_statue()`、`get_attunement_count()` 和 `statue_attuned` 信号，雕像摘要会同时暴露基础触发间隔、有效触发间隔、基础效果值、有效效果值和调谐次数。
- 调谐规则当前采用保守数值：每次调谐会把触发间隔降低 1，最低为 1；回复类和护盾类雕像每层调谐增加 1 点效果，短时战斗规则类每层增加 4% 效果值。
- `Resonance Tuning` 在玩家已有雕像时直接强化目标或自动选择最适合强化的已拥有雕像；没有雕像时回退为雕像三选一，避免事件房出现空奖励。
- `EventRoomSmokeTest` 覆盖事件结算、`statue_attuned` 信号、`Echo Reservoir` 调谐计数、有效触发间隔和有效回能值；`ContentPipelineSmokeTest` 和 `FullRunSmokeTest` 已同步识别新事件模式。
- 本批通过 `ContentPipelineSmokeTest`、`EventRoomSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 234.7 秒，第一次 180 秒超时不是失败信号。

## 第一百四十批已落地靠拢改动

### 雕像调谐反馈与结算可读性
- `Main` 现在监听 `statue_attuned`，调谐发生时会显示 HUD 消息和局内浮字，避免 `Resonance Tuning` 只产生后台数值变化。
- 本局统计新增 `statue_attunement_count` 和 `statue_attunement_counts`，按雕像记录调谐次数，和已有的祝福触发、雕像触发统计保持同一套结算口径。
- Run Summary 中的雕像名称会显示调谐层数，例如 `Bulwark Idol +1`，帮助玩家在结算页回看本局 Build 是由哪个事件强化出来的。
- HUD 结果全文和 Build 分组新增 `Statue Triggers: N | Attunes: M`，让雕像触发收益与事件强化次数同时可见。
- `RunSummarySmokeTest` 已覆盖调谐后的雕像名称、总调谐次数、按雕像调谐统计和 HUD 结果文本；`FullRunSmokeTest` 已覆盖新 summary 字段存在性。
- 本批通过 `RunSummarySmokeTest`、`EventRoomSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 228.8 秒。

## 第一百四十一批已落地靠拢改动

### 事件房结果回看第一版
- `EventShrine.get_event_summary()` 现在暴露事件显示名、金币范围和 biome 信息，事件记录不再只能看到内部 id。
- `Main` 在 `special_event_resolved` 时保存 `event_records`，记录事件 id、结果 id、显示名、奖励模式、生命代价、金币范围和 biome 字段。
- Run Summary 新增 `event_names` 和 `event_records`；结果页会显示类似 `Blood Pact -> Sacrifice For Blessing` 的事件结果回看文本。
- HUD 结果全文和 Loot 分组新增 `Event Outcomes`，让玩家能在通关或死亡后回看本局事件房选择，而不是只看到 `Events 3`。
- `RunSummarySmokeTest` 覆盖手动事件记录、事件结果文本和 Loot 分组；`FullRunSmokeTest` 覆盖三层路线每层一个事件结果记录。
- 本批通过 `RunSummarySmokeTest`、`EventRoomSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时约 228 秒。

## 第一百四十二批已落地靠拢改动

### 结果页滚动承载第一版
- HUD 结果页的六个分组现在被放入运行时创建的 `ResultScroll`，长路线、长 Build、事件结果和 Boss 记录不会继续挤压 Replay / Restart / Main Menu 按钮。
- `ResultSummaryLabel` 仍保留为隐藏的兼容文本，现有测试接口和旧的 `get_result_summary_text()` 不受影响。
- `RunSummarySmokeTest` 新增滚动容器断言，验证 `ResultScroll` 存在、子节点为 `ResultSections`，并保留足够的结果阅读高度。
- `FullRunSmokeTest` 新增完整路线结果页滚动承载断言，覆盖三层路线后长结算文本仍进入滚动区域。
- 本批通过 `RunSummarySmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 230.2 秒。

## 第一百四十三批已落地靠拢改动

### 特殊房间路线回看第一版
- Run Summary 新增 `special_room_counts` 和 `special_room_count_text`，按已访问、已清理或当前所在的事件、挑战、陷阱、奖励、军械、治疗、精英和商店房统计本局路线构成。
- HUD 结果全文新增 `Special Rooms` 行，结果页 Overview 分组同步显示特殊房间回看，让玩家能在结算时快速理解本局绕路收益和风险结构。
- `RunSummarySmokeTest` 新增 summary 字段、可读文本和 Overview 分组断言，确保旧结算文本和分组结果都能读到特殊房间回看。
- `FullRunSmokeTest` 新增完整三层路线断言，要求事件房每层计数准确，并确认挑战、陷阱、奖励、军械、治疗、精英和商店房至少被统计一次。
- 本批通过 `RunSummarySmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 232.1 秒。

## 第一百四十四批已落地靠拢改动

### 结果页详情密度切换第一版
- HUD 结果页新增 `ResultDetailToggleButton`，默认展开全部六个分组；玩家可切到 Compact，只保留 Overview、Build 和 Loot 三个核心分组，降低完整三层路线后的阅读密度。
- Compact 模式只改变分组行可见性，不清空隐藏分组文本；旧的 `get_result_summary_text()` 和 `get_result_section_text()` 调试/测试接口继续可读。
- HUD 新增 `is_result_details_expanded()`、`get_result_detail_toggle_text()`、`toggle_result_detail_mode()`、`is_result_section_visible()` 和 `get_visible_result_section_count()` 测试接口。
- `RunSummarySmokeTest` 覆盖默认展开、Compact 切换、核心分组保留、细节分组隐藏和隐藏文本保留。
- `FullRunSmokeTest` 覆盖完整三层路线结算默认处于展开模式，并可进入 Compact 视图。
- 本批通过 `RunSummarySmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 233.1 秒。

## 第一百四十五批已落地靠拢改动

### Boss 路线回看第一版
- HUD 结果全文新增 `Boss Route` 行，把每层 Boss 名称、最终 Boss 标记和 Seen/Cleared/Pending 状态串成三层路线回看。
- Overview 分组同步显示 `Boss Route`，因此 Compact 模式下玩家仍能看到三层 Boss 进度，而不必展开全部细节。
- `RunSummarySmokeTest` 新增完整结果文本、Overview 分组和 Compact 模式中的 Boss 路线断言。
- `FullRunSmokeTest` 新增三层 Boss 路线数量、每层清理状态、最终 Boss `Final Cleared` 文本和 Compact 保留断言。
- 本批通过 `RunSummarySmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 230.8 秒。

## 第一百四十六批已落地靠拢改动

### 失败结算位置说明第一版
- Run Summary 新增 `run_position` 和 `run_position_text`，优先记录当前房间，其次回退到最后访问或清理过的房间，包含房间 id、房间类型、层号、Biome 名称和 Current/Visited/Cleared 状态。
- HUD 结果全文和 Overview 分组新增位置行；失败结算显示为 `Defeat Point`，胜利或运行中摘要显示为 `Run Position`。
- `MenuFlowSmokeTest` 覆盖真实玩家死亡路径，验证失败 summary 记录当前房间、结果页全文显示 `Defeat Point`，Overview 分组也包含死亡房间 id。
- `RunSummarySmokeTest` 和 `FullRunSmokeTest` 已复跑，确认新增位置说明不破坏胜利结算、Boss Route 或 Compact 结果页。
- 本批通过 `MenuFlowSmokeTest`、`RunSummarySmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 232.4 秒。

## 第一百四十七批已落地靠拢改动

### 最后伤害来源回看第一版
- Player 在 `take_damage(amount, source)` 中保存最后一次实际扣 HP 的伤害摘要，记录伤害量、来源名和来源类型；完全被护甲吸收的伤害不覆盖该摘要。
- Main 在 `player_damaged` 时读取 Player 的最后伤害摘要，Run Summary 新增 `last_damage` 和 `last_damage_text`。
- HUD 结果全文和 Overview 分组新增 `Last Hit`，死亡页会和 `Defeat Point` 一起解释“死在哪”和“最后被什么打到”。
- `MenuFlowSmokeTest` 使用命名伤害源造成死亡，验证 summary、完整结果文本和 Overview 分组都能显示最后伤害来源。
- 本批通过 `MenuFlowSmokeTest`、`RunSummarySmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 231.0 秒。

## 第一百四十八批已落地靠拢改动

### 失败原因汇总第一版
- Run Summary 新增 `defeat_cause` 和 `defeat_cause_text`，把失败结果、当前位置和最后伤害来源合成为可直接阅读的死亡原因。
- `defeat_cause` 会按最后伤害来源类型归类为 Boss、Enemy、Hazard 或 Unknown，并记录来源名、伤害量、位置文本和完整说明。
- `get_run_summary()` 改为按当前 run state 输出 `Defeat`、`Victory` 或 `In Progress`，避免死亡后的调试摘要仍按进行中结果生成。
- HUD 结果全文和 Overview 分组新增 `Defeat Cause`，在 Compact 结果页也能直接看到“被什么、在哪里击倒”。
- `MenuFlowSmokeTest` 把 Debug Spike 标记为 enemy，验证 summary、完整结果文本和 Overview 分组都能显示 `Enemy Debug Spike` 失败原因。
- 本批通过 `MenuFlowSmokeTest`、`RunSummarySmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 233.4 秒。

## 第一百四十九批已落地靠拢改动

### 稳定伤害来源标识第一版
- Player 的最后伤害摘要新增 `source_id` 和 `source_scene`，在 `source_name/source_type` 之外提供可用于统计、图标化和图鉴链接的稳定来源标识。
- `source_id` 优先读取来源节点显式 id，其次使用场景文件名，最后回退到显示名或节点名，避免结算只依赖不稳定的节点实例名。
- `EnemyProjectile` 会在发射时缓存 owner 的来源摘要；即使发射者随后死亡，弹丸命中玩家时仍能归因到原敌人或 Boss。
- `DangerWarning` 会在配置时缓存来源摘要，Boss/精英/陷阱式警示区域后续也能复用同一套死亡归因字段。
- `defeat_cause` 同步保留 `source_id` 和 `source_scene`，让失败原因可读文本和结构化统计字段保持一致。
- `CombatFeedbackSmokeTest` 新增 owner 死亡后敌方弹丸命中玩家的来源断言；`MenuFlowSmokeTest` 新增 `debug_spike` source id 断言。
- 本批通过 `CombatFeedbackSmokeTest`、`MenuFlowSmokeTest`、`RunSummarySmokeTest`、`EnemyVarietySmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 230.9 秒。

## 第一百五十批已落地靠拢改动

### 最近失败原因档案第一版
- Main 新增 `_last_defeat_record` 和 `get_last_defeat_summary()`，把最近一次失败的 `defeat_cause` 从单局结算保留到大厅档案层。
- 最近失败记录独立保存到 ConfigFile 的 `last_defeat` section，避免把字符串字段混入纯数字 `history` 统计循环。
- 记录内容包含 `source_id`、`source_name`、`source_type`、`source_scene`、伤害量、失败位置、房间 id、Biome、seed、清房数、击杀数和耗时。
- Hall Summary 新增 `last_defeat`；Lobby Records 页面在存在记录时显示 `Last Defeat` 行，包含可读死亡原因、来源 id、seed、Biome、房间和击杀摘要。
- `MenuFlowSmokeTest` 扩展为验证真实死亡后最近失败记录生成、重载 Main 后持久化读取，以及大厅 Records 文本显示 `Enemy Debug Spike`、`Source debug_spike` 和 `Seed 24680`。
- 本批通过 `MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`RunSummarySmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 235.2 秒。

## 第一百五十一批已落地靠拢改动

### 死亡来源统计第一版
- Main 新增 `_defeat_source_counts` 和 `get_defeat_source_summary()`，按 `source_id` 累计失败来源次数。
- 失败结算记录最近失败原因后，同步更新对应来源的死亡次数、最近 run index、最近 seed、Biome、房间和可读失败文本。
- 死亡来源统计独立保存到 ConfigFile 的 `defeat_sources` section，通过 `source_ids` 列表作为权威索引读取，继续避免污染纯数字 `history`。
- Hall Summary 新增 `defeat_sources`，按死亡次数降序、最近出现降序输出稳定数组。
- Lobby Records 页面新增 `Death Sources` 区块，最多展示前三个来源，包含 `source_id`、次数、显示名、最近 seed 和最近 Biome。
- `MenuFlowSmokeTest` 扩展为验证死亡来源统计生成、重载持久化读取，以及大厅 Records 文本显示 `Death Sources` 和 `debug_spike x1`。
- 本批通过 `MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`RunSummarySmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 233.4 秒。

## 第一百五十二批已落地靠拢改动

### 死亡来源类型概览第一版
- Main 新增 `get_defeat_source_type_summary()`，从已持久化的 `defeat_sources` 派生 Enemy、Boss、Hazard 和 Unknown 类型死亡次数。
- 类型概览不重复保存，避免与按 `source_id` 聚合的来源统计出现漂移。
- Hall Summary 新增 `defeat_source_types`，大厅 UI 可直接读取按类型聚合后的死亡来源。
- Lobby Records 页面新增 `Death Types: Enemy N | Boss N | Hazard N | Unknown N`，放在具体 `Death Sources` 排名前，帮助玩家快速判断常死于哪类威胁。
- `MenuFlowSmokeTest` 扩展为验证真实死亡后、重载后和大厅文本中都能看到 enemy 类型死亡计数。
- 本批通过 `MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`RunSummarySmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 229.7 秒。

## 第一百五十三批已落地靠拢改动

### 敌人伤害来源摘要接口第一版
- `Enemy.gd` 和 `BossEnemy.gd` 新增显式 `source_id` 与 `get_damage_source_summary()`，让接触伤害、弹丸和预警区域都能从源头读取稳定来源摘要。
- 普通敌人来源摘要包含 `source_id`、显示名、`enemy` 类型、场景路径和精英修饰 id/name；精英前缀会保留在可读名称中，基础来源 id 仍优先稳定到场景文件名。
- Boss 来源摘要包含 `boss` 类型、场景路径和当前阶段，为后续 Boss 死亡归因、图鉴链接和战斗回放保留结构化字段。
- `EnemyProjectile` 与 `DangerWarning` 的缓存逻辑改为优先复用来源节点提供的摘要，避免弹丸、Boss 警示区和精英死亡爆炸各自拼接出不一致字段。
- `CombatRoom` 在 `boss_died` 后会清理 Boss 房残留追踪敌人并直接推进清房，修复 Boss 已死但奖励箱不生成的边界情况。
- `CombatFeedbackSmokeTest`、`EnemyVarietySmokeTest` 和 `BossSmokeTest` 新增来源摘要断言，覆盖敌人、精英、Boss 与 owner 死亡后的弹丸归因。
- 本批通过 `CombatFeedbackSmokeTest`、`EnemyVarietySmokeTest`、`BossSmokeTest`、`MenuFlowSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 234.4 秒。

## 第一百五十四批已落地靠拢改动

### 房间危险来源摘要第一版
- `CombatRoom.gd` 新增 `get_damage_source_summary()`，让陷阱房、挑战房和 Boss 场地地板危险也能像敌人/Boss 一样提供结构化伤害来源。
- 房间 hazard 来源现在稳定区分为 `trap_room_hazard`、`challenge_room_hazard` 和 `boss_arena_hazard`，避免死亡来源统计把房间危险混成通用 `PrototypeCombatRoom` 场景来源。
- 来源摘要保留 `hazard` 类型、场景路径、房间类型、Biome id/name 和布局 profile，为后续 Records 过滤、图鉴跳转和死亡复盘提供更多上下文。
- `TrapRoomSmokeTest` 新增陷阱房来源摘要与 DangerWarning 缓存断言，确认 warning 命中玩家时会归因到 `Trap Room Hazard`。
- `BossSmokeTest` 新增 Boss 场地地板 warning 来源断言，确认二阶段 Arena hazard 与 Boss 自身弹幕归因保持分离。
- 本批通过 `TrapRoomSmokeTest`、`BossSmokeTest`、`DungeonGenerationSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 233.7 秒。

## 第一百五十五批已落地靠拢改动

### 死亡来源上下文持久化第一版
- `Player.gd` 的 last damage 摘要现在会保留来源提供的 `source_room_type`、`source_biome_id`、`source_biome_name` 和 `source_layout_profile`，让房间 hazard 不只记录来源 id，还能记录发生在哪类房间、哪一层和哪套布局。
- `Main.gd` 将这些上下文字段继续传入 `defeat_cause`、最近失败记录和 `defeat_sources` 持久化统计，重载 Main 后仍能读回来源上下文。
- `LobbyScreen.gd` 的 Records 死亡来源列表新增 `Type ...` 文案；当存在房间上下文时可显示类似 `hazard/trap` 的类型组合，帮助后续区分敌人死亡、Boss 死亡和房间机制死亡。
- `MenuFlowSmokeTest` 通过 `reset_run_records_for_test()` 隔离本地 `settings.cfg` 中的历史死亡来源，避免重复运行 smoke test 时计数累加导致断言漂移，并验证普通敌人来源不会凭空带房间上下文。
- `TrapRoomSmokeTest` 扩展为让玩家实际吃到陷阱房 warning 伤害，验证 last damage 与 defeat cause 都保留 `trap_room_hazard`、`trap` 房间类型、Biome id 和布局 profile。
- 本批通过 `MenuFlowSmokeTest`、`RunSummarySmokeTest`、`TrapRoomSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 230.8 秒。

## 第一百五十六批已落地靠拢改动

### 死亡来源上下文展示第一版
- `LobbyScreen.gd` 的 Records 页面现在会把来源上下文格式化为 `Context Room ... / Biome ... / Layout ...` 后缀，让持久化字段真正转化为玩家可读的死亡复盘信息。
- `Last Defeat` 行会在来源 id 后展示上下文后缀；`Death Sources` 排名行也会在最近 Biome 后展示相同上下文，保证最近一次死亡和聚合来源统计读到同一套解释。
- 上下文 token 会把下划线 id 转成可读标题，例如 `trap` 显示为 `Room Trap`，布局 profile 也显示为更易读的标题文本。
- `TrapRoomSmokeTest` 新增真实陷阱 warning 致死、最近失败记录、死亡来源统计、重载 Main 读取和大厅 Records 文本断言，确认 `trap_room_hazard` 可以完整显示 `Type hazard/trap`、`Context Room Trap` 和 `Layout ...`。
- 第二段陷阱死亡测试使用类型化 `Array[Resource]` 设置 `room_data_sequence`，并补充房型与敌人数量断言，避免回退到默认战斗房导致归因污染。
- 本批通过 `TrapRoomSmokeTest`、`MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 232.9 秒。

## 第一百五十七批已落地靠拢改动

### 死亡来源上下文汇总第一版
- Records 页面新增 `Death Context` 汇总行，从已持久化的 `defeat_sources` 派生房间类型、Biome 和布局维度的死亡次数。
- 汇总行不会新增独立存档字段，而是按死亡来源记录的 `count` 聚合 `source_room_type`、`source_biome_name/source_biome_id` 和 `source_layout_profile`，避免和来源统计产生漂移。
- 每个维度最多展示前三项，并按次数降序、名称升序排序；当前文案形如 `Death Context: Rooms Trap x1 | Biomes Outer Warrens x1 | Layouts ... x1`。
- `TrapRoomSmokeTest` 扩展大厅 Records 文本断言，确认真实陷阱死亡重载后能看到 `Death Context`、`Rooms Trap x1`、Biome 汇总和 Layout 汇总。
- `MenuFlowSmokeTest` 和 `HallArchiveSmokeTest` 复跑确认普通敌人死亡记录和大厅图鉴页面不受新增上下文汇总影响。
- 本批通过 `TrapRoomSmokeTest`、`MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 268.0 秒。

## 第一百五十八批已落地靠拢改动

### 死亡记录视图切换第一版
- Records 页复用大厅既有 `Previous/Next/Clear` 过滤控件，新增 `Death View` 切换，当前支持 `All`、`Types`、`Context` 和 `Sources` 四种视图。
- `All` 视图保留最近失败、死亡类型、死亡上下文和死亡来源排名；`Types` 只显示 Enemy/Boss/Hazard/Unknown 类型统计；`Context` 只显示房间/Biome/布局维度汇总；`Sources` 只显示具体来源排名。
- 大厅总览页仍然调用完整 Records，不受单独 Records 页的 Death View 状态影响，避免总览页面被过滤控件截断。
- `LobbyScreen.gd` 新增 Records 专用测试入口，能直接设置、切换、清空 Death View；图鉴页的 Build Route、搜索、排序和稀有度过滤逻辑保持原样。
- `TrapRoomSmokeTest` 扩展为切换四个 Death View 并验证各视图只显示对应死亡信息；`LobbyScreenSmokeTest` 复跑确认图鉴过滤控件未被 Records 复用破坏。
- 本批通过 `TrapRoomSmokeTest`、`LobbyScreenSmokeTest`、`HallArchiveSmokeTest`、`MenuFlowSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 255.4 秒。

## 第一百五十九批已落地靠拢改动

### 死亡来源类型筛选第一版
- Records 页在 `Context` 和 `Sources` 两个 Death View 下新增 `Source Type` 二级筛选，当前支持 `All`、`Enemy`、`Boss`、`Hazard` 和 `Unknown`。
- 二级筛选复用大厅既有搜索/排序行中的前后按钮和 Reset 按钮；在 Records 页显示为 `Source Type: ...`，在图鉴页仍恢复为搜索、排序和稀有度控件。
- Source Type 筛选不新增存档字段，只从现有 `defeat_sources` 按 `source_type` 过滤上下文汇总和具体来源排名；空结果显示 `Death Context: None` 或 `Death Sources: None`。
- `All` 和 `Types` Death View 不显示二级 Source Type 筛选，避免类型统计页再被类型筛选造成歧义。
- `TrapRoomSmokeTest` 扩展为在真实陷阱死亡后切换 Hazard/Enemy 筛选，验证 Hazard 保留 `trap_room_hazard`，Enemy 显示空结果。
- 本批通过 `TrapRoomSmokeTest`、`LobbyScreenSmokeTest`、`MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 239.9 秒。

## 第一百六十批已落地靠拢改动

### 死亡来源详情聚焦第一版
- Records 页在 `Sources` Death View 下新增 `Death Source Detail` 聚焦块，默认展示当前筛选结果中排名最高的死亡来源。
- 详情块复用现有 `defeat_sources` 字段，展示 `source_id`、可读名称、`Type`、累计次数、最近 seed、最近 Biome、上下文后缀和 `Last Cause`，不新增存档字段。
- 当 `Source Type` 筛选无匹配结果时，Sources 视图继续显示 `Death Sources: None`，并隐藏聚焦详情，避免空视图出现误导性的旧来源。
- `TrapRoomSmokeTest` 扩展为验证真实陷阱死亡后的 `Death Source Detail`、`Trap Room Hazard`、最近死亡原因，以及 Hazard/Enemy 筛选下详情块的保留与隐藏。
- 本批通过 `TrapRoomSmokeTest`、`LobbyScreenSmokeTest`、`MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 231.7 秒。

## 第一百六十一批已落地靠拢改动

### 死亡来源详情卡第一版
- Records 页在 `Sources` Death View 下复用现有 `CodexDetailCard` 展示聚焦死亡来源，把纯文本复盘推进为图鉴同款详情卡。
- 详情卡只在 `Records + Sources` 下显示；`All`、`Types`、`Context` 和空筛选结果保持隐藏，避免总览和空视图被错误卡片挤占。
- 详情卡使用稳定 `death_source_<source_id>` 图标 key、`SRC` 徽标和按 Enemy/Boss/Hazard/Unknown 区分的颜色，为后续正式复盘图标和图鉴链接预留入口。
- 卡片正文展示 `Last Cause`、上下文和 `Source ID`，meta 展示类型上下文、累计次数、最近 seed 和最近 Biome，与 Sources 文本排名共享同一条筛选结果。
- `TrapRoomSmokeTest` 扩展为验证真实陷阱死亡后详情卡标题、徽标、图标 key、Hazard badge、meta/body 文本，以及 Hazard/Enemy 筛选下卡片保留和隐藏。
- 本批通过 `TrapRoomSmokeTest`、`LobbyScreenSmokeTest`、`MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 239.5 秒。

## 第一百六十二批已落地靠拢改动

### 死亡来源复盘建议第一版
- `Death Source Detail` 文本块和 Records 来源详情卡正文新增 `Review` 建议行，把死亡来源从“记录发生了什么”推进到“提示下局如何规避”。
- 建议文本由 `defeat_sources` 中已有的 `source_type` 和 `source_room_type` 派生，当前覆盖 Hazard/Trap、Challenge hazard、Boss arena hazard、Boss、Enemy 和 Unknown。
- 陷阱房 hazard 会显示类似“Treat warning zones as lanes...”的复盘建议，强调预警区域、逃生路线和脉冲后穿越。
- 本批不新增存档字段、不改战斗数值，只在大厅复盘展示层派生解释性文案，保持与现有死亡来源统计一致。
- `TrapRoomSmokeTest` 扩展为验证真实陷阱死亡后的文本详情和详情卡正文都包含 trap hazard 复盘建议。
- 本批通过 `TrapRoomSmokeTest`、`LobbyScreenSmokeTest`、`MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 231.8 秒。

## 第一百六十三批已落地靠拢改动

### 死亡复盘建议字段管线化第一版
- 伤害来源摘要新增 `source_review_tip` 字段，从房间/敌人/Boss 来源进入 Player last damage、defeat cause、最近死亡记录和 `defeat_sources` 持久化统计。
- `RoomData` 和 `CombatRoom` 新增可配置 `hazard_review_tip`，`DungeonController` 会把房间资源或内置房间 config 中的建议写入运行时房间实例。
- 内置 Challenge、Trap 和 Boss 房间 hazard 现在各自提供默认复盘建议；普通敌人按行为类型提供建议，Boss 提供读招/护甲恢复建议。
- 大厅 Records 的 `Review` 文案优先读取保存下来的 `source_review_tip`，缺失时才回退到 `source_type/source_room_type` 推导，兼容旧存档。
- `TrapRoomSmokeTest` 扩展为验证 trap hazard 建议从房间摘要、DangerWarning 缓存、Player last damage、defeat cause、最近死亡记录、死亡来源统计到重载后记录的完整链路。
- 本批通过 `TrapRoomSmokeTest`、`LobbyScreenSmokeTest`、`MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 241.1 秒。

## 第一百六十四批已落地靠拢改动

### 死亡来源威胁情报第一版
- Records 页在 `Sources` Death View 的 `Death Source Detail` 文本块中新增 `Threat Intel` 行，把死亡来源解释为威胁类别、可读前摇、应对方式和稳定 `death_source_<source_id>` 图鉴 key。
- 复盘详情卡正文同步展示 `Threat Intel`，让死亡来源卡不只显示最近死因和 Review 建议，还能成为后续跳转敌人、Boss 或房间 hazard 图鉴说明的桥接层。
- 当前情报由既有 `source_id`、`source_type`、`source_room_type` 和 `source_name` 派生，不新增存档字段；旧记录仍能得到 Enemy/Boss/Hazard/Unknown 的兜底说明。
- Trap hazard 会显示类似 `Room Hazard / Trap | Tell warning lanes | Counter cross after pulse | Codex death_source_trap_room_hazard` 的结构化说明，继续强化死亡后“知道哪里失误、下局怎么处理”的局外复盘。
- `TrapRoomSmokeTest` 扩展为验证真实陷阱死亡后，Sources 文本详情和 `CodexDetailCard` 正文都会展示 trap hazard 威胁情报和稳定 death source key。
- 本批通过 `TrapRoomSmokeTest`、`LobbyScreenSmokeTest`、`MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 234.1 秒。

## 第一百六十五批已落地靠拢改动

### 死亡来源威胁情报字段管线化第一版
- 伤害来源摘要新增 `source_threat_intel` 字段，从房间/敌人/Boss 源头进入 Player last damage、defeat cause、最近死亡记录和 `defeat_sources` 持久化统计。
- `RoomData` 和 `CombatRoom` 新增可配置 `hazard_threat_intel`；`DungeonController` 会把房间资源或内置 Challenge、Trap、Boss 房间 config 中的威胁情报写入运行时房间实例。
- 普通敌人按行为类型输出 Ranged Pressure、Charger、Explosion、Support、Shield、Contact 等威胁情报；Boss 输出 Boss Threat；房间 hazard 输出 Trap、Challenge 或 Boss arena 威胁情报。
- 大厅 Records 的 `Threat Intel` 文案优先读取保存下来的 `source_threat_intel`，缺失时才回退到 UI 派生说明，兼容旧存档并降低后续 UI 硬编码压力。
- `TrapRoomSmokeTest` 扩展为验证 trap hazard 威胁情报从房间摘要、DangerWarning 缓存、Player last damage、defeat cause、最近死亡记录、死亡来源统计到重载后记录的完整链路；`BossSmokeTest`、`CombatFeedbackSmokeTest` 和 `EnemyVarietySmokeTest` 同步验证 Boss、普通敌人和精英敌人的来源摘要字段。
- 本批通过 `TrapRoomSmokeTest`、`BossSmokeTest`、`CombatFeedbackSmokeTest`、`EnemyVarietySmokeTest`、`LobbyScreenSmokeTest`、`MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 235.4 秒。

## 第一百六十六批已落地靠拢改动

### 死亡来源反制 Build 标签第一版
- 伤害来源摘要新增 `source_counter_tags`，把死亡来源和现有图鉴 Build Route 标签连接起来，让复盘不只说明威胁，还能提示下局可尝试的路线。
- `RoomData` 和 `CombatRoom` 新增可配置 `hazard_counter_tags`；内置 Trap、Challenge 和 Boss arena hazard 分别给出 Speed/Survival/Armor、Crowd Control/Damage/Survival、Survival/Armor/Damage 等反制标签。
- 普通敌人按行为类型输出反制标签，例如远程压制推荐 Guard/Line Clear/Precision，冲锋推荐 Speed/Crowd Control/Close Range，护盾推荐 Piercing/Guard/Melee；Boss 推荐 Survival/Armor/Damage。
- Player last damage、defeat cause、最近死亡记录和 `defeat_sources` 会保存并重载 `source_counter_tags`；大厅 Records 的 `Death Source Detail` 和详情卡正文新增 `Counter Build` 行。
- `TrapRoomSmokeTest` 扩展为验证 trap hazard 的反制标签从房间摘要、DangerWarning 缓存、Player last damage、defeat cause、最近死亡记录、死亡来源统计到重载后大厅详情展示的完整链路；Boss、普通敌人和精英敌人烟测同步覆盖来源摘要字段。
- 本批通过 `TrapRoomSmokeTest`、`BossSmokeTest`、`CombatFeedbackSmokeTest`、`EnemyVarietySmokeTest`、`LobbyScreenSmokeTest`、`MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 236.4 秒。

## 第一百六十七批已落地靠拢改动

### 死亡来源反制图鉴推荐第一版
- Records 页在 `Sources` Death View 的 `Death Source Detail` 文本块和来源详情卡正文中新增 `Counter Picks` 行，直接从大厅当前内容摘要中列出匹配反制标签的图鉴条目。
- 推荐逻辑复用现有 `source_counter_tags`，从武器 `tags` 以及遗物、天赋、祝福、雕像的 `build_tags` 中匹配，不新增存档字段或独立推荐表。
- 每类内容只展示少量可读条目，避免复盘详情过长；Trap hazard 的 Speed/Survival/Armor 反制标签当前会推荐类似 `Relics Adrenaline Charm...` 和 `Statues Bulwark Idol` 的内容入口。
- `LobbyScreen.gd` 新增 `_format_defeat_source_counter_picks()`、匹配和标签规范化 helper，旧记录仍能先通过 Counter Build 兜底标签获得推荐结果。
- `TrapRoomSmokeTest` 扩展为验证真实陷阱死亡后，Sources 文本详情和 `CodexDetailCard` 正文都会展示 `Counter Picks`、匹配遗物和匹配雕像推荐。
- 本批通过 `TrapRoomSmokeTest`、`LobbyScreenSmokeTest`、`MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整路线本轮耗时 234.0 秒。

## 第一百六十八批已落地靠拢改动

### 死亡来源反制路线跳转第一版
- Records 页在 `Sources` Death View 的 `Death Source Detail` 文本块和来源详情卡正文中新增 `Counter Route` 行，把死亡来源反制标签解析为可进入的图鉴路线，例如 Trap hazard 默认指向 `Relics -> Speed`。
- `CodexDetailCard` 新增 `CounterRouteButton`，仅在 Records 来源详情存在可匹配路线时显示，按钮文案会标明目标路线，例如 `Open Relics -> Speed`。
- `LobbyScreen.gd` 新增 `open_counter_route()` 和测试入口，能从当前聚焦死亡来源读取 `source_counter_tags`，优先跳到遗物路线，必要时回退到武器、天赋、祝福或雕像中存在的匹配标签。
- 跳转会切换到对应图鉴分页，套用 Build Route 筛选，并清空该分页的搜索、排序和稀有度细筛，避免旧筛选把推荐路线结果隐藏。
- `TrapRoomSmokeTest` 扩展真实陷阱死亡后的大厅断言，确认 Sources 文本、详情卡正文、按钮文案和跳转后的 Relics/Speed 图鉴页都能展示匹配遗物 `Adrenaline Charm`。
- 本批通过 `TrapRoomSmokeTest`、`LobbyScreenSmokeTest`、`MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整回归本轮耗时 342.3 秒。

## 第一百六十九批已落地靠拢改动

### 死亡来源反制推荐条目跳转第一版
- Records 页在 `Sources` Death View 的 `Death Source Detail` 文本块和来源详情卡正文中新增 `Counter Focus` 行，把死亡来源的首个可用反制推荐解析为具体图鉴条目，例如 `Relics -> Adrenaline Charm (Speed)`。
- `CodexDetailCard` 新增 `CounterPickButton`，仅在当前聚焦死亡来源存在可匹配推荐条目时显示，按钮文案会标明具体推荐，例如 `Open Pick Adrenaline Charm`。
- `LobbyScreen.gd` 新增 `open_counter_pick()` 和测试入口，能在保持 Build Route 标签的同时把图鉴搜索框聚焦到推荐条目名，直接打开对应详情卡。
- 具体推荐目标复用当前大厅 summary，不新增推荐资源表；默认按反制路线页序和来源标签选择首个匹配项，也支持测试或后续 UI 传入指定 page/tag/name。
- `TrapRoomSmokeTest` 扩展真实陷阱死亡后的大厅断言，确认 Sources 文本、详情卡正文、推荐按钮和跳转后的 Relics/Speed/Search `Adrenaline Charm` 精确聚焦都正常。
- 本批通过 `TrapRoomSmokeTest`、`LobbyScreenSmokeTest`、`MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整回归本轮耗时 329.9 秒。

## 第一百七十批已落地靠拢改动

### 死亡来源反制推荐循环第一版
- Records 页来源详情卡新增 `Next Pick` 循环入口，允许玩家在同一死亡来源的多条 `Counter Picks` 推荐之间切换当前聚焦项，而不是只能打开首个推荐。
- `LobbyScreen.gd` 新增 `_counter_pick_focus_indexes`，按死亡来源和 Source Type 记录当前推荐焦点；`Counter Focus` 文本和 `Open Pick` 按钮会随焦点同步刷新。
- 具体推荐池从当前大厅 summary 动态收集，按反制路线页序和 `source_counter_tags` 顺序排列，并按 page/display name 去重，避免同一条目因多标签重复出现。
- `open_counter_pick()` 无参数时会打开当前循环聚焦项；传入 page/tag/name 时仍可精确打开指定条目，保留测试和后续直接选择入口。
- `TrapRoomSmokeTest` 扩展真实陷阱死亡后的大厅断言，确认 `Next Pick 1/N` 可见、循环后变为 `Next Pick 2/N`、`Open Pick` 文案更新，并且焦点离开首个 `Adrenaline Charm` 推荐。
- 本批通过 `TrapRoomSmokeTest`、`LobbyScreenSmokeTest`、`MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整回归本轮耗时 326.4 秒。

## 第一百七十一批已落地靠拢改动

### 死亡来源反制推荐焦点计数第一版
- Records 页 `Counter Focus` 文本新增焦点位置计数，显示为类似 `1/N Relics -> Adrenaline Charm (Speed)`，让玩家知道当前推荐不是唯一条目。
- `LobbyScreen.gd` 的推荐焦点格式化现在复用当前死亡来源的完整推荐池和焦点索引，与 `Next Pick 1/N` 按钮保持同一套计数来源。
- 循环到下一条推荐后，`Counter Focus` 会同步变为 `2/N ...`，`Open Pick` 按钮继续指向当前聚焦项，避免文本、按钮和实际跳转目标不一致。
- 无推荐或单条推荐时仍保持简洁显示，不额外暴露无意义的计数。
- `TrapRoomSmokeTest` 扩展断言，确认来源详情文本和详情卡正文都包含 `Counter Focus: 1/N`，循环后会变为 `Counter Focus: 2/N`。
- 本批通过 `TrapRoomSmokeTest`、`LobbyScreenSmokeTest`、`MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整回归本轮耗时 328.2 秒。

## 第一百七十二批已落地靠拢改动

### 死亡来源反制推荐类型切换第一版
- Records 页来源详情卡新增 `Next Type` 入口，在同一死亡来源的反制推荐中先按图鉴类型页切换，例如从 `Relics` 切到其它可用推荐类型。
- `LobbyScreen.gd` 新增 `_counter_pick_page_focus_indexes`，按死亡来源和 Source Type 记录当前推荐类型页；`Counter Focus`、`Open Pick` 和 `Next Pick` 会基于当前类型页内的推荐池同步刷新。
- 反制推荐收集拆分为跨页推荐池和单页推荐池：跨页逻辑继续服务精确跳转，单页逻辑服务详情卡当前类型页内循环，避免 `Next Pick` 把不同类型混在一条长列表里。
- 切换 `Next Type` 时会把当前条目焦点重置到该类型页的首个推荐，让玩家先选类型，再在该类型内部循环具体推荐。
- `TrapRoomSmokeTest` 扩展真实陷阱死亡后的大厅断言，确认 `Next Type Relics 1/N` 可见、类型切换后按钮离开初始类型，并且 `Counter Focus` 行切到非 Relics 推荐。
- 本批通过 `TrapRoomSmokeTest`、`LobbyScreenSmokeTest`、`MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整回归本轮耗时 347.2 秒。

## 第一百七十三批已落地靠拢改动

### 死亡来源反制类型直接选择第一版
- Records 页来源详情卡新增 `CounterPickTypeRow` 分段按钮行，只显示当前死亡来源实际存在推荐的图鉴类型，让玩家能直接点回 `Relics`、`Weapons`、`Talents`、`Blessings` 或 `Statues`。
- 当前推荐类型会以类似 `[Relics]` 的按钮文本标记并禁用，非当前类型按钮可直接切换，不再只能依赖 `Next Type` 逐个循环。
- `LobbyScreen.gd` 新增 `request_counter_pick_page_for_test()` 和类型按钮可见性测试接口；直接选择类型会同步刷新 `Next Type` 文案、`Counter Focus` 正文、`Open Pick` 目标和当前类型内的 `Next Pick` 状态。
- 直接选择类型时仍会重置条目焦点到该类型首个推荐，保持“先选类型，再选具体推荐”的导航层级清晰。
- `TrapRoomSmokeTest` 扩展真实陷阱死亡后的大厅断言，确认初始 `[Relics]` 类型按钮可见，循环离开后可直接选择回 Relics，并恢复 `Relics -> Adrenaline Charm` 焦点推荐。
- 本批通过 `TrapRoomSmokeTest`、`LobbyScreenSmokeTest`、`MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整回归本轮耗时 327.1 秒。

## 第一百七十四批已落地靠拢改动

### 死亡来源反制操作紧凑布局第一版
- Records 页来源详情卡把 `Route` / `Pick` 操作按钮合并到 `CounterActionRow`，把 `Next Pick` / `Type` 切换按钮合并到 `CounterCycleRow`，从四个纵向按钮压缩为两行紧凑 controls。
- `CounterRouteButton` 和 `CounterPickButton` 文案缩短为 `Route Relics -> Speed`、`Pick Adrenaline Charm` 这类直接动作标签，减少按钮宽度压力。
- `CounterPickPageButton` 文案从 `Next Type ...` 缩短为 `Type Relics 1/N`，保留类型循环语义，同时和类型分段按钮形成更清晰的主次关系。
- `CodexDetailCard` 高度从 276 回落到 248，给下方 Records 正文列表腾回空间，降低 720p 下来源详情卡挤压档案正文的风险。
- `TrapRoomSmokeTest` 同步更新来源详情卡按钮断言，确认紧凑文案仍能正确指向路线、推荐条目、页内推荐序号和类型切换状态。
- 本批通过 `TrapRoomSmokeTest`、`LobbyScreenSmokeTest`、`MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整回归本轮耗时 327.3 秒。

## 第一百七十五批已落地靠拢改动

### 死亡来源反制类型短标签第一版
- Records 页来源详情卡的类型分段按钮从 `Weapons/Relics/Talents/Bless/Statues` 改为 `W/R/T/B/S` 短 token，进一步降低横向占用。
- 当前类型继续用方括号标记，例如 Relics 会显示为 `[R]`，保持当前焦点类型一眼可见。
- `LobbyScreen.gd` 新增 `_format_counter_pick_type_token()`，让可见 token 和完整类型名称分离，后续可替换为正式图标或短符号。
- 类型按钮 tooltip 保留完整名称，例如 `[R]` 仍会暴露 `Current counter type: Relics`，避免短 token 牺牲可理解性。
- `TrapRoomSmokeTest` 扩展断言，确认短 token active 状态和 Relics tooltip 都存在，并且直接选回 Relics 后仍保持同样语义。
- 本批通过 `TrapRoomSmokeTest`、`LobbyScreenSmokeTest`、`MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整回归本轮耗时 329.3 秒。

## 第一百七十六批已落地靠拢改动

### 死亡来源反制类型 active 颜色第一版
- Records 页来源详情卡的类型短 token 新增明确 active/inactive 字体色，当前类型使用金色，非当前类型使用浅蓝灰色，不再只靠方括号表达选中状态。
- `LobbyScreen.gd` 新增 `COUNTER_PICK_TYPE_ACTIVE_COLOR` 和 `COUNTER_PICK_TYPE_INACTIVE_COLOR`，并在刷新 `CounterPickTypeRow` 时统一覆写 `font_color`、hover、pressed 和 disabled 字体色。
- 当前类型按钮保持 disabled，但 disabled 字体色会被覆写为 active 金色，避免默认灰色让当前类型看起来不可读或弱化。
- 新增 `get_counter_pick_type_button_font_color_text()` 测试接口，用于确认 UI 运行时实际取到的 active 字体色。
- `TrapRoomSmokeTest` 扩展断言，确认初始 Relics token 和直接选回 Relics 后都使用 `1.00,0.82,0.28` 金色 active 状态。
- 本批通过 `TrapRoomSmokeTest`、`LobbyScreenSmokeTest`、`MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整回归本轮耗时 335.7 秒。

## 第一百七十七批已落地靠拢改动

### 死亡来源反制类型 pressed 状态第一版
- Records 页来源详情卡的 `W/R/T/B/S` 类型 token 现在启用 `toggle_mode`，让当前类型拥有真正的 pressed 状态，更接近正式 segmented control。
- `_set_counter_pick_type_row_state()` 会同步设置 `button_pressed`，当前类型为 pressed 且 disabled，非当前类型为未按下且可点击。
- 场景文件中五个 `CounterPickType*Button` 默认启用 `toggle_mode`，让编辑器默认状态与运行时行为一致。
- 新增 `is_counter_pick_type_button_pressed()` 测试接口，用于验证类型切换时 pressed 状态随当前类型同步移动。
- `TrapRoomSmokeTest` 扩展断言，确认初始 Relics 为 pressed，循环到其它类型后 Relics 释放，直接选回 Relics 后 pressed 状态恢复。
- 本批通过 `TrapRoomSmokeTest`、`LobbyScreenSmokeTest`、`MenuFlowSmokeTest`、`HallArchiveSmokeTest`、`FullRunSmokeTest` 和 `git diff --check`；完整回归本轮耗时 329.5 秒。

## 第一百七十八批已落地靠拢改动

### 角色初始武器引用校验第一版
- `ContentPipelineSmokeTest` 的角色校验现在会读取完整武器资源 ID 集合，逐项确认每个角色的 `starting_weapon_ids` 都能解析到真实武器资源。
- 每个角色的初始武器列表新增非空和去重断言，避免后续扩角色时出现空 ID、重复武器位或拼写错误导致开局装配失效。
- 新增 `_resource_id_lookup()` helper，把资源 ID 集合构造成可复用查找表；当前先用于角色初始武器引用，后续可继续扩展到解锁、被动、图鉴或掉落池引用校验。
- 本批不改变运行时战斗逻辑和资源内容，只加固内容管线 smoke test，让类元气骑士式多角色/多武器扩池时更早暴露坏引用。
- 本批通过 `ContentPipelineSmokeTest` 和 `git diff --check`；Godot 退出时仍打印既有资源/RID 泄漏告警，但目标测试退出码为 0。

## 第一百七十九批已落地靠拢改动

### 角色初始武器运行时装配第一版
- `Player.gd` 现在会从当前角色资源的 `starting_weapon_ids` 解析对应武器资源，并在角色切换时重建玩家三槽 `weapon_loadout`。
- 角色切换后会回到第 1 槽并重新触发武器装备刷新，HUD 的武器名和三槽负载摘要会跟随角色初始武器变化。
- 新增 `get_weapon_loadout_ids()` 测试入口，直接暴露当前运行时 loadout ID，避免只通过显示名间接判断。
- `CharacterSmokeTest` 扩展为验证 Wanderer、Warden、Arcanist 和 Field Medic 的配置武器会进入运行时负载，并在 HUD 负载摘要中显示对应专属武器。
- 本批同时放宽两个既有脆弱断言：skill-ready 音效只要求触发音效计数增加，不再要求它一定是最后一个音效；Arcanist 回能只要求达到配置回能量，允许同帧自然回能叠加。
- 本批通过 `CharacterSmokeTest`、`ContentPipelineSmokeTest` 和 `git diff --check`；`ContentPipelineSmokeTest` 退出时仍有既有资源/RID 泄漏告警，但退出码为 0。

## 第一百八十批已落地靠拢改动

### 全角色初始装配回归覆盖第一版
- `CharacterSmokeTest` 现在覆盖 6 个角色的初始武器运行时装配，不再只验证 Wanderer、Warden、Arcanist 和 Field Medic。
- 新增 Rift Runner 的 `Basic Pistol / Ricochet Blaster / Arc Blade` 断言，确认敏捷/反弹/近战身份能进入菜单预览负载。
- 新增 Emberwright 的 `Basic Pistol / Blast Launcher / Coil Carbine` 断言，确认爆破/精准混合身份能进入菜单预览负载。
- 开始新局后，测试会检查 run summary 的 `loadout` 包含当前角色的武器组合，避免结算 Build 回顾和实际装配脱节。
- 本批通过 `CharacterSmokeTest`；它把角色选择、HUD 负载、开局锁定和结算摘要串成同一条回归链路。

## 第一百八十一批已落地靠拢改动

### 角色被动运行时加成第一版
- `Player.gd` 现在会把 6 个角色资源中的 `passive_id` 映射为轻量运行时加成，不再只把被动作为菜单展示文本。
- Wanderer 的 `steady_hands` 接入暴击与装填手感；Warden 的 `armored_core` 接入弹幕格挡半径、角度和伤害；Arcanist 的 `energy_focus` 接入射速与装填；Rift Runner 的 `phase_footing` 接入移动倍率；Emberwright 的 `volatile_focus` 接入伤害倍率；Field Medic 的 `triage_kit` 接入护甲恢复速率。
- 新增 `get_character_passive_summary()` 测试入口，直接暴露当前角色被动 ID 和加成摘要，避免烟测只通过最终倍率反推角色被动。
- 角色切换时会清理上一名角色的被动加成，再应用当前角色被动；技能临时加成结束后会回到当前角色的被动基线，而不是固定回到 1.0。
- 本批通过 `CharacterSmokeTest` 和 `ContentPipelineSmokeTest`；后者退出时仍有既有资源/RID 泄漏告警，但退出码为 0。

## 第一百八十二批已落地靠拢改动

### Field Medic 清房恢复被动第一版
- `triage_kit` 现在不再只是护甲恢复速率加成，还会监听现有 `Events.room_cleared` 信号，在清房后为 Field Medic 恢复少量 HP 和 Armor。
- 该效果复用 `Player.heal()` 和 `add_shield()`，因此会走现有 HUD、音效和事件反馈链路，不新增平行恢复接口。
- `get_character_passive_summary()` 新增 `room_clear_heal_amount` 和 `room_clear_shield_amount`，把事件型被动参数暴露给测试和后续 UI 文案。
- 角色切换仍通过 `_clear_character_passive_bonuses()` 清理清房恢复参数，避免其它角色继承 Field Medic 的事件型恢复。
- `CharacterSmokeTest` 新增 Field Medic 缺血缺甲后触发 `room_cleared` 的断言，确认清房恢复和主动技能治疗是两条独立机制。

## 第一百八十三批已落地靠拢改动

### Warden 破甲守势被动第一版
- `armored_core` 现在会监听现有 `Events.player_shield_broken` 信号，在护甲破裂后开启短时守势窗口，进一步强化近战挡弹半径、挡弹角度和反击伤害。
- 该窗口接入既有 `get_projectile_block_radius_bonus()`、`get_projectile_block_arc_bonus()` 和 `get_projectile_block_damage_bonus()`，因此 Warden 的 Arc Blade 装配能直接读到临时守势收益。
- `_tick_timers()` 统一衰减守势窗口计时，角色切换时通过 `_clear_character_passive_bonuses()` 清理持续时间、剩余时间和临时挡弹参数。
- `get_character_passive_summary()` 新增 `shield_break_guard_*` 摘要字段，暴露持续时间、剩余时间、激活状态和临时挡弹参数。
- `CharacterSmokeTest` 新增 Warden 破甲事件断言，确认守势窗口会激活、提升挡弹三项参数，并在计时结束后回到基础被动值。

## 第一百八十四批已落地靠拢改动

### Rift Runner 清房移速窗口第一版
- `phase_footing` 现在不再只是常驻移速加成，还会监听现有 `Events.room_cleared` 信号，在清房后触发短时移速窗口。
- 该效果复用现有 `apply_temporary_speed_boost()`、`_speed_boost_timer` 和 `get_current_speed_multiplier()`，不新增独立移动系统，也能和已有 Dash/临时移速逻辑共用回落路径。
- `get_character_passive_summary()` 新增 `room_clear_speed_multiplier_bonus`、`room_clear_speed_duration`、`room_clear_speed_active` 和 `speed_boost_remaining`，把清房速度窗口参数暴露给测试和后续 UI。
- 角色切换时会清理通用临时移速，避免 Rift Runner 的清房速度窗口残留到其它角色预览或后续测试段。
- `CharacterSmokeTest` 新增 Rift Runner 清房事件断言，确认速度窗口会激活、速度高于常驻被动基线，并在计时结束后回到基线。

## 第一百八十五批已落地靠拢改动

### Emberwright 击杀爆发被动第一版
- `volatile_focus` 现在不再只是常驻伤害加成，还会监听现有 `Events.enemy_died` 信号，在击杀后开启短时爆发窗口。
- 爆发窗口使用独立 `_passive_kill_burst_*` 状态接入 `get_damage_multiplier()` 和 `get_fire_rate_multiplier()`，避免覆盖事件房的 `_temporary_rule_*` 临时规则或主动技能加成。
- `_tick_timers()` 统一衰减击杀爆发计时，角色切换时通过 `_clear_character_passive_bonuses()` 清理持续时间、剩余时间和爆发倍率。
- `get_character_passive_summary()` 新增 `kill_burst_*` 摘要字段，暴露持续时间、剩余时间、激活状态、伤害倍率和射速倍率。
- `CharacterSmokeTest` 新增 Emberwright 击杀事件断言，确认击杀爆发会激活、伤害和射速高于常驻被动基线，并在计时结束后回到基线。

## 第一百八十六批已落地靠拢改动

### Arcanist 能量消耗 Focus 被动第一版
- `energy_focus` 现在不再只是常驻射速/装填加成，还会在武器实际消耗 Energy 后开启短时 Focus 窗口。
- 触发点限定在 `spend_energy_for_weapon()`，因此只有武器能量消耗会触发 Focus；主动技能回能和其它角色技能消耗不会混入这条被动链路。
- Focus 窗口使用独立 `_passive_energy_spend_focus_*` 状态接入 `get_fire_rate_multiplier()` 和 `get_reload_speed_multiplier()`，不覆盖主动技能、事件房临时规则或击杀爆发。
- `_tick_timers()` 统一衰减 Focus 计时，角色切换时通过 `_clear_character_passive_bonuses()` 清理持续时间、剩余时间和倍率。
- `CharacterSmokeTest` 新增 Arcanist 使用 `Energy Staff` 消耗能量的断言，确认 Focus 会激活、射速和装填高于常驻被动基线，并在计时结束后回到基线。

## 第一百八十七批已落地靠拢改动

### Wanderer 暴击稳定输出被动第一版
- `steady_hands` 现在不再只是常驻暴击率/装填加成，还会监听现有 `Events.projectile_critical_hit` 信号，在暴击后开启短时稳定输出窗口。
- 稳定输出窗口使用独立 `_passive_critical_focus_*` 状态接入 `get_fire_rate_multiplier()` 和 `get_reload_speed_multiplier()`，不覆盖 Arcanist 的能量 Focus、Emberwright 的击杀爆发、主动技能或事件房临时规则。
- 暴击回调会忽略目标为玩家自身的反馈事件，避免调试烟测或未来敌方暴击事件误触 Wanderer 的输出窗口。
- `_tick_timers()` 统一衰减暴击窗口计时，角色切换时通过 `_clear_character_passive_bonuses()` 清理持续时间、剩余时间和倍率，避免其它角色继承 Wanderer 的暴击收益。
- `get_character_passive_summary()` 新增 `critical_focus_*` 摘要字段，暴露持续时间、剩余时间、激活状态、射速倍率和装填倍率。
- `CharacterSmokeTest` 新增 Wanderer 暴击事件断言，确认暴击窗口会激活、射速和装填高于常驻被动基线，并在计时结束后回到基线。

## 第一百八十八批已落地靠拢改动

### 角色事件型被动 HUD 状态第一版
- HUD 新增 `PassiveStatusLabel`，常态显示当前角色被动基线，例如 `Steady Hands`、`Armored Core`、`Triage Kit`，让角色身份不只停留在菜单说明里。
- `Main.gd` 每帧从 Player 的 `get_character_passive_summary()` 同步被动摘要到 HUD，短时窗口会显示倒计时，例如 `Crit Focus`、`Guard Stance`、`Energy Flow`、`Speed Surge` 和 `Kill Burst`。
- HUD 只消费摘要字段，不反查 Player 或复制角色触发逻辑；事件型被动仍由 Player 侧状态和计时负责。
- `CharacterSmokeTest` 扩展为验证 Wanderer、Warden、Arcanist、Rift Runner、Emberwright 和 Field Medic 的被动 HUD 基线/激活文案，避免后续角色被动可读性退化。
- `UILayoutSmokeTest` 修正 ScrollContainer 校验边界：面板本体和滚动容器必须在视口内，但滚动内容不再被错误要求完整落在 720p/900p/1080p 可视区域内。

## 第一百八十九批已落地靠拢改动

### 角色事件型被动浮字反馈第一版
- `Events.gd` 新增 `player_passive_triggered` 信号，作为角色被动触发的统一反馈出口，避免每个角色各自直接调用 HUD 或 Main。
- `Player.gd` 在 `Crit Focus`、`Guard Stance`、`Energy Flow`、`Speed Surge`、`Kill Burst` 和 `Triage Kit` 触发时发出该信号；带持续时间的窗口只在从未激活变为激活时播报，避免连续暴击或连续能量消耗刷屏。
- `Main.gd` 监听该信号后复用现有 `show_message()` 和 `_spawn_floating_text()`，在玩家上方显示被动触发短浮字，并继续遵守 Combat Text 强度设置。
- 不同被动使用不同浮字颜色，区分稳定输出、护甲守势、能量流、速度爆发、击杀爆发和治疗支援。
- `CharacterSmokeTest` 扩展为验证各角色事件型被动触发时出现对应浮字，`CombatFeedbackSmokeTest` 继续覆盖基础伤害/暴击/护甲/治疗浮字链路。

## 第一百九十批已落地靠拢改动

### 角色事件型被动音效反馈第一版
- `AudioFeedback.gd` 现在监听统一的 `player_passive_triggered` 信号，让被动触发不只显示 HUD 消息和浮字，也会进入 SFX 反馈链路。
- 六个角色被动分别映射到轻量程序化占位音效：`steady_hands` -> `passive_focus`，`armored_core` -> `passive_guard`，`energy_focus` -> `passive_energy`，`phase_footing` -> `passive_speed`，`volatile_focus` -> `passive_burst`，`triage_kit` -> `passive_support`。
- 新增 `passive_trigger` 作为未知被动 ID 的回退音效，避免后续新增角色时出现静默触发。
- `AudioFeedbackSmokeTest` 扩展为逐一发出六类被动触发事件，验证 SFX 计数增加、最后播放 ID 正确，并覆盖被动 ID 到音效 ID 的解析入口。
- 本批通过 `AudioFeedbackSmokeTest`、`CharacterSmokeTest` 和 `ContentPipelineSmokeTest`；后者退出时仍有既有资源/RID 泄漏告警，但退出码为 0。

## 第一百九十一批已落地靠拢改动

### 角色事件型被动 HUD 脉冲第一版
- `HUD.gd` 新增被动状态触发脉冲计时，让 `PassiveStatusLabel` 在角色被动触发时短促提亮，补齐被动触发的 HUD 即时可读性。
- `update_character_passive_status()` 改为通过统一颜色刷新函数处理基线、激活窗口和触发脉冲，避免每帧状态刷新覆盖脉冲颜色。
- `Main.gd` 在处理 `player_passive_triggered` 时调用 `show_passive_trigger_pulse()`，继续保持 Player 只负责触发事件、HUD 只负责表现。
- `CharacterSmokeTest` 新增 Wanderer 暴击被动触发时的被动状态脉冲断言，覆盖脉冲启动、颜色提亮和计时结束回落。
- 本批通过 `CharacterSmokeTest` 和 `UILayoutSmokeTest`，确认新增 HUD 脉冲不破坏角色被动回归和现有布局约束。

## 第一百九十二批已落地靠拢改动

### 祝福/雕像触发音效反馈第一版
- `AudioFeedback.gd` 现在监听 `blessing_triggered`、`statue_triggered` 和 `statue_attuned`，让事件祝福和雕像共鸣不只显示消息/浮字，也能进入 SFX 反馈链路。
- 祝福触发按事件类型分流到 `blessing_clear`、`blessing_kill`、`blessing_guard` 和 `blessing_resonance`，未知事件回退到 `blessing_trigger`，方便后续新增祝福时先有可听反馈。
- 雕像触发新增 `statue_skill` 与 `statue_trigger` 回退音效，雕像调谐新增 `statue_attune`，把“获得/调谐/触发”三类时刻区分开。
- `AudioFeedbackSmokeTest` 扩展为校验祝福、雕像触发和雕像调谐的 SFX 计数、最后播放 ID 和解析入口，避免后续规则类内容扩展时静默退化。
- 本批通过 `AudioFeedbackSmokeTest` 和 `EventRoomSmokeTest`，确认音频反馈接入不影响真实事件房祝福/雕像触发链路。

## 第一百九十三批已落地靠拢改动

### 祝福/雕像触发 HUD 规则提示第一版
- `HUD.tscn` 在战斗状态区新增常驻 `RuleFeedbackLabel`，默认显示 `Rule: --`，触发时显示最近一次 `Blessing` 或 `Statue` 规则反馈，不临时插入节点，避免武器槽等状态信息上下跳动。
- `HUD.gd` 新增 `show_rule_trigger_feedback()`，用独立计时和颜色区分祝福暖色反馈、雕像冷色反馈，并在持续时间结束后回到空闲文本。
- `Main.gd` 在 `blessing_triggered`、`statue_triggered` 和 `statue_attuned` 回调中调用该 HUD 方法，让规则类触发形成“HUD 提示 + 浮字 + SFX”的统一反馈链。
- `EventRoomSmokeTest` 扩展真实房间事件链路，验证房间清理祝福、技能雕像和雕像调谐都会刷新 HUD 规则提示，并确认提示会按时回落。
- 本批通过 `EventRoomSmokeTest` 和 `UILayoutSmokeTest`，确认新增状态行不破坏事件房流程和 720p/900p/1080p 布局边界。

## 第一百九十四批已落地靠拢改动

### 规则触发 HUD 图标反馈第一版
- `HUD.tscn` 将原本纯文本 `RuleFeedbackLabel` 升级为固定行：`TextureRect` 显示注册图标，`Label` 保留类型 token fallback，右侧继续显示短文本，避免触发时临时插入节点造成状态区跳动。
- `HUD.gd` 的 `show_rule_trigger_feedback()` 现在接受 `icon_key`，按 `Blessing/Statue` 映射到内容图标注册表，优先显示贴图，贴图缺失时显示 `BLS/STU` 类型 token。
- `Main.gd` 在祝福触发、雕像触发和雕像调谐回调中复用 `_resolve_content_icon_key()`，确保 HUD 读取真实资源图标键而不是自行推断。
- `EventRoomSmokeTest` 扩展真实事件链路断言，覆盖规则反馈文本、颜色、图标键、贴图路径、可见性、fallback token 和回落清理。
- 本批通过 `EventRoomSmokeTest` 和 `UILayoutSmokeTest`，确认新增图标行不破坏事件房流程与 HUD 布局边界。

## 第一百九十五批已落地靠拢改动

### 角色被动 HUD 图标反馈第一版
- `HUD.tscn` 将 `PassiveStatusLabel` 升级为固定 `PassiveStatusRow`，包含角色注册图标、`CHR` token fallback 和被动状态文本，让角色身份在战斗 HUD 中更容易被识别。
- `Player.get_character_passive_summary()` 现在暴露 `character_id`、`display_name` 和稳定 `icon_key`；当角色资源未显式填写 `icon_key` 时，会回退为 `character_<id>`，避免空 key 错读注册表默认项。
- `HUD.gd` 只消费被动摘要并查 `ContentIconRegistry` 的 `characters` 页，优先显示角色贴图，缺贴图时显示类型 token，同时保持原有被动触发脉冲颜色。
- `CharacterSmokeTest` 扩展默认 Wanderer 和切换 Warden 的断言，覆盖被动状态图标键、贴图路径、可见性和 fallback token。
- 本批通过 `CharacterSmokeTest` 和 `UILayoutSmokeTest`，确认角色被动图标链路不破坏角色切换、被动触发和 HUD 布局边界。

## 第一百九十六批已落地靠拢改动

### 自爆敌人危险圈预警第一版
- `Enemy.gd` 的 `BOMBER` 行为在进入自爆前摇时会生成圆形 `DangerWarning`，直接标出爆炸半径，不再只依赖敌人闪色判断安全距离。
- 自爆预警复用现有 `DangerWarning` 轮廓、脉冲和 `danger_warning_started` 事件；预警节点不直接结算伤害，实际伤害仍由 `_self_destruct()` 在前摇结束时处理，避免双重伤害。
- 预警事件会携带 Bomber 的威胁伤害和来源，后续音频分流、死亡归因和复盘说明继续走统一危险预警链路。
- `EnemyVarietySmokeTest` 扩展 Bomber 断言，验证自爆前先出现圆形危险区、具备可读轮廓，且前摇期间不会提前掉血。
- 本批通过 `EnemyVarietySmokeTest`，并顺手加固了 Barrage Totem 前摇和精英死亡爆炸测试的时间窗口，减少帧率差异导致的误报。

## 第一百九十七批已落地靠拢改动

### 近战挡弹反馈事件与音效第一版
- `Events.gd` 新增 `player_projectile_blocked(player, weapon_data, blocked_count, block_position)`，把近战挡弹从武器内部计数推进为统一战斗反馈事件。
- `Weapon.gd` 在 `blocks_projectiles` 武器成功清除敌方弹丸后发出该事件，并携带挡弹数量、武器数据和挡弹位置；原有反击伤害和 `last_blocked_projectiles` 调试字段保持不变。
- `AudioFeedback.gd` 订阅挡弹事件并播放独立 `projectile_block` 程序化占位 SFX，避免和 Armor 吸收伤害的 `armor_block` 语义混在一起。
- 新增 `ProjectileBlockSmokeTest`，用 Guard Cleaver 覆盖真实挡弹事件、弹丸移除、后方弹丸不受影响和反击伤害。
- `AudioFeedbackSmokeTest` 扩展直接事件断言，验证 `player_projectile_blocked` 会触发 `projectile_block` 音效；本批通过 `ProjectileBlockSmokeTest` 和 `AudioFeedbackSmokeTest`。

## 第一百九十八批已落地靠拢改动

### 近战挡弹浮字反馈第一版
- `Main.gd` 现在订阅 `player_projectile_blocked`，只消费当前玩家自己的挡弹事件，避免其它测试节点或未来同屏实体误刷玩家 HUD 反馈。
- 成功挡弹会在 `block_position` 附近生成 `BLOCK` 或 `BLOCK xN` 浮字，并按挡弹数量触发轻量屏幕震动，让近战挡弹从“音效可听”推进到“场景位置可读”。
- 挡弹浮字继续复用现有 `_spawn_floating_text()`，因此会服从 Combat Text 强度设置，不新增一套独立表现开关。
- `CombatFeedbackSmokeTest` 新增挡弹位置断言，验证 `player_projectile_blocked` 浮字出现在被挡弹丸附近；同时加固低血角色测试前置，避免反馈测试因玩家死亡暂停场景树而误报。
- 本批通过 `CombatFeedbackSmokeTest` 和 `ProjectileBlockSmokeTest`，确认统一事件、真实挡弹和视觉反馈链路可以并存。

## 第一百九十九批已落地靠拢改动

### 近战挡弹火花反馈第一版
- 新增 `ProjectileBlockSpark` 轻量效果场景，用程序化圆环和放射线表现挡弹瞬间，不依赖正式素材也能让被挡弹位置更醒目。
- `Main.gd` 在消费 `player_projectile_blocked` 时同时生成火花效果，仍保持 `Weapon.gd -> Events -> Main/Audio` 的单向反馈链路。
- 火花会按 `blocked_count` 略微增加放射线数量和扩散半径，连续挡多发弹丸时比单发挡弹更容易被读到。
- `CombatFeedbackSmokeTest` 扩展挡弹反馈断言，验证火花出现在挡弹位置附近、携带挡弹数量，并在短生命周期后自动清理。
- 本批通过 `CombatFeedbackSmokeTest` 和 `ProjectileBlockSmokeTest`，确认挡弹火花、浮字、音效事件和真实 Guard Cleaver 挡弹链路兼容。

## 第二百批已落地靠拢改动

### 近战挡弹武器槽脉冲第一版
- `HUD.gd` 新增 `show_weapon_block_pulse()`，把近战主动挡弹从场景浮字/火花继续接入当前武器槽状态反馈。
- 挡弹脉冲会短暂染亮武器名称、当前负载槽、武器槽边框、图标和状态条，并在状态行显示 `Guard`，让玩家能读到“当前武器完成了一次防守动作”。
- `Main.gd` 在消费 `player_projectile_blocked` 时调用 HUD 脉冲方法，仍由统一事件驱动，不让 `Weapon.gd` 直接操作 HUD。
- `CombatFeedbackSmokeTest` 扩展挡弹反馈断言，验证 HUD 武器挡弹脉冲被触发，且武器名称和当前负载槽颜色发生变化。
- 本批通过 `CombatFeedbackSmokeTest`、`ProjectileBlockSmokeTest` 和 `UILayoutSmokeTest`，确认武器槽脉冲不破坏真实挡弹结算和 HUD 布局。

## 第二百零一批已落地靠拢改动

### 近战挡弹结算统计第一版
- `Main.gd` 新增 `_projectiles_blocked` 本局计数器，并在 `player_projectile_blocked` 事件来源为当前玩家且处于 RUNNING 状态时按 `blocked_count` 累加。
- `get_run_summary()` / `_build_run_summary()` 新增 `projectiles_blocked` 字段，让 Guard/挡弹路线不只停留在即时反馈，也能进入通关或失败复盘。
- `HUD.gd` 的结果总览文本和 `Combat` 分区新增 `Projectiles Blocked`，与 `Crits`、`Healing`、`Shield Blocked` 并列展示。
- `RunSummarySmokeTest` 通过直接挡弹事件验证 summary 字段、结果面板文本和 Combat 分区文本；`FullRunSmokeTest` 覆盖完整路线 summary 字段存在性。
- 本批通过 `RunSummarySmokeTest`、`ProjectileBlockSmokeTest` 和 `FullRunSmokeTest`，确认挡弹统计不会破坏真实挡弹链路和完整三层通关流程。

## 第二百零二批已落地靠拢改动

### 近战挡弹历史最佳记录第一版
- `Main.gd` 的历史记录新增 `best_projectiles_blocked`，在每局结算时取本局 `projectiles_blocked` 与历史值的最大值。
- `_default_history_stats()` 写入该字段，旧存档读取时会自然回退为 0，并通过现有历史保存流程持久化。
- `HUD.gd` 的结果总览和 `Record` 分区新增 `Best Guard Blocks`，让 Guard/挡弹构筑具备长期可见目标。
- `RunSummarySmokeTest` 扩展为验证本局挡弹数会进入历史记录、结果面板和重载后的 settings 读取。
- 本批通过 `RunSummarySmokeTest`；与上一批 `projectiles_blocked` summary 字段一起，把主动挡弹从战斗反馈推进到局外长期记录。

## 第二百零三批已落地靠拢改动

### 大厅 Records 挡弹最佳记录第一版
- `LobbyScreen.gd` 的 Records 页新增 `Defense: Best Guard Blocks` 独立行，避免继续拉长主记录行，同时让 Guard/挡弹构筑在大厅长期记录中可见。
- 大厅总览页复用同一 Records 文案，因此玩家从 All Records 或 Records 分页都能看到挡弹最佳值。
- `HallArchiveSmokeTest` 在真实 run 中触发一次 `player_projectile_blocked`，通关保存后重载大厅并验证 `Best Guard Blocks 4`，覆盖 settings 持久化到大厅展示链路。
- `LobbyScreenSmokeTest` 扩展 Records 分页断言，验证新档案的初始 `Best Guard Blocks 0` 文本存在。
- 本批通过 `HallArchiveSmokeTest` 和 `LobbyScreenSmokeTest`，把上一批的历史字段接入局外大厅记录体验。

## 第二百零四批已落地靠拢改动

### AimAssistController 候选组接口第一版
- `AimAssistController.gd` 新增 `candidate_groups`、`collect_candidates()` 和 `pick_target_from_tree()`，把目标候选收集从 Player 硬编码推进到可复用控制器接口。
- 控制器会按配置组收集 `Node2D` 目标、去重、过滤无效和已死亡目标；默认仍使用 `enemies` 组，保持 PC 鼠标瞄准默认体验不变。
- `Player.gd` 的 `_get_aim_assist_candidates()` 改为委托 `AimAssistController.collect_candidates()`，并补充测试用候选组配置/读取方法，为训练靶、移动端和未来手柄目标层复用同一接口。
- `AimAssistSmokeTest` 扩展为验证自定义 `training_dummy` 候选组可以被辅助瞄准选中，不再只能依赖敌人组。
- `ContentPipelineSmokeTest` 扩展 `AimAssistController` 契约断言，验证候选组公开接口、场景树收集和目标选择流程。
- 本批通过 `AimAssistSmokeTest`、`ContentPipelineSmokeTest` 和 `SettingsSmokeTest`，确认辅助瞄准设置、公共控制器和内容契约仍然稳定。

## 第二百零五批已落地靠拢改动

### 训练房 Aim Assist 目标层切换第一版
- `Main.gd` 新增 `_apply_aim_assist_candidate_groups_for_state()`，根据当前 `run_state` 切换辅助瞄准候选组。
- 正式 run 和主菜单等非训练状态继续使用 `enemies` 组，保持 PC 首发默认战斗目标层不变。
- 训练房进入和重置时切换为 `training_dummy` 组，让训练入口真正使用上一批 `AimAssistController` 的可配置候选组能力。
- `_apply_gameplay_settings_to_player()` 会在应用 Aim Assist 开关/强度后同步当前状态的候选组，避免打开设置后把训练房目标层重置成默认敌人组。
- `TrainingRoomSmokeTest` 扩展进入训练和训练重置后的候选组断言，并修正 6 角色池下回到 Wanderer 的测试导航。
- `SettingsSmokeTest` 扩展非训练状态候选组断言，确认普通状态仍使用 `enemies` 且不会误用 `training_dummy`。
- 本批通过 `TrainingRoomSmokeTest`、`SettingsSmokeTest` 和 `AimAssistSmokeTest`，把辅助瞄准从公共接口推进到真实训练房校准流程。

## 第二百零六批已落地靠拢改动

### 训练 HUD Aim Assist 校准状态第一版
- `HUD.gd` 的训练面板新增 Aim Assist 状态行，显示当前开关、强度百分比和目标层，例如 `Aim Assist: On 70% | Targets Training`。
- `Main.gd` 在 `_update_training_hud()` 前同步 `aim_assist_text`、`aim_assist_enabled`、`aim_assist_strength_percent` 和 `aim_assist_target_layer` 到训练 summary。
- 训练中应用设置后，`_apply_gameplay_settings_to_player()` 会刷新训练 HUD，确保状态行从 `Off 35%` 更新到玩家刚保存的强度。
- `TrainingRoomSmokeTest` 扩展默认 Off/35%/Training 展示断言，并验证训练中保存 Aim Assist 设置后 HUD 刷新为 On/70% 且目标层仍是 Training。
- 本批通过 `TrainingRoomSmokeTest`、`SettingsSmokeTest` 和 `UILayoutSmokeTest`，让训练房从后台目标层切换推进到玩家可读的校准入口。

## 第二百零七批已落地靠拢改动

### Aim Assist 校准训练 drill 第一版
- `Main.gd` 新增 `Aim Assist` 训练 drill，保持 3 个训练靶布局，其中 2 个 `assist` 靶作为完成目标，1 个 `standard` 靶作为直线参考。
- 新 drill 复用现有 `target_type_hits` 目标系统，完成条件为 `Tag both assist targets 2/2`，因此不新增独立进度框架。
- `TrainingDummy.gd` 为 `assist` 靶补充独立外圈和核心颜色，让辅助瞄准校准靶与普通、移动、护甲和爆发靶区分开。
- `TrainingRoomSmokeTest` 扩展为覆盖循环到 Aim Assist drill、命中两个 assist 靶、Clean 徽章保存、重置保留最佳徽章、重载后大厅展示 `Aim Assist | Badge: Clean [CN]`。
- `LobbyScreenSmokeTest` 和 `HallArchiveSmokeTest` 同步把训练徽章总数从 `3` 更新到 `4`，确认大厅总览、Records 页和快速状态不会因新增训练项退化。
- 本批通过 `TrainingRoomSmokeTest`、`HallArchiveSmokeTest` 和 `LobbyScreenSmokeTest`，把 Aim Assist 从可读状态推进到可练习、可记录的训练流程。

## 第二百零八批已落地靠拢改动

### Aim Assist 强度档位反馈第一版
- `Main.gd` 新增 Aim Assist 强度档位计算，并在训练 summary 中暴露 `aim_assist_strength_band`。
- 训练 HUD 的 Aim Assist 状态行从单纯显示开关和百分比，扩展为 `Aim Assist: On 70% | Band Strong | Targets Training` 这类可读档位反馈。
- 档位规则保持轻量：关闭或 0 强度为 `Off`，低强度为 `Light`，中段为 `Balanced`，高强度为 `Strong`，帮助训练 drill 更直观地区分设置变化。
- `TrainingRoomSmokeTest` 扩展默认 `Band Off`、设置后 `Band Strong` 和 Aim Assist drill 内 summary 字段断言，避免后续设置/HUD 改动丢失校准反馈。
- 本批通过 `TrainingRoomSmokeTest` 和 `UILayoutSmokeTest`，并继续把训练房作为 PC 辅助瞄准与未来移动端目标选择的校准入口。

## 第二百零九批已落地靠拢改动

### 设置页 Aim Assist 档位预览第一版
- `HUD.gd` 的设置面板在 Aim Assist 强度滑条旁新增 `Aim Assist Band` 预览行，玩家不进入训练房也能看到当前 Off/Light/Balanced/Strong 档位。
- 设置页预览会随 Aim Assist 开关和强度滑条即时刷新；关闭时固定显示 `Off`，开启 60% 时显示 `Balanced`。
- `Main.get_settings_summary()` 新增 `aim_assist_strength_band` 字段，让设置摘要、后续大厅设置页和测试入口复用同一档位语义。
- `SettingsSmokeTest` 扩展默认 Off、设置页即时预览 Balanced、应用后 summary Balanced、重载后设置页仍显示 Balanced 的断言。
- 本批通过 `SettingsSmokeTest` 和 `UILayoutSmokeTest`，把 Aim Assist 校准反馈从训练房推进到设置入口。

## 第二百一十批已落地靠拢改动

### 设置页 Aim Assist 档位快捷选择第一版
- `HUD.gd` 在设置页 Aim Assist 区域新增 `Off / Light / Balanced / Strong` 分段按钮行，让玩家可以直接选择常用强度档位，再按原有 Apply 流程保存。
- 档位按钮会同步 Aim Assist 开关、强度滑条、`Aim Assist Band` 文本和按钮高亮：`Off` 会关闭辅助瞄准，`Light` 使用 35%，`Balanced` 使用 60%，`Strong` 使用 80%。
- 设置页仍保留滑条作为精细调节入口，因此快捷档位不会削弱玩家自定义强度能力。
- `SettingsSmokeTest` 扩展默认 `Off` 高亮、选择 `Strong` 后开关/滑条/档位/按钮高亮同步、再切回 `Balanced` 保存并重载回显的断言。
- 本批通过 `SettingsSmokeTest` 和 `UILayoutSmokeTest`，把 PC 首发辅助瞄准设置从“可读”推进为“可快速操作”。

## 第二百一十一批已落地靠拢改动

### 训练房 Aim Assist 快捷校准第一版
- `HUD.gd` 在训练面板 Aim Assist 状态行下新增 `Off / Light / Balanced / Strong` 快捷按钮，让玩家在训练靶场中不用打开设置页也能即时切换辅助瞄准强度。
- `Main.gd` 新增 `apply_aim_assist_preset()`，统一解析档位、应用玩家 Aim Assist 设置、保存 settings，并在训练状态下刷新训练 HUD。
- 训练房快捷档位与设置页语义保持一致：`Off` 关闭辅助瞄准，`Light` 为 35%，`Balanced` 为 60%，`Strong` 为 80%。
- `TrainingRoomSmokeTest` 扩展默认 `Off` 高亮、训练面板选择 `Light` 后 HUD/summary 更新、再通过设置切到 `Strong` 后训练按钮同步高亮的断言。
- 本批通过 `TrainingRoomSmokeTest`、`SettingsSmokeTest` 和 `UILayoutSmokeTest`，把 Aim Assist 校准从“设置页预设”推进到真实训练场内即时调试。

## 第二百一十二批已落地靠拢改动

### 手柄右摇杆瞄准输入入口第一版
- `Main.gd` 新增固定 `aim_left / aim_right / aim_up / aim_down` 输入动作，并绑定到手柄右摇杆 X/Y 轴，作为非键盘重绑定项保留在默认控制入口中。
- `Player.gd` 将原来的鼠标瞄准目标抽象为当前瞄准目标：右摇杆超过死区时使用摇杆方向生成远距瞄准点，否则继续回退到鼠标位置，保持 PC 首发鼠标体验不变。
- Aim Assist 继续作用在“原始瞄准方向”之后，因此鼠标、右摇杆和训练房目标层切换复用同一套吸附逻辑，不新增独立手柄专用瞄准分支。
- `HUD.gd` 的底部输入提示更新为 `Aim Mouse/RS`，让手柄右摇杆入口可见但不扩展成完整教程。
- `SettingsSmokeTest` 增加右摇杆 InputMap 绑定、非键盘重绑定列表隔离、玩家读取右摇杆归一化向量和输入提示的断言。
- 本批通过 `SettingsSmokeTest`、`AimAssistSmokeTest`、`TrainingRoomSmokeTest` 和 `UILayoutSmokeTest`，把“PC 优先、预留手柄”的控制策略推进到可运行输入入口。

## 第二百一十三批已落地靠拢改动

### 手柄基础动作默认绑定第一版
- `Main.gd` 在默认 InputMap 中补齐左摇杆移动绑定：`move_left / move_right / move_up / move_down` 继续复用既有动作名，因此玩家移动逻辑无需新增手柄专用分支。
- `shoot` 现在除鼠标左键外，也默认绑定右扳机 RT，并补右肩键 RB 作为射击 fallback，保证手柄基础开火入口可用。
- `reload / skill / interact / pause` 分别补充 X / A / Y / Start 默认按钮，`weapon_slot_1/2/3` 补充 D-pad 左/上/右，先满足基础运行和换武器，不展开完整手柄设置页。
- `_apply_input_bindings()` 仍只替换键盘事件，因此玩家重绑定键盘时不会清掉手柄默认轴/按钮事件。
- `HUD.gd` 的底部提示更新为 `Move W/A/S/D/LS` 与 `Shoot LMB/RT`，把基础手柄入口以低成本方式显露出来。
- `SettingsSmokeTest` 增加左摇杆、RT/RB、X/A/Y/Start 和 D-pad 武器槽绑定断言；本批通过 `SettingsSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`。

## 第二百一十四批已落地靠拢改动

### 动态输入提示切换第一版
- `HUD.gd` 新增最近输入设备状态，默认显示键鼠提示；检测到手柄按钮或摇杆轴超过阈值时切换到手柄提示，检测到键盘、鼠标点击或有效鼠标移动后切回键鼠提示。
- 底部输入提示拆成两套文案：键鼠模式保留 `Move W/A/S/D | Aim Mouse | Shoot LMB`，手柄模式显示 `Move LS | Aim RS | Shoot RT/RB`，避免同一行同时塞入所有平台入口。
- 动态提示只影响 HUD 可读性，不改变实际 `InputMap`、键盘重绑定、手柄默认绑定或 settings 保存结构。
- `SettingsSmokeTest` 增加默认键鼠提示、手柄提示切换、鼠标事件切回键鼠、手柄按钮事件切换到手柄的断言。
- 本批通过 `SettingsSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，把前两批手柄输入入口推进到更清晰的运行时可读反馈。

## 第二百一十五批已落地靠拢改动

### Controller 布局摘要第一版
- `HUD.gd` 新增首版 Controller 布局摘要，集中描述 `Move LS`、`Aim RS`、`Shoot RT/RB`、`Weapons D-Pad` 等手柄入口，避免 HUD 手柄提示继续散落硬编码按钮名。
- 手柄模式的底部输入提示现在由 `_format_controller_layout_hint()` 从同一张布局表生成，为后续不同手柄平台、图标化提示或可配置布局预留统一入口。
- 设置页新增只读 `Controller` 布局摘要行，玩家在配置音量、Aim Assist、键盘键位时也能看到当前手柄默认布局。
- 本批不改变实际 `InputMap`、键盘重绑定或 settings 保存结构，只把第 212-214 批的手柄入口推进到可维护的提示/展示层。
- `SettingsSmokeTest` 增加布局表、手柄 HUD 提示和设置页 Controller 摘要同源断言；本批通过 `SettingsSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`。

## 第二百一十六批已落地靠拢改动

### ControllerLayout 共享接口第一版
- 新增 `scripts/input/ControllerLayout.gd`，把 `Move LS`、`Aim RS`、`Shoot RT/RB`、`Reload X` 等默认手柄布局从 HUD 私有常量提升为共享输入布局脚本。
- `HUD.gd` 的手柄底部提示和设置页 Controller 摘要继续显示同一份布局，但现在通过 `ControllerLayout.format_hint()` 生成。
- `Main.gd` 的 `get_settings_summary()` 新增 `controller_layout` 字段，暴露 `scheme`、`hint` 和 `items`，让大厅设置、后续 Controller 设置页或自动化测试可以从游戏根节点读取布局摘要。
- 本批仍不改变实际手柄默认绑定、不写入 settings，也不引入完整手柄重绑定；重点是把布局说明推进为可复用公共接口。
- `SettingsSmokeTest` 增加 `controller_layout` summary 字段断言，并继续校验 HUD 手柄提示和设置页布局展示同源；本批通过 `SettingsSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`。

## 第二百一十七批已落地靠拢改动

### Controller 布局资源化第一版
- 新增 `scripts/input/ControllerLayoutData.gd` Resource 类型，用 `scheme`、`item_ids`、`item_labels` 和 `item_controls` 描述手柄布局，并提供 `get_items()`、`format_hint()` 和 `get_summary()`。
- 新增 `resources/input/default_controller_layout.tres`，把默认手柄布局从脚本常量迁移到可编辑资源数据，为后续平台差异、图标提示和完整手柄重绑定继续铺路。
- `ControllerLayout.gd` 现在 preload 默认布局资源并保留原有静态接口，因此 `Main.gd`、`HUD.gd` 和测试调用点不需要知道布局数据来自 `.tres`。
- 本批不改变实际 InputMap 绑定、不改变 settings 保存结构，只把手柄布局说明从共享脚本继续推进为资源化数据。
- `SettingsSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest` 继续通过，确认资源化后 settings summary、HUD 提示和设置页 Controller 摘要保持同源。

## 第二百一十八批已落地靠拢改动

### Controller 布局动作契约第一版
- `ControllerLayoutData.gd` 新增 `item_actions` 字段，每个布局显示项现在能声明自己对应的真实 `InputMap` action 列表。
- `default_controller_layout.tres` 为 `Move`、`Aim`、`Shoot`、`Weapons` 等布局项补齐动作契约，例如 `Move` 对应 `move_left/move_right/move_up/move_down`，`Weapons` 对应三个武器槽动作。
- `ControllerLayoutData.get_items()` 会在每个 item 中暴露 `actions`，让 `Main.get_settings_summary().controller_layout.items` 不只包含展示文案，也包含可验证的输入动作映射。
- `SettingsSmokeTest` 新增布局动作契约校验：遍历每个 Controller item，确认其 actions 非空、存在于 `InputMap`，并且至少拥有一个手柄轴或按钮事件。
- 本批不改变手柄默认绑定本身，而是把“说明文字”和“实际输入动作”连成可测试契约，继续降低后续 Controller 设置页和图标提示的漂移风险。

## 第二百一十九批已落地靠拢改动

### Controller 调参资源化第一版
- `ControllerLayoutData.gd` 新增 `aim_deadzone`、`aim_target_distance`、`input_switch_threshold` 和 `mouse_return_threshold`，把右摇杆瞄准和 HUD 输入提示切换阈值纳入同一份 Controller 布局资源。
- `Player.gd` 的右摇杆瞄准死区和远距瞄准点距离改为读取 `ControllerLayout`，不再保留本地手柄瞄准常量。
- `HUD.gd` 的手柄/键鼠提示切换阈值改为读取 `ControllerLayout`，降低摇杆漂移和鼠标移动阈值说明与实现漂移的风险。
- `SettingsSmokeTest` 新增 `controller_layout.tuning` 断言，并用低于/高于资源阈值的模拟手柄与鼠标事件验证提示切换行为。
- 本批通过 `SettingsSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，继续把手柄支持从硬编码实现推进为可配置资源契约。

## 第二百二十批已落地靠拢改动

### Controller 调参设置页第一版
- `ControllerLayout.gd` 在资源默认值外新增运行时 tuning override，让玩家设置可以覆盖右摇杆死区和 HUD 手柄提示切换阈值，同时保留 `.tres` 作为默认布局来源。
- `Main.gd` 新增 `controller_aim_deadzone` 和 `controller_input_switch_threshold` 设置项，纳入 settings summary、`user://settings.cfg` 保存/重载和 `ControllerLayout.configure_tuning()` 应用流程。
- `HUD.gd` 的设置页新增 `Right Stick Deadzone` 和 `Gamepad Hint Switch` 两个滑条，分别控制右摇杆漂移过滤和 HUD 切到手柄提示所需的摇杆输入强度。
- `SettingsSmokeTest` 新增默认值、设置页预览、Apply、配置文件持久化、重载、Player 实际读取和 Controller summary override 断言。
- 本批通过 `SettingsSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，把 Controller 调参从资源默认值推进到玩家可见、可保存的设置入口。

## 第二百二十一批已落地靠拢改动

### Lobby Objective Board 第一版
- `LobbyScreen.gd` 在 Outpost Hall 快捷统计下新增 Objective Board，直接把下一局外目标压缩成一行可见提示。
- 目标板从现有 `get_hall_summary()` 数据推导，不新增经济规则：优先显示下一名未解锁角色的 Data Shards 进度、当前角色下一熟练度等级所需 XP、下一枚训练徽章目标。
- `HUD.gd` 新增 `get_lobby_objective_board_text()` 测试代理，让大厅目标板进入 UI 回归测试面。
- `LobbyScreenSmokeTest` 新增目标板断言，确认新档会显示 `Unlock Rift Runner 0/10 Data Shards`、`Master Wanderer 40 XP to L2` 和 `Training Basics badge: Hit all targets`。
- 本批通过 `LobbyScreenSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，继续把局外大厅从资料页推进为能提示重复游玩动力的主入口。

## 第二百二十二批已落地靠拢改动

### Lobby Objective Board 反制建议第一版
- `LobbyScreen.gd` 的 Objective Board 新增上次死亡来源反制目标：当 `last_defeat.has_record` 存在时，会优先显示 `Counter <source>: <tags>`。
- 反制标签复用 Records 页现有 `_get_defeat_source_counter_tags()` 规则，例如陷阱房 hazard 会提示 `Speed / Survival / Armor`，不新增独立规则表。
- `LobbyScreenSmokeTest` 使用合成 `last_defeat` summary 验证 `Counter Spike Trap: Speed / Survival / Armor`，确认目标板能读取持久化死亡来源并给出下一局 Build 方向。
- 本批通过 `LobbyScreenSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，让局外大厅从“下一目标提示”继续推进到“失败后反制再开一局”的复玩引导。

## 第二百二十三批已落地靠拢改动

### Lobby Objective Counter 路由第一版
- `LobbyScreen.gd` 的 Objective Board 新增 `Review` 按钮，仅在存在 `last_defeat.has_record` 时显示。
- `Review` 会调用 `open_objective_counter()`，直接切到 Records 页的 Sources 视图，并按上次死亡来源类型套用 source type 过滤，例如陷阱死亡会进入 Hazard 来源视图。
- 目标板按钮复用 Records 页已有 `_set_records_filter("sources")` 和 `_set_records_source_type_filter()`，不新增平行记录页或独立详情逻辑。
- `LobbyScreenSmokeTest` 新增按钮可见性、按钮文案、路由结果、Sources 死亡视图、Hazard source type 过滤和 Death Source Detail 展示断言。
- 本批通过 `LobbyScreenSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，把失败反制目标从静态提示推进为可操作的大厅导航入口。

## 第二百二十四批已落地靠拢改动

### Lobby Objective Build Route 第一版
- `LobbyScreen.gd` 的 Objective Board 新增 `Build` 按钮，仅在上次死亡来源能解析出可用 Counter Route 时显示。
- `Build` 调用新的 `open_objective_build_route()`，直接跳到既有 Codex build 路线筛选页，例如陷阱 hazard 会进入 `Relics -> Speed`。
- 该入口复用 `_resolve_counter_route_target()`、`_get_codex_filter_index()` 和既有 Codex filter 状态，不新增平行 Build 推荐规则。
- `LobbyScreenSmokeTest` 新增 Build 按钮隐藏/显示、按钮文案、tooltip、路由结果、`Relics` 页面、`Speed` 过滤和 `Adrenaline Charm` 命中断言。
- 本批通过 `LobbyScreenSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，把目标板反制入口拆成 `Review` 查看来源与 `Build` 直接尝试反制路线两条路径。

## 第二百二十五批已落地靠拢改动

### Lobby Objective Counter Pick 第一版
- `LobbyScreen.gd` 的 Objective Board 新增 `Pick` 按钮，仅在上次死亡来源能通过现有 Counter Pick 规则解析出具体推荐条目时显示。
- `Pick` 调用新的 `open_objective_counter_pick()`，直接打开推荐条目的 Codex 页面、路线过滤和搜索聚焦，例如陷阱 hazard 会聚焦到 `Relics -> Adrenaline Charm (Speed)`。
- `open_counter_pick()` 与 Objective Pick 现在共用 `_open_counter_pick_target()`，避免 Records 详情卡和 Objective Board 维护两套跳转写入逻辑。
- `Pick` 的 tooltip 展示具体推荐名和路线，例如 `Open counter pick: Adrenaline Charm in Relics -> Speed`，让玩家在大厅首屏就能判断下一局可尝试的反制物品。
- `LobbyScreenSmokeTest` 新增 Pick 按钮隐藏/显示、按钮文案、tooltip、搜索框、详情卡标题和 `Search "Adrenaline Charm"` 结果断言。
- 本批通过 `LobbyScreenSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，把失败后大厅引导从“查看来源/进入路线”推进到“一键打开具体反制推荐”。

## 第二百二十六批已落地靠拢改动

### Lobby Objective Pick 文案第一版
- `LobbyScreen.gd` 的 `_format_last_defeat_counter_goal()` 现在会读取现有 Counter Pick 焦点推荐，并把具体推荐追加到 Objective Board 文案中。
- 当上次死亡来源能解析出具体推荐时，目标板会显示类似 `Counter Spike Trap: Speed / Survival / Armor; Try Adrenaline Charm`，让玩家不需要 hover 按钮就能看到下一局可尝试物品。
- 该文案继续复用 `_get_focused_counter_pick_target()`，不新增独立推荐表，也不改变 `Pick` 按钮的跳转目标。
- `LobbyScreenSmokeTest` 新增 `Try Adrenaline Charm` 断言，同时继续覆盖 `Pick` 按钮 tooltip、搜索框和详情卡聚焦。
- 本批通过 `LobbyScreenSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，把大厅失败反制推荐从可操作入口推进为首屏可读目标。

## 第二百二十七批已落地靠拢改动

### Lobby Objective Pick 路线文案第一版
- `LobbyScreen.gd` 新增 `_format_counter_pick_objective_hint()`，把具体推荐压缩为 `Try <item> [<page>/<tag>]` 的可见目标板文案。
- 目标板现在会显示类似 `Counter Spike Trap: Speed / Survival / Armor; Try Adrenaline Charm [Relics/Speed]`，让推荐物品和实际 Codex 跳转路线在首屏保持一致。
- 该格式仍由 `_get_focused_counter_pick_target()` 的结果驱动，不改变 Counter Pick 推荐顺序，也不新增独立 UI 状态。
- `LobbyScreenSmokeTest` 将目标板断言收紧为 `Try Adrenaline Charm [Relics/Speed]`，确保文案包含具体条目和路线。
- 本批通过 `LobbyScreenSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，继续增强失败后重开一局前的 build 选择可读性。

## 第二百二十八批已落地靠拢改动

### Lobby Objective Pick 循环第一版
- `LobbyScreen.gd` 的 Objective Board 新增 `Next` 按钮，仅在当前上次死亡来源的聚焦推荐页存在多条 Counter Pick 时显示。
- 新增 `cycle_objective_counter_pick()`，复用 `_counter_pick_focus_indexes` 和 `_get_focused_counter_pick_targets()`，让目标板文案、`Pick` 按钮 tooltip 和打开目标保持同步切换。
- `open_counter_pick()` 和 Objective Pick 仍共用 `_open_counter_pick_target()`，`Next` 只改变推荐焦点，不新增跳转写入逻辑。
- `LobbyScreenSmokeTest` 新增 `Next 1/N` 初始状态、点击后目标板离开 `Adrenaline Charm`、推荐仍可见和 `Next 2/N` 状态断言。
- 本批通过 `LobbyScreenSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，让失败后大厅推荐从单一固定物品推进为可循环的 build 尝试入口。

## 第二百二十九批已落地靠拢改动

### Lobby Objective 跨类型推荐池第一版
- `LobbyScreen.gd` 新增 `_objective_counter_pick_focus_indexes`、`_get_objective_counter_pick_targets()` 和 `_get_objective_counter_pick_target()`，让 Objective Board 使用独立的大厅级推荐焦点。
- Objective 推荐池现在会跨 `Relics`、`Weapons`、`Talents`、`Blessings`、`Statues` 收集 Counter Pick，并按类型轮询顺序组织候选，避免 `Next` 只在同类遗物中循环。
- Records 来源详情卡仍保留原有 `_get_focused_counter_pick_targets()` 和类型页焦点逻辑，Objective 的跨类型循环不会改写 Records 详情卡推荐状态。
- `LobbyScreenSmokeTest` 新增循环后必须出现非 `Relics` 推荐类型的断言，确保大厅 `Next` 真正能带玩家看到不同 build 类型方向。
- 本批通过 `LobbyScreenSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，把死亡后大厅推荐从“同类型换物品”推进为“跨类型换 build 方向”。

## 第二百三十批已落地靠拢改动

### Lobby Objective Next 推荐预览第一版
- `LobbyScreen.gd` 新增 `get_objective_counter_pick_cycle_button_tooltip_text()` 测试入口，并让 Objective Board 的 `Next` tooltip 预览下一条推荐。
- 当存在多条大厅级 Counter Pick 时，`Next` tooltip 会显示类似 `Next pick: Try <item> [<page>/<tag>]`，复用 `_format_counter_pick_objective_hint()` 的短路线文案。
- `Next` 按钮文案仍保持 `Next x/N`，避免首屏按钮过宽；具体下一条推荐放在 tooltip 中，作为低成本可读性增强。
- `LobbyScreenSmokeTest` 新增初始 `Next pick:` tooltip、路线标记和切换后 tooltip 更新断言。
- 本批通过 `LobbyScreenSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，让跨类型推荐循环从盲切推进为可预览的下一步选择。

## 第二百三十一批已落地靠拢改动

### Lobby Objective Next 类型标记第一版
- `LobbyScreen.gd` 的 Objective `Next` 按钮文本从纯 `Next x/N` 扩展为 `Next x/N <type token>`，把下一条推荐的类型短标记直接放进按钮可见文本。
- 类型 token 复用 `_format_counter_pick_type_token()`，继续使用 `W/R/T/B/S` 映射 Weapons、Relics、Talents、Blessings、Statues，不新增另一套类型缩写。
- `Next` tooltip 仍保留完整 `Next pick: Try <item> [<page>/<tag>]` 预览，按钮文本只承担非 hover 状态下的轻量提示。
- `LobbyScreenSmokeTest` 新增 Objective `Next` 文本包含类型 token 的断言，并确认循环后 token 仍保持可见。
- 本批通过 `LobbyScreenSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，让跨类型推荐循环在键鼠 hover 之外也能读到下一条推荐的大类。

## 第二百三十二批已落地靠拢改动

### Lobby Objective Pick 类型标记第一版
- `LobbyScreen.gd` 的 Objective `Pick` 按钮文本从纯 `Pick` 扩展为 `Pick <type token>`，把当前推荐的大类直接放进按钮可见文本。
- 类型 token 复用 `_format_counter_pick_type_token()` 的 `W/R/T/B/S` 映射，与 `Next` 的下一条推荐类型标记保持同源。
- `Pick` tooltip 仍保留完整推荐名和路线，例如 `Open counter pick: Adrenaline Charm in Relics -> Speed`；按钮正文只承担当前推荐类型提示。
- `LobbyScreenSmokeTest` 新增初始 `Pick R` 和循环后 `Pick` 类型 token 更新断言，确保当前推荐和 `Next` 后的可见状态同步。
- 本批通过 `LobbyScreenSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，让 Objective Board 在不依赖 hover 的情况下同时读到当前推荐类型和下一条推荐类型。

## 第二百三十三批已落地靠拢改动

### Lobby Objective 类型提示标签第一版
- `LobbyScreen.gd` 在 Objective Board 的 `Pick/Next` 按钮后新增 `ObjectiveCounterPickTypeLabel`，用 `Now <type> | Next <type>` 解释当前推荐和下一条推荐的大类。
- 类型提示标签复用 `_format_counter_pick_type_label()` 与 `_format_counter_pick_type_token()`，因此 `Relics/Weapons/Talents/Bless/Statues` 全称和 `R/W/T/B/S` 字母 token 来自同一套规则。
- 标签仅在存在具体 Counter Pick 时显示；没有上次失败记录或没有推荐目标时隐藏，避免新档大厅出现无意义说明。
- 标签 tooltip 进一步给出 `Current type: Relics (R); Next type: Weapons (W)` 这类 token legend，作为鼠标和未来焦点说明的补充。
- `LobbyScreenSmokeTest` 新增无失败记录隐藏、初始 `Now Relics | Next ...`、tooltip token legend 和循环后标签更新断言；本批通过 `LobbyScreenSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`。

## 第二百三十四批已落地靠拢改动

### Lobby Objective 动作行拆分第一版
- `LobbyScreen.gd` 将 Objective Board 从单行 `ObjectiveBoardRow` 拆成目标文本行和 `ObjectiveBoardActionRow` 动作行，降低 `Review/Build/Pick/Next/Now...` 同屏时对目标文本的横向挤压。
- `ObjectiveBoardRow` 现在只承载 `ObjectiveBoardLabel`；`ObjectiveBoardActionRow` 统一承载 `Review`、`Build`、`Pick`、`Next` 和类型提示标签。
- 动作行仅在存在上次失败记录时显示；新档或无失败记录时保持隐藏，让普通大厅目标仍是简洁的单行局外目标。
- `_get_existing_objective_action_button()` 和 `_get_existing_objective_action_label()` 会把旧父节点下的运行时按钮迁移到动作行，避免后续场景文件显式化时出现重复控件。
- `LobbyScreenSmokeTest` 新增拆分布局契约、无失败记录动作行隐藏、失败记录后动作行显示断言；本批通过 `LobbyScreenSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，其中 `UILayoutSmokeTest` 覆盖 1280x720、1600x900 和 1920x1080。

## 第二百三十五批已落地靠拢改动

### Lobby Objective 进度条第一版
- `LobbyScreen.gd` 在 Objective 文本行和动作行之间新增 `ObjectiveProgressRow`，包含 `ObjectiveProgressLabel` 和真实 `ProgressBar`。
- 进度条不新增独立经济规则，而是从现有大厅 summary 派生：优先显示下一名角色解锁进度，其次显示当前角色熟练度进度，再其次显示训练徽章总进度。
- 初始大厅会显示类似 `Unlock Rift Runner`，进度值来自 `Data Shards / unlock_cost`，tooltip 给出 `0/10 Data Shards` 这类具体进度。
- `HUD.gd` 新增 `get_lobby_objective_progress_text/value/tooltip_text()` 测试代理，让局外目标进度进入自动化回归面。
- `LobbyScreenSmokeTest` 新增 Objective progress 可见、下一名角色解锁优先级、进度百分比和 tooltip 断言；本批通过 `LobbyScreenSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`。

## 第二百三十六批已落地靠拢改动

### Lobby Objective 进度数值常驻第一版
- `LobbyScreen.gd` 在 `ObjectiveProgressBar` 右侧新增 `ObjectiveProgressValueLabel`，把具体进度数值从 tooltip 提升为常驻文本。
- 三类 Objective progress 共用同一字段：角色解锁显示 `当前/成本 Data Shards`，熟练度显示 `当前/需求 XP`，训练徽章显示 `当前/总数 badges`。
- `ObjectiveProgressValueLabel` 使用固定宽度，减少数值变化时对进度条布局的抖动。
- `HUD.gd` 新增 `get_lobby_objective_progress_value_text()` 测试代理；`LobbyScreenSmokeTest` 新增初始 `0/10 Data Shards` 常驻文本断言。
- 本批通过 `LobbyScreenSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，继续把局外目标从“可看见进度条”推进为“不 hover 也能读到具体进度”。

## 第二百三十七批已落地靠拢改动

### Lobby Objective 进度入口第一版
- `LobbyScreen.gd` 在 Objective Progress 行新增 `ObjectiveProgressActionButton`，让局外目标从可读进度继续推进为可点击导航入口。
- 进度摘要现在声明 `action`、`target_page`、`action_text` 和 `action_tooltip`：角色解锁/熟练度目标显示 `Roster` 并跳到 Characters 页，训练徽章目标显示 `Train` 并触发训练入口。
- `open_objective_progress_target()` 复用 `_set_active_page()` 和现有 `training_requested` 信号，不新增平行导航系统。
- `LobbyScreenSmokeTest` 新增 `Roster` 按钮、Rift Runner tooltip、点击后进入 Characters 页并展示解锁目标的断言。
- 本批通过 `LobbyScreenSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，让大厅 Objective Progress 从状态展示推进为可直接行动的复玩引导。

## 第二百三十八批已落地靠拢改动

### Lobby Objective Train 入口回归第一版
- `LobbyScreenSmokeTest` 新增合成大厅 summary：所有角色已解锁、当前角色熟练度已满、训练徽章未满，用来强制 Objective Progress fallback 到 `Training Badges`。
- 测试现在断言训练目标显示 `0/4 badges`、动作按钮显示 `Train`，并且点击 Objective Progress action 后进入 Training run state。
- 该批不改运行时代码，目标是补齐第二百三十七批中 `Train` 分支的自动化证据，避免只有 `Roster` 分支被验证。
- 本批通过 `LobbyScreenSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，让 Objective Progress 的角色和训练两条局外目标入口都有回归覆盖。

## 第二百三十九批已落地靠拢改动

### Lobby Objective 定向训练入口第一版
- `LobbyScreen.gd` 的训练徽章进度现在会从大厅 `training_drills` summary 中解析第一项未取得徽章的 drill，并把 `target_drill_id`、`target_drill_name` 写入 Objective Progress summary。
- `training_requested` 信号新增可选 drill id，`HUD.gd` 会把该 id 传给 `Main.start_training_room(target_drill_id)`；普通 Training 按钮继续传空 id，因此仍默认进入 Basics。
- `Main.gd` 新增 `_get_training_drill_index_by_id()`，训练房启动时可按 id 定位到对应 drill；无效或空 id 回退到 0，避免影响旧入口。
- `LobbyScreenSmokeTest` 将合成训练目标调整为 Basics 已完成、Movement 未完成，断言 `Train` tooltip 预览 Movement，点击 Objective Progress action 后训练面板直接进入 `Movement` drill。
- 本批通过 `LobbyScreenSmokeTest`、`TrainingRoomSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，让局外训练目标从“进入训练房”推进为“进入下一项缺失训练目标”。

## 第二百四十批已落地靠拢改动

### Lobby Objective 训练目标常驻标签第一版
- `LobbyScreen.gd` 的训练徽章 Objective Progress 在存在未完成 drill 时，会把进度标签从通用 `Training Badges` 改为 `Training: <Drill>`。
- 训练目标仍保留 `1/4 badges` 这类常驻数值和完整 tooltip；本批只把下一项 drill 名称提升到首屏可读文本，不新增新的训练选择规则。
- `LobbyScreenSmokeTest` 现在断言 Basics 已完成、Movement 未完成时，Objective Progress 常驻文本为 `Training: Movement`，并继续验证 `Train` 入口直达 Movement drill。
- 本批通过 `LobbyScreenSmokeTest`、`TrainingRoomSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，让大厅训练目标在不依赖 hover 的情况下可读。

## 第二百四十一批已落地靠拢改动

### Lobby Objective 训练完成态隐藏第一版
- `LobbyScreen.gd` 的训练徽章 Objective Progress 在 `training_drills` 存在、没有未完成 drill、且徽章计数达到总数时会返回空进度，不再显示 100% 的 `Train` 行。
- 该规则只处理“训练目标已全部完成”的边界；如果 summary 缺少 drill 明细但徽章总数未满，仍保留通用 `Training Badges` 进度，避免旧数据丢失训练入口。
- `LobbyScreenSmokeTest` 新增合成完成态：所有角色已解锁、熟练度已满、所有训练 drill 都有徽章时，Objective Progress 和 action 按钮都隐藏；随后再恢复 Movement 未完成态验证定向训练入口。
- 本批通过 `LobbyScreenSmokeTest`、`TrainingRoomSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，避免大厅把已完成局外目标继续展示为下一步行动。

## 第二百四十二批已落地靠拢改动

### Lobby Objective 完成态开局指引第一版
- `LobbyScreen.gd` 的 `_format_next_unlock_goal()`、`_format_current_mastery_goal()` 和 `_format_next_training_goal()` 在对应目标完成时不再返回 `Roster complete`、`Master ... maxed` 或 `Training badges complete`。
- 当没有上次失败反制、没有角色解锁、没有熟练度目标、也没有训练徽章目标时，Objective Board 会回退到既有 `Objectives: Start a run and test a new build`，把玩家导向下一局尝试 build。
- `LobbyScreenSmokeTest` 新增完成态目标板断言，确认所有局外目标完成后不会把 `complete`/`maxed` 文案当作 active objective 展示。
- 本批通过 `LobbyScreenSmokeTest`、`TrainingRoomSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`，让大厅完成态从“列出完成项”改为“回到下一局复玩入口”。

## 第二百四十三批已落地靠拢改动

### Lobby Objective 完成态 Start 动作第一版
- `LobbyScreen.gd` 在 Objective 动作行新增 `ObjectiveStartRunButton`，仅当没有失败反制、没有角色解锁目标、没有熟练度目标、没有训练徽章目标时显示。
- 完成态目标板现在会显示 `Objectives: Start a run and test a new build`，并在动作行给出 `Start` 按钮；普通新档仍因存在解锁/熟练度/训练目标而保持动作行隐藏。
- `Start` 按钮复用既有 `start_requested` 信号，不新增独立开局流程；若主 Start 按钮处于禁用状态，该 Objective Start 也会同步禁用。
- `LobbyScreenSmokeTest` 新增完成态动作行、Start 按钮文案、tooltip 和反制按钮隐藏断言；本批通过 `LobbyScreenSmokeTest`、`TrainingRoomSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`。

## 第二百四十四批已落地靠拢改动

### Lobby Objective Start 激活回归第一版
- `LobbyScreenSmokeTest` 新增独立 Main 实例，合成所有局外目标完成的大厅 summary 后点击 `ObjectiveStartRunButton`。
- 测试现在断言 Objective Start 激活后进入 `Running` run state，并且大厅隐藏，证明该按钮不仅可见，也实际复用开局流程。
- 本批不改运行时代码，只补第二百四十三批的行为级自动化证据，避免完成态 Start 停留在静态 UI 断言。
- 本批通过 `LobbyScreenSmokeTest`、`TrainingRoomSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`。

## 第二百四十五批已落地靠拢改动

### Lobby Objective Start 状态复位回归第一版
- `LobbyScreenSmokeTest` 扩展 Objective Start 的状态切换断言：当上次失败反制目标存在时，`ObjectiveStartRunButton` 必须隐藏，只显示 Review/Build/Pick/Next 这一组反制动作。
- 同一测试还覆盖从“所有局外目标完成”切回“Training: Movement” 训练目标时，Objective 动作行和 Objective Start 都会重新隐藏，避免完成态按钮残留。
- 本批不改运行时代码，只补第二百四十三/二百四十四批的状态复位证据，让完成态 Start 不会污染其它大厅目标状态。
- 本批通过 `LobbyScreenSmokeTest`、`TrainingRoomSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`。

## 第二百四十六批已落地靠拢改动

### Lobby Objective Start 角色提示第一版
- `LobbyScreen.gd` 新增 `_get_objective_start_run_tooltip()`，让完成态 `ObjectiveStartRunButton` 的 tooltip 从当前大厅 summary 读取角色名。
- 完成态开局提示现在会显示类似 `Start a run with Wanderer`，把“继续开一局”从泛称按钮推进为绑定当前角色的复玩入口。
- 大厅内切换角色时会同步本地 summary 当前角色索引，并刷新当前角色图标和 Objective Start tooltip，避免 hover 文案停留在上一个角色。
- 如果底层 Start 按钮不可用，Objective Start tooltip 会回退为“解锁或选择可用角色后再开局”的禁用提示；开局流程本身仍复用既有 `start_requested` 信号。
- `LobbyScreenSmokeTest` 现在同时断言完成态 tooltip 和实际点击前 tooltip 都包含 `Wanderer`，避免后续改动把角色上下文退回成泛称。
- 本批通过 `LobbyScreenSmokeTest`、`TrainingRoomSmokeTest`、`HallArchiveSmokeTest`、`UILayoutSmokeTest` 和 `MenuFlowSmokeTest`。

## 第二百四十七批已落地靠拢改动

### 35 武器 / 40 遗物内容深度与专属 Build 参数第一版
- 武器池从 30 把扩到 35 把，新增原创武器 `Quench Repeater`、`Furnace Scattergun`、`Bastion Saw`、`Rift Bloom` 和 `Thunder Nest`，分别覆盖减速精准、燃烧霰射、重击挡弹、环形弹跳和传奇部署控场定位。
- 遗物池从 35 个扩到 40 个，新增 `Ricochet Gyro`、`Blast Radius Gauge`、`Kinetic Bridle`、`Reserve Drum` 和 `Flux Reservoir`。
- `RelicData`、`RelicSystem`、`Player`、`Weapon`、`Projectile` 和 `DeployableTrap` 新增额外弹跳、爆炸半径、击退倍率、弹匣容量与最大能量效果链路；弹匣扩容会立即补满新增槽位，并通过独立负载属性刷新信号同步 HUD 三槽容量。
- 新武器已进入普通奖励、商店和 Boss 武器池；新遗物已进入五类资源化掉落表、奖励/商店 fallback 池及高级/Boss 宝箱覆盖。
- `ContentPipelineSmokeTest` 将内容下限提升为 35 武器 / 40 遗物，并锁定新 ID 与 Build 标签；`RelicSmokeTest` 直接验证五类新效果运行时数值。
- `WeaponSmokeTest` 将短生命周期弹丸、挥砍闪光、能量状态和 HUD 脉冲改为同步读取，避免资源池扩大后的首帧耗时让测试把已发生的反馈误判为缺失。
- 本批通过 `ContentPipelineSmokeTest`、`RelicSmokeTest`、`WeaponSmokeTest`、`ChestSmokeTest`、`ShopSmokeTest`、`HallArchiveSmokeTest` 和 `LobbyScreenSmokeTest`。

## 第二百四十八批已落地靠拢改动

### 35 武器 / 40 遗物专属图标补齐第一版
- 为 `Quench Repeater`、`Furnace Scattergun`、`Bastion Saw`、`Rift Bloom` 和 `Thunder Nest` 新增 5 个 64px 武器 SVG 图标，延续冷青边框、深色底板和琥珀信号色的工业奇幻语言。
- 为 `Ricochet Gyro`、`Blast Radius Gauge`、`Kinetic Bridle`、`Reserve Drum` 和 `Flux Reservoir` 新增 5 个遗物 SVG 图标，以紫色边框区分内容类型，并用陀螺、刻度表、导轨、弹鼓和能量罐主轮廓表达效果。
- 新增 10 个 `ContentIconDefinitionData` 资源并写入 `content_icon_registry.tres`，注册表定义下限从 102 提升到 112；新增条目不再使用默认武器/遗物 fallback。
- `ContentPipelineSmokeTest` 将 10 个新 icon key 纳入逐条目路径、非 fallback 和 `ResourceLoader.exists()` 校验，并将注册表数量契约提升到 112。
- 使用 Godot 无头编辑器完成 10 个 SVG 导入，并生成 2×5 联系表做视觉检查；十个图标均非空、主体未贴边，且在 64px 语义上可区分。
- 本批通过 `ContentPipelineSmokeTest`、`WeaponSmokeTest`、`HallArchiveSmokeTest` 和 `LobbyScreenSmokeTest`，确认注册表、HUD 武器槽、图鉴条目和完整大厅均能加载新贴图。

## 第二百四十九批已落地靠拢改动

### 部署物 Field / Mine / Sentry 行为分化第一版
- `WeaponData` 新增 `deployable_behavior`，支持 `field`、`mine`、`sentry` 三种数据驱动部署行为。
- `Snare Beacon` 和 `Thunder Nest` 配置为 `field`，按周期影响范围内全部敌人；`Ember Mine` 配置为 `mine`，检测到范围目标后执行一次范围爆发并销毁；`Sentry Seed` 配置为 `sentry`，每次只锁定最近目标。
- `DeployableTrap.gd` 将目标收集、最近目标选择、地雷触发退场拆成独立逻辑，同时保留伤害、状态、击退、持续时间和部署物遗物倍率的统一接口。
- 三类部署物新增不同程序化轮廓：Field 使用双环范围场，Mine 使用橙色菱形触发体，Sentry 使用炮台矩形和随最近目标旋转的朝向线，避免局内仍只靠名称区分。
- `Main.gd` 的武器摘要新增行为字段，Outpost Hall 武器详情会显示 `Deploy Field`、`Deploy Mine` 或 `Deploy Sentry`，让玩家在图鉴中直接读取差异。
- `ContentPipelineSmokeTest` 新增行为枚举与标签契约；`WeaponSmokeTest` 新增哨戒仅攻击最近目标、地雷范围爆发后销毁和减速场保持持续生效的行为级断言。
- 本批通过 `ContentPipelineSmokeTest`、`WeaponSmokeTest`、`RelicSmokeTest`、`HallArchiveSmokeTest` 和 `LobbyScreenSmokeTest`。

## 第二百五十批已落地靠拢改动

### 40 武器 / 45 遗物与 Homing / Chain Build 路线第一版

- `WeaponData` 新增追踪角速度、索敌半径、连锁目标数、连锁半径和连锁伤害倍率；`Projectile` 会按角速度逐帧转向最近敌人，并在主命中后按半径逐跳选择未命中的最近目标。
- 连锁命中生成短生命周期青色折线反馈，保留伤害、击退、状态和命中事件接口；追踪与连锁遗物只增强原本支持对应机制的武器，不会把基础手枪等普通武器隐式改造成新模式。
- 新增 Compass Needle、Relay Arc、Lantern Swarm、Undertow Volley、Stormglass Rail 五把原创武器，覆盖单发追踪、连锁清群、环形追踪、追踪减速霰弹和传奇蓄力连锁五个战斗角色，武器总数达到 40。
- 新增 Tracking Vane、Longview Array、Forked Bus、Conduction Mesh、Stormglass Filament 五件原创遗物，分别增强追踪转速、追踪半径、连锁目标数、连锁半径和连锁伤害，遗物总数达到 45。
- 新条目已接入 RewardChest、ShopInventory、五类遗物掉落表、Premium Chest 和 Boss Reward Chest；Outpost Hall 显示 Homing/Chain 具体参数，并支持 `homing` / `chain` Build 路线筛选。
- 十个新条目都有专属 64px SVG 和 `ContentIconDefinitionData`，内容图标注册表定义数量从 112 提升到 122；`ContentPipelineSmokeTest` 把内容下限锁定为 40 武器 / 45 遗物。
- `WeaponSmokeTest` 覆盖追踪转向方向、角速度上限、连锁选敌、跳数、半径和伤害缩放；`RelicSmokeTest` 覆盖五类新遗物的拾取应用、支持武器增强和普通武器能力门控。

## 第二百五十一批已落地靠拢改动

### 三层 Boss Signature Attack 专属机制第一版

- `BossEnemy` 在原有环形弹幕、瞄准齐射和召唤之外加入第四招 Signature Attack，并公开机制名称、前摇、半径、射弹数、防御状态和使用次数摘要。
- Outer Warrens 的 Warrens Gatekeeper 使用 `Pincer Gates`：在玩家两侧生成两条收束射线预警，前摇结束后由两侧向目标位置发射夹击弹幕。
- Iron Catacombs 的 Iron Bulwark 使用 `Bastion Lock`：进入可见蓝色防御窗口，承受伤害按场景倍率降低，随后释放环形封锁弹幕。
- Void Foundry 的 Void Foundry Heart 使用 `Void Bloom`：在玩家当前位置生成紫色圆形预警，留在中心会受伤，随后从标记点向外爆发环形弹幕；召唤物由通用 Chaser 改为本层 Null Acolyte。
- Boss 死亡来源摘要新增 Signature 名称、机制专属复盘提示和反制 Build 标签；HUD Boss 标题直接显示 `Boss Name | Signature Name`，让机制在战斗开始后即可识别。
- 新增 `BossSignatureSmokeTest`，直接验证双侧线形预警、夹击弹量、Bastion 减伤、Void Bloom 目标点伤害和环形爆发；`ContentPipelineSmokeTest` 锁定三层 Boss 与三个唯一机制的配置关系。
- 本批通过 `BossSignatureSmokeTest`、`BossSmokeTest`、`ContentPipelineSmokeTest`、`DungeonGenerationSmokeTest`、`EnemyVarietySmokeTest` 和完整 `FullRunSmokeTest`。

## 第二百五十二批已落地靠拢改动

### 三层 Biome 像素地板纹理与 TerrainLayer 第一版

- 使用内置 ImageGen 生成三张原创俯视角像素地板：Outer Warrens 的苔痕石板与铜钉、Iron Catacombs 的铆接钢板与热栅、Void Foundry 的紫黑铸板与青色裂隙；均缩放为 512×512 PNG 并保存到 `art/terrain`。
- `BiomeData` 新增地板纹理路径、调制色和透明度字段；三个 Biome 资源分别配置独立纹理，不再只依赖纯色 floor tint。
- 新增 `BiomeTerrainLayer`，使用最近邻过滤和重复铺设把纹理覆盖到 1280×720 房间地板；原 Floor Polygon 保留为底色，墙体、障碍和所有碰撞节点不变。
- `DungeonController` 将纹理字段写入房间定义、运行时房间和 Biome 摘要；`CombatRoom.get_biome_visual_summary()` 暴露纹理路径、加载状态、尺寸、透明度、重复和过滤状态。
- 三张入库图已逐张视觉检查，并通过尺寸、非空、平均色差和 Godot 导入验证；Void Foundry 保持最暗，避免青色裂隙压过弹幕与危险预警。
- `ContentPipelineSmokeTest` 锁定三张唯一 512px PNG；`DungeonGenerationSmokeTest` 验证每个生成房间加载正确纹理并启用重复/最近邻；`RoomFlowSmokeTest` 同步采用 FullRun 已使用的动态召唤物清理循环，修复 Room13 分裂体导致的夹具漂移。

## 第二百五十三批已落地靠拢改动

### 三层墙体/障碍 Surface Atlas 与分区铺设第一版

- 新增三套原创 `512×256` SVG Surface Atlas：左侧 `256×256` 固定为墙体区，右侧 `256×256` 固定为障碍区；Outer Warrens 使用苔痕石墙与铜芯石柱，Iron Catacombs 使用铆接钢板与热栅掩体，Void Foundry 使用紫黑铸板与青色回路核心。
- 新增 `BiomeSurfaceVisual`，对任意矩形墙体或动态布局障碍执行最近邻、逐块区域采样；不依赖整张 Atlas 回绕，避免墙体采到障碍区或障碍采到墙体区。
- `BiomeData` 新增 Surface Atlas 路径、墙体/障碍调制色和透明度；`DungeonController` 将五项字段接入房间记录、Biome 摘要和运行时实例。
- `CombatRoom` 为六段固定墙体和每个 `LayoutObstacles` 动态障碍创建独立视觉子节点；原 Polygon 继续作为底色与资源缺失时的降级表现，碰撞形状、碰撞层和房间布局不变。
- 三套 Atlas 已通过 Godot `--import` 导入，并逐张渲染检查分区、颜色、像素边缘和重复节奏；源文件无文字、角色或第三方视觉元素。
- `ContentPipelineSmokeTest` 锁定三套唯一 Atlas、`512×256` 尺寸和可见透明度；`DungeonGenerationSmokeTest` 验证墙体使用左区、障碍使用右区、手动区域铺设和最近邻过滤；完整 `RoomFlowSmokeTest` 再次通过。

## 第二百五十四批已落地靠拢改动

### 普通敌人关键动作前摇与语义预警第一版

- `DangerWarning` 新增 `warning_purpose`，保持原调用兼容，同时可区分 `projectile`、`charge`、`zone`、`self_destruct`、`elite_death`、`summon`、`support` 和 `shield_bash`；后续音效、色弱方案和死亡复盘可直接按用途路由。
- `Enemy` 新增通用 Utility Windup 状态机和 `get_attack_telegraph_summary()`；前摇期间敌人停止位移，动作结束后才执行实际效果。
- Summoner 与 Rift Caller 会先冻结每个安全出生点并显示紫色召唤圈，前摇结束后才在同一位置生成单位；召唤上限和玩家安全距离保持不变。
- Grave Mender 只在范围内存在受伤友军时启动绿色治疗范围脉冲，前摇结束前不恢复生命，避免治疗在视觉提示前瞬时发生。
- Shielded 与 Aegis Drone 新增蓝色短线盾击前摇、短冲窗口和恢复窗口；盾击复用现有玩家触碰伤害路径，不让预警自身重复结算伤害。
- `EnemyVarietySmokeTest` 验证七种普通敌人预警用途、召唤点冻结、治疗延迟、盾击位移与实际接触伤害；`BossSignatureSmokeTest`、`CombatFeedbackSmokeTest`、`ContentPipelineSmokeTest` 和完整 `RoomFlowSmokeTest` 保持通过。

## 第二百五十五批已落地靠拢改动

### 敌人动作形状提示与独立起手音第一版

- 新增无文字 `EnemyActionCue`：召唤以三枚菱形表示“数量增加”，治疗以十字表示“恢复”，盾击以随朝向旋转的双箭头表示“前向突进”；即使不看紫、绿、蓝三种颜色，也能从轮廓区分动作。
- `Events` 新增兼容式 `enemy_action_windup_started` 事件，和原有 `danger_warning_started` 分别表达“敌人在做什么”与“哪个空间即将危险”。
- 三类 Utility Windup 统一生成头顶提示并发送动作事件，提示随敌人位置更新、按前摇进度脉冲淡出，并在动作完成或来源失效时自动清理。
- `AudioFeedback` 为召唤、治疗、盾击加入三套独立起手音色与通用降级路由；动作音与范围警告音各自限流，不修改现有 Boss、陷阱和弹幕警告音接口。
- `AudioFeedbackSmokeTest` 锁定三类 SFX 路由，`EnemyVarietySmokeTest` 锁定 `diamonds`、`cross`、`chevrons` 三种形状语义；Godot 脚本导入及两组定向烟测均通过。

## 第二百五十六批已落地靠拢改动

### 敌人关键动作四帧像素 Atlas 第一版

- 新增召唤者、治疗者、盾卫三套原创 `128×128 / 2×2` 像素 Atlas，每套固定表达待机、蓄势、动作峰值和恢复四个阶段；素材无文字、水印或第三方角色元素。
- Summoner / Rift Caller、Grave Mender、Shielded / Aegis Drone 五个场景从纯 Polygon 主视觉切换为最近邻 `ActionSprite`，原节点只保留为资源缺失时的降级路径。
- `Enemy` 将 Utility Windup 进度映射到蓄势和峰值帧，动作完成后进入恢复帧；盾击冲刺期间保持峰值帧，盾击恢复窗口使用恢复帧。
- 动作 Sprite 接入不修改碰撞体、攻击判定、召唤出生点、治疗目标选择或盾击接触伤害；场景变体调色在受击闪烁后会恢复原值。
- 新增 `EnemyActionAnimationSmokeTest` 锁定 Atlas、五场景和四帧循环契约；内容管线和敌人综合烟测同时验证资源配置与真实 AI 前摇切帧。
- 内置 ImageGen 在本批连续超时，未切换需 API Key 的 CLI；最终采用确定性原创 SVG 像素源并通过 Godot 导入与 Edge Headless 预览检查，后续透明 PNG 可按同规格直接替换。

## 第二百五十七批已落地靠拢改动

### 四类普通敌人 ImageGen 透明 PNG 动作 Atlas 第一版

- 使用内置 ImageGen 生成机械射手、楔角冲锋构造体、高压爆破容器和地形导管四套原创 `2×2` 像素动作 Atlas，分别表达待机、蓄势、动作峰值和恢复。
- 通过官方色键辅助脚本完成绿幕/品红幕透明化，四张 `1254×1254 RGBA` PNG 均通过透明角、主体覆盖和逐张视觉检查；项目中不保留绿幕源图引用。
- Shooter、Ember Marksman、Barrage Totem、Needle Skater、Charger、Iron Breaker、Bomber、Volatile Vessel、Mire Conduit、Null Acolyte 十个场景切换到最近邻 PNG ActionSprite，缩放后单帧约 62.7px。
- `Enemy` 动画驱动扩展到 Projectile Windup、Charge 三阶段、Self Destruct 倒计时和 Zone 视觉施法计时；现有攻击判定、伤害、危险区和 AI 移动规则不变。
- 全部 15 个非追击型普通敌人现在具备 `2×2` 动作 Atlas；`EnemyActionAnimationSmokeTest`、`ContentPipelineSmokeTest` 和真实 AI `EnemyVarietySmokeTest` 同时锁定资源、世界尺寸和切帧行为。

## 第二百五十八批已落地靠拢改动

### Chaser 移动步态与三层 Boss 阶段/招牌技动画第一版
- 使用内置 ImageGen 生成四套原创 `1254×1254 / 2×2` 透明 PNG Atlas：Chaser 使用待机、左步、右步、接触突刺；三个 Boss 使用一阶段待机、普通蓄力、招牌技/转阶段峰值、二阶段狂暴。
- 四张源图通过官方色键辅助脚本执行 Border 自动取色、Soft Matte 与 Despill；透明角点、主体覆盖率和逐张视觉检查均通过，未使用外部 API Key 或 CLI 降级路径。
- Chaser / Rust Skirmisher / Soot Splitter 接入约 62.7px 最近邻帧，并按移动速度循环步态、按 48px 接触距离切换突刺；普通敌人动作 Atlas 覆盖由 15 个非追击场景扩展到全部 18 个场景。
- Warrens Gatekeeper、Iron Bulwark、Void Foundry Heart 分别接入约 125.4px 的独立最近邻 Atlas；普通攻击、招牌技、阶段转换、二阶段稳定态已绑定明确帧语义，Polygon 仅作为资源缺失降级路径。
- 新增 `BossActionAnimationSmokeTest`，并扩展 `EnemyActionAnimationSmokeTest`、`ContentPipelineSmokeTest`、`BossSignatureSmokeTest`、`BossSmokeTest`；完整 Boss 房、敌人多样性和战斗反馈回归保持通过。

## 第二百五十九批已落地靠拢改动

### 三层 Boss 二阶段第二专属机制第一版
- Warrens Gatekeeper 新增三条平行通道扫射 `Warren Sweep`；Iron Bulwark 新增带半角延迟回声的双波 `Iron Quake`；Void Foundry Heart 新增四向向心交叉弹幕 `Rift Cross`。
- 一阶段继续执行径向、瞄准、召唤、原招牌技四槽循环；二阶段扩展为五槽，第五槽稳定路由到对应第二专属机制，不以单纯数值增强代替玩法差异。
- 三套机制具备独立前摇配置、语义化危险预警、Boss 来源缓存、使用次数摘要和死亡复盘字段，并复用现有 Boss 峰值动画帧。
- Boss HUD 一阶段显示原招牌技，进入二阶段后切换为第二专属机制名称；阶段提示同时暴露新机制，玩家无需死亡后才知道规则变化。
- 新增 `BossPhaseTwoAttackSmokeTest`，并扩展 `ContentPipelineSmokeTest` 与 `BossSmokeTest`；原招牌技、Boss 动画、完整 Boss 房和 UI 布局回归保持通过。

## 第二百六十批已落地靠拢改动

### 炮台/高速敌人独立 Atlas 与六类精英动态标识第一版
- 使用内置 ImageGen 生成并透明化 Barrage Totem、Needle Skater 两套原创 `2×2` PNG Atlas；前者以固定五炮口轮廓表达弹幕源，后者以银钢针形机体和青色翼片表达高速侧移职责。
- 两个场景不再复用机械射手图集，继续遵循约 62.7px、最近邻、四帧动作契约；定向测试锁定独立资源路径和完整切帧循环。
- 六种精英修饰新增数据驱动动态标识：火舌、护盾、速度尾迹、爆破节点、准星、重型环；图形可叠加到全部普通敌人并位于主体后方，不依赖文字或单纯色相区分。
- 新增 `EliteVisualSmokeTest`，并扩展动作动画、内容管线和真实敌人多样性测试；精英数值与死亡爆炸规则保持通过。
- 同步修复 `CombatFeedbackSmokeTest` 两个历史时序抖动点，改用真实清理条件和按 SFX id 计数；战斗反馈测试连续两次通过，音频专项回归通过。

## 第二百六十一批已落地靠拢改动

### 六类精英机制差异第一版
- 六种精英修饰在既有动态标识和数值修饰之外，新增唯一数据驱动战斗特性：`Scorch Pulse`、`Guarded Core`、`Overclock`、`Volatile Core`、`Focused Fire` 与 `Unstoppable`。
- Blazing 周期性释放带预警的范围灼烧；Bulwark 降低实际承伤；Quickened 周期性进入可读的加速攻击窗口；Volatile 在半血时进入一次性失稳状态。
- Sharpshot 在基础攻击上追加两条弹道；Titan 获得更强击退抗性和接触压迫，六类精英不再只靠颜色、缩放和生命倍率区分。
- 新增 `EliteTraitSmokeTest`，并稳定敌人多样性测试中的显式动作状态推进；内容管线、精英视觉、敌人多样性和完整流程回归保持通过。

## 第二百六十二批已落地靠拢改动

### 原创 authored SFX 资产管线第一版
- 新增 54 个原创 `16-bit / 44.1 kHz` PCM WAV，覆盖七类武器、命中/受击、生命/护甲、危险预警、敌人前摇、规则触发、Boss 和结算反馈；所有文件均由仓库内固定种子生成器构建，不含第三方录音。
- 新增 `SfxLibrary`，集中维护正式事件和 40 把武器自定义音效键的样本映射；`AudioFeedback` 优先加载 authored stream，旧程序化音调只保留为可计数的未知键/缺失资源回退。
- 音频专项测试锁定 54/54 资源加载、全部当前武器键覆盖和正式事件零回退；内容管线对每个武器强制校验非空键、映射和可导入 WAV。
- 生成器可复现哈希和 WAV 格式、唯一性、静音、削波 QA 通过；headless 与 Windows 显示 + Dummy 音频驱动两条播放路径、武器、战斗反馈和内容管线回归保持通过。正式音乐仍是后续音频锁定项。

## 第二百六十三批已落地靠拢改动

### 原创 authored 音乐与三层 Biome 接线第一版
- 新增 Menu、三层 Biome、Boss、Victory、Defeat 共 7 条原创 `16-bit / 44.1 kHz stereo` WAV，由仓库内固定种子生成器构建，不含第三方音乐或其他游戏素材。
- 新增 `MusicLibrary` 并移除运行时音乐采样生成；两台 Music bus 播放器以 `0.45s` 交叉淡化切换，菜单/三层/Boss 循环，结算轨道单次播放。
- 激活 `BiomeData.music_key`：键值进入生成 metadata、Biome summary、房间记录和实例，普通房按当前层切换独立轨道，Boss 与结算继续覆盖专属音乐。
- 内容管线锁定三层 music key 唯一映射和资源存在；音频、地牢生成、设置持久化、Windows Dummy 播放路径和格式/循环边界 QA 全部通过。

## 后续建议顺序

1. 战斗外大厅：在 Outpost Hall、Data Shards、角色解锁、训练入口、训练靶场布局、训练 drill、训练目标类型、drill 完成目标、drill 评级、训练徽章记录、训练徽章 token、训练奖励 toast、熟练度加成、图鉴分页、全内容 SVG 图标、Featured Card、CodexDetailCard、Build 路线筛选和搜索/排序/稀有度筛选基础上继续补正式像素 Atlas、视觉进度条、多卡片详情布局、更完整训练奖励演出和更清晰的视觉层级。
2. 特殊房间：在已落地武器房、治疗补给房、事件房随机结果池、商人折扣、诅咒武器、短时过载规则、雕像选择、雕像调谐、挑战房变体和陷阱房基础上，继续补更多随机强化、更细挑战奖励差异和多机关组合。
3. 角色深度：在当前 6 角色、清房/击杀/受伤事件驱动祝福基础上继续让角色技能与遗物、Boss 后天赋、事件祝福和雕像系统产生更可读的组合变化。
4. 内容池深度：当前已达到 40 武器 / 45 遗物，并具备全条目 SVG 图标、Field/Mine/Sentry 部署、Homing/Chain 路线和七类 authored 武器音效；后续优先补掉落权重实机调优、更多部署行为、武器专属命中反馈和特殊交互。
5. Biome 差异化：在当前三层独立像素地板、三套墙体/障碍 Surface Atlas、三条独立 authored 音乐、3 个 Boss Signature Attack、3 个二阶段第二专属机制、18 个普通敌人四帧 Atlas、Barrage Totem/Needle Skater 独立 Atlas、3 套 Boss 阶段/招牌技 Atlas、6 套精英动态标识与独立战斗特性、独立布局池、奖励权重接线和小地图分层显示基础上，继续补门/边角装饰 Atlas、更细的精英组合变化和奖励曲线。
6. 手感打磨：在已有辅助瞄准锁定权重、低血量反馈、屏幕震动、伤害闪屏、武器槽反馈、语义化敌人前摇、54 个 authored SFX 和 7 条 authored 音乐基础上，继续优化弹幕密度、受击反馈、击退、危险区纹样、统一像素密度、独立敌人轮廓、音频优先级和最终混音。

## 验收方向

- 玩家能在 HUD 中同时看到 HP、Armor、Energy、Ammo。
- Armor 能挡伤害并在安全间隔后恢复。
- 高价值武器会明显消耗 Energy，能量不足时不能开火。
- 基础手枪保持稳定可用，避免玩家因能量耗尽完全失去攻击能力。
- 房间清理、奖励、商店和 Boss 推进不因资源循环改动而退化。
- 主菜单能切换 6 个角色，切换后 HP、Armor、Energy、移动速度和技能状态同步刷新。
- 进入 run 后角色锁定，主动技能可用且冷却、持续和能量变化能在 HUD 中观察。
- 宝箱/商店能提供不同形态武器，至少包含近战、环形弹幕、爆炸和贯穿类型。

extends Node

const LOCALE := "zh_CN"

const SHORT_EMBEDDED_MESSAGES := {
	"Off": "关闭",
	"All": "全部",
	"Mid": "中距离",
	"Band": "档位",
	"energy": "能量",
}

const WORD_MESSAGES := {
	"unvisited": "未访问", "visited": "已访问", "tags": "标签", "tag": "标签",
	"drop": "掉落权重", "duration": "持续时间", "effect": "效果", "value": "数值",
	"conflicts": "冲突", "charge": "蓄力", "chain": "连锁", "max": "上限",
	"fire": "射击", "challenge": "挑战", "homing": "追踪", "crit": "暴击",
	"bounce": "反弹", "stacking": "叠加", "pierce": "穿透", "layout": "布局",
	"state": "状态", "doors": "门", "explosion": "爆炸", "stats": "属性",
	"stackable": "可叠加", "unique": "唯一", "deploy": "部署", "traits": "特性",
	"mode": "模式", "mag": "弹匣", "projectile": "弹丸", "projectiles": "弹丸",
	"east": "东", "west": "西", "south": "南", "north": "北", "main": "主线",
	"branch": "支线", "role": "定位", "event": "事件", "bonus": "加成",
	"run": "冒险", "boss": "首领", "multiplier": "倍率", "range": "距离",
	"reward": "奖励", "rewards": "奖励", "combat": "战斗", "long": "远距离",
	"control": "控制", "slow": "减速", "healing": "治疗", "elite": "精英",
	"counter": "反击", "rate": "速率", "burst": "爆发", "crowd": "群体",
	"kill": "击杀", "kills": "击杀", "radial": "环形", "spread": "散射",
	"burn": "灼烧", "scope": "作用域", "rule": "规则", "elemental": "元素",
	"health": "生命", "trap": "陷阱", "laser": "激光", "core": "核心",
	"tempo": "节奏", "tick": "跳", "line": "直线", "heal": "治疗",
	"hurt": "受伤", "speed": "速度", "deg": "度", "cooldown": "冷却",
	"upgrade": "升级", "biome": "地区", "biomes": "地区", "remaining": "剩余",
	"multi": "多重", "shot": "射击", "shots": "弹丸", "precise": "精准",
	"skill": "技能", "wide": "宽幅", "count": "数量", "detail": "详情",
	"shield": "护甲", "name": "名称", "search": "搜索", "refine": "筛选",
	"filter": "筛选", "sort": "排序", "field": "区域", "mine": "地雷",
	"sentry": "哨戒", "launcher": "发射器", "area": "范围", "summon": "召唤",
	"momentum": "动量", "synergy": "联动", "sustain": "续航", "death": "死亡",
	"defeat": "失败", "defeats": "失败", "sources": "来源", "source": "来源",
	"type": "类型", "progress": "进度", "defensive": "防御", "defense": "防御",
	"magic": "魔法", "free": "免费", "damage": "伤害", "chance": "概率",
	"targets": "目标", "target": "目标", "radius": "半径", "block": "格挡",
	"recover": "恢复", "restore": "恢复", "gain": "获得", "temporary": "临时",
	"used": "使用", "using": "使用", "triggered": "触发", "available": "可用",
	"roster": "角色名单", "now": "当前", "time": "时间", "grid": "网格",
	"standard": "标准", "flexible": "灵活", "mobility": "机动", "fragile": "脆弱",
	"ranged": "远程", "close": "近距离", "open": "开放", "start": "开始",
	"room": "房间", "rooms": "房间", "shop": "商店", "shrine": "神龛",
	"hazard": "危险", "blocks": "障碍", "armory": "武器库", "cache": "补给",
	"lane": "通道", "layouts": "布局", "box": "箱体", "maze": "迷宫",
	"narrow": "狭窄", "gap": "缺口", "corner": "角落", "corners": "角落",
	"arena": "竞技场", "ambush": "伏击", "nests": "巢穴", "crescent": "新月",
	"bunker": "掩体堡", "split": "分隔", "cover": "掩体", "center": "中央",
	"crossfire": "交叉火力", "ring": "环场", "diagonal": "对角", "gauntlet": "挑战长廊",
	"twin": "双子", "islands": "岛", "spike": "尖刺", "rush": "突袭",
	"both": "两者", "show": "显示", "picks": "选择", "pick": "选择",
	"training": "训练", "badge": "徽章", "badges": "徽章", "characters": "角色",
	"weapons": "武器", "relics": "遗物", "talents": "天赋", "blessings": "祝福",
	"statues": "雕像", "objectives": "目标", "train": "训练", "lifetime": "累计",
	"earned": "获得", "status": "状态", "none": "无", "all": "全部",
	"mastery": "熟练度", "slots": "槽位", "starting": "初始", "piercing": "穿透",
	"cross": "十字", "routes": "路线", "arc": "弧度", "spd": "速度", "dmg": "伤害",
	"every": "每", "types": "类型", "unlockable": "可解锁", "knockback": "击退",
	"statue": "雕像", "enemy": "敌人", "unlock": "解锁", "last": "最近",
	"debug": "调试", "boost": "增益", "assist": "辅助", "try": "尝试",
	"movement": "移动", "mobile": "移动", "size": "容量", "selected": "已选择",
	"turn": "转向", "major": "高级", "bless": "祝福", "skirmisher": "游击",
	"extra": "额外", "for": "用于", "with": "使用", "on": "触发于", "to": "至", "at": "于", "of": "的",
}

const MESSAGES := {
	# Common interface text.
	"Dungeon Unleashed": "地牢觉醒",
	"Prototype Run": "原型冒险",
	"Outpost Hall": "前哨大厅",
	"Character": "角色",
	"Previous": "上一个",
	"Next": "下一个",
	"Unlocked": "已解锁",
	"Selected: Ready": "已选择：就绪",
	"Start Run": "开始冒险",
	"Training": "训练场",
	"Settings": "设置",
	"All": "全部",
	"Records": "记录",
	"Chars": "角色",
	"Weapons": "武器",
	"Relics": "遗物",
	"Talents": "天赋",
	"Blessings": "祝福",
	"Statues": "雕像",
	"Reset": "重置",
	"Featured Card": "精选条目",
	"Rarity": "稀有度",
	"Core details": "核心详情",
	"Route": "路线",
	"Pick": "选择",
	"Next Pick": "下个选择",
	"Type": "类型",
	"Meta Progress": "局外进度",
	"Back": "返回",
	"Open": "打开",
	"Review": "查看",
	"Build": "构筑",
	"Progress": "进度",
	"Search codex": "搜索图鉴",
	"All Records": "全部记录",
	"COMMON": "普通",
	"HP": "生命",
	"Armor": "护甲",
	"Energy": "能量",
	"Skill": "技能",
	"Passive": "被动",
	"Rule": "规则",
	"Weapon": "武器",
	"Ammo": "弹药",
	"Gold": "金币",
	"Enemies": "敌人",
	"Room": "房间",
	"Map": "地图",
	"Current": "当前",
	"Seed": "种子",
	"Choose a Relic": "选择一件遗物",
	"Room Cleared": "房间已清理",
	"DEFEATED": "冒险失败",
	"RUN COMPLETE": "冒险完成",
	"Dungeon Seed": "地牢种子",
	"0 = Random": "0 = 随机",
	"Apply Seed": "应用种子",
	"Random": "随机",
	"Paused": "已暂停",
	"Resume": "继续",
	"Restart": "重新开始",
	"Main Menu": "主菜单",
	"Master": "主音量",
	"Music": "音乐",
	"Resolution": "分辨率",
	"Fullscreen": "全屏",
	"Apply": "应用",
	"Run Complete": "冒险完成",
	"Replay Seed": "重玩此种子",
	"Debug Map": "调试地图",
	"No dungeon debug map available.": "暂无地牢调试地图。",
	"Copy Map": "复制地图",
	"Close": "关闭",
	"Relic": "遗物",
	"Choose Relic": "选择遗物",
	"Resolved": "已完成",
	"Opened": "已开启",
	"SOLD OUT": "已售罄",
	"Shop": "商店",
	"Shop Item": "商店商品",
	"Training Dummy": "训练假人",
	"Weapon Chest": "武器宝箱",
	"Premium Chest": "高级宝箱",
	"Normal Chest": "普通宝箱",
	"Chest": "宝箱",
	"Healing Cache": "治疗补给箱",
	"Boss Chest": "首领宝箱",
	"Reward Room": "奖励房",
	"WASD Move | Mouse Aim | LMB Shoot | R Reload | 1/2/3 Weapons | E Interact | Esc Pause": "WASD 移动 | 鼠标瞄准 | 左键射击 | R 换弹 | 1/2/3 切换武器 | E 互动 | Esc 暂停",

	# Characters and skills.
	"Wanderer": "流浪者", "Phase Dash": "相位冲刺",
	"Warden": "守卫", "Guard Pulse": "守护脉冲",
	"Arcanist": "秘术师", "Energy Surge": "能量涌动",
	"Rift Runner": "裂隙行者", "Rift Step": "裂隙步",
	"Field Medic": "战地医师", "Stabilize": "紧急稳固",
	"Emberwright": "烬火工匠", "Overdrive Spark": "过载火花",
	"Balanced shooter with stable health, armor, and energy.": "生命、护甲与能量均衡的射手。",
	"Balanced stats make every weapon class viable during a run.": "均衡属性让各类武器都能稳定发挥。",
	"Default all-rounder for learning room flow, weapons, and relic builds.": "适合熟悉房间节奏、武器和遗物构筑的全能角色。",
	"Brief speed burst with short invulnerability.": "短暂高速冲刺，并在期间免疫伤害。",
	"Heavy frontline fighter with high armor and lower energy.": "高护甲、低能量的重装前排战士。",
	"High armor supports close-range weapons, but lower energy limits spam.": "高护甲适合近战，较低能量限制连续射击。",
	"Durable defender for players who prefer close fights and recovery windows.": "适合近身作战并把握恢复时机的坚韧防御者。",
	"Restores armor and grants a brief damage buffer.": "恢复护甲，并短暂降低所受伤害。",
	"Fragile energy specialist that spikes weapon tempo.": "身板脆弱、擅长爆发武器节奏的能量专家。",
	"Higher energy pool supports costly weapons, but lower armor punishes mistakes.": "高能量上限支持高耗能武器，但低护甲容错较低。",
	"High-energy caster for players who manage burst windows and distance.": "适合控制爆发窗口与作战距离的高能量施法者。",
	"Restores energy and briefly increases fire rate.": "恢复能量，并短暂提高射速。",
	"Fast skirmisher with low armor and high repositioning uptime.": "低护甲、高机动的快速游击者。",
	"High speed rewards short trades, but low armor makes mistakes costly.": "高速移动利于短促交锋，但低护甲会放大失误。",
	"Unlockable mobility specialist for players who weave through projectile pressure.": "可解锁的机动专家，适合穿梭于密集弹幕。",
	"Sharp evasive burst with brief invulnerability.": "迅捷闪避冲刺，并短暂无敌。",
	"Support-oriented survivor with steady recovery and lower burst damage.": "恢复稳定、爆发较低的辅助型生存者。",
	"Recovery tools make long routes safer, but damage output is modest.": "恢复手段让长路线更安全，但伤害输出较低。",
	"Unlockable sustain specialist for players who value recovery and route consistency.": "可解锁的续航专家，适合重视恢复和稳定推进的玩家。",
	"Restores health and armor during a short recovery window.": "在短暂恢复窗口内回复生命与护甲。",
	"Volatile damage specialist that rewards clean burst windows.": "善于把握爆发窗口的高风险伤害专家。",
	"Strong burst windows pair well with explosive and precision weapons.": "强力爆发适合搭配爆炸与精准武器。",
	"Unlockable burst specialist for players who want short high-damage windows.": "可解锁的爆发专家，擅长在短时间造成高额伤害。",
	"Briefly increases weapon damage and fire rate.": "短暂提高武器伤害与射速。",

	# Weapons.
	"Arc Blade": "电弧刃", "Basic Pistol": "基础手枪", "Bastion Saw": "堡垒锯刃",
	"Blast Launcher": "爆破发射器", "Bulwark Fan": "壁垒战扇", "Cinder Mortar": "烬火迫击炮",
	"Coil Bow": "线圈弓", "Coil Carbine": "线圈卡宾枪", "Compass Needle": "罗盘针",
	"Ember Mine": "余烬地雷", "Ember Sprayer": "余烬喷射器", "Energy Staff": "能量法杖",
	"Frost Sickle": "寒霜镰", "Furnace Scattergun": "熔炉霰弹枪", "Guard Cleaver": "守御斩刀",
	"Halo Kernel": "光环核心", "Lantern Swarm": "灯火群", "Laser Lance": "激光长枪",
	"Mirror Sickle": "镜影镰", "Nova Core": "新星核心", "Orbit Sower": "轨道播种器",
	"Prism Ray": "棱镜射线", "Pulse Needler": "脉冲针枪", "Quench Repeater": "淬火连发枪",
	"Relay Arc": "接力电弧", "Ricochet Blaster": "跳弹爆能枪", "Rift Bloom": "裂隙绽放",
	"Rift Spear": "裂隙长矛", "Riposte Saber": "还击军刀", "Sentry Seed": "哨戒种子",
	"Shatter Fan": "碎裂扇", "Shotgun": "霰弹枪", "Slag Comet": "熔渣彗星",
	"Snare Beacon": "诱捕信标", "Storm Capacitor": "风暴电容", "Storm Fan": "风暴战扇",
	"Stormglass Rail": "风暴晶轨炮", "Thunder Nest": "雷霆巢", "Undertow Volley": "暗流齐射",
	"Vault Lance": "穹顶长枪",

	# Relics.
	"Adrenaline Charm": "肾上腺护符", "Anchor Spool": "锚定线轴", "Blast Radius Gauge": "爆炸半径计",
	"Breach Powder": "破甲火药", "Breakwater Guard": "防波护盾", "Bulwark Plate": "壁垒甲板",
	"Conduction Mesh": "导电网", "Counterweight Core": "配重核心", "Draw Weight": "强弓配重",
	"Echo Chamber": "回声膛室", "Ember Catalyst": "余烬催化剂", "Field Rations": "战地口粮",
	"Flux Reservoir": "通量储罐", "Forked Bus": "分叉母线", "Gilded Tip": "镀金弹头",
	"Guardian Ward": "守护结界", "Heart Core": "生命核心", "Hollow Needle": "空心针",
	"Keen Sights": "锐利瞄具", "Kinetic Bridle": "动能缰绳", "Kinetic Ram": "动能撞锤",
	"Lingering Ash": "不灭余烬", "Longview Array": "远视阵列", "Lucky Primer": "幸运底火",
	"Momentum Coil": "动量线圈", "Parry Grip": "格挡握柄", "Phase Tip": "相位弹头",
	"Quick Trigger": "速射扳机", "Quick Windup": "快速蓄能", "Redline Boots": "红线战靴",
	"Reserve Drum": "备用弹鼓", "Ricochet Gyro": "跳弹陀螺", "Scatter Lens": "散射透镜",
	"Sharp Rounds": "锐化弹药", "Siphon Clasp": "虹吸扣", "Split Chamber": "分裂膛室",
	"Steady Capacitor": "稳流电容", "Stored Spark": "储能火花", "Stormglass Filament": "风暴晶丝",
	"Swift Loader": "快速装填器", "Tracking Vane": "追踪尾翼", "Tripwire Amplifier": "绊线放大器",
	"Vampire Fang": "吸血獠牙", "Volatile Oil": "挥发油", "Warding Hinge": "守御铰链",

	# Talents, blessings, statues, biomes and modifiers.
	"Iron Vow": "钢铁誓言", "Kinetic Rounds": "动能弹药", "Steady Hands": "稳健双手",
	"Afterglow Circuit": "余辉回路", "Brace Current": "固守电流", "Deep Cell": "深层电池",
	"Ember Tithe": "余烬献礼", "Quiet Plate": "静默甲片", "Resonance Battery": "共鸣电池",
	"Spark Dividend": "火花红利", "Bulwark Idol": "壁垒神像", "Cinder Focus": "烬火焦点",
	"Echo Reservoir": "回声储池", "Outer Warrens": "外围地窟", "Iron Catacombs": "钢铁墓穴",
	"Void Foundry": "虚空铸造厂", "Blazing": "炽燃", "Bulwark": "壁垒",
	"Quickened": "迅捷", "Sharpshot": "神射", "Titan": "泰坦", "Volatile": "易爆",

	# Enemies, bosses and events.
	"Aegis Drone": "护盾无人机", "Barrage Totem": "弹幕图腾", "Bomber": "爆破兵",
	"Charger": "冲锋者", "Chaser": "追猎者", "Ember Marksman": "余烬射手",
	"Grave Mender": "墓穴修复者", "Iron Breaker": "钢铁破阵者", "Iron Bulwark": "钢铁壁垒",
	"Mire Conduit": "泥沼导体", "Needle Skater": "针刺滑行者", "Null Acolyte": "虚无侍从",
	"Rift Caller": "裂隙召唤者", "Rust Skirmisher": "锈蚀游击兵", "Shielded": "持盾者",
	"Shooter": "射手", "Soot Splitter": "烟尘分裂者", "Summoner": "召唤师",
	"Void Foundry Heart": "虚空铸造核心", "Volatile Vessel": "易爆容器",
	"Warrens Gatekeeper": "地窟守门者", "Dungeon Core": "地牢核心",
	"Blood Pact": "鲜血契约", "Merchant Oath": "商人誓约", "Cursed Armory": "诅咒武库",
	"Overclock Trial": "超频试炼", "Resonant Statue": "共鸣雕像", "Resonance Tuning": "共鸣调谐",

	# Room layouts and run routes.
	"Ambush Corners": "角落伏击", "Boss Arena": "首领竞技场", "Boss Cross": "首领十字场",
	"Box Maze": "箱体迷宫", "Bunker": "掩体堡", "Center Ring": "中央环场",
	"Corner Nests": "角落巢穴", "Crescent": "新月场", "Crossfire": "交叉火力",
	"Diagonal Blocks": "对角障碍", "Gauntlet": "挑战长廊", "Long Lane": "狭长通道",
	"Market": "集市", "Narrow Gap": "狭窄缺口", "Open Cross": "开放十字场",
	"Four Pillars": "四柱场", "Reward Cache": "奖励仓", "Shrine": "神龛",
	"Split Cover": "分隔掩体", "Training Yard": "训练庭院", "Twin Islands": "双子岛",
	"Wide Arena": "宽阔竞技场", "Standard Three-Biome Run": "标准三地区冒险",

	# Reusable dynamic interface vocabulary.
	"Data Shards": "数据碎片", "Runs": "冒险次数", "Wins": "胜利次数", "Locked": "未解锁",
	"Unlock": "解锁", "Ready": "就绪", "Active": "生效中", "Reloading": "换弹中", "Empty": "弹匣为空",
	"Guard": "格挡", "None": "无", "Unknown": "未知", "Fixed": "固定", "Rating": "评级",
	"Best": "最佳", "Targets": "目标", "Hits": "命中", "Damage": "伤害", "Goal": "目标",
	"Badge": "徽章", "Practice": "练习", "Basics": "基础训练", "Controls": "操作设置",
	"Controller": "手柄", "Aim Assist": "辅助瞄准", "Screen Shake": "屏幕震动",
	"Damage Flash": "受伤闪光", "Combat Text": "战斗文字", "Right Stick Deadzone": "右摇杆死区",
	"Gamepad Hint Switch": "手柄提示切换阈值", "Details": "详情", "Compact": "精简",
	"Run Failed": "冒险失败", "Choose a Talent": "选择一项天赋", "Choose a Blessing": "选择一项祝福",
	"Choose a Statue": "选择一座雕像", "Press E": "按 E 互动", "Gold (was": "金币（原价",
	"Common": "普通", "Uncommon": "优秀", "Rare": "稀有", "Epic": "史诗", "Legendary": "传说",
	"Sidearm": "副武器", "Staff": "法杖", "Melee": "近战",
	"Explosive": "爆炸", "Precision": "精准", "Deployable": "部署装置", "Mid": "中距离",
	"Far": "远距离", "Layer": "层级", "Off": "关闭", "On": "开启",
	"Last rule trigger": "最近一次规则触发", "Starter": "初始", "Mid range": "中距离",
	"Close range": "近距离", "关闭 range": "近距离", "range": "距离", "Slot": "栏位",
	"Magazine": "弹匣", "Free to fire": "可直接射击", "Need": "需要", "No weapon": "无武器",
	"No energy check": "无需检查能量", "Energy ready": "能量充足", "icon": "图标",
	"Basic P.": "基础手枪", "Energy St.": "能量法杖", "Unentered": "未进入",
	"Move": "移动", "Aim Mouse": "鼠标瞄准", "Shoot": "射击", "Reload": "换弹",
	"Interact": "互动", "Pause": "暂停", "Debug": "调试", "Space": "空格",
	"Outpost / Records": "前哨大厅 / 记录", "Training Room": "训练场",
	"Practice the selected character without recording a run": "使用所选角色练习，且不记录为正式冒险",
	"Overview": "总览", "Combat": "战斗", "Survival": "生存", "Loot": "战利品", "Record": "记录",
	"Result summary compatibility text": "冒险结果摘要",
	"Aim Assist Strength": "辅助瞄准强度", "Aim Assist Band": "辅助瞄准档位",
	"Light": "轻度", "Balanced": "均衡", "Strong": "强力", "Set Aim Assist to": "设置辅助瞄准为",
	"Weakly bends shots toward nearby enemies while aiming": "瞄准时让弹道轻微偏向附近敌人",
	"Scales floating damage, crit, healing, and armor text": "调整伤害、暴击、治疗和护甲浮动文字强度",
	"Filters small right-stick drift before it counts as aim input": "过滤右摇杆轻微漂移，超过阈值才视为瞄准输入",
	"Minimum stick movement needed before HUD switches to gamepad hints": "HUD 切换为手柄提示所需的最小摇杆幅度",
	"Scales the red screen flash when HP damage is taken": "调整生命受损时的红色屏幕闪光强度",
	"Low-Health Feedback": "低生命反馈",
	"Scales low-health edge pulse and heartbeat feedback": "调整低生命时的边缘脉冲与心跳反馈强度",
	"Scales camera shake from hits, crits, room clears, and bosses": "调整命中、暴击、清房和首领造成的镜头震动",
	"Move LS | Aim RS | Shoot RT/RB | Reload X | Skill A | Weapons D-Pad | Interact Y | Pause Start": "左摇杆移动 | 右摇杆瞄准 | RT/RB 射击 | X 换弹 | A 技能 | 十字键切换武器 | Y 互动 | Start 暂停",
	"Down": "下移", "Left": "左移", "Right": "右移",
	"Up": "上移", "Reset Controls": "重置按键",
	"Objectives": "目标", "Badges": "徽章", "badges": "徽章", "Characters": "角色",
	"Train": "训练", "Training Badges": "训练徽章", "Lifetime Earned": "累计获得",
	"Start a run and test a new build": "开始一次冒险并测试新构筑",
	"Fire Rate": "射速", "Multi Shot": "多重射击", "Low Health": "低生命",
	"Risk Reward": "风险收益", "Kill Chain": "连杀", "Line Clear": "直线清理",
	"Close Range": "近距离", "Long Range": "远距离", "Room Clear": "清理房间",
	"On Room Clear": "清理房间时", "On Kill": "击杀时", "On Hurt": "受伤时",
	"On Skill Used": "使用技能时", "Run rule": "冒险规则",
	"No Matching Entry": "没有匹配条目", "Adjust filters": "请调整筛选条件",
	"Run rule: restore 12 Energy whenever a room is cleared.": "冒险规则：每次清理房间时恢复 12 点能量。",
	"Run rule: gain 1 Armor after taking HP damage.": "冒险规则：生命受损后获得 1 点护甲。",
	"Run rule: +18 max Energy after accepting an event sacrifice.": "冒险规则：接受事件献祭后，能量上限提高 18。",
	"Run rule: +12% weapon damage after accepting an event sacrifice.": "冒险规则：接受事件献祭后，武器伤害提高 12%。",
	"Run rule: +1 max Armor after accepting an event sacrifice.": "冒险规则：接受事件献祭后，护甲上限提高 1。",
	"Run rule: restore 5 Energy whenever a statue effect triggers.": "冒险规则：每次触发雕像效果时恢复 5 点能量。",
	"Run rule: restore 6 Energy after every 3 enemy defeats.": "冒险规则：每击败 3 个敌人恢复 6 点能量。",
	"Run rule: gain 1 Armor whenever your character skill is used.": "冒险规则：每次使用角色技能时获得 1 点护甲。",
	"Run rule: using a character skill grants +14% weapon damage for 5 seconds.": "冒险规则：使用角色技能后武器伤害提高 14%，持续 5 秒。",
	"Run rule: every second character skill use restores 8 Energy.": "冒险规则：每使用 2 次角色技能恢复 8 点能量。",
	"Compare close, mid, and far target damage.": "比较近、中、远距离目标受到的伤害。",
	"Hit all targets": "命中全部目标", "Next Drill": "下个训练", "Clear": "完成",
	"Apply Aim Assist": "应用辅助瞄准", "in training": "到训练场",
	"No icon key": "暂无图标", "Objectives: Preparing": "目标：准备中",
	"Objective progress": "目标进度", "Objective progress value": "目标进度数值",
	"Open objective target": "打开目标条目", "Start": "开始",
	"Start a run with the selected character": "使用所选角色开始冒险",
	"Open Records Sources for the last defeat": "查看上次失败的来源记录",
	"Open counter build route": "打开克制构筑路线", "Open counter pick": "打开克制选择",
	"Cycle objective counter pick": "切换目标的克制选择", "Counter pick type legend": "克制选择类型图例",
	"Route: All": "路线：全部", "Rarity: All": "稀有度：全部", "Sort: Name": "排序：名称",
	"HP: %d / %d": "生命：%d / %d", "Armor: %d / %d": "护甲：%d / %d", "Armor: %d": "护甲：%d",
	"Energy: %d / %d": "能量：%d / %d", "Skill: %s Active %.1fs": "技能：%s 生效中 %.1f 秒",
	"Skill: %s CD %.1fs": "技能：%s 冷却 %.1f 秒", "Skill: %s Ready": "技能：%s 已就绪",
	"Skill: Ready": "技能：已就绪", "Passive: %s %.1fs": "被动：%s %.1f 秒",
	"Passive: %s": "被动：%s", "Passive: None": "被动：无",
	"Character %d/%d: %s": "角色 %d/%d：%s", "%s\nSkill: %s - %s": "%s\n技能：%s - %s",
	"Weapon %s: %s": "武器 %s：%s", "Ammo: Reloading...": "弹药：换弹中……",
	"Ammo: %d / %d": "弹药：%d / %d", "Gold: %d": "金币：%d", "Relics: None": "遗物：无",
	"Relics: %s": "遗物：%s", "Enemies: %d": "敌人：%d", "Room: %s": "房间：%s",
	"Delay %.1fs": "延迟 %.1f 秒", "Recovering": "恢复中", "Recovery Off": "恢复暂停",
	"LOW": "低生命", "Crit Focus": "暴击专注", "Guard Stance": "守御姿态",
	"Energy Flow": "能量流", "Kill Burst": "击杀爆发", "Speed Surge": "速度涌动",
	"Armored Core": "装甲核心", "Energy Focus": "能量专注", "Phase Footing": "相位步法",
	"Volatile Focus": "易爆专注", "Triage Kit": "急救套件",

	# Weapon descriptions.
	"Close melee sweep that costs no energy and clears nearby threats.": "不消耗能量的近身横扫，可清除周围威胁。",
	"Stable mid-range sidearm for baseline testing.": "稳定的中距离副武器，性能均衡可靠。",
	"A forceful guard sweep that cuts down shots and drives enemies back.": "强力防御横扫，可击落弹幕并逼退敌人。",
	"Slow explosive shot that punishes clustered enemies.": "发射缓慢爆炸弹，擅长打击聚集的敌人。",
	"A heavy guard fan with a wide sweep for clearing bullets before they reach armor.": "重型防御战扇，以宽幅横扫在弹幕触及护甲前将其清除。",
	"Fires slow heavy shells that punish clustered enemies at medium range.": "发射缓慢重弹，在中距离重创聚集敌人。",
	"Hold fire to compress a precise high-damage bolt.": "按住射击蓄力，释放精准的高伤害箭矢。",
	"Accurate mid-range sidearm with light ricochet utility.": "精准的中距离副武器，附带轻度跳弹能力。",
	"A light sidearm whose rounds bend toward nearby targets.": "轻型副武器，子弹会偏转追踪附近目标。",
	"Places a short-lived mine that burns enemies caught nearby.": "放置短时存在的地雷，灼烧附近敌人。",
	"Fans short-range embers that can burn enemies after impact.": "扇形喷射近距离余烬，命中后可灼烧敌人。",
	"Slow piercing bolts that reward lining up enemies.": "发射缓慢的穿透能量弹，适合贯穿直线上的敌人。",
	"A close-range sweep that can slow enemies caught in its arc.": "近距离横扫，可减速弧形范围内的敌人。",
	"Fans burning fragments across close targets and crowded doorways.": "向近处目标和拥挤门口散射燃烧碎片。",
	"A steady close-range blade that can cut down incoming enemy shots.": "稳定的近战刀刃，可击落迎面飞来的敌方子弹。",
	"Releases a full halo of controlled shots for emergency space control.": "释放环形弹幕，在紧急情况下控制周围空间。",
	"Releases a ring of slow sparks that curve back into nearby threats.": "释放一圈缓慢火花，随后弯向附近敌人。",
	"Fast piercing beam-like shot for lining up rooms.": "高速穿透光束，适合攻击同一直线上的敌人。",
	"Sweeps a wide close-range crescent for sustained self-defense.": "挥出宽阔的近距离新月斩，提供持续自卫能力。",
	"Fires a ring of weak shots for crowd control.": "发射一圈低伤害弹丸，用于控制敌群。",
	"Launches a slow circular spread that buys space against swarms.": "发射缓慢环形弹幕，在敌群中争取活动空间。",
	"Long-range piercing laser that rewards lining enemies into a lane.": "远距离穿透激光，适合将敌人引到同一直线后攻击。",
	"Fast precision sidearm that rewards steady aim with high crit uptime.": "高速精准副武器，稳定瞄准可维持较高暴击率。",
	"A steady sidearm that slows targets to keep firing lanes under control.": "稳定副武器，可减速目标并控制射击通道。",
	"A compact staff that transfers each impact through two nearby targets.": "紧凑法杖，每次命中可向附近两个目标传导。",
	"Shop weapon that trades raw damage for bouncing shots.": "以基础伤害换取跳弹能力的商店武器。",
	"Releases a ring of ricocheting shards that keeps enclosed rooms dangerous.": "释放环形跳弹碎片，让封闭房间持续充满威胁。",
	"Narrow melee thrust with extra reach for lining up doorways.": "攻击范围较长的狭窄近战突刺，适合封锁门口。",
	"A narrow parry blade that turns blocked shots into a sharper counter-hit.": "狭窄的招架刀刃，可将格挡的子弹转化为更强反击。",
	"Deploys a temporary ward that repeatedly strikes nearby enemies.": "部署临时守卫，持续攻击附近敌人。",
	"Wide burst weapon that floods close corridors with low-damage shards.": "宽幅爆发武器，以低伤碎片覆盖近距离走廊。",
	"Close-range burst weapon with wide spread and heavy knockback.": "扩散宽、击退强的近距离爆发武器。",
	"Launches an unstable shell that explodes and can ignite clustered enemies.": "发射不稳定炮弹，爆炸并可能点燃聚集敌人。",
	"Deploys a slowing field that chips enemies over time.": "部署减速区域，持续削减敌人生命。",
	"Charges into a fan of unstable arcs for room control.": "蓄力后释放扇形不稳定电弧，控制房间。",
	"Throws a dense fan of short-lived bolts for risky close-range burst damage.": "扇形投射密集的短时电矢，以高风险换取近距离爆发。",
	"A charged line shot that pierces its first lane and forks through clustered survivors.": "蓄力直线射击，贯穿首条通道并向聚集的残敌分叉。",
	"Deploys a long-lived pulse engine that slows and repels nearby threats.": "部署持续较久的脉冲装置，减速并击退附近敌人。",
	"A wide slow-shot burst whose pellets pull their aim back toward close targets.": "宽幅慢速齐射，弹丸会重新偏向近处目标。",
	"A deliberate charged beam that punches through long lanes.": "稳步蓄力后发射光束，贯穿狭长通道。",

	# Relic descriptions.
	"After taking damage, move 35% faster for 2 seconds.": "受到伤害后，移动速度提高 35%，持续 2 秒。",
	"Deployable weapons last 30% longer.": "部署类武器持续时间延长 30%。",
	"Explosive projectiles gain 36 blast radius.": "爆炸弹丸的爆炸半径增加 36。",
	"Increase weapon damage by 18%.": "武器伤害提高 18%。",
	"Gain 1 armor when a room is cleared.": "清理房间后恢复 1 点护甲。",
	"Gain 2 armor when a room is cleared.": "清理房间后恢复 2 点护甲。",
	"Chain attacks can bridge wider gaps between targets.": "连锁攻击可跨越更远的目标间距。",
	"Increase melee projectile block counter damage by 1.": "近战格挡弹丸后的反击伤害提高 1。",
	"Fully charged shots deal 25% more damage.": "完全蓄力的射击伤害提高 25%。",
	"Add 1 projectile per shot.": "每次射击额外发射 1 枚弹丸。",
	"Increase status damage by 30%.": "状态伤害提高 30%。",
	"Every third kill restores 1 health.": "每击败 3 个敌人恢复 1 点生命。",
	"Increase maximum energy by 3 and restore the same amount.": "能量上限提高 3，并恢复等量能量。",
	"Chain attacks jump to one additional target.": "连锁攻击额外跳转至 1 个目标。",
	"Increase critical chance by 10%.": "暴击率提高 10%。",
	"Gain 1 shield when a room is cleared.": "清理房间后获得 1 点护盾。",
	"Increase max health by 1 and heal 1.": "生命上限提高 1，并恢复 1 点生命。",
	"Projectiles pierce one additional target.": "弹丸额外穿透 1 个目标。",
	"Increase critical chance by 8%.": "暴击率提高 8%。",
	"Attacks apply 25% more knockback.": "攻击击退效果提高 25%。",
	"Increase weapon damage by 12%.": "武器伤害提高 12%。",
	"Increase status duration by 25%.": "状态持续时间延长 25%。",
	"Homing projectiles acquire targets from farther away.": "追踪弹丸可从更远距离锁定目标。",
	"Projectiles gain 12% critical chance.": "弹丸暴击率提高 12%。",
	"Increase fire rate by 14%.": "射速提高 14%。",
	"Increase melee projectile block radius by 24.": "近战弹丸格挡半径增加 24。",
	"Projectiles pierce one additional enemy.": "弹丸额外穿透 1 个敌人。",
	"Weapons fire 20% faster.": "武器射速提高 20%。",
	"Charge weapons build charge 25% faster.": "蓄力武器的蓄力速度提高 25%。",
	"After taking damage, move 50% faster for 3 seconds.": "受到伤害后，移动速度提高 50%，持续 3 秒。",
	"Weapons gain three rounds of magazine capacity.": "武器弹匣容量增加 3 发。",
	"Projectiles gain one additional wall bounce.": "弹丸额外增加 1 次墙壁反弹。",
	"Fire one extra projectile.": "额外发射 1 枚弹丸。",
	"Projectiles deal 25% more damage.": "弹丸伤害提高 25%。",
	"Heal 1 HP after every 3 enemy kills.": "每击败 3 个敌人恢复 1 点生命。",
	"Fire one extra projectile per trigger pull.": "每次扣动扳机额外发射 1 枚弹丸。",
	"Increase fire rate by 12%.": "射速提高 12%。",
	"Fully charged shots release one extra projectile.": "完全蓄力的射击额外释放 1 枚弹丸。",
	"Chain attacks retain more damage after the first impact.": "连锁攻击首次命中后的伤害衰减降低。",
	"Weapons reload 25% faster.": "武器换弹速度提高 25%。",
	"Homing projectiles turn faster toward their targets.": "追踪弹丸转向目标的速度更快。",
	"Deployable weapons deal 25% more damage.": "部署类武器伤害提高 25%。",
	"Increase status effect chance by 12%.": "施加状态效果的概率提高 12%。",
	"Increase melee projectile block arc by 24 degrees.": "近战弹丸格挡角度增加 24 度。",

	# Talent, blessing, statue, biome and elite descriptions.
	"Gain one max health for the rest of this run.": "本次冒险中生命上限提高 1。",
	"Increase weapon damage for the rest of this run.": "本次冒险中武器伤害提高。",
	"Increase fire rate for the rest of this run.": "本次冒险中射速提高。",
	"Event blessing that restores energy whenever a room is cleared.": "事件祝福：每次清理房间时恢复能量。",
	"Event blessing that converts a hit into a small armor recovery pulse.": "事件祝福：受击时触发一次小幅护甲恢复。",
	"Event blessing that expands the energy pool for longer weapon chains.": "事件祝福：提高能量上限，以支持更长的连续攻击。",
	"Event blessing that turns a sacrifice into stronger weapon damage for the rest of the run.": "事件祝福：献祭后，本次冒险中的武器伤害提高。",
	"Event blessing that adds a small armor buffer for longer routes.": "事件祝福：增加少量护甲，提升长路线续航。",
	"Event blessing that restores energy whenever a statue resonance triggers.": "事件祝福：每次触发雕像共鸣时恢复能量。",
	"Event blessing that refunds energy every third enemy defeated.": "事件祝福：每击败 3 个敌人返还能量。",
	"Skill-linked statue that restores a small amount of armor whenever a skill is used.": "技能联动雕像：每次使用技能时恢复少量护甲。",
	"Skill-linked statue that briefly increases weapon damage after using a skill.": "技能联动雕像：使用技能后短暂提高武器伤害。",
	"Skill-linked statue that refunds energy after every second skill use.": "技能联动雕像：每使用 2 次技能返还能量。",
	"Opening biome focused on readable pursuit, simple crossfire, and early build setup.": "起始地区，以清晰的追击、简单交叉火力和早期构筑为主。",
	"Middle biome that adds armor pressure, chargers, and target-priority summons.": "中段地区，加入护甲压力、冲锋敌人和需要优先处理的召唤物。",
	"Final biome that combines ranged pressure, shields, bombs, and summons before the last boss.": "最终地区，在终极首领前综合远程压制、护盾、炸弹与召唤威胁。",
	"Aggressive elite that periodically telegraphs a damaging scorch pulse and leaves a small death blast.": "进攻型精英，会周期预警灼烧脉冲，死亡时产生小型爆炸。",
	"Durable elite whose guarded core reduces incoming damage, balanced by slower movement.": "耐久型精英，受保护的核心可降低伤害，但移动较慢。",
	"Fast elite that telegraphs periodic overclock bursts before accelerating its movement.": "高速精英，会预警周期性超频并加快移动。",
	"Ranged elite that adds two focused projectile lanes with a longer readable windup.": "远程精英，较长前摇后追加两条集中弹道。",
	"Large unstoppable elite with heavy contact pressure and strong resistance to knockback.": "体型巨大的强韧精英，接触威胁高且抗击退能力强。",
	"Explosive elite that destabilizes below half health, accelerates attacks, and leaves a large death blast.": "爆炸型精英，半血后失稳并加快攻击，死亡时产生大型爆炸。",

	# Compact relic effect summaries.
	"+35% move speed for 2s after hurt": "受伤后移动速度 +35%，持续 2 秒",
	"+30% deployable duration": "部署物持续时间 +30%", "+36 explosion radius": "爆炸半径 +36",
	"+18% weapon damage": "武器伤害 +18%", "+1 armor on room clear": "清理房间时护甲 +1",
	"+2 armor on room clear": "清理房间时护甲 +2", "+55 chain radius": "连锁半径 +55",
	"+1 block counter damage": "格挡反击伤害 +1", "+25% charged damage": "蓄力伤害 +25%",
	"+1 projectile": "弹丸数量 +1", "+30% status damage": "状态伤害 +30%",
	"+1 health every 3 kills": "每击败 3 个敌人恢复 1 点生命", "+3 maximum energy": "能量上限 +3",
	"+1 chain target": "连锁目标 +1", "+10% critical chance": "暴击率 +10%",
	"+1 max HP and +1 heal": "生命上限 +1，并恢复 1 点生命", "+1 projectile pierce": "弹丸穿透 +1",
	"+8% critical chance": "暴击率 +8%", "+25% attack knockback": "攻击击退 +25%",
	"+12% weapon damage": "武器伤害 +12%", "+25% status duration": "状态持续时间 +25%",
	"+100 homing acquisition radius": "追踪锁定半径 +100", "+12% projectile crit chance": "弹丸暴击率 +12%",
	"+14% fire rate": "射速 +14%", "+24 block radius": "格挡半径 +24",
	"+20% fire rate": "射速 +20%", "+25% charge speed": "蓄力速度 +25%",
	"+50% move speed for 3s after hurt": "受伤后移动速度 +50%，持续 3 秒",
	"+3 magazine capacity": "弹匣容量 +3", "+1 projectile bounce": "弹丸反弹 +1",
	"+25% projectile damage": "弹丸伤害 +25%", "+1 HP after every 3 kills": "每击败 3 个敌人恢复 1 点生命",
	"+1 projectile per shot": "每次射击弹丸 +1", "+12% fire rate": "射速 +12%",
	"+1 full-charge projectile": "完全蓄力弹丸 +1", "+20% chain damage": "连锁伤害 +20%",
	"+25% reload speed": "换弹速度 +25%", "+90 deg/s homing turn rate": "追踪转向速度 +90 度/秒",
	"+25% deployable damage": "部署物伤害 +25%", "+12% status chance": "状态触发概率 +12%",
	"+24 deg block arc": "格挡角度 +24 度",
}

var _translation: Translation
var _message_keys_by_length: Array[String] = []
var _scan_accumulator := 0.0
var _localizing_controls: Dictionary = {}
var _control_text_cache: Dictionary = {}
var _scan_enabled := false


func _enter_tree() -> void:
	_translation = Translation.new()
	_translation.locale = LOCALE
	for source_text in MESSAGES:
		_translation.add_message(StringName(source_text), StringName(MESSAGES[source_text]))
	TranslationServer.add_translation(_translation)
	TranslationServer.set_locale(LOCALE)
	_message_keys_by_length.assign(MESSAGES.keys())
	_message_keys_by_length.sort_custom(func(a: String, b: String) -> bool: return a.length() > b.length())


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)
	get_tree().node_removed.connect(_on_node_removed)
	call_deferred("_configure_runtime_locale")


func _configure_runtime_locale() -> void:
	var current_scene := get_tree().current_scene
	var scene_path := current_scene.scene_file_path if current_scene != null else ""
	var is_debug_scene := scene_path.begins_with("res://scenes/debug/")
	var is_localization_test := scene_path.ends_with("ChineseLocalizationSmokeTest.tscn")
	_scan_enabled = not is_debug_scene or is_localization_test
	TranslationServer.set_locale(LOCALE if _scan_enabled else "en")
	set_process(_scan_enabled)
	if _scan_enabled:
		localize_tree(get_tree().root)


func _process(delta: float) -> void:
	if not _scan_enabled:
		return
	_scan_accumulator += delta
	if _scan_accumulator < 0.2:
		return
	_scan_accumulator = 0.0
	localize_tree(get_tree().root)


func text(source_text: Variant) -> String:
	return TranslationServer.translate(StringName(str(source_text)))


func format(source_template: String, values: Variant) -> String:
	return text(source_template) % values


func is_translated(source_text: Variant) -> bool:
	var source := str(source_text)
	return source.to_lower() == source.to_upper() or text(source) != source


func visible_text(source_text: Variant) -> String:
	var source := str(source_text)
	if source.to_lower() == source.to_upper():
		return source
	var translated := text(source)
	if translated != source:
		return translated
	for key in _message_keys_by_length:
		if not (key.contains(" ") or key.contains("\n")) or not translated.contains(key):
			continue
		translated = translated.replace(key, str(MESSAGES[key]))
	return _translate_words(translated)


func _translate_words(source: String) -> String:
	var output := ""
	var word := ""
	for index in range(source.length()):
		var character := source[index]
		var code := character.unicode_at(0)
		var is_ascii_letter := (code >= 65 and code <= 90) or (code >= 97 and code <= 122)
		if is_ascii_letter:
			word += character
			continue
		output += _translate_word(word)
		word = ""
		output += character
	return output + _translate_word(word)


func _translate_word(word: String) -> String:
	if word.is_empty():
		return ""
	if MESSAGES.has(word):
		return str(MESSAGES[word])
	if SHORT_EMBEDDED_MESSAGES.has(word):
		return str(SHORT_EMBEDDED_MESSAGES[word])
	var normalized := word.to_lower()
	if WORD_MESSAGES.has(normalized):
		return str(WORD_MESSAGES[normalized])
	return word


func localize_tree(root: Node) -> void:
	if root == null:
		return
	if root is Control:
		_localize_control(root as Control)
	for child in root.get_children():
		localize_tree(child)


func _localize_control(control: Control) -> void:
	var instance_id := control.get_instance_id()
	if _localizing_controls.has(instance_id):
		return
	_localizing_controls[instance_id] = true
	var cache: Dictionary = _control_text_cache.get(instance_id, {})
	if control is Label or control is RichTextLabel or control is BaseButton:
		var current_text := str(control.get("text"))
		if not cache.has("text") or current_text != str(cache["text"]):
			var localized_text := visible_text(current_text)
			if localized_text != current_text:
				control.set("text", localized_text)
			cache["text"] = localized_text
	if control is LineEdit:
		var current_placeholder := (control as LineEdit).placeholder_text
		if not cache.has("placeholder") or current_placeholder != str(cache["placeholder"]):
			var localized_placeholder := visible_text(current_placeholder)
			if localized_placeholder != current_placeholder:
				(control as LineEdit).placeholder_text = localized_placeholder
			cache["placeholder"] = localized_placeholder
	var current_tooltip := control.tooltip_text
	if not cache.has("tooltip") or current_tooltip != str(cache["tooltip"]):
		var localized_tooltip := visible_text(current_tooltip)
		if localized_tooltip != current_tooltip:
			control.tooltip_text = localized_tooltip
		cache["tooltip"] = localized_tooltip
	_control_text_cache[instance_id] = cache
	_localizing_controls.erase(instance_id)


func _on_node_removed(node: Node) -> void:
	_control_text_cache.erase(node.get_instance_id())
	_localizing_controls.erase(node.get_instance_id())

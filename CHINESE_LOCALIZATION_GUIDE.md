# 中文版开发规范

本项目从当前版本起以简体中文作为唯一面向玩家的默认语言。代码符号、资源路径、内容 ID、存档键和测试选择器继续使用稳定英文标识，避免破坏逻辑、存档兼容性与数据引用。

## 新内容规则

1. 新增菜单、HUD、提示、按钮、房间交互和结算文案时，优先直接编写中文。
2. 若资源字段需要保留英文源文（例如 `display_name`、`description`），必须同时在 `dungeon-unleashed/scripts/localization/Localization.gd` 的 `MESSAGES` 中补充中文映射。
3. 动态数值文本应先使用中文模板再格式化；若沿用英文模板，最终显示节点必须经过 `Localization.visible_text()`。
4. 不翻译 `weapon_basic_pistol`、`rift_runner` 等内部 ID，也不要在玩家工具提示中暴露这些 ID。
5. 键盘与手柄实体按键名可保留 `WASD`、`LMB`、`Esc`、`Start` 等标准标识，操作说明本身必须为中文。
6. 中文句子使用全角中文标点；数值、百分号、按键名和代码标识按界面可读性保留半角形式。

## 验收要求

- 运行 `ChineseLocalizationSmokeTest`，确认所有内容资源字段已有中文结果，HUD、大厅、隐藏面板与工具提示无未许可英文残留。
- 中文增量扫描平均耗时必须低于 `2.5 ms`，防止本地化引入周期性长帧。
- 任何新增玩家可见页面都要加入中文冒烟测试覆盖；普通战斗测试继续使用稳定内部英文测试契约。
- Windows 导出后人工检查中文字体、换行、按钮宽度、长描述和 1280x720 下的布局。

## 验证命令

```powershell
$env:APPDATA='E:\Dungeon Unleashed\tmp_godot\appdata'
$env:LOCALAPPDATA='E:\Dungeon Unleashed\tmp_godot\localappdata'
& 'C:\Godot_v4.7-stable\Godot_v4.7-stable_win64_console.exe' --headless --path 'E:\Dungeon Unleashed\dungeon-unleashed' 'res://scenes/debug/ChineseLocalizationSmokeTest.tscn'
```

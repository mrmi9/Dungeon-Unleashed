extends Node

const HUD_SCENE := preload("res://scenes/ui/HUD.tscn")
const TEST_RESOLUTIONS := [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
]
const TEST_RELICS := [
	preload("res://resources/relics/sharp_rounds.tres"),
	preload("res://resources/relics/guardian_ward.tres"),
	preload("res://resources/relics/adrenaline_charm.tres"),
]

var _failures: Array[String] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_run")


func _run() -> void:
	for resolution in TEST_RESOLUTIONS:
		await _check_resolution(resolution)
	_finish()


func _check_resolution(resolution: Vector2i) -> void:
	var viewport := SubViewport.new()
	viewport.name = "UILayoutViewport_%dx%d" % [resolution.x, resolution.y]
	viewport.size = resolution
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_tree().root.add_child(viewport)

	var hud := HUD_SCENE.instantiate()
	viewport.add_child(hud)
	await get_tree().process_frame
	await get_tree().process_frame

	_check_gameplay_overlay(hud, resolution)

	hud.call("show_main_menu")
	await get_tree().process_frame
	_check_modal_panel(hud, "MainMenuPanel", "main menu", resolution)

	hud.call("show_settings_menu", 1.0, 1.0, 0.8, false, 0)
	await get_tree().process_frame
	_check_modal_panel(hud, "SettingsPanel", "settings panel", resolution)

	hud.call("show_pause_menu")
	await get_tree().process_frame
	_check_modal_panel(hud, "PausePanel", "pause panel", resolution)

	hud.call("show_run_result", true, _make_verbose_summary())
	await get_tree().process_frame
	_check_modal_panel(hud, "ResultPanel", "result panel", resolution)

	hud.call("hide_flow_panels")
	hud.call("show_relic_choices", TEST_RELICS)
	await get_tree().process_frame
	_check_modal_panel(hud, "RelicChoicePanel", "relic choice panel", resolution)

	hud.call("hide_relic_choices")
	hud.call("show_debug_map_panel")
	await get_tree().process_frame
	_check_modal_panel(hud, "DebugMapPanel", "debug map panel", resolution)

	hud.call("hide_debug_map_panel")
	hud.call("hide_flow_panels")
	await get_tree().process_frame
	_check_gameplay_overlay(hud, resolution)

	viewport.queue_free()
	await get_tree().process_frame


func _check_gameplay_overlay(hud: Node, resolution: Vector2i) -> void:
	var input_hint_panel := hud.get_node_or_null("InputHintPanel") as Control
	_expect(input_hint_panel != null, "Input hint panel should exist")
	if input_hint_panel != null:
		_expect(input_hint_panel.visible, "Input hint should be visible during gameplay at %s" % _format_resolution(resolution))
		_check_rect_inside(input_hint_panel, resolution, "gameplay input hint")
	_expect(bool(hud.call("is_gameplay_stats_visible_for_test")), "Combat stats should be visible during gameplay")
	_expect(bool(hud.call("is_minimap_visible_for_test")), "Minimap should be visible during gameplay")

	var combat_stats := hud.get_node_or_null("MarginContainer") as Control
	_check_rect_inside(combat_stats, resolution, "combat stats")
	if combat_stats != null:
		_expect(combat_stats.size.x <= 190.0, "Compact combat stats should stay at or below 190 px wide")
		_expect(combat_stats.size.y <= 190.0, "Compact combat stats should stay at or below 190 px tall, got %.1f" % combat_stats.size.y)
	for icon_name in ["HealthIcon", "ShieldIcon", "EnergyIcon"]:
		var status_icon := hud.get_node_or_null("MarginContainer/VBoxContainer/VitalsRow/%s" % icon_name) as TextureRect
		_expect(status_icon != null and status_icon.texture != null, "Compact HUD should render the %s texture" % icon_name)
	_expect(not _is_control_visible(hud, "MarginContainer/VBoxContainer/PassiveStatusRow/PassiveStatusLabel"), "Compact HUD should move passive details into the icon tooltip")
	_expect(not _is_control_visible(hud, "MarginContainer/VBoxContainer/RuleFeedbackRow"), "Compact HUD should hide inactive rule feedback")
	_expect(not _is_control_visible(hud, "MarginContainer/VBoxContainer/RoomStateLabel"), "Compact HUD should avoid duplicating room state beside the minimap")
	_expect(not _is_control_visible(hud, "MarginContainer/VBoxContainer/WeaponLabel"), "Compact HUD should hide the duplicate weapon line")
	_expect(not _is_control_visible(hud, "MarginContainer/VBoxContainer/AmmoLabel"), "Compact HUD should hide the duplicate ammo line")
	_expect(not _is_control_visible(hud, "MarginContainer/VBoxContainer/WeaponSlotPanel/MarginContainer/VBoxContainer/WeaponSlotMetaLabel"), "Compact HUD should move weapon metadata into tooltips")
	for slot_index in range(1, 4):
		var slot_base := "MarginContainer/VBoxContainer/WeaponSlotPanel/MarginContainer/VBoxContainer/WeaponSlotLoadoutRow/LoadoutSlot%d/LoadoutSlotMargin/LoadoutSlotContent" % slot_index
		_expect(_is_control_visible(hud, "%s/LoadoutSlotIcon" % slot_base), "Compact HUD weapon slot %d should keep its icon visible" % slot_index)
		_expect(not _is_control_visible(hud, "%s/LoadoutSlotLabel" % slot_base), "Compact HUD weapon slot %d should hide its long text label" % slot_index)
	_check_rect_inside(hud.get_node_or_null("MinimapPanel") as Control, resolution, "minimap")


func _is_control_visible(root: Node, path: String) -> bool:
	var control := root.get_node_or_null(path) as Control
	return control != null and control.visible


func _check_modal_panel(hud: Node, panel_path: String, label: String, resolution: Vector2i) -> void:
	var panel := hud.get_node_or_null(panel_path) as Control
	_expect(panel != null, "%s should exist at %s" % [label, _format_resolution(resolution)])
	if panel == null:
		return

	_expect(panel.visible, "%s should be visible at %s" % [label, _format_resolution(resolution)])
	_check_rect_inside(panel, resolution, label)
	_check_visible_children_inside(panel, resolution, label)

	var input_hint_panel := hud.get_node_or_null("InputHintPanel") as Control
	if input_hint_panel != null:
		_expect(not input_hint_panel.visible, "%s should hide gameplay input hint at %s" % [label, _format_resolution(resolution)])
	_expect(not bool(hud.call("is_gameplay_stats_visible_for_test")), "%s should hide combat stats" % label)
	_expect(not bool(hud.call("is_minimap_visible_for_test")), "%s should hide the minimap" % label)


func _check_visible_children_inside(node: Node, resolution: Vector2i, context: String) -> void:
	for child in node.get_children():
		if child is Control:
			var control := child as Control
			if control.visible:
				_check_rect_inside(control, resolution, "%s child %s" % [context, child.name])
				if control is ScrollContainer:
					continue
				_check_visible_children_inside(child, resolution, context)
		else:
			_check_visible_children_inside(child, resolution, context)


func _check_rect_inside(control: Control, resolution: Vector2i, label: String) -> void:
	if control == null or not control.visible:
		return

	var rect := control.get_global_rect()
	var viewport_rect := Rect2(Vector2.ZERO, Vector2(resolution))
	var tolerance := 1.5
	var inside := (
		rect.position.x >= viewport_rect.position.x - tolerance
		and rect.position.y >= viewport_rect.position.y - tolerance
		and rect.end.x <= viewport_rect.end.x + tolerance
		and rect.end.y <= viewport_rect.end.y + tolerance
	)
	_expect(
		inside,
		"%s rect should stay inside %s, got pos=%s size=%s" % [
			label,
			_format_resolution(resolution),
			rect.position,
			rect.size,
		]
	)


func _make_verbose_summary() -> Dictionary:
	return {
		"result": "Victory",
		"rooms_cleared": 6,
		"kills": 32,
		"elapsed_seconds": 426,
		"gold": 48,
		"gold_earned": 184,
		"gold_spent": 136,
		"weapon": "Ricochet Blaster",
		"loadout": ["Basic Pistol", "Shotgun", "Energy Staff", "Ricochet Blaster"],
		"relic_names": ["Sharp Rounds", "Quick Trigger", "Guardian Ward", "Adrenaline Charm", "Vampire Fang"],
		"current_hp": 4,
		"max_hp": 8,
		"shield": 2,
		"damage_taken": 9,
		"critical_hits": 18,
		"healing_received": 3,
		"shield_absorbed": 4,
		"rewards_collected": 3,
		"chests_opened": 2,
		"shop_purchases": 2,
		"boss_defeated": true,
		"history": {
			"runs": 5,
			"victories": 2,
			"best_rooms": 6,
			"best_kills": 34,
			"best_gold": 192,
		},
	}


func _format_resolution(resolution: Vector2i) -> String:
	return "%dx%d" % [resolution.x, resolution.y]


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("UILayoutSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

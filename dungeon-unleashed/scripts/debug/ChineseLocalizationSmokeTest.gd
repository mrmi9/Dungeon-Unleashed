extends Node

const HUD_SCENE := preload("res://scenes/ui/HUD.tscn")
const LOBBY_SCENE := preload("res://scenes/ui/LobbyScreen.tscn")
const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const CONTENT_DIRS := [
	"res://resources/weapons",
	"res://resources/relics",
	"res://resources/characters",
	"res://resources/talents",
	"res://resources/blessings",
	"res://resources/statues",
	"res://resources/biomes",
	"res://resources/elite_modifiers",
	"res://resources/room_layouts",
	"res://resources/relic_drop_tables",
]
const PLAYER_VISIBLE_FIELDS := [
	"display_name",
	"description",
	"passive_description",
	"hall_summary",
	"skill_name",
	"skill_description",
	"description_value_template",
	"rule_text",
]
const ALLOWED_INTERFACE_WORDS := [
	"CHR", "WPN", "REL", "STU", "SRC", "SFX", "WASD", "LMB", "CD", "Esc", "Start",
]

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	_expect(TranslationServer.get_locale() == "zh_CN", "Chinese should be the default locale")
	_expect(Localization.text("Dungeon Unleashed") == "地牢觉醒", "Game title should have a Chinese translation")
	_verify_content_resources()
	await _verify_ui_scenes()
	await _verify_live_main_lobby()
	_finish()


func _verify_content_resources() -> void:
	for directory_path in CONTENT_DIRS:
		for file_name in DirAccess.get_files_at(directory_path):
			if not file_name.ends_with(".tres"):
				continue
			var resource_path := "%s/%s" % [directory_path, file_name]
			var content := load(resource_path)
			_expect(content != null, "Content should load: %s" % resource_path)
			if content == null:
				continue
			for field_name in PLAYER_VISIBLE_FIELDS:
				var value = content.get(field_name)
				if value == null or str(value).strip_edges().is_empty():
					continue
				_expect(
					Localization.is_translated(value),
					"Player-visible field requires Chinese translation: %s %s = %s" % [resource_path, field_name, value]
				)


func _verify_ui_scenes() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	get_tree().root.add_child(viewport)
	var hud := HUD_SCENE.instantiate()
	viewport.add_child(hud)
	hud.call("update_character_selection", "Wanderer", "Balanced shooter with stable health, armor, and energy.", "Phase Dash", "Brief speed burst with short invulnerability.", 0, 6)
	hud.call("set_weapon_name", "Basic Pistol", 1, 3)
	hud.call("update_health", 6, 6)
	var lobby := LOBBY_SCENE.instantiate()
	viewport.add_child(lobby)
	lobby.call("update_character_selection", "Wanderer", "Balanced shooter with stable health, armor, and energy.", "Phase Dash", "Brief speed burst with short invulnerability.", 0, 6)
	await get_tree().create_timer(0.25).timeout
	_expect(_node_text(hud, "MarginContainer/VBoxContainer/HealthLabel").contains("生命"), "HUD health label should be Chinese")
	_expect(_node_text(hud, "MainMenuPanel/MarginContainer/VBoxContainer/TitleLabel") == "地牢觉醒", "Main menu title should be Chinese")
	_expect(str(hud.call("get_weapon_label_text")).contains("基础手枪"), "Dynamic weapon label should translate the weapon name")
	_expect(_find_text(lobby, "前哨大厅"), "Lobby title should be Chinese")
	_expect(_find_text(lobby, "流浪者"), "Dynamic lobby character text should translate the character name")
	_audit_control_tree(hud)
	_audit_control_tree(lobby)
	var scan_started := Time.get_ticks_usec()
	for _iteration in range(100):
		Localization.localize_tree(viewport)
	var scan_average_us := float(Time.get_ticks_usec() - scan_started) / 100.0
	print("ChineseLocalizationSmokeTest localization_scan_avg_us=%d" % roundi(scan_average_us))
	_expect(scan_average_us < 2500.0, "Periodic localization scan should stay below 2.5 ms")
	viewport.queue_free()
	await get_tree().process_frame


func _verify_live_main_lobby() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	get_tree().root.add_child(viewport)
	var main := MAIN_SCENE.instantiate()
	viewport.add_child(main)
	await get_tree().process_frame
	main.call("open_hall_menu")
	await get_tree().create_timer(0.25).timeout
	var hud := main.get_node_or_null("CanvasLayer/HUD")
	_expect(hud != null, "Live Main scene should expose HUD")
	if hud != null:
		_audit_control_tree(hud)
		_expect(str(hud.call("get_lobby_quick_stats_text")).contains("角色"), "Live lobby quick stats should use Chinese plurals")
		_expect(not str(hud.call("get_lobby_objective_board_text")).contains("Objectives"), "Live lobby objectives should be Chinese")
	viewport.queue_free()
	await get_tree().process_frame


func _node_text(root: Node, path: String) -> String:
	var node := root.get_node_or_null(path)
	return str(node.get("text")) if node != null else ""


func _find_text(root: Node, fragment: String) -> bool:
	if root is Label or root is BaseButton or root is RichTextLabel:
		if str(root.get("text")).contains(fragment):
			return true
	for child in root.get_children():
		if _find_text(child, fragment):
			return true
	return false


func _audit_control_tree(root: Node) -> void:
	if root is Label or root is BaseButton or root is RichTextLabel:
		_audit_visible_string(str(root.get("text")), str(root.get_path()))
	if root is LineEdit:
		_audit_visible_string((root as LineEdit).placeholder_text, "%s placeholder" % root.get_path())
	if root is Control:
		_audit_visible_string((root as Control).tooltip_text, "%s tooltip" % root.get_path())
	for child in root.get_children():
		_audit_control_tree(child)


func _audit_visible_string(value: String, context: String) -> void:
	var regex := RegEx.new()
	regex.compile("[A-Za-z]{3,}")
	for match_result in regex.search_all(value):
		var word := match_result.get_string()
		if word in ALLOWED_INTERFACE_WORDS or word == word.to_upper():
			continue
		_expect(false, "English interface residue at %s: %s" % [context, value.replace("\n", " | ")])
		return


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CHINESE LOCALIZATION SMOKE TEST PASSED")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error(failure)
	print("CHINESE LOCALIZATION SMOKE TEST FAILED: %d issue(s)" % _failures.size())
	get_tree().quit(1)

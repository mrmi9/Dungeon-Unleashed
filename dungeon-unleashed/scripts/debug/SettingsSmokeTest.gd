extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const SETTINGS_FILE := "settings.cfg"
const SETTINGS_PATH := "user://settings.cfg"

var _failures: Array[String] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_run")


func _run() -> void:
	_delete_settings_file()

	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame

	var hud = main.get_node_or_null("CanvasLayer/HUD")
	_expect(hud != null, "HUD should exist")
	_expect(main.has_method("get_settings_summary"), "Main should expose settings summary")
	if hud == null or not main.has_method("get_settings_summary"):
		_finish()
		return

	var summary: Dictionary = main.call("get_settings_summary")
	_expect(is_equal_approx(float(summary.get("master_volume", -1.0)), 1.0), "Default master volume should be 1.0")
	_expect(is_equal_approx(float(summary.get("sfx_volume", -1.0)), 1.0), "Default SFX volume should be 1.0")
	_expect(is_equal_approx(float(summary.get("music_volume", -1.0)), 0.8), "Default music volume should be 0.8")
	_expect(summary.get("fullscreen", true) != true, "Default fullscreen should be false")
	_expect(int(summary.get("resolution_width", 0)) == 1280, "Default resolution width should be 1280")
	_expect(int(summary.get("resolution_height", 0)) == 720, "Default resolution height should be 720")

	main.call("open_settings_menu")
	await get_tree().process_frame
	_expect(bool(hud.call("is_settings_visible")), "Settings panel should open from main menu")

	hud.call("set_settings_for_test", 0.35, 0.45, 0.55, true, 2)
	main.call(
		"apply_settings",
		float(hud.call("get_settings_volume_value")),
		float(hud.call("get_settings_sfx_volume_value")),
		float(hud.call("get_settings_music_volume_value")),
		hud.call("get_settings_fullscreen_enabled") == true,
		int(hud.call("get_settings_resolution_index"))
	)
	await get_tree().process_frame

	summary = main.call("get_settings_summary")
	_expect(is_equal_approx(float(summary.get("master_volume", -1.0)), 0.35), "Applied master volume should be stored in Main")
	_expect(is_equal_approx(float(summary.get("sfx_volume", -1.0)), 0.45), "Applied SFX volume should be stored in Main")
	_expect(is_equal_approx(float(summary.get("music_volume", -1.0)), 0.55), "Applied music volume should be stored in Main")
	_expect(summary.get("fullscreen", false) == true, "Applied fullscreen should be stored in Main")
	_expect(int(summary.get("resolution_width", 0)) == 1920, "Applied resolution width should be stored in Main")
	_expect(int(summary.get("resolution_height", 0)) == 1080, "Applied resolution height should be stored in Main")

	_expect(bool(main.call("rebind_input_action", "reload", KEY_T)), "Reload key should be rebindable")
	await get_tree().process_frame
	summary = main.call("get_settings_summary")
	var input_bindings: Dictionary = summary.get("input_bindings", {})
	var reload_binding: Dictionary = input_bindings.get("reload", {})
	_expect(int(reload_binding.get("keycode", 0)) == KEY_T, "Settings summary should expose rebound reload key")
	_expect(_action_has_physical_key("reload", KEY_T), "InputMap should use rebound reload key")
	_expect(not _action_has_physical_key("reload", KEY_R), "InputMap should remove old reload key")
	_expect(str(hud.call("get_control_rebind_button_text", "reload")).contains("T"), "Settings UI should show rebound reload key")
	_expect(str(hud.call("get_input_hint_text")).contains("Reload T"), "Input hint should show rebound reload key")
	_expect(_settings_file_has(0.35, 0.45, 0.55, true, 1920, 1080, KEY_T), "Settings file should persist applied values and rebound controls")

	get_tree().paused = false
	main.queue_free()
	await get_tree().process_frame

	var reloaded_main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(reloaded_main)
	await get_tree().process_frame
	var reloaded_hud = reloaded_main.get_node_or_null("CanvasLayer/HUD")
	var reloaded_summary: Dictionary = reloaded_main.call("get_settings_summary")
	_expect(is_equal_approx(float(reloaded_summary.get("master_volume", -1.0)), 0.35), "Reloaded main should read saved master volume")
	_expect(is_equal_approx(float(reloaded_summary.get("sfx_volume", -1.0)), 0.45), "Reloaded main should read saved SFX volume")
	_expect(is_equal_approx(float(reloaded_summary.get("music_volume", -1.0)), 0.55), "Reloaded main should read saved music volume")
	_expect(reloaded_summary.get("fullscreen", false) == true, "Reloaded main should read saved fullscreen")
	_expect(int(reloaded_summary.get("resolution_width", 0)) == 1920, "Reloaded main should read saved resolution width")
	_expect(int(reloaded_summary.get("resolution_height", 0)) == 1080, "Reloaded main should read saved resolution height")
	var reloaded_bindings: Dictionary = reloaded_summary.get("input_bindings", {})
	var reloaded_reload_binding: Dictionary = reloaded_bindings.get("reload", {})
	_expect(int(reloaded_reload_binding.get("keycode", 0)) == KEY_T, "Reloaded main should read saved reload key")
	_expect(_action_has_physical_key("reload", KEY_T), "Reloaded InputMap should use saved reload key")
	if reloaded_hud != null:
		reloaded_main.call("open_settings_menu")
		await get_tree().process_frame
		_expect(is_equal_approx(float(reloaded_hud.call("get_settings_volume_value")), 0.35), "Settings UI should show saved master volume")
		_expect(is_equal_approx(float(reloaded_hud.call("get_settings_sfx_volume_value")), 0.45), "Settings UI should show saved SFX volume")
		_expect(is_equal_approx(float(reloaded_hud.call("get_settings_music_volume_value")), 0.55), "Settings UI should show saved music volume")
		_expect(reloaded_hud.call("get_settings_fullscreen_enabled") == true, "Settings UI should show saved fullscreen")
		_expect(int(reloaded_hud.call("get_settings_resolution_index")) == 2, "Settings UI should show saved resolution")
		_expect(str(reloaded_hud.call("get_control_rebind_button_text", "reload")).contains("T"), "Settings UI should show saved rebound reload key")

	get_tree().paused = false
	reloaded_main.queue_free()
	await get_tree().process_frame
	_delete_settings_file()
	_finish()


func _settings_file_has(expected_volume: float, expected_sfx_volume: float, expected_music_volume: float, expected_fullscreen: bool, expected_width: int, expected_height: int, expected_reload_key: int) -> bool:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return false
	var volume := float(config.get_value("audio", "master_volume", -1.0))
	var sfx_volume := float(config.get_value("audio", "sfx_volume", -1.0))
	var music_volume := float(config.get_value("audio", "music_volume", -1.0))
	var fullscreen: bool = config.get_value("display", "fullscreen", not expected_fullscreen) == true
	var width := int(config.get_value("display", "resolution_width", 0))
	var height := int(config.get_value("display", "resolution_height", 0))
	var reload_key := int(config.get_value("controls", "reload", 0))
	return (
		is_equal_approx(volume, expected_volume)
		and is_equal_approx(sfx_volume, expected_sfx_volume)
		and is_equal_approx(music_volume, expected_music_volume)
		and fullscreen == expected_fullscreen
		and width == expected_width
		and height == expected_height
		and reload_key == expected_reload_key
	)


func _action_has_physical_key(action_name: String, expected_keycode: int) -> bool:
	for event in InputMap.action_get_events(StringName(action_name)):
		if event is InputEventKey and (event as InputEventKey).physical_keycode == expected_keycode:
			return true
	return false


func _delete_settings_file() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var dir := DirAccess.open("user://")
	if dir != null:
		dir.remove(SETTINGS_FILE)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	get_tree().paused = false
	if _failures.is_empty():
		print("SettingsSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

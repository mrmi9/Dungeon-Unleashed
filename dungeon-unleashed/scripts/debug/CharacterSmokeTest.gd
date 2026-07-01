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
	var player := main.get_node_or_null("Player") as Player
	_expect(hud != null, "HUD should exist")
	_expect(player != null, "Player should exist")
	_expect(main.has_method("select_next_character"), "Main should expose next character selection")
	_expect(main.has_method("select_previous_character"), "Main should expose previous character selection")
	_expect(main.has_method("get_character_selection_summary"), "Main should expose current character summary")
	if hud == null or player == null:
		_finish()
		return

	var initial_summary: Dictionary = main.call("get_character_selection_summary")
	_expect(str(initial_summary.get("display_name", "")) == "Wanderer", "Default character should be Wanderer")
	_expect(int(initial_summary.get("total", 0)) == 3, "Main menu should expose three selectable characters")
	_expect(str(hud.call("get_character_name_text")).contains("Wanderer"), "HUD should show default character")
	_expect(str(hud.call("get_skill_label_text")).contains("Phase Dash"), "HUD should show default skill")

	_expect(bool(main.call("select_next_character")), "Selecting next character in main menu should succeed")
	await get_tree().process_frame
	var warden_summary: Dictionary = main.call("get_character_selection_summary")
	_expect(str(warden_summary.get("display_name", "")) == "Warden", "Next character should be Warden")
	_expect(player.max_health == 7, "Warden should apply higher health")
	_expect(player.max_shield == 8, "Warden should apply higher armor")
	_expect(player.max_energy == 100, "Warden should apply lower energy")
	_expect(is_equal_approx(player.move_speed, 238.0), "Warden should apply slower movement speed")
	_expect(str(hud.call("get_character_name_text")).contains("Warden"), "HUD should show selected Warden")
	_expect(str(hud.call("get_character_info_text")).contains("Guard Pulse"), "HUD should show Warden skill details")

	player.current_shield = 4
	player.current_energy = player.max_energy
	var used_warden_skill := player.try_use_skill()
	await get_tree().process_frame
	_expect(used_warden_skill, "Warden skill should activate when energy is available")
	_expect(player.current_shield == 7, "Warden skill should restore armor")
	_expect(player.current_energy == 90, "Warden skill should spend energy")
	_expect(player.get_skill_summary().get("cooldown_remaining", 0.0) > 0.0, "Warden skill should start cooldown")
	_expect(not player.try_use_skill(), "Skill should not be reusable while on cooldown")
	_expect(str(hud.call("get_skill_label_text")).contains("Guard Pulse"), "HUD should show Warden skill status")

	_expect(bool(main.call("select_next_character")), "Selecting next character after Warden should succeed")
	await get_tree().process_frame
	var arcanist_summary: Dictionary = main.call("get_character_selection_summary")
	_expect(str(arcanist_summary.get("display_name", "")) == "Arcanist", "Next character should be Arcanist")
	_expect(player.max_health == 5, "Arcanist should apply lower health")
	_expect(player.max_shield == 4, "Arcanist should apply lower armor")
	_expect(player.max_energy == 160, "Arcanist should apply higher energy")
	player.current_energy = 20
	var used_arcanist_skill := player.try_use_skill()
	await get_tree().process_frame
	_expect(used_arcanist_skill, "Arcanist skill should activate without energy cost")
	_expect(player.current_energy == 56, "Arcanist skill should restore energy")
	_expect(player.get_fire_rate_multiplier() > 1.0, "Arcanist skill should temporarily increase fire rate")
	player.call("_tick_timers", 3.2)
	await get_tree().process_frame
	_expect(is_equal_approx(player.get_fire_rate_multiplier(), 1.0), "Arcanist fire-rate boost should expire")

	_expect(bool(main.call("select_previous_character")), "Selecting previous character should succeed in main menu")
	await get_tree().process_frame
	_expect(str(main.call("get_character_selection_summary").get("display_name", "")) == "Warden", "Previous character should return to Warden")

	main.call("start_new_run")
	await get_tree().process_frame
	var locked_summary: Dictionary = main.call("get_character_selection_summary")
	_expect(not bool(main.call("select_next_character")), "Character selection should be locked after run start")
	await get_tree().process_frame
	_expect(str(main.call("get_character_selection_summary").get("display_name", "")) == str(locked_summary.get("display_name", "")), "Run start should preserve selected character")
	var run_summary: Dictionary = main.call("get_run_summary")
	_expect(str(run_summary.get("character", "")) == str(locked_summary.get("display_name", "")), "Run summary should include selected character")

	get_tree().paused = false
	main.queue_free()
	await get_tree().process_frame
	_delete_settings_file()
	_finish()


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
		print("CharacterSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

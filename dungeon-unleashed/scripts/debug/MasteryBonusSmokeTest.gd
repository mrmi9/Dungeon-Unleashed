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

	for _index in range(4):
		var run_main := MAIN_SCENE.instantiate()
		get_tree().root.add_child(run_main)
		await get_tree().process_frame
		run_main.call("start_new_run")
		await get_tree().process_frame
		Events.run_completed.emit()
		await get_tree().process_frame
		get_tree().paused = false
		run_main.queue_free()
		await get_tree().process_frame

	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame

	var hud = main.get_node_or_null("CanvasLayer/HUD")
	var player := main.get_node_or_null("Player") as Player
	_expect(hud != null, "HUD should exist")
	_expect(player != null, "Player should exist")
	if hud == null or player == null:
		_finish()
		return

	var meta: Dictionary = main.call("get_meta_progression_summary")
	var mastery: Dictionary = meta.get("character_mastery_xp", {})
	_expect(int(mastery.get("wanderer", 0)) >= 100, "Four completed runs should reach Wanderer mastery level 3")

	var summary: Dictionary = main.call("get_character_selection_summary")
	var mastery_bonus: Dictionary = summary.get("mastery_bonus", {})
	_expect(str(summary.get("display_name", "")) == "Wanderer", "Default selected character should remain Wanderer")
	_expect(int(summary.get("mastery_level", 0)) == 3, "Wanderer should load as mastery level 3")
	_expect(int(mastery_bonus.get("energy_bonus", 0)) == 1, "Mastery L2 should add one energy")
	_expect(int(mastery_bonus.get("armor_bonus", 0)) == 1, "Mastery L3 should add one armor")
	_expect(player.max_energy == 121, "Wanderer mastery should apply energy bonus to player stats")
	_expect(player.current_energy == 121, "Wanderer mastery should refill bonus energy")
	_expect(player.max_shield == 7, "Wanderer mastery should apply armor bonus to player stats")
	_expect(player.current_shield == 7, "Wanderer mastery should refill bonus armor")
	_expect(str(hud.call("get_character_info_text")).contains("Mastery L3"), "Main menu should show mastery level")
	_expect(str(hud.call("get_character_info_text")).contains("+1 Energy"), "Main menu should show energy mastery bonus")
	_expect(str(hud.call("get_character_info_text")).contains("+1 Armor"), "Main menu should show armor mastery bonus")

	main.call("open_hall_menu")
	await get_tree().process_frame
	var hall_text := str(hud.call("get_hall_summary_text"))
	_expect(hall_text.contains("Wanderer | Unlocked | Mastery L3"), "Hall archive should show Wanderer mastery level")
	_expect(hall_text.contains("Bonus: +1 Armor, +1 Energy") or hall_text.contains("Bonus: +1 Energy, +1 Armor"), "Hall archive should show mastery bonuses")

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
		print("MasteryBonusSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

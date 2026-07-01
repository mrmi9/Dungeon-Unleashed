extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const SETTINGS_FILE := "settings.cfg"
const SETTINGS_PATH := "user://settings.cfg"
const SHARP_ROUNDS := preload("res://resources/relics/sharp_rounds.tres")

var _failures: Array[String] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_run")


func _run() -> void:
	_delete_settings_file()

	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	main.call("start_new_run")
	await get_tree().process_frame

	var hud = main.get_node_or_null("CanvasLayer/HUD")
	var player := main.get_node_or_null("Player") as Player
	var relic_system := main.get_node_or_null("RelicSystem")
	_expect(hud != null, "HUD should exist")
	_expect(player != null, "Player should exist")
	_expect(relic_system != null, "RelicSystem should exist")
	if hud == null or player == null or relic_system == null:
		_finish()
		return

	main.call("_grant_gold", 15)
	relic_system.call("obtain_relic", SHARP_ROUNDS)
	Events.projectile_critical_hit.emit(null, player, 4)
	player.current_health = maxi(player.max_health - 2, 1)
	player.health_changed.emit(player.current_health, player.max_health)
	player.call("heal", 2)
	player.call("add_shield", 2)
	player.set("_invulnerability_timer", 0.0)
	player.call("take_damage", 3, null)
	_emit_enemy_died(main)
	_emit_room_cleared(main)
	Events.reward_collected.emit(main, player)
	Events.shop_item_purchased.emit(main, player, 7, "Heal")
	Events.chest_opened.emit(main, player, "normal")
	Events.boss_died.emit(null)
	await get_tree().process_frame

	Events.run_completed.emit()
	await get_tree().process_frame

	var summary: Dictionary = main.call("get_run_summary")
	var history: Dictionary = main.call("get_history_summary")
	_expect(str(main.call("get_run_state_name")) == "Victory", "Run completion should enter victory state")
	_expect(int(summary.get("kills", 0)) == 1, "Run summary should track kills")
	_expect(int(summary.get("rooms_cleared", 0)) == 1, "Run summary should track rooms cleared")
	_expect(int(summary.get("gold_earned", 0)) >= 18, "Run summary should track earned gold")
	_expect(int(summary.get("gold_spent", 0)) == 7, "Run summary should track spent gold")
	_expect(int(summary.get("shop_purchases", 0)) == 1, "Run summary should track shop purchases")
	_expect(int(summary.get("chests_opened", 0)) == 1, "Run summary should track chests opened")
	_expect(int(summary.get("rewards_collected", 0)) == 1, "Run summary should track rewards collected")
	_expect(int(summary.get("damage_taken", 0)) == 1, "Run summary should track damage taken")
	_expect(int(summary.get("critical_hits", 0)) == 1, "Run summary should track critical hits")
	_expect(int(summary.get("healing_received", 0)) == 2, "Run summary should track healing received")
	_expect(int(summary.get("shield_absorbed", 0)) == 2, "Run summary should track shield absorption")
	_expect(summary.get("boss_defeated", false) == true, "Run summary should track boss defeat")
	_expect(str(summary.get("weapon", "")) == "Basic Pistol", "Run summary should include final weapon")
	_expect(_array_has(summary.get("relic_names", []), "Sharp Rounds"), "Run summary should include relic names")
	_expect(int(history.get("runs", 0)) == 1, "History should persist total runs")
	_expect(int(history.get("victories", 0)) == 1, "History should persist victories")
	_expect(int(history.get("best_kills", 0)) == 1, "History should persist best kills")

	var result_text := str(hud.call("get_result_summary_text"))
	_expect(result_text.contains("Weapon:"), "Result panel should show weapon details")
	_expect(result_text.contains("Relics:"), "Result panel should show relic details")
	_expect(result_text.contains("Combat:"), "Result panel should show combat details")
	_expect(result_text.contains("Crits 1"), "Result panel should show critical hit count")
	_expect(result_text.contains("Healing 2"), "Result panel should show healing received")
	_expect(result_text.contains("Shield Blocked 2"), "Result panel should show shield absorption")
	_expect(result_text.contains("Record:"), "Result panel should show history record")
	_expect(result_text.contains("Sharp Rounds"), "Result panel should show collected relic name")
	_expect(int(hud.call("get_result_section_count")) == 6, "Result panel should expose six grouped sections")
	_expect(str(hud.call("get_result_section_text", "Overview")).contains("Rooms 1"), "Overview result section should show room progress")
	_expect(str(hud.call("get_result_section_text", "Build")).contains("Sharp Rounds"), "Build result section should show relic names")
	_expect(str(hud.call("get_result_section_text", "Combat")).contains("Shield Blocked 2"), "Combat result section should show shield absorption")
	_expect(str(hud.call("get_result_section_text", "Loot")).contains("Shop Buys 1"), "Loot result section should show shop purchases")
	_expect(str(hud.call("get_result_section_text", "Record")).contains("Wins 1"), "Record result section should show saved wins")

	get_tree().paused = false
	main.queue_free()
	await get_tree().process_frame

	var reloaded_main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(reloaded_main)
	await get_tree().process_frame
	var reloaded_history: Dictionary = reloaded_main.call("get_history_summary")
	_expect(int(reloaded_history.get("runs", 0)) == 1, "Reloaded Main should read saved total runs")
	_expect(int(reloaded_history.get("victories", 0)) == 1, "Reloaded Main should read saved victories")

	get_tree().paused = false
	reloaded_main.queue_free()
	await get_tree().process_frame
	_delete_settings_file()
	_finish()


func _emit_enemy_died(parent: Node) -> void:
	var enemy := Node.new()
	parent.add_child(enemy)
	Events.enemy_died.emit(enemy)
	enemy.queue_free()


func _emit_room_cleared(parent: Node) -> void:
	var room := Node.new()
	parent.add_child(room)
	Events.room_cleared.emit(room)
	room.queue_free()


func _array_has(values, expected: String) -> bool:
	if not values is Array:
		return false
	for value in values:
		if str(value) == expected:
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
		print("RunSummarySmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

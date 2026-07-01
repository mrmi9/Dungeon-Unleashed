extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")

var _failures: Array[String] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_run")


func _run() -> void:
	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)

	await get_tree().process_frame
	var hud = main.get_node_or_null("CanvasLayer/HUD")
	var player := main.get_node_or_null("Player") as Player
	_expect(hud != null, "HUD should exist")
	_expect(player != null, "Player should exist")
	_expect(main.has_method("get_run_state_name") and str(main.call("get_run_state_name")) == "Main Menu", "Main scene should start in main menu state")
	_expect(get_tree().paused, "Tree should be paused while main menu is open")
	if hud != null and hud.has_method("is_main_menu_visible"):
		_expect(bool(hud.call("is_main_menu_visible")), "HUD should show main menu on startup")
	var controller := main.get_node_or_null("DungeonController")
	_expect(controller != null and controller.has_method("get_generation_seed"), "Main scene should expose active dungeon seed through DungeonController")
	_expect(main.has_method("apply_dungeon_seed_text"), "Main should allow seed entry from main menu")
	_expect(main.has_method("randomize_dungeon_seed"), "Main should allow returning to random dungeon seed")
	_expect(main.has_method("start_new_run_from_menu"), "Main should allow starting with entered dungeon seed")
	if controller != null and hud != null:
		var applied := bool(main.call("apply_dungeon_seed_text", "13579"))
		await get_tree().process_frame
		_expect(applied, "Applying a valid menu seed should succeed")
		_expect(int(controller.call("get_generation_seed")) == 13579, "Applying a menu seed should regenerate the dungeon with that seed")
		if hud.has_method("get_seed_input_text"):
			_expect(str(hud.call("get_seed_input_text")) == "13579", "HUD seed input should keep the configured fixed seed")
		if hud.has_method("get_seed_status_text"):
			_expect(str(hud.call("get_seed_status_text")).contains("Fixed"), "HUD seed status should show fixed mode")
		var invalid_seed := bool(main.call("apply_dungeon_seed_text", "not-a-seed"))
		await get_tree().process_frame
		_expect(not invalid_seed, "Invalid menu seed text should be rejected")
		_expect(int(controller.call("get_generation_seed")) == 13579, "Invalid seed should not change the active dungeon")
		main.call("randomize_dungeon_seed")
		await get_tree().process_frame
		_expect(int(controller.call("get_generation_seed")) > 0, "Random seed button should regenerate to a valid active seed")
		if hud.has_method("get_seed_input_text"):
			_expect(str(hud.call("get_seed_input_text")).is_empty(), "Random seed mode should clear the seed input")
		if hud.has_method("get_seed_status_text"):
			_expect(str(hud.call("get_seed_status_text")).contains("Random"), "HUD seed status should show random mode")
	if hud != null and hud.has_method("get_input_hint_text"):
		var input_hint := str(hud.call("get_input_hint_text"))
		var input_bindings: Dictionary = main.call("get_input_bindings_summary")
		var move_up: Dictionary = input_bindings.get("move_up", {})
		var move_left: Dictionary = input_bindings.get("move_left", {})
		var move_down: Dictionary = input_bindings.get("move_down", {})
		var move_right: Dictionary = input_bindings.get("move_right", {})
		var interact: Dictionary = input_bindings.get("interact", {})
		var pause: Dictionary = input_bindings.get("pause", {})
		_expect(input_hint.contains("Move"), "HUD should show movement input hint")
		_expect(input_hint.contains(str(move_up.get("label", ""))), "HUD should show move up binding")
		_expect(input_hint.contains(str(move_left.get("label", ""))), "HUD should show move left binding")
		_expect(input_hint.contains(str(move_down.get("label", ""))), "HUD should show move down binding")
		_expect(input_hint.contains(str(move_right.get("label", ""))), "HUD should show move right binding")
		_expect(input_hint.contains("Interact") and input_hint.contains(str(interact.get("label", ""))), "HUD should show interaction input hint")
		_expect(input_hint.contains("Pause") and input_hint.contains(str(pause.get("label", ""))), "HUD should show pause input hint")

	main.call("start_new_run_from_menu", "24680")
	await get_tree().process_frame
	_expect(str(main.call("get_run_state_name")) == "Running", "start_new_run should enter running state")
	_expect(not get_tree().paused, "Starting a run should unpause the tree")
	if controller != null:
		_expect(int(controller.call("get_generation_seed")) == 24680, "Starting from the menu should use the typed seed")
	if hud != null and hud.has_method("is_main_menu_visible"):
		_expect(not bool(hud.call("is_main_menu_visible")), "Starting a run should hide main menu")

	main.call("pause_run")
	await get_tree().process_frame
	_expect(str(main.call("get_run_state_name")) == "Paused", "pause_run should enter paused state")
	_expect(get_tree().paused, "pause_run should pause the tree")
	if hud != null and hud.has_method("is_pause_menu_visible"):
		_expect(bool(hud.call("is_pause_menu_visible")), "pause_run should show pause menu")

	main.call("resume_run")
	await get_tree().process_frame
	_expect(str(main.call("get_run_state_name")) == "Running", "resume_run should return to running state")
	_expect(not get_tree().paused, "resume_run should unpause the tree")
	if hud != null and hud.has_method("is_pause_menu_visible"):
		_expect(not bool(hud.call("is_pause_menu_visible")), "resume_run should hide pause menu")

	if player != null:
		player.set("_invulnerability_timer", 0.0)
		player.call("take_damage", 9999, null)
	await get_tree().process_frame
	_expect(str(main.call("get_run_state_name")) == "Defeated", "Player death should enter defeated state")
	_expect(get_tree().paused, "Player death should pause the tree")
	var defeat_summary: Dictionary = main.call("get_run_summary")
	_expect(int(defeat_summary.get("dungeon_seed", 0)) == 24680, "Run summary should include the active dungeon seed")
	if hud != null and hud.has_method("is_result_visible"):
		_expect(bool(hud.call("is_result_visible")), "Player death should show result panel")
		_expect(str(hud.call("get_result_title_text")) == "Run Failed", "Death result title should be Run Failed")

	get_tree().paused = false
	main.queue_free()
	await get_tree().process_frame

	var victory_main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(victory_main)
	await get_tree().process_frame
	var victory_hud = victory_main.get_node_or_null("CanvasLayer/HUD")
	victory_main.call("start_new_run")
	await get_tree().process_frame
	Events.run_completed.emit()
	await get_tree().process_frame
	_expect(str(victory_main.call("get_run_state_name")) == "Victory", "run_completed should enter victory state")
	_expect(get_tree().paused, "run_completed should pause the tree")
	if victory_hud != null and victory_hud.has_method("is_result_visible"):
		_expect(bool(victory_hud.call("is_result_visible")), "Victory should show result panel")
		_expect(str(victory_hud.call("get_result_title_text")) == "Run Complete", "Victory result title should be Run Complete")

	_finish()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	get_tree().paused = false
	if _failures.is_empty():
		print("MenuFlowSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

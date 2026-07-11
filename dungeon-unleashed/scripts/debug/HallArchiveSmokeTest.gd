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
	_expect(main.has_method("get_hall_summary"), "Main should expose hall summary")
	_expect(main.has_method("get_meta_progression_summary"), "Main should expose meta progression summary")
	_expect(main.has_method("open_hall_menu"), "Main should expose hall menu entry")
	_expect(main.has_method("close_hall_menu"), "Main should expose hall menu close")
	if hud == null:
		_finish()
		return

	var summary: Dictionary = main.call("get_hall_summary")
	var counts: Dictionary = summary.get("counts", {})
	_expect(int(counts.get("characters", 0)) >= 6, "Hall summary should include expanded character pool")
	_expect(int(counts.get("weapons", 0)) >= 40, "Hall summary should include the v1-target 40-weapon pool")
	_expect(int(counts.get("relics", 0)) >= 45, "Hall summary should include the v1-target 45-relic pool")
	_expect(int(counts.get("talents", 0)) >= 3, "Hall summary should include talents")
	_expect(int(counts.get("blessings", 0)) >= 3, "Hall summary should include blessings")
	_expect(int(counts.get("statues", 0)) >= 3, "Hall summary should include statues")
	var meta: Dictionary = main.call("get_meta_progression_summary")
	_expect(int(meta.get("currency", -1)) == 0, "Fresh meta currency should start at zero")
	_expect(int(meta.get("total_currency_earned", -1)) == 0, "Fresh lifetime meta currency should start at zero")
	_expect(int(meta.get("training_badge_count", -1)) == 0, "Fresh training badge count should start at zero")
	_expect(int(meta.get("training_badge_total", -1)) == 4, "Training badge total should match drill count")

	main.call("open_hall_menu")
	await get_tree().process_frame
	_expect(bool(hud.call("is_hall_visible")), "Opening hall menu should show archive panel")
	_expect(not bool(hud.call("is_main_menu_visible")), "Opening hall menu should hide main menu panel")
	var hall_text := str(hud.call("get_hall_summary_text"))
	_expect(hall_text.contains("Data Shards: 0"), "Hall archive should show empty meta currency")
	_expect(hall_text.contains("Records"), "Hall archive should show record section")
	_expect(hall_text.contains("Training Badges (0/4)"), "Hall archive should show empty training badges")
	_expect(hall_text.contains("Basics | Badge: None"), "Hall archive should list Basics badge slot")
	_expect(hall_text.contains("Basics | Badge: None [--]"), "Hall archive should show locked badge token")
	_expect(hall_text.contains("Wanderer"), "Hall archive should list characters")
	_expect(hall_text.contains("Rift Runner"), "Hall archive should list unlockable characters")
	_expect(hall_text.contains("Emberwright"), "Hall archive should list Emberwright")
	_expect(hall_text.contains("Field Medic"), "Hall archive should list Field Medic")
	_expect(hall_text.contains("Locked 10 Data Shards"), "Hall archive should show locked character cost")
	_expect(hall_text.contains("Mastery L1 (0 XP)"), "Hall archive should show character mastery")
	_expect(hall_text.contains("Basic Pistol"), "Hall archive should list weapons")
	_expect(hall_text.contains("Coil Carbine"), "Hall archive should list expanded weapon pool")
	_expect(hall_text.contains("Pulse Needler"), "Hall archive should list second-pass weapon additions")
	_expect(hall_text.contains("Ember Sprayer"), "Hall archive should list status weapon additions")
	_expect(hall_text.contains("Guard Cleaver"), "Hall archive should list projectile-blocking weapon additions")
	_expect(hall_text.contains("Coil Bow"), "Hall archive should list charge weapon additions")
	_expect(hall_text.contains("Snare Beacon"), "Hall archive should list deployable weapon additions")
	_expect(hall_text.contains("Deploy Field"), "Hall archive should identify field deployables")
	_expect(hall_text.contains("Deploy Mine"), "Hall archive should identify mine deployables")
	_expect(hall_text.contains("Deploy Sentry"), "Hall archive should identify sentry deployables")
	_expect(hall_text.contains("Compass Needle"), "Hall archive should list homing weapon additions")
	_expect(hall_text.contains("Homing 210deg/s 300r"), "Hall archive should expose homing turn and acquisition stats")
	_expect(hall_text.contains("Relay Arc"), "Hall archive should list chain weapon additions")
	_expect(hall_text.contains("Chain 2x 150r 65%"), "Hall archive should expose chain target, radius, and damage stats")
	_expect(hall_text.contains("Sharp Rounds"), "Hall archive should list relics")
	_expect(hall_text.contains("Momentum Coil"), "Hall archive should list expanded relic pool")
	_expect(hall_text.contains("Echo Chamber"), "Hall archive should list second-pass relic additions")
	_expect(hall_text.contains("Volatile Oil"), "Hall archive should list status relic additions")
	_expect(hall_text.contains("Parry Grip"), "Hall archive should list projectile-blocking relic additions")
	_expect(hall_text.contains("Draw Weight"), "Hall archive should list charge relic additions")
	_expect(hall_text.contains("Anchor Spool"), "Hall archive should list deployable relic additions")
	_expect(hall_text.contains("Tracking Vane"), "Hall archive should list homing relic additions")
	_expect(hall_text.contains("Forked Bus"), "Hall archive should list chain relic additions")
	_expect(hall_text.contains("Steady Hands"), "Hall archive should list talents")
	_expect(hall_text.contains("Deep Cell"), "Hall archive should list blessings")
	_expect(hall_text.contains("Bulwark Idol"), "Hall archive should list statues")
	_expect(hall_text.contains("Runs 0"), "Hall archive should show initial run history")
	_expect(hall_text.contains("Best Guard Blocks 0"), "Hall archive should show empty projectile block record")

	main.call("close_hall_menu")
	await get_tree().process_frame
	_expect(not bool(hud.call("is_hall_visible")), "Closing hall menu should hide archive panel")
	_expect(bool(hud.call("is_main_menu_visible")), "Closing hall menu should return to main menu")

	main.call("select_next_character")
	main.call("select_next_character")
	main.call("select_next_character")
	await get_tree().process_frame
	var locked_summary: Dictionary = main.call("get_character_selection_summary")
	_expect(str(locked_summary.get("display_name", "")) == "Rift Runner", "Fourth character should be Rift Runner")
	_expect(not bool(locked_summary.get("unlocked", true)), "Rift Runner should start locked")
	_expect(int(locked_summary.get("unlock_cost", 0)) == 10, "Rift Runner should expose unlock cost")
	_expect(str(hud.call("get_character_unlock_button_text")).contains("Unlock: 10 Data Shards"), "HUD should show Rift Runner unlock cost")
	_expect(bool(hud.call("is_character_unlock_button_disabled")), "Unlock button should be disabled without permanent currency")
	_expect(bool(hud.call("is_start_button_disabled")), "Start button should be disabled while selected character is locked")
	main.call("start_new_run")
	await get_tree().process_frame
	_expect(str(main.call("get_run_state_name")) == "Main Menu", "Locked character should not start a run")
	for _character_index in range(6):
		if str(main.call("get_character_selection_summary").get("display_name", "")) == "Wanderer":
			break
		main.call("select_next_character")
		await get_tree().process_frame
	_expect(str(main.call("get_character_selection_summary").get("display_name", "")) == "Wanderer", "Character selection should wrap back to Wanderer")
	_expect(not bool(hud.call("is_start_button_disabled")), "Start button should re-enable after selecting unlocked character")

	main.call("start_new_run")
	await get_tree().process_frame
	var player := main.get_node_or_null("Player") as Player
	if player != null:
		player.add_gold(50)
		Events.player_projectile_blocked.emit(player, null, 4, player.global_position + Vector2(64, 0))
	Events.run_completed.emit()
	await get_tree().process_frame
	var meta_after_run: Dictionary = main.call("get_meta_progression_summary")
	_expect(int(meta_after_run.get("currency", 0)) > 0, "Completing a run should award permanent currency")
	_expect(int(meta_after_run.get("total_currency_earned", 0)) == int(meta_after_run.get("currency", 0)), "Lifetime currency should track earned permanent currency")
	var mastery_after_run: Dictionary = meta_after_run.get("character_mastery_xp", {})
	_expect(int(mastery_after_run.get("wanderer", 0)) > 0, "Completing a run should award selected character mastery")
	_expect(player != null and player.current_gold == 50, "Permanent currency should not consume or mirror in-run gold")
	get_tree().paused = false
	main.queue_free()
	await get_tree().process_frame

	var reloaded_main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(reloaded_main)
	await get_tree().process_frame
	var reloaded_hud = reloaded_main.get_node_or_null("CanvasLayer/HUD")
	reloaded_main.call("open_hall_menu")
	await get_tree().process_frame
	_expect(reloaded_hud != null and bool(reloaded_hud.call("is_hall_visible")), "Reloaded main should show hall archive")
	if reloaded_hud != null:
		var reloaded_meta: Dictionary = reloaded_main.call("get_meta_progression_summary")
		var reloaded_mastery: Dictionary = reloaded_meta.get("character_mastery_xp", {})
		_expect(int(reloaded_meta.get("currency", 0)) > 0, "Reloaded Main should read saved permanent currency")
		_expect(int(reloaded_mastery.get("wanderer", 0)) > 0, "Reloaded Main should read saved character mastery")
		var reloaded_text := str(reloaded_hud.call("get_hall_summary_text"))
		_expect(reloaded_text.contains("Runs 1"), "Hall archive should read saved total runs")
		_expect(reloaded_text.contains("Wins 1"), "Hall archive should read saved victories")
		_expect(reloaded_text.contains("Best Guard Blocks 4"), "Hall archive should read saved projectile block record")
		_expect(reloaded_text.contains("Data Shards:"), "Hall archive should show saved permanent currency")
		_expect(reloaded_text.contains("Mastery L1"), "Hall archive should show saved mastery level")
		_expect(reloaded_text.contains("Rift Runner"), "Reloaded hall archive should keep Rift Runner listed")

	reloaded_main.call("close_hall_menu")
	await get_tree().process_frame
	reloaded_main.call("select_next_character")
	reloaded_main.call("select_next_character")
	reloaded_main.call("select_next_character")
	await get_tree().process_frame
	var unlockable_summary: Dictionary = reloaded_main.call("get_character_selection_summary")
	_expect(str(unlockable_summary.get("display_name", "")) == "Rift Runner", "Reloaded main should select Rift Runner")
	_expect(not bool(unlockable_summary.get("unlocked", true)), "Rift Runner should remain locked before purchase")
	_expect(reloaded_hud != null and not bool(reloaded_hud.call("is_character_unlock_button_disabled")), "Unlock button should enable when currency is sufficient")
	var meta_before_unlock: Dictionary = reloaded_main.call("get_meta_progression_summary")
	var currency_before_unlock := int(meta_before_unlock.get("currency", 0))
	_expect(bool(reloaded_main.call("unlock_selected_character")), "Rift Runner should unlock with enough permanent currency")
	await get_tree().process_frame
	var unlocked_meta: Dictionary = reloaded_main.call("get_meta_progression_summary")
	var unlocked_ids: Dictionary = unlocked_meta.get("unlocked_character_ids", {})
	_expect(int(unlocked_meta.get("currency", 0)) == currency_before_unlock - 10, "Unlock should spend permanent currency")
	_expect(bool(unlocked_ids.get("rift_runner", false)), "Unlocked character should persist in meta summary")
	var unlocked_summary: Dictionary = reloaded_main.call("get_character_selection_summary")
	_expect(bool(unlocked_summary.get("unlocked", false)), "Character summary should mark Rift Runner unlocked")
	_expect(reloaded_hud != null and str(reloaded_hud.call("get_character_unlock_button_text")) == "Unlocked", "HUD should mark Rift Runner unlocked")
	_expect(reloaded_hud != null and not bool(reloaded_hud.call("is_start_button_disabled")), "Start button should enable after unlock")
	reloaded_main.call("open_hall_menu")
	await get_tree().process_frame
	if reloaded_hud != null:
		var unlocked_hall_text := str(reloaded_hud.call("get_hall_summary_text"))
		_expect(unlocked_hall_text.contains("Rift Runner | Unlocked"), "Hall archive should show unlocked Rift Runner")
	reloaded_main.call("close_hall_menu")
	await get_tree().process_frame
	reloaded_main.call("start_new_run")
	await get_tree().process_frame
	_expect(str(reloaded_main.call("get_run_state_name")) == "Running", "Unlocked Rift Runner should be able to start a run")

	get_tree().paused = false
	reloaded_main.queue_free()
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
		print("HallArchiveSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

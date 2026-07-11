extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const TRAINING_LAYOUT := preload("res://resources/room_layouts/training.tres")
const SETTINGS_FILE := "settings.cfg"
const SETTINGS_PATH := "user://settings.cfg"
const TRAINING_TARGET_COUNT := 3
const TRAINING_PLAYER_POSITION := Vector2(-300.0, 0.0)

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
	_expect(main.has_method("start_training_room"), "Main should expose training room entry")
	_expect(str(main.call("get_run_state_name")) == "Main Menu", "Main scene should start in main menu")
	_expect(TRAINING_LAYOUT.get_obstacle_count() >= 4, "Training layout should include range obstacles")
	_expect(TRAINING_LAYOUT.spawn_positions.size() >= 4, "Training layout should keep fallback spawn markers")
	if hud == null:
		_finish()
		return

	_expect(str(hud.call("get_training_button_text")) == "Training Room", "HUD should expose Training Room button")
	_expect(not bool(hud.call("is_training_button_disabled")), "Training Room button should be enabled for unlocked character")

	main.call("select_next_character")
	main.call("select_next_character")
	main.call("select_next_character")
	await get_tree().process_frame
	_expect(str(main.call("get_character_selection_summary").get("display_name", "")) == "Rift Runner", "Smoke test should reach locked Rift Runner")
	_expect(bool(hud.call("is_training_button_disabled")), "Training Room button should be disabled for locked character")
	main.call("start_training_room")
	await get_tree().process_frame
	_expect(str(main.call("get_run_state_name")) == "Main Menu", "Locked character should not enter training")

	for _character_index in range(6):
		if str(main.call("get_character_selection_summary").get("display_name", "")) == "Wanderer":
			break
		main.call("select_next_character")
		await get_tree().process_frame
	_expect(str(main.call("get_character_selection_summary").get("display_name", "")) == "Wanderer", "Selection should wrap back to unlocked Wanderer")
	_expect(not bool(hud.call("is_training_button_disabled")), "Training Room button should re-enable for unlocked character")

	main.call("start_training_room")
	for _index in range(8):
		await get_tree().process_frame
	_expect(str(main.call("get_run_state_name")) == "Training", "Training room should enter Training state")
	_expect(not get_tree().paused, "Training room should unpause the tree")
	_expect(not bool(hud.call("is_main_menu_visible")), "Training room should hide main menu")
	_expect(bool(hud.call("is_training_panel_visible")), "Training room should show training stats panel")
	_expect(str(hud.call("get_training_drill_text")) == "Basics", "Training should start on Basics drill")
	_expect(str(hud.call("get_training_guide_text")).contains("close"), "Training should show Basics guidance")
	_expect(str(hud.call("get_training_goal_text")).contains("Goal: Hit all targets 0/3"), "Basics should show target goal")
	_expect(str(hud.call("get_training_rating_text")).contains("Practice"), "Basics should start with Practice rating")
	_expect(str(hud.call("get_training_badge_text")).contains("Badge: None [--]"), "Basics should start with locked badge token")
	_expect(str(hud.call("get_training_stats_text")).contains("Targets 3"), "Training stats should show target count")
	_expect(str(hud.call("get_training_stats_text")).contains("Types Standard 3"), "Basics stats should show standard targets")
	_expect(str(hud.call("get_training_stats_text")).contains("Damage 0"), "Training stats should start at zero")
	_expect(str(hud.call("get_training_aim_assist_text")).contains("Aim Assist: Off 35%"), "Training should show default aim assist state")
	_expect(str(hud.call("get_training_aim_assist_text")).contains("Band Off"), "Training should show default aim assist strength band")
	_expect(str(hud.call("get_training_aim_assist_text")).contains("Targets Training"), "Training should show training aim target layer")
	_expect(str(hud.call("get_training_aim_assist_active_preset_text")) == "Off", "Training should highlight default aim assist preset")
	var default_aim_summary: Dictionary = main.call("get_training_summary")
	_expect(str(default_aim_summary.get("aim_assist_strength_band", "")) == "Off", "Training summary should expose default aim assist band")
	_expect(main.has_method("apply_aim_assist_preset"), "Main should expose an aim assist preset apply method")

	hud.call("choose_training_aim_assist_preset_for_test", "light")
	await get_tree().process_frame
	_expect(str(hud.call("get_training_aim_assist_text")).contains("Aim Assist: On 35%"), "Training preset should apply Light aim assist strength")
	_expect(str(hud.call("get_training_aim_assist_text")).contains("Band Light"), "Training preset should update aim assist band")
	_expect(str(hud.call("get_training_aim_assist_active_preset_text")) == "Light", "Training should highlight the Light aim assist preset")
	var light_aim_summary: Dictionary = main.call("get_training_summary")
	_expect(str(light_aim_summary.get("aim_assist_strength_band", "")) == "Light", "Training summary should expose Light aim assist band")

	main.call("apply_settings", 1.0, 1.0, 0.8, false, 0, true, 0.7, 1.0, 1.0, 1.0, 1.0)
	await get_tree().process_frame
	_expect(str(hud.call("get_training_aim_assist_text")).contains("Aim Assist: On 70%"), "Training should refresh aim assist state after settings change")
	_expect(str(hud.call("get_training_aim_assist_text")).contains("Band Strong"), "Training should refresh aim assist strength band after settings change")
	_expect(str(hud.call("get_training_aim_assist_text")).contains("Targets Training"), "Training settings refresh should keep training aim target layer")
	_expect(str(hud.call("get_training_aim_assist_active_preset_text")) == "Strong", "Training should highlight the Strong aim assist preset after settings change")
	var updated_aim_summary: Dictionary = main.call("get_training_summary")
	_expect(str(updated_aim_summary.get("aim_assist_strength_band", "")) == "Strong", "Training summary should expose updated aim assist band")

	var player := main.get_node_or_null("Player") as Node2D
	if player != null:
		_expect(player.global_position.distance_to(TRAINING_PLAYER_POSITION) < 0.5, "Training should place player at the firing line")
		if player.has_method("get_aim_assist_candidate_groups_for_test"):
			var training_aim_groups: PackedStringArray = player.call("get_aim_assist_candidate_groups_for_test")
			_expect(training_aim_groups.has("training_dummy"), "Training should configure aim assist to training dummy targets")
			_expect(not training_aim_groups.has("enemies"), "Training aim assist should not use the normal enemy target group")
	var enemies_seen := _alive_enemy_count()
	_expect(enemies_seen >= TRAINING_TARGET_COUNT, "Training room should spawn practice enemies")
	_expect(_training_dummy_count() == TRAINING_TARGET_COUNT, "Training room should spawn three training dummies")
	_expect(_training_dummy_names().has("Close Target"), "Basics drill should spawn close target")
	var basics_types := _training_dummy_type_counts()
	_expect(int(basics_types.get("standard", 0)) == TRAINING_TARGET_COUNT, "Basics drill should spawn standard target types")
	_expect(bool(main.call("cycle_training_drill")), "Training drill cycle should succeed while in Training state")
	await get_tree().process_frame
	_expect(str(hud.call("get_training_drill_text")) == "Movement", "Training drill cycle should advance to Movement")
	_expect(str(hud.call("get_training_guide_text")).contains("staggered"), "Movement drill should show movement guidance")
	_expect(str(hud.call("get_training_goal_text")).contains("Tag both mobile targets 0/2"), "Movement should show mobile target goal")
	_expect(str(hud.call("get_training_stats_text")).contains("Mobile 2"), "Movement stats should show mobile targets")
	_expect(str(hud.call("get_training_stats_text")).contains("Armored 1"), "Movement stats should show armored target")
	var movement_summary: Dictionary = main.call("get_training_summary")
	_expect(str(movement_summary.get("drill_id", "")) == "movement", "Training summary should expose active drill id")
	_expect(str(movement_summary.get("target_types", "")).contains("Mobile 2"), "Training summary should expose movement target types")
	_expect(int(movement_summary.get("hits", -1)) == 0, "Training drill cycle should reset hit count")
	_expect(_training_dummy_count() == TRAINING_TARGET_COUNT, "Training drill cycle should respawn three training dummies")
	_expect(_training_dummy_names().has("Left Strafe"), "Movement drill should spawn movement target names")
	var movement_types := _training_dummy_type_counts()
	_expect(int(movement_types.get("mobile", 0)) == 2, "Movement drill should spawn two mobile targets")
	_expect(int(movement_types.get("armored", 0)) == 1, "Movement drill should spawn one armored target")
	var dummy := _get_training_dummy_by_type("armored")
	_expect(dummy != null, "Movement drill should spawn an armored training dummy")
	if dummy != null:
		dummy.call("apply_damage", 8, null, Vector2.ZERO, 0.0)
		Events.projectile_hit.emit(null, dummy, 8)
		await get_tree().process_frame
		var training_summary: Dictionary = main.call("get_training_summary")
		_expect(int(training_summary.get("targets", 0)) == TRAINING_TARGET_COUNT, "Training summary should count available targets")
		_expect(int(training_summary.get("hits", 0)) == 1, "Training summary should count dummy hits")
		_expect(int(training_summary.get("damage", 0)) == 4, "Training summary should count armored effective damage")
		_expect(int(training_summary.get("best_hit", 0)) == 4, "Training summary should record armored effective best hit")
		_expect(int(training_summary.get("goal_progress", -1)) == 0, "Armored hit should not advance mobile target goal")
		_expect(not bool(training_summary.get("goal_complete", true)), "Movement goal should remain incomplete after armored hit")
		_expect(str(training_summary.get("rating_rank", "")) == "practice", "Incomplete Movement goal should keep Practice rating")
		_expect(int(dummy.call("get_last_applied_damage")) == 4, "Armored dummy should expose effective damage")
		_expect(int(dummy.call("get_mitigated_damage")) == 4, "Armored dummy should expose mitigated damage")
		_expect(str(hud.call("get_training_rating_text")).contains("Practice"), "HUD should keep Practice rating before goal completion")
		_expect(str(hud.call("get_training_stats_text")).contains("Damage 4"), "HUD should show armored effective damage")

	_expect(bool(main.call("cycle_training_drill")), "Training drill cycle should advance to Burst")
	await get_tree().process_frame
	_expect(str(hud.call("get_training_drill_text")) == "Burst", "Training drill cycle should advance to Burst drill")
	_expect(str(hud.call("get_training_goal_text")).contains("Build a Burst x2 chain 0/2"), "Burst should show chain goal")
	_expect(str(hud.call("get_training_stats_text")).contains("Burst 2"), "Burst stats should show burst targets")
	_expect(str(hud.call("get_training_stats_text")).contains("Armored 1"), "Burst stats should show armored target")
	var burst_summary: Dictionary = main.call("get_training_summary")
	_expect(str(burst_summary.get("drill_id", "")) == "burst", "Training summary should expose Burst drill id")
	_expect(str(burst_summary.get("target_types", "")).contains("Burst 2"), "Training summary should expose burst target types")
	var burst_types := _training_dummy_type_counts()
	_expect(int(burst_types.get("burst", 0)) == 2, "Burst drill should spawn two burst targets")
	_expect(int(burst_types.get("armored", 0)) == 1, "Burst drill should spawn one armored target")
	var burst_dummy := _get_training_dummy_by_type("burst")
	_expect(burst_dummy != null, "Burst drill should spawn a burst training dummy")
	if burst_dummy != null:
		burst_dummy.call("apply_damage", 5, null, Vector2.ZERO, 0.0)
		Events.projectile_hit.emit(null, burst_dummy, 5)
		burst_dummy.call("apply_damage", 5, null, Vector2.ZERO, 0.0)
		Events.projectile_hit.emit(null, burst_dummy, 5)
		await get_tree().process_frame
		var burst_hit_summary: Dictionary = main.call("get_training_summary")
		_expect(int(burst_hit_summary.get("best_burst_chain", 0)) == 2, "Burst drill should record quick hit chain")
		_expect(int(burst_hit_summary.get("goal_progress", 0)) == 2, "Burst goal should track best chain")
		_expect(bool(burst_hit_summary.get("goal_complete", false)), "Burst goal should complete at x2 chain")
		_expect(str(burst_hit_summary.get("rating_rank", "")) == "clean", "Burst completion with required hits should earn Clean rating")
		_expect(str(burst_hit_summary.get("best_rating_rank", "")) == "clean", "Burst completion should save Clean as the best training badge")
		_expect(int(burst_dummy.call("get_best_burst_chain")) == 2, "Burst dummy should expose best chain")
		_expect(str(hud.call("get_training_goal_text")).contains("Complete: Build a Burst x2 chain 2/2"), "HUD should show completed Burst goal")
		_expect(str(hud.call("get_training_rating_text")).contains("Clean"), "HUD should show Clean rating after efficient Burst completion")
		_expect(str(hud.call("get_training_rating_text")).contains("Best Clean"), "HUD should show saved Clean training badge")
		_expect(str(hud.call("get_training_badge_text")).contains("Badge Unlocked: Clean [CN]"), "HUD should show badge unlock presentation")
		if hud.has_method("is_training_reward_toast_visible_for_test"):
			_expect(bool(hud.call("is_training_reward_toast_visible_for_test")), "HUD should show a training reward toast after badge unlock")
			_expect(str(hud.call("get_training_reward_title_text_for_test")) == "TRAINING BADGE", "Training reward toast should show a badge title")
			_expect(str(hud.call("get_training_reward_body_text_for_test")).contains("Burst | Clean [CN]"), "Training reward toast should show drill rating and badge token")
		_expect(str(hud.call("get_training_stats_text")).contains("Burst x2"), "HUD should show best burst chain")
		var meta_after_badge: Dictionary = main.call("get_meta_progression_summary")
		var training_badges: Dictionary = meta_after_badge.get("training_drill_best_ratings", {})
		_expect(int(meta_after_badge.get("training_badge_count", 0)) == 1, "Training badge count should update after clean completion")
		_expect(str(training_badges.get("burst", "")) == "clean", "Training meta should record Burst Clean badge")
		_expect(int(meta_after_badge.get("currency", 0)) == 0, "Training badge should not grant permanent currency")

	_expect(bool(main.call("cycle_training_drill")), "Training drill cycle should advance to Aim Assist")
	await get_tree().process_frame
	_expect(str(hud.call("get_training_drill_text")) == "Aim Assist", "Training drill cycle should advance to Aim Assist drill")
	_expect(str(hud.call("get_training_guide_text")).contains("offset target"), "Aim Assist drill should show offset guidance")
	_expect(str(hud.call("get_training_goal_text")).contains("Tag both assist targets 0/2"), "Aim Assist should show assist target goal")
	_expect(str(hud.call("get_training_stats_text")).contains("Assist 2"), "Aim Assist stats should show assist targets")
	_expect(str(hud.call("get_training_stats_text")).contains("Standard 1"), "Aim Assist stats should show reference target")
	_expect(str(hud.call("get_training_aim_assist_text")).contains("Band Strong"), "Aim Assist drill should show the current strength band")
	var aim_summary: Dictionary = main.call("get_training_summary")
	_expect(str(aim_summary.get("drill_id", "")) == "aim_assist", "Training summary should expose Aim Assist drill id")
	_expect(str(aim_summary.get("aim_assist_strength_band", "")) == "Strong", "Aim Assist summary should expose the current strength band")
	_expect(str(aim_summary.get("target_types", "")).contains("Assist 2"), "Training summary should expose assist target types")
	_expect(int(aim_summary.get("hits", -1)) == 0, "Aim Assist drill cycle should reset hit count")
	_expect(_training_dummy_count() == TRAINING_TARGET_COUNT, "Aim Assist drill should spawn three training dummies")
	_expect(_training_dummy_names().has("Assist Left"), "Aim Assist drill should spawn left assist target")
	_expect(_training_dummy_names().has("Reference Line"), "Aim Assist drill should spawn reference target")
	var aim_types := _training_dummy_type_counts()
	_expect(int(aim_types.get("assist", 0)) == 2, "Aim Assist drill should spawn two assist targets")
	_expect(int(aim_types.get("standard", 0)) == 1, "Aim Assist drill should spawn one standard target")
	var assist_dummies := _get_training_dummies_by_type("assist")
	_expect(assist_dummies.size() == 2, "Aim Assist drill should expose two assist training dummies")
	if assist_dummies.size() >= 2:
		assist_dummies[0].call("apply_damage", 5, null, Vector2.ZERO, 0.0)
		Events.projectile_hit.emit(null, assist_dummies[0], 5)
		await get_tree().process_frame
		var first_aim_hit_summary: Dictionary = main.call("get_training_summary")
		_expect(int(first_aim_hit_summary.get("goal_progress", 0)) == 1, "Aim Assist goal should advance after first assist target")
		_expect(not bool(first_aim_hit_summary.get("goal_complete", true)), "Aim Assist goal should remain incomplete after one assist target")
		_expect(str(first_aim_hit_summary.get("rating_rank", "")) == "practice", "Incomplete Aim Assist goal should keep Practice rating")
		assist_dummies[1].call("apply_damage", 5, null, Vector2.ZERO, 0.0)
		Events.projectile_hit.emit(null, assist_dummies[1], 5)
		await get_tree().process_frame
		var aim_hit_summary: Dictionary = main.call("get_training_summary")
		_expect(int(aim_hit_summary.get("goal_progress", 0)) == 2, "Aim Assist goal should track both assist targets")
		_expect(bool(aim_hit_summary.get("goal_complete", false)), "Aim Assist goal should complete after both assist targets")
		_expect(str(aim_hit_summary.get("rating_rank", "")) == "clean", "Aim Assist completion with required hits should earn Clean rating")
		_expect(str(aim_hit_summary.get("best_rating_rank", "")) == "clean", "Aim Assist completion should save Clean as the best training badge")
		_expect(str(hud.call("get_training_goal_text")).contains("Complete: Tag both assist targets 2/2"), "HUD should show completed Aim Assist goal")
		_expect(str(hud.call("get_training_rating_text")).contains("Clean"), "HUD should show Clean rating after efficient Aim Assist completion")
		_expect(str(hud.call("get_training_badge_text")).contains("Badge Unlocked: Clean [CN]"), "HUD should show Aim Assist badge unlock presentation")
		if hud.has_method("is_training_reward_toast_visible_for_test"):
			_expect(bool(hud.call("is_training_reward_toast_visible_for_test")), "HUD should show a training reward toast after Aim Assist badge unlock")
			_expect(str(hud.call("get_training_reward_body_text_for_test")).contains("Aim Assist | Clean [CN]"), "Training reward toast should show Aim Assist rating and badge token")
		var meta_after_aim_badge: Dictionary = main.call("get_meta_progression_summary")
		var aim_training_badges: Dictionary = meta_after_aim_badge.get("training_drill_best_ratings", {})
		_expect(int(meta_after_aim_badge.get("training_badge_count", 0)) == 2, "Training badge count should include Burst and Aim Assist")
		_expect(str(aim_training_badges.get("burst", "")) == "clean", "Training meta should keep Burst Clean badge")
		_expect(str(aim_training_badges.get("aim_assist", "")) == "clean", "Training meta should record Aim Assist Clean badge")
		_expect(int(meta_after_aim_badge.get("currency", 0)) == 0, "Aim Assist training badge should not grant permanent currency")

	var history_before: Dictionary = main.call("get_history_summary")
	var meta_before: Dictionary = main.call("get_meta_progression_summary")
	_expect(int(history_before.get("runs", 0)) == 0, "Training should not create a run before completion")
	_expect(int(meta_before.get("currency", 0)) == 0, "Training should not grant permanent currency before completion")

	Events.run_completed.emit()
	await get_tree().process_frame
	_expect(str(main.call("get_run_state_name")) == "Training", "Training should ignore run_completed victory events")
	_expect(not get_tree().paused, "Ignored training completion should not pause the tree")
	var history_after_completion: Dictionary = main.call("get_history_summary")
	var meta_after_completion: Dictionary = main.call("get_meta_progression_summary")
	_expect(int(history_after_completion.get("runs", 0)) == 0, "Training completion should not record history")
	_expect(int(meta_after_completion.get("currency", 0)) == 0, "Training completion should not award permanent currency")

	main.call("pause_run")
	await get_tree().process_frame
	_expect(str(main.call("get_run_state_name")) == "Paused", "Training should support pause")
	_expect(get_tree().paused, "Pausing training should pause the tree")
	main.call("resume_run")
	await get_tree().process_frame
	_expect(str(main.call("get_run_state_name")) == "Training", "Resuming training should restore Training state")
	_expect(not get_tree().paused, "Resuming training should unpause the tree")
	_expect(bool(main.call("reset_training_room")), "Training reset should succeed while in Training state")
	await get_tree().process_frame
	var reset_summary: Dictionary = main.call("get_training_summary")
	_expect(str(reset_summary.get("drill_id", "")) == "aim_assist", "Training reset should keep active drill")
	_expect(str(reset_summary.get("target_types", "")).contains("Assist 2"), "Training reset should keep active target types")
	_expect(int(reset_summary.get("goal_progress", -1)) == 0, "Training reset should clear goal progress")
	_expect(not bool(reset_summary.get("goal_complete", true)), "Training reset should clear goal completion")
	_expect(str(reset_summary.get("rating_rank", "")) == "practice", "Training reset should restore Practice rating")
	_expect(str(reset_summary.get("best_rating_rank", "")) == "clean", "Training reset should keep best badge record")
	_expect(int(reset_summary.get("targets", 0)) == TRAINING_TARGET_COUNT, "Training reset should keep target count")
	_expect(int(reset_summary.get("hits", -1)) == 0, "Training reset should clear hit count")
	_expect(int(reset_summary.get("damage", -1)) == 0, "Training reset should clear damage count")
	_expect(_training_dummy_count() == TRAINING_TARGET_COUNT, "Training reset should respawn three training dummies")
	_expect(str(hud.call("get_training_rating_text")).contains("Practice"), "HUD should show Practice rating after reset")
	_expect(str(hud.call("get_training_rating_text")).contains("Best Clean"), "HUD should keep best badge text after reset")
	_expect(str(hud.call("get_training_badge_text")).contains("Badge: Clean [CN]"), "HUD should show saved badge token after reset")
	var reset_player := main.get_node_or_null("Player") as Node2D
	if reset_player != null and reset_player.has_method("get_aim_assist_candidate_groups_for_test"):
		var reset_aim_groups: PackedStringArray = reset_player.call("get_aim_assist_candidate_groups_for_test")
		_expect(reset_aim_groups.has("training_dummy"), "Training reset should keep aim assist on training dummy targets")
	if hud.has_method("is_training_reward_toast_visible_for_test"):
		_expect(not bool(hud.call("is_training_reward_toast_visible_for_test")), "Training reward toast should hide after training reset")
	_expect(str(hud.call("get_training_stats_text")).contains("Damage 0"), "HUD should show reset training damage")

	get_tree().paused = false
	main.queue_free()
	await get_tree().process_frame

	var reloaded_main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(reloaded_main)
	await get_tree().process_frame
	var reloaded_hud = reloaded_main.get_node_or_null("CanvasLayer/HUD")
	var reloaded_meta: Dictionary = reloaded_main.call("get_meta_progression_summary")
	var reloaded_badges: Dictionary = reloaded_meta.get("training_drill_best_ratings", {})
	_expect(int(reloaded_meta.get("training_badge_count", 0)) == 2, "Reloaded Main should read saved training badge count")
	_expect(str(reloaded_badges.get("burst", "")) == "clean", "Reloaded Main should read saved Burst Clean badge")
	_expect(str(reloaded_badges.get("aim_assist", "")) == "clean", "Reloaded Main should read saved Aim Assist Clean badge")
	_expect(int(reloaded_meta.get("currency", 0)) == 0, "Reloaded training badge should not create permanent currency")
	if reloaded_hud != null:
		reloaded_main.call("open_hall_menu")
		await get_tree().process_frame
		var reloaded_hall_text := str(reloaded_hud.call("get_hall_summary_text"))
		_expect(reloaded_hall_text.contains("Training Badges (2/4)"), "Hall should show saved training badge count")
		_expect(reloaded_hall_text.contains("Burst | Badge: Clean"), "Hall should show saved Burst Clean badge")
		_expect(reloaded_hall_text.contains("Burst | Badge: Clean [CN]"), "Hall should show saved Burst Clean badge token")
		_expect(reloaded_hall_text.contains("Aim Assist | Badge: Clean"), "Hall should show saved Aim Assist Clean badge")
		_expect(reloaded_hall_text.contains("Aim Assist | Badge: Clean [CN]"), "Hall should show saved Aim Assist Clean badge token")
	get_tree().paused = false
	reloaded_main.queue_free()
	await get_tree().process_frame
	_delete_settings_file()
	_finish()


func _alive_enemy_count() -> int:
	var count := 0
	for node in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		if node.has_method("is_dead") and bool(node.call("is_dead")):
			continue
		count += 1
	return count


func _get_training_dummy() -> Node:
	for node in get_tree().get_nodes_in_group("training_dummy"):
		if is_instance_valid(node) and not node.is_queued_for_deletion():
			return node
	return null


func _get_training_dummy_by_type(target_type: String) -> Node:
	var wanted := target_type.strip_edges().to_lower()
	for node in get_tree().get_nodes_in_group("training_dummy"):
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		var current := "standard"
		if node.has_method("get_target_type"):
			current = str(node.call("get_target_type"))
		else:
			current = str(node.get("target_type"))
		if current.strip_edges().to_lower() == wanted:
			return node
	return null


func _get_training_dummies_by_type(target_type: String) -> Array[Node]:
	var wanted := target_type.strip_edges().to_lower()
	var matches: Array[Node] = []
	for node in get_tree().get_nodes_in_group("training_dummy"):
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		var current := "standard"
		if node.has_method("get_target_type"):
			current = str(node.call("get_target_type"))
		else:
			current = str(node.get("target_type"))
		if current.strip_edges().to_lower() == wanted:
			matches.append(node)
	return matches


func _training_dummy_count() -> int:
	var count := 0
	for node in get_tree().get_nodes_in_group("training_dummy"):
		if is_instance_valid(node) and not node.is_queued_for_deletion():
			count += 1
	return count


func _training_dummy_names() -> Array[String]:
	var names: Array[String] = []
	for node in get_tree().get_nodes_in_group("training_dummy"):
		if is_instance_valid(node) and not node.is_queued_for_deletion():
			names.append(str(node.get("display_name")))
	return names


func _training_dummy_type_counts() -> Dictionary:
	var counts := {}
	for node in get_tree().get_nodes_in_group("training_dummy"):
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		var target_type := "standard"
		if node.has_method("get_target_type"):
			target_type = str(node.call("get_target_type"))
		else:
			target_type = str(node.get("target_type"))
		target_type = target_type.strip_edges().to_lower()
		if target_type.is_empty():
			target_type = "standard"
		counts[target_type] = int(counts.get(target_type, 0)) + 1
	return counts


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
		print("TrainingRoomSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

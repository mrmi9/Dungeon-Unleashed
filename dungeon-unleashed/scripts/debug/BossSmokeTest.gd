extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const ROOM_STATE_CLEARED := 3
const MIN_SAFE_SUMMON_DISTANCE := 120.0

var _failures: Array[String] = []
var _phase_signal := 1
var _boss_died_seen := false
var _run_completed_seen := false
var _last_boss_health := -1


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	Events.boss_health_changed.connect(_on_boss_health_changed)
	Events.boss_phase_changed.connect(_on_boss_phase_changed)
	Events.boss_died.connect(_on_boss_died)
	Events.run_completed.connect(_on_run_completed)

	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	if main.has_method("start_new_run"):
		main.call("start_new_run")

	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().create_timer(0.15).timeout

	var player := main.get_node("Player") as Player
	var hud = main.get_node_or_null("CanvasLayer/HUD")
	var rooms := _get_rooms()
	_expect(player != null, "Player should exist")
	_expect(hud != null, "HUD should exist")
	_expect(rooms.size() >= 6, "Generated route should include a boss room")
	if player == null or rooms.size() < 6:
		_finish()
		return

	var boss_room = rooms[rooms.size() - 1]
	await _enter_room(boss_room, player)

	var boss := _get_boss()
	_expect(boss != null, "Boss room should spawn a boss")
	if boss == null:
		_finish()
		return

	_expect(str(boss.get("display_name")) == "Void Foundry Heart", "Final boss room should use the configured biome boss display name")
	_expect(boss.has_method("get_damage_source_summary"), "Boss should expose damage source summary")
	var boss_source: Dictionary = boss.call("get_damage_source_summary")
	_expect(str(boss_source.get("source_type", "")) == "boss", "Boss source summary should classify boss source")
	_expect(str(boss_source.get("source_name", "")) == "Void Foundry Heart", "Boss source summary should expose display name")
	_expect(str(boss_source.get("source_id", "")).length() > 0, "Boss source summary should expose a stable source id")
	_expect(str(boss_source.get("source_threat_intel", "")).contains("Boss Threat"), "Boss source summary should expose threat intel")
	_expect(str(boss_source.get("signature_attack", "")) == "void_bloom", "Final boss threat summary should expose Void Bloom")
	_expect(str(boss_source.get("signature_name", "")) == "Void Bloom", "Final boss threat summary should expose readable signature name")
	_expect(str(boss_source.get("phase_two_attack", "")) == "rift_cross", "Final boss threat summary should expose Rift Cross")
	_expect(str(boss_source.get("phase_two_name", "")) == "Rift Cross", "Final boss threat summary should expose readable phase-two attack name")
	_expect((boss_source.get("source_counter_tags", []) as Array).has("survival"), "Boss source summary should expose counter build tags")
	_expect(_last_boss_health == int(boss.get("max_health")), "Boss health signal should announce full health on spawn")
	if hud != null and hud.has_method("is_boss_health_visible"):
		_expect(bool(hud.call("is_boss_health_visible")), "HUD should show boss health after boss spawns")
	if hud != null and hud.has_method("get_boss_name_text"):
		_expect(str(hud.call("get_boss_name_text")).contains("Void Bloom"), "Boss HUD title should expose the biome-specific signature")

	var phase_threshold := roundi(float(boss.get("max_health")) * float(boss.get("phase_two_health_ratio")))
	var phase_damage := int(boss.get("max_health")) - phase_threshold + 1
	boss.call("apply_damage", phase_damage, null, Vector2.ZERO, 0.0)
	await get_tree().process_frame
	_expect(boss.has_method("get_phase") and int(boss.call("get_phase")) == 2, "Boss should enter phase 2 below half health")
	_expect(_phase_signal == 2, "Boss phase signal should report phase 2")
	if hud != null and hud.has_method("get_boss_name_text"):
		_expect(str(hud.call("get_boss_name_text")).contains("Rift Cross"), "Boss HUD title should switch to the phase-two exclusive attack")
	_expect(boss.has_method("get_phase_transition_remaining") and float(boss.call("get_phase_transition_remaining")) > 0.0, "Boss should start a phase transition pause")
	var phase_action_summary: Dictionary = boss.call("get_action_sprite_summary")
	_expect(int(phase_action_summary.get("frame", -1)) == 2, "Boss phase transition should use its transformation frame")
	_expect(_danger_warning_count() > 0, "Boss phase transition should create a danger warning")
	_expect(_danger_warning_has_readability_outline(), "Boss phase transition warning should expose a readable outline")
	_expect(boss_room.has_method("is_boss_arena_active") and bool(boss_room.call("is_boss_arena_active")), "Boss phase 2 should activate boss arena hazards")
	_expect(boss_room.has_method("get_boss_arena_marker_count") and int(boss_room.call("get_boss_arena_marker_count")) >= 5, "Boss arena should expose hazard markers")
	_expect(boss_room.has_method("get_boss_arena_warning_count") and int(boss_room.call("get_boss_arena_warning_count")) == 0, "Boss arena hazards should wait for the phase transition to read clearly")

	_clear_enemy_projectiles()
	boss.set("_attack_index", 0)
	boss.set("_attack_timer", 0.0)
	await get_tree().create_timer(minf(float(boss.get("phase_transition_duration")) * 0.5, float(boss.get("attack_windup")) + 0.2)).timeout
	await get_tree().physics_frame
	_expect(_enemy_projectile_count() == 0, "Boss should not fire during the phase transition pause")
	_expect(float(boss.call("get_phase_transition_remaining")) > 0.0, "Boss phase transition should still be active during the early pause window")

	await get_tree().create_timer(float(boss.call("get_phase_transition_remaining")) + 0.12).timeout
	await get_tree().physics_frame
	boss.set("_boss_action_timer", 0.0)
	boss.call("_tick_boss_action_sprite", 0.0)
	_expect(int(boss.call("get_action_sprite_summary").get("frame", -1)) == 3, "Boss should settle into its phase-two frame after the transition")
	await get_tree().create_timer(0.25).timeout
	await get_tree().process_frame
	_expect(int(boss_room.call("get_boss_arena_warning_count")) > 0, "Boss arena should create delayed floor hazard warnings after the phase transition")
	_expect(_danger_warning_source_id_exists("boss_arena_hazard", "hazard"), "Boss arena floor warning should cache a stable hazard source id")
	_clear_enemy_projectiles()
	_clear_danger_warnings()
	boss.set("_attack_index", 0)
	boss.set("_attack_timer", 0.0)
	for index in range(4):
		await get_tree().physics_frame
		await get_tree().process_frame
	_expect(_danger_warning_count() > 0, "Boss radial burst should create a danger warning before firing")
	_expect(_danger_warning_has_readability_outline(), "Boss radial burst warning should expose a readable outline")
	await get_tree().create_timer(float(boss.get("attack_windup")) + 0.15).timeout
	await get_tree().physics_frame
	_expect(_enemy_projectile_count() >= int(boss.get("radial_projectile_count")), "Boss radial burst should create enemy projectiles")

	_clear_enemy_projectiles()
	_clear_danger_warnings()
	boss.set("_attack_index", 3)
	boss.set("_attack_timer", 0.0)
	for index in range(4):
		await get_tree().physics_frame
		await get_tree().process_frame
	var signature_summary: Dictionary = boss.call("get_signature_attack_summary")
	_expect(str(signature_summary.get("id", "")) == "void_bloom", "Void Foundry Heart should expose Void Bloom signature")
	_expect(int(signature_summary.get("uses", 0)) > 0, "Boss attack cycle should execute its fourth-slot signature")
	_expect(_danger_warning_count() > 0, "Void Bloom should create a target-centered warning")
	_expect(_danger_warning_source_id_exists("void_foundry_heart", "boss"), "Void Bloom warning should retain final boss source identity")
	await get_tree().create_timer(float(boss.get("signature_windup")) + 0.12).timeout
	await get_tree().physics_frame
	_expect(_enemy_projectile_count() >= int(boss.get("signature_projectile_count")), "Void Bloom should emit its configured radial projectile ring")

	_clear_enemy_projectiles()
	_clear_danger_warnings()
	boss.set("_attack_index", 2)
	boss.set("_attack_timer", 0.0)
	for index in range(5):
		await get_tree().physics_frame
		await get_tree().process_frame
	_expect(_enemy_count_by_name("Null Acolyte") > 0, "Final boss summon attack should create Void Foundry minions")
	_expect(_nearest_enemy_distance_to(player.global_position, "Null Acolyte") >= MIN_SAFE_SUMMON_DISTANCE, "Boss summon minions should spawn away from the player")

	boss.call("apply_damage", 9999, null, Vector2.ZERO, 0.0)
	for index in range(5):
		await get_tree().physics_frame
		await get_tree().process_frame
	await get_tree().create_timer(boss_room.time_between_waves + 0.2).timeout
	await get_tree().physics_frame

	_expect(_boss_died_seen, "Boss death signal should fire")
	_expect(not _run_completed_seen, "Boss death should wait for boss reward chest before run_completed")
	_expect(boss_room.state == ROOM_STATE_CLEARED, "Boss room should clear after boss death")
	_expect(not bool(boss_room.call("is_boss_arena_active")), "Boss arena hazards should stop after boss death")

	var reward := _find_reward_near(boss_room.global_position)
	_expect(reward != null and reward.has_method("open_for_player"), "Boss room should spawn an openable reward chest")
	if reward != null and reward.has_method("open_for_player"):
		reward.call("open_for_player", player)
		await get_tree().process_frame

	_expect(_run_completed_seen, "Opening boss reward chest should emit run_completed")
	if hud != null and hud.has_method("is_completion_visible"):
		_expect(bool(hud.call("is_completion_visible")), "HUD should show run completion after boss reward chest opens")

	_finish()


func _on_boss_health_changed(_boss: Node, current_hp: int, _max_hp: int) -> void:
	_last_boss_health = current_hp


func _on_boss_phase_changed(_boss: Node, phase: int) -> void:
	_phase_signal = phase


func _on_boss_died(_boss: Node) -> void:
	_boss_died_seen = true


func _on_run_completed() -> void:
	_run_completed_seen = true


func _enter_room(room: Node, player: Player) -> void:
	player.global_position = room.global_position + Vector2(-700, 0)
	await get_tree().physics_frame
	await get_tree().process_frame
	player.global_position = room.global_position
	for index in range(4):
		await get_tree().physics_frame
		await get_tree().process_frame


func _get_rooms() -> Array:
	var rooms: Array = []
	for room in get_tree().get_nodes_in_group("combat_rooms"):
		if is_instance_valid(room):
			rooms.append(room)
	rooms.sort_custom(func(a, b) -> bool:
		return a.global_position.x < b.global_position.x
	)
	return rooms


func _get_boss() -> Node:
	for boss in get_tree().get_nodes_in_group("bosses"):
		if is_instance_valid(boss) and not boss.is_queued_for_deletion():
			return boss
	return null


func _enemy_projectile_count() -> int:
	var count := 0
	for projectile in get_tree().get_nodes_in_group("enemy_projectiles"):
		if is_instance_valid(projectile) and not projectile.is_queued_for_deletion():
			count += 1
	return count


func _clear_enemy_projectiles() -> void:
	for projectile in get_tree().get_nodes_in_group("enemy_projectiles"):
		if is_instance_valid(projectile):
			projectile.queue_free()


func _danger_warning_count() -> int:
	var count := 0
	for warning in get_tree().get_nodes_in_group("danger_warnings"):
		if is_instance_valid(warning) and not warning.is_queued_for_deletion():
			count += 1
	return count


func _danger_warning_has_readability_outline() -> bool:
	for warning in get_tree().get_nodes_in_group("danger_warnings"):
		if not is_instance_valid(warning) or warning.is_queued_for_deletion():
			continue
		if warning.has_method("has_readability_outline_for_test") and bool(warning.call("has_readability_outline_for_test")):
			return true
	return false


func _danger_warning_source_id_exists(source_id: String, source_type: String) -> bool:
	for warning in get_tree().get_nodes_in_group("danger_warnings"):
		if not is_instance_valid(warning) or warning.is_queued_for_deletion():
			continue
		if not warning.has_method("get_damage_source_summary"):
			continue
		var summary = warning.call("get_damage_source_summary")
		if not (summary is Dictionary):
			continue
		var source_summary := summary as Dictionary
		if str(source_summary.get("source_id", "")) == source_id and str(source_summary.get("source_type", "")) == source_type:
			return true
	return false


func _clear_danger_warnings() -> void:
	for warning in get_tree().get_nodes_in_group("danger_warnings"):
		if is_instance_valid(warning):
			warning.queue_free()


func _enemy_count_by_name(display_name: String) -> int:
	var count := 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		if str(enemy.get("display_name")) == display_name:
			count += 1
	return count


func _nearest_enemy_distance_to(position: Vector2, display_name: String = "") -> float:
	var nearest := 1.0e20
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		if display_name != "" and str(enemy.get("display_name")) != display_name:
			continue
		var enemy_node := enemy as Node2D
		if enemy_node == null:
			continue
		nearest = minf(nearest, enemy_node.global_position.distance_to(position))
	return nearest


func _find_reward_near(position: Vector2) -> Node2D:
	for reward in get_tree().get_nodes_in_group("rewards"):
		if not is_instance_valid(reward) or reward.is_queued_for_deletion():
			continue
		var reward_node := reward as Node2D
		if reward_node != null and reward_node.global_position.distance_to(position) < 500.0:
			return reward_node
	return null


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	get_tree().paused = false
	if _failures.is_empty():
		print("BossSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

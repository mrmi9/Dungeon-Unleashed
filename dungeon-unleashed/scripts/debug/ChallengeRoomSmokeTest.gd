extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const CHALLENGE_ROOM_DATA := preload("res://resources/rooms/challenge_room.tres")
const ROOM_STATE_COMBAT := 2
const ROOM_STATE_CLEARED := 3
const ROOM_STATE_REWARD_CLAIMED := 4

var _failures: Array[String] = []
var _chests_seen := 0


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	Events.chest_opened.connect(func(_chest: Node, _opener: Node, _chest_type: String) -> void:
		_chests_seen += 1
	)

	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	await get_tree().physics_frame

	var controller := main.get_node_or_null("DungeonController")
	_expect(controller != null, "Main scene should include DungeonController")
	if controller == null:
		_finish()
		return

	var challenge_sequence: Array[Resource] = [CHALLENGE_ROOM_DATA]
	controller.set("room_data_sequence", challenge_sequence)
	controller.call("regenerate_with_seed", 777001)
	await get_tree().process_frame
	await get_tree().physics_frame

	main.call("start_new_run")
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().create_timer(0.15).timeout

	var player := main.get_node_or_null("Player") as Player
	var hud = main.get_node_or_null("CanvasLayer/HUD")
	_expect(player != null, "Player should exist")
	_expect(hud != null, "HUD should exist")
	if player == null or hud == null:
		_finish()
		return

	var rooms: Array = controller.call("get_combat_rooms")
	_expect(rooms.size() == 1, "Challenge test route should contain one room")
	if rooms.is_empty():
		_finish()
		return

	var room: Node = rooms[0]
	var records: Array = controller.call("get_room_records")
	var record: Dictionary = records[0] if not records.is_empty() and records[0] is Dictionary else {}
	var challenge_variant := str(record.get("challenge_variant", ""))
	_expect(str(room.get("room_type")) == "challenge", "Generated test room should be a challenge room")
	_expect(challenge_variant in ["gauntlet", "hazard_rush"], "Challenge room record should expose a resolved challenge variant")
	_expect(str(room.get("challenge_variant")) == challenge_variant, "Challenge runtime variant should match generation record")
	_expect(room.has_method("get_challenge_summary"), "Challenge room should expose challenge summary")
	if room.has_method("get_challenge_summary"):
		var challenge_summary: Dictionary = room.call("get_challenge_summary")
		_expect(str(challenge_summary.get("variant", "")) == challenge_variant, "Challenge summary should preserve resolved variant")
		_expect(not str(challenge_summary.get("label", "")).is_empty(), "Challenge summary should expose a readable variant label")
	_expect(not bool(room.get("auto_clear_on_enter")), "Challenge room should require combat")
	_expect(bool(room.get("lock_doors_during_combat")), "Challenge room should lock connected doors during combat")
	_expect(bool(room.get("elite_enemies")), "Challenge room should apply elite enemy modifiers")
	_expect(is_equal_approx(float(room.get("elite_health_multiplier")), 1.35), "Challenge room should use tuned elite health multiplier")
	_expect(is_equal_approx(float(room.get("elite_damage_multiplier")), 1.2), "Challenge room should use tuned elite damage multiplier")
	var elite_profiles: Array = room.get("elite_modifier_profiles")
	_expect(elite_profiles.size() >= 6, "Challenge room should expose the elite modifier profile pool")

	await _enter_room(room, player)
	_expect(int(room.get("state")) == ROOM_STATE_COMBAT, "Challenge room should enter combat on player entry")
	if challenge_variant == "hazard_rush":
		_expect(room.has_method("is_challenge_hazard_active") and bool(room.call("is_challenge_hazard_active")), "Hazard Rush challenge should activate combat hazards")
		await get_tree().create_timer(0.2).timeout
		_expect(int(room.call("get_trap_warning_count")) > 0, "Hazard Rush challenge should spawn readable hazard warnings")
	else:
		_expect(room.has_method("is_challenge_hazard_active") and not bool(room.call("is_challenge_hazard_active")), "Gauntlet challenge should not activate hazard rush warnings")

	var wave_counts: PackedInt32Array = room.get("wave_enemy_counts")
	_expect(wave_counts == PackedInt32Array([4, 6]), "Challenge room should run the configured two-wave trial")
	for wave_index in range(wave_counts.size()):
		_expect(_enemy_count_near(room.global_position) == int(wave_counts[wave_index]), "Challenge wave %d should spawn configured enemies" % (wave_index + 1))
		_expect(_all_local_enemies_elite(room.global_position), "Challenge wave %d should spawn elite enemies" % (wave_index + 1))
		_expect(_local_elite_modifier_ids(room.global_position).size() >= 2, "Challenge wave %d should rotate elite modifier profiles" % (wave_index + 1))
		_kill_all_enemies()
		await get_tree().create_timer(float(room.get("time_between_waves")) + 0.2).timeout
		await get_tree().physics_frame

	_expect(int(room.get("state")) == ROOM_STATE_CLEARED, "Challenge room should clear after both waves")

	var reward := _find_reward_near(room.global_position)
	_expect(reward != null and reward.has_method("open_for_player"), "Challenge room should spawn an openable premium chest")
	var chests_before := _chests_seen
	if reward != null and reward.has_method("open_for_player"):
		_expect(bool(reward.call("open_for_player", player)), "Challenge premium chest should open for player")
		await get_tree().process_frame
		await _choose_relic_if_prompted(hud)
	_expect(_chests_seen == chests_before + 1, "Challenge premium chest should emit chest_opened")
	_expect(int(room.get("state")) == ROOM_STATE_REWARD_CLAIMED, "Challenge room should mark reward claimed after chest opens")

	get_tree().paused = false
	main.queue_free()
	await get_tree().process_frame
	_finish()


func _enter_room(room: Node, player: Player) -> void:
	player.global_position = (room as Node2D).global_position + Vector2(-700, 0)
	await get_tree().physics_frame
	await get_tree().process_frame
	player.global_position = (room as Node2D).global_position
	for _index in range(4):
		await get_tree().physics_frame
		await get_tree().process_frame


func _enemy_count_near(position: Vector2, radius: float = 640.0) -> int:
	var count := 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		if enemy.has_method("is_dead") and enemy.call("is_dead"):
			continue
		var enemy_node := enemy as Node2D
		if enemy_node == null or enemy_node.global_position.distance_to(position) > radius:
			continue
		count += 1
	return count


func _all_local_enemies_elite(position: Vector2, radius: float = 640.0) -> bool:
	var local_count := 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		if enemy.has_method("is_dead") and enemy.call("is_dead"):
			continue
		var enemy_node := enemy as Node2D
		if enemy_node == null or enemy_node.global_position.distance_to(position) > radius:
			continue
		local_count += 1
		if enemy.get("is_elite") != true:
			return false
	return local_count > 0


func _local_elite_modifier_ids(position: Vector2, radius: float = 640.0) -> PackedStringArray:
	var ids := PackedStringArray()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		if enemy.has_method("is_dead") and enemy.call("is_dead"):
			continue
		var enemy_node := enemy as Node2D
		if enemy_node == null or enemy_node.global_position.distance_to(position) > radius:
			continue
		var id := str(enemy.get("elite_modifier_id"))
		if not id.is_empty() and not ids.has(id):
			ids.append(id)
	return ids


func _kill_all_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy) and enemy.has_method("apply_damage"):
			enemy.call("apply_damage", 9999)


func _find_reward_near(position: Vector2) -> Node2D:
	for reward in get_tree().get_nodes_in_group("rewards"):
		if not is_instance_valid(reward) or reward.is_queued_for_deletion():
			continue
		if reward.has_method("is_claimed") and bool(reward.call("is_claimed")):
			continue
		if reward.has_method("is_opened") and bool(reward.call("is_opened")):
			continue
		if reward is CanvasItem and not (reward as CanvasItem).visible:
			continue
		var reward_node := reward as Node2D
		if reward_node != null and reward_node.global_position.distance_to(position) < 500.0:
			return reward_node
	return null


func _choose_relic_if_prompted(hud: Node) -> void:
	if hud.has_method("is_relic_choice_visible") and bool(hud.call("is_relic_choice_visible")):
		hud.call("choose_relic_for_test", 0)
		for _index in range(3):
			await get_tree().physics_frame
			await get_tree().process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	get_tree().paused = false
	if _failures.is_empty():
		print("ChallengeRoomSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

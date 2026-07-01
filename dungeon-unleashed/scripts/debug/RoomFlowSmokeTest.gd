extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const ROOM_STATE_COMBAT := 2
const ROOM_STATE_CLEARED := 3
const ROOM_STATE_REWARD_CLAIMED := 4

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	if main.has_method("start_new_run"):
		main.call("start_new_run")

	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().create_timer(0.15).timeout

	var player := main.get_node("Player") as Player
	_expect(player != null, "Player should exist")
	if player == null:
		_finish()
		return

	var rooms := _get_rooms()
	_expect(rooms.size() >= 4, "Main scene should contain a generated dungeon route with at least 4 combat rooms")
	if rooms.is_empty():
		_finish()
		return

	var start_room = rooms[0]
	_expect(start_room.state == ROOM_STATE_COMBAT, "Start room should naturally enter COMBAT after starting from main menu")
	var start_wave_counts = start_room.wave_enemy_counts
	if start_wave_counts.size() > 0:
		_expect(_enemy_count() == start_wave_counts[0], "Start room should spawn the first enemy wave without test teleport")

	for room in rooms:
		await _complete_room(room, player)

	_finish()


func _complete_room(room, player: Player) -> void:
	if room.state == 0:
		await _enter_room(room, player)

	if bool(room.get("auto_clear_on_enter")):
		_expect(room.state == ROOM_STATE_CLEARED, "%s should auto-clear after entry" % room.get_path())
		_expect(_enemy_count() == 0, "%s should not spawn enemies when auto-clearing" % room.get_path())
		_expect(room.doors_are_unlocked(), "%s should keep doors unlocked when auto-clearing" % room.get_path())
		if str(room.get("room_type")) == "shop":
			_expect(_shop_item_count_near(room.global_position) == 3, "%s should spawn shop inventory" % room.get_path())
			return
		await _collect_reward(room, player)
		_expect(room.state == ROOM_STATE_REWARD_CLAIMED, "%s should record REWARD_CLAIMED after pickup" % room.get_path())
		return

	_expect(room.state == ROOM_STATE_COMBAT, "%s should enter COMBAT" % room.get_path())
	_expect(not room.doors_are_unlocked(), "%s should lock doors during combat" % room.get_path())

	var wave_counts = room.wave_enemy_counts
	for wave_index in range(wave_counts.size()):
		_expect(_enemy_count() == wave_counts[wave_index], "%s wave %d enemy count should match config" % [room.get_path(), wave_index + 1])
		_kill_all_enemies()
		await get_tree().create_timer(room.time_between_waves + 0.2).timeout
		await get_tree().physics_frame

		if wave_index < wave_counts.size() - 1:
			_expect(room.state == ROOM_STATE_COMBAT, "%s should stay in COMBAT between waves" % room.get_path())

	_expect(room.state == ROOM_STATE_CLEARED, "%s should become CLEARED after all waves" % room.get_path())
	_expect(_enemy_count() == 0, "No enemies should remain after clearing %s" % room.get_path())
	_expect(room.doors_are_unlocked(), "%s should unlock doors after clear" % room.get_path())

	if _run_completed():
		_expect(_result_panel_visible(), "%s should show victory result after boss clear" % room.get_path())
		return

	await _collect_reward(room, player)

	_expect(room.state == ROOM_STATE_REWARD_CLAIMED, "%s should record REWARD_CLAIMED after pickup" % room.get_path())


func _enter_room(room, player: Player) -> void:
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


func _kill_all_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy) and enemy.has_method("apply_damage"):
			enemy.call("apply_damage", 9999)


func _enemy_count() -> int:
	var count := 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		if enemy.has_method("is_dead") and enemy.call("is_dead"):
			continue
		count += 1
	return count


func _reward_count() -> int:
	var count := 0
	for reward in get_tree().get_nodes_in_group("rewards"):
		if is_instance_valid(reward) and not reward.is_queued_for_deletion() and not _reward_is_consumed(reward):
			count += 1
	return count


func _find_reward_near(position: Vector2) -> Node2D:
	for reward in get_tree().get_nodes_in_group("rewards"):
		if not is_instance_valid(reward) or reward.is_queued_for_deletion():
			continue
		if _reward_is_consumed(reward):
			continue
		var reward_node := reward as Node2D
		if reward_node != null and reward_node.global_position.distance_to(position) < 500.0:
			return reward_node
	return null


func _reward_is_consumed(reward: Node) -> bool:
	if reward.has_method("is_claimed") and bool(reward.call("is_claimed")):
		return true
	if reward.has_method("is_opened") and bool(reward.call("is_opened")):
		return true
	if reward is CanvasItem and not (reward as CanvasItem).visible:
		return true
	return false


func _shop_item_count_near(position: Vector2) -> int:
	var count := 0
	for item in get_tree().get_nodes_in_group("shop_items"):
		if not is_instance_valid(item) or item.is_queued_for_deletion():
			continue
		var item_node := item as Node2D
		if item_node != null and item_node.global_position.distance_to(position) < 500.0:
			count += 1
	return count


func _collect_reward(room, player: Player) -> void:
	var reward := _find_reward_near(room.global_position)
	if reward != null:
		if reward.has_method("open_for_player"):
			reward.call("open_for_player", player)
			await get_tree().process_frame
		elif reward.has_method("claim_for_player"):
			reward.call("claim_for_player", player)
			await get_tree().process_frame
		else:
			player.global_position = reward.global_position
			for index in range(4):
				await get_tree().physics_frame
				await get_tree().process_frame
		await _choose_relic_if_prompted()
	elif int(room.get("state")) == 4:
		return
	else:
		var hud := get_tree().root.find_child("HUD", true, false)
		if hud != null and hud.has_method("is_relic_choice_visible") and bool(hud.call("is_relic_choice_visible")):
			await _choose_relic_if_prompted()
			return
		_expect(false, "%s should spawn one local reward" % room.get_path())


func _choose_relic_if_prompted() -> void:
	var hud := get_tree().root.find_child("HUD", true, false)
	if hud == null or not hud.has_method("is_relic_choice_visible"):
		return
	if not bool(hud.call("is_relic_choice_visible")):
		return
	if hud.has_method("choose_relic_for_test"):
		hud.call("choose_relic_for_test", 0)
		for index in range(3):
			await get_tree().physics_frame
			await get_tree().process_frame


func _run_completed() -> bool:
	var game_root := get_tree().get_first_node_in_group("game_root")
	if game_root == null or not game_root.has_method("get_run_state_name"):
		return false
	return str(game_root.call("get_run_state_name")) == "Victory"


func _result_panel_visible() -> bool:
	var hud := get_tree().root.find_child("HUD", true, false)
	if hud == null or not hud.has_method("is_result_visible"):
		return false
	return bool(hud.call("is_result_visible"))


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	get_tree().paused = false
	if _failures.is_empty():
		print("RoomFlowSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

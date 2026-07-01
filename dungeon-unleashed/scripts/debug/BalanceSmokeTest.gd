extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const BOSS_SCENE := preload("res://scenes/enemies/BossEnemy.tscn")

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
	var relic_system := main.get_node_or_null("RelicSystem")
	_expect(player != null, "Player should exist")
	_expect(hud != null, "HUD should exist")
	_expect(relic_system != null, "RelicSystem should exist")
	if player == null or hud == null:
		_finish()
		return
	var controller := main.get_node_or_null("DungeonController")
	if controller != null and controller.has_method("regenerate_with_seed"):
		controller.call("regenerate_with_seed", 424242)
		await get_tree().process_frame
		await get_tree().physics_frame

	main.call("start_new_run")
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().create_timer(0.15).timeout

	var rooms := _get_rooms(main)
	_expect(rooms.size() >= 12 and rooms.size() <= 15, "Balance route should contain a variable 12-15 room route")
	if rooms.size() < 12:
		_finish()
		return

	var start_wave_counts: PackedInt32Array = rooms[0].get("wave_enemy_counts")
	var elite_index := _first_room_index_by_type(rooms, "elite")
	var shop_index := _first_room_index_by_type(rooms, "shop")
	_expect(elite_index > 0, "Balance route should include an elite room")
	_expect(shop_index > elite_index, "Balance route should place first shop after an elite pressure check")
	if elite_index < 0 or shop_index < 0:
		_finish()
		return

	var elite_room = rooms[elite_index]
	var elite_wave_counts: PackedInt32Array = elite_room.get("wave_enemy_counts")
	_expect(_wave_total(start_wave_counts) == 6, "Start room should use a gentler 6-enemy opening")
	_expect(_wave_total(elite_wave_counts) == 9, "Elite room should use 9 elite enemies after first balance pass")
	_expect(is_equal_approx(float(elite_room.get("elite_health_multiplier")), 1.65), "Elite health multiplier should use first balance pass value")

	for index in range(shop_index):
		await _complete_pre_shop_room(rooms[index], player, hud)

	var gold_before_shop := player.current_gold
	_expect(gold_before_shop >= 160, "Natural gold before first shop should afford a meaningful purchase; gold=%d route=%s" % [gold_before_shop, _room_type_signature(rooms)])
	_expect(gold_before_shop <= 330, "Natural gold before first shop should not trivialize shop decisions; gold=%d route=%s" % [gold_before_shop, _room_type_signature(rooms)])

	await _enter_room(rooms[shop_index], player)
	var items := _get_shop_items()
	var heal_item := _first_item_by_type(items, "Heal")
	var relic_item := _first_item_by_type(items, "Relic")
	var weapon_item := _first_item_by_type(items, "Weapon")
	_expect(heal_item != null and relic_item != null and weapon_item != null, "Shop should offer heal, relic, and weapon")
	if heal_item != null and relic_item != null and weapon_item != null:
		var heal_price := int(heal_item.call("get_price"))
		var relic_price := int(relic_item.call("get_price"))
		var weapon_price := int(weapon_item.call("get_price"))
		var total_price := heal_price + relic_price + weapon_price
		_expect(heal_price == 30, "Heal price should match branching route balance pass")
		_expect(relic_price == 110, "Relic price should match branching route balance pass")
		_expect(weapon_price == 160, "Weapon price should match branching route balance pass")
		_expect(gold_before_shop >= relic_price, "Natural gold should afford a relic")
		_expect(gold_before_shop >= weapon_price, "Natural gold should afford a weapon")
		_expect(gold_before_shop >= heal_price + relic_price, "Natural gold should afford heal plus relic")
		_expect(gold_before_shop < relic_price + weapon_price, "Natural gold should not afford both major shop items; gold=%d route=%s" % [gold_before_shop, _room_type_signature(rooms)])
		_expect(gold_before_shop < total_price, "Natural gold should not buy out the whole shop; gold=%d route=%s" % [gold_before_shop, _room_type_signature(rooms)])

	var boss := BOSS_SCENE.instantiate()
	_expect(boss != null, "Boss scene should instantiate for balance checks")
	if boss != null:
		_expect(int(boss.get("max_health")) == 48, "Boss health should match first balance pass")
		boss.queue_free()

	get_tree().paused = false
	main.queue_free()
	await get_tree().process_frame
	_finish()


func _complete_pre_shop_room(room: Node, player: Player, hud: Node) -> void:
	var room_type := str(room.get("room_type"))
	if room_type in ["start", "combat", "elite"]:
		await _complete_combat_room(room, player, hud)
	elif room_type in ["reward", "armory", "healing"]:
		await _claim_reward_room(room, player, hud)


func _complete_combat_room(room: Node, player: Player, hud: Node) -> void:
	await _enter_room(room, player)
	var wave_counts: PackedInt32Array = room.get("wave_enemy_counts")
	for _wave_index in range(wave_counts.size()):
		_kill_all_enemies()
		await get_tree().create_timer(float(room.get("time_between_waves")) + 0.2).timeout
		await get_tree().physics_frame
	await _collect_reward_near((room as Node2D).global_position, player, hud, room)


func _claim_reward_room(room: Node, player: Player, hud: Node) -> void:
	await _enter_room(room, player)
	await _collect_reward_near((room as Node2D).global_position, player, hud, room)


func _collect_reward_near(position: Vector2, player: Player, hud: Node, room: Node = null) -> void:
	var reward := _find_reward_near(position)
	if reward == null:
		if room != null and int(room.get("state")) == 4:
			return
		if hud.has_method("is_relic_choice_visible") and bool(hud.call("is_relic_choice_visible")):
			hud.call("choose_relic_for_test", 0)
			for _index in range(3):
				await get_tree().physics_frame
				await get_tree().process_frame
			return
		var context := "Room"
		if room != null:
			context = str(room.get_path())
		_expect(false, "%s should spawn a reward for balance route" % context)
		return
	if reward.has_method("open_for_player"):
		reward.call("open_for_player", player)
		await get_tree().process_frame
	elif reward.has_method("claim_for_player"):
		reward.call("claim_for_player", player)
		await get_tree().process_frame
	else:
		player.global_position = reward.global_position
		for _index in range(5):
			await get_tree().physics_frame
			await get_tree().process_frame
	if hud.has_method("is_relic_choice_visible") and bool(hud.call("is_relic_choice_visible")):
		hud.call("choose_relic_for_test", 0)
		for _index in range(3):
			await get_tree().physics_frame
			await get_tree().process_frame


func _enter_room(room: Node, player: Player) -> void:
	player.global_position = (room as Node2D).global_position + Vector2(-700, 0)
	await get_tree().physics_frame
	await get_tree().process_frame
	player.global_position = (room as Node2D).global_position
	for _index in range(4):
		await get_tree().physics_frame
		await get_tree().process_frame


func _get_rooms(main: Node) -> Array:
	var controller := main.get_node_or_null("DungeonController")
	var rooms: Array = []
	if controller != null and controller.has_method("get_combat_rooms"):
		rooms = controller.call("get_combat_rooms")
	return rooms


func _first_room_index_by_type(rooms: Array, type_name: String) -> int:
	for index in range(rooms.size()):
		if str(rooms[index].get("room_type")) == type_name:
			return index
	return -1


func _room_type_signature(rooms: Array) -> String:
	var parts: PackedStringArray = []
	for room in rooms:
		parts.append(str(room.get("room_type")))
	return ">".join(parts)


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


func _get_shop_items() -> Array:
	var items: Array = []
	for item in get_tree().get_nodes_in_group("shop_items"):
		if is_instance_valid(item) and not item.is_queued_for_deletion():
			items.append(item)
	return items


func _first_item_by_type(items: Array, type_name: String) -> Node:
	for item in items:
		if is_instance_valid(item) and item.has_method("get_item_type_name") and str(item.call("get_item_type_name")) == type_name:
			return item
	return null


func _wave_total(wave_counts: PackedInt32Array) -> int:
	var total := 0
	for count in wave_counts:
		total += int(count)
	return total


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	get_tree().paused = false
	if _failures.is_empty():
		print("BalanceSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const ROOM_STATE_REWARD_CLAIMED := 4

var _failures: Array[String] = []
var _run_completed_seen := false
var _purchases_seen := 0
var _chests_seen := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_run")


func _run() -> void:
	Events.run_completed.connect(func() -> void:
		_run_completed_seen = true
	)
	Events.shop_item_purchased.connect(func(_item: Node, _buyer: Node, _price: int, _item_type: String) -> void:
		_purchases_seen += 1
	)
	Events.chest_opened.connect(func(_chest: Node, _opener: Node, _chest_type: String) -> void:
		_chests_seen += 1
	)

	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	var controller := main.get_node_or_null("DungeonController")
	if controller != null and controller.has_method("regenerate_with_seed"):
		controller.call("regenerate_with_seed", 424242)
		await get_tree().process_frame
		await get_tree().physics_frame

	var hud = main.get_node_or_null("CanvasLayer/HUD")
	var player := main.get_node_or_null("Player") as Player
	var relic_system := main.get_node_or_null("RelicSystem")
	_expect(hud != null, "HUD should exist")
	_expect(player != null, "Player should exist")
	_expect(relic_system != null, "RelicSystem should exist")
	_expect(str(main.call("get_run_state_name")) == "Main Menu", "Full run should begin at main menu")
	if hud != null and hud.has_method("is_main_menu_visible"):
		_expect(bool(hud.call("is_main_menu_visible")), "Main menu should be visible before starting")
	if player == null or hud == null or relic_system == null:
		_finish()
		return

	main.call("start_new_run")
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().create_timer(0.15).timeout
	_expect(str(main.call("get_run_state_name")) == "Running", "Starting from menu should enter running state")

	var rooms := _get_rooms(main)
	_expect(rooms.size() >= 12 and rooms.size() <= 15, "Generated full route should contain 12-15 rooms, got %d: %s" % [rooms.size(), _room_type_signature(rooms)])
	if rooms.size() < 12:
		_finish()
		return
	_expect(str(rooms[0].get("room_type")) == "start", "Generated full route should start with a start room")
	_expect(str(rooms[rooms.size() - 1].get("room_type")) == "boss", "Generated full route should end with a boss room")
	_expect(_has_room_type(rooms, "reward"), "Generated full route should include at least one reward branch")
	_expect(_has_room_type(rooms, "armory"), "Generated full route should include a weapon armory branch")
	_expect(_has_room_type(rooms, "healing"), "Generated full route should include a healing branch")
	_expect(_has_room_type(rooms, "shop"), "Generated full route should include a shop branch")
	_expect(_has_room_type(rooms, "elite"), "Generated full route should include an elite room")

	for room in rooms:
		var room_type := str(room.get("room_type"))
		if room_type in ["start", "combat", "elite"]:
			await _complete_combat_room(room, player, hud)
		elif room_type == "reward":
			await _claim_reward_room(room, player, hud, relic_system)
		elif room_type == "armory":
			await _claim_armory_room(room, player, hud)
		elif room_type == "healing":
			await _claim_healing_room(room, player, hud)
		elif room_type == "shop":
			await _use_shop_room(room, player)
		elif room_type == "boss":
			await _complete_boss_room(room, player)

	await get_tree().process_frame
	var summary: Dictionary = main.call("get_run_summary")
	_expect(_run_completed_seen, "Opening boss reward chest should complete the run")
	_expect(str(main.call("get_run_state_name")) == "Victory", "Full route should end in Victory")
	_expect(bool(hud.call("is_result_visible")), "Victory should show the result panel")
	_expect(str(hud.call("get_result_title_text")) == "Run Complete", "Victory result title should be Run Complete")
	_expect(int(summary.get("rooms_cleared", 0)) >= 12, "Full run summary should include all cleared rooms")
	_expect(int(summary.get("kills", 0)) >= 35, "Full run summary should include expanded combat and boss kills")
	_expect(int(summary.get("relic_count", 0)) >= 2, "Full run should collect branch reward relics")
	_expect(int(summary.get("shop_purchases", 0)) >= 1, "Full run should include a shop purchase")
	_expect(int(summary.get("chests_opened", 0)) >= 5, "Full run should open combat, armory, healing, premium, and boss chests")
	_expect(summary.get("boss_defeated", false) == true, "Full run summary should record boss defeat")
	_expect(_purchases_seen >= 1, "Full run should emit a shop purchase event")
	_expect(_chests_seen >= 5, "Full run should emit chest opened events")
	_expect(str(hud.call("get_result_section_text", "Overview")).contains("Rooms"), "Grouped result should include Overview details")
	_expect(str(hud.call("get_result_section_text", "Build")).contains("Relics:"), "Grouped result should include Build details")
	_expect(str(hud.call("get_result_section_text", "Loot")).contains("Chests"), "Grouped result should include Loot details")
	_expect(str(hud.call("get_result_section_text", "Record")).contains("Wins"), "Grouped result should include Record details")

	get_tree().paused = false
	main.queue_free()
	await get_tree().process_frame
	_finish()


func _complete_combat_room(room: Node, player: Player, hud: Node) -> void:
	await _enter_room(room, player)
	_expect(str(room.get("room_type")) in ["start", "combat", "elite"], "%s should be a combat route room" % room.get_path())
	_expect(int(room.get("state")) == 2, "%s should enter combat state" % room.get_path())
	var wave_counts = room.get("wave_enemy_counts")
	for wave_index in range(wave_counts.size()):
		_expect(_enemy_count() == int(wave_counts[wave_index]), "%s wave %d should spawn configured enemies" % [room.get_path(), wave_index + 1])
		_kill_all_enemies()
		await get_tree().create_timer(float(room.get("time_between_waves")) + 0.2).timeout
		await get_tree().physics_frame
	_expect(int(room.get("state")) == 3, "%s should clear after all waves" % room.get_path())
	await _collect_reward_near(room.global_position, player, hud, room)
	await _choose_relic_if_prompted(hud)
	_expect(int(room.get("state")) == ROOM_STATE_REWARD_CLAIMED, "%s should claim reward after clear" % room.get_path())


func _claim_reward_room(room: Node, player: Player, hud: Node, relic_system: Node) -> void:
	await _enter_room(room, player)
	_expect(str(room.get("room_type")) == "reward", "Reward branch room should be a reward room")
	_expect(int(room.get("state")) == 3, "Reward room should auto-clear on entry")
	var relic_stacks_before := _get_total_relic_stacks(relic_system)
	await _collect_reward_near(room.global_position, player, hud, room)
	await _choose_relic_if_prompted(hud)
	_expect(_get_total_relic_stacks(relic_system) > relic_stacks_before, "Reward room should grant a relic or stack; room=%s seed=%s state=%s" % [room.get_path(), _get_generation_seed_text(room), str(room.get("state"))])
	_expect(int(room.get("state")) == ROOM_STATE_REWARD_CLAIMED, "Reward room should mark reward claimed")


func _claim_armory_room(room: Node, player: Player, hud: Node) -> void:
	await _enter_room(room, player)
	_expect(str(room.get("room_type")) == "armory", "Armory branch room should be an armory room")
	_expect(int(room.get("state")) == 3, "Armory room should auto-clear on entry")
	await _collect_reward_near(room.global_position, player, hud, room)
	_expect(player.weapon_loadout.size() > 0, "Armory room should leave the player with a weapon loadout")
	_expect(player.weapon != null and player.weapon.weapon_data != null, "Armory room should equip a valid weapon")
	_expect(int(room.get("state")) == ROOM_STATE_REWARD_CLAIMED, "Armory room should mark reward claimed")


func _claim_healing_room(room: Node, player: Player, hud: Node) -> void:
	await _enter_room(room, player)
	_expect(str(room.get("room_type")) == "healing", "Healing branch room should be a healing room")
	_expect(int(room.get("state")) == 3, "Healing room should auto-clear on entry")
	player.current_health = maxi(player.max_health - 2, 1)
	player.health_changed.emit(player.current_health, player.max_health)
	var health_before := player.current_health
	await _collect_reward_near(room.global_position, player, hud, room)
	_expect(player.current_health > health_before, "Healing room should restore player health")
	_expect(int(room.get("state")) == ROOM_STATE_REWARD_CLAIMED, "Healing room should mark reward claimed")


func _use_shop_room(room: Node, player: Player) -> void:
	await _enter_room(room, player)
	_expect(str(room.get("room_type")) == "shop", "Shop branch room should be a shop room")
	_expect(int(room.get("state")) == 3, "Shop room should auto-clear on entry")
	var items := _get_shop_items()
	_expect(items.size() == 3, "Shop room should spawn three items")
	var relic_item := _first_item_by_type(items, "Relic")
	var heal_item := _first_item_by_type(items, "Heal")
	var item_to_buy := relic_item if relic_item != null else heal_item
	_expect(item_to_buy != null, "Shop should have a buyable relic or heal item")
	if item_to_buy != null:
		var gold_before := player.current_gold
		_expect(gold_before >= int(item_to_buy.call("get_price")), "Full run should naturally afford at least one shop item")
		_expect(bool(item_to_buy.call("purchase_for_player", player)), "Full run should buy one shop item")
		await get_tree().process_frame
		_expect(player.current_gold < gold_before, "Shop purchase should spend gold")
		_expect(bool(item_to_buy.call("is_sold_out")), "Purchased shop item should sell out")


func _complete_boss_room(room: Node, player: Player) -> void:
	await _enter_room(room, player)
	_expect(str(room.get("room_type")) == "boss", "Final room should be boss room")
	var boss := _get_boss()
	_expect(boss != null, "Boss room should spawn a boss")
	if boss != null:
		boss.call("apply_damage", 9999, null, Vector2.ZERO, 0.0)
	for index in range(5):
		await get_tree().physics_frame
		await get_tree().process_frame
	await get_tree().create_timer(float(room.get("time_between_waves")) + 0.2).timeout
	await get_tree().physics_frame
	_expect(int(room.get("state")) == 3, "Boss room should clear after boss death")
	var reward := _find_reward_near(room.global_position)
	_expect(reward != null and reward.has_method("open_for_player"), "Boss room should spawn an openable boss chest")
	if reward != null and reward.has_method("open_for_player"):
		_expect(bool(reward.call("open_for_player", player)), "Full run should open boss reward chest")
		await get_tree().process_frame


func _enter_room(room: Node, player: Player) -> void:
	player.global_position = (room as Node2D).global_position + Vector2(-700, 0)
	await get_tree().physics_frame
	await get_tree().process_frame
	player.global_position = (room as Node2D).global_position
	for index in range(4):
		await get_tree().physics_frame
		await get_tree().process_frame


func _collect_reward_near(position: Vector2, player: Player, hud: Node = null, room: Node = null) -> void:
	var reward := _find_reward_near(position)
	if reward == null:
		if room != null and int(room.get("state")) == ROOM_STATE_REWARD_CLAIMED:
			return
		if hud != null and hud.has_method("is_relic_choice_visible") and bool(hud.call("is_relic_choice_visible")):
			return
		var context := "Room"
		if room != null:
			context = str(room.get_path())
		_expect(false, "%s should spawn a claimable reward" % context)
		return
	if reward.has_method("open_for_player"):
		_expect(bool(reward.call("open_for_player", player)), "Reward chest should open for player")
		await get_tree().process_frame
		return
	if reward.has_method("claim_for_player"):
		_expect(bool(reward.call("claim_for_player", player)), "Reward pickup should claim for player")
		await get_tree().process_frame
		return
	player.global_position = reward.global_position
	for index in range(5):
		await get_tree().physics_frame
		await get_tree().process_frame


func _choose_relic_if_prompted(hud: Node) -> void:
	if hud.has_method("is_relic_choice_visible") and bool(hud.call("is_relic_choice_visible")):
		hud.call("choose_relic_for_test", 0)
		for index in range(3):
			await get_tree().physics_frame
			await get_tree().process_frame


func _get_rooms(main: Node) -> Array:
	var rooms: Array = []
	var controller := main.get_node_or_null("DungeonController")
	if controller != null and controller.has_method("get_combat_rooms"):
		rooms = controller.call("get_combat_rooms")
	else:
		for room in get_tree().get_nodes_in_group("combat_rooms"):
			if is_instance_valid(room):
				rooms.append(room)
	return rooms


func _get_generation_seed_text(room: Node) -> String:
	var main := room.get_tree().root.find_child("Main", true, false)
	if main == null:
		return "unknown"
	var controller := main.get_node_or_null("DungeonController")
	if controller != null and controller.has_method("get_generation_seed"):
		return str(controller.call("get_generation_seed"))
	return "unknown"


func _get_total_relic_stacks(relic_system: Node) -> int:
	if relic_system == null or not relic_system.has_method("get_relic_summaries"):
		return 0
	var total := 0
	var summaries: Array = relic_system.call("get_relic_summaries")
	for summary in summaries:
		if summary is Dictionary:
			total += maxi(int(summary.get("stacks", 1)), 1)
	return total


func _room_type_signature(rooms: Array) -> String:
	var parts: PackedStringArray = []
	for room in rooms:
		parts.append(str(room.get("room_type")))
	return ">".join(parts)


func _has_room_type(rooms: Array, type_name: String) -> bool:
	for room in rooms:
		if str(room.get("room_type")) == type_name:
			return true
	return false


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


func _get_boss() -> Node:
	for boss in get_tree().get_nodes_in_group("bosses"):
		if is_instance_valid(boss) and not boss.is_queued_for_deletion():
			return boss
	return null


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


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	get_tree().paused = false
	if _failures.is_empty():
		print("FullRunSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")

var _failures: Array[String] = []
var _purchased_count := 0
var _failed_count := 0


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	Events.shop_item_purchased.connect(func(_item: Node, _buyer: Node, _price: int, _type_name: String) -> void:
		_purchased_count += 1
	)
	Events.shop_purchase_failed.connect(func(_item: Node, _buyer: Node, _price: int, _reason: String) -> void:
		_failed_count += 1
	)

	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	if main.has_method("start_new_run"):
		main.call("start_new_run")

	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().create_timer(0.15).timeout

	var player := main.get_node("Player") as Player
	var relic_system := main.get_node_or_null("RelicSystem")
	var rooms := _get_rooms()
	_expect(player != null, "Player should exist")
	_expect(relic_system != null, "RelicSystem should exist")
	_expect(rooms.size() >= 10, "Route should include a shop branch before boss")
	if player == null or relic_system == null or rooms.size() < 10:
		_finish()
		return

	var shop_room = _first_room_by_type(rooms, "shop")
	_expect(shop_room != null, "Route should include a shop room")
	if shop_room == null:
		_finish()
		return
	await _enter_room(shop_room, player)

	var items := _get_shop_items()
	_expect(items.size() == 3, "Shop should spawn exactly 3 items")
	_expect(_has_item_type(items, "Heal"), "Shop should offer healing")
	_expect(_has_item_type(items, "Relic"), "Shop should offer a relic")
	_expect(_has_item_type(items, "Weapon"), "Shop should offer a weapon")

	var heal_item := _first_item_by_type(items, "Heal")
	var relic_item := _first_item_by_type(items, "Relic")
	var weapon_item := _first_item_by_type(items, "Weapon")
	var shop_pool_ids: Array = relic_system.call("get_source_pool_ids", "shop")
	_expect(shop_pool_ids.has(str(relic_item.call("get_payload_id"))), "Shop relic should come from the shop relic source pool")

	var full_shop_budget := int(heal_item.call("get_price")) + int(relic_item.call("get_price")) + int(weapon_item.call("get_price")) + 20
	player.add_gold(full_shop_budget)
	player.current_health = player.max_health - 2
	player.health_changed.emit(player.current_health, player.max_health)
	var health_before := player.current_health
	var gold_before := player.current_gold
	await _touch_item_without_purchase(heal_item, player)
	_expect(player.current_gold == gold_before, "Touching a shop item should not buy without interaction")
	_expect(bool(heal_item.call("purchase_for_player", player)), "Interact purchase should buy heal")
	await get_tree().process_frame
	_expect(player.current_health > health_before, "Buying heal should restore health")
	_expect(player.current_gold == gold_before - int(heal_item.call("get_price")), "Buying heal should spend its price")
	_expect(bool(heal_item.call("is_sold_out")), "Heal item should be sold out after purchase")

	var relic_count_before := int(relic_system.call("get_relic_count"))
	gold_before = player.current_gold
	_expect(bool(relic_item.call("purchase_for_player", player)), "Interact purchase should buy relic")
	await get_tree().process_frame
	_expect(int(relic_system.call("get_relic_count")) > relic_count_before, "Buying relic should add a relic")
	_expect(player.current_gold == gold_before - int(relic_item.call("get_price")), "Buying relic should spend its price")
	_expect(bool(relic_item.call("is_sold_out")), "Relic item should be sold out after purchase")

	var weapon_name := str(weapon_item.call("get_display_name"))
	gold_before = player.current_gold
	_expect(bool(weapon_item.call("purchase_for_player", player)), "Interact purchase should buy weapon")
	await get_tree().process_frame
	_expect(player.get_weapon_display_name() == weapon_name, "Buying weapon should equip purchased weapon")
	_expect(player.current_gold == gold_before - int(weapon_item.call("get_price")), "Buying weapon should spend its price")
	_expect(bool(weapon_item.call("is_sold_out")), "Weapon item should be sold out after purchase")
	_expect(_purchased_count == 3, "Shop should emit one purchase event per bought item")

	var broke_item := _spawn_direct_shop_item()
	player.current_gold = 0
	player.gold_changed.emit(player.current_gold)
	_expect(not bool(broke_item.call("purchase_for_player", player)), "Interact purchase should fail when player lacks gold")
	await get_tree().process_frame
	_expect(_failed_count > 0, "Shop should emit failed purchase when player lacks gold")

	_finish()


func _enter_room(room: Node, player: Player) -> void:
	player.global_position = room.global_position + Vector2(-700, 0)
	await get_tree().physics_frame
	await get_tree().process_frame
	player.global_position = room.global_position
	for index in range(4):
		await get_tree().physics_frame
		await get_tree().process_frame


func _touch_item_without_purchase(item: Node, player: Player) -> void:
	if item == null:
		return
	var item_node := item as Node2D
	player.global_position = item_node.global_position
	for index in range(5):
		await get_tree().physics_frame
		await get_tree().process_frame


func _get_rooms() -> Array:
	var rooms: Array = []
	for room in get_tree().get_nodes_in_group("combat_rooms"):
		if is_instance_valid(room):
			rooms.append(room)
	return rooms


func _first_room_by_type(rooms: Array, room_type: String) -> Node:
	for room in rooms:
		if is_instance_valid(room) and str(room.get("room_type")) == room_type:
			return room
	return null


func _get_shop_items() -> Array:
	var items: Array = []
	for item in get_tree().get_nodes_in_group("shop_items"):
		if is_instance_valid(item) and not item.is_queued_for_deletion():
			items.append(item)
	return items


func _has_item_type(items: Array, type_name: String) -> bool:
	return _first_item_by_type(items, type_name) != null


func _first_item_by_type(items: Array, type_name: String) -> Node:
	for item in items:
		if is_instance_valid(item) and item.has_method("get_item_type_name") and str(item.call("get_item_type_name")) == type_name:
			return item
	return null


func _spawn_direct_shop_item() -> Node:
	var scene := load("res://scenes/shop/ShopItem.tscn") as PackedScene
	var item := scene.instantiate()
	get_tree().root.add_child(item)
	item.global_position = Vector2(-1200, -1200)
	item.call("configure", 0, 10, null, 1)
	return item


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	get_tree().paused = false
	if _failures.is_empty():
		print("ShopSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

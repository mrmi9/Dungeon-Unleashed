extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const CONTENT_ICON_REGISTRY := preload("res://scripts/content/ContentIconRegistry.gd")

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
	var hud = main.get_node_or_null("CanvasLayer/HUD")
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
	var shop_inventory := get_tree().get_first_node_in_group("shop_inventories")
	_expect(shop_inventory != null, "Shop room should spawn a ShopInventory reward node")
	if shop_inventory != null and shop_inventory.has_method("get_biome_reward_summary"):
		var reward_summary: Dictionary = shop_inventory.call("get_biome_reward_summary")
		var room_biome_id := str(shop_room.get("biome_id"))
		_expect(str(reward_summary.get("biome_id", "")) == room_biome_id, "Shop inventory should inherit room biome id")
		_expect(is_equal_approx(float(reward_summary.get("reward_weight_multiplier", 0.0)), _expected_biome_reward_multiplier(room_biome_id)), "Shop inventory should inherit biome reward weight multiplier")
	else:
		_expect(false, "Shop inventory should expose biome reward summary")
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
	if hud != null and hud.has_method("get_weapon_slot_loadout_summary_for_test"):
		var loadout_summary: Dictionary = hud.call("get_weapon_slot_loadout_summary_for_test")
		var loadout_names: Array = loadout_summary.get("names", [])
		var loadout_entries: Array = loadout_summary.get("entries", [])
		var loadout_icon_keys: Array = loadout_summary.get("icon_keys", [])
		var loadout_icon_paths: Array = loadout_summary.get("icon_texture_paths", [])
		var loadout_icon_visibility: Array = loadout_summary.get("icon_texture_visible", [])
		var loadout_slot_border_colors: Array = loadout_summary.get("slot_border_colors", [])
		var loadout_slot_border_widths: Array = loadout_summary.get("slot_border_widths", [])
		var loadout_ammo_summaries: Array = loadout_summary.get("ammo_summaries", [])
		var loadout_energy_states: Array = loadout_summary.get("energy_states", [])
		_expect(loadout_names.has(weapon_name), "Buying weapon should update the HUD weapon loadout preview")
		_expect(int(loadout_summary.get("active_slot", 0)) == player.current_weapon_index + 1, "HUD weapon loadout preview should keep the purchased weapon slot active")
		var purchased_weapon_data = weapon_item.get("weapon_data")
		if purchased_weapon_data != null:
			var expected_weapon_icon_key := _resolve_weapon_icon_key(purchased_weapon_data)
			var purchased_slot_index := int(loadout_summary.get("active_slot", 1)) - 1
			_expect(_loadout_entries_contain_metadata(loadout_entries, weapon_name, str(purchased_weapon_data.get("rarity")), str(purchased_weapon_data.get("weapon_class"))), "Buying weapon should update HUD loadout rarity and class metadata")
			_expect(_loadout_entries_contain_icon_key(loadout_entries, weapon_name, expected_weapon_icon_key), "Buying weapon should update HUD loadout icon key metadata")
			_expect(purchased_slot_index >= 0 and purchased_slot_index < loadout_icon_keys.size() and str(loadout_icon_keys[purchased_slot_index]) == expected_weapon_icon_key, "Buying weapon should update the active HUD loadout slot icon key")
			_expect(purchased_slot_index >= 0 and purchased_slot_index < loadout_icon_paths.size() and str(loadout_icon_paths[purchased_slot_index]) == CONTENT_ICON_REGISTRY.get_texture_path(expected_weapon_icon_key, "weapons"), "Buying weapon should update the active HUD loadout slot icon texture from the registry")
			_expect(purchased_slot_index >= 0 and purchased_slot_index < loadout_icon_visibility.size() and bool(loadout_icon_visibility[purchased_slot_index]), "Buying weapon should keep the active HUD loadout slot icon visible")
			_expect(purchased_slot_index >= 0 and purchased_slot_index < loadout_slot_border_widths.size() and int(loadout_slot_border_widths[purchased_slot_index]) >= 2, "Buying weapon should keep the active HUD loadout slot border visible")
			_expect(purchased_slot_index >= 0 and purchased_slot_index < loadout_slot_border_colors.size() and typeof(loadout_slot_border_colors[purchased_slot_index]) == TYPE_COLOR, "Buying weapon should keep the active HUD loadout slot border color readable")
			_expect(purchased_slot_index >= 0 and purchased_slot_index < loadout_ammo_summaries.size() and str(loadout_ammo_summaries[purchased_slot_index]) == "%d/%d" % [int(purchased_weapon_data.get("magazine_size")), int(purchased_weapon_data.get("magazine_size"))], "Buying weapon should show the purchased weapon full magazine in the active HUD loadout slot")
			_expect(purchased_slot_index >= 0 and purchased_slot_index < loadout_energy_states.size() and str(loadout_energy_states[purchased_slot_index]) != "blocked", "Buying weapon should expose an affordable active HUD loadout energy state at full energy")
			if hud.has_method("get_weapon_slot_meta_text"):
				var purchased_meta_text := str(hud.call("get_weapon_slot_meta_text"))
				_expect(purchased_meta_text.contains(str(purchased_weapon_data.get("rarity")).capitalize()), "Buying weapon should update HUD weapon slot rarity text")
				_expect(purchased_meta_text.contains(str(purchased_weapon_data.get("weapon_class")).capitalize()), "Buying weapon should update HUD weapon slot class text")
			if hud.has_method("get_weapon_slot_visual_summary_for_test"):
				var purchased_visual_summary: Dictionary = hud.call("get_weapon_slot_visual_summary_for_test")
				_expect(str(purchased_visual_summary.get("icon_key", "")) == expected_weapon_icon_key, "Buying weapon should update HUD weapon slot icon key")
				_expect(str(purchased_visual_summary.get("icon_texture_path", "")) == CONTENT_ICON_REGISTRY.get_texture_path(expected_weapon_icon_key, "weapons"), "Buying weapon should update HUD weapon slot icon texture from the registry")
				_expect(bool(purchased_visual_summary.get("icon_texture_visible", false)), "Buying weapon should keep HUD weapon slot icon texture visible")
				_expect(str(purchased_visual_summary.get("type", "")).contains(str(purchased_weapon_data.get("weapon_class")).capitalize()), "Buying weapon should update HUD weapon slot type symbol")
				_expect(str(purchased_visual_summary.get("energy", "")) == "E%d" % int(purchased_weapon_data.get("energy_cost")), "Buying weapon should update HUD weapon slot energy symbol")
				_expect(typeof(purchased_visual_summary.get("rarity_color")) == TYPE_COLOR, "Buying weapon should keep HUD weapon slot rarity strip color readable")
			if hud.has_method("get_weapon_slot_panel_summary_for_test"):
				var purchased_panel_summary: Dictionary = hud.call("get_weapon_slot_panel_summary_for_test")
				_expect(int(purchased_panel_summary.get("active_slot", 0)) == player.current_weapon_index + 1, "Buying weapon should keep HUD weapon slot active border on the purchased slot")
				_expect(int(purchased_panel_summary.get("border_width", 0)) >= 2, "Buying weapon should keep HUD weapon slot active border visible")
				_expect(typeof(purchased_panel_summary.get("border_color")) == TYPE_COLOR, "Buying weapon should update HUD weapon slot rarity border color")
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


func _expected_biome_reward_multiplier(biome_id: String) -> float:
	match biome_id:
		"outer_warrens":
			return 1.0
		"iron_catacombs":
			return 1.08
		"void_foundry":
			return 1.16
	return 1.0


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


func _loadout_entries_contain_metadata(entries: Array, display_name: String, rarity: String, weapon_class: String) -> bool:
	for entry in entries:
		if not entry is Dictionary:
			continue
		if str(entry.get("display_name", "")) == display_name and str(entry.get("rarity", "")) == rarity and str(entry.get("weapon_class", "")) == weapon_class:
			return true
	return false


func _loadout_entries_contain_icon_key(entries: Array, display_name: String, icon_key: String) -> bool:
	for entry in entries:
		if not entry is Dictionary:
			continue
		if str(entry.get("display_name", "")) == display_name and str(entry.get("icon_key", "")) == icon_key:
			return true
	return false


func _resolve_weapon_icon_key(weapon_data: Resource) -> String:
	if weapon_data == null:
		return "weapon"
	var explicit_key := str(weapon_data.get("icon_key")).strip_edges()
	if not explicit_key.is_empty():
		return explicit_key
	return "weapon_%s" % str(weapon_data.get("id")).strip_edges()


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

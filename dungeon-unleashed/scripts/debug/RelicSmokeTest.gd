extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const SHARP_ROUNDS := preload("res://resources/relics/sharp_rounds.tres")
const QUICK_TRIGGER := preload("res://resources/relics/quick_trigger.tres")
const SPLIT_CHAMBER := preload("res://resources/relics/split_chamber.tres")
const PHASE_TIP := preload("res://resources/relics/phase_tip.tres")
const VAMPIRE_FANG := preload("res://resources/relics/vampire_fang.tres")
const GUARDIAN_WARD := preload("res://resources/relics/guardian_ward.tres")
const ADRENALINE_CHARM := preload("res://resources/relics/adrenaline_charm.tres")
const LUCKY_PRIMER := preload("res://resources/relics/lucky_primer.tres")
const SWIFT_LOADER := preload("res://resources/relics/swift_loader.tres")
const HEART_CORE := preload("res://resources/relics/heart_core.tres")

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
	var relic_system := main.get_node_or_null("RelicSystem")
	var hud = main.get_node_or_null("CanvasLayer/HUD")
	_expect(player != null, "Player should exist")
	_expect(relic_system != null, "RelicSystem should exist")
	if player == null or relic_system == null:
		_finish()
		return

	_expect(relic_system.call("get_relic_count") == 0, "RelicSystem should start empty")
	_expect((relic_system.get("available_relics") as Array).size() >= 10, "RelicSystem should expose at least 10 relics")
	_verify_relic_choice_randomization(relic_system)
	_verify_source_drop_pools(relic_system)
	_expect(bool(relic_system.call("obtain_relic", SHARP_ROUNDS)), "Should obtain Sharp Rounds")
	_expect(player.get_damage_multiplier() > 1.0, "Sharp Rounds should increase player damage multiplier")
	if hud != null and hud.has_method("get_relic_label_text"):
		_expect(str(hud.call("get_relic_label_text")).contains("Sharp Rounds"), "HUD should show collected relic")

	_expect(bool(relic_system.call("obtain_relic", QUICK_TRIGGER)), "Should obtain Quick Trigger")
	_expect(player.get_fire_rate_multiplier() > 1.0, "Quick Trigger should increase fire rate multiplier")
	_expect(bool(relic_system.call("obtain_relic", SPLIT_CHAMBER)), "Should obtain Split Chamber")
	_expect(player.get_projectile_count_bonus() == 1, "Split Chamber should add one projectile")
	_expect(bool(relic_system.call("obtain_relic", PHASE_TIP)), "Should obtain Phase Tip")
	_expect(player.get_pierce_bonus() == 1, "Phase Tip should add one pierce")
	_expect(bool(relic_system.call("obtain_relic", VAMPIRE_FANG)), "Should obtain Vampire Fang")
	_expect(bool(relic_system.call("obtain_relic", GUARDIAN_WARD)), "Should obtain Guardian Ward")
	_expect(bool(relic_system.call("obtain_relic", ADRENALINE_CHARM)), "Should obtain Adrenaline Charm")
	_expect(bool(relic_system.call("obtain_relic", LUCKY_PRIMER)), "Should obtain Lucky Primer")
	_expect(player.get_crit_chance_bonus() > 0.0, "Lucky Primer should increase crit chance bonus")
	_expect(bool(relic_system.call("obtain_relic", SWIFT_LOADER)), "Should obtain Swift Loader")
	_expect(player.get_reload_speed_multiplier() > 1.0, "Swift Loader should increase reload speed multiplier")
	var max_health_before := player.max_health
	var health_before := player.current_health
	_expect(bool(relic_system.call("obtain_relic", HEART_CORE)), "Should obtain Heart Core")
	_expect(player.max_health == max_health_before + 1, "Heart Core should increase max health by 1")
	_expect(player.current_health == mini(health_before + 1, player.max_health), "Heart Core should heal by 1")

	await _verify_projectile_modifiers(player)
	await _verify_triggered_relics(player)
	await _verify_reward_room_relic_pickup(main, player, relic_system)
	_finish()


func _verify_projectile_modifiers(player: Player) -> void:
	player.call("_equip_weapon", 0)
	await get_tree().process_frame

	var weapon := player.weapon
	var weapon_data := weapon.weapon_data
	_clear_projectiles()
	weapon.set("_cooldown", 0.0)
	var fired := weapon.try_fire(player.global_position + Vector2(320, 0), player)
	await get_tree().process_frame

	var expected_projectiles := weapon_data.projectile_count + player.get_projectile_count_bonus()
	_expect(fired, "Weapon should fire after relic modifiers")
	_expect(_projectile_count() == expected_projectiles, "Split Chamber should increase projectile count")
	_expect(float(weapon.get("_cooldown")) < 1.0 / weapon_data.fire_rate, "Quick Trigger should reduce cooldown")

	var projectile := get_tree().get_first_node_in_group("projectiles")
	_expect(projectile != null, "Projectile should exist for relic modifier checks")
	if projectile != null:
		var expected_damage := maxi(roundi(float(weapon_data.damage) * player.get_damage_multiplier()), 1)
		_expect(projectile.get("damage") == expected_damage, "Sharp Rounds should increase projectile damage")
		_expect(projectile.get("_remaining_pierce") == weapon_data.pierce_count + player.get_pierce_bonus(), "Phase Tip should increase projectile pierce")
		_expect(is_equal_approx(float(projectile.get("crit_chance")), clampf(weapon_data.crit_chance + player.get_crit_chance_bonus(), 0.0, 1.0)), "Lucky Primer should increase projectile crit chance")

	_expect(weapon.start_reload(), "Weapon should start manual reload after spending ammo")
	_expect(weapon.is_reloading(), "Weapon should be reloading after start_reload")
	_expect(float(weapon.get("_reload_timer")) < weapon_data.reload_duration, "Swift Loader should reduce reload timer")

	_clear_projectiles()


func _verify_relic_choice_randomization(relic_system: Node) -> void:
	_expect(float(relic_system.call("get_rarity_weight", "common")) > float(relic_system.call("get_rarity_weight", "rare")), "Common relics should have higher weight than rare relics")
	_expect(float(relic_system.call("get_rarity_weight", "rare")) > float(relic_system.call("get_rarity_weight", "epic")), "Rare relics should have higher weight than epic relics")
	_expect(float(relic_system.call("get_rarity_weight", "epic")) > float(relic_system.call("get_rarity_weight", "legendary")), "Epic relics should have higher weight than legendary relics")
	relic_system.call("set_random_seed", 123456)
	var first_choices: Array = relic_system.call("get_reward_choices", 3)
	relic_system.call("set_random_seed", 123456)
	var repeat_choices: Array = relic_system.call("get_reward_choices", 3)
	_expect(first_choices.size() == 3, "Weighted reward choices should return 3 candidates")
	_expect(_unique_choice_count(first_choices) == first_choices.size(), "Weighted reward choices should not repeat relics")
	_expect(_choice_id_signature(first_choices) == _choice_id_signature(repeat_choices), "Weighted reward choices should be reproducible with the same seed")


func _verify_source_drop_pools(relic_system: Node) -> void:
	_expect(relic_system.has_method("get_source_pool_ids"), "RelicSystem should expose source pool ids")
	_expect(relic_system.has_method("get_source_rarity_weight"), "RelicSystem should expose source rarity weights")
	_expect(relic_system.has_method("get_configured_drop_source_ids"), "RelicSystem should expose configured drop source ids")
	_expect(relic_system.has_method("get_drop_table_resource_path"), "RelicSystem should expose drop table resource paths")
	if not relic_system.has_method("get_source_pool_ids") or not relic_system.has_method("get_source_rarity_weight"):
		return

	var configured_sources: Array = relic_system.call("get_configured_drop_source_ids")
	var reward_ids: Array = relic_system.call("get_source_pool_ids", "reward")
	var shop_ids: Array = relic_system.call("get_source_pool_ids", "shop")
	var normal_chest_ids: Array = relic_system.call("get_source_pool_ids", "normal_chest")
	var premium_chest_ids: Array = relic_system.call("get_source_pool_ids", "premium_chest")
	var boss_chest_ids: Array = relic_system.call("get_source_pool_ids", "boss_chest")
	_expect(configured_sources.has("reward"), "Reward source should be configured by a drop table resource")
	_expect(configured_sources.has("shop"), "Shop source should be configured by a drop table resource")
	_expect(configured_sources.has("normal_chest"), "Normal chest source should be configured by a drop table resource")
	_expect(configured_sources.has("premium_chest"), "Premium chest source should be configured by a drop table resource")
	_expect(configured_sources.has("boss_chest"), "Boss chest source should be configured by a drop table resource")
	_expect(str(relic_system.call("get_drop_table_resource_path", "shop")).begins_with("res://resources/relic_drop_tables/"), "Shop drop table should live in resource configuration")
	_expect(reward_ids.size() >= 10, "Reward source should include the full first-version relic pool")
	_expect(shop_ids.size() < reward_ids.size(), "Shop source should use a narrower relic pool than reward room")
	_expect(normal_chest_ids.has("guardian_ward"), "Normal chest source should include survival relics")
	_expect(not normal_chest_ids.has("heart_core"), "Normal chest source should exclude higher-value rare health relic")
	_expect(premium_chest_ids.has("heart_core"), "Premium chest source should include Heart Core")
	_expect(boss_chest_ids.has("lucky_primer"), "Boss chest source should include higher-impact rare relics")
	_expect(float(relic_system.call("get_source_rarity_weight", "normal_chest", "common")) > float(relic_system.call("get_source_rarity_weight", "normal_chest", "rare")), "Normal chest should favor common relics")
	_expect(float(relic_system.call("get_source_rarity_weight", "premium_chest", "rare")) > float(relic_system.call("get_source_rarity_weight", "premium_chest", "common")), "Premium chest should favor rare relics over common relics")
	_expect(float(relic_system.call("get_source_rarity_weight", "boss_chest", "epic")) > float(relic_system.call("get_source_rarity_weight", "boss_chest", "common")), "Boss chest should favor high-impact rarities over common relics")


func _verify_triggered_relics(player: Player) -> void:
	player.current_health = player.max_health - 2
	player.health_changed.emit(player.current_health, player.max_health)
	var damaged_health := player.current_health
	for index in range(3):
		Events.enemy_died.emit(null)
		await get_tree().process_frame
	_expect(player.current_health > damaged_health, "Vampire Fang should heal after 3 kills")

	var shield_before := player.get_shield()
	Events.room_cleared.emit(null)
	await get_tree().process_frame
	_expect(player.get_shield() > shield_before, "Guardian Ward should add shield on room clear")

	player.set("_invulnerability_timer", 0.0)
	var health_before_shield_hit := player.current_health
	var shield_before_hit := player.get_shield()
	player.take_damage(1, null)
	await get_tree().process_frame
	_expect(player.current_health == health_before_shield_hit, "Shield should absorb damage before health")
	_expect(player.get_shield() < shield_before_hit, "Shield should decrease after absorbing damage")

	player.current_shield = 0
	player.shield_changed.emit(player.current_shield)
	player.set("_invulnerability_timer", 0.0)
	player.set("_temporary_speed_multiplier", 1.0)
	player.set("_speed_boost_timer", 0.0)
	var speed_before := player.get_current_speed_multiplier()
	player.take_damage(1, null)
	await get_tree().process_frame
	_expect(player.get_current_speed_multiplier() > speed_before, "Adrenaline Charm should increase speed after damage")
	player.call("_tick_timers", 2.2)
	await get_tree().process_frame
	_expect(is_equal_approx(player.get_current_speed_multiplier(), 1.0), "Adrenaline Charm speed boost should expire")


func _verify_reward_room_relic_pickup(main: Node, player: Player, relic_system: Node) -> void:
	var hud = main.get_node_or_null("CanvasLayer/HUD")
	relic_system.call("set_random_seed", 91011)
	var rooms := _get_rooms(main)
	var room := _first_room_by_type(rooms, "reward")
	if room != null:

		await _enter_room(room, player)
		var reward := _find_reward_near(room.global_position)
		if reward != null:
			_expect(reward.has_method("_update_label"), "Reward room reward should be RelicPickup")
			if reward.has_method("claim_for_player"):
				reward.call("claim_for_player", player)
				await get_tree().process_frame
			else:
				player.global_position = reward.global_position
				for index in range(4):
					await get_tree().physics_frame
					await get_tree().process_frame
		else:
			_expect(hud != null and hud.has_method("is_relic_choice_visible") and bool(hud.call("is_relic_choice_visible")), "Reward room should spawn a relic pickup or open relic choice panel")

		_expect(hud != null and hud.has_method("is_relic_choice_visible") and hud.call("is_relic_choice_visible"), "Reward room pickup should open relic choice panel")
		_expect(hud != null and hud.has_method("get_relic_choice_count") and hud.call("get_relic_choice_count") == 3, "Relic choice panel should show 3 choices")
		_expect(room.state == 3, "Reward room should stay CLEARED while waiting for relic choice")
		var pending_choices: Array = main.get("_pending_relic_choices")
		_expect(pending_choices.size() == 3, "Main should store 3 pending relic choices")
		var selected_id := ""
		var selected_stack_before := 0
		if pending_choices.size() > 0:
			_expect(pending_choices[0] is Resource, "First pending relic choice should be a Resource")
			_expect(_unique_choice_count(pending_choices) == pending_choices.size(), "Pending relic choices should not repeat relics")
			_verify_relic_choice_ui(hud, pending_choices)
			selected_id = str(pending_choices[0].get("id"))
			selected_stack_before = int(relic_system.call("get_stack_count", selected_id))
		_expect(hud != null and hud.has_method("choose_relic_for_test"), "HUD should expose test relic choice method")
		if hud != null and hud.has_method("choose_relic_for_test"):
			hud.call("choose_relic_for_test", 0)
		for index in range(3):
			await get_tree().physics_frame
			await get_tree().process_frame

		if selected_id != "":
			_expect(int(relic_system.call("get_stack_count", selected_id)) == selected_stack_before + 1, "Choosing first reward should add the selected relic stack")
		_expect(hud != null and not bool(hud.call("is_relic_choice_visible")), "Relic choice panel should hide after choosing")
		_expect(room.state == 4, "Choosing a relic should mark reward room REWARD_CLAIMED")
		return

	_expect(false, "Generated route should include a reward room")


func _verify_relic_choice_ui(hud: Node, pending_choices: Array) -> void:
	if hud == null:
		_failures.append("HUD should exist for relic choice UI checks")
		return
	if not hud.has_method("get_relic_choice_text") or not hud.has_method("get_relic_choice_font_color"):
		_failures.append("HUD should expose relic choice text and color for tests")
		return

	for index in range(mini(pending_choices.size(), 3)):
		var relic := pending_choices[index] as Resource
		if relic == null:
			continue
		var choice_text := str(hud.call("get_relic_choice_text", index))
		var rarity := str(relic.get("rarity"))
		_expect(choice_text.contains(str(relic.get("display_name"))), "Relic choice text should include display name")
		_expect(choice_text.contains(rarity.capitalize()), "Relic choice text should include rarity")
		_expect(choice_text.contains("Tags:"), "Relic choice text should include tags")
		for tag in _get_relic_tag_names(relic):
			_expect(choice_text.contains(tag), "Relic choice text should include tag %s" % tag)

		var actual_color: Color = hud.call("get_relic_choice_font_color", index)
		var expected_color := _expected_rarity_color(rarity)
		_expect(actual_color.is_equal_approx(expected_color), "Relic choice color should match rarity %s" % rarity)


func _get_relic_tag_names(relic: Resource) -> PackedStringArray:
	var tags := PackedStringArray()
	var raw_tags = relic.get("tags")
	if raw_tags is PackedStringArray:
		for tag in raw_tags:
			tags.append(str(tag).replace("_", " ").capitalize())
	elif raw_tags is Array:
		for tag in raw_tags:
			tags.append(str(tag).replace("_", " ").capitalize())
	return tags


func _expected_rarity_color(rarity: String) -> Color:
	match rarity.to_lower():
		"common":
			return Color(0.86, 0.9, 0.92, 1.0)
		"rare":
			return Color(0.36, 0.72, 1.0, 1.0)
		"epic":
			return Color(0.82, 0.48, 1.0, 1.0)
		"legendary":
			return Color(1.0, 0.72, 0.24, 1.0)
	return Color.WHITE


func _get_rooms(main: Node) -> Array:
	var controller := main.get_node_or_null("DungeonController")
	if controller != null and controller.has_method("get_combat_rooms"):
		return controller.call("get_combat_rooms")

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


func _enter_room(room: Node, player: Player) -> void:
	player.global_position = room.global_position + Vector2(-660, 0)
	await get_tree().physics_frame
	await get_tree().process_frame
	player.global_position = room.global_position
	for index in range(4):
		await get_tree().physics_frame
		await get_tree().process_frame


func _find_reward_near(position: Vector2) -> Node2D:
	for reward in get_tree().get_nodes_in_group("rewards"):
		if not is_instance_valid(reward) or reward.is_queued_for_deletion():
			continue
		var reward_node := reward as Node2D
		if reward_node != null and reward_node.global_position.distance_to(position) < 500.0:
			return reward_node
	return null


func _clear_projectiles() -> void:
	for projectile in get_tree().get_nodes_in_group("projectiles"):
		if is_instance_valid(projectile):
			projectile.queue_free()


func _projectile_count() -> int:
	var count := 0
	for projectile in get_tree().get_nodes_in_group("projectiles"):
		if is_instance_valid(projectile) and not projectile.is_queued_for_deletion():
			count += 1
	return count


func _choice_id_signature(choices: Array) -> String:
	var parts: PackedStringArray = []
	for choice in choices:
		if choice is Resource:
			parts.append(str(choice.get("id")))
	return "|".join(parts)


func _unique_choice_count(choices: Array) -> int:
	var seen := {}
	for choice in choices:
		if choice is Resource:
			seen[str(choice.get("id"))] = true
	return seen.size()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("RelicSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

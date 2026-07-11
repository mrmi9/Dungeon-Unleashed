extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const ROOM_STATE_COMBAT := 2
const ROOM_STATE_CLEARED := 3
const ROOM_STATE_REWARD_CLAIMED := 4
const TOTAL_BIOMES := 3
const MIN_ROUTE_ROOMS := 39
const MAX_ROUTE_ROOMS := 45
const ROOM_ENEMY_SCAN_RADIUS := 720.0
const WAVE_DRAIN_MAX_STEPS := 24

var _failures: Array[String] = []
var _run_completed_seen := false
var _purchases_seen := 0
var _chests_seen := 0
var _events_seen := 0


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
	Events.special_event_resolved.connect(func(_event_node: Node, _player: Node, _event_id: String, _outcome_id: String) -> void:
		_events_seen += 1
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
	var blessing_system := main.get_node_or_null("BlessingSystem")
	var statue_system := main.get_node_or_null("StatueSystem")
	_expect(hud != null, "HUD should exist")
	_expect(player != null, "Player should exist")
	_expect(relic_system != null, "RelicSystem should exist")
	_expect(blessing_system != null, "BlessingSystem should exist")
	_expect(statue_system != null, "StatueSystem should exist")
	_expect(str(main.call("get_run_state_name")) == "Main Menu", "Full run should begin at main menu")
	if hud != null and hud.has_method("is_main_menu_visible"):
		_expect(bool(hud.call("is_main_menu_visible")), "Main menu should be visible before starting")
	if player == null or hud == null or relic_system == null or blessing_system == null or statue_system == null:
		_finish()
		return

	main.call("start_new_run")
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().create_timer(0.15).timeout
	_expect(str(main.call("get_run_state_name")) == "Running", "Starting from menu should enter running state")

	var rooms := _get_rooms(main)
	_expect(rooms.size() >= MIN_ROUTE_ROOMS and rooms.size() <= MAX_ROUTE_ROOMS, "Generated full route should contain 39-45 rooms, got %d: %s" % [rooms.size(), _room_type_signature(rooms)])
	if rooms.size() < MIN_ROUTE_ROOMS:
		_finish()
		return
	_expect(str(rooms[0].get("room_type")) == "start", "Generated full route should start with a start room")
	_expect(str(rooms[rooms.size() - 1].get("room_type")) == "boss", "Generated full route should end with a boss room")
	_expect(_get_room_type_count(rooms, "start") == TOTAL_BIOMES, "Generated full route should include one start per biome")
	_expect(_get_room_type_count(rooms, "boss") == TOTAL_BIOMES, "Generated full route should include one boss per biome")
	_expect(_get_room_type_count(rooms, "event") == TOTAL_BIOMES, "Generated full route should include one event room per biome")
	_expect(_has_room_type(rooms, "trap"), "Generated full route should include a trap branch")
	_expect(_has_room_type(rooms, "reward"), "Generated full route should include at least one reward branch")
	_expect(_has_room_type(rooms, "armory"), "Generated full route should include a weapon armory branch")
	_expect(_has_room_type(rooms, "healing"), "Generated full route should include a healing branch")
	_expect(_has_room_type(rooms, "shop"), "Generated full route should include a shop branch")
	_expect(_has_room_type(rooms, "elite"), "Generated full route should include an elite room")

	for room in rooms:
		var room_type := str(room.get("room_type"))
		if room_type in ["start", "combat", "elite", "challenge"]:
			await _complete_combat_room(room, player, hud)
		elif room_type == "reward":
			await _claim_reward_room(room, player, hud, relic_system)
		elif room_type == "event":
			await _claim_event_room(room, player, hud, relic_system, blessing_system, statue_system)
		elif room_type == "trap":
			await _complete_trap_room(room, player, hud)
		elif room_type == "armory":
			await _claim_armory_room(room, player, hud)
		elif room_type == "healing":
			await _claim_healing_room(room, player, hud)
		elif room_type == "shop":
			await _use_shop_room(room, player)
		elif room_type == "boss":
			await _complete_boss_room(room, player, main)

	await get_tree().process_frame
	var summary: Dictionary = main.call("get_run_summary")
	_expect(_run_completed_seen, "Opening final boss reward chest should complete the run")
	_expect(str(main.call("get_run_state_name")) == "Victory", "Full route should end in Victory")
	_expect(bool(hud.call("is_result_visible")), "Victory should show the result panel")
	_expect(str(hud.call("get_result_title_text")) == "Run Complete", "Victory result title should be Run Complete")
	_expect(int(summary.get("rooms_cleared", 0)) >= rooms.size(), "Full run summary should include all cleared rooms")
	_expect(int(summary.get("kills", 0)) >= 35, "Full run summary should include expanded combat and boss kills")
	_expect(int(summary.get("relic_count", 0)) >= 2, "Full run should collect branch reward relics")
	_expect(int(summary.get("talent_count", 0)) >= TOTAL_BIOMES - 1, "Full run should collect boss talents from non-final biome bosses")
	_expect(summary.has("blessing_count"), "Full run summary should expose blessing count")
	_expect(summary.has("blessing_trigger_count"), "Full run summary should expose blessing trigger count")
	_expect(summary.has("statue_count"), "Full run summary should expose statue count")
	_expect(summary.has("statue_trigger_count"), "Full run summary should expose statue trigger count")
	_expect(summary.has("statue_attunement_count"), "Full run summary should expose statue attunement count")
	_expect(summary.has("projectiles_blocked"), "Full run summary should expose projectile block count")
	_expect(int(summary.get("shop_purchases", 0)) >= 1, "Full run should include a shop purchase")
	_expect(int(summary.get("chests_opened", 0)) >= 9, "Full run should open biome combat, armory, healing, premium, and boss chests")
	_expect(summary.get("boss_defeated", false) == true, "Full run summary should record boss defeat")
	_expect(int(summary.get("bosses_defeated", 0)) == TOTAL_BIOMES, "Full run summary should record all biome boss defeats")
	_expect(int(summary.get("biomes_reached", 0)) == TOTAL_BIOMES, "Full run summary should record reaching final biome")
	_expect(int(summary.get("total_biomes", 0)) == TOTAL_BIOMES, "Full run summary should record total biome count")
	_expect(int(summary.get("events_resolved", 0)) == TOTAL_BIOMES, "Full run summary should record all event rooms")
	var event_names: Array = summary.get("event_names", [])
	var event_records: Array = summary.get("event_records", [])
	var special_room_counts: Dictionary = summary.get("special_room_counts", {})
	var boss_route: Array = summary.get("boss_route", [])
	_expect(event_names.size() == TOTAL_BIOMES, "Full run summary should record one event outcome per biome")
	_expect(event_records.size() == TOTAL_BIOMES, "Full run summary should expose one event record per biome")
	_expect(boss_route.size() == TOTAL_BIOMES, "Full run summary should expose one boss route entry per biome")
	for boss_record in boss_route:
		if boss_record is Dictionary:
			_expect(bool((boss_record as Dictionary).get("cleared", false)), "Full run boss route entries should be cleared")
	_expect(int(special_room_counts.get("event", 0)) == TOTAL_BIOMES, "Full run summary should count all visited event rooms")
	_expect(int(special_room_counts.get("challenge", 0)) >= 1, "Full run summary should count visited challenge rooms")
	_expect(int(special_room_counts.get("trap", 0)) >= 1, "Full run summary should count visited trap rooms")
	_expect(int(special_room_counts.get("reward", 0)) >= 1, "Full run summary should count visited reward rooms")
	_expect(int(special_room_counts.get("armory", 0)) >= 1, "Full run summary should count visited armory rooms")
	_expect(int(special_room_counts.get("healing", 0)) >= 1, "Full run summary should count visited healing rooms")
	_expect(int(special_room_counts.get("elite", 0)) >= 1, "Full run summary should count visited elite rooms")
	_expect(int(special_room_counts.get("shop", 0)) >= 1, "Full run summary should count visited shop rooms")
	_expect(_purchases_seen >= 1, "Full run should emit a shop purchase event")
	_expect(_chests_seen >= 9, "Full run should emit chest opened events")
	_expect(_events_seen == TOTAL_BIOMES, "Full run should emit special event resolved events")
	_expect(str(hud.call("get_result_section_text", "Overview")).contains("Biomes"), "Grouped result should include biome overview details")
	_expect(str(hud.call("get_result_section_text", "Overview")).contains("Boss Route"), "Grouped result should include boss route recap")
	_expect(str(hud.call("get_result_section_text", "Overview")).contains("Final Cleared"), "Grouped result should include final boss route state")
	_expect(str(hud.call("get_result_section_text", "Overview")).contains("Special Rooms"), "Grouped result should include special room route recap")
	_expect(str(hud.call("get_result_section_text", "Build")).contains("Relics:"), "Grouped result should include Build details")
	_expect(str(hud.call("get_result_section_text", "Build")).contains("Talents:"), "Grouped result should include talent Build details")
	_expect(str(hud.call("get_result_section_text", "Build")).contains("Blessings:"), "Grouped result should include blessing Build details")
	_expect(str(hud.call("get_result_section_text", "Loot")).contains("Events"), "Grouped result should include event loot details")
	_expect(str(hud.call("get_result_section_text", "Loot")).contains("Event Outcomes"), "Grouped result should include event outcome details")
	_expect(str(hud.call("get_result_section_text", "Record")).contains("Best Biome"), "Grouped result should include biome record details")
	_expect(hud.has_method("is_result_scroll_available") and bool(hud.call("is_result_scroll_available")), "Full run result should keep grouped sections inside a scroll container")
	_expect(hud.has_method("is_result_details_expanded") and bool(hud.call("is_result_details_expanded")), "Full run result should open in expanded detail mode")
	_expect(hud.has_method("get_result_detail_toggle_text") and str(hud.call("get_result_detail_toggle_text")) == "Compact", "Full run result should expose compact detail mode")
	_expect(hud.has_method("get_visible_result_section_count") and int(hud.call("get_visible_result_section_count")) == 6, "Full run expanded result should show all grouped sections")
	hud.call("toggle_result_detail_mode")
	_expect(int(hud.call("get_visible_result_section_count")) == 3, "Full run compact result should show core sections")
	_expect(str(hud.call("get_result_section_text", "Overview")).contains("Boss Route"), "Full run compact result should retain boss route recap")
	hud.call("toggle_result_detail_mode")

	get_tree().paused = false
	main.queue_free()
	await get_tree().process_frame
	_finish()


func _complete_combat_room(room: Node, player: Player, hud: Node) -> void:
	await _enter_room(room, player)
	_expect(str(room.get("room_type")) in ["start", "combat", "elite", "challenge"], "%s should be a combat route room" % room.get_path())
	if str(room.get("room_type")) == "challenge":
		_expect(bool(room.get("elite_enemies")), "%s should use elite enemy modifiers" % room.get_path())
		_expect(room.has_method("get_challenge_summary"), "%s should expose challenge variant summary" % room.get_path())
		if room.has_method("get_challenge_summary"):
			var challenge_summary: Dictionary = room.call("get_challenge_summary")
			var challenge_variant := str(challenge_summary.get("variant", ""))
			_expect(challenge_variant in ["gauntlet", "hazard_rush"], "%s should resolve a supported challenge variant" % room.get_path())
	_expect(int(room.get("state")) == 2, "%s should enter combat state" % room.get_path())
	if str(room.get("room_type")) == "challenge" and str(room.get("challenge_variant")) == "hazard_rush":
		_expect(room.has_method("is_challenge_hazard_active") and bool(room.call("is_challenge_hazard_active")), "%s hazard rush should activate hazards during combat" % room.get_path())
	var wave_counts = room.get("wave_enemy_counts")
	for wave_index in range(wave_counts.size()):
		var expected_wave_count := int(wave_counts[wave_index])
		var actual_wave_count := _enemy_count_near(room.global_position)
		_expect(actual_wave_count >= expected_wave_count, "%s wave %d should spawn at least configured enemies, expected=%d actual=%d" % [room.get_path(), wave_index + 1, expected_wave_count, actual_wave_count])
		await _drain_active_wave(room)
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


func _claim_event_room(room: Node, player: Player, hud: Node, relic_system: Node, blessing_system: Node, statue_system: Node) -> void:
	await _enter_room(room, player)
	_expect(str(room.get("room_type")) == "event", "Event branch room should be an event room")
	_expect(int(room.get("state")) == 3, "Event room should auto-clear on entry")
	var reward := _find_reward_near(room.global_position)
	var event_summary: Dictionary = {}
	if reward != null and reward.has_method("get_event_summary"):
		event_summary = reward.call("get_event_summary")
	var reward_mode := str(event_summary.get("reward_mode", "blessing_choice"))
	var gold_before := player.current_gold
	var health_before := player.current_health
	var damage_multiplier_before := player.get_damage_multiplier()
	var fire_rate_multiplier_before := player.get_fire_rate_multiplier()
	var rule_summary_before: Dictionary = player.call("get_temporary_rule_summary")
	var temporary_rule_active_before := bool(rule_summary_before.get("active", false))
	var relic_stacks_before := _get_total_relic_stacks(relic_system)
	var blessing_count_before := int(blessing_system.call("get_blessing_count"))
	var statue_count_before := int(statue_system.call("get_statue_count"))
	var statue_attunements_before := _get_total_statue_attunements(statue_system)
	await _collect_reward_near(room.global_position, player, hud, room)
	await _choose_relic_if_prompted(hud)
	_expect(player.current_health == maxi(health_before - 1, 1), "Event room should sacrifice one health")
	match reward_mode:
		"shop_discount":
			var discount_summary: Dictionary = player.call("get_shop_discount_summary")
			_expect(bool(discount_summary.get("active", false)), "Shop discount event should leave an active shop discount")
			_expect(_get_total_relic_stacks(relic_system) >= relic_stacks_before, "Shop discount event should not remove relic progress")
		"cursed_weapon":
			var curse_summary: Dictionary = player.call("get_event_curse_summary")
			_expect(int(curse_summary.get("max_health_penalty", 0)) >= 1, "Cursed weapon event should record a max health curse")
			_expect(player.weapon != null and player.weapon.weapon_data != null, "Cursed weapon event should leave the player with a valid weapon")
			_expect(_get_total_relic_stacks(relic_system) >= relic_stacks_before, "Cursed weapon event should not remove relic progress")
		"temporary_rule":
			var rule_summary: Dictionary = player.call("get_temporary_rule_summary")
			_expect(bool(rule_summary.get("active", false)), "Temporary rule event should leave an active player rule")
			if temporary_rule_active_before:
				_expect(float(rule_summary.get("remaining", 0.0)) > float(rule_summary_before.get("remaining", 0.0)) * 0.5, "Temporary rule event should refresh or preserve its active window")
			else:
				_expect(player.get_damage_multiplier() > damage_multiplier_before, "Temporary rule event should raise damage during the rule window")
				_expect(player.get_fire_rate_multiplier() > fire_rate_multiplier_before, "Temporary rule event should raise fire rate during the rule window")
			_expect(_get_total_relic_stacks(relic_system) >= relic_stacks_before, "Temporary rule event should not remove relic progress")
		"relic_choice":
			_expect(_get_total_relic_stacks(relic_system) > relic_stacks_before, "Relic event should grant a relic reward")
		"statue_choice":
			_expect(int(statue_system.call("get_statue_count")) > statue_count_before, "Statue event should grant a statue reward")
		"statue_attunement":
			_expect(
				int(statue_system.call("get_statue_count")) > statue_count_before or _get_total_statue_attunements(statue_system) > statue_attunements_before,
				"Statue attunement event should attune an owned statue or grant a statue fallback"
			)
		_:
			_expect(player.current_gold > gold_before, "Blessing event should grant gold after sacrifice")
			_expect(_get_total_relic_stacks(relic_system) >= relic_stacks_before, "Blessing event should not remove relic progress")
			_expect(int(blessing_system.call("get_blessing_count")) > blessing_count_before, "Blessing event should grant a blessing reward")
	_expect(int(room.get("state")) == ROOM_STATE_REWARD_CLAIMED, "Event room should mark reward claimed")


func _complete_trap_room(room: Node, player: Player, hud: Node) -> void:
	await _enter_room(room, player)
	_expect(str(room.get("room_type")) == "trap", "Trap branch room should be a trap room")
	_expect(int(room.get("state")) == ROOM_STATE_COMBAT, "Trap room should enter combat state while hazards are active")
	_expect(room.has_method("is_trap_active") and bool(room.call("is_trap_active")), "Trap room should activate hazard cycle")
	player.global_position = (room as Node2D).global_position + Vector2(-520, -285)
	await get_tree().create_timer(float(room.get("trap_survival_duration")) + 0.4).timeout
	await get_tree().physics_frame
	_expect(int(room.get("state")) == ROOM_STATE_CLEARED, "Trap room should clear after survival duration")
	await _collect_reward_near(room.global_position, player, hud, room)
	await _choose_relic_if_prompted(hud)
	_expect(int(room.get("state")) == ROOM_STATE_REWARD_CLAIMED, "Trap room should mark reward claimed")


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
	var items := _get_shop_items_near((room as Node2D).global_position)
	_expect(items.size() == 3, "Shop room should spawn three items")
	var item_to_buy := _first_affordable_item(items, player.current_gold)
	if item_to_buy != null:
		var gold_before := player.current_gold
		_expect(bool(item_to_buy.call("purchase_for_player", player)), "Full run should buy one shop item")
		await get_tree().process_frame
		_expect(player.current_gold < gold_before, "Shop purchase should spend gold")
		_expect(bool(item_to_buy.call("is_sold_out")), "Purchased shop item should sell out")


func _complete_boss_room(room: Node, player: Player, main: Node) -> void:
	await _enter_room(room, player)
	_expect(str(room.get("room_type")) == "boss", "Final room should be boss room")
	var should_complete_run := bool(room.get("complete_run_on_reward"))
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
		if should_complete_run:
			_expect(_run_completed_seen, "Final biome boss reward should complete the run")
			_expect(str(main.call("get_run_state_name")) == "Victory", "Final biome boss reward should enter Victory")
		else:
			_expect(not _run_completed_seen, "Non-final biome boss reward should not complete the run")
			_expect(str(main.call("get_run_state_name")) == "Running", "Non-final biome boss reward should keep the run active")
			await _choose_relic_if_prompted(main.get_node_or_null("CanvasLayer/HUD"))


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
		if hud.has_method("is_blessing_choice_visible") and bool(hud.call("is_blessing_choice_visible")) and hud.has_method("choose_blessing_for_test"):
			hud.call("choose_blessing_for_test", 0)
		elif hud.has_method("is_statue_choice_visible") and bool(hud.call("is_statue_choice_visible")) and hud.has_method("choose_statue_for_test"):
			hud.call("choose_statue_for_test", 0)
		elif hud.has_method("choose_relic_for_test"):
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


func _get_total_statue_attunements(statue_system: Node) -> int:
	if statue_system == null or not statue_system.has_method("get_statue_summaries"):
		return 0
	var total := 0
	var summaries: Array = statue_system.call("get_statue_summaries")
	for summary in summaries:
		if summary is Dictionary:
			total += maxi(int(summary.get("attunements", 0)), 0)
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


func _get_room_type_count(rooms: Array, type_name: String) -> int:
	var count := 0
	for room in rooms:
		if str(room.get("room_type")) == type_name:
			count += 1
	return count


func _drain_active_wave(room: Node) -> void:
	var position: Vector2 = (room as Node2D).global_position
	var step := 0
	while step < WAVE_DRAIN_MAX_STEPS:
		if _enemy_count_near(position) <= 0:
			return
		_kill_enemies_near(position)
		await get_tree().physics_frame
		await get_tree().process_frame
		step += 1
	_expect(_enemy_count_near(position) == 0, "%s should drain dynamic enemy spawns before the next wave" % room.get_path())


func _kill_enemies_near(position: Vector2) -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not _is_live_enemy_near(enemy, position):
			continue
		if enemy.has_method("apply_damage"):
			enemy.call("apply_damage", 9999)


func _enemy_count_near(position: Vector2) -> int:
	var count := 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if _is_live_enemy_near(enemy, position):
			count += 1
	return count


func _is_live_enemy_near(enemy: Node, position: Vector2) -> bool:
	if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
		return false
	if enemy.has_method("is_dead") and enemy.call("is_dead"):
		return false
	var enemy_node := enemy as Node2D
	if enemy_node == null:
		return false
	return enemy_node.global_position.distance_to(position) <= ROOM_ENEMY_SCAN_RADIUS


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


func _get_shop_items_near(position: Vector2) -> Array:
	var items: Array = []
	for item in _get_shop_items():
		var item_node := item as Node2D
		if item_node != null and item_node.global_position.distance_to(position) < 500.0:
			items.append(item)
	return items


func _first_item_by_type(items: Array, type_name: String) -> Node:
	for item in items:
		if is_instance_valid(item) and item.has_method("get_item_type_name") and str(item.call("get_item_type_name")) == type_name:
			return item
	return null


func _first_affordable_item(items: Array, current_gold: int) -> Node:
	for type_name in ["Relic", "Weapon", "Heal"]:
		var item := _first_item_by_type(items, type_name)
		if item != null and item.has_method("get_price") and int(item.call("get_price")) <= current_gold:
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

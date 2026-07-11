extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const ENEMY_PROJECTILE_SCENE := preload("res://scenes/projectiles/EnemyProjectile.tscn")
const MIN_SAFE_SUMMON_DISTANCE := 120.0

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

	var rooms := _get_rooms(main)
	_expect(rooms.size() >= 12, "Main scene should contain the generated branching route")
	if rooms.size() < 12:
		_finish()
		return
	var combat_room := _first_room_by_type(rooms, "combat")
	var reward_room := _first_room_by_type(rooms, "reward")
	var event_room := _first_room_by_type(rooms, "event")
	var trap_room := _first_room_by_type(rooms, "trap")
	var armory_room := _first_room_by_type(rooms, "armory")
	var healing_room := _first_room_by_type(rooms, "healing")
	var elite_room := _first_room_by_type(rooms, "elite")
	var shop_room := _first_room_by_type(rooms, "shop")
	var boss_room := _first_room_by_type(rooms, "boss")
	_expect(combat_room != null, "Generated route should include a combat room")
	_expect(reward_room != null, "Generated route should include a reward room")
	_expect(event_room != null, "Generated route should include an event room")
	_expect(trap_room != null, "Generated route should include a trap room")
	_expect(armory_room != null, "Generated route should include an armory room")
	_expect(healing_room != null, "Generated route should include a healing room")
	_expect(elite_room != null, "Generated route should include an elite room")
	_expect(shop_room != null, "Generated route should include a shop room")
	_expect(boss_room != null, "Generated route should include a boss room")
	if combat_room == null or reward_room == null or event_room == null or trap_room == null or armory_room == null or healing_room == null or elite_room == null or shop_room == null or boss_room == null:
		_finish()
		return

	await _enter_room(rooms[0], player)
	_expect(_spawned_enemy_names().has("Chaser"), "Room01 should spawn Chaser enemies")
	var first_pool := _room_enemy_scene_names(rooms[0])
	_expect(_names_include_type(first_pool, "Rust Skirmisher"), "Biome 1 pool should include Rust Skirmisher")
	_expect(_names_include_type(first_pool, "Ember Marksman"), "Biome 1 pool should include Ember Marksman")
	_expect(_names_include_type(first_pool, "Needle Skater"), "Biome 1 pool should include Needle Skater")
	_expect(_names_include_type(first_pool, "Soot Splitter"), "Biome 1 pool should include Soot Splitter")
	_expect(_spawned_names_match_room_pool(rooms[0]), "Room01 enemies should come from its configured biome pool")
	await _discard_all_enemies()

	await _enter_room(combat_room, player)
	var combat_names := _spawned_enemy_names()
	_expect(not combat_names.is_empty(), "Combat room should spawn enemies")
	_expect(_spawned_names_match_room_pool(combat_room), "Combat room enemies should come from its configured biome pool")
	await _discard_all_enemies()

	await _enter_room(reward_room, player)
	_expect(_spawned_enemy_names_near(reward_room.global_position).is_empty(), "Reward room should not spawn local enemies")
	await _discard_all_enemies()

	await _enter_room(event_room, player)
	_expect(_spawned_enemy_names_near(event_room.global_position).is_empty(), "Event room should not spawn local enemies")
	await _discard_all_enemies()

	await _enter_room(trap_room, player)
	_expect(_spawned_enemy_names_near(trap_room.global_position).is_empty(), "Trap room should not spawn local enemies")
	await _discard_all_enemies()

	await _enter_room(armory_room, player)
	_expect(_spawned_enemy_names_near(armory_room.global_position).is_empty(), "Armory room should not spawn local enemies")
	await _discard_all_enemies()

	await _enter_room(healing_room, player)
	_expect(_spawned_enemy_names_near(healing_room.global_position).is_empty(), "Healing room should not spawn local enemies")
	await _discard_all_enemies()

	await _enter_room(elite_room, player)
	var elite_names := _spawned_enemy_names()
	_expect(not elite_names.is_empty(), "Elite room should spawn enemies")
	_expect(_spawned_names_match_room_pool(elite_room), "Elite room enemies should come from its configured biome pool")
	_expect(_all_spawned_enemies_are_elite(), "Elite room should spawn elite enemy variants")
	_expect(_spawned_elite_modifier_ids().size() >= 2, "Elite room should rotate multiple elite modifier profiles")
	await _discard_all_enemies()

	_verify_later_biome_enemy_pools(rooms)

	await _enter_room(shop_room, player)
	_expect(_spawned_enemy_names_near(shop_room.global_position).is_empty(), "Shop room should not spawn local enemies")
	await _discard_all_enemies()

	await _enter_room(boss_room, player)
	var boss_names := _spawned_enemy_names()
	_expect(boss_names.has("Warrens Gatekeeper"), "Generated first boss room should spawn Warrens Gatekeeper")
	_expect(_boss_count() == 1, "Generated boss room should spawn exactly one boss")
	await _discard_all_enemies()

	await _verify_enemy_projectile_damage(player)
	await _verify_shield_damage_rule()
	await _verify_shield_bash_warning(player)
	await _verify_summoner_behavior(player)
	await _verify_bomber_behavior(player)
	await _verify_charger_windup_warning(player)
	await _verify_barrage_projectile_pattern(player)
	await _verify_zoner_behavior(player)
	await _verify_support_behavior(player)
	await _verify_death_spawn_behavior(player)
	await _verify_elite_profile_application()
	await _verify_elite_death_explosion(player)
	_finish()


func _enter_room(room, player: Player) -> void:
	player.global_position = room.global_position + Vector2(-660, 0)
	await get_tree().physics_frame
	await get_tree().process_frame
	player.global_position = room.global_position
	for index in range(4):
		await get_tree().physics_frame
		await get_tree().process_frame


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


func _spawned_enemy_names() -> PackedStringArray:
	var names := PackedStringArray()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		var display_name = enemy.get("display_name")
		if display_name != null:
			names.append(str(display_name))
	return names


func _spawned_enemy_names_near(position: Vector2, radius: float = 520.0) -> PackedStringArray:
	var names := PackedStringArray()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		var enemy_node := enemy as Node2D
		if enemy_node == null or enemy_node.global_position.distance_to(position) > radius:
			continue
		var display_name = enemy.get("display_name")
		if display_name != null:
			names.append(str(display_name))
	return names


func _discard_all_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy):
			var parent := enemy.get_parent()
			if parent != null:
				parent.remove_child(enemy)
			enemy.free()
	for index in range(2):
		await get_tree().physics_frame
		await get_tree().process_frame


func _verify_enemy_projectile_damage(player: Player) -> void:
	player.global_position = Vector2(-1200, -900)
	player.current_health = player.max_health
	player.current_shield = 0
	player.shield_changed.emit(player.current_shield)
	player.set("_is_dead", false)
	player.set("_invulnerability_timer", 0.0)
	await get_tree().physics_frame
	await get_tree().process_frame

	var start_health := player.current_health
	var projectile := ENEMY_PROJECTILE_SCENE.instantiate() as Node2D
	get_tree().root.add_child(projectile)
	projectile.global_position = player.global_position + Vector2(-80, 0)
	projectile.call("launch", Vector2.RIGHT, 640.0, 1, null)

	for index in range(8):
		await get_tree().physics_frame
		await get_tree().process_frame

	_expect(player.current_health == start_health - 1, "Enemy projectile should damage player once")


func _verify_shield_damage_rule() -> void:
	var shield_scene := load("res://scenes/enemies/ShieldEnemy.tscn") as PackedScene
	var shield := shield_scene.instantiate() as Enemy
	get_tree().root.add_child(shield)
	await get_tree().process_frame
	shield.global_position = Vector2(0, 0)
	shield.rotation = 0.0
	var starting_health = shield.current_health
	shield.call("apply_damage", 2, null, Vector2.LEFT, 0.0)
	_expect(shield.current_health == starting_health - 1, "Shielded enemy should reduce frontal low damage without blocking it completely")
	shield.call("apply_damage", 2, null, Vector2.RIGHT, 0.0)
	_expect(shield.current_health == starting_health - 3, "Shielded enemy should take full damage from behind")
	for index in range(8):
		if not is_instance_valid(shield) or shield.is_queued_for_deletion():
			break
		if shield.has_method("is_dead") and bool(shield.call("is_dead")):
			break
		shield.call("apply_damage", 1, null, Vector2.LEFT, 0.0)
	await get_tree().process_frame
	_expect(not is_instance_valid(shield) or shield.is_queued_for_deletion() or bool(shield.call("is_dead")), "Shielded enemy should be killable from the front with low-damage weapons")
	if is_instance_valid(shield) and not shield.is_queued_for_deletion():
		shield.queue_free()


func _verify_summoner_behavior(player: Player) -> void:
	await _discard_all_enemies()
	await _discard_all_danger_warnings()
	var summoner_scene := load("res://scenes/enemies/SummonerEnemy.tscn") as PackedScene
	var summoner := summoner_scene.instantiate()
	get_tree().root.add_child(summoner)
	summoner.global_position = player.global_position + Vector2(280, 0)
	await get_tree().process_frame
	summoner.set_physics_process(false)
	summoner.set("target", player)
	_expect(summoner.has_method("can_deal_contact_damage") and not bool(summoner.call("can_deal_contact_damage")), "Newly spawned enemies should have contact damage grace")
	summoner.set("utility_action_windup", 0.35)
	summoner.set("_attack_timer", 0.0)
	summoner.call("_update_summoner")
	summoner.call("_tick_action_sprite", 0.0)
	await get_tree().process_frame

	_expect(_danger_warning_count_by_purpose("summon") >= 2, "Summoner should mark each pending minion position before spawning")
	_expect(_enemy_action_cue_has_shape("summon", "diamonds"), "Summon windup should show a multi-diamond cue that remains readable without color")
	_expect(_enemy_count_by_name("Chaser") == 0, "Summoner should not create minions before its utility windup finishes")
	var telegraph_summary := summoner.call("get_attack_telegraph_summary") as Dictionary
	_expect(str(telegraph_summary.get("utility_action", "")) == "summon", "Summoner should expose active summon windup state")
	_expect(_telegraph_uses_active_action_frame(telegraph_summary), "Summoner should use an anticipation or peak sprite frame during summon windup")
	_expect((telegraph_summary.get("pending_summon_positions", PackedVector2Array()) as PackedVector2Array).size() >= 2, "Summoner should preserve warned spawn positions until completion")
	summoner.call("_tick_utility_windup", 0.36)
	_advance_enemy_action_cues("summon", 0.36)
	await get_tree().process_frame

	_expect(not _enemy_action_cue_has_shape("summon", "diamonds"), "Summon action cue should clear when the utility windup completes")
	_expect(_enemy_count_by_name("Chaser") >= 2, "Summoner should create Chaser minions")
	_expect(_nearest_enemy_distance_to(player.global_position, "Chaser") >= MIN_SAFE_SUMMON_DISTANCE, "Summoner minions should spawn away from the player")
	summoner.set("utility_action_windup", 0.05)
	for cycle in range(6):
		summoner.set("_attack_timer", 0.0)
		summoner.call("_update_summoner")
		summoner.call("_tick_utility_windup", 0.06)
		await get_tree().process_frame
	_expect(_enemy_count_by_name("Chaser") <= int(summoner.get("max_active_summons")), "Summoner should cap active Chaser minions")
	await _discard_all_enemies()
	await _discard_all_danger_warnings()


func _verify_shield_bash_warning(player: Player) -> void:
	await _discard_all_enemies()
	await _discard_all_danger_warnings()
	player.global_position = Vector2(-1200, -900)

	var shield_scene := load("res://scenes/enemies/ShieldEnemy.tscn") as PackedScene
	var shield := shield_scene.instantiate() as Enemy
	get_tree().root.add_child(shield)
	shield.global_position = player.global_position + Vector2(82, 0)
	await get_tree().process_frame
	player.current_health = player.max_health
	player.current_shield = 0
	player.shield_changed.emit(player.current_shield)
	player.set("_invulnerability_timer", 0.0)
	player.set("_contact_damage_timer", 0.0)
	var start_health := player.current_health
	shield.set("shield_bash_windup", 0.4)
	shield.set("_attack_timer", 0.0)

	for index in range(4):
		await get_tree().physics_frame
		await get_tree().process_frame

	_expect(_danger_warning_has_purpose("shield_bash"), "Shielded enemy should expose a dedicated shield-bash warning")
	_expect(_danger_warning_has_shape("line"), "Shield bash should telegraph its short movement lane")
	_expect(_enemy_action_cue_has_shape("shield_bash", "chevrons"), "Shield bash should show a direction-shaped chevron cue above the enemy")
	var telegraph_summary := shield.call("get_attack_telegraph_summary") as Dictionary
	_expect(str(telegraph_summary.get("utility_action", "")) == "shield_bash", "Shielded enemy should remain in bash windup while its lane is visible")
	_expect(_telegraph_uses_active_action_frame(telegraph_summary), "Shielded enemy should use an anticipation or peak sprite frame during bash windup")
	var position_before_bash := shield.global_position
	await get_tree().create_timer(0.43).timeout
	for index in range(3):
		await get_tree().physics_frame
		await get_tree().process_frame
	telegraph_summary = shield.call("get_attack_telegraph_summary") as Dictionary
	_expect(bool(telegraph_summary.get("shield_bash_active", false)) or shield.global_position.distance_to(position_before_bash) > 1.0, "Shielded enemy should enter its short bash after the warning finishes")
	await get_tree().create_timer(float(shield.get("shield_bash_duration")) + 0.08).timeout
	for index in range(3):
		await get_tree().physics_frame
		await get_tree().process_frame
	_expect(player.current_health < start_health, "Shield bash should reuse the existing enemy contact-damage path")
	await _discard_all_danger_warnings()
	await _discard_all_enemies()


func _verify_bomber_behavior(player: Player) -> void:
	await _discard_all_enemies()
	await _discard_all_danger_warnings()
	player.current_health = player.max_health
	player.current_shield = 0
	player.shield_changed.emit(player.current_shield)
	player.set("_is_dead", false)
	player.set("_invulnerability_timer", 0.0)
	var start_health := player.current_health

	var bomber_scene := load("res://scenes/enemies/BomberEnemy.tscn") as PackedScene
	var bomber := bomber_scene.instantiate()
	get_tree().root.add_child(bomber)
	bomber.global_position = player.global_position + Vector2(48, 0)
	bomber.set("_attack_timer", 0.0)

	for index in range(4):
		await get_tree().physics_frame
		await get_tree().process_frame

	_expect(_danger_warning_count() > 0, "Bomber should telegraph its self-destruct radius before exploding")
	_expect(_danger_warning_has_shape("circle"), "Bomber self-destruct warning should use a circular danger area")
	_expect(_danger_warning_has_purpose("self_destruct"), "Bomber warning should expose self-destruct purpose")
	_expect(_danger_warning_has_readability_outline(), "Bomber self-destruct warning should expose a readable outline")
	_expect(_telegraph_uses_active_action_frame(bomber.call("get_attack_telegraph_summary") as Dictionary), "Bomber should use an anticipation or peak sprite frame while pressurizing")
	_expect(player.current_health == start_health, "Bomber self-destruct warning should not damage before the windup finishes")

	for index in range(70):
		player.set("_invulnerability_timer", 0.0)
		await get_tree().physics_frame
		await get_tree().process_frame

	_expect(player.current_health < start_health, "Bomber should damage player after self-destruct windup")
	await _discard_all_enemies()
	await _discard_all_danger_warnings()


func _verify_charger_windup_warning(player: Player) -> void:
	await _discard_all_enemies()
	await _discard_all_danger_warnings()
	player.global_position = Vector2(-1200, -900)

	var charger_scene := load("res://scenes/enemies/ChargerEnemy.tscn") as PackedScene
	var charger := charger_scene.instantiate()
	get_tree().root.add_child(charger)
	charger.global_position = player.global_position + Vector2(180, 0)
	await get_tree().process_frame
	charger.set("_attack_timer", 0.0)

	for index in range(4):
		await get_tree().physics_frame
		await get_tree().process_frame

	_expect(_danger_warning_count() > 0, "Charger should telegraph its charge lane before lunging")
	_expect(_danger_warning_has_purpose("charge"), "Charger warning should expose charge purpose")
	_expect(_danger_warning_has_readability_outline(), "Charger lane warning should expose a readable outline")
	_expect(_telegraph_uses_active_action_frame(charger.call("get_attack_telegraph_summary") as Dictionary), "Charger should use an anticipation or peak sprite frame during charge windup")
	_expect(int(charger.get("_charge_state")) == 1, "Charger should remain in windup while charge warning is visible")
	await _discard_all_danger_warnings()
	await _discard_all_enemies()


func _verify_barrage_projectile_pattern(player: Player) -> void:
	await _discard_all_enemies()
	await _discard_all_enemy_projectiles()
	player.global_position = Vector2(-1200, -900)

	var totem_scene := load("res://scenes/enemies/BarrageTotem.tscn") as PackedScene
	var totem := totem_scene.instantiate()
	get_tree().root.add_child(totem)
	totem.global_position = player.global_position + Vector2(320, 0)
	await get_tree().process_frame
	totem.set("projectile_attack_windup", 0.55)
	totem.set("_attack_timer", 0.0)

	for index in range(4):
		await get_tree().physics_frame
		await get_tree().process_frame

	_expect(_danger_warning_count() >= 5, "Barrage Totem should telegraph spread projectiles before firing")
	_expect(_danger_warning_has_purpose("projectile"), "Ranged warning should expose projectile purpose")
	_expect(_danger_warning_has_readability_outline(), "Barrage Totem projectile warnings should expose readable outlines")
	_expect(_telegraph_uses_active_action_frame(totem.call("get_attack_telegraph_summary") as Dictionary), "Ranged enemy should use an anticipation or peak sprite frame before firing")
	_expect(_enemy_projectile_count() == 0, "Barrage Totem should not fire before projectile windup finishes")
	await get_tree().create_timer(float(totem.get("projectile_attack_windup")) + 0.08).timeout
	await get_tree().physics_frame
	await get_tree().process_frame

	_expect(_enemy_projectile_count() >= 5, "Barrage Totem should fire a spread projectile pattern")
	await _discard_all_danger_warnings()
	await _discard_all_enemy_projectiles()
	await _discard_all_enemies()


func _verify_zoner_behavior(player: Player) -> void:
	await _discard_all_enemies()
	await _discard_all_danger_warnings()
	player.global_position = Vector2(-1200, -900)

	var zoner_scene := load("res://scenes/enemies/MireConduit.tscn") as PackedScene
	var zoner := zoner_scene.instantiate()
	get_tree().root.add_child(zoner)
	zoner.global_position = player.global_position + Vector2(280, 0)
	await get_tree().process_frame
	zoner.set("_attack_timer", 0.0)

	for index in range(4):
		await get_tree().physics_frame
		await get_tree().process_frame

	_expect(_danger_warning_count() > 0, "Zoner enemy should create a readable danger warning")
	_expect(_danger_warning_has_purpose("zone"), "Zoner warning should expose zone purpose")
	_expect(_danger_warning_has_readability_outline(), "Zoner danger warning should expose a readable outline")
	_expect(_telegraph_uses_active_action_frame(zoner.call("get_attack_telegraph_summary") as Dictionary), "Zoner should use an anticipation or peak sprite frame while shaping its danger area")
	await _discard_all_danger_warnings()
	await _discard_all_enemies()


func _verify_support_behavior(player: Player) -> void:
	await _discard_all_enemies()
	await _discard_all_danger_warnings()
	player.global_position = Vector2(-1200, -900)

	var chaser_scene := load("res://scenes/enemies/ChaserEnemy.tscn") as PackedScene
	var mender_scene := load("res://scenes/enemies/GraveMender.tscn") as PackedScene
	var injured := chaser_scene.instantiate()
	var mender := mender_scene.instantiate()
	get_tree().root.add_child(injured)
	get_tree().root.add_child(mender)
	injured.global_position = player.global_position + Vector2(280, 0)
	mender.global_position = injured.global_position + Vector2(60, 0)
	await get_tree().process_frame
	mender.set_physics_process(false)
	mender.set("target", player)
	injured.set("current_health", 1)
	mender.set("utility_action_windup", 0.35)
	mender.set("_attack_timer", 0.0)
	mender.call("_update_support")
	mender.call("_tick_action_sprite", 0.0)
	await get_tree().process_frame

	_expect(_danger_warning_has_purpose("support"), "Support enemy should show a dedicated healing-range warning")
	_expect(_enemy_action_cue_has_shape("support", "cross"), "Support windup should show a cross cue that remains readable without color")
	_expect(int(injured.get("current_health")) == 1, "Support enemy should not heal before its utility windup finishes")
	var telegraph_summary := mender.call("get_attack_telegraph_summary") as Dictionary
	_expect(str(telegraph_summary.get("utility_action", "")) == "support", "Support enemy should expose active support windup state")
	_expect(_telegraph_uses_active_action_frame(telegraph_summary), "Support enemy should use an anticipation or peak sprite frame during healing windup")
	mender.call("_tick_utility_windup", 0.36)
	_advance_enemy_action_cues("support", 0.36)
	await get_tree().process_frame

	_expect(int(injured.get("current_health")) > 1, "Support enemy should heal nearby damaged allies")
	await _discard_all_enemies()
	await _discard_all_danger_warnings()


func _verify_death_spawn_behavior(player: Player) -> void:
	await _discard_all_enemies()
	player.global_position = Vector2(-1200, -900)

	var splitter_scene := load("res://scenes/enemies/SootSplitter.tscn") as PackedScene
	var splitter := splitter_scene.instantiate()
	get_tree().root.add_child(splitter)
	splitter.global_position = player.global_position + Vector2(260, 0)
	await get_tree().process_frame
	splitter.call("apply_damage", 9999, null, Vector2.RIGHT, 0.0)

	for index in range(3):
		await get_tree().physics_frame
		await get_tree().process_frame

	_expect(_enemy_count_by_name("Rust Skirmisher") >= 2, "Death-spawn enemy should create Rust Skirmisher minions")
	await _discard_all_enemies()


func _verify_elite_profile_application() -> void:
	await _discard_all_enemies()
	var profile := load("res://resources/elite_modifiers/quickened.tres") as Resource
	var chaser_scene := load("res://scenes/enemies/ChaserEnemy.tscn") as PackedScene
	var elite := chaser_scene.instantiate()
	get_tree().root.add_child(elite)
	await get_tree().process_frame
	var base_speed := float(elite.get("move_speed"))
	var base_cooldown := float(elite.get("attack_cooldown"))
	elite.call("apply_elite_profile", profile)
	_expect(bool(elite.get("is_elite")), "Elite profile should mark enemy as elite")
	_expect(str(elite.get("elite_modifier_id")) == "quickened", "Elite profile should store modifier id")
	_expect(str(elite.get("display_name")).begins_with("Quickened "), "Elite profile should prefix display name")
	_expect(elite.has_method("get_damage_source_summary"), "Elite enemy should expose damage source summary")
	var elite_source: Dictionary = elite.call("get_damage_source_summary")
	_expect(str(elite_source.get("source_type", "")) == "enemy", "Elite source summary should remain enemy type")
	_expect(str(elite_source.get("elite_modifier_id", "")) == "quickened", "Elite source summary should expose modifier id")
	_expect(str(elite_source.get("source_name", "")).begins_with("Quickened "), "Elite source summary should expose elite display name")
	_expect(str(elite_source.get("source_threat_intel", "")).contains("Enemy Threat"), "Elite source summary should expose threat intel")
	_expect((elite_source.get("source_counter_tags", []) as Array).size() >= 1, "Elite source summary should expose counter build tags")
	_expect(float(elite.get("move_speed")) > base_speed, "Quickened elite profile should increase movement speed")
	_expect(float(elite.get("attack_cooldown")) < base_cooldown, "Quickened elite profile should reduce attack cooldown")
	var elite_visual: Dictionary = elite.call("get_elite_visual_summary")
	_expect(bool(elite_visual.get("enabled", false)), "Quickened elite should enable its dedicated aura")
	_expect(str(elite_visual.get("pattern", "")) == "velocity", "Quickened elite should expose velocity-trail visual semantics")
	_expect(int(elite_visual.get("motif_count", 0)) >= 3, "Quickened elite aura should expose readable repeated geometry")
	var elite_trait: Dictionary = elite.call("get_elite_trait_summary")
	_expect(str(elite_trait.get("id", "")) == "overclock", "Quickened elite should expose its overclock combat trait")
	_expect(float(elite_trait.get("interval", 0.0)) >= 4.0, "Quickened overclock should preserve a readable repeat interval")
	if is_instance_valid(elite):
		elite.queue_free()
	await get_tree().process_frame


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


func _names_include_type(names: PackedStringArray, base_name: String) -> bool:
	for enemy_name in names:
		if enemy_name == base_name or enemy_name.ends_with(" %s" % base_name):
			return true
	return false


func _spawned_names_match_room_pool(room: Node) -> bool:
	var pool := _room_enemy_scene_names(room)
	if pool.is_empty():
		return false
	for enemy_name in _spawned_enemy_names():
		if not _enemy_name_matches_pool(enemy_name, pool):
			return false
	return true


func _enemy_name_matches_pool(enemy_name: String, pool: PackedStringArray) -> bool:
	for base_name in pool:
		if enemy_name == base_name or enemy_name.ends_with(" %s" % base_name):
			return true
	return false


func _room_enemy_scene_names(room: Node) -> PackedStringArray:
	var names := PackedStringArray()
	var scenes: Array = room.get("enemy_scenes")
	for scene in scenes:
		if scene is PackedScene:
			var name := _enemy_name_from_scene(scene)
			if not name.is_empty() and not names.has(name):
				names.append(name)
	return names


func _enemy_name_from_scene(scene: PackedScene) -> String:
	var path := scene.resource_path.get_file().get_basename()
	match path:
		"ChaserEnemy":
			return "Chaser"
		"RustSkirmisher":
			return "Rust Skirmisher"
		"ShooterEnemy":
			return "Shooter"
		"EmberMarksman":
			return "Ember Marksman"
		"NeedleSkater":
			return "Needle Skater"
		"SootSplitter":
			return "Soot Splitter"
		"ChargerEnemy":
			return "Charger"
		"IronBreaker":
			return "Iron Breaker"
		"MireConduit":
			return "Mire Conduit"
		"GraveMender":
			return "Grave Mender"
		"SummonerEnemy":
			return "Summoner"
		"RiftCaller":
			return "Rift Caller"
		"ShieldEnemy":
			return "Shielded"
		"AegisDrone":
			return "Aegis Drone"
		"BomberEnemy":
			return "Bomber"
		"VolatileVessel":
			return "Volatile Vessel"
		"BarrageTotem":
			return "Barrage Totem"
		"NullAcolyte":
			return "Null Acolyte"
		"BossEnemy":
			return "Dungeon Core"
		"WarrensGatekeeper":
			return "Warrens Gatekeeper"
		"IronBulwark":
			return "Iron Bulwark"
		"VoidFoundryHeart":
			return "Void Foundry Heart"
	return path


func _verify_later_biome_enemy_pools(rooms: Array) -> void:
	var biome_two_room := _first_room_by_biome_and_type(rooms, 2, "combat")
	var biome_three_room := _first_room_by_biome_and_type(rooms, 3, "combat")
	_expect(biome_two_room != null, "Generated route should include a biome 2 combat room")
	_expect(biome_three_room != null, "Generated route should include a biome 3 combat room")
	if biome_two_room != null:
		var biome_two_pool := _room_enemy_scene_names(biome_two_room)
		_expect(_names_include_type(biome_two_pool, "Charger"), "Biome 2 pool should include Charger")
		_expect(_names_include_type(biome_two_pool, "Summoner"), "Biome 2 pool should include Summoner")
		_expect(_names_include_type(biome_two_pool, "Shielded"), "Biome 2 pool should include Shielded")
		_expect(_names_include_type(biome_two_pool, "Iron Breaker"), "Biome 2 pool should include Iron Breaker")
		_expect(_names_include_type(biome_two_pool, "Aegis Drone"), "Biome 2 pool should include Aegis Drone")
		_expect(_names_include_type(biome_two_pool, "Mire Conduit"), "Biome 2 pool should include Mire Conduit")
		_expect(_names_include_type(biome_two_pool, "Grave Mender"), "Biome 2 pool should include Grave Mender")
	if biome_three_room != null:
		var biome_three_pool := _room_enemy_scene_names(biome_three_room)
		_expect(_names_include_type(biome_three_pool, "Bomber"), "Biome 3 pool should include Bomber")
		_expect(_names_include_type(biome_three_pool, "Summoner"), "Biome 3 pool should include Summoner")
		_expect(_names_include_type(biome_three_pool, "Shielded"), "Biome 3 pool should include Shielded")
		_expect(_names_include_type(biome_three_pool, "Volatile Vessel"), "Biome 3 pool should include Volatile Vessel")
		_expect(_names_include_type(biome_three_pool, "Rift Caller"), "Biome 3 pool should include Rift Caller")
		_expect(_names_include_type(biome_three_pool, "Needle Skater"), "Biome 3 pool should include Needle Skater")
		_expect(_names_include_type(biome_three_pool, "Barrage Totem"), "Biome 3 pool should include Barrage Totem")
		_expect(_names_include_type(biome_three_pool, "Null Acolyte"), "Biome 3 pool should include Null Acolyte")


func _first_room_by_biome_and_type(rooms: Array, biome_index: int, room_type: String) -> Node:
	var main := get_tree().root.find_child("Main", true, false)
	if main == null:
		return null
	var controller := main.get_node_or_null("DungeonController")
	if controller == null or not controller.has_method("get_room_records"):
		return null
	var records: Array = controller.call("get_room_records")
	for index in range(mini(records.size(), rooms.size())):
		var record = records[index]
		if record is Dictionary and int(record.get("biome_index", 0)) == biome_index and str(record.get("room_type", "")) == room_type:
			return rooms[index]
	return null


func _all_spawned_enemies_are_elite() -> bool:
	var checked := 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		checked += 1
		if not bool(enemy.get("is_elite")):
			return false
	return checked > 0


func _spawned_elite_modifier_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		if not bool(enemy.get("is_elite")):
			continue
		var id := str(enemy.get("elite_modifier_id"))
		if not id.is_empty() and not ids.has(id):
			ids.append(id)
	return ids


func _boss_count() -> int:
	var count := 0
	for boss in get_tree().get_nodes_in_group("bosses"):
		if is_instance_valid(boss) and not boss.is_queued_for_deletion():
			count += 1
	return count


func _enemy_projectile_count() -> int:
	var count := 0
	for projectile in get_tree().get_nodes_in_group("enemy_projectiles"):
		if is_instance_valid(projectile) and not projectile.is_queued_for_deletion():
			count += 1
	return count


func _verify_elite_death_explosion(player: Player) -> void:
	await _discard_all_enemies()
	await _discard_all_danger_warnings()
	get_tree().paused = false
	player.set("_is_dead", false)
	player.current_health = player.max_health
	player.current_shield = 0
	player.shield_changed.emit(player.current_shield)
	player.set("_invulnerability_timer", 0.0)
	player.global_position = Vector2(-1200, -900)
	await get_tree().physics_frame
	await get_tree().process_frame
	player.set("_invulnerability_timer", 0.0)
	var start_health := player.current_health

	var chaser_scene := load("res://scenes/enemies/ChaserEnemy.tscn") as PackedScene
	var elite := chaser_scene.instantiate()
	get_tree().root.add_child(elite)
	elite.global_position = player.global_position + Vector2(88, 0)
	await get_tree().process_frame
	elite.call("apply_elite_modifiers", 1.8, 1.35, 120.0, 1)
	_expect(bool(elite.get("is_elite")), "Elite modifier should mark enemy as elite")
	_expect(int(elite.get("max_health")) > 3, "Elite modifier should increase max health")
	elite.call("apply_damage", 9999, null, Vector2.RIGHT, 0.0)
	player.set("_invulnerability_timer", 0.0)
	for index in range(4):
		await get_tree().physics_frame
		await get_tree().process_frame
	_expect(_danger_warning_count() > 0, "Elite death explosion should create a warning before damage")
	_expect(_danger_warning_has_purpose("elite_death"), "Elite explosion warning should expose elite-death purpose")
	_expect(_danger_warning_has_readability_outline(), "Elite death explosion warning should expose a readable outline")
	player.global_position = Vector2(-1200, -900)
	player.set("_invulnerability_timer", 0.0)
	for index in range(45):
		player.global_position = Vector2(-1200, -900)
		player.set("_invulnerability_timer", 0.0)
		await get_tree().physics_frame
		await get_tree().process_frame
		if player.current_health < start_health:
			break
	_expect(player.current_health < start_health, "Elite death explosion should damage nearby player")
	await _discard_all_enemies()
	await _discard_all_danger_warnings()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _danger_warning_count() -> int:
	var count := 0
	for warning in get_tree().get_nodes_in_group("danger_warnings"):
		if is_instance_valid(warning) and not warning.is_queued_for_deletion():
			count += 1
	return count


func _danger_warning_count_by_purpose(expected_purpose: String) -> int:
	var count := 0
	for warning in get_tree().get_nodes_in_group("danger_warnings"):
		if not is_instance_valid(warning) or warning.is_queued_for_deletion():
			continue
		if warning.has_method("get_warning_purpose_for_test") and str(warning.call("get_warning_purpose_for_test")) == expected_purpose:
			count += 1
	return count


func _danger_warning_has_purpose(expected_purpose: String) -> bool:
	return _danger_warning_count_by_purpose(expected_purpose) > 0


func _danger_warning_has_readability_outline() -> bool:
	for warning in get_tree().get_nodes_in_group("danger_warnings"):
		if not is_instance_valid(warning) or warning.is_queued_for_deletion():
			continue
		if warning.has_method("has_readability_outline_for_test") and bool(warning.call("has_readability_outline_for_test")):
			return true
	return false


func _danger_warning_has_shape(expected_shape: String) -> bool:
	for warning in get_tree().get_nodes_in_group("danger_warnings"):
		if not is_instance_valid(warning) or warning.is_queued_for_deletion():
			continue
		if warning.has_method("get_warning_shape_name_for_test") and str(warning.call("get_warning_shape_name_for_test")) == expected_shape:
			return true
	return false


func _enemy_action_cue_has_shape(expected_action: String, expected_shape: String) -> bool:
	for cue in get_tree().get_nodes_in_group("enemy_action_cues"):
		if not is_instance_valid(cue) or cue.is_queued_for_deletion():
			continue
		if not cue.has_method("get_action_id_for_test") or not cue.has_method("get_shape_signature_for_test"):
			continue
		if str(cue.call("get_action_id_for_test")) == expected_action and str(cue.call("get_shape_signature_for_test")) == expected_shape:
			return true
	return false


func _advance_enemy_action_cues(expected_action: String, delta: float) -> void:
	for cue in get_tree().get_nodes_in_group("enemy_action_cues"):
		if not is_instance_valid(cue) or cue.is_queued_for_deletion() or not cue.has_method("get_action_id_for_test"):
			continue
		if str(cue.call("get_action_id_for_test")) == expected_action:
			cue.call("_process", delta)


func _telegraph_uses_active_action_frame(telegraph_summary: Dictionary) -> bool:
	var sprite_summary = telegraph_summary.get("action_sprite", {})
	if not sprite_summary is Dictionary:
		return false
	var summary := sprite_summary as Dictionary
	return bool(summary.get("enabled", false)) and int(summary.get("frame", -1)) in [1, 2]


func _discard_all_danger_warnings() -> void:
	for warning in get_tree().get_nodes_in_group("danger_warnings"):
		if is_instance_valid(warning):
			warning.queue_free()
	await get_tree().physics_frame


func _discard_all_enemy_projectiles() -> void:
	for projectile in get_tree().get_nodes_in_group("enemy_projectiles"):
		if is_instance_valid(projectile):
			projectile.queue_free()
	await get_tree().physics_frame


func _finish() -> void:
	if _failures.is_empty():
		print("EnemyVarietySmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

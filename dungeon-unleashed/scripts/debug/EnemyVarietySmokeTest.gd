extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const ENEMY_PROJECTILE_SCENE := preload("res://scenes/projectiles/EnemyProjectile.tscn")

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
	_expect(rooms.size() >= 10, "Main scene should contain the generated branching route")
	if rooms.size() < 10:
		_finish()
		return
	var combat_room := _first_room_by_type(rooms, "combat")
	var reward_room := _first_room_by_type(rooms, "reward")
	var elite_room := _first_room_by_type(rooms, "elite")
	var shop_room := _first_room_by_type(rooms, "shop")
	var boss_room := _first_room_by_type(rooms, "boss")
	_expect(combat_room != null, "Generated route should include a combat room")
	_expect(reward_room != null, "Generated route should include a reward room")
	_expect(elite_room != null, "Generated route should include an elite room")
	_expect(shop_room != null, "Generated route should include a shop room")
	_expect(boss_room != null, "Generated route should include a boss room")
	if combat_room == null or reward_room == null or elite_room == null or shop_room == null or boss_room == null:
		_finish()
		return

	await _enter_room(rooms[0], player)
	_expect(_spawned_enemy_names().has("Chaser"), "Room01 should spawn Chaser enemies")
	_expect(not _spawned_enemy_names().has("Shooter"), "Room01 first wave should not spawn Shooter enemies")
	await _discard_all_enemies()

	await _enter_room(combat_room, player)
	var combat_names := _spawned_enemy_names()
	_expect(combat_names.has("Chaser"), "Combat room should include Chaser enemies")
	_expect(combat_names.has("Shooter"), "Combat room should include Shooter enemies")
	_expect(combat_names.has("Bomber"), "Combat room should include Bomber enemies")
	await _discard_all_enemies()

	await _enter_room(reward_room, player)
	_expect(_spawned_enemy_names_near(reward_room.global_position).is_empty(), "Reward room should not spawn local enemies")
	await _discard_all_enemies()

	await _enter_room(elite_room, player)
	var elite_names := _spawned_enemy_names()
	_expect(_names_include_type(elite_names, "Shooter"), "Elite room should include Shooter enemies")
	_expect(_names_include_type(elite_names, "Charger"), "Elite room should include Charger enemies")
	_expect(_names_include_type(elite_names, "Summoner"), "Elite room should include Summoner enemies")
	_expect(_names_include_type(elite_names, "Shielded"), "Elite room should include Shielded enemies")
	_expect(_all_spawned_enemies_are_elite(), "Elite room should spawn elite enemy variants")
	await _discard_all_enemies()

	await _enter_room(shop_room, player)
	_expect(_spawned_enemy_names_near(shop_room.global_position).is_empty(), "Shop room should not spawn local enemies")
	await _discard_all_enemies()

	await _enter_room(boss_room, player)
	var boss_names := _spawned_enemy_names()
	_expect(boss_names.has("Dungeon Core"), "Generated boss room should spawn Dungeon Core")
	_expect(_boss_count() == 1, "Generated boss room should spawn exactly one boss")
	await _discard_all_enemies()

	await _verify_enemy_projectile_damage(player)
	await _verify_shield_damage_rule()
	await _verify_summoner_behavior(player)
	await _verify_bomber_behavior(player)
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
	var shield := shield_scene.instantiate()
	get_tree().root.add_child(shield)
	await get_tree().process_frame
	shield.global_position = Vector2(0, 0)
	shield.rotation = 0.0
	var starting_health = shield.current_health
	shield.call("apply_damage", 2, null, Vector2.LEFT, 0.0)
	_expect(shield.current_health == starting_health, "Shielded enemy should block frontal low damage")
	shield.call("apply_damage", 2, null, Vector2.RIGHT, 0.0)
	_expect(shield.current_health < starting_health, "Shielded enemy should take damage from behind")
	shield.queue_free()


func _verify_summoner_behavior(player: Player) -> void:
	await _discard_all_enemies()
	var summoner_scene := load("res://scenes/enemies/SummonerEnemy.tscn") as PackedScene
	var summoner := summoner_scene.instantiate()
	get_tree().root.add_child(summoner)
	summoner.global_position = player.global_position + Vector2(280, 0)
	await get_tree().process_frame
	summoner.set("_attack_timer", 0.0)

	for index in range(4):
		await get_tree().physics_frame
		await get_tree().process_frame

	_expect(_enemy_count_by_name("Chaser") >= 2, "Summoner should create Chaser minions")
	await _discard_all_enemies()


func _verify_bomber_behavior(player: Player) -> void:
	await _discard_all_enemies()
	player.current_health = player.max_health
	player.set("_invulnerability_timer", 0.0)
	var start_health := player.current_health

	var bomber_scene := load("res://scenes/enemies/BomberEnemy.tscn") as PackedScene
	var bomber := bomber_scene.instantiate()
	get_tree().root.add_child(bomber)
	bomber.global_position = player.global_position + Vector2(48, 0)

	for index in range(70):
		await get_tree().physics_frame
		await get_tree().process_frame

	_expect(player.current_health < start_health, "Bomber should damage player after self-destruct windup")
	await _discard_all_enemies()


func _enemy_count_by_name(display_name: String) -> int:
	var count := 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		if str(enemy.get("display_name")) == display_name:
			count += 1
	return count


func _names_include_type(names: PackedStringArray, base_name: String) -> bool:
	for enemy_name in names:
		if enemy_name == base_name or enemy_name.ends_with(" %s" % base_name):
			return true
	return false


func _all_spawned_enemies_are_elite() -> bool:
	var checked := 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		checked += 1
		if not bool(enemy.get("is_elite")):
			return false
	return checked > 0


func _boss_count() -> int:
	var count := 0
	for boss in get_tree().get_nodes_in_group("bosses"):
		if is_instance_valid(boss) and not boss.is_queued_for_deletion():
			count += 1
	return count


func _verify_elite_death_explosion(player: Player) -> void:
	await _discard_all_enemies()
	player.current_health = player.max_health
	player.current_shield = 0
	player.set("_invulnerability_timer", 0.0)
	player.global_position = Vector2.ZERO
	var start_health := player.current_health

	var chaser_scene := load("res://scenes/enemies/ChaserEnemy.tscn") as PackedScene
	var elite := chaser_scene.instantiate()
	get_tree().root.add_child(elite)
	elite.global_position = player.global_position + Vector2(32, 0)
	await get_tree().process_frame
	elite.call("apply_elite_modifiers", 1.8, 1.35, 120.0, 1)
	_expect(bool(elite.get("is_elite")), "Elite modifier should mark enemy as elite")
	_expect(int(elite.get("max_health")) > 3, "Elite modifier should increase max health")
	elite.call("apply_damage", 9999, null, Vector2.RIGHT, 0.0)
	for index in range(4):
		await get_tree().physics_frame
		await get_tree().process_frame
	_expect(_danger_warning_count() > 0, "Elite death explosion should create a warning before damage")
	await get_tree().create_timer(0.6).timeout
	await get_tree().physics_frame
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


func _discard_all_danger_warnings() -> void:
	for warning in get_tree().get_nodes_in_group("danger_warnings"):
		if is_instance_valid(warning):
			warning.queue_free()
	await get_tree().physics_frame


func _finish() -> void:
	if _failures.is_empty():
		print("EnemyVarietySmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const GUARD_CLEAVER := preload("res://resources/weapons/guard_cleaver.tres")
const ENEMY_PROJECTILE_SCENE := preload("res://scenes/projectiles/EnemyProjectile.tscn")
const CHASER_SCENE := preload("res://scenes/enemies/ChaserEnemy.tscn")

var _failures: Array[String] = []
var _block_event_count := 0
var _last_blocked_count := 0
var _last_block_position := Vector2.ZERO
var _last_block_weapon: Resource


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	if main.has_method("start_new_run"):
		main.call("start_new_run")

	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().create_timer(0.12).timeout

	var player := main.get_node_or_null("Player") as Player
	_expect(player != null, "Player should exist")
	if player == null:
		_finish()
		return

	var weapon := player.weapon
	_expect(weapon != null, "Player should have a weapon node")
	if weapon == null:
		_finish()
		return

	var guard_data := GUARD_CLEAVER.duplicate() as WeaponData
	guard_data.energy_cost = 0
	guard_data.projectile_block_radius = 168.0
	guard_data.projectile_block_arc_degrees = 150.0
	guard_data.projectile_block_damage = 1
	guard_data.crit_chance = 0.0
	weapon.set_weapon_data(guard_data)
	player.global_position = Vector2(-1200, -900)
	player.recover_energy(player.max_energy)
	await get_tree().process_frame

	var blocked_projectile := ENEMY_PROJECTILE_SCENE.instantiate() as EnemyProjectile
	_add_test_node(blocked_projectile)
	blocked_projectile.global_position = weapon.muzzle.global_position + Vector2(138, 0)
	var expected_block_position := blocked_projectile.global_position
	blocked_projectile.call("launch", Vector2.LEFT, 480.0, 1, null)

	var outside_projectile := ENEMY_PROJECTILE_SCENE.instantiate() as EnemyProjectile
	_add_test_node(outside_projectile)
	outside_projectile.global_position = weapon.muzzle.global_position + Vector2(-138, 0)
	outside_projectile.call("launch", Vector2.RIGHT, 480.0, 1, null)

	var enemy := CHASER_SCENE.instantiate() as Enemy
	_add_test_node(enemy)
	enemy.global_position = blocked_projectile.global_position + Vector2(8, 0)
	enemy.current_health = 8
	enemy.max_health = 8
	var health_before := enemy.current_health

	_block_event_count = 0
	_last_blocked_count = 0
	_last_block_position = Vector2.ZERO
	_last_block_weapon = null
	Events.player_projectile_blocked.connect(_on_player_projectile_blocked)

	var fired := weapon.try_fire(weapon.muzzle.global_position + Vector2(220, 0), player)
	await get_tree().process_frame
	if Events.player_projectile_blocked.is_connected(_on_player_projectile_blocked):
		Events.player_projectile_blocked.disconnect(_on_player_projectile_blocked)

	_expect(fired, "Guard Cleaver should fire")
	_expect(int(weapon.get_meta(&"last_blocked_projectiles", 0)) == 1, "Guard Cleaver should record one blocked projectile")
	_expect(_block_event_count == 1, "Guard Cleaver should emit one projectile block feedback event")
	_expect(_last_blocked_count == 1, "Projectile block feedback should report blocked projectile count")
	_expect(_last_block_weapon == guard_data, "Projectile block feedback should expose the blocking weapon data")
	_expect(_last_block_position.distance_to(expected_block_position) <= 32.0, "Projectile block feedback should expose the block position")
	_expect(not is_instance_valid(blocked_projectile) or blocked_projectile.is_queued_for_deletion(), "Blocked projectile should be removed")
	_expect(is_instance_valid(outside_projectile) and not outside_projectile.is_queued_for_deletion(), "Projectile behind the player should not be blocked")
	_expect(enemy.current_health < health_before, "Projectile block should apply counter damage near blocked projectile")

	_finish()


func _on_player_projectile_blocked(_player: Node, weapon_data: Resource, blocked_count: int, block_position: Vector2) -> void:
	_block_event_count += 1
	_last_blocked_count = blocked_count
	_last_block_position = block_position
	_last_block_weapon = weapon_data


func _add_test_node(node: Node) -> void:
	var parent := get_tree().current_scene
	if parent == null:
		parent = get_tree().root
	parent.add_child(node)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if Events.player_projectile_blocked.is_connected(_on_player_projectile_blocked):
		Events.player_projectile_blocked.disconnect(_on_player_projectile_blocked)
	get_tree().paused = false
	if _failures.is_empty():
		print("ProjectileBlockSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

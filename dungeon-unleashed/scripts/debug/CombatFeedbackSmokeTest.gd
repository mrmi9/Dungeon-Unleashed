extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const PROJECTILE_SCENE := preload("res://scenes/projectiles/Projectile.tscn")
const ENEMY_PROJECTILE_SCENE := preload("res://scenes/projectiles/EnemyProjectile.tscn")
const CHASER_SCENE := preload("res://scenes/enemies/ChaserEnemy.tscn")
const SHOOTER_SCENE := preload("res://scenes/enemies/ShooterEnemy.tscn")

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

	var player := main.get_node_or_null("Player") as Player
	_expect(player != null, "Player should exist")
	_expect(main.has_method("get_floating_text_count"), "Main should expose floating text count")
	if player == null:
		_finish()
		return

	var count_before := int(main.call("get_floating_text_count"))
	Events.projectile_hit.emit(null, player, 2)
	Events.projectile_critical_hit.emit(null, player, 6)

	player.current_health = maxi(player.max_health - 2, 1)
	player.health_changed.emit(player.current_health, player.max_health)
	player.heal(1)
	player.add_shield(2)
	player.set("_invulnerability_timer", 0.0)
	player.take_damage(3, null)

	await get_tree().process_frame
	var texts := _collect_floating_texts()
	_expect(int(main.call("get_floating_text_count")) >= count_before + 6, "Combat feedback should spawn floating text for damage, crit, heal, shield, shield block, and hurt")
	_expect(_has_text_containing(texts, "-2"), "Normal projectile hit should show damage text")
	_expect(_has_text_containing(texts, "CRIT 6"), "Critical hit should show crit damage text")
	_expect(_has_text_containing(texts, "+1 HP"), "Healing should show HP floating text")
	_expect(_has_text_containing(texts, "+2 SH"), "Shield gain should show shield floating text")
	_expect(_has_text_containing(texts, "-2 SH"), "Shield absorption should show blocked shield floating text")
	_expect(_has_text_containing(texts, "-1"), "Player damage should show hurt floating text")

	await get_tree().create_timer(1.25).timeout
	await get_tree().process_frame
	var count_after_cleanup := int(main.call("get_floating_text_count"))
	_expect(count_after_cleanup <= count_before, "Floating text should clean itself up after its duration, expected at most %d got %d" % [count_before, count_after_cleanup])

	await _verify_projectile_hit_feedback_position(main)
	await _verify_enemy_projectile_after_owner_death(player)

	get_tree().paused = false
	main.queue_free()
	await get_tree().process_frame
	_finish()


func _collect_floating_texts() -> Array[String]:
	var texts: Array[String] = []
	for node in get_tree().get_nodes_in_group("floating_text"):
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		if node.has_method("get_text"):
			texts.append(str(node.call("get_text")))
	return texts


func _has_text_containing(texts: Array[String], needle: String) -> bool:
	for text in texts:
		if text.contains(needle):
			return true
	return false


func _verify_projectile_hit_feedback_position(main: Node) -> void:
	_clear_floating_texts()
	var hit_position := Vector2(420, -180)
	var enemy := CHASER_SCENE.instantiate()
	get_tree().root.add_child(enemy)
	enemy.global_position = hit_position + Vector2(12, 0)
	await get_tree().process_frame

	var projectile := PROJECTILE_SCENE.instantiate() as Projectile
	get_tree().root.add_child(projectile)
	projectile.global_position = hit_position
	projectile.damage = 5
	projectile.knockback = 0.0
	projectile.crit_chance = 0.0
	projectile.call("_handle_collision", enemy)
	await get_tree().process_frame

	var snapshots: Array = main.call("get_floating_text_snapshots")
	var found_near_hit := false
	for snapshot in snapshots:
		if not (snapshot is Dictionary):
			continue
		if not str(snapshot.get("text", "")).contains("-5"):
			continue
		var position: Vector2 = snapshot.get("position", Vector2.ZERO)
		if position.distance_to(hit_position) <= 28.0:
			found_near_hit = true
			break
	_expect(found_near_hit, "Enemy damage floating text should appear near the projectile hit position")

	if is_instance_valid(enemy):
		enemy.queue_free()
	if is_instance_valid(projectile):
		projectile.queue_free()
	_clear_floating_texts()


func _verify_enemy_projectile_after_owner_death(player: Player) -> void:
	_clear_enemy_projectiles()
	_clear_enemies()
	player.set("_is_dead", false)
	player.current_health = player.max_health
	player.current_shield = 0
	player.set("_invulnerability_timer", 0.0)
	player.global_position = Vector2(-1200, -760)
	await get_tree().physics_frame
	await get_tree().process_frame

	var shooter := SHOOTER_SCENE.instantiate()
	get_tree().root.add_child(shooter)
	shooter.global_position = player.global_position + Vector2(-220, 0)
	await get_tree().process_frame

	var projectile := ENEMY_PROJECTILE_SCENE.instantiate() as EnemyProjectile
	get_tree().root.add_child(projectile)
	projectile.global_position = player.global_position + Vector2(-96, 0)
	projectile.call("launch", Vector2.RIGHT, 720.0, 1, shooter)
	shooter.call("apply_damage", 9999, null, Vector2.ZERO, 0.0)
	await get_tree().process_frame

	var start_health := player.current_health
	player.set("_invulnerability_timer", 0.0)
	for index in range(8):
		await get_tree().physics_frame
		await get_tree().process_frame
	_expect(player.current_health == start_health - 1, "Enemy projectile should safely damage player after its owner dies")

	_clear_enemy_projectiles()
	_clear_enemies()


func _clear_floating_texts() -> void:
	for node in get_tree().get_nodes_in_group("floating_text"):
		if is_instance_valid(node):
			node.queue_free()


func _clear_enemy_projectiles() -> void:
	for projectile in get_tree().get_nodes_in_group("enemy_projectiles"):
		if is_instance_valid(projectile):
			projectile.queue_free()


func _clear_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy):
			enemy.queue_free()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	get_tree().paused = false
	if _failures.is_empty():
		print("CombatFeedbackSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

extends Node

const WARRENS_GATEKEEPER := preload("res://scenes/enemies/WarrensGatekeeper.tscn")
const IRON_BULWARK := preload("res://scenes/enemies/IronBulwark.tscn")
const VOID_FOUNDRY_HEART := preload("res://scenes/enemies/VoidFoundryHeart.tscn")

var _failures: Array[String] = []


class TestTarget:
	extends Node2D
	var damage_taken := 0

	func is_alive() -> bool:
		return true

	func take_damage(amount: int, _source: Node = null) -> void:
		damage_taken += maxi(amount, 0)


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var target := TestTarget.new()
	target.name = "SignatureTarget"
	target.add_to_group("player")
	get_tree().current_scene.add_child(target)
	target.global_position = Vector2(420.0, 320.0)

	await _verify_pincer_gates(target)
	await _verify_bastion_lock(target)
	await _verify_void_bloom(target)
	target.queue_free()
	_finish()


func _verify_pincer_gates(target: Node2D) -> void:
	var boss := await _spawn_boss(WARRENS_GATEKEEPER, target, Vector2(120.0, 320.0))
	_expect(str(boss.get("signature_attack")) == "pincer_gates", "Warrens Gatekeeper should configure Pincer Gates")
	boss.call("_start_signature_attack")
	boss.call("_tick_boss_action_sprite", 0.0)
	_expect(int(boss.call("get_action_sprite_summary").get("frame", -1)) == 2, "Pincer Gates should use its signature peak frame")
	var summary: Dictionary = boss.call("get_signature_attack_summary")
	_expect(str(summary.get("display_name", "")) == "Pincer Gates", "Pincer Gates should expose a readable signature name")
	_expect(int(summary.get("uses", 0)) == 1, "Pincer Gates should record its use")
	_expect(_danger_warning_count() == 2, "Pincer Gates should telegraph two converging lanes")
	_expect(_danger_warning_shape_count("line") == 2, "Pincer Gates telegraphs should use line warnings")
	await get_tree().create_timer(float(boss.get("signature_windup")) + 0.08).timeout
	_expect(_enemy_projectile_count() >= int(boss.get("signature_projectile_count")), "Pincer Gates should fire its configured two-sided volley")
	await _clear_signature_nodes(boss)


func _verify_bastion_lock(target: Node2D) -> void:
	var boss := await _spawn_boss(IRON_BULWARK, target, Vector2(120.0, 320.0))
	_expect(str(boss.get("signature_attack")) == "bastion_lock", "Iron Bulwark should configure Bastion Lock")
	boss.call("_start_signature_attack")
	boss.call("_tick_boss_action_sprite", 0.0)
	_expect(int(boss.call("get_action_sprite_summary").get("frame", -1)) == 2, "Bastion Lock should use its signature peak frame")
	_expect(bool(boss.call("is_signature_guard_active")), "Bastion Lock should activate a temporary guard window")
	_expect(_danger_warning_shape_count("circle") == 1, "Bastion Lock should telegraph its radial release")
	var health_before := int(boss.get("current_health"))
	boss.call("apply_damage", 10, null, Vector2.ZERO, 0.0)
	var expected_damage := maxi(roundi(10.0 * float(boss.get("signature_guard_damage_multiplier"))), 1)
	_expect(int(boss.get("current_health")) == health_before - expected_damage, "Bastion Lock should reduce incoming damage during guard")
	var summary: Dictionary = boss.call("get_signature_attack_summary")
	_expect(bool(summary.get("guard_active", false)), "Bastion Lock summary should expose active guard state")
	await get_tree().create_timer(float(boss.get("signature_windup")) + 0.08).timeout
	_expect(_enemy_projectile_count() >= int(boss.get("signature_projectile_count")), "Bastion Lock should release a radial projectile pattern")
	await _clear_signature_nodes(boss)


func _verify_void_bloom(target: Node2D) -> void:
	var boss := await _spawn_boss(VOID_FOUNDRY_HEART, target, Vector2(120.0, 320.0))
	_expect(str(boss.get("signature_attack")) == "void_bloom", "Void Foundry Heart should configure Void Bloom")
	var damage_before := int(target.get("damage_taken"))
	boss.call("_start_signature_attack")
	boss.call("_tick_boss_action_sprite", 0.0)
	_expect(int(boss.call("get_action_sprite_summary").get("frame", -1)) == 2, "Void Bloom should use its signature peak frame")
	_expect(_danger_warning_shape_count("circle") == 1, "Void Bloom should telegraph a target-centered circle")
	_expect(_nearest_warning_distance(target.global_position) <= 1.0, "Void Bloom warning should snapshot the target position")
	_expect(_warning_source_exists("void_foundry_heart", "boss"), "Void Bloom warning should preserve boss source identity")
	await get_tree().create_timer(float(boss.get("signature_windup")) + 0.08).timeout
	_expect(int(target.get("damage_taken")) > damage_before, "Remaining inside Void Bloom should deal telegraphed damage")
	_expect(_enemy_projectile_count() >= int(boss.get("signature_projectile_count")), "Void Bloom should erupt into its configured projectile ring")
	await _clear_signature_nodes(boss)


func _spawn_boss(scene: PackedScene, target: Node2D, position: Vector2) -> Node:
	_clear_enemy_projectiles()
	_clear_danger_warnings()
	await get_tree().process_frame
	var boss := scene.instantiate()
	boss.set("signature_windup", 0.08)
	boss.set("attack_cooldown", 99.0)
	get_tree().current_scene.add_child(boss)
	boss.global_position = position
	boss.set("target", target)
	boss.set_physics_process(false)
	return boss


func _clear_signature_nodes(boss: Node) -> void:
	_clear_enemy_projectiles()
	_clear_danger_warnings()
	if boss != null and is_instance_valid(boss):
		boss.queue_free()
	await get_tree().process_frame


func _enemy_projectile_count() -> int:
	var count := 0
	for projectile in get_tree().get_nodes_in_group("enemy_projectiles"):
		if is_instance_valid(projectile) and not projectile.is_queued_for_deletion():
			count += 1
	return count


func _danger_warning_count() -> int:
	var count := 0
	for warning in get_tree().get_nodes_in_group("danger_warnings"):
		if is_instance_valid(warning) and not warning.is_queued_for_deletion():
			count += 1
	return count


func _danger_warning_shape_count(shape_name: String) -> int:
	var count := 0
	for warning in get_tree().get_nodes_in_group("danger_warnings"):
		if not is_instance_valid(warning) or warning.is_queued_for_deletion():
			continue
		if warning.has_method("get_warning_shape_name_for_test") and str(warning.call("get_warning_shape_name_for_test")) == shape_name:
			count += 1
	return count


func _nearest_warning_distance(position: Vector2) -> float:
	var nearest := INF
	for warning in get_tree().get_nodes_in_group("danger_warnings"):
		if warning is Node2D and is_instance_valid(warning) and not warning.is_queued_for_deletion():
			nearest = minf(nearest, (warning as Node2D).global_position.distance_to(position))
	return nearest


func _warning_source_exists(source_id: String, source_type: String) -> bool:
	for warning in get_tree().get_nodes_in_group("danger_warnings"):
		if not is_instance_valid(warning) or warning.is_queued_for_deletion() or not warning.has_method("get_damage_source_summary"):
			continue
		var summary = warning.call("get_damage_source_summary")
		if summary is Dictionary and str(summary.get("source_id", "")) == source_id and str(summary.get("source_type", "")) == source_type:
			return true
	return false


func _clear_enemy_projectiles() -> void:
	for projectile in get_tree().get_nodes_in_group("enemy_projectiles"):
		if is_instance_valid(projectile):
			projectile.queue_free()


func _clear_danger_warnings() -> void:
	for warning in get_tree().get_nodes_in_group("danger_warnings"):
		if is_instance_valid(warning):
			warning.queue_free()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("BossSignatureSmokeTest passed.")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

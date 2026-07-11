extends Node

const CHASER_SCENE := preload("res://scenes/enemies/ChaserEnemy.tscn")
const SHOOTER_SCENE := preload("res://scenes/enemies/ShooterEnemy.tscn")

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	await _verify_blazing()
	await _verify_bulwark()
	await _verify_quickened()
	await _verify_volatile()
	await _verify_sharpshot()
	await _verify_titan()
	_finish()


func _verify_blazing() -> void:
	var enemy := await _spawn_elite(CHASER_SCENE, "res://resources/elite_modifiers/blazing.tres")
	_expect(str(enemy.get_elite_trait_summary().get("id", "")) == "scorch_pulse", "Blazing elite should expose scorch pulse")
	enemy.set("_elite_trait_timer", 0.0)
	enemy.call("_tick_elite_trait", 0.0)
	_expect(_warning_purpose_count("elite_scorch") == 1, "Blazing scorch pulse should create one semantic warning")
	_expect(_warning_damage_for_purpose("elite_scorch") >= 1, "Blazing scorch pulse warning should deal damage after its windup")
	await _clear_case(enemy)


func _verify_bulwark() -> void:
	var enemy := await _spawn_elite(CHASER_SCENE, "res://resources/elite_modifiers/bulwark.tres")
	var health_before := enemy.current_health
	enemy.apply_damage(10, null, Vector2.ZERO, 0.0)
	_expect(health_before - enemy.current_health == 7, "Bulwark guarded core should reduce ten damage to seven")
	_expect(is_equal_approx(float(enemy.get_elite_trait_summary().get("damage_taken_multiplier", 1.0)), 0.68), "Bulwark summary should expose guarded-core multiplier")
	await _clear_case(enemy)


func _verify_quickened() -> void:
	var enemy := await _spawn_elite(CHASER_SCENE, "res://resources/elite_modifiers/quickened.tres")
	enemy.set("_elite_trait_timer", 0.0)
	enemy.call("_tick_elite_trait", 0.0)
	_expect(_warning_purpose_count("elite_overclock") == 1, "Quickened overclock should telegraph before accelerating")
	var windup := float(enemy.get_elite_trait_summary().get("windup", 0.0))
	_expect(float(enemy.get_elite_trait_summary().get("windup_remaining", 0.0)) > 0.0, "Quickened overclock should enter windup")
	enemy.call("_tick_elite_trait", windup + 0.01)
	_expect(float(enemy.get_elite_trait_summary().get("active_remaining", 0.0)) > 0.0, "Quickened overclock should activate after windup")
	_expect(is_equal_approx(enemy.get_elite_move_speed_multiplier(), 1.45), "Quickened overclock should apply its active movement multiplier")
	await _clear_case(enemy)


func _verify_volatile() -> void:
	var enemy := await _spawn_elite(CHASER_SCENE, "res://resources/elite_modifiers/volatile.tres")
	var cooldown_before := enemy.attack_cooldown
	var damage_to_half := ceili(float(enemy.current_health) * 0.52)
	enemy.apply_damage(damage_to_half, null, Vector2.ZERO, 0.0)
	_expect(bool(enemy.get_elite_trait_summary().get("volatile_triggered", false)), "Volatile core should destabilize below half health")
	_expect(enemy.attack_cooldown < cooldown_before, "Volatile core should accelerate attacks after destabilizing")
	_expect(_warning_purpose_count("elite_volatile_core") == 1, "Volatile core should announce its half-health state change")
	await _clear_case(enemy)


func _verify_sharpshot() -> void:
	_clear_warnings()
	var enemy := SHOOTER_SCENE.instantiate() as Enemy
	enemy.max_health = 100
	add_child(enemy)
	enemy.set_physics_process(false)
	var base_projectile_count := enemy.projectile_count
	var profile := load("res://resources/elite_modifiers/sharpshot.tres") as Resource
	enemy.apply_elite_profile(profile)
	_expect(str(enemy.get_elite_trait_summary().get("id", "")) == "focused_fire", "Sharpshot elite should expose focused fire")
	_expect(enemy.projectile_count == base_projectile_count + 2, "Sharpshot focused fire should add two projectile lanes")
	_expect(enemy.projectile_attack_windup >= 0.28, "Sharpshot focused fire should preserve readable projectile windup")
	await _clear_case(enemy)


func _verify_titan() -> void:
	var enemy := CHASER_SCENE.instantiate() as Enemy
	enemy.max_health = 100
	add_child(enemy)
	enemy.set_physics_process(false)
	var base_contact_damage := enemy.contact_damage
	var profile := load("res://resources/elite_modifiers/titan.tres") as Resource
	enemy.apply_elite_profile(profile)
	enemy.apply_damage(1, null, Vector2.RIGHT, 100.0)
	var knockback_velocity := enemy.get("_knockback_velocity") as Vector2
	_expect(str(enemy.get_elite_trait_summary().get("id", "")) == "unstoppable", "Titan elite should expose unstoppable trait")
	_expect(enemy.contact_damage > base_contact_damage, "Titan unstoppable trait should increase contact pressure")
	_expect(is_equal_approx(knockback_velocity.length(), 20.0), "Titan unstoppable trait should reduce incoming knockback to twenty percent")
	await _clear_case(enemy)


func _spawn_elite(scene: PackedScene, profile_path: String) -> Enemy:
	_clear_warnings()
	var enemy := scene.instantiate() as Enemy
	enemy.max_health = 100
	add_child(enemy)
	enemy.position = Vector2(-500.0, -500.0)
	enemy.set_physics_process(false)
	var profile := load(profile_path) as Resource
	enemy.apply_elite_profile(profile)
	return enemy


func _warning_purpose_count(purpose: String) -> int:
	var count := 0
	for warning in get_tree().get_nodes_in_group("danger_warnings"):
		if is_instance_valid(warning) and not warning.is_queued_for_deletion() and warning.has_method("get_warning_purpose_for_test"):
			if str(warning.call("get_warning_purpose_for_test")) == purpose:
				count += 1
	return count


func _warning_damage_for_purpose(purpose: String) -> int:
	for warning in get_tree().get_nodes_in_group("danger_warnings"):
		if not is_instance_valid(warning) or warning.is_queued_for_deletion() or not warning.has_method("get_warning_purpose_for_test"):
			continue
		if str(warning.call("get_warning_purpose_for_test")) == purpose:
			return int(warning.get("damage"))
	return 0


func _clear_case(enemy: Node) -> void:
	_clear_warnings()
	if enemy != null and is_instance_valid(enemy):
		enemy.queue_free()
	await get_tree().process_frame


func _clear_warnings() -> void:
	for warning in get_tree().get_nodes_in_group("danger_warnings"):
		if is_instance_valid(warning):
			warning.queue_free()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("EliteTraitSmokeTest passed.")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

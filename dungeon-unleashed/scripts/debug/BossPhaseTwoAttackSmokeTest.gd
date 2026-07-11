extends Node

const BOSS_CASES := [
	{
		"scene": preload("res://scenes/enemies/WarrensGatekeeper.tscn"),
		"attack": "warren_sweep",
		"name": "Warren Sweep",
		"warning_shape": "line",
		"warning_count": 3,
		"projectile_multiplier": 1,
	},
	{
		"scene": preload("res://scenes/enemies/IronBulwark.tscn"),
		"attack": "iron_quake",
		"name": "Iron Quake",
		"warning_shape": "circle",
		"warning_count": 1,
		"projectile_multiplier": 2,
	},
	{
		"scene": preload("res://scenes/enemies/VoidFoundryHeart.tscn"),
		"attack": "rift_cross",
		"name": "Rift Cross",
		"warning_shape": "line",
		"warning_count": 4,
		"projectile_multiplier": 1,
	},
]

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
	target.name = "PhaseTwoTarget"
	target.add_to_group("player")
	get_tree().current_scene.add_child(target)
	target.global_position = Vector2(460.0, 320.0)
	for boss_case in BOSS_CASES:
		await _verify_phase_two_attack(boss_case, target)
	target.queue_free()
	_finish()


func _verify_phase_two_attack(boss_case: Dictionary, target: Node2D) -> void:
	_clear_enemy_projectiles()
	_clear_danger_warnings()
	await get_tree().process_frame
	var scene := boss_case.get("scene") as PackedScene
	var boss := scene.instantiate() as BossEnemy
	_expect(boss != null, "Phase-two boss scene should instantiate")
	if boss == null:
		return
	get_tree().current_scene.add_child(boss)
	boss.global_position = Vector2(140.0, 320.0)
	boss.target = target
	boss.set_physics_process(false)
	boss.set("_phase", 2)
	boss.phase_two_attack_windup = 0.08
	var attack_id := str(boss_case.get("attack", ""))
	_expect(boss.phase_two_attack == attack_id, "%s should configure its phase-two attack" % boss.display_name)
	boss.call("_start_phase_two_attack")
	boss.call("_tick_boss_action_sprite", 0.0)
	var summary := boss.get_phase_two_attack_summary()
	_expect(str(summary.get("id", "")) == attack_id, "%s summary should expose its configured id" % boss.display_name)
	_expect(str(summary.get("display_name", "")) == str(boss_case.get("name", "")), "%s summary should expose a readable name" % boss.display_name)
	_expect(int(summary.get("uses", 0)) == 1, "%s should record direct phase-two attack use" % boss.display_name)
	_expect(int(boss.get_action_sprite_summary().get("frame", -1)) == 2, "%s phase-two attack should use the action peak frame" % boss.display_name)
	_expect(_warning_shape_count(str(boss_case.get("warning_shape", ""))) == int(boss_case.get("warning_count", 0)), "%s should create its configured warning geometry" % boss.display_name)
	_expect(_warning_purpose_count(attack_id) == int(boss_case.get("warning_count", 0)), "%s warnings should expose semantic purpose" % boss.display_name)
	_expect(_warning_source_exists(str(boss.source_id), "boss"), "%s warnings should preserve boss source identity" % boss.display_name)

	var extra_wait := 0.22 if attack_id == "iron_quake" else 0.06
	await get_tree().create_timer(boss.phase_two_attack_windup + extra_wait).timeout
	var expected_projectiles := boss.phase_two_attack_projectile_count * int(boss_case.get("projectile_multiplier", 1))
	_expect(_enemy_projectile_count() >= expected_projectiles, "%s should release its configured projectile pattern" % boss.display_name)

	_clear_enemy_projectiles()
	_clear_danger_warnings()
	boss.set("_phase_two_attack_count", 0)
	boss.set("_attack_index", 4)
	boss.set("_attack_timer", 0.0)
	boss.call("_tick_attack", 0.0)
	_expect(int(boss.get_phase_two_attack_summary().get("uses", 0)) == 1, "%s fifth phase-two attack slot should route to its second exclusive pattern" % boss.display_name)
	boss.queue_free()
	await get_tree().process_frame


func _enemy_projectile_count() -> int:
	var count := 0
	for projectile in get_tree().get_nodes_in_group("enemy_projectiles"):
		if is_instance_valid(projectile) and not projectile.is_queued_for_deletion():
			count += 1
	return count


func _warning_shape_count(shape_name: String) -> int:
	var count := 0
	for warning in get_tree().get_nodes_in_group("danger_warnings"):
		if is_instance_valid(warning) and not warning.is_queued_for_deletion() and warning.has_method("get_warning_shape_name_for_test"):
			if str(warning.call("get_warning_shape_name_for_test")) == shape_name:
				count += 1
	return count


func _warning_purpose_count(purpose: String) -> int:
	var count := 0
	for warning in get_tree().get_nodes_in_group("danger_warnings"):
		if is_instance_valid(warning) and not warning.is_queued_for_deletion() and warning.has_method("get_warning_purpose_for_test"):
			if str(warning.call("get_warning_purpose_for_test")) == purpose:
				count += 1
	return count


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
		print("BossPhaseTwoAttackSmokeTest passed.")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const PROJECTILE_SCENE := preload("res://scenes/projectiles/Projectile.tscn")

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
	await get_tree().create_timer(0.1).timeout

	var player := main.get_node("Player") as Player
	_expect(player != null, "Player should exist")
	if player == null:
		_finish()
		return

	_expect(player.weapon_loadout.size() == 3, "Player should have 3 weapons in loadout")

	for index in range(player.weapon_loadout.size()):
		var data := player.weapon_loadout[index]
		player.call("_equip_weapon", index)
		await get_tree().process_frame

		_clear_projectiles()
		var weapon := player.weapon
		var fired := weapon.try_fire(player.global_position + Vector2(320, 0), player)
		await get_tree().process_frame

		_expect(fired, "%s should fire" % data.display_name)
		_expect(_projectile_count() == maxi(data.projectile_count, 1), "%s projectile count should match WeaponData" % data.display_name)
		_expect(weapon.get_current_ammo() == weapon.get_magazine_size() - 1, "%s should consume one ammo per trigger pull" % data.display_name)

		if data.id == &"energy_staff":
			var projectile := get_tree().get_first_node_in_group("projectiles")
			_expect(projectile != null and projectile.get("_remaining_pierce") == data.pierce_count, "Energy Staff projectile should carry pierce count")

	player.call("_equip_weapon", 0)
	await get_tree().process_frame
	var pistol := player.weapon
	_clear_projectiles()
	for index in range(pistol.get_magazine_size()):
		pistol.try_fire(player.global_position + Vector2(320, 0), player)
		await get_tree().create_timer(1.0 / pistol.weapon_data.fire_rate + 0.02).timeout

	_expect(pistol.get_current_ammo() == 0, "Pistol magazine should reach 0 after firing full magazine")
	_expect(pistol.is_reloading(), "Pistol should auto reload after empty magazine")
	await get_tree().create_timer(pistol.weapon_data.reload_duration + 0.1).timeout
	_expect(not pistol.is_reloading(), "Pistol reload should finish")
	_expect(pistol.get_current_ammo() == pistol.get_magazine_size(), "Pistol ammo should refill after reload")
	_verify_critical_damage_roll()

	_clear_projectiles()
	_finish()


func _verify_critical_damage_roll() -> void:
	var projectile := PROJECTILE_SCENE.instantiate() as Projectile
	get_tree().current_scene.add_child(projectile)
	projectile.damage = 3
	projectile.crit_chance = 1.0
	projectile.crit_multiplier = 2.0
	var critical_roll: Dictionary = projectile.call("_roll_damage")
	_expect(bool(critical_roll.get("critical", false)), "Projectile should report guaranteed crit as critical")
	_expect(int(critical_roll.get("damage", 0)) == 6, "Projectile critical damage should use crit multiplier")
	projectile.crit_chance = 0.0
	var normal_roll: Dictionary = projectile.call("_roll_damage")
	_expect(not bool(normal_roll.get("critical", true)), "Projectile should report zero crit chance as normal hit")
	_expect(int(normal_roll.get("damage", 0)) == 3, "Projectile normal damage should remain unchanged")
	projectile.queue_free()


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


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("WeaponSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

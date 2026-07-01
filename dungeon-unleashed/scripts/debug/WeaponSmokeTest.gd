extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const ENEMY_SCENE := preload("res://scenes/enemies/Enemy.tscn")
const PROJECTILE_SCENE := preload("res://scenes/projectiles/Projectile.tscn")
const ARC_BLADE := preload("res://resources/weapons/arc_blade.tres")
const NOVA_CORE := preload("res://resources/weapons/nova_core.tres")
const BLAST_LAUNCHER := preload("res://resources/weapons/blast_launcher.tres")
const LASER_LANCE := preload("res://resources/weapons/laser_lance.tres")

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
		var energy_before := player.get_energy()
		var expected_energy_cost := int(data.get("energy_cost"))
		var fired := weapon.try_fire(player.global_position + Vector2(320, 0), player)
		await get_tree().process_frame

		_expect(fired, "%s should fire" % data.display_name)
		_expect(_projectile_count() == maxi(data.projectile_count, 1), "%s projectile count should match WeaponData" % data.display_name)
		_expect(weapon.get_current_ammo() == weapon.get_magazine_size() - 1, "%s should consume one ammo per trigger pull" % data.display_name)
		_expect(player.get_energy() == energy_before - expected_energy_cost, "%s should spend configured energy cost" % data.display_name)

		if data.id == &"energy_staff":
			var projectile := get_tree().get_first_node_in_group("projectiles")
			_expect(projectile != null and projectile.get("_remaining_pierce") == data.pierce_count, "Energy Staff projectile should carry pierce count")

	await _verify_special_weapon_modes(player)
	await _verify_energy_weapon_gate(player)
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


func _verify_energy_weapon_gate(player: Player) -> void:
	player.call("_equip_weapon", 1)
	await get_tree().process_frame
	var weapon := player.weapon
	var weapon_data := weapon.weapon_data
	_expect(int(weapon_data.get("energy_cost")) > 0, "Energy gate check should use a weapon with energy cost")

	player.current_energy = 0
	player.energy_changed.emit(player.current_energy, player.max_energy)
	weapon.set("_cooldown", 0.0)
	var ammo_before := weapon.get_current_ammo()
	_clear_projectiles()
	var fired_without_energy := weapon.try_fire(player.global_position + Vector2(320, 0), player)
	await get_tree().process_frame
	_expect(not fired_without_energy, "Weapon should not fire when player has insufficient energy")
	_expect(weapon.get_current_ammo() == ammo_before, "Failed energy-gated fire should not consume ammo")
	_expect(_projectile_count() == 0, "Failed energy-gated fire should not spawn projectiles")

	player.set("_energy_regen_delay_timer", 0.0)
	player.call("_tick_timers", 0.25)
	await get_tree().process_frame
	_expect(player.get_energy() > 0, "Player energy should regenerate after delay")
	player.recover_energy(player.max_energy)


func _verify_special_weapon_modes(player: Player) -> void:
	await _verify_melee_weapon(player)
	await _verify_radial_weapon(player)
	await _verify_explosive_weapon(player)
	await _verify_laser_weapon(player)


func _verify_melee_weapon(player: Player) -> void:
	var weapon := player.weapon
	weapon.set_weapon_data(ARC_BLADE)
	player.recover_energy(player.max_energy)
	await get_tree().process_frame

	var enemy := _spawn_test_enemy(weapon.muzzle.global_position + Vector2(58, 0), 7)
	_clear_projectiles()
	var fired := weapon.try_fire(weapon.muzzle.global_position + Vector2(160, 0), player)
	await get_tree().process_frame

	_expect(fired, "Arc Blade should fire")
	_expect(_projectile_count() == 0, "Arc Blade melee sweep should not spawn projectiles")
	_expect(enemy.current_health < enemy.max_health, "Arc Blade should damage enemies inside its sweep")
	enemy.queue_free()


func _verify_radial_weapon(player: Player) -> void:
	var weapon := player.weapon
	weapon.set_weapon_data(NOVA_CORE)
	player.recover_energy(player.max_energy)
	await get_tree().process_frame

	_clear_projectiles()
	var energy_before := player.get_energy()
	var fired := weapon.try_fire(weapon.muzzle.global_position + Vector2(160, 0), player)
	await get_tree().process_frame

	_expect(fired, "Nova Core should fire")
	_expect(_projectile_count() == NOVA_CORE.projectile_count, "Nova Core should spawn a full radial projectile ring")
	_expect(player.get_energy() == energy_before - int(NOVA_CORE.get("energy_cost")), "Nova Core should spend configured energy")


func _verify_explosive_weapon(player: Player) -> void:
	var blast_data := BLAST_LAUNCHER.duplicate() as WeaponData
	blast_data.crit_chance = 0.0
	var primary := _spawn_test_enemy(player.global_position + Vector2(180, 0), 9)
	var secondary := _spawn_test_enemy(primary.global_position + Vector2(42, 0), 9)
	var projectile := PROJECTILE_SCENE.instantiate() as Projectile
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = primary.global_position
	projectile.call("launch", Vector2.RIGHT, blast_data, player)
	projectile.call("_handle_collision", primary)
	await get_tree().process_frame

	_expect(primary.current_health < primary.max_health, "Blast Launcher direct hit should damage primary target")
	_expect(secondary.current_health < secondary.max_health, "Blast Launcher explosion should damage nearby enemies")
	primary.queue_free()
	secondary.queue_free()


func _verify_laser_weapon(player: Player) -> void:
	var weapon := player.weapon
	weapon.set_weapon_data(LASER_LANCE)
	player.recover_energy(player.max_energy)
	await get_tree().process_frame

	_clear_projectiles()
	var fired := weapon.try_fire(weapon.muzzle.global_position + Vector2(260, 0), player)
	await get_tree().process_frame
	var projectile := get_tree().get_first_node_in_group("projectiles")
	_expect(fired, "Laser Lance should fire")
	_expect(projectile != null, "Laser Lance should spawn a beam-like projectile")
	if projectile != null:
		_expect(projectile.get("_remaining_pierce") == LASER_LANCE.pierce_count, "Laser Lance should carry high pierce count")
		_expect(is_equal_approx(float(projectile.get("speed")), LASER_LANCE.projectile_speed), "Laser Lance should use fast projectile speed")


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


func _spawn_test_enemy(position: Vector2, health: int) -> Enemy:
	var enemy := ENEMY_SCENE.instantiate() as Enemy
	enemy.max_health = health
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = position
	return enemy


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

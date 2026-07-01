extends Node2D
class_name Weapon

signal ammo_changed(current_ammo: int, magazine_size: int, is_reloading: bool)

@export var weapon_data: WeaponData
@export var projectile_scene: PackedScene = preload("res://scenes/projectiles/Projectile.tscn")
@export var muzzle_flash_scene: PackedScene = preload("res://scenes/effects/MuzzleFlash.tscn")

@onready var muzzle: Marker2D = $Muzzle

var _cooldown: float = 0.0
var _current_ammo: int = 0
var _reload_timer: float = 0.0
var _is_reloading := false


func _process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown = maxf(_cooldown - delta, 0.0)

	if _is_reloading:
		_reload_timer = maxf(_reload_timer - delta, 0.0)
		if _reload_timer <= 0.0:
			_finish_reload()


func try_fire(target_position: Vector2, owner_body: Node2D) -> bool:
	if weapon_data == null or projectile_scene == null or _cooldown > 0.0 or _is_reloading:
		return false

	if _current_ammo <= 0:
		start_reload()
		return false
	if not _can_owner_spend_energy(owner_body):
		return false

	var origin := muzzle.global_position
	var base_direction := target_position - origin
	if base_direction.length_squared() <= 0.001:
		base_direction = Vector2.RIGHT.rotated(global_rotation)
	base_direction = base_direction.normalized()

	global_rotation = base_direction.angle()
	if not _spend_owner_energy(owner_body):
		return false

	match weapon_data.fire_mode:
		"radial":
			_spawn_radial_projectiles(origin, base_direction, owner_body)
		"melee":
			_perform_melee_sweep(origin, base_direction, owner_body)
		_:
			_spawn_projectiles(origin, base_direction, owner_body)
	_spawn_muzzle_flash(base_direction)

	_current_ammo = maxi(_current_ammo - 1, 0)
	_cooldown = 1.0 / maxf(weapon_data.fire_rate * _get_owner_fire_rate_multiplier(owner_body), 0.01)
	Events.player_fired.emit(weapon_data, origin, base_direction)
	_emit_ammo_changed()

	if _current_ammo <= 0:
		start_reload()

	return true


func get_display_name() -> String:
	if weapon_data == null:
		return "Unarmed"
	return weapon_data.display_name


func set_weapon_data(data: WeaponData) -> void:
	weapon_data = data
	_cooldown = 0.0
	_is_reloading = false
	_reload_timer = 0.0
	_current_ammo = _get_magazine_size()
	_emit_ammo_changed()


func start_reload() -> bool:
	if weapon_data == null or _is_reloading:
		return false

	var magazine_size := _get_magazine_size()
	if _current_ammo >= magazine_size:
		return false

	_is_reloading = true
	_reload_timer = maxf(weapon_data.reload_duration / _get_owner_reload_speed_multiplier(), 0.01)
	_emit_ammo_changed()
	return true


func get_current_ammo() -> int:
	return _current_ammo


func get_magazine_size() -> int:
	return _get_magazine_size()


func is_reloading() -> bool:
	return _is_reloading


func _finish_reload() -> void:
	_is_reloading = false
	_reload_timer = 0.0
	_current_ammo = _get_magazine_size()
	_emit_ammo_changed()


func _spawn_projectiles(origin: Vector2, base_direction: Vector2, owner_body: Node2D) -> void:
	var projectile_total: int = maxi(weapon_data.projectile_count + _get_owner_projectile_count_bonus(owner_body), 1)
	var spread_radians := deg_to_rad(weapon_data.spread_angle)

	for index in range(projectile_total):
		var angle_offset := 0.0
		if projectile_total > 1:
			var step_ratio := float(index) / float(projectile_total - 1)
			angle_offset = lerpf(-spread_radians * 0.5, spread_radians * 0.5, step_ratio)

		_spawn_single_projectile(origin, base_direction.rotated(angle_offset), owner_body)


func _spawn_radial_projectiles(origin: Vector2, base_direction: Vector2, owner_body: Node2D) -> void:
	var projectile_total: int = maxi(weapon_data.projectile_count + _get_owner_projectile_count_bonus(owner_body), 1)
	for index in range(projectile_total):
		var angle_offset := 0.0
		if projectile_total > 1:
			angle_offset = TAU * float(index) / float(projectile_total)
		_spawn_single_projectile(origin, base_direction.rotated(angle_offset), owner_body)


func _spawn_single_projectile(origin: Vector2, direction: Vector2, owner_body: Node2D) -> void:
	var projectile := projectile_scene.instantiate() as Node2D
	if projectile == null:
		return

	get_tree().current_scene.add_child(projectile)
	projectile.global_position = origin
	projectile.call("launch", direction, weapon_data, owner_body)
	Events.projectile_spawned.emit(projectile)


func _perform_melee_sweep(origin: Vector2, base_direction: Vector2, owner_body: Node2D) -> void:
	var sweep_range := maxf(weapon_data.projectile_range, 1.0)
	var half_angle := deg_to_rad(clampf(weapon_data.spread_angle, 1.0, 360.0)) * 0.5
	var hit_targets: Array[Node] = []

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		if not enemy is Node2D or not (enemy as Node).has_method("apply_damage"):
			continue
		if enemy.has_method("is_dead") and bool(enemy.call("is_dead")):
			continue

		var enemy_node := enemy as Node2D
		var offset := enemy_node.global_position - origin
		if offset.length() > sweep_range:
			continue
		if offset.length_squared() > 0.001 and absf(base_direction.angle_to(offset.normalized())) > half_angle:
			continue
		hit_targets.append(enemy)

	for target in hit_targets:
		var target_node := target as Node2D
		var direction := (target_node.global_position - origin).normalized()
		if direction.length_squared() <= 0.001:
			direction = base_direction
		var damage_roll := _roll_direct_damage(owner_body)
		var final_damage := int(damage_roll.get("damage", weapon_data.damage))
		var was_critical := bool(damage_roll.get("critical", false))
		target.call("apply_damage", final_damage, owner_body, direction, weapon_data.knockback)
		Events.projectile_hit.emit(null, target, final_damage)
		if was_critical:
			Events.projectile_critical_hit.emit(null, target, final_damage)


func _roll_direct_damage(owner_body: Node) -> Dictionary:
	var base_damage := maxi(roundi(float(weapon_data.damage) * _get_owner_damage_multiplier(owner_body)), 1)
	var crit_chance := clampf(weapon_data.crit_chance + _get_owner_crit_chance_bonus(owner_body), 0.0, 1.0)
	if randf() < crit_chance:
		return {
			"damage": maxi(roundi(float(base_damage) * weapon_data.crit_multiplier), 1),
			"critical": true,
		}
	return {
		"damage": base_damage,
		"critical": false,
	}


func _spawn_muzzle_flash(direction: Vector2) -> void:
	if muzzle_flash_scene == null:
		return

	var flash := muzzle_flash_scene.instantiate() as Node2D
	if flash == null:
		return

	get_tree().current_scene.add_child(flash)
	flash.global_position = muzzle.global_position
	flash.global_rotation = direction.angle()


func _get_magazine_size() -> int:
	if weapon_data == null:
		return 0
	return maxi(weapon_data.magazine_size, 1)


func _emit_ammo_changed() -> void:
	ammo_changed.emit(_current_ammo, _get_magazine_size(), _is_reloading)


func _get_owner_fire_rate_multiplier(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_fire_rate_multiplier"):
		return maxf(float(owner_body.call("get_fire_rate_multiplier")), 0.1)
	return 1.0


func _get_owner_projectile_count_bonus(owner_body: Node) -> int:
	if owner_body != null and owner_body.has_method("get_projectile_count_bonus"):
		return maxi(int(owner_body.call("get_projectile_count_bonus")), 0)
	return 0


func _get_owner_damage_multiplier(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_damage_multiplier"):
		return maxf(float(owner_body.call("get_damage_multiplier")), 0.1)
	return 1.0


func _get_owner_crit_chance_bonus(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_crit_chance_bonus"):
		return clampf(float(owner_body.call("get_crit_chance_bonus")), 0.0, 1.0)
	return 0.0


func _can_owner_spend_energy(owner_body: Node) -> bool:
	if owner_body != null and owner_body.has_method("can_spend_energy_for_weapon"):
		return bool(owner_body.call("can_spend_energy_for_weapon", weapon_data))
	return true


func _spend_owner_energy(owner_body: Node) -> bool:
	if owner_body != null and owner_body.has_method("spend_energy_for_weapon"):
		return bool(owner_body.call("spend_energy_for_weapon", weapon_data))
	return true


func _get_owner_reload_speed_multiplier() -> float:
	var owner_body := get_parent()
	if owner_body != null and owner_body.has_method("get_reload_speed_multiplier"):
		return maxf(float(owner_body.call("get_reload_speed_multiplier")), 0.1)
	return 1.0

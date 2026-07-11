extends Node2D
class_name Weapon

signal ammo_changed(current_ammo: int, magazine_size: int, is_reloading: bool)

@export var weapon_data: WeaponData
@export var projectile_scene: PackedScene = preload("res://scenes/projectiles/Projectile.tscn")
@export var deployable_scene: PackedScene = preload("res://scenes/weapons/DeployableTrap.tscn")
@export var muzzle_flash_scene: PackedScene = preload("res://scenes/effects/MuzzleFlash.tscn")
@export var melee_sweep_flash_scene: PackedScene = preload("res://scenes/effects/MeleeSweepFlash.tscn")

@onready var muzzle: Marker2D = $Muzzle

var _cooldown: float = 0.0
var _current_ammo: int = 0
var _reload_timer: float = 0.0
var _is_reloading := false
var _is_charging := false
var _charge_timer := 0.0
var _charge_target_position := Vector2.ZERO
var _charge_owner_body: Node2D


func _process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown = maxf(_cooldown - delta, 0.0)

	if _is_reloading:
		_reload_timer = maxf(_reload_timer - delta, 0.0)
		if _reload_timer <= 0.0:
			_finish_reload()

	if _is_charging and weapon_data != null:
		var charge_duration := _get_charge_duration()
		if charge_duration <= 0.0:
			_charge_timer = 1.0
		else:
			_charge_timer = minf(_charge_timer + delta * _get_owner_charge_speed_multiplier(_get_safe_charge_owner_body()), charge_duration)


func try_fire(target_position: Vector2, owner_body: Node2D) -> bool:
	if weapon_data == null or projectile_scene == null or _cooldown > 0.0 or _is_reloading:
		return false

	if weapon_data.fire_mode == "charge":
		return _try_start_or_update_charge(target_position, owner_body)

	return _fire_weapon_payload(target_position, owner_body)


func release_charge(target_position: Vector2, owner_body: Node2D) -> bool:
	if weapon_data == null or weapon_data.fire_mode != "charge" or not _is_charging:
		return false

	var charge_ratio := get_charge_ratio()
	cancel_charge()
	return _fire_weapon_payload(target_position, owner_body, charge_ratio)


func cancel_charge() -> void:
	_is_charging = false
	_charge_timer = 0.0
	_charge_target_position = Vector2.ZERO
	_charge_owner_body = null


func is_charging() -> bool:
	return _is_charging


func get_charge_ratio() -> float:
	if not _is_charging or weapon_data == null:
		return 0.0
	var charge_duration := _get_charge_duration()
	if charge_duration <= 0.0:
		return 1.0
	return clampf(_charge_timer / charge_duration, 0.0, 1.0)


func _try_start_or_update_charge(target_position: Vector2, owner_body: Node2D) -> bool:
	if _current_ammo <= 0:
		start_reload()
		return false
	if not _can_owner_spend_energy(owner_body):
		return false

	_charge_target_position = target_position
	_charge_owner_body = owner_body
	if not _is_charging:
		_is_charging = true
		_charge_timer = 0.0
	return true


func _fire_weapon_payload(target_position: Vector2, owner_body: Node2D, charge_ratio: float = 0.0) -> bool:
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
			_spawn_radial_projectiles(origin, base_direction, owner_body, charge_ratio)
		"melee":
			_perform_melee_sweep(origin, base_direction, owner_body)
		"deployable":
			_spawn_deployable(origin, base_direction, target_position, owner_body)
		_:
			_spawn_projectiles(origin, base_direction, owner_body, charge_ratio)
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
	cancel_charge()
	weapon_data = data
	_cooldown = 0.0
	_is_reloading = false
	_reload_timer = 0.0
	_current_ammo = _get_magazine_size()
	_emit_ammo_changed()


func start_reload() -> bool:
	if weapon_data == null or _is_reloading:
		return false

	if _is_charging:
		cancel_charge()

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


func refresh_magazine_size(previous_size: int) -> void:
	var resolved_previous_size := maxi(previous_size, 0)
	var new_size := _get_magazine_size()
	var added_capacity := maxi(new_size - resolved_previous_size, 0)
	_current_ammo = clampi(_current_ammo + added_capacity, 0, new_size)
	_emit_ammo_changed()


func is_reloading() -> bool:
	return _is_reloading


func _finish_reload() -> void:
	_is_reloading = false
	_reload_timer = 0.0
	_current_ammo = _get_magazine_size()
	_emit_ammo_changed()
	Events.player_weapon_reloaded.emit(weapon_data)


func _spawn_projectiles(origin: Vector2, base_direction: Vector2, owner_body: Node2D, charge_ratio: float = 0.0) -> void:
	var projectile_total: int = maxi(weapon_data.projectile_count + _get_owner_projectile_count_bonus(owner_body) + _get_charge_projectile_bonus(owner_body, charge_ratio), 1)
	var spread_radians := deg_to_rad(weapon_data.spread_angle)

	for index in range(projectile_total):
		var angle_offset := 0.0
		if projectile_total > 1:
			var step_ratio := float(index) / float(projectile_total - 1)
			angle_offset = lerpf(-spread_radians * 0.5, spread_radians * 0.5, step_ratio)

		_spawn_single_projectile(origin, base_direction.rotated(angle_offset), owner_body, charge_ratio)


func _spawn_radial_projectiles(origin: Vector2, base_direction: Vector2, owner_body: Node2D, charge_ratio: float = 0.0) -> void:
	var projectile_total: int = maxi(weapon_data.projectile_count + _get_owner_projectile_count_bonus(owner_body) + _get_charge_projectile_bonus(owner_body, charge_ratio), 1)
	for index in range(projectile_total):
		var angle_offset := 0.0
		if projectile_total > 1:
			angle_offset = TAU * float(index) / float(projectile_total)
		_spawn_single_projectile(origin, base_direction.rotated(angle_offset), owner_body, charge_ratio)


func _spawn_single_projectile(origin: Vector2, direction: Vector2, owner_body: Node2D, charge_ratio: float = 0.0) -> void:
	var projectile := projectile_scene.instantiate() as Node2D
	if projectile == null:
		return

	get_tree().current_scene.add_child(projectile)
	projectile.global_position = origin
	projectile.call("launch", direction, weapon_data, owner_body, charge_ratio)
	Events.projectile_spawned.emit(projectile)


func _spawn_deployable(origin: Vector2, base_direction: Vector2, target_position: Vector2, owner_body: Node2D) -> void:
	if deployable_scene == null:
		return

	var deployable := deployable_scene.instantiate() as Node2D
	if deployable == null:
		return

	get_tree().current_scene.add_child(deployable)
	deployable.global_position = _get_deployable_position(origin, base_direction, target_position)
	deployable.call("configure", weapon_data, owner_body)


func _get_deployable_position(origin: Vector2, base_direction: Vector2, target_position: Vector2) -> Vector2:
	var max_distance := maxf(weapon_data.projectile_range, 1.0)
	var offset := target_position - origin
	if offset.length_squared() <= 0.001:
		return origin + base_direction * minf(max_distance, 160.0)
	if offset.length() > max_distance:
		return origin + offset.normalized() * max_distance
	return target_position


func _perform_melee_sweep(origin: Vector2, base_direction: Vector2, owner_body: Node2D) -> void:
	var sweep_range := maxf(weapon_data.projectile_range, 1.0)
	var half_angle := deg_to_rad(clampf(weapon_data.spread_angle, 1.0, 360.0)) * 0.5
	var hit_targets: Array[Node] = []
	_spawn_melee_sweep_flash(origin, base_direction, sweep_range, rad_to_deg(half_angle * 2.0))

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
		target.call("apply_damage", final_damage, owner_body, direction, weapon_data.knockback * _get_owner_knockback_multiplier(owner_body))
		_try_apply_direct_status(target, owner_body)
		Events.projectile_hit.emit(null, target, final_damage)
		if was_critical:
			Events.projectile_critical_hit.emit(null, target, final_damage)

	_block_enemy_projectiles(origin, base_direction, owner_body)


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


func _try_apply_direct_status(target: Node, owner_body: Node) -> void:
	if target == null or weapon_data == null or not target.has_method("apply_status_effect"):
		return
	if weapon_data.status_effect.is_empty() or weapon_data.status_effect == "none" or weapon_data.status_duration <= 0.0:
		return

	var chance := clampf(weapon_data.status_chance + _get_owner_status_chance_bonus(owner_body), 0.0, 1.0)
	if chance <= 0.0 or randf() > chance:
		return

	target.call(
		"apply_status_effect",
		weapon_data.status_effect,
		maxf(weapon_data.status_duration * _get_owner_status_duration_multiplier(owner_body), 0.0),
		maxi(roundi(float(weapon_data.status_damage_per_tick) * _get_owner_status_damage_multiplier(owner_body)), 0),
		maxf(weapon_data.status_tick_interval, 0.1),
		clampf(weapon_data.status_slow_multiplier, 0.1, 1.0),
		owner_body
	)


func _block_enemy_projectiles(origin: Vector2, base_direction: Vector2, owner_body: Node) -> int:
	if weapon_data == null or not weapon_data.blocks_projectiles:
		set_meta(&"last_blocked_projectiles", 0)
		return 0

	var block_radius := maxf(weapon_data.projectile_block_radius + _get_owner_projectile_block_radius_bonus(owner_body), 1.0)
	var half_angle := deg_to_rad(clampf(weapon_data.projectile_block_arc_degrees + _get_owner_projectile_block_arc_bonus(owner_body), 1.0, 360.0)) * 0.5
	var blocked_count := 0
	var last_block_position := origin
	for projectile in get_tree().get_nodes_in_group("enemy_projectiles"):
		if not is_instance_valid(projectile) or projectile.is_queued_for_deletion():
			continue
		if not projectile is Node2D:
			continue

		var projectile_node := projectile as Node2D
		var offset := projectile_node.global_position - origin
		if offset.length() > block_radius:
			continue
		if offset.length_squared() > 0.001 and absf(base_direction.angle_to(offset.normalized())) > half_angle:
			continue

		blocked_count += 1
		last_block_position = projectile_node.global_position
		_apply_projectile_block_damage(projectile_node.global_position, owner_body, base_direction, block_radius)
		projectile.queue_free()

	set_meta(&"last_blocked_projectiles", blocked_count)
	if blocked_count > 0:
		Events.player_projectile_blocked.emit(owner_body, weapon_data, blocked_count, last_block_position)
	return blocked_count


func _apply_projectile_block_damage(block_position: Vector2, owner_body: Node, fallback_direction: Vector2, block_radius: float) -> void:
	var counter_damage := maxi(weapon_data.projectile_block_damage + _get_owner_projectile_block_damage_bonus(owner_body), 0)
	if counter_damage <= 0:
		return

	var counter_radius := maxf(block_radius * 0.55, 32.0)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		if not enemy is Node2D or not (enemy as Node).has_method("apply_damage"):
			continue
		if enemy.has_method("is_dead") and bool(enemy.call("is_dead")):
			continue

		var enemy_node := enemy as Node2D
		if enemy_node.global_position.distance_to(block_position) > counter_radius:
			continue
		var direction := (enemy_node.global_position - block_position).normalized()
		if direction.length_squared() <= 0.001:
			direction = fallback_direction
		(enemy as Node).call("apply_damage", counter_damage, owner_body, direction, weapon_data.knockback * _get_owner_knockback_multiplier(owner_body) * 0.45)
		Events.projectile_hit.emit(null, enemy as Node, counter_damage)


func _spawn_muzzle_flash(direction: Vector2) -> void:
	if muzzle_flash_scene == null:
		return

	var flash := muzzle_flash_scene.instantiate() as Node2D
	if flash == null:
		return

	get_tree().current_scene.add_child(flash)
	flash.global_position = muzzle.global_position
	flash.global_rotation = direction.angle()


func _spawn_melee_sweep_flash(origin: Vector2, direction: Vector2, sweep_radius: float, sweep_arc_degrees: float) -> void:
	if melee_sweep_flash_scene == null:
		return

	var flash := melee_sweep_flash_scene.instantiate() as Node2D
	if flash == null:
		return

	get_tree().current_scene.add_child(flash)
	flash.global_position = origin
	flash.global_rotation = direction.angle()
	if flash.has_method("configure"):
		flash.call("configure", sweep_radius, sweep_arc_degrees)


func _get_magazine_size() -> int:
	if weapon_data == null:
		return 0
	var owner_body := get_parent()
	var owner_bonus := 0
	if owner_body != null and owner_body.has_method("get_magazine_size_bonus"):
		owner_bonus = maxi(int(owner_body.call("get_magazine_size_bonus")), 0)
	return maxi(weapon_data.magazine_size + owner_bonus, 1)


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


func _get_owner_knockback_multiplier(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_knockback_multiplier"):
		return maxf(float(owner_body.call("get_knockback_multiplier")), 0.1)
	return 1.0


func _get_owner_crit_chance_bonus(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_crit_chance_bonus"):
		return clampf(float(owner_body.call("get_crit_chance_bonus")), 0.0, 1.0)
	return 0.0


func _get_owner_status_chance_bonus(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_status_chance_bonus"):
		return clampf(float(owner_body.call("get_status_chance_bonus")), 0.0, 1.0)
	return 0.0


func _get_owner_status_damage_multiplier(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_status_damage_multiplier"):
		return maxf(float(owner_body.call("get_status_damage_multiplier")), 0.1)
	return 1.0


func _get_owner_status_duration_multiplier(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_status_duration_multiplier"):
		return maxf(float(owner_body.call("get_status_duration_multiplier")), 0.1)
	return 1.0


func _get_owner_projectile_block_radius_bonus(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_projectile_block_radius_bonus"):
		return maxf(float(owner_body.call("get_projectile_block_radius_bonus")), 0.0)
	return 0.0


func _get_owner_projectile_block_arc_bonus(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_projectile_block_arc_bonus"):
		return maxf(float(owner_body.call("get_projectile_block_arc_bonus")), 0.0)
	return 0.0


func _get_owner_projectile_block_damage_bonus(owner_body: Node) -> int:
	if owner_body != null and owner_body.has_method("get_projectile_block_damage_bonus"):
		return maxi(int(owner_body.call("get_projectile_block_damage_bonus")), 0)
	return 0


func _get_charge_projectile_bonus(owner_body: Node, charge_ratio: float) -> int:
	var resolved_charge := clampf(charge_ratio, 0.0, 1.0)
	if resolved_charge <= 0.0:
		return 0

	var configured_bonus := maxi(weapon_data.charge_projectile_count_bonus, 0)
	var owner_bonus := _get_owner_charge_projectile_count_bonus(owner_body)
	return maxi(roundi(float(configured_bonus + owner_bonus) * resolved_charge), 0)


func _get_charge_duration() -> float:
	if weapon_data == null:
		return 0.0
	return maxf(weapon_data.charge_duration, 0.0)


func _get_safe_charge_owner_body() -> Node2D:
	if _charge_owner_body == null or not is_instance_valid(_charge_owner_body):
		return null
	if _charge_owner_body.is_queued_for_deletion():
		return null
	return _charge_owner_body


func _get_owner_charge_speed_multiplier(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_charge_speed_multiplier"):
		return maxf(float(owner_body.call("get_charge_speed_multiplier")), 0.1)
	return 1.0


func _get_owner_charge_projectile_count_bonus(owner_body: Node) -> int:
	if owner_body != null and owner_body.has_method("get_charge_projectile_count_bonus"):
		return maxi(int(owner_body.call("get_charge_projectile_count_bonus")), 0)
	return 0


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

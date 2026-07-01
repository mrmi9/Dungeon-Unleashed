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

	var origin := muzzle.global_position
	var base_direction := target_position - origin
	if base_direction.length_squared() <= 0.001:
		base_direction = Vector2.RIGHT.rotated(global_rotation)
	base_direction = base_direction.normalized()

	global_rotation = base_direction.angle()
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

		var projectile := projectile_scene.instantiate() as Node2D
		if projectile == null:
			continue

		get_tree().current_scene.add_child(projectile)
		projectile.global_position = origin
		projectile.call("launch", base_direction.rotated(angle_offset), weapon_data, owner_body)
		Events.projectile_spawned.emit(projectile)


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


func _get_owner_reload_speed_multiplier() -> float:
	var owner_body := get_parent()
	if owner_body != null and owner_body.has_method("get_reload_speed_multiplier"):
		return maxf(float(owner_body.call("get_reload_speed_multiplier")), 0.1)
	return 1.0

extends CharacterBody2D
class_name Player

signal health_changed(current_hp: int, max_hp: int)
signal shield_changed(current_shield: int)
signal gold_changed(current_gold: int)
signal weapon_changed(display_name: String)
signal ammo_changed(current_ammo: int, magazine_size: int, is_reloading: bool)

@export var max_health: int = 6
@export var move_speed: float = 260.0
@export var invulnerability_duration: float = 0.7
@export var contact_damage_interval: float = 0.65
@export var max_shield: int = 6
@export var weapon_loadout: Array[WeaponData] = [
	preload("res://resources/weapons/basic_pistol.tres"),
	preload("res://resources/weapons/shotgun.tres"),
	preload("res://resources/weapons/energy_staff.tres"),
]

@onready var weapon: Weapon = $Weapon
@onready var visual: CanvasItem = $Visual
@onready var hurtbox: Area2D = $Hurtbox

var current_health: int
var current_shield: int = 0
var current_gold: int = 0
var current_weapon_index: int = 0
var relic_damage_multiplier_bonus := 0.0
var relic_fire_rate_multiplier_bonus := 0.0
var relic_projectile_count_bonus := 0
var relic_pierce_bonus := 0
var relic_crit_chance_bonus := 0.0
var relic_reload_speed_multiplier_bonus := 0.0
var _temporary_speed_multiplier := 1.0
var _speed_boost_timer := 0.0
var _is_dead := false
var _invulnerability_timer := 0.0
var _contact_damage_timer := 0.0
var _touching_enemies: Array[Node] = []


func _ready() -> void:
	add_to_group("player")
	current_health = max_health
	weapon.ammo_changed.connect(_on_weapon_ammo_changed)
	_equip_weapon(0)
	health_changed.emit(current_health, max_health)
	shield_changed.emit(current_shield)
	gold_changed.emit(current_gold)
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)
	hurtbox.body_exited.connect(_on_hurtbox_body_exited)


func _physics_process(delta: float) -> void:
	_tick_timers(delta)

	if _is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	_aim_at_mouse()
	_handle_weapon_switch_input()
	if Input.is_action_just_pressed("reload"):
		weapon.start_reload()

	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * move_speed * _temporary_speed_multiplier
	move_and_slide()

	if Input.is_action_pressed("shoot"):
		weapon.try_fire(get_global_mouse_position(), self)

	_try_contact_damage()


func is_alive() -> bool:
	return not _is_dead


func get_weapon_display_name() -> String:
	if weapon == null:
		return "Unarmed"
	return weapon.get_display_name()


func add_gold(amount: int) -> void:
	if _is_dead:
		return

	current_gold = maxi(current_gold + amount, 0)
	gold_changed.emit(current_gold)
	Events.gold_changed.emit(current_gold)


func can_afford(amount: int) -> bool:
	return current_gold >= maxi(amount, 0)


func spend_gold(amount: int) -> bool:
	var cost := maxi(amount, 0)
	if _is_dead or current_gold < cost:
		return false

	current_gold -= cost
	gold_changed.emit(current_gold)
	Events.gold_changed.emit(current_gold)
	return true


func buy_weapon(weapon_data: Resource) -> bool:
	if _is_dead or weapon_data == null:
		return false

	var typed_weapon := weapon_data as WeaponData
	if typed_weapon == null:
		return false

	if weapon_loadout.is_empty():
		weapon_loadout.append(typed_weapon)
		current_weapon_index = 0
	else:
		current_weapon_index = clampi(current_weapon_index, 0, weapon_loadout.size() - 1)
		weapon_loadout[current_weapon_index] = typed_weapon

	_equip_weapon(current_weapon_index)
	return true


func apply_relic_effect(effect_type: String, effect_value: float) -> void:
	match effect_type:
		"damage_multiplier":
			relic_damage_multiplier_bonus += effect_value
		"fire_rate_multiplier":
			relic_fire_rate_multiplier_bonus += effect_value
		"projectile_count":
			relic_projectile_count_bonus += roundi(effect_value)
		"pierce":
			relic_pierce_bonus += roundi(effect_value)
		"crit_chance_bonus":
			relic_crit_chance_bonus += effect_value
		"reload_speed_multiplier":
			relic_reload_speed_multiplier_bonus += effect_value
		"max_health":
			var health_bonus := maxi(roundi(effect_value), 1)
			max_health += health_bonus
			current_health = mini(current_health + health_bonus, max_health)
			health_changed.emit(current_health, max_health)
			Events.player_healed.emit(health_bonus, current_health)


func heal(amount: int) -> void:
	if _is_dead or amount <= 0:
		return

	var previous_health := current_health
	current_health = mini(current_health + amount, max_health)
	if current_health != previous_health:
		var healed_amount := current_health - previous_health
		health_changed.emit(current_health, max_health)
		Events.player_healed.emit(healed_amount, current_health)


func add_shield(amount: int) -> void:
	if _is_dead or amount <= 0:
		return

	var previous_shield := current_shield
	current_shield = mini(current_shield + amount, max_shield)
	if current_shield != previous_shield:
		var gained_amount := current_shield - previous_shield
		shield_changed.emit(current_shield)
		Events.player_shield_gained.emit(gained_amount, current_shield)


func get_shield() -> int:
	return current_shield


func apply_temporary_speed_boost(multiplier_bonus: float, duration: float) -> void:
	if _is_dead:
		return

	_temporary_speed_multiplier = maxf(_temporary_speed_multiplier, 1.0 + multiplier_bonus)
	_speed_boost_timer = maxf(_speed_boost_timer, duration)


func get_current_speed_multiplier() -> float:
	return _temporary_speed_multiplier


func get_damage_multiplier() -> float:
	return maxf(1.0 + relic_damage_multiplier_bonus, 0.1)


func get_fire_rate_multiplier() -> float:
	return maxf(1.0 + relic_fire_rate_multiplier_bonus, 0.1)


func get_projectile_count_bonus() -> int:
	return maxi(relic_projectile_count_bonus, 0)


func get_pierce_bonus() -> int:
	return maxi(relic_pierce_bonus, 0)


func get_crit_chance_bonus() -> float:
	return clampf(relic_crit_chance_bonus, 0.0, 1.0)


func get_reload_speed_multiplier() -> float:
	return maxf(1.0 + relic_reload_speed_multiplier_bonus, 0.1)


func _handle_weapon_switch_input() -> void:
	if Input.is_action_just_pressed("weapon_slot_1"):
		_equip_weapon(0)
	elif Input.is_action_just_pressed("weapon_slot_2"):
		_equip_weapon(1)
	elif Input.is_action_just_pressed("weapon_slot_3"):
		_equip_weapon(2)


func _equip_weapon(index: int) -> void:
	if index < 0 or index >= weapon_loadout.size():
		return

	var data := weapon_loadout[index]
	if data == null:
		return

	current_weapon_index = index
	weapon.set_weapon_data(data)
	weapon_changed.emit(weapon.get_display_name())


func take_damage(amount: int, source: Node = null) -> void:
	if _is_dead or _invulnerability_timer > 0.0:
		return

	var remaining_damage := maxi(amount, 0)
	if current_shield > 0 and remaining_damage > 0:
		var absorbed := mini(current_shield, remaining_damage)
		current_shield -= absorbed
		remaining_damage -= absorbed
		shield_changed.emit(current_shield)
		Events.player_shield_absorbed.emit(absorbed, current_shield)

	current_health = maxi(current_health - remaining_damage, 0)
	_invulnerability_timer = invulnerability_duration
	health_changed.emit(current_health, max_health)
	Events.player_damaged.emit(remaining_damage, current_health)
	_flash(Color(1.0, 0.35, 0.35, 1.0), 0.16)

	if current_health <= 0:
		_die()


func _tick_timers(delta: float) -> void:
	if _invulnerability_timer > 0.0:
		_invulnerability_timer = maxf(_invulnerability_timer - delta, 0.0)

	if _contact_damage_timer > 0.0:
		_contact_damage_timer = maxf(_contact_damage_timer - delta, 0.0)

	if _speed_boost_timer > 0.0:
		_speed_boost_timer = maxf(_speed_boost_timer - delta, 0.0)
		if _speed_boost_timer <= 0.0:
			_temporary_speed_multiplier = 1.0


func _aim_at_mouse() -> void:
	var direction := get_global_mouse_position() - global_position
	if direction.length_squared() > 0.001:
		global_rotation = direction.angle()


func _try_contact_damage() -> void:
	if _contact_damage_timer > 0.0:
		return

	for enemy in _touching_enemies.duplicate():
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			_touching_enemies.erase(enemy)
			continue

		if enemy.has_method("is_dead") and enemy.call("is_dead"):
			continue

		var amount := 1
		var damage_property = enemy.get("contact_damage")
		if damage_property != null:
			amount = int(damage_property)

		take_damage(amount, enemy)
		_contact_damage_timer = contact_damage_interval
		return


func _flash(color: Color, duration: float) -> void:
	visual.modulate = color
	var tween := create_tween()
	tween.tween_property(visual, "modulate", Color.WHITE, duration)


func _die() -> void:
	_is_dead = true
	velocity = Vector2.ZERO
	visual.modulate = Color(0.35, 0.35, 0.35, 1.0)
	Events.player_died.emit()


func _on_hurtbox_body_entered(body: Node) -> void:
	if body.is_in_group("enemies") and not _touching_enemies.has(body):
		_touching_enemies.append(body)


func _on_hurtbox_body_exited(body: Node) -> void:
	_touching_enemies.erase(body)


func _on_weapon_ammo_changed(current_ammo: int, magazine_size: int, is_reloading: bool) -> void:
	ammo_changed.emit(current_ammo, magazine_size, is_reloading)

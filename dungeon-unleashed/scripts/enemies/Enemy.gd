extends CharacterBody2D
class_name Enemy

signal died(enemy: Enemy)

const DEATH_BURST_SCENE := preload("res://scenes/effects/DeathBurst.tscn")
const DANGER_WARNING_SCENE := preload("res://scenes/effects/DangerWarning.tscn")

enum BehaviorType {
	CHASER,
	SHOOTER,
	CHARGER,
	BOMBER,
	SUMMONER,
	SHIELDED,
}

@export var display_name: String = "Chaser"
@export var behavior_type: BehaviorType = BehaviorType.CHASER
@export var max_health: int = 3
@export var move_speed: float = 95.0
@export var contact_damage: int = 1
@export var knockback_decay: float = 900.0
@export var attack_damage: int = 1
@export var attack_cooldown: float = 1.4
@export var attack_range: float = 280.0
@export var preferred_range: float = 210.0
@export var projectile_scene: PackedScene = preload("res://scenes/projectiles/EnemyProjectile.tscn")
@export var projectile_speed: float = 340.0
@export var charge_speed: float = 360.0
@export var charge_windup: float = 0.35
@export var charge_duration: float = 0.38
@export var charge_recover: float = 0.55
@export var self_destruct_radius: float = 86.0
@export var self_destruct_windup: float = 0.7
@export var summon_scene: PackedScene
@export var summon_count: int = 2
@export var summon_spacing: float = 34.0
@export var shield_front_arc_degrees: float = 120.0
@export_range(0.0, 1.0, 0.05) var shield_front_damage_multiplier: float = 0.25

@onready var visual: CanvasItem = $Visual

var current_health: int
var is_elite := false
var elite_death_explosion_radius := 0.0
var elite_death_explosion_damage := 0
var target: Node2D
var _dead := false
var _knockback_velocity := Vector2.ZERO
var _attack_timer := 0.0
var _charge_state := 0
var _charge_timer := 0.0
var _charge_direction := Vector2.ZERO
var _is_self_destructing := false
var _self_destruct_timer := 0.0


func _ready() -> void:
	add_to_group("enemies")
	add_to_group("enemy_%s" % display_name.to_snake_case())
	current_health = max_health
	_attack_timer = randf_range(0.25, attack_cooldown)
	_find_target()


func _physics_process(delta: float) -> void:
	if _dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if target == null or not is_instance_valid(target):
		_find_target()

	_tick_attack_timer(delta)

	var behavior_velocity := Vector2.ZERO
	if _can_chase_target():
		match behavior_type:
			BehaviorType.SHOOTER:
				behavior_velocity = _update_shooter()
			BehaviorType.CHARGER:
				behavior_velocity = _update_charger(delta)
			BehaviorType.BOMBER:
				behavior_velocity = _update_bomber(delta)
			BehaviorType.SUMMONER:
				behavior_velocity = _update_summoner()
			BehaviorType.SHIELDED:
				behavior_velocity = _update_shielded()
			_:
				behavior_velocity = _update_chaser()

	velocity = behavior_velocity + _knockback_velocity
	_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
	move_and_slide()


func is_dead() -> bool:
	return _dead


func apply_elite_modifiers(health_multiplier: float, damage_multiplier: float, death_explosion_radius: float, death_explosion_damage: int) -> void:
	if is_elite:
		return

	is_elite = true
	display_name = "Elite %s" % display_name
	max_health = maxi(roundi(float(max_health) * maxf(health_multiplier, 1.0)), max_health + 1)
	current_health = max_health
	contact_damage = maxi(roundi(float(contact_damage) * maxf(damage_multiplier, 1.0)), contact_damage)
	attack_damage = maxi(roundi(float(attack_damage) * maxf(damage_multiplier, 1.0)), attack_damage)
	elite_death_explosion_radius = maxf(death_explosion_radius, 0.0)
	elite_death_explosion_damage = maxi(death_explosion_damage, 0)
	scale *= 1.18
	if visual != null:
		visual.modulate = Color(1.0, 0.62, 0.18, 1.0)


func apply_damage(amount: int, source: Node = null, knockback_direction: Vector2 = Vector2.ZERO, knockback_force: float = 0.0) -> void:
	if _dead:
		return

	var final_amount := _calculate_damage_after_defense(amount, knockback_direction)
	if final_amount <= 0:
		_flash(Color(0.35, 0.72, 1.0, 1.0), 0.12)
		return

	current_health = maxi(current_health - final_amount, 0)
	if knockback_direction.length_squared() > 0.001 and knockback_force > 0.0:
		_knockback_velocity += knockback_direction.normalized() * knockback_force

	Events.enemy_damaged.emit(self, final_amount)
	_flash(Color(1.0, 0.92, 0.45, 1.0), 0.1)

	if current_health <= 0:
		_die()


func _find_target() -> void:
	target = get_tree().get_first_node_in_group("player") as Node2D


func _can_chase_target() -> bool:
	if target == null or not is_instance_valid(target):
		return false

	if target.has_method("is_alive") and not target.call("is_alive"):
		return false

	return true


func _tick_attack_timer(delta: float) -> void:
	if _attack_timer > 0.0:
		_attack_timer = maxf(_attack_timer - delta, 0.0)


func _update_chaser() -> Vector2:
	var direction := _direction_to_target()
	if direction.length_squared() > 0.001:
		rotation = direction.angle()
	return direction * move_speed


func _update_shooter() -> Vector2:
	var offset := target.global_position - global_position
	var distance := offset.length()
	var direction := offset.normalized() if distance > 0.001 else Vector2.RIGHT
	rotation = direction.angle()

	if distance <= attack_range and _attack_timer <= 0.0:
		_fire_projectile(direction)
		_attack_timer = attack_cooldown

	if distance < preferred_range * 0.75:
		return -direction * move_speed * 0.75
	if distance > preferred_range * 1.2:
		return direction * move_speed * 0.65
	return Vector2.ZERO


func _update_charger(delta: float) -> Vector2:
	var direction := _direction_to_target()
	var distance := global_position.distance_to(target.global_position)
	if direction.length_squared() > 0.001:
		rotation = direction.angle()

	match _charge_state:
		0:
			if distance <= attack_range and _attack_timer <= 0.0:
				_charge_state = 1
				_charge_timer = charge_windup
				_charge_direction = direction
				_attack_timer = attack_cooldown
				_flash(Color(1.0, 0.55, 0.2, 1.0), charge_windup)
				return Vector2.ZERO
			return direction * move_speed * 0.8
		1:
			_charge_timer -= delta
			if _charge_timer <= 0.0:
				_charge_state = 2
				_charge_timer = charge_duration
			return Vector2.ZERO
		2:
			_charge_timer -= delta
			if _charge_timer <= 0.0:
				_charge_state = 3
				_charge_timer = charge_recover
			return _charge_direction * charge_speed
		3:
			_charge_timer -= delta
			if _charge_timer <= 0.0:
				_charge_state = 0
			return Vector2.ZERO

	return Vector2.ZERO


func _update_bomber(delta: float) -> Vector2:
	var direction := _direction_to_target()
	var distance := global_position.distance_to(target.global_position)
	if direction.length_squared() > 0.001:
		rotation = direction.angle()

	if _is_self_destructing:
		_self_destruct_timer -= delta
		visual.modulate = Color(1.0, 0.28 + sin(Time.get_ticks_msec() * 0.02) * 0.18, 0.12, 1.0)
		if _self_destruct_timer <= 0.0:
			_self_destruct()
		return Vector2.ZERO

	if distance <= attack_range:
		_is_self_destructing = true
		_self_destruct_timer = self_destruct_windup
		_flash(Color(1.0, 0.16, 0.08, 1.0), self_destruct_windup)
		return Vector2.ZERO

	return direction * move_speed


func _update_summoner() -> Vector2:
	var offset := target.global_position - global_position
	var distance := offset.length()
	var direction := offset.normalized() if distance > 0.001 else Vector2.RIGHT
	rotation = direction.angle()

	if _attack_timer <= 0.0:
		_summon_minions()
		_attack_timer = attack_cooldown

	if distance < preferred_range:
		return -direction * move_speed * 0.55
	if distance > preferred_range * 1.35:
		return direction * move_speed * 0.45
	return Vector2.ZERO


func _update_shielded() -> Vector2:
	var direction := _direction_to_target()
	if direction.length_squared() > 0.001:
		rotation = direction.angle()
	return direction * move_speed * 0.72


func _direction_to_target() -> Vector2:
	if target == null or not is_instance_valid(target):
		return Vector2.ZERO
	var offset := target.global_position - global_position
	if offset.length_squared() <= 0.001:
		return Vector2.ZERO
	return offset.normalized()


func _fire_projectile(direction: Vector2) -> void:
	if projectile_scene == null:
		return

	var projectile := projectile_scene.instantiate() as Node2D
	if projectile == null:
		return

	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position + direction * 22.0
	projectile.call("launch", direction, projectile_speed, attack_damage, self)


func _summon_minions() -> void:
	if summon_scene == null:
		return

	for index in range(maxi(summon_count, 1)):
		var angle := TAU * float(index) / float(maxi(summon_count, 1))
		var minion := summon_scene.instantiate() as Node2D
		if minion == null:
			continue

		get_tree().current_scene.add_child(minion)
		minion.global_position = global_position + Vector2.RIGHT.rotated(angle) * summon_spacing
		Events.enemy_spawned.emit(minion)


func _self_destruct() -> void:
	if _dead:
		return

	if target != null and is_instance_valid(target):
		var distance := global_position.distance_to(target.global_position)
		if distance <= self_destruct_radius and target.has_method("take_damage"):
			target.call("take_damage", attack_damage, self)

	_spawn_death_effect()
	_apply_elite_death_explosion()
	Events.enemy_died.emit(self)
	died.emit(self)
	_dead = true
	queue_free()


func _calculate_damage_after_defense(amount: int, knockback_direction: Vector2) -> int:
	if behavior_type != BehaviorType.SHIELDED or knockback_direction.length_squared() <= 0.001:
		return amount

	var forward := Vector2.RIGHT.rotated(rotation)
	var incoming_dot := knockback_direction.normalized().dot(forward)
	var front_threshold := -cos(deg_to_rad(shield_front_arc_degrees * 0.5))
	if incoming_dot <= front_threshold:
		return floori(float(amount) * shield_front_damage_multiplier)

	return amount


func _flash(color: Color, duration: float) -> void:
	visual.modulate = color
	var tween := create_tween()
	tween.tween_property(visual, "modulate", Color.WHITE, duration)


func _die() -> void:
	_dead = true
	_spawn_death_effect()
	_apply_elite_death_explosion()
	Events.enemy_died.emit(self)
	died.emit(self)
	queue_free()


func _spawn_death_effect() -> void:
	var effect := DEATH_BURST_SCENE.instantiate() as Node2D
	if effect == null:
		return

	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position


func _apply_elite_death_explosion() -> void:
	if not is_elite or elite_death_explosion_radius <= 0.0 or elite_death_explosion_damage <= 0:
		return

	var warning := DANGER_WARNING_SCENE.instantiate() as Node2D
	if warning == null:
		return

	get_tree().current_scene.add_child(warning)
	warning.global_position = global_position
	warning.call(
		"configure_circle",
		elite_death_explosion_radius,
		0.45,
		Color(1.0, 0.36, 0.08, 0.48),
		elite_death_explosion_damage,
		self
	)

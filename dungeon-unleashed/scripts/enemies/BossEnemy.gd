extends CharacterBody2D
class_name BossEnemy

const DEATH_BURST_SCENE := preload("res://scenes/effects/DeathBurst.tscn")
const DANGER_WARNING_SCENE := preload("res://scenes/effects/DangerWarning.tscn")

@export var display_name: String = "Dungeon Core"
@export var max_health: int = 48
@export var move_speed: float = 74.0
@export var contact_damage: int = 1
@export var attack_damage: int = 1
@export var attack_cooldown: float = 1.45
@export var attack_windup: float = 0.35
@export var phase_two_health_ratio: float = 0.5
@export var phase_transition_duration: float = 0.9
@export var phase_transition_warning_radius: float = 285.0
@export var preferred_range: float = 310.0
@export var projectile_scene: PackedScene = preload("res://scenes/projectiles/EnemyProjectile.tscn")
@export var projectile_speed: float = 330.0
@export var radial_projectile_count: int = 12
@export var volley_projectile_count: int = 3
@export var volley_spread_degrees: float = 22.0
@export var summon_scene: PackedScene = preload("res://scenes/enemies/ChaserEnemy.tscn")
@export var summon_count: int = 2
@export var max_active_summons: int = 4
@export var summon_spacing: float = 76.0

@onready var visual: CanvasItem = $Visual

var current_health: int
var target: Node2D
var _dead := false
var _phase := 1
var _attack_timer := 0.75
var _attack_index := 0
var _phase_transition_timer := 0.0
var _summoned_minions: Array[Node] = []


func _ready() -> void:
	add_to_group("enemies")
	add_to_group("bosses")
	current_health = max_health
	_find_target()
	_emit_health()
	Events.boss_phase_changed.emit(self, _phase)


func _physics_process(delta: float) -> void:
	if _dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if target == null or not is_instance_valid(target):
		_find_target()

	_tick_phase_transition(delta)
	if _phase_transition_timer > 0.0:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	_update_movement()
	_tick_attack(delta)
	move_and_slide()


func is_dead() -> bool:
	return _dead


func get_phase() -> int:
	return _phase


func get_phase_transition_remaining() -> float:
	return _phase_transition_timer


func apply_damage(amount: int, _source: Node = null, _knockback_direction: Vector2 = Vector2.ZERO, _knockback_force: float = 0.0) -> void:
	if _dead:
		return

	var final_amount := maxi(amount, 0)
	if final_amount <= 0:
		return

	current_health = maxi(current_health - final_amount, 0)
	Events.enemy_damaged.emit(self, final_amount)
	_emit_health()
	_flash(Color(1.0, 0.82, 0.35, 1.0), 0.12)
	_update_phase()

	if current_health <= 0:
		_die()


func _find_target() -> void:
	target = get_tree().get_first_node_in_group("player") as Node2D


func _update_movement() -> void:
	if target == null or not is_instance_valid(target):
		velocity = Vector2.ZERO
		return

	if target.has_method("is_alive") and not bool(target.call("is_alive")):
		velocity = Vector2.ZERO
		return

	var offset := target.global_position - global_position
	var distance := offset.length()
	var direction := offset.normalized() if distance > 0.001 else Vector2.RIGHT
	rotation = direction.angle()

	var phase_speed := move_speed * (1.18 if _phase == 2 else 1.0)
	if distance < preferred_range * 0.72:
		velocity = -direction * phase_speed * 0.55
	elif distance > preferred_range * 1.28:
		velocity = direction * phase_speed
	else:
		var strafe := direction.orthogonal()
		velocity = strafe * phase_speed * 0.42


func _tick_attack(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return
	if _phase_transition_timer > 0.0:
		return

	_attack_timer = maxf(_attack_timer - delta, 0.0)
	if _attack_timer > 0.0:
		return

	match _attack_index % 3:
		0:
			_start_radial_burst()
		1:
			_start_aimed_volley()
		_:
			_summon_minions()

	_attack_index += 1
	_attack_timer = attack_cooldown * (0.72 if _phase == 2 else 1.0)


func _start_radial_burst() -> void:
	var count := radial_projectile_count + (6 if _phase == 2 else 0)
	var start_angle := randf_range(0.0, TAU / float(maxi(count, 1)))
	_spawn_circle_warning(170.0 + float(count) * 3.0, Color(1.0, 0.24, 0.12, 0.34))
	get_tree().create_timer(attack_windup).timeout.connect(_fire_radial_burst_now.bind(count, start_angle))


func _fire_radial_burst_now(count: int, start_angle: float) -> void:
	if _dead:
		return

	for index in range(count):
		var angle := start_angle + TAU * float(index) / float(count)
		_fire_projectile(Vector2.RIGHT.rotated(angle))
	_flash(Color(1.0, 0.35, 0.2, 1.0), 0.16)


func _start_aimed_volley() -> void:
	var direction := _direction_to_target()
	if direction.length_squared() <= 0.001:
		return

	var count := volley_projectile_count + (2 if _phase == 2 else 0)
	var total_spread := deg_to_rad(volley_spread_degrees * (1.35 if _phase == 2 else 1.0))
	var start_angle := -total_spread * 0.5
	var step := total_spread / float(maxi(count - 1, 1))
	for index in range(count):
		var angle := start_angle + step * float(index)
		_spawn_line_warning(direction.rotated(angle), 520.0, 22.0, Color(1.0, 0.58, 0.12, 0.32))
	get_tree().create_timer(attack_windup).timeout.connect(_fire_aimed_volley_now.bind(direction, count, start_angle, step))


func _fire_aimed_volley_now(direction: Vector2, count: int, start_angle: float, step: float) -> void:
	if _dead:
		return

	for index in range(count):
		var angle := start_angle + step * float(index)
		_fire_projectile(direction.rotated(angle))
	_flash(Color(1.0, 0.65, 0.18, 1.0), 0.14)


func _summon_minions() -> void:
	_prune_summons()
	if summon_scene == null or _summoned_minions.size() >= max_active_summons:
		_start_aimed_volley()
		return

	var remaining_slots := max_active_summons - _summoned_minions.size()
	var count := mini(summon_count + (1 if _phase == 2 else 0), remaining_slots)
	for index in range(count):
		var angle := TAU * float(index) / float(maxi(count, 1)) + rotation
		var minion := summon_scene.instantiate() as Node2D
		if minion == null:
			continue

		get_tree().current_scene.add_child(minion)
		minion.global_position = global_position + Vector2.RIGHT.rotated(angle) * summon_spacing
		_summoned_minions.append(minion)
		Events.enemy_spawned.emit(minion)
	_flash(Color(0.72, 0.42, 1.0, 1.0), 0.18)


func _fire_projectile(direction: Vector2) -> void:
	if projectile_scene == null:
		return

	var projectile := projectile_scene.instantiate() as Node2D
	if projectile == null:
		return

	var normalized_direction := direction.normalized() if direction.length_squared() > 0.001 else Vector2.RIGHT
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position + normalized_direction * 44.0
	projectile.call("launch", normalized_direction, projectile_speed * (1.14 if _phase == 2 else 1.0), attack_damage, self)


func _spawn_circle_warning(warning_radius: float, color: Color, warning_duration: float = -1.0) -> void:
	var warning := DANGER_WARNING_SCENE.instantiate() as Node2D
	if warning == null:
		return
	var duration := attack_windup if warning_duration <= 0.0 else warning_duration
	get_tree().current_scene.add_child(warning)
	warning.global_position = global_position
	warning.call("configure_circle", warning_radius, duration, color, 0, self)


func _spawn_line_warning(direction: Vector2, warning_length: float, warning_width: float, color: Color) -> void:
	var warning := DANGER_WARNING_SCENE.instantiate() as Node2D
	if warning == null:
		return
	var normalized_direction := direction.normalized() if direction.length_squared() > 0.001 else Vector2.RIGHT
	get_tree().current_scene.add_child(warning)
	warning.global_position = global_position + normalized_direction * 44.0
	warning.call("configure_line", warning_length, warning_width, attack_windup, normalized_direction.angle(), color)


func _direction_to_target() -> Vector2:
	if target == null or not is_instance_valid(target):
		return Vector2.ZERO
	var offset := target.global_position - global_position
	if offset.length_squared() <= 0.001:
		return Vector2.ZERO
	return offset.normalized()


func _update_phase() -> void:
	if _phase != 1:
		return

	if current_health > roundi(float(max_health) * phase_two_health_ratio):
		return

	_phase = 2
	if visual != null:
		visual.modulate = Color(1.0, 0.28, 0.42, 1.0)
		_pulse_phase_transition_visual()
	_begin_phase_transition()
	Events.boss_phase_changed.emit(self, _phase)


func _begin_phase_transition() -> void:
	_phase_transition_timer = maxf(phase_transition_duration, 0.05)
	_attack_timer = _phase_transition_timer + attack_windup
	_attack_index = 0
	velocity = Vector2.ZERO
	_clear_enemy_projectiles()
	_spawn_circle_warning(phase_transition_warning_radius, Color(1.0, 0.12, 0.34, 0.42), _phase_transition_timer)


func _tick_phase_transition(delta: float) -> void:
	if _phase_transition_timer <= 0.0:
		return
	_phase_transition_timer = maxf(_phase_transition_timer - delta, 0.0)


func _pulse_phase_transition_visual() -> void:
	if visual == null:
		return
	var tween := create_tween()
	tween.tween_property(visual, "scale", Vector2.ONE * 1.18, phase_transition_duration * 0.35)
	tween.tween_property(visual, "scale", Vector2.ONE, phase_transition_duration * 0.65)


func _clear_enemy_projectiles() -> void:
	for projectile in get_tree().get_nodes_in_group("enemy_projectiles"):
		if is_instance_valid(projectile) and not projectile.is_queued_for_deletion():
			projectile.queue_free()


func _emit_health() -> void:
	Events.boss_health_changed.emit(self, current_health, max_health)


func _flash(color: Color, duration: float) -> void:
	if visual == null:
		return

	visual.modulate = color
	var target_color := Color(1.0, 0.28, 0.42, 1.0) if _phase == 2 else Color.WHITE
	var tween := create_tween()
	tween.tween_property(visual, "modulate", target_color, duration)


func _die() -> void:
	if _dead:
		return

	_dead = true
	_clear_summons()
	_spawn_death_effect()
	Events.enemy_died.emit(self)
	Events.boss_died.emit(self)
	queue_free()


func _spawn_death_effect() -> void:
	for index in range(5):
		var effect := DEATH_BURST_SCENE.instantiate() as Node2D
		if effect == null:
			continue
		get_tree().current_scene.add_child(effect)
		effect.global_position = global_position + Vector2.RIGHT.rotated(TAU * float(index) / 5.0) * 30.0


func _prune_summons() -> void:
	var alive: Array[Node] = []
	for minion in _summoned_minions:
		if is_instance_valid(minion) and not minion.is_queued_for_deletion():
			alive.append(minion)
	_summoned_minions = alive


func _clear_summons() -> void:
	for minion in _summoned_minions:
		if is_instance_valid(minion) and not minion.is_queued_for_deletion():
			minion.queue_free()
	_summoned_minions.clear()

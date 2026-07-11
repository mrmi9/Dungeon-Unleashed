extends CharacterBody2D
class_name BossEnemy

const DEATH_BURST_SCENE := preload("res://scenes/effects/DeathBurst.tscn")
const DANGER_WARNING_SCENE := preload("res://scenes/effects/DangerWarning.tscn")
const PLAYER_BODY_COLLISION_BIT := 1

@export var display_name: String = "Dungeon Core"
@export var source_id: StringName = &""
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
@export var min_summon_distance_from_player: float = 145.0
@export var spawn_contact_grace_duration: float = 0.45
@export_enum("generic", "pincer_gates", "bastion_lock", "void_bloom") var signature_attack: String = "generic"
@export var signature_windup: float = 0.55
@export var signature_projectile_count: int = 8
@export var signature_radius: float = 140.0
@export var signature_range: float = 520.0
@export var signature_guard_duration: float = 1.6
@export_range(0.1, 1.0, 0.05) var signature_guard_damage_multiplier: float = 0.55
@export_enum("generic", "warren_sweep", "iron_quake", "rift_cross") var phase_two_attack: String = "generic"
@export var phase_two_attack_windup: float = 0.62
@export var phase_two_attack_projectile_count: int = 8
@export var phase_two_attack_radius: float = 150.0
@export var phase_two_attack_range: float = 520.0

@onready var visual: CanvasItem = $Visual
@onready var core_visual: CanvasItem = get_node_or_null("Core") as CanvasItem
@onready var action_sprite: Sprite2D = get_node_or_null("ActionSprite") as Sprite2D

var current_health: int
var target: Node2D
var _dead := false
var _phase := 1
var _attack_timer := 0.75
var _attack_index := 0
var _phase_transition_timer := 0.0
var _summoned_minions: Array[Node] = []
var _spawn_contact_grace_timer := 0.0
var _signature_guard_timer := 0.0
var _signature_attack_count := 0
var _phase_two_attack_count := 0
var _boss_action_timer := 0.0
var _boss_action_is_signature := false
var _action_sprite_base_modulate := Color.WHITE
var _action_sprite_base_scale := Vector2.ONE


func _ready() -> void:
	add_to_group("enemies")
	add_to_group("bosses")
	collision_mask = collision_mask & ~PLAYER_BODY_COLLISION_BIT
	current_health = max_health
	_spawn_contact_grace_timer = maxf(spawn_contact_grace_duration, 0.0)
	_configure_action_sprite()
	_find_target()
	_emit_health()
	Events.boss_phase_changed.emit(self, _phase)


func _physics_process(delta: float) -> void:
	if _dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if _spawn_contact_grace_timer > 0.0:
		_spawn_contact_grace_timer = maxf(_spawn_contact_grace_timer - delta, 0.0)
	if _signature_guard_timer > 0.0:
		_signature_guard_timer = maxf(_signature_guard_timer - delta, 0.0)

	if target == null or not is_instance_valid(target):
		_find_target()

	_tick_phase_transition(delta)
	_tick_boss_action_sprite(delta)
	if _phase_transition_timer > 0.0:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	_update_movement()
	_tick_attack(delta)
	move_and_slide()


func is_dead() -> bool:
	return _dead


func can_deal_contact_damage() -> bool:
	return not _dead and _spawn_contact_grace_timer <= 0.0


func get_phase() -> int:
	return _phase


func get_phase_transition_remaining() -> float:
	return _phase_transition_timer


func get_signature_attack_summary() -> Dictionary:
	return {
		"id": signature_attack,
		"display_name": _get_signature_display_name(),
		"windup": signature_windup,
		"projectile_count": signature_projectile_count,
		"radius": signature_radius,
		"range": signature_range,
		"guard_duration": signature_guard_duration,
		"guard_damage_multiplier": signature_guard_damage_multiplier,
		"guard_active": _signature_guard_timer > 0.0,
		"uses": _signature_attack_count,
		"action_sprite": get_action_sprite_summary(),
		"phase_two_attack": get_phase_two_attack_summary(),
	}


func get_phase_two_attack_summary() -> Dictionary:
	return {
		"id": phase_two_attack,
		"display_name": _get_phase_two_attack_display_name(),
		"windup": phase_two_attack_windup,
		"projectile_count": phase_two_attack_projectile_count,
		"radius": phase_two_attack_radius,
		"range": phase_two_attack_range,
		"uses": _phase_two_attack_count,
	}


func get_action_sprite_summary() -> Dictionary:
	var world_frame_size := 0.0
	if action_sprite != null and action_sprite.texture != null:
		world_frame_size = action_sprite.texture.get_size().x * absf(action_sprite.scale.x) * 0.5
	return {
		"enabled": action_sprite != null and action_sprite.texture != null,
		"frame": action_sprite.frame if action_sprite != null else -1,
		"hframes": action_sprite.hframes if action_sprite != null else 0,
		"vframes": action_sprite.vframes if action_sprite != null else 0,
		"fallback_hidden": visual != null and not visual.visible,
		"core_hidden": core_visual == null or not core_visual.visible,
		"world_frame_size": world_frame_size,
	}


func is_signature_guard_active() -> bool:
	return _signature_guard_timer > 0.0


func get_damage_source_summary() -> Dictionary:
	return {
		"source_id": _get_damage_source_id(),
		"source_name": display_name,
		"source_type": "boss",
		"source_scene": scene_file_path,
		"boss_phase": _phase,
		"source_review_tip": _get_signature_review_tip(),
		"source_threat_intel": "Boss Threat | Signature %s | Phase 2 %s | Counter %s | Codex death_source_%s" % [_get_signature_display_name(), _get_phase_two_attack_display_name(), _get_signature_counter_text(), _get_damage_source_id()],
		"source_counter_tags": _get_signature_counter_tags(),
		"signature_attack": signature_attack,
		"signature_name": _get_signature_display_name(),
		"phase_two_attack": phase_two_attack,
		"phase_two_name": _get_phase_two_attack_display_name(),
	}


func _get_damage_source_id() -> String:
	var explicit_id := str(source_id).strip_edges()
	if not explicit_id.is_empty():
		return explicit_id.to_snake_case()

	var scene_path := scene_file_path.strip_edges()
	if not scene_path.is_empty():
		return scene_path.get_file().get_basename().to_snake_case()

	var resolved_name := display_name.strip_edges()
	if not resolved_name.is_empty():
		return resolved_name.to_snake_case()

	if not name.is_empty():
		return name.to_snake_case()
	return "boss"


func apply_damage(amount: int, _source: Node = null, _knockback_direction: Vector2 = Vector2.ZERO, _knockback_force: float = 0.0) -> void:
	if _dead:
		return

	var final_amount := maxi(amount, 0)
	if final_amount > 0 and _signature_guard_timer > 0.0:
		final_amount = maxi(roundi(float(final_amount) * signature_guard_damage_multiplier), 1)
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

	var cycle_size := 5 if _phase == 2 and phase_two_attack != "generic" else 4
	match _attack_index % cycle_size:
		0:
			_start_radial_burst()
		1:
			_start_aimed_volley()
		2:
			_summon_minions()
		3:
			_start_signature_attack()
		_:
			_start_phase_two_attack()

	_attack_index += 1
	_attack_timer = attack_cooldown * (0.72 if _phase == 2 else 1.0)


func _start_signature_attack() -> void:
	_signature_attack_count += 1
	_start_boss_action_animation(signature_windup, true)
	match signature_attack:
		"pincer_gates":
			_start_pincer_gates()
		"bastion_lock":
			_start_bastion_lock()
		"void_bloom":
			_start_void_bloom()
		_:
			_start_radial_burst()


func _start_phase_two_attack() -> void:
	_phase_two_attack_count += 1
	_start_boss_action_animation(phase_two_attack_windup, true)
	match phase_two_attack:
		"warren_sweep":
			_start_warren_sweep()
		"iron_quake":
			_start_iron_quake()
		"rift_cross":
			_start_rift_cross()
		_:
			_start_signature_attack()


func _start_warren_sweep() -> void:
	var target_position := target.global_position if target != null and is_instance_valid(target) else global_position + Vector2.RIGHT * preferred_range
	var direction := (target_position - global_position).normalized()
	if direction.length_squared() <= 0.001:
		direction = Vector2.RIGHT
	var lane_spacing := maxf(phase_two_attack_radius * 0.55, 56.0)
	var side := direction.orthogonal()
	var origins: Array[Vector2] = []
	for lane_index in range(-1, 2):
		var origin := global_position + side * lane_spacing * float(lane_index)
		origins.append(origin)
		_spawn_line_warning_at(origin, direction, phase_two_attack_range, 30.0, Color(0.92, 0.5, 0.18, 0.38), phase_two_attack_windup, &"warren_sweep")
	get_tree().create_timer(maxf(phase_two_attack_windup, 0.05)).timeout.connect(_fire_warren_sweep_now.bind(origins, direction))


func _fire_warren_sweep_now(origins: Array[Vector2], direction: Vector2) -> void:
	if _dead:
		return
	var shots_per_lane := maxi(ceili(float(phase_two_attack_projectile_count) / float(maxi(origins.size(), 1))), 1)
	var spread := deg_to_rad(10.0)
	for origin in origins:
		for shot_index in range(shots_per_lane):
			var ratio := 0.5 if shots_per_lane <= 1 else float(shot_index) / float(shots_per_lane - 1)
			_fire_projectile_from(origin, direction.rotated(lerpf(-spread, spread, ratio)))
	_flash(Color(1.0, 0.58, 0.22, 1.0), 0.18)


func _start_iron_quake() -> void:
	_spawn_circle_warning(maxf(phase_two_attack_radius, 100.0), Color(0.95, 0.34, 0.16, 0.4), phase_two_attack_windup, &"iron_quake")
	get_tree().create_timer(maxf(phase_two_attack_windup, 0.05)).timeout.connect(_fire_iron_quake_ring.bind(0.0, true))


func _fire_iron_quake_ring(angle_offset: float, schedule_echo: bool) -> void:
	if _dead:
		return
	var count := maxi(phase_two_attack_projectile_count, 6)
	for index in range(count):
		_fire_projectile(Vector2.RIGHT.rotated(angle_offset + TAU * float(index) / float(count)))
	_flash(Color(1.0, 0.42, 0.2, 1.0), 0.16)
	if schedule_echo:
		get_tree().create_timer(0.16).timeout.connect(_fire_iron_quake_ring.bind(PI / float(count), false))


func _start_rift_cross() -> void:
	var target_position := target.global_position if target != null and is_instance_valid(target) else global_position
	var axis := (target_position - global_position).normalized()
	if axis.length_squared() <= 0.001:
		axis = Vector2.RIGHT
	var side := axis.orthogonal()
	var half_range := maxf(phase_two_attack_range * 0.5, 120.0)
	var origins: Array[Vector2] = [
		target_position - axis * half_range,
		target_position + axis * half_range,
		target_position - side * half_range,
		target_position + side * half_range,
	]
	for origin in origins:
		var inward := (target_position - origin).normalized()
		_spawn_line_warning_at(origin, inward, half_range, 28.0, Color(0.58, 0.28, 1.0, 0.42), phase_two_attack_windup, &"rift_cross")
	get_tree().create_timer(maxf(phase_two_attack_windup, 0.05)).timeout.connect(_fire_rift_cross_now.bind(origins, target_position))


func _fire_rift_cross_now(origins: Array[Vector2], target_position: Vector2) -> void:
	if _dead:
		return
	var shots_per_arm := maxi(ceili(float(phase_two_attack_projectile_count) / float(maxi(origins.size(), 1))), 1)
	var spread := deg_to_rad(8.0)
	for origin in origins:
		var inward := (target_position - origin).normalized()
		for shot_index in range(shots_per_arm):
			var ratio := 0.5 if shots_per_arm <= 1 else float(shot_index) / float(shots_per_arm - 1)
			_fire_projectile_from(origin, inward.rotated(lerpf(-spread, spread, ratio)))
	_flash(Color(0.72, 0.38, 1.0, 1.0), 0.2)


func _start_pincer_gates() -> void:
	var target_position := target.global_position if target != null and is_instance_valid(target) else global_position + Vector2.RIGHT * preferred_range
	var direction := (target_position - global_position).normalized()
	if direction.length_squared() <= 0.001:
		direction = Vector2.RIGHT
	var side := direction.orthogonal() * maxf(signature_radius, 40.0)
	var origins: Array[Vector2] = [global_position + side, global_position - side]
	for origin in origins:
		var lane_direction := (target_position - origin).normalized()
		_spawn_line_warning_at(origin, lane_direction, signature_range, 34.0, Color(0.88, 0.68, 0.22, 0.38), signature_windup)
	get_tree().create_timer(maxf(signature_windup, 0.05)).timeout.connect(_fire_pincer_gates_now.bind(origins, target_position))


func _fire_pincer_gates_now(origins: Array[Vector2], target_position: Vector2) -> void:
	if _dead:
		return
	var shots_per_gate := maxi(ceili(float(signature_projectile_count) * 0.5), 1)
	var spread := deg_to_rad(18.0 if _phase == 1 else 26.0)
	for origin in origins:
		var base_direction := (target_position - origin).normalized()
		for index in range(shots_per_gate):
			var ratio := 0.5 if shots_per_gate <= 1 else float(index) / float(shots_per_gate - 1)
			_fire_projectile_from(origin, base_direction.rotated(lerpf(-spread * 0.5, spread * 0.5, ratio)))
	_flash(Color(0.95, 0.72, 0.24, 1.0), 0.16)


func _start_bastion_lock() -> void:
	_signature_guard_timer = maxf(signature_guard_duration, signature_windup)
	_spawn_circle_warning(maxf(signature_radius, 80.0), Color(0.38, 0.72, 1.0, 0.34), signature_windup)
	_pulse_signature_visual(Color(0.42, 0.78, 1.0, 1.0), _signature_guard_timer)
	get_tree().create_timer(maxf(signature_windup, 0.05)).timeout.connect(_fire_bastion_lock_now)


func _fire_bastion_lock_now() -> void:
	if _dead:
		return
	var count := maxi(signature_projectile_count + (4 if _phase == 2 else 0), 4)
	for index in range(count):
		_fire_projectile(Vector2.RIGHT.rotated(TAU * float(index) / float(count)))
	_flash(Color(0.52, 0.82, 1.0, 1.0), 0.18)


func _start_void_bloom() -> void:
	var target_position := target.global_position if target != null and is_instance_valid(target) else global_position
	_spawn_circle_warning_at(target_position, maxf(signature_radius, 80.0), Color(0.68, 0.28, 1.0, 0.42), signature_windup, attack_damage)
	get_tree().create_timer(maxf(signature_windup, 0.05)).timeout.connect(_fire_void_bloom_now.bind(target_position))


func _fire_void_bloom_now(origin: Vector2) -> void:
	if _dead:
		return
	var count := maxi(signature_projectile_count + (4 if _phase == 2 else 0), 6)
	var offset := PI / float(count) if _phase == 2 else 0.0
	for index in range(count):
		_fire_projectile_from(origin, Vector2.RIGHT.rotated(offset + TAU * float(index) / float(count)))
	_flash(Color(0.68, 0.34, 1.0, 1.0), 0.2)


func _start_radial_burst() -> void:
	_start_boss_action_animation(attack_windup, false)
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

	_start_boss_action_animation(attack_windup, false)
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
	_start_boss_action_animation(0.2, false)
	for index in range(count):
		var angle := TAU * float(index) / float(maxi(count, 1)) + rotation
		var minion := summon_scene.instantiate() as Node2D
		if minion == null:
			continue

		get_tree().current_scene.add_child(minion)
		minion.global_position = _get_safe_summon_position(angle)
		_summoned_minions.append(minion)
		Events.enemy_spawned.emit(minion)
	_flash(Color(0.72, 0.42, 1.0, 1.0), 0.18)


func _get_safe_summon_position(angle: float) -> Vector2:
	var position := global_position + Vector2.RIGHT.rotated(angle) * summon_spacing
	var player := target
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null or not is_instance_valid(player):
		return position

	var minimum_distance := maxf(min_summon_distance_from_player, summon_spacing)
	if position.distance_to(player.global_position) >= minimum_distance:
		return position

	var away := position - player.global_position
	if away.length_squared() <= 0.001:
		away = Vector2.RIGHT.rotated(angle + PI)
	return player.global_position + away.normalized() * minimum_distance


func _fire_projectile(direction: Vector2) -> void:
	_fire_projectile_from(global_position, direction)


func _fire_projectile_from(origin: Vector2, direction: Vector2) -> void:
	if projectile_scene == null:
		return

	var projectile := projectile_scene.instantiate() as Node2D
	if projectile == null:
		return

	var normalized_direction := direction.normalized() if direction.length_squared() > 0.001 else Vector2.RIGHT
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = origin + normalized_direction * 44.0
	projectile.call("launch", normalized_direction, projectile_speed * (1.14 if _phase == 2 else 1.0), attack_damage, self)


func _spawn_circle_warning(warning_radius: float, color: Color, warning_duration: float = -1.0, warning_purpose: StringName = &"danger") -> void:
	_spawn_circle_warning_at(global_position, warning_radius, color, warning_duration, 0, warning_purpose)


func _spawn_circle_warning_at(position: Vector2, warning_radius: float, color: Color, warning_duration: float = -1.0, warning_damage: int = 0, warning_purpose: StringName = &"danger") -> void:
	var warning := DANGER_WARNING_SCENE.instantiate() as Node2D
	if warning == null:
		return
	var duration := attack_windup if warning_duration <= 0.0 else warning_duration
	get_tree().current_scene.add_child(warning)
	warning.global_position = position
	warning.call("configure_circle", warning_radius, duration, color, warning_damage, self, warning_purpose)


func _spawn_line_warning(direction: Vector2, warning_length: float, warning_width: float, color: Color) -> void:
	_spawn_line_warning_at(global_position + direction.normalized() * 44.0, direction, warning_length, warning_width, color, attack_windup)


func _spawn_line_warning_at(position: Vector2, direction: Vector2, warning_length: float, warning_width: float, color: Color, warning_duration: float, warning_purpose: StringName = &"danger") -> void:
	var warning := DANGER_WARNING_SCENE.instantiate() as Node2D
	if warning == null:
		return
	var normalized_direction := direction.normalized() if direction.length_squared() > 0.001 else Vector2.RIGHT
	get_tree().current_scene.add_child(warning)
	warning.global_position = position
	warning.call("configure_line", warning_length, warning_width, warning_duration, normalized_direction.angle(), color, attack_damage, self, warning_purpose)


func _pulse_signature_visual(color: Color, duration: float) -> void:
	var pulse_target := _get_active_visual()
	if pulse_target == null:
		return
	pulse_target.modulate = color
	var target_color := _get_phase_visual_modulate()
	var tween := create_tween()
	tween.tween_interval(maxf(duration, 0.05))
	tween.tween_property(pulse_target, "modulate", target_color, 0.16)


func _configure_action_sprite() -> void:
	if action_sprite == null or action_sprite.texture == null:
		return
	action_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	action_sprite.frame = 0
	action_sprite.visible = true
	_action_sprite_base_modulate = action_sprite.modulate
	_action_sprite_base_scale = action_sprite.scale
	if visual != null:
		visual.visible = false
	if core_visual != null:
		core_visual.visible = false


func _start_boss_action_animation(duration: float, is_signature: bool) -> void:
	_boss_action_timer = maxf(duration, 0.05)
	_boss_action_is_signature = is_signature


func _tick_boss_action_sprite(delta: float) -> void:
	_boss_action_timer = maxf(_boss_action_timer - delta, 0.0)
	if action_sprite == null or action_sprite.texture == null:
		return
	if _phase_transition_timer > 0.0:
		action_sprite.frame = 2
	elif _boss_action_timer > 0.0:
		action_sprite.frame = 2 if _boss_action_is_signature else 1
	else:
		action_sprite.frame = 3 if _phase == 2 else 0


func _get_active_visual() -> CanvasItem:
	if action_sprite != null and action_sprite.texture != null and action_sprite.visible:
		return action_sprite
	return visual


func _get_phase_visual_modulate() -> Color:
	if action_sprite == null or action_sprite.texture == null:
		return Color(1.0, 0.28, 0.42, 1.0) if _phase == 2 else Color.WHITE
	var phase_tint := Color(1.0, 0.78, 0.84, 1.0) if _phase == 2 else Color.WHITE
	return Color(
		_action_sprite_base_modulate.r * phase_tint.r,
		_action_sprite_base_modulate.g * phase_tint.g,
		_action_sprite_base_modulate.b * phase_tint.b,
		_action_sprite_base_modulate.a
	)


func _get_signature_display_name() -> String:
	match signature_attack:
		"pincer_gates":
			return "Pincer Gates"
		"bastion_lock":
			return "Bastion Lock"
		"void_bloom":
			return "Void Bloom"
	return "Core Burst"


func _get_phase_two_attack_display_name() -> String:
	match phase_two_attack:
		"warren_sweep":
			return "Warren Sweep"
		"iron_quake":
			return "Iron Quake"
		"rift_cross":
			return "Rift Cross"
	return "Core Overdrive"


func _get_signature_review_tip() -> String:
	match signature_attack:
		"pincer_gates":
			return "Move out of the two converging lane warnings before the gate volleys close."
		"bastion_lock":
			return "Use the blue guard window to reposition, then attack after the radial lock releases."
		"void_bloom":
			return "Leave the marked bloom center before its ring erupts and opens radial lanes."
	return "Save movement and armor recovery for boss tells instead of trading during burst windows."


func _get_signature_counter_text() -> String:
	match signature_attack:
		"pincer_gates":
			return "cross the open side before converging lanes fire"
		"bastion_lock":
			return "stop trading into the blue guard window"
		"void_bloom":
			return "leave the marked center before the ring erupts"
	return "stop trading during tells"


func _get_signature_counter_tags() -> Array[String]:
	match signature_attack:
		"pincer_gates":
			return ["speed", "control", "survival"]
		"bastion_lock":
			return ["burst", "energy", "survival"]
		"void_bloom":
			return ["speed", "armor", "survival"]
	return ["survival", "armor", "damage"]


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
	var phase_visual := _get_active_visual()
	if phase_visual != null:
		phase_visual.modulate = _get_phase_visual_modulate()
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
	var pulse_target := _get_active_visual() as Node2D
	if pulse_target == null:
		return
	var base_scale := _action_sprite_base_scale if pulse_target == action_sprite else Vector2.ONE
	var tween := create_tween()
	tween.tween_property(pulse_target, "scale", base_scale * 1.18, phase_transition_duration * 0.35)
	tween.tween_property(pulse_target, "scale", base_scale, phase_transition_duration * 0.65)


func _clear_enemy_projectiles() -> void:
	for projectile in get_tree().get_nodes_in_group("enemy_projectiles"):
		if is_instance_valid(projectile) and not projectile.is_queued_for_deletion():
			projectile.queue_free()


func _emit_health() -> void:
	Events.boss_health_changed.emit(self, current_health, max_health)


func _flash(color: Color, duration: float) -> void:
	var flash_target := _get_active_visual()
	if flash_target == null:
		return

	flash_target.modulate = color
	var target_color := _get_phase_visual_modulate()
	var tween := create_tween()
	tween.tween_property(flash_target, "modulate", target_color, duration)


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

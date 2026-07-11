extends Area2D
class_name DeployableTrap

var weapon_data: WeaponData
var damage := 1
var knockback := 80.0
var radius := 64.0
var tick_interval := 0.5
var duration := 1.0
var arming_time := 0.0
var behavior := "field"

var _owner_body: Node
var _elapsed := 0.0
var _tick_timer := 0.0
var _total_hits := 0
var _triggered := false


func _ready() -> void:
	add_to_group("player_deployables")
	_update_shape()


func configure(data: WeaponData, owner_body: Node = null) -> void:
	weapon_data = data
	_owner_body = owner_body
	behavior = str(data.deployable_behavior)
	if behavior not in ["field", "mine", "sentry"]:
		behavior = "field"
	duration = maxf(data.deployable_duration * _get_owner_deployable_duration_multiplier(owner_body), 0.1)
	radius = maxf(data.deployable_radius + _get_owner_deployable_radius_bonus(owner_body), 1.0)
	tick_interval = maxf(data.deployable_tick_interval, 0.05)
	arming_time = maxf(data.deployable_arming_time, 0.0)
	damage = maxi(roundi(float(data.damage) * data.deployable_damage_multiplier * _get_owner_damage_multiplier(owner_body) * _get_owner_deployable_damage_multiplier(owner_body)), 1)
	knockback = data.knockback * _get_owner_knockback_multiplier(owner_body)
	_elapsed = 0.0
	_tick_timer = arming_time
	_total_hits = 0
	_triggered = false
	set_meta(&"last_tick_hits", 0)
	set_meta(&"total_hits", 0)
	set_meta(&"deployable_behavior", behavior)
	set_meta(&"triggered", false)
	_update_shape()


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= duration:
		queue_free()
		return

	_tick_timer -= delta
	if _tick_timer > 0.0:
		return

	_tick_damage()
	_tick_timer = tick_interval


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color(0.25, 0.8, 1.0, 0.1))
	match behavior:
		"mine":
			draw_colored_polygon(
				PackedVector2Array([Vector2(0, -16), Vector2(16, 0), Vector2(0, 16), Vector2(-16, 0)]),
				Color(1.0, 0.38, 0.18, 0.9)
			)
			draw_circle(Vector2.ZERO, 6.0, Color(1.0, 0.86, 0.3, 1.0))
			draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, Color(1.0, 0.48, 0.2, 0.78), 2.0)
		"sentry":
			draw_rect(Rect2(-13.0, -10.0, 26.0, 20.0), Color(0.32, 0.72, 1.0, 0.92), true)
			draw_rect(Rect2(-13.0, -10.0, 26.0, 20.0), Color(0.86, 0.96, 1.0, 1.0), false, 2.0)
			draw_line(Vector2.ZERO, Vector2(21.0, 0.0), Color(1.0, 0.84, 0.34, 1.0), 4.0)
			draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, Color(0.32, 0.72, 1.0, 0.62), 2.0)
		_:
			draw_circle(Vector2.ZERO, 11.0, Color(0.25, 0.8, 1.0, 0.72))
			draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, Color(0.25, 0.8, 1.0, 0.75), 2.0)
			draw_arc(Vector2.ZERO, radius * 0.62, 0.0, TAU, 32, Color(0.72, 0.94, 1.0, 0.62), 2.0)


func _tick_damage() -> int:
	if weapon_data == null or _triggered:
		return 0

	var targets := _get_targets_in_radius()
	if behavior == "sentry" and targets.size() > 1:
		var nearest_target := _get_nearest_target(targets)
		targets.clear()
		if nearest_target != null:
			targets.append(nearest_target)

	var hits := 0
	for enemy in targets:
		var enemy_node := enemy as Node2D
		var direction := (enemy_node.global_position - global_position).normalized()
		if direction.length_squared() <= 0.001:
			direction = Vector2.RIGHT
		(enemy as Node).call("apply_damage", damage, _get_safe_owner_body(), direction, knockback)
		_try_apply_status(enemy as Node)
		Events.projectile_hit.emit(null, enemy as Node, damage)
		hits += 1

	_total_hits += hits
	set_meta(&"last_tick_hits", hits)
	set_meta(&"total_hits", _total_hits)
	if behavior == "mine" and hits > 0:
		_triggered = true
		set_meta(&"triggered", true)
		queue_free()
	return hits


func get_deployable_behavior() -> String:
	return behavior


func _get_targets_in_radius() -> Array[Node]:
	var targets: Array[Node] = []
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		if not enemy is Node2D or not (enemy as Node).has_method("apply_damage"):
			continue
		if enemy.has_method("is_dead") and bool(enemy.call("is_dead")):
			continue
		if (enemy as Node2D).global_position.distance_to(global_position) <= radius:
			targets.append(enemy as Node)
	return targets


func _get_nearest_target(targets: Array[Node]) -> Node:
	var nearest: Node = null
	var nearest_distance := INF
	for target in targets:
		if not target is Node2D:
			continue
		var distance := (target as Node2D).global_position.distance_squared_to(global_position)
		if distance < nearest_distance:
			nearest = target
			nearest_distance = distance
	if nearest != null:
		var target_position := (nearest as Node2D).global_position
		set_meta(&"last_target_position", target_position)
		var aim_direction := target_position - global_position
		if aim_direction.length_squared() > 0.001:
			global_rotation = aim_direction.angle()
			queue_redraw()
	return nearest


func _try_apply_status(target: Node) -> void:
	if target == null or weapon_data == null or not target.has_method("apply_status_effect"):
		return
	if weapon_data.status_effect.is_empty() or weapon_data.status_effect == "none" or weapon_data.status_duration <= 0.0:
		return

	var chance := clampf(weapon_data.status_chance + _get_owner_status_chance_bonus(_get_safe_owner_body()), 0.0, 1.0)
	if chance <= 0.0 or randf() > chance:
		return

	target.call(
		"apply_status_effect",
		weapon_data.status_effect,
		maxf(weapon_data.status_duration * _get_owner_status_duration_multiplier(_get_safe_owner_body()), 0.0),
		maxi(roundi(float(weapon_data.status_damage_per_tick) * _get_owner_status_damage_multiplier(_get_safe_owner_body())), 0),
		maxf(weapon_data.status_tick_interval, 0.1),
		clampf(weapon_data.status_slow_multiplier, 0.1, 1.0),
		_get_safe_owner_body()
	)


func _update_shape() -> void:
	var collision_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape != null and collision_shape.shape is CircleShape2D:
		(collision_shape.shape as CircleShape2D).radius = radius
	queue_redraw()


func _get_owner_damage_multiplier(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_damage_multiplier"):
		return maxf(float(owner_body.call("get_damage_multiplier")), 0.1)
	return 1.0


func _get_owner_knockback_multiplier(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_knockback_multiplier"):
		return maxf(float(owner_body.call("get_knockback_multiplier")), 0.1)
	return 1.0


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


func _get_owner_deployable_damage_multiplier(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_deployable_damage_multiplier"):
		return maxf(float(owner_body.call("get_deployable_damage_multiplier")), 0.1)
	return 1.0


func _get_owner_deployable_duration_multiplier(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_deployable_duration_multiplier"):
		return maxf(float(owner_body.call("get_deployable_duration_multiplier")), 0.1)
	return 1.0


func _get_owner_deployable_radius_bonus(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_deployable_radius_bonus"):
		return maxf(float(owner_body.call("get_deployable_radius_bonus")), 0.0)
	return 0.0


func _get_safe_owner_body() -> Node:
	if _owner_body == null or not is_instance_valid(_owner_body):
		return null
	if _owner_body.is_queued_for_deletion():
		return null
	return _owner_body

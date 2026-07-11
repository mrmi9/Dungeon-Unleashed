extends Area2D
class_name Projectile

const HIT_BURST_SCENE := preload("res://scenes/effects/HitBurst.tscn")

var speed := 720.0
var max_range := 720.0
var damage := 1
var knockback := 120.0
var crit_chance := 0.0
var crit_multiplier := 2.0
var homing_turn_rate := 0.0
var homing_radius := 0.0
var chain_count := 0
var chain_radius := 0.0
var chain_damage_multiplier := 0.65
var explosion_radius := 0.0
var status_effect := "none"
var status_chance := 0.0
var status_duration := 0.0
var status_damage_per_tick := 0
var status_tick_interval := 1.0
var status_slow_multiplier := 1.0

var _direction := Vector2.RIGHT
var _owner_body: Node
var _distance_traveled := 0.0
var _remaining_pierce := 0
var _remaining_bounces := 0
var _last_hit_was_critical := false
var _last_hit_position := Vector2.ZERO
var _last_chain_target_count := 0
var _hit_rids: Array[RID] = []
var _hit_instance_ids := {}


func _ready() -> void:
	add_to_group("projectiles")


func launch(direction: Vector2, weapon_data: WeaponData, owner_body: Node = null, charge_ratio: float = 0.0) -> void:
	if direction.length_squared() > 0.001:
		_direction = direction.normalized()
	else:
		_direction = Vector2.RIGHT

	var resolved_charge := clampf(charge_ratio, 0.0, 1.0)
	var charge_damage_multiplier := lerpf(1.0, maxf(weapon_data.charge_damage_multiplier, 1.0), resolved_charge)
	var owner_charge_damage_multiplier := lerpf(1.0, _get_owner_charge_damage_multiplier(owner_body), resolved_charge)
	speed = weapon_data.projectile_speed * lerpf(1.0, maxf(weapon_data.charge_projectile_speed_multiplier, 0.1), resolved_charge)
	max_range = weapon_data.projectile_range
	damage = maxi(roundi(float(weapon_data.damage) * _get_owner_damage_multiplier(owner_body) * charge_damage_multiplier * owner_charge_damage_multiplier), 1)
	knockback = weapon_data.knockback * _get_owner_knockback_multiplier(owner_body)
	crit_chance = clampf(weapon_data.crit_chance + _get_owner_crit_chance_bonus(owner_body), 0.0, 1.0)
	crit_multiplier = weapon_data.crit_multiplier
	if weapon_data.homing_turn_rate > 0.0 and weapon_data.homing_radius > 0.0:
		homing_turn_rate = maxf(weapon_data.homing_turn_rate + _get_owner_homing_turn_rate_bonus(owner_body), 0.0)
		homing_radius = maxf(weapon_data.homing_radius + _get_owner_homing_radius_bonus(owner_body), 0.0)
	if weapon_data.chain_count > 0 and weapon_data.chain_radius > 0.0:
		chain_count = maxi(weapon_data.chain_count + _get_owner_chain_count_bonus(owner_body), 0)
		chain_radius = maxf(weapon_data.chain_radius + _get_owner_chain_radius_bonus(owner_body), 0.0)
	chain_damage_multiplier = maxf(weapon_data.chain_damage_multiplier * _get_owner_chain_damage_multiplier(owner_body), 0.1)
	explosion_radius = weapon_data.explosion_radius
	if explosion_radius > 0.0:
		explosion_radius += _get_owner_explosion_radius_bonus(owner_body)
	status_effect = weapon_data.status_effect
	status_chance = clampf(weapon_data.status_chance + _get_owner_status_chance_bonus(owner_body), 0.0, 1.0)
	status_duration = maxf(weapon_data.status_duration * _get_owner_status_duration_multiplier(owner_body), 0.0)
	status_damage_per_tick = maxi(roundi(float(weapon_data.status_damage_per_tick) * _get_owner_status_damage_multiplier(owner_body)), 0)
	status_tick_interval = maxf(weapon_data.status_tick_interval, 0.1)
	status_slow_multiplier = clampf(weapon_data.status_slow_multiplier, 0.1, 1.0)
	_remaining_pierce = maxi(weapon_data.pierce_count + _get_owner_pierce_bonus(owner_body), 0)
	_remaining_bounces = maxi(weapon_data.bounce_count + _get_owner_bounce_count_bonus(owner_body), 0)
	_owner_body = owner_body
	global_rotation = _direction.angle()


func _physics_process(delta: float) -> void:
	_update_homing(delta)
	var travel_distance := speed * delta
	var start_position := global_position
	var end_position := start_position + _direction * travel_distance
	var hit := _raycast(start_position, end_position)

	if not hit.is_empty():
		global_position = hit["position"]
		_distance_traveled += start_position.distance_to(global_position)
		_handle_collision(hit["collider"])
		return

	global_position = end_position
	_distance_traveled += travel_distance

	if _distance_traveled >= max_range:
		queue_free()


func _raycast(start_position: Vector2, end_position: Vector2) -> Dictionary:
	var query := PhysicsRayQueryParameters2D.create(start_position, end_position, collision_mask)
	var excludes: Array[RID] = [get_rid()]
	excludes.append_array(_hit_rids)
	var owner_body := _get_safe_owner_body()
	if owner_body is CollisionObject2D:
		excludes.append((owner_body as CollisionObject2D).get_rid())
	query.exclude = excludes

	return get_world_2d().direct_space_state.intersect_ray(query)


func _handle_collision(collider: Object) -> void:
	if collider is Node and (collider as Node).has_method("apply_damage"):
		var target := collider as Node
		var hit_position := global_position
		var owner_body := _get_safe_owner_body()
		var damage_roll := _roll_damage()
		var final_damage := int(damage_roll.get("damage", damage))
		var was_critical := bool(damage_roll.get("critical", false))
		_last_hit_was_critical = was_critical
		_last_hit_position = hit_position
		set_meta(&"last_hit_position", hit_position)
		_track_hit_target(collider)
		target.call("apply_damage", final_damage, owner_body, _direction, knockback)
		_try_apply_status(target)
		Events.projectile_hit.emit(self, target, final_damage)
		if was_critical:
			Events.projectile_critical_hit.emit(self, target, final_damage)
		_apply_explosion_damage(target, final_damage, owner_body)
		_apply_chain_damage(target, final_damage, owner_body)
		_spawn_hit_effect(was_critical)
		if _remaining_pierce > 0:
			_remaining_pierce -= 1
			global_position += _direction * 4.0
			return

		queue_free()
		return

	if _remaining_bounces > 0:
		_remaining_bounces -= 1
		_direction = _direction.bounce(_get_collision_normal()).normalized()
		global_rotation = _direction.angle()
		global_position += _direction * 4.0
		return

	queue_free()


func _spawn_hit_effect(was_critical: bool = false) -> void:
	var effect := HIT_BURST_SCENE.instantiate() as Node2D
	if effect == null:
		return

	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position
	if was_critical:
		effect.set("duration", 0.22)
		effect.set("radius", 40.0)
		effect.set("color", Color(1.0, 0.28, 0.12, 1.0))
		effect.set("line_width", 3.5)


func _roll_damage() -> Dictionary:
	if randf() < crit_chance:
		return {
			"damage": maxi(roundi(float(damage) * crit_multiplier), 1),
			"critical": true,
		}
	return {
		"damage": damage,
		"critical": false,
	}


func was_last_hit_critical() -> bool:
	return _last_hit_was_critical


func get_last_hit_position() -> Vector2:
	return _last_hit_position


func get_last_chain_target_count() -> int:
	return _last_chain_target_count


func get_direction_for_test() -> Vector2:
	return _direction


func _track_hit_target(collider: Object) -> void:
	if collider != null:
		_hit_instance_ids[collider.get_instance_id()] = true
	if collider is CollisionObject2D:
		_hit_rids.append((collider as CollisionObject2D).get_rid())


func _apply_explosion_damage(primary_target: Node, final_damage: int, owner_body: Node) -> void:
	if explosion_radius <= 0.0:
		return

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == primary_target or not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		if not enemy is Node2D or not (enemy as Node).has_method("apply_damage"):
			continue

		var enemy_node := enemy as Node2D
		var distance := enemy_node.global_position.distance_to(global_position)
		if distance <= explosion_radius:
			var direction := (enemy_node.global_position - global_position).normalized()
			(enemy as Node).call("apply_damage", final_damage, owner_body, direction, knockback * 0.7)
			_try_apply_status(enemy as Node)


func _update_homing(delta: float) -> void:
	if homing_turn_rate <= 0.0 or homing_radius <= 0.0:
		return

	var target := _get_nearest_homing_target()
	if target == null:
		return
	var desired_direction := (target.global_position - global_position).normalized()
	if desired_direction.length_squared() <= 0.001:
		return
	var turn_step := deg_to_rad(homing_turn_rate) * maxf(delta, 0.0)
	_direction = Vector2.from_angle(rotate_toward(_direction.angle(), desired_direction.angle(), turn_step))
	global_rotation = _direction.angle()


func _get_nearest_homing_target() -> Node2D:
	var nearest: Node2D = null
	var nearest_distance := homing_radius
	for candidate in get_tree().get_nodes_in_group("enemies"):
		if not candidate is Node2D or not is_instance_valid(candidate) or candidate.is_queued_for_deletion():
			continue
		if candidate is CollisionObject2D and _hit_rids.has((candidate as CollisionObject2D).get_rid()):
			continue
		var candidate_node := candidate as Node2D
		var distance := global_position.distance_to(candidate_node.global_position)
		if distance <= nearest_distance:
			nearest = candidate_node
			nearest_distance = distance
	return nearest


func _apply_chain_damage(primary_target: Node, final_damage: int, owner_body: Node) -> void:
	_last_chain_target_count = 0
	if chain_count <= 0 or chain_radius <= 0.0:
		return

	var excluded_ids := _hit_instance_ids.duplicate()
	excluded_ids[primary_target.get_instance_id()] = true
	var current_position := global_position
	var arc_points: Array[Vector2] = [current_position]
	var chain_damage := maxi(roundi(float(final_damage) * chain_damage_multiplier), 1)
	for _hop in range(chain_count):
		var target := _get_nearest_chain_target(current_position, excluded_ids)
		if target == null:
			break
		var direction := (target.global_position - current_position).normalized()
		target.call("apply_damage", chain_damage, owner_body, direction, knockback * 0.55)
		_try_apply_status(target)
		Events.projectile_hit.emit(self, target, chain_damage)
		_track_hit_target(target)
		excluded_ids[target.get_instance_id()] = true
		current_position = target.global_position
		arc_points.append(current_position)
		_last_chain_target_count += 1

	if _last_chain_target_count > 0:
		_spawn_chain_arc(arc_points)


func _get_nearest_chain_target(origin: Vector2, excluded_ids: Dictionary) -> Node2D:
	var nearest: Node2D = null
	var nearest_distance := chain_radius
	for candidate in get_tree().get_nodes_in_group("enemies"):
		if not candidate is Node2D or not is_instance_valid(candidate) or candidate.is_queued_for_deletion():
			continue
		if excluded_ids.has(candidate.get_instance_id()):
			continue
		var candidate_node := candidate as Node2D
		var distance := origin.distance_to(candidate_node.global_position)
		if distance <= nearest_distance:
			nearest = candidate_node
			nearest_distance = distance
	return nearest


func _spawn_chain_arc(points: Array[Vector2]) -> void:
	var scene_root := get_tree().current_scene
	if scene_root == null or points.size() < 2:
		return
	var arc := Line2D.new()
	arc.width = 4.0
	arc.default_color = Color(0.42, 0.9, 1.0, 0.95)
	arc.antialiased = true
	arc.z_index = 6
	scene_root.add_child(arc)
	for point in points:
		arc.add_point(arc.to_local(point))
	var tween := arc.create_tween()
	tween.tween_property(arc, "modulate:a", 0.0, 0.14)
	tween.tween_callback(arc.queue_free)


func _try_apply_status(target: Node) -> void:
	if target == null or not target.has_method("apply_status_effect"):
		return
	if status_effect.is_empty() or status_effect == "none" or status_duration <= 0.0:
		return
	if status_chance <= 0.0 or randf() > status_chance:
		return

	target.call(
		"apply_status_effect",
		status_effect,
		status_duration,
		status_damage_per_tick,
		status_tick_interval,
		status_slow_multiplier,
		_get_safe_owner_body()
	)


func _get_collision_normal() -> Vector2:
	var space_state := get_world_2d().direct_space_state
	var normal_probe := PhysicsRayQueryParameters2D.create(global_position - _direction * 8.0, global_position + _direction * 2.0, collision_mask)
	normal_probe.exclude = _hit_rids
	var result := space_state.intersect_ray(normal_probe)
	if result.has("normal"):
		return result["normal"]
	return -_direction


func _get_owner_damage_multiplier(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_damage_multiplier"):
		return maxf(float(owner_body.call("get_damage_multiplier")), 0.1)
	return 1.0


func _get_owner_pierce_bonus(owner_body: Node) -> int:
	if owner_body != null and owner_body.has_method("get_pierce_bonus"):
		return maxi(int(owner_body.call("get_pierce_bonus")), 0)
	return 0


func _get_owner_bounce_count_bonus(owner_body: Node) -> int:
	if owner_body != null and owner_body.has_method("get_bounce_count_bonus"):
		return maxi(int(owner_body.call("get_bounce_count_bonus")), 0)
	return 0


func _get_owner_homing_turn_rate_bonus(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_homing_turn_rate_bonus"):
		return maxf(float(owner_body.call("get_homing_turn_rate_bonus")), 0.0)
	return 0.0


func _get_owner_homing_radius_bonus(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_homing_radius_bonus"):
		return maxf(float(owner_body.call("get_homing_radius_bonus")), 0.0)
	return 0.0


func _get_owner_chain_count_bonus(owner_body: Node) -> int:
	if owner_body != null and owner_body.has_method("get_chain_count_bonus"):
		return maxi(int(owner_body.call("get_chain_count_bonus")), 0)
	return 0


func _get_owner_chain_radius_bonus(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_chain_radius_bonus"):
		return maxf(float(owner_body.call("get_chain_radius_bonus")), 0.0)
	return 0.0


func _get_owner_chain_damage_multiplier(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_chain_damage_multiplier"):
		return maxf(float(owner_body.call("get_chain_damage_multiplier")), 0.1)
	return 1.0


func _get_owner_explosion_radius_bonus(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_explosion_radius_bonus"):
		return maxf(float(owner_body.call("get_explosion_radius_bonus")), 0.0)
	return 0.0


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


func _get_owner_charge_damage_multiplier(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_charge_damage_multiplier"):
		return maxf(float(owner_body.call("get_charge_damage_multiplier")), 0.1)
	return 1.0


func _get_safe_owner_body() -> Node:
	if _owner_body == null or not is_instance_valid(_owner_body):
		return null
	if _owner_body.is_queued_for_deletion():
		return null
	return _owner_body

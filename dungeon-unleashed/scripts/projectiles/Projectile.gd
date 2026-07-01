extends Area2D
class_name Projectile

const HIT_BURST_SCENE := preload("res://scenes/effects/HitBurst.tscn")

var speed := 720.0
var max_range := 720.0
var damage := 1
var knockback := 120.0
var crit_chance := 0.0
var crit_multiplier := 2.0
var explosion_radius := 0.0

var _direction := Vector2.RIGHT
var _owner_body: Node
var _distance_traveled := 0.0
var _remaining_pierce := 0
var _remaining_bounces := 0
var _last_hit_was_critical := false
var _last_hit_position := Vector2.ZERO
var _hit_rids: Array[RID] = []


func _ready() -> void:
	add_to_group("projectiles")


func launch(direction: Vector2, weapon_data: WeaponData, owner_body: Node = null) -> void:
	if direction.length_squared() > 0.001:
		_direction = direction.normalized()
	else:
		_direction = Vector2.RIGHT

	speed = weapon_data.projectile_speed
	max_range = weapon_data.projectile_range
	damage = maxi(roundi(float(weapon_data.damage) * _get_owner_damage_multiplier(owner_body)), 1)
	knockback = weapon_data.knockback
	crit_chance = clampf(weapon_data.crit_chance + _get_owner_crit_chance_bonus(owner_body), 0.0, 1.0)
	crit_multiplier = weapon_data.crit_multiplier
	explosion_radius = weapon_data.explosion_radius
	_remaining_pierce = maxi(weapon_data.pierce_count + _get_owner_pierce_bonus(owner_body), 0)
	_remaining_bounces = maxi(weapon_data.bounce_count, 0)
	_owner_body = owner_body
	global_rotation = _direction.angle()


func _physics_process(delta: float) -> void:
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
		Events.projectile_hit.emit(self, target, final_damage)
		if was_critical:
			Events.projectile_critical_hit.emit(self, target, final_damage)
		_apply_explosion_damage(target, final_damage, owner_body)
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


func _track_hit_target(collider: Object) -> void:
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


func _get_owner_crit_chance_bonus(owner_body: Node) -> float:
	if owner_body != null and owner_body.has_method("get_crit_chance_bonus"):
		return clampf(float(owner_body.call("get_crit_chance_bonus")), 0.0, 1.0)
	return 0.0


func _get_safe_owner_body() -> Node:
	if _owner_body == null or not is_instance_valid(_owner_body):
		return null
	if _owner_body.is_queued_for_deletion():
		return null
	return _owner_body

extends Area2D
class_name EnemyProjectile

const HIT_BURST_SCENE := preload("res://scenes/effects/HitBurst.tscn")

@export var max_range: float = 620.0

var speed := 340.0
var damage := 1
var _direction := Vector2.RIGHT
var _owner_ref: WeakRef
var _owner_rid := RID()
var _distance_traveled := 0.0
var _damage_source_summary: Dictionary = {}


func _ready() -> void:
	add_to_group("enemy_projectiles")


func launch(direction: Vector2, projectile_speed: float, projectile_damage: int, owner_body: Node = null) -> void:
	_direction = direction.normalized() if direction.length_squared() > 0.001 else Vector2.RIGHT
	speed = projectile_speed
	damage = projectile_damage
	_owner_ref = weakref(owner_body) if owner_body != null else null
	_owner_rid = (owner_body as CollisionObject2D).get_rid() if owner_body is CollisionObject2D else RID()
	_damage_source_summary = _build_damage_source_summary(owner_body)
	global_rotation = _direction.angle()


func _physics_process(delta: float) -> void:
	var travel_distance := speed * delta
	var start_position := global_position
	var end_position := start_position + _direction * travel_distance
	var hit := _raycast(start_position, end_position)

	if not hit.is_empty():
		global_position = hit["position"]
		_handle_collision(hit["collider"])
		return

	global_position = end_position
	_distance_traveled += travel_distance
	if _distance_traveled >= max_range:
		queue_free()


func _raycast(start_position: Vector2, end_position: Vector2) -> Dictionary:
	var query := PhysicsRayQueryParameters2D.create(start_position, end_position, collision_mask)
	var excludes: Array[RID] = [get_rid()]
	if _owner_rid.is_valid():
		excludes.append(_owner_rid)
	query.exclude = excludes
	return get_world_2d().direct_space_state.intersect_ray(query)


func _handle_collision(collider: Object) -> void:
	if collider is Node and (collider as Node).has_method("take_damage"):
		var source := _get_safe_owner_body()
		(collider as Node).call("take_damage", damage, source if source != null else self)
		_spawn_hit_effect()
	queue_free()


func _spawn_hit_effect() -> void:
	var effect := HIT_BURST_SCENE.instantiate() as Node2D
	if effect == null:
		return
	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position


func _get_safe_owner_body() -> Node:
	if _owner_ref == null:
		return null
	var owner := _owner_ref.get_ref() as Node
	if owner == null or not is_instance_valid(owner):
		return null
	if owner.is_queued_for_deletion():
		return null
	return owner


func get_damage_source_summary() -> Dictionary:
	if not _damage_source_summary.is_empty():
		return _damage_source_summary.duplicate()
	return _build_damage_source_summary(null)


func _build_damage_source_summary(source: Node = null) -> Dictionary:
	var source_name := "Enemy Projectile"
	var source_type := "enemy"
	var source_scene := ""
	if source != null and is_instance_valid(source):
		if source.has_method("get_damage_source_summary"):
			var provided = source.call("get_damage_source_summary")
			if provided is Dictionary and not (provided as Dictionary).is_empty():
				return (provided as Dictionary).duplicate()

		var display_value = source.get("display_name")
		if display_value != null and not str(display_value).strip_edges().is_empty():
			source_name = str(display_value).strip_edges()
		elif not source.name.is_empty():
			source_name = source.name
		source_scene = source.scene_file_path
		if source.is_in_group("bosses"):
			source_type = "boss"
		elif source.is_in_group("enemies"):
			source_type = "enemy"
		else:
			source_type = "hazard"
	return {
		"source_id": _get_damage_source_id(source, source_name),
		"source_name": source_name,
		"source_type": source_type,
		"source_scene": source_scene,
	}


func _get_damage_source_id(source: Node, source_name: String) -> String:
	if source != null and is_instance_valid(source):
		for property_name in ["source_id", "enemy_id", "id"]:
			var value = source.get(property_name)
			if value != null and not str(value).strip_edges().is_empty():
				return str(value).strip_edges().to_snake_case()
		var scene_path := source.scene_file_path.strip_edges()
		if not scene_path.is_empty():
			return scene_path.get_file().get_basename().to_snake_case()
	if not source_name.strip_edges().is_empty() and source_name != "Unknown":
		return source_name.strip_edges().to_snake_case()
	return "enemy_projectile"

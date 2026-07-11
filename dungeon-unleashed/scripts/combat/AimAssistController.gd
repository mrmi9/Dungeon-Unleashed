extends Node
class_name AimAssistController

@export var enabled: bool = false
@export var max_distance: float = 520.0
@export_range(0.0, 180.0, 1.0) var max_angle_degrees: float = 35.0
@export_range(0.0, 1.0, 0.01) var strength: float = 0.35
@export_range(0.0, 5.0, 0.05) var lock_weight: float = 0.65
@export var candidate_groups: Array[String] = ["enemies"]

var _locked_target: Node2D
var _last_pick_score := 0.0


func collect_candidates(source_tree: SceneTree = null) -> Array:
	var candidates: Array = []
	var tree := source_tree
	if tree == null and is_inside_tree():
		tree = get_tree()
	if tree == null:
		return candidates

	var seen := {}
	for group_name in _get_candidate_groups():
		for node in tree.get_nodes_in_group(group_name):
			var target := node as Node2D
			if not _is_valid_target(target):
				continue
			if _is_target_dead(target):
				continue
			if seen.has(target):
				continue
			seen[target] = true
			candidates.append(target)
	return candidates


func pick_target_from_tree(origin: Vector2, aim_direction: Vector2, source_tree: SceneTree = null) -> Node2D:
	return pick_target(origin, aim_direction, collect_candidates(source_tree))


func pick_target(origin: Vector2, aim_direction: Vector2, candidates: Array) -> Node2D:
	if not enabled:
		_clear_invalid_lock()
		return null
	if aim_direction.is_zero_approx():
		_clear_invalid_lock()
		return null

	var best_target: Node2D = null
	var best_score := -INF
	for candidate in candidates:
		var target := candidate as Node2D
		var score := get_candidate_score(origin, aim_direction, target)
		if score <= -INF:
			continue

		if target == _locked_target and _is_valid_target(target):
			score += maxf(lock_weight, 0.0)

		if score > best_score:
			best_score = score
			best_target = target

	_locked_target = best_target
	_last_pick_score = best_score if best_target != null else 0.0
	return best_target


func get_assisted_direction(origin: Vector2, raw_direction: Vector2, candidates: Array) -> Vector2:
	if raw_direction.is_zero_approx():
		return raw_direction

	var target := pick_target(origin, raw_direction, candidates)
	if target == null:
		return raw_direction.normalized()

	var target_direction := (target.global_position - origin).normalized()
	return raw_direction.normalized().lerp(target_direction, strength).normalized()


func get_candidate_score(origin: Vector2, aim_direction: Vector2, candidate: Node2D) -> float:
	if not _is_valid_target(candidate) or aim_direction.is_zero_approx():
		return -INF

	var normalized_aim := aim_direction.normalized()
	var to_target := candidate.global_position - origin
	var distance := to_target.length()
	if distance <= 0.0 or distance > max_distance:
		return -INF

	var safe_max_angle := maxf(max_angle_degrees, 0.001)
	var angle := rad_to_deg(absf(normalized_aim.angle_to(to_target.normalized())))
	if angle > safe_max_angle:
		return -INF

	var angle_score := (1.0 - angle / safe_max_angle) * 2.0
	var distance_score := 1.0 - distance / maxf(max_distance, 1.0)
	return angle_score + distance_score


func set_locked_target(target: Node2D) -> void:
	_locked_target = target if _is_valid_target(target) else null


func clear_lock() -> void:
	_locked_target = null
	_last_pick_score = 0.0


func get_locked_target() -> Node2D:
	return _locked_target if _is_valid_target(_locked_target) else null


func get_last_pick_score() -> float:
	return _last_pick_score


func set_candidate_groups(groups: Array) -> void:
	var normalized: Array[String] = []
	for group_value in groups:
		var group_name := str(group_value).strip_edges()
		if group_name.is_empty() or normalized.has(group_name):
			continue
		normalized.append(group_name)
	candidate_groups = normalized


func get_candidate_groups() -> PackedStringArray:
	var groups := PackedStringArray()
	for group_name in _get_candidate_groups():
		groups.append(group_name)
	return groups


func _is_valid_target(target: Node2D) -> bool:
	return target != null and is_instance_valid(target) and not target.is_queued_for_deletion()


func _is_target_dead(target: Node2D) -> bool:
	return target.has_method("is_dead") and bool(target.call("is_dead"))


func _clear_invalid_lock() -> void:
	if not _is_valid_target(_locked_target):
		_locked_target = null


func _get_candidate_groups() -> Array[String]:
	if candidate_groups.is_empty():
		return ["enemies"]
	return candidate_groups

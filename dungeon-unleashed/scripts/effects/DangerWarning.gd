extends Node2D
class_name DangerWarning

enum WarningShape {
	CIRCLE,
	LINE,
}

const CIRCLE_SEGMENTS := 56
const OUTLINE_WIDTH := 3.0
const OUTLINE_ALPHA_BOOST := 0.2
const OUTLINE_MIN_ALPHA := 0.22
const OUTLINE_MAX_ALPHA := 0.82

@export var warning_shape: WarningShape = WarningShape.CIRCLE
@export var duration: float = 0.4
@export var radius: float = 96.0
@export var length: float = 420.0
@export var width: float = 24.0
@export var damage: int = 0
@export var target_group: StringName = &"player"
@export var warning_purpose: StringName = &"danger"

@onready var visual: Polygon2D = $Visual
@onready var outline: Line2D = get_node_or_null("Outline") as Line2D

var _elapsed := 0.0
var _damage_applied := false
var _warning_color := Color(1.0, 0.22, 0.12, 0.42)
var _source: Node
var _damage_source_summary: Dictionary = {}


func _ready() -> void:
	add_to_group("danger_warnings")
	_refresh_polygon()


func configure_circle(
	warning_radius: float,
	warning_duration: float,
	warning_color: Color = Color(1.0, 0.22, 0.12, 0.42),
	warning_damage: int = 0,
	source: Node = null,
	purpose: StringName = &"danger"
) -> void:
	warning_shape = WarningShape.CIRCLE
	radius = maxf(warning_radius, 1.0)
	duration = maxf(warning_duration, 0.05)
	_warning_color = warning_color
	damage = maxi(warning_damage, 0)
	_source = source
	warning_purpose = purpose
	_damage_source_summary = _build_damage_source_summary(source)
	_refresh_polygon()
	_emit_warning_started()


func configure_line(
	warning_length: float,
	warning_width: float,
	warning_duration: float,
	angle: float,
	warning_color: Color = Color(1.0, 0.48, 0.12, 0.35),
	warning_damage: int = 0,
	source: Node = null,
	purpose: StringName = &"danger"
) -> void:
	warning_shape = WarningShape.LINE
	length = maxf(warning_length, 1.0)
	width = maxf(warning_width, 1.0)
	duration = maxf(warning_duration, 0.05)
	rotation = angle
	_warning_color = warning_color
	damage = maxi(warning_damage, 0)
	_source = source
	warning_purpose = purpose
	_damage_source_summary = _build_damage_source_summary(source)
	_refresh_polygon()
	_emit_warning_started()


func _process(delta: float) -> void:
	_elapsed += delta
	_update_pulse()

	if _elapsed >= duration:
		_apply_damage_once()
		queue_free()


func _refresh_polygon() -> void:
	if visual == null:
		return

	match warning_shape:
		WarningShape.LINE:
			visual.polygon = PackedVector2Array([
				Vector2(0.0, -width * 0.5),
				Vector2(length, -width * 0.5),
				Vector2(length, width * 0.5),
				Vector2(0.0, width * 0.5),
			])
		_:
			var points := PackedVector2Array()
			for index in range(CIRCLE_SEGMENTS):
				var angle := TAU * float(index) / float(CIRCLE_SEGMENTS)
				points.append(Vector2.RIGHT.rotated(angle) * radius)
			visual.polygon = points

	visual.color = _warning_color
	_refresh_outline()


func _update_pulse() -> void:
	if visual == null:
		return

	var progress := clampf(_elapsed / duration, 0.0, 1.0)
	var alpha := lerpf(_warning_color.a, 0.11, progress)
	visual.color = Color(_warning_color.r, _warning_color.g, _warning_color.b, alpha)
	if outline == null:
		return
	var pulse := 0.72 + 0.28 * sin(_elapsed * 18.0)
	var trigger_weight := lerpf(0.86, 1.18, progress)
	var outline_alpha := clampf((_warning_color.a + OUTLINE_ALPHA_BOOST) * pulse * trigger_weight, OUTLINE_MIN_ALPHA, OUTLINE_MAX_ALPHA)
	outline.default_color = Color(_warning_color.r, _warning_color.g, _warning_color.b, outline_alpha)


func _refresh_outline() -> void:
	if outline == null:
		return

	outline.visible = true
	outline.z_index = 1
	outline.closed = true
	outline.width = OUTLINE_WIDTH
	match warning_shape:
		WarningShape.LINE:
			outline.points = PackedVector2Array([
				Vector2(0.0, -width * 0.5),
				Vector2(length, -width * 0.5),
				Vector2(length, width * 0.5),
				Vector2(0.0, width * 0.5),
			])
		_:
			var points := PackedVector2Array()
			for index in range(CIRCLE_SEGMENTS):
				var angle := TAU * float(index) / float(CIRCLE_SEGMENTS)
				points.append(Vector2.RIGHT.rotated(angle) * radius)
			outline.points = points
	outline.default_color = Color(_warning_color.r, _warning_color.g, _warning_color.b, clampf(_warning_color.a + OUTLINE_ALPHA_BOOST, OUTLINE_MIN_ALPHA, OUTLINE_MAX_ALPHA))


func _emit_warning_started() -> void:
	var shape_name := "circle"
	if warning_shape == WarningShape.LINE:
		shape_name = "line"
	Events.danger_warning_started.emit(shape_name, duration, damage)


func has_readability_outline_for_test() -> bool:
	return outline != null and outline.visible and outline.points.size() >= 4 and outline.default_color.a > 0.0


func get_visual_alpha_for_test() -> float:
	if visual == null:
		return 0.0
	return visual.color.a


func get_outline_alpha_for_test() -> float:
	if outline == null:
		return 0.0
	return outline.default_color.a


func get_warning_shape_name_for_test() -> String:
	if warning_shape == WarningShape.LINE:
		return "line"
	return "circle"


func get_warning_purpose_for_test() -> String:
	return str(warning_purpose)


func _apply_damage_once() -> void:
	if _damage_applied or damage <= 0:
		return

	_damage_applied = true
	for target in get_tree().get_nodes_in_group(target_group):
		var target_node := target as Node2D
		if target_node == null or not is_instance_valid(target_node) or not target_node.has_method("take_damage"):
			continue
		if target_node.global_position.distance_to(global_position) <= radius:
			var source := _source if is_instance_valid(_source) else null
			target_node.call("take_damage", damage, source if source != null else self)


func get_damage_source_summary() -> Dictionary:
	if not _damage_source_summary.is_empty():
		return _damage_source_summary.duplicate()
	return _build_damage_source_summary(null)


func _build_damage_source_summary(source: Node = null) -> Dictionary:
	var source_name := "Danger Zone"
	var source_type := "hazard"
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
	return "danger_zone"

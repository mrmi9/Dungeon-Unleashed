extends Node2D
class_name DangerWarning

enum WarningShape {
	CIRCLE,
	LINE,
}

@export var warning_shape: WarningShape = WarningShape.CIRCLE
@export var duration: float = 0.4
@export var radius: float = 96.0
@export var length: float = 420.0
@export var width: float = 24.0
@export var damage: int = 0
@export var target_group: StringName = &"player"

@onready var visual: Polygon2D = $Visual

var _elapsed := 0.0
var _damage_applied := false
var _warning_color := Color(1.0, 0.22, 0.12, 0.42)
var _source: Node


func _ready() -> void:
	add_to_group("danger_warnings")
	_refresh_polygon()


func configure_circle(warning_radius: float, warning_duration: float, warning_color: Color = Color(1.0, 0.22, 0.12, 0.42), warning_damage: int = 0, source: Node = null) -> void:
	warning_shape = WarningShape.CIRCLE
	radius = maxf(warning_radius, 1.0)
	duration = maxf(warning_duration, 0.05)
	_warning_color = warning_color
	damage = maxi(warning_damage, 0)
	_source = source
	_refresh_polygon()


func configure_line(warning_length: float, warning_width: float, warning_duration: float, angle: float, warning_color: Color = Color(1.0, 0.48, 0.12, 0.35)) -> void:
	warning_shape = WarningShape.LINE
	length = maxf(warning_length, 1.0)
	width = maxf(warning_width, 1.0)
	duration = maxf(warning_duration, 0.05)
	rotation = angle
	_warning_color = warning_color
	_refresh_polygon()


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
			var segments := 48
			for index in range(segments):
				var angle := TAU * float(index) / float(segments)
				points.append(Vector2.RIGHT.rotated(angle) * radius)
			visual.polygon = points

	visual.color = _warning_color


func _update_pulse() -> void:
	if visual == null:
		return

	var progress := clampf(_elapsed / duration, 0.0, 1.0)
	var alpha := lerpf(_warning_color.a, 0.08, progress)
	visual.color = Color(_warning_color.r, _warning_color.g, _warning_color.b, alpha)


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
			target_node.call("take_damage", damage, source)

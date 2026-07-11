extends Node2D
class_name MeleeSweepFlash

@export var duration: float = 0.12
@export var radius: float = 96.0
@export var arc_degrees: float = 120.0
@export var segments: int = 18
@export var color: Color = Color(0.42, 0.86, 1.0, 0.42)
@export var edge_color: Color = Color(1.0, 0.96, 0.72, 0.95)

var _elapsed := 0.0


func _ready() -> void:
	add_to_group("melee_sweep_flash")
	queue_redraw()


func configure(new_radius: float, new_arc_degrees: float, new_color: Color = Color(0.42, 0.86, 1.0, 0.42)) -> void:
	radius = maxf(new_radius, 1.0)
	arc_degrees = clampf(new_arc_degrees, 1.0, 360.0)
	color = new_color
	queue_redraw()


func get_radius_for_test() -> float:
	return radius


func get_arc_degrees_for_test() -> float:
	return arc_degrees


func _process(delta: float) -> void:
	_elapsed += delta
	var safe_duration := maxf(duration, 0.01)
	if _elapsed >= safe_duration:
		queue_free()
		return

	var t := clampf(_elapsed / safe_duration, 0.0, 1.0)
	scale = Vector2.ONE * lerpf(0.94, 1.08, t)
	queue_redraw()


func _draw() -> void:
	var safe_duration := maxf(duration, 0.01)
	var t := clampf(_elapsed / safe_duration, 0.0, 1.0)
	var fade := 1.0 - t
	var points := _build_arc_points()
	var fill_color := color
	fill_color.a *= fade
	draw_colored_polygon(points, fill_color)

	var outline := PackedVector2Array()
	for index in range(1, points.size()):
		outline.append(points[index])

	var resolved_edge_color := edge_color
	resolved_edge_color.a *= fade
	draw_polyline(outline, resolved_edge_color, 2.0, true)
	draw_polyline(PackedVector2Array([Vector2.ZERO, Vector2.RIGHT * radius]), resolved_edge_color, 1.0, true)


func _build_arc_points() -> PackedVector2Array:
	var resolved_segments := maxi(segments, 4)
	var half_angle := deg_to_rad(clampf(arc_degrees, 1.0, 360.0)) * 0.5
	var points := PackedVector2Array([Vector2.ZERO])

	for index in range(resolved_segments + 1):
		var angle_ratio := float(index) / float(resolved_segments)
		var angle := lerpf(-half_angle, half_angle, angle_ratio)
		points.append(Vector2.RIGHT.rotated(angle) * radius)

	return points

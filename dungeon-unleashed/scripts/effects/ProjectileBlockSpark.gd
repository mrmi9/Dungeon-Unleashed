extends Node2D
class_name ProjectileBlockSpark

@export var duration: float = 0.18
@export var base_radius: float = 14.0
@export var max_radius: float = 34.0
@export var ray_length: float = 18.0
@export var ring_color: Color = Color(0.58, 0.96, 1.0, 0.86)
@export var ray_color: Color = Color(1.0, 0.96, 0.62, 0.92)

var blocked_count := 1
var _elapsed := 0.0


func _ready() -> void:
	add_to_group("projectile_block_spark")
	queue_redraw()


func configure(new_blocked_count: int = 1) -> void:
	blocked_count = maxi(new_blocked_count, 1)
	queue_redraw()


func get_blocked_count_for_test() -> int:
	return blocked_count


func get_current_radius_for_test() -> float:
	return _get_current_radius()


func get_visual_alpha_for_test() -> float:
	return 1.0 - clampf(_elapsed / maxf(duration, 0.01), 0.0, 1.0)


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= maxf(duration, 0.01):
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var progress := clampf(_elapsed / maxf(duration, 0.01), 0.0, 1.0)
	var fade := 1.0 - progress
	var radius := _get_current_radius()
	var resolved_ring_color := ring_color
	resolved_ring_color.a *= fade
	var resolved_ray_color := ray_color
	resolved_ray_color.a *= fade

	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, resolved_ring_color, 2.5, true)
	draw_arc(Vector2.ZERO, radius * 0.58, 0.0, TAU, 32, Color(resolved_ring_color.r, resolved_ring_color.g, resolved_ring_color.b, resolved_ring_color.a * 0.55), 1.25, true)

	var ray_count := 8 + mini(blocked_count, 4) * 2
	var spin := progress * 0.28
	for index in range(ray_count):
		var angle := TAU * float(index) / float(ray_count) + spin
		var direction := Vector2.RIGHT.rotated(angle)
		var inner := direction * radius * 0.42
		var outer := direction * (radius + ray_length * fade)
		draw_line(inner, outer, resolved_ray_color, 2.0, true)

	draw_circle(Vector2.ZERO, 3.5 + float(mini(blocked_count, 3)), Color(1.0, 1.0, 1.0, 0.42 * fade))


func _get_current_radius() -> float:
	var progress := clampf(_elapsed / maxf(duration, 0.01), 0.0, 1.0)
	var block_bonus := minf(float(blocked_count), 4.0) * 2.5
	return lerpf(base_radius, max_radius + block_bonus, progress)

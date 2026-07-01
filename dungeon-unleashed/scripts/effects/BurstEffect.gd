extends Node2D

@export var duration: float = 0.18
@export var radius: float = 32.0
@export var color: Color = Color.WHITE
@export var line_width: float = 2.0

var _elapsed := 0.0


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= duration:
		queue_free()
		return

	queue_redraw()


func _draw() -> void:
	var t := clampf(_elapsed / duration, 0.0, 1.0)
	var burst_color := color
	burst_color.a = 1.0 - t
	var current_radius := lerpf(4.0, radius, t)

	draw_circle(Vector2.ZERO, current_radius * 0.45, Color(burst_color.r, burst_color.g, burst_color.b, burst_color.a * 0.24))
	draw_arc(Vector2.ZERO, current_radius, 0.0, TAU, 28, burst_color, line_width, true)

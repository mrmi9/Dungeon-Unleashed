extends Node2D

@export var duration: float = 0.06
@export var flash_length: float = 34.0
@export var flash_width: float = 16.0
@export var color: Color = Color(1.0, 0.76, 0.25, 1.0)

var _elapsed := 0.0


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= duration:
		queue_free()
		return

	queue_redraw()


func _draw() -> void:
	var t := clampf(_elapsed / duration, 0.0, 1.0)
	var flash_color := color
	flash_color.a = 1.0 - t

	var points := PackedVector2Array([
		Vector2.ZERO,
		Vector2(flash_length * (1.0 - t * 0.35), -flash_width * 0.5),
		Vector2(flash_length * 0.72, 0.0),
		Vector2(flash_length * (1.0 - t * 0.35), flash_width * 0.5),
	])
	draw_colored_polygon(points, flash_color)

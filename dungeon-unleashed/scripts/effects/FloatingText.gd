extends Node2D
class_name FloatingText

@export var duration: float = 0.72
@export var rise_distance: float = 46.0
@export var side_drift: float = 0.0
@export var text: String = "0"
@export var text_color: Color = Color.WHITE
@export var font_size: int = 20

@onready var label: Label = $Label

var _elapsed := 0.0
var _start_position := Vector2.ZERO


func _ready() -> void:
	add_to_group("floating_text")
	_start_position = position
	_apply_label_style()


func setup(new_text: String, new_color: Color, new_font_size: int = 20, new_rise_distance: float = 46.0, new_side_drift: float = 0.0) -> void:
	text = new_text
	text_color = new_color
	font_size = new_font_size
	rise_distance = new_rise_distance
	side_drift = new_side_drift
	_apply_label_style()


func get_text() -> String:
	return text


func _process(delta: float) -> void:
	_elapsed += delta
	var progress := clampf(_elapsed / maxf(duration, 0.01), 0.0, 1.0)
	var eased := 1.0 - pow(1.0 - progress, 2.0)
	position = _start_position + Vector2(side_drift * eased, -rise_distance * eased)
	scale = Vector2.ONE * lerpf(1.16, 0.92, progress)
	modulate.a = 1.0 - progress

	if _elapsed >= duration:
		queue_free()


func _apply_label_style() -> void:
	if label == null:
		return

	label.text = text
	label.modulate = text_color
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", text_color)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.88))
	label.add_theme_constant_override("outline_size", 4)

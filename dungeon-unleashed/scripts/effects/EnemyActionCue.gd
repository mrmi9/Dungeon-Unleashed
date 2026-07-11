extends Node2D
class_name EnemyActionCue

const HEAD_OFFSET := Vector2(0.0, -40.0)
const BACKDROP_RADIUS := 17.0

var _action_id := ""
var _duration := 0.5
var _elapsed := 0.0
var _source: Node2D
var _cue_color := Color(1.0, 0.78, 0.26, 1.0)
var _shape_signature := "burst"


func _ready() -> void:
	add_to_group("enemy_action_cues")
	z_index = 48
	set_as_top_level(true)
	queue_redraw()


func configure(action_id: String, cue_duration: float, source: Node2D) -> void:
	_action_id = action_id.strip_edges().to_lower()
	_duration = maxf(cue_duration, 0.05)
	_source = source
	match _action_id:
		"summon":
			_cue_color = Color(0.76, 0.48, 1.0, 1.0)
			_shape_signature = "diamonds"
		"support":
			_cue_color = Color(0.36, 1.0, 0.62, 1.0)
			_shape_signature = "cross"
		"shield_bash":
			_cue_color = Color(0.42, 0.82, 1.0, 1.0)
			_shape_signature = "chevrons"
		_:
			_cue_color = Color(1.0, 0.74, 0.24, 1.0)
			_shape_signature = "burst"
	_sync_to_source()
	queue_redraw()


func _process(delta: float) -> void:
	if _source == null or not is_instance_valid(_source) or _source.is_queued_for_deletion():
		queue_free()
		return

	_elapsed += delta
	_sync_to_source()
	var progress := clampf(_elapsed / _duration, 0.0, 1.0)
	var pulse := 0.94 + 0.1 * sin(_elapsed * 22.0)
	scale = Vector2.ONE * pulse
	modulate.a = lerpf(1.0, 0.38, progress)
	queue_redraw()
	if _elapsed >= _duration:
		queue_free()


func _sync_to_source() -> void:
	if _source == null or not is_instance_valid(_source):
		return
	global_position = _source.global_position + HEAD_OFFSET
	rotation = _source.rotation if _action_id == "shield_bash" else 0.0


func _draw() -> void:
	draw_circle(Vector2.ZERO, BACKDROP_RADIUS, Color(0.025, 0.035, 0.055, 0.78))
	draw_arc(Vector2.ZERO, BACKDROP_RADIUS - 1.0, -PI * 0.9, PI * 0.9, 24, _cue_color, 2.0, true)
	match _shape_signature:
		"diamonds":
			_draw_diamond(Vector2(0.0, -6.0), 4.5)
			_draw_diamond(Vector2(-7.0, 5.0), 4.5)
			_draw_diamond(Vector2(7.0, 5.0), 4.5)
		"cross":
			draw_line(Vector2(-8.0, 0.0), Vector2(8.0, 0.0), _cue_color, 4.0, true)
			draw_line(Vector2(0.0, -8.0), Vector2(0.0, 8.0), _cue_color, 4.0, true)
		"chevrons":
			_draw_chevron(-5.0)
			_draw_chevron(4.0)
		_:
			for index in range(6):
				var direction := Vector2.RIGHT.rotated(TAU * float(index) / 6.0)
				draw_line(direction * 4.0, direction * 10.0, _cue_color, 2.5, true)


func _draw_diamond(center: Vector2, size: float) -> void:
	var points := PackedVector2Array([
		center + Vector2(0.0, -size),
		center + Vector2(size, 0.0),
		center + Vector2(0.0, size),
		center + Vector2(-size, 0.0),
		center + Vector2(0.0, -size),
	])
	draw_polyline(points, _cue_color, 2.2, true)


func _draw_chevron(offset_x: float) -> void:
	var points := PackedVector2Array([
		Vector2(offset_x - 4.0, -7.0),
		Vector2(offset_x + 3.0, 0.0),
		Vector2(offset_x - 4.0, 7.0),
	])
	draw_polyline(points, _cue_color, 3.0, true)


func get_action_id_for_test() -> String:
	return _action_id


func get_shape_signature_for_test() -> String:
	return _shape_signature


func has_distinct_shape_for_test() -> bool:
	return _shape_signature in ["diamonds", "cross", "chevrons"]

extends Node2D

var pattern := "ring"
var aura_color := Color(1.0, 0.62, 0.18, 1.0)
var aura_radius := 30.0
var pulse_speed := 2.0
var _phase := 0.0


func _ready() -> void:
	show_behind_parent = true
	z_index = -1
	queue_redraw()


func configure(next_pattern: String, color: Color, radius: float, speed: float) -> void:
	pattern = next_pattern if not next_pattern.is_empty() else "ring"
	aura_color = color
	aura_radius = maxf(radius, 12.0)
	pulse_speed = maxf(speed, 0.1)
	queue_redraw()


func get_visual_summary() -> Dictionary:
	return {
		"enabled": visible,
		"pattern": pattern,
		"color": aura_color,
		"radius": aura_radius,
		"pulse_speed": pulse_speed,
		"phase": _phase,
		"motif_count": get_pattern_geometry_count_for_test(),
		"behind_parent": show_behind_parent and z_index < 0,
	}


func get_pattern_geometry_count_for_test() -> int:
	match pattern:
		"flame":
			return 8
		"shield":
			return 6
		"velocity":
			return 3
		"blast":
			return 6
		"reticle":
			return 8
		"mass":
			return 8
	return 1


func _process(delta: float) -> void:
	_phase = fmod(_phase + delta * pulse_speed, TAU)
	queue_redraw()


func _draw() -> void:
	var pulse := 0.5 + 0.5 * sin(_phase)
	var radius := aura_radius * lerpf(0.92, 1.06, pulse)
	var bright := Color(aura_color.r, aura_color.g, aura_color.b, 0.8)
	var faint := Color(aura_color.r, aura_color.g, aura_color.b, 0.22)
	match pattern:
		"flame":
			_draw_flame(radius, bright, faint, pulse)
		"shield":
			_draw_shield(radius, bright, faint)
		"velocity":
			_draw_velocity(radius, bright, faint)
		"blast":
			_draw_blast(radius, bright, faint, pulse)
		"reticle":
			_draw_reticle(radius, bright, faint)
		"mass":
			_draw_mass(radius, bright, faint, pulse)
		_:
			draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, bright, 2.0)


func _draw_flame(radius: float, bright: Color, faint: Color, pulse: float) -> void:
	draw_circle(Vector2.ZERO, radius * 0.82, faint)
	for index in range(8):
		var angle := TAU * float(index) / 8.0 + _phase * 0.08
		var direction := Vector2.RIGHT.rotated(angle)
		var tangent := direction.orthogonal()
		var tip := direction * radius * lerpf(1.02, 1.2, pulse)
		var points := PackedVector2Array([
			direction * radius * 0.72 + tangent * 4.0,
			tip,
			direction * radius * 0.72 - tangent * 4.0,
		])
		draw_colored_polygon(points, bright)


func _draw_shield(radius: float, bright: Color, faint: Color) -> void:
	var points := PackedVector2Array()
	for index in range(6):
		points.append(Vector2.RIGHT.rotated(TAU * float(index) / 6.0 + PI / 6.0) * radius)
	points.append(points[0])
	draw_polyline(points, bright, 3.0, true)
	for index in range(3):
		var angle := TAU * float(index) / 3.0
		draw_arc(Vector2.ZERO, radius * (0.68 + float(index) * 0.07), angle - 0.42, angle + 0.42, 8, faint, 5.0)


func _draw_velocity(radius: float, bright: Color, faint: Color) -> void:
	for index in range(3):
		var offset := Vector2(-radius * (0.52 + float(index) * 0.22), (float(index) - 1.0) * 9.0)
		var length := radius * (0.72 - float(index) * 0.08)
		draw_line(offset, offset + Vector2.LEFT * length, faint if index > 0 else bright, 3.0)
		draw_line(offset + Vector2.LEFT * length, offset + Vector2.LEFT * (length - 8.0) + Vector2(5.0, -5.0), bright, 2.0)
		draw_line(offset + Vector2.LEFT * length, offset + Vector2.LEFT * (length - 8.0) + Vector2(5.0, 5.0), bright, 2.0)


func _draw_blast(radius: float, bright: Color, faint: Color, pulse: float) -> void:
	draw_arc(Vector2.ZERO, radius * 0.82, 0.0, TAU, 32, faint, 3.0)
	for index in range(6):
		var angle := TAU * float(index) / 6.0 + _phase * 0.16
		var distance := radius * lerpf(0.76, 1.04, pulse)
		var center := Vector2.RIGHT.rotated(angle) * distance
		draw_circle(center, 3.5 + pulse * 1.5, bright)


func _draw_reticle(radius: float, bright: Color, faint: Color) -> void:
	draw_arc(Vector2.ZERO, radius * 0.76, 0.0, TAU, 32, faint, 2.0)
	for index in range(4):
		var direction := Vector2.RIGHT.rotated(TAU * float(index) / 4.0)
		draw_line(direction * radius * 0.62, direction * radius, bright, 3.0)
		var tangent := direction.orthogonal()
		draw_line(direction * radius + tangent * 5.0, direction * radius - tangent * 5.0, bright, 2.0)


func _draw_mass(radius: float, bright: Color, faint: Color, pulse: float) -> void:
	draw_arc(Vector2.ZERO, radius * 0.86, 0.0, TAU, 40, faint, 7.0)
	for index in range(8):
		var angle := TAU * float(index) / 8.0
		var direction := Vector2.RIGHT.rotated(angle)
		var inner := direction * radius * 0.74
		var outer := direction * radius * lerpf(0.94, 1.04, pulse)
		draw_line(inner, outer, bright, 5.0)

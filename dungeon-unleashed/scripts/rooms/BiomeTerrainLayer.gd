extends Node2D
class_name BiomeTerrainLayer

const FLOOR_RECT := Rect2(-640.0, -360.0, 1280.0, 720.0)

var _texture: Texture2D
var _texture_path := ""
var _draw_modulate := Color.WHITE


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	queue_redraw()


func configure(texture_path: String, color_modulate: Color = Color.WHITE, opacity: float = 1.0) -> void:
	_texture_path = texture_path.strip_edges()
	_draw_modulate = color_modulate
	_draw_modulate.a = clampf(opacity, 0.0, 1.0)
	_texture = null
	if not _texture_path.is_empty() and ResourceLoader.exists(_texture_path):
		_texture = load(_texture_path) as Texture2D
	visible = _texture != null
	queue_redraw()


func get_terrain_summary() -> Dictionary:
	return {
		"texture_path": _texture_path,
		"texture_loaded": _texture != null,
		"texture_size": _texture.get_size() if _texture != null else Vector2.ZERO,
		"opacity": _draw_modulate.a,
		"repeat_enabled": texture_repeat == CanvasItem.TEXTURE_REPEAT_ENABLED,
		"nearest_filter": texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST,
	}


func _draw() -> void:
	if _texture == null:
		return
	draw_texture_rect(_texture, FLOOR_RECT, true, _draw_modulate)

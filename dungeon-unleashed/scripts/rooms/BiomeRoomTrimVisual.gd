extends Node2D
class_name BiomeRoomTrimVisual

const CELL_SIZE := Vector2(256.0, 256.0)
const VERTICAL_DOOR_REGION := Rect2(Vector2.ZERO, CELL_SIZE)
const HORIZONTAL_DOOR_REGION := Rect2(Vector2(256.0, 0.0), CELL_SIZE)
const CORNER_REGION := Rect2(Vector2(0.0, 256.0), CELL_SIZE)
const THRESHOLD_REGION := Rect2(Vector2(256.0, 256.0), CELL_SIZE)
const CORNER_POSITIONS := [
	Vector2(-586.0, -306.0),
	Vector2(586.0, -306.0),
	Vector2(586.0, 306.0),
	Vector2(-586.0, 306.0),
]
const CORNER_ROTATIONS := [0.0, PI * 0.5, PI, -PI * 0.5]

var _atlas_path := ""
var _atlas_texture: Texture2D
var _connected_directions := PackedStringArray()
var _draw_modulate := Color.WHITE


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture_repeat = CanvasItem.TEXTURE_REPEAT_DISABLED
	queue_redraw()


func configure(
	atlas_path: String,
	connected_directions: PackedStringArray,
	color_modulate: Color = Color.WHITE,
	opacity: float = 1.0
) -> void:
	_atlas_path = atlas_path.strip_edges()
	_connected_directions = connected_directions.duplicate()
	_draw_modulate = color_modulate
	_draw_modulate.a *= clampf(opacity, 0.0, 1.0)
	_atlas_texture = null
	if not _atlas_path.is_empty() and ResourceLoader.exists(_atlas_path):
		_atlas_texture = load(_atlas_path) as Texture2D
	visible = _atlas_texture != null
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture_repeat = CanvasItem.TEXTURE_REPEAT_DISABLED
	queue_redraw()


func get_trim_summary() -> Dictionary:
	return {
		"atlas_path": _atlas_path,
		"atlas_loaded": _atlas_texture != null,
		"atlas_size": _atlas_texture.get_size() if _atlas_texture != null else Vector2.ZERO,
		"connected_directions": _connected_directions.duplicate(),
		"corner_count": CORNER_POSITIONS.size(),
		"door_frame_count": _connected_directions.size(),
		"threshold_count": _connected_directions.size(),
		"draw_item_count": CORNER_POSITIONS.size() + _connected_directions.size() * 2,
		"vertical_door_region": VERTICAL_DOOR_REGION,
		"horizontal_door_region": HORIZONTAL_DOOR_REGION,
		"corner_region": CORNER_REGION,
		"threshold_region": THRESHOLD_REGION,
		"opacity": _draw_modulate.a,
		"nearest_filter": texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST,
	}


func _draw() -> void:
	if _atlas_texture == null:
		return

	for index in range(CORNER_POSITIONS.size()):
		_draw_region(CORNER_POSITIONS[index], Vector2(80.0, 80.0), CORNER_REGION, CORNER_ROTATIONS[index])

	for direction in _connected_directions:
		_draw_door_trim(str(direction))


func _draw_door_trim(direction: String) -> void:
	match direction:
		"west":
			_draw_region(Vector2(-586.0, 0.0), Vector2(84.0, 190.0), VERTICAL_DOOR_REGION)
			_draw_region(Vector2(-540.0, 0.0), Vector2(112.0, 76.0), THRESHOLD_REGION)
		"east":
			_draw_region(Vector2(586.0, 0.0), Vector2(84.0, 190.0), VERTICAL_DOOR_REGION, PI)
			_draw_region(Vector2(540.0, 0.0), Vector2(112.0, 76.0), THRESHOLD_REGION, PI)
		"north":
			_draw_region(Vector2(0.0, -310.0), Vector2(190.0, 84.0), HORIZONTAL_DOOR_REGION)
			_draw_region(Vector2(0.0, -264.0), Vector2(76.0, 112.0), THRESHOLD_REGION, PI * 0.5)
		"south":
			_draw_region(Vector2(0.0, 310.0), Vector2(190.0, 84.0), HORIZONTAL_DOOR_REGION, PI)
			_draw_region(Vector2(0.0, 264.0), Vector2(76.0, 112.0), THRESHOLD_REGION, -PI * 0.5)


func _draw_region(position: Vector2, size: Vector2, source_region: Rect2, rotation: float = 0.0) -> void:
	draw_set_transform(position, rotation, Vector2.ONE)
	draw_texture_rect_region(_atlas_texture, Rect2(-size * 0.5, size), source_region, _draw_modulate)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

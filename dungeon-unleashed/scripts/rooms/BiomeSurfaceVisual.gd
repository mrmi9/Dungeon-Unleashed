extends Node2D
class_name BiomeSurfaceVisual

enum SurfaceKind {
	WALL,
	OBSTACLE,
}

const ATLAS_REGION_SIZE := Vector2(256.0, 256.0)
const WALL_REGION := Rect2(Vector2.ZERO, ATLAS_REGION_SIZE)
const OBSTACLE_REGION := Rect2(Vector2(256.0, 0.0), ATLAS_REGION_SIZE)

var _atlas_path := ""
var _atlas_texture: Texture2D
var _surface_kind := SurfaceKind.WALL
var _surface_size := Vector2.ZERO
var _draw_modulate := Color.WHITE


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture_repeat = CanvasItem.TEXTURE_REPEAT_DISABLED
	queue_redraw()


func configure(
	atlas_path: String,
	surface_kind: SurfaceKind,
	surface_size: Vector2,
	color_modulate: Color = Color.WHITE,
	opacity: float = 1.0
) -> void:
	_atlas_path = atlas_path
	_surface_kind = surface_kind
	_surface_size = Vector2(maxf(surface_size.x, 0.0), maxf(surface_size.y, 0.0))
	_draw_modulate = color_modulate
	_draw_modulate.a *= clampf(opacity, 0.0, 1.0)
	_atlas_texture = null

	if not _atlas_path.is_empty() and ResourceLoader.exists(_atlas_path):
		_atlas_texture = load(_atlas_path) as Texture2D

	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture_repeat = CanvasItem.TEXTURE_REPEAT_DISABLED
	queue_redraw()


func get_surface_summary() -> Dictionary:
	return {
		"atlas_path": _atlas_path,
		"atlas_loaded": _atlas_texture != null,
		"atlas_size": _atlas_texture.get_size() if _atlas_texture != null else Vector2.ZERO,
		"surface_kind": "wall" if _surface_kind == SurfaceKind.WALL else "obstacle",
		"surface_size": _surface_size,
		"atlas_region": _get_atlas_region(),
		"opacity": _draw_modulate.a,
		"repeat_enabled": true,
		"manual_region_tiling": true,
		"nearest_filter": texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST,
	}


func _draw() -> void:
	if _atlas_texture == null or _surface_size.x <= 0.0 or _surface_size.y <= 0.0:
		return
	var draw_rect := Rect2(-_surface_size * 0.5, _surface_size)
	var atlas_region := _get_atlas_region()
	var tile_y := 0.0
	while tile_y < draw_rect.size.y:
		var tile_height := minf(ATLAS_REGION_SIZE.y, draw_rect.size.y - tile_y)
		var tile_x := 0.0
		while tile_x < draw_rect.size.x:
			var tile_width := minf(ATLAS_REGION_SIZE.x, draw_rect.size.x - tile_x)
			var tile_size := Vector2(tile_width, tile_height)
			var destination := Rect2(draw_rect.position + Vector2(tile_x, tile_y), tile_size)
			var source := Rect2(atlas_region.position, tile_size)
			draw_texture_rect_region(_atlas_texture, destination, source, _draw_modulate)
			tile_x += ATLAS_REGION_SIZE.x
		tile_y += ATLAS_REGION_SIZE.y


func _get_atlas_region() -> Rect2:
	if _surface_kind == SurfaceKind.OBSTACLE:
		return OBSTACLE_REGION
	return WALL_REGION

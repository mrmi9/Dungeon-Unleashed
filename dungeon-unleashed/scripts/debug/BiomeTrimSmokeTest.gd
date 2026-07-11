extends Node

const ROOM_SCENE := preload("res://scenes/rooms/PrototypeCombatRoom.tscn")
const BIOMES := [
	preload("res://resources/biomes/outer_warrens.tres"),
	preload("res://resources/biomes/iron_catacombs.tres"),
	preload("res://resources/biomes/void_foundry.tres"),
]
const VIEWPORT_SIZE := Vector2i(1280, 720)
const PREVIEW_SIZE := Vector2i(640, 360)

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var can_capture_visual := DisplayServer.get_name() != "headless"
	var contact_sheet := Image.create_empty(PREVIEW_SIZE.x * BIOMES.size(), PREVIEW_SIZE.y, false, Image.FORMAT_RGBA8)
	contact_sheet.fill(Color(0.025, 0.03, 0.04, 1.0))
	var atlas_paths := {}

	for index in range(BIOMES.size()):
		var biome := BIOMES[index] as Resource
		var viewport := SubViewport.new()
		viewport.size = VIEWPORT_SIZE
		viewport.transparent_bg = false
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		add_child(viewport)

		var room_root := ROOM_SCENE.instantiate() as Node2D
		room_root.position = Vector2(VIEWPORT_SIZE) * 0.5
		var room := room_root.get_node("CombatRoom") as CombatRoom
		_configure_room(room, biome)
		viewport.add_child(room_root)
		await get_tree().process_frame
		await get_tree().process_frame
		RenderingServer.force_draw(true)
		await get_tree().process_frame

		var summary: Dictionary = room.get_biome_visual_summary()
		var trim_summary := summary.get("trim_layer", {}) as Dictionary
		var atlas_path := str(trim_summary.get("atlas_path", ""))
		_expect(bool(trim_summary.get("atlas_loaded", false)), "%s trim atlas should load" % str(biome.get("id")))
		_expect(trim_summary.get("atlas_size", Vector2.ZERO) == Vector2(512.0, 512.0), "%s trim atlas should use four 256px regions" % str(biome.get("id")))
		_expect(not atlas_paths.has(atlas_path), "Biome trim previews should use unique atlases")
		atlas_paths[atlas_path] = true
		_expect(int(trim_summary.get("corner_count", 0)) == 4, "Trim preview should draw four corners")
		_expect(int(trim_summary.get("door_frame_count", 0)) == 4, "Trim preview should draw four door frames")
		_expect(int(trim_summary.get("threshold_count", 0)) == 4, "Trim preview should draw four thresholds")
		_expect(int(trim_summary.get("draw_item_count", 0)) == 12, "Trim preview should draw twelve atlas items")
		_expect(bool(trim_summary.get("nearest_filter", false)), "Trim preview should use nearest-neighbor filtering")
		_verify_horizontal_door(room, "NorthDoor")
		_verify_horizontal_door(room, "SouthDoor")

		if can_capture_visual:
			var viewport_texture := viewport.get_texture()
			_expect(viewport_texture != null, "%s preview should expose a rendered viewport texture" % str(biome.get("id")))
			var image: Image = viewport_texture.get_image() if viewport_texture != null else null
			if image != null and not image.is_empty() and _get_image_center_luminance(image) <= 0.04:
				await get_tree().process_frame
				RenderingServer.force_draw(true)
				await get_tree().process_frame
				image = viewport_texture.get_image()
			_expect(image != null and not image.is_empty(), "%s preview should capture a rendered image" % str(biome.get("id")))
			if image != null and not image.is_empty():
				_expect(image.get_used_rect().size == VIEWPORT_SIZE, "%s preview should contain nontransparent viewport pixels" % str(biome.get("id")))
				_expect(_get_image_center_luminance(image) > 0.04, "%s preview center should contain rendered floor pixels" % str(biome.get("id")))
				image.resize(PREVIEW_SIZE.x, PREVIEW_SIZE.y, Image.INTERPOLATE_NEAREST)
				contact_sheet.blit_rect(image, Rect2i(Vector2i.ZERO, PREVIEW_SIZE), Vector2i(index * PREVIEW_SIZE.x, 0))

		viewport.remove_child(room_root)
		room_root.free()
		remove_child(viewport)
		viewport.free()

	if can_capture_visual:
		var output_path := "user://biome_trim_contact.png"
		var save_error := contact_sheet.save_png(output_path)
		_expect(save_error == OK, "Biome trim contact sheet should save")
		print("Biome trim contact sheet: %s" % ProjectSettings.globalize_path(output_path))
	else:
		print("Biome trim screenshot skipped: headless display driver.")
	_finish()


func _configure_room(room: CombatRoom, biome: Resource) -> void:
	room.connected_directions = PackedStringArray(["west", "east", "north", "south"])
	room.biome_id = str(biome.get("id"))
	room.biome_name = str(biome.get("display_name"))
	room.biome_color_key = str(biome.get("color_key"))
	room.biome_visual_floor_tint = biome.get("visual_floor_tint")
	room.biome_visual_floor_texture_path = str(biome.get("visual_floor_texture_path"))
	room.biome_visual_floor_texture_modulate = biome.get("visual_floor_texture_modulate")
	room.biome_visual_floor_texture_opacity = float(biome.get("visual_floor_texture_opacity"))
	room.biome_visual_wall_color = biome.get("visual_wall_color")
	room.biome_visual_obstacle_tint = biome.get("visual_obstacle_tint")
	room.biome_visual_surface_atlas_path = str(biome.get("visual_surface_atlas_path"))
	room.biome_visual_trim_atlas_path = str(biome.get("visual_trim_atlas_path"))
	room.biome_visual_trim_texture_modulate = biome.get("visual_trim_texture_modulate")
	room.biome_visual_trim_texture_opacity = float(biome.get("visual_trim_texture_opacity"))
	room.biome_visual_wall_texture_modulate = biome.get("visual_wall_texture_modulate")
	room.biome_visual_wall_texture_opacity = float(biome.get("visual_wall_texture_opacity"))
	room.biome_visual_obstacle_texture_modulate = biome.get("visual_obstacle_texture_modulate")
	room.biome_visual_obstacle_texture_opacity = float(biome.get("visual_obstacle_texture_opacity"))
	room.biome_visual_accent_color = biome.get("visual_accent_color")
	room.biome_visual_tint_strength = float(biome.get("visual_tint_strength"))


func _verify_horizontal_door(room: CombatRoom, door_name: String) -> void:
	var door := room.get_node_or_null("Doors/%s" % door_name) as StaticBody2D
	_expect(door != null, "%s should exist in four-way trim preview" % door_name)
	if door == null:
		return
	var collision := door.get_node_or_null("CollisionShape2D") as CollisionShape2D
	_expect(collision != null and collision.shape is RectangleShape2D, "%s should define rectangle collision" % door_name)
	if collision != null and collision.shape is RectangleShape2D:
		_expect((collision.shape as RectangleShape2D).size == Vector2(170.0, 42.0), "%s should use the centered trim opening" % door_name)


func _get_image_center_luminance(image: Image) -> float:
	var color := image.get_pixel(image.get_width() / 2, image.get_height() / 2)
	return color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("BiomeTrimSmokeTest passed.")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

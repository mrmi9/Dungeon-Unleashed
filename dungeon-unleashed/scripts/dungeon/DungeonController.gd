extends Node
class_name DungeonController

const PROTOTYPE_ROOM_SCENE := preload("res://scenes/rooms/PrototypeCombatRoom.tscn")
const START_ROOM_DATA := preload("res://resources/rooms/start_room.tres")
const COMBAT_ROOM_DATA := preload("res://resources/rooms/combat_room.tres")
const REWARD_ROOM_DATA := preload("res://resources/rooms/reward_room.tres")
const ELITE_ROOM_DATA := preload("res://resources/rooms/elite_room.tres")
const SHOP_ROOM_DATA := preload("res://resources/rooms/shop_room.tres")
const BOSS_PLACEHOLDER_ROOM_DATA := preload("res://resources/rooms/boss_placeholder_room.tres")
const TRAINING_LAYOUT := preload("res://resources/room_layouts/training.tres")
const CROSSFIRE_LAYOUT := preload("res://resources/room_layouts/crossfire.tres")
const REWARD_CACHE_LAYOUT := preload("res://resources/room_layouts/reward_cache.tres")
const PILLARS_LAYOUT := preload("res://resources/room_layouts/pillars.tres")
const MARKET_LAYOUT := preload("res://resources/room_layouts/market.tres")
const BOSS_ARENA_LAYOUT := preload("res://resources/room_layouts/boss_arena.tres")
const GAUNTLET_LAYOUT := preload("res://resources/room_layouts/gauntlet.tres")
const SPLIT_COVER_LAYOUT := preload("res://resources/room_layouts/split_cover.tres")
const SHRINE_LAYOUT := preload("res://resources/room_layouts/shrine.tres")
const CENTER_RING_LAYOUT := preload("res://resources/room_layouts/center_ring.tres")
const AMBUSH_CORNERS_LAYOUT := preload("res://resources/room_layouts/ambush_corners.tres")
const BOSS_CROSS_LAYOUT := preload("res://resources/room_layouts/boss_cross.tres")
const BOX_MAZE_LAYOUT := preload("res://resources/room_layouts/box_maze.tres")
const BUNKER_LAYOUT := preload("res://resources/room_layouts/bunker.tres")
const CORNER_NESTS_LAYOUT := preload("res://resources/room_layouts/corner_nests.tres")
const CRESCENT_LAYOUT := preload("res://resources/room_layouts/crescent.tres")
const DIAGONAL_BLOCKS_LAYOUT := preload("res://resources/room_layouts/diagonal_blocks.tres")
const LONG_LANE_LAYOUT := preload("res://resources/room_layouts/long_lane.tres")
const NARROW_GAP_LAYOUT := preload("res://resources/room_layouts/narrow_gap.tres")
const OPEN_CROSS_LAYOUT := preload("res://resources/room_layouts/open_cross.tres")
const TWIN_ISLANDS_LAYOUT := preload("res://resources/room_layouts/twin_islands.tres")
const WIDE_ARENA_LAYOUT := preload("res://resources/room_layouts/wide_arena.tres")

@export var rooms_parent_path: NodePath = ^"../Rooms"
@export var room_spacing := Vector2(1320, 820)
@export var room_data_sequence: Array[Resource] = []
@export var generation_seed: int = 0

var _room_records: Array[Dictionary] = []
var _combat_rooms: Array[Node] = []
var _room_id_by_instance_id: Dictionary = {}
var _record_index_by_room_id: Dictionary = {}
var _current_room_id := ""
var _active_generation_seed := 0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	Events.room_state_changed.connect(_on_room_state_changed)
	generate_dungeon()


func generate_dungeon() -> void:
	var rooms_parent := get_node_or_null(rooms_parent_path) as Node2D
	if rooms_parent == null:
		push_error("DungeonController could not find rooms parent: %s" % rooms_parent_path)
		return

	_clear_generated_rooms(rooms_parent)
	_room_records.clear()
	_combat_rooms.clear()
	_room_id_by_instance_id.clear()
	_record_index_by_room_id.clear()
	_current_room_id = ""
	_prepare_rng()

	var definitions := _get_room_definitions()
	var room_count := definitions.size()
	for index in range(room_count):
		var definition: Dictionary = definitions[index]
		var room_data := definition["room_data"] as Resource
		var record := _build_room_record(index, room_count, room_data, definition)
		var room_scene := _get_room_scene(room_data)
		var room_instance := room_scene.instantiate() as Node2D
		if room_instance == null:
			push_error("DungeonController failed to instantiate room %s" % record["id"])
			continue

		room_instance.name = record["id"]
		var grid_position := record["grid_position"] as Vector2i
		room_instance.position = Vector2(grid_position.x * room_spacing.x, grid_position.y * room_spacing.y)
		room_instance.add_to_group("generated_dungeon_rooms")

		var combat_room := room_instance.get_node_or_null("CombatRoom")
		if combat_room == null:
			push_error("Generated room %s is missing CombatRoom node" % record["id"])
			room_instance.queue_free()
			continue

		_apply_room_config(combat_room, room_data, record["connections"], definition.get("layout_data"))
		rooms_parent.add_child(room_instance)
		_room_records.append(record)
		_combat_rooms.append(combat_room)
		_room_id_by_instance_id[combat_room.get_instance_id()] = record["id"]
		_record_index_by_room_id[record["id"]] = _room_records.size() - 1

	Events.dungeon_generated.emit(get_room_records())
	_emit_dungeon_updated()
	_sync_parent_minimap()


func get_room_records() -> Array:
	return _room_records.duplicate(true)


func get_combat_rooms() -> Array:
	return _combat_rooms.duplicate()


func get_current_room_id() -> String:
	return _current_room_id


func get_generation_seed() -> int:
	return _active_generation_seed


func get_debug_map_text() -> String:
	var lines := PackedStringArray()
	lines.append("Seed: %d" % _active_generation_seed)
	lines.append("Grid:")
	lines.append_array(_get_debug_grid_lines())
	lines.append("Rooms:")
	for record in _room_records:
		var grid_position := record["grid_position"] as Vector2i
		var connections := record["connections"] as PackedStringArray
		var sorted_connections := Array(connections)
		sorted_connections.sort()
		lines.append("%s %s %s at (%d,%d) doors=%s layout=%s state=%s" % [
			str(record.get("id", "")),
			_get_debug_room_marker(str(record.get("room_type", ""))),
			str(record.get("room_type", "")),
			grid_position.x,
			grid_position.y,
			",".join(sorted_connections),
			str(record.get("layout_profile", "")),
			str(record.get("state", "")),
		])
	return "\n".join(lines)


func set_generation_seed(seed: int) -> void:
	generation_seed = seed


func regenerate_with_seed(seed: int) -> void:
	generation_seed = seed
	generate_dungeon()


func _clear_generated_rooms(rooms_parent: Node2D) -> void:
	for child in rooms_parent.get_children():
		if child.is_in_group("generated_dungeon_rooms"):
			rooms_parent.remove_child(child)
			child.free()


func _build_room_record(index: int, _room_count: int, room_data: Resource, definition: Dictionary) -> Dictionary:
	var connections: PackedStringArray = definition.get("connections", PackedStringArray())
	var grid_position: Vector2i = definition.get("grid_position", Vector2i(index, 0))
	var layout_data := _get_definition_layout_data(definition, room_data)

	return {
		"id": "Room%02d" % (index + 1),
		"generation_seed": _active_generation_seed,
		"room_data_id": _get_room_data_id(room_data),
		"room_type": _get_room_data_string(room_data, "room_type", "combat"),
		"grid_position": grid_position,
		"connections": connections,
		"template_id": _get_room_data_string(room_data, "template_id", "prototype_combat_room"),
		"layout_profile": _get_layout_id(room_data, layout_data),
		"enemy_pool": _get_room_data_packed_strings(room_data, "enemy_names"),
		"wave_counts": _get_room_data_wave_counts(room_data),
		"auto_clear": bool(room_data.get("auto_clear_on_enter")),
		"locks_doors": bool(room_data.get("lock_doors_during_combat")),
		"has_reward": room_data.get("reward_scene") != null,
		"elite_enemies": bool(room_data.get("elite_enemies")),
		"visited": false,
		"cleared": false,
		"current": false,
		"state": "Unentered",
	}


func _apply_room_config(combat_room: Node, room_data: Resource, connections: PackedStringArray, layout_override = null) -> void:
	var layout_data := layout_override as Resource
	if layout_data == null:
		layout_data = _get_room_layout_data(room_data)
	combat_room.set("room_type", _get_room_data_string(room_data, "room_type", "combat"))
	combat_room.set("layout_profile", _get_layout_id(room_data, layout_data))
	combat_room.set("layout_data", layout_data)
	combat_room.set("connected_directions", connections)
	combat_room.set("enemy_scenes", room_data.get("enemy_scenes"))
	combat_room.set("wave_enemy_counts", _get_room_data_wave_counts(room_data))
	combat_room.set("reward_scene", room_data.get("reward_scene"))
	combat_room.set("lock_doors_during_combat", bool(room_data.get("lock_doors_during_combat")))
	combat_room.set("auto_clear_on_enter", bool(room_data.get("auto_clear_on_enter")))
	combat_room.set("elite_enemies", bool(room_data.get("elite_enemies")))
	combat_room.set("elite_health_multiplier", float(room_data.get("elite_health_multiplier")))
	combat_room.set("elite_damage_multiplier", float(room_data.get("elite_damage_multiplier")))
	combat_room.set("elite_death_explosion_radius", float(room_data.get("elite_death_explosion_radius")))
	combat_room.set("elite_death_explosion_damage", int(room_data.get("elite_death_explosion_damage")))


func _get_room_definitions() -> Array[Dictionary]:
	if not room_data_sequence.is_empty():
		var legacy_definitions: Array[Dictionary] = []
		for index in range(room_data_sequence.size()):
			var connections := PackedStringArray()
			if index > 0:
				connections.append("west")
			if index < room_data_sequence.size() - 1:
				connections.append("east")
			legacy_definitions.append(_make_room_definition(room_data_sequence[index], Vector2i(index, 0), connections, null))
		return legacy_definitions

	var used_layout_ids := {}
	var reward_one_direction := _pick_branch_direction("north")
	var shop_direction := _pick_branch_direction("south")
	var reward_two_direction := _pick_branch_direction("north")
	var reward_one_position := Vector2i(1, 0) + _direction_to_offset(reward_one_direction)
	var shop_position := Vector2i(3, 0) + _direction_to_offset(shop_direction)
	var reward_two_position := Vector2i(4, 0) + _direction_to_offset(reward_two_direction)

	return [
		_make_room_definition(START_ROOM_DATA, Vector2i(0, 0), PackedStringArray(["east"]), _pick_layout(_start_layout_pool(), used_layout_ids)),
		_make_room_definition(COMBAT_ROOM_DATA, Vector2i(1, 0), _packed_connections(["west", "east", reward_one_direction]), _pick_layout(_combat_layout_pool(), used_layout_ids)),
		_make_room_definition(REWARD_ROOM_DATA, reward_one_position, PackedStringArray([_opposite_direction(reward_one_direction)]), _pick_layout(_reward_layout_pool(), used_layout_ids)),
		_make_room_definition(COMBAT_ROOM_DATA, Vector2i(2, 0), PackedStringArray(["west", "east"]), _pick_layout(_combat_layout_pool(), used_layout_ids)),
		_make_room_definition(ELITE_ROOM_DATA, Vector2i(3, 0), _packed_connections(["west", "east", shop_direction]), _pick_layout(_elite_layout_pool(), used_layout_ids)),
		_make_room_definition(SHOP_ROOM_DATA, shop_position, PackedStringArray([_opposite_direction(shop_direction)]), _pick_layout(_shop_layout_pool(), used_layout_ids)),
		_make_room_definition(COMBAT_ROOM_DATA, Vector2i(4, 0), _packed_connections(["west", "east", reward_two_direction]), _pick_layout(_combat_layout_pool(), used_layout_ids)),
		_make_room_definition(REWARD_ROOM_DATA, reward_two_position, PackedStringArray([_opposite_direction(reward_two_direction)]), _pick_layout(_reward_layout_pool(), used_layout_ids)),
		_make_room_definition(COMBAT_ROOM_DATA, Vector2i(5, 0), PackedStringArray(["west", "east"]), _pick_layout(_combat_layout_pool(), used_layout_ids)),
		_make_room_definition(BOSS_PLACEHOLDER_ROOM_DATA, Vector2i(6, 0), PackedStringArray(["west"]), _pick_layout(_boss_layout_pool(), used_layout_ids)),
	]


func _make_room_definition(room_data: Resource, grid_position: Vector2i, connections: PackedStringArray, layout_data: Resource) -> Dictionary:
	return {
		"room_data": room_data,
		"grid_position": grid_position,
		"connections": connections,
		"layout_data": layout_data,
	}


func _get_room_data_sequence() -> Array[Resource]:
	if not room_data_sequence.is_empty():
		return room_data_sequence

	return [
		START_ROOM_DATA,
		COMBAT_ROOM_DATA,
		REWARD_ROOM_DATA,
		ELITE_ROOM_DATA,
		SHOP_ROOM_DATA,
		BOSS_PLACEHOLDER_ROOM_DATA,
	]


func _get_room_scene(room_data: Resource) -> PackedScene:
	var scene := room_data.get("room_scene") as PackedScene
	if scene != null:
		return scene
	return PROTOTYPE_ROOM_SCENE


func _get_room_data_id(room_data: Resource) -> String:
	var value = room_data.get("id")
	if value == null:
		return ""
	return str(value)


func _get_room_data_string(room_data: Resource, property_name: String, fallback: String) -> String:
	var value = room_data.get(property_name)
	if value == null:
		return fallback
	return str(value)


func _get_room_layout_data(room_data: Resource) -> Resource:
	var value = room_data.get("layout_data")
	if value is Resource:
		return value
	return null


func _get_definition_layout_data(definition: Dictionary, room_data: Resource) -> Resource:
	var value = definition.get("layout_data")
	if value is Resource:
		return value
	return _get_room_layout_data(room_data)


func _get_layout_id(room_data: Resource, layout_override: Resource = null) -> String:
	var layout_data := layout_override
	if layout_data == null:
		layout_data = _get_room_layout_data(room_data)
	if layout_data != null:
		var layout_id = layout_data.get("id")
		if layout_id != null and not str(layout_id).is_empty():
			return str(layout_id)
	return _get_room_data_string(room_data, "layout_profile", "crossfire")


func _prepare_rng() -> void:
	if generation_seed != 0:
		_active_generation_seed = generation_seed
	else:
		_rng.randomize()
		_active_generation_seed = int(_rng.randi())
	_rng.seed = _active_generation_seed


func _pick_branch_direction(_preferred_direction: String) -> String:
	if _rng.randi_range(0, 1) == 0:
		return "north"
	return "south"


func _pick_layout(pool: Array, used_layout_ids: Dictionary) -> Resource:
	if pool.is_empty():
		return null

	var candidates: Array[Resource] = []
	for layout in pool:
		if not layout is Resource:
			continue
		var layout_id := _get_layout_resource_id(layout)
		if layout_id.is_empty() or not used_layout_ids.has(layout_id):
			candidates.append(layout)

	if candidates.is_empty():
		for layout in pool:
			if layout is Resource:
				candidates.append(layout)

	if candidates.is_empty():
		return null

	var selected := candidates[_rng.randi_range(0, candidates.size() - 1)] as Resource
	var selected_id := _get_layout_resource_id(selected)
	if not selected_id.is_empty():
		used_layout_ids[selected_id] = true
	return selected


func _get_layout_resource_id(layout: Resource) -> String:
	if layout == null:
		return ""
	var value = layout.get("id")
	if value == null:
		return ""
	return str(value)


func _packed_connections(values: Array) -> PackedStringArray:
	var connections := PackedStringArray()
	for value in values:
		var direction := str(value)
		if not direction.is_empty():
			connections.append(direction)
	return connections


func _direction_to_offset(direction: String) -> Vector2i:
	match direction:
		"east":
			return Vector2i(1, 0)
		"west":
			return Vector2i(-1, 0)
		"north":
			return Vector2i(0, -1)
		"south":
			return Vector2i(0, 1)
	return Vector2i.ZERO


func _opposite_direction(direction: String) -> String:
	match direction:
		"east":
			return "west"
		"west":
			return "east"
		"north":
			return "south"
		"south":
			return "north"
	return ""


func _start_layout_pool() -> Array:
	return [TRAINING_LAYOUT, OPEN_CROSS_LAYOUT]


func _combat_layout_pool() -> Array:
	return [
		CROSSFIRE_LAYOUT,
		GAUNTLET_LAYOUT,
		SPLIT_COVER_LAYOUT,
		CENTER_RING_LAYOUT,
		AMBUSH_CORNERS_LAYOUT,
		BOX_MAZE_LAYOUT,
		BUNKER_LAYOUT,
		CORNER_NESTS_LAYOUT,
		CRESCENT_LAYOUT,
		DIAGONAL_BLOCKS_LAYOUT,
		LONG_LANE_LAYOUT,
		NARROW_GAP_LAYOUT,
		TWIN_ISLANDS_LAYOUT,
		WIDE_ARENA_LAYOUT,
	]


func _reward_layout_pool() -> Array:
	return [
		REWARD_CACHE_LAYOUT,
		SHRINE_LAYOUT,
		OPEN_CROSS_LAYOUT,
		CRESCENT_LAYOUT,
		TWIN_ISLANDS_LAYOUT,
	]


func _elite_layout_pool() -> Array:
	return [
		PILLARS_LAYOUT,
		BUNKER_LAYOUT,
		BOX_MAZE_LAYOUT,
		DIAGONAL_BLOCKS_LAYOUT,
		WIDE_ARENA_LAYOUT,
	]


func _shop_layout_pool() -> Array:
	return [
		MARKET_LAYOUT,
		CORNER_NESTS_LAYOUT,
		OPEN_CROSS_LAYOUT,
		CRESCENT_LAYOUT,
	]


func _boss_layout_pool() -> Array:
	return [
		BOSS_ARENA_LAYOUT,
		BOSS_CROSS_LAYOUT,
		WIDE_ARENA_LAYOUT,
	]


func _get_room_data_packed_strings(room_data: Resource, property_name: String) -> PackedStringArray:
	var value = room_data.get(property_name)
	if value is PackedStringArray:
		return value
	return PackedStringArray()


func _get_room_data_wave_counts(room_data: Resource) -> PackedInt32Array:
	var value = room_data.get("wave_enemy_counts")
	if value is PackedInt32Array:
		return value
	return PackedInt32Array()


func _get_debug_grid_lines() -> PackedStringArray:
	var lines := PackedStringArray()
	if _room_records.is_empty():
		return lines

	var min_x := 0
	var max_x := 0
	var min_y := 0
	var max_y := 0
	var rooms_by_position := {}
	for record in _room_records:
		var grid_position := record["grid_position"] as Vector2i
		min_x = mini(min_x, grid_position.x)
		max_x = maxi(max_x, grid_position.x)
		min_y = mini(min_y, grid_position.y)
		max_y = maxi(max_y, grid_position.y)
		rooms_by_position[grid_position] = record

	for y in range(min_y, max_y + 1):
		var row := PackedStringArray()
		for x in range(min_x, max_x + 1):
			var grid_position := Vector2i(x, y)
			if rooms_by_position.has(grid_position):
				row.append(_get_debug_room_marker(str(rooms_by_position[grid_position].get("room_type", ""))))
			else:
				row.append(".")
		lines.append(" ".join(row))
	return lines


func _get_debug_room_marker(room_type: String) -> String:
	match room_type:
		"start":
			return "S"
		"reward":
			return "R"
		"elite":
			return "E"
		"shop":
			return "$"
		"boss", "boss_placeholder":
			return "B"
	return "C"


func _on_room_state_changed(room: Node, state_name: String) -> void:
	var room_id = _room_id_by_instance_id.get(room.get_instance_id(), "")
	if room_id == "":
		return

	_update_room_record(str(room_id), state_name)
	_emit_dungeon_updated()


func _update_room_record(room_id: String, state_name: String) -> void:
	if not _record_index_by_room_id.has(room_id):
		return

	var record_index := int(_record_index_by_room_id[room_id])
	var record := _room_records[record_index]
	record["state"] = state_name

	if state_name != "Unentered":
		record["visited"] = true

	if state_name == "Cleared" or state_name == "Reward Claimed":
		record["cleared"] = true

	_room_records[record_index] = record

	if state_name != "Unentered":
		_set_current_room_id(room_id)


func _set_current_room_id(room_id: String) -> void:
	_current_room_id = room_id
	for index in range(_room_records.size()):
		var record := _room_records[index]
		record["current"] = record["id"] == room_id
		_room_records[index] = record


func _emit_dungeon_updated() -> void:
	Events.dungeon_updated.emit(get_room_records(), _current_room_id)


func _sync_parent_minimap() -> void:
	var parent := get_parent()
	if parent != null and parent.has_method("sync_dungeon_hud"):
		parent.call_deferred("sync_dungeon_hud")

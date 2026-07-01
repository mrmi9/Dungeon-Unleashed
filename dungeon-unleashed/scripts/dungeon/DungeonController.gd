extends Node
class_name DungeonController

const PROTOTYPE_ROOM_SCENE := preload("res://scenes/rooms/PrototypeCombatRoom.tscn")
const START_ROOM_DATA := preload("res://resources/rooms/start_room.tres")
const COMBAT_ROOM_DATA := preload("res://resources/rooms/combat_room.tres")
const REWARD_ROOM_DATA := preload("res://resources/rooms/reward_room.tres")
const ARMORY_ROOM_DATA := preload("res://resources/rooms/armory_room.tres")
const HEALING_ROOM_DATA := preload("res://resources/rooms/healing_room.tres")
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
const COIN_PICKUP_SCENE := preload("res://scenes/pickups/CoinPickup.tscn")
const RELIC_PICKUP_SCENE := preload("res://scenes/pickups/RelicPickup.tscn")
const NORMAL_CHEST_SCENE := preload("res://scenes/chests/NormalChest.tscn")
const PREMIUM_CHEST_SCENE := preload("res://scenes/chests/PremiumChest.tscn")
const WEAPON_CHEST_SCENE := preload("res://scenes/chests/WeaponChest.tscn")
const HEALING_CHEST_SCENE := preload("res://scenes/chests/HealingChest.tscn")
const BOSS_REWARD_CHEST_SCENE := preload("res://scenes/chests/BossRewardChest.tscn")
const SHOP_INVENTORY_SCENE := preload("res://scenes/shop/ShopInventory.tscn")
const CHASER_ENEMY_SCENE := preload("res://scenes/enemies/ChaserEnemy.tscn")
const SHOOTER_ENEMY_SCENE := preload("res://scenes/enemies/ShooterEnemy.tscn")
const CHARGER_ENEMY_SCENE := preload("res://scenes/enemies/ChargerEnemy.tscn")
const SUMMONER_ENEMY_SCENE := preload("res://scenes/enemies/SummonerEnemy.tscn")
const SHIELD_ENEMY_SCENE := preload("res://scenes/enemies/ShieldEnemy.tscn")
const BOMBER_ENEMY_SCENE := preload("res://scenes/enemies/BomberEnemy.tscn")
const BOSS_ENEMY_SCENE := preload("res://scenes/enemies/BossEnemy.tscn")
const MAIN_PATH_MIN_ROOMS := 7
const MAIN_PATH_MAX_ROOMS := 9
const BRANCH_MIN_ROOMS := 5
const BRANCH_MAX_ROOMS := 6

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
		lines.append("%s %s %s at (%d,%d) doors=%s role=%s main=%d branch_of=%d layout=%s state=%s" % [
			str(record.get("id", "")),
			_get_debug_room_marker(str(record.get("room_type", ""))),
			str(record.get("room_type", "")),
			grid_position.x,
			grid_position.y,
			",".join(sorted_connections),
			str(record.get("path_role", "")),
			int(record.get("main_path_index", -1)),
			int(record.get("branch_of", -1)),
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
		"path_role": str(definition.get("path_role", "main")),
		"main_path_index": int(definition.get("main_path_index", -1)),
		"branch_of": int(definition.get("branch_of", -1)),
		"template_id": _get_room_data_string(room_data, "template_id", "prototype_combat_room"),
		"layout_profile": _get_layout_id(room_data, layout_data),
		"enemy_pool": _get_room_data_packed_strings(room_data, "enemy_names"),
		"wave_counts": _get_room_data_wave_counts(room_data),
		"auto_clear": _get_room_data_auto_clear(room_data),
		"locks_doors": _get_room_data_lock_doors(room_data),
		"has_reward": _get_room_data_reward_scene(room_data) != null,
		"elite_enemies": _get_room_data_elite_enemies(room_data),
		"visited": false,
		"cleared": false,
		"current": false,
		"state": "Unentered",
	}


func _apply_room_config(combat_room: Node, room_data: Resource, connections: PackedStringArray, layout_override = null) -> void:
	var typed_room := combat_room as CombatRoom
	if typed_room == null:
		return

	var layout_data := layout_override as Resource
	if layout_data == null:
		layout_data = _get_room_layout_data(room_data)
	typed_room.room_type = _get_room_data_string(room_data, "room_type", "combat")
	typed_room.layout_profile = _get_layout_id(room_data, layout_data)
	typed_room.layout_data = layout_data
	typed_room.connected_directions = connections
	typed_room.enemy_scenes = _get_room_data_enemy_scenes(room_data)
	typed_room.wave_enemy_counts = _get_room_data_wave_counts(room_data)
	typed_room.reward_scene = _get_room_data_reward_scene(room_data)
	typed_room.lock_doors_during_combat = _get_room_data_lock_doors(room_data)
	typed_room.auto_clear_on_enter = _get_room_data_auto_clear(room_data)
	typed_room.elite_enemies = _get_room_data_elite_enemies(room_data)
	typed_room.elite_health_multiplier = _get_room_data_elite_health_multiplier(room_data)
	typed_room.elite_damage_multiplier = _get_room_data_elite_damage_multiplier(room_data)
	typed_room.elite_death_explosion_radius = _get_room_data_elite_death_explosion_radius(room_data)
	typed_room.elite_death_explosion_damage = _get_room_data_elite_death_explosion_damage(room_data)


func _get_room_definitions() -> Array[Dictionary]:
	if not room_data_sequence.is_empty():
		var legacy_definitions: Array[Dictionary] = []
		for index in range(room_data_sequence.size()):
			var connections := PackedStringArray()
			if index > 0:
				connections.append("west")
			if index < room_data_sequence.size() - 1:
				connections.append("east")
			legacy_definitions.append(_make_room_definition(
				room_data_sequence[index],
				Vector2i(index, 0),
				connections,
				null,
				{
					"path_role": "legacy",
					"main_path_index": index,
				}
			))
		return legacy_definitions

	var used_layout_ids := {}
	var main_path_room_count := _rng.randi_range(MAIN_PATH_MIN_ROOMS, MAIN_PATH_MAX_ROOMS)
	var boss_x := main_path_room_count - 1
	var elite_x := _pick_main_elite_x(main_path_room_count)
	var branch_specs := _build_branch_specs(main_path_room_count, elite_x)
	var branches_by_anchor := _group_branches_by_anchor(branch_specs)
	var definitions: Array[Dictionary] = []

	for x in range(main_path_room_count):
		var room_data := _get_main_path_room_data(x, boss_x, elite_x)
		var connections := _get_main_path_connections(x, boss_x, branches_by_anchor)
		definitions.append(_make_room_definition(
			room_data,
			Vector2i(x, 0),
			connections,
			_pick_layout(_layout_pool_for_room_data(room_data), used_layout_ids),
			{
				"path_role": "main",
				"main_path_index": x,
			}
		))

		var branch_list: Array = branches_by_anchor.get(x, [])
		for branch in branch_list:
			var branch_direction := str(branch.get("direction", "north"))
			var branch_data := branch.get("room_data") as Resource
			definitions.append(_make_room_definition(
				branch_data,
				Vector2i(x, 0) + _direction_to_offset(branch_direction),
				PackedStringArray([_opposite_direction(branch_direction)]),
				_pick_layout(_layout_pool_for_room_data(branch_data), used_layout_ids),
				{
					"path_role": "branch",
					"main_path_index": -1,
					"branch_of": x,
				}
			))

	return definitions


func _make_room_definition(room_data: Resource, grid_position: Vector2i, connections: PackedStringArray, layout_data: Resource, metadata: Dictionary = {}) -> Dictionary:
	var definition := {
		"room_data": room_data,
		"grid_position": grid_position,
		"connections": connections,
		"layout_data": layout_data,
	}
	for key in metadata.keys():
		definition[key] = metadata[key]
	return definition


func _get_room_data_sequence() -> Array[Resource]:
	if not room_data_sequence.is_empty():
		return room_data_sequence

	return [
		START_ROOM_DATA,
		COMBAT_ROOM_DATA,
		REWARD_ROOM_DATA,
		ARMORY_ROOM_DATA,
		HEALING_ROOM_DATA,
		ELITE_ROOM_DATA,
		SHOP_ROOM_DATA,
		BOSS_PLACEHOLDER_ROOM_DATA,
	]


func _pick_main_elite_x(main_path_room_count: int) -> int:
	var boss_x := main_path_room_count - 1
	var low := mini(2, boss_x - 2)
	var high := mini(maxi(low, boss_x - 2), 3)
	return _rng.randi_range(low, high)


func _get_main_path_room_data(x: int, boss_x: int, elite_x: int) -> Resource:
	if x == 0:
		return START_ROOM_DATA
	if x == boss_x:
		return BOSS_PLACEHOLDER_ROOM_DATA
	if x == elite_x:
		return ELITE_ROOM_DATA
	return COMBAT_ROOM_DATA


func _get_main_path_connections(x: int, boss_x: int, branches_by_anchor: Dictionary) -> PackedStringArray:
	var connections := PackedStringArray()
	if x > 0:
		connections.append("west")
	if x < boss_x:
		connections.append("east")

	var branch_list: Array = branches_by_anchor.get(x, [])
	for branch in branch_list:
		var direction := str(branch.get("direction", ""))
		if not direction.is_empty() and not connections.has(direction):
			connections.append(direction)
	return connections


func _build_branch_specs(main_path_room_count: int, elite_x: int) -> Array[Dictionary]:
	var boss_x := main_path_room_count - 1
	var candidates := _get_branch_candidates(boss_x)
	var branch_count := _rng.randi_range(BRANCH_MIN_ROOMS, mini(BRANCH_MAX_ROOMS, candidates.size()))
	var specs: Array[Dictionary] = []

	_add_branch_spec(specs, candidates, REWARD_ROOM_DATA, -1, true)
	_add_branch_spec(specs, candidates, SHOP_ROOM_DATA, elite_x, true)
	_add_branch_spec(specs, candidates, REWARD_ROOM_DATA, -1, false)
	_add_branch_spec(specs, candidates, ARMORY_ROOM_DATA, -1, true)
	_add_branch_spec(specs, candidates, HEALING_ROOM_DATA, -1, true)

	var optional_rooms := [
		ELITE_ROOM_DATA,
		REWARD_ROOM_DATA,
		COMBAT_ROOM_DATA,
	]
	while specs.size() < branch_count and not candidates.is_empty():
		var room_data := optional_rooms[_rng.randi_range(0, optional_rooms.size() - 1)] as Resource
		_add_branch_spec(specs, candidates, room_data, -1, true)

	specs.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ax := int(a.get("anchor_x", 0))
		var bx := int(b.get("anchor_x", 0))
		if ax == bx:
			return str(a.get("direction", "")) < str(b.get("direction", ""))
		return ax < bx
	)
	return specs


func _get_branch_candidates(boss_x: int) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	for x in range(1, boss_x):
		candidates.append({
			"anchor_x": x,
			"direction": "north",
		})
		candidates.append({
			"anchor_x": x,
			"direction": "south",
		})
	return candidates


func _add_branch_spec(specs: Array[Dictionary], candidates: Array[Dictionary], room_data: Resource, preferred_anchor_x: int = -1, prefer_late: bool = false) -> void:
	if candidates.is_empty():
		return

	var candidate_index := _pick_branch_candidate_index(candidates, preferred_anchor_x, prefer_late)
	var candidate := candidates[candidate_index]
	candidates.remove_at(candidate_index)
	specs.append({
		"room_data": room_data,
		"anchor_x": int(candidate.get("anchor_x", 1)),
		"direction": str(candidate.get("direction", "north")),
	})


func _pick_branch_candidate_index(candidates: Array[Dictionary], preferred_anchor_x: int, prefer_late: bool) -> int:
	var filtered_indexes: Array[int] = []
	if preferred_anchor_x > 0:
		for index in range(candidates.size()):
			if int(candidates[index].get("anchor_x", -1)) == preferred_anchor_x:
				filtered_indexes.append(index)

	if filtered_indexes.is_empty() and prefer_late:
		var max_anchor := 0
		for candidate in candidates:
			max_anchor = maxi(max_anchor, int(candidate.get("anchor_x", 0)))
		var min_anchor := maxi(1, max_anchor - 2)
		for index in range(candidates.size()):
			if int(candidates[index].get("anchor_x", 0)) >= min_anchor:
				filtered_indexes.append(index)

	if filtered_indexes.is_empty():
		for index in range(candidates.size()):
			filtered_indexes.append(index)

	return filtered_indexes[_rng.randi_range(0, filtered_indexes.size() - 1)]


func _group_branches_by_anchor(branch_specs: Array[Dictionary]) -> Dictionary:
	var branches_by_anchor := {}
	for branch in branch_specs:
		var anchor_x := int(branch.get("anchor_x", 1))
		var branch_list: Array = branches_by_anchor.get(anchor_x, [])
		branch_list.append(branch)
		branches_by_anchor[anchor_x] = branch_list
	return branches_by_anchor


func _layout_pool_for_room_data(room_data: Resource) -> Array:
	var room_type := _get_room_data_string(room_data, "room_type", "combat")
	match room_type:
		"start":
			return _start_layout_pool()
		"reward", "armory":
			return _reward_layout_pool()
		"healing":
			return _healing_layout_pool()
		"elite":
			return _elite_layout_pool()
		"shop":
			return _shop_layout_pool()
		"boss", "boss_placeholder":
			return _boss_layout_pool()
	return _combat_layout_pool()


func _get_room_scene(room_data: Resource) -> PackedScene:
	var config := _get_room_data_config(room_data)
	if config.has("room_scene") and config["room_scene"] is PackedScene:
		return config["room_scene"] as PackedScene

	var typed_room_data := room_data as RoomData
	if typed_room_data != null and typed_room_data.room_scene != null:
		return typed_room_data.room_scene
	return PROTOTYPE_ROOM_SCENE


func _get_room_data_id(room_data: Resource) -> String:
	var config := _get_room_data_config(room_data)
	if config.has("id"):
		return str(config["id"])

	var typed_room_data := room_data as RoomData
	if typed_room_data == null:
		return ""
	return str(typed_room_data.id)


func _get_room_data_string(room_data: Resource, property_name: String, fallback: String) -> String:
	var config := _get_room_data_config(room_data)
	if config.has(property_name):
		return str(config[property_name])

	var typed_room_data := room_data as RoomData
	if typed_room_data == null:
		return fallback
	match property_name:
		"room_type":
			return typed_room_data.room_type
		"template_id":
			return typed_room_data.template_id
		"layout_profile":
			return typed_room_data.layout_profile
	return fallback


func _get_room_layout_data(room_data: Resource) -> Resource:
	var config := _get_room_data_config(room_data)
	if config.has("layout_data") and config["layout_data"] is Resource:
		return config["layout_data"] as Resource

	var typed_room_data := room_data as RoomData
	if typed_room_data != null and typed_room_data.layout_data != null:
		return typed_room_data.layout_data
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
		var typed_layout := layout_data as RoomLayoutData
		if typed_layout != null and not str(typed_layout.id).is_empty():
			return str(typed_layout.id)
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
	var typed_layout := layout as RoomLayoutData
	if typed_layout == null:
		return ""
	return str(typed_layout.id)


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


func _healing_layout_pool() -> Array:
	return [
		SHRINE_LAYOUT,
		OPEN_CROSS_LAYOUT,
		REWARD_CACHE_LAYOUT,
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
	var config := _get_room_data_config(room_data)
	if config.has(property_name) and config[property_name] is PackedStringArray:
		return config[property_name]

	var typed_room_data := room_data as RoomData
	if typed_room_data != null and property_name == "enemy_names":
		return typed_room_data.enemy_names
	return PackedStringArray()


func _get_room_data_wave_counts(room_data: Resource) -> PackedInt32Array:
	var config := _get_room_data_config(room_data)
	if config.has("wave_enemy_counts") and config["wave_enemy_counts"] is PackedInt32Array:
		return config["wave_enemy_counts"]

	var typed_room_data := room_data as RoomData
	if typed_room_data != null:
		return typed_room_data.wave_enemy_counts
	return PackedInt32Array()


func _get_room_data_enemy_scenes(room_data: Resource) -> Array[PackedScene]:
	var config := _get_room_data_config(room_data)
	if config.has("enemy_scenes"):
		var configured_scenes: Array[PackedScene] = []
		for scene in config["enemy_scenes"]:
			if scene is PackedScene:
				configured_scenes.append(scene)
		return configured_scenes

	var typed_room_data := room_data as RoomData
	if typed_room_data != null:
		return typed_room_data.enemy_scenes
	return []


func _get_room_data_reward_scene(room_data: Resource) -> PackedScene:
	var config := _get_room_data_config(room_data)
	if config.has("reward_scene") and config["reward_scene"] is PackedScene:
		return config["reward_scene"] as PackedScene

	var typed_room_data := room_data as RoomData
	if typed_room_data != null:
		return typed_room_data.reward_scene
	return null


func _get_room_data_lock_doors(room_data: Resource) -> bool:
	var config := _get_room_data_config(room_data)
	if config.has("lock_doors_during_combat"):
		return bool(config["lock_doors_during_combat"])

	var typed_room_data := room_data as RoomData
	if typed_room_data != null:
		return typed_room_data.lock_doors_during_combat
	return true


func _get_room_data_auto_clear(room_data: Resource) -> bool:
	var config := _get_room_data_config(room_data)
	if config.has("auto_clear_on_enter"):
		return bool(config["auto_clear_on_enter"])

	var typed_room_data := room_data as RoomData
	if typed_room_data != null:
		return typed_room_data.auto_clear_on_enter
	return false


func _get_room_data_elite_enemies(room_data: Resource) -> bool:
	var config := _get_room_data_config(room_data)
	if config.has("elite_enemies"):
		return bool(config["elite_enemies"])

	var typed_room_data := room_data as RoomData
	if typed_room_data != null:
		return typed_room_data.elite_enemies
	return false


func _get_room_data_elite_health_multiplier(room_data: Resource) -> float:
	var config := _get_room_data_config(room_data)
	if config.has("elite_health_multiplier"):
		return float(config["elite_health_multiplier"])

	var typed_room_data := room_data as RoomData
	if typed_room_data != null:
		return typed_room_data.elite_health_multiplier
	return 1.0


func _get_room_data_elite_damage_multiplier(room_data: Resource) -> float:
	var config := _get_room_data_config(room_data)
	if config.has("elite_damage_multiplier"):
		return float(config["elite_damage_multiplier"])

	var typed_room_data := room_data as RoomData
	if typed_room_data != null:
		return typed_room_data.elite_damage_multiplier
	return 1.0


func _get_room_data_elite_death_explosion_radius(room_data: Resource) -> float:
	var config := _get_room_data_config(room_data)
	if config.has("elite_death_explosion_radius"):
		return float(config["elite_death_explosion_radius"])

	var typed_room_data := room_data as RoomData
	if typed_room_data != null:
		return typed_room_data.elite_death_explosion_radius
	return 0.0


func _get_room_data_elite_death_explosion_damage(room_data: Resource) -> int:
	var config := _get_room_data_config(room_data)
	if config.has("elite_death_explosion_damage"):
		return int(config["elite_death_explosion_damage"])

	var typed_room_data := room_data as RoomData
	if typed_room_data != null:
		return typed_room_data.elite_death_explosion_damage
	return 0


func _get_room_data_config(room_data: Resource) -> Dictionary:
	match _get_room_data_key(room_data):
		"start_room":
			return {
				"id": "start_room",
				"room_type": "start",
				"template_id": "prototype_combat_room",
				"layout_profile": "training",
				"layout_data": TRAINING_LAYOUT,
				"room_scene": PROTOTYPE_ROOM_SCENE,
				"enemy_scenes": [CHASER_ENEMY_SCENE],
				"enemy_names": PackedStringArray(["Chaser"]),
				"wave_enemy_counts": PackedInt32Array([2, 4]),
				"reward_scene": COIN_PICKUP_SCENE,
				"lock_doors_during_combat": true,
				"auto_clear_on_enter": false,
			}
		"combat_room":
			return {
				"id": "combat_room",
				"room_type": "combat",
				"template_id": "prototype_combat_room",
				"layout_profile": "crossfire",
				"layout_data": CROSSFIRE_LAYOUT,
				"room_scene": PROTOTYPE_ROOM_SCENE,
				"enemy_scenes": [CHASER_ENEMY_SCENE, SHOOTER_ENEMY_SCENE, BOMBER_ENEMY_SCENE],
				"enemy_names": PackedStringArray(["Chaser", "Shooter", "Bomber"]),
				"wave_enemy_counts": PackedInt32Array([3, 5]),
				"reward_scene": NORMAL_CHEST_SCENE,
				"lock_doors_during_combat": true,
				"auto_clear_on_enter": false,
			}
		"reward_room":
			return {
				"id": "reward_room",
				"room_type": "reward",
				"template_id": "prototype_combat_room",
				"layout_profile": "reward_cache",
				"layout_data": REWARD_CACHE_LAYOUT,
				"room_scene": PROTOTYPE_ROOM_SCENE,
				"enemy_scenes": [],
				"enemy_names": PackedStringArray(),
				"wave_enemy_counts": PackedInt32Array(),
				"reward_scene": RELIC_PICKUP_SCENE,
				"lock_doors_during_combat": false,
				"auto_clear_on_enter": true,
			}
		"armory_room":
			return {
				"id": "armory_room",
				"room_type": "armory",
				"template_id": "prototype_combat_room",
				"layout_profile": "reward_cache",
				"layout_data": REWARD_CACHE_LAYOUT,
				"room_scene": PROTOTYPE_ROOM_SCENE,
				"enemy_scenes": [],
				"enemy_names": PackedStringArray(),
				"wave_enemy_counts": PackedInt32Array(),
				"reward_scene": WEAPON_CHEST_SCENE,
				"lock_doors_during_combat": false,
				"auto_clear_on_enter": true,
			}
		"healing_room":
			return {
				"id": "healing_room",
				"room_type": "healing",
				"template_id": "prototype_combat_room",
				"layout_profile": "shrine",
				"layout_data": SHRINE_LAYOUT,
				"room_scene": PROTOTYPE_ROOM_SCENE,
				"enemy_scenes": [],
				"enemy_names": PackedStringArray(),
				"wave_enemy_counts": PackedInt32Array(),
				"reward_scene": HEALING_CHEST_SCENE,
				"lock_doors_during_combat": false,
				"auto_clear_on_enter": true,
			}
		"elite_room":
			return {
				"id": "elite_room",
				"room_type": "elite",
				"template_id": "prototype_combat_room",
				"layout_profile": "pillars",
				"layout_data": PILLARS_LAYOUT,
				"room_scene": PROTOTYPE_ROOM_SCENE,
				"enemy_scenes": [SHOOTER_ENEMY_SCENE, CHARGER_ENEMY_SCENE, SUMMONER_ENEMY_SCENE, SHIELD_ENEMY_SCENE, BOMBER_ENEMY_SCENE, CHASER_ENEMY_SCENE],
				"enemy_names": PackedStringArray(["Shooter", "Charger", "Summoner", "Shielded", "Bomber", "Chaser"]),
				"wave_enemy_counts": PackedInt32Array([4, 5]),
				"reward_scene": PREMIUM_CHEST_SCENE,
				"lock_doors_during_combat": true,
				"auto_clear_on_enter": false,
				"elite_enemies": true,
				"elite_health_multiplier": 1.65,
				"elite_damage_multiplier": 1.35,
				"elite_death_explosion_radius": 120.0,
				"elite_death_explosion_damage": 1,
			}
		"shop_room":
			return {
				"id": "shop_room",
				"room_type": "shop",
				"template_id": "prototype_combat_room",
				"layout_profile": "market",
				"layout_data": MARKET_LAYOUT,
				"room_scene": PROTOTYPE_ROOM_SCENE,
				"enemy_scenes": [],
				"enemy_names": PackedStringArray(),
				"wave_enemy_counts": PackedInt32Array(),
				"reward_scene": SHOP_INVENTORY_SCENE,
				"lock_doors_during_combat": false,
				"auto_clear_on_enter": true,
			}
		"boss_placeholder_room", "boss_room":
			return {
				"id": "boss_room",
				"room_type": "boss",
				"template_id": "prototype_combat_room",
				"layout_profile": "boss_arena",
				"layout_data": BOSS_ARENA_LAYOUT,
				"room_scene": PROTOTYPE_ROOM_SCENE,
				"enemy_scenes": [BOSS_ENEMY_SCENE],
				"enemy_names": PackedStringArray(["Dungeon Core"]),
				"wave_enemy_counts": PackedInt32Array([1]),
				"reward_scene": BOSS_REWARD_CHEST_SCENE,
				"lock_doors_during_combat": true,
				"auto_clear_on_enter": false,
			}
	return {}


func _get_room_data_key(room_data: Resource) -> String:
	if room_data == START_ROOM_DATA:
		return "start_room"
	if room_data == COMBAT_ROOM_DATA:
		return "combat_room"
	if room_data == REWARD_ROOM_DATA:
		return "reward_room"
	if room_data == ARMORY_ROOM_DATA:
		return "armory_room"
	if room_data == HEALING_ROOM_DATA:
		return "healing_room"
	if room_data == ELITE_ROOM_DATA:
		return "elite_room"
	if room_data == SHOP_ROOM_DATA:
		return "shop_room"
	if room_data == BOSS_PLACEHOLDER_ROOM_DATA:
		return "boss_placeholder_room"
	if room_data != null and not room_data.resource_path.is_empty():
		return room_data.resource_path.get_file().get_basename()
	return ""


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
		"armory":
			return "A"
		"healing":
			return "H"
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

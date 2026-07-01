extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	_verify_room_layout_library()

	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	if main.has_method("start_new_run"):
		main.call("start_new_run")

	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().create_timer(0.15).timeout

	var controller := main.get_node_or_null("DungeonController")
	_expect(controller != null, "Main scene should include DungeonController")
	if controller == null:
		_finish()
		return
	_expect(controller.has_method("regenerate_with_seed"), "DungeonController should expose seeded regeneration")
	_expect(controller.has_method("get_generation_seed"), "DungeonController should expose active generation seed")
	_expect(controller.has_method("get_debug_map_text"), "DungeonController should expose debug map text")
	if controller.has_method("regenerate_with_seed"):
		await _verify_seeded_generation(controller)

	var records: Array = controller.call("get_room_records")
	var combat_rooms: Array = controller.call("get_combat_rooms")
	var hud = main.get_node_or_null("CanvasLayer/HUD")
	var debug_map_text := ""
	if controller.has_method("get_debug_map_text"):
		debug_map_text = str(controller.call("get_debug_map_text"))
	var last_room_id := "Room%02d" % records.size()
	_expect(records.size() >= 10 and records.size() <= 14, "Dungeon should generate a variable 10-14 room route")
	_expect(combat_rooms.size() == records.size(), "Every generated room record should have one CombatRoom")
	_expect(int(controller.call("get_generation_seed")) == 424242, "Seeded generation should report the active seed")
	_expect(debug_map_text.contains("Seed: 424242"), "Debug map should include active seed")
	_expect(debug_map_text.contains("Grid:"), "Debug map should include a grid block")
	_expect(debug_map_text.contains("Room01"), "Debug map should list room ids")
	_expect(debug_map_text.contains(last_room_id), "Debug map should list final boss room id")
	_expect(records[0]["room_type"] == "start", "First generated room should be marked as start")
	_expect(records[records.size() - 1]["room_type"] == "boss", "Last generated room should be marked as boss")
	_expect(_has_room_type(records, "reward"), "Generated route should include a reward room")
	_expect(_has_room_type(records, "elite"), "Generated route should include an elite room")
	_expect(_has_room_type(records, "shop"), "Generated route should include a shop room")
	_expect(_get_first_record_by_type(records, "elite").get("elite_enemies", false), "Elite room record should enable elite enemies")
	_expect(_get_path_role_count(records, "main") >= 7 and _get_path_role_count(records, "main") <= 9, "Dungeon should vary main path length within first-version bounds")
	_expect(_get_path_role_count(records, "branch") >= 3 and _get_path_role_count(records, "branch") <= 5, "Dungeon should vary branch count within first-version bounds")
	_expect(_get_branch_anchor_count(records) >= 2, "Dungeon should attach branches to multiple main-path anchors")
	_expect(_get_unique_layout_profile_count(records) >= 8, "Generated route should include broad layout variety")
	_validate_connection_graph(records)

	for index in range(records.size()):
		_validate_room_record(records[index], index, combat_rooms)

	if hud != null and hud.has_method("get_minimap_marker_count"):
		_expect(hud.call("get_minimap_marker_count") == records.size(), "HUD minimap should render one marker per generated room")
	else:
		_expect(false, "HUD should expose minimap marker count for smoke tests")
	if hud != null and hud.has_method("get_minimap_seed_text") and hud.has_method("get_minimap_debug_text"):
		_expect(str(hud.call("get_minimap_seed_text")).contains("424242"), "HUD minimap should expose the active dungeon seed")
		_expect(str(hud.call("get_minimap_debug_text")).contains(last_room_id), "HUD debug tooltip should include dungeon map details")
	else:
		_expect(false, "HUD should expose dungeon seed and debug map text for smoke tests")
	if hud != null and hud.has_method("show_debug_map_panel") and hud.has_method("get_debug_map_panel_text"):
		hud.call("show_debug_map_panel")
		await get_tree().process_frame
		_expect(bool(hud.call("is_debug_map_visible")), "HUD should show the debug map panel")
		_expect(str(hud.call("get_debug_map_panel_text")).contains("Seed: 424242"), "Debug map panel should include active seed")
		_expect(str(hud.call("get_debug_map_panel_text")).contains(last_room_id), "Debug map panel should include final boss room id")
		_expect(bool(hud.call("copy_debug_map_to_clipboard")), "Debug map panel should expose copy-to-clipboard flow")
		hud.call("hide_debug_map_panel")
	else:
		_expect(false, "HUD should expose a debug map panel for playtest reproduction")

	await _verify_exploration_state(controller, combat_rooms, main.get_node("Player"), hud)

	_finish()


func _validate_room_record(record: Dictionary, index: int, combat_rooms: Array) -> void:
	var expected_id := "Room%02d" % (index + 1)
	var grid_position := record["grid_position"] as Vector2i
	var connections := record["connections"] as PackedStringArray
	var enemy_pool := record["enemy_pool"] as PackedStringArray
	var wave_counts := record["wave_counts"] as PackedInt32Array
	var room = combat_rooms[index]
	var room_type := str(record["room_type"])
	var layout_profile := str(record.get("layout_profile", ""))

	_expect(record["id"] == expected_id, "Generated room id should be sequential")
	_expect(int(record.get("generation_seed", 0)) == 424242, "%s should record active generation seed" % expected_id)
	_expect(record["template_id"] == "prototype_combat_room", "%s should use the prototype room template" % expected_id)
	_expect(str(record.get("path_role", "")).length() > 0, "%s should record its dungeon graph role" % expected_id)
	_expect(not layout_profile.is_empty(), "%s should define a layout profile" % expected_id)
	_expect(not connections.is_empty(), "%s should define at least one connection" % expected_id)
	_expect(room != null, "%s should have a CombatRoom instance" % expected_id)
	if room != null:
		_expect(room.get_parent().name == expected_id, "%s instance name should match record id" % expected_id)
		_expect(str(room.get("layout_profile")) == layout_profile, "%s runtime layout profile should match metadata" % expected_id)
		_expect(room.get("layout_data") is Resource, "%s should receive layout data resource" % expected_id)
		_expect(_get_layout_obstacle_count(room) == _expected_layout_obstacle_count(room), "%s should create expected layout obstacles for %s" % [expected_id, layout_profile])
		_expect(room.get("enemy_scenes").size() == enemy_pool.size(), "%s enemy scene count should match metadata" % expected_id)
		_expect(room.get("wave_enemy_counts") == wave_counts, "%s wave counts should match metadata" % expected_id)
		_expect(room.global_position == Vector2(1320.0 * grid_position.x, 820.0 * grid_position.y), "%s should be placed from its grid position" % expected_id)
		_expect(room.get("connected_directions") == connections, "%s runtime connections should match metadata" % expected_id)
		_expect(room.get("auto_clear_on_enter") == record["auto_clear"], "%s auto-clear config should match metadata" % expected_id)
		_expect(room.get("lock_doors_during_combat") == record["locks_doors"], "%s door-lock config should match metadata" % expected_id)

	if room_type == "reward" or room_type == "shop":
		_expect(str(record.get("path_role", "")) == "branch", "%s %s room should be generated as a branch room" % [expected_id, room_type])
		_expect(int(record.get("branch_of", -1)) >= 1, "%s %s room should record its main-path anchor" % [expected_id, room_type])
		_expect(enemy_pool.is_empty(), "%s %s room should not define enemy pool metadata" % [expected_id, room_type])
		_expect(wave_counts.is_empty(), "%s %s room should not define wave count metadata" % [expected_id, room_type])
		_expect(record["auto_clear"], "%s %s room should auto-clear on enter" % [expected_id, room_type])
		_expect(not record["locks_doors"], "%s %s room should not lock doors" % [expected_id, room_type])
	else:
		_expect(not enemy_pool.is_empty(), "%s should define enemy pool metadata" % expected_id)
		_expect(not wave_counts.is_empty(), "%s should define wave count metadata" % expected_id)
		_expect(record["locks_doors"], "%s combat-like room should lock doors" % expected_id)
		if room_type == "elite":
			_expect(record["elite_enemies"], "%s elite room should mark elite enemy spawning" % expected_id)

	_expect(record["has_reward"], "%s should define a reward scene" % expected_id)


func _verify_exploration_state(controller: Node, combat_rooms: Array, player: Player, hud: Node) -> void:
	if combat_rooms.is_empty():
		return

	var first_room = combat_rooms[0]
	await _enter_room(first_room, player)

	var records: Array = controller.call("get_room_records")
	_expect(records[0]["visited"], "Entering first room should mark it visited")
	_expect(records[0]["current"], "Entering first room should mark it current")
	_expect(controller.call("get_current_room_id") == "Room01", "Controller current room should become Room01")
	if hud != null and hud.has_method("get_minimap_current_room_id"):
		_expect(hud.call("get_minimap_current_room_id") == "Room01", "HUD minimap should track current room")

	var wave_counts: PackedInt32Array = first_room.get("wave_enemy_counts")
	for _wave_index in range(wave_counts.size()):
		_kill_all_enemies()
		await get_tree().create_timer(first_room.get("time_between_waves") + 0.2).timeout
		await get_tree().physics_frame

	records = controller.call("get_room_records")
	_expect(records[0]["cleared"], "Clearing first room should mark it cleared in dungeon records")

	await _verify_reward_room_state(controller, combat_rooms, player)


func _verify_reward_room_state(controller: Node, combat_rooms: Array, player: Player) -> void:
	var records: Array = controller.call("get_room_records")
	for index in range(records.size()):
		if str(records[index]["room_type"]) != "reward":
			continue

		var room = combat_rooms[index]
		await _enter_room(room, player)
		await get_tree().process_frame
		await get_tree().physics_frame
		records = controller.call("get_room_records")
		_expect(records[index]["visited"], "Entering reward room should mark it visited")
		_expect(records[index]["cleared"], "Reward room should auto-clear after entry")
		_expect(room.doors_are_unlocked(), "Reward room doors should remain unlocked")
		_expect(_enemy_count_near(room.global_position) == 0, "Reward room should not spawn local enemies")
		return

	_expect(false, "Reward room should be present for reward room state verification")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _verify_seeded_generation(controller: Node) -> void:
	await _regenerate_with_seed(controller, 424242)
	var signature_a := _route_signature(controller.call("get_room_records"))
	await _regenerate_with_seed(controller, 424242)
	var signature_b := _route_signature(controller.call("get_room_records"))
	_expect(signature_a == signature_b, "Dungeon generation should be reproducible with the same seed")
	await _regenerate_with_seed(controller, 424243)
	var signature_c := _route_signature(controller.call("get_room_records"))
	_expect(signature_a != signature_c, "Dungeon generation should vary with a different seed")
	await _regenerate_with_seed(controller, 424242)


func _regenerate_with_seed(controller: Node, seed: int) -> void:
	controller.call("regenerate_with_seed", seed)
	await get_tree().process_frame
	await get_tree().physics_frame


func _route_signature(records: Array) -> String:
	var parts := PackedStringArray()
	for record in records:
		if not record is Dictionary:
			continue
		var grid_position := record["grid_position"] as Vector2i
		var connections := record["connections"] as PackedStringArray
		var sorted_connections := Array(connections)
		sorted_connections.sort()
		parts.append("%s:%s:%d,%d:%s" % [
			str(record.get("room_type", "")),
			str(record.get("layout_profile", "")),
			grid_position.x,
			grid_position.y,
			"|".join(sorted_connections),
		])
	return ";".join(parts)


func _has_room_type(records: Array, room_type: String) -> bool:
	for record in records:
		if record is Dictionary and str(record.get("room_type", "")) == room_type:
			return true
	return false


func _get_first_record_by_type(records: Array, room_type: String) -> Dictionary:
	for record in records:
		if record is Dictionary and str(record.get("room_type", "")) == room_type:
			return record
	return {}


func _get_path_role_count(records: Array, role_name: String) -> int:
	var count := 0
	for record in records:
		if record is Dictionary and str(record.get("path_role", "")) == role_name:
			count += 1
	return count


func _get_branch_anchor_count(records: Array) -> int:
	var anchors := {}
	for record in records:
		if record is Dictionary and str(record.get("path_role", "")) == "branch":
			anchors[int(record.get("branch_of", -1))] = true
	return anchors.size()


func _verify_room_layout_library() -> void:
	var dir := DirAccess.open("res://resources/room_layouts")
	_expect(dir != null, "Room layout resource directory should exist")
	if dir == null:
		return

	var layout_ids := {}
	var layout_count := 0
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			layout_count += 1
			var layout := load(("res:/" + "/resources/room_layouts/%s") % file_name)
			_expect(layout is Resource, "Room layout %s should load as a resource" % file_name)
			if layout is Resource:
				var layout_id := str(layout.get("id"))
				_expect(not layout_id.is_empty(), "Room layout %s should define id" % file_name)
				_expect(not layout_ids.has(layout_id), "Room layout id should be unique: %s" % layout_id)
				layout_ids[layout_id] = true
				var spawn_positions = layout.get("spawn_positions")
				var obstacle_positions = layout.get("obstacle_positions")
				var obstacle_sizes = layout.get("obstacle_sizes")
				_expect(spawn_positions != null and spawn_positions.size() >= 4, "Room layout %s should define at least 4 spawn positions" % layout_id)
				_expect(obstacle_positions != null and obstacle_sizes != null, "Room layout %s should define obstacle arrays" % layout_id)
				if obstacle_positions != null and obstacle_sizes != null:
					_expect(obstacle_positions.size() == obstacle_sizes.size(), "Room layout %s obstacle positions and sizes should match" % layout_id)
		file_name = dir.get_next()
	dir.list_dir_end()

	_expect(layout_count >= 20, "Room layout library should contain at least 20 layout resources")
	_expect(layout_ids.has("training"), "Room layout library should include training")
	_expect(layout_ids.has("crossfire"), "Room layout library should include crossfire")
	_expect(layout_ids.has("reward_cache"), "Room layout library should include reward_cache")
	_expect(layout_ids.has("pillars"), "Room layout library should include pillars")
	_expect(layout_ids.has("market"), "Room layout library should include market")
	_expect(layout_ids.has("boss_arena"), "Room layout library should include boss_arena")


func _get_unique_layout_profile_count(records: Array) -> int:
	var profiles := {}
	for record in records:
		if record is Dictionary:
			var profile := str(record.get("layout_profile", ""))
			if not profile.is_empty():
				profiles[profile] = true
	return profiles.size()


func _validate_connection_graph(records: Array) -> void:
	var records_by_grid := {}
	for record in records:
		if not record is Dictionary:
			continue
		var grid_position := record["grid_position"] as Vector2i
		_expect(not records_by_grid.has(grid_position), "Dungeon grid positions should be unique")
		records_by_grid[grid_position] = record

	var has_vertical_connection := false
	for record in records:
		if not record is Dictionary:
			continue
		var grid_position := record["grid_position"] as Vector2i
		var connections := record["connections"] as PackedStringArray
		for direction in connections:
			var neighbor_position := grid_position + _direction_to_offset(direction)
			var opposite := _opposite_direction(direction)
			_expect(records_by_grid.has(neighbor_position), "%s connection %s should lead to another room" % [record["id"], direction])
			if records_by_grid.has(neighbor_position):
				var neighbor: Dictionary = records_by_grid[neighbor_position]
				var neighbor_connections := neighbor["connections"] as PackedStringArray
				_expect(neighbor_connections.has(opposite), "%s connection %s should be reciprocated by %s" % [record["id"], direction, neighbor["id"]])
			if direction == "north" or direction == "south":
				has_vertical_connection = true

	_expect(has_vertical_connection, "Dungeon route should include at least one vertical branch")
	_expect(_is_boss_reachable(records_by_grid, records[0]["grid_position"], records[records.size() - 1]["grid_position"]), "Boss room should be reachable from start")


func _is_boss_reachable(records_by_grid: Dictionary, start_position: Vector2i, boss_position: Vector2i) -> bool:
	var frontier: Array[Vector2i] = [start_position]
	var visited := {}
	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		if current == boss_position:
			return true
		if visited.has(current):
			continue
		visited[current] = true
		var record: Dictionary = records_by_grid[current]
		var connections := record["connections"] as PackedStringArray
		for direction in connections:
			var next_position := current + _direction_to_offset(direction)
			if records_by_grid.has(next_position) and not visited.has(next_position):
				frontier.append(next_position)
	return false


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


func _get_layout_obstacle_count(room: Node) -> int:
	var obstacle_parent := room.get_node_or_null("LayoutObstacles")
	if obstacle_parent == null:
		return 0
	return obstacle_parent.get_child_count()


func _expected_layout_obstacle_count(room: Node) -> int:
	var layout_data = room.get("layout_data")
	if layout_data is Resource:
		var positions = layout_data.get("obstacle_positions")
		var sizes = layout_data.get("obstacle_sizes")
		if positions != null and sizes != null:
			return mini(positions.size(), sizes.size())
	return 0


func _enter_room(room: Node, player: Player) -> void:
	player.global_position = room.global_position + Vector2(-700, 0)
	await get_tree().physics_frame
	await get_tree().process_frame
	player.global_position = room.global_position
	for index in range(4):
		await get_tree().physics_frame
		await get_tree().process_frame


func _kill_all_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy) and enemy.has_method("apply_damage"):
			enemy.call("apply_damage", 9999)


func _enemy_count_near(position: Vector2) -> int:
	var count := 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		if enemy.has_method("is_dead") and enemy.call("is_dead"):
			continue
		var enemy_node := enemy as Node2D
		if enemy_node == null or enemy_node.global_position.distance_to(position) > 500.0:
			continue
		count += 1
	return count


func _finish() -> void:
	if _failures.is_empty():
		print("DungeonGenerationSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const TOTAL_BIOMES := 3
const MIN_ROUTE_ROOMS := 39
const MAX_ROUTE_ROOMS := 45
const MIN_MAIN_ROOMS := 21
const MAX_MAIN_ROOMS := 27
const MIN_BRANCH_ROOMS := 15
const MAX_BRANCH_ROOMS := 18
const EXPECTED_BIOME_NAMES := ["Outer Warrens", "Iron Catacombs", "Void Foundry"]
const EXPECTED_BOSS_NAMES := ["Warrens Gatekeeper", "Iron Bulwark", "Void Foundry Heart"]

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
	var biome_summaries: Array = []
	if controller.has_method("get_biome_summaries"):
		biome_summaries = controller.call("get_biome_summaries")
	else:
		_expect(false, "DungeonController should expose biome summaries")
	var hud = main.get_node_or_null("CanvasLayer/HUD")
	var debug_map_text := ""
	if controller.has_method("get_debug_map_text"):
		debug_map_text = str(controller.call("get_debug_map_text"))
	var last_room_id := "Room%02d" % records.size()
	_expect(records.size() >= MIN_ROUTE_ROOMS and records.size() <= MAX_ROUTE_ROOMS, "Dungeon should generate a three-biome 39-45 room route")
	_expect(combat_rooms.size() == records.size(), "Every generated room record should have one CombatRoom")
	_expect(controller.has_method("get_total_biomes") and int(controller.call("get_total_biomes")) == TOTAL_BIOMES, "Dungeon should expose three total biomes")
	_expect(biome_summaries.size() == TOTAL_BIOMES, "Dungeon should create three biome summaries")
	_expect(int(controller.call("get_generation_seed")) == 424242, "Seeded generation should report the active seed")
	_expect(debug_map_text.contains("Seed: 424242"), "Debug map should include active seed")
	_expect(debug_map_text.contains("Biomes:"), "Debug map should include biome summary block")
	_expect(debug_map_text.contains("Outer Warrens"), "Debug map should list first biome")
	_expect(debug_map_text.contains("Iron Catacombs"), "Debug map should list second biome")
	_expect(debug_map_text.contains("Void Foundry"), "Debug map should list final biome")
	_expect(debug_map_text.contains("Grid:"), "Debug map should include a grid block")
	_expect(debug_map_text.contains("Room01"), "Debug map should list room ids")
	_expect(debug_map_text.contains(last_room_id), "Debug map should list final boss room id")
	_expect(records[0]["room_type"] == "start", "First generated room should be marked as start")
	_expect(records[records.size() - 1]["room_type"] == "boss", "Last generated room should be marked as boss")
	_expect(records[records.size() - 1].get("is_final_boss", false) == true, "Last generated boss should be marked final")
	_expect(_get_room_type_count(records, "start") == TOTAL_BIOMES, "Each biome should have one start room")
	_expect(_get_room_type_count(records, "boss") == TOTAL_BIOMES, "Each biome should have one boss room")
	_expect(_get_boss_names(records) == EXPECTED_BOSS_NAMES, "Each biome should use its configured boss identity")
	_expect(_get_room_type_count(records, "event") == TOTAL_BIOMES, "Each biome should have one event room")
	_expect(_has_room_type(records, "trap"), "Generated route should include a trap room branch")
	_expect(_get_final_boss_count(records) == 1, "Only one boss should be marked as final")
	_expect(_get_boss_completion_flag_count(records) == 1, "Only final boss reward should complete the run")
	_expect(_has_room_type(records, "reward"), "Generated route should include a reward room")
	_expect(_has_room_type(records, "event"), "Generated route should include an event room")
	_expect(_has_room_type(records, "armory"), "Generated route should include an armory room")
	_expect(_has_room_type(records, "healing"), "Generated route should include a healing room")
	_expect(_has_room_type(records, "elite"), "Generated route should include an elite room")
	_expect(_has_room_type(records, "shop"), "Generated route should include a shop room")
	_expect(_get_first_record_by_type(records, "elite").get("elite_enemies", false), "Elite room record should enable elite enemies")
	_expect(_get_path_role_count(records, "main") >= MIN_MAIN_ROOMS and _get_path_role_count(records, "main") <= MAX_MAIN_ROOMS, "Dungeon should vary three-biome main path length within configured bounds")
	_expect(_get_path_role_count(records, "branch") >= MIN_BRANCH_ROOMS and _get_path_role_count(records, "branch") <= MAX_BRANCH_ROOMS, "Dungeon should vary three-biome branch count within configured bounds")
	_expect(_get_branch_anchor_count(records) >= 2, "Dungeon should attach branches to multiple main-path anchors")
	_expect(_get_unique_layout_profile_count(records) >= 8, "Generated route should include broad layout variety")
	_validate_biome_summaries(records, biome_summaries)
	_validate_biome_layout_pool_usage(records)
	_validate_connection_graph(records)

	for index in range(records.size()):
		_validate_room_record(records[index], index, combat_rooms)

	if hud != null and hud.has_method("get_minimap_marker_count"):
		_expect(hud.call("get_minimap_marker_count") == records.size(), "HUD minimap should render one marker per generated room")
	else:
		_expect(false, "HUD should expose minimap marker count for smoke tests")
	_verify_minimap_marker_contract(hud, records)
	if hud != null and hud.has_method("get_minimap_seed_text") and hud.has_method("get_minimap_debug_text"):
		_expect(str(hud.call("get_minimap_seed_text")).contains("424242"), "HUD minimap should expose the active dungeon seed")
		_expect(str(hud.call("get_minimap_debug_text")).contains(last_room_id), "HUD debug tooltip should include dungeon map details")
		_expect(str(hud.call("get_minimap_debug_text")).contains("Biomes:"), "HUD debug tooltip should include biome details")
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


func _verify_minimap_marker_contract(hud: Node, records: Array) -> void:
	if hud == null:
		_expect(false, "HUD should exist for minimap marker contract checks")
		return
	if (
		not hud.has_method("get_minimap_marker_icon_for_type")
		or not hud.has_method("get_minimap_marker_icon_key_for_type")
		or not hud.has_method("get_minimap_marker_texture_path_for_type")
		or not hud.has_method("get_minimap_marker_texture_visible_for_type")
		or not hud.has_method("get_minimap_marker_label_for_type")
		or not hud.has_method("get_minimap_marker_tooltip_for_type")
		or not hud.has_method("get_minimap_biome_layer_count")
		or not hud.has_method("get_minimap_marker_count_for_biome")
		or not hud.has_method("get_minimap_biome_layer_text")
		or not hud.has_method("get_minimap_biome_layer_tooltip")
	):
		_expect(false, "HUD should expose minimap marker, biome layer, and tooltip test accessors")
		return

	_expect(int(hud.call("get_minimap_biome_layer_count")) == TOTAL_BIOMES, "HUD minimap should render one layer group per biome")
	for biome_index in range(1, TOTAL_BIOMES + 1):
		var layer_text := str(hud.call("get_minimap_biome_layer_text", biome_index))
		var layer_tooltip := str(hud.call("get_minimap_biome_layer_tooltip", biome_index))
		_expect(layer_text.contains("L%d" % biome_index), "Minimap biome layer %d should expose layer number" % biome_index)
		_expect(layer_text.contains(EXPECTED_BIOME_NAMES[biome_index - 1]), "Minimap biome layer %d should expose biome display name" % biome_index)
		_expect(layer_tooltip.contains(EXPECTED_BIOME_NAMES[biome_index - 1]), "Minimap biome layer %d tooltip should include biome display name" % biome_index)
		_expect(int(hud.call("get_minimap_marker_count_for_biome", biome_index)) == _get_record_biome_count(records, biome_index), "Minimap biome layer %d should contain only its generated room markers" % biome_index)

	var expected_markers := {
		"start": ["S", "Start Room", "room_start", "room_start.svg"],
		"combat": ["C", "Combat Room", "room_combat", "room_combat.svg"],
		"elite": ["EL", "Elite Room", "room_elite", "room_elite.svg"],
		"challenge": ["CH", "Challenge Room", "room_challenge", "room_challenge.svg"],
		"trap": ["X", "Trap Room", "room_trap", "room_trap.svg"],
		"reward": ["*", "Reward Room", "room_reward", "room_reward.svg"],
		"event": ["!", "Event Room", "room_event", "room_event.svg"],
		"armory": ["W", "Armory", "room_armory", "room_armory.svg"],
		"healing": ["+", "Healing Room", "room_healing", "room_healing.svg"],
		"shop": ["$", "Shop", "room_shop", "room_shop.svg"],
		"boss": ["B", "Boss Room", "room_boss", "room_boss.svg"],
	}
	for room_type in expected_markers.keys():
		if not _has_room_type(records, room_type):
			continue
		var expected: Array = expected_markers[room_type]
		var icon := str(hud.call("get_minimap_marker_icon_for_type", room_type))
		var icon_key := str(hud.call("get_minimap_marker_icon_key_for_type", room_type))
		var texture_path := str(hud.call("get_minimap_marker_texture_path_for_type", room_type))
		var texture_visible := bool(hud.call("get_minimap_marker_texture_visible_for_type", room_type))
		var label := str(hud.call("get_minimap_marker_label_for_type", room_type))
		var tooltip := str(hud.call("get_minimap_marker_tooltip_for_type", room_type))
		_expect(icon == str(expected[0]), "Minimap %s marker should use stable room icon token" % room_type)
		_expect(label == str(expected[1]), "Minimap %s marker should expose player-facing room label" % room_type)
		_expect(icon_key == str(expected[2]), "Minimap %s marker should expose stable content icon key" % room_type)
		_expect(texture_path.begins_with("res:" + "//art/ui/content_icons/"), "Minimap %s marker should expose a content icon texture path" % room_type)
		_expect(texture_path.ends_with(str(expected[3])), "Minimap %s marker should point at its room SVG icon" % room_type)
		_expect(texture_visible, "Minimap %s marker should render its room SVG texture" % room_type)
		_expect(tooltip.contains(str(expected[1])), "Minimap %s tooltip should include player-facing room label" % room_type)
		_expect(tooltip.contains("L"), "Minimap %s tooltip should include biome context" % room_type)


func _validate_room_record(record: Dictionary, index: int, combat_rooms: Array) -> void:
	var expected_id := "Room%02d" % (index + 1)
	var grid_position := record["grid_position"] as Vector2i
	var connections := record["connections"] as PackedStringArray
	var enemy_pool := record["enemy_pool"] as PackedStringArray
	var wave_counts := record["wave_counts"] as PackedInt32Array
	var room = combat_rooms[index]
	var room_type := str(record["room_type"])
	var layout_profile := str(record.get("layout_profile", ""))
	var biome_layout_pool_ids := record.get("biome_layout_pool_ids", PackedStringArray()) as PackedStringArray
	var biome_reward_weight_multiplier := float(record.get("biome_reward_weight_multiplier", 0.0))

	_expect(record["id"] == expected_id, "Generated room id should be sequential")
	_expect(int(record.get("generation_seed", 0)) == 424242, "%s should record active generation seed" % expected_id)
	_expect(record["template_id"] == "prototype_combat_room", "%s should use the prototype room template" % expected_id)
	_expect(str(record.get("path_role", "")).length() > 0, "%s should record its dungeon graph role" % expected_id)
	_expect(str(record.get("run_graph_id", "")) == "standard_three_biome_run", "%s should record active run graph id" % expected_id)
	_expect(int(record.get("biome_index", 0)) >= 1 and int(record.get("biome_index", 0)) <= TOTAL_BIOMES, "%s should record biome index" % expected_id)
	_expect(not str(record.get("biome_id", "")).is_empty(), "%s should record biome id" % expected_id)
	_expect(not str(record.get("biome_name", "")).is_empty(), "%s should record biome name" % expected_id)
	_expect(not str(record.get("biome_color_key", "")).is_empty(), "%s should record biome visual color key" % expected_id)
	_expect(typeof(record.get("biome_visual_floor_tint")) == TYPE_COLOR, "%s should record biome floor visual tint" % expected_id)
	_expect(str(record.get("biome_music_key", "")).begins_with("biome_"), "%s should record biome music key" % expected_id)
	_expect(str(record.get("biome_visual_floor_texture_path", "")).begins_with("res://art/terrain/"), "%s should record biome floor texture path" % expected_id)
	_expect(typeof(record.get("biome_visual_floor_texture_modulate")) == TYPE_COLOR, "%s should record biome floor texture modulation" % expected_id)
	_expect(float(record.get("biome_visual_floor_texture_opacity", 0.0)) > 0.0, "%s should record active biome floor texture opacity" % expected_id)
	_expect(typeof(record.get("biome_visual_wall_color")) == TYPE_COLOR, "%s should record biome wall visual color" % expected_id)
	_expect(typeof(record.get("biome_visual_obstacle_tint")) == TYPE_COLOR, "%s should record biome obstacle visual tint" % expected_id)
	_expect(str(record.get("biome_visual_surface_atlas_path", "")).ends_with("_surface_atlas.svg"), "%s should record biome surface atlas path" % expected_id)
	_expect(str(record.get("biome_visual_trim_atlas_path", "")).ends_with("_trim_atlas.svg"), "%s should record biome trim atlas path" % expected_id)
	_expect(typeof(record.get("biome_visual_trim_texture_modulate")) == TYPE_COLOR, "%s should record trim texture modulation" % expected_id)
	_expect(float(record.get("biome_visual_trim_texture_opacity", 0.0)) > 0.0, "%s should record active trim texture opacity" % expected_id)
	_expect(typeof(record.get("biome_visual_wall_texture_modulate")) == TYPE_COLOR, "%s should record wall texture modulation" % expected_id)
	_expect(float(record.get("biome_visual_wall_texture_opacity", 0.0)) > 0.0, "%s should record active wall texture opacity" % expected_id)
	_expect(typeof(record.get("biome_visual_obstacle_texture_modulate")) == TYPE_COLOR, "%s should record obstacle texture modulation" % expected_id)
	_expect(float(record.get("biome_visual_obstacle_texture_opacity", 0.0)) > 0.0, "%s should record active obstacle texture opacity" % expected_id)
	_expect(typeof(record.get("biome_visual_accent_color")) == TYPE_COLOR, "%s should record biome accent visual color" % expected_id)
	_expect(float(record.get("biome_visual_tint_strength", 0.0)) > 0.0, "%s should record active biome visual tint strength" % expected_id)
	_expect(biome_layout_pool_ids.size() >= 4, "%s should record biome layout pool ids" % expected_id)
	_expect(is_equal_approx(biome_reward_weight_multiplier, _expected_biome_reward_weight_multiplier(int(record.get("biome_index", 0)))), "%s should record biome reward weight multiplier" % expected_id)
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
		_validate_directional_door_geometry(room, connections, expected_id)
		_expect(room.get("auto_clear_on_enter") == record["auto_clear"], "%s auto-clear config should match metadata" % expected_id)
		_expect(room.get("lock_doors_during_combat") == record["locks_doors"], "%s door-lock config should match metadata" % expected_id)
		_expect(is_equal_approx(float(room.get("biome_reward_weight_multiplier")), biome_reward_weight_multiplier), "%s runtime reward weight multiplier should match metadata" % expected_id)
		_expect(str(room.get("biome_music_key")) == str(record.get("biome_music_key", "")), "%s runtime music key should match metadata" % expected_id)
		_expect(room.has_method("get_biome_visual_summary"), "%s should expose runtime biome visual summary" % expected_id)
		if room.has_method("get_biome_visual_summary"):
			var visual_summary: Dictionary = room.call("get_biome_visual_summary")
			_expect(str(visual_summary.get("biome_id", "")) == str(record.get("biome_id", "")), "%s runtime biome visual id should match metadata" % expected_id)
			_expect(str(visual_summary.get("color_key", "")) == str(record.get("biome_color_key", "")), "%s runtime biome color key should match metadata" % expected_id)
			_expect(str(visual_summary.get("music_key", "")) == str(record.get("biome_music_key", "")), "%s runtime biome music key should match metadata" % expected_id)
			_expect(_as_color(visual_summary.get("floor_tint")) == _as_color(record.get("biome_visual_floor_tint")), "%s runtime floor tint should match metadata" % expected_id)
			_expect(str(visual_summary.get("floor_texture_path", "")) == str(record.get("biome_visual_floor_texture_path", "")), "%s runtime floor texture should match metadata" % expected_id)
			_expect(_as_color(visual_summary.get("floor_texture_modulate")) == _as_color(record.get("biome_visual_floor_texture_modulate")), "%s runtime floor texture modulation should match metadata" % expected_id)
			_expect(is_equal_approx(float(visual_summary.get("floor_texture_opacity", 0.0)), float(record.get("biome_visual_floor_texture_opacity", 0.0))), "%s runtime floor texture opacity should match metadata" % expected_id)
			var terrain_summary := visual_summary.get("terrain_layer", {}) as Dictionary
			_expect(bool(terrain_summary.get("texture_loaded", false)), "%s terrain layer should load its biome texture" % expected_id)
			_expect(str(terrain_summary.get("texture_path", "")) == str(record.get("biome_visual_floor_texture_path", "")), "%s terrain layer should expose its configured path" % expected_id)
			_expect(terrain_summary.get("texture_size", Vector2.ZERO) == Vector2(512.0, 512.0), "%s terrain layer should expose optimized source size" % expected_id)
			_expect(bool(terrain_summary.get("repeat_enabled", false)), "%s terrain layer should enable texture repetition" % expected_id)
			_expect(bool(terrain_summary.get("nearest_filter", false)), "%s terrain layer should preserve pixel edges" % expected_id)
			_expect(_as_color(visual_summary.get("wall_color")) == _as_color(record.get("biome_visual_wall_color")), "%s runtime wall color should match metadata" % expected_id)
			_expect(_as_color(visual_summary.get("obstacle_tint")) == _as_color(record.get("biome_visual_obstacle_tint")), "%s runtime obstacle tint should match metadata" % expected_id)
			_expect(str(visual_summary.get("surface_atlas_path", "")) == str(record.get("biome_visual_surface_atlas_path", "")), "%s runtime surface atlas should match metadata" % expected_id)
			_expect(str(visual_summary.get("trim_atlas_path", "")) == str(record.get("biome_visual_trim_atlas_path", "")), "%s runtime trim atlas should match metadata" % expected_id)
			_expect(_as_color(visual_summary.get("trim_texture_modulate")) == _as_color(record.get("biome_visual_trim_texture_modulate")), "%s runtime trim modulation should match metadata" % expected_id)
			_expect(is_equal_approx(float(visual_summary.get("trim_texture_opacity", 0.0)), float(record.get("biome_visual_trim_texture_opacity", 0.0))), "%s runtime trim opacity should match metadata" % expected_id)
			var trim_summary := visual_summary.get("trim_layer", {}) as Dictionary
			_expect(bool(trim_summary.get("atlas_loaded", false)), "%s trim layer should load its biome atlas" % expected_id)
			_expect(trim_summary.get("atlas_size", Vector2.ZERO) == Vector2(512.0, 512.0), "%s trim layer should expose four 256px regions" % expected_id)
			_expect(str(trim_summary.get("atlas_path", "")) == str(record.get("biome_visual_trim_atlas_path", "")), "%s trim layer should expose its configured atlas" % expected_id)
			_expect(int(trim_summary.get("corner_count", 0)) == 4, "%s trim layer should draw all four room corners" % expected_id)
			_expect(int(trim_summary.get("door_frame_count", -1)) == connections.size(), "%s trim layer should draw one frame per connected door" % expected_id)
			_expect(int(trim_summary.get("threshold_count", -1)) == connections.size(), "%s trim layer should draw one threshold per connected door" % expected_id)
			_expect(int(trim_summary.get("draw_item_count", 0)) == 4 + connections.size() * 2, "%s trim layer draw count should match corners plus connected doors" % expected_id)
			_expect(bool(trim_summary.get("nearest_filter", false)), "%s trim layer should preserve pixel edges" % expected_id)
			_expect(_as_color(visual_summary.get("wall_texture_modulate")) == _as_color(record.get("biome_visual_wall_texture_modulate")), "%s runtime wall texture modulation should match metadata" % expected_id)
			_expect(is_equal_approx(float(visual_summary.get("wall_texture_opacity", 0.0)), float(record.get("biome_visual_wall_texture_opacity", 0.0))), "%s runtime wall texture opacity should match metadata" % expected_id)
			_expect(_as_color(visual_summary.get("obstacle_texture_modulate")) == _as_color(record.get("biome_visual_obstacle_texture_modulate")), "%s runtime obstacle texture modulation should match metadata" % expected_id)
			_expect(is_equal_approx(float(visual_summary.get("obstacle_texture_opacity", 0.0)), float(record.get("biome_visual_obstacle_texture_opacity", 0.0))), "%s runtime obstacle texture opacity should match metadata" % expected_id)
			var wall_surface := visual_summary.get("wall_surface", {}) as Dictionary
			_expect(bool(wall_surface.get("atlas_loaded", false)), "%s wall surface should load its biome atlas" % expected_id)
			_expect(str(wall_surface.get("atlas_path", "")) == str(record.get("biome_visual_surface_atlas_path", "")), "%s wall surface should expose its configured atlas" % expected_id)
			_expect(wall_surface.get("atlas_size", Vector2.ZERO) == Vector2(512.0, 256.0), "%s wall surface should expose the two-region atlas size" % expected_id)
			_expect(str(wall_surface.get("surface_kind", "")) == "wall", "%s wall surface should use the wall atlas region" % expected_id)
			_expect(wall_surface.get("atlas_region", Rect2()) == Rect2(0.0, 0.0, 256.0, 256.0), "%s wall surface should use the left atlas region" % expected_id)
			_expect(bool(wall_surface.get("repeat_enabled", false)), "%s wall surface should repeat its atlas region" % expected_id)
			_expect(bool(wall_surface.get("manual_region_tiling", false)), "%s wall surface should isolate its atlas region while tiling" % expected_id)
			_expect(bool(wall_surface.get("nearest_filter", false)), "%s wall surface should preserve pixel edges" % expected_id)
			var obstacle_surface := visual_summary.get("obstacle_surface", {}) as Dictionary
			if _get_layout_obstacle_count(room) > 0:
				_expect(bool(obstacle_surface.get("atlas_loaded", false)), "%s obstacle surface should load its biome atlas" % expected_id)
				_expect(str(obstacle_surface.get("surface_kind", "")) == "obstacle", "%s obstacle surface should use the obstacle atlas region" % expected_id)
				_expect(obstacle_surface.get("atlas_region", Rect2()) == Rect2(256.0, 0.0, 256.0, 256.0), "%s obstacle surface should use the right atlas region" % expected_id)
				_expect(bool(obstacle_surface.get("repeat_enabled", false)), "%s obstacle surface should repeat its atlas region" % expected_id)
				_expect(bool(obstacle_surface.get("manual_region_tiling", false)), "%s obstacle surface should isolate its atlas region while tiling" % expected_id)
				_expect(bool(obstacle_surface.get("nearest_filter", false)), "%s obstacle surface should preserve pixel edges" % expected_id)
			_expect(_as_color(visual_summary.get("accent_color")) == _as_color(record.get("biome_visual_accent_color")), "%s runtime accent color should match metadata" % expected_id)
			_expect(is_equal_approx(float(visual_summary.get("tint_strength", 0.0)), float(record.get("biome_visual_tint_strength", 0.0))), "%s runtime tint strength should match metadata" % expected_id)
			_expect(_as_color(visual_summary.get("first_wall_color")) == _as_color(record.get("biome_visual_wall_color")), "%s arena wall color should use biome visual theme" % expected_id)
			var runtime_layout = room.get("layout_data")
			if runtime_layout is Resource and runtime_layout.get("floor_color") is Color:
				var base_floor: Color = runtime_layout.get("floor_color")
				var floor_tint := _as_color(record.get("biome_visual_floor_tint"))
				var expected_floor := base_floor.lerp(floor_tint, clampf(float(record.get("biome_visual_tint_strength", 0.0)), 0.0, 1.0))
				expected_floor.a = base_floor.a
				_expect(_as_color(visual_summary.get("floor_color")).is_equal_approx(expected_floor), "%s floor color should apply biome visual tint to layout floor" % expected_id)
		_expect(room.has_method("get_biome_reward_summary"), "%s should expose runtime biome reward summary" % expected_id)
		if room.has_method("get_biome_reward_summary"):
			var reward_summary: Dictionary = room.call("get_biome_reward_summary")
			_expect(str(reward_summary.get("biome_id", "")) == str(record.get("biome_id", "")), "%s runtime reward biome id should match metadata" % expected_id)
			_expect(is_equal_approx(float(reward_summary.get("reward_weight_multiplier", 0.0)), biome_reward_weight_multiplier), "%s runtime reward weight multiplier should match metadata" % expected_id)
		if room_type == "boss":
			_expect(room.get("complete_run_on_reward") == record["boss_reward_completes_run"], "%s boss reward completion flag should match metadata" % expected_id)

	if room_type in ["reward", "event", "trap", "armory", "healing", "shop"]:
		_expect(str(record.get("path_role", "")) == "branch", "%s %s room should be generated as a branch room" % [expected_id, room_type])
		_expect(int(record.get("branch_of", -1)) >= 1, "%s %s room should record its main-path anchor" % [expected_id, room_type])
		_expect(enemy_pool.is_empty(), "%s %s room should not define enemy pool metadata" % [expected_id, room_type])
		_expect(wave_counts.is_empty(), "%s %s room should not define wave count metadata" % [expected_id, room_type])
		if room_type == "trap":
			_expect(not record["auto_clear"], "%s trap room should require survival before clearing" % expected_id)
			_expect(record["locks_doors"], "%s trap room should lock doors during the hazard cycle" % expected_id)
		else:
			_expect(record["auto_clear"], "%s %s room should auto-clear on enter" % [expected_id, room_type])
			_expect(not record["locks_doors"], "%s %s room should not lock doors" % [expected_id, room_type])
	else:
		_expect(not enemy_pool.is_empty(), "%s should define enemy pool metadata" % expected_id)
		_expect(not wave_counts.is_empty(), "%s should define wave count metadata" % expected_id)
		_expect(record["locks_doors"], "%s combat-like room should lock doors" % expected_id)
		if room_type == "start":
			_expect(record.get("is_biome_start", false) == true, "%s start room should mark biome start" % expected_id)
		if room_type == "elite":
			_expect(record["elite_enemies"], "%s elite room should mark elite enemy spawning" % expected_id)
		if room_type == "challenge":
			var challenge_variant := str(record.get("challenge_variant", ""))
			_expect(challenge_variant in ["gauntlet", "hazard_rush"], "%s challenge room should record a supported challenge variant" % expected_id)
			_expect(str(room.get("challenge_variant")) == challenge_variant, "%s runtime challenge variant should match metadata" % expected_id)
			_expect(room.has_method("get_challenge_summary"), "%s challenge room should expose challenge summary" % expected_id)
			if room.has_method("get_challenge_summary"):
				var challenge_summary: Dictionary = room.call("get_challenge_summary")
				_expect(str(challenge_summary.get("variant", "")) == challenge_variant, "%s challenge summary variant should match metadata" % expected_id)
		if room_type == "boss":
			_expect(record.get("is_biome_boss", false) == true, "%s boss room should mark biome boss" % expected_id)
			_expect(record.get("boss_reward_completes_run", false) == record.get("is_final_boss", false), "%s only final boss should complete the run" % expected_id)

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
	await _verify_special_room_state(controller, combat_rooms, player, "event")
	await _verify_trap_room_state(controller, combat_rooms, player)
	await _verify_special_room_state(controller, combat_rooms, player, "armory")
	await _verify_special_room_state(controller, combat_rooms, player, "healing")


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


func _verify_special_room_state(controller: Node, combat_rooms: Array, player: Player, room_type: String) -> void:
	var records: Array = controller.call("get_room_records")
	for index in range(records.size()):
		if str(records[index]["room_type"]) != room_type:
			continue

		var room = combat_rooms[index]
		await _enter_room(room, player)
		await get_tree().process_frame
		await get_tree().physics_frame
		records = controller.call("get_room_records")
		_expect(records[index]["visited"], "Entering %s room should mark it visited" % room_type)
		_expect(records[index]["cleared"], "%s room should auto-clear after entry" % room_type.capitalize())
		_expect(room.doors_are_unlocked(), "%s room doors should remain unlocked" % room_type.capitalize())
		_expect(_enemy_count_near(room.global_position) == 0, "%s room should not spawn local enemies" % room_type.capitalize())
		return

	_expect(false, "%s room should be present for special room state verification" % room_type.capitalize())


func _verify_trap_room_state(controller: Node, combat_rooms: Array, player: Player) -> void:
	var records: Array = controller.call("get_room_records")
	for index in range(records.size()):
		if str(records[index]["room_type"]) != "trap":
			continue

		var room = combat_rooms[index]
		await _enter_room(room, player)
		await get_tree().process_frame
		await get_tree().physics_frame
		records = controller.call("get_room_records")
		_expect(records[index]["visited"], "Entering trap room should mark it visited")
		_expect(int(room.get("state")) == 2, "Trap room should enter combat state while hazards are active")
		_expect(room.has_method("is_trap_active") and bool(room.call("is_trap_active")), "Trap room should activate hazard cycle")
		await get_tree().create_timer(float(room.get("trap_survival_duration")) + 0.4).timeout
		await get_tree().physics_frame
		records = controller.call("get_room_records")
		_expect(records[index]["cleared"], "Surviving trap room should mark it cleared")
		_expect(room.doors_are_unlocked(), "Trap room doors should unlock after survival")
		_expect(_enemy_count_near(room.global_position) == 0, "Trap room should not spawn local enemies")
		return

	_expect(false, "Trap room should be present for trap room state verification")


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


func _get_room_type_count(records: Array, room_type: String) -> int:
	var count := 0
	for record in records:
		if record is Dictionary and str(record.get("room_type", "")) == room_type:
			count += 1
	return count


func _get_final_boss_count(records: Array) -> int:
	var count := 0
	for record in records:
		if record is Dictionary and bool(record.get("is_final_boss", false)):
			count += 1
	return count


func _get_boss_completion_flag_count(records: Array) -> int:
	var count := 0
	for record in records:
		if record is Dictionary and bool(record.get("boss_reward_completes_run", false)):
			count += 1
	return count


func _get_boss_names(records: Array) -> Array:
	var names: Array = []
	for record in records:
		if not record is Dictionary or str(record.get("room_type", "")) != "boss":
			continue
		var enemy_names := record.get("enemy_pool", PackedStringArray()) as PackedStringArray
		if enemy_names.size() > 0:
			names.append(enemy_names[0])
	return names


func _get_branch_anchor_count(records: Array) -> int:
	var anchors := {}
	for record in records:
		if record is Dictionary and str(record.get("path_role", "")) == "branch":
			anchors[int(record.get("branch_of", -1))] = true
	return anchors.size()


func _validate_biome_summaries(records: Array, biome_summaries: Array) -> void:
	var expected_ids := ["outer_warrens", "iron_catacombs", "void_foundry"]
	var expected_music_keys := ["biome_outer_warrens", "biome_iron_catacombs", "biome_void_foundry"]
	var total_summary_rooms := 0
	for index in range(biome_summaries.size()):
		if not biome_summaries[index] is Dictionary:
			_expect(false, "Biome summary %d should be a dictionary" % (index + 1))
			continue
		var summary: Dictionary = biome_summaries[index]

		var biome_index := index + 1
		var room_count := int(summary.get("room_count", 0))
		var main_count := int(summary.get("main_path_rooms", 0))
		var branch_count := int(summary.get("branch_rooms", 0))
		var boss_room_id := str(summary.get("boss_room_id", ""))
		var layout_pool_ids := summary.get("biome_layout_pool_ids", PackedStringArray()) as PackedStringArray
		var reward_multiplier := float(summary.get("biome_reward_weight_multiplier", 0.0))
		total_summary_rooms += room_count
		_expect(int(summary.get("biome_index", 0)) == biome_index, "Biome summary should use sequential biome index")
		_expect(str(summary.get("biome_id", "")) == expected_ids[index], "Biome summary should preserve biome id")
		_expect(str(summary.get("biome_name", "")) == EXPECTED_BIOME_NAMES[index], "Biome summary should preserve biome display name")
		_expect(not str(summary.get("biome_color_key", "")).is_empty(), "Biome summary should preserve visual color key")
		_expect(str(summary.get("biome_music_key", "")) == expected_music_keys[index], "Biome summary should preserve its authored music key")
		_expect(typeof(summary.get("biome_visual_floor_tint")) == TYPE_COLOR, "Biome summary should preserve floor visual tint")
		_expect(str(summary.get("biome_visual_floor_texture_path", "")).begins_with("res://art/terrain/"), "Biome summary should preserve floor texture path")
		_expect(typeof(summary.get("biome_visual_floor_texture_modulate")) == TYPE_COLOR, "Biome summary should preserve floor texture modulation")
		_expect(float(summary.get("biome_visual_floor_texture_opacity", 0.0)) > 0.0, "Biome summary should preserve floor texture opacity")
		_expect(typeof(summary.get("biome_visual_wall_color")) == TYPE_COLOR, "Biome summary should preserve wall visual color")
		_expect(typeof(summary.get("biome_visual_obstacle_tint")) == TYPE_COLOR, "Biome summary should preserve obstacle visual tint")
		_expect(str(summary.get("biome_visual_surface_atlas_path", "")).ends_with("_surface_atlas.svg"), "Biome summary should preserve surface atlas path")
		_expect(str(summary.get("biome_visual_trim_atlas_path", "")).ends_with("_trim_atlas.svg"), "Biome summary should preserve trim atlas path")
		_expect(typeof(summary.get("biome_visual_trim_texture_modulate")) == TYPE_COLOR, "Biome summary should preserve trim texture modulation")
		_expect(float(summary.get("biome_visual_trim_texture_opacity", 0.0)) > 0.0, "Biome summary should preserve trim texture opacity")
		_expect(typeof(summary.get("biome_visual_wall_texture_modulate")) == TYPE_COLOR, "Biome summary should preserve wall texture modulation")
		_expect(float(summary.get("biome_visual_wall_texture_opacity", 0.0)) > 0.0, "Biome summary should preserve wall texture opacity")
		_expect(typeof(summary.get("biome_visual_obstacle_texture_modulate")) == TYPE_COLOR, "Biome summary should preserve obstacle texture modulation")
		_expect(float(summary.get("biome_visual_obstacle_texture_opacity", 0.0)) > 0.0, "Biome summary should preserve obstacle texture opacity")
		_expect(typeof(summary.get("biome_visual_accent_color")) == TYPE_COLOR, "Biome summary should preserve accent visual color")
		_expect(float(summary.get("biome_visual_tint_strength", 0.0)) > 0.0, "Biome summary should preserve active visual tint strength")
		_expect(layout_pool_ids.size() >= 4, "Biome %d summary should preserve layout pool ids" % biome_index)
		_expect(is_equal_approx(reward_multiplier, _expected_biome_reward_weight_multiplier(biome_index)), "Biome %d summary should preserve reward weight multiplier" % biome_index)
		for expected_layout_id in _expected_biome_layout_pool_ids(biome_index):
			_expect(layout_pool_ids.has(expected_layout_id), "Biome %d summary should include layout %s" % [biome_index, expected_layout_id])
		_expect(main_count >= 7 and main_count <= 9, "Biome %d main path should stay within 7-9 rooms" % biome_index)
		_expect(branch_count == 6, "Biome %d branch count should stay at six rooms after trap branch integration" % biome_index)
		_expect(room_count == main_count + branch_count, "Biome %d summary room count should equal main plus branch rooms" % biome_index)
		_expect(_get_record_biome_count(records, biome_index) == room_count, "Biome %d summary room count should match generated records" % biome_index)
		var boss_record := _get_record_by_id(records, boss_room_id)
		_expect(not boss_record.is_empty(), "Biome %d summary boss id should reference a generated room" % biome_index)
		_expect(str(boss_record.get("room_type", "")) == "boss", "Biome %d summary boss id should reference a boss room" % biome_index)
		_expect((boss_record.get("enemy_pool", PackedStringArray()) as PackedStringArray).has(EXPECTED_BOSS_NAMES[index]), "Biome %d boss room should record expected boss name" % biome_index)
		_expect(bool(summary.get("is_final", false)) == (biome_index == TOTAL_BIOMES), "Only final biome summary should be marked final")
	_expect(total_summary_rooms == records.size(), "Biome summaries should account for every generated room")


func _validate_biome_layout_pool_usage(records: Array) -> void:
	for biome_index in range(1, TOTAL_BIOMES + 1):
		var combat_like_count := 0
		var biome_pool_pick_count := 0
		var layout_pool_size := 0
		var used_pool_layouts := {}
		for record in records:
			if not record is Dictionary:
				continue
			if int(record.get("biome_index", 0)) != biome_index:
				continue
			var layout_pool_ids := record.get("biome_layout_pool_ids", PackedStringArray()) as PackedStringArray
			layout_pool_size = maxi(layout_pool_size, layout_pool_ids.size())
			var room_type := str(record.get("room_type", ""))
			if not _is_biome_layout_room_type(room_type):
				continue
			combat_like_count += 1
			var layout_profile := str(record.get("layout_profile", ""))
			if layout_pool_ids.has(layout_profile):
				biome_pool_pick_count += 1
				used_pool_layouts[layout_profile] = true

		_expect(layout_pool_size >= 4, "Biome %d should expose at least four layout pool ids to generated rooms" % biome_index)
		_expect(combat_like_count >= 3, "Biome %d should generate enough combat-like rooms to exercise its layout pool" % biome_index)
		_expect(biome_pool_pick_count >= mini(3, combat_like_count), "Biome %d combat-like rooms should prefer biome layout pool picks" % biome_index)
		_expect(used_pool_layouts.size() >= mini(3, layout_pool_size), "Biome %d should use multiple distinct biome layout pool profiles" % biome_index)


func _get_record_biome_count(records: Array, biome_index: int) -> int:
	var count := 0
	for record in records:
		if record is Dictionary and int(record.get("biome_index", 0)) == biome_index:
			count += 1
	return count


func _get_record_by_id(records: Array, room_id: String) -> Dictionary:
	for record in records:
		if record is Dictionary and str(record.get("id", "")) == room_id:
			return record
	return {}


func _as_color(value, fallback: Color = Color(0.0, 0.0, 0.0, 0.0)) -> Color:
	if value is Color:
		var color: Color = value
		return color
	return fallback


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


func _is_biome_layout_room_type(room_type: String) -> bool:
	return room_type == "combat" or room_type == "elite" or room_type == "challenge"


func _expected_biome_layout_pool_ids(biome_index: int) -> Array:
	match biome_index:
		1:
			return ["crossfire", "open_cross", "corner_nests", "wide_arena"]
		2:
			return ["bunker", "narrow_gap", "split_cover", "center_ring"]
		3:
			return ["ambush_corners", "box_maze", "long_lane", "twin_islands"]
	return []


func _expected_biome_reward_weight_multiplier(biome_index: int) -> float:
	match biome_index:
		1:
			return 1.0
		2:
			return 1.08
		3:
			return 1.16
	return 1.0


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


func _validate_directional_door_geometry(room: Node, connections: PackedStringArray, room_id: String) -> void:
	for direction in ["north", "south"]:
		if not connections.has(direction):
			continue
		var prefix := "North" if direction == "north" else "South"
		var door := room.get_node_or_null("Doors/%sDoor" % prefix) as StaticBody2D
		_expect(door != null, "%s should create a %s directional door" % [room_id, direction])
		if door != null:
			var door_collision := door.get_node_or_null("CollisionShape2D") as CollisionShape2D
			_expect(door_collision != null and door_collision.shape is RectangleShape2D, "%s %s door should define rectangle collision" % [room_id, direction])
			if door_collision != null and door_collision.shape is RectangleShape2D:
				var door_size := (door_collision.shape as RectangleShape2D).size
				_expect(is_equal_approx(door_size.x, 170.0) and is_equal_approx(door_size.y, 42.0), "%s %s door should use the centered 170px opening" % [room_id, direction])
		var arena: Node = null
		if room.get_parent() != null:
			arena = room.get_parent().get_node_or_null("Arena")
		for side in ["Left", "Right"]:
			var segment: StaticBody2D = null
			if arena != null:
				segment = arena.get_node_or_null("Wall%s%s" % [prefix, side]) as StaticBody2D
			_expect(segment != null, "%s %s boundary should keep its %s wall segment" % [room_id, direction, side.to_lower()])
			if segment == null:
				continue
			var segment_collision := segment.get_node_or_null("CollisionShape2D") as CollisionShape2D
			_expect(segment_collision != null and segment_collision.shape is RectangleShape2D, "%s %s wall segment should define rectangle collision" % [room_id, direction])
			if segment_collision != null and segment_collision.shape is RectangleShape2D:
				var segment_size := (segment_collision.shape as RectangleShape2D).size
				_expect(is_equal_approx(segment_size.x, 595.0) and is_equal_approx(segment_size.y, 40.0), "%s %s wall segment should close the boundary outside the doorway" % [room_id, direction])
			var segment_surface := segment.get_node_or_null("SurfaceVisual")
			_expect(segment_surface != null and segment_surface.has_method("get_surface_summary"), "%s %s wall segment should receive biome surface art" % [room_id, direction])


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

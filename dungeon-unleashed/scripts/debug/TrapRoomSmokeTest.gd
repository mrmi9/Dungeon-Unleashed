extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const TRAP_ROOM_DATA := preload("res://resources/rooms/trap_room.tres")
const ROOM_STATE_COMBAT := 2
const ROOM_STATE_CLEARED := 3
const ROOM_STATE_REWARD_CLAIMED := 4

var _failures: Array[String] = []
var _chests_seen := 0


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	Events.chest_opened.connect(func(_chest: Node, _opener: Node, _chest_type: String) -> void:
		_chests_seen += 1
	)

	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	await get_tree().physics_frame
	if main.has_method("reset_run_records_for_test"):
		main.call("reset_run_records_for_test")
		await get_tree().process_frame

	var controller := main.get_node_or_null("DungeonController")
	_expect(controller != null, "Main scene should include DungeonController")
	if controller == null:
		_finish()
		return

	var trap_sequence: Array[Resource] = [TRAP_ROOM_DATA]
	controller.set("room_data_sequence", trap_sequence)
	controller.call("regenerate_with_seed", 777002)
	await get_tree().process_frame
	await get_tree().physics_frame

	main.call("start_new_run")
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().create_timer(0.15).timeout

	var player := main.get_node_or_null("Player") as Player
	_expect(player != null, "Player should exist")
	if player == null:
		_finish()
		return

	var rooms: Array = controller.call("get_combat_rooms")
	_expect(rooms.size() == 1, "Trap test route should contain one room")
	if rooms.is_empty():
		_finish()
		return

	var room: Node = rooms[0]
	_expect(str(room.get("room_type")) == "trap", "Generated test room should be a trap room")
	_expect(not bool(room.get("auto_clear_on_enter")), "Trap room should not auto-clear immediately")
	_expect(bool(room.get("lock_doors_during_combat")), "Trap room should lock during hazard survival")
	_expect((room.get("wave_enemy_counts") as PackedInt32Array).is_empty(), "Trap room should not define enemy waves")

	await _enter_room(room, player)
	_expect(int(room.get("state")) == ROOM_STATE_COMBAT, "Trap room should enter combat state on player entry")
	_expect(room.has_method("is_trap_active") and bool(room.call("is_trap_active")), "Trap room should activate hazard cycle")
	await get_tree().create_timer(0.25).timeout
	await get_tree().process_frame
	_expect(room.has_method("get_trap_warning_count") and int(room.call("get_trap_warning_count")) > 0, "Trap room should spawn readable danger warnings")
	_expect(room.has_method("get_damage_source_summary"), "Trap room should expose hazard damage source summary")
	var room_source: Dictionary = room.call("get_damage_source_summary")
	_expect(str(room_source.get("source_id", "")) == "trap_room_hazard", "Trap room hazard source summary should expose stable id")
	_expect(str(room_source.get("source_type", "")) == "hazard", "Trap room hazard source summary should classify hazard type")
	_expect(str(room_source.get("source_review_tip", "")).contains("Treat warning zones as lanes"), "Trap room hazard source summary should expose review advice")
	_expect(str(room_source.get("source_threat_intel", "")).contains("Room Hazard / Trap"), "Trap room hazard source summary should expose threat intel")
	_expect(_tags_include(room_source.get("source_counter_tags", []), "speed"), "Trap room hazard source summary should expose speed counter tag")
	_expect(_tags_include(room_source.get("source_counter_tags", []), "survival"), "Trap room hazard source summary should expose survival counter tag")
	var warning_source := _first_danger_warning_source_summary()
	_expect(str(warning_source.get("source_id", "")) == "trap_room_hazard", "Trap warning should cache stable hazard source id")
	_expect(str(warning_source.get("source_name", "")) == "Trap Room Hazard", "Trap warning should cache readable hazard source name")
	_expect(str(warning_source.get("source_review_tip", "")).contains("Treat warning zones as lanes"), "Trap warning should cache hazard review advice")
	_expect(str(warning_source.get("source_threat_intel", "")).contains("Room Hazard / Trap"), "Trap warning should cache hazard threat intel")
	_expect(_tags_include(warning_source.get("source_counter_tags", []), "speed"), "Trap warning should cache hazard counter tags")
	var warning := _first_danger_warning_node()
	_expect(warning != null, "Trap room should expose a live danger warning for damage context verification")
	if warning != null:
		player.current_health = player.max_health
		player.current_shield = 0
		player.shield_changed.emit(player.current_shield)
		player.set("_invulnerability_timer", 0.0)
		player.global_position = (warning as Node2D).global_position
		await get_tree().create_timer(float(warning.get("duration")) + 0.08).timeout
		await get_tree().physics_frame
		var last_damage: Dictionary = player.call("get_last_damage_summary")
		_expect(str(last_damage.get("source_id", "")) == "trap_room_hazard", "Player last damage should preserve trap hazard source id")
		_expect(str(last_damage.get("source_room_type", "")) == "trap", "Player last damage should preserve trap room source context")
		_expect(not str(last_damage.get("source_biome_id", "")).is_empty(), "Player last damage should preserve source biome id")
		_expect(not str(last_damage.get("source_layout_profile", "")).is_empty(), "Player last damage should preserve source layout profile")
		_expect(str(last_damage.get("source_review_tip", "")).contains("Treat warning zones as lanes"), "Player last damage should preserve hazard review advice")
		_expect(str(last_damage.get("source_threat_intel", "")).contains("Room Hazard / Trap"), "Player last damage should preserve hazard threat intel")
		_expect(_tags_include(last_damage.get("source_counter_tags", []), "speed"), "Player last damage should preserve hazard counter tags")
		var synthetic_position := {"text": "L1 Trap Test"}
		var defeat_cause: Dictionary = main.call("_get_defeat_cause_summary", "Defeat", synthetic_position, last_damage)
		_expect(str(defeat_cause.get("source_room_type", "")) == "trap", "Defeat cause should preserve trap room source context")
		_expect(str(defeat_cause.get("source_biome_id", "")) == str(last_damage.get("source_biome_id", "")), "Defeat cause should preserve source biome id")
		_expect(str(defeat_cause.get("source_review_tip", "")).contains("Treat warning zones as lanes"), "Defeat cause should preserve hazard review advice")
		_expect(str(defeat_cause.get("source_threat_intel", "")).contains("Room Hazard / Trap"), "Defeat cause should preserve hazard threat intel")
		_expect(_tags_include(defeat_cause.get("source_counter_tags", []), "speed"), "Defeat cause should preserve hazard counter tags")
	_expect(_enemy_count_near(room.global_position) == 0, "Trap room should not spawn enemies")

	player.global_position = room.global_position + Vector2(-520, -285)
	await get_tree().create_timer(float(room.get("trap_survival_duration")) + 0.4).timeout
	await get_tree().physics_frame
	_expect(int(room.get("state")) == ROOM_STATE_CLEARED, "Trap room should clear after survival duration")
	_expect(room.has_method("is_trap_active") and not bool(room.call("is_trap_active")), "Trap room should deactivate hazards after clearing")

	var reward := _find_reward_near(room.global_position)
	_expect(reward != null and reward.has_method("open_for_player"), "Trap room should spawn an openable chest after survival")
	var chests_before := _chests_seen
	if reward != null and reward.has_method("open_for_player"):
		_expect(bool(reward.call("open_for_player", player)), "Trap room chest should open for player")
		await get_tree().process_frame
	_expect(_chests_seen == chests_before + 1, "Trap room chest should emit chest_opened")
	_expect(int(room.get("state")) == ROOM_STATE_REWARD_CLAIMED, "Trap room should mark reward claimed after chest opens")

	get_tree().paused = false
	main.queue_free()
	await get_tree().process_frame
	await _verify_trap_death_records()
	_finish()


func _enter_room(room: Node, player: Player) -> void:
	player.global_position = (room as Node2D).global_position + Vector2(-700, 0)
	await get_tree().physics_frame
	await get_tree().process_frame
	player.global_position = (room as Node2D).global_position
	for _index in range(4):
		await get_tree().physics_frame
		await get_tree().process_frame


func _enemy_count_near(position: Vector2, radius: float = 640.0) -> int:
	var count := 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		if enemy.has_method("is_dead") and enemy.call("is_dead"):
			continue
		var enemy_node := enemy as Node2D
		if enemy_node == null or enemy_node.global_position.distance_to(position) > radius:
			continue
		count += 1
	return count


func _find_reward_near(position: Vector2) -> Node2D:
	for reward in get_tree().get_nodes_in_group("rewards"):
		if not is_instance_valid(reward) or reward.is_queued_for_deletion():
			continue
		if reward.has_method("is_opened") and bool(reward.call("is_opened")):
			continue
		var reward_node := reward as Node2D
		if reward_node != null and reward_node.global_position.distance_to(position) < 500.0:
			return reward_node
	return null


func _first_danger_warning_source_summary() -> Dictionary:
	for warning in get_tree().get_nodes_in_group("danger_warnings"):
		if not is_instance_valid(warning) or warning.is_queued_for_deletion():
			continue
		if warning.has_method("get_damage_source_summary"):
			var summary = warning.call("get_damage_source_summary")
			if summary is Dictionary:
				return summary as Dictionary
	return {}


func _first_danger_warning_node() -> Node:
	for warning in get_tree().get_nodes_in_group("danger_warnings"):
		if is_instance_valid(warning) and not warning.is_queued_for_deletion():
			return warning
	return null


func _wait_for_danger_warning(max_wait_seconds: float) -> Node:
	var elapsed := 0.0
	while elapsed < max_wait_seconds:
		var warning := _first_danger_warning_node()
		if warning != null:
			return warning
		await get_tree().create_timer(0.05).timeout
		await get_tree().process_frame
		elapsed += 0.05
	return null


func _verify_trap_death_records() -> void:
	var archive_main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(archive_main)
	await get_tree().process_frame
	await get_tree().physics_frame
	if archive_main.has_method("reset_run_records_for_test"):
		archive_main.call("reset_run_records_for_test")
		await get_tree().process_frame

	var controller := archive_main.get_node_or_null("DungeonController")
	var player := archive_main.get_node_or_null("Player") as Player
	_expect(controller != null, "Trap death archive should include DungeonController")
	_expect(player != null, "Trap death archive should include Player")
	if controller == null or player == null:
		archive_main.queue_free()
		await get_tree().process_frame
		return

	var trap_sequence: Array[Resource] = [TRAP_ROOM_DATA]
	controller.set("room_data_sequence", trap_sequence)
	controller.call("regenerate_with_seed", 777003)
	await get_tree().process_frame
	await get_tree().physics_frame

	archive_main.call("start_new_run")
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().create_timer(0.15).timeout

	var rooms: Array = controller.call("get_combat_rooms")
	_expect(not rooms.is_empty(), "Trap death archive route should contain a trap room")
	if rooms.is_empty():
		get_tree().paused = false
		archive_main.queue_free()
		await get_tree().process_frame
		return

	var room: Node = rooms[0]
	_expect(str(room.get("room_type")) == "trap", "Trap death archive room should be a trap room")
	_expect(_enemy_count_near(room.global_position) == 0, "Trap death archive room should not spawn enemies")
	await _enter_room(room, player)
	var warning := await _wait_for_danger_warning(2.0)
	_expect(warning != null, "Trap death archive should expose a live danger warning")
	if warning == null:
		get_tree().paused = false
		archive_main.queue_free()
		await get_tree().process_frame
		return

	player.current_health = 1
	player.current_shield = 0
	player.health_changed.emit(player.current_health, player.max_health)
	player.shield_changed.emit(player.current_shield)
	player.set("_invulnerability_timer", 0.0)
	player.global_position = (warning as Node2D).global_position
	await get_tree().create_timer(float(warning.get("duration")) + 0.08).timeout
	await get_tree().physics_frame
	await get_tree().process_frame

	_expect(str(archive_main.call("get_run_state_name")) == "Defeated", "Trap warning death should enter defeated state")
	var last_defeat: Dictionary = archive_main.call("get_last_defeat_summary")
	_expect(str(last_defeat.get("source_id", "")) == "trap_room_hazard", "Trap death archive should persist hazard source id")
	_expect(str(last_defeat.get("source_type", "")) == "hazard", "Trap death archive should persist hazard source type")
	_expect(str(last_defeat.get("source_room_type", "")) == "trap", "Trap death archive should persist source room type")
	_expect(not str(last_defeat.get("source_biome_id", "")).is_empty(), "Trap death archive should persist source biome id")
	_expect(not str(last_defeat.get("source_layout_profile", "")).is_empty(), "Trap death archive should persist source layout profile")
	_expect(str(last_defeat.get("source_review_tip", "")).contains("Treat warning zones as lanes"), "Trap death archive should persist source review advice")
	_expect(str(last_defeat.get("source_threat_intel", "")).contains("Room Hazard / Trap"), "Trap death archive should persist source threat intel")
	_expect(_tags_include(last_defeat.get("source_counter_tags", []), "speed"), "Trap death archive should persist source counter tags")
	var source_record := _find_defeat_source_record(archive_main.call("get_defeat_source_summary"), "trap_room_hazard")
	_expect(not source_record.is_empty(), "Trap death source archive should record trap hazard")
	_expect(str(source_record.get("source_room_type", "")) == "trap", "Trap death source archive should persist source room context")
	_expect(not str(source_record.get("source_layout_profile", "")).is_empty(), "Trap death source archive should persist layout context")
	_expect(str(source_record.get("source_review_tip", "")).contains("Treat warning zones as lanes"), "Trap death source archive should persist source review advice")
	_expect(str(source_record.get("source_threat_intel", "")).contains("Room Hazard / Trap"), "Trap death source archive should persist source threat intel")
	_expect(_tags_include(source_record.get("source_counter_tags", []), "speed"), "Trap death source archive should persist source counter tags")

	get_tree().paused = false
	archive_main.queue_free()
	await get_tree().process_frame

	var reloaded_main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(reloaded_main)
	await get_tree().process_frame
	var reloaded_last_defeat: Dictionary = reloaded_main.call("get_last_defeat_summary")
	_expect(str(reloaded_last_defeat.get("source_room_type", "")) == "trap", "Reloaded trap death archive should preserve source room context")
	_expect(str(reloaded_last_defeat.get("source_review_tip", "")).contains("Treat warning zones as lanes"), "Reloaded trap death archive should preserve source review advice")
	_expect(str(reloaded_last_defeat.get("source_threat_intel", "")).contains("Room Hazard / Trap"), "Reloaded trap death archive should preserve source threat intel")
	_expect(_tags_include(reloaded_last_defeat.get("source_counter_tags", []), "speed"), "Reloaded trap death archive should preserve source counter tags")
	var reloaded_source_record := _find_defeat_source_record(reloaded_main.call("get_defeat_source_summary"), "trap_room_hazard")
	_expect(str(reloaded_source_record.get("source_room_type", "")) == "trap", "Reloaded defeat source archive should preserve source room context")
	_expect(str(reloaded_source_record.get("source_review_tip", "")).contains("Treat warning zones as lanes"), "Reloaded defeat source archive should preserve source review advice")
	_expect(str(reloaded_source_record.get("source_threat_intel", "")).contains("Room Hazard / Trap"), "Reloaded defeat source archive should preserve source threat intel")
	_expect(_tags_include(reloaded_source_record.get("source_counter_tags", []), "speed"), "Reloaded defeat source archive should preserve source counter tags")
	reloaded_main.call("open_hall_menu")
	await get_tree().process_frame
	var hud = reloaded_main.get_node_or_null("CanvasLayer/HUD")
	if hud != null and hud.has_method("get_hall_summary_text"):
		var lobby = hud.get_node_or_null("LobbyScreen")
		if lobby != null and lobby.has_method("select_tab_for_test"):
			lobby.call("select_tab_for_test", "records")
			await get_tree().process_frame
		var hall_text := str(hud.call("get_hall_summary_text"))
		if lobby != null and lobby.has_method("get_records_filter_text"):
			_expect(str(lobby.call("get_records_filter_text")).contains("Death View: All"), "Records page should default to all death view")
		_expect(hall_text.contains("trap_room_hazard"), "Hall Records should show trap hazard source id")
		_expect(hall_text.contains("Type hazard/trap"), "Hall Records should show hazard room type")
		_expect(hall_text.contains("Death Context:"), "Hall Records should show death context breakdown")
		_expect(hall_text.contains("Rooms Trap x1"), "Hall Records should aggregate trap room deaths")
		_expect(hall_text.contains("Biomes "), "Hall Records should aggregate source biome deaths")
		_expect(hall_text.contains("Layouts "), "Hall Records should aggregate source layout deaths")
		_expect(hall_text.contains("Context Room Trap"), "Hall Records should show readable source room context")
		_expect(hall_text.contains("Layout "), "Hall Records should show source layout context")
		if lobby != null and lobby.has_method("set_records_filter_for_test"):
			lobby.call("set_records_filter_for_test", "types")
			await get_tree().process_frame
			var type_view_text := str(hud.call("get_hall_summary_text"))
			_expect(str(lobby.call("get_records_filter_text")).contains("Death View: Types"), "Records filter should switch to death type view")
			_expect(type_view_text.contains("Death View: Types"), "Type view should label the active death view")
			_expect(type_view_text.contains("Death Types: Enemy 0 | Boss 0 | Hazard 1 | Unknown 0"), "Type view should show hazard death count")
			_expect(not type_view_text.contains("Death Context:"), "Type view should hide death context breakdown")
			_expect(not type_view_text.contains("Death Sources"), "Type view should hide detailed death source rankings")
			lobby.call("set_records_filter_for_test", "context")
			await get_tree().process_frame
			var context_view_text := str(hud.call("get_hall_summary_text"))
			_expect(str(lobby.call("get_records_filter_text")).contains("Death View: Context"), "Records filter should switch to death context view")
			_expect(context_view_text.contains("Death View: Context"), "Context view should label the active death view")
			_expect(context_view_text.contains("Death Context:"), "Context view should show death context breakdown")
			_expect(context_view_text.contains("Rooms Trap x1"), "Context view should show room context counts")
			_expect(not context_view_text.contains("Death Types:"), "Context view should hide death type counts")
			_expect(not context_view_text.contains("Death Sources"), "Context view should hide detailed death source rankings")
			if lobby.has_method("set_records_source_type_for_test"):
				lobby.call("set_records_source_type_for_test", "hazard")
				await get_tree().process_frame
				var hazard_context_text := str(hud.call("get_hall_summary_text"))
				_expect(str(lobby.call("get_records_source_type_filter_text")).contains("Source Type: Hazard"), "Context view should expose hazard source type filter")
				_expect(hazard_context_text.contains("Source Type Filter: Hazard"), "Context view should label active hazard filter")
				_expect(hazard_context_text.contains("Rooms Trap x1"), "Hazard context filter should retain trap room deaths")
				lobby.call("set_records_source_type_for_test", "enemy")
				await get_tree().process_frame
				var enemy_context_text := str(hud.call("get_hall_summary_text"))
				_expect(str(lobby.call("get_records_source_type_filter_text")).contains("Source Type: Enemy"), "Context view should switch to enemy source type filter")
				_expect(enemy_context_text.contains("Source Type Filter: Enemy"), "Context view should label active enemy filter")
				_expect(enemy_context_text.contains("Death Context: None"), "Enemy context filter should show no trap hazard context")
				lobby.call("request_clear_records_source_type_for_test")
				await get_tree().process_frame
				_expect(str(lobby.call("get_records_source_type_filter_text")).contains("Source Type: All"), "Clearing source type should restore all context sources")
			lobby.call("set_records_filter_for_test", "sources")
			await get_tree().process_frame
			var source_view_text := str(hud.call("get_hall_summary_text"))
			_expect(str(lobby.call("get_records_filter_text")).contains("Death View: Sources"), "Records filter should switch to death source view")
			_expect(source_view_text.contains("Death View: Sources"), "Source view should label the active death view")
			_expect(source_view_text.contains("Death Sources"), "Source view should show detailed death source rankings")
			_expect(source_view_text.contains("trap_room_hazard x1"), "Source view should show trap hazard source count")
			_expect(source_view_text.contains("Death Source Detail"), "Source view should show focused death source detail")
			_expect(source_view_text.contains("Trap Room Hazard | Type hazard/trap | Count 1"), "Source detail should summarize the top trap hazard source")
			_expect(source_view_text.contains("Last Cause: Hazard Trap Room Hazard"), "Source detail should show the latest readable death cause")
			_expect(source_view_text.contains("Threat Intel: Room Hazard / Trap"), "Source detail should show trap hazard threat intel")
			_expect(source_view_text.contains("Codex death_source_trap_room_hazard"), "Source detail should expose the stable death source codex key")
			_expect(source_view_text.contains("Counter Build: Speed, Survival, Armor"), "Source detail should show counter build tags")
			_expect(source_view_text.contains("Counter Route: Relics -> Speed"), "Source detail should expose a focused counter codex route")
			_expect(source_view_text.contains("Counter Focus: 1/"), "Source detail should show focused counter pick position")
			_expect(source_view_text.contains("Relics -> Adrenaline Charm (Speed)"), "Source detail should expose a focused counter pick")
			_expect(source_view_text.contains("Counter Picks:"), "Source detail should show counter pick recommendations")
			_expect(source_view_text.contains("Relics Adrenaline Charm"), "Source detail should recommend matching relics")
			_expect(source_view_text.contains("Statues Bulwark Idol"), "Source detail should recommend matching statues")
			_expect(source_view_text.contains("Review: Treat warning zones as lanes"), "Source detail should show trap hazard review advice")
			if lobby.has_method("is_codex_detail_card_visible"):
				_expect(bool(lobby.call("is_codex_detail_card_visible")), "Source view should show death source detail card")
				_expect(str(lobby.call("get_codex_detail_title_text")) == "Trap Room Hazard", "Source detail card should show readable hazard title")
				_expect(str(lobby.call("get_codex_detail_icon_text")) == "SRC", "Source detail card should use source badge")
				_expect(str(lobby.call("get_codex_detail_icon_key")) == "death_source_trap_room_hazard", "Source detail card should expose stable death source icon key")
				_expect(str(lobby.call("get_codex_detail_rarity_badge_text")) == "HAZARD", "Source detail card should show hazard badge")
				_expect(str(lobby.call("get_codex_detail_meta_text")).contains("Type Hazard/trap"), "Source detail card should show hazard type context")
				_expect(str(lobby.call("get_codex_detail_body_text")).contains("Last Cause: Hazard Trap Room Hazard"), "Source detail card should show latest death cause")
				_expect(str(lobby.call("get_codex_detail_body_text")).contains("Threat Intel: Room Hazard / Trap"), "Source detail card should show trap hazard threat intel")
				_expect(str(lobby.call("get_codex_detail_body_text")).contains("Codex death_source_trap_room_hazard"), "Source detail card should show the stable death source codex key")
				_expect(str(lobby.call("get_codex_detail_body_text")).contains("Counter Build: Speed, Survival, Armor"), "Source detail card should show counter build tags")
				_expect(str(lobby.call("get_codex_detail_body_text")).contains("Counter Route: Relics -> Speed"), "Source detail card should show the focused counter route")
				_expect(str(lobby.call("get_codex_detail_body_text")).contains("Counter Focus: 1/"), "Source detail card should show focused counter pick position")
				_expect(str(lobby.call("get_codex_detail_body_text")).contains("Relics -> Adrenaline Charm (Speed)"), "Source detail card should show the focused counter pick")
				_expect(str(lobby.call("get_codex_detail_body_text")).contains("Counter Picks:"), "Source detail card should show counter pick recommendations")
				_expect(str(lobby.call("get_codex_detail_body_text")).contains("Relics Adrenaline Charm"), "Source detail card should recommend matching relics")
				_expect(str(lobby.call("get_codex_detail_body_text")).contains("Statues Bulwark Idol"), "Source detail card should recommend matching statues")
				_expect(str(lobby.call("get_codex_detail_body_text")).contains("Review: Treat warning zones as lanes"), "Source detail card should show trap hazard review advice")
				_expect(str(lobby.call("get_codex_detail_body_text")).contains("Source ID: trap_room_hazard"), "Source detail card should show source id")
			if lobby.has_method("is_counter_route_button_visible"):
				_expect(bool(lobby.call("is_counter_route_button_visible")), "Source detail card should expose a counter route button")
				_expect(str(lobby.call("get_counter_route_button_text")).contains("Route Relics -> Speed"), "Counter route button should name the focused route")
			if lobby.has_method("is_counter_pick_button_visible"):
				_expect(bool(lobby.call("is_counter_pick_button_visible")), "Source detail card should expose a counter pick button")
				_expect(str(lobby.call("get_counter_pick_button_text")).contains("Pick Adrenaline Charm"), "Counter pick button should name the focused pick")
			if lobby.has_method("is_counter_pick_cycle_button_visible"):
				_expect(bool(lobby.call("is_counter_pick_cycle_button_visible")), "Source detail card should expose a counter pick cycle button")
				_expect(str(lobby.call("get_counter_pick_cycle_button_text")).contains("Next Pick 1/"), "Counter pick cycle button should show initial focus position")
			if lobby.has_method("is_counter_pick_page_button_visible"):
				_expect(bool(lobby.call("is_counter_pick_page_button_visible")), "Source detail card should expose a counter pick type button")
				_expect(str(lobby.call("get_counter_pick_page_button_text")).contains("Type Relics 1/"), "Counter pick type button should show the initial recommendation type")
			if lobby.has_method("is_counter_pick_type_button_visible"):
				_expect(bool(lobby.call("is_counter_pick_type_button_visible", "relics")), "Source detail card should expose a direct Relics counter type button")
				_expect(str(lobby.call("get_counter_pick_type_button_text", "relics")).contains("[R]"), "Direct counter type row should mark the active Relics type")
				_expect(str(lobby.call("get_counter_pick_type_button_tooltip_text", "relics")).contains("Relics"), "Direct counter type token should keep a readable Relics tooltip")
				_expect(str(lobby.call("get_counter_pick_type_button_font_color_text", "relics")).begins_with("1.00,0.82,0.28"), "Active counter type token should use the gold active color")
				_expect(bool(lobby.call("is_counter_pick_type_button_pressed", "relics")), "Active counter type token should use the pressed state")
			if lobby.has_method("request_next_counter_pick_for_test"):
				lobby.call("request_next_counter_pick_for_test")
				await get_tree().process_frame
				var cycled_source_text := str(hud.call("get_hall_summary_text"))
				_expect(str(lobby.call("get_counter_pick_cycle_button_text")).contains("Next Pick 2/"), "Cycling counter picks should advance the focus index")
				_expect(not str(lobby.call("get_counter_pick_button_text")).contains("Pick Adrenaline Charm"), "Cycling counter picks should update the focused pick button")
				_expect(cycled_source_text.contains("Counter Focus: 2/"), "Cycling counter picks should keep a readable focused pick position")
				_expect(not cycled_source_text.contains("Counter Focus: 1/"), "Cycling counter picks should move away from the first focused pick")
			if lobby.has_method("request_next_counter_pick_page_for_test"):
				lobby.call("request_next_counter_pick_page_for_test")
				await get_tree().process_frame
				var typed_source_text := str(hud.call("get_hall_summary_text"))
				var typed_focus_line := ""
				for line in typed_source_text.split("\n"):
					var focus_candidate := str(line)
					if focus_candidate.contains("Counter Focus:"):
						typed_focus_line = focus_candidate
						break
				_expect(str(lobby.call("get_counter_pick_page_button_text")).contains("Type"), "Cycling counter pick types should keep a readable type button")
				_expect(not str(lobby.call("get_counter_pick_page_button_text")).contains("Relics 1/"), "Cycling counter pick types should move away from the initial type")
				_expect(not bool(lobby.call("is_counter_pick_type_button_pressed", "relics")), "Cycling counter pick types should release the previous Relics token")
				_expect(not typed_focus_line.is_empty(), "Cycling counter pick types should keep a readable focused pick")
				_expect(not typed_focus_line.contains("Relics ->"), "Cycling counter pick types should update the focused counter pick type")
			if lobby.has_method("request_counter_pick_page_for_test"):
				var selected_relics := bool(lobby.call("request_counter_pick_page_for_test", "relics"))
				await get_tree().process_frame
				var selected_source_text := str(hud.call("get_hall_summary_text"))
				var selected_focus_line := ""
				for line in selected_source_text.split("\n"):
					var selected_focus_candidate := str(line)
					if selected_focus_candidate.contains("Counter Focus:"):
						selected_focus_line = selected_focus_candidate
						break
				_expect(selected_relics, "Direct counter type selection should accept an available Relics type")
				_expect(str(lobby.call("get_counter_pick_type_button_text", "relics")).contains("[R]"), "Direct counter type selection should mark Relics active again")
				_expect(str(lobby.call("get_counter_pick_type_button_tooltip_text", "relics")).contains("Relics"), "Direct counter type selection should keep the Relics tooltip")
				_expect(str(lobby.call("get_counter_pick_type_button_font_color_text", "relics")).begins_with("1.00,0.82,0.28"), "Direct counter type selection should restore the gold active color")
				_expect(bool(lobby.call("is_counter_pick_type_button_pressed", "relics")), "Direct counter type selection should restore the pressed state")
				_expect(str(lobby.call("get_counter_pick_page_button_text")).contains("Type Relics 1/"), "Direct counter type selection should synchronize the cycle button state")
				_expect(selected_focus_line.contains("Relics -> Adrenaline Charm"), "Direct counter type selection should restore the Relics focused pick")
			_expect(not source_view_text.contains("Death Types:"), "Source view should hide death type counts")
			_expect(not source_view_text.contains("Death Context:"), "Source view should hide death context breakdown")
			if lobby.has_method("set_records_source_type_for_test"):
				lobby.call("set_records_source_type_for_test", "hazard")
				await get_tree().process_frame
				var hazard_source_text := str(hud.call("get_hall_summary_text"))
				_expect(str(lobby.call("get_records_source_type_filter_text")).contains("Source Type: Hazard"), "Source view should expose hazard source type filter")
				_expect(hazard_source_text.contains("Source Type Filter: Hazard"), "Source view should label active hazard filter")
				_expect(hazard_source_text.contains("trap_room_hazard x1"), "Hazard source filter should retain trap hazard ranking")
				_expect(hazard_source_text.contains("Death Source Detail"), "Hazard source filter should retain focused detail")
				if lobby.has_method("is_codex_detail_card_visible"):
					_expect(bool(lobby.call("is_codex_detail_card_visible")), "Hazard source filter should retain detail card")
					_expect(str(lobby.call("get_codex_detail_title_text")) == "Trap Room Hazard", "Hazard source filter detail card should retain trap hazard")
				lobby.call("set_records_source_type_for_test", "enemy")
				await get_tree().process_frame
				var enemy_source_text := str(hud.call("get_hall_summary_text"))
				_expect(str(lobby.call("get_records_source_type_filter_text")).contains("Source Type: Enemy"), "Source view should switch to enemy source type filter")
				_expect(enemy_source_text.contains("Source Type Filter: Enemy"), "Source view should label active enemy filter")
				_expect(enemy_source_text.contains("Death Sources: None"), "Enemy source filter should show no trap hazard source")
				_expect(not enemy_source_text.contains("Death Source Detail"), "Enemy source filter should hide focused detail when there are no matching sources")
				if lobby.has_method("is_codex_detail_card_visible"):
					_expect(not bool(lobby.call("is_codex_detail_card_visible")), "Enemy source filter should hide detail card when there are no matching sources")
				lobby.call("request_clear_records_source_type_for_test")
				await get_tree().process_frame
				_expect(str(lobby.call("get_records_source_type_filter_text")).contains("Source Type: All"), "Clearing source type should restore all death sources")
			lobby.call("request_clear_records_filter_for_test")
			await get_tree().process_frame
			var cleared_view_text := str(hud.call("get_hall_summary_text"))
			_expect(str(lobby.call("get_records_filter_text")).contains("Death View: All"), "Clearing Records filter should restore all death view")
			_expect(cleared_view_text.contains("Death Types:"), "Cleared Records filter should restore death type counts")
			_expect(cleared_view_text.contains("Death Context:"), "Cleared Records filter should restore death context")
			_expect(cleared_view_text.contains("Death Sources"), "Cleared Records filter should restore death source rankings")
			if lobby.has_method("open_counter_pick_for_test"):
				lobby.call("set_records_filter_for_test", "sources")
				await get_tree().process_frame
				var opened_counter_pick := bool(lobby.call("open_counter_pick_for_test", "relics", "speed", "Adrenaline Charm"))
				await get_tree().process_frame
				var counter_pick_text := str(hud.call("get_hall_summary_text"))
				_expect(opened_counter_pick, "Counter pick action should open a matching codex item")
				_expect(str(lobby.call("get_active_page")) == "relics", "Counter pick action should switch to the relics codex page")
				_expect(str(lobby.call("get_codex_filter_text")).contains("Route: Speed"), "Counter pick action should apply the speed route filter")
				_expect(str(lobby.call("get_codex_search_text")) == "Adrenaline Charm", "Counter pick action should focus the recommended relic search")
				_expect(str(lobby.call("get_codex_detail_title_text")) == "Adrenaline Charm", "Counter pick action should focus the recommended relic card")
				_expect(counter_pick_text.contains("Search \"Adrenaline Charm\""), "Counter pick codex page should summarize the focused search")
			if lobby.has_method("open_counter_route_for_test"):
				lobby.call("select_tab_for_test", "records")
				lobby.call("set_records_filter_for_test", "sources")
				await get_tree().process_frame
				var opened_counter_route := bool(lobby.call("open_counter_route_for_test", "relics", "speed"))
				await get_tree().process_frame
				var counter_route_text := str(hud.call("get_hall_summary_text"))
				_expect(opened_counter_route, "Counter route action should open a matching codex route")
				_expect(str(lobby.call("get_active_page")) == "relics", "Counter route action should switch to the relics codex page")
				_expect(str(lobby.call("get_codex_filter_text")).contains("Route: Speed"), "Counter route action should apply the speed route filter")
				_expect(counter_route_text.contains("Filter: Speed"), "Counter route codex page should summarize the speed filter")
				_expect(counter_route_text.contains("Adrenaline Charm"), "Counter route codex page should show matching speed relics")
	get_tree().paused = false
	reloaded_main.queue_free()
	await get_tree().process_frame


func _find_defeat_source_record(records: Array, source_id: String) -> Dictionary:
	for entry in records:
		if entry is Dictionary and str((entry as Dictionary).get("source_id", "")) == source_id:
			return (entry as Dictionary).duplicate()
	return {}


func _tags_include(value, expected_tag: String) -> bool:
	var expected := expected_tag.strip_edges()
	if expected.is_empty():
		return false
	if value is PackedStringArray:
		for tag in value:
			if str(tag) == expected:
				return true
	elif value is Array:
		for tag in value:
			if str(tag) == expected:
				return true
	elif value is String:
		for tag in str(value).split(",", false):
			if str(tag).strip_edges() == expected:
				return true
	return false


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	get_tree().paused = false
	if _failures.is_empty():
		print("TrapRoomSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

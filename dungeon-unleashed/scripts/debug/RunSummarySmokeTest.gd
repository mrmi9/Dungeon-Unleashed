extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const SETTINGS_FILE := "settings.cfg"
const SETTINGS_PATH := "user://settings.cfg"
const SHARP_ROUNDS := preload("res://resources/relics/sharp_rounds.tres")
const DEEP_CELL := preload("res://resources/blessings/deep_cell.tres")
const AFTERGLOW_CIRCUIT := preload("res://resources/blessings/afterglow_circuit.tres")
const BULWARK_IDOL := preload("res://resources/statues/bulwark_idol.tres")

var _failures: Array[String] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_run")


func _run() -> void:
	_delete_settings_file()

	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	main.call("start_new_run")
	await get_tree().process_frame

	var hud = main.get_node_or_null("CanvasLayer/HUD")
	var player := main.get_node_or_null("Player") as Player
	var relic_system := main.get_node_or_null("RelicSystem")
	var blessing_system := main.get_node_or_null("BlessingSystem")
	var statue_system := main.get_node_or_null("StatueSystem")
	_expect(hud != null, "HUD should exist")
	_expect(player != null, "Player should exist")
	_expect(relic_system != null, "RelicSystem should exist")
	_expect(blessing_system != null, "BlessingSystem should exist")
	_expect(statue_system != null, "StatueSystem should exist")
	if hud == null or player == null or relic_system == null or blessing_system == null or statue_system == null:
		_finish()
		return

	main.call("_grant_gold", 15)
	relic_system.call("obtain_relic", SHARP_ROUNDS)
	blessing_system.call("obtain_blessing", DEEP_CELL)
	blessing_system.call("obtain_blessing", AFTERGLOW_CIRCUIT)
	statue_system.call("obtain_statue", BULWARK_IDOL)
	_expect(bool(statue_system.call("attune_statue", "bulwark_idol")), "Run summary setup should attune the selected statue")
	Events.projectile_critical_hit.emit(null, player, 4)
	player.current_health = maxi(player.max_health - 2, 1)
	player.health_changed.emit(player.current_health, player.max_health)
	player.call("heal", 2)
	player.current_shield = 0
	player.shield_changed.emit(player.current_shield)
	player.call("add_shield", 2)
	player.set("_invulnerability_timer", 0.0)
	player.call("take_damage", 3, null)
	Events.player_projectile_blocked.emit(player, null, 3, player.global_position + Vector2(64, 0))
	_emit_enemy_died(main)
	player.current_energy = maxi(player.max_energy - 30, 0)
	player.energy_changed.emit(player.current_energy, player.max_energy)
	_emit_room_cleared(main)
	player.current_shield = 0
	player.shield_changed.emit(player.current_shield)
	player.current_energy = player.max_energy
	player.energy_changed.emit(player.current_energy, player.max_energy)
	player.set("_skill_cooldown_timer", 0.0)
	player.set("_skill_active_timer", 0.0)
	_expect(player.try_use_skill(), "Run summary setup should trigger the selected statue via skill use")
	Events.reward_collected.emit(main, player)
	Events.shop_item_purchased.emit(main, player, 7, "Heal")
	Events.chest_opened.emit(main, player, "normal")
	Events.special_event_resolved.emit(main, player, "blood_pact", "sacrifice_for_blessing")
	Events.boss_died.emit(null)
	await get_tree().process_frame

	Events.run_completed.emit()
	await get_tree().process_frame

	var summary: Dictionary = main.call("get_run_summary")
	var history: Dictionary = main.call("get_history_summary")
	var meta: Dictionary = main.call("get_meta_progression_summary")
	_expect(str(main.call("get_run_state_name")) == "Victory", "Run completion should enter victory state")
	_expect(int(summary.get("kills", 0)) == 1, "Run summary should track kills")
	_expect(int(summary.get("rooms_cleared", 0)) == 1, "Run summary should track rooms cleared")
	_expect(int(summary.get("gold_earned", 0)) >= 18, "Run summary should track earned gold")
	_expect(int(summary.get("gold_spent", 0)) == 7, "Run summary should track spent gold")
	_expect(int(summary.get("shop_purchases", 0)) == 1, "Run summary should track shop purchases")
	_expect(int(summary.get("chests_opened", 0)) == 1, "Run summary should track chests opened")
	_expect(int(summary.get("rewards_collected", 0)) == 1, "Run summary should track rewards collected")
	_expect(int(summary.get("events_resolved", 0)) == 1, "Run summary should track events resolved")
	_expect(_array_has(summary.get("event_names", []), "Blood Pact -> Sacrifice For Blessing"), "Run summary should track resolved event names")
	var event_records: Array = summary.get("event_records", [])
	_expect(event_records.size() == 1, "Run summary should expose resolved event records")
	if event_records.size() > 0 and event_records[0] is Dictionary:
		_expect(str((event_records[0] as Dictionary).get("event_id", "")) == "blood_pact", "Run summary event record should preserve event id")
		_expect(str((event_records[0] as Dictionary).get("outcome_id", "")) == "sacrifice_for_blessing", "Run summary event record should preserve outcome id")
	_expect(int(summary.get("damage_taken", 0)) == 1, "Run summary should track damage taken")
	_expect(int(summary.get("critical_hits", 0)) == 1, "Run summary should track critical hits")
	_expect(int(summary.get("healing_received", 0)) == 2, "Run summary should track healing received")
	_expect(int(summary.get("shield_absorbed", 0)) == 2, "Run summary should track shield absorption")
	_expect(int(summary.get("projectiles_blocked", 0)) == 3, "Run summary should track projectiles blocked by weapon guards")
	_expect(summary.get("boss_defeated", false) == true, "Run summary should track boss defeat")
	_expect(str(summary.get("character", "")) == "Wanderer", "Run summary should include selected character")
	_expect(str(summary.get("weapon", "")) == "Basic Pistol", "Run summary should include final weapon")
	_expect(_array_has(summary.get("relic_names", []), "Sharp Rounds"), "Run summary should include relic names")
	_expect(_array_has(summary.get("blessing_names", []), "Deep Cell"), "Run summary should include blessing names")
	_expect(_array_has(summary.get("blessing_names", []), "Afterglow Circuit"), "Run summary should include event-triggered blessing names")
	_expect(int(summary.get("blessing_trigger_count", 0)) == 1, "Run summary should count event-triggered blessings")
	var blessing_trigger_counts: Dictionary = summary.get("blessing_trigger_counts", {})
	_expect(int(blessing_trigger_counts.get("afterglow_circuit", 0)) == 1, "Run summary should count triggers per blessing id")
	_expect(_array_has(summary.get("statue_names", []), "Bulwark Idol +1"), "Run summary should include attuned statue names")
	_expect(int(summary.get("statue_trigger_count", 0)) == 1, "Run summary should count skill-triggered statues")
	var statue_trigger_counts: Dictionary = summary.get("statue_trigger_counts", {})
	_expect(int(statue_trigger_counts.get("bulwark_idol", 0)) == 1, "Run summary should count triggers per statue id")
	_expect(int(summary.get("statue_attunement_count", 0)) == 1, "Run summary should count statue attunements")
	var statue_attunement_counts: Dictionary = summary.get("statue_attunement_counts", {})
	_expect(int(statue_attunement_counts.get("bulwark_idol", 0)) == 1, "Run summary should count attunements per statue id")
	_expect(int(summary.get("dungeon_seed", 0)) > 0, "Run summary should include active dungeon seed")
	var route_nodes: Array = summary.get("route_nodes", [])
	var boss_route: Array = summary.get("boss_route", [])
	var defeated_boss_names: Array = summary.get("defeated_boss_names", [])
	var build_route_counts: Dictionary = summary.get("build_route_counts", {})
	var primary_build_routes: Array = summary.get("primary_build_routes", [])
	var special_room_counts: Dictionary = summary.get("special_room_counts", {})
	_expect(route_nodes.size() >= 39, "Run summary should preserve the generated three-biome route nodes")
	_expect(str(summary.get("route_signature", "")).contains("L1:"), "Run summary should expose a compact route signature")
	_expect(str(summary.get("route_signature", "")).contains("L2:"), "Run summary route signature should include the second biome")
	_expect(str(summary.get("route_signature", "")).contains("L3:"), "Run summary route signature should include the third biome")
	_expect(str(summary.get("visited_route_signature", "")).length() > 0, "Run summary should expose visited route signature")
	_expect(special_room_counts.has("event"), "Run summary should expose event room route counts")
	_expect(special_room_counts.has("challenge"), "Run summary should expose challenge room route counts")
	_expect(special_room_counts.has("trap"), "Run summary should expose trap room route counts")
	_expect(str(summary.get("special_room_count_text", "")).length() > 0, "Run summary should expose a readable special room route recap")
	_expect(str(summary.get("reached_biome_name", "")).length() > 0, "Run summary should expose reached biome display name")
	_expect(boss_route.size() == int(summary.get("total_biomes", 0)), "Run summary should expose one boss route entry per biome")
	_expect(_boss_route_has_name(boss_route), "Run summary boss route entries should expose boss display names")
	_expect(not defeated_boss_names.is_empty(), "Run summary should record defeated boss names")
	_expect(build_route_counts.has("damage"), "Run summary build route counts should include relic damage tag")
	_expect(build_route_counts.has("projectile"), "Run summary build route counts should include relic projectile tag")
	_expect(not primary_build_routes.is_empty(), "Run summary should expose primary build route labels")
	_expect(int(history.get("runs", 0)) == 1, "History should persist total runs")
	_expect(int(history.get("victories", 0)) == 1, "History should persist victories")
	_expect(int(history.get("best_kills", 0)) == 1, "History should persist best kills")
	_expect(int(history.get("best_projectiles_blocked", 0)) == 3, "History should persist best projectile block count")
	_expect(int(meta.get("currency", 0)) > 0, "Meta progression should award permanent currency")
	var mastery: Dictionary = meta.get("character_mastery_xp", {})
	_expect(int(mastery.get("wanderer", 0)) > 0, "Meta progression should award character mastery")

	var result_text := str(hud.call("get_result_summary_text"))
	_expect(result_text.contains("Weapon:"), "Result panel should show weapon details")
	_expect(result_text.contains("Character:"), "Result panel should show character details")
	_expect(result_text.contains("Relics:"), "Result panel should show relic details")
	_expect(result_text.contains("Blessings:"), "Result panel should show blessing details")
	_expect(result_text.contains("Route:"), "Result panel should show route signature")
	_expect(result_text.contains("Build Routes:"), "Result panel should show primary build routes")
	_expect(result_text.contains("Combat:"), "Result panel should show combat details")
	_expect(result_text.contains("Crits 1"), "Result panel should show critical hit count")
	_expect(result_text.contains("Healing 2"), "Result panel should show healing received")
	_expect(result_text.contains("Shield Blocked 2"), "Result panel should show shield absorption")
	_expect(result_text.contains("Projectiles Blocked 3"), "Result panel should show projectile block count")
	_expect(result_text.contains("Best Guard Blocks 3"), "Result panel should show best projectile block record")
	_expect(result_text.contains("Record:"), "Result panel should show history record")
	_expect(result_text.contains("Meta:"), "Result panel should show meta progression reward")
	_expect(result_text.contains("Data Shards"), "Result panel should show permanent currency name")
	_expect(result_text.contains("Sharp Rounds"), "Result panel should show collected relic name")
	_expect(result_text.contains("Deep Cell"), "Result panel should show collected blessing name")
	_expect(result_text.contains("Afterglow Circuit"), "Result panel should show event-triggered blessing name")
	_expect(result_text.contains("Blessing Triggers: 1"), "Result panel should show blessing trigger count")
	_expect(result_text.contains("Bulwark Idol +1"), "Result panel should show attuned statue name")
	_expect(result_text.contains("Statue Triggers: 1 | Attunes: 1"), "Result panel should show statue trigger and attunement counts")
	_expect(result_text.contains("Event Outcomes: Blood Pact -> Sacrifice For Blessing"), "Result panel should show resolved event outcomes")
	_expect(result_text.contains("Special Rooms:"), "Result panel should show special room route recap")
	_expect(result_text.contains("Boss Route:"), "Result panel should show boss route recap")
	_expect(bool(hud.call("is_result_scroll_available")), "Result panel should keep grouped sections inside a scroll container")
	_expect(str(hud.call("get_result_scroll_child_name")) == "ResultSections", "Result scroll should contain the grouped result sections")
	_expect(float(hud.call("get_result_scroll_minimum_height")) >= 300.0, "Result scroll should reserve readable vertical space")
	_expect(int(hud.call("get_result_section_count")) == 6, "Result panel should expose six grouped sections")
	_expect(bool(hud.call("is_result_details_expanded")), "Result panel should open in expanded detail mode")
	_expect(str(hud.call("get_result_detail_toggle_text")) == "Compact", "Result detail toggle should offer compact mode by default")
	_expect(int(hud.call("get_visible_result_section_count")) == 6, "Expanded result should show all grouped sections")
	_expect(bool(hud.call("is_result_section_visible", "Record")), "Expanded result should show the record section")
	_expect(str(hud.call("get_result_section_text", "Overview")).contains("Rooms 1"), "Overview result section should show room progress")
	_expect(str(hud.call("get_result_section_text", "Overview")).contains("Route"), "Overview result section should show route signature")
	_expect(str(hud.call("get_result_section_text", "Overview")).contains("Boss Route"), "Overview result section should show boss route recap")
	_expect(str(hud.call("get_result_section_text", "Overview")).contains("Special Rooms"), "Overview result section should show special room route recap")
	_expect(str(hud.call("get_result_section_text", "Build")).contains("Wanderer"), "Build result section should show selected character")
	_expect(str(hud.call("get_result_section_text", "Build")).contains("Build Routes:"), "Build result section should show primary build routes")
	_expect(str(hud.call("get_result_section_text", "Build")).contains("Sharp Rounds"), "Build result section should show relic names")
	_expect(str(hud.call("get_result_section_text", "Build")).contains("Deep Cell"), "Build result section should show blessing names")
	_expect(str(hud.call("get_result_section_text", "Build")).contains("Afterglow Circuit"), "Build result section should show event-triggered blessing names")
	_expect(str(hud.call("get_result_section_text", "Build")).contains("Blessing Triggers: 1"), "Build result section should show blessing trigger count")
	_expect(str(hud.call("get_result_section_text", "Build")).contains("Bulwark Idol +1"), "Build result section should show attuned statue names")
	_expect(str(hud.call("get_result_section_text", "Build")).contains("Statue Triggers: 1 | Attunes: 1"), "Build result section should show statue trigger and attunement counts")
	_expect(str(hud.call("get_result_section_text", "Combat")).contains("Shield Blocked 2"), "Combat result section should show shield absorption")
	_expect(str(hud.call("get_result_section_text", "Combat")).contains("Projectiles Blocked 3"), "Combat result section should show projectile block count")
	_expect(str(hud.call("get_result_section_text", "Loot")).contains("Shop Buys 1"), "Loot result section should show shop purchases")
	_expect(str(hud.call("get_result_section_text", "Loot")).contains("Events 1"), "Loot result section should show event room count")
	_expect(str(hud.call("get_result_section_text", "Loot")).contains("Blood Pact -> Sacrifice For Blessing"), "Loot result section should show event outcomes")
	_expect(str(hud.call("get_result_section_text", "Record")).contains("Wins 1"), "Record result section should show saved wins")
	_expect(str(hud.call("get_result_section_text", "Record")).contains("Best Guard Blocks 3"), "Record result section should show best projectile block record")
	_expect(str(hud.call("get_result_section_text", "Record")).contains("Data Shards"), "Record result section should show meta currency")
	hud.call("toggle_result_detail_mode")
	_expect(not bool(hud.call("is_result_details_expanded")), "Result panel should switch to compact detail mode")
	_expect(str(hud.call("get_result_detail_toggle_text")) == "Details", "Result detail toggle should offer expanded mode from compact mode")
	_expect(int(hud.call("get_visible_result_section_count")) == 3, "Compact result should show only core grouped sections")
	_expect(bool(hud.call("is_result_section_visible", "Overview")), "Compact result should keep overview visible")
	_expect(str(hud.call("get_result_section_text", "Overview")).contains("Boss Route"), "Compact result should retain boss route recap in overview text")
	_expect(bool(hud.call("is_result_section_visible", "Build")), "Compact result should keep build visible")
	_expect(bool(hud.call("is_result_section_visible", "Loot")), "Compact result should keep loot visible")
	_expect(not bool(hud.call("is_result_section_visible", "Combat")), "Compact result should hide combat detail rows")
	_expect(not bool(hud.call("is_result_section_visible", "Record")), "Compact result should hide record detail rows")
	_expect(str(hud.call("get_result_section_text", "Record")).contains("Wins 1"), "Compact result should retain hidden record text")
	_expect(str(hud.call("get_result_section_text", "Record")).contains("Best Guard Blocks 3"), "Compact result should retain hidden projectile block record")
	hud.call("toggle_result_detail_mode")
	_expect(bool(hud.call("is_result_details_expanded")), "Result panel should switch back to expanded detail mode")
	_expect(int(hud.call("get_visible_result_section_count")) == 6, "Expanded result should restore all grouped sections")

	get_tree().paused = false
	main.queue_free()
	await get_tree().process_frame

	var reloaded_main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(reloaded_main)
	await get_tree().process_frame
	var reloaded_history: Dictionary = reloaded_main.call("get_history_summary")
	var reloaded_meta: Dictionary = reloaded_main.call("get_meta_progression_summary")
	_expect(int(reloaded_history.get("runs", 0)) == 1, "Reloaded Main should read saved total runs")
	_expect(int(reloaded_history.get("victories", 0)) == 1, "Reloaded Main should read saved victories")
	_expect(int(reloaded_history.get("best_projectiles_blocked", 0)) == 3, "Reloaded Main should read saved projectile block record")
	_expect(int(reloaded_meta.get("currency", 0)) > 0, "Reloaded Main should read saved permanent currency")

	get_tree().paused = false
	reloaded_main.queue_free()
	await get_tree().process_frame
	_delete_settings_file()
	_finish()


func _emit_enemy_died(parent: Node) -> void:
	var enemy := Node.new()
	parent.add_child(enemy)
	Events.enemy_died.emit(enemy)
	enemy.queue_free()


func _emit_room_cleared(parent: Node) -> void:
	var room := Node.new()
	parent.add_child(room)
	Events.room_cleared.emit(room)
	room.queue_free()


func _array_has(values, expected: String) -> bool:
	if not values is Array:
		return false
	for value in values:
		if str(value) == expected:
			return true
	return false


func _boss_route_has_name(values: Array) -> bool:
	for value in values:
		if not value is Dictionary:
			continue
		if not str(value.get("boss_name", "")).is_empty():
			return true
	return false


func _delete_settings_file() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var dir := DirAccess.open("user://")
	if dir != null:
		dir.remove(SETTINGS_FILE)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	get_tree().paused = false
	if _failures.is_empty():
		print("RunSummarySmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

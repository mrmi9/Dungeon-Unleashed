extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const UI_SAMPLE_COUNT := 24
const MINIMAP_SAMPLE_COUNT := 6
const ROOM_POLL_SAMPLE_COUNT := 30
const COMBAT_TEXT_SAMPLE_COUNT := 64

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	await get_tree().physics_frame

	var hud := main.get_node_or_null("CanvasLayer/HUD")
	var controller := main.get_node_or_null("DungeonController")
	_expect(hud != null, "Main should include HUD")
	_expect(controller != null, "Main should include DungeonController")
	if hud == null or controller == null:
		_finish()
		return

	var records: Array = controller.call("get_room_records")
	var rooms: Array = controller.call("get_combat_rooms")
	var current_room_id := str(controller.call("get_current_room_id"))
	_expect(records.size() >= 30, "Performance sample should include the full multi-biome dungeon")

	var armor_avg_usec := _measure_callable(Callable(main, "_refresh_armor_hud"), UI_SAMPLE_COUNT)
	var passive_avg_usec := _measure_callable(Callable(main, "_refresh_passive_status_hud"), UI_SAMPLE_COUNT)
	var minimap_avg_usec := _measure_minimap(hud, records, current_room_id)
	var room_poll_avg_usec := _measure_room_overlap_polling(rooms)
	var combat_text_avg_usec := _measure_combat_text_spawning(main)
	var text_creation_count := int(main.call("get_floating_text_creation_count_for_test"))
	var steady_combat_text_avg_usec := _measure_combat_text_spawning(main)
	var active_room_pollers := 0
	for room in rooms:
		if room != null and is_instance_valid(room) and room.is_physics_processing():
			active_room_pollers += 1

	_expect(active_room_pollers == 0, "Generated rooms should use entry signals instead of per-frame overlap polling")
	_expect(passive_avg_usec < 5000, "Passive HUD refresh should remain below 5 ms")
	_expect(minimap_avg_usec < 5000, "Stable-topology minimap updates should remain below 5 ms")
	_expect(combat_text_avg_usec < 1000, "Combat text acquisition should remain below 1 ms per entry")
	_expect(int(main.call("get_floating_text_pool_size_for_test")) <= 48, "Combat text pool should remain bounded")
	_expect(int(main.call("get_floating_text_count")) <= 48, "Visible combat text should remain bounded")
	_expect(int(main.call("get_floating_text_creation_count_for_test")) == text_creation_count, "A saturated combat text pool should reuse existing labels")

	print(
		"RuntimePerformanceSmokeTest metrics: rooms=%d active_room_pollers=%d armor_avg_us=%d passive_avg_us=%d minimap_avg_us=%d room_poll_cycle_avg_us=%d combat_text_spawn_avg_us=%d combat_text_steady_avg_us=%d" % [
			rooms.size(),
			active_room_pollers,
			armor_avg_usec,
			passive_avg_usec,
			minimap_avg_usec,
			room_poll_avg_usec,
			combat_text_avg_usec,
			steady_combat_text_avg_usec,
		]
	)
	_finish()


func _measure_callable(callable: Callable, sample_count: int) -> int:
	var started_usec := Time.get_ticks_usec()
	for _index in range(sample_count):
		callable.call()
	return int(Time.get_ticks_usec() - started_usec) / maxi(sample_count, 1)


func _measure_minimap(hud: Node, records: Array, current_room_id: String) -> int:
	var started_usec := Time.get_ticks_usec()
	for _index in range(MINIMAP_SAMPLE_COUNT):
		hud.call("update_minimap", records, current_room_id)
	return int(Time.get_ticks_usec() - started_usec) / MINIMAP_SAMPLE_COUNT


func _measure_room_overlap_polling(rooms: Array) -> int:
	var started_usec := Time.get_ticks_usec()
	for _sample in range(ROOM_POLL_SAMPLE_COUNT):
		for room in rooms:
			if room != null and is_instance_valid(room) and int(room.get("state")) == 0:
				room.call("_check_initial_overlap")
	return int(Time.get_ticks_usec() - started_usec) / ROOM_POLL_SAMPLE_COUNT


func _measure_combat_text_spawning(main: Node) -> int:
	var started_usec := Time.get_ticks_usec()
	for index in range(COMBAT_TEXT_SAMPLE_COUNT):
		main.call(
			"_spawn_floating_text",
			Vector2(float(index % 8) * 18.0, float(index / 8) * 18.0),
			"-%d" % (index + 1),
			Color(1.0, 0.86, 0.34, 1.0),
			20,
			42.0
		)
	return int(Time.get_ticks_usec() - started_usec) / COMBAT_TEXT_SAMPLE_COUNT


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("RuntimePerformanceSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

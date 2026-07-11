extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const RUN_SEED_STREAMS := preload("res://scripts/dungeon/RunSeedStreams.gd")
const EVENT_SCENE := preload("res://scenes/events/EventShrine.tscn")
const NORMAL_CHEST_SCENE := preload("res://scenes/chests/NormalChest.tscn")
const SHOP_SCENE := preload("res://scenes/shop/ShopInventory.tscn")
const TEST_SEED := 726411

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	_verify_seed_derivation()
	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	await _wait_frames(4)

	var controller := main.get_node_or_null("DungeonController")
	_expect(controller != null, "Main should expose DungeonController")
	if controller == null:
		main.queue_free()
		_finish()
		return

	controller.call("regenerate_with_seed", TEST_SEED)
	await _wait_frames(4)
	var first_summary: Dictionary = controller.call("get_run_random_stream_summary")
	var first_room_signature := _room_seed_signature(controller)
	_verify_system_streams(main, first_summary)
	_verify_room_streams(controller)
	_verify_central_choice_replay(main, first_summary)
	_verify_relic_source_isolation(main, first_summary)
	await _verify_local_reward_replay(main, first_summary)

	controller.call("regenerate_with_seed", TEST_SEED)
	await _wait_frames(4)
	var repeat_summary: Dictionary = controller.call("get_run_random_stream_summary")
	_expect(first_summary == repeat_summary, "Regenerating the same run seed should reproduce every named stream seed")
	_expect(first_room_signature == _room_seed_signature(controller), "Regenerating the same run seed should reproduce every room reward seed")

	controller.call("regenerate_with_seed", TEST_SEED + 1)
	await _wait_frames(4)
	var changed_summary: Dictionary = controller.call("get_run_random_stream_summary")
	_expect(first_summary != changed_summary, "Changing the run seed should change named reward streams")
	_expect(first_room_signature != _room_seed_signature(controller), "Changing the run seed should change room reward streams")

	main.queue_free()
	await get_tree().process_frame
	_finish()


func _verify_seed_derivation() -> void:
	var relic_seed := RUN_SEED_STREAMS.derive_seed(TEST_SEED, "relic_rewards")
	_expect(relic_seed > 0, "Derived seeds should be positive and non-zero")
	_expect(relic_seed == RUN_SEED_STREAMS.derive_seed(TEST_SEED, "relic_rewards"), "Named seed derivation should be stable")
	_expect(relic_seed != RUN_SEED_STREAMS.derive_seed(TEST_SEED, "talent_rewards"), "Different stream names should derive independent seeds")
	_expect(relic_seed != RUN_SEED_STREAMS.derive_seed(TEST_SEED + 1, "relic_rewards"), "Different run seeds should derive different stream seeds")


func _verify_system_streams(main: Node, summary: Dictionary) -> void:
	_expect(int(summary.get("run_seed", 0)) == TEST_SEED, "Random stream summary should expose the active run seed")
	var system_seeds: Dictionary = summary.get("system_seeds", {})
	var configs := [
		{"node": "RelicSystem", "key": "relic_rewards"},
		{"node": "TalentSystem", "key": "talent_rewards"},
		{"node": "BlessingSystem", "key": "blessing_rewards"},
		{"node": "StatueSystem", "key": "statue_rewards"},
	]
	var unique_seeds: Dictionary = {}
	for config in configs:
		var key := str(config.get("key", ""))
		var expected_seed := RUN_SEED_STREAMS.derive_seed(TEST_SEED, key)
		var system := main.get_node_or_null(str(config.get("node", "")))
		_expect(system != null and system.has_method("get_random_seed"), "%s should expose its configured random seed" % key)
		_expect(int(system_seeds.get(key, 0)) == expected_seed, "%s summary should use the named derived seed" % key)
		if system != null and system.has_method("get_random_seed"):
			_expect(int(system.call("get_random_seed")) == expected_seed, "%s runtime should preserve its pre-ready seed" % key)
		unique_seeds[expected_seed] = true
	_expect(unique_seeds.size() == configs.size(), "Central reward systems should receive unique random streams")


func _verify_room_streams(controller: Node) -> void:
	var records: Array = controller.call("get_room_records")
	var rooms: Array = controller.call("get_combat_rooms")
	var unique_seeds: Dictionary = {}
	_expect(records.size() == rooms.size(), "Room records and runtime rooms should stay aligned")
	for index in range(mini(records.size(), rooms.size())):
		var record: Dictionary = records[index]
		var room: Node = rooms[index]
		var room_id := str(record.get("id", ""))
		var expected_seed := RUN_SEED_STREAMS.derive_seed(TEST_SEED, "room_reward:%s" % room_id)
		_expect(int(record.get("reward_random_seed", 0)) == expected_seed, "%s should record its deterministic reward seed" % room_id)
		_expect(int(room.get("reward_random_seed")) == expected_seed, "%s runtime room should receive its deterministic reward seed" % room_id)
		if room.has_method("get_biome_reward_summary"):
			var reward_summary: Dictionary = room.call("get_biome_reward_summary")
			_expect(int(reward_summary.get("random_seed", 0)) == expected_seed, "%s reward summary should expose its deterministic seed" % room_id)
		unique_seeds[expected_seed] = true
	_expect(unique_seeds.size() == records.size(), "Every generated room should receive a unique reward stream")


func _verify_central_choice_replay(main: Node, summary: Dictionary) -> void:
	var system_seeds: Dictionary = summary.get("system_seeds", {})
	var configs := [
		{"node": "RelicSystem", "key": "relic_rewards", "source": "reward"},
		{"node": "TalentSystem", "key": "talent_rewards", "source": "boss"},
		{"node": "BlessingSystem", "key": "blessing_rewards", "source": "event"},
		{"node": "StatueSystem", "key": "statue_rewards", "source": "event"},
	]
	for config in configs:
		var system := main.get_node_or_null(str(config.get("node", "")))
		if system == null:
			continue
		var seed := int(system_seeds.get(str(config.get("key", "")), 0))
		system.call("reset_run")
		system.call("set_random_seed", seed)
		var first := _choice_signature(system.call("get_reward_choices", 3, str(config.get("source", "event"))))
		system.call("reset_run")
		var repeat := _choice_signature(system.call("get_reward_choices", 3, str(config.get("source", "event"))))
		_expect(not first.is_empty(), "%s should generate a non-empty deterministic choice signature" % str(config.get("key", "")))
		_expect(first == repeat, "%s reset should rewind its random stream" % str(config.get("key", "")))


func _verify_relic_source_isolation(main: Node, summary: Dictionary) -> void:
	var relic_system := main.get_node_or_null("RelicSystem")
	if relic_system == null:
		return
	var relic_seed := int((summary.get("system_seeds", {}) as Dictionary).get("relic_rewards", 0))
	relic_system.call("reset_run")
	relic_system.call("set_random_seed", relic_seed)
	var baseline_shop := _choice_signature(relic_system.call("get_reward_choices", 3, "shop", 1.0))
	relic_system.call("reset_run")
	relic_system.call("set_random_seed", relic_seed)
	relic_system.call("choose_reward_relic", "normal_chest", 1.0)
	var isolated_shop := _choice_signature(relic_system.call("get_reward_choices", 3, "shop", 1.0))
	_expect(baseline_shop == isolated_shop, "Normal chest relic rolls should not advance the Shop relic stream")


func _verify_local_reward_replay(main: Node, summary: Dictionary) -> void:
	var room_seed := RUN_SEED_STREAMS.derive_seed(TEST_SEED, "room_reward:Room07")
	var event_signature_a := await _event_signature(room_seed)
	var event_signature_b := await _event_signature(room_seed)
	_expect(event_signature_a == event_signature_b, "Event shrine variant and rule payload should replay from the same room seed")

	var chest_signature_a := await _chest_signature(room_seed)
	var chest_signature_b := await _chest_signature(room_seed)
	_expect(chest_signature_a == chest_signature_b, "Chest drop kind, gold, and weapon probe should replay from the same room seed")

	var relic_system := main.get_node_or_null("RelicSystem")
	var relic_seed := int((summary.get("system_seeds", {}) as Dictionary).get("relic_rewards", 0))
	var shop_signature_a := await _shop_signature(relic_system, relic_seed, room_seed)
	var shop_signature_b := await _shop_signature(relic_system, relic_seed, room_seed)
	_expect(shop_signature_a == shop_signature_b, "Shop relic and weapon stock should replay from the same run and room seeds")


func _event_signature(seed: int) -> String:
	var shrine := EVENT_SCENE.instantiate()
	shrine.set("random_seed", seed)
	add_child(shrine)
	await get_tree().process_frame
	var signature := JSON.stringify(shrine.call("get_event_summary"))
	shrine.queue_free()
	await get_tree().process_frame
	return signature


func _chest_signature(seed: int) -> String:
	var chest := NORMAL_CHEST_SCENE.instantiate()
	chest.set("random_seed", seed)
	add_child(chest)
	await get_tree().process_frame
	var signature := str(chest.call("get_roll_signature_for_test"))
	chest.queue_free()
	await get_tree().process_frame
	return signature


func _shop_signature(relic_system: Node, relic_seed: int, room_seed: int) -> String:
	if relic_system != null:
		relic_system.call("reset_run")
		relic_system.call("set_random_seed", relic_seed)
	var shop := SHOP_SCENE.instantiate()
	shop.set("random_seed", room_seed)
	add_child(shop)
	await get_tree().process_frame
	var signature := str(shop.call("get_inventory_signature"))
	shop.queue_free()
	await get_tree().process_frame
	return signature


func _room_seed_signature(controller: Node) -> String:
	var parts: Array[String] = []
	for record in controller.call("get_room_records"):
		parts.append("%s:%d" % [str(record.get("id", "")), int(record.get("reward_random_seed", 0))])
	return "|".join(parts)


func _choice_signature(choices: Array) -> String:
	var ids: Array[String] = []
	for choice in choices:
		if choice is Resource:
			ids.append(str(choice.get("id")))
	return ",".join(ids)


func _wait_frames(count: int) -> void:
	for index in range(count):
		await get_tree().physics_frame
		await get_tree().process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("SeededRewardSmokeTest passed.")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

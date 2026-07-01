extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const NORMAL_CHEST := preload("res://scenes/chests/NormalChest.tscn")
const PREMIUM_CHEST := preload("res://scenes/chests/PremiumChest.tscn")
const BOSS_CHEST := preload("res://scenes/chests/BossRewardChest.tscn")

var _failures: Array[String] = []
var _opened_count := 0
var _run_completed_seen := false


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	Events.chest_opened.connect(func(_chest: Node, _opener: Node, _chest_type: String) -> void:
		_opened_count += 1
	)
	Events.run_completed.connect(func() -> void:
		_run_completed_seen = true
	)

	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	if main.has_method("start_new_run"):
		main.call("start_new_run")

	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().create_timer(0.15).timeout

	var player := main.get_node("Player") as Player
	var relic_system := main.get_node_or_null("RelicSystem")
	_expect(player != null, "Player should exist")
	_expect(relic_system != null, "RelicSystem should exist")
	if player == null or relic_system == null:
		_finish()
		return

	await _verify_normal_chest(player)
	await _verify_premium_chest(player, relic_system)
	await _verify_chest_source_pools(player, relic_system)
	await _verify_boss_chest(player)

	_expect(_opened_count == 6, "Each test chest should emit chest_opened once")
	_finish()


func _verify_normal_chest(player: Player) -> void:
	var chest := NORMAL_CHEST.instantiate()
	get_tree().root.add_child(chest)
	chest.global_position = Vector2(-1000, -1000)
	player.global_position = chest.global_position
	for index in range(3):
		await get_tree().physics_frame
		await get_tree().process_frame
	_expect(not bool(chest.call("is_opened")), "Touching a chest should not open it without interaction")
	chest.set("drop_pool", PackedStringArray(["gold"]))
	chest.set("reward_count", 1)
	chest.set("gold_min", 11)
	chest.set("gold_max", 11)
	var gold_before := player.current_gold
	_expect(bool(chest.call("open_for_player", player)), "Normal chest should open for player")
	_expect(player.current_gold == gold_before + 11, "Normal chest should grant configured gold")
	_expect(bool(chest.call("is_opened")), "Normal chest should stay opened")
	_expect(not bool(chest.call("open_for_player", player)), "Opened normal chest should not open twice")


func _verify_premium_chest(player: Player, relic_system: Node) -> void:
	var chest := PREMIUM_CHEST.instantiate()
	get_tree().root.add_child(chest)
	chest.set("drop_pool", PackedStringArray(["heal", "relic"]))
	chest.set("reward_count", 2)
	chest.set("heal_amount", 2)
	player.current_health = player.max_health - 2
	player.health_changed.emit(player.current_health, player.max_health)
	var health_before := player.current_health
	var relic_count_before := int(relic_system.call("get_relic_count"))
	_expect(bool(chest.call("open_for_player", player)), "Premium chest should open for player")
	_expect(player.current_health > health_before, "Premium chest should heal when heal is in drop pool")
	_expect(int(relic_system.call("get_relic_count")) > relic_count_before, "Premium chest should grant a relic when relic is in drop pool")


func _verify_boss_chest(player: Player) -> void:
	var chest := BOSS_CHEST.instantiate()
	get_tree().root.add_child(chest)
	_expect(bool(chest.get("complete_run_on_open")), "Boss chest should complete run on open")
	_expect(bool(chest.call("open_for_player", player)), "Boss chest should open for player")
	await get_tree().process_frame
	_expect(_run_completed_seen, "Boss chest should emit run_completed")


func _verify_chest_source_pools(player: Player, relic_system: Node) -> void:
	_expect(relic_system.has_method("get_source_pool_ids"), "RelicSystem should expose source pool ids for chest checks")
	if not relic_system.has_method("get_source_pool_ids"):
		return

	var normal_ids: Array = relic_system.call("get_source_pool_ids", "normal_chest")
	var premium_ids: Array = relic_system.call("get_source_pool_ids", "premium_chest")
	var boss_ids: Array = relic_system.call("get_source_pool_ids", "boss_chest")
	var normal_relic: String = await _open_single_relic_chest(NORMAL_CHEST, "normal", player, relic_system)
	var premium_relic: String = await _open_single_relic_chest(PREMIUM_CHEST, "premium", player, relic_system)
	var boss_relic: String = await _open_single_relic_chest(BOSS_CHEST, "boss", player, relic_system)
	_expect(normal_ids.has(normal_relic), "Normal chest relic should come from normal chest source pool")
	_expect(premium_ids.has(premium_relic), "Premium chest relic should come from premium chest source pool")
	_expect(boss_ids.has(boss_relic), "Boss chest relic should come from boss chest source pool")


func _open_single_relic_chest(scene: PackedScene, type_name: String, player: Player, relic_system: Node) -> String:
	var chest := scene.instantiate()
	get_tree().root.add_child(chest)
	chest.set("chest_type", type_name)
	chest.set("drop_pool", PackedStringArray(["relic"]))
	chest.set("reward_count", 1)
	chest.set("complete_run_on_open", false)
	var before: Array = relic_system.call("get_relic_summaries")
	_expect(bool(chest.call("open_for_player", player)), "%s source chest should open for player" % type_name)
	await get_tree().process_frame
	var after: Array = relic_system.call("get_relic_summaries")
	for summary in after:
		if not summary is Dictionary:
			continue
		var id := str(summary.get("id", ""))
		if _summary_stack_for(before, id) < int(summary.get("stacks", 0)):
			return id
	return ""


func _summary_stack_for(summaries: Array, relic_id: String) -> int:
	for summary in summaries:
		if summary is Dictionary and str(summary.get("id", "")) == relic_id:
			return int(summary.get("stacks", 0))
	return 0


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	get_tree().paused = false
	if _failures.is_empty():
		print("ChestSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

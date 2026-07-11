extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const CONTENT_ICON_REGISTRY := preload("res://scripts/content/ContentIconRegistry.gd")
const REWARD_CHEST_SCRIPT := preload("res://scripts/chests/RewardChest.gd")

var _failures: Array[String] = []
var _talents_seen := 0
var _talent_choices_seen := 0


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	Events.talent_choice_requested.connect(func(_choices: Array, _source_node: Node, _collector: Node) -> void:
		_talent_choices_seen += 1
	)
	Events.talent_collected.connect(func(_talent_data: Resource, _stack_count: int) -> void:
		_talents_seen += 1
	)

	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	await get_tree().physics_frame

	var player := main.get_node_or_null("Player") as Player
	var hud = main.get_node_or_null("CanvasLayer/HUD")
	var talent_system := main.get_node_or_null("TalentSystem")
	_expect(player != null, "Player should exist")
	_expect(hud != null, "HUD should exist")
	_expect(talent_system != null, "TalentSystem should exist")
	if player == null or hud == null or talent_system == null:
		_finish()
		return

	_expect(talent_system.has_method("get_reward_choices"), "TalentSystem should expose reward choices")
	_expect(talent_system.has_method("obtain_talent"), "TalentSystem should obtain talents")
	_expect((talent_system.get("available_talents") as Array).size() >= 3, "TalentSystem should expose at least three talents")
	if talent_system.has_method("set_random_seed"):
		talent_system.call("set_random_seed", 20260702)

	main.call("start_new_run")
	await get_tree().process_frame
	await get_tree().physics_frame

	var damage_before := float(player.call("get_damage_multiplier"))
	var fire_rate_before := float(player.call("get_fire_rate_multiplier"))
	var max_health_before := player.max_health

	Events.chest_opened.emit(main, player, "boss")
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(_talent_choices_seen == 1, "Non-final boss chest should request a talent choice")
	_expect(hud.has_method("is_talent_choice_visible") and bool(hud.call("is_talent_choice_visible")), "HUD should show a talent choice panel")
	_expect(str(hud.call("get_choice_panel_title_text")) == "Choose a Talent", "Talent choice panel should use talent title")
	_expect(int(hud.call("get_relic_choice_count")) == 3, "Talent choice should present three options")
	_expect(str(hud.call("get_relic_choice_text", 0)).contains("["), "Talent choice text should include rarity")
	var pending_talent_choices: Array = main.get("_pending_talent_choices")
	if pending_talent_choices.size() > 0:
		var first_talent := pending_talent_choices[0] as Resource
		if first_talent != null:
			var expected_icon_key := _resolve_choice_icon_key(first_talent, "talent")
			_expect(str(hud.call("get_relic_choice_icon_key", 0)) == expected_icon_key, "Talent choice icon key should resolve from talent data")
			_expect(str(hud.call("get_relic_choice_icon_texture_path", 0)) == CONTENT_ICON_REGISTRY.get_texture_path(expected_icon_key, "talents"), "Talent choice icon texture should come from the content icon registry")
			_expect(bool(hud.call("is_relic_choice_icon_visible", 0)), "Talent choice icon should be visible when registry texture exists")
			if hud.has_method("get_relic_choice_icon_tooltip_text"):
				_expect(str(hud.call("get_relic_choice_icon_tooltip_text", 0)).contains(expected_icon_key), "Talent choice icon tooltip should include icon key")

	if hud.has_method("choose_talent_for_test"):
		hud.call("choose_talent_for_test", 0)
	else:
		hud.call("choose_relic_for_test", 0)
	for _index in range(3):
		await get_tree().physics_frame
		await get_tree().process_frame

	_expect(_talents_seen == 1, "Choosing a talent should emit talent_collected")
	_expect(int(talent_system.call("get_talent_count")) == 1, "TalentSystem should record the chosen talent")
	_expect(not bool(hud.call("is_talent_choice_visible")), "Talent choice panel should close after selection")
	var changed_stats := (
		float(player.call("get_damage_multiplier")) > damage_before
		or float(player.call("get_fire_rate_multiplier")) > fire_rate_before
		or player.max_health > max_health_before
	)
	_expect(changed_stats, "Chosen talent should apply a real player stat effect")

	var summary: Dictionary = main.call("get_run_summary")
	_expect(int(summary.get("talent_count", 0)) == 1, "Run summary should include selected talent count")
	var talent_names: Array = summary.get("talent_names", [])
	_expect(talent_names.size() == 1, "Run summary should include selected talent name")

	var final_chest = REWARD_CHEST_SCRIPT.new()
	final_chest.set("complete_run_on_open", true)
	Events.chest_opened.emit(final_chest, player, "boss")
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(_talent_choices_seen == 1, "Final boss chest should not request an extra talent choice")
	final_chest.free()

	get_tree().paused = false
	main.queue_free()
	await get_tree().process_frame
	_finish()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _resolve_choice_icon_key(choice: Resource, content_type: String) -> String:
	var explicit_key := str(choice.get("icon_key")).strip_edges()
	if not explicit_key.is_empty():
		return explicit_key
	return "%s_%s" % [content_type, str(choice.get("id")).strip_edges()]


func _finish() -> void:
	get_tree().paused = false
	if _failures.is_empty():
		print("TalentSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

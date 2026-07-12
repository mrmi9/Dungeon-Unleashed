extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const CONTENT_ICON_REGISTRY := preload("res://scripts/content/ContentIconRegistry.gd")
const EVENT_SHRINE_SCENE := preload("res://scenes/events/EventShrine.tscn")
const SHOP_ITEM_SCENE := preload("res://scenes/shop/ShopItem.tscn")
const CURSED_EVENT_WEAPON := preload("res://resources/weapons/blast_launcher.tres")
const ROOM_CLEAR_BLESSING := preload("res://resources/blessings/afterglow_circuit.tres")
const KILL_BLESSING := preload("res://resources/blessings/spark_dividend.tres")
const HURT_BLESSING := preload("res://resources/blessings/brace_current.tres")
const RESONANCE_BATTERY := preload("res://resources/blessings/resonance_battery.tres")
const BULWARK_IDOL := preload("res://resources/statues/bulwark_idol.tres")
const ECHO_RESERVOIR := preload("res://resources/statues/echo_reservoir.tres")

var _failures: Array[String] = []
var _events_seen := 0
var _rewards_seen := 0
var _blessings_seen := 0
var _blessing_triggers_seen := 0
var _last_blessing_trigger_id := ""
var _last_blessing_trigger_event := ""
var _statues_seen := 0
var _statue_triggers_seen := 0
var _last_statue_trigger_id := ""
var _last_statue_trigger_event := ""
var _statue_attunements_seen := 0
var _last_attuned_statue_id := ""
var _last_attunement_count := 0


func _ready() -> void:
	call_deferred("_run")


func _verify_cursed_weapon_drop_table_contract() -> void:
	var shrine := EVENT_SHRINE_SCENE.instantiate()
	_expect(str(shrine.call("get_cursed_weapon_reward_source_id")) == "cursed_event", "Event shrine should use the cursed weapon source table")
	_expect((shrine.call("get_cursed_weapon_reward_pool_ids") as PackedStringArray).size() == 15, "Cursed event source should expose all Epic+ weapons")
	shrine.free()


func _run() -> void:
	Events.special_event_resolved.connect(func(_event_node: Node, _player: Node, _event_id: String, _outcome_id: String) -> void:
		_events_seen += 1
	)
	Events.reward_collected.connect(func(_reward: Node, _collector: Node) -> void:
		_rewards_seen += 1
	)
	Events.blessing_collected.connect(func(_blessing_data: Resource, _stack_count: int) -> void:
		_blessings_seen += 1
	)
	Events.blessing_triggered.connect(func(blessing_data: Resource, trigger_event: String, _effect_type: String, _effect_value: float) -> void:
		_blessing_triggers_seen += 1
		_last_blessing_trigger_id = str(blessing_data.get("id")) if blessing_data != null else ""
		_last_blessing_trigger_event = trigger_event
	)
	Events.statue_collected.connect(func(_statue_data: Resource, _stack_count: int) -> void:
		_statues_seen += 1
	)
	Events.statue_triggered.connect(func(statue_data: Resource, trigger_event: String, _effect_type: String, _effect_value: float) -> void:
		_statue_triggers_seen += 1
		_last_statue_trigger_id = str(statue_data.get("id")) if statue_data != null else ""
		_last_statue_trigger_event = trigger_event
	)
	Events.statue_attuned.connect(func(statue_data: Resource, attunement_count: int) -> void:
		_statue_attunements_seen += 1
		_last_attuned_statue_id = str(statue_data.get("id")) if statue_data != null else ""
		_last_attunement_count = attunement_count
	)

	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	main.call("start_new_run")

	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().create_timer(0.15).timeout

	var player := main.get_node_or_null("Player") as Player
	var hud = main.get_node_or_null("CanvasLayer/HUD")
	var blessing_system := main.get_node_or_null("BlessingSystem")
	var statue_system := main.get_node_or_null("StatueSystem")
	_expect(player != null, "Player should exist")
	_expect(hud != null, "HUD should exist")
	_expect(blessing_system != null, "BlessingSystem should exist")
	_expect(statue_system != null, "StatueSystem should exist")
	if player == null or hud == null or blessing_system == null or statue_system == null:
		_finish()
		return

	_verify_cursed_weapon_drop_table_contract()
	await _verify_event_shrine_touch_does_not_trigger(main, player)
	await _verify_room_clear_blessing_trigger(player, blessing_system, hud)
	await _verify_kill_and_hurt_blessing_triggers(player, blessing_system)
	await _verify_skill_statue_trigger(player, statue_system, hud)
	await _verify_statue_blessing_synergy(player, blessing_system, statue_system)
	await _verify_event_shrine_activation(main, player, hud, blessing_system)
	await _verify_event_shrine_statue_choice(main, player, hud, statue_system)
	await _verify_event_shrine_statue_attunement(main, player, hud, statue_system)
	await _verify_event_shrine_shop_discount(main, player)
	await _verify_event_shrine_cursed_weapon(main, player)
	await _verify_event_shrine_temporary_rule(main, player)
	await _verify_event_shrine_low_health_rejection(main, player)

	_finish()


func _verify_event_shrine_touch_does_not_trigger(main: Node, player: Player) -> void:
	var shrine := _spawn_shrine(main, Vector2(900, -900))
	shrine.set("gold_min", 10)
	shrine.set("gold_max", 10)
	var health_before := player.current_health
	var gold_before := player.current_gold
	player.global_position = shrine.global_position
	for _index in range(4):
		await get_tree().physics_frame
		await get_tree().process_frame
	_expect(not bool(shrine.call("is_claimed")), "Touching event shrine should not resolve it without interaction")
	_expect(player.current_health == health_before, "Touching event shrine should not spend health")
	_expect(player.current_gold == gold_before, "Touching event shrine should not grant gold")
	shrine.queue_free()


func _verify_event_shrine_activation(main: Node, player: Player, hud: Node, blessing_system: Node) -> void:
	var shrine := _spawn_shrine(main, Vector2(980, -900))
	shrine.set("gold_min", 10)
	shrine.set("gold_max", 10)
	shrine.set("biome_id", "void_foundry")
	shrine.set("biome_name", "Void Foundry")
	shrine.set("biome_reward_weight_multiplier", 1.16)
	_expect(shrine.has_method("get_biome_reward_summary"), "Event shrine should expose biome reward summary")
	if shrine.has_method("get_biome_reward_summary"):
		var reward_summary: Dictionary = shrine.call("get_biome_reward_summary")
		_expect(str(reward_summary.get("biome_id", "")) == "void_foundry", "Event shrine should preserve biome reward id")
		_expect(is_equal_approx(float(reward_summary.get("reward_weight_multiplier", 0.0)), 1.16), "Event shrine should preserve biome reward weight multiplier")
	var health_before := player.current_health
	var gold_before := player.current_gold
	var blessing_count_before := int(blessing_system.call("get_blessing_count"))
	var events_before := _events_seen
	var rewards_before := _rewards_seen
	var blessings_before := _blessings_seen
	_expect(bool(shrine.call("activate_for_player", player)), "Event shrine should resolve for a healthy player")
	await get_tree().process_frame
	_expect(bool(shrine.call("is_claimed")), "Resolved event shrine should stay claimed")
	_expect(player.current_health == health_before - 1, "Event shrine should spend one health")
	_expect(player.current_gold == gold_before + 12, "Event shrine should apply biome reward multiplier to configured gold")
	_expect(_events_seen == events_before + 1, "Event shrine should emit special_event_resolved")
	_expect(hud.has_method("is_blessing_choice_visible") and bool(hud.call("is_blessing_choice_visible")), "Event shrine should open blessing choice")
	var pending_blessing_choices: Array = main.get("_pending_blessing_choices")
	if pending_blessing_choices.size() > 0:
		var first_blessing := pending_blessing_choices[0] as Resource
		if first_blessing != null:
			var expected_icon_key := _resolve_choice_icon_key(first_blessing, "blessing")
			_expect(str(hud.call("get_relic_choice_icon_key", 0)) == expected_icon_key, "Blessing choice icon key should resolve from blessing data")
			_expect(str(hud.call("get_relic_choice_icon_texture_path", 0)) == CONTENT_ICON_REGISTRY.get_texture_path(expected_icon_key, "blessings"), "Blessing choice icon texture should come from the content icon registry")
			_expect(bool(hud.call("is_relic_choice_icon_visible", 0)), "Blessing choice icon should be visible when registry texture exists")
			if hud.has_method("get_relic_choice_icon_tooltip_text"):
				_expect(str(hud.call("get_relic_choice_icon_tooltip_text", 0)).contains(expected_icon_key), "Blessing choice icon tooltip should include icon key")
	if hud.has_method("choose_blessing_for_test"):
		hud.call("choose_blessing_for_test", 0)
		for _index in range(3):
			await get_tree().physics_frame
			await get_tree().process_frame
	_expect(_rewards_seen == rewards_before + 1, "Event shrine blessing choice should emit reward_collected")
	_expect(_blessings_seen == blessings_before + 1, "Event shrine should emit blessing_collected")
	_expect(int(blessing_system.call("get_blessing_count")) > blessing_count_before, "Event shrine should grant a blessing reward")


func _verify_room_clear_blessing_trigger(player: Player, blessing_system: Node, hud: Node) -> void:
	_expect(blessing_system.has_method("obtain_blessing"), "BlessingSystem should expose obtain_blessing")
	_expect(ROOM_CLEAR_BLESSING != null, "Room clear blessing resource should load")
	if ROOM_CLEAR_BLESSING == null or not blessing_system.has_method("obtain_blessing"):
		return

	var summaries_before: Array = blessing_system.call("get_blessing_summaries")
	_expect(bool(blessing_system.call("obtain_blessing", ROOM_CLEAR_BLESSING)), "Room clear blessing should be obtainable")
	var summaries_after: Array = blessing_system.call("get_blessing_summaries")
	_expect(summaries_after.size() == summaries_before.size() + 1, "Obtaining room clear blessing should add one blessing summary")
	var found_summary := false
	for summary in summaries_after:
		if summary is Dictionary and str((summary as Dictionary).get("id", "")) == "afterglow_circuit":
			found_summary = true
			_expect(str((summary as Dictionary).get("trigger_event", "")) == "on_room_clear", "Room clear blessing summary should preserve trigger event")
			_expect(str((summary as Dictionary).get("effect_type", "")) == "recover_energy", "Room clear blessing summary should preserve effect type")
	_expect(found_summary, "Room clear blessing summary should be present after obtain")

	player.current_energy = maxi(player.max_energy - 30, 0)
	player.set("_energy_regen_accumulator", 0.0)
	player.set("_energy_regen_delay_timer", 999.0)
	player.energy_changed.emit(player.current_energy, player.max_energy)
	var energy_before := player.current_energy
	var triggers_before := _blessing_triggers_seen
	Events.room_cleared.emit(null)
	await get_tree().process_frame
	_expect(player.current_energy == mini(energy_before + 12, player.max_energy), "Room clear blessing should restore energy when a room is cleared")
	_expect(_blessing_triggers_seen == triggers_before + 1, "Room clear blessing should emit blessing_triggered")
	_expect(_last_blessing_trigger_id == "afterglow_circuit", "Room clear blessing trigger should identify the blessing")
	_expect(_last_blessing_trigger_event == "on_room_clear", "Room clear blessing trigger should identify the trigger event")
	_expect_rule_feedback(hud, "Blessing", str(ROOM_CLEAR_BLESSING.get("display_name")), "blessing", _resolve_choice_icon_key(ROOM_CLEAR_BLESSING, "blessing"), "blessings")
	_expect_rule_feedback_fades(hud)


func _verify_kill_and_hurt_blessing_triggers(player: Player, blessing_system: Node) -> void:
	_expect(KILL_BLESSING != null, "Kill blessing resource should load")
	_expect(HURT_BLESSING != null, "Hurt blessing resource should load")
	if KILL_BLESSING == null or HURT_BLESSING == null or not blessing_system.has_method("obtain_blessing"):
		return

	_expect(bool(blessing_system.call("obtain_blessing", KILL_BLESSING)), "Kill blessing should be obtainable")
	_expect(bool(blessing_system.call("obtain_blessing", HURT_BLESSING)), "Hurt blessing should be obtainable")

	var summaries: Array = blessing_system.call("get_blessing_summaries")
	var found_kill_summary := false
	var found_hurt_summary := false
	for summary in summaries:
		if not summary is Dictionary:
			continue
		var blessing_id := str((summary as Dictionary).get("id", ""))
		if blessing_id == "spark_dividend":
			found_kill_summary = true
			_expect(str((summary as Dictionary).get("trigger_event", "")) == "on_kill", "Kill blessing summary should preserve trigger event")
			_expect(int((summary as Dictionary).get("trigger_interval", 0)) == 3, "Kill blessing summary should preserve trigger interval")
		elif blessing_id == "brace_current":
			found_hurt_summary = true
			_expect(str((summary as Dictionary).get("trigger_event", "")) == "on_hurt", "Hurt blessing summary should preserve trigger event")
			_expect(int((summary as Dictionary).get("trigger_interval", 0)) == 1, "Hurt blessing summary should preserve trigger interval")
	_expect(found_kill_summary, "Kill blessing summary should be present after obtain")
	_expect(found_hurt_summary, "Hurt blessing summary should be present after obtain")

	player.current_energy = maxi(player.max_energy - 30, 0)
	player.set("_energy_regen_accumulator", 0.0)
	player.set("_energy_regen_delay_timer", 999.0)
	player.energy_changed.emit(player.current_energy, player.max_energy)
	var energy_before := player.current_energy
	var triggers_before := _blessing_triggers_seen
	Events.enemy_died.emit(null)
	Events.enemy_died.emit(null)
	await get_tree().process_frame
	_expect(player.current_energy == energy_before, "Kill blessing should wait for its trigger interval")
	_expect(_blessing_triggers_seen == triggers_before, "Kill blessing should not emit before its trigger interval")
	Events.enemy_died.emit(null)
	await get_tree().process_frame
	_expect(player.current_energy == mini(energy_before + 6, player.max_energy), "Kill blessing should restore energy on its third kill trigger")
	_expect(_blessing_triggers_seen == triggers_before + 1, "Kill blessing should emit blessing_triggered on its third kill")
	_expect(_last_blessing_trigger_id == "spark_dividend", "Kill blessing trigger should identify the blessing")
	_expect(_last_blessing_trigger_event == "on_kill", "Kill blessing trigger should identify the trigger event")

	player.current_shield = 0
	player.shield_changed.emit(player.current_shield)
	triggers_before = _blessing_triggers_seen
	Events.player_damaged.emit(1, player.current_health)
	await get_tree().process_frame
	_expect(player.current_shield == mini(1, player.max_shield), "Hurt blessing should recover armor after HP damage")
	_expect(_blessing_triggers_seen == triggers_before + 1, "Hurt blessing should emit blessing_triggered")
	_expect(_last_blessing_trigger_id == "brace_current", "Hurt blessing trigger should identify the blessing")
	_expect(_last_blessing_trigger_event == "on_hurt", "Hurt blessing trigger should identify the trigger event")


func _verify_skill_statue_trigger(player: Player, statue_system: Node, hud: Node) -> void:
	_expect(statue_system.has_method("obtain_statue"), "StatueSystem should expose obtain_statue")
	_expect(BULWARK_IDOL != null, "Bulwark Idol resource should load")
	if BULWARK_IDOL == null or not statue_system.has_method("obtain_statue"):
		return

	var statues_before := _statues_seen
	_expect(bool(statue_system.call("obtain_statue", BULWARK_IDOL)), "Skill statue should be obtainable")
	_expect(_statues_seen == statues_before + 1, "Obtaining a statue should emit statue_collected")
	var summaries: Array = statue_system.call("get_statue_summaries")
	var found_summary := false
	for summary in summaries:
		if summary is Dictionary and str((summary as Dictionary).get("id", "")) == "bulwark_idol":
			found_summary = true
			_expect(str((summary as Dictionary).get("trigger_event", "")) == "on_skill_used", "Statue summary should preserve trigger event")
			_expect(str((summary as Dictionary).get("effect_type", "")) == "gain_shield", "Statue summary should preserve effect type")
	_expect(found_summary, "Statue summary should be present after obtain")

	player.current_shield = 0
	player.shield_changed.emit(player.current_shield)
	player.current_energy = player.max_energy
	player.energy_changed.emit(player.current_energy, player.max_energy)
	player.set("_skill_cooldown_timer", 0.0)
	player.set("_skill_active_timer", 0.0)
	var triggers_before := _statue_triggers_seen
	_expect(player.try_use_skill(), "Using a ready skill should succeed for statue trigger coverage")
	await get_tree().process_frame
	_expect(player.current_shield == mini(1, player.max_shield), "Skill statue should recover armor after skill use")
	_expect(_statue_triggers_seen == triggers_before + 1, "Skill statue should emit statue_triggered")
	_expect(_last_statue_trigger_id == "bulwark_idol", "Statue trigger should identify the statue")
	_expect(_last_statue_trigger_event == "on_skill_used", "Statue trigger should identify the trigger event")
	_expect_rule_feedback(hud, "Statue", str(BULWARK_IDOL.get("display_name")), "statue", _resolve_choice_icon_key(BULWARK_IDOL, "statue"), "statues")


func _verify_statue_blessing_synergy(player: Player, blessing_system: Node, statue_system: Node) -> void:
	_expect(RESONANCE_BATTERY != null, "Resonance Battery resource should load")
	if RESONANCE_BATTERY == null or not blessing_system.has_method("obtain_blessing"):
		return

	if int(statue_system.call("get_statue_count")) <= 0:
		_expect(bool(statue_system.call("obtain_statue", BULWARK_IDOL)), "Statue synergy test should have a skill statue")

	_expect(bool(blessing_system.call("obtain_blessing", RESONANCE_BATTERY)), "Statue-linked blessing should be obtainable")
	var summaries: Array = blessing_system.call("get_blessing_summaries")
	var found_summary := false
	for summary in summaries:
		if summary is Dictionary and str((summary as Dictionary).get("id", "")) == "resonance_battery":
			found_summary = true
			_expect(str((summary as Dictionary).get("trigger_event", "")) == "on_statue_triggered", "Statue-linked blessing summary should preserve trigger event")
			_expect(str((summary as Dictionary).get("effect_type", "")) == "recover_energy", "Statue-linked blessing summary should preserve effect type")
	_expect(found_summary, "Statue-linked blessing summary should be present after obtain")

	var skill_summary: Dictionary = player.get_skill_summary()
	var skill_cost := maxi(int(skill_summary.get("energy_cost", 0)), 0)
	player.current_energy = mini(player.max_energy - 10, player.max_energy)
	player.current_energy = maxi(player.current_energy, skill_cost + 1)
	player.set("_energy_regen_accumulator", 0.0)
	player.set("_energy_regen_delay_timer", 999.0)
	player.set("_skill_cooldown_timer", 0.0)
	player.set("_skill_active_timer", 0.0)
	player.energy_changed.emit(player.current_energy, player.max_energy)
	var energy_before := player.current_energy
	var expected_energy := mini(energy_before - skill_cost + 5, player.max_energy)
	var blessing_triggers_before := _blessing_triggers_seen
	var statue_triggers_before := _statue_triggers_seen
	_expect(player.try_use_skill(), "Using a ready skill should trigger statue-linked blessing coverage")
	await get_tree().process_frame
	_expect(_statue_triggers_seen == statue_triggers_before + 1, "Statue-linked blessing test should trigger a statue")
	_expect(_blessing_triggers_seen == blessing_triggers_before + 1, "Statue-linked blessing should emit blessing_triggered")
	_expect(_last_blessing_trigger_id == "resonance_battery", "Statue-linked blessing trigger should identify the blessing")
	_expect(_last_blessing_trigger_event == "on_statue_triggered", "Statue-linked blessing trigger should identify the trigger event")
	_expect(player.current_energy == expected_energy, "Statue-linked blessing should restore energy after statue trigger")


func _verify_event_shrine_statue_choice(main: Node, player: Player, hud: Node, statue_system: Node) -> void:
	var shrine := _spawn_shrine(main, Vector2(1020, -960), "manual")
	shrine.set("event_id", "resonant_statue")
	shrine.set("outcome_id", "sacrifice_for_statue")
	shrine.set("display_name", "Resonant Statue")
	shrine.set("reward_mode", "statue_choice")
	shrine.set("health_cost", 1)
	shrine.set("gold_min", 10)
	shrine.set("gold_max", 10)
	_expect(shrine.has_method("get_event_summary"), "Statue event shrine should expose event summary")
	if shrine.has_method("get_event_summary"):
		var event_summary: Dictionary = shrine.call("get_event_summary")
		_expect(str(event_summary.get("reward_mode", "")) == "statue_choice", "Statue event summary should preserve reward mode")

	player.current_health = player.max_health
	player.health_changed.emit(player.current_health, player.max_health)
	var statue_count_before := int(statue_system.call("get_statue_count"))
	var statues_before := _statues_seen
	_expect(bool(shrine.call("activate_for_player", player)), "Statue event shrine should resolve for a healthy player")
	await get_tree().process_frame
	_expect(hud.has_method("is_statue_choice_visible") and bool(hud.call("is_statue_choice_visible")), "Statue event should open statue choice")
	if hud.has_method("choose_statue_for_test"):
		hud.call("choose_statue_for_test", 0)
		for _index in range(3):
			await get_tree().physics_frame
			await get_tree().process_frame
	_expect(_statues_seen == statues_before + 1, "Statue event choice should emit statue_collected")
	_expect(int(statue_system.call("get_statue_count")) > statue_count_before, "Statue event should grant a statue reward")


func _verify_event_shrine_statue_attunement(main: Node, player: Player, hud: Node, statue_system: Node) -> void:
	_expect(ECHO_RESERVOIR != null, "Echo Reservoir resource should load")
	_expect(statue_system.has_method("attune_statue"), "StatueSystem should expose attune_statue")
	_expect(statue_system.has_method("get_attunement_count"), "StatueSystem should expose get_attunement_count")
	if ECHO_RESERVOIR == null or not statue_system.has_method("attune_statue") or not statue_system.has_method("get_attunement_count"):
		return

	if int(statue_system.call("get_stack_count", "echo_reservoir")) <= 0:
		_expect(bool(statue_system.call("obtain_statue", ECHO_RESERVOIR)), "Attunement test should obtain Echo Reservoir")

	var attunements_before := int(statue_system.call("get_attunement_count", "echo_reservoir"))
	var shrine := _spawn_shrine(main, Vector2(1100, -960), "manual")
	shrine.set("event_id", "resonance_tuning")
	shrine.set("outcome_id", "attune_statue")
	shrine.set("display_name", "Resonance Tuning")
	shrine.set("reward_mode", "statue_attunement")
	shrine.set("statue_attunement_target_id", "echo_reservoir")
	shrine.set("health_cost", 1)
	shrine.set("gold_min", 0)
	shrine.set("gold_max", 0)
	_expect(shrine.has_method("get_event_summary"), "Statue attunement event shrine should expose event summary")
	if shrine.has_method("get_event_summary"):
		var event_summary: Dictionary = shrine.call("get_event_summary")
		_expect(str(event_summary.get("reward_mode", "")) == "statue_attunement", "Statue attunement event summary should preserve reward mode")
		_expect(str(event_summary.get("statue_attunement_target_id", "")) == "echo_reservoir", "Statue attunement event summary should preserve target id")

	player.current_health = player.max_health
	player.health_changed.emit(player.current_health, player.max_health)
	var events_before := _events_seen
	var rewards_before := _rewards_seen
	var signal_count_before := _statue_attunements_seen
	_expect(bool(shrine.call("activate_for_player", player)), "Statue attunement event shrine should resolve for a healthy player")
	await get_tree().process_frame
	_expect(bool(shrine.call("is_claimed")), "Statue attunement shrine should stay claimed")
	_expect(_events_seen == events_before + 1, "Statue attunement event should emit special_event_resolved")
	_expect(_rewards_seen == rewards_before + 1, "Statue attunement event should emit reward_collected")
	_expect(_statue_attunements_seen == signal_count_before + 1, "Statue attunement event should emit statue_attuned")
	_expect(_last_attuned_statue_id == "echo_reservoir", "Statue attunement signal should identify the target statue")
	_expect(_last_attunement_count == attunements_before + 1, "Statue attunement signal should report the new count")
	_expect(int(statue_system.call("get_attunement_count", "echo_reservoir")) == attunements_before + 1, "Statue attunement event should increase attunement count")
	_expect_rule_feedback(hud, "Statue", str(ECHO_RESERVOIR.get("display_name")), "statue", _resolve_choice_icon_key(ECHO_RESERVOIR, "statue"), "statues")

	var found_summary := false
	var summaries: Array = statue_system.call("get_statue_summaries")
	for summary in summaries:
		if not (summary is Dictionary):
			continue
		if str((summary as Dictionary).get("id", "")) != "echo_reservoir":
			continue
		found_summary = true
		var expected_attunements := attunements_before + 1
		_expect(int((summary as Dictionary).get("attunements", 0)) == expected_attunements, "Attuned statue summary should expose attunement count")
		_expect(int((summary as Dictionary).get("trigger_interval", 0)) == 2, "Attuned statue summary should preserve base trigger interval")
		_expect(int((summary as Dictionary).get("effective_trigger_interval", 0)) == 1, "Attuned statue should reduce Echo Reservoir trigger interval to one")
		_expect(is_equal_approx(float((summary as Dictionary).get("effect_value", 0.0)), 8.0), "Attuned statue summary should preserve base effect value")
		_expect(is_equal_approx(float((summary as Dictionary).get("effective_effect_value", 0.0)), 8.0 + float(expected_attunements)), "Attuned statue summary should expose scaled effect value")
	_expect(found_summary, "Attuned statue summary should include Echo Reservoir")
	shrine.queue_free()


func _verify_event_shrine_shop_discount(main: Node, player: Player) -> void:
	var shrine := _spawn_shrine(main, Vector2(1060, -900), "manual")
	shrine.set("event_id", "merchant_oath")
	shrine.set("outcome_id", "shop_discount")
	shrine.set("display_name", "Merchant Oath")
	shrine.set("reward_mode", "shop_discount")
	shrine.set("health_cost", 1)
	shrine.set("gold_min", 0)
	shrine.set("gold_max", 0)
	shrine.set("shop_discount_multiplier", 0.5)
	shrine.set("shop_discount_charges", 1)
	_expect(shrine.has_method("get_event_summary"), "Event shrine should expose event summary")
	if shrine.has_method("get_event_summary"):
		var event_summary: Dictionary = shrine.call("get_event_summary")
		_expect(str(event_summary.get("reward_mode", "")) == "shop_discount", "Event shrine summary should preserve reward mode")
		_expect(str(event_summary.get("outcome_id", "")) == "shop_discount", "Event shrine summary should preserve outcome id")

	player.current_health = player.max_health
	player.health_changed.emit(player.current_health, player.max_health)
	var events_before := _events_seen
	var rewards_before := _rewards_seen
	_expect(bool(shrine.call("activate_for_player", player)), "Shop discount event shrine should resolve for a healthy player")
	await get_tree().process_frame
	_expect(_events_seen == events_before + 1, "Shop discount event should emit special_event_resolved")
	_expect(_rewards_seen == rewards_before + 1, "Shop discount event should emit reward_collected")
	var discount_summary: Dictionary = player.call("get_shop_discount_summary")
	_expect(bool(discount_summary.get("active", false)), "Shop discount event should activate a player shop discount")
	_expect(is_equal_approx(float(discount_summary.get("multiplier", 0.0)), 0.5), "Shop discount event should preserve multiplier")
	_expect(int(discount_summary.get("charges", 0)) == 1, "Shop discount event should grant one charge")

	var item := _spawn_direct_shop_item(100)
	player.current_gold = 100
	player.gold_changed.emit(player.current_gold)
	_expect(int(item.call("get_purchase_price_for_player", player)) == 50, "Shop item should expose discounted price for event discount")
	_expect(bool(item.call("purchase_for_player", player)), "Discounted shop item should be purchasable")
	await get_tree().process_frame
	_expect(player.current_gold == 50, "Discounted shop item should spend discounted price")
	discount_summary = player.call("get_shop_discount_summary")
	_expect(not bool(discount_summary.get("active", true)), "Shop discount should be consumed after one successful purchase")
	item.queue_free()
	shrine.queue_free()


func _verify_event_shrine_cursed_weapon(main: Node, player: Player) -> void:
	var shrine := _spawn_shrine(main, Vector2(1140, -900), "manual")
	shrine.set("event_id", "cursed_armory")
	shrine.set("outcome_id", "curse_for_weapon")
	shrine.set("display_name", "Cursed Armory")
	shrine.set("reward_mode", "cursed_weapon")
	shrine.set("health_cost", 1)
	shrine.set("gold_min", 0)
	shrine.set("gold_max", 0)
	shrine.set("cursed_weapon_max_health_penalty", 1)
	var cursed_weapon_pool: Array[Resource] = [CURSED_EVENT_WEAPON]
	shrine.set("cursed_weapon_pool", cursed_weapon_pool)
	shrine.set("cursed_weapon_drop_table", null)
	_expect(shrine.has_method("get_event_summary"), "Cursed weapon event shrine should expose event summary")
	if shrine.has_method("get_event_summary"):
		var event_summary: Dictionary = shrine.call("get_event_summary")
		_expect(str(event_summary.get("reward_mode", "")) == "cursed_weapon", "Cursed weapon event summary should preserve reward mode")
		_expect(int(event_summary.get("cursed_weapon_max_health_penalty", 0)) == 1, "Cursed weapon event summary should preserve curse penalty")

	player.current_health = player.max_health
	player.health_changed.emit(player.current_health, player.max_health)
	var max_health_before := player.max_health
	var events_before := _events_seen
	var rewards_before := _rewards_seen
	_expect(bool(shrine.call("activate_for_player", player)), "Cursed weapon event shrine should resolve for a healthy player")
	await get_tree().process_frame
	_expect(_events_seen == events_before + 1, "Cursed weapon event should emit special_event_resolved")
	_expect(_rewards_seen == rewards_before + 1, "Cursed weapon event should emit reward_collected")
	_expect(player.max_health == max_health_before - 1, "Cursed weapon event should reduce max health")
	_expect(player.current_health == max_health_before - 1, "Cursed weapon event should clamp current health after curse")
	_expect(player.weapon != null and player.weapon.weapon_data == CURSED_EVENT_WEAPON, "Cursed weapon event should equip the configured weapon")
	var curse_summary: Dictionary = player.call("get_event_curse_summary")
	_expect(int(curse_summary.get("max_health_penalty", 0)) >= 1, "Cursed weapon event should record max health curse penalty")
	_expect(int(curse_summary.get("count", 0)) >= 1, "Cursed weapon event should record an event curse")
	shrine.queue_free()


func _verify_event_shrine_temporary_rule(main: Node, player: Player) -> void:
	var shrine := _spawn_shrine(main, Vector2(1220, -900), "manual")
	shrine.set("event_id", "overclock_trial")
	shrine.set("outcome_id", "temporary_overclock")
	shrine.set("display_name", "Overclock Trial")
	shrine.set("reward_mode", "temporary_rule")
	shrine.set("health_cost", 1)
	shrine.set("gold_min", 0)
	shrine.set("gold_max", 0)
	shrine.set("temporary_rule_id", "test_overclock")
	shrine.set("temporary_rule_damage_multiplier_bonus", 0.2)
	shrine.set("temporary_rule_fire_rate_multiplier_bonus", 0.15)
	shrine.set("temporary_rule_duration", 0.5)
	_expect(shrine.has_method("get_event_summary"), "Temporary rule event shrine should expose event summary")
	if shrine.has_method("get_event_summary"):
		var event_summary: Dictionary = shrine.call("get_event_summary")
		_expect(str(event_summary.get("reward_mode", "")) == "temporary_rule", "Temporary rule event summary should preserve reward mode")
		_expect(str(event_summary.get("temporary_rule_id", "")) == "test_overclock", "Temporary rule event summary should preserve rule id")
		_expect(is_equal_approx(float(event_summary.get("temporary_rule_duration", 0.0)), 0.5), "Temporary rule event summary should preserve duration")

	player.current_health = player.max_health
	player.health_changed.emit(player.current_health, player.max_health)
	var damage_before := player.get_damage_multiplier()
	var fire_rate_before := player.get_fire_rate_multiplier()
	var events_before := _events_seen
	var rewards_before := _rewards_seen
	_expect(bool(shrine.call("activate_for_player", player)), "Temporary rule event shrine should resolve for a healthy player")
	await get_tree().process_frame
	_expect(_events_seen == events_before + 1, "Temporary rule event should emit special_event_resolved")
	_expect(_rewards_seen == rewards_before + 1, "Temporary rule event should emit reward_collected")
	var temporary_rule_summary: Dictionary = player.call("get_temporary_rule_summary")
	_expect(bool(temporary_rule_summary.get("active", false)), "Temporary rule event should activate a timed player rule")
	_expect(str(temporary_rule_summary.get("id", "")) == "test_overclock", "Temporary rule should preserve rule id")
	_expect(is_equal_approx(player.get_damage_multiplier(), damage_before + 0.2), "Temporary rule should increase damage while active")
	_expect(is_equal_approx(player.get_fire_rate_multiplier(), fire_rate_before + 0.15), "Temporary rule should increase fire rate while active")
	await get_tree().create_timer(0.6).timeout
	await get_tree().process_frame
	temporary_rule_summary = player.call("get_temporary_rule_summary")
	_expect(not bool(temporary_rule_summary.get("active", true)), "Temporary rule should expire after its duration")
	_expect(is_equal_approx(player.get_damage_multiplier(), damage_before), "Temporary rule damage bonus should clear after expiry")
	_expect(is_equal_approx(player.get_fire_rate_multiplier(), fire_rate_before), "Temporary rule fire-rate bonus should clear after expiry")
	shrine.queue_free()


func _verify_event_shrine_low_health_rejection(main: Node, player: Player) -> void:
	var shrine := _spawn_shrine(main, Vector2(1300, -900))
	player.current_health = 1
	player.health_changed.emit(player.current_health, player.max_health)
	var gold_before := player.current_gold
	var events_before := _events_seen
	_expect(not bool(shrine.call("activate_for_player", player)), "Event shrine should reject activation at one health")
	_expect(not bool(shrine.call("is_claimed")), "Rejected event shrine should remain unclaimed")
	_expect(player.current_health == 1, "Rejected event shrine should not spend health")
	_expect(player.current_gold == gold_before, "Rejected event shrine should not grant gold")
	_expect(_events_seen == events_before, "Rejected event shrine should not emit event completion")
	shrine.queue_free()


func _spawn_shrine(main: Node, position: Vector2, event_variant: String = "blood_pact") -> Node2D:
	var shrine := EVENT_SHRINE_SCENE.instantiate() as Node2D
	shrine.set("event_variant", event_variant)
	main.add_child(shrine)
	shrine.global_position = position
	return shrine


func _spawn_direct_shop_item(price: int) -> Node2D:
	var item := SHOP_ITEM_SCENE.instantiate() as Node2D
	get_tree().root.add_child(item)
	item.global_position = Vector2(-1300, -1300)
	item.call("configure", ShopItem.ItemType.HEAL, price, null, 1)
	return item


func _expect_rule_feedback(hud: Node, kind: String, display_name: String, color_kind: String, expected_icon_key: String, expected_icon_page: String) -> void:
	_expect(hud.has_method("get_rule_feedback_text"), "HUD should expose rule feedback text for tests")
	if not hud.has_method("get_rule_feedback_text"):
		return

	var feedback_text := str(hud.call("get_rule_feedback_text"))
	_expect(feedback_text.contains("%s:" % kind), "HUD rule feedback should show %s trigger kind" % kind)
	if not display_name.strip_edges().is_empty():
		_expect(feedback_text.contains(display_name), "HUD rule feedback should show %s" % display_name)
	if hud.has_method("is_rule_feedback_active"):
		_expect(bool(hud.call("is_rule_feedback_active")), "HUD rule feedback should stay active briefly after trigger")
	if not hud.has_method("get_rule_feedback_color_for_test"):
		return

	var feedback_color: Color = hud.call("get_rule_feedback_color_for_test")
	match color_kind:
		"blessing":
			_expect(feedback_color.r > 0.9 and feedback_color.g > 0.65 and feedback_color.b < 0.45, "Blessing rule feedback should use warm highlight color")
		"statue":
			_expect(feedback_color.r > 0.55 and feedback_color.g > 0.75 and feedback_color.b > 0.9, "Statue rule feedback should use cool highlight color")

	var expected_texture_path := CONTENT_ICON_REGISTRY.get_texture_path(expected_icon_key, expected_icon_page)
	var expected_token := CONTENT_ICON_REGISTRY.get_type_token(expected_icon_key, expected_icon_page)
	var expected_icon_visible := not expected_texture_path.is_empty()
	_expect(hud.has_method("get_rule_feedback_icon_key_for_test"), "HUD should expose rule feedback icon key for tests")
	if hud.has_method("get_rule_feedback_icon_key_for_test"):
		_expect(str(hud.call("get_rule_feedback_icon_key_for_test")) == expected_icon_key, "HUD rule feedback should keep the triggered rule icon key")
	_expect(hud.has_method("get_rule_feedback_icon_texture_path_for_test"), "HUD should expose rule feedback icon texture path for tests")
	if hud.has_method("get_rule_feedback_icon_texture_path_for_test"):
		_expect(str(hud.call("get_rule_feedback_icon_texture_path_for_test")) == expected_texture_path, "HUD rule feedback icon texture should come from the content icon registry")
	_expect(hud.has_method("is_rule_feedback_icon_visible_for_test"), "HUD should expose rule feedback icon visibility for tests")
	if hud.has_method("is_rule_feedback_icon_visible_for_test"):
		_expect(bool(hud.call("is_rule_feedback_icon_visible_for_test")) == expected_icon_visible, "HUD rule feedback icon visibility should match registry texture availability")
	_expect(hud.has_method("get_rule_feedback_token_text_for_test"), "HUD should expose rule feedback fallback token for tests")
	if hud.has_method("get_rule_feedback_token_text_for_test"):
		_expect(str(hud.call("get_rule_feedback_token_text_for_test")) == expected_token, "HUD rule feedback fallback token should come from the content icon registry")


func _expect_rule_feedback_fades(hud: Node) -> void:
	if hud.has_method("is_rule_feedback_active"):
		hud.call("_process", 1.5)
		_expect(not bool(hud.call("is_rule_feedback_active")), "HUD rule feedback should fade after its duration")
	if hud.has_method("get_rule_feedback_text"):
		_expect(str(hud.call("get_rule_feedback_text")) == "Rule: --", "HUD rule feedback should return to idle text after fading")
	if hud.has_method("is_rule_feedback_icon_visible_for_test"):
		_expect(not bool(hud.call("is_rule_feedback_icon_visible_for_test")), "HUD rule feedback icon should hide after fading")
	if hud.has_method("get_rule_feedback_token_text_for_test"):
		_expect(str(hud.call("get_rule_feedback_token_text_for_test")) == "--", "HUD rule feedback token should reset after fading")


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
		print("EventRoomSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

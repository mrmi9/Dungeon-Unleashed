extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const BASIC_PISTOL := preload("res://resources/weapons/basic_pistol.tres")
const BLAST_LAUNCHER := preload("res://resources/weapons/blast_launcher.tres")

var _failures: Array[String] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_run")


func _run() -> void:
	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame

	var audio_feedback := main.get_node_or_null("AudioFeedback")
	_expect(audio_feedback != null, "Main scene should include AudioFeedback")
	if audio_feedback == null:
		_finish()
		return

	_expect(audio_feedback.has_method("has_audio_bus"), "AudioFeedback should expose audio bus checks")
	_expect(audio_feedback.call("has_audio_bus", "SFX") == true, "SFX bus should exist")
	_expect(audio_feedback.call("has_audio_bus", "Music") == true, "Music bus should exist")
	_expect(str(audio_feedback.call("get_music_mode")) == "menu", "AudioFeedback should start menu music")

	var weapon_sfx_count_before := int(audio_feedback.call("get_sfx_play_count"))
	Events.player_fired.emit(BASIC_PISTOL, Vector2.ZERO, Vector2.RIGHT)
	await get_tree().process_frame
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == BASIC_PISTOL.fire_sfx_key, "Player fired event should use the weapon fire_sfx_key")
	Events.player_fired.emit(BLAST_LAUNCHER, Vector2.ZERO, Vector2.RIGHT)
	await get_tree().process_frame
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == BLAST_LAUNCHER.fire_sfx_key, "Launcher fired event should use its configured fire_sfx_key")
	var fallback_weapon := WeaponData.new()
	fallback_weapon.fire_sfx_key = ""
	fallback_weapon.weapon_class = "laser"
	Events.player_fired.emit(fallback_weapon, Vector2.ZERO, Vector2.RIGHT)
	await get_tree().process_frame
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "weapon_laser_fire", "Player fired event should fall back to weapon class SFX when no fire_sfx_key is set")
	Events.player_fired.emit(null, Vector2.ZERO, Vector2.RIGHT)
	await get_tree().process_frame
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "shoot", "Player fired event should keep generic shoot SFX without WeaponData")
	_expect(int(audio_feedback.call("get_sfx_play_count")) >= weapon_sfx_count_before + 4, "Weapon fire SFX checks should trigger audio feedback")

	var count_before := int(audio_feedback.call("get_sfx_play_count"))
	Events.player_fired.emit(null, Vector2.ZERO, Vector2.RIGHT)
	Events.projectile_hit.emit(null, null, 1)
	Events.projectile_critical_hit.emit(null, null, 3)
	Events.enemy_died.emit(null)
	Events.player_damaged.emit(1, 5)
	await get_tree().process_frame
	var count_after := int(audio_feedback.call("get_sfx_play_count"))
	_expect(count_after >= count_before + 5, "Combat events should trigger SFX")

	Events.player_healed.emit(1, 4)
	await get_tree().process_frame
	var count_after_hp_heal := int(audio_feedback.call("get_sfx_play_count"))
	_expect(count_after_hp_heal > count_after, "Player healed event should trigger hp-heal SFX")
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "hp_heal", "Player healed event should use the hp_heal SFX")

	if audio_feedback.has_method("set_low_health_feedback_intensity"):
		audio_feedback.call("set_low_health_feedback_intensity", 0.0)
		Events.player_low_health_warning.emit(3, 10)
		await get_tree().process_frame
		_expect(int(audio_feedback.call("get_sfx_play_count")) == count_after_hp_heal, "Disabled low-health feedback should not trigger low-health SFX")
		if audio_feedback.has_method("is_low_health_heartbeat_active_for_test"):
			_expect(not bool(audio_feedback.call("is_low_health_heartbeat_active_for_test")), "Disabled low-health feedback should not start heartbeat")
		audio_feedback.call("set_low_health_feedback_intensity", 1.0)

	Events.player_low_health_warning.emit(3, 10)
	await get_tree().process_frame
	var count_after_low_health := int(audio_feedback.call("get_sfx_play_count"))
	_expect(count_after_low_health > count_after_hp_heal, "Low-health warning event should trigger low-health SFX")
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "low_health", "Low-health warning event should use the low_health SFX")
	if audio_feedback.has_method("is_low_health_heartbeat_active_for_test"):
		_expect(bool(audio_feedback.call("is_low_health_heartbeat_active_for_test")), "Low-health warning event should start low-health heartbeat")
	var low_health_entry_heartbeat_interval := float(audio_feedback.call("get_low_health_heartbeat_interval_for_test")) if audio_feedback.has_method("get_low_health_heartbeat_interval_for_test") else 0.0
	Events.player_low_health_updated.emit(1, 10)
	await get_tree().process_frame
	if audio_feedback.has_method("get_low_health_heartbeat_interval_for_test"):
		_expect(float(audio_feedback.call("get_low_health_heartbeat_interval_for_test")) < low_health_entry_heartbeat_interval, "Critical low-health update should shorten heartbeat interval")
	await get_tree().create_timer(0.48).timeout
	await get_tree().process_frame
	var count_after_low_health_heartbeat := int(audio_feedback.call("get_sfx_play_count"))
	_expect(count_after_low_health_heartbeat > count_after_low_health, "Low-health heartbeat should tick while HP remains low")
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "low_health_heartbeat", "Low-health heartbeat tick should use the low_health_heartbeat SFX")

	Events.player_low_health_recovered.emit(4, 6)
	await get_tree().process_frame
	var count_after_low_health_recover := int(audio_feedback.call("get_sfx_play_count"))
	_expect(count_after_low_health_recover > count_after_low_health_heartbeat, "Low-health recovered event should trigger recovery SFX")
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "low_health_recover", "Low-health recovered event should use the low_health_recover SFX")
	if audio_feedback.has_method("is_low_health_heartbeat_active_for_test"):
		_expect(not bool(audio_feedback.call("is_low_health_heartbeat_active_for_test")), "Low-health recovered event should stop low-health heartbeat")

	Events.player_shield_absorbed.emit(2, 4)
	await get_tree().process_frame
	var count_after_armor_block := int(audio_feedback.call("get_sfx_play_count"))
	_expect(count_after_armor_block > count_after_low_health_recover, "Armor absorbed event should trigger armor-block SFX")
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "armor_block", "Armor absorbed event should use the armor_block SFX")

	Events.player_projectile_blocked.emit(null, BASIC_PISTOL, 1, Vector2.ZERO)
	await get_tree().process_frame
	var count_after_projectile_block := int(audio_feedback.call("get_sfx_play_count"))
	_expect(count_after_projectile_block > count_after_armor_block, "Projectile block event should trigger projectile-block SFX")
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "projectile_block", "Projectile block event should use the projectile_block SFX")

	Events.player_shield_broken.emit(2, 0)
	await get_tree().process_frame
	var count_after_armor_break := int(audio_feedback.call("get_sfx_play_count"))
	_expect(count_after_armor_break > count_after_projectile_block, "Armor broken event should trigger armor-break SFX")
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "armor_break", "Armor broken event should use the armor_break SFX")

	Events.player_shield_gained.emit(2, 4)
	await get_tree().process_frame
	var count_after_armor_gain := int(audio_feedback.call("get_sfx_play_count"))
	_expect(count_after_armor_gain > count_after_armor_break, "Armor gained event should trigger armor-gain SFX")
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "armor_gain", "Armor gained event should use the armor_gain SFX")

	Events.danger_warning_started.emit("circle", 0.6, 2)
	await get_tree().process_frame
	var count_after_danger_warning := int(audio_feedback.call("get_sfx_play_count"))
	_expect(count_after_danger_warning > count_after_armor_gain, "Danger warning event should trigger danger-warning SFX")
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "danger_warning", "Danger warning event should use the danger_warning SFX")
	if audio_feedback.has_method("get_danger_warning_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_danger_warning_sfx_id_for_test", "line", 0.3, 1)) == "danger_warning_line", "Line danger warnings should resolve to line warning SFX")
		_expect(str(audio_feedback.call("get_danger_warning_sfx_id_for_test", "circle", 0.95, 0)) == "danger_warning_heavy", "Long circle danger warnings should resolve to heavy warning SFX")
		_expect(str(audio_feedback.call("get_danger_warning_sfx_id_for_test", "circle", 0.35, 4)) == "danger_warning_heavy", "High-damage circle danger warnings should resolve to heavy warning SFX")
	if audio_feedback.has_method("reset_danger_warning_sfx_cooldown_for_test"):
		audio_feedback.call("reset_danger_warning_sfx_cooldown_for_test")
	Events.danger_warning_started.emit("line", 0.35, 1)
	await get_tree().process_frame
	var count_after_line_danger_warning := int(audio_feedback.call("get_sfx_play_count"))
	_expect(count_after_line_danger_warning > count_after_danger_warning, "Line danger warning event should trigger a separate SFX")
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "danger_warning_line", "Line danger warning event should use the danger_warning_line SFX")
	if audio_feedback.has_method("reset_danger_warning_sfx_cooldown_for_test"):
		audio_feedback.call("reset_danger_warning_sfx_cooldown_for_test")
	Events.danger_warning_started.emit("circle", 0.95, 0)
	await get_tree().process_frame
	var count_after_heavy_danger_warning := int(audio_feedback.call("get_sfx_play_count"))
	_expect(count_after_heavy_danger_warning > count_after_line_danger_warning, "Heavy danger warning event should trigger a separate SFX")
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "danger_warning_heavy", "Heavy danger warning event should use the danger_warning_heavy SFX")
	if audio_feedback.has_method("reset_danger_warning_sfx_cooldown_for_test"):
		audio_feedback.call("reset_danger_warning_sfx_cooldown_for_test")

	var enemy_action_sfx_cases := [
		{"action": "summon", "sfx": "enemy_summon_windup"},
		{"action": "support", "sfx": "enemy_support_windup"},
		{"action": "shield_bash", "sfx": "enemy_shield_bash_windup"},
	]
	var count_after_enemy_action_sfx := count_after_heavy_danger_warning
	for action_case in enemy_action_sfx_cases:
		if audio_feedback.has_method("reset_enemy_action_windup_sfx_cooldown_for_test"):
			audio_feedback.call("reset_enemy_action_windup_sfx_cooldown_for_test")
		Events.enemy_action_windup_started.emit(main, str(action_case.get("action", "")), 0.5)
		await get_tree().process_frame
		var next_action_sfx_count := int(audio_feedback.call("get_sfx_play_count"))
		_expect(next_action_sfx_count > count_after_enemy_action_sfx, "%s windup should trigger dedicated enemy-action SFX" % str(action_case.get("action", "")))
		if audio_feedback.has_method("get_last_sfx_id_for_test"):
			_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == str(action_case.get("sfx", "")), "%s windup should use %s SFX" % [str(action_case.get("action", "")), str(action_case.get("sfx", ""))])
		if audio_feedback.has_method("get_enemy_action_windup_sfx_id_for_test"):
			_expect(str(audio_feedback.call("get_enemy_action_windup_sfx_id_for_test", str(action_case.get("action", "")))) == str(action_case.get("sfx", "")), "%s should resolve to its dedicated windup SFX" % str(action_case.get("action", "")))
		count_after_enemy_action_sfx = next_action_sfx_count

	Events.player_energy_insufficient.emit(0, 2, null)
	await get_tree().process_frame
	var count_after_energy_warning := int(audio_feedback.call("get_sfx_play_count"))
	_expect(count_after_energy_warning > count_after_enemy_action_sfx, "Energy insufficient event should trigger a dedicated SFX")
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "energy_empty", "Energy insufficient event should use the energy_empty SFX")

	Events.player_weapon_reloaded.emit(BASIC_PISTOL)
	await get_tree().process_frame
	var count_after_reload_ready := int(audio_feedback.call("get_sfx_play_count"))
	_expect(count_after_reload_ready > count_after_energy_warning, "Weapon reloaded event should trigger reload-ready SFX")
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "reload_ready", "Weapon reloaded event should use the reload_ready SFX")

	Events.player_skill_unavailable.emit("Guard Pulse", "cooldown", 1.5)
	await get_tree().process_frame
	var count_after_skill_fail := int(audio_feedback.call("get_sfx_play_count"))
	_expect(count_after_skill_fail > count_after_reload_ready, "Skill unavailable event should trigger skill-fail SFX")
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "skill_fail", "Skill unavailable event should use the skill_fail SFX")

	Events.player_skill_ready.emit("Guard Pulse")
	await get_tree().process_frame
	var count_after_skill_ready := int(audio_feedback.call("get_sfx_play_count"))
	_expect(count_after_skill_ready > count_after_skill_fail, "Skill ready event should trigger skill-ready SFX")
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "skill_ready", "Skill ready event should use the skill_ready SFX")

	var count_after_passive_sfx := count_after_skill_ready
	var passive_sfx_cases := [
		{
			"passive_id": "steady_hands",
			"effect_name": "Crit Focus",
			"sfx_id": "passive_focus",
		},
		{
			"passive_id": "armored_core",
			"effect_name": "Guard Stance",
			"sfx_id": "passive_guard",
		},
		{
			"passive_id": "energy_focus",
			"effect_name": "Energy Flow",
			"sfx_id": "passive_energy",
		},
		{
			"passive_id": "phase_footing",
			"effect_name": "Speed Surge",
			"sfx_id": "passive_speed",
		},
		{
			"passive_id": "volatile_focus",
			"effect_name": "Kill Burst",
			"sfx_id": "passive_burst",
		},
		{
			"passive_id": "triage_kit",
			"effect_name": "Triage Kit",
			"sfx_id": "passive_support",
		},
	]
	for passive_sfx_case in passive_sfx_cases:
		var passive_id := str(passive_sfx_case["passive_id"])
		var effect_name := str(passive_sfx_case["effect_name"])
		var expected_sfx_id := str(passive_sfx_case["sfx_id"])
		Events.player_passive_triggered.emit(null, passive_id, effect_name, 1.4)
		await get_tree().process_frame
		var passive_count_after_emit := int(audio_feedback.call("get_sfx_play_count"))
		_expect(passive_count_after_emit > count_after_passive_sfx, "%s passive trigger should play SFX" % effect_name)
		count_after_passive_sfx = passive_count_after_emit
		if audio_feedback.has_method("get_last_sfx_id_for_test"):
			_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == expected_sfx_id, "%s passive trigger should use %s SFX" % [effect_name, expected_sfx_id])
		if audio_feedback.has_method("get_passive_trigger_sfx_id_for_test"):
			_expect(str(audio_feedback.call("get_passive_trigger_sfx_id_for_test", passive_id)) == expected_sfx_id, "%s passive should resolve to %s SFX" % [passive_id, expected_sfx_id])

	var rule_sfx_source := Resource.new()
	var count_after_rule_sfx := count_after_passive_sfx
	var blessing_sfx_cases := [
		{
			"trigger_event": "on_room_clear",
			"sfx_id": "blessing_clear",
		},
		{
			"trigger_event": "on_kill",
			"sfx_id": "blessing_kill",
		},
		{
			"trigger_event": "on_hurt",
			"sfx_id": "blessing_guard",
		},
		{
			"trigger_event": "on_statue_triggered",
			"sfx_id": "blessing_resonance",
		},
	]
	for blessing_sfx_case in blessing_sfx_cases:
		var trigger_event := str(blessing_sfx_case["trigger_event"])
		var expected_sfx_id := str(blessing_sfx_case["sfx_id"])
		Events.blessing_triggered.emit(rule_sfx_source, trigger_event, "damage_multiplier", 0.12)
		await get_tree().process_frame
		var blessing_count_after_emit := int(audio_feedback.call("get_sfx_play_count"))
		_expect(blessing_count_after_emit > count_after_rule_sfx, "%s blessing trigger should play SFX" % trigger_event)
		count_after_rule_sfx = blessing_count_after_emit
		if audio_feedback.has_method("get_last_sfx_id_for_test"):
			_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == expected_sfx_id, "%s blessing trigger should use %s SFX" % [trigger_event, expected_sfx_id])
		if audio_feedback.has_method("get_blessing_trigger_sfx_id_for_test"):
			_expect(str(audio_feedback.call("get_blessing_trigger_sfx_id_for_test", trigger_event)) == expected_sfx_id, "%s blessing trigger should resolve to %s SFX" % [trigger_event, expected_sfx_id])

	Events.blessing_triggered.emit(rule_sfx_source, "custom_rule", "damage_multiplier", 0.12)
	await get_tree().process_frame
	count_after_rule_sfx = int(audio_feedback.call("get_sfx_play_count"))
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "blessing_trigger", "Unknown blessing trigger should use fallback SFX")
	if audio_feedback.has_method("get_blessing_trigger_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_blessing_trigger_sfx_id_for_test", "custom_rule")) == "blessing_trigger", "Unknown blessing trigger should resolve to fallback SFX")

	Events.statue_triggered.emit(rule_sfx_source, "on_skill_used", "fire_rate_multiplier", 0.12)
	await get_tree().process_frame
	var count_after_statue_trigger := int(audio_feedback.call("get_sfx_play_count"))
	_expect(count_after_statue_trigger > count_after_rule_sfx, "Skill statue trigger should play SFX")
	count_after_rule_sfx = count_after_statue_trigger
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "statue_skill", "Skill statue trigger should use the statue_skill SFX")
	if audio_feedback.has_method("get_statue_trigger_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_statue_trigger_sfx_id_for_test", "on_skill_used")) == "statue_skill", "Skill statue trigger should resolve to statue_skill SFX")

	Events.statue_triggered.emit(rule_sfx_source, "custom_statue", "fire_rate_multiplier", 0.12)
	await get_tree().process_frame
	var count_after_statue_fallback := int(audio_feedback.call("get_sfx_play_count"))
	_expect(count_after_statue_fallback > count_after_rule_sfx, "Unknown statue trigger should play fallback SFX")
	count_after_rule_sfx = count_after_statue_fallback
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "statue_trigger", "Unknown statue trigger should use fallback SFX")
	if audio_feedback.has_method("get_statue_trigger_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_statue_trigger_sfx_id_for_test", "custom_statue")) == "statue_trigger", "Unknown statue trigger should resolve to fallback SFX")

	Events.statue_attuned.emit(rule_sfx_source, 2)
	await get_tree().process_frame
	var count_after_statue_attune := int(audio_feedback.call("get_sfx_play_count"))
	_expect(count_after_statue_attune > count_after_rule_sfx, "Statue attunement should play SFX")
	count_after_rule_sfx = count_after_statue_attune
	if audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "statue_attune", "Statue attunement should use the statue_attune SFX")

	Events.boss_health_changed.emit(null, 10, 20)
	await get_tree().process_frame
	_expect(str(audio_feedback.call("get_music_mode")) == "boss", "Boss health event should switch to boss music")

	Events.run_completed.emit()
	await get_tree().process_frame
	_expect(str(audio_feedback.call("get_music_mode")) == "victory", "Run completion should switch to victory music")
	_expect(int(audio_feedback.call("get_sfx_play_count")) > count_after_rule_sfx, "Run completion should trigger victory SFX")
	await get_tree().create_timer(0.5, true).timeout

	get_tree().paused = false
	main.queue_free()
	await get_tree().process_frame
	_finish()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	get_tree().paused = false
	if _failures.is_empty():
		print("AudioFeedbackSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

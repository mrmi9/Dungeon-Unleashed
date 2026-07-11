extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const CONTENT_ICON_REGISTRY := preload("res://scripts/content/ContentIconRegistry.gd")
const SETTINGS_FILE := "settings.cfg"
const SETTINGS_PATH := "user://settings.cfg"

var _failures: Array[String] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_run")


func _run() -> void:
	_delete_settings_file()

	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame

	var hud = main.get_node_or_null("CanvasLayer/HUD")
	var audio_feedback = main.get_node_or_null("AudioFeedback")
	var player := main.get_node_or_null("Player") as Player
	_expect(hud != null, "HUD should exist")
	_expect(player != null, "Player should exist")
	_expect(main.has_method("select_next_character"), "Main should expose next character selection")
	_expect(main.has_method("select_previous_character"), "Main should expose previous character selection")
	_expect(main.has_method("get_character_selection_summary"), "Main should expose current character summary")
	if hud == null or player == null:
		_finish()
		return

	var initial_summary: Dictionary = main.call("get_character_selection_summary")
	_expect(str(initial_summary.get("display_name", "")) == "Wanderer", "Default character should be Wanderer")
	_expect(int(initial_summary.get("total", 0)) == 6, "Main menu should expose six selectable characters")
	_expect(str(hud.call("get_character_name_text")).contains("Wanderer"), "HUD should show default character")
	_expect(str(hud.call("get_skill_label_text")).contains("Phase Dash"), "HUD should show default skill")
	_expect(_loadout_ids_match(player, ["basic_pistol", "shotgun", "energy_staff"]), "Wanderer should apply its configured starting weapons")
	_expect(_hud_loadout_contains(hud, "Shotgun"), "HUD should show Wanderer starting loadout")
	_expect(_passive_id_matches(player, "steady_hands"), "Wanderer should apply the Steady Hands passive")
	_expect(player.get_crit_chance_bonus() > 0.0, "Wanderer passive should improve critical consistency")
	_expect(player.get_reload_speed_multiplier() > 1.0, "Wanderer passive should improve reload handling")
	_expect(str(hud.call("get_passive_status_text")).contains("Steady Hands"), "HUD should show Wanderer passive baseline")
	_expect_passive_status_icon(hud, "character_wanderer", "Wanderer")
	var wanderer_fire_rate_baseline := player.get_fire_rate_multiplier()
	var wanderer_reload_baseline := player.get_reload_speed_multiplier()
	var wanderer_passive_summary: Dictionary = player.call("get_character_passive_summary")
	_expect(float(wanderer_passive_summary.get("critical_focus_duration", 0.0)) > 0.0, "Wanderer passive should expose critical focus duration")
	_expect(float(wanderer_passive_summary.get("critical_focus_fire_rate_multiplier_bonus", 0.0)) > 0.0, "Wanderer critical focus should expose fire-rate bonus")
	_expect(float(wanderer_passive_summary.get("critical_focus_reload_speed_multiplier_bonus", 0.0)) > 0.0, "Wanderer critical focus should expose reload bonus")
	Events.projectile_critical_hit.emit(null, null, 4)
	await get_tree().process_frame
	wanderer_passive_summary = player.call("get_character_passive_summary")
	_expect(bool(wanderer_passive_summary.get("critical_focus_active", false)), "Wanderer passive should activate after a critical hit")
	_expect(player.get_fire_rate_multiplier() > wanderer_fire_rate_baseline, "Wanderer critical focus should improve fire rate")
	_expect(player.get_reload_speed_multiplier() > wanderer_reload_baseline, "Wanderer critical focus should improve reload handling")
	_expect(str(hud.call("get_passive_status_text")).contains("Crit Focus"), "HUD should show Wanderer critical focus while active")
	if hud.has_method("is_passive_trigger_pulse_active"):
		_expect(bool(hud.call("is_passive_trigger_pulse_active")), "HUD should pulse Passive status when a character passive triggers")
	if hud.has_method("get_passive_status_color_for_test"):
		var passive_trigger_color: Color = hud.call("get_passive_status_color_for_test")
		_expect(passive_trigger_color.g > 0.92, "Passive trigger pulse should brighten the passive status label")
	_expect(_has_floating_text(main, "CRIT FOCUS"), "Wanderer critical focus should show passive floating text")
	if hud.has_method("is_passive_trigger_pulse_active"):
		hud.call("_process", 0.6)
		_expect(not bool(hud.call("is_passive_trigger_pulse_active")), "HUD passive trigger pulse should fade after its duration")
	player.call("_tick_timers", float(wanderer_passive_summary.get("critical_focus_duration", 0.0)) + 0.1)
	await get_tree().process_frame
	wanderer_passive_summary = player.call("get_character_passive_summary")
	_expect(not bool(wanderer_passive_summary.get("critical_focus_active", true)), "Wanderer critical focus should expire")
	_expect(is_equal_approx(player.get_fire_rate_multiplier(), wanderer_fire_rate_baseline), "Wanderer fire rate should return to passive baseline")
	_expect(is_equal_approx(player.get_reload_speed_multiplier(), wanderer_reload_baseline), "Wanderer reload should return to passive baseline")
	_expect(str(hud.call("get_passive_status_text")).contains("Steady Hands"), "HUD should return Wanderer passive status to baseline")
	var base_health := player.current_health
	var base_shield := player.current_shield
	var heal_sfx_count_before := int(audio_feedback.call("get_sfx_play_count")) if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count") else -1
	player.current_health = maxi(base_health - 1, 1)
	player.health_changed.emit(player.current_health, player.max_health)
	player.heal(1)
	await get_tree().process_frame
	_expect(player.current_health == base_health, "Direct heal should restore missing HP")
	if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count") and heal_sfx_count_before >= 0:
		_expect(int(audio_feedback.call("get_sfx_play_count")) > heal_sfx_count_before, "Direct heal should trigger hp-heal SFX")
	if audio_feedback != null and audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "hp_heal", "Direct heal should use the hp_heal SFX")
	var armor_block_sfx_count_before := int(audio_feedback.call("get_sfx_play_count")) if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count") else -1
	player.take_damage(2)
	await get_tree().process_frame
	_expect(player.current_health == base_health, "Armor should absorb small hits before HP")
	_expect(player.current_shield == base_shield - 2, "Armor should drop by absorbed damage")
	_expect(str(hud.call("get_shield_label_text")).contains("Delay"), "HUD should show Armor recharge delay after damage")
	if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count") and armor_block_sfx_count_before >= 0:
		_expect(int(audio_feedback.call("get_sfx_play_count")) > armor_block_sfx_count_before, "Armor absorption should trigger armor-block SFX")
	if audio_feedback != null and audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "armor_block", "Armor absorption should use the armor_block SFX instead of hurt")
	player.call("_tick_timers", player.shield_recharge_delay - 0.2)
	await get_tree().process_frame
	_expect(player.current_shield == base_shield - 2, "Armor should not recover before the safe-delay window")
	_expect(str(hud.call("get_shield_label_text")).contains("Delay"), "HUD should keep Armor delay text before recovery starts")
	player.call("_tick_timers", 0.3)
	await get_tree().process_frame
	_expect(str(hud.call("get_shield_label_text")).contains("Recovering"), "HUD should show Armor recovering after the safe-delay window")
	var armor_gain_sfx_count_before := int(audio_feedback.call("get_sfx_play_count")) if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count") else -1
	player.call("_tick_timers", 0.7)
	await get_tree().process_frame
	_expect(player.current_shield == base_shield - 1, "Armor should recover one point after the safe-delay window")
	_expect(str(hud.call("get_shield_label_text")).contains("Recovering"), "HUD should keep Armor recovering text while armor is not full")
	if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count") and armor_gain_sfx_count_before >= 0:
		_expect(int(audio_feedback.call("get_sfx_play_count")) > armor_gain_sfx_count_before, "Armor recovery tick should trigger armor-gain SFX")
	if audio_feedback != null and audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "armor_gain", "Armor recovery tick should use the armor_gain SFX")
	if hud.has_method("is_armor_recovery_pulse_active"):
		_expect(bool(hud.call("is_armor_recovery_pulse_active")), "HUD should pulse Armor after a recharge tick")
	if hud.has_method("get_shield_label_color_for_test"):
		var armor_pulse_color: Color = hud.call("get_shield_label_color_for_test")
		_expect(armor_pulse_color.g > 0.9, "Armor pulse should brighten the shield label while active")
	if hud.has_method("is_armor_recovery_pulse_active"):
		hud.call("_process", 0.5)
		_expect(not bool(hud.call("is_armor_recovery_pulse_active")), "HUD Armor pulse should fade after its duration")
	player.call("_tick_timers", 2.0)
	await get_tree().process_frame
	_expect(player.current_shield == base_shield, "Armor should continue recovering up to max armor")
	_expect(player.current_health == base_health, "Armor recovery should not change HP")
	_expect(not str(hud.call("get_shield_label_text")).contains("Recovering"), "HUD should hide Armor recovering text at full armor")

	_expect(bool(main.call("select_next_character")), "Selecting next character in main menu should succeed")
	await get_tree().process_frame
	var warden_summary: Dictionary = main.call("get_character_selection_summary")
	_expect(str(warden_summary.get("display_name", "")) == "Warden", "Next character should be Warden")
	_expect(player.max_health == 7, "Warden should apply higher health")
	_expect(player.max_shield == 8, "Warden should apply higher armor")
	_expect(player.max_energy == 100, "Warden should apply lower energy")
	_expect(is_equal_approx(player.move_speed, 238.0), "Warden should apply slower movement speed")
	_expect(str(hud.call("get_character_name_text")).contains("Warden"), "HUD should show selected Warden")
	_expect(str(hud.call("get_character_info_text")).contains("Guard Pulse"), "HUD should show Warden skill details")
	_expect(_loadout_ids_match(player, ["basic_pistol", "arc_blade", "shotgun"]), "Warden should apply its configured starting weapons")
	_expect(_hud_loadout_contains(hud, "Arc Blade"), "HUD should show Warden starting loadout")
	_expect(_passive_id_matches(player, "armored_core"), "Warden should apply the Armored Core passive")
	_expect(player.get_projectile_block_radius_bonus() > 0.0, "Warden passive should improve projectile block radius")
	_expect(player.get_projectile_block_damage_bonus() > 0, "Warden passive should improve projectile block damage")
	_expect(str(hud.call("get_passive_status_text")).contains("Armored Core"), "HUD should show Warden passive baseline")
	_expect_passive_status_icon(hud, "character_warden", "Warden")
	var warden_passive_summary: Dictionary = player.call("get_character_passive_summary")
	_expect(float(warden_passive_summary.get("shield_break_guard_duration", 0.0)) > 0.0, "Warden passive should expose shield-break guard duration")
	var warden_block_radius_baseline := player.get_projectile_block_radius_bonus()
	var warden_block_arc_baseline := player.get_projectile_block_arc_bonus()
	var warden_block_damage_baseline := player.get_projectile_block_damage_bonus()
	player.current_health = player.max_health
	player.current_shield = 1
	player.health_changed.emit(player.current_health, player.max_health)
	player.shield_changed.emit(player.current_shield)
	player.take_damage(1)
	await get_tree().process_frame
	warden_passive_summary = player.call("get_character_passive_summary")
	_expect(bool(warden_passive_summary.get("shield_break_guard_active", false)), "Warden passive should activate when armor breaks")
	_expect(player.get_projectile_block_radius_bonus() > warden_block_radius_baseline, "Warden shield-break guard should expand projectile block radius")
	_expect(player.get_projectile_block_arc_bonus() > warden_block_arc_baseline, "Warden shield-break guard should expand projectile block arc")
	_expect(player.get_projectile_block_damage_bonus() > warden_block_damage_baseline, "Warden shield-break guard should improve counter damage")
	_expect(str(hud.call("get_passive_status_text")).contains("Guard Stance"), "HUD should show Warden guard stance while active")
	_expect(_has_floating_text(main, "GUARD STANCE"), "Warden guard stance should show passive floating text")
	player.call("_tick_timers", float(warden_passive_summary.get("shield_break_guard_duration", 0.0)) + 0.1)
	await get_tree().process_frame
	warden_passive_summary = player.call("get_character_passive_summary")
	_expect(not bool(warden_passive_summary.get("shield_break_guard_active", true)), "Warden shield-break guard should expire")
	_expect(is_equal_approx(player.get_projectile_block_radius_bonus(), warden_block_radius_baseline), "Warden shield-break radius should return to passive baseline")
	_expect(is_equal_approx(player.get_projectile_block_arc_bonus(), warden_block_arc_baseline), "Warden shield-break arc should return to passive baseline")
	_expect(player.get_projectile_block_damage_bonus() == warden_block_damage_baseline, "Warden shield-break counter damage should return to passive baseline")
	_expect(str(hud.call("get_passive_status_text")).contains("Armored Core"), "HUD should return Warden passive status to baseline")

	player.current_shield = 4
	player.current_energy = player.max_energy
	var used_warden_skill := player.try_use_skill()
	await get_tree().process_frame
	_expect(used_warden_skill, "Warden skill should activate when energy is available")
	_expect(player.current_shield == 7, "Warden skill should restore armor")
	_expect(player.current_energy == 90, "Warden skill should spend energy")
	_expect(player.get_skill_summary().get("cooldown_remaining", 0.0) > 0.0, "Warden skill should start cooldown")
	var skill_fail_sfx_count_before := int(audio_feedback.call("get_sfx_play_count")) if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count") else -1
	_expect(not player.try_use_skill(), "Skill should not be reusable while on cooldown")
	await get_tree().process_frame
	if main.has_method("get_floating_text_count") and main.has_method("get_floating_text_snapshots"):
		_expect(_has_floating_text(main, "SKILL CD"), "Cooldown skill retry should show SKILL CD feedback")
	if hud.has_method("is_skill_warning_active"):
		_expect(bool(hud.call("is_skill_warning_active")), "Cooldown skill retry should pulse the HUD skill label")
	if hud.has_method("get_skill_label_color_for_test"):
		var skill_warning_color: Color = hud.call("get_skill_label_color_for_test")
		_expect(skill_warning_color.r > 0.9 and skill_warning_color.g < 0.9, "Skill warning should shift the skill label toward orange while active")
	if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count") and skill_fail_sfx_count_before >= 0:
		_expect(int(audio_feedback.call("get_sfx_play_count")) > skill_fail_sfx_count_before, "Cooldown skill retry should trigger skill-fail SFX")
	if audio_feedback != null and audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "skill_fail", "Cooldown skill retry should use the skill_fail SFX")
	if hud.has_method("is_skill_warning_active"):
		hud.call("_process", 0.5)
		_expect(not bool(hud.call("is_skill_warning_active")), "HUD skill warning should fade after its duration")
	_expect(str(hud.call("get_skill_label_text")).contains("Guard Pulse"), "HUD should show Warden skill status")
	var skill_ready_sfx_count_before := int(audio_feedback.call("get_sfx_play_count")) if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count") else -1
	player.call("_tick_timers", 9.1)
	await get_tree().process_frame
	_expect(str(hud.call("get_skill_label_text")).contains("Ready"), "HUD should show Warden skill ready after cooldown")
	if hud.has_method("is_skill_ready_pulse_active"):
		_expect(bool(hud.call("is_skill_ready_pulse_active")), "HUD should pulse Skill when cooldown finishes")
	if hud.has_method("get_skill_label_color_for_test"):
		var skill_ready_color: Color = hud.call("get_skill_label_color_for_test")
		_expect(skill_ready_color.r < 0.65 and skill_ready_color.b < 0.7, "Skill ready pulse should shift the skill label toward green while active")
	if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count") and skill_ready_sfx_count_before >= 0:
		_expect(int(audio_feedback.call("get_sfx_play_count")) > skill_ready_sfx_count_before, "Skill cooldown finish should trigger skill-ready SFX")
	if hud.has_method("is_skill_ready_pulse_active"):
		hud.call("_process", 0.6)
		_expect(not bool(hud.call("is_skill_ready_pulse_active")), "HUD skill ready pulse should fade after its duration")

	_expect(bool(main.call("select_next_character")), "Selecting next character after Warden should succeed")
	await get_tree().process_frame
	var arcanist_summary: Dictionary = main.call("get_character_selection_summary")
	_expect(str(arcanist_summary.get("display_name", "")) == "Arcanist", "Next character should be Arcanist")
	_expect(player.max_health == 5, "Arcanist should apply lower health")
	_expect(player.max_shield == 4, "Arcanist should apply lower armor")
	_expect(player.max_energy == 160, "Arcanist should apply higher energy")
	_expect(_loadout_ids_match(player, ["basic_pistol", "energy_staff", "laser_lance"]), "Arcanist should apply its configured starting weapons")
	_expect(_hud_loadout_contains(hud, "Laser Lance"), "HUD should show Arcanist starting loadout")
	_expect(_passive_id_matches(player, "energy_focus"), "Arcanist should apply the Energy Focus passive")
	_expect(str(hud.call("get_passive_status_text")).contains("Energy Focus"), "HUD should show Arcanist passive baseline")
	var arcanist_fire_rate_baseline := player.get_fire_rate_multiplier()
	var arcanist_reload_baseline := player.get_reload_speed_multiplier()
	_expect(arcanist_fire_rate_baseline > 1.0, "Arcanist passive should improve fire-rate handling")
	_expect(arcanist_reload_baseline > 1.0, "Arcanist passive should improve reload handling")
	var arcanist_passive_summary: Dictionary = player.call("get_character_passive_summary")
	_expect(float(arcanist_passive_summary.get("energy_spend_focus_duration", 0.0)) > 0.0, "Arcanist passive should expose energy-spend focus duration")
	_expect(float(arcanist_passive_summary.get("energy_spend_focus_fire_rate_multiplier_bonus", 0.0)) > 0.0, "Arcanist passive should expose energy-spend fire rate")
	_expect(float(arcanist_passive_summary.get("energy_spend_focus_reload_speed_multiplier_bonus", 0.0)) > 0.0, "Arcanist passive should expose energy-spend reload speed")
	var energy_focus_weapon := load("res://resources/weapons/energy_staff.tres")
	_expect(energy_focus_weapon != null, "Arcanist energy-spend test should load Energy Staff")
	player.current_energy = player.max_energy
	var energy_before_focus := player.current_energy
	_expect(player.spend_energy_for_weapon(energy_focus_weapon), "Arcanist should spend weapon energy for focus test")
	await get_tree().process_frame
	arcanist_passive_summary = player.call("get_character_passive_summary")
	_expect(player.current_energy < energy_before_focus, "Arcanist energy-spend focus test should consume energy")
	_expect(bool(arcanist_passive_summary.get("energy_spend_focus_active", false)), "Arcanist passive should activate after weapon energy spend")
	_expect(player.get_fire_rate_multiplier() > arcanist_fire_rate_baseline, "Arcanist energy-spend focus should increase fire rate over passive baseline")
	_expect(player.get_reload_speed_multiplier() > arcanist_reload_baseline, "Arcanist energy-spend focus should increase reload speed over passive baseline")
	_expect(str(hud.call("get_passive_status_text")).contains("Energy Flow"), "HUD should show Arcanist energy flow while active")
	_expect(_has_floating_text(main, "ENERGY FLOW"), "Arcanist energy flow should show passive floating text")
	player.call("_tick_timers", float(arcanist_passive_summary.get("energy_spend_focus_duration", 0.0)) + 0.1)
	await get_tree().process_frame
	arcanist_passive_summary = player.call("get_character_passive_summary")
	_expect(not bool(arcanist_passive_summary.get("energy_spend_focus_active", true)), "Arcanist energy-spend focus should expire")
	_expect(is_equal_approx(player.get_fire_rate_multiplier(), arcanist_fire_rate_baseline), "Arcanist focus fire rate should return to passive baseline")
	_expect(is_equal_approx(player.get_reload_speed_multiplier(), arcanist_reload_baseline), "Arcanist focus reload speed should return to passive baseline")
	_expect(str(hud.call("get_passive_status_text")).contains("Energy Focus"), "HUD should return Arcanist passive status to baseline")
	player.current_energy = 20
	var used_arcanist_skill := player.try_use_skill()
	await get_tree().process_frame
	_expect(used_arcanist_skill, "Arcanist skill should activate without energy cost")
	_expect(player.current_energy >= 56, "Arcanist skill should restore at least its configured energy")
	_expect(player.get_fire_rate_multiplier() > arcanist_fire_rate_baseline, "Arcanist skill should temporarily increase fire rate")
	player.call("_tick_timers", 3.2)
	await get_tree().process_frame
	_expect(is_equal_approx(player.get_fire_rate_multiplier(), arcanist_fire_rate_baseline), "Arcanist fire-rate boost should expire back to passive baseline")

	_expect(bool(main.call("select_next_character")), "Selecting next character after Arcanist should succeed")
	await get_tree().process_frame
	var rift_summary: Dictionary = main.call("get_character_selection_summary")
	_expect(str(rift_summary.get("display_name", "")) == "Rift Runner", "Fourth character should be Rift Runner")
	_expect(not bool(rift_summary.get("unlocked", true)), "Rift Runner should start locked")
	_expect(_loadout_ids_match(player, ["basic_pistol", "ricochet_blaster", "arc_blade"]), "Rift Runner should apply its configured starting weapons")
	_expect(_hud_loadout_contains(hud, "Ricochet Blaster"), "HUD should show Rift Runner starting loadout")
	_expect(_passive_id_matches(player, "phase_footing"), "Rift Runner should apply the Phase Footing passive")
	_expect(str(hud.call("get_passive_status_text")).contains("Phase Footing"), "HUD should show Rift Runner passive baseline")
	var rift_speed_baseline := player.get_current_speed_multiplier()
	_expect(rift_speed_baseline > 1.0, "Rift Runner passive should improve speed")
	var rift_passive_summary: Dictionary = player.call("get_character_passive_summary")
	_expect(float(rift_passive_summary.get("room_clear_speed_multiplier_bonus", 0.0)) > 0.0, "Rift Runner passive should expose room-clear speed bonus")
	_expect(float(rift_passive_summary.get("room_clear_speed_duration", 0.0)) > 0.0, "Rift Runner passive should expose room-clear speed duration")
	Events.room_cleared.emit(null)
	await get_tree().process_frame
	rift_passive_summary = player.call("get_character_passive_summary")
	_expect(bool(rift_passive_summary.get("room_clear_speed_active", false)), "Rift Runner passive should activate speed boost on room clear")
	_expect(player.get_current_speed_multiplier() > rift_speed_baseline, "Rift Runner room-clear speed boost should exceed passive baseline")
	_expect(str(hud.call("get_passive_status_text")).contains("Speed Surge"), "HUD should show Rift Runner speed surge while active")
	_expect(_has_floating_text(main, "SPEED SURGE"), "Rift Runner speed surge should show passive floating text")
	player.call("_tick_timers", float(rift_passive_summary.get("room_clear_speed_duration", 0.0)) + 0.1)
	await get_tree().process_frame
	rift_passive_summary = player.call("get_character_passive_summary")
	_expect(not bool(rift_passive_summary.get("room_clear_speed_active", true)), "Rift Runner room-clear speed boost should expire")
	_expect(is_equal_approx(player.get_current_speed_multiplier(), rift_speed_baseline), "Rift Runner speed should return to passive baseline")
	_expect(str(hud.call("get_passive_status_text")).contains("Phase Footing"), "HUD should keep Rift Runner passive status readable after expiry")

	_expect(bool(main.call("select_next_character")), "Selecting next character after Rift Runner should succeed")
	await get_tree().process_frame
	var ember_summary: Dictionary = main.call("get_character_selection_summary")
	_expect(str(ember_summary.get("display_name", "")) == "Emberwright", "Fifth character should be Emberwright")
	_expect(not bool(ember_summary.get("unlocked", true)), "Emberwright should start locked")
	_expect(player.max_health == 5, "Emberwright should apply lower health")
	_expect(player.max_shield == 5, "Emberwright should apply medium armor")
	_expect(player.max_energy == 135, "Emberwright should apply burst energy pool")
	_expect(_loadout_ids_match(player, ["basic_pistol", "blast_launcher", "coil_carbine"]), "Emberwright should apply its configured starting weapons")
	_expect(_hud_loadout_contains(hud, "Blast Launcher"), "HUD should show Emberwright starting loadout")
	_expect(_passive_id_matches(player, "volatile_focus"), "Emberwright should apply the Volatile Focus passive")
	_expect(str(hud.call("get_passive_status_text")).contains("Volatile Focus"), "HUD should show Emberwright passive baseline")
	var ember_damage_baseline := player.get_damage_multiplier()
	var ember_fire_rate_baseline := player.get_fire_rate_multiplier()
	_expect(ember_damage_baseline > 1.0, "Emberwright passive should improve damage")
	var ember_passive_summary: Dictionary = player.call("get_character_passive_summary")
	_expect(float(ember_passive_summary.get("kill_burst_duration", 0.0)) > 0.0, "Emberwright passive should expose kill-burst duration")
	_expect(float(ember_passive_summary.get("kill_burst_damage_multiplier_bonus", 0.0)) > 0.0, "Emberwright passive should expose kill-burst damage")
	_expect(float(ember_passive_summary.get("kill_burst_fire_rate_multiplier_bonus", 0.0)) > 0.0, "Emberwright passive should expose kill-burst fire rate")
	Events.enemy_died.emit(null)
	await get_tree().process_frame
	ember_passive_summary = player.call("get_character_passive_summary")
	_expect(bool(ember_passive_summary.get("kill_burst_active", false)), "Emberwright passive should activate on enemy kill")
	_expect(player.get_damage_multiplier() > ember_damage_baseline, "Emberwright kill burst should increase damage over passive baseline")
	_expect(player.get_fire_rate_multiplier() > ember_fire_rate_baseline, "Emberwright kill burst should increase fire rate over passive baseline")
	_expect(str(hud.call("get_passive_status_text")).contains("Kill Burst"), "HUD should show Emberwright kill burst while active")
	_expect(_has_floating_text(main, "KILL BURST"), "Emberwright kill burst should show passive floating text")
	player.call("_tick_timers", float(ember_passive_summary.get("kill_burst_duration", 0.0)) + 0.1)
	await get_tree().process_frame
	ember_passive_summary = player.call("get_character_passive_summary")
	_expect(not bool(ember_passive_summary.get("kill_burst_active", true)), "Emberwright kill burst should expire")
	_expect(is_equal_approx(player.get_damage_multiplier(), ember_damage_baseline), "Emberwright kill burst damage should return to passive baseline")
	_expect(is_equal_approx(player.get_fire_rate_multiplier(), ember_fire_rate_baseline), "Emberwright kill burst fire rate should return to passive baseline")
	_expect(str(hud.call("get_passive_status_text")).contains("Volatile Focus"), "HUD should return Emberwright passive status to baseline")
	player.current_energy = player.max_energy
	var used_ember_skill := player.try_use_skill()
	await get_tree().process_frame
	_expect(used_ember_skill, "Emberwright skill should activate when energy is available")
	_expect(player.current_energy == 117, "Emberwright skill should spend energy")
	_expect(player.get_damage_multiplier() > ember_damage_baseline, "Emberwright skill should temporarily increase damage")
	_expect(player.get_fire_rate_multiplier() > ember_fire_rate_baseline, "Emberwright skill should temporarily increase fire rate")
	player.call("_tick_timers", 3.2)
	await get_tree().process_frame
	_expect(is_equal_approx(player.get_damage_multiplier(), ember_damage_baseline), "Emberwright damage boost should expire back to passive baseline")
	_expect(is_equal_approx(player.get_fire_rate_multiplier(), ember_fire_rate_baseline), "Emberwright fire-rate boost should expire back to passive baseline")

	_expect(bool(main.call("select_next_character")), "Selecting next character after Emberwright should succeed")
	await get_tree().process_frame
	var medic_summary: Dictionary = main.call("get_character_selection_summary")
	_expect(str(medic_summary.get("display_name", "")) == "Field Medic", "Sixth character should be Field Medic")
	_expect(not bool(medic_summary.get("unlocked", true)), "Field Medic should start locked")
	_expect(player.max_health == 7, "Field Medic should apply higher health")
	_expect(player.max_shield == 5, "Field Medic should apply medium armor")
	_expect(player.max_energy == 115, "Field Medic should apply lower energy")
	_expect(_loadout_ids_match(player, ["basic_pistol", "energy_staff", "shatter_fan"]), "Field Medic should apply its configured starting weapons")
	_expect(_hud_loadout_contains(hud, "Shatter Fan"), "HUD should show Field Medic starting loadout")
	_expect(_passive_id_matches(player, "triage_kit"), "Field Medic should apply the Triage Kit passive")
	_expect(str(hud.call("get_passive_status_text")).contains("Triage Kit"), "HUD should show Field Medic passive baseline")
	_expect(float(player.get_shield_recharge_summary().get("rate", 0.0)) > player.shield_recharge_rate, "Field Medic passive should improve armor recovery rate")
	var medic_passive_summary: Dictionary = player.call("get_character_passive_summary")
	_expect(int(medic_passive_summary.get("room_clear_heal_amount", 0)) == 1, "Field Medic passive should expose room-clear healing")
	_expect(int(medic_passive_summary.get("room_clear_shield_amount", 0)) == 1, "Field Medic passive should expose room-clear armor recovery")
	player.current_health = player.max_health - 1
	player.current_shield = maxi(player.max_shield - 2, 0)
	player.health_changed.emit(player.current_health, player.max_health)
	player.shield_changed.emit(player.current_shield)
	Events.room_cleared.emit(null)
	await get_tree().process_frame
	_expect(player.current_health == player.max_health, "Field Medic passive should heal on room clear")
	_expect(player.current_shield == player.max_shield - 1, "Field Medic passive should restore armor on room clear")
	_expect(_has_floating_text(main, "TRIAGE KIT"), "Field Medic room-clear recovery should show passive floating text")
	player.current_health = 5
	player.current_shield = 1
	player.current_energy = player.max_energy
	var used_medic_skill := player.try_use_skill()
	await get_tree().process_frame
	_expect(used_medic_skill, "Field Medic skill should activate when energy is available")
	_expect(player.current_health == 7, "Field Medic skill should restore health")
	_expect(player.current_shield == 2, "Field Medic skill should restore armor")
	_expect(player.current_energy == 99, "Field Medic skill should spend energy")

	_expect(bool(main.call("select_next_character")), "Selecting next character should wrap after Field Medic")
	await get_tree().process_frame
	_expect(str(main.call("get_character_selection_summary").get("display_name", "")) == "Wanderer", "Character selection should wrap back to Wanderer")

	main.call("start_new_run")
	await get_tree().process_frame
	var locked_summary: Dictionary = main.call("get_character_selection_summary")
	_expect(not bool(main.call("select_next_character")), "Character selection should be locked after run start")
	await get_tree().process_frame
	_expect(str(main.call("get_character_selection_summary").get("display_name", "")) == str(locked_summary.get("display_name", "")), "Run start should preserve selected character")
	var run_summary: Dictionary = main.call("get_run_summary")
	_expect(str(run_summary.get("character", "")) == str(locked_summary.get("display_name", "")), "Run summary should include selected character")
	_expect(_run_summary_loadout_contains(run_summary, "Shotgun"), "Run summary should include selected character loadout")

	get_tree().paused = false
	main.queue_free()
	await get_tree().process_frame
	_delete_settings_file()
	_finish()


func _delete_settings_file() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var dir := DirAccess.open("user://")
	if dir != null:
		dir.remove(SETTINGS_FILE)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _has_floating_text(main: Node, expected_text: String) -> bool:
	var snapshots: Array = main.call("get_floating_text_snapshots")
	for snapshot in snapshots:
		if snapshot is Dictionary and str(snapshot.get("text", "")).contains(expected_text):
			return true
	return false


func _loadout_ids_match(player: Player, expected_ids: Array) -> bool:
	if player == null or not player.has_method("get_weapon_loadout_ids"):
		return false
	var actual_ids_value = player.call("get_weapon_loadout_ids")
	if not (actual_ids_value is PackedStringArray):
		return false
	var actual_ids := actual_ids_value as PackedStringArray
	if actual_ids.size() != expected_ids.size():
		return false
	for index in range(expected_ids.size()):
		if str(actual_ids[index]) != str(expected_ids[index]):
			return false
	return true


func _passive_id_matches(player: Player, expected_id: String) -> bool:
	if player == null or not player.has_method("get_character_passive_summary"):
		return false
	var passive_summary: Dictionary = player.call("get_character_passive_summary")
	return str(passive_summary.get("passive_id", "")) == expected_id


func _expect_passive_status_icon(hud: Node, expected_icon_key: String, character_name: String) -> void:
	_expect(hud.has_method("get_passive_status_icon_key_for_test"), "HUD should expose passive status icon key for tests")
	if hud.has_method("get_passive_status_icon_key_for_test"):
		_expect(str(hud.call("get_passive_status_icon_key_for_test")) == expected_icon_key, "HUD passive status icon key should match %s" % character_name)
	var expected_texture_path := CONTENT_ICON_REGISTRY.get_texture_path(expected_icon_key, "characters")
	_expect(hud.has_method("get_passive_status_icon_texture_path_for_test"), "HUD should expose passive status icon texture path for tests")
	if hud.has_method("get_passive_status_icon_texture_path_for_test"):
		_expect(str(hud.call("get_passive_status_icon_texture_path_for_test")) == expected_texture_path, "HUD passive status icon texture should come from the content icon registry for %s" % character_name)
	var expected_icon_visible := not expected_texture_path.is_empty()
	_expect(hud.has_method("is_passive_status_icon_visible_for_test"), "HUD should expose passive status icon visibility for tests")
	if hud.has_method("is_passive_status_icon_visible_for_test"):
		_expect(bool(hud.call("is_passive_status_icon_visible_for_test")) == expected_icon_visible, "HUD passive status icon visibility should match registry texture availability for %s" % character_name)
	_expect(hud.has_method("get_passive_status_token_text_for_test"), "HUD should expose passive status fallback token for tests")
	if hud.has_method("get_passive_status_token_text_for_test"):
		_expect(str(hud.call("get_passive_status_token_text_for_test")) == CONTENT_ICON_REGISTRY.get_type_token(expected_icon_key, "characters"), "HUD passive status fallback token should come from the content icon registry for %s" % character_name)


func _hud_loadout_contains(hud: Node, expected_name: String) -> bool:
	if hud == null or not hud.has_method("get_weapon_slot_loadout_summary_for_test"):
		return false
	var summary: Dictionary = hud.call("get_weapon_slot_loadout_summary_for_test")
	var names: Array = summary.get("names", [])
	for name in names:
		if str(name) == expected_name:
			return true
	return false


func _run_summary_loadout_contains(summary: Dictionary, expected_name: String) -> bool:
	var names: Array = summary.get("loadout", [])
	for name in names:
		if str(name) == expected_name:
			return true
	return false


func _finish() -> void:
	get_tree().paused = false
	if _failures.is_empty():
		print("CharacterSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

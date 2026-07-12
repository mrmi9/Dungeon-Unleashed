extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const CONTENT_ICON_REGISTRY := preload("res://scripts/content/ContentIconRegistry.gd")
const ENEMY_SCENE := preload("res://scenes/enemies/Enemy.tscn")
const PROJECTILE_SCENE := preload("res://scenes/projectiles/Projectile.tscn")
const ENEMY_PROJECTILE_SCENE := preload("res://scenes/projectiles/EnemyProjectile.tscn")
const ARC_BLADE := preload("res://resources/weapons/arc_blade.tres")
const NOVA_CORE := preload("res://resources/weapons/nova_core.tres")
const BLAST_LAUNCHER := preload("res://resources/weapons/blast_launcher.tres")
const LASER_LANCE := preload("res://resources/weapons/laser_lance.tres")
const EMBER_SPRAYER := preload("res://resources/weapons/ember_sprayer.tres")
const FROST_SICKLE := preload("res://resources/weapons/frost_sickle.tres")
const GUARD_CLEAVER := preload("res://resources/weapons/guard_cleaver.tres")
const COIL_BOW := preload("res://resources/weapons/coil_bow.tres")
const SNARE_BEACON := preload("res://resources/weapons/snare_beacon.tres")
const EMBER_MINE := preload("res://resources/weapons/ember_mine.tres")
const SENTRY_SEED := preload("res://resources/weapons/sentry_seed.tres")
const COMPASS_NEEDLE := preload("res://resources/weapons/compass_needle.tres")
const RELAY_ARC := preload("res://resources/weapons/relay_arc.tres")

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	if main.has_method("start_new_run"):
		main.call("start_new_run")

	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().create_timer(0.1).timeout

	var player := main.get_node("Player") as Player
	_expect(player != null, "Player should exist")
	if player == null:
		_finish()
		return

	var hud = main.get_node_or_null("CanvasLayer/HUD")
	var audio_feedback = main.get_node_or_null("AudioFeedback")
	_expect(player.weapon_loadout.size() == 3, "Player should have 3 weapons in loadout")
	if hud != null and hud.has_method("get_weapon_slot_index_text"):
		_expect(str(hud.call("get_weapon_slot_index_text")) == "1/3", "HUD weapon slot should show the starting weapon slot index")
	if hud != null and hud.has_method("get_weapon_slot_name_text"):
		_expect(str(hud.call("get_weapon_slot_name_text")).contains(player.weapon_loadout[0].display_name), "HUD weapon slot should show the starting weapon name")
	if hud != null and hud.has_method("get_weapon_slot_loadout_summary_for_test"):
		var starting_loadout_summary: Dictionary = hud.call("get_weapon_slot_loadout_summary_for_test")
		var starting_loadout_names: Array = starting_loadout_summary.get("names", [])
		var starting_loadout_entries: Array = starting_loadout_summary.get("entries", [])
		var starting_loadout_icon_keys: Array = starting_loadout_summary.get("icon_keys", [])
		var starting_loadout_icon_paths: Array = starting_loadout_summary.get("icon_texture_paths", [])
		var starting_loadout_icon_visibility: Array = starting_loadout_summary.get("icon_texture_visible", [])
		var starting_loadout_tooltips: Array = starting_loadout_summary.get("tooltips", [])
		var starting_loadout_border_colors: Array = starting_loadout_summary.get("slot_border_colors", [])
		var starting_loadout_border_widths: Array = starting_loadout_summary.get("slot_border_widths", [])
		var starting_loadout_ammo_summaries: Array = starting_loadout_summary.get("ammo_summaries", [])
		var starting_loadout_energy_states: Array = starting_loadout_summary.get("energy_states", [])
		var starting_loadout_energy_needs: Array = starting_loadout_summary.get("energy_needs", [])
		_expect(int(starting_loadout_summary.get("active_slot", 0)) == 1, "HUD weapon loadout preview should mark slot 1 active at start")
		_expect(starting_loadout_names.size() == player.weapon_loadout.size(), "HUD weapon loadout preview should list every starting weapon")
		_expect(str(starting_loadout_names[0]) == player.weapon_loadout[0].display_name, "HUD weapon loadout preview should list the first weapon")
		_expect(str(starting_loadout_names[1]) == player.weapon_loadout[1].display_name, "HUD weapon loadout preview should list the second weapon")
		_expect(not starting_loadout_entries.is_empty() and str(starting_loadout_entries[0].get("rarity", "")) == player.weapon_loadout[0].rarity, "HUD weapon loadout preview should expose weapon rarity metadata")
		_expect(not starting_loadout_entries.is_empty() and str(starting_loadout_entries[0].get("weapon_class", "")) == player.weapon_loadout[0].weapon_class, "HUD weapon loadout preview should expose weapon class metadata")
		_expect(not starting_loadout_entries.is_empty() and str(starting_loadout_entries[0].get("icon_key", "")) == _resolve_weapon_icon_key(player.weapon_loadout[0]), "HUD weapon loadout preview should expose weapon icon key metadata")
		_expect(starting_loadout_icon_keys.size() == player.weapon_loadout.size(), "HUD weapon loadout preview should expose one icon key per weapon slot")
		_expect(not starting_loadout_icon_keys.is_empty() and str(starting_loadout_icon_keys[0]) == _resolve_weapon_icon_key(player.weapon_loadout[0]), "HUD weapon loadout preview slot 1 should expose the current weapon icon key")
		_expect(not starting_loadout_icon_paths.is_empty() and not starting_loadout_icon_keys.is_empty() and str(starting_loadout_icon_paths[0]) == CONTENT_ICON_REGISTRY.get_texture_path(str(starting_loadout_icon_keys[0]), "weapons"), "HUD weapon loadout preview slot 1 icon texture should come from the registry")
		_expect(not starting_loadout_icon_paths.is_empty() and str(starting_loadout_icon_paths[0]).ends_with("basic_pistol.svg"), "HUD weapon loadout preview slot 1 should use the Basic Pistol icon")
		_expect(starting_loadout_icon_paths.size() > 1 and str(starting_loadout_icon_paths[1]).ends_with("shotgun.svg"), "HUD weapon loadout preview slot 2 should use the Shotgun icon")
		_expect(starting_loadout_icon_paths.size() > 2 and str(starting_loadout_icon_paths[2]).ends_with("energy_staff.svg"), "HUD weapon loadout preview slot 3 should use the Energy Staff icon")
		_expect(not starting_loadout_icon_visibility.is_empty() and bool(starting_loadout_icon_visibility[0]), "HUD weapon loadout preview slot 1 icon should be visible")
		_expect(not starting_loadout_tooltips.is_empty() and not starting_loadout_icon_keys.is_empty() and str(starting_loadout_tooltips[0]).contains(str(starting_loadout_icon_keys[0])), "HUD weapon loadout preview tooltip should expose slot icon key")
		_expect(not starting_loadout_border_widths.is_empty() and int(starting_loadout_border_widths[0]) >= 2, "HUD weapon loadout preview slot 1 should use an active slot border")
		_expect(starting_loadout_border_widths.size() > 1 and int(starting_loadout_border_widths[1]) == 1, "HUD weapon loadout preview inactive slots should use a lighter border")
		_expect(not starting_loadout_border_colors.is_empty() and typeof(starting_loadout_border_colors[0]) == TYPE_COLOR, "HUD weapon loadout preview slot 1 should expose a readable border color")
		_expect(not starting_loadout_ammo_summaries.is_empty() and str(starting_loadout_ammo_summaries[0]) == "%d/%d" % [player.weapon.get_current_ammo(), player.weapon.get_magazine_size()], "HUD weapon loadout preview active slot should expose current ammo")
		_expect(starting_loadout_ammo_summaries.size() > 1 and str(starting_loadout_ammo_summaries[1]) == "M%d/E%d" % [int(player.weapon_loadout[1].get("magazine_size")), int(player.weapon_loadout[1].get("energy_cost"))], "HUD weapon loadout preview inactive slot should expose magazine and energy summary")
		_expect(not starting_loadout_energy_states.is_empty() and str(starting_loadout_energy_states[0]) == "free", "HUD weapon loadout preview should mark zero-cost weapons as free")
		_expect(starting_loadout_energy_states.size() > 1 and str(starting_loadout_energy_states[1]) == "ready", "HUD weapon loadout preview should mark affordable inactive weapons as ready")
		_expect(starting_loadout_energy_needs.size() > 1 and int(starting_loadout_energy_needs[1]) == 0, "HUD weapon loadout preview should not report energy need for affordable inactive weapons")
		_expect(str(starting_loadout_summary.get("text", "")).contains("ST/"), "HUD weapon loadout preview should include a rarity/class prefix")
		player.set("_energy_regen_delay_timer", 10.0)
		player.current_energy = maxi(int(player.weapon_loadout[1].get("energy_cost")) - 1, 0)
		player.energy_changed.emit(player.current_energy, player.max_energy)
		var low_energy_loadout_summary: Dictionary = hud.call("get_weapon_slot_loadout_summary_for_test")
		var low_energy_states: Array = low_energy_loadout_summary.get("energy_states", [])
		var low_energy_needs: Array = low_energy_loadout_summary.get("energy_needs", [])
		var low_energy_tooltips: Array = low_energy_loadout_summary.get("tooltips", [])
		var low_energy_label_colors: Array = low_energy_loadout_summary.get("label_colors", [])
		_expect(not low_energy_states.is_empty() and str(low_energy_states[0]) == "free", "HUD weapon loadout preview should keep zero-cost weapons free when energy is low")
		_expect(low_energy_states.size() > 1 and str(low_energy_states[1]) == "blocked", "HUD weapon loadout preview should mark unaffordable inactive weapons as blocked")
		_expect(low_energy_needs.size() > 1 and int(low_energy_needs[1]) == 1, "HUD weapon loadout preview should expose missing energy for blocked weapons")
		_expect(low_energy_tooltips.size() > 1 and str(low_energy_tooltips[1]).contains("Need"), "HUD weapon loadout preview tooltip should explain blocked energy")
		if low_energy_label_colors.size() > 1 and typeof(low_energy_label_colors[1]) == TYPE_COLOR:
			var low_energy_color: Color = low_energy_label_colors[1]
			_expect(low_energy_color.r > 0.75 and low_energy_color.g < 0.75, "HUD weapon loadout preview blocked slot text should shift toward warning color")
		player.current_energy = player.max_energy
		player.energy_changed.emit(player.current_energy, player.max_energy)
		player.set("_energy_regen_delay_timer", 0.0)
		var restored_energy_loadout_summary: Dictionary = hud.call("get_weapon_slot_loadout_summary_for_test")
		var restored_energy_states: Array = restored_energy_loadout_summary.get("energy_states", [])
		_expect(restored_energy_states.size() > 1 and str(restored_energy_states[1]) == "ready", "HUD weapon loadout preview should return inactive weapon energy state to ready after energy is restored")
	if hud != null and hud.has_method("get_weapon_slot_meta_text"):
		var starting_meta_text := str(hud.call("get_weapon_slot_meta_text"))
		_expect(starting_meta_text.contains(player.weapon_loadout[0].rarity.capitalize()), "HUD weapon slot meta should show current weapon rarity")
		_expect(starting_meta_text.contains(player.weapon_loadout[0].weapon_class.capitalize()), "HUD weapon slot meta should show current weapon class")
		_expect(starting_meta_text.contains(player.weapon_loadout[0].recommended_range.capitalize()), "HUD weapon slot meta should show current weapon recommended range")
		_expect(starting_meta_text.contains("E%d" % int(player.weapon_loadout[0].energy_cost)), "HUD weapon slot meta should show current weapon energy cost")
	if hud != null and hud.has_method("get_weapon_slot_visual_summary_for_test"):
		var starting_visual_summary: Dictionary = hud.call("get_weapon_slot_visual_summary_for_test")
		_expect(str(starting_visual_summary.get("icon", "")).length() >= 2, "HUD weapon slot should show a class icon token")
		_expect(str(starting_visual_summary.get("icon_key", "")) == _resolve_weapon_icon_key(player.weapon_loadout[0]), "HUD weapon slot should expose current weapon icon key")
		_expect(str(starting_visual_summary.get("icon_texture_path", "")) == CONTENT_ICON_REGISTRY.get_texture_path(str(starting_visual_summary.get("icon_key", "")), "weapons"), "HUD weapon slot icon texture should come from the content icon registry")
		_expect(str(starting_visual_summary.get("icon_texture_path", "")).ends_with("basic_pistol.svg"), "HUD weapon slot should use the Basic Pistol weapon icon when available")
		_expect(bool(starting_visual_summary.get("icon_texture_visible", false)), "HUD weapon slot icon texture should be visible when registry texture exists")
		_expect(str(starting_visual_summary.get("icon_tooltip", "")).contains(str(starting_visual_summary.get("icon_key", ""))), "HUD weapon slot icon tooltip should expose icon key")
		_expect(str(starting_visual_summary.get("type", "")).contains(player.weapon_loadout[0].weapon_class.capitalize()), "HUD weapon slot should show a readable type symbol")
		_expect(str(starting_visual_summary.get("energy", "")) == "E%d" % int(player.weapon_loadout[0].energy_cost), "HUD weapon slot should show current weapon energy symbol")
		_expect(typeof(starting_visual_summary.get("rarity_color")) == TYPE_COLOR, "HUD weapon slot should expose rarity strip color")
	if hud != null and hud.has_method("get_weapon_slot_panel_summary_for_test"):
		var starting_panel_summary: Dictionary = hud.call("get_weapon_slot_panel_summary_for_test")
		_expect(int(starting_panel_summary.get("active_slot", 0)) == 1, "HUD weapon slot panel should mark the starting slot active")
		_expect(int(starting_panel_summary.get("border_width", 0)) >= 2, "HUD weapon slot panel should use a visible active-slot border")
		_expect(typeof(starting_panel_summary.get("border_color")) == TYPE_COLOR, "HUD weapon slot panel should expose a rarity border color")

	player.call("_equip_weapon", 1)
	if hud != null and hud.has_method("get_weapon_slot_index_text"):
		_expect(str(hud.call("get_weapon_slot_index_text")) == "2/3", "HUD weapon slot should update after switching weapons")
	if hud != null and hud.has_method("get_weapon_slot_name_text"):
		_expect(str(hud.call("get_weapon_slot_name_text")).contains(player.weapon_loadout[1].display_name), "HUD weapon slot should show the switched weapon name")
	if hud != null and hud.has_method("get_weapon_slot_loadout_summary_for_test"):
		var switched_loadout_summary: Dictionary = hud.call("get_weapon_slot_loadout_summary_for_test")
		var switched_loadout_icon_keys: Array = switched_loadout_summary.get("icon_keys", [])
		var switched_loadout_icon_paths: Array = switched_loadout_summary.get("icon_texture_paths", [])
		var switched_loadout_icon_visibility: Array = switched_loadout_summary.get("icon_texture_visible", [])
		var switched_loadout_icon_modulates: Array = switched_loadout_summary.get("icon_modulates", [])
		var switched_loadout_border_colors: Array = switched_loadout_summary.get("slot_border_colors", [])
		var switched_loadout_border_widths: Array = switched_loadout_summary.get("slot_border_widths", [])
		_expect(int(switched_loadout_summary.get("active_slot", 0)) == 2, "HUD weapon loadout preview should mark slot 2 active after switching")
		_expect(switched_loadout_icon_keys.size() > 1 and str(switched_loadout_icon_keys[1]) == _resolve_weapon_icon_key(player.weapon_loadout[1]), "HUD weapon loadout preview slot 2 icon key should track switched weapon")
		_expect(switched_loadout_icon_paths.size() > 1 and switched_loadout_icon_keys.size() > 1 and str(switched_loadout_icon_paths[1]) == CONTENT_ICON_REGISTRY.get_texture_path(str(switched_loadout_icon_keys[1]), "weapons"), "HUD weapon loadout preview slot 2 icon texture should come from the registry")
		_expect(switched_loadout_icon_visibility.size() > 1 and bool(switched_loadout_icon_visibility[1]), "HUD weapon loadout preview slot 2 icon should be visible after switching")
		if switched_loadout_icon_modulates.size() > 1 and typeof(switched_loadout_icon_modulates[1]) == TYPE_COLOR:
			var switched_loadout_icon_modulate: Color = switched_loadout_icon_modulates[1]
			_expect(switched_loadout_icon_modulate.r > 0.95 and switched_loadout_icon_modulate.g > 0.9 and switched_loadout_icon_modulate.b < 0.9, "HUD weapon loadout preview active icon should flash toward switch yellow")
		_expect(switched_loadout_border_widths.size() > 1 and int(switched_loadout_border_widths[1]) >= 2, "HUD weapon loadout preview active slot should keep a thick border after switching")
		if switched_loadout_border_colors.size() > 1 and typeof(switched_loadout_border_colors[1]) == TYPE_COLOR:
			var switched_loadout_border_color: Color = switched_loadout_border_colors[1]
			_expect(switched_loadout_border_color.r > 0.95 and switched_loadout_border_color.g > 0.85 and switched_loadout_border_color.b < 0.85, "HUD weapon loadout preview active border should flash toward switch yellow")
	if hud != null and hud.has_method("get_weapon_slot_meta_text"):
		var switched_meta_text := str(hud.call("get_weapon_slot_meta_text"))
		_expect(switched_meta_text.contains(player.weapon_loadout[1].weapon_class.capitalize()), "HUD weapon slot meta should update after switching weapons")
	if hud != null and hud.has_method("get_weapon_slot_visual_summary_for_test"):
		var switched_visual_summary: Dictionary = hud.call("get_weapon_slot_visual_summary_for_test")
		_expect(str(switched_visual_summary.get("icon_key", "")) == _resolve_weapon_icon_key(player.weapon_loadout[1]), "HUD weapon slot icon key should update after switching weapons")
		_expect(str(switched_visual_summary.get("icon_texture_path", "")) == CONTENT_ICON_REGISTRY.get_texture_path(str(switched_visual_summary.get("icon_key", "")), "weapons"), "HUD weapon slot icon texture should follow registry after switching weapons")
		_expect(bool(switched_visual_summary.get("icon_texture_visible", false)), "HUD weapon slot icon texture should remain visible after switching weapons")
		if typeof(switched_visual_summary.get("icon_modulate")) == TYPE_COLOR:
			var switched_icon_modulate: Color = switched_visual_summary.get("icon_modulate")
			_expect(switched_icon_modulate.r > 0.95 and switched_icon_modulate.g > 0.9 and switched_icon_modulate.b < 0.9, "HUD weapon slot icon should flash toward switch yellow")
		_expect(str(switched_visual_summary.get("type", "")).contains(player.weapon_loadout[1].weapon_class.capitalize()), "HUD weapon slot type symbol should update after switching weapons")
		_expect(str(switched_visual_summary.get("energy", "")) == "E%d" % int(player.weapon_loadout[1].energy_cost), "HUD weapon slot energy symbol should update after switching weapons")
	if hud != null and hud.has_method("get_weapon_slot_panel_summary_for_test"):
		var switched_panel_summary: Dictionary = hud.call("get_weapon_slot_panel_summary_for_test")
		_expect(int(switched_panel_summary.get("active_slot", 0)) == 2, "HUD weapon slot panel should track the active slot after switching weapons")
		_expect(typeof(switched_panel_summary.get("border_color")) == TYPE_COLOR, "HUD weapon slot panel border should remain readable after switching weapons")
	if hud != null and hud.has_method("is_weapon_slot_switch_pulse_active"):
		_expect(bool(hud.call("is_weapon_slot_switch_pulse_active")), "HUD weapon slot should pulse when switching active weapons")
	if hud != null and hud.has_method("get_weapon_slot_active_loadout_color_for_test"):
		var switched_active_slot_color: Color = hud.call("get_weapon_slot_active_loadout_color_for_test")
		_expect(switched_active_slot_color.r > 0.9 and switched_active_slot_color.g > 0.82, "HUD weapon loadout active slot should brighten during switch pulse")
	if hud != null and hud.has_method("is_weapon_slot_switch_pulse_active"):
		hud.call("_process", 0.42)
		_expect(not bool(hud.call("is_weapon_slot_switch_pulse_active")), "HUD weapon slot switch pulse should fade after its duration")

	for index in range(player.weapon_loadout.size()):
		var data := player.weapon_loadout[index]
		player.call("_equip_weapon", index)
		await get_tree().process_frame

		_clear_projectiles()
		var weapon := player.weapon
		var energy_before := player.get_energy()
		var expected_energy_cost := int(data.get("energy_cost"))
		var sfx_count_before := int(audio_feedback.call("get_sfx_play_count")) if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count") else -1
		var fired := weapon.try_fire(player.global_position + Vector2(320, 0), player)

		_expect(fired, "%s should fire" % data.display_name)
		_expect(_projectile_count() == maxi(data.projectile_count, 1), "%s projectile count should match WeaponData" % data.display_name)
		_expect(weapon.get_current_ammo() == weapon.get_magazine_size() - 1, "%s should consume one ammo per trigger pull" % data.display_name)
		_expect(player.get_energy() == energy_before - expected_energy_cost, "%s should spend configured energy cost" % data.display_name)
		if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count") and sfx_count_before >= 0:
			_expect(int(audio_feedback.call("get_sfx_play_count")) > sfx_count_before, "%s should trigger fire SFX" % data.display_name)
		if audio_feedback != null and audio_feedback.has_method("get_last_sfx_id_for_test"):
			_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == str(data.get("fire_sfx_key")), "%s should use its configured fire SFX key" % data.display_name)
		await get_tree().process_frame

		if data.id == &"energy_staff":
			var projectile := get_tree().get_first_node_in_group("projectiles")
			_expect(projectile != null and projectile.get("_remaining_pierce") == data.pierce_count, "Energy Staff projectile should carry pierce count")

	await _verify_special_weapon_modes(player)
	await _verify_energy_weapon_gate(player, main)
	player.call("_equip_weapon", 0)
	await get_tree().process_frame
	var pistol := player.weapon
	_clear_projectiles()
	for index in range(pistol.get_magazine_size()):
		pistol.try_fire(player.global_position + Vector2(320, 0), player)
		await get_tree().create_timer(1.0 / pistol.weapon_data.fire_rate + 0.02).timeout

	_expect(pistol.get_current_ammo() == 0, "Pistol magazine should reach 0 after firing full magazine")
	_expect(pistol.is_reloading(), "Pistol should auto reload after empty magazine")
	if hud != null and hud.has_method("get_weapon_slot_status_text"):
		_expect(str(hud.call("get_weapon_slot_status_text")).contains("Reloading"), "HUD weapon slot should show Reloading while the weapon reloads")
	if hud != null and hud.has_method("get_weapon_slot_loadout_summary_for_test"):
		var reloading_loadout_summary: Dictionary = hud.call("get_weapon_slot_loadout_summary_for_test")
		var reloading_ammo_summaries: Array = reloading_loadout_summary.get("ammo_summaries", [])
		_expect(not reloading_ammo_summaries.is_empty() and str(reloading_ammo_summaries[0]) == "RLD", "HUD weapon loadout preview active slot should show reloading state")
	if hud != null and hud.has_method("get_weapon_slot_magazine_segment_summary_for_test"):
		var reloading_segment_summary: Dictionary = hud.call("get_weapon_slot_magazine_segment_summary_for_test")
		_expect(int(reloading_segment_summary.get("segments", 0)) == mini(pistol.get_magazine_size(), 12), "HUD weapon slot should cap magazine pips to the weapon magazine size or 12")
		_expect(int(reloading_segment_summary.get("filled", -1)) == 0, "HUD weapon slot magazine pips should be empty while the pistol reloads from 0")
		_expect(bool(reloading_segment_summary.get("reload_sweep_active", false)), "HUD weapon slot should animate magazine pips while reloading")
		var initial_reload_sweep_index := int(reloading_segment_summary.get("reload_sweep_index", -1))
		_expect(initial_reload_sweep_index >= 0 and initial_reload_sweep_index < int(reloading_segment_summary.get("segments", 0)), "HUD weapon slot reload sweep should point at a valid pip")
		if hud.has_method("get_weapon_slot_reload_sweep_segment_color_for_test"):
			var reload_sweep_color: Color = hud.call("get_weapon_slot_reload_sweep_segment_color_for_test")
			_expect(reload_sweep_color.r > 0.95 and reload_sweep_color.g > 0.8, "HUD weapon slot reload sweep pip should brighten while reloading")
		hud.call("_process", 0.12)
		var advanced_reload_segment_summary: Dictionary = hud.call("get_weapon_slot_magazine_segment_summary_for_test")
		_expect(int(advanced_reload_segment_summary.get("reload_sweep_index", -1)) != initial_reload_sweep_index, "HUD weapon slot reload sweep should advance while reloading")
	var reload_sfx_count_before := int(audio_feedback.call("get_sfx_play_count")) if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count") else -1
	pistol.call("_process", pistol.weapon_data.reload_duration + 0.1)
	_expect(not pistol.is_reloading(), "Pistol reload should finish")
	_expect(pistol.get_current_ammo() == pistol.get_magazine_size(), "Pistol ammo should refill after reload")
	if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count") and reload_sfx_count_before >= 0:
		_expect(int(audio_feedback.call("get_sfx_play_count")) > reload_sfx_count_before, "Pistol reload completion should trigger reload-ready SFX")
	if audio_feedback != null and audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "reload_ready", "Pistol reload completion should use the reload_ready SFX")
	if hud != null and hud.has_method("get_ammo_label_text"):
		_expect(str(hud.call("get_ammo_label_text")).contains("%d / %d" % [pistol.get_magazine_size(), pistol.get_magazine_size()]), "HUD ammo text should show a full magazine after reload")
	if hud != null and hud.has_method("get_weapon_slot_name_text"):
		_expect(str(hud.call("get_weapon_slot_name_text")).contains(pistol.weapon_data.display_name), "HUD weapon slot should keep showing the reloaded weapon")
	if hud != null and hud.has_method("get_weapon_slot_status_text"):
		var weapon_slot_status := str(hud.call("get_weapon_slot_status_text"))
		_expect(weapon_slot_status.contains("%d / %d" % [pistol.get_magazine_size(), pistol.get_magazine_size()]) and weapon_slot_status.contains("Ready"), "HUD weapon slot should show full ammo and Ready after reload")
	if hud != null and hud.has_method("get_weapon_slot_loadout_summary_for_test"):
		var reloaded_loadout_summary: Dictionary = hud.call("get_weapon_slot_loadout_summary_for_test")
		var reloaded_ammo_summaries: Array = reloaded_loadout_summary.get("ammo_summaries", [])
		_expect(not reloaded_ammo_summaries.is_empty() and str(reloaded_ammo_summaries[0]) == "%d/%d" % [pistol.get_magazine_size(), pistol.get_magazine_size()], "HUD weapon loadout preview active slot should return to full ammo after reload")
	if hud != null and hud.has_method("get_weapon_slot_magazine_segment_summary_for_test"):
		var ready_segment_summary: Dictionary = hud.call("get_weapon_slot_magazine_segment_summary_for_test")
		_expect(int(ready_segment_summary.get("segments", 0)) == mini(pistol.get_magazine_size(), 12), "HUD weapon slot should keep a bounded magazine pip count after reload")
		_expect(int(ready_segment_summary.get("filled", 0)) == int(ready_segment_summary.get("segments", -1)), "HUD weapon slot magazine pips should be full after reload")
	if hud != null and hud.has_method("is_ammo_ready_pulse_active"):
		_expect(bool(hud.call("is_ammo_ready_pulse_active")), "HUD should pulse Ammo when reload completes")
	if hud != null and hud.has_method("get_ammo_label_color_for_test"):
		var ammo_ready_color: Color = hud.call("get_ammo_label_color_for_test")
		_expect(ammo_ready_color.g > 0.95 and ammo_ready_color.r < 0.75, "Ammo ready pulse should shift the ammo label toward green while active")
	if hud != null and hud.has_method("get_weapon_label_text"):
		_expect(str(hud.call("get_weapon_label_text")).contains(pistol.weapon_data.display_name), "HUD weapon text should keep showing the reloaded weapon")
	if hud != null and hud.has_method("is_weapon_ready_pulse_active"):
		_expect(bool(hud.call("is_weapon_ready_pulse_active")), "HUD should pulse the weapon row when reload completes")
	if hud != null and hud.has_method("get_weapon_label_color_for_test"):
		var weapon_ready_color: Color = hud.call("get_weapon_label_color_for_test")
		_expect(weapon_ready_color.g > 0.95 and weapon_ready_color.r < 0.75, "Weapon ready pulse should shift the weapon label toward green while active")
	if hud != null and hud.has_method("get_weapon_slot_bar_color_for_test"):
		var weapon_slot_bar_color: Color = hud.call("get_weapon_slot_bar_color_for_test")
		_expect(weapon_slot_bar_color.g > 0.9 and weapon_slot_bar_color.r < 0.55, "Weapon slot status bar should flash green when reload completes")
	if hud != null and hud.has_method("get_weapon_slot_panel_summary_for_test"):
		var ready_panel_summary: Dictionary = hud.call("get_weapon_slot_panel_summary_for_test")
		var ready_panel_border_color: Color = ready_panel_summary.get("border_color")
		_expect(int(ready_panel_summary.get("border_width", 0)) >= 2, "Weapon slot active border should remain visible after reload completes")
		_expect(ready_panel_border_color.g > 0.75, "Weapon slot border should brighten toward ready feedback after reload completes")
	if hud != null and hud.has_method("get_weapon_slot_visual_summary_for_test"):
		var ready_visual_summary: Dictionary = hud.call("get_weapon_slot_visual_summary_for_test")
		if typeof(ready_visual_summary.get("icon_modulate")) == TYPE_COLOR:
			var ready_icon_modulate: Color = ready_visual_summary.get("icon_modulate")
			_expect(ready_icon_modulate.g > 0.95 and ready_icon_modulate.r < 0.9, "Weapon slot icon should flash green when reload completes")
	if hud != null and hud.has_method("get_weapon_slot_loadout_summary_for_test"):
		var ready_loadout_summary: Dictionary = hud.call("get_weapon_slot_loadout_summary_for_test")
		var ready_loadout_icon_modulates: Array = ready_loadout_summary.get("icon_modulates", [])
		var ready_loadout_border_colors: Array = ready_loadout_summary.get("slot_border_colors", [])
		var ready_loadout_border_widths: Array = ready_loadout_summary.get("slot_border_widths", [])
		if not ready_loadout_icon_modulates.is_empty() and typeof(ready_loadout_icon_modulates[0]) == TYPE_COLOR:
			var ready_loadout_icon_modulate: Color = ready_loadout_icon_modulates[0]
			_expect(ready_loadout_icon_modulate.g > 0.95 and ready_loadout_icon_modulate.r < 0.9, "Active loadout slot icon should flash green when reload completes")
		_expect(not ready_loadout_border_widths.is_empty() and int(ready_loadout_border_widths[0]) >= 2, "Active loadout slot border should stay thick when reload completes")
		if not ready_loadout_border_colors.is_empty() and typeof(ready_loadout_border_colors[0]) == TYPE_COLOR:
			var ready_loadout_border_color: Color = ready_loadout_border_colors[0]
			_expect(ready_loadout_border_color.g > 0.9 and ready_loadout_border_color.r < 0.9, "Active loadout slot border should flash green when reload completes")
	if hud != null and hud.has_method("get_weapon_slot_magazine_first_segment_color_for_test"):
		var weapon_slot_segment_color: Color = hud.call("get_weapon_slot_magazine_first_segment_color_for_test")
		_expect(weapon_slot_segment_color.g > 0.9 and weapon_slot_segment_color.r < 0.65, "Weapon slot magazine pips should flash green when reload completes")
	if hud != null and hud.has_method("is_ammo_ready_pulse_active"):
		hud.call("_process", 0.55)
		_expect(not bool(hud.call("is_ammo_ready_pulse_active")), "HUD ammo ready pulse should fade after its duration")
	if hud != null and hud.has_method("is_weapon_ready_pulse_active"):
		_expect(not bool(hud.call("is_weapon_ready_pulse_active")), "HUD weapon ready pulse should fade after its duration")
	_verify_critical_damage_roll()

	_clear_projectiles()
	_finish()


func _verify_energy_weapon_gate(player: Player, main: Node) -> void:
	player.call("_equip_weapon", 1)
	await get_tree().process_frame
	var weapon := player.weapon
	var weapon_data := weapon.weapon_data
	var hud = main.get_node_or_null("CanvasLayer/HUD")
	var audio_feedback = main.get_node_or_null("AudioFeedback")
	_expect(int(weapon_data.get("energy_cost")) > 0, "Energy gate check should use a weapon with energy cost")

	player.current_energy = 0
	player.energy_changed.emit(player.current_energy, player.max_energy)
	weapon.set("_cooldown", 0.0)
	var ammo_before := weapon.get_current_ammo()
	var floating_count_before := int(main.call("get_floating_text_count")) if main.has_method("get_floating_text_count") else 0
	var sfx_count_before := int(audio_feedback.call("get_sfx_play_count")) if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count") else -1
	_clear_projectiles()
	var fired_without_energy := weapon.try_fire(player.global_position + Vector2(320, 0), player)
	_expect(not fired_without_energy, "Weapon should not fire when player has insufficient energy")
	_expect(weapon.get_current_ammo() == ammo_before, "Failed energy-gated fire should not consume ammo")
	_expect(_projectile_count() == 0, "Failed energy-gated fire should not spawn projectiles")
	if hud != null and hud.has_method("get_energy_label_text"):
		_expect(str(hud.call("get_energy_label_text")).ends_with("!"), "Failed energy-gated fire should mark the compact HUD energy warning")
	if hud != null and hud.has_method("is_energy_warning_active"):
		_expect(bool(hud.call("is_energy_warning_active")), "Failed energy-gated fire should activate the HUD energy warning")
	if hud != null and hud.has_method("get_energy_label_color_for_test"):
		var energy_warning_color: Color = hud.call("get_energy_label_color_for_test")
		_expect(energy_warning_color.r > 0.5 and energy_warning_color.g > 0.8, "Energy warning should brighten the energy label while active")
	if hud != null and hud.has_method("get_weapon_slot_energy_symbol_color_for_test"):
		var weapon_slot_energy_warning_color: Color = hud.call("get_weapon_slot_energy_symbol_color_for_test")
		_expect(weapon_slot_energy_warning_color.r > 0.95 and weapon_slot_energy_warning_color.g > 0.86, "Energy warning should brighten the weapon slot energy symbol while active")
	if main.has_method("get_floating_text_count") and main.has_method("get_floating_text_snapshots"):
		_expect(int(main.call("get_floating_text_count")) > floating_count_before, "Failed energy-gated fire should spawn a feedback floating text")
		_expect(_has_floating_text(main, "NO ENERGY"), "Failed energy-gated fire should show NO ENERGY feedback")
	if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count") and sfx_count_before >= 0:
		_expect(int(audio_feedback.call("get_sfx_play_count")) > sfx_count_before, "Failed energy-gated fire should trigger energy-empty SFX")
	if audio_feedback != null and audio_feedback.has_method("get_last_sfx_id_for_test"):
		_expect(str(audio_feedback.call("get_last_sfx_id_for_test")) == "energy_empty", "Failed energy-gated fire should use the energy_empty SFX")
	await get_tree().process_frame
	if hud != null and hud.has_method("is_energy_warning_active"):
		hud.call("_process", 1.0)
		_expect(not bool(hud.call("is_energy_warning_active")), "HUD energy warning should fade after its duration")
	if hud != null and hud.has_method("get_weapon_slot_energy_symbol_color_for_test"):
		var weapon_slot_energy_restored_color: Color = hud.call("get_weapon_slot_energy_symbol_color_for_test")
		_expect(weapon_slot_energy_restored_color.g < 0.86, "Weapon slot energy symbol warning color should restore after warning fades")

	player.set("_energy_regen_delay_timer", 0.0)
	player.call("_tick_timers", 0.25)
	await get_tree().process_frame
	_expect(player.get_energy() > 0, "Player energy should regenerate after delay")
	player.recover_energy(player.max_energy)


func _verify_special_weapon_modes(player: Player) -> void:
	await _verify_melee_weapon(player)
	await _verify_radial_weapon(player)
	await _verify_explosive_weapon(player)
	await _verify_laser_weapon(player)
	await _verify_status_weapon_effects(player)
	await _verify_projectile_blocking_melee(player)
	await _verify_charge_weapon(player)
	await _verify_deployable_weapon(player)
	await _verify_deployable_behavior_variants(player)
	await _verify_homing_and_chain_projectiles(player)


func _verify_melee_weapon(player: Player) -> void:
	var weapon := player.weapon
	weapon.set_weapon_data(ARC_BLADE)
	player.recover_energy(player.max_energy)
	await get_tree().process_frame

	var enemy := _spawn_test_enemy(weapon.muzzle.global_position + Vector2(58, 0), 7)
	_clear_projectiles()
	_clear_melee_sweep_flashes()
	var sweep_flash_count_before := _melee_sweep_flash_count()
	var fired := weapon.try_fire(weapon.muzzle.global_position + Vector2(160, 0), player)
	var sweep_flash := _get_active_melee_sweep_flash()

	_expect(fired, "Arc Blade should fire")
	_expect(_projectile_count() == 0, "Arc Blade melee sweep should not spawn projectiles")
	_expect(_melee_sweep_flash_count() > sweep_flash_count_before, "Arc Blade should spawn a visible melee sweep arc")
	_expect(sweep_flash != null, "Arc Blade sweep arc should remain visible for at least one frame")
	if sweep_flash != null and sweep_flash.has_method("get_radius_for_test"):
		_expect(is_equal_approx(float(sweep_flash.call("get_radius_for_test")), ARC_BLADE.projectile_range), "Arc Blade visible sweep radius should match WeaponData range")
	if sweep_flash != null and sweep_flash.has_method("get_arc_degrees_for_test"):
		_expect(is_equal_approx(float(sweep_flash.call("get_arc_degrees_for_test")), ARC_BLADE.spread_angle), "Arc Blade visible sweep arc should match WeaponData spread")
	_expect(enemy.current_health < enemy.max_health, "Arc Blade should damage enemies inside its sweep")
	await get_tree().process_frame
	enemy.queue_free()
	_clear_melee_sweep_flashes()


func _verify_radial_weapon(player: Player) -> void:
	var weapon := player.weapon
	weapon.set_weapon_data(NOVA_CORE)
	player.recover_energy(player.max_energy)
	await get_tree().process_frame

	_clear_projectiles()
	var energy_before := player.get_energy()
	var fired := weapon.try_fire(weapon.muzzle.global_position + Vector2(160, 0), player)
	await get_tree().process_frame

	_expect(fired, "Nova Core should fire")
	_expect(_projectile_count() == NOVA_CORE.projectile_count, "Nova Core should spawn a full radial projectile ring")
	_expect(player.get_energy() == energy_before - int(NOVA_CORE.get("energy_cost")), "Nova Core should spend configured energy")


func _verify_explosive_weapon(player: Player) -> void:
	var blast_data := BLAST_LAUNCHER.duplicate() as WeaponData
	blast_data.crit_chance = 0.0
	var primary := _spawn_test_enemy(player.global_position + Vector2(180, 0), 9)
	var secondary := _spawn_test_enemy(primary.global_position + Vector2(42, 0), 9)
	var projectile := PROJECTILE_SCENE.instantiate() as Projectile
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = primary.global_position
	projectile.call("launch", Vector2.RIGHT, blast_data, player)
	projectile.call("_handle_collision", primary)
	await get_tree().process_frame

	_expect(primary.current_health < primary.max_health, "Blast Launcher direct hit should damage primary target")
	_expect(secondary.current_health < secondary.max_health, "Blast Launcher explosion should damage nearby enemies")
	primary.queue_free()
	secondary.queue_free()


func _verify_laser_weapon(player: Player) -> void:
	var weapon := player.weapon
	weapon.set_weapon_data(LASER_LANCE)
	player.recover_energy(player.max_energy)
	await get_tree().process_frame

	_clear_projectiles()
	var fired := weapon.try_fire(weapon.muzzle.global_position + Vector2(260, 0), player)
	await get_tree().process_frame
	var projectile := get_tree().get_first_node_in_group("projectiles")
	_expect(fired, "Laser Lance should fire")
	_expect(projectile != null, "Laser Lance should spawn a beam-like projectile")
	if projectile != null:
		_expect(projectile.get("_remaining_pierce") == LASER_LANCE.pierce_count, "Laser Lance should carry high pierce count")
		_expect(is_equal_approx(float(projectile.get("speed")), LASER_LANCE.projectile_speed), "Laser Lance should use fast projectile speed")


func _verify_status_weapon_effects(player: Player) -> void:
	await _verify_projectile_burn_status(player)
	await _verify_melee_slow_status(player)


func _verify_projectile_burn_status(player: Player) -> void:
	var ember_data := EMBER_SPRAYER.duplicate() as WeaponData
	ember_data.status_chance = 1.0
	ember_data.status_damage_per_tick = 1
	ember_data.status_tick_interval = 0.1
	ember_data.crit_chance = 0.0
	var enemy := _spawn_test_enemy(player.global_position + Vector2(180, 0), 9)
	var projectile := PROJECTILE_SCENE.instantiate() as Projectile
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = enemy.global_position
	projectile.call("launch", Vector2.RIGHT, ember_data, player)
	projectile.call("_handle_collision", enemy)
	await get_tree().process_frame

	_expect(enemy.has_status_effect("burn"), "Ember Sprayer should apply burn status on hit")
	var health_after_hit := enemy.current_health
	enemy.call("_tick_status_effects", 0.12)
	await get_tree().process_frame
	_expect(enemy.current_health < health_after_hit, "Burn status should deal tick damage after interval")
	enemy.queue_free()


func _verify_melee_slow_status(player: Player) -> void:
	var weapon := player.weapon
	var frost_data := FROST_SICKLE.duplicate() as WeaponData
	frost_data.status_chance = 1.0
	frost_data.crit_chance = 0.0
	weapon.set_weapon_data(frost_data)
	player.recover_energy(player.max_energy)
	await get_tree().process_frame

	var enemy := _spawn_test_enemy(weapon.muzzle.global_position + Vector2(58, 0), 9)
	_clear_projectiles()
	var fired := weapon.try_fire(weapon.muzzle.global_position + Vector2(160, 0), player)
	await get_tree().process_frame

	_expect(fired, "Frost Sickle should fire")
	_expect(enemy.has_status_effect("slow"), "Frost Sickle should apply slow status in melee sweep")
	_expect(enemy.get_status_move_speed_multiplier() <= 0.56, "Slow status should reduce enemy movement multiplier")
	enemy.queue_free()


func _verify_projectile_blocking_melee(player: Player) -> void:
	_clear_enemy_projectiles()
	await get_tree().process_frame
	var weapon := player.weapon
	var guard_data := GUARD_CLEAVER.duplicate() as WeaponData
	guard_data.projectile_block_radius = 168.0
	guard_data.projectile_block_arc_degrees = 150.0
	guard_data.projectile_block_damage = 1
	guard_data.crit_chance = 0.0
	weapon.set_weapon_data(guard_data)
	weapon.global_rotation = 0.0
	player.recover_energy(player.max_energy)
	await get_tree().process_frame

	var blocked_projectile := ENEMY_PROJECTILE_SCENE.instantiate() as EnemyProjectile
	get_tree().current_scene.add_child(blocked_projectile)
	blocked_projectile.global_position = weapon.muzzle.global_position + Vector2(138, 0)
	blocked_projectile.call("launch", Vector2.LEFT, 480.0, 1, null)
	var outside_projectile := ENEMY_PROJECTILE_SCENE.instantiate() as EnemyProjectile
	get_tree().current_scene.add_child(outside_projectile)
	outside_projectile.global_position = weapon.muzzle.global_position + Vector2(-138, 0)
	outside_projectile.call("launch", Vector2.RIGHT, 480.0, 1, null)
	var enemy := _spawn_test_enemy(blocked_projectile.global_position + Vector2(8, 0), 8)

	var health_before := enemy.current_health
	var fired := weapon.try_fire(weapon.muzzle.global_position + Vector2(220, 0), player)
	await get_tree().process_frame

	_expect(fired, "Guard Cleaver should fire")
	_expect(int(weapon.get_meta(&"last_blocked_projectiles", 0)) == 1, "Guard Cleaver should block one enemy projectile in its arc")
	_expect(not is_instance_valid(blocked_projectile) or blocked_projectile.is_queued_for_deletion(), "Guard Cleaver should remove enemy projectile inside guard arc")
	_expect(not outside_projectile.is_queued_for_deletion(), "Guard Cleaver should not block enemy projectile behind the player")
	_expect(enemy.current_health < health_before, "Guard Cleaver block should apply counter damage near blocked projectile")
	enemy.queue_free()
	outside_projectile.queue_free()


func _verify_charge_weapon(player: Player) -> void:
	var weapon := player.weapon
	var charge_data := COIL_BOW.duplicate() as WeaponData
	charge_data.energy_cost = 0
	charge_data.charge_duration = 0.05
	charge_data.charge_damage_multiplier = 3.0
	charge_data.charge_projectile_speed_multiplier = 1.5
	weapon.set_weapon_data(charge_data)
	player.recover_energy(player.max_energy)
	await get_tree().process_frame

	_clear_projectiles()
	var ammo_before := weapon.get_current_ammo()
	var started := weapon.try_fire(weapon.muzzle.global_position + Vector2(220, 0), player)
	await get_tree().process_frame
	weapon.call("_process", 0.06)
	var charge_ratio := weapon.get_charge_ratio()
	var projectiles_while_charging := _projectile_count()
	var released := weapon.release_charge(weapon.muzzle.global_position + Vector2(220, 0), player)
	await get_tree().process_frame

	_expect(started, "Coil Bow should start charging while fire is held")
	_expect(charge_ratio >= 1.0, "Coil Bow should reach full charge after its charge duration")
	_expect(projectiles_while_charging == 0, "Coil Bow should not spawn projectiles before release")
	_expect(released, "Coil Bow should fire on charge release")
	_expect(not weapon.is_charging(), "Coil Bow should stop charging after release")
	_expect(weapon.get_current_ammo() == ammo_before - 1, "Coil Bow should consume ammo on release")
	_expect(_projectile_count() == charge_data.projectile_count, "Coil Bow should spawn projectile on release only")
	var projectile := get_tree().get_first_node_in_group("projectiles")
	_expect(projectile != null, "Coil Bow released shot should create a projectile")
	if projectile != null:
		_expect(int(projectile.get("damage")) >= roundi(float(charge_data.damage) * charge_data.charge_damage_multiplier), "Coil Bow full charge should multiply projectile damage")
		_expect(float(projectile.get("speed")) > charge_data.projectile_speed, "Coil Bow full charge should increase projectile speed")
	_expect(not weapon.release_charge(weapon.muzzle.global_position + Vector2(220, 0), player), "Coil Bow release without active charge should fail cleanly")
	_clear_projectiles()


func _verify_deployable_weapon(player: Player) -> void:
	var weapon := player.weapon
	var deployable_data := SNARE_BEACON.duplicate() as WeaponData
	deployable_data.energy_cost = 0
	deployable_data.deployable_duration = 0.4
	deployable_data.deployable_radius = 120.0
	deployable_data.deployable_tick_interval = 0.05
	deployable_data.status_chance = 1.0
	deployable_data.crit_chance = 0.0
	weapon.set_weapon_data(deployable_data)
	weapon.set("_cooldown", 0.0)
	player.recover_energy(player.max_energy)
	await get_tree().process_frame

	var target_position := weapon.muzzle.global_position + Vector2(150, 0)
	var enemy := _spawn_test_enemy(target_position + Vector2(18, 0), 9)
	_clear_projectiles()
	_clear_deployables()
	var ammo_before := weapon.get_current_ammo()
	var fired := weapon.try_fire(target_position, player)
	await get_tree().process_frame
	var deployable := get_tree().get_first_node_in_group("player_deployables")
	if deployable != null and deployable.has_method("get_deployable_behavior"):
		_expect(str(deployable.call("get_deployable_behavior")) == "field", "Snare Beacon should create a field deployable")
	if deployable != null:
		deployable.call("_tick_damage")
	await get_tree().process_frame

	_expect(fired, "Snare Beacon should fire")
	_expect(_projectile_count() == 0, "Snare Beacon should not spawn normal projectiles")
	_expect(_deployable_count() == 1, "Snare Beacon should spawn one deployable trap")
	_expect(weapon.get_current_ammo() == ammo_before - 1, "Snare Beacon should consume one ammo per deploy")
	_expect(enemy.current_health < enemy.max_health, "Snare Beacon deployable should damage enemies in radius")
	_expect(enemy.has_status_effect("slow"), "Snare Beacon deployable should apply slow status")
	enemy.queue_free()
	_clear_deployables()
	await get_tree().process_frame


func _verify_deployable_behavior_variants(player: Player) -> void:
	await _verify_sentry_deployable(player)
	await _verify_mine_deployable(player)


func _verify_sentry_deployable(player: Player) -> void:
	var weapon := player.weapon
	var sentry_data := SENTRY_SEED.duplicate() as WeaponData
	sentry_data.energy_cost = 0
	sentry_data.deployable_duration = 20.0
	sentry_data.deployable_radius = 180.0
	sentry_data.deployable_tick_interval = 10.0
	sentry_data.deployable_arming_time = 10.0
	weapon.set_weapon_data(sentry_data)
	player.recover_energy(player.max_energy)
	await get_tree().process_frame

	var target_position := weapon.muzzle.global_position + Vector2(150, 0)
	var near_enemy := _spawn_test_enemy(target_position + Vector2(18, 0), 9)
	var far_enemy := _spawn_test_enemy(target_position + Vector2(76, 0), 9)
	_clear_deployables()
	_expect(weapon.try_fire(target_position, player), "Sentry Seed should deploy a sentry")
	await get_tree().process_frame
	var deployable := get_tree().get_first_node_in_group("player_deployables")
	_expect(deployable != null, "Sentry Seed should create a deployable node")
	if deployable != null:
		_expect(str(deployable.call("get_deployable_behavior")) == "sentry", "Sentry Seed should use sentry behavior")
		var near_health_before := near_enemy.current_health
		var far_health_before := far_enemy.current_health
		var hits := int(deployable.call("_tick_damage"))
		_expect(hits == 1, "Sentry behavior should hit exactly one target per tick")
		_expect(near_enemy.current_health < near_health_before, "Sentry behavior should target the nearest enemy")
		_expect(far_enemy.current_health == far_health_before, "Sentry behavior should leave farther enemies untouched on the same tick")
		var expected_rotation: float = (near_enemy.global_position - deployable.global_position).angle()
		_expect(is_equal_approx(deployable.global_rotation, expected_rotation), "Sentry visual should face its selected target")
	near_enemy.queue_free()
	far_enemy.queue_free()
	_clear_deployables()
	await get_tree().process_frame


func _verify_mine_deployable(player: Player) -> void:
	var weapon := player.weapon
	var mine_data := EMBER_MINE.duplicate() as WeaponData
	mine_data.energy_cost = 0
	mine_data.deployable_duration = 20.0
	mine_data.deployable_radius = 140.0
	mine_data.deployable_tick_interval = 10.0
	mine_data.deployable_arming_time = 10.0
	mine_data.status_chance = 1.0
	weapon.set_weapon_data(mine_data)
	player.recover_energy(player.max_energy)
	await get_tree().process_frame

	var target_position := weapon.muzzle.global_position + Vector2(150, 0)
	var first_enemy := _spawn_test_enemy(target_position + Vector2(18, 0), 12)
	var second_enemy := _spawn_test_enemy(target_position + Vector2(58, 0), 12)
	_clear_deployables()
	_expect(weapon.try_fire(target_position, player), "Ember Mine should deploy a mine")
	await get_tree().process_frame
	var deployable := get_tree().get_first_node_in_group("player_deployables")
	_expect(deployable != null, "Ember Mine should create a deployable node")
	if deployable != null:
		_expect(str(deployable.call("get_deployable_behavior")) == "mine", "Ember Mine should use mine behavior")
		var first_health_before := first_enemy.current_health
		var second_health_before := second_enemy.current_health
		var hits := int(deployable.call("_tick_damage"))
		_expect(hits == 2, "Mine behavior should damage every target in its trigger radius")
		_expect(first_enemy.current_health < first_health_before and second_enemy.current_health < second_health_before, "Mine behavior should apply one area burst")
		_expect(bool(deployable.get_meta(&"triggered", false)), "Mine behavior should mark itself triggered after a successful burst")
		_expect(deployable.is_queued_for_deletion(), "Mine behavior should retire after its first successful burst")
	await get_tree().process_frame
	_expect(_deployable_count() == 0, "Triggered mine should leave no active deployable behind")
	first_enemy.queue_free()
	second_enemy.queue_free()


func _verify_homing_and_chain_projectiles(player: Player) -> void:
	await _verify_homing_projectile(player)
	await _verify_chain_projectile(player)


func _verify_homing_projectile(player: Player) -> void:
	var projectile := PROJECTILE_SCENE.instantiate() as Projectile
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = Vector2(5000.0, 5000.0)
	var enemy := _spawn_test_enemy(projectile.global_position + Vector2(80.0, 80.0), 12)
	projectile.launch(Vector2.RIGHT, COMPASS_NEEDLE, player)
	var direction_before := projectile.get_direction_for_test()
	projectile.call("_update_homing", 0.25)
	var direction_after := projectile.get_direction_for_test()
	_expect(is_equal_approx(direction_before.angle(), 0.0), "Compass Needle should launch along the requested direction")
	_expect(direction_after.y > 0.0, "Compass Needle homing should turn toward an offset target")
	_expect(direction_after.angle() <= deg_to_rad(COMPASS_NEEDLE.homing_turn_rate) * 0.25 + 0.001, "Homing turn should respect the configured angular rate")
	_expect(is_equal_approx(float(projectile.homing_radius), COMPASS_NEEDLE.homing_radius), "Compass Needle should transfer acquisition radius into its projectile")
	projectile.queue_free()
	enemy.queue_free()
	await get_tree().process_frame


func _verify_chain_projectile(player: Player) -> void:
	var projectile := PROJECTILE_SCENE.instantiate() as Projectile
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = Vector2(8000.0, 8000.0)
	projectile.launch(Vector2.RIGHT, RELAY_ARC, player)
	var primary := _spawn_test_enemy(projectile.global_position + Vector2(10.0, 0.0), 20)
	var first_chain := _spawn_test_enemy(projectile.global_position + Vector2(70.0, 0.0), 20)
	var second_chain := _spawn_test_enemy(projectile.global_position + Vector2(130.0, 0.0), 20)
	var out_of_range := _spawn_test_enemy(projectile.global_position + Vector2(360.0, 0.0), 20)
	var first_health_before := first_chain.current_health
	var second_health_before := second_chain.current_health
	var out_health_before := out_of_range.current_health
	projectile.call("_apply_chain_damage", primary, 10, player)
	_expect(projectile.get_last_chain_target_count() == RELAY_ARC.chain_count, "Relay Arc should chain through its configured extra target count")
	_expect(first_chain.current_health == first_health_before - 7, "Relay Arc first chain target should receive scaled damage")
	_expect(second_chain.current_health == second_health_before - 7, "Relay Arc second chain target should receive scaled damage")
	_expect(out_of_range.current_health == out_health_before, "Relay Arc should not bridge beyond its configured chain radius")
	var hit_instance_ids := projectile.get("_hit_instance_ids") as Dictionary
	_expect(hit_instance_ids.has(first_chain.get_instance_id()) and hit_instance_ids.has(second_chain.get_instance_id()), "Chain targets should join the projectile lifetime hit set to prevent later duplicate hits")
	projectile.queue_free()
	primary.queue_free()
	first_chain.queue_free()
	second_chain.queue_free()
	out_of_range.queue_free()
	await get_tree().process_frame


func _verify_critical_damage_roll() -> void:
	var projectile := PROJECTILE_SCENE.instantiate() as Projectile
	get_tree().current_scene.add_child(projectile)
	projectile.damage = 3
	projectile.crit_chance = 1.0
	projectile.crit_multiplier = 2.0
	var critical_roll: Dictionary = projectile.call("_roll_damage")
	_expect(bool(critical_roll.get("critical", false)), "Projectile should report guaranteed crit as critical")
	_expect(int(critical_roll.get("damage", 0)) == 6, "Projectile critical damage should use crit multiplier")
	projectile.crit_chance = 0.0
	var normal_roll: Dictionary = projectile.call("_roll_damage")
	_expect(not bool(normal_roll.get("critical", true)), "Projectile should report zero crit chance as normal hit")
	_expect(int(normal_roll.get("damage", 0)) == 3, "Projectile normal damage should remain unchanged")
	projectile.queue_free()


func _spawn_test_enemy(position: Vector2, health: int) -> Enemy:
	var enemy := ENEMY_SCENE.instantiate() as Enemy
	enemy.max_health = health
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = position
	return enemy


func _clear_projectiles() -> void:
	for projectile in get_tree().get_nodes_in_group("projectiles"):
		if is_instance_valid(projectile):
			projectile.queue_free()


func _clear_enemy_projectiles() -> void:
	for projectile in get_tree().get_nodes_in_group("enemy_projectiles"):
		if is_instance_valid(projectile):
			projectile.queue_free()


func _clear_deployables() -> void:
	for deployable in get_tree().get_nodes_in_group("player_deployables"):
		if is_instance_valid(deployable):
			deployable.queue_free()


func _clear_melee_sweep_flashes() -> void:
	for sweep_flash in get_tree().get_nodes_in_group("melee_sweep_flash"):
		if is_instance_valid(sweep_flash):
			sweep_flash.queue_free()


func _projectile_count() -> int:
	var count := 0
	for projectile in get_tree().get_nodes_in_group("projectiles"):
		if is_instance_valid(projectile) and not projectile.is_queued_for_deletion():
			count += 1
	return count


func _deployable_count() -> int:
	var count := 0
	for deployable in get_tree().get_nodes_in_group("player_deployables"):
		if is_instance_valid(deployable) and not deployable.is_queued_for_deletion():
			count += 1
	return count


func _melee_sweep_flash_count() -> int:
	var count := 0
	for sweep_flash in get_tree().get_nodes_in_group("melee_sweep_flash"):
		if is_instance_valid(sweep_flash) and not sweep_flash.is_queued_for_deletion():
			count += 1
	return count


func _get_active_melee_sweep_flash() -> Node:
	for sweep_flash in get_tree().get_nodes_in_group("melee_sweep_flash"):
		if is_instance_valid(sweep_flash) and not sweep_flash.is_queued_for_deletion():
			return sweep_flash
	return null


func _has_floating_text(main: Node, expected_text: String) -> bool:
	var snapshots: Array = main.call("get_floating_text_snapshots")
	for snapshot in snapshots:
		if snapshot is Dictionary and str(snapshot.get("text", "")).contains(expected_text):
			return true
	return false


func _resolve_weapon_icon_key(weapon_data: Resource) -> String:
	if weapon_data == null:
		return "weapon"
	var explicit_key := str(weapon_data.get("icon_key")).strip_edges()
	if not explicit_key.is_empty():
		return explicit_key
	return "weapon_%s" % str(weapon_data.get("id")).strip_edges()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("WeaponSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

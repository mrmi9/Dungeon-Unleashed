extends Node2D

const SETTINGS_PATH := "user://settings.cfg"
const SFX_BUS := "SFX"
const MUSIC_BUS := "Music"
const MAX_DUNGEON_SEED := 2147483647
const RUNTIME_ROOM_CHECK_ARG := "--runtime-room-check"
const RUNTIME_ROOM_CHECK_SEED := 424242
const RUNTIME_ROOM_CHECK_FAILURE_EXIT_CODE := 61
const RUNTIME_ROOM_CHECK_MIN_ENEMY_DISTANCE := 140.0
const AVAILABLE_RESOLUTIONS := [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
]
const FLOATING_TEXT_SCENE := preload("res://scenes/effects/FloatingText.tscn")
const REBINDABLE_INPUT_ACTIONS := [
	"move_up",
	"move_down",
	"move_left",
	"move_right",
	"reload",
	"skill",
	"interact",
	"pause",
]
const DEFAULT_INPUT_KEYCODES := {
	"move_up": KEY_W,
	"move_down": KEY_S,
	"move_left": KEY_A,
	"move_right": KEY_D,
	"reload": KEY_R,
	"skill": KEY_SPACE,
	"interact": KEY_E,
	"pause": KEY_ESCAPE,
}

enum RunState {
	MAIN_MENU,
	RUNNING,
	PAUSED,
	DEFEATED,
	VICTORY,
}

@onready var player: Player = $Player
@onready var camera: Camera2D = $Camera2D
@onready var hud: PrototypeHUD = $CanvasLayer/HUD
@onready var relic_system: Node = $RelicSystem

var run_state: RunState = RunState.MAIN_MENU
var _shake_strength := 0.0
var _shake_decay := 56.0
var _rng := RandomNumberGenerator.new()
var _pending_relic_choices: Array = []
var _pending_relic_pickup: Node
var _pending_relic_collector: Node
var _run_started_msec := 0
var _kills := 0
var _rooms_cleared := 0
var _gold_earned := 0
var _gold_spent := 0
var _shop_purchases := 0
var _chests_opened := 0
var _rewards_collected := 0
var _damage_taken := 0
var _critical_hits := 0
var _healing_received := 0
var _shield_absorbed := 0
var _boss_defeated := false
var _run_result_recorded := false
var _settings_master_volume := 1.0
var _settings_sfx_volume := 1.0
var _settings_music_volume := 0.8
var _settings_fullscreen := false
var _settings_resolution_index := 0
var _settings_dungeon_seed := 0
var _settings_input_keycodes: Dictionary = {}
var _history_stats: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("game_root")
	_settings_input_keycodes = _get_default_input_keycodes()
	_ensure_input_actions()
	_rng.randomize()
	_load_settings()
	_apply_configured_dungeon_seed(false)
	_apply_settings_to_engine()
	_apply_input_bindings()
	Events.projectile_hit.connect(_on_projectile_hit)
	Events.projectile_critical_hit.connect(_on_projectile_critical_hit)
	Events.enemy_died.connect(_on_enemy_died)
	Events.player_damaged.connect(_on_player_damaged)
	Events.player_healed.connect(_on_player_healed)
	Events.player_shield_gained.connect(_on_player_shield_gained)
	Events.player_shield_absorbed.connect(_on_player_shield_absorbed)
	Events.player_died.connect(_on_player_died)
	Events.room_state_changed.connect(_on_room_state_changed)
	Events.room_started.connect(_on_room_started)
	Events.room_cleared.connect(_on_room_cleared)
	Events.reward_spawned.connect(_on_reward_spawned)
	Events.reward_collected.connect(_on_reward_collected)
	Events.dungeon_generated.connect(_on_dungeon_generated)
	Events.dungeon_updated.connect(_on_dungeon_updated)
	Events.relic_choice_requested.connect(_on_relic_choice_requested)
	Events.relic_collected.connect(_on_relic_collected)
	Events.relics_changed.connect(_on_relics_changed)
	Events.boss_health_changed.connect(_on_boss_health_changed)
	Events.boss_phase_changed.connect(_on_boss_phase_changed)
	Events.boss_died.connect(_on_boss_died)
	Events.run_completed.connect(_on_run_completed)
	Events.shop_item_purchased.connect(_on_shop_item_purchased)
	Events.shop_purchase_failed.connect(_on_shop_purchase_failed)
	Events.chest_opened.connect(_on_chest_opened)
	player.health_changed.connect(_on_player_health_changed)
	player.shield_changed.connect(_on_player_shield_changed)
	player.energy_changed.connect(_on_player_energy_changed)
	player.character_changed.connect(_on_player_character_changed)
	player.skill_state_changed.connect(_on_player_skill_state_changed)
	player.gold_changed.connect(_on_player_gold_changed)
	player.weapon_changed.connect(_on_player_weapon_changed)
	player.ammo_changed.connect(_on_player_ammo_changed)

	hud.update_health(player.current_health, player.max_health)
	hud.update_shield(player.current_shield, player.max_shield)
	hud.update_energy(player.current_energy, player.max_energy)
	_update_character_hud()
	hud.update_gold(player.current_gold)
	hud.set_weapon_name(player.get_weapon_display_name())
	hud.update_relics(relic_system.get_relic_summaries())
	_sync_dungeon_hud()
	_refresh_seed_controls()
	_refresh_enemy_count()
	hud.set_flow_receiver(self)
	hud.update_settings_controls(_settings_master_volume, _settings_sfx_volume, _settings_music_volume, _settings_fullscreen, _settings_resolution_index)
	hud.refresh_input_bindings()
	_enter_main_menu()
	if _has_user_argument(RUNTIME_ROOM_CHECK_ARG):
		call_deferred("_run_runtime_room_spawn_check")


func _process(delta: float) -> void:
	if is_instance_valid(player):
		camera.global_position = player.global_position

	if _shake_strength > 0.0:
		camera.offset = Vector2(
			_rng.randf_range(-_shake_strength, _shake_strength),
			_rng.randf_range(-_shake_strength, _shake_strength)
		)
		_shake_strength = maxf(_shake_strength - _shake_decay * delta, 0.0)
	else:
		camera.offset = Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_map"):
		if hud != null and hud.has_method("toggle_debug_map_panel"):
			hud.call("toggle_debug_map_panel")
			get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("pause"):
		if run_state == RunState.RUNNING:
			pause_run()
			get_viewport().set_input_as_handled()
		elif run_state == RunState.PAUSED:
			resume_run()
			get_viewport().set_input_as_handled()


func start_new_run() -> void:
	if run_state == RunState.RUNNING:
		return
	if run_state == RunState.PAUSED:
		resume_run()
		return
	if run_state == RunState.DEFEATED or run_state == RunState.VICTORY:
		restart_run()
		return

	run_state = RunState.RUNNING
	_run_started_msec = Time.get_ticks_msec()
	_reset_run_stats()
	get_tree().paused = false
	hud.hide_flow_panels()


func start_new_run_from_menu(seed_text: String) -> void:
	if run_state == RunState.MAIN_MENU and not _apply_dungeon_seed_text(seed_text, false):
		return
	start_new_run()


func apply_dungeon_seed_text(seed_text: String) -> bool:
	return _apply_dungeon_seed_text(seed_text, true)


func randomize_dungeon_seed() -> void:
	if run_state != RunState.MAIN_MENU:
		hud.show_message("Seed From Main Menu")
		return

	_settings_dungeon_seed = 0
	_save_settings()
	_regenerate_dungeon_for_seed(0)
	hud.show_message("Random Seed")


func replay_current_seed() -> void:
	var seed := _get_active_dungeon_seed()
	if seed <= 0:
		hud.show_message("No Seed Available")
		return

	_settings_dungeon_seed = seed
	_save_settings()
	get_tree().paused = false
	get_tree().call_deferred("reload_current_scene")


func pause_run() -> void:
	if run_state != RunState.RUNNING:
		return

	run_state = RunState.PAUSED
	get_tree().paused = true
	hud.show_pause_menu(self)


func resume_run() -> void:
	if run_state != RunState.PAUSED:
		return

	run_state = RunState.RUNNING
	get_tree().paused = false
	hud.hide_flow_panels()


func restart_run() -> void:
	get_tree().paused = false
	get_tree().call_deferred("reload_current_scene")


func return_to_main_menu() -> void:
	get_tree().paused = false
	get_tree().call_deferred("reload_current_scene")


func open_settings_menu() -> void:
	hud.show_settings_menu(_settings_master_volume, _settings_sfx_volume, _settings_music_volume, _settings_fullscreen, _settings_resolution_index, self)


func close_settings_menu() -> void:
	if run_state == RunState.PAUSED:
		hud.show_pause_menu(self)
	elif run_state == RunState.MAIN_MENU:
		hud.show_main_menu(self)
	else:
		hud.hide_flow_panels()


func apply_settings(master_volume: float, sfx_volume = null, music_volume = null, fullscreen = null, resolution_index = null) -> void:
	var resolved_sfx_volume := _settings_sfx_volume
	var resolved_music_volume := _settings_music_volume
	var resolved_fullscreen := _settings_fullscreen
	var resolved_resolution_index := _settings_resolution_index

	if typeof(sfx_volume) == TYPE_BOOL:
		resolved_fullscreen = sfx_volume == true
	elif sfx_volume != null:
		resolved_sfx_volume = clampf(float(sfx_volume), 0.0, 1.0)

	if music_volume != null and typeof(music_volume) != TYPE_BOOL:
		resolved_music_volume = clampf(float(music_volume), 0.0, 1.0)

	if fullscreen != null:
		resolved_fullscreen = fullscreen == true

	if resolution_index != null:
		resolved_resolution_index = clampi(int(resolution_index), 0, AVAILABLE_RESOLUTIONS.size() - 1)

	_settings_master_volume = clampf(master_volume, 0.0, 1.0)
	_settings_sfx_volume = resolved_sfx_volume
	_settings_music_volume = resolved_music_volume
	_settings_fullscreen = resolved_fullscreen
	_settings_resolution_index = resolved_resolution_index
	_apply_settings_to_engine()
	_save_settings()
	hud.update_settings_controls(_settings_master_volume, _settings_sfx_volume, _settings_music_volume, _settings_fullscreen, _settings_resolution_index)
	hud.show_message("Settings Saved")


func get_run_state_name() -> String:
	match run_state:
		RunState.MAIN_MENU:
			return "Main Menu"
		RunState.RUNNING:
			return "Running"
		RunState.PAUSED:
			return "Paused"
		RunState.DEFEATED:
			return "Defeated"
		RunState.VICTORY:
			return "Victory"
	return "Unknown"


func get_run_summary() -> Dictionary:
	return _build_run_summary()


func get_settings_summary() -> Dictionary:
	return {
		"master_volume": _settings_master_volume,
		"sfx_volume": _settings_sfx_volume,
		"music_volume": _settings_music_volume,
		"fullscreen": _settings_fullscreen,
		"resolution_index": _settings_resolution_index,
		"resolution_width": AVAILABLE_RESOLUTIONS[_settings_resolution_index].x,
		"resolution_height": AVAILABLE_RESOLUTIONS[_settings_resolution_index].y,
		"resolution_label": _get_resolution_label(_settings_resolution_index),
		"input_bindings": get_input_bindings_summary(),
	}


func get_history_summary() -> Dictionary:
	return _history_stats.duplicate()


func get_input_bindings_summary() -> Dictionary:
	var bindings := {}
	for action_name in REBINDABLE_INPUT_ACTIONS:
		var keycode := int(_settings_input_keycodes.get(action_name, DEFAULT_INPUT_KEYCODES[action_name]))
		bindings[action_name] = {
			"keycode": keycode,
			"label": _get_keycode_label(keycode),
		}
	return bindings


func rebind_input_action(action_name: String, keycode: int) -> bool:
	if not DEFAULT_INPUT_KEYCODES.has(action_name) or keycode <= 0:
		return false

	var previous_keycode := int(_settings_input_keycodes.get(action_name, DEFAULT_INPUT_KEYCODES[action_name]))
	for other_action in REBINDABLE_INPUT_ACTIONS:
		if other_action == action_name:
			continue
		if int(_settings_input_keycodes.get(other_action, DEFAULT_INPUT_KEYCODES[other_action])) == keycode:
			_settings_input_keycodes[other_action] = previous_keycode
			break

	_settings_input_keycodes[action_name] = keycode
	_apply_input_bindings()
	_save_settings()
	if hud != null and hud.has_method("refresh_input_bindings"):
		hud.call("refresh_input_bindings")
	if hud != null:
		hud.show_message("Controls Saved")
	return true


func reset_input_bindings() -> void:
	_settings_input_keycodes = _get_default_input_keycodes()
	_apply_input_bindings()
	_save_settings()
	if hud != null and hud.has_method("refresh_input_bindings"):
		hud.call("refresh_input_bindings")
	if hud != null:
		hud.show_message("Controls Reset")


func select_next_character() -> bool:
	if run_state != RunState.MAIN_MENU:
		hud.show_message("Choose From Main Menu")
		return false
	var changed := player.select_next_character()
	if changed:
		_update_character_hud()
	return changed


func select_previous_character() -> bool:
	if run_state != RunState.MAIN_MENU:
		hud.show_message("Choose From Main Menu")
		return false
	var changed := player.select_previous_character()
	if changed:
		_update_character_hud()
	return changed


func get_character_selection_summary() -> Dictionary:
	if player == null or not player.has_method("get_character_summary"):
		return {}
	return player.get_character_summary()


func _on_projectile_hit(_projectile: Node, _target: Node, _damage: int) -> void:
	_add_shake(3.5)
	if _projectile != null and _projectile.has_method("was_last_hit_critical") and bool(_projectile.call("was_last_hit_critical")):
		return
	_spawn_floating_text(_get_projectile_feedback_position(_projectile, _target), "-%d" % maxi(_damage, 0), Color(1.0, 0.86, 0.34, 1.0), 20, 42.0)


func _on_projectile_critical_hit(_projectile: Node, _target: Node, _damage: int) -> void:
	if run_state == RunState.RUNNING:
		_critical_hits += 1
	_add_shake(6.5)
	_spawn_floating_text(_get_projectile_feedback_position(_projectile, _target), "CRIT %d" % maxi(_damage, 0), Color(1.0, 0.3, 0.12, 1.0), 26, 58.0)


func _on_enemy_died(enemy: Node) -> void:
	if run_state == RunState.RUNNING and enemy != null:
		_kills += 1
		_grant_gold(_get_enemy_gold_value(enemy))
	_add_shake(8.0)
	call_deferred("_refresh_enemy_count")


func _on_player_damaged(_amount: int, _current_hp: int) -> void:
	if run_state == RunState.RUNNING:
		_damage_taken += maxi(_amount, 0)
	if _amount <= 0:
		return
	_add_shake(12.0)
	_spawn_floating_text(_get_feedback_position(player, null) + Vector2(0, -16), "-%d" % maxi(_amount, 0), Color(1.0, 0.24, 0.24, 1.0), 22, 50.0)


func _on_player_healed(amount: int, _current_hp: int) -> void:
	if amount <= 0:
		return
	if run_state == RunState.RUNNING:
		_healing_received += amount
	_spawn_floating_text(_get_feedback_position(player, null) + Vector2(-18, -22), "+%d HP" % amount, Color(0.36, 1.0, 0.52, 1.0), 20, 46.0)


func _on_player_shield_gained(amount: int, _current_shield: int) -> void:
	if amount <= 0:
		return
	_spawn_floating_text(_get_feedback_position(player, null) + Vector2(18, -22), "+%d SH" % amount, Color(0.34, 0.72, 1.0, 1.0), 20, 46.0)


func _on_player_shield_absorbed(amount: int, _current_shield: int) -> void:
	if amount <= 0:
		return
	if run_state == RunState.RUNNING:
		_shield_absorbed += amount
	_add_shake(8.0)
	_spawn_floating_text(_get_feedback_position(player, null) + Vector2(18, -10), "-%d SH" % amount, Color(0.28, 0.58, 1.0, 1.0), 20, 46.0)


func _on_player_died() -> void:
	if run_state == RunState.DEFEATED:
		return

	run_state = RunState.DEFEATED
	_add_shake(20.0)
	hud.show_death()
	hud.show_run_result(false, _finalize_run_summary(false), self)
	get_tree().paused = true


func _on_player_health_changed(current_hp: int, max_hp: int) -> void:
	hud.update_health(current_hp, max_hp)


func _on_player_shield_changed(current_shield: int) -> void:
	hud.update_shield(current_shield, player.max_shield)


func _on_player_energy_changed(current_energy: int, max_energy: int) -> void:
	hud.update_energy(current_energy, max_energy)


func _on_player_character_changed(display_name: String, description: String, skill_name: String, skill_description: String, index: int, total: int) -> void:
	hud.update_character_selection(display_name, description, skill_name, skill_description, index, total)


func _on_player_skill_state_changed(skill_name: String, cooldown_remaining: float, cooldown_duration: float, active_remaining: float) -> void:
	hud.update_skill_status(skill_name, cooldown_remaining, cooldown_duration, active_remaining)


func _on_player_gold_changed(current_gold: int) -> void:
	hud.update_gold(current_gold)


func _on_player_weapon_changed(display_name: String) -> void:
	hud.set_weapon_name(display_name)


func _on_player_ammo_changed(current_ammo: int, magazine_size: int, is_reloading: bool) -> void:
	hud.update_ammo(current_ammo, magazine_size, is_reloading)


func _on_room_state_changed(room: Node, state_name: String) -> void:
	hud.update_room_state("%s %s" % [_get_room_label(room), state_name])


func _on_room_started(_room: Node) -> void:
	hud.show_message("Room Locked")
	call_deferred("_refresh_enemy_count")


func _on_room_cleared(_room: Node) -> void:
	if run_state == RunState.RUNNING:
		_rooms_cleared += 1
		_grant_gold(_get_room_clear_gold(_room))
	_add_shake(14.0)
	hud.show_message("Room Cleared")
	call_deferred("_refresh_enemy_count")


func _on_reward_spawned(_reward: Node) -> void:
	hud.show_message("Reward Spawned")


func _on_reward_collected(_reward: Node, _collector: Node) -> void:
	if run_state == RunState.RUNNING:
		_rewards_collected += 1
	hud.show_message("Reward Claimed")


func _on_dungeon_generated(_room_records: Array) -> void:
	_sync_dungeon_hud()


func _on_dungeon_updated(_room_records: Array, _current_room_id: String) -> void:
	_sync_dungeon_hud()


func _on_relic_choice_requested(relic_choices: Array, source_pickup: Node, collector: Node) -> void:
	_pending_relic_choices = relic_choices.duplicate()
	_pending_relic_pickup = source_pickup
	_pending_relic_collector = collector
	hud.show_relic_choices(relic_choices, self)


func _on_relic_collected(relic_data: Resource, stack_count: int) -> void:
	var display_name := str(relic_data.get("display_name"))
	if stack_count > 1:
		hud.show_message("%s x%d" % [display_name, stack_count])
	else:
		hud.show_message(display_name)


func _on_relics_changed(relic_summaries: Array) -> void:
	hud.update_relics(relic_summaries)


func _on_boss_health_changed(boss: Node, current_hp: int, max_hp: int) -> void:
	var display_name := "Boss"
	if boss != null:
		var value = boss.get("display_name")
		if value != null:
			display_name = str(value)
	hud.update_boss_health(display_name, current_hp, max_hp)


func _on_boss_phase_changed(_boss: Node, phase: int) -> void:
	if phase > 1:
		_add_shake(16.0)
		hud.show_message("Boss Phase %d" % phase)


func _on_boss_died(_boss: Node) -> void:
	_boss_defeated = true
	_add_shake(24.0)
	hud.hide_boss_health()
	hud.show_message("Boss Defeated")


func _on_run_completed() -> void:
	if run_state == RunState.DEFEATED or run_state == RunState.VICTORY:
		return

	run_state = RunState.VICTORY
	hud.show_completion()
	hud.show_run_result(true, _finalize_run_summary(true), self)
	get_tree().paused = true


func _on_shop_item_purchased(shop_item: Node, _buyer: Node, price: int, item_type: String) -> void:
	if run_state == RunState.RUNNING:
		_gold_spent += maxi(price, 0)
		_shop_purchases += 1
	var item_name := item_type
	if shop_item != null and shop_item.has_method("get_display_name"):
		item_name = str(shop_item.call("get_display_name"))
	hud.show_message("Bought %s -%d Gold" % [item_name, price])


func _on_shop_purchase_failed(_shop_item: Node, _buyer: Node, _price: int, reason: String) -> void:
	if reason == "not_enough_gold":
		hud.show_message("Not Enough Gold")
	else:
		hud.show_message("Cannot Buy")


func _on_chest_opened(_chest: Node, _opener: Node, chest_type: String) -> void:
	if run_state == RunState.RUNNING:
		_chests_opened += 1
	if chest_type == "boss":
		hud.show_message("Boss Reward Claimed")
	else:
		hud.show_message("Chest Opened")


func _on_hud_relic_choice_selected(index: int) -> void:
	choose_relic_reward(index)


func choose_relic_reward(index: int) -> bool:
	if index < 0 or index >= _pending_relic_choices.size():
		return false

	var relic_data := _pending_relic_choices[index] as Resource
	if relic_data == null:
		return false

	if not bool(relic_system.call("obtain_relic", relic_data)):
		return false

	var reward_source: Node = self
	if is_instance_valid(_pending_relic_pickup):
		reward_source = _pending_relic_pickup
		_pending_relic_pickup.queue_free()
	Events.reward_collected.emit(reward_source, _pending_relic_collector)

	_pending_relic_choices.clear()
	_pending_relic_pickup = null
	_pending_relic_collector = null
	hud.hide_relic_choices()
	return true


func _refresh_enemy_count() -> void:
	var count := 0
	for node in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		if node.has_method("is_dead") and node.call("is_dead"):
			continue
		count += 1

	hud.update_enemy_count(count)


func _add_shake(amount: float) -> void:
	_shake_strength = maxf(_shake_strength, amount)


func _spawn_floating_text(world_position: Vector2, text: String, color: Color, font_size: int = 20, rise_distance: float = 46.0) -> Node:
	var floating_text := FLOATING_TEXT_SCENE.instantiate() as Node2D
	if floating_text == null:
		return null

	add_child(floating_text)
	floating_text.global_position = world_position + Vector2(_rng.randf_range(-10.0, 10.0), _rng.randf_range(-8.0, 4.0))
	if floating_text.has_method("setup"):
		floating_text.call("setup", text, color, font_size, rise_distance, _rng.randf_range(-12.0, 12.0))
	return floating_text


func get_floating_text_count() -> int:
	var count := 0
	for node in get_tree().get_nodes_in_group("floating_text"):
		if is_instance_valid(node) and not node.is_queued_for_deletion():
			count += 1
	return count


func get_floating_text_snapshots() -> Array[Dictionary]:
	var snapshots: Array[Dictionary] = []
	for node in get_tree().get_nodes_in_group("floating_text"):
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		var text := ""
		if node.has_method("get_text"):
			text = str(node.call("get_text"))
		var position := Vector2.ZERO
		if node is Node2D:
			position = (node as Node2D).global_position
		snapshots.append({
			"text": text,
			"position": position,
		})
	return snapshots


func _get_projectile_feedback_position(projectile: Node, target: Node) -> Vector2:
	if projectile != null and is_instance_valid(projectile) and projectile.has_meta(&"last_hit_position"):
		var metadata_hit_position = projectile.get_meta(&"last_hit_position")
		if typeof(metadata_hit_position) == TYPE_VECTOR2:
			return metadata_hit_position
	if projectile != null and is_instance_valid(projectile) and projectile.has_method("get_last_hit_position"):
		var hit_position = projectile.call("get_last_hit_position")
		if typeof(hit_position) == TYPE_VECTOR2:
			return hit_position
	return _get_feedback_position(target, projectile)


func _get_feedback_position(primary: Node, fallback: Node) -> Vector2:
	if primary is Node2D and is_instance_valid(primary) and not primary.is_queued_for_deletion():
		return (primary as Node2D).global_position
	if fallback is Node2D and is_instance_valid(fallback) and not fallback.is_queued_for_deletion():
		return (fallback as Node2D).global_position
	if is_instance_valid(player):
		return player.global_position
	return Vector2.ZERO


func _sync_dungeon_hud() -> void:
	var controller := get_node_or_null("DungeonController")
	if controller == null or not controller.has_method("get_room_records"):
		return

	var records: Array = controller.call("get_room_records")
	var current_room_id := ""
	if controller.has_method("get_current_room_id"):
		current_room_id = str(controller.call("get_current_room_id"))
	hud.update_minimap(records, current_room_id)
	if controller.has_method("get_generation_seed") and hud.has_method("update_dungeon_debug_info"):
		var debug_map := ""
		if controller.has_method("get_debug_map_text"):
			debug_map = str(controller.call("get_debug_map_text"))
		hud.call("update_dungeon_debug_info", int(controller.call("get_generation_seed")), debug_map)
	_refresh_seed_controls()


func sync_dungeon_hud() -> void:
	_sync_dungeon_hud()


func _run_runtime_room_spawn_check() -> void:
	var controller := _get_dungeon_controller()
	if controller != null and controller.has_method("regenerate_with_seed"):
		controller.call("regenerate_with_seed", RUNTIME_ROOM_CHECK_SEED)

	start_new_run()
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().create_timer(0.2).timeout

	var rooms: Array = []
	if controller != null and controller.has_method("get_combat_rooms"):
		rooms = controller.call("get_combat_rooms")

	if rooms.is_empty():
		push_error("RuntimeRoomSpawnCheck failed: no combat rooms generated")
		get_tree().quit(RUNTIME_ROOM_CHECK_FAILURE_EXIT_CODE)
		return

	var first_room := rooms[0] as CombatRoom
	var enemy_count := _runtime_alive_enemy_count()
	var nearest_enemy_distance := _runtime_nearest_enemy_distance(player.global_position)
	var expected_wave_count := 0
	var wave_counts := PackedInt32Array()
	if first_room != null:
		wave_counts = first_room.wave_enemy_counts
	if wave_counts.size() > 0:
		expected_wave_count = int(wave_counts[0])

	if first_room == null or first_room.state != 2 or enemy_count <= 0 or expected_wave_count <= 0 or nearest_enemy_distance < RUNTIME_ROOM_CHECK_MIN_ENEMY_DISTANCE:
		push_error("RuntimeRoomSpawnCheck failed: first_room_state=%s enemies=%d expected_wave=%d nearest_enemy_distance=%.1f" % [
			str(first_room.state if first_room != null else "missing"),
			enemy_count,
			expected_wave_count,
			nearest_enemy_distance,
		])
		get_tree().quit(RUNTIME_ROOM_CHECK_FAILURE_EXIT_CODE)
		return

	print("RuntimeRoomSpawnCheck passed: first_room_state=%s enemies=%d expected_wave=%d nearest_enemy_distance=%.1f" % [
		str(first_room.state),
		enemy_count,
		expected_wave_count,
		nearest_enemy_distance,
	])
	get_tree().quit(0)


func _apply_dungeon_seed_text(seed_text: String, show_feedback: bool) -> bool:
	if run_state != RunState.MAIN_MENU:
		if show_feedback:
			hud.show_message("Seed From Main Menu")
		return false

	var parse_result := _parse_dungeon_seed_text(seed_text)
	if not bool(parse_result.get("valid", false)):
		if show_feedback:
			hud.show_message("Invalid Seed")
		return false

	_settings_dungeon_seed = int(parse_result.get("seed", 0))
	_save_settings()
	_regenerate_dungeon_for_seed(_settings_dungeon_seed)
	if show_feedback:
		if _settings_dungeon_seed > 0:
			hud.show_message("Seed Applied")
		else:
			hud.show_message("Random Seed")
	return true


func _parse_dungeon_seed_text(seed_text: String) -> Dictionary:
	var normalized := seed_text.strip_edges()
	if normalized.is_empty():
		return {
			"valid": true,
			"seed": 0,
		}
	if not normalized.is_valid_int():
		return {
			"valid": false,
			"seed": 0,
		}

	var parsed_seed := int(normalized)
	return {
		"valid": parsed_seed >= 0 and parsed_seed <= MAX_DUNGEON_SEED,
		"seed": clampi(parsed_seed, 0, MAX_DUNGEON_SEED),
	}


func _apply_configured_dungeon_seed(regenerate_random: bool) -> void:
	if _settings_dungeon_seed > 0 or regenerate_random:
		_regenerate_dungeon_for_seed(_settings_dungeon_seed)


func _regenerate_dungeon_for_seed(seed: int) -> void:
	var controller := _get_dungeon_controller()
	if controller == null:
		return

	if seed > 0 and controller.has_method("regenerate_with_seed"):
		controller.call("regenerate_with_seed", seed)
	elif controller.has_method("set_generation_seed") and controller.has_method("generate_dungeon"):
		controller.call("set_generation_seed", 0)
		controller.call("generate_dungeon")
	_sync_dungeon_hud()


func _get_dungeon_controller() -> Node:
	return get_node_or_null("DungeonController")


func _get_active_dungeon_seed() -> int:
	var controller := _get_dungeon_controller()
	if controller != null and controller.has_method("get_generation_seed"):
		return int(controller.call("get_generation_seed"))
	return 0


func _refresh_seed_controls() -> void:
	if hud != null and hud.has_method("update_seed_controls"):
		hud.call("update_seed_controls", _get_active_dungeon_seed(), _settings_dungeon_seed)


func _runtime_alive_enemy_count() -> int:
	var count := 0
	for node in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		if node.has_method("is_dead") and node.call("is_dead"):
			continue
		count += 1
	return count


func _runtime_nearest_enemy_distance(position: Vector2) -> float:
	var nearest := 1.0e20
	for node in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		if node.has_method("is_dead") and node.call("is_dead"):
			continue
		var enemy_node := node as Node2D
		if enemy_node == null:
			continue
		nearest = minf(nearest, enemy_node.global_position.distance_to(position))
	return nearest


func _has_user_argument(argument: String) -> bool:
	for candidate in OS.get_cmdline_user_args():
		if candidate == argument:
			return true
	return false


func _reset_run_stats() -> void:
	_kills = 0
	_rooms_cleared = 0
	_gold_earned = 0
	_gold_spent = 0
	_shop_purchases = 0
	_chests_opened = 0
	_rewards_collected = 0
	_damage_taken = 0
	_critical_hits = 0
	_healing_received = 0
	_shield_absorbed = 0
	_boss_defeated = false
	_run_result_recorded = false


func _ensure_input_actions() -> void:
	for action_name in REBINDABLE_INPUT_ACTIONS:
		if not InputMap.has_action(StringName(action_name)):
			InputMap.add_action(StringName(action_name))
	_bind_key(&"weapon_slot_1", KEY_1)
	_bind_key(&"weapon_slot_2", KEY_2)
	_bind_key(&"weapon_slot_3", KEY_3)
	_bind_key(&"debug_map", KEY_F3)
	_bind_mouse_button(&"shoot", MOUSE_BUTTON_LEFT)


func _apply_input_bindings() -> void:
	for action_name in REBINDABLE_INPUT_ACTIONS:
		var action := StringName(action_name)
		if not InputMap.has_action(action):
			InputMap.add_action(action)

		for event in InputMap.action_get_events(action):
			if event is InputEventKey:
				InputMap.action_erase_event(action, event)

		var keycode := int(_settings_input_keycodes.get(action_name, DEFAULT_INPUT_KEYCODES[action_name]))
		var new_event := InputEventKey.new()
		new_event.physical_keycode = keycode
		InputMap.action_add_event(action, new_event)


func _get_default_input_keycodes() -> Dictionary:
	return DEFAULT_INPUT_KEYCODES.duplicate()


func _get_keycode_label(keycode: int) -> String:
	if keycode == KEY_ESCAPE:
		return "Esc"
	if keycode <= 0:
		return "--"

	var label := OS.get_keycode_string(keycode)
	if label.is_empty():
		return str(keycode)
	return label


func _update_character_hud() -> void:
	if player == null or hud == null:
		return
	if player.has_method("get_character_summary"):
		var character_summary: Dictionary = player.call("get_character_summary")
		hud.update_character_selection(
			str(character_summary.get("display_name", "Adventurer")),
			str(character_summary.get("description", "")),
			str(character_summary.get("skill_name", "Skill")),
			str(character_summary.get("skill_description", "")),
			int(character_summary.get("index", 0)),
			int(character_summary.get("total", 1))
		)
	if player.has_method("get_skill_summary"):
		var skill_summary: Dictionary = player.call("get_skill_summary")
		hud.update_skill_status(
			str(skill_summary.get("skill_name", "Skill")),
			float(skill_summary.get("cooldown_remaining", 0.0)),
			float(skill_summary.get("cooldown_duration", 0.0)),
			float(skill_summary.get("active_remaining", 0.0))
		)


func _get_room_label(room: Node) -> String:
	var owner_room := room.get_parent()
	if owner_room != null and owner_room.name.begins_with("Room"):
		return owner_room.name
	return room.name


func _bind_key(action: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)

	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			var key_event := event as InputEventKey
			if key_event.keycode == keycode or key_event.physical_keycode == keycode:
				return

	var new_event := InputEventKey.new()
	new_event.physical_keycode = keycode
	InputMap.action_add_event(action, new_event)


func _bind_mouse_button(action: StringName, button_index: MouseButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)

	for event in InputMap.action_get_events(action):
		if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == button_index:
			return

	var new_event := InputEventMouseButton.new()
	new_event.button_index = button_index
	InputMap.action_add_event(action, new_event)


func _enter_main_menu() -> void:
	run_state = RunState.MAIN_MENU
	get_tree().paused = true
	hud.show_main_menu(self)


func _build_run_summary(result_name: String = "In Progress") -> Dictionary:
	var elapsed_seconds := 0
	if _run_started_msec > 0:
		elapsed_seconds = maxi(roundi(float(Time.get_ticks_msec() - _run_started_msec) / 1000.0), 0)

	var relic_count := 0
	var relic_stacks := 0
	var relic_names: Array[String] = []
	if relic_system != null and relic_system.has_method("get_relic_summaries"):
		var summaries: Array = relic_system.call("get_relic_summaries")
		relic_count = summaries.size()
		for summary in summaries:
			if summary is Dictionary:
				var name := str(summary.get("display_name", "Relic"))
				var stacks := int(summary.get("stacks", 1))
				relic_stacks += maxi(stacks, 1)
				if stacks > 1:
					relic_names.append("%s x%d" % [name, stacks])
				else:
					relic_names.append(name)

	var gold := 0
	var current_hp := 0
	var max_hp := 0
	var shield := 0
	var weapon_name := "Unarmed"
	var character_name := "Adventurer"
	var loadout_names: Array[String] = []
	if is_instance_valid(player):
		gold = player.current_gold
		current_hp = player.current_health
		max_hp = player.max_health
		shield = player.current_shield
		weapon_name = player.get_weapon_display_name()
		if player.has_method("get_character_display_name"):
			character_name = player.get_character_display_name()
		loadout_names = _get_player_loadout_names()

	return {
		"result": result_name,
		"kills": _kills,
		"rooms_cleared": _rooms_cleared,
		"gold": gold,
		"gold_earned": _gold_earned,
		"gold_spent": _gold_spent,
		"relic_count": relic_count,
		"relic_stacks": relic_stacks,
		"relic_names": relic_names,
		"character": character_name,
		"weapon": weapon_name,
		"loadout": loadout_names,
		"current_hp": current_hp,
		"max_hp": max_hp,
		"shield": shield,
		"shop_purchases": _shop_purchases,
		"chests_opened": _chests_opened,
		"rewards_collected": _rewards_collected,
		"damage_taken": _damage_taken,
		"critical_hits": _critical_hits,
		"healing_received": _healing_received,
		"shield_absorbed": _shield_absorbed,
		"boss_defeated": _boss_defeated,
		"dungeon_seed": _get_active_dungeon_seed(),
		"elapsed_seconds": elapsed_seconds,
		"history": _history_stats.duplicate(),
	}


func _finalize_run_summary(victory: bool) -> Dictionary:
	var summary := _build_run_summary("Victory" if victory else "Defeat")
	_record_run_result(summary, victory)
	summary["history"] = _history_stats.duplicate()
	return summary


func _record_run_result(summary: Dictionary, victory: bool) -> void:
	if _run_result_recorded:
		return

	_run_result_recorded = true
	_history_stats["runs"] = int(_history_stats.get("runs", 0)) + 1
	if victory:
		_history_stats["victories"] = int(_history_stats.get("victories", 0)) + 1
	else:
		_history_stats["defeats"] = int(_history_stats.get("defeats", 0)) + 1

	_history_stats["best_rooms"] = maxi(int(_history_stats.get("best_rooms", 0)), int(summary.get("rooms_cleared", 0)))
	_history_stats["best_kills"] = maxi(int(_history_stats.get("best_kills", 0)), int(summary.get("kills", 0)))
	_history_stats["best_gold"] = maxi(int(_history_stats.get("best_gold", 0)), int(summary.get("gold", 0)))
	if victory:
		var elapsed := int(summary.get("elapsed_seconds", 0))
		var best_time := int(_history_stats.get("best_time_seconds", 0))
		if best_time <= 0 or elapsed < best_time:
			_history_stats["best_time_seconds"] = elapsed

	_save_history()


func _get_player_loadout_names() -> Array[String]:
	var names: Array[String] = []
	if not is_instance_valid(player):
		return names

	for weapon_data in player.weapon_loadout:
		if weapon_data == null:
			continue
		names.append(str(weapon_data.display_name))
	return names


func _grant_gold(amount: int) -> void:
	if amount <= 0 or not is_instance_valid(player):
		return
	_gold_earned += amount
	player.add_gold(amount)


func _get_enemy_gold_value(enemy: Node) -> int:
	if enemy.is_in_group("bosses"):
		return 24
	if enemy.get("is_elite") == true:
		return 5
	return 3


func _get_room_clear_gold(room: Node) -> int:
	if room == null:
		return 0

	if room.get("auto_clear_on_enter") == true:
		return 0

	var type_name := str(room.get("room_type"))
	match type_name:
		"elite":
			return 18
		"boss":
			return 30
		"start":
			return 8
		"combat":
			return 12
	return 0


func _load_settings() -> void:
	_history_stats = _default_history_stats()
	var config := ConfigFile.new()
	var error := config.load(SETTINGS_PATH)
	if error != OK:
		_settings_master_volume = 1.0
		_settings_sfx_volume = 1.0
		_settings_music_volume = 0.8
		_settings_fullscreen = false
		_settings_resolution_index = 0
		_settings_dungeon_seed = 0
		_settings_input_keycodes = _get_default_input_keycodes()
		return

	_settings_master_volume = clampf(float(config.get_value("audio", "master_volume", 1.0)), 0.0, 1.0)
	_settings_sfx_volume = clampf(float(config.get_value("audio", "sfx_volume", 1.0)), 0.0, 1.0)
	_settings_music_volume = clampf(float(config.get_value("audio", "music_volume", 0.8)), 0.0, 1.0)
	_settings_fullscreen = config.get_value("display", "fullscreen", false) == true
	_settings_resolution_index = _find_resolution_index(
		int(config.get_value("display", "resolution_width", AVAILABLE_RESOLUTIONS[0].x)),
		int(config.get_value("display", "resolution_height", AVAILABLE_RESOLUTIONS[0].y))
	)
	_settings_dungeon_seed = clampi(int(config.get_value("gameplay", "dungeon_seed", 0)), 0, MAX_DUNGEON_SEED)
	_load_input_bindings_from_config(config)
	_load_history_from_config(config)


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("audio", "master_volume", _settings_master_volume)
	config.set_value("audio", "sfx_volume", _settings_sfx_volume)
	config.set_value("audio", "music_volume", _settings_music_volume)
	config.set_value("display", "fullscreen", _settings_fullscreen)
	config.set_value("display", "resolution_width", AVAILABLE_RESOLUTIONS[_settings_resolution_index].x)
	config.set_value("display", "resolution_height", AVAILABLE_RESOLUTIONS[_settings_resolution_index].y)
	config.set_value("gameplay", "dungeon_seed", _settings_dungeon_seed)
	_write_input_bindings_to_config(config)
	_write_history_to_config(config)
	var error := config.save(SETTINGS_PATH)
	if error != OK:
		push_warning("Failed to save settings to %s: %s" % [SETTINGS_PATH, error])


func _save_history() -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("audio", "master_volume", _settings_master_volume)
	config.set_value("audio", "sfx_volume", _settings_sfx_volume)
	config.set_value("audio", "music_volume", _settings_music_volume)
	config.set_value("display", "fullscreen", _settings_fullscreen)
	config.set_value("display", "resolution_width", AVAILABLE_RESOLUTIONS[_settings_resolution_index].x)
	config.set_value("display", "resolution_height", AVAILABLE_RESOLUTIONS[_settings_resolution_index].y)
	config.set_value("gameplay", "dungeon_seed", _settings_dungeon_seed)
	_write_input_bindings_to_config(config)
	_write_history_to_config(config)
	var error := config.save(SETTINGS_PATH)
	if error != OK:
		push_warning("Failed to save history to %s: %s" % [SETTINGS_PATH, error])


func _default_history_stats() -> Dictionary:
	return {
		"runs": 0,
		"victories": 0,
		"defeats": 0,
		"best_rooms": 0,
		"best_kills": 0,
		"best_gold": 0,
		"best_time_seconds": 0,
	}


func _load_history_from_config(config: ConfigFile) -> void:
	_history_stats = _default_history_stats()
	for key in _history_stats.keys():
		_history_stats[key] = maxi(int(config.get_value("history", key, _history_stats[key])), 0)


func _write_history_to_config(config: ConfigFile) -> void:
	for key in _default_history_stats().keys():
		config.set_value("history", key, int(_history_stats.get(key, 0)))


func _load_input_bindings_from_config(config: ConfigFile) -> void:
	var loaded_bindings := _get_default_input_keycodes()
	for action_name in REBINDABLE_INPUT_ACTIONS:
		var fallback := int(DEFAULT_INPUT_KEYCODES[action_name])
		var keycode := int(config.get_value("controls", action_name, fallback))
		if keycode <= 0:
			keycode = fallback
		loaded_bindings[action_name] = keycode

	_settings_input_keycodes = _dedupe_input_bindings(loaded_bindings)


func _write_input_bindings_to_config(config: ConfigFile) -> void:
	for action_name in REBINDABLE_INPUT_ACTIONS:
		config.set_value("controls", action_name, int(_settings_input_keycodes.get(action_name, DEFAULT_INPUT_KEYCODES[action_name])))


func _dedupe_input_bindings(bindings: Dictionary) -> Dictionary:
	var deduped := {}
	var used_keycodes := {}
	for action_name in REBINDABLE_INPUT_ACTIONS:
		var default_keycode := int(DEFAULT_INPUT_KEYCODES[action_name])
		var keycode := int(bindings.get(action_name, default_keycode))
		if keycode <= 0 or used_keycodes.has(keycode):
			keycode = default_keycode
		if used_keycodes.has(keycode):
			keycode = default_keycode
		deduped[action_name] = keycode
		used_keycodes[keycode] = action_name
	return deduped


func _apply_settings_to_engine() -> void:
	_apply_bus_volume("Master", _settings_master_volume)
	_apply_bus_volume(SFX_BUS, _settings_sfx_volume)
	_apply_bus_volume(MUSIC_BUS, _settings_music_volume)

	if DisplayServer.get_name() == "headless":
		return

	DisplayServer.window_set_size(AVAILABLE_RESOLUTIONS[_settings_resolution_index])
	if _settings_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _find_resolution_index(width: int, height: int) -> int:
	for index in range(AVAILABLE_RESOLUTIONS.size()):
		var resolution: Vector2i = AVAILABLE_RESOLUTIONS[index]
		if resolution.x == width and resolution.y == height:
			return index
	return 0


func _get_resolution_label(index: int) -> String:
	var clamped_index := clampi(index, 0, AVAILABLE_RESOLUTIONS.size() - 1)
	var resolution: Vector2i = AVAILABLE_RESOLUTIONS[clamped_index]
	return "%d x %d" % [resolution.x, resolution.y]


func _apply_bus_volume(bus_name: String, linear_volume: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0 and bus_name != "Master":
		bus_index = _ensure_audio_bus(bus_name)
	if bus_index < 0:
		return

	var clamped_volume := clampf(linear_volume, 0.0, 1.0)
	AudioServer.set_bus_mute(bus_index, clamped_volume <= 0.001)
	if clamped_volume > 0.001:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(clamped_volume))


func _ensure_audio_bus(bus_name: String) -> int:
	var index := AudioServer.get_bus_index(bus_name)
	if index >= 0:
		return index

	AudioServer.add_bus(AudioServer.get_bus_count())
	index = AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, "Master")
	return index

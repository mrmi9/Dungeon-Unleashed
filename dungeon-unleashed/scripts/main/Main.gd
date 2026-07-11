extends Node2D

const SETTINGS_PATH := "user://settings.cfg"
const SFX_BUS := "SFX"
const MUSIC_BUS := "Music"
const MAX_DUNGEON_SEED := 2147483647
const RUNTIME_ROOM_CHECK_ARG := "--runtime-room-check"
const RUNTIME_ROOM_CHECK_SEED := 424242
const RUNTIME_ROOM_CHECK_FAILURE_EXIT_CODE := 61
const RUNTIME_ROOM_CHECK_MIN_ENEMY_DISTANCE := 140.0
const CHARACTER_RESOURCE_DIR := "res://resources/characters"
const WEAPON_RESOURCE_DIR := "res://resources/weapons"
const RELIC_RESOURCE_DIR := "res://resources/relics"
const TALENT_RESOURCE_DIR := "res://resources/talents"
const BLESSING_RESOURCE_DIR := "res://resources/blessings"
const STATUE_RESOURCE_DIR := "res://resources/statues"
const MASTERY_LEVEL_2_ENERGY_BONUS := 1
const MASTERY_LEVEL_3_ARMOR_BONUS := 1
const AVAILABLE_RESOLUTIONS := [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
]
const DEFAULT_AIM_ASSIST_ENABLED := false
const DEFAULT_AIM_ASSIST_STRENGTH := 0.35
const DEFAULT_SCREEN_SHAKE_INTENSITY := 1.0
const DEFAULT_DAMAGE_FLASH_INTENSITY := 1.0
const DEFAULT_COMBAT_TEXT_INTENSITY := 1.0
const LOW_HEALTH_FEEDBACK := preload("res://scripts/core/LowHealthFeedback.gd")
const CONTROLLER_LAYOUT := preload("res://scripts/input/ControllerLayout.gd")
const FLOATING_TEXT_SCENE := preload("res://scenes/effects/FloatingText.tscn")
const PROJECTILE_BLOCK_SPARK_SCENE := preload("res://scenes/effects/ProjectileBlockSpark.tscn")
const TRAINING_DUMMY_SCENE := preload("res://scenes/training/TrainingDummy.tscn")
const TRAINING_PLAYER_POSITION := Vector2(-300.0, 0.0)
const TRAINING_DRILLS := [
	{
		"id": "basics",
		"display_name": "Basics",
		"instruction": "Compare close, mid, and far target damage.",
		"goal_type": "unique_targets",
		"goal_text": "Hit all targets",
		"goal_required": 3,
		"targets": [
			{
				"display_name": "Close Target",
				"target_type": "standard",
				"position": Vector2(60.0, -120.0),
			},
			{
				"display_name": "Mid Target",
				"target_type": "standard",
				"position": Vector2(260.0, 0.0),
			},
			{
				"display_name": "Far Target",
				"target_type": "standard",
				"position": Vector2(460.0, 120.0),
			},
		],
	},
	{
		"id": "movement",
		"display_name": "Movement",
		"instruction": "Track staggered targets while repositioning.",
		"goal_type": "target_type_hits",
		"goal_target_type": "mobile",
		"goal_text": "Tag both mobile targets",
		"goal_required": 2,
		"targets": [
			{
				"display_name": "Left Strafe",
				"target_type": "mobile",
				"position": Vector2(95.0, -175.0),
				"movement_axis": Vector2(1.0, 0.0),
				"movement_distance": 42.0,
				"movement_speed": 1.6,
			},
			{
				"display_name": "Center Anchor",
				"target_type": "armored",
				"position": Vector2(320.0, 0.0),
			},
			{
				"display_name": "Right Strafe",
				"target_type": "mobile",
				"position": Vector2(95.0, 175.0),
				"movement_axis": Vector2(1.0, 0.0),
				"movement_distance": 42.0,
				"movement_speed": 1.6,
			},
		],
	},
	{
		"id": "burst",
		"display_name": "Burst",
		"instruction": "Test cooldown windows against clustered targets.",
		"goal_type": "burst_chain",
		"goal_text": "Build a Burst x2 chain",
		"goal_required": 2,
		"targets": [
			{
				"display_name": "Burst Alpha",
				"target_type": "burst",
				"position": Vector2(230.0, -70.0),
				"burst_chain_window": 0.8,
			},
			{
				"display_name": "Burst Beta",
				"target_type": "armored",
				"position": Vector2(310.0, 0.0),
			},
			{
				"display_name": "Burst Gamma",
				"target_type": "burst",
				"position": Vector2(230.0, 70.0),
				"burst_chain_window": 0.8,
			},
		],
	},
	{
		"id": "aim_assist",
		"display_name": "Aim Assist",
		"instruction": "Toggle Aim Assist and compare offset target bend strength.",
		"goal_type": "target_type_hits",
		"goal_target_type": "assist",
		"goal_text": "Tag both assist targets",
		"goal_required": 2,
		"targets": [
			{
				"display_name": "Assist Left",
				"target_type": "assist",
				"position": Vector2(210.0, -96.0),
			},
			{
				"display_name": "Reference Line",
				"target_type": "standard",
				"position": Vector2(420.0, 0.0),
			},
			{
				"display_name": "Assist Right",
				"target_type": "assist",
				"position": Vector2(210.0, 96.0),
			},
		],
	},
]
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
	TRAINING,
	PAUSED,
	DEFEATED,
	VICTORY,
}

@onready var player: Player = $Player
@onready var camera: Camera2D = $Camera2D
@onready var hud: PrototypeHUD = $CanvasLayer/HUD
@onready var audio_feedback: AudioFeedback = $AudioFeedback
@onready var relic_system: Node = $RelicSystem
@onready var talent_system: Node = $TalentSystem
@onready var blessing_system: Node = $BlessingSystem
@onready var statue_system: Node = $StatueSystem

var run_state: RunState = RunState.MAIN_MENU
var _shake_strength := 0.0
var _shake_decay := 56.0
var _rng := RandomNumberGenerator.new()
var _pending_relic_choices: Array = []
var _pending_relic_pickup: Node
var _pending_relic_collector: Node
var _pending_talent_choices: Array = []
var _pending_talent_source: Node
var _pending_talent_collector: Node
var _pending_blessing_choices: Array = []
var _pending_blessing_source: Node
var _pending_blessing_collector: Node
var _pending_statue_choices: Array = []
var _pending_statue_source: Node
var _pending_statue_collector: Node
var _run_started_msec := 0
var _kills := 0
var _rooms_cleared := 0
var _gold_earned := 0
var _gold_spent := 0
var _shop_purchases := 0
var _chests_opened := 0
var _rewards_collected := 0
var _events_resolved := 0
var _event_records: Array[Dictionary] = []
var _damage_taken := 0
var _last_damage_record: Dictionary = {}
var _critical_hits := 0
var _healing_received := 0
var _shield_absorbed := 0
var _projectiles_blocked := 0
var _blessing_trigger_count := 0
var _blessing_trigger_counts: Dictionary = {}
var _statue_trigger_count := 0
var _statue_trigger_counts: Dictionary = {}
var _statue_attunement_count := 0
var _statue_attunement_counts: Dictionary = {}
var _was_low_health_active := false
var _boss_defeated := false
var _bosses_defeated := 0
var _defeated_boss_names: Array[String] = []
var _run_result_recorded := false
var _resume_run_state := RunState.RUNNING
var _training_dummies: Array[Node2D] = []
var _training_drill_index := 0
var _training_stats: Dictionary = {}
var _training_hit_target_ids := {}
var _training_hit_type_target_ids := {}
var _training_drill_best_ratings := {}
var _settings_master_volume := 1.0
var _settings_sfx_volume := 1.0
var _settings_music_volume := 0.8
var _settings_fullscreen := false
var _settings_resolution_index := 0
var _settings_aim_assist_enabled := DEFAULT_AIM_ASSIST_ENABLED
var _settings_aim_assist_strength := DEFAULT_AIM_ASSIST_STRENGTH
var _settings_low_health_feedback_intensity := LOW_HEALTH_FEEDBACK.DEFAULT_FEEDBACK_INTENSITY
var _settings_screen_shake_intensity := DEFAULT_SCREEN_SHAKE_INTENSITY
var _settings_damage_flash_intensity := DEFAULT_DAMAGE_FLASH_INTENSITY
var _settings_combat_text_intensity := DEFAULT_COMBAT_TEXT_INTENSITY
var _settings_controller_aim_deadzone := 0.22
var _settings_controller_input_switch_threshold := 0.45
var _settings_dungeon_seed := 0
var _settings_input_keycodes: Dictionary = {}
var _history_stats: Dictionary = {}
var _last_defeat_record: Dictionary = {}
var _defeat_source_counts: Dictionary = {}
var _meta_currency := 0
var _meta_total_currency_earned := 0
var _character_mastery_xp: Dictionary = {}
var _unlocked_character_ids: Dictionary = {}


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
	Events.player_shield_broken.connect(_on_player_shield_broken)
	Events.player_projectile_blocked.connect(_on_player_projectile_blocked)
	Events.player_energy_insufficient.connect(_on_player_energy_insufficient)
	Events.player_skill_unavailable.connect(_on_player_skill_unavailable)
	Events.player_passive_triggered.connect(_on_player_passive_triggered)
	Events.player_died.connect(_on_player_died)
	Events.room_state_changed.connect(_on_room_state_changed)
	Events.room_started.connect(_on_room_started)
	Events.room_cleared.connect(_on_room_cleared)
	Events.reward_spawned.connect(_on_reward_spawned)
	Events.reward_collected.connect(_on_reward_collected)
	Events.dungeon_generated.connect(_on_dungeon_generated)
	Events.dungeon_updated.connect(_on_dungeon_updated)
	Events.relic_choice_requested.connect(_on_relic_choice_requested)
	Events.blessing_choice_requested.connect(_on_blessing_choice_requested)
	Events.statue_choice_requested.connect(_on_statue_choice_requested)
	Events.relic_collected.connect(_on_relic_collected)
	Events.relics_changed.connect(_on_relics_changed)
	Events.talent_collected.connect(_on_talent_collected)
	Events.blessing_collected.connect(_on_blessing_collected)
	Events.blessing_triggered.connect(_on_blessing_triggered)
	Events.statue_collected.connect(_on_statue_collected)
	Events.statue_attuned.connect(_on_statue_attuned)
	Events.statue_triggered.connect(_on_statue_triggered)
	Events.boss_health_changed.connect(_on_boss_health_changed)
	Events.boss_phase_changed.connect(_on_boss_phase_changed)
	Events.boss_died.connect(_on_boss_died)
	Events.run_completed.connect(_on_run_completed)
	Events.shop_item_purchased.connect(_on_shop_item_purchased)
	Events.shop_purchase_failed.connect(_on_shop_purchase_failed)
	Events.chest_opened.connect(_on_chest_opened)
	Events.special_event_resolved.connect(_on_special_event_resolved)
	player.health_changed.connect(_on_player_health_changed)
	player.shield_changed.connect(_on_player_shield_changed)
	player.energy_changed.connect(_on_player_energy_changed)
	player.character_changed.connect(_on_player_character_changed)
	player.skill_state_changed.connect(_on_player_skill_state_changed)
	player.gold_changed.connect(_on_player_gold_changed)
	player.weapon_changed.connect(_on_player_weapon_changed)
	player.weapon_loadout_stats_changed.connect(_on_player_weapon_loadout_stats_changed)
	player.ammo_changed.connect(_on_player_ammo_changed)

	_apply_gameplay_settings_to_player()
	_apply_current_character_mastery_bonus(true)
	hud.update_health(player.current_health, player.max_health)
	_sync_low_health_warning_state(player.current_health, player.max_health)
	_refresh_armor_hud()
	hud.update_energy(player.current_energy, player.max_energy)
	_update_character_hud()
	hud.update_gold(player.current_gold)
	hud.set_weapon_name(player.get_weapon_display_name(), player.current_weapon_index + 1, player.weapon_loadout.size())
	hud.update_weapon_loadout(_get_player_loadout_summaries(), player.current_weapon_index + 1, player.weapon_loadout.size())
	hud.update_relics(relic_system.get_relic_summaries())
	_sync_dungeon_hud()
	_refresh_seed_controls()
	_refresh_enemy_count()
	hud.set_flow_receiver(self)
	hud.update_settings_controls(_settings_master_volume, _settings_sfx_volume, _settings_music_volume, _settings_fullscreen, _settings_resolution_index, _settings_aim_assist_enabled, _settings_aim_assist_strength, _settings_low_health_feedback_intensity, _settings_screen_shake_intensity, _settings_damage_flash_intensity, _settings_combat_text_intensity, _settings_controller_aim_deadzone, _settings_controller_input_switch_threshold)
	hud.refresh_input_bindings()
	_enter_main_menu()
	if _has_user_argument(RUNTIME_ROOM_CHECK_ARG):
		call_deferred("_run_runtime_room_spawn_check")


func _process(delta: float) -> void:
	if is_instance_valid(player):
		camera.global_position = player.global_position
		_refresh_armor_hud()
		_refresh_passive_status_hud()

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
		if run_state == RunState.RUNNING or run_state == RunState.TRAINING:
			pause_run()
			get_viewport().set_input_as_handled()
		elif run_state == RunState.PAUSED:
			resume_run()
			get_viewport().set_input_as_handled()


func start_new_run() -> void:
	if run_state == RunState.RUNNING:
		return
	if run_state == RunState.TRAINING:
		return
	if run_state == RunState.PAUSED:
		resume_run()
		return
	if run_state == RunState.DEFEATED or run_state == RunState.VICTORY:
		restart_run()
		return
	if run_state == RunState.MAIN_MENU and not _is_current_character_unlocked():
		hud.show_message("Unlock Character First")
		_update_character_hud()
		return

	run_state = RunState.RUNNING
	_run_started_msec = Time.get_ticks_msec()
	_clear_training_state()
	_apply_aim_assist_candidate_groups_for_state()
	_reset_run_stats()
	get_tree().paused = false
	hud.hide_flow_panels()


func start_training_room(target_drill_id: String = "") -> void:
	if run_state != RunState.MAIN_MENU:
		hud.show_message("Training From Main Menu")
		return
	if not _is_current_character_unlocked():
		hud.show_message("Unlock Character First")
		_update_character_hud()
		return

	run_state = RunState.TRAINING
	_run_started_msec = Time.get_ticks_msec()
	_apply_aim_assist_candidate_groups_for_state()
	_reset_run_stats()
	_training_drill_index = _get_training_drill_index_by_id(target_drill_id)
	_reset_training_stats()
	_restore_player_for_training()
	_position_player_for_training()
	get_tree().paused = false
	hud.hide_flow_panels()
	hud.update_room_state("Training Room")
	_spawn_training_dummies()
	_show_training_hud()
	hud.show_message("Training Room")


func reset_training_room() -> bool:
	if run_state != RunState.TRAINING:
		hud.show_message("Reset From Training")
		return false

	_reset_training_stats()
	_apply_aim_assist_candidate_groups_for_state()
	_restore_player_for_training()
	_position_player_for_training()
	_despawn_training_dummies()
	_spawn_training_dummies()
	_show_training_hud()
	hud.show_message("Training Reset")
	return true


func get_training_summary() -> Dictionary:
	return _training_stats.duplicate()


func cycle_training_drill() -> bool:
	if run_state != RunState.TRAINING:
		hud.show_message("Drill From Training")
		return false

	_training_drill_index = posmod(_training_drill_index + 1, TRAINING_DRILLS.size())
	_reset_training_stats()
	_position_player_for_training()
	_despawn_training_dummies()
	_spawn_training_dummies()
	_show_training_hud()
	hud.show_message("Training: %s" % _get_training_drill_name())
	return true


func _get_training_drill_index_by_id(drill_id: String) -> int:
	var target_id := drill_id.strip_edges().to_lower()
	if target_id.is_empty():
		return 0
	for index in range(TRAINING_DRILLS.size()):
		var drill_data: Dictionary = TRAINING_DRILLS[index]
		if str(drill_data.get("id", "")).strip_edges().to_lower() == target_id:
			return index
	return 0


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
	if run_state != RunState.RUNNING and run_state != RunState.TRAINING:
		return

	_resume_run_state = run_state
	run_state = RunState.PAUSED
	get_tree().paused = true
	hud.show_pause_menu(self)


func resume_run() -> void:
	if run_state != RunState.PAUSED:
		return

	run_state = _resume_run_state
	get_tree().paused = false
	hud.hide_flow_panels()


func restart_run() -> void:
	get_tree().paused = false
	get_tree().call_deferred("reload_current_scene")


func return_to_main_menu() -> void:
	get_tree().paused = false
	get_tree().call_deferred("reload_current_scene")


func open_settings_menu() -> void:
	hud.show_settings_menu(_settings_master_volume, _settings_sfx_volume, _settings_music_volume, _settings_fullscreen, _settings_resolution_index, self, _settings_aim_assist_enabled, _settings_aim_assist_strength, _settings_low_health_feedback_intensity, _settings_screen_shake_intensity, _settings_damage_flash_intensity, _settings_combat_text_intensity, _settings_controller_aim_deadzone, _settings_controller_input_switch_threshold)


func close_settings_menu() -> void:
	if run_state == RunState.PAUSED:
		hud.show_pause_menu(self)
	elif run_state == RunState.MAIN_MENU:
		hud.show_main_menu(self)
	else:
		hud.hide_flow_panels()


func open_hall_menu() -> void:
	if run_state != RunState.MAIN_MENU:
		hud.show_message("Hall From Main Menu")
		return
	hud.show_hall_menu(get_hall_summary(), self)


func refresh_hall_menu() -> void:
	if run_state != RunState.MAIN_MENU:
		return
	if hud == null or not hud.has_method("is_hall_visible"):
		return
	if not bool(hud.call("is_hall_visible")):
		return
	hud.show_hall_menu(get_hall_summary(), self)


func close_hall_menu() -> void:
	if run_state == RunState.MAIN_MENU:
		hud.show_main_menu(self)
	else:
		hud.hide_flow_panels()


func apply_settings(master_volume: float, sfx_volume = null, music_volume = null, fullscreen = null, resolution_index = null, aim_assist_enabled = null, aim_assist_strength = null, low_health_feedback_intensity = null, screen_shake_intensity = null, damage_flash_intensity = null, combat_text_intensity = null, controller_aim_deadzone = null, controller_input_switch_threshold = null) -> void:
	var resolved_sfx_volume := _settings_sfx_volume
	var resolved_music_volume := _settings_music_volume
	var resolved_fullscreen := _settings_fullscreen
	var resolved_resolution_index := _settings_resolution_index
	var resolved_aim_assist_enabled := _settings_aim_assist_enabled
	var resolved_aim_assist_strength := _settings_aim_assist_strength
	var resolved_low_health_feedback_intensity := _settings_low_health_feedback_intensity
	var resolved_screen_shake_intensity := _settings_screen_shake_intensity
	var resolved_damage_flash_intensity := _settings_damage_flash_intensity
	var resolved_combat_text_intensity := _settings_combat_text_intensity
	var resolved_controller_aim_deadzone := _settings_controller_aim_deadzone
	var resolved_controller_input_switch_threshold := _settings_controller_input_switch_threshold

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

	if aim_assist_enabled != null:
		resolved_aim_assist_enabled = aim_assist_enabled == true

	if aim_assist_strength != null:
		resolved_aim_assist_strength = clampf(float(aim_assist_strength), 0.0, 1.0)

	if low_health_feedback_intensity != null:
		resolved_low_health_feedback_intensity = LOW_HEALTH_FEEDBACK.clamp_feedback_intensity(float(low_health_feedback_intensity))

	if screen_shake_intensity != null:
		resolved_screen_shake_intensity = clampf(float(screen_shake_intensity), 0.0, 1.0)

	if damage_flash_intensity != null:
		resolved_damage_flash_intensity = clampf(float(damage_flash_intensity), 0.0, 1.0)

	if combat_text_intensity != null:
		resolved_combat_text_intensity = clampf(float(combat_text_intensity), 0.0, 1.0)

	if controller_aim_deadzone != null:
		resolved_controller_aim_deadzone = CONTROLLER_LAYOUT.clamp_aim_deadzone(float(controller_aim_deadzone))

	if controller_input_switch_threshold != null:
		resolved_controller_input_switch_threshold = CONTROLLER_LAYOUT.clamp_input_switch_threshold(float(controller_input_switch_threshold))

	_settings_master_volume = clampf(master_volume, 0.0, 1.0)
	_settings_sfx_volume = resolved_sfx_volume
	_settings_music_volume = resolved_music_volume
	_settings_fullscreen = resolved_fullscreen
	_settings_resolution_index = resolved_resolution_index
	_settings_aim_assist_enabled = resolved_aim_assist_enabled
	_settings_aim_assist_strength = resolved_aim_assist_strength
	_settings_low_health_feedback_intensity = resolved_low_health_feedback_intensity
	_settings_screen_shake_intensity = resolved_screen_shake_intensity
	_settings_damage_flash_intensity = resolved_damage_flash_intensity
	_settings_combat_text_intensity = resolved_combat_text_intensity
	_settings_controller_aim_deadzone = resolved_controller_aim_deadzone
	_settings_controller_input_switch_threshold = resolved_controller_input_switch_threshold
	_apply_controller_tuning_settings()
	_apply_settings_to_engine()
	_apply_gameplay_settings_to_player()
	_apply_feedback_settings()
	_save_settings()
	hud.update_settings_controls(_settings_master_volume, _settings_sfx_volume, _settings_music_volume, _settings_fullscreen, _settings_resolution_index, _settings_aim_assist_enabled, _settings_aim_assist_strength, _settings_low_health_feedback_intensity, _settings_screen_shake_intensity, _settings_damage_flash_intensity, _settings_combat_text_intensity, _settings_controller_aim_deadzone, _settings_controller_input_switch_threshold)
	hud.show_message("Settings Saved")


func apply_aim_assist_preset(band: String) -> bool:
	var preset := _get_aim_assist_preset_settings(band)
	if preset.is_empty():
		if hud != null:
			hud.show_message("Unknown Aim Preset")
		return false

	_settings_aim_assist_enabled = bool(preset.get("enabled", false))
	_settings_aim_assist_strength = clampf(float(preset.get("strength", DEFAULT_AIM_ASSIST_STRENGTH)), 0.0, 1.0)
	_apply_gameplay_settings_to_player()
	_save_settings()
	if hud != null:
		hud.update_settings_controls(_settings_master_volume, _settings_sfx_volume, _settings_music_volume, _settings_fullscreen, _settings_resolution_index, _settings_aim_assist_enabled, _settings_aim_assist_strength, _settings_low_health_feedback_intensity, _settings_screen_shake_intensity, _settings_damage_flash_intensity, _settings_combat_text_intensity, _settings_controller_aim_deadzone, _settings_controller_input_switch_threshold)
		hud.show_message("Aim Assist: %s" % _get_aim_assist_strength_band())
	if run_state == RunState.TRAINING:
		_update_training_hud()
	return true


func get_run_state_name() -> String:
	match run_state:
		RunState.MAIN_MENU:
			return "Main Menu"
		RunState.RUNNING:
			return "Running"
		RunState.TRAINING:
			return "Training"
		RunState.PAUSED:
			return "Paused"
		RunState.DEFEATED:
			return "Defeated"
		RunState.VICTORY:
			return "Victory"
	return "Unknown"


func get_run_summary() -> Dictionary:
	return _build_run_summary(_get_current_run_summary_result_name())


func _get_current_run_summary_result_name() -> String:
	match run_state:
		RunState.DEFEATED:
			return "Defeat"
		RunState.VICTORY:
			return "Victory"
	return "In Progress"


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
		"aim_assist_enabled": _settings_aim_assist_enabled,
		"aim_assist_strength": _settings_aim_assist_strength,
		"aim_assist_strength_band": _get_aim_assist_strength_band(),
		"low_health_feedback_intensity": _settings_low_health_feedback_intensity,
		"screen_shake_intensity": _settings_screen_shake_intensity,
		"damage_flash_intensity": _settings_damage_flash_intensity,
		"combat_text_intensity": _settings_combat_text_intensity,
		"controller_aim_deadzone": _settings_controller_aim_deadzone,
		"controller_input_switch_threshold": _settings_controller_input_switch_threshold,
		"input_bindings": get_input_bindings_summary(),
		"controller_layout": get_controller_layout_summary(),
	}


func get_history_summary() -> Dictionary:
	return _history_stats.duplicate()


func get_last_defeat_summary() -> Dictionary:
	return _last_defeat_record.duplicate()


func get_defeat_source_summary() -> Array:
	return _get_defeat_source_records()


func get_defeat_source_type_summary() -> Dictionary:
	return _get_defeat_source_type_counts()


func reset_run_records_for_test() -> void:
	_history_stats = _default_history_stats()
	_last_defeat_record = _default_last_defeat_record()
	_defeat_source_counts.clear()
	_save_history()


func get_hall_summary() -> Dictionary:
	return _build_hall_summary()


func get_meta_progression_summary() -> Dictionary:
	return _build_meta_progression_summary()


func get_input_bindings_summary() -> Dictionary:
	var bindings := {}
	for action_name in REBINDABLE_INPUT_ACTIONS:
		var keycode := int(_settings_input_keycodes.get(action_name, DEFAULT_INPUT_KEYCODES[action_name]))
		bindings[action_name] = {
			"keycode": keycode,
			"label": _get_keycode_label(keycode),
		}
	return bindings


func get_controller_layout_summary() -> Dictionary:
	return CONTROLLER_LAYOUT.get_summary()


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
		_apply_current_character_mastery_bonus(true)
		_update_character_hud()
		_show_locked_character_message()
	return changed


func select_previous_character() -> bool:
	if run_state != RunState.MAIN_MENU:
		hud.show_message("Choose From Main Menu")
		return false
	var changed := player.select_previous_character()
	if changed:
		_apply_current_character_mastery_bonus(true)
		_update_character_hud()
		_show_locked_character_message()
	return changed


func get_character_selection_summary() -> Dictionary:
	if player == null or not player.has_method("get_character_summary"):
		return {}
	var summary: Dictionary = player.get_character_summary()
	var character := _get_current_character_data()
	if character != null:
		var character_id := str(character.get("id"))
		var mastery_level := _get_character_mastery_level_for_data(character)
		summary["unlocked"] = _is_character_unlocked(character_id, character)
		summary["unlock_cost"] = _get_character_unlock_cost(character)
		summary["meta_currency"] = _meta_currency
		summary["mastery_xp"] = int(_character_mastery_xp.get(character_id, 0))
		summary["mastery_level"] = mastery_level
		summary["mastery_bonus"] = _get_mastery_bonus_for_level(mastery_level)
	return summary


func unlock_selected_character() -> bool:
	if run_state != RunState.MAIN_MENU:
		hud.show_message("Unlock From Main Menu")
		return false

	var character := _get_current_character_data()
	if character == null:
		return false

	var character_id := str(character.get("id"))
	if _is_character_unlocked(character_id, character):
		hud.show_message("Already Unlocked")
		_update_character_hud()
		return true

	var cost := _get_character_unlock_cost(character)
	if _meta_currency < cost:
		hud.show_message("Need %d Data Shards" % cost)
		_update_character_hud()
		return false

	var unlocked := unlock_character(character_id)
	if unlocked:
		hud.show_message("%s Unlocked" % str(character.get("display_name")))
	_update_character_hud()
	return unlocked


func _on_projectile_hit(_projectile: Node, _target: Node, _damage: int) -> void:
	_add_shake(3.5)
	if run_state == RunState.TRAINING:
		_record_training_hit(_target, _damage)
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
		if player != null and player.has_method("get_last_damage_summary"):
			var damage_summary: Dictionary = player.call("get_last_damage_summary")
			if int(damage_summary.get("amount", 0)) > 0:
				_last_damage_record = damage_summary.duplicate()
	if _amount <= 0:
		return
	_add_shake(12.0)
	if hud.has_method("show_damage_flash"):
		hud.call("show_damage_flash", _amount)
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


func _on_player_shield_broken(absorbed_amount: int, _current_shield: int) -> void:
	if absorbed_amount <= 0:
		return
	_add_shake(11.0)
	if hud.has_method("show_armor_break_pulse"):
		hud.call("show_armor_break_pulse")
	hud.show_message("Armor Broken")
	_spawn_floating_text(_get_feedback_position(player, null) + Vector2(0, -34), "ARMOR BREAK", Color(1.0, 0.62, 0.32, 1.0), 20, 52.0)


func _on_player_projectile_blocked(source_player: Node, _weapon_data: Resource, blocked_count: int, block_position: Vector2) -> void:
	if source_player != player or blocked_count <= 0:
		return

	if run_state == RunState.RUNNING:
		_projectiles_blocked += blocked_count
	_add_shake(4.0 + minf(float(blocked_count), 3.0) * 1.5)
	var display_text := "BLOCK"
	if blocked_count > 1:
		display_text = "BLOCK x%d" % blocked_count
	_spawn_floating_text(block_position, display_text, Color(0.58, 0.95, 1.0, 1.0), 18, 40.0)
	_spawn_projectile_block_spark(block_position, blocked_count)
	if hud.has_method("show_weapon_block_pulse"):
		hud.call("show_weapon_block_pulse")


func _on_player_energy_insufficient(current_energy: int, required_energy: int, _source_data: Resource) -> void:
	var message := "Not Enough Energy"
	if required_energy > 0:
		message = "Not Enough Energy %d/%d" % [maxi(current_energy, 0), required_energy]
	hud.show_message(message)
	if hud.has_method("show_energy_warning"):
		hud.call("show_energy_warning", required_energy)
	_spawn_floating_text(
		_get_feedback_position(player, null) + Vector2(0, -34),
		"NO ENERGY",
		Color(0.38, 0.82, 1.0, 1.0),
		18,
		40.0
	)


func _on_player_skill_unavailable(skill_name: String, reason: String, cooldown_remaining: float) -> void:
	if hud.has_method("show_skill_warning"):
		hud.call("show_skill_warning")
	match reason:
		"cooldown":
			hud.show_message("%s Cooldown %.1fs" % [skill_name, maxf(cooldown_remaining, 0.0)])
			_spawn_floating_text(
				_get_feedback_position(player, null) + Vector2(-18, -38),
				"SKILL CD",
				Color(1.0, 0.76, 0.28, 1.0),
				18,
				40.0
			)
		_:
			hud.show_message("%s Unavailable" % skill_name)


func _on_player_passive_triggered(source_player: Node, passive_id: String, effect_name: String, duration: float) -> void:
	if source_player != player:
		return

	var display_name := effect_name.strip_edges()
	if display_name.is_empty():
		display_name = "Passive"
	var message := display_name
	if duration > 0.0:
		message = "%s %.1fs" % [display_name, duration]
	hud.show_message(message)
	if hud.has_method("show_passive_trigger_pulse"):
		hud.call("show_passive_trigger_pulse")
	_spawn_floating_text(
		_get_feedback_position(player, null) + Vector2(0, -64),
		display_name.to_upper(),
		_get_passive_feedback_color(passive_id),
		18,
		44.0
	)


func _on_player_died() -> void:
	if run_state == RunState.TRAINING:
		hud.show_message("Training Ended")
		get_tree().paused = false
		get_tree().call_deferred("reload_current_scene")
		return
	if run_state == RunState.DEFEATED:
		return

	run_state = RunState.DEFEATED
	_add_shake(20.0)
	hud.show_death()
	hud.show_run_result(false, _finalize_run_summary(false), self)
	get_tree().paused = true


func _on_player_health_changed(current_hp: int, max_hp: int) -> void:
	hud.update_health(current_hp, max_hp)
	_sync_low_health_warning_state(current_hp, max_hp)


func _sync_low_health_warning_state(current_hp: int, max_hp: int) -> void:
	if hud == null or not hud.has_method("is_low_health_active"):
		return

	var is_low_health := bool(hud.call("is_low_health_active"))
	if is_low_health and not _was_low_health_active:
		Events.player_low_health_warning.emit(current_hp, max_hp)
	elif is_low_health and _was_low_health_active:
		Events.player_low_health_updated.emit(current_hp, max_hp)
	elif not is_low_health and _was_low_health_active and current_hp > 0:
		Events.player_low_health_recovered.emit(current_hp, max_hp)
	_was_low_health_active = is_low_health


func _refresh_armor_hud() -> void:
	if hud == null or not is_instance_valid(player):
		return

	hud.update_shield(player.current_shield, player.max_shield, player.get_shield_recharge_summary())


func _refresh_passive_status_hud() -> void:
	if hud == null or not is_instance_valid(player):
		return
	if not hud.has_method("update_character_passive_status"):
		return
	if not player.has_method("get_character_passive_summary"):
		return

	hud.call("update_character_passive_status", player.call("get_character_passive_summary"))


func _on_player_shield_changed(_current_shield: int) -> void:
	_refresh_armor_hud()


func _on_player_energy_changed(current_energy: int, max_energy: int) -> void:
	hud.update_energy(current_energy, max_energy)


func _on_player_character_changed(display_name: String, description: String, skill_name: String, skill_description: String, index: int, total: int) -> void:
	hud.update_character_selection(display_name, description, skill_name, skill_description, index, total)
	_update_character_unlock_hud()


func _on_player_skill_state_changed(skill_name: String, cooldown_remaining: float, cooldown_duration: float, active_remaining: float) -> void:
	hud.update_skill_status(skill_name, cooldown_remaining, cooldown_duration, active_remaining)


func _on_player_gold_changed(current_gold: int) -> void:
	hud.update_gold(current_gold)


func _on_player_weapon_changed(display_name: String, slot_index: int, slot_total: int) -> void:
	hud.set_weapon_name(display_name, slot_index, slot_total)
	hud.update_weapon_loadout(_get_player_loadout_summaries(), slot_index, slot_total)


func _on_player_weapon_loadout_stats_changed() -> void:
	hud.update_weapon_loadout(_get_player_loadout_summaries(), player.current_weapon_index + 1, player.weapon_loadout.size())


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


func _on_blessing_choice_requested(blessing_choices: Array, source_node: Node, collector: Node) -> void:
	_pending_blessing_choices = blessing_choices.duplicate()
	_pending_blessing_source = source_node
	_pending_blessing_collector = collector
	hud.show_blessing_choices(blessing_choices, self)


func _on_statue_choice_requested(statue_choices: Array, source_node: Node, collector: Node) -> void:
	_pending_statue_choices = statue_choices.duplicate()
	_pending_statue_source = source_node
	_pending_statue_collector = collector
	hud.show_statue_choices(statue_choices, self)


func _on_relic_collected(relic_data: Resource, stack_count: int) -> void:
	var display_name := str(relic_data.get("display_name"))
	if stack_count > 1:
		hud.show_message("%s x%d" % [display_name, stack_count])
	else:
		hud.show_message(display_name)


func _on_relics_changed(relic_summaries: Array) -> void:
	hud.update_relics(relic_summaries)


func _on_boss_health_changed(boss: Node, current_hp: int, max_hp: int) -> void:
	hud.update_boss_health(_get_boss_hud_display_name(boss), current_hp, max_hp)


func _get_boss_hud_display_name(boss: Node) -> String:
	var display_name := "Boss"
	if boss != null:
		var value = boss.get("display_name")
		if value != null:
			display_name = str(value)
		var phase := int(boss.call("get_phase")) if boss.has_method("get_phase") else 1
		if phase > 1 and boss.has_method("get_phase_two_attack_summary"):
			var phase_two_summary: Dictionary = boss.call("get_phase_two_attack_summary")
			var phase_two_name := str(phase_two_summary.get("display_name", "")).strip_edges()
			if not phase_two_name.is_empty():
				display_name = "%s | %s" % [display_name, phase_two_name]
		elif boss.has_method("get_signature_attack_summary"):
			var signature_summary: Dictionary = boss.call("get_signature_attack_summary")
			var signature_name := str(signature_summary.get("display_name", "")).strip_edges()
			if not signature_name.is_empty():
				display_name = "%s | %s" % [display_name, signature_name]
	return display_name


func _on_boss_phase_changed(boss: Node, phase: int) -> void:
	if phase > 1:
		_add_shake(16.0)
		var phase_name := ""
		if boss != null and boss.has_method("get_phase_two_attack_summary"):
			var phase_two_summary: Dictionary = boss.call("get_phase_two_attack_summary")
			phase_name = str(phase_two_summary.get("display_name", "")).strip_edges()
		var phase_message := "Boss Phase %d" % phase
		if not phase_name.is_empty():
			phase_message = "%s | %s" % [phase_message, phase_name]
		hud.show_message(phase_message)
		if boss != null:
			var current_hp := int(boss.get("current_health"))
			var max_hp := int(boss.get("max_health"))
			hud.update_boss_health(_get_boss_hud_display_name(boss), current_hp, max_hp)


func _on_boss_died(_boss: Node) -> void:
	_boss_defeated = true
	if run_state == RunState.RUNNING:
		_bosses_defeated += 1
	var boss_name := _resolve_defeated_boss_name(_boss)
	if not _defeated_boss_names.has(boss_name):
		_defeated_boss_names.append(boss_name)
	_add_shake(24.0)
	hud.hide_boss_health()
	hud.show_message("Boss Defeated")


func _on_run_completed() -> void:
	if run_state == RunState.DEFEATED or run_state == RunState.VICTORY:
		return
	if run_state == RunState.TRAINING:
		hud.show_message("Training Complete")
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
		var completes_run := false
		if _chest != null:
			completes_run = _chest.get("complete_run_on_open") == true
		if run_state == RunState.RUNNING and not completes_run:
			call_deferred("_request_boss_talent_choice", _chest, _opener)
	else:
		hud.show_message("Chest Opened")


func _on_special_event_resolved(event_node: Node, _player: Node, event_id: String, outcome_id: String) -> void:
	var event_record := _build_event_record(event_node, event_id, outcome_id)
	if run_state == RunState.RUNNING:
		_events_resolved += 1
		_event_records.append(event_record)
	var display_name := str(event_record.get("display_name", "Event")).strip_edges()
	if display_name.is_empty():
		display_name = "Event"
	hud.show_message("%s Resolved" % display_name)


func _build_event_record(event_node: Node, event_id: String, outcome_id: String) -> Dictionary:
	var event_summary: Dictionary = {}
	if event_node != null and event_node.has_method("get_event_summary"):
		event_summary = event_node.call("get_event_summary")

	var display_name := str(event_summary.get("display_name", "")).strip_edges()
	if display_name.is_empty() and event_node != null:
		var event_display_name = event_node.get("display_name")
		if event_display_name != null:
			display_name = str(event_display_name).strip_edges()
	if display_name.is_empty():
		display_name = _format_event_token(event_id, "Event")

	var reward_mode := str(event_summary.get("reward_mode", "")).strip_edges()
	return {
		"event_id": event_id,
		"outcome_id": outcome_id,
		"display_name": display_name,
		"event_variant": str(event_summary.get("event_variant", "")).strip_edges(),
		"reward_mode": reward_mode,
		"outcome_label": _format_event_outcome_label(outcome_id, reward_mode),
		"health_cost": maxi(int(event_summary.get("health_cost", 0)), 0),
		"gold_min": int(event_summary.get("gold_min", 0)),
		"gold_max": int(event_summary.get("gold_max", 0)),
		"biome_id": str(event_summary.get("biome_id", "")).strip_edges(),
		"biome_name": str(event_summary.get("biome_name", "")).strip_edges(),
	}


func _format_event_outcome_label(outcome_id: String, reward_mode: String) -> String:
	match reward_mode:
		"blessing_choice":
			return "Blessing Choice"
		"relic_choice":
			return "Relic Choice"
		"statue_choice":
			return "Statue Choice"
		"statue_attunement":
			return "Statue Attune"
		"shop_discount":
			return "Shop Discount"
		"cursed_weapon":
			return "Cursed Weapon"
		"temporary_rule":
			return "Temporary Rule"
	return _format_event_token(outcome_id, "Event Result")


func _format_event_token(value: String, fallback: String) -> String:
	var clean_value := value.strip_edges()
	if clean_value.is_empty():
		return fallback
	return clean_value.replace("_", " ").capitalize()


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


func choose_talent_reward(index: int) -> bool:
	if index < 0 or index >= _pending_talent_choices.size():
		return false

	var talent_data := _pending_talent_choices[index] as Resource
	if talent_data == null:
		return false

	if talent_system == null or not talent_system.has_method("obtain_talent"):
		return false
	if not bool(talent_system.call("obtain_talent", talent_data)):
		return false

	_pending_talent_choices.clear()
	_pending_talent_source = null
	_pending_talent_collector = null
	hud.hide_relic_choices()
	return true


func choose_blessing_reward(index: int) -> bool:
	if index < 0 or index >= _pending_blessing_choices.size():
		return false

	var blessing_data := _pending_blessing_choices[index] as Resource
	if blessing_data == null:
		return false

	if blessing_system == null or not blessing_system.has_method("obtain_blessing"):
		return false
	if not bool(blessing_system.call("obtain_blessing", blessing_data)):
		return false

	var reward_source: Node = self
	if is_instance_valid(_pending_blessing_source):
		reward_source = _pending_blessing_source
		_pending_blessing_source.queue_free()
	Events.reward_collected.emit(reward_source, _pending_blessing_collector)

	_pending_blessing_choices.clear()
	_pending_blessing_source = null
	_pending_blessing_collector = null
	hud.hide_relic_choices()
	return true


func choose_statue_reward(index: int) -> bool:
	if index < 0 or index >= _pending_statue_choices.size():
		return false

	var statue_data := _pending_statue_choices[index] as Resource
	if statue_data == null:
		return false

	if statue_system == null or not statue_system.has_method("obtain_statue"):
		return false
	if not bool(statue_system.call("obtain_statue", statue_data)):
		return false

	var reward_source: Node = self
	if is_instance_valid(_pending_statue_source):
		reward_source = _pending_statue_source
		_pending_statue_source.queue_free()
	Events.reward_collected.emit(reward_source, _pending_statue_collector)

	_pending_statue_choices.clear()
	_pending_statue_source = null
	_pending_statue_collector = null
	hud.hide_relic_choices()
	return true


func _request_boss_talent_choice(source_node: Node, collector: Node) -> void:
	if run_state != RunState.RUNNING:
		return
	if talent_system == null or not talent_system.has_method("get_reward_choices"):
		return

	var choices: Array = talent_system.call("get_reward_choices", 3, "boss")
	if choices.is_empty():
		return

	_pending_talent_choices = choices.duplicate()
	_pending_talent_source = source_node
	_pending_talent_collector = collector
	Events.talent_choice_requested.emit(choices, source_node, collector)
	hud.show_talent_choices(choices, self)


func _on_talent_collected(talent_data: Resource, stack_count: int) -> void:
	var display_name := str(talent_data.get("display_name"))
	if stack_count > 1:
		hud.show_message("%s x%d" % [display_name, stack_count])
	else:
		hud.show_message(display_name)


func _on_blessing_collected(blessing_data: Resource, stack_count: int) -> void:
	var display_name := str(blessing_data.get("display_name"))
	if stack_count > 1:
		hud.show_message("%s x%d" % [display_name, stack_count])
	else:
		hud.show_message(display_name)


func _on_blessing_triggered(blessing_data: Resource, trigger_event: String, _effect_type: String, _effect_value: float) -> void:
	var display_name := str(blessing_data.get("display_name"))
	if display_name.is_empty():
		display_name = "Blessing"
	if run_state == RunState.RUNNING:
		_blessing_trigger_count += 1
		var blessing_id := str(blessing_data.get("id"))
		if blessing_id.is_empty():
			blessing_id = display_name
		_blessing_trigger_counts[blessing_id] = int(_blessing_trigger_counts.get(blessing_id, 0)) + 1

	hud.show_message("%s Triggered" % display_name)
	if hud.has_method("show_rule_trigger_feedback"):
		hud.call("show_rule_trigger_feedback", "Blessing", display_name, trigger_event, _resolve_content_icon_key(blessing_data, "blessing"))
	_spawn_floating_text(
		_get_feedback_position(player, null) + Vector2(0, -52),
		_format_blessing_trigger_text(display_name, trigger_event),
		Color(1.0, 0.72, 0.28, 1.0),
		18,
		42.0
	)


func _on_statue_collected(statue_data: Resource, stack_count: int) -> void:
	var display_name := str(statue_data.get("display_name"))
	if stack_count > 1:
		hud.show_message("%s x%d" % [display_name, stack_count])
	else:
		hud.show_message(display_name)


func _on_statue_attuned(statue_data: Resource, attunement_count: int) -> void:
	var display_name := str(statue_data.get("display_name"))
	if display_name.is_empty():
		display_name = "Statue"
	if run_state == RunState.RUNNING:
		_statue_attunement_count += 1
		var statue_id := str(statue_data.get("id"))
		if statue_id.is_empty():
			statue_id = display_name
		_statue_attunement_counts[statue_id] = int(_statue_attunement_counts.get(statue_id, 0)) + 1

	hud.show_message("%s Attuned +%d" % [display_name, maxi(attunement_count, 1)])
	if hud.has_method("show_rule_trigger_feedback"):
		hud.call("show_rule_trigger_feedback", "Statue", display_name, "attuned", _resolve_content_icon_key(statue_data, "statue"))
	_spawn_floating_text(
		_get_feedback_position(player, null) + Vector2(0, -96),
		_format_statue_attunement_text(display_name, attunement_count),
		Color(0.45, 0.98, 1.0, 1.0),
		18,
		46.0
	)


func _on_statue_triggered(statue_data: Resource, trigger_event: String, _effect_type: String, _effect_value: float) -> void:
	var display_name := str(statue_data.get("display_name"))
	if display_name.is_empty():
		display_name = "Statue"
	if run_state == RunState.RUNNING:
		_statue_trigger_count += 1
		var statue_id := str(statue_data.get("id"))
		if statue_id.is_empty():
			statue_id = display_name
		_statue_trigger_counts[statue_id] = int(_statue_trigger_counts.get(statue_id, 0)) + 1

	hud.show_message("%s Resonates" % display_name)
	if hud.has_method("show_rule_trigger_feedback"):
		hud.call("show_rule_trigger_feedback", "Statue", display_name, trigger_event, _resolve_content_icon_key(statue_data, "statue"))
	_spawn_floating_text(
		_get_feedback_position(player, null) + Vector2(0, -78),
		_format_statue_trigger_text(display_name, trigger_event),
		Color(0.62, 0.84, 1.0, 1.0),
		18,
		44.0
	)


func _get_passive_feedback_color(passive_id: String) -> Color:
	match passive_id:
		"steady_hands":
			return Color(1.0, 0.78, 0.28, 1.0)
		"armored_core":
			return Color(0.42, 0.78, 1.0, 1.0)
		"energy_focus":
			return Color(0.62, 0.9, 1.0, 1.0)
		"phase_footing":
			return Color(0.62, 1.0, 0.72, 1.0)
		"volatile_focus":
			return Color(1.0, 0.48, 0.24, 1.0)
		"triage_kit":
			return Color(0.42, 1.0, 0.62, 1.0)
		_:
			return Color(1.0, 0.86, 0.36, 1.0)


func _refresh_enemy_count() -> void:
	var count := 0
	for node in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		if node.has_method("is_dead") and node.call("is_dead"):
			continue
		count += 1

	hud.update_enemy_count(count)


func _format_blessing_trigger_text(display_name: String, trigger_event: String) -> String:
	match trigger_event:
		"on_room_clear":
			return "BLESSING CLEAR"
		"on_kill":
			return "BLESSING KILL"
		"on_hurt":
			return "BLESSING GUARD"
	var clean_name := display_name.strip_edges()
	if clean_name.length() > 14:
		clean_name = clean_name.substr(0, 14)
	return clean_name.to_upper()


func _format_statue_trigger_text(display_name: String, trigger_event: String) -> String:
	if trigger_event == "on_skill_used":
		return "STATUE SKILL"
	var clean_name := display_name.strip_edges()
	if clean_name.length() > 14:
		clean_name = clean_name.substr(0, 14)
	return clean_name.to_upper()


func _format_statue_attunement_text(display_name: String, attunement_count: int) -> String:
	var clean_name := display_name.strip_edges()
	if clean_name.length() > 10:
		clean_name = clean_name.substr(0, 10)
	return "%s +%d" % [clean_name.to_upper(), maxi(attunement_count, 1)]


func _add_shake(amount: float) -> void:
	var scaled_amount := maxf(amount, 0.0) * _settings_screen_shake_intensity
	if scaled_amount <= 0.0:
		return
	_shake_strength = maxf(_shake_strength, scaled_amount)


func get_screen_shake_strength_for_test() -> float:
	return _shake_strength


func get_screen_shake_intensity_for_test() -> float:
	return _settings_screen_shake_intensity


func set_screen_shake_intensity_for_test(value: float) -> void:
	_settings_screen_shake_intensity = clampf(value, 0.0, 1.0)
	_apply_feedback_settings()


func add_screen_shake_for_test(amount: float) -> void:
	_add_shake(amount)


func get_combat_text_intensity_for_test() -> float:
	return _settings_combat_text_intensity


func set_combat_text_intensity_for_test(value: float) -> void:
	_settings_combat_text_intensity = clampf(value, 0.0, 1.0)


func _spawn_floating_text(world_position: Vector2, text: String, color: Color, font_size: int = 20, rise_distance: float = 46.0) -> Node:
	var text_intensity := clampf(_settings_combat_text_intensity, 0.0, 1.0)
	if text_intensity <= 0.0:
		return null

	var floating_text := FLOATING_TEXT_SCENE.instantiate() as Node2D
	if floating_text == null:
		return null

	var text_color := color
	text_color.a = clampf(text_color.a, 0.0, 1.0) * text_intensity
	add_child(floating_text)
	floating_text.global_position = world_position + Vector2(_rng.randf_range(-10.0, 10.0), _rng.randf_range(-8.0, 4.0))
	if floating_text.has_method("setup"):
		floating_text.call("setup", text, text_color, font_size, rise_distance, _rng.randf_range(-12.0, 12.0))
	return floating_text


func _spawn_projectile_block_spark(world_position: Vector2, blocked_count: int) -> Node:
	var spark := PROJECTILE_BLOCK_SPARK_SCENE.instantiate() as Node2D
	if spark == null:
		return null

	add_child(spark)
	spark.global_position = world_position
	if spark.has_method("configure"):
		spark.call("configure", blocked_count)
	return spark


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
		var text_color := Color.WHITE
		if node.has_method("get_text_color"):
			var reported_color = node.call("get_text_color")
			if typeof(reported_color) == TYPE_COLOR:
				text_color = reported_color
		snapshots.append({
			"text": text,
			"position": position,
			"color": text_color,
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


func _get_total_biomes() -> int:
	var controller := _get_dungeon_controller()
	if controller != null and controller.has_method("get_total_biomes"):
		return int(controller.call("get_total_biomes"))
	return 1


func _get_biomes_reached() -> int:
	var controller := _get_dungeon_controller()
	if controller == null or not controller.has_method("get_room_records"):
		return 1

	var reached := 1
	var records: Array = controller.call("get_room_records")
	for record in records:
		if not record is Dictionary:
			continue
		if bool(record.get("visited", false)) or bool(record.get("cleared", false)) or bool(record.get("current", false)):
			reached = maxi(reached, int(record.get("biome_index", 1)))
	return reached


func _get_run_route_nodes() -> Array[Dictionary]:
	var nodes: Array[Dictionary] = []
	var controller := _get_dungeon_controller()
	if controller == null or not controller.has_method("get_room_records"):
		return nodes

	var records: Array = controller.call("get_room_records")
	for record in records:
		if not record is Dictionary:
			continue
		var room_type := str(record.get("room_type", "combat"))
		var enemy_names := _string_array_from_variant(record.get("enemy_pool", []))
		var boss_name := ""
		if room_type == "boss" or room_type == "boss_placeholder":
			boss_name = _first_text(enemy_names, "%s Boss" % str(record.get("biome_name", "Biome")))
		nodes.append({
			"id": str(record.get("id", "")),
			"biome_index": int(record.get("biome_index", 1)),
			"biome_id": str(record.get("biome_id", "")),
			"biome_name": str(record.get("biome_name", "")),
			"room_type": room_type,
			"path_role": str(record.get("path_role", "main")),
			"main_path_index": int(record.get("main_path_index", -1)),
			"biome_main_path_index": int(record.get("biome_main_path_index", -1)),
			"branch_of": int(record.get("branch_of", -1)),
			"state": str(record.get("state", "Unentered")),
			"visited": bool(record.get("visited", false)),
			"cleared": bool(record.get("cleared", false)),
			"current": bool(record.get("current", false)),
			"is_biome_boss": bool(record.get("is_biome_boss", false)),
			"is_final_boss": bool(record.get("is_final_boss", false)),
			"boss_name": boss_name,
		})
	return nodes


func _get_boss_route_summary(route_nodes: Array[Dictionary]) -> Array[Dictionary]:
	var bosses: Array[Dictionary] = []
	for node in route_nodes:
		if not bool(node.get("is_biome_boss", false)):
			continue
		bosses.append({
			"room_id": str(node.get("id", "")),
			"biome_index": int(node.get("biome_index", 1)),
			"biome_name": str(node.get("biome_name", "")),
			"boss_name": str(node.get("boss_name", "")),
			"is_final_boss": bool(node.get("is_final_boss", false)),
			"visited": bool(node.get("visited", false)),
			"cleared": bool(node.get("cleared", false)),
		})
	return bosses


func _get_special_room_counts(route_nodes: Array[Dictionary]) -> Dictionary:
	var counts := {}
	for room_type in _get_special_room_types():
		counts[room_type] = 0

	for node in route_nodes:
		var room_type := str(node.get("room_type", "combat"))
		if not counts.has(room_type):
			continue
		var is_visited := bool(node.get("visited", false)) or bool(node.get("cleared", false)) or bool(node.get("current", false))
		if is_visited:
			counts[room_type] = int(counts.get(room_type, 0)) + 1
	return counts


func _format_special_room_counts(counts: Dictionary) -> String:
	var parts: PackedStringArray = []
	for room_type in _get_special_room_types():
		var count := int(counts.get(room_type, 0))
		if count <= 0:
			continue
		parts.append("%s %d" % [_get_special_room_label(room_type), count])
	return ", ".join(parts) if not parts.is_empty() else "None"


func _get_special_room_types() -> PackedStringArray:
	return PackedStringArray(["event", "challenge", "trap", "reward", "armory", "healing", "elite", "shop"])


func _get_special_room_label(room_type: String) -> String:
	match room_type:
		"event":
			return "Event"
		"challenge":
			return "Challenge"
		"trap":
			return "Trap"
		"reward":
			return "Reward"
		"armory":
			return "Armory"
		"healing":
			return "Healing"
		"elite":
			return "Elite"
		"shop":
			return "Shop"
	return room_type.capitalize()


func _get_run_position_summary(route_nodes: Array[Dictionary]) -> Dictionary:
	var selected: Dictionary = {}
	for node in route_nodes:
		if bool(node.get("current", false)):
			selected = node
			break
		if bool(node.get("visited", false)) or bool(node.get("cleared", false)):
			selected = node

	if selected.is_empty():
		return {
			"room_id": "",
			"room_type": "unknown",
			"room_label": "Unknown",
			"biome_index": 1,
			"biome_name": "Layer 1",
			"state": "Unknown",
			"is_boss": false,
			"is_final_boss": false,
			"text": "Unknown",
		}

	var room_type := str(selected.get("room_type", "combat"))
	var room_label := _get_run_position_room_label(room_type, bool(selected.get("is_final_boss", false)))
	var state := _get_run_position_state(selected)
	var biome_index := int(selected.get("biome_index", 1))
	var biome_name := str(selected.get("biome_name", "Layer %d" % biome_index))
	var room_id := str(selected.get("id", ""))
	return {
		"room_id": room_id,
		"room_type": room_type,
		"room_label": room_label,
		"biome_index": biome_index,
		"biome_name": biome_name,
		"state": state,
		"is_boss": room_type == "boss" or room_type == "boss_placeholder",
		"is_final_boss": bool(selected.get("is_final_boss", false)),
		"text": "L%d %s %s %s %s" % [biome_index, biome_name, room_id, room_label, state],
	}


func _get_run_position_state(node: Dictionary) -> String:
	if bool(node.get("current", false)):
		return "Current"
	if bool(node.get("cleared", false)):
		return "Cleared"
	if bool(node.get("visited", false)):
		return "Visited"
	return str(node.get("state", "Unvisited"))


func _get_run_position_room_label(room_type: String, is_final_boss: bool) -> String:
	if is_final_boss:
		return "Final Boss"
	match room_type:
		"start":
			return "Start"
		"combat":
			return "Combat"
		"challenge":
			return "Challenge"
		"trap":
			return "Trap"
		"reward":
			return "Reward"
		"event":
			return "Event"
		"armory":
			return "Armory"
		"healing":
			return "Healing"
		"elite":
			return "Elite"
		"shop":
			return "Shop"
		"boss", "boss_placeholder":
			return "Boss"
	return room_type.capitalize()


func _get_defeat_cause_summary(result_name: String, run_position: Dictionary, last_damage: Dictionary) -> Dictionary:
	var location := str(run_position.get("text", "Unknown"))
	if result_name != "Defeat":
		return {
			"category": "none",
			"source_id": "none",
			"source_name": "None",
			"source_type": "none",
			"source_scene": "",
			"source_room_type": "",
			"source_biome_id": "",
			"source_biome_name": "",
			"source_layout_profile": "",
			"source_review_tip": "",
			"source_threat_intel": "",
			"source_counter_tags": [],
			"amount": 0,
			"location": location,
			"text": "None",
		}

	var source_type := str(last_damage.get("source_type", "unknown"))
	var source_id := str(last_damage.get("source_id", "unknown"))
	var source_name := str(last_damage.get("source_name", "Unknown"))
	var source_scene := str(last_damage.get("source_scene", ""))
	var source_room_type := str(last_damage.get("source_room_type", ""))
	var source_biome_id := str(last_damage.get("source_biome_id", ""))
	var source_biome_name := str(last_damage.get("source_biome_name", ""))
	var source_layout_profile := str(last_damage.get("source_layout_profile", ""))
	var source_review_tip := str(last_damage.get("source_review_tip", ""))
	var source_threat_intel := str(last_damage.get("source_threat_intel", ""))
	var source_counter_tags := _string_array_from_variant(last_damage.get("source_counter_tags", []))
	var amount := int(last_damage.get("amount", 0))
	var category := _get_defeat_cause_category(source_type)
	if amount > 0:
		return {
			"category": category,
			"source_id": source_id,
			"source_name": source_name,
			"source_type": source_type,
			"source_scene": source_scene,
			"source_room_type": source_room_type,
			"source_biome_id": source_biome_id,
			"source_biome_name": source_biome_name,
			"source_layout_profile": source_layout_profile,
			"source_review_tip": source_review_tip,
			"source_threat_intel": source_threat_intel,
			"source_counter_tags": source_counter_tags,
			"amount": amount,
			"location": location,
			"text": "%s %s for %d at %s" % [category, source_name, amount, location],
		}

	return {
		"category": "Unknown",
		"source_id": "unknown",
		"source_name": "Unknown",
		"source_type": "unknown",
		"source_scene": "",
		"source_room_type": "",
		"source_biome_id": "",
		"source_biome_name": "",
		"source_layout_profile": "",
		"source_review_tip": "",
		"source_threat_intel": "",
		"source_counter_tags": [],
		"amount": 0,
		"location": location,
		"text": "Unknown at %s" % location,
	}


func _get_defeat_cause_category(source_type: String) -> String:
	match source_type:
		"boss":
			return "Boss"
		"enemy":
			return "Enemy"
		"hazard":
			return "Hazard"
	return "Unknown"


func _get_route_signature(route_nodes: Array[Dictionary], visited_only: bool = false) -> String:
	var markers_by_biome := {}
	var branch_counts := {}
	for node in route_nodes:
		var is_visited := bool(node.get("visited", false)) or bool(node.get("cleared", false)) or bool(node.get("current", false))
		if visited_only and not is_visited:
			continue

		var biome_index := int(node.get("biome_index", 1))
		if not markers_by_biome.has(biome_index):
			markers_by_biome[biome_index] = PackedStringArray()
			branch_counts[biome_index] = 0

		var path_role := str(node.get("path_role", "main"))
		if path_role == "main" or visited_only:
			var markers: PackedStringArray = markers_by_biome[biome_index]
			markers.append(_get_route_room_marker(str(node.get("room_type", "combat"))))
			markers_by_biome[biome_index] = markers
		else:
			branch_counts[biome_index] = int(branch_counts.get(biome_index, 0)) + 1

	if markers_by_biome.is_empty():
		return "Unvisited"

	var biome_indexes := markers_by_biome.keys()
	biome_indexes.sort()
	var parts := PackedStringArray()
	for key in biome_indexes:
		var biome_index := int(key)
		var markers: PackedStringArray = markers_by_biome[biome_index]
		if markers.is_empty():
			continue
		var text := "L%d:%s" % [biome_index, "-".join(markers)]
		var branch_count := int(branch_counts.get(biome_index, 0))
		if branch_count > 0 and not visited_only:
			text += "+%dB" % branch_count
		parts.append(text)
	return " | ".join(parts) if not parts.is_empty() else "Unvisited"


func _get_route_room_marker(room_type: String) -> String:
	match room_type:
		"start":
			return "S"
		"reward":
			return "R"
		"event":
			return "E"
		"challenge":
			return "C!"
		"trap":
			return "T"
		"armory":
			return "A"
		"healing":
			return "H"
		"elite":
			return "EL"
		"shop":
			return "$"
		"boss", "boss_placeholder":
			return "B"
	return "C"


func _get_reached_biome_name(route_nodes: Array[Dictionary], reached_biome: int) -> String:
	for node in route_nodes:
		if int(node.get("biome_index", 1)) == reached_biome:
			return str(node.get("biome_name", "Layer %d" % reached_biome))
	return "Layer %d" % reached_biome


func _resolve_defeated_boss_name(boss: Node) -> String:
	if boss != null:
		var value = boss.get("display_name")
		if value != null and not str(value).is_empty():
			return str(value)

	var route_nodes := _get_run_route_nodes()
	for node in route_nodes:
		if bool(node.get("is_biome_boss", false)) and not bool(node.get("cleared", false)):
			var fallback := str(node.get("boss_name", ""))
			if not fallback.is_empty():
				return fallback
	return "Boss %d" % maxi(_bosses_defeated, 1)


func _first_text(values: Array, fallback: String) -> String:
	for value in values:
		var text := str(value)
		if not text.is_empty():
			return text
	return fallback


func _join_text_values(values: Array, fallback: String) -> String:
	var strings := PackedStringArray()
	for value in values:
		var text := str(value)
		if not text.is_empty():
			strings.append(text)
	return ", ".join(strings) if not strings.is_empty() else fallback


func _get_event_record_names() -> Array[String]:
	var names: Array[String] = []
	for record in _event_records:
		names.append(_format_event_record_name(record))
	return names


func _format_event_record_name(record: Dictionary) -> String:
	var display_name := str(record.get("display_name", "Event")).strip_edges()
	if display_name.is_empty():
		display_name = "Event"
	var outcome_label := str(record.get("outcome_label", "")).strip_edges()
	if outcome_label.is_empty():
		outcome_label = _format_event_token(str(record.get("outcome_id", "")), "Event Result")
	var text := "%s -> %s" % [display_name, outcome_label]
	var health_cost := int(record.get("health_cost", 0))
	if health_cost > 0:
		text += " (-%d HP)" % health_cost
	return text


func _duplicate_event_records() -> Array:
	var records: Array = []
	for record in _event_records:
		records.append(record.duplicate(true))
	return records


func _collect_build_route_counts(relic_summaries: Array, talent_summaries: Array, blessing_summaries: Array, statue_summaries: Array = []) -> Dictionary:
	var counts := {}
	if is_instance_valid(player):
		for weapon_data in player.weapon_loadout:
			if weapon_data == null:
				continue
			_add_build_tags(counts, weapon_data.get("tags"))
	for summary in relic_summaries:
		if summary is Dictionary:
			_add_build_tags(counts, summary.get("build_tags"))
	for summary in talent_summaries:
		if summary is Dictionary:
			_add_build_tags(counts, summary.get("build_tags"))
	for summary in blessing_summaries:
		if summary is Dictionary:
			_add_build_tags(counts, summary.get("build_tags"))
	for summary in statue_summaries:
		if summary is Dictionary:
			_add_build_tags(counts, summary.get("build_tags"))
	return counts


func _add_build_tags(counts: Dictionary, raw_tags) -> void:
	for tag in _string_array_from_variant(raw_tags):
		var normalized := str(tag).strip_edges().to_lower()
		if normalized.is_empty() or normalized == "starter":
			continue
		counts[normalized] = int(counts.get(normalized, 0)) + 1


func _get_primary_build_routes(counts: Dictionary, limit: int = 5) -> Array[String]:
	var entries: Array[Dictionary] = []
	for key in counts.keys():
		entries.append({
			"tag": str(key),
			"count": int(counts[key]),
		})
	entries.sort_custom(_sort_build_route_entries)

	var routes: Array[String] = []
	for index in range(mini(limit, entries.size())):
		var entry := entries[index]
		var tag := str(entry.get("tag", ""))
		var count := int(entry.get("count", 0))
		routes.append("%s x%d" % [_format_build_route_label(tag), count])
	return routes


func _sort_build_route_entries(a: Dictionary, b: Dictionary) -> bool:
	var a_count := int(a.get("count", 0))
	var b_count := int(b.get("count", 0))
	if a_count == b_count:
		return str(a.get("tag", "")) < str(b.get("tag", ""))
	return a_count > b_count


func _format_build_route_label(tag: String) -> String:
	return tag.replace("_", " ").capitalize()


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
	_events_resolved = 0
	_event_records.clear()
	_damage_taken = 0
	_last_damage_record.clear()
	_critical_hits = 0
	_healing_received = 0
	_shield_absorbed = 0
	_projectiles_blocked = 0
	_blessing_trigger_count = 0
	_blessing_trigger_counts.clear()
	_statue_trigger_count = 0
	_statue_trigger_counts.clear()
	_statue_attunement_count = 0
	_statue_attunement_counts.clear()
	_boss_defeated = false
	_bosses_defeated = 0
	_defeated_boss_names.clear()
	_run_result_recorded = false
	_pending_relic_choices.clear()
	_pending_relic_pickup = null
	_pending_relic_collector = null
	_pending_talent_choices.clear()
	_pending_talent_source = null
	_pending_talent_collector = null
	_pending_blessing_choices.clear()
	_pending_blessing_source = null
	_pending_blessing_collector = null
	_pending_statue_choices.clear()
	_pending_statue_source = null
	_pending_statue_collector = null
	if relic_system != null and relic_system.has_method("reset_run"):
		relic_system.call("reset_run")
	if talent_system != null and talent_system.has_method("reset_run"):
		talent_system.call("reset_run")
	if blessing_system != null and blessing_system.has_method("reset_run"):
		blessing_system.call("reset_run")
	if statue_system != null and statue_system.has_method("reset_run"):
		statue_system.call("reset_run")


func _reset_training_stats() -> void:
	var drill := _get_training_drill()
	var drill_id := str(drill.get("id", "basics"))
	var best_rating_rank := _get_training_drill_best_rating_rank(drill_id)
	_training_hit_target_ids.clear()
	_training_hit_type_target_ids.clear()
	_training_stats = {
		"drill_id": drill_id,
		"drill_name": str(drill.get("display_name", "Basics")),
		"instruction": str(drill.get("instruction", "")),
		"targets": _get_training_targets().size(),
		"target_types": _format_training_target_type_summary(),
		"goal_text": str(drill.get("goal_text", "")),
		"goal_progress": 0,
		"goal_required": int(drill.get("goal_required", 0)),
		"goal_complete": false,
		"rating_rank": "practice",
		"rating_text": "Practice",
		"best_rating_rank": best_rating_rank,
		"best_rating_text": _get_training_rating_text(best_rating_rank),
		"best_rating_token": _get_training_badge_token(best_rating_rank),
		"badge_notice_text": "",
		"hits": 0,
		"damage": 0,
		"best_hit": 0,
		"best_burst_chain": 0,
	}
	_update_training_goal_progress()
	_update_training_rating()
	_update_training_hud()


func _record_training_hit(target: Node, damage: int) -> void:
	if target == null or not target.is_in_group("training_dummy"):
		return

	var effective_damage := maxi(damage, 0)
	if target.has_method("get_last_applied_damage"):
		effective_damage = maxi(int(target.call("get_last_applied_damage")), 0)
	_training_stats["hits"] = int(_training_stats.get("hits", 0)) + 1
	_training_stats["damage"] = int(_training_stats.get("damage", 0)) + effective_damage
	_training_stats["best_hit"] = maxi(int(_training_stats.get("best_hit", 0)), effective_damage)
	if target.has_method("get_best_burst_chain"):
		_training_stats["best_burst_chain"] = maxi(
			int(_training_stats.get("best_burst_chain", 0)),
			int(target.call("get_best_burst_chain"))
		)
	_record_training_goal_hit(target)
	_update_training_goal_progress()
	_update_training_rating()
	_record_training_badge_if_improved()
	_update_training_hud()


func _record_training_goal_hit(target: Node) -> void:
	var target_id := target.get_instance_id()
	_training_hit_target_ids[target_id] = true

	var target_type := "standard"
	if target.has_method("get_target_type"):
		target_type = str(target.call("get_target_type"))
	else:
		target_type = str(target.get("target_type"))
	target_type = target_type.strip_edges().to_lower()
	if target_type.is_empty():
		target_type = "standard"
	if not _training_hit_type_target_ids.has(target_type):
		_training_hit_type_target_ids[target_type] = {}
	var type_targets: Dictionary = _training_hit_type_target_ids[target_type]
	type_targets[target_id] = true
	_training_hit_type_target_ids[target_type] = type_targets


func _update_training_goal_progress() -> void:
	var drill := _get_training_drill()
	var goal_type := str(drill.get("goal_type", ""))
	var required := maxi(int(drill.get("goal_required", 0)), 0)
	var progress := 0
	match goal_type:
		"unique_targets":
			progress = _training_hit_target_ids.size()
		"target_type_hits":
			var target_type := str(drill.get("goal_target_type", "")).strip_edges().to_lower()
			var type_targets: Dictionary = _training_hit_type_target_ids.get(target_type, {})
			progress = type_targets.size()
		"burst_chain":
			progress = int(_training_stats.get("best_burst_chain", 0))
		_:
			progress = 0

	progress = mini(progress, required) if required > 0 else progress
	_training_stats["goal_text"] = str(drill.get("goal_text", ""))
	_training_stats["goal_progress"] = progress
	_training_stats["goal_required"] = required
	_training_stats["goal_complete"] = required > 0 and progress >= required


func _update_training_rating() -> void:
	var goal_complete := bool(_training_stats.get("goal_complete", false))
	var required := int(_training_stats.get("goal_required", 0))
	var hits := int(_training_stats.get("hits", 0))
	var rating_rank := "practice"
	var rating_text := "Practice"
	if goal_complete:
		rating_rank = "clear"
		rating_text = "Clear"
		if required > 0 and hits <= required:
			rating_rank = "clean"
			rating_text = "Clean"

	_training_stats["rating_rank"] = rating_rank
	_training_stats["rating_text"] = rating_text
	var drill_id := str(_training_stats.get("drill_id", ""))
	var best_rating_rank := _get_training_drill_best_rating_rank(drill_id)
	_training_stats["best_rating_rank"] = best_rating_rank
	_training_stats["best_rating_text"] = _get_training_rating_text(best_rating_rank)
	_training_stats["best_rating_token"] = _get_training_badge_token(best_rating_rank)
	if not _training_stats.has("badge_notice_text"):
		_training_stats["badge_notice_text"] = ""


func _record_training_badge_if_improved() -> void:
	if not bool(_training_stats.get("goal_complete", false)):
		return

	var drill_id := str(_training_stats.get("drill_id", ""))
	if drill_id.is_empty():
		return

	var rating_rank := _normalize_training_rating_rank(str(_training_stats.get("rating_rank", "practice")))
	var current_score := _get_training_rating_score(rating_rank)
	if current_score <= 0:
		return

	var previous_rank := _get_training_drill_best_rating_rank(drill_id)
	if current_score <= _get_training_rating_score(previous_rank):
		return

	_training_drill_best_ratings[drill_id] = rating_rank
	_training_stats["best_rating_rank"] = rating_rank
	_training_stats["best_rating_text"] = _get_training_rating_text(rating_rank)
	_training_stats["best_rating_token"] = _get_training_badge_token(rating_rank)
	_training_stats["badge_notice_text"] = "Badge Unlocked: %s %s" % [
		_get_training_rating_text(rating_rank),
		_get_training_badge_token(rating_rank),
	]
	_save_history()
	if hud != null:
		hud.show_message("Training Badge: %s %s" % [
			_get_training_rating_text(rating_rank),
			_get_training_badge_token(rating_rank),
		])


func _get_training_drill_best_rating_rank(drill_id: String) -> String:
	return _normalize_training_rating_rank(str(_training_drill_best_ratings.get(drill_id, "")))


func _get_training_rating_text(rating_rank: String) -> String:
	match _normalize_training_rating_rank(rating_rank):
		"clean":
			return "Clean"
		"clear":
			return "Clear"
		"practice":
			return "Practice"
	return "None"


func _get_training_badge_token(rating_rank: String) -> String:
	match _normalize_training_rating_rank(rating_rank):
		"clean":
			return "[CN]"
		"clear":
			return "[CL]"
	return "[--]"


func _normalize_training_rating_rank(rating_rank: String) -> String:
	var normalized := rating_rank.strip_edges().to_lower()
	match normalized:
		"clean", "clear", "practice":
			return normalized
	return ""


func _get_training_rating_score(rating_rank: String) -> int:
	match _normalize_training_rating_rank(rating_rank):
		"clean":
			return 2
		"clear":
			return 1
		"practice":
			return 0
	return -1


func _get_training_badge_count() -> int:
	var count := 0
	for drill in TRAINING_DRILLS:
		var drill_data: Dictionary = drill
		var drill_id := str(drill_data.get("id", ""))
		if _get_training_rating_score(_get_training_drill_best_rating_rank(drill_id)) > 0:
			count += 1
	return count


func _spawn_training_dummies() -> void:
	if _has_training_dummies():
		return

	_training_dummies.clear()
	for entry in _get_training_targets():
		var entry_data: Dictionary = entry
		var target_position: Vector2 = entry_data.get("position", Vector2.ZERO)
		var dummy := TRAINING_DUMMY_SCENE.instantiate() as Node2D
		if dummy == null:
			continue

		if dummy.has_method("configure"):
			dummy.call("configure", entry_data)
		else:
			dummy.set("display_name", str(entry_data.get("display_name", "Training Target")))
		dummy.global_position = target_position
		add_child(dummy)
		_training_dummies.append(dummy)


func _despawn_training_dummies() -> void:
	for dummy in _training_dummies:
		if is_instance_valid(dummy):
			dummy.queue_free()
	_training_dummies.clear()


func _has_training_dummies() -> bool:
	for dummy in _training_dummies:
		if is_instance_valid(dummy) and not dummy.is_queued_for_deletion():
			return true
	return false


func _position_player_for_training() -> void:
	if not is_instance_valid(player):
		return

	player.global_position = TRAINING_PLAYER_POSITION
	player.velocity = Vector2.ZERO
	if is_instance_valid(camera):
		camera.global_position = player.global_position


func _get_training_drill() -> Dictionary:
	if TRAINING_DRILLS.is_empty():
		return {}
	_training_drill_index = clampi(_training_drill_index, 0, TRAINING_DRILLS.size() - 1)
	return TRAINING_DRILLS[_training_drill_index]


func _get_training_drill_name() -> String:
	var drill := _get_training_drill()
	return str(drill.get("display_name", "Training"))


func _get_training_targets() -> Array:
	var drill := _get_training_drill()
	var targets = drill.get("targets", [])
	if targets is Array:
		return targets
	return []


func _format_training_target_type_summary() -> String:
	var counts := {}
	for entry in _get_training_targets():
		if not entry is Dictionary:
			continue
		var target_type := str((entry as Dictionary).get("target_type", "standard")).strip_edges().to_lower()
		if target_type.is_empty():
			target_type = "standard"
		counts[target_type] = int(counts.get(target_type, 0)) + 1
	if counts.is_empty():
		return "None"

	var keys := counts.keys()
	keys.sort()
	var parts := PackedStringArray()
	for key in keys:
		parts.append("%s %d" % [
			_format_training_target_type_label(str(key)),
			int(counts.get(key, 0)),
		])
	return ", ".join(parts)


func _format_training_target_type_label(target_type: String) -> String:
	var text := target_type.strip_edges()
	if text.is_empty():
		return "Standard"
	return text.replace("_", " ").capitalize()


func _restore_player_for_training() -> void:
	if not is_instance_valid(player):
		return
	if player.has_method("select_character"):
		player.call("select_character", player.current_character_index)
	_apply_current_character_mastery_bonus(true)


func _show_training_hud() -> void:
	if hud == null or not hud.has_method("show_training_panel"):
		return
	hud.call("show_training_panel", self)
	_update_training_hud()


func _sync_training_aim_assist_stats() -> void:
	if _training_stats.is_empty():
		return

	var state_text := "On" if _settings_aim_assist_enabled else "Off"
	var target_text := "Training" if run_state == RunState.TRAINING else "Enemies"
	var strength_band := _get_aim_assist_strength_band()
	_training_stats["aim_assist_enabled"] = _settings_aim_assist_enabled
	_training_stats["aim_assist_strength_percent"] = roundi(_settings_aim_assist_strength * 100.0)
	_training_stats["aim_assist_strength_band"] = strength_band
	_training_stats["aim_assist_target_layer"] = target_text
	_training_stats["aim_assist_text"] = "Aim Assist: %s %d%% | Band %s | Targets %s" % [
		state_text,
		int(_training_stats.get("aim_assist_strength_percent", 0)),
		strength_band,
		target_text,
	]


func _get_aim_assist_strength_band() -> String:
	if not _settings_aim_assist_enabled or _settings_aim_assist_strength <= 0.0:
		return "Off"
	if _settings_aim_assist_strength < 0.45:
		return "Light"
	if _settings_aim_assist_strength < 0.7:
		return "Balanced"
	return "Strong"


func _get_aim_assist_preset_settings(band: String) -> Dictionary:
	match band.strip_edges().to_lower():
		"off":
			return {
				"enabled": false,
				"strength": DEFAULT_AIM_ASSIST_STRENGTH,
			}
		"light":
			return {
				"enabled": true,
				"strength": 0.35,
			}
		"balanced":
			return {
				"enabled": true,
				"strength": 0.6,
			}
		"strong":
			return {
				"enabled": true,
				"strength": 0.8,
			}
	return {}


func _update_training_hud() -> void:
	if hud == null or not hud.has_method("update_training_stats"):
		return
	_sync_training_aim_assist_stats()
	hud.call("update_training_stats", _training_stats)


func _clear_training_state() -> void:
	_despawn_training_dummies()
	_reset_training_stats()
	if hud != null and hud.has_method("hide_training_panel"):
		hud.call("hide_training_panel")


func _ensure_input_actions() -> void:
	for action_name in REBINDABLE_INPUT_ACTIONS:
		if not InputMap.has_action(StringName(action_name)):
			InputMap.add_action(StringName(action_name))
	_bind_joy_axis(&"move_left", JOY_AXIS_LEFT_X, -1.0)
	_bind_joy_axis(&"move_right", JOY_AXIS_LEFT_X, 1.0)
	_bind_joy_axis(&"move_up", JOY_AXIS_LEFT_Y, -1.0)
	_bind_joy_axis(&"move_down", JOY_AXIS_LEFT_Y, 1.0)
	_bind_key(&"weapon_slot_1", KEY_1)
	_bind_key(&"weapon_slot_2", KEY_2)
	_bind_key(&"weapon_slot_3", KEY_3)
	_bind_key(&"debug_map", KEY_F3)
	_bind_mouse_button(&"shoot", MOUSE_BUTTON_LEFT)
	_bind_joy_axis(&"shoot", JOY_AXIS_TRIGGER_RIGHT, 1.0)
	_bind_joy_button(&"shoot", JOY_BUTTON_RIGHT_SHOULDER)
	_bind_joy_button(&"reload", JOY_BUTTON_X)
	_bind_joy_button(&"skill", JOY_BUTTON_A)
	_bind_joy_button(&"interact", JOY_BUTTON_Y)
	_bind_joy_button(&"pause", JOY_BUTTON_START)
	_bind_joy_button(&"weapon_slot_1", JOY_BUTTON_DPAD_LEFT)
	_bind_joy_button(&"weapon_slot_2", JOY_BUTTON_DPAD_UP)
	_bind_joy_button(&"weapon_slot_3", JOY_BUTTON_DPAD_RIGHT)
	_bind_joy_axis(&"aim_left", JOY_AXIS_RIGHT_X, -1.0)
	_bind_joy_axis(&"aim_right", JOY_AXIS_RIGHT_X, 1.0)
	_bind_joy_axis(&"aim_up", JOY_AXIS_RIGHT_Y, -1.0)
	_bind_joy_axis(&"aim_down", JOY_AXIS_RIGHT_Y, 1.0)


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
		var character_description := str(character_summary.get("description", ""))
		var character := _get_current_character_data()
		if character != null:
			var mastery_level := _get_character_mastery_level_for_data(character)
			var bonus_text := _format_mastery_bonus(_get_mastery_bonus_for_character(character))
			if mastery_level > 1 and bonus_text != "None":
				character_description = "%s\nMastery L%d: %s" % [
					character_description,
					mastery_level,
					bonus_text,
				]
		hud.update_character_selection(
			str(character_summary.get("display_name", "Adventurer")),
			character_description,
			str(character_summary.get("skill_name", "Skill")),
			str(character_summary.get("skill_description", "")),
			int(character_summary.get("index", 0)),
			int(character_summary.get("total", 1))
		)
	_update_character_unlock_hud()
	if player.has_method("get_skill_summary"):
		var skill_summary: Dictionary = player.call("get_skill_summary")
		hud.update_skill_status(
			str(skill_summary.get("skill_name", "Skill")),
			float(skill_summary.get("cooldown_remaining", 0.0)),
			float(skill_summary.get("cooldown_duration", 0.0)),
			float(skill_summary.get("active_remaining", 0.0))
		)
	_refresh_passive_status_hud()


func _update_character_unlock_hud() -> void:
	if hud == null or not hud.has_method("update_character_unlock_status"):
		return

	var character := _get_current_character_data()
	if character == null:
		hud.call("update_character_unlock_status", true, 0, _meta_currency)
		return

	var character_id := str(character.get("id"))
	hud.call(
		"update_character_unlock_status",
		_is_character_unlocked(character_id, character),
		_get_character_unlock_cost(character),
		_meta_currency
	)


func _show_locked_character_message() -> void:
	if hud == null:
		return
	var character := _get_current_character_data()
	if character == null:
		return
	var character_id := str(character.get("id"))
	if _is_character_unlocked(character_id, character):
		return
	hud.show_message("Locked - %d Data Shards" % _get_character_unlock_cost(character))


func _get_current_character_data() -> Resource:
	if player == null or not player.has_method("get_current_character_data"):
		return null
	return player.call("get_current_character_data") as Resource


func _is_current_character_unlocked() -> bool:
	var character := _get_current_character_data()
	if character == null:
		return true
	return _is_character_unlocked(str(character.get("id")), character)


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


func _bind_joy_axis(action: StringName, axis: JoyAxis, axis_value: float) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)

	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadMotion:
			var joy_event := event as InputEventJoypadMotion
			if joy_event.axis == axis and joy_event.axis_value * axis_value > 0.0:
				return

	var new_event := InputEventJoypadMotion.new()
	new_event.axis = axis
	new_event.axis_value = axis_value
	InputMap.action_add_event(action, new_event)


func _bind_joy_button(action: StringName, button_index: JoyButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)

	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton and (event as InputEventJoypadButton).button_index == button_index:
			return

	var new_event := InputEventJoypadButton.new()
	new_event.button_index = button_index
	InputMap.action_add_event(action, new_event)


func _enter_main_menu() -> void:
	_clear_training_state()
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
	var relic_summaries: Array = []
	if relic_system != null and relic_system.has_method("get_relic_summaries"):
		relic_summaries = relic_system.call("get_relic_summaries")
		relic_count = relic_summaries.size()
		for summary in relic_summaries:
			if summary is Dictionary:
				var name := str(summary.get("display_name", "Relic"))
				var stacks := int(summary.get("stacks", 1))
				relic_stacks += maxi(stacks, 1)
				if stacks > 1:
					relic_names.append("%s x%d" % [name, stacks])
				else:
					relic_names.append(name)

	var talent_count := 0
	var talent_names: Array[String] = []
	var talent_summaries: Array = []
	if talent_system != null and talent_system.has_method("get_talent_summaries"):
		talent_summaries = talent_system.call("get_talent_summaries")
		talent_count = talent_summaries.size()
		for summary in talent_summaries:
			if summary is Dictionary:
				var talent_name := str(summary.get("display_name", "Talent"))
				var stacks := int(summary.get("stacks", 1))
				if stacks > 1:
					talent_names.append("%s x%d" % [talent_name, stacks])
				else:
					talent_names.append(talent_name)

	var blessing_count := 0
	var blessing_names: Array[String] = []
	var blessing_summaries: Array = []
	if blessing_system != null and blessing_system.has_method("get_blessing_summaries"):
		blessing_summaries = blessing_system.call("get_blessing_summaries")
		blessing_count = blessing_summaries.size()
		for summary in blessing_summaries:
			if summary is Dictionary:
				var blessing_name := str(summary.get("display_name", "Blessing"))
				var stacks := int(summary.get("stacks", 1))
				if stacks > 1:
					blessing_names.append("%s x%d" % [blessing_name, stacks])
				else:
					blessing_names.append(blessing_name)

	var statue_count := 0
	var statue_names: Array[String] = []
	var statue_summaries: Array = []
	if statue_system != null and statue_system.has_method("get_statue_summaries"):
		statue_summaries = statue_system.call("get_statue_summaries")
		statue_count = statue_summaries.size()
		for summary in statue_summaries:
			if summary is Dictionary:
				var statue_name := str(summary.get("display_name", "Statue"))
				var stacks := int(summary.get("stacks", 1))
				var attunements := int(summary.get("attunements", 0))
				if stacks > 1 and attunements > 0:
					statue_names.append("%s x%d +%d" % [statue_name, stacks, attunements])
				elif stacks > 1:
					statue_names.append("%s x%d" % [statue_name, stacks])
				elif attunements > 0:
					statue_names.append("%s +%d" % [statue_name, attunements])
				else:
					statue_names.append(statue_name)

	var gold := 0
	var current_hp := 0
	var max_hp := 0
	var shield := 0
	var weapon_name := "Unarmed"
	var character_name := "Adventurer"
	var character_id := ""
	var loadout_names: Array[String] = []
	if is_instance_valid(player):
		gold = player.current_gold
		current_hp = player.current_health
		max_hp = player.max_health
		shield = player.current_shield
		weapon_name = player.get_weapon_display_name()
		if player.has_method("get_character_display_name"):
			character_name = player.get_character_display_name()
		if player.has_method("get_current_character_data"):
			var character_data: Resource = player.call("get_current_character_data")
			if character_data != null:
				character_id = str(character_data.get("id"))
		loadout_names = _get_player_loadout_names()

	var route_nodes := _get_run_route_nodes()
	var boss_route := _get_boss_route_summary(route_nodes)
	var special_room_counts := _get_special_room_counts(route_nodes)
	var run_position := _get_run_position_summary(route_nodes)
	var defeat_cause := _get_defeat_cause_summary(result_name, run_position, _last_damage_record)
	var biomes_reached := _get_biomes_reached()
	var build_route_counts := _collect_build_route_counts(relic_summaries, talent_summaries, blessing_summaries, statue_summaries)
	var primary_build_routes := _get_primary_build_routes(build_route_counts)

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
		"talent_count": talent_count,
		"talent_names": talent_names,
		"blessing_count": blessing_count,
		"blessing_names": blessing_names,
		"statue_count": statue_count,
		"statue_names": statue_names,
		"statue_attunement_count": _statue_attunement_count,
		"statue_attunement_counts": _statue_attunement_counts.duplicate(),
		"character_id": character_id,
		"character": character_name,
		"weapon": weapon_name,
		"loadout": loadout_names,
		"current_hp": current_hp,
		"max_hp": max_hp,
		"shield": shield,
		"shop_purchases": _shop_purchases,
		"chests_opened": _chests_opened,
		"rewards_collected": _rewards_collected,
		"events_resolved": _events_resolved,
		"event_names": _get_event_record_names(),
		"event_records": _duplicate_event_records(),
		"damage_taken": _damage_taken,
		"last_damage": _last_damage_record.duplicate(),
		"last_damage_text": str(_last_damage_record.get("text", "None")),
		"defeat_cause": defeat_cause,
		"defeat_cause_text": str(defeat_cause.get("text", "None")),
		"critical_hits": _critical_hits,
		"healing_received": _healing_received,
		"shield_absorbed": _shield_absorbed,
		"projectiles_blocked": _projectiles_blocked,
		"blessing_trigger_count": _blessing_trigger_count,
		"blessing_trigger_counts": _blessing_trigger_counts.duplicate(),
		"statue_trigger_count": _statue_trigger_count,
		"statue_trigger_counts": _statue_trigger_counts.duplicate(),
		"boss_defeated": _boss_defeated,
		"bosses_defeated": _bosses_defeated,
		"defeated_boss_names": _defeated_boss_names.duplicate(),
		"boss_route": boss_route,
		"biomes_reached": biomes_reached,
		"reached_biome_name": _get_reached_biome_name(route_nodes, biomes_reached),
		"total_biomes": _get_total_biomes(),
		"dungeon_seed": _get_active_dungeon_seed(),
		"route_nodes": route_nodes,
		"route_signature": _get_route_signature(route_nodes),
		"visited_route_signature": _get_route_signature(route_nodes, true),
		"special_room_counts": special_room_counts,
		"special_room_count_text": _format_special_room_counts(special_room_counts),
		"run_position": run_position,
		"run_position_text": str(run_position.get("text", "Unknown")),
		"build_route_counts": build_route_counts,
		"primary_build_routes": primary_build_routes,
		"primary_build_route_text": _join_text_values(primary_build_routes, "Flexible"),
		"elapsed_seconds": elapsed_seconds,
		"history": _history_stats.duplicate(),
		"meta_progression": _build_meta_progression_summary(),
	}


func _finalize_run_summary(victory: bool) -> Dictionary:
	var summary := _build_run_summary("Victory" if victory else "Defeat")
	_record_run_result(summary, victory)
	summary["history"] = _history_stats.duplicate()
	summary["meta_progression"] = _build_meta_progression_summary()
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
	_history_stats["best_biome"] = maxi(int(_history_stats.get("best_biome", 0)), int(summary.get("biomes_reached", 0)))
	_history_stats["best_projectiles_blocked"] = maxi(int(_history_stats.get("best_projectiles_blocked", 0)), int(summary.get("projectiles_blocked", 0)))
	if victory:
		var elapsed := int(summary.get("elapsed_seconds", 0))
		var best_time := int(_history_stats.get("best_time_seconds", 0))
		if best_time <= 0 or elapsed < best_time:
			_history_stats["best_time_seconds"] = elapsed
	else:
		_last_defeat_record = _build_last_defeat_record(summary)
		_record_defeat_source(_last_defeat_record)

	_apply_meta_progression_reward(summary, victory)
	_save_history()


func _apply_meta_progression_reward(summary: Dictionary, victory: bool) -> void:
	var currency_reward := _calculate_meta_currency_reward(summary, victory)
	var mastery_reward := _calculate_mastery_xp_reward(summary, victory)
	var character_id := str(summary.get("character_id", ""))

	_meta_currency = maxi(_meta_currency + currency_reward, 0)
	_meta_total_currency_earned = maxi(_meta_total_currency_earned + currency_reward, 0)
	if not character_id.is_empty():
		_character_mastery_xp[character_id] = maxi(int(_character_mastery_xp.get(character_id, 0)) + mastery_reward, 0)

	summary["meta_currency_awarded"] = currency_reward
	summary["meta_currency_total"] = _meta_currency
	summary["character_mastery_xp_awarded"] = mastery_reward
	summary["character_mastery_level"] = _get_character_mastery_level(character_id)


func _calculate_meta_currency_reward(summary: Dictionary, victory: bool) -> int:
	var reached := maxi(int(summary.get("biomes_reached", 1)), 1)
	var rooms := maxi(int(summary.get("rooms_cleared", 0)), 0)
	var kills := maxi(int(summary.get("kills", 0)), 0)
	var bosses := maxi(int(summary.get("bosses_defeated", 0)), 0)
	var reward := 1 + reached * 2 + bosses * 4 + floori(float(rooms) / 3.0) + floori(float(kills) / 8.0)
	if victory:
		reward += 8
	return maxi(reward, 1)


func _calculate_mastery_xp_reward(summary: Dictionary, victory: bool) -> int:
	var rooms := maxi(int(summary.get("rooms_cleared", 0)), 0)
	var kills := maxi(int(summary.get("kills", 0)), 0)
	var bosses := maxi(int(summary.get("bosses_defeated", 0)), 0)
	var reward := 5 + rooms * 2 + kills + bosses * 10
	if victory:
		reward += 20
	return maxi(reward, 1)


func _build_last_defeat_record(summary: Dictionary) -> Dictionary:
	var cause: Dictionary = summary.get("defeat_cause", {})
	var position: Dictionary = summary.get("run_position", {})
	return {
		"has_record": true,
		"run_index": int(_history_stats.get("runs", 0)),
		"source_id": str(cause.get("source_id", "unknown")),
		"source_name": str(cause.get("source_name", "Unknown")),
		"source_type": str(cause.get("source_type", "unknown")),
		"source_scene": str(cause.get("source_scene", "")),
		"source_room_type": str(cause.get("source_room_type", "")),
		"source_biome_id": str(cause.get("source_biome_id", "")),
		"source_biome_name": str(cause.get("source_biome_name", "")),
		"source_layout_profile": str(cause.get("source_layout_profile", "")),
		"source_review_tip": str(cause.get("source_review_tip", "")),
		"source_threat_intel": str(cause.get("source_threat_intel", "")),
		"source_counter_tags": _string_array_from_variant(cause.get("source_counter_tags", [])),
		"amount": int(cause.get("amount", 0)),
		"location": str(cause.get("location", summary.get("run_position_text", "Unknown"))),
		"room_id": str(position.get("room_id", "")),
		"room_type": str(position.get("room_type", "unknown")),
		"biome_index": int(position.get("biome_index", summary.get("biomes_reached", 1))),
		"biome_name": str(position.get("biome_name", summary.get("reached_biome_name", "Layer 1"))),
		"dungeon_seed": int(summary.get("dungeon_seed", 0)),
		"rooms_cleared": int(summary.get("rooms_cleared", 0)),
		"kills": int(summary.get("kills", 0)),
		"elapsed_seconds": int(summary.get("elapsed_seconds", 0)),
		"text": str(cause.get("text", summary.get("defeat_cause_text", "Unknown"))),
	}


func _record_defeat_source(record: Dictionary) -> void:
	var source_id := str(record.get("source_id", "unknown")).strip_edges()
	if source_id.is_empty():
		source_id = "unknown"

	var raw_entry = _defeat_source_counts.get(source_id, {})
	var entry: Dictionary = raw_entry if raw_entry is Dictionary else {}
	entry["source_id"] = source_id
	entry["source_name"] = str(record.get("source_name", entry.get("source_name", "Unknown")))
	entry["source_type"] = str(record.get("source_type", entry.get("source_type", "unknown")))
	entry["source_scene"] = str(record.get("source_scene", entry.get("source_scene", "")))
	entry["source_room_type"] = str(record.get("source_room_type", entry.get("source_room_type", "")))
	entry["source_biome_id"] = str(record.get("source_biome_id", entry.get("source_biome_id", "")))
	entry["source_biome_name"] = str(record.get("source_biome_name", entry.get("source_biome_name", "")))
	entry["source_layout_profile"] = str(record.get("source_layout_profile", entry.get("source_layout_profile", "")))
	entry["source_review_tip"] = str(record.get("source_review_tip", entry.get("source_review_tip", "")))
	entry["source_threat_intel"] = str(record.get("source_threat_intel", entry.get("source_threat_intel", "")))
	entry["source_counter_tags"] = _string_array_from_variant(record.get("source_counter_tags", entry.get("source_counter_tags", [])))
	entry["count"] = maxi(int(entry.get("count", 0)) + 1, 1)
	entry["last_run_index"] = int(record.get("run_index", entry.get("last_run_index", 0)))
	entry["last_seed"] = int(record.get("dungeon_seed", entry.get("last_seed", 0)))
	entry["last_biome_index"] = int(record.get("biome_index", entry.get("last_biome_index", 0)))
	entry["last_room_id"] = str(record.get("room_id", entry.get("last_room_id", "")))
	entry["last_text"] = str(record.get("text", entry.get("last_text", "Unknown")))
	_defeat_source_counts[source_id] = entry


func _get_defeat_source_records() -> Array:
	var records: Array = []
	for value in _defeat_source_counts.values():
		if value is Dictionary:
			records.append((value as Dictionary).duplicate())
	records.sort_custom(_sort_defeat_source_records)
	return records


func _get_defeat_source_type_counts() -> Dictionary:
	var counts := {
		"enemy": 0,
		"boss": 0,
		"hazard": 0,
		"unknown": 0,
	}
	for value in _defeat_source_counts.values():
		if not value is Dictionary:
			continue
		var entry := value as Dictionary
		var source_type := str(entry.get("source_type", "unknown")).strip_edges().to_lower()
		if source_type.is_empty() or not counts.has(source_type):
			source_type = "unknown"
		counts[source_type] = int(counts.get(source_type, 0)) + maxi(int(entry.get("count", 0)), 0)
	return counts


func _sort_defeat_source_records(a: Dictionary, b: Dictionary) -> bool:
	var a_count := int(a.get("count", 0))
	var b_count := int(b.get("count", 0))
	if a_count != b_count:
		return a_count > b_count

	var a_run := int(a.get("last_run_index", 0))
	var b_run := int(b.get("last_run_index", 0))
	if a_run != b_run:
		return a_run > b_run

	return str(a.get("source_name", "")) < str(b.get("source_name", ""))


func unlock_character(character_id: String) -> bool:
	var character := _find_character_resource(character_id)
	if character == null:
		return false
	if _is_character_unlocked(character_id, character):
		return true

	var cost := _get_character_unlock_cost(character)
	if cost > _meta_currency:
		return false

	_meta_currency = maxi(_meta_currency - cost, 0)
	_unlocked_character_ids[character_id] = true
	_save_history()
	return true


func _build_meta_progression_summary() -> Dictionary:
	return {
		"currency_name": "Data Shards",
		"currency": _meta_currency,
		"total_currency_earned": _meta_total_currency_earned,
		"character_mastery_xp": _character_mastery_xp.duplicate(),
		"character_mastery_bonuses": _build_character_mastery_bonus_summary(),
		"unlocked_character_ids": _unlocked_character_ids.duplicate(),
		"training_drill_best_ratings": _training_drill_best_ratings.duplicate(),
		"training_badge_count": _get_training_badge_count(),
		"training_badge_total": TRAINING_DRILLS.size(),
	}


func _get_character_mastery_level(character_id: String) -> int:
	var character := _find_character_resource(character_id)
	if character == null:
		return 1
	return _get_character_mastery_level_for_data(character)


func _get_character_mastery_level_for_data(character: Resource) -> int:
	if character == null:
		return 1

	var character_id := str(character.get("id"))
	var xp := int(_character_mastery_xp.get(character_id, 0))
	var level_2 := maxi(int(character.get("mastery_level_2_xp")), 1)
	var level_3 := maxi(int(character.get("mastery_level_3_xp")), level_2 + 1)
	if xp >= level_3:
		return 3
	if xp >= level_2:
		return 2
	return 1


func _get_mastery_bonus_for_level(mastery_level: int) -> Dictionary:
	var level := clampi(mastery_level, 1, 3)
	return {
		"health_bonus": 0,
		"armor_bonus": MASTERY_LEVEL_3_ARMOR_BONUS if level >= 3 else 0,
		"energy_bonus": MASTERY_LEVEL_2_ENERGY_BONUS if level >= 2 else 0,
	}


func _get_mastery_bonus_for_character(character: Resource) -> Dictionary:
	if character == null:
		return _get_mastery_bonus_for_level(1)
	return _get_mastery_bonus_for_level(_get_character_mastery_level_for_data(character))


func _build_character_mastery_bonus_summary() -> Dictionary:
	var summary := {}
	for character in _load_content_resources(CHARACTER_RESOURCE_DIR):
		var character_id := str(character.get("id"))
		if character_id.is_empty():
			continue
		summary[character_id] = _get_mastery_bonus_for_character(character)
	return summary


func _format_mastery_bonus(bonus: Dictionary) -> String:
	var parts: PackedStringArray = []
	var health_bonus := int(bonus.get("health_bonus", 0))
	var armor_bonus := int(bonus.get("armor_bonus", 0))
	var energy_bonus := int(bonus.get("energy_bonus", 0))
	if health_bonus > 0:
		parts.append("+%d HP" % health_bonus)
	if armor_bonus > 0:
		parts.append("+%d Armor" % armor_bonus)
	if energy_bonus > 0:
		parts.append("+%d Energy" % energy_bonus)
	if parts.is_empty():
		return "None"
	return ", ".join(parts)


func _apply_current_character_mastery_bonus(refill_resources: bool) -> void:
	if player == null or not player.has_method("apply_meta_stat_bonus"):
		return

	var character := _get_current_character_data()
	if character == null:
		return

	var bonus := _get_mastery_bonus_for_character(character)
	player.call(
		"apply_meta_stat_bonus",
		int(bonus.get("health_bonus", 0)),
		int(bonus.get("armor_bonus", 0)),
		int(bonus.get("energy_bonus", 0)),
		refill_resources
	)


func _find_character_resource(character_id: String) -> Resource:
	for character in _load_content_resources(CHARACTER_RESOURCE_DIR):
		if str(character.get("id")) == character_id:
			return character
	return null


func _is_character_unlocked(character_id: String, character: Resource = null) -> bool:
	if character_id.is_empty():
		return false
	if bool(_unlocked_character_ids.get(character_id, false)):
		return true

	var character_data := character
	if character_data == null:
		character_data = _find_character_resource(character_id)
	if character_data == null:
		return false

	return str(character_data.get("unlock_condition")) == "default" or _get_character_unlock_cost(character_data) <= 0


func _get_character_unlock_cost(character: Resource) -> int:
	if character == null:
		return 0
	return maxi(int(character.get("meta_currency_unlock_cost")), 0)


func _get_player_loadout_names() -> Array[String]:
	var names: Array[String] = []
	if not is_instance_valid(player):
		return names

	for weapon_data in player.weapon_loadout:
		if weapon_data == null:
			continue
		names.append(str(weapon_data.display_name))
	return names


func _get_player_loadout_summaries() -> Array[Dictionary]:
	var summaries: Array[Dictionary] = []
	if not is_instance_valid(player):
		return summaries

	for index in range(player.weapon_loadout.size()):
		var weapon_data := player.weapon_loadout[index]
		if weapon_data == null:
			continue
		var is_active := index == player.current_weapon_index
		summaries.append({
			"id": str(weapon_data.id),
			"display_name": str(weapon_data.display_name),
			"icon_key": _resolve_content_icon_key(weapon_data, "weapon"),
			"rarity": str(weapon_data.rarity),
			"weapon_class": str(weapon_data.weapon_class),
			"recommended_range": str(weapon_data.recommended_range),
			"energy_cost": int(weapon_data.energy_cost),
			"magazine_size": int(weapon_data.magazine_size) + player.get_magazine_size_bonus(),
			"current_ammo": int(player.weapon.get_current_ammo()) if is_active and player.weapon != null else -1,
			"is_reloading": bool(player.weapon.is_reloading()) if is_active and player.weapon != null else false,
			"is_active": is_active,
		})
	return summaries


func _get_weapon_display_names_for_ids(weapon_ids: Array) -> Array[String]:
	var names: Array[String] = []
	for weapon_id_value in weapon_ids:
		var weapon_id := str(weapon_id_value)
		if weapon_id.is_empty():
			continue
		var display_name := weapon_id
		for weapon in _load_content_resources(WEAPON_RESOURCE_DIR):
			if str(weapon.get("id")) == weapon_id:
				display_name = str(weapon.get("display_name"))
				break
		names.append(display_name)
	return names


func _get_next_mastery_summary(character: Resource, mastery_xp: int, mastery_level: int) -> Dictionary:
	if character == null or mastery_level >= 3:
		return {
			"level": 0,
			"xp_required": 0,
			"xp_remaining": 0,
			"progress_start_xp": mastery_xp,
			"progress_current_xp": 0,
			"progress_required_xp": 0,
			"progress_percent": 100,
			"bonus_text": "Maxed",
		}

	var next_level := mastery_level + 1
	var xp_required := int(character.get("mastery_level_2_xp")) if next_level == 2 else int(character.get("mastery_level_3_xp"))
	xp_required = maxi(xp_required, 1)
	var progress_start_xp := 0
	if mastery_level == 2:
		progress_start_xp = maxi(int(character.get("mastery_level_2_xp")), 0)
	var progress_required_xp := maxi(xp_required - progress_start_xp, 1)
	var progress_current_xp := clampi(mastery_xp - progress_start_xp, 0, progress_required_xp)
	var bonus := _get_incremental_mastery_bonus(mastery_level, next_level)
	return {
		"level": next_level,
		"xp_required": xp_required,
		"xp_remaining": maxi(xp_required - mastery_xp, 0),
		"progress_start_xp": progress_start_xp,
		"progress_current_xp": progress_current_xp,
		"progress_required_xp": progress_required_xp,
		"progress_percent": roundi(float(progress_current_xp) / float(progress_required_xp) * 100.0),
		"bonus_text": _format_mastery_bonus(bonus),
	}


func _get_incremental_mastery_bonus(current_level: int, next_level: int) -> Dictionary:
	var current_bonus := _get_mastery_bonus_for_level(current_level)
	var next_bonus := _get_mastery_bonus_for_level(next_level)
	return {
		"health_bonus": maxi(int(next_bonus.get("health_bonus", 0)) - int(current_bonus.get("health_bonus", 0)), 0),
		"armor_bonus": maxi(int(next_bonus.get("armor_bonus", 0)) - int(current_bonus.get("armor_bonus", 0)), 0),
		"energy_bonus": maxi(int(next_bonus.get("energy_bonus", 0)) - int(current_bonus.get("energy_bonus", 0)), 0),
	}


func _build_hall_summary() -> Dictionary:
	var characters := _summarize_characters()
	var weapons := _summarize_weapons()
	var relics := _summarize_relics()
	var talents := _summarize_talents()
	var blessings := _summarize_blessings()
	var statues := _summarize_statues()
	var training_drills := _summarize_training_drills()
	var current_character := _get_current_character_data()
	return {
		"history": _history_stats.duplicate(),
		"last_defeat": _last_defeat_record.duplicate(),
		"defeat_sources": _get_defeat_source_records(),
		"defeat_source_types": _get_defeat_source_type_counts(),
		"meta_progression": _build_meta_progression_summary(),
		"current_character_id": str(current_character.get("id")) if current_character != null else "",
		"characters": characters,
		"training_drills": training_drills,
		"weapons": weapons,
		"relics": relics,
		"talents": talents,
		"blessings": blessings,
		"statues": statues,
		"counts": {
			"characters": characters.size(),
			"training_drills": training_drills.size(),
			"weapons": weapons.size(),
			"relics": relics.size(),
			"talents": talents.size(),
			"blessings": blessings.size(),
			"statues": statues.size(),
		},
	}


func _summarize_characters() -> Array:
	var entries: Array = []
	for character in _load_content_resources(CHARACTER_RESOURCE_DIR):
		var character_id := str(character.get("id"))
		var mastery_xp := int(_character_mastery_xp.get(character_id, 0))
		var mastery_level := _get_character_mastery_level_for_data(character)
		var mastery_bonus := _get_mastery_bonus_for_character(character)
		var next_mastery := _get_next_mastery_summary(character, mastery_xp, mastery_level)
		var starting_weapon_ids := _string_array_from_variant(character.get("starting_weapon_ids"))
		entries.append({
			"id": character_id,
			"display_name": str(character.get("display_name")),
			"description": str(character.get("description")),
			"icon_key": _resolve_content_icon_key(character, "character"),
			"hall_summary": str(character.get("hall_summary")),
			"role_tags": _string_array_from_variant(character.get("role_tags")),
			"unlock_condition": str(character.get("unlock_condition")),
			"unlock_cost": _get_character_unlock_cost(character),
			"unlocked": _is_character_unlocked(character_id, character),
			"starting_weapon_ids": starting_weapon_ids,
			"starting_weapon_names": _get_weapon_display_names_for_ids(starting_weapon_ids),
			"passive_id": str(character.get("passive_id")),
			"passive_description": str(character.get("passive_description")),
			"skill_name": str(character.get("skill_name")),
			"skill_description": str(character.get("skill_description")),
			"skill_cooldown": float(character.get("skill_cooldown")),
			"skill_duration": float(character.get("skill_duration")),
			"skill_energy_cost": int(character.get("skill_energy_cost")),
			"mastery_xp": mastery_xp,
			"mastery_level": mastery_level,
			"mastery_bonus": mastery_bonus,
			"mastery_bonus_text": _format_mastery_bonus(mastery_bonus),
			"next_mastery_level": int(next_mastery.get("level", 0)),
			"next_mastery_xp_required": int(next_mastery.get("xp_required", 0)),
			"next_mastery_xp_remaining": int(next_mastery.get("xp_remaining", 0)),
			"next_mastery_progress_start_xp": int(next_mastery.get("progress_start_xp", 0)),
			"next_mastery_progress_current_xp": int(next_mastery.get("progress_current_xp", 0)),
			"next_mastery_progress_required_xp": int(next_mastery.get("progress_required_xp", 0)),
			"next_mastery_progress_percent": int(next_mastery.get("progress_percent", 0)),
			"next_mastery_bonus_text": str(next_mastery.get("bonus_text", "Maxed")),
			"mastery_level_2_xp": int(character.get("mastery_level_2_xp")),
			"mastery_level_3_xp": int(character.get("mastery_level_3_xp")),
			"upgrade_slots": int(character.get("upgrade_slots")),
			"max_health": int(character.get("max_health")),
			"max_armor": int(character.get("max_armor")),
			"max_energy": int(character.get("max_energy")),
			"move_speed": float(character.get("move_speed")),
			"sort_order": int(character.get("sort_order")),
		})
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("sort_order", 0)) < int(b.get("sort_order", 0))
	)
	return entries


func _summarize_training_drills() -> Array:
	var entries: Array = []
	for drill in TRAINING_DRILLS:
		var drill_data: Dictionary = drill
		var drill_id := str(drill_data.get("id", ""))
		var best_rating_rank := _get_training_drill_best_rating_rank(drill_id)
		entries.append({
			"id": drill_id,
			"display_name": str(drill_data.get("display_name", "Training")),
			"instruction": str(drill_data.get("instruction", "")),
			"goal_text": str(drill_data.get("goal_text", "")),
			"goal_required": int(drill_data.get("goal_required", 0)),
			"best_rating_rank": best_rating_rank,
			"best_rating_text": _get_training_rating_text(best_rating_rank),
			"best_rating_token": _get_training_badge_token(best_rating_rank),
			"badge_unlocked": _get_training_rating_score(best_rating_rank) > 0,
		})
	return entries


func _summarize_weapons() -> Array:
	var entries: Array = []
	for weapon in _load_content_resources(WEAPON_RESOURCE_DIR):
		entries.append({
			"id": str(weapon.get("id")),
			"display_name": str(weapon.get("display_name")),
			"description": str(weapon.get("description")),
			"icon_key": _resolve_content_icon_key(weapon, "weapon"),
			"rarity": str(weapon.get("rarity")),
			"weapon_class": str(weapon.get("weapon_class")),
			"recommended_range": str(weapon.get("recommended_range")),
			"drop_weight": float(weapon.get("drop_weight")),
			"content_role": str(weapon.get("content_role")),
			"damage": int(weapon.get("damage")),
			"fire_rate": float(weapon.get("fire_rate")),
			"projectile_count": int(weapon.get("projectile_count")),
			"spread_angle": float(weapon.get("spread_angle")),
			"fire_mode": str(weapon.get("fire_mode")),
			"energy_cost": int(weapon.get("energy_cost")),
			"magazine_size": int(weapon.get("magazine_size")),
			"reload_duration": float(weapon.get("reload_duration")),
			"crit_chance": float(weapon.get("crit_chance")),
			"crit_multiplier": float(weapon.get("crit_multiplier")),
			"pierce_count": int(weapon.get("pierce_count")),
			"bounce_count": int(weapon.get("bounce_count")),
			"homing_turn_rate": float(weapon.get("homing_turn_rate")),
			"homing_radius": float(weapon.get("homing_radius")),
			"chain_count": int(weapon.get("chain_count")),
			"chain_radius": float(weapon.get("chain_radius")),
			"chain_damage_multiplier": float(weapon.get("chain_damage_multiplier")),
			"explosion_radius": float(weapon.get("explosion_radius")),
			"status_effect": str(weapon.get("status_effect")),
			"status_chance": float(weapon.get("status_chance")),
			"status_duration": float(weapon.get("status_duration")),
			"status_damage_per_tick": int(weapon.get("status_damage_per_tick")),
			"status_tick_interval": float(weapon.get("status_tick_interval")),
			"status_slow_multiplier": float(weapon.get("status_slow_multiplier")),
			"blocks_projectiles": bool(weapon.get("blocks_projectiles")),
			"projectile_block_radius": float(weapon.get("projectile_block_radius")),
			"projectile_block_arc_degrees": float(weapon.get("projectile_block_arc_degrees")),
			"projectile_block_damage": int(weapon.get("projectile_block_damage")),
			"charge_duration": float(weapon.get("charge_duration")),
			"charge_damage_multiplier": float(weapon.get("charge_damage_multiplier")),
			"charge_projectile_speed_multiplier": float(weapon.get("charge_projectile_speed_multiplier")),
			"charge_projectile_count_bonus": int(weapon.get("charge_projectile_count_bonus")),
			"deployable_behavior": str(weapon.get("deployable_behavior")),
			"deployable_duration": float(weapon.get("deployable_duration")),
			"deployable_radius": float(weapon.get("deployable_radius")),
			"deployable_tick_interval": float(weapon.get("deployable_tick_interval")),
			"deployable_arming_time": float(weapon.get("deployable_arming_time")),
			"deployable_damage_multiplier": float(weapon.get("deployable_damage_multiplier")),
			"tags": _string_array_from_variant(weapon.get("tags")),
		})
	return _sort_entries_by_name(entries)


func _summarize_relics() -> Array:
	var entries: Array = []
	for relic in _load_content_resources(RELIC_RESOURCE_DIR):
		entries.append({
			"id": str(relic.get("id")),
			"display_name": str(relic.get("display_name")),
			"description": str(relic.get("description")),
			"icon_key": _resolve_content_icon_key(relic, "relic"),
			"rarity": str(relic.get("rarity")),
			"trigger_event": str(relic.get("trigger_event")),
			"effect_type": str(relic.get("effect_type")),
			"effect_value": float(relic.get("effect_value")),
			"effect_duration": float(relic.get("effect_duration")),
			"drop_weight": float(relic.get("drop_weight")),
			"stackable": bool(relic.get("stackable")),
			"max_stacks": int(relic.get("max_stacks")),
			"build_tags": _string_array_from_variant(relic.get("build_tags")),
			"conflict_tags": _string_array_from_variant(relic.get("conflict_tags")),
		})
	return _sort_entries_by_name(entries)


func _summarize_talents() -> Array:
	var entries: Array = []
	for talent in _load_content_resources(TALENT_RESOURCE_DIR):
		entries.append({
			"id": str(talent.get("id")),
			"display_name": str(talent.get("display_name")),
			"description": str(talent.get("description")),
			"icon_key": _resolve_content_icon_key(talent, "talent"),
			"rarity": str(talent.get("rarity")),
			"duration_scope": str(talent.get("duration_scope")),
			"trigger_event": str(talent.get("trigger_event")),
			"effect_type": str(talent.get("effect_type")),
			"effect_value": float(talent.get("effect_value")),
			"effect_duration": float(talent.get("effect_duration")),
			"drop_weight": float(talent.get("drop_weight")),
			"build_tags": _string_array_from_variant(talent.get("build_tags")),
			"conflict_tags": _string_array_from_variant(talent.get("conflict_tags")),
		})
	return _sort_entries_by_name(entries)


func _summarize_blessings() -> Array:
	var entries: Array = []
	for blessing in _load_content_resources(BLESSING_RESOURCE_DIR):
		entries.append({
			"id": str(blessing.get("id")),
			"display_name": str(blessing.get("display_name")),
			"description": str(blessing.get("description")),
			"icon_key": _resolve_content_icon_key(blessing, "blessing"),
			"rarity": str(blessing.get("rarity")),
			"duration_scope": str(blessing.get("duration_scope")),
			"trigger_event": str(blessing.get("trigger_event")),
			"effect_type": str(blessing.get("effect_type")),
			"effect_value": float(blessing.get("effect_value")),
			"effect_duration": float(blessing.get("effect_duration")),
			"trigger_interval": maxi(int(blessing.get("trigger_interval")), 1),
			"drop_weight": float(blessing.get("drop_weight")),
			"build_tags": _string_array_from_variant(blessing.get("build_tags")),
			"conflict_tags": _string_array_from_variant(blessing.get("conflict_tags")),
			"rule_text": str(blessing.get("rule_text")),
		})
	return _sort_entries_by_name(entries)


func _summarize_statues() -> Array:
	var entries: Array = []
	for statue in _load_content_resources(STATUE_RESOURCE_DIR):
		entries.append({
			"id": str(statue.get("id")),
			"display_name": str(statue.get("display_name")),
			"description": str(statue.get("description")),
			"icon_key": _resolve_content_icon_key(statue, "statue"),
			"rarity": str(statue.get("rarity")),
			"duration_scope": str(statue.get("duration_scope")),
			"trigger_event": str(statue.get("trigger_event")),
			"effect_type": str(statue.get("effect_type")),
			"effect_value": float(statue.get("effect_value")),
			"effect_duration": float(statue.get("effect_duration")),
			"trigger_interval": maxi(int(statue.get("trigger_interval")), 1),
			"drop_weight": float(statue.get("drop_weight")),
			"build_tags": _string_array_from_variant(statue.get("build_tags")),
			"conflict_tags": _string_array_from_variant(statue.get("conflict_tags")),
			"rule_text": str(statue.get("rule_text")),
		})
	return _sort_entries_by_name(entries)


func _load_content_resources(path: String) -> Array:
	var resources: Array = []
	var dir := DirAccess.open(path)
	if dir == null:
		push_warning("Content directory missing: %s" % path)
		return resources

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var resource := load("%s/%s" % [path, file_name])
			if resource is Resource:
				resources.append(resource)
		file_name = dir.get_next()
	dir.list_dir_end()
	return resources


func _sort_entries_by_name(entries: Array) -> Array:
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get("display_name", "")) < str(b.get("display_name", ""))
	)
	return entries


func _string_array_from_variant(value) -> Array:
	var strings: Array = []
	if value is PackedStringArray:
		for item in value:
			strings.append(str(item))
	elif value is Array:
		for item in value:
			strings.append(str(item))
	elif value is String:
		for item in str(value).split(",", false):
			var token := str(item).strip_edges()
			if not token.is_empty():
				strings.append(token)
	return strings


func _format_string_array_for_config(value) -> String:
	return ",".join(PackedStringArray(_string_array_from_variant(value)))


func _resolve_content_icon_key(resource: Resource, content_prefix: String) -> String:
	if resource == null:
		return content_prefix

	var explicit_value = resource.get("icon_key")
	if explicit_value != null:
		var explicit_key := str(explicit_value).strip_edges()
		if not explicit_key.is_empty():
			return explicit_key

	var resource_id := str(resource.get("id")).strip_edges()
	if resource_id.is_empty():
		return content_prefix
	return "%s_%s" % [content_prefix, resource_id]


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
		"challenge":
			return 20
		"trap":
			return 10
		"boss":
			return 30
		"start":
			return 8
		"combat":
			return 12
	return 0


func _load_settings() -> void:
	_history_stats = _default_history_stats()
	_last_defeat_record = _default_last_defeat_record()
	_defeat_source_counts.clear()
	_reset_meta_progression()
	var config := ConfigFile.new()
	var error := config.load(SETTINGS_PATH)
	if error != OK:
		_settings_master_volume = 1.0
		_settings_sfx_volume = 1.0
		_settings_music_volume = 0.8
		_settings_fullscreen = false
		_settings_resolution_index = 0
		_settings_aim_assist_enabled = DEFAULT_AIM_ASSIST_ENABLED
		_settings_aim_assist_strength = DEFAULT_AIM_ASSIST_STRENGTH
		_settings_low_health_feedback_intensity = LOW_HEALTH_FEEDBACK.DEFAULT_FEEDBACK_INTENSITY
		_settings_screen_shake_intensity = DEFAULT_SCREEN_SHAKE_INTENSITY
		_settings_damage_flash_intensity = DEFAULT_DAMAGE_FLASH_INTENSITY
		_settings_combat_text_intensity = DEFAULT_COMBAT_TEXT_INTENSITY
		_settings_controller_aim_deadzone = CONTROLLER_LAYOUT.get_default_aim_deadzone()
		_settings_controller_input_switch_threshold = CONTROLLER_LAYOUT.get_default_input_switch_threshold()
		_settings_dungeon_seed = 0
		_settings_input_keycodes = _get_default_input_keycodes()
		_apply_controller_tuning_settings()
		return

	_settings_master_volume = clampf(float(config.get_value("audio", "master_volume", 1.0)), 0.0, 1.0)
	_settings_sfx_volume = clampf(float(config.get_value("audio", "sfx_volume", 1.0)), 0.0, 1.0)
	_settings_music_volume = clampf(float(config.get_value("audio", "music_volume", 0.8)), 0.0, 1.0)
	_settings_fullscreen = config.get_value("display", "fullscreen", false) == true
	_settings_resolution_index = _find_resolution_index(
		int(config.get_value("display", "resolution_width", AVAILABLE_RESOLUTIONS[0].x)),
		int(config.get_value("display", "resolution_height", AVAILABLE_RESOLUTIONS[0].y))
	)
	_settings_aim_assist_enabled = config.get_value("gameplay", "aim_assist_enabled", DEFAULT_AIM_ASSIST_ENABLED) == true
	_settings_aim_assist_strength = clampf(float(config.get_value("gameplay", "aim_assist_strength", DEFAULT_AIM_ASSIST_STRENGTH)), 0.0, 1.0)
	_settings_low_health_feedback_intensity = LOW_HEALTH_FEEDBACK.clamp_feedback_intensity(float(config.get_value("gameplay", "low_health_feedback_intensity", LOW_HEALTH_FEEDBACK.DEFAULT_FEEDBACK_INTENSITY)))
	_settings_screen_shake_intensity = clampf(float(config.get_value("gameplay", "screen_shake_intensity", DEFAULT_SCREEN_SHAKE_INTENSITY)), 0.0, 1.0)
	_settings_damage_flash_intensity = clampf(float(config.get_value("gameplay", "damage_flash_intensity", DEFAULT_DAMAGE_FLASH_INTENSITY)), 0.0, 1.0)
	_settings_combat_text_intensity = clampf(float(config.get_value("gameplay", "combat_text_intensity", DEFAULT_COMBAT_TEXT_INTENSITY)), 0.0, 1.0)
	_settings_controller_aim_deadzone = CONTROLLER_LAYOUT.clamp_aim_deadzone(float(config.get_value("controls", "controller_aim_deadzone", CONTROLLER_LAYOUT.get_default_aim_deadzone())))
	_settings_controller_input_switch_threshold = CONTROLLER_LAYOUT.clamp_input_switch_threshold(float(config.get_value("controls", "controller_input_switch_threshold", CONTROLLER_LAYOUT.get_default_input_switch_threshold())))
	_settings_dungeon_seed = clampi(int(config.get_value("gameplay", "dungeon_seed", 0)), 0, MAX_DUNGEON_SEED)
	_apply_controller_tuning_settings()
	_load_input_bindings_from_config(config)
	_load_history_from_config(config)
	_load_last_defeat_from_config(config)
	_load_defeat_sources_from_config(config)
	_load_meta_progression_from_config(config)


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
	config.set_value("gameplay", "aim_assist_enabled", _settings_aim_assist_enabled)
	config.set_value("gameplay", "aim_assist_strength", _settings_aim_assist_strength)
	config.set_value("gameplay", "low_health_feedback_intensity", _settings_low_health_feedback_intensity)
	config.set_value("gameplay", "screen_shake_intensity", _settings_screen_shake_intensity)
	config.set_value("gameplay", "damage_flash_intensity", _settings_damage_flash_intensity)
	config.set_value("gameplay", "combat_text_intensity", _settings_combat_text_intensity)
	config.set_value("controls", "controller_aim_deadzone", _settings_controller_aim_deadzone)
	config.set_value("controls", "controller_input_switch_threshold", _settings_controller_input_switch_threshold)
	_write_input_bindings_to_config(config)
	_write_history_to_config(config)
	_write_last_defeat_to_config(config)
	_write_defeat_sources_to_config(config)
	_write_meta_progression_to_config(config)
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
	config.set_value("gameplay", "aim_assist_enabled", _settings_aim_assist_enabled)
	config.set_value("gameplay", "aim_assist_strength", _settings_aim_assist_strength)
	config.set_value("gameplay", "low_health_feedback_intensity", _settings_low_health_feedback_intensity)
	config.set_value("gameplay", "screen_shake_intensity", _settings_screen_shake_intensity)
	config.set_value("gameplay", "damage_flash_intensity", _settings_damage_flash_intensity)
	config.set_value("gameplay", "combat_text_intensity", _settings_combat_text_intensity)
	config.set_value("controls", "controller_aim_deadzone", _settings_controller_aim_deadzone)
	config.set_value("controls", "controller_input_switch_threshold", _settings_controller_input_switch_threshold)
	_write_input_bindings_to_config(config)
	_write_history_to_config(config)
	_write_last_defeat_to_config(config)
	_write_defeat_sources_to_config(config)
	_write_meta_progression_to_config(config)
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
		"best_biome": 0,
		"best_projectiles_blocked": 0,
		"best_time_seconds": 0,
	}


func _default_last_defeat_record() -> Dictionary:
	return {
		"has_record": false,
		"run_index": 0,
		"source_id": "",
		"source_name": "",
		"source_type": "",
		"source_scene": "",
		"source_room_type": "",
		"source_biome_id": "",
		"source_biome_name": "",
		"source_layout_profile": "",
		"source_review_tip": "",
		"source_threat_intel": "",
		"source_counter_tags": [],
		"amount": 0,
		"location": "",
		"room_id": "",
		"room_type": "",
		"biome_index": 0,
		"biome_name": "",
		"dungeon_seed": 0,
		"rooms_cleared": 0,
		"kills": 0,
		"elapsed_seconds": 0,
		"text": "None",
	}


func _load_history_from_config(config: ConfigFile) -> void:
	_history_stats = _default_history_stats()
	for key in _history_stats.keys():
		_history_stats[key] = maxi(int(config.get_value("history", key, _history_stats[key])), 0)


func _write_history_to_config(config: ConfigFile) -> void:
	for key in _default_history_stats().keys():
		config.set_value("history", key, int(_history_stats.get(key, 0)))


func _load_last_defeat_from_config(config: ConfigFile) -> void:
	_last_defeat_record = _default_last_defeat_record()
	if config.get_value("last_defeat", "has_record", false) != true:
		return

	_last_defeat_record["has_record"] = true
	_last_defeat_record["run_index"] = maxi(int(config.get_value("last_defeat", "run_index", 0)), 0)
	_last_defeat_record["source_id"] = str(config.get_value("last_defeat", "source_id", ""))
	_last_defeat_record["source_name"] = str(config.get_value("last_defeat", "source_name", ""))
	_last_defeat_record["source_type"] = str(config.get_value("last_defeat", "source_type", ""))
	_last_defeat_record["source_scene"] = str(config.get_value("last_defeat", "source_scene", ""))
	_last_defeat_record["source_room_type"] = str(config.get_value("last_defeat", "source_room_type", ""))
	_last_defeat_record["source_biome_id"] = str(config.get_value("last_defeat", "source_biome_id", ""))
	_last_defeat_record["source_biome_name"] = str(config.get_value("last_defeat", "source_biome_name", ""))
	_last_defeat_record["source_layout_profile"] = str(config.get_value("last_defeat", "source_layout_profile", ""))
	_last_defeat_record["source_review_tip"] = str(config.get_value("last_defeat", "source_review_tip", ""))
	_last_defeat_record["source_threat_intel"] = str(config.get_value("last_defeat", "source_threat_intel", ""))
	_last_defeat_record["source_counter_tags"] = _string_array_from_variant(config.get_value("last_defeat", "source_counter_tags", ""))
	_last_defeat_record["amount"] = maxi(int(config.get_value("last_defeat", "amount", 0)), 0)
	_last_defeat_record["location"] = str(config.get_value("last_defeat", "location", ""))
	_last_defeat_record["room_id"] = str(config.get_value("last_defeat", "room_id", ""))
	_last_defeat_record["room_type"] = str(config.get_value("last_defeat", "room_type", ""))
	_last_defeat_record["biome_index"] = maxi(int(config.get_value("last_defeat", "biome_index", 0)), 0)
	_last_defeat_record["biome_name"] = str(config.get_value("last_defeat", "biome_name", ""))
	_last_defeat_record["dungeon_seed"] = maxi(int(config.get_value("last_defeat", "dungeon_seed", 0)), 0)
	_last_defeat_record["rooms_cleared"] = maxi(int(config.get_value("last_defeat", "rooms_cleared", 0)), 0)
	_last_defeat_record["kills"] = maxi(int(config.get_value("last_defeat", "kills", 0)), 0)
	_last_defeat_record["elapsed_seconds"] = maxi(int(config.get_value("last_defeat", "elapsed_seconds", 0)), 0)
	_last_defeat_record["text"] = str(config.get_value("last_defeat", "text", "None"))


func _write_last_defeat_to_config(config: ConfigFile) -> void:
	var defaults := _default_last_defeat_record()
	for key in defaults.keys():
		var value = _last_defeat_record.get(key, defaults[key])
		if value is bool:
			config.set_value("last_defeat", key, value)
		elif value is int:
			config.set_value("last_defeat", key, maxi(int(value), 0))
		elif value is PackedStringArray or value is Array:
			config.set_value("last_defeat", key, _format_string_array_for_config(value))
		else:
			config.set_value("last_defeat", key, str(value))


func _load_defeat_sources_from_config(config: ConfigFile) -> void:
	_defeat_source_counts.clear()
	var source_ids := str(config.get_value("defeat_sources", "source_ids", "")).split(",", false)
	for source_id_value in source_ids:
		var source_id := str(source_id_value).strip_edges()
		if source_id.is_empty():
			continue
		var entry := {
			"source_id": source_id,
			"source_name": str(config.get_value("defeat_sources", "%s_source_name" % source_id, source_id.capitalize())),
			"source_type": str(config.get_value("defeat_sources", "%s_source_type" % source_id, "unknown")),
			"source_scene": str(config.get_value("defeat_sources", "%s_source_scene" % source_id, "")),
			"source_room_type": str(config.get_value("defeat_sources", "%s_source_room_type" % source_id, "")),
			"source_biome_id": str(config.get_value("defeat_sources", "%s_source_biome_id" % source_id, "")),
			"source_biome_name": str(config.get_value("defeat_sources", "%s_source_biome_name" % source_id, "")),
			"source_layout_profile": str(config.get_value("defeat_sources", "%s_source_layout_profile" % source_id, "")),
			"source_review_tip": str(config.get_value("defeat_sources", "%s_source_review_tip" % source_id, "")),
			"source_threat_intel": str(config.get_value("defeat_sources", "%s_source_threat_intel" % source_id, "")),
			"source_counter_tags": _string_array_from_variant(config.get_value("defeat_sources", "%s_source_counter_tags" % source_id, "")),
			"count": maxi(int(config.get_value("defeat_sources", "%s_count" % source_id, 0)), 0),
			"last_run_index": maxi(int(config.get_value("defeat_sources", "%s_last_run_index" % source_id, 0)), 0),
			"last_seed": maxi(int(config.get_value("defeat_sources", "%s_last_seed" % source_id, 0)), 0),
			"last_biome_index": maxi(int(config.get_value("defeat_sources", "%s_last_biome_index" % source_id, 0)), 0),
			"last_room_id": str(config.get_value("defeat_sources", "%s_last_room_id" % source_id, "")),
			"last_text": str(config.get_value("defeat_sources", "%s_last_text" % source_id, "Unknown")),
		}
		if int(entry.get("count", 0)) > 0:
			_defeat_source_counts[source_id] = entry


func _write_defeat_sources_to_config(config: ConfigFile) -> void:
	var source_ids := PackedStringArray()
	for source_id_value in _defeat_source_counts.keys():
		var source_id := str(source_id_value).strip_edges()
		if source_id.is_empty():
			continue
		var raw_entry = _defeat_source_counts.get(source_id, {})
		if not raw_entry is Dictionary:
			continue
		var entry := raw_entry as Dictionary
		source_ids.append(source_id)
		config.set_value("defeat_sources", "%s_source_name" % source_id, str(entry.get("source_name", source_id.capitalize())))
		config.set_value("defeat_sources", "%s_source_type" % source_id, str(entry.get("source_type", "unknown")))
		config.set_value("defeat_sources", "%s_source_scene" % source_id, str(entry.get("source_scene", "")))
		config.set_value("defeat_sources", "%s_source_room_type" % source_id, str(entry.get("source_room_type", "")))
		config.set_value("defeat_sources", "%s_source_biome_id" % source_id, str(entry.get("source_biome_id", "")))
		config.set_value("defeat_sources", "%s_source_biome_name" % source_id, str(entry.get("source_biome_name", "")))
		config.set_value("defeat_sources", "%s_source_layout_profile" % source_id, str(entry.get("source_layout_profile", "")))
		config.set_value("defeat_sources", "%s_source_review_tip" % source_id, str(entry.get("source_review_tip", "")))
		config.set_value("defeat_sources", "%s_source_threat_intel" % source_id, str(entry.get("source_threat_intel", "")))
		config.set_value("defeat_sources", "%s_source_counter_tags" % source_id, _format_string_array_for_config(entry.get("source_counter_tags", [])))
		config.set_value("defeat_sources", "%s_count" % source_id, maxi(int(entry.get("count", 0)), 0))
		config.set_value("defeat_sources", "%s_last_run_index" % source_id, maxi(int(entry.get("last_run_index", 0)), 0))
		config.set_value("defeat_sources", "%s_last_seed" % source_id, maxi(int(entry.get("last_seed", 0)), 0))
		config.set_value("defeat_sources", "%s_last_biome_index" % source_id, maxi(int(entry.get("last_biome_index", 0)), 0))
		config.set_value("defeat_sources", "%s_last_room_id" % source_id, str(entry.get("last_room_id", "")))
		config.set_value("defeat_sources", "%s_last_text" % source_id, str(entry.get("last_text", "Unknown")))
	config.set_value("defeat_sources", "source_ids", ",".join(source_ids))


func _reset_meta_progression() -> void:
	_meta_currency = 0
	_meta_total_currency_earned = 0
	_character_mastery_xp.clear()
	_unlocked_character_ids.clear()
	_training_drill_best_ratings.clear()


func _load_meta_progression_from_config(config: ConfigFile) -> void:
	_reset_meta_progression()
	_meta_currency = maxi(int(config.get_value("meta", "data_shards", 0)), 0)
	_meta_total_currency_earned = maxi(int(config.get_value("meta", "total_data_shards_earned", _meta_currency)), 0)

	for character in _load_content_resources(CHARACTER_RESOURCE_DIR):
		var character_id := str(character.get("id"))
		if character_id.is_empty():
			continue
		_character_mastery_xp[character_id] = maxi(int(config.get_value("mastery", character_id, 0)), 0)
		if config.get_value("character_unlocks", character_id, false) == true:
			_unlocked_character_ids[character_id] = true

	for drill in TRAINING_DRILLS:
		var drill_data: Dictionary = drill
		var drill_id := str(drill_data.get("id", ""))
		if drill_id.is_empty():
			continue
		var rating_rank := _normalize_training_rating_rank(str(config.get_value("training", "%s_best_rating" % drill_id, "")))
		if _get_training_rating_score(rating_rank) > 0:
			_training_drill_best_ratings[drill_id] = rating_rank


func _write_meta_progression_to_config(config: ConfigFile) -> void:
	config.set_value("meta", "data_shards", _meta_currency)
	config.set_value("meta", "total_data_shards_earned", _meta_total_currency_earned)

	for character in _load_content_resources(CHARACTER_RESOURCE_DIR):
		var character_id := str(character.get("id"))
		if character_id.is_empty():
			continue
		config.set_value("mastery", character_id, int(_character_mastery_xp.get(character_id, 0)))
		config.set_value("character_unlocks", character_id, _is_character_unlocked(character_id, character))

	for drill in TRAINING_DRILLS:
		var drill_data: Dictionary = drill
		var drill_id := str(drill_data.get("id", ""))
		if drill_id.is_empty():
			continue
		config.set_value("training", "%s_best_rating" % drill_id, _get_training_drill_best_rating_rank(drill_id))


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


func _apply_gameplay_settings_to_player() -> void:
	if player != null and player.has_method("configure_aim_assist"):
		player.call("configure_aim_assist", _settings_aim_assist_enabled, _settings_aim_assist_strength)
	_apply_aim_assist_candidate_groups_for_state()
	if hud != null and hud.has_method("set_low_health_feedback_intensity"):
		hud.call("set_low_health_feedback_intensity", _settings_low_health_feedback_intensity)
	if hud != null and hud.has_method("set_damage_flash_intensity"):
		hud.call("set_damage_flash_intensity", _settings_damage_flash_intensity)
	if audio_feedback != null and audio_feedback.has_method("set_low_health_feedback_intensity"):
		audio_feedback.call("set_low_health_feedback_intensity", _settings_low_health_feedback_intensity)
	if run_state == RunState.TRAINING:
		_update_training_hud()


func _apply_controller_tuning_settings() -> void:
	CONTROLLER_LAYOUT.configure_tuning(_settings_controller_aim_deadzone, _settings_controller_input_switch_threshold)


func _apply_aim_assist_candidate_groups_for_state() -> void:
	if player == null or not player.has_method("configure_aim_assist_candidate_groups"):
		return

	var groups: Array[String] = ["enemies"]
	if run_state == RunState.TRAINING:
		groups = ["training_dummy"]
	player.call("configure_aim_assist_candidate_groups", groups)


func _apply_feedback_settings() -> void:
	if _settings_screen_shake_intensity > 0.0:
		return
	_shake_strength = 0.0
	if camera != null:
		camera.offset = Vector2.ZERO


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

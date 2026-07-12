extends Control
class_name PrototypeHUD

signal relic_choice_selected(index: int)
signal talent_choice_selected(index: int)
signal blessing_choice_selected(index: int)
signal statue_choice_selected(index: int)

const LOW_HEALTH_FEEDBACK := preload("res://scripts/core/LowHealthFeedback.gd")
const CONTENT_ICON_REGISTRY := preload("res://scripts/content/ContentIconRegistry.gd")
const CONTROLLER_LAYOUT := preload("res://scripts/input/ControllerLayout.gd")
const INPUT_HINT_KEYBOARD_MOUSE := "keyboard_mouse"
const INPUT_HINT_GAMEPAD := "gamepad"
const CONTROL_REBIND_ACTIONS := [
	{"action": "move_up", "label": "Up"},
	{"action": "move_down", "label": "Down"},
	{"action": "move_left", "label": "Left"},
	{"action": "move_right", "label": "Right"},
	{"action": "reload", "label": "Reload"},
	{"action": "skill", "label": "Skill"},
	{"action": "interact", "label": "Interact"},
	{"action": "pause", "label": "Pause"},
]
const UI_SAFE_MARGIN := 18.0
const MAIN_MENU_PANEL_SIZE := Vector2(440.0, 648.0)
const PAUSE_PANEL_SIZE := Vector2(340.0, 252.0)
const SETTINGS_PANEL_SIZE := Vector2(460.0, 660.0)
const RESULT_PANEL_SIZE := Vector2(580.0, 588.0)
const RELIC_CHOICE_PANEL_SIZE := Vector2(720.0, 356.0)
const DEBUG_MAP_PANEL_SIZE := Vector2(760.0, 560.0)
const HALL_PANEL_SIZE := Vector2(760.0, 560.0)
const RESULT_SECTION_NAMES := ["Overview", "Build", "Survival", "Combat", "Loot", "Record"]
const RESULT_COMPACT_SECTION_KEYS := ["overview", "build", "loot"]
const ENERGY_WARNING_DURATION := 0.9
const DAMAGE_FLASH_DURATION := 0.22
const LOW_HEALTH_VIGNETTE_ALPHA := 0.22
const LOW_HEALTH_VIGNETTE_CRITICAL_ALPHA := 0.32
const LOW_HEALTH_VIGNETTE_PULSE_ALPHA := 0.04
const LOW_HEALTH_VIGNETTE_PULSE_SPEED := 5.0
const LOW_HEALTH_VIGNETTE_CRITICAL_PULSE_SPEED := 8.0
const LOW_HEALTH_VIGNETTE_EDGE_SIZE := 42.0
const LOW_HEALTH_VIGNETTE_FADE_SPEED := 0.75
const ARMOR_RECOVERY_PULSE_DURATION := 0.42
const ARMOR_BREAK_PULSE_DURATION := 0.55
const SKILL_WARNING_DURATION := 0.42
const SKILL_READY_PULSE_DURATION := 0.5
const PASSIVE_TRIGGER_PULSE_DURATION := 0.48
const RULE_FEEDBACK_DURATION := 1.4
const AMMO_READY_PULSE_DURATION := 0.45
const WEAPON_READY_PULSE_DURATION := 0.45
const WEAPON_SLOT_SWITCH_PULSE_DURATION := 0.34
const WEAPON_BLOCK_PULSE_DURATION := 0.38
const WEAPON_SLOT_RELOAD_SWEEP_INTERVAL := 0.11
const WEAPON_SLOT_MAX_MAGAZINE_SEGMENTS := 12
const TRAINING_REWARD_TOAST_DURATION := 1.8
const TRAINING_REWARD_TOAST_FADE_TIME := 0.22
const HEALTH_NORMAL_COLOR := Color(0.9, 0.97, 1.0, 1.0)
const HEALTH_LOW_COLOR := Color(1.0, 0.28, 0.22, 1.0)
const ARMOR_NORMAL_COLOR := Color(0.55, 0.86, 1.0, 1.0)
const ARMOR_RECOVERY_COLOR := Color(0.5, 1.0, 0.88, 1.0)
const ARMOR_BREAK_COLOR := Color(1.0, 0.58, 0.28, 1.0)
const ENERGY_NORMAL_COLOR := Color(0.42, 0.72, 1.0, 1.0)
const ENERGY_WARNING_COLOR := Color(0.72, 0.94, 1.0, 1.0)
const SKILL_NORMAL_COLOR := Color(0.78, 1.0, 0.88, 1.0)
const SKILL_WARNING_COLOR := Color(1.0, 0.76, 0.28, 1.0)
const SKILL_READY_COLOR := Color(0.48, 1.0, 0.56, 1.0)
const PASSIVE_STATUS_BASE_COLOR := Color(0.7, 0.78, 0.88, 1.0)
const PASSIVE_STATUS_ACTIVE_COLOR := Color(1.0, 0.86, 0.36, 1.0)
const PASSIVE_STATUS_TRIGGER_COLOR := Color(1.0, 1.0, 0.58, 1.0)
const RULE_FEEDBACK_BASE_COLOR := Color(0.58, 0.64, 0.72, 1.0)
const RULE_FEEDBACK_BLESSING_COLOR := Color(1.0, 0.72, 0.28, 1.0)
const RULE_FEEDBACK_STATUE_COLOR := Color(0.62, 0.84, 1.0, 1.0)
const AMMO_NORMAL_COLOR := Color(0.82, 0.9, 1.0, 1.0)
const AMMO_READY_COLOR := Color(0.58, 1.0, 0.62, 1.0)
const WEAPON_NORMAL_COLOR := Color(0.9, 0.95, 1.0, 1.0)
const WEAPON_READY_COLOR := Color(0.62, 1.0, 0.72, 1.0)
const WEAPON_BLOCK_COLOR := Color(0.52, 0.96, 1.0, 1.0)
const WEAPON_SLOT_NAME_COLOR := Color(0.9, 0.95, 1.0, 1.0)
const WEAPON_SLOT_AMMO_COLOR := Color(0.82, 0.9, 1.0, 1.0)
const WEAPON_SLOT_READY_TEXT_COLOR := Color(0.66, 1.0, 0.76, 1.0)
const WEAPON_SLOT_BLOCK_TEXT_COLOR := Color(0.58, 0.96, 1.0, 1.0)
const WEAPON_SLOT_RELOADING_TEXT_COLOR := Color(1.0, 0.82, 0.42, 1.0)
const WEAPON_SLOT_BAR_NORMAL_COLOR := Color(0.36, 0.56, 0.78, 1.0)
const WEAPON_SLOT_BAR_READY_COLOR := Color(0.42, 1.0, 0.56, 1.0)
const WEAPON_SLOT_BAR_BLOCK_COLOR := Color(0.42, 0.9, 1.0, 1.0)
const WEAPON_SLOT_BAR_RELOADING_COLOR := Color(1.0, 0.68, 0.28, 1.0)
const WEAPON_SLOT_BAR_EMPTY_COLOR := Color(0.94, 0.38, 0.28, 1.0)
const WEAPON_SLOT_SEGMENT_FILLED_COLOR := Color(0.58, 0.86, 1.0, 1.0)
const WEAPON_SLOT_SEGMENT_READY_COLOR := Color(0.46, 1.0, 0.58, 1.0)
const WEAPON_SLOT_SEGMENT_BLOCK_COLOR := Color(0.5, 0.96, 1.0, 1.0)
const WEAPON_SLOT_SEGMENT_EMPTY_COLOR := Color(0.18, 0.25, 0.32, 1.0)
const WEAPON_SLOT_SEGMENT_RELOADING_COLOR := Color(1.0, 0.64, 0.26, 1.0)
const WEAPON_SLOT_SEGMENT_RELOAD_SWEEP_COLOR := Color(1.0, 0.92, 0.42, 1.0)
const WEAPON_SLOT_SEGMENT_WARNING_COLOR := Color(0.95, 0.34, 0.28, 1.0)
const WEAPON_SLOT_LOADOUT_ACTIVE_COLOR := Color(0.66, 1.0, 0.76, 1.0)
const WEAPON_SLOT_LOADOUT_SWITCH_COLOR := Color(1.0, 0.94, 0.42, 1.0)
const WEAPON_SLOT_LOADOUT_BLOCK_COLOR := Color(0.48, 0.96, 1.0, 1.0)
const WEAPON_SLOT_LOADOUT_INACTIVE_COLOR := Color(0.58, 0.68, 0.78, 1.0)
const WEAPON_SLOT_LOADOUT_EMPTY_COLOR := Color(0.36, 0.42, 0.5, 1.0)
const WEAPON_SLOT_LOADOUT_ENERGY_READY_COLOR := Color(0.6, 0.88, 1.0, 1.0)
const WEAPON_SLOT_LOADOUT_ENERGY_BLOCKED_COLOR := Color(1.0, 0.5, 0.32, 1.0)
const WEAPON_SLOT_LOADOUT_PANEL_BACKGROUND_COLOR := Color(0.06, 0.075, 0.1, 0.72)
const WEAPON_SLOT_LOADOUT_ACTIVE_BACKGROUND_COLOR := Color(0.1, 0.135, 0.13, 0.84)
const WEAPON_SLOT_LOADOUT_EMPTY_BACKGROUND_COLOR := Color(0.04, 0.05, 0.065, 0.62)
const WEAPON_SLOT_META_FALLBACK_COLOR := Color(0.74, 0.86, 0.96, 1.0)
const WEAPON_SLOT_ICON_FALLBACK_COLOR := Color(0.62, 0.7, 0.78, 1.0)
const WEAPON_SLOT_ENERGY_FREE_COLOR := Color(0.58, 0.86, 1.0, 1.0)
const WEAPON_SLOT_ENERGY_COST_COLOR := Color(1.0, 0.78, 0.36, 1.0)
const WEAPON_SLOT_ENERGY_WARNING_COLOR := Color(1.0, 0.96, 0.42, 1.0)
const WEAPON_SLOT_PANEL_BACKGROUND_COLOR := Color(0.075, 0.095, 0.13, 0.88)
const WEAPON_SLOT_PANEL_READY_BORDER_COLOR := Color(0.58, 1.0, 0.66, 1.0)
const WEAPON_SLOT_PANEL_SWITCH_BORDER_COLOR := Color(1.0, 0.9, 0.36, 1.0)
const WEAPON_SLOT_PANEL_BLOCK_BORDER_COLOR := Color(0.46, 0.96, 1.0, 1.0)
const WEAPON_SLOT_PANEL_RELOADING_BORDER_COLOR := Color(1.0, 0.72, 0.32, 1.0)
const WEAPON_SLOT_PANEL_EMPTY_BORDER_COLOR := Color(0.96, 0.36, 0.28, 1.0)
const WEAPON_SLOT_PANEL_FALLBACK_BORDER_COLOR := Color(0.36, 0.44, 0.54, 1.0)
const LOBBY_SCREEN_SCENE := preload("res://scenes/ui/LobbyScreen.tscn")

@onready var health_label: Label = $MarginContainer/VBoxContainer/VitalsRow/HealthLabel
@onready var shield_label: Label = $MarginContainer/VBoxContainer/VitalsRow/ShieldLabel
@onready var energy_label: Label = $MarginContainer/VBoxContainer/VitalsRow/EnergyLabel
@onready var skill_label: Label = $MarginContainer/VBoxContainer/SkillLabel
@onready var passive_status_icon_texture: TextureRect = $MarginContainer/VBoxContainer/PassiveStatusRow/PassiveStatusIconTexture
@onready var passive_status_token_label: Label = $MarginContainer/VBoxContainer/PassiveStatusRow/PassiveStatusTokenLabel
@onready var passive_status_label: Label = $MarginContainer/VBoxContainer/PassiveStatusRow/PassiveStatusLabel
@onready var rule_feedback_icon_texture: TextureRect = $MarginContainer/VBoxContainer/RuleFeedbackRow/RuleFeedbackIconTexture
@onready var rule_feedback_token_label: Label = $MarginContainer/VBoxContainer/RuleFeedbackRow/RuleFeedbackTokenLabel
@onready var rule_feedback_label: Label = $MarginContainer/VBoxContainer/RuleFeedbackRow/RuleFeedbackLabel
@onready var weapon_label: Label = $MarginContainer/VBoxContainer/WeaponLabel
@onready var ammo_label: Label = $MarginContainer/VBoxContainer/AmmoLabel
@onready var weapon_slot_panel: PanelContainer = $MarginContainer/VBoxContainer/WeaponSlotPanel
@onready var weapon_slot_rarity_strip: ColorRect = $MarginContainer/VBoxContainer/WeaponSlotPanel/MarginContainer/VBoxContainer/WeaponSlotIdentityRow/WeaponSlotRarityStrip
@onready var weapon_slot_icon_texture: TextureRect = $MarginContainer/VBoxContainer/WeaponSlotPanel/MarginContainer/VBoxContainer/WeaponSlotIdentityRow/WeaponSlotIconTexture
@onready var weapon_slot_icon_label: Label = $MarginContainer/VBoxContainer/WeaponSlotPanel/MarginContainer/VBoxContainer/WeaponSlotIdentityRow/WeaponSlotIconLabel
@onready var weapon_slot_type_symbol_label: Label = $MarginContainer/VBoxContainer/WeaponSlotPanel/MarginContainer/VBoxContainer/WeaponSlotIdentityRow/WeaponSlotTypeSymbolLabel
@onready var weapon_slot_energy_symbol_label: Label = $MarginContainer/VBoxContainer/WeaponSlotPanel/MarginContainer/VBoxContainer/WeaponSlotIdentityRow/WeaponSlotEnergySymbolLabel
@onready var weapon_slot_name_label: Label = $MarginContainer/VBoxContainer/WeaponSlotPanel/MarginContainer/VBoxContainer/WeaponSlotNameLabel
@onready var weapon_slot_meta_label: Label = $MarginContainer/VBoxContainer/WeaponSlotPanel/MarginContainer/VBoxContainer/WeaponSlotMetaLabel
@onready var weapon_slot_loadout_row: HBoxContainer = $MarginContainer/VBoxContainer/WeaponSlotPanel/MarginContainer/VBoxContainer/WeaponSlotLoadoutRow
@onready var weapon_slot_ammo_label: Label = $MarginContainer/VBoxContainer/WeaponSlotPanel/MarginContainer/VBoxContainer/WeaponSlotAmmoLabel
@onready var weapon_slot_magazine_row: HBoxContainer = $MarginContainer/VBoxContainer/WeaponSlotPanel/MarginContainer/VBoxContainer/WeaponSlotMagazineRow
@onready var weapon_slot_status_bar: ColorRect = $MarginContainer/VBoxContainer/WeaponSlotPanel/MarginContainer/VBoxContainer/WeaponSlotStatusBar
@onready var gold_label: Label = $MarginContainer/VBoxContainer/RunSummaryRow/GoldLabel
@onready var relic_label: Label = $MarginContainer/VBoxContainer/RelicLabel
@onready var enemy_label: Label = $MarginContainer/VBoxContainer/RunSummaryRow/EnemyLabel
@onready var room_state_label: Label = $MarginContainer/VBoxContainer/RoomStateLabel
@onready var boss_panel: PanelContainer = $BossPanel
@onready var boss_name_label: Label = $BossPanel/MarginContainer/VBoxContainer/BossNameLabel
@onready var boss_health_bar: ProgressBar = $BossPanel/MarginContainer/VBoxContainer/BossHealthBar
@onready var minimap_row: HBoxContainer = $MinimapPanel/MarginContainer/VBoxContainer/MinimapRow
@onready var minimap_current_label: Label = $MinimapPanel/MarginContainer/VBoxContainer/MinimapCurrentLabel
@onready var minimap_seed_label: Label = $MinimapPanel/MarginContainer/VBoxContainer/MinimapSeedLabel
@onready var input_hint_panel: PanelContainer = $InputHintPanel
@onready var input_hint_label: Label = $InputHintPanel/MarginContainer/InputHintLabel
@onready var relic_choice_panel: PanelContainer = $RelicChoicePanel
@onready var relic_choice_title: Label = $RelicChoicePanel/MarginContainer/VBoxContainer/TitleLabel
@onready var relic_choice_buttons: Array[Button] = [
	$RelicChoicePanel/MarginContainer/VBoxContainer/ChoiceA,
	$RelicChoicePanel/MarginContainer/VBoxContainer/ChoiceB,
	$RelicChoicePanel/MarginContainer/VBoxContainer/ChoiceC,
]
@onready var message_label: Label = $MessageLabel
@onready var death_label: Label = $DeathLabel
@onready var completion_label: Label = $CompletionLabel
@onready var main_menu_panel: PanelContainer = $MainMenuPanel
@onready var main_menu_vbox: VBoxContainer = $MainMenuPanel/MarginContainer/VBoxContainer
@onready var main_menu_seed_input: LineEdit = $MainMenuPanel/MarginContainer/VBoxContainer/SeedInput
@onready var main_menu_seed_status_label: Label = $MainMenuPanel/MarginContainer/VBoxContainer/SeedStatusLabel
@onready var apply_seed_button: Button = $MainMenuPanel/MarginContainer/VBoxContainer/SeedButtonRow/ApplySeedButton
@onready var random_seed_button: Button = $MainMenuPanel/MarginContainer/VBoxContainer/SeedButtonRow/RandomSeedButton
@onready var character_name_label: Label = $MainMenuPanel/MarginContainer/VBoxContainer/CharacterNameLabel
@onready var character_info_label: Label = $MainMenuPanel/MarginContainer/VBoxContainer/CharacterInfoLabel
@onready var previous_character_button: Button = $MainMenuPanel/MarginContainer/VBoxContainer/CharacterButtonRow/PreviousCharacterButton
@onready var next_character_button: Button = $MainMenuPanel/MarginContainer/VBoxContainer/CharacterButtonRow/NextCharacterButton
@onready var start_button: Button = $MainMenuPanel/MarginContainer/VBoxContainer/StartButton
@onready var main_settings_button: Button = $MainMenuPanel/MarginContainer/VBoxContainer/SettingsButton
@onready var pause_panel: PanelContainer = $PausePanel
@onready var resume_button: Button = $PausePanel/MarginContainer/VBoxContainer/ResumeButton
@onready var pause_settings_button: Button = $PausePanel/MarginContainer/VBoxContainer/SettingsButton
@onready var pause_restart_button: Button = $PausePanel/MarginContainer/VBoxContainer/RestartButton
@onready var pause_menu_button: Button = $PausePanel/MarginContainer/VBoxContainer/MainMenuButton
@onready var settings_panel: PanelContainer = $SettingsPanel
@onready var settings_vbox: VBoxContainer = $SettingsPanel/MarginContainer/VBoxContainer
@onready var settings_volume_slider: HSlider = $SettingsPanel/MarginContainer/VBoxContainer/VolumeSlider
@onready var settings_volume_value_label: Label = $SettingsPanel/MarginContainer/VBoxContainer/VolumeValueLabel
@onready var settings_sfx_volume_slider: HSlider = $SettingsPanel/MarginContainer/VBoxContainer/SfxVolumeSlider
@onready var settings_sfx_volume_value_label: Label = $SettingsPanel/MarginContainer/VBoxContainer/SfxVolumeValueLabel
@onready var settings_music_volume_slider: HSlider = $SettingsPanel/MarginContainer/VBoxContainer/MusicVolumeSlider
@onready var settings_music_volume_value_label: Label = $SettingsPanel/MarginContainer/VBoxContainer/MusicVolumeValueLabel
@onready var settings_resolution_option: OptionButton = $SettingsPanel/MarginContainer/VBoxContainer/ResolutionOption
@onready var settings_fullscreen_check: CheckButton = $SettingsPanel/MarginContainer/VBoxContainer/FullscreenCheck
@onready var settings_apply_button: Button = $SettingsPanel/MarginContainer/VBoxContainer/ApplyButton
@onready var settings_back_button: Button = $SettingsPanel/MarginContainer/VBoxContainer/BackButton
@onready var result_panel: PanelContainer = $ResultPanel
@onready var result_vbox: VBoxContainer = $ResultPanel/MarginContainer/VBoxContainer
@onready var result_title_label: Label = $ResultPanel/MarginContainer/VBoxContainer/ResultTitleLabel
@onready var result_summary_label: Label = $ResultPanel/MarginContainer/VBoxContainer/ResultSummaryLabel
@onready var result_replay_seed_button: Button = $ResultPanel/MarginContainer/VBoxContainer/ReplaySeedButton
@onready var result_restart_button: Button = $ResultPanel/MarginContainer/VBoxContainer/RestartButton
@onready var result_menu_button: Button = $ResultPanel/MarginContainer/VBoxContainer/MainMenuButton
@onready var debug_map_panel: PanelContainer = $DebugMapPanel
@onready var debug_map_text: TextEdit = $DebugMapPanel/MarginContainer/VBoxContainer/DebugMapText
@onready var debug_map_copy_button: Button = $DebugMapPanel/MarginContainer/VBoxContainer/ButtonRow/CopyButton
@onready var debug_map_close_button: Button = $DebugMapPanel/MarginContainer/VBoxContainer/ButtonRow/CloseButton

var _minimap_current_room_id := ""
var _minimap_debug_text := ""
var _minimap_structure_signature := ""
var _minimap_markers_by_room_id: Dictionary = {}
var _active_relic_choices: Array = []
var _active_choice_kind := "relic"
var relic_choice_receiver: Node
var flow_receiver: Node
var character_unlock_button: Button
var training_button: Button
var training_panel: PanelContainer
var training_drill_label: Label
var training_guide_label: Label
var training_goal_label: Label
var training_rating_label: Label
var training_badge_label: Label
var training_aim_assist_label: Label
var training_aim_assist_preset_row: HBoxContainer
var training_aim_assist_preset_buttons := {}
var training_stats_label: Label
var training_next_drill_button: Button
var training_reset_button: Button
var training_reward_panel: PanelContainer
var training_reward_title_label: Label
var training_reward_body_label: Label
var settings_aim_assist_check: CheckButton
var settings_aim_assist_slider: HSlider
var settings_aim_assist_value_label: Label
var settings_aim_assist_band_label: Label
var settings_aim_assist_preset_row: HBoxContainer
var settings_aim_assist_preset_buttons := {}
var settings_low_health_feedback_slider: HSlider
var settings_low_health_feedback_value_label: Label
var settings_screen_shake_slider: HSlider
var settings_screen_shake_value_label: Label
var settings_damage_flash_slider: HSlider
var settings_damage_flash_value_label: Label
var settings_combat_text_slider: HSlider
var settings_combat_text_value_label: Label
var settings_controller_layout_label: Label
var settings_controller_aim_deadzone_slider: HSlider
var settings_controller_aim_deadzone_value_label: Label
var settings_controller_input_switch_slider: HSlider
var settings_controller_input_switch_value_label: Label
var hall_button: Button
var hall_panel: Control
var hall_summary_label: Label
var hall_close_button: Button
var lobby_screen
var _rarity_colors := {
	"starter": Color(0.66, 1.0, 0.76, 1.0),
	"common": Color(0.86, 0.9, 0.92, 1.0),
	"rare": Color(0.36, 0.72, 1.0, 1.0),
	"epic": Color(0.82, 0.48, 1.0, 1.0),
	"legendary": Color(1.0, 0.72, 0.24, 1.0),
}
var _result_section_labels: Dictionary = {}
var _result_section_title_labels: Dictionary = {}
var result_scroll: ScrollContainer
var result_sections_grid: GridContainer
var result_detail_toggle_button: Button
var _result_details_expanded := true
var _settings_control_buttons: Dictionary = {}
var _pending_rebind_action := ""
var _pending_rebind_button: Button
var _energy_current := 0
var _energy_max := 0
var _energy_warning_required := 0
var _energy_warning_timer := 0.0
var _energy_warning_duration := ENERGY_WARNING_DURATION
var _damage_flash_overlay: ColorRect
var _damage_flash_timer := 0.0
var _damage_flash_duration := DAMAGE_FLASH_DURATION
var _damage_flash_alpha := 0.0
var _damage_flash_intensity := 1.0
var _is_low_health := false
var _low_health_ratio := 1.0
var _low_health_feedback_intensity := LOW_HEALTH_FEEDBACK.DEFAULT_FEEDBACK_INTENSITY
var _low_health_vignette_edges: Array[ColorRect] = []
var _low_health_vignette_alpha := 0.0
var _low_health_vignette_target_alpha := 0.0
var _low_health_vignette_display_alpha := 0.0
var _low_health_vignette_pulse_timer := 0.0
var _low_health_vignette_pulse_speed := LOW_HEALTH_VIGNETTE_PULSE_SPEED
var _last_shield_value := -1
var _armor_recovery_pulse_timer := 0.0
var _armor_break_pulse_timer := 0.0
var _skill_warning_timer := 0.0
var _skill_warning_duration := SKILL_WARNING_DURATION
var _skill_ready_pulse_timer := 0.0
var _skill_ready_pulse_duration := SKILL_READY_PULSE_DURATION
var _skill_ready_state_known := false
var _was_skill_ready := false
var _last_skill_name := ""
var _passive_trigger_pulse_timer := 0.0
var _passive_trigger_pulse_duration := PASSIVE_TRIGGER_PULSE_DURATION
var _passive_status_is_active := false
var _passive_status_icon_key := ""
var _passive_status_icon_texture_path := ""
var _passive_status_tooltip_cache_key := ""
var _rule_feedback_timer := 0.0
var _rule_feedback_duration := RULE_FEEDBACK_DURATION
var _rule_feedback_active_color := RULE_FEEDBACK_BASE_COLOR
var _rule_feedback_icon_key := ""
var _rule_feedback_icon_texture_path := ""
var _ammo_ready_pulse_timer := 0.0
var _ammo_ready_pulse_duration := AMMO_READY_PULSE_DURATION
var _ammo_state_known := false
var _was_reloading := false
var _weapon_ready_pulse_timer := 0.0
var _weapon_ready_pulse_duration := WEAPON_READY_PULSE_DURATION
var _weapon_slot_switch_pulse_timer := 0.0
var _weapon_slot_switch_pulse_duration := WEAPON_SLOT_SWITCH_PULSE_DURATION
var _weapon_block_pulse_timer := 0.0
var _weapon_block_pulse_duration := WEAPON_BLOCK_PULSE_DURATION
var _weapon_slot_reload_sweep_timer := 0.0
var _weapon_slot_reload_sweep_index := 0
var _weapon_slot_display_name := "Basic Pistol"
var _weapon_slot_index := 1
var _weapon_slot_total := 3
var _weapon_slot_current_ammo := 12
var _weapon_slot_magazine_size := 12
var _weapon_slot_is_reloading := false
var _weapon_slot_magazine_segments: Array[ColorRect] = []
var _weapon_slot_loadout_names: Array[String] = ["Basic Pistol", "Shotgun", "Energy Staff"]
var _weapon_slot_loadout_entries: Array[Dictionary] = [
	{"id": "basic_pistol", "display_name": "Basic Pistol", "icon_key": "weapon_basic_pistol", "rarity": "starter", "weapon_class": "sidearm", "recommended_range": "mid", "energy_cost": 0, "magazine_size": 12, "current_ammo": 12, "is_reloading": false, "is_active": true},
	{"id": "shotgun", "display_name": "Shotgun", "icon_key": "weapon_shotgun", "rarity": "common", "weapon_class": "shotgun", "recommended_range": "close", "energy_cost": 2, "magazine_size": 6, "current_ammo": -1, "is_reloading": false, "is_active": false},
	{"id": "energy_staff", "display_name": "Energy Staff", "icon_key": "weapon_energy_staff", "rarity": "common", "weapon_class": "staff", "recommended_range": "mid", "energy_cost": 3, "magazine_size": 8, "current_ammo": -1, "is_reloading": false, "is_active": false},
]
var _weapon_slot_loadout_slots: Array[Control] = []
var _weapon_slot_loadout_icons: Array = []
var _weapon_slot_loadout_labels: Array[Label] = []
var _weapon_slot_loadout_styles: Array = []
var _weapon_slot_tooltip_cache_keys: Array[String] = []
var _weapon_slot_tooltip_cache_values: Array[Dictionary] = []
var _weapon_slot_panel_style: StyleBoxFlat
var _weapon_slot_icon_key := "weapon_basic_pistol"
var _weapon_slot_icon_texture_path := ""
var _texture_cache: Dictionary = {}
var _training_reward_toast_timer := 0.0
var _last_training_reward_notice := ""
var _input_hint_device := INPUT_HINT_KEYBOARD_MOUSE


func _ready() -> void:
	_setup_damage_flash_overlay()
	_setup_low_health_vignette()
	_setup_character_unlock_button()
	_setup_training_button()
	_setup_training_panel()
	_setup_training_reward_panel()
	_setup_hall_panel()
	_setup_resolution_options()
	_setup_settings_scroll_container()
	_setup_aim_assist_controls()
	_setup_low_health_feedback_controls()
	_setup_screen_shake_controls()
	_setup_damage_flash_controls()
	_setup_combat_text_controls()
	_setup_control_rebind_buttons()
	_setup_controller_layout_panel()
	_setup_controller_tuning_controls()
	_setup_result_sections()
	_setup_weapon_slot_panel_style()
	_refresh_weapon_slot_loadout_row()
	_refresh_weapon_slot_meta_label()
	_refresh_weapon_slot_status()
	_reset_rule_feedback_label()
	_update_input_hint()
	_update_responsive_layout()
	for index in range(relic_choice_buttons.size()):
		var button := relic_choice_buttons[index]
		button.pressed.connect(_on_relic_choice_button_pressed.bind(index))
	start_button.pressed.connect(_on_start_button_pressed)
	apply_seed_button.pressed.connect(_on_apply_seed_button_pressed)
	random_seed_button.pressed.connect(_on_random_seed_button_pressed)
	previous_character_button.pressed.connect(_on_previous_character_button_pressed)
	next_character_button.pressed.connect(_on_next_character_button_pressed)
	main_settings_button.pressed.connect(_on_settings_button_pressed)
	resume_button.pressed.connect(_on_resume_button_pressed)
	pause_settings_button.pressed.connect(_on_settings_button_pressed)
	pause_restart_button.pressed.connect(_on_restart_button_pressed)
	pause_menu_button.pressed.connect(_on_main_menu_button_pressed)
	settings_volume_slider.value_changed.connect(_on_settings_volume_changed)
	settings_sfx_volume_slider.value_changed.connect(_on_settings_volume_changed)
	settings_music_volume_slider.value_changed.connect(_on_settings_volume_changed)
	settings_aim_assist_check.toggled.connect(_on_settings_aim_assist_toggled)
	settings_aim_assist_slider.value_changed.connect(_on_settings_volume_changed)
	settings_low_health_feedback_slider.value_changed.connect(_on_settings_volume_changed)
	settings_screen_shake_slider.value_changed.connect(_on_settings_volume_changed)
	settings_damage_flash_slider.value_changed.connect(_on_settings_volume_changed)
	settings_combat_text_slider.value_changed.connect(_on_settings_volume_changed)
	settings_controller_aim_deadzone_slider.value_changed.connect(_on_settings_volume_changed)
	settings_controller_input_switch_slider.value_changed.connect(_on_settings_volume_changed)
	settings_apply_button.pressed.connect(_on_settings_apply_button_pressed)
	settings_back_button.pressed.connect(_on_settings_back_button_pressed)
	result_replay_seed_button.pressed.connect(_on_replay_seed_button_pressed)
	result_restart_button.pressed.connect(_on_restart_button_pressed)
	result_menu_button.pressed.connect(_on_main_menu_button_pressed)
	debug_map_copy_button.pressed.connect(_on_debug_map_copy_button_pressed)
	debug_map_close_button.pressed.connect(_on_debug_map_close_button_pressed)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_update_responsive_layout()


func _process(delta: float) -> void:
	if _energy_warning_timer > 0.0:
		_energy_warning_timer = maxf(_energy_warning_timer - delta, 0.0)
		if _energy_warning_timer <= 0.0:
			_energy_warning_required = 0
		_refresh_energy_label()
		_refresh_weapon_slot_energy_symbol_color()
		_refresh_weapon_slot_loadout_row()

	if _damage_flash_timer > 0.0:
		_damage_flash_timer = maxf(_damage_flash_timer - delta, 0.0)
		_refresh_damage_flash_overlay()

	if _is_low_health:
		_low_health_vignette_pulse_timer += delta * _low_health_vignette_pulse_speed
		_refresh_low_health_vignette()

	if not is_equal_approx(_low_health_vignette_alpha, _low_health_vignette_target_alpha):
		_low_health_vignette_alpha = move_toward(_low_health_vignette_alpha, _low_health_vignette_target_alpha, LOW_HEALTH_VIGNETTE_FADE_SPEED * delta)
		_refresh_low_health_vignette()

	if _armor_recovery_pulse_timer > 0.0:
		_armor_recovery_pulse_timer = maxf(_armor_recovery_pulse_timer - delta, 0.0)
		_refresh_armor_recovery_pulse()
	if _armor_break_pulse_timer > 0.0:
		_armor_break_pulse_timer = maxf(_armor_break_pulse_timer - delta, 0.0)
		_refresh_armor_recovery_pulse()

	if _skill_warning_timer > 0.0:
		_skill_warning_timer = maxf(_skill_warning_timer - delta, 0.0)
		_refresh_skill_label_color()

	if _skill_ready_pulse_timer > 0.0:
		_skill_ready_pulse_timer = maxf(_skill_ready_pulse_timer - delta, 0.0)
		_refresh_skill_label_color()

	if _passive_trigger_pulse_timer > 0.0:
		_passive_trigger_pulse_timer = maxf(_passive_trigger_pulse_timer - delta, 0.0)
		_refresh_passive_status_color()

	if _rule_feedback_timer > 0.0:
		_rule_feedback_timer = maxf(_rule_feedback_timer - delta, 0.0)
		if _rule_feedback_timer <= 0.0:
			_reset_rule_feedback_label()
		else:
			_refresh_rule_feedback_color()

	if _ammo_ready_pulse_timer > 0.0:
		_ammo_ready_pulse_timer = maxf(_ammo_ready_pulse_timer - delta, 0.0)
		_refresh_ammo_label_color()

	if _weapon_ready_pulse_timer > 0.0:
		_weapon_ready_pulse_timer = maxf(_weapon_ready_pulse_timer - delta, 0.0)
		_refresh_weapon_label_color()
		_refresh_weapon_slot_loadout_row()
		_refresh_weapon_slot_status()
		_refresh_weapon_slot_icon_modulates()

	if _weapon_slot_switch_pulse_timer > 0.0:
		_weapon_slot_switch_pulse_timer = maxf(_weapon_slot_switch_pulse_timer - delta, 0.0)
		_refresh_weapon_slot_loadout_row()
		_refresh_weapon_slot_panel_style()
		_refresh_weapon_slot_icon_modulates()

	if _weapon_block_pulse_timer > 0.0:
		_weapon_block_pulse_timer = maxf(_weapon_block_pulse_timer - delta, 0.0)
		_refresh_weapon_label_color()
		_refresh_weapon_slot_loadout_row()
		_refresh_weapon_slot_status()
		_refresh_weapon_slot_panel_style()
		_refresh_weapon_slot_icon_modulates()

	if _weapon_slot_is_reloading and _weapon_slot_magazine_size > 0:
		_weapon_slot_reload_sweep_timer += delta
		while _weapon_slot_reload_sweep_timer >= WEAPON_SLOT_RELOAD_SWEEP_INTERVAL:
			_weapon_slot_reload_sweep_timer -= WEAPON_SLOT_RELOAD_SWEEP_INTERVAL
			_advance_weapon_slot_reload_sweep()
		_refresh_weapon_slot_status()

	if _training_reward_toast_timer > 0.0:
		_training_reward_toast_timer = maxf(_training_reward_toast_timer - delta, 0.0)
		_refresh_training_reward_toast()


func _input(event: InputEvent) -> void:
	_update_input_hint_device_from_event(event)


func _unhandled_input(event: InputEvent) -> void:
	if _pending_rebind_action.is_empty():
		return
	if not (event is InputEventKey):
		return

	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	var keycode := key_event.physical_keycode
	if keycode <= 0:
		keycode = key_event.keycode
	if keycode <= 0:
		return

	if is_instance_valid(flow_receiver) and flow_receiver.has_method("rebind_input_action"):
		flow_receiver.call("rebind_input_action", _pending_rebind_action, keycode)

	_pending_rebind_action = ""
	_pending_rebind_button = null
	accept_event()


func update_health(current_hp: int, max_hp: int) -> void:
	var safe_max_hp := maxi(max_hp, 1)
	var health_ratio := LOW_HEALTH_FEEDBACK.get_health_ratio(current_hp, safe_max_hp)
	_low_health_ratio = health_ratio
	var was_low_health := _is_low_health
	_is_low_health = LOW_HEALTH_FEEDBACK.is_low_health(current_hp, safe_max_hp)
	health_label.text = Localization.format("HP: %d / %d", [current_hp, max_hp])
	if _is_low_health:
		health_label.text += " | %s" % Localization.text("LOW")
		health_label.add_theme_color_override("font_color", HEALTH_LOW_COLOR)
	else:
		health_label.add_theme_color_override("font_color", HEALTH_NORMAL_COLOR)
	_update_low_health_vignette_state(was_low_health, health_ratio)


func set_low_health_feedback_intensity(value: float) -> void:
	_low_health_feedback_intensity = LOW_HEALTH_FEEDBACK.clamp_feedback_intensity(value)
	if _is_low_health:
		_low_health_vignette_target_alpha = _get_low_health_vignette_target_alpha(_low_health_ratio)
		_low_health_vignette_alpha = _low_health_vignette_target_alpha
		_low_health_vignette_pulse_speed = _get_low_health_vignette_pulse_speed(_low_health_ratio)
	else:
		_low_health_vignette_target_alpha = 0.0
		_low_health_vignette_pulse_speed = LOW_HEALTH_VIGNETTE_PULSE_SPEED
	_refresh_low_health_vignette()


func set_damage_flash_intensity(value: float) -> void:
	_damage_flash_intensity = clampf(value, 0.0, 1.0)
	if _damage_flash_intensity > 0.0:
		_refresh_damage_flash_overlay()
		return
	_damage_flash_timer = 0.0
	_damage_flash_alpha = 0.0
	_refresh_damage_flash_overlay()


func update_shield(current_shield: int, max_shield: int = -1, recharge_summary: Dictionary = {}) -> void:
	var status_text := _format_shield_recharge_status(recharge_summary)
	var previous_shield := _last_shield_value
	if max_shield > 0:
		shield_label.text = Localization.format("Armor: %d / %d", [current_shield, max_shield])
	else:
		shield_label.text = Localization.format("Armor: %d", current_shield)
	if not status_text.is_empty():
		shield_label.text += " | %s" % status_text
	if previous_shield >= 0 and current_shield > previous_shield:
		show_armor_recovery_pulse()
	elif previous_shield >= 0 and current_shield < previous_shield:
		_armor_recovery_pulse_timer = 0.0
	_last_shield_value = current_shield
	_refresh_armor_recovery_pulse()


func show_armor_recovery_pulse(duration: float = ARMOR_RECOVERY_PULSE_DURATION) -> void:
	_armor_recovery_pulse_timer = maxf(duration, 0.05)
	_refresh_armor_recovery_pulse()


func show_armor_break_pulse(duration: float = ARMOR_BREAK_PULSE_DURATION) -> void:
	_armor_break_pulse_timer = maxf(duration, 0.05)
	_armor_recovery_pulse_timer = 0.0
	_refresh_armor_recovery_pulse()


func _format_shield_recharge_status(recharge_summary: Dictionary) -> String:
	if recharge_summary.is_empty():
		return ""

	match str(recharge_summary.get("state", "")):
		"delayed":
			var delay_remaining := maxf(float(recharge_summary.get("delay_remaining", 0.0)), 0.0)
			if delay_remaining > 0.0:
				return Localization.format("Delay %.1fs", delay_remaining)
		"recovering":
			return Localization.text("Recovering")
		"stalled":
			return Localization.text("Recovery Off")

	return ""


func update_energy(current_energy: int, max_energy: int) -> void:
	_energy_current = current_energy
	_energy_max = max_energy
	_refresh_energy_label()
	_refresh_weapon_slot_energy_symbol_color()
	_refresh_weapon_slot_loadout_row()


func show_energy_warning(required_energy: int, duration: float = ENERGY_WARNING_DURATION) -> void:
	_energy_warning_required = maxi(required_energy, 0)
	_energy_warning_timer = maxf(duration, 0.0)
	_energy_warning_duration = maxf(duration, 0.05)
	_refresh_energy_label()
	_refresh_weapon_slot_energy_symbol_color()
	_refresh_weapon_slot_loadout_row()


func show_damage_flash(amount: int, duration: float = DAMAGE_FLASH_DURATION) -> void:
	if amount <= 0 or _damage_flash_intensity <= 0.0:
		return

	_damage_flash_duration = maxf(duration, 0.05)
	_damage_flash_timer = _damage_flash_duration
	_damage_flash_alpha = clampf(0.16 + float(amount) * 0.04, 0.16, 0.36) * _damage_flash_intensity
	_refresh_damage_flash_overlay()


func show_skill_warning(duration: float = SKILL_WARNING_DURATION) -> void:
	_skill_warning_duration = maxf(duration, 0.05)
	_skill_warning_timer = _skill_warning_duration
	_refresh_skill_label_color()


func show_skill_ready_pulse(duration: float = SKILL_READY_PULSE_DURATION) -> void:
	_skill_ready_pulse_duration = maxf(duration, 0.05)
	_skill_ready_pulse_timer = _skill_ready_pulse_duration
	_refresh_skill_label_color()


func show_passive_trigger_pulse(duration: float = PASSIVE_TRIGGER_PULSE_DURATION) -> void:
	_passive_trigger_pulse_duration = maxf(duration, 0.05)
	_passive_trigger_pulse_timer = _passive_trigger_pulse_duration
	_refresh_passive_status_color()


func show_rule_trigger_feedback(kind: String, display_name: String, trigger_event: String = "", icon_key: String = "", duration: float = RULE_FEEDBACK_DURATION) -> void:
	if rule_feedback_label == null:
		return

	var clean_kind := kind.strip_edges()
	if clean_kind.is_empty():
		clean_kind = "Rule"
	var clean_name := display_name.strip_edges()
	if clean_name.is_empty():
		clean_name = "Triggered"
	var icon_page := _get_rule_feedback_icon_page(clean_kind)
	var clean_icon_key := icon_key.strip_edges()
	if clean_icon_key.is_empty():
		clean_icon_key = _get_rule_feedback_fallback_icon_key(clean_kind)

	rule_feedback_label.text = "%s: %s" % [clean_kind, clean_name]
	rule_feedback_label.tooltip_text = _format_rule_feedback_tooltip(clean_kind, clean_name, trigger_event)
	_rule_feedback_icon_key = clean_icon_key
	_rule_feedback_icon_texture_path = CONTENT_ICON_REGISTRY.get_texture_path(_rule_feedback_icon_key, icon_page)
	_rule_feedback_active_color = _get_rule_feedback_color(clean_kind)
	_rule_feedback_duration = maxf(duration, 0.05)
	_rule_feedback_timer = _rule_feedback_duration
	_refresh_rule_feedback_icon(clean_kind, clean_name)
	_refresh_rule_feedback_color()


func _refresh_energy_label() -> void:
	energy_label.text = Localization.format("Energy: %d / %d", [_energy_current, _energy_max])
	if _energy_warning_timer > 0.0 and _energy_warning_required > _energy_current:
		energy_label.text += " | Need %d" % _energy_warning_required
		var progress := clampf(_energy_warning_timer / _energy_warning_duration, 0.0, 1.0)
		energy_label.add_theme_color_override("font_color", ENERGY_NORMAL_COLOR.lerp(ENERGY_WARNING_COLOR, progress))
	else:
		energy_label.add_theme_color_override("font_color", ENERGY_NORMAL_COLOR)


func _refresh_armor_recovery_pulse() -> void:
	if shield_label == null:
		return

	if _armor_break_pulse_timer > 0.0:
		var break_progress := clampf(_armor_break_pulse_timer / ARMOR_BREAK_PULSE_DURATION, 0.0, 1.0)
		shield_label.add_theme_color_override("font_color", ARMOR_NORMAL_COLOR.lerp(ARMOR_BREAK_COLOR, break_progress))
		return

	if _armor_recovery_pulse_timer <= 0.0:
		shield_label.add_theme_color_override("font_color", ARMOR_NORMAL_COLOR)
		return

	var progress := clampf(_armor_recovery_pulse_timer / ARMOR_RECOVERY_PULSE_DURATION, 0.0, 1.0)
	shield_label.add_theme_color_override("font_color", ARMOR_NORMAL_COLOR.lerp(ARMOR_RECOVERY_COLOR, progress))


func _refresh_skill_label_color() -> void:
	if skill_label == null:
		return

	if _skill_warning_timer > 0.0:
		var warning_progress := clampf(_skill_warning_timer / _skill_warning_duration, 0.0, 1.0)
		skill_label.add_theme_color_override("font_color", SKILL_NORMAL_COLOR.lerp(SKILL_WARNING_COLOR, warning_progress))
		return

	if _skill_ready_pulse_timer > 0.0:
		var ready_progress := clampf(_skill_ready_pulse_timer / _skill_ready_pulse_duration, 0.0, 1.0)
		skill_label.add_theme_color_override("font_color", SKILL_NORMAL_COLOR.lerp(SKILL_READY_COLOR, ready_progress))
		return

	skill_label.add_theme_color_override("font_color", SKILL_NORMAL_COLOR)


func _refresh_passive_status_color() -> void:
	if passive_status_label == null:
		return

	var base_color := PASSIVE_STATUS_ACTIVE_COLOR if _passive_status_is_active else PASSIVE_STATUS_BASE_COLOR
	if _passive_trigger_pulse_timer > 0.0:
		var progress := clampf(_passive_trigger_pulse_timer / _passive_trigger_pulse_duration, 0.0, 1.0)
		var pulse_color := base_color.lerp(PASSIVE_STATUS_TRIGGER_COLOR, progress)
		passive_status_label.add_theme_color_override("font_color", pulse_color)
		if passive_status_token_label != null:
			passive_status_token_label.add_theme_color_override("font_color", pulse_color)
		return

	passive_status_label.add_theme_color_override("font_color", base_color)
	if passive_status_token_label != null:
		passive_status_token_label.add_theme_color_override("font_color", base_color)


func _refresh_rule_feedback_color() -> void:
	if rule_feedback_label == null:
		return

	if _rule_feedback_timer <= 0.0:
		rule_feedback_label.add_theme_color_override("font_color", RULE_FEEDBACK_BASE_COLOR)
		if rule_feedback_token_label != null:
			rule_feedback_token_label.add_theme_color_override("font_color", RULE_FEEDBACK_BASE_COLOR)
		return

	var progress := clampf(_rule_feedback_timer / _rule_feedback_duration, 0.0, 1.0)
	var feedback_color := RULE_FEEDBACK_BASE_COLOR.lerp(_rule_feedback_active_color, progress)
	rule_feedback_label.add_theme_color_override("font_color", feedback_color)
	if rule_feedback_token_label != null:
		rule_feedback_token_label.add_theme_color_override("font_color", feedback_color)


func _reset_rule_feedback_label() -> void:
	if rule_feedback_label == null:
		return
	rule_feedback_label.text = "Rule: --"
	rule_feedback_label.tooltip_text = "Last rule trigger"
	rule_feedback_label.add_theme_color_override("font_color", RULE_FEEDBACK_BASE_COLOR)
	_rule_feedback_icon_key = ""
	_rule_feedback_icon_texture_path = ""
	if rule_feedback_icon_texture != null:
		rule_feedback_icon_texture.texture = null
		rule_feedback_icon_texture.visible = false
		rule_feedback_icon_texture.tooltip_text = "Last rule trigger"
	if rule_feedback_token_label != null:
		rule_feedback_token_label.text = "--"
		rule_feedback_token_label.tooltip_text = "Last rule trigger"
		rule_feedback_token_label.visible = true
		rule_feedback_token_label.add_theme_color_override("font_color", RULE_FEEDBACK_BASE_COLOR)


func _format_rule_feedback_tooltip(kind: String, display_name: String, trigger_event: String) -> String:
	var clean_event := trigger_event.strip_edges()
	if clean_event.is_empty():
		return "%s triggered: %s" % [kind, display_name]
	return "%s triggered: %s (%s)" % [kind, display_name, clean_event.replace("_", " ")]


func _get_rule_feedback_color(kind: String) -> Color:
	match kind.strip_edges().to_lower():
		"blessing":
			return RULE_FEEDBACK_BLESSING_COLOR
		"statue":
			return RULE_FEEDBACK_STATUE_COLOR
	return RULE_FEEDBACK_BASE_COLOR


func _refresh_rule_feedback_icon(kind: String, display_name: String) -> void:
	var icon_page := _get_rule_feedback_icon_page(kind)
	var base_tooltip := display_name
	if rule_feedback_label != null:
		base_tooltip = rule_feedback_label.tooltip_text
	var tooltip := "%s\n%s" % [
		base_tooltip,
		CONTENT_ICON_REGISTRY.get_placeholder_tooltip(_rule_feedback_icon_key, display_name, icon_page),
	]
	var texture := _load_texture_2d(_rule_feedback_icon_texture_path)
	if rule_feedback_icon_texture != null:
		rule_feedback_icon_texture.texture = texture
		rule_feedback_icon_texture.visible = texture != null
		rule_feedback_icon_texture.tooltip_text = tooltip
		rule_feedback_icon_texture.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if rule_feedback_token_label != null:
		rule_feedback_token_label.text = CONTENT_ICON_REGISTRY.get_type_token(_rule_feedback_icon_key, icon_page)
		rule_feedback_token_label.tooltip_text = tooltip
		rule_feedback_token_label.visible = texture == null


func _get_rule_feedback_icon_page(kind: String) -> String:
	match kind.strip_edges().to_lower():
		"blessing":
			return "blessings"
		"statue":
			return "statues"
	return ""


func _get_rule_feedback_fallback_icon_key(kind: String) -> String:
	match kind.strip_edges().to_lower():
		"blessing":
			return "blessing"
		"statue":
			return "statue"
	return ""


func update_skill_status(skill_name: String, cooldown_remaining: float, cooldown_duration: float, active_remaining: float) -> void:
	var is_ready := active_remaining <= 0.0 and cooldown_remaining <= 0.0 and cooldown_duration > 0.0
	var skill_changed := skill_name != _last_skill_name
	var localized_skill_name := Localization.text(skill_name)
	if active_remaining > 0.0:
		skill_label.text = Localization.format("Skill: %s Active %.1fs", [localized_skill_name, active_remaining])
	elif cooldown_remaining > 0.0:
		skill_label.text = Localization.format("Skill: %s CD %.1fs", [localized_skill_name, cooldown_remaining])
	elif cooldown_duration > 0.0:
		skill_label.text = Localization.format("Skill: %s Ready", localized_skill_name)
	else:
		skill_label.text = Localization.text("Skill: Ready")
	if skill_changed:
		_last_skill_name = skill_name
		_skill_ready_state_known = true
		_was_skill_ready = is_ready
		_skill_ready_pulse_timer = 0.0
	elif _skill_ready_state_known and is_ready and not _was_skill_ready:
		show_skill_ready_pulse()
		_was_skill_ready = is_ready
	else:
		_skill_ready_state_known = true
		_was_skill_ready = is_ready
	_refresh_skill_label_color()


func update_character_passive_status(summary: Dictionary) -> void:
	if passive_status_label == null:
		return

	var active_entry := _get_active_passive_status_entry(summary)
	if not active_entry.is_empty():
		_passive_status_is_active = true
		passive_status_label.text = Localization.format("Passive: %s %.1fs", [
			Localization.text(active_entry.get("label", "Active")),
			maxf(float(active_entry.get("remaining", 0.0)), 0.0),
		])
		passive_status_label.tooltip_text = Localization.text(str(summary.get("passive_description", "")).strip_edges())
		_refresh_passive_status_icon(summary, str(active_entry.get("label", "Active")))
		_refresh_passive_status_color()
		return

	var passive_id := str(summary.get("passive_id", "")).strip_edges()
	var passive_name := _format_passive_status_name(passive_id)
	_passive_status_is_active = false
	passive_status_label.text = Localization.format("Passive: %s", Localization.text(passive_name)) if not passive_name.is_empty() else Localization.text("Passive: None")
	passive_status_label.tooltip_text = Localization.text(str(summary.get("passive_description", "")).strip_edges())
	_refresh_passive_status_icon(summary, passive_name)
	_refresh_passive_status_color()


func _refresh_passive_status_icon(summary: Dictionary, display_name: String) -> void:
	var icon_key := str(summary.get("icon_key", "")).strip_edges()
	if icon_key.is_empty():
		var character_id := str(summary.get("character_id", "")).strip_edges()
		if not character_id.is_empty():
			icon_key = "character_%s" % character_id
	if icon_key.is_empty():
		icon_key = "character"

	if icon_key != _passive_status_icon_key:
		_passive_status_icon_key = icon_key
		_passive_status_icon_texture_path = CONTENT_ICON_REGISTRY.get_texture_path(_passive_status_icon_key, "characters")
		var texture := _load_texture_2d(_passive_status_icon_texture_path)
		if passive_status_icon_texture != null:
			passive_status_icon_texture.texture = texture
			passive_status_icon_texture.visible = texture != null
			passive_status_icon_texture.modulate = Color(1.0, 1.0, 1.0, 1.0)
		if passive_status_token_label != null:
			passive_status_token_label.text = CONTENT_ICON_REGISTRY.get_type_token(_passive_status_icon_key, "characters")
			passive_status_token_label.visible = texture == null

	var base_tooltip := display_name
	if passive_status_label != null:
		base_tooltip = passive_status_label.tooltip_text
	var tooltip_cache_key := "%s|%s|%s" % [_passive_status_icon_key, display_name, base_tooltip]
	if tooltip_cache_key == _passive_status_tooltip_cache_key:
		return
	_passive_status_tooltip_cache_key = tooltip_cache_key
	var tooltip := "%s\n%s" % [
		base_tooltip,
		CONTENT_ICON_REGISTRY.get_placeholder_tooltip(_passive_status_icon_key, display_name, "characters"),
	]
	if passive_status_icon_texture != null:
		passive_status_icon_texture.tooltip_text = tooltip
	if passive_status_token_label != null:
		passive_status_token_label.tooltip_text = tooltip


func _get_active_passive_status_entry(summary: Dictionary) -> Dictionary:
	var active_entries: Array[Dictionary] = [
		{"active": "critical_focus_active", "remaining": "critical_focus_remaining", "label": "Crit Focus"},
		{"active": "shield_break_guard_active", "remaining": "shield_break_guard_remaining", "label": "Guard Stance"},
		{"active": "energy_spend_focus_active", "remaining": "energy_spend_focus_remaining", "label": "Energy Flow"},
		{"active": "kill_burst_active", "remaining": "kill_burst_remaining", "label": "Kill Burst"},
		{"active": "room_clear_speed_active", "remaining": "speed_boost_remaining", "label": "Speed Surge"},
	]
	for entry in active_entries:
		if bool(summary.get(str(entry.get("active", "")), false)):
			return {
				"label": str(entry.get("label", "Active")),
				"remaining": float(summary.get(str(entry.get("remaining", "")), 0.0)),
			}
	return {}


func _format_passive_status_name(passive_id: String) -> String:
	match passive_id:
		"steady_hands":
			return "Steady Hands"
		"armored_core":
			return "Armored Core"
		"energy_focus":
			return "Energy Focus"
		"phase_footing":
			return "Phase Footing"
		"volatile_focus":
			return "Volatile Focus"
		"triage_kit":
			return "Triage Kit"
		_:
			return passive_id.replace("_", " ").capitalize()


func update_character_selection(display_name: String, description: String, skill_name: String, skill_description: String, index: int, total: int) -> void:
	character_name_label.text = Localization.format("Character %d/%d: %s", [index + 1, maxi(total, 1), Localization.text(display_name)])
	character_info_label.text = Localization.format("%s\nSkill: %s - %s", [Localization.text(description), Localization.text(skill_name), Localization.text(skill_description)])
	if lobby_screen != null:
		lobby_screen.call("update_character_selection", display_name, description, skill_name, skill_description, index, total)


func update_character_unlock_status(unlocked: bool, unlock_cost: int, currency: int) -> void:
	if character_unlock_button == null:
		_setup_character_unlock_button()

	if unlocked:
		character_unlock_button.text = "Unlocked"
		character_unlock_button.disabled = true
		character_unlock_button.tooltip_text = "Character available"
		start_button.disabled = false
		if training_button != null:
			training_button.disabled = false
		if lobby_screen != null:
			lobby_screen.call("update_character_unlock_status", true, unlock_cost, currency)
		return

	character_unlock_button.text = "Unlock: %d Data Shards" % maxi(unlock_cost, 0)
	character_unlock_button.disabled = currency < unlock_cost
	character_unlock_button.tooltip_text = "You have %d Data Shards" % maxi(currency, 0)
	start_button.disabled = true
	if training_button != null:
		training_button.disabled = true
	if lobby_screen != null:
		lobby_screen.call("update_character_unlock_status", false, unlock_cost, currency)


func set_weapon_name(display_name: String, slot_index: int = -1, slot_total: int = 0) -> void:
	_weapon_slot_display_name = display_name
	var previous_slot_index := _weapon_slot_index
	if slot_index > 0:
		_weapon_slot_index = slot_index
	if slot_total > 0:
		_weapon_slot_total = slot_total
	_update_weapon_slot_switch_pulse(previous_slot_index)
	weapon_label.text = Localization.format("Weapon %s: %s", [_format_weapon_slot_index(), Localization.text(display_name)])
	_weapon_ready_pulse_timer = 0.0
	_refresh_weapon_label_color()
	_refresh_weapon_slot_loadout_row()
	_refresh_weapon_slot_meta_label()
	_refresh_weapon_slot_status()


func update_weapon_loadout(loadout_entries: Array, slot_index: int = -1, slot_total: int = 0) -> void:
	var previous_slot_index := _weapon_slot_index
	_weapon_slot_loadout_names.clear()
	_weapon_slot_loadout_entries.clear()
	for loadout_entry in loadout_entries:
		var entry := _normalize_weapon_loadout_entry(loadout_entry)
		var name := str(entry.get("display_name", "")).strip_edges()
		if not name.is_empty():
			entry["display_name"] = name
			_weapon_slot_loadout_names.append(name)
			_weapon_slot_loadout_entries.append(entry)

	if slot_index > 0:
		_weapon_slot_index = slot_index
	if slot_total > 0:
		_weapon_slot_total = slot_total
	elif not _weapon_slot_loadout_names.is_empty():
		_weapon_slot_total = _weapon_slot_loadout_names.size()
	_update_weapon_slot_switch_pulse(previous_slot_index)
	_refresh_weapon_slot_loadout_row()
	_refresh_weapon_slot_meta_label()
	_refresh_weapon_slot_status()


func update_ammo(current_ammo: int, magazine_size: int, is_reloading: bool) -> void:
	var was_weapon_slot_reloading := _weapon_slot_is_reloading
	_weapon_slot_current_ammo = current_ammo
	_weapon_slot_magazine_size = magazine_size
	_weapon_slot_is_reloading = is_reloading
	_sync_active_weapon_loadout_ammo_entry(current_ammo, magazine_size, is_reloading)
	if is_reloading and not was_weapon_slot_reloading:
		_weapon_slot_reload_sweep_timer = 0.0
		_weapon_slot_reload_sweep_index = 0
	elif not is_reloading:
		_weapon_slot_reload_sweep_timer = 0.0
		_weapon_slot_reload_sweep_index = 0
	if is_reloading:
		ammo_label.text = Localization.text("Ammo: Reloading...")
	else:
		ammo_label.text = Localization.format("Ammo: %d / %d", [current_ammo, magazine_size])
	if _ammo_state_known and _was_reloading and not is_reloading and current_ammo > 0:
		show_ammo_ready_pulse()
		show_weapon_ready_pulse()
	_ammo_state_known = true
	_was_reloading = is_reloading
	_refresh_ammo_label_color()
	_refresh_active_weapon_slot_loadout_ammo()
	_refresh_weapon_slot_status()


func show_ammo_ready_pulse(duration: float = AMMO_READY_PULSE_DURATION) -> void:
	_ammo_ready_pulse_duration = maxf(duration, 0.05)
	_ammo_ready_pulse_timer = _ammo_ready_pulse_duration
	_refresh_ammo_label_color()


func show_weapon_ready_pulse(duration: float = WEAPON_READY_PULSE_DURATION) -> void:
	_weapon_ready_pulse_duration = maxf(duration, 0.05)
	_weapon_ready_pulse_timer = _weapon_ready_pulse_duration
	_refresh_weapon_label_color()
	_refresh_weapon_slot_loadout_row()
	_refresh_weapon_slot_status()
	_refresh_weapon_slot_icon_modulates()


func show_weapon_block_pulse(duration: float = WEAPON_BLOCK_PULSE_DURATION) -> void:
	_weapon_block_pulse_duration = maxf(duration, 0.05)
	_weapon_block_pulse_timer = _weapon_block_pulse_duration
	_refresh_weapon_label_color()
	_refresh_weapon_slot_loadout_row()
	_refresh_weapon_slot_status()
	_refresh_weapon_slot_panel_style()
	_refresh_weapon_slot_icon_modulates()


func _update_weapon_slot_switch_pulse(previous_slot_index: int) -> void:
	if previous_slot_index <= 0 or previous_slot_index == _weapon_slot_index:
		return
	_weapon_slot_switch_pulse_timer = _weapon_slot_switch_pulse_duration


func _refresh_ammo_label_color() -> void:
	if ammo_label == null:
		return

	if _ammo_ready_pulse_timer <= 0.0:
		ammo_label.add_theme_color_override("font_color", AMMO_NORMAL_COLOR)
		return

	var progress := clampf(_ammo_ready_pulse_timer / _ammo_ready_pulse_duration, 0.0, 1.0)
	ammo_label.add_theme_color_override("font_color", AMMO_NORMAL_COLOR.lerp(AMMO_READY_COLOR, progress))


func _refresh_weapon_label_color() -> void:
	if weapon_label == null:
		return

	if _weapon_block_pulse_timer > 0.0:
		var block_progress := clampf(_weapon_block_pulse_timer / _weapon_block_pulse_duration, 0.0, 1.0)
		weapon_label.add_theme_color_override("font_color", WEAPON_NORMAL_COLOR.lerp(WEAPON_BLOCK_COLOR, block_progress))
		return

	if _weapon_ready_pulse_timer <= 0.0:
		weapon_label.add_theme_color_override("font_color", WEAPON_NORMAL_COLOR)
		return
	var progress := clampf(_weapon_ready_pulse_timer / _weapon_ready_pulse_duration, 0.0, 1.0)
	weapon_label.add_theme_color_override("font_color", WEAPON_NORMAL_COLOR.lerp(WEAPON_READY_COLOR, progress))


func _refresh_weapon_slot_status() -> void:
	if weapon_slot_panel == null:
		return

	var block_progress := _get_weapon_block_pulse_progress()
	weapon_slot_name_label.text = "Slot %s  %s" % [_format_weapon_slot_index(), _weapon_slot_display_name]
	weapon_slot_name_label.add_theme_color_override("font_color", WEAPON_SLOT_NAME_COLOR.lerp(WEAPON_SLOT_BLOCK_TEXT_COLOR, block_progress))
	_refresh_weapon_slot_panel_style()
	_refresh_weapon_slot_icon_modulates()

	if _weapon_slot_is_reloading:
		weapon_slot_ammo_label.text = "Reloading"
		weapon_slot_ammo_label.add_theme_color_override("font_color", WEAPON_SLOT_RELOADING_TEXT_COLOR)
		weapon_slot_status_bar.color = WEAPON_SLOT_BAR_RELOADING_COLOR
		_refresh_weapon_slot_magazine_segments(0.0, "reloading")
		return

	var ammo_text := "%d / %d" % [_weapon_slot_current_ammo, maxi(_weapon_slot_magazine_size, 0)]
	if _weapon_slot_magazine_size <= 0:
		ammo_text = "%d / --" % _weapon_slot_current_ammo

	if _weapon_block_pulse_timer > 0.0:
		weapon_slot_ammo_label.text = "%s Guard" % ammo_text
		weapon_slot_ammo_label.add_theme_color_override("font_color", WEAPON_SLOT_AMMO_COLOR.lerp(WEAPON_SLOT_BLOCK_TEXT_COLOR, block_progress))
		weapon_slot_status_bar.color = WEAPON_SLOT_BAR_NORMAL_COLOR.lerp(WEAPON_SLOT_BAR_BLOCK_COLOR, block_progress)
		_refresh_weapon_slot_magazine_segments(block_progress, "block")
		return

	if _weapon_ready_pulse_timer > 0.0:
		var ready_progress := clampf(_weapon_ready_pulse_timer / _weapon_ready_pulse_duration, 0.0, 1.0)
		weapon_slot_ammo_label.text = "%s Ready" % ammo_text
		weapon_slot_ammo_label.add_theme_color_override("font_color", WEAPON_SLOT_AMMO_COLOR.lerp(WEAPON_SLOT_READY_TEXT_COLOR, ready_progress))
		weapon_slot_status_bar.color = WEAPON_SLOT_BAR_NORMAL_COLOR.lerp(WEAPON_SLOT_BAR_READY_COLOR, ready_progress)
		_refresh_weapon_slot_magazine_segments(ready_progress, "ready")
		return

	if _weapon_slot_magazine_size > 0 and _weapon_slot_current_ammo <= 0:
		weapon_slot_ammo_label.text = "%s Empty" % ammo_text
		weapon_slot_ammo_label.add_theme_color_override("font_color", WEAPON_SLOT_RELOADING_TEXT_COLOR)
		weapon_slot_status_bar.color = WEAPON_SLOT_BAR_EMPTY_COLOR
		_refresh_weapon_slot_magazine_segments(0.0, "empty")
		return

	weapon_slot_ammo_label.text = "%s Ready" % ammo_text
	weapon_slot_ammo_label.add_theme_color_override("font_color", WEAPON_SLOT_AMMO_COLOR)
	weapon_slot_status_bar.color = WEAPON_SLOT_BAR_NORMAL_COLOR
	_refresh_weapon_slot_magazine_segments()


func _refresh_weapon_slot_magazine_segments(ready_progress: float = 0.0, state: String = "normal") -> void:
	if weapon_slot_magazine_row == null:
		return

	var segment_count := 0
	if _weapon_slot_magazine_size > 0:
		segment_count = clampi(_weapon_slot_magazine_size, 1, WEAPON_SLOT_MAX_MAGAZINE_SEGMENTS)
	_set_weapon_slot_magazine_segment_count(segment_count)
	if segment_count <= 0:
		return

	var filled_segments := _calculate_weapon_slot_filled_segments(segment_count)
	for index in range(segment_count):
		var segment := _weapon_slot_magazine_segments[index]
		var is_filled := index < filled_segments
		match state:
			"reloading":
				segment.color = WEAPON_SLOT_SEGMENT_RELOAD_SWEEP_COLOR if index == _get_weapon_slot_reload_sweep_index(segment_count) else WEAPON_SLOT_SEGMENT_RELOADING_COLOR
			"ready":
				segment.color = WEAPON_SLOT_SEGMENT_FILLED_COLOR.lerp(WEAPON_SLOT_SEGMENT_READY_COLOR, ready_progress) if is_filled else WEAPON_SLOT_SEGMENT_EMPTY_COLOR
			"block":
				segment.color = WEAPON_SLOT_SEGMENT_FILLED_COLOR.lerp(WEAPON_SLOT_SEGMENT_BLOCK_COLOR, ready_progress) if is_filled else WEAPON_SLOT_SEGMENT_EMPTY_COLOR.lerp(WEAPON_SLOT_SEGMENT_BLOCK_COLOR, ready_progress * 0.24)
			"empty":
				segment.color = WEAPON_SLOT_SEGMENT_WARNING_COLOR
			_:
				segment.color = WEAPON_SLOT_SEGMENT_FILLED_COLOR if is_filled else WEAPON_SLOT_SEGMENT_EMPTY_COLOR


func _set_weapon_slot_magazine_segment_count(segment_count: int) -> void:
	while _weapon_slot_magazine_segments.size() < segment_count:
		var segment := ColorRect.new()
		segment.custom_minimum_size = Vector2(8.0, 5.0)
		segment.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		segment.color = WEAPON_SLOT_SEGMENT_EMPTY_COLOR
		weapon_slot_magazine_row.add_child(segment)
		_weapon_slot_magazine_segments.append(segment)

	while _weapon_slot_magazine_segments.size() > segment_count:
		var segment: ColorRect = _weapon_slot_magazine_segments.pop_back()
		if is_instance_valid(segment):
			segment.queue_free()


func _calculate_weapon_slot_filled_segments(segment_count: int) -> int:
	if segment_count <= 0 or _weapon_slot_magazine_size <= 0 or _weapon_slot_current_ammo <= 0:
		return 0

	var filled_ratio := clampf(float(_weapon_slot_current_ammo) / float(_weapon_slot_magazine_size), 0.0, 1.0)
	return clampi(ceili(filled_ratio * float(segment_count)), 0, segment_count)


func _advance_weapon_slot_reload_sweep() -> void:
	var segment_count := _weapon_slot_magazine_segments.size()
	if segment_count <= 0:
		_weapon_slot_reload_sweep_index = 0
		return
	_weapon_slot_reload_sweep_index = (_weapon_slot_reload_sweep_index + 1) % segment_count


func _get_weapon_slot_reload_sweep_index(segment_count: int = -1) -> int:
	var resolved_segment_count := segment_count
	if resolved_segment_count < 0:
		resolved_segment_count = _weapon_slot_magazine_segments.size()
	if not _weapon_slot_is_reloading or resolved_segment_count <= 0:
		return -1
	return clampi(_weapon_slot_reload_sweep_index, 0, resolved_segment_count - 1)


func _refresh_weapon_slot_loadout_row() -> void:
	if weapon_slot_loadout_row == null:
		return

	var slot_count := maxi(_weapon_slot_total, _weapon_slot_loadout_names.size())
	_set_weapon_slot_loadout_label_count(slot_count)
	for index in range(slot_count):
		var label := _weapon_slot_loadout_labels[index]
		var icon_texture := _weapon_slot_loadout_icons[index] as TextureRect
		var slot_control := _weapon_slot_loadout_slots[index]
		var slot_style := _weapon_slot_loadout_styles[index] as StyleBoxFlat
		var is_active := index + 1 == _weapon_slot_index
		var has_weapon := index < _weapon_slot_loadout_names.size()
		var entry := _weapon_slot_loadout_entries[index] if index < _weapon_slot_loadout_entries.size() else {}
		var tooltip := _format_weapon_loadout_tooltip(index, has_weapon)
		label.text = _format_weapon_loadout_label(index, has_weapon)
		label.tooltip_text = tooltip
		slot_control.tooltip_text = tooltip
		_refresh_weapon_slot_loadout_slot_style(slot_style, index, has_weapon, is_active)
		_refresh_weapon_slot_loadout_icon(icon_texture, entry, has_weapon, is_active, tooltip)
		if not has_weapon:
			label.add_theme_color_override("font_color", WEAPON_SLOT_LOADOUT_EMPTY_COLOR)
		elif is_active:
			var active_color := _get_weapon_loadout_color(index, true)
			if _weapon_block_pulse_timer > 0.0:
				var block_progress := _get_weapon_block_pulse_progress()
				active_color = active_color.lerp(WEAPON_SLOT_LOADOUT_BLOCK_COLOR, block_progress)
			elif _weapon_slot_switch_pulse_timer > 0.0:
				var switch_progress := clampf(_weapon_slot_switch_pulse_timer / _weapon_slot_switch_pulse_duration, 0.0, 1.0)
				active_color = active_color.lerp(WEAPON_SLOT_LOADOUT_SWITCH_COLOR, switch_progress)
			label.add_theme_color_override("font_color", active_color)
		else:
			label.add_theme_color_override("font_color", _get_weapon_loadout_color(index, false))


func _refresh_active_weapon_slot_loadout_ammo() -> void:
	var active_index := _weapon_slot_index - 1
	if active_index < 0 or active_index >= _weapon_slot_loadout_labels.size():
		return
	if active_index >= _weapon_slot_loadout_names.size():
		return

	var label := _weapon_slot_loadout_labels[active_index]
	var slot_control := _weapon_slot_loadout_slots[active_index] if active_index < _weapon_slot_loadout_slots.size() else null
	var icon_texture := _weapon_slot_loadout_icons[active_index] as TextureRect if active_index < _weapon_slot_loadout_icons.size() else null
	var tooltip := _format_weapon_loadout_tooltip(active_index, true)
	label.text = _format_weapon_loadout_label(active_index, true)
	label.tooltip_text = tooltip
	if slot_control != null:
		slot_control.tooltip_text = tooltip
	if icon_texture != null:
		icon_texture.tooltip_text = tooltip


func _sync_active_weapon_loadout_ammo_entry(current_ammo: int, magazine_size: int, is_reloading: bool) -> void:
	var active_index := _weapon_slot_index - 1
	if active_index < 0 or active_index >= _weapon_slot_loadout_entries.size():
		return
	_weapon_slot_loadout_entries[active_index]["current_ammo"] = current_ammo
	_weapon_slot_loadout_entries[active_index]["magazine_size"] = magazine_size
	_weapon_slot_loadout_entries[active_index]["is_reloading"] = is_reloading
	_weapon_slot_loadout_entries[active_index]["is_active"] = true


func _refresh_weapon_slot_meta_label() -> void:
	if weapon_slot_meta_label == null:
		return

	var entry := _get_active_weapon_loadout_entry()
	if entry.is_empty():
		weapon_slot_meta_label.text = "Unknown Weapon | E0"
		weapon_slot_meta_label.add_theme_color_override("font_color", WEAPON_SLOT_META_FALLBACK_COLOR)
		weapon_slot_meta_label.tooltip_text = "No weapon metadata available"
		_refresh_weapon_slot_identity_visuals({})
		return

	weapon_slot_meta_label.text = "%s %s | %s | E%d" % [
		_format_label_token(entry.get("rarity", "")),
		_format_label_token(entry.get("weapon_class", "")),
		_format_label_token(entry.get("recommended_range", "")),
		maxi(int(entry.get("energy_cost", 0)), 0),
	]
	weapon_slot_meta_label.add_theme_color_override("font_color", _get_weapon_loadout_color(_weapon_slot_index - 1, true))
	weapon_slot_meta_label.tooltip_text = _format_weapon_loadout_tooltip(_weapon_slot_index - 1, true)
	_refresh_weapon_slot_identity_visuals(entry)


func _refresh_weapon_slot_identity_visuals(entry: Dictionary) -> void:
	if weapon_slot_rarity_strip == null or weapon_slot_icon_label == null or weapon_slot_type_symbol_label == null or weapon_slot_energy_symbol_label == null:
		return

	if entry.is_empty():
		_weapon_slot_icon_key = ""
		_weapon_slot_icon_texture_path = ""
		weapon_slot_rarity_strip.color = WEAPON_SLOT_LOADOUT_EMPTY_COLOR
		_update_weapon_slot_icon_texture(null, "No weapon metadata available")
		weapon_slot_icon_label.text = "--"
		weapon_slot_icon_label.visible = true
		weapon_slot_type_symbol_label.text = "Unknown"
		weapon_slot_energy_symbol_label.text = "E0"
		weapon_slot_icon_label.add_theme_color_override("font_color", WEAPON_SLOT_ICON_FALLBACK_COLOR)
		weapon_slot_type_symbol_label.add_theme_color_override("font_color", WEAPON_SLOT_META_FALLBACK_COLOR)
		_refresh_weapon_slot_energy_symbol_color(0)
		_refresh_weapon_slot_panel_style()
		return

	var rarity := str(entry.get("rarity", "")).strip_edges()
	var weapon_class := str(entry.get("weapon_class", "")).strip_edges()
	var energy_cost := maxi(int(entry.get("energy_cost", 0)), 0)
	var rarity_color: Color = _rarity_colors.get(rarity, WEAPON_SLOT_META_FALLBACK_COLOR)
	var tooltip := "%s | %s %s | %s range | Energy %d" % [
		str(entry.get("display_name", _weapon_slot_display_name)),
		_format_label_token(rarity),
		_format_label_token(weapon_class),
		_format_label_token(entry.get("recommended_range", "")),
		energy_cost,
	]

	weapon_slot_rarity_strip.color = rarity_color
	_weapon_slot_icon_key = _resolve_weapon_slot_icon_key(entry)
	_weapon_slot_icon_texture_path = CONTENT_ICON_REGISTRY.get_texture_path(_weapon_slot_icon_key, "weapons")
	var icon_tooltip := "%s\n%s" % [
		tooltip,
		CONTENT_ICON_REGISTRY.get_placeholder_tooltip(_weapon_slot_icon_key, str(entry.get("display_name", _weapon_slot_display_name)), "weapons"),
	]
	_update_weapon_slot_icon_texture(_load_texture_2d(_weapon_slot_icon_texture_path), icon_tooltip)
	_refresh_weapon_slot_icon_modulates()
	var has_loaded_weapon_icon := weapon_slot_icon_texture != null and weapon_slot_icon_texture.texture != null
	weapon_slot_icon_label.text = _format_weapon_class_symbol(weapon_class)
	weapon_slot_icon_label.visible = not has_loaded_weapon_icon
	weapon_slot_type_symbol_label.text = _format_label_token(weapon_class)
	weapon_slot_energy_symbol_label.text = "E%d" % energy_cost
	weapon_slot_icon_label.add_theme_color_override("font_color", rarity_color)
	weapon_slot_type_symbol_label.add_theme_color_override("font_color", WEAPON_SLOT_AMMO_COLOR)
	_refresh_weapon_slot_energy_symbol_color(energy_cost)
	weapon_slot_rarity_strip.tooltip_text = tooltip
	weapon_slot_icon_label.tooltip_text = icon_tooltip
	weapon_slot_type_symbol_label.tooltip_text = tooltip
	weapon_slot_energy_symbol_label.tooltip_text = tooltip
	_refresh_weapon_slot_panel_style()


func _update_weapon_slot_icon_texture(texture: Texture2D, tooltip: String) -> void:
	if weapon_slot_icon_texture == null:
		return
	weapon_slot_icon_texture.texture = texture
	weapon_slot_icon_texture.visible = texture != null
	weapon_slot_icon_texture.tooltip_text = tooltip
	weapon_slot_icon_texture.modulate = _get_weapon_slot_icon_modulate(true)


func _load_texture_2d(texture_path: String) -> Texture2D:
	var normalized_path := texture_path.strip_edges()
	if normalized_path.is_empty():
		return null
	if _texture_cache.has(normalized_path):
		return _texture_cache[normalized_path] as Texture2D
	var loaded_resource := load(normalized_path)
	if loaded_resource is Texture2D:
		_texture_cache[normalized_path] = loaded_resource
		return loaded_resource
	return null


func _resolve_weapon_slot_icon_key(entry: Dictionary) -> String:
	var explicit_key := str(entry.get("icon_key", "")).strip_edges()
	if not explicit_key.is_empty():
		return explicit_key

	var weapon_id := str(entry.get("id", "")).strip_edges()
	if not weapon_id.is_empty():
		return "weapon_%s" % weapon_id
	return "weapon"


func _refresh_weapon_slot_energy_symbol_color(energy_cost: int = -1) -> void:
	if weapon_slot_energy_symbol_label == null:
		return

	var resolved_energy_cost := energy_cost
	if resolved_energy_cost < 0:
		var entry := _get_active_weapon_loadout_entry()
		resolved_energy_cost = maxi(int(entry.get("energy_cost", 0)), 0) if not entry.is_empty() else 0

	var base_color := WEAPON_SLOT_ENERGY_COST_COLOR if resolved_energy_cost > 0 else WEAPON_SLOT_ENERGY_FREE_COLOR
	if _energy_warning_timer > 0.0 and _energy_warning_required > _energy_current and resolved_energy_cost > 0:
		var progress := clampf(_energy_warning_timer / _energy_warning_duration, 0.0, 1.0)
		weapon_slot_energy_symbol_label.add_theme_color_override("font_color", base_color.lerp(WEAPON_SLOT_ENERGY_WARNING_COLOR, progress))
		return

	weapon_slot_energy_symbol_label.add_theme_color_override("font_color", base_color)


func _setup_weapon_slot_panel_style() -> void:
	if weapon_slot_panel == null:
		return
	if _weapon_slot_panel_style == null:
		_weapon_slot_panel_style = StyleBoxFlat.new()
		_weapon_slot_panel_style.bg_color = WEAPON_SLOT_PANEL_BACKGROUND_COLOR
		_weapon_slot_panel_style.border_width_left = 2
		_weapon_slot_panel_style.border_width_top = 2
		_weapon_slot_panel_style.border_width_right = 2
		_weapon_slot_panel_style.border_width_bottom = 2
		_weapon_slot_panel_style.corner_radius_top_left = 4
		_weapon_slot_panel_style.corner_radius_top_right = 4
		_weapon_slot_panel_style.corner_radius_bottom_left = 4
		_weapon_slot_panel_style.corner_radius_bottom_right = 4
	weapon_slot_panel.add_theme_stylebox_override("panel", _weapon_slot_panel_style)
	_refresh_weapon_slot_panel_style()


func _refresh_weapon_slot_panel_style() -> void:
	if weapon_slot_panel == null:
		return
	if _weapon_slot_panel_style == null:
		_setup_weapon_slot_panel_style()
		return

	var entry := _get_active_weapon_loadout_entry()
	var rarity := str(entry.get("rarity", "")).strip_edges()
	var border_color: Color = _rarity_colors.get(rarity, WEAPON_SLOT_PANEL_FALLBACK_BORDER_COLOR)
	if _weapon_block_pulse_timer > 0.0:
		var block_progress := _get_weapon_block_pulse_progress()
		border_color = border_color.lerp(WEAPON_SLOT_PANEL_BLOCK_BORDER_COLOR, block_progress)
	elif _weapon_slot_is_reloading:
		border_color = border_color.lerp(WEAPON_SLOT_PANEL_RELOADING_BORDER_COLOR, 0.62)
	elif _weapon_slot_magazine_size > 0 and _weapon_slot_current_ammo <= 0:
		border_color = border_color.lerp(WEAPON_SLOT_PANEL_EMPTY_BORDER_COLOR, 0.62)
	elif _weapon_ready_pulse_timer > 0.0:
		var ready_progress := clampf(_weapon_ready_pulse_timer / _weapon_ready_pulse_duration, 0.0, 1.0)
		border_color = border_color.lerp(WEAPON_SLOT_PANEL_READY_BORDER_COLOR, ready_progress)
	elif _weapon_slot_switch_pulse_timer > 0.0:
		var switch_progress := clampf(_weapon_slot_switch_pulse_timer / _weapon_slot_switch_pulse_duration, 0.0, 1.0)
		border_color = border_color.lerp(WEAPON_SLOT_PANEL_SWITCH_BORDER_COLOR, switch_progress)

	var active_border_width := 3 if _weapon_slot_total > 1 else 2
	_weapon_slot_panel_style.bg_color = WEAPON_SLOT_PANEL_BACKGROUND_COLOR
	_weapon_slot_panel_style.border_color = border_color
	_weapon_slot_panel_style.border_width_left = active_border_width
	_weapon_slot_panel_style.border_width_top = active_border_width
	_weapon_slot_panel_style.border_width_right = active_border_width
	_weapon_slot_panel_style.border_width_bottom = active_border_width


func _set_weapon_slot_loadout_label_count(slot_count: int) -> void:
	_cache_weapon_slot_loadout_controls()
	while _weapon_slot_loadout_labels.size() < slot_count:
		var slot := _create_weapon_slot_loadout_control(_weapon_slot_loadout_labels.size())
		var icon := _get_weapon_slot_loadout_icon(slot)
		var label := _get_weapon_slot_loadout_label(slot)
		weapon_slot_loadout_row.add_child(slot)
		_weapon_slot_loadout_slots.append(slot)
		_weapon_slot_loadout_icons.append(icon)
		_weapon_slot_loadout_labels.append(label)
		_weapon_slot_loadout_styles.append(_ensure_weapon_slot_loadout_style(slot))

	while _weapon_slot_loadout_labels.size() > slot_count:
		_weapon_slot_loadout_labels.pop_back()
		_weapon_slot_loadout_icons.pop_back()
		_weapon_slot_loadout_styles.pop_back()
		var slot: Control = _weapon_slot_loadout_slots.pop_back()
		if is_instance_valid(slot):
			slot.queue_free()


func _cache_weapon_slot_loadout_controls() -> void:
	if not _weapon_slot_loadout_labels.is_empty() or weapon_slot_loadout_row == null:
		return

	for child in weapon_slot_loadout_row.get_children():
		var slot_control := child as Control
		if slot_control == null:
			continue
		var icon_texture := _get_weapon_slot_loadout_icon(slot_control)
		var label := _get_weapon_slot_loadout_label(slot_control)
		if label == null and child is Label:
			label = child as Label
		if label == null:
			continue
		_weapon_slot_loadout_slots.append(slot_control)
		_weapon_slot_loadout_icons.append(icon_texture)
		_weapon_slot_loadout_labels.append(label)
		_weapon_slot_loadout_styles.append(_ensure_weapon_slot_loadout_style(slot_control))


func _create_weapon_slot_loadout_control(index: int) -> PanelContainer:
	var slot := PanelContainer.new()
	slot.name = "LoadoutSlot%d" % [index + 1]
	slot.custom_minimum_size = Vector2(0.0, 22.0)
	slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var margin := MarginContainer.new()
	margin.name = "LoadoutSlotMargin"
	margin.add_theme_constant_override("margin_left", 2)
	margin.add_theme_constant_override("margin_top", 1)
	margin.add_theme_constant_override("margin_right", 2)
	margin.add_theme_constant_override("margin_bottom", 1)
	slot.add_child(margin)

	var content := HBoxContainer.new()
	content.name = "LoadoutSlotContent"
	content.add_theme_constant_override("separation", 2)
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(content)

	var icon := TextureRect.new()
	icon.name = "LoadoutSlotIcon"
	icon.custom_minimum_size = Vector2(18.0, 18.0)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	content.add_child(icon)

	var label := Label.new()
	label.name = "LoadoutSlotLabel"
	label.visible = false
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.clip_text = true
	label.add_theme_font_size_override("font_size", 10)
	content.add_child(label)
	return slot


func _get_weapon_slot_loadout_icon(slot_control: Control) -> TextureRect:
	if slot_control == null:
		return null
	var icon := slot_control.get_node_or_null("LoadoutSlotMargin/LoadoutSlotContent/LoadoutSlotIcon") as TextureRect
	if icon == null:
		icon = slot_control.get_node_or_null("LoadoutSlotIcon") as TextureRect
	return icon


func _get_weapon_slot_loadout_label(slot_control: Control) -> Label:
	if slot_control == null:
		return null
	var label := slot_control.get_node_or_null("LoadoutSlotMargin/LoadoutSlotContent/LoadoutSlotLabel") as Label
	if label == null:
		label = slot_control.get_node_or_null("LoadoutSlotLabel") as Label
	return label


func _ensure_weapon_slot_loadout_style(slot_control: Control) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = WEAPON_SLOT_LOADOUT_PANEL_BACKGROUND_COLOR
	style.border_color = WEAPON_SLOT_LOADOUT_INACTIVE_COLOR
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	if slot_control is PanelContainer:
		(slot_control as PanelContainer).add_theme_stylebox_override("panel", style)
	return style


func _refresh_weapon_slot_loadout_slot_style(style: StyleBoxFlat, index: int, has_weapon: bool, is_active: bool) -> void:
	if style == null:
		return

	var border_color := WEAPON_SLOT_LOADOUT_EMPTY_COLOR
	var bg_color := WEAPON_SLOT_LOADOUT_EMPTY_BACKGROUND_COLOR
	var border_width := 1
	if has_weapon:
		border_color = _get_weapon_loadout_color(index, is_active)
		bg_color = WEAPON_SLOT_LOADOUT_ACTIVE_BACKGROUND_COLOR if is_active else WEAPON_SLOT_LOADOUT_PANEL_BACKGROUND_COLOR
		if _get_weapon_loadout_energy_state(index, has_weapon) == "blocked":
			bg_color = bg_color.lerp(WEAPON_SLOT_LOADOUT_ENERGY_BLOCKED_COLOR, 0.16)
		if is_active:
			border_width = 2
			if _weapon_block_pulse_timer > 0.0:
				var block_progress := _get_weapon_block_pulse_progress()
				border_color = border_color.lerp(WEAPON_SLOT_PANEL_BLOCK_BORDER_COLOR, block_progress)
				bg_color = bg_color.lerp(WEAPON_SLOT_PANEL_BLOCK_BORDER_COLOR, block_progress * 0.3)
			elif _weapon_ready_pulse_timer > 0.0:
				var ready_progress := clampf(_weapon_ready_pulse_timer / _weapon_ready_pulse_duration, 0.0, 1.0)
				border_color = border_color.lerp(WEAPON_SLOT_PANEL_READY_BORDER_COLOR, ready_progress)
				bg_color = bg_color.lerp(WEAPON_SLOT_PANEL_READY_BORDER_COLOR, ready_progress * 0.28)
			elif _weapon_slot_switch_pulse_timer > 0.0:
				var switch_progress := clampf(_weapon_slot_switch_pulse_timer / _weapon_slot_switch_pulse_duration, 0.0, 1.0)
				border_color = border_color.lerp(WEAPON_SLOT_PANEL_SWITCH_BORDER_COLOR, switch_progress)
				bg_color = bg_color.lerp(WEAPON_SLOT_PANEL_SWITCH_BORDER_COLOR, switch_progress * 0.24)

	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width


func _refresh_weapon_slot_loadout_icon(icon_texture: TextureRect, entry: Dictionary, has_weapon: bool, is_active: bool, tooltip: String) -> void:
	if icon_texture == null:
		return
	icon_texture.tooltip_text = tooltip
	if not has_weapon or entry.is_empty():
		icon_texture.texture = null
		icon_texture.visible = false
		return

	var icon_key := _resolve_weapon_slot_icon_key(entry)
	var texture_path := CONTENT_ICON_REGISTRY.get_texture_path(icon_key, "weapons")
	icon_texture.texture = _load_texture_2d(texture_path)
	icon_texture.visible = icon_texture.texture != null
	icon_texture.modulate = _get_weapon_slot_icon_modulate(is_active)


func _refresh_weapon_slot_icon_modulates() -> void:
	if weapon_slot_icon_texture != null:
		weapon_slot_icon_texture.modulate = _get_weapon_slot_icon_modulate(true)

	for index in range(_weapon_slot_loadout_icons.size()):
		var icon_texture := _weapon_slot_loadout_icons[index] as TextureRect
		if icon_texture == null:
			continue
		var is_active := index + 1 == _weapon_slot_index
		icon_texture.modulate = _get_weapon_slot_icon_modulate(is_active)


func _get_weapon_slot_icon_modulate(is_active: bool) -> Color:
	var icon_alpha := 1.0 if is_active else 0.72
	var modulate_color := Color(1.0, 1.0, 1.0, icon_alpha)
	if not is_active:
		return modulate_color

	if _weapon_block_pulse_timer > 0.0:
		var block_progress := _get_weapon_block_pulse_progress()
		modulate_color = modulate_color.lerp(WEAPON_SLOT_BLOCK_TEXT_COLOR, block_progress)
	elif _weapon_ready_pulse_timer > 0.0:
		var ready_progress := clampf(_weapon_ready_pulse_timer / _weapon_ready_pulse_duration, 0.0, 1.0)
		modulate_color = modulate_color.lerp(WEAPON_SLOT_READY_TEXT_COLOR, ready_progress)
	elif _weapon_slot_switch_pulse_timer > 0.0:
		var switch_progress := clampf(_weapon_slot_switch_pulse_timer / _weapon_slot_switch_pulse_duration, 0.0, 1.0)
		modulate_color = modulate_color.lerp(WEAPON_SLOT_LOADOUT_SWITCH_COLOR, switch_progress)
	modulate_color.a = icon_alpha
	return modulate_color


func _format_weapon_loadout_label(index: int, has_weapon: bool) -> String:
	if not has_weapon:
		return "%d --" % [index + 1]
	var entry := _weapon_slot_loadout_entries[index] if index < _weapon_slot_loadout_entries.size() else {}
	return "%d %s %s %s" % [
		index + 1,
		_format_weapon_meta_prefix(entry),
		_shorten_weapon_slot_name(Localization.text(_weapon_slot_loadout_names[index]), 7),
		_format_weapon_loadout_ammo_summary(index, has_weapon),
	]


func _format_weapon_loadout_tooltip(index: int, has_weapon: bool) -> String:
	if not has_weapon:
		return "Slot %d: Empty" % [index + 1]

	var entry := _weapon_slot_loadout_entries[index] if index < _weapon_slot_loadout_entries.size() else {}
	var static_tooltip := _get_cached_weapon_loadout_tooltip_static(index, entry)
	return "%s | %s\n%s" % [
		str(static_tooltip.get("base", "Slot %d" % [index + 1])),
		_format_weapon_loadout_ammo_tooltip(index, has_weapon),
		str(static_tooltip.get("icon", "")),
	]


func _get_cached_weapon_loadout_tooltip_static(index: int, entry: Dictionary) -> Dictionary:
	while _weapon_slot_tooltip_cache_keys.size() <= index:
		_weapon_slot_tooltip_cache_keys.append("")
		_weapon_slot_tooltip_cache_values.append({})

	var display_name := str(entry.get("display_name", _weapon_slot_loadout_names[index]))
	var icon_key := _resolve_weapon_slot_icon_key(entry)
	var cache_key := "%s|%s|%s|%s|%s" % [
		display_name,
		icon_key,
		str(entry.get("rarity", "")),
		str(entry.get("weapon_class", "")),
		str(entry.get("recommended_range", "")),
	]
	if _weapon_slot_tooltip_cache_keys[index] == cache_key:
		return _weapon_slot_tooltip_cache_values[index]

	var value := {
		"base": "Slot %d: %s | %s %s | %s range" % [
			index + 1,
			display_name,
			_format_label_token(entry.get("rarity", "")),
			_format_label_token(entry.get("weapon_class", "")),
			_format_label_token(entry.get("recommended_range", "")),
		],
		"icon": CONTENT_ICON_REGISTRY.get_placeholder_tooltip(icon_key, display_name, "weapons"),
	}
	_weapon_slot_tooltip_cache_keys[index] = cache_key
	_weapon_slot_tooltip_cache_values[index] = value
	return value


func _format_weapon_loadout_ammo_summary(index: int, has_weapon: bool) -> String:
	if not has_weapon:
		return "--"
	var entry := _weapon_slot_loadout_entries[index] if index < _weapon_slot_loadout_entries.size() else {}
	var magazine_size := maxi(int(entry.get("magazine_size", 0)), 0)
	var is_active := index + 1 == _weapon_slot_index
	if is_active:
		if bool(entry.get("is_reloading", false)):
			return "RLD"
		var current_ammo := int(entry.get("current_ammo", _weapon_slot_current_ammo))
		if magazine_size > 0:
			return "%d/%d" % [maxi(current_ammo, 0), magazine_size]
		return "%d/--" % maxi(current_ammo, 0)

	var energy_cost := maxi(int(entry.get("energy_cost", 0)), 0)
	if magazine_size > 0:
		return "M%d/E%d" % [magazine_size, energy_cost]
	return "M--/E%d" % energy_cost


func _format_weapon_loadout_ammo_tooltip(index: int, has_weapon: bool) -> String:
	if not has_weapon:
		return "No weapon"
	var entry := _weapon_slot_loadout_entries[index] if index < _weapon_slot_loadout_entries.size() else {}
	var magazine_size := maxi(int(entry.get("magazine_size", 0)), 0)
	var energy_cost := maxi(int(entry.get("energy_cost", 0)), 0)
	var energy_context := _format_weapon_loadout_energy_tooltip(index, has_weapon)
	if index + 1 == _weapon_slot_index:
		if bool(entry.get("is_reloading", false)):
			return "Reloading, magazine %d, %s" % [magazine_size, energy_context]
		var current_ammo := int(entry.get("current_ammo", _weapon_slot_current_ammo))
		return "Ammo %d/%d, energy %d, %s" % [maxi(current_ammo, 0), magazine_size, energy_cost, energy_context]
	return "Magazine %d, energy %d, %s" % [magazine_size, energy_cost, energy_context]


func _format_weapon_loadout_energy_tooltip(index: int, has_weapon: bool) -> String:
	var energy_state := _get_weapon_loadout_energy_state(index, has_weapon)
	if energy_state == "empty":
		return "No energy check"

	var entry := _weapon_slot_loadout_entries[index] if index >= 0 and index < _weapon_slot_loadout_entries.size() else {}
	var energy_cost := maxi(int(entry.get("energy_cost", 0)), 0)
	if energy_state == "free":
		return "Free to fire"
	if energy_state == "ready":
		return "Energy ready %d/%d" % [_energy_current, energy_cost]
	return "Need %d energy (%d/%d)" % [_get_weapon_loadout_energy_need(index, has_weapon), _energy_current, energy_cost]


func _get_weapon_loadout_energy_state(index: int, has_weapon: bool) -> String:
	if not has_weapon:
		return "empty"
	var entry := _weapon_slot_loadout_entries[index] if index >= 0 and index < _weapon_slot_loadout_entries.size() else {}
	var energy_cost := maxi(int(entry.get("energy_cost", 0)), 0)
	if energy_cost <= 0:
		return "free"
	if _energy_current >= energy_cost:
		return "ready"
	return "blocked"


func _get_weapon_loadout_energy_need(index: int, has_weapon: bool) -> int:
	if not has_weapon:
		return 0
	var entry := _weapon_slot_loadout_entries[index] if index >= 0 and index < _weapon_slot_loadout_entries.size() else {}
	var energy_cost := maxi(int(entry.get("energy_cost", 0)), 0)
	return maxi(energy_cost - _energy_current, 0)


func _format_weapon_meta_prefix(entry: Dictionary) -> String:
	var rarity := str(entry.get("rarity", "")).strip_edges()
	if rarity.is_empty():
		return "--"
	var weapon_class_name := str(entry.get("weapon_class", "")).strip_edges()
	var rarity_token := rarity.substr(0, mini(rarity.length(), 2)).to_upper()
	if weapon_class_name.is_empty():
		return rarity_token
	return "%s/%s" % [rarity_token, weapon_class_name.substr(0, mini(weapon_class_name.length(), 2)).to_upper()]


func _format_weapon_class_symbol(weapon_class: String) -> String:
	var normalized := weapon_class.strip_edges().to_lower().replace("_", " ").replace("-", " ")
	match normalized:
		"sidearm":
			return "SI"
		"shotgun":
			return "SH"
		"staff":
			return "ST"
		"blade":
			return "BL"
		"launcher":
			return "LA"
		"lance":
			return "LN"
		"fan":
			return "FN"
		"bow":
			return "BW"
		"trap":
			return "TR"
		"mortar":
			return "MO"
		"sprayer":
			return "SP"
		"ray":
			return "RY"
		"sentry":
			return "SN"
	if normalized.is_empty():
		return "--"

	var parts := normalized.split(" ", false)
	var token := ""
	for part in parts:
		token += part.substr(0, 1).to_upper()
	if token.length() >= 2:
		return token.substr(0, mini(token.length(), 3))
	return normalized.substr(0, mini(normalized.length(), 3)).to_upper()


func _get_weapon_loadout_color(index: int, is_active: bool) -> Color:
	var entry := _weapon_slot_loadout_entries[index] if index >= 0 and index < _weapon_slot_loadout_entries.size() else {}
	var rarity := str(entry.get("rarity", "")).strip_edges()
	var rarity_color: Color = _rarity_colors.get(rarity, WEAPON_SLOT_LOADOUT_ACTIVE_COLOR)
	var base_color := rarity_color if is_active else WEAPON_SLOT_LOADOUT_INACTIVE_COLOR.lerp(rarity_color, 0.42)
	var energy_state := _get_weapon_loadout_energy_state(index, not entry.is_empty())
	if energy_state == "blocked":
		return base_color.lerp(WEAPON_SLOT_LOADOUT_ENERGY_BLOCKED_COLOR, 0.62 if is_active else 0.5)
	if energy_state == "ready" and not is_active:
		return base_color.lerp(WEAPON_SLOT_LOADOUT_ENERGY_READY_COLOR, 0.18)
	if is_active:
		return rarity_color
	return base_color


func _get_weapon_block_pulse_progress() -> float:
	if _weapon_block_pulse_timer <= 0.0:
		return 0.0
	return clampf(_weapon_block_pulse_timer / _weapon_block_pulse_duration, 0.0, 1.0)


func _normalize_weapon_loadout_entry(loadout_entry) -> Dictionary:
	if loadout_entry is Dictionary:
		return {
			"id": str(loadout_entry.get("id", "")),
			"display_name": str(loadout_entry.get("display_name", "")),
			"icon_key": _resolve_weapon_slot_icon_key({
				"id": str(loadout_entry.get("id", "")),
				"icon_key": str(loadout_entry.get("icon_key", "")),
			}),
			"rarity": str(loadout_entry.get("rarity", "")),
			"weapon_class": str(loadout_entry.get("weapon_class", "")),
			"recommended_range": str(loadout_entry.get("recommended_range", "")),
			"energy_cost": int(loadout_entry.get("energy_cost", 0)),
			"magazine_size": int(loadout_entry.get("magazine_size", 0)),
			"current_ammo": int(loadout_entry.get("current_ammo", -1)),
			"is_reloading": bool(loadout_entry.get("is_reloading", false)),
			"is_active": bool(loadout_entry.get("is_active", false)),
		}

	if loadout_entry is Resource:
		return {
			"id": str(loadout_entry.get("id")),
			"display_name": str(loadout_entry.get("display_name")),
			"icon_key": _resolve_weapon_slot_icon_key({
				"id": str(loadout_entry.get("id")),
				"icon_key": str(loadout_entry.get("icon_key")),
			}),
			"rarity": str(loadout_entry.get("rarity")),
			"weapon_class": str(loadout_entry.get("weapon_class")),
			"recommended_range": str(loadout_entry.get("recommended_range")),
			"energy_cost": int(loadout_entry.get("energy_cost")),
			"magazine_size": int(loadout_entry.get("magazine_size")),
			"current_ammo": -1,
			"is_reloading": false,
			"is_active": false,
		}

	return {
		"id": "",
		"display_name": str(loadout_entry),
		"icon_key": "",
		"rarity": "",
		"weapon_class": "",
		"recommended_range": "",
		"energy_cost": 0,
		"magazine_size": 0,
		"current_ammo": -1,
		"is_reloading": false,
		"is_active": false,
	}


func _get_active_weapon_loadout_entry() -> Dictionary:
	var index := _weapon_slot_index - 1
	if index >= 0 and index < _weapon_slot_loadout_entries.size():
		return _weapon_slot_loadout_entries[index]
	return {}


func _shorten_weapon_slot_name(display_name: String, max_length: int = 13) -> String:
	var cleaned := display_name.strip_edges()
	if cleaned.length() <= max_length:
		return cleaned
	return "%s." % cleaned.substr(0, maxi(max_length - 1, 1))


func _format_weapon_slot_index() -> String:
	return "%d/%d" % [maxi(_weapon_slot_index, 1), maxi(_weapon_slot_total, 1)]


func update_gold(current_gold: int) -> void:
	gold_label.text = Localization.format("Gold: %d", current_gold)


func update_relics(relic_summaries: Array) -> void:
	if relic_summaries.is_empty():
		relic_label.text = Localization.text("Relics: None")
		relic_label.tooltip_text = relic_label.text
		return

	var parts: PackedStringArray = []
	for summary in relic_summaries:
		if not summary is Dictionary:
			continue
		var name := Localization.text(summary.get("display_name", "Relic"))
		var stacks := int(summary.get("stacks", 1))
		if stacks > 1:
			parts.append("%s x%d" % [name, stacks])
		else:
			parts.append(name)

	relic_label.text = Localization.format("Relics: %s", "、".join(parts))
	relic_label.tooltip_text = relic_label.text


func update_enemy_count(count: int) -> void:
	enemy_label.text = Localization.format("Enemies: %d", count)


func update_room_state(state_name: String) -> void:
	room_state_label.text = Localization.format("Room: %s", Localization.text(state_name))


func update_boss_health(display_name: String, current_hp: int, max_hp: int) -> void:
	boss_panel.visible = true
	boss_name_label.text = Localization.text(display_name)
	boss_health_bar.max_value = maxf(float(max_hp), 1.0)
	boss_health_bar.value = clampf(float(current_hp), 0.0, boss_health_bar.max_value)


func hide_boss_health() -> void:
	boss_panel.visible = false


func set_flow_receiver(receiver: Node) -> void:
	flow_receiver = receiver


func show_main_menu(receiver: Node = null) -> void:
	if receiver != null:
		flow_receiver = receiver
	hide_flow_panels()
	hide_training_panel()
	death_label.visible = false
	completion_label.visible = false
	main_menu_panel.visible = true
	_refresh_input_hint_panel_visibility()


func show_pause_menu(receiver: Node = null) -> void:
	if receiver != null:
		flow_receiver = receiver
	hide_flow_panels()
	pause_panel.visible = true
	_refresh_input_hint_panel_visibility()


func show_settings_menu(master_volume: float, sfx_volume = null, music_volume = null, fullscreen = null, resolution_index = null, receiver: Node = null, aim_assist_enabled = null, aim_assist_strength = null, low_health_feedback_intensity = null, screen_shake_intensity = null, damage_flash_intensity = null, combat_text_intensity = null, controller_aim_deadzone = null, controller_input_switch_threshold = null) -> void:
	if receiver != null:
		flow_receiver = receiver
	hide_flow_panels()
	update_settings_controls(master_volume, sfx_volume, music_volume, fullscreen, resolution_index, aim_assist_enabled, aim_assist_strength, low_health_feedback_intensity, screen_shake_intensity, damage_flash_intensity, combat_text_intensity, controller_aim_deadzone, controller_input_switch_threshold)
	settings_panel.visible = true
	_refresh_input_hint_panel_visibility()


func show_hall_menu(summary: Dictionary, receiver: Node = null) -> void:
	if receiver != null:
		flow_receiver = receiver
	hide_flow_panels()
	if lobby_screen == null:
		_setup_hall_panel()
	if lobby_screen != null:
		lobby_screen.call("show_summary", summary)
	elif hall_summary_label != null:
		hall_summary_label.text = _format_hall_summary(summary)
		hall_panel.visible = true
	_refresh_input_hint_panel_visibility()


func update_settings_controls(master_volume: float, sfx_volume = null, music_volume = null, fullscreen = null, resolution_index = null, aim_assist_enabled = null, aim_assist_strength = null, low_health_feedback_intensity = null, screen_shake_intensity = null, damage_flash_intensity = null, combat_text_intensity = null, controller_aim_deadzone = null, controller_input_switch_threshold = null) -> void:
	var resolved_sfx_volume := 1.0
	var resolved_music_volume := 0.8
	var resolved_fullscreen := false
	var resolved_resolution_index := 0
	var resolved_aim_assist_enabled := false
	var resolved_aim_assist_strength := 0.35
	var resolved_low_health_feedback_intensity := LOW_HEALTH_FEEDBACK.DEFAULT_FEEDBACK_INTENSITY
	var resolved_screen_shake_intensity := 1.0
	var resolved_damage_flash_intensity := 1.0
	var resolved_combat_text_intensity := 1.0
	var resolved_controller_aim_deadzone := CONTROLLER_LAYOUT.get_aim_deadzone()
	var resolved_controller_input_switch_threshold := CONTROLLER_LAYOUT.get_input_switch_threshold()

	if typeof(sfx_volume) == TYPE_BOOL:
		resolved_fullscreen = sfx_volume == true
	elif sfx_volume != null:
		resolved_sfx_volume = clampf(float(sfx_volume), 0.0, 1.0)

	if music_volume != null and typeof(music_volume) != TYPE_BOOL:
		resolved_music_volume = clampf(float(music_volume), 0.0, 1.0)

	if fullscreen != null:
		resolved_fullscreen = fullscreen == true
	if resolution_index != null:
		resolved_resolution_index = clampi(int(resolution_index), 0, settings_resolution_option.item_count - 1)

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

	settings_volume_slider.value = roundf(clampf(master_volume, 0.0, 1.0) * 100.0)
	settings_sfx_volume_slider.value = roundf(resolved_sfx_volume * 100.0)
	settings_music_volume_slider.value = roundf(resolved_music_volume * 100.0)
	settings_fullscreen_check.button_pressed = resolved_fullscreen
	settings_resolution_option.select(resolved_resolution_index)
	settings_aim_assist_check.button_pressed = resolved_aim_assist_enabled
	settings_aim_assist_slider.value = roundf(resolved_aim_assist_strength * 100.0)
	set_low_health_feedback_intensity(resolved_low_health_feedback_intensity)
	settings_low_health_feedback_slider.value = roundf(_low_health_feedback_intensity * 100.0)
	settings_screen_shake_slider.value = roundf(resolved_screen_shake_intensity * 100.0)
	set_damage_flash_intensity(resolved_damage_flash_intensity)
	settings_damage_flash_slider.value = roundf(_damage_flash_intensity * 100.0)
	settings_combat_text_slider.value = roundf(resolved_combat_text_intensity * 100.0)
	settings_controller_aim_deadzone_slider.value = roundf(resolved_controller_aim_deadzone * 100.0)
	settings_controller_input_switch_slider.value = roundf(resolved_controller_input_switch_threshold * 100.0)
	_update_volume_value_label()
	refresh_input_bindings()


func refresh_input_bindings() -> void:
	_update_control_rebind_buttons()
	_update_input_hint()


func show_run_result(victory: bool, summary: Dictionary, receiver: Node = null) -> void:
	if receiver != null:
		flow_receiver = receiver
	hide_flow_panels()
	hide_training_panel()
	result_panel.visible = true
	result_title_label.text = "Run Complete" if victory else "Run Failed"
	result_summary_label.text = _format_run_summary(summary)
	_update_result_sections(summary)
	_result_details_expanded = true
	_refresh_result_detail_mode()
	_refresh_input_hint_panel_visibility()


func hide_flow_panels() -> void:
	main_menu_panel.visible = false
	pause_panel.visible = false
	settings_panel.visible = false
	result_panel.visible = false
	debug_map_panel.visible = false
	if lobby_screen != null:
		lobby_screen.call("hide_screen")
	elif hall_panel != null:
		hall_panel.visible = false
	_refresh_input_hint_panel_visibility()


func show_training_panel(receiver: Node = null) -> void:
	if receiver != null:
		flow_receiver = receiver
	if training_panel == null:
		_setup_training_panel()
	training_panel.visible = true


func hide_training_panel() -> void:
	if training_panel != null:
		training_panel.visible = false
	if training_reward_panel != null:
		_training_reward_toast_timer = 0.0
		_refresh_training_reward_toast()


func update_training_stats(summary: Dictionary) -> void:
	if training_stats_label == null or training_rating_label == null or training_badge_label == null:
		_setup_training_panel()
	training_drill_label.text = str(summary.get("drill_name", "Basics"))
	training_guide_label.text = str(summary.get("instruction", ""))
	training_goal_label.text = _format_training_goal(summary)
	training_rating_label.text = "Rating: %s | Best %s" % [
		str(summary.get("rating_text", "Practice")),
		str(summary.get("best_rating_text", "None")),
	]
	training_badge_label.text = _format_training_badge(summary)
	if training_aim_assist_label != null:
		training_aim_assist_label.text = str(summary.get("aim_assist_text", "Aim Assist: Off 35% | Band Off | Targets Training"))
	_update_training_aim_assist_preset_buttons(summary)
	var burst_suffix := ""
	var best_burst_chain := int(summary.get("best_burst_chain", 0))
	if best_burst_chain > 0:
		burst_suffix = " | Burst x%d" % best_burst_chain
	training_stats_label.text = "Targets %d | Types %s | Hits %d | Damage %d | Best %d%s" % [
		int(summary.get("targets", 0)),
		str(summary.get("target_types", "None")),
		int(summary.get("hits", 0)),
		int(summary.get("damage", 0)),
		int(summary.get("best_hit", 0)),
		burst_suffix,
	]
	_maybe_show_training_reward_toast(summary)


func _format_training_goal(summary: Dictionary) -> String:
	var goal_text := str(summary.get("goal_text", "")).strip_edges()
	if goal_text.is_empty():
		return ""

	var progress := int(summary.get("goal_progress", 0))
	var required := int(summary.get("goal_required", 0))
	var prefix := "Complete" if bool(summary.get("goal_complete", false)) else "Goal"
	if required <= 0:
		return "%s: %s" % [prefix, goal_text]
	return "%s: %s %d/%d" % [
		prefix,
		goal_text,
		progress,
		required,
	]


func _format_training_badge(summary: Dictionary) -> String:
	var notice := str(summary.get("badge_notice_text", "")).strip_edges()
	if not notice.is_empty():
		return notice

	return "Badge: %s %s" % [
		str(summary.get("best_rating_text", "None")),
		str(summary.get("best_rating_token", "[--]")),
	]


func _maybe_show_training_reward_toast(summary: Dictionary) -> void:
	var notice := str(summary.get("badge_notice_text", "")).strip_edges()
	if notice.is_empty():
		_last_training_reward_notice = ""
		if training_reward_panel != null and training_reward_panel.visible:
			_training_reward_toast_timer = 0.0
			_refresh_training_reward_toast()
		return
	if notice == _last_training_reward_notice:
		return

	_last_training_reward_notice = notice
	show_training_reward_toast(summary)


func show_training_reward_toast(summary: Dictionary) -> void:
	if training_reward_panel == null:
		_setup_training_reward_panel()
	training_reward_title_label.text = "TRAINING BADGE"
	training_reward_body_label.text = "%s | %s %s" % [
		str(summary.get("drill_name", "Training")),
		str(summary.get("best_rating_text", "None")),
		str(summary.get("best_rating_token", "[--]")),
	]
	training_reward_panel.visible = true
	_training_reward_toast_timer = TRAINING_REWARD_TOAST_DURATION
	_refresh_training_reward_toast()


func _refresh_training_reward_toast() -> void:
	if training_reward_panel == null:
		return
	if _training_reward_toast_timer <= 0.0:
		training_reward_panel.visible = false
		training_reward_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
		training_reward_panel.scale = Vector2.ONE
		return

	var elapsed := TRAINING_REWARD_TOAST_DURATION - _training_reward_toast_timer
	var fade_in := clampf(elapsed / TRAINING_REWARD_TOAST_FADE_TIME, 0.0, 1.0)
	var fade_out := clampf(_training_reward_toast_timer / TRAINING_REWARD_TOAST_FADE_TIME, 0.0, 1.0)
	var alpha := minf(fade_in, fade_out)
	var pulse := 1.0 + 0.035 * sin(elapsed * 18.0) * fade_out
	training_reward_panel.modulate = Color(1.0, 1.0, 1.0, alpha)
	training_reward_panel.scale = Vector2(pulse, pulse)


func update_minimap(room_records: Array, current_room_id: String = "") -> void:
	_minimap_current_room_id = current_room_id
	var structure_signature := _get_minimap_structure_signature(room_records)
	if structure_signature != _minimap_structure_signature:
		_rebuild_minimap(room_records, current_room_id, structure_signature)
	else:
		for record in room_records:
			if not record is Dictionary:
				continue
			var room_id := str(record.get("id", ""))
			var marker := _minimap_markers_by_room_id.get(room_id) as PanelContainer
			if marker != null:
				_update_minimap_marker(marker, record, current_room_id)

	if current_room_id.is_empty():
		minimap_current_label.text = "Current: --"
	else:
		minimap_current_label.text = "Current: %s" % current_room_id


func _rebuild_minimap(room_records: Array, current_room_id: String, structure_signature: String) -> void:
	for child in minimap_row.get_children():
		minimap_row.remove_child(child)
		child.free()
	_minimap_markers_by_room_id.clear()

	var layer_by_biome := {}
	for record in room_records:
		if record is Dictionary:
			var biome_index := int(record.get("biome_index", 1))
			if not layer_by_biome.has(biome_index):
				var layer := _make_minimap_biome_layer(record)
				minimap_row.add_child(layer)
				layer_by_biome[biome_index] = layer
			var layer_node := layer_by_biome[biome_index] as Control
			var marker_row := layer_node.get_node_or_null("MinimapLayerMarkers") as HBoxContainer
			if marker_row != null:
				var marker := _make_minimap_marker(record, current_room_id)
				marker_row.add_child(marker)
				_minimap_markers_by_room_id[str(record.get("id", ""))] = marker
	_minimap_structure_signature = structure_signature


func _get_minimap_structure_signature(room_records: Array) -> String:
	var parts := PackedStringArray()
	for record in room_records:
		if not record is Dictionary:
			continue
		parts.append("%s:%s:%d:%s" % [
			str(record.get("id", "")),
			str(record.get("room_type", "combat")),
			int(record.get("biome_index", 1)),
			str(record.get("biome_name", "")),
		])
	return "|".join(parts)


func update_dungeon_debug_info(seed: int, debug_map_text: String = "") -> void:
	minimap_seed_label.text = "Seed: %d" % seed
	_minimap_debug_text = debug_map_text
	minimap_seed_label.tooltip_text = debug_map_text
	if debug_map_panel.visible:
		_refresh_debug_map_panel_text()


func update_seed_controls(active_seed: int, configured_seed: int = 0) -> void:
	if configured_seed > 0:
		main_menu_seed_input.text = str(configured_seed)
		main_menu_seed_status_label.text = "Current: %d | Fixed" % active_seed
	else:
		main_menu_seed_input.text = ""
		main_menu_seed_status_label.text = "Current: %d | Random" % active_seed


func show_relic_choices(relic_choices: Array, selection_receiver: Node = null) -> void:
	_active_relic_choices = relic_choices.duplicate()
	_active_choice_kind = "relic"
	if selection_receiver != null:
		relic_choice_receiver = selection_receiver
	relic_choice_panel.visible = true
	relic_choice_title.text = "Choose a Relic"

	for index in range(relic_choice_buttons.size()):
		var button := relic_choice_buttons[index]
		if index >= relic_choices.size():
			button.visible = false
			button.disabled = true
			_clear_relic_choice_button_icon(button)
			continue

		var relic := relic_choices[index] as Resource
		button.visible = true
		button.disabled = false
		button.text = _format_relic_choice(relic)
		button.tooltip_text = _format_relic_tooltip(relic)
		_apply_relic_choice_icon(button, relic, "relic")
		_apply_relic_choice_style(button, relic)
	_refresh_input_hint_panel_visibility()


func show_talent_choices(talent_choices: Array, selection_receiver: Node = null) -> void:
	_active_relic_choices = talent_choices.duplicate()
	_active_choice_kind = "talent"
	if selection_receiver != null:
		relic_choice_receiver = selection_receiver
	relic_choice_panel.visible = true
	relic_choice_title.text = "Choose a Talent"

	for index in range(relic_choice_buttons.size()):
		var button := relic_choice_buttons[index]
		if index >= talent_choices.size():
			button.visible = false
			button.disabled = true
			_clear_relic_choice_button_icon(button)
			continue

		var talent := talent_choices[index] as Resource
		button.visible = true
		button.disabled = false
		button.text = _format_talent_choice(talent)
		button.tooltip_text = _format_talent_tooltip(talent)
		_apply_relic_choice_icon(button, talent, "talent")
		_apply_relic_choice_style(button, talent)
	_refresh_input_hint_panel_visibility()


func show_blessing_choices(blessing_choices: Array, selection_receiver: Node = null) -> void:
	_active_relic_choices = blessing_choices.duplicate()
	_active_choice_kind = "blessing"
	if selection_receiver != null:
		relic_choice_receiver = selection_receiver
	relic_choice_panel.visible = true
	relic_choice_title.text = "Choose a Blessing"

	for index in range(relic_choice_buttons.size()):
		var button := relic_choice_buttons[index]
		if index >= blessing_choices.size():
			button.visible = false
			button.disabled = true
			_clear_relic_choice_button_icon(button)
			continue

		var blessing := blessing_choices[index] as Resource
		button.visible = true
		button.disabled = false
		button.text = _format_blessing_choice(blessing)
		button.tooltip_text = _format_blessing_tooltip(blessing)
		_apply_relic_choice_icon(button, blessing, "blessing")
		_apply_relic_choice_style(button, blessing)
	_refresh_input_hint_panel_visibility()


func show_statue_choices(statue_choices: Array, selection_receiver: Node = null) -> void:
	_active_relic_choices = statue_choices.duplicate()
	_active_choice_kind = "statue"
	if selection_receiver != null:
		relic_choice_receiver = selection_receiver
	relic_choice_panel.visible = true
	relic_choice_title.text = "Choose a Statue"

	for index in range(relic_choice_buttons.size()):
		var button := relic_choice_buttons[index]
		if index >= statue_choices.size():
			button.visible = false
			button.disabled = true
			_clear_relic_choice_button_icon(button)
			continue

		var statue := statue_choices[index] as Resource
		button.visible = true
		button.disabled = false
		button.text = _format_statue_choice(statue)
		button.tooltip_text = _format_statue_tooltip(statue)
		_apply_relic_choice_icon(button, statue, "statue")
		_apply_relic_choice_style(button, statue)
	_refresh_input_hint_panel_visibility()


func hide_relic_choices() -> void:
	relic_choice_panel.visible = false
	_active_relic_choices.clear()
	_active_choice_kind = "relic"
	for button in relic_choice_buttons:
		_clear_relic_choice_button_icon(button)
	_refresh_input_hint_panel_visibility()


func show_message(message: String, duration: float = 1.8) -> void:
	message_label.text = message
	message_label.visible = true
	var tween := create_tween()
	tween.tween_interval(duration)
	tween.tween_callback(func() -> void: message_label.visible = false)


func show_death() -> void:
	death_label.visible = true


func show_completion() -> void:
	completion_label.visible = true


func get_minimap_marker_count() -> int:
	return _get_minimap_markers().size()


func get_minimap_biome_layer_count() -> int:
	var count := 0
	for child in minimap_row.get_children():
		if child.has_meta("biome_layer") and bool(child.get_meta("biome_layer")):
			count += 1
	return count


func get_minimap_marker_count_for_biome(biome_index: int) -> int:
	var count := 0
	for marker in _get_minimap_markers():
		if int(marker.get_meta("biome_index", 0)) == biome_index:
			count += 1
	return count


func get_minimap_biome_layer_text(biome_index: int) -> String:
	var layer := _get_minimap_layer_for_biome(biome_index)
	if layer == null:
		return ""
	return str(layer.get_meta("biome_layer_text", ""))


func get_minimap_biome_layer_tooltip(biome_index: int) -> String:
	var layer := _get_minimap_layer_for_biome(biome_index)
	if layer == null:
		return ""
	return layer.tooltip_text


func get_minimap_current_room_id() -> String:
	return _minimap_current_room_id


func get_minimap_seed_text() -> String:
	return minimap_seed_label.text


func get_minimap_debug_text() -> String:
	return _minimap_debug_text


func get_minimap_marker_icon_for_type(room_type: String) -> String:
	var marker := _get_minimap_marker_for_type(room_type)
	if marker == null:
		return ""
	if marker is Label:
		var label := marker as Label
		return str(marker.get_meta("room_icon", label.text))
	return str(marker.get_meta("room_icon", ""))


func get_minimap_marker_icon_key_for_type(room_type: String) -> String:
	var marker := _get_minimap_marker_for_type(room_type)
	if marker == null:
		return ""
	return str(marker.get_meta("room_icon_key", ""))


func get_minimap_marker_texture_path_for_type(room_type: String) -> String:
	var marker := _get_minimap_marker_for_type(room_type)
	if marker == null:
		return ""
	return str(marker.get_meta("room_icon_texture_path", ""))


func get_minimap_marker_texture_visible_for_type(room_type: String) -> bool:
	var marker := _get_minimap_marker_for_type(room_type)
	if marker == null:
		return false
	return bool(marker.get_meta("room_icon_texture_visible", false))


func get_minimap_marker_label_for_type(room_type: String) -> String:
	var marker := _get_minimap_marker_for_type(room_type)
	if marker == null:
		return ""
	return str(marker.get_meta("room_label", ""))


func get_minimap_marker_tooltip_for_type(room_type: String) -> String:
	var marker := _get_minimap_marker_for_type(room_type)
	if marker == null:
		return ""
	return marker.tooltip_text


func toggle_debug_map_panel() -> void:
	if debug_map_panel.visible:
		hide_debug_map_panel()
	else:
		show_debug_map_panel()


func show_debug_map_panel() -> void:
	_refresh_debug_map_panel_text()
	debug_map_panel.visible = true
	_refresh_input_hint_panel_visibility()


func hide_debug_map_panel() -> void:
	debug_map_panel.visible = false
	_refresh_input_hint_panel_visibility()


func copy_debug_map_to_clipboard() -> bool:
	var text := get_debug_map_panel_text()
	if text.is_empty():
		return false
	DisplayServer.clipboard_set(text)
	return true


func is_debug_map_visible() -> bool:
	return debug_map_panel.visible


func get_debug_map_panel_text() -> String:
	return debug_map_text.text


func get_seed_input_text() -> String:
	return main_menu_seed_input.text


func get_seed_status_text() -> String:
	return main_menu_seed_status_label.text


func get_health_label_text() -> String:
	return health_label.text


func is_low_health_active() -> bool:
	return _is_low_health


func is_low_health_vignette_visible() -> bool:
	return _low_health_vignette_alpha > 0.01 and _has_visible_low_health_vignette_edge()


func get_low_health_vignette_alpha_for_test() -> float:
	return _low_health_vignette_display_alpha


func get_low_health_vignette_target_alpha_for_test() -> float:
	return _low_health_vignette_target_alpha


func get_low_health_vignette_pulse_speed_for_test() -> float:
	return _low_health_vignette_pulse_speed


func get_low_health_feedback_intensity_for_test() -> float:
	return _low_health_feedback_intensity


func get_damage_flash_intensity_for_test() -> float:
	return _damage_flash_intensity


func get_relic_label_text() -> String:
	return relic_label.text


func get_shield_label_text() -> String:
	return shield_label.text


func is_armor_recovery_pulse_active() -> bool:
	return _armor_recovery_pulse_timer > 0.0


func is_armor_break_pulse_active() -> bool:
	return _armor_break_pulse_timer > 0.0


func get_shield_label_color_for_test() -> Color:
	return shield_label.get_theme_color("font_color")


func get_energy_label_text() -> String:
	return energy_label.text


func is_energy_warning_active() -> bool:
	return _energy_warning_timer > 0.0 and _energy_warning_required > _energy_current


func get_energy_label_color_for_test() -> Color:
	return energy_label.get_theme_color("font_color")


func get_skill_label_text() -> String:
	return skill_label.text


func get_weapon_label_text() -> String:
	return weapon_label.text


func is_weapon_ready_pulse_active() -> bool:
	return _weapon_ready_pulse_timer > 0.0


func is_weapon_block_pulse_active() -> bool:
	return _weapon_block_pulse_timer > 0.0


func get_weapon_label_color_for_test() -> Color:
	return weapon_label.get_theme_color("font_color")


func get_weapon_slot_name_text() -> String:
	return weapon_slot_name_label.text


func get_weapon_slot_meta_text() -> String:
	return weapon_slot_meta_label.text


func get_weapon_slot_visual_summary_for_test() -> Dictionary:
	return {
		"icon": weapon_slot_icon_label.text,
		"icon_key": _weapon_slot_icon_key,
		"icon_texture_path": _weapon_slot_icon_texture_path,
		"icon_texture_visible": weapon_slot_icon_texture != null and weapon_slot_icon_texture.visible,
		"icon_modulate": weapon_slot_icon_texture.modulate if weapon_slot_icon_texture != null else Color(0.0, 0.0, 0.0, 0.0),
		"icon_tooltip": weapon_slot_icon_texture.tooltip_text if weapon_slot_icon_texture != null and weapon_slot_icon_texture.visible else weapon_slot_icon_label.tooltip_text,
		"type": weapon_slot_type_symbol_label.text,
		"energy": weapon_slot_energy_symbol_label.text,
		"rarity_color": weapon_slot_rarity_strip.color,
	}


func get_weapon_slot_energy_symbol_color_for_test() -> Color:
	return weapon_slot_energy_symbol_label.get_theme_color("font_color")


func get_weapon_slot_panel_summary_for_test() -> Dictionary:
	_refresh_weapon_slot_panel_style()
	var border_color := Color(0.0, 0.0, 0.0, 0.0)
	var border_width := 0
	if _weapon_slot_panel_style != null:
		border_color = _weapon_slot_panel_style.border_color
		border_width = _weapon_slot_panel_style.border_width_left
	return {
		"active_slot": _weapon_slot_index,
		"slot_total": _weapon_slot_total,
		"border_color": border_color,
		"border_width": border_width,
	}


func is_weapon_slot_switch_pulse_active() -> bool:
	return _weapon_slot_switch_pulse_timer > 0.0


func get_weapon_slot_active_loadout_color_for_test() -> Color:
	_refresh_weapon_slot_loadout_row()
	var active_index := _weapon_slot_index - 1
	if active_index >= 0 and active_index < _weapon_slot_loadout_labels.size():
		return _weapon_slot_loadout_labels[active_index].get_theme_color("font_color")
	return Color(0.0, 0.0, 0.0, 0.0)


func get_weapon_slot_index_text() -> String:
	return _format_weapon_slot_index()


func get_weapon_slot_loadout_text() -> String:
	_refresh_weapon_slot_loadout_row()
	var parts: PackedStringArray = []
	for label in _weapon_slot_loadout_labels:
		parts.append(label.text)
	return " | ".join(parts)


func _get_weapon_slot_loadout_icon_keys_for_test() -> Array[String]:
	var icon_keys: Array[String] = []
	var slot_count := maxi(_weapon_slot_total, _weapon_slot_loadout_names.size())
	for index in range(slot_count):
		if index < _weapon_slot_loadout_entries.size():
			icon_keys.append(_resolve_weapon_slot_icon_key(_weapon_slot_loadout_entries[index]))
		else:
			icon_keys.append("")
	return icon_keys


func _get_weapon_slot_loadout_icon_texture_paths_for_test() -> Array[String]:
	var icon_paths: Array[String] = []
	for icon_key_value in _get_weapon_slot_loadout_icon_keys_for_test():
		var icon_key := str(icon_key_value)
		if icon_key.is_empty():
			icon_paths.append("")
		else:
			icon_paths.append(CONTENT_ICON_REGISTRY.get_texture_path(icon_key, "weapons"))
	return icon_paths


func _get_weapon_slot_loadout_icon_visibility_for_test() -> Array[bool]:
	_refresh_weapon_slot_loadout_row()
	var visibility: Array[bool] = []
	for icon_texture_value in _weapon_slot_loadout_icons:
		var icon_texture := icon_texture_value as TextureRect
		visibility.append(icon_texture != null and icon_texture.visible)
	return visibility


func _get_weapon_slot_loadout_icon_modulates_for_test() -> Array[Color]:
	_refresh_weapon_slot_loadout_row()
	var modulates: Array[Color] = []
	for icon_texture_value in _weapon_slot_loadout_icons:
		var icon_texture := icon_texture_value as TextureRect
		if icon_texture == null:
			modulates.append(Color(0.0, 0.0, 0.0, 0.0))
		else:
			modulates.append(icon_texture.modulate)
	return modulates


func _get_weapon_slot_loadout_border_colors_for_test() -> Array[Color]:
	_refresh_weapon_slot_loadout_row()
	var colors: Array[Color] = []
	for style_value in _weapon_slot_loadout_styles:
		var style := style_value as StyleBoxFlat
		if style == null:
			colors.append(Color(0.0, 0.0, 0.0, 0.0))
		else:
			colors.append(style.border_color)
	return colors


func _get_weapon_slot_loadout_border_widths_for_test() -> Array[int]:
	_refresh_weapon_slot_loadout_row()
	var widths: Array[int] = []
	for style_value in _weapon_slot_loadout_styles:
		var style := style_value as StyleBoxFlat
		widths.append(style.border_width_left if style != null else 0)
	return widths


func _get_weapon_slot_loadout_background_colors_for_test() -> Array[Color]:
	_refresh_weapon_slot_loadout_row()
	var colors: Array[Color] = []
	for style_value in _weapon_slot_loadout_styles:
		var style := style_value as StyleBoxFlat
		if style == null:
			colors.append(Color(0.0, 0.0, 0.0, 0.0))
		else:
			colors.append(style.bg_color)
	return colors


func _get_weapon_slot_loadout_ammo_summaries_for_test() -> Array[String]:
	var summaries: Array[String] = []
	var slot_count := maxi(_weapon_slot_total, _weapon_slot_loadout_names.size())
	for index in range(slot_count):
		summaries.append(_format_weapon_loadout_ammo_summary(index, index < _weapon_slot_loadout_names.size()))
	return summaries


func _get_weapon_slot_loadout_energy_states_for_test() -> Array[String]:
	var states: Array[String] = []
	var slot_count := maxi(_weapon_slot_total, _weapon_slot_loadout_names.size())
	for index in range(slot_count):
		states.append(_get_weapon_loadout_energy_state(index, index < _weapon_slot_loadout_names.size()))
	return states


func _get_weapon_slot_loadout_energy_needs_for_test() -> Array[int]:
	var needs: Array[int] = []
	var slot_count := maxi(_weapon_slot_total, _weapon_slot_loadout_names.size())
	for index in range(slot_count):
		needs.append(_get_weapon_loadout_energy_need(index, index < _weapon_slot_loadout_names.size()))
	return needs


func _get_weapon_slot_loadout_label_colors_for_test() -> Array[Color]:
	_refresh_weapon_slot_loadout_row()
	var colors: Array[Color] = []
	for label in _weapon_slot_loadout_labels:
		colors.append(label.get_theme_color("font_color"))
	return colors


func _get_weapon_slot_loadout_tooltips_for_test() -> Array[String]:
	_refresh_weapon_slot_loadout_row()
	var tooltips: Array[String] = []
	for label in _weapon_slot_loadout_labels:
		tooltips.append(label.tooltip_text)
	return tooltips


func get_weapon_slot_loadout_summary_for_test() -> Dictionary:
	return {
		"active_slot": _weapon_slot_index,
		"slot_total": _weapon_slot_total,
		"names": _weapon_slot_loadout_names.duplicate(),
		"entries": _weapon_slot_loadout_entries.duplicate(true),
		"icon_keys": _get_weapon_slot_loadout_icon_keys_for_test(),
		"icon_texture_paths": _get_weapon_slot_loadout_icon_texture_paths_for_test(),
		"icon_texture_visible": _get_weapon_slot_loadout_icon_visibility_for_test(),
		"icon_modulates": _get_weapon_slot_loadout_icon_modulates_for_test(),
		"slot_border_colors": _get_weapon_slot_loadout_border_colors_for_test(),
		"slot_border_widths": _get_weapon_slot_loadout_border_widths_for_test(),
		"slot_background_colors": _get_weapon_slot_loadout_background_colors_for_test(),
		"ammo_summaries": _get_weapon_slot_loadout_ammo_summaries_for_test(),
		"energy_states": _get_weapon_slot_loadout_energy_states_for_test(),
		"energy_needs": _get_weapon_slot_loadout_energy_needs_for_test(),
		"label_colors": _get_weapon_slot_loadout_label_colors_for_test(),
		"tooltips": _get_weapon_slot_loadout_tooltips_for_test(),
		"text": get_weapon_slot_loadout_text(),
	}


func get_weapon_slot_status_text() -> String:
	return weapon_slot_ammo_label.text


func get_weapon_slot_bar_color_for_test() -> Color:
	return weapon_slot_status_bar.color


func get_weapon_slot_magazine_segment_summary_for_test() -> Dictionary:
	var segment_count := _weapon_slot_magazine_segments.size()
	return {
		"segments": segment_count,
		"filled": _calculate_weapon_slot_filled_segments(segment_count),
		"current_ammo": _weapon_slot_current_ammo,
		"magazine_size": _weapon_slot_magazine_size,
		"reload_sweep_active": _weapon_slot_is_reloading and segment_count > 0,
		"reload_sweep_index": _get_weapon_slot_reload_sweep_index(segment_count),
	}


func get_weapon_slot_magazine_first_segment_color_for_test() -> Color:
	if _weapon_slot_magazine_segments.is_empty():
		return Color(0, 0, 0, 0)
	return _weapon_slot_magazine_segments[0].color


func get_weapon_slot_reload_sweep_segment_color_for_test() -> Color:
	var sweep_index := _get_weapon_slot_reload_sweep_index()
	if sweep_index < 0 or sweep_index >= _weapon_slot_magazine_segments.size():
		return Color(0, 0, 0, 0)
	return _weapon_slot_magazine_segments[sweep_index].color


func get_ammo_label_text() -> String:
	return ammo_label.text


func is_ammo_ready_pulse_active() -> bool:
	return _ammo_ready_pulse_timer > 0.0


func get_ammo_label_color_for_test() -> Color:
	return ammo_label.get_theme_color("font_color")


func is_skill_warning_active() -> bool:
	return _skill_warning_timer > 0.0


func is_skill_ready_pulse_active() -> bool:
	return _skill_ready_pulse_timer > 0.0


func is_passive_trigger_pulse_active() -> bool:
	return _passive_trigger_pulse_timer > 0.0


func get_skill_label_color_for_test() -> Color:
	return skill_label.get_theme_color("font_color")


func get_passive_status_text() -> String:
	return passive_status_label.text


func get_passive_status_color_for_test() -> Color:
	return passive_status_label.get_theme_color("font_color")


func get_passive_status_icon_key_for_test() -> String:
	return _passive_status_icon_key


func get_passive_status_icon_texture_path_for_test() -> String:
	return _passive_status_icon_texture_path


func is_passive_status_icon_visible_for_test() -> bool:
	return passive_status_icon_texture != null and passive_status_icon_texture.visible


func get_passive_status_token_text_for_test() -> String:
	if passive_status_token_label == null:
		return ""
	return passive_status_token_label.text


func get_rule_feedback_text() -> String:
	return rule_feedback_label.text


func is_rule_feedback_active() -> bool:
	return _rule_feedback_timer > 0.0


func get_rule_feedback_color_for_test() -> Color:
	return rule_feedback_label.get_theme_color("font_color")


func get_rule_feedback_icon_key_for_test() -> String:
	return _rule_feedback_icon_key


func get_rule_feedback_icon_texture_path_for_test() -> String:
	return _rule_feedback_icon_texture_path


func is_rule_feedback_icon_visible_for_test() -> bool:
	return rule_feedback_icon_texture != null and rule_feedback_icon_texture.visible


func get_rule_feedback_token_text_for_test() -> String:
	if rule_feedback_token_label == null:
		return ""
	return rule_feedback_token_label.text


func is_damage_flash_visible() -> bool:
	return _damage_flash_overlay != null and _damage_flash_overlay.visible and _damage_flash_timer > 0.0


func get_damage_flash_alpha_for_test() -> float:
	if _damage_flash_overlay == null:
		return 0.0
	return _damage_flash_overlay.color.a


func get_character_name_text() -> String:
	return character_name_label.text


func get_character_info_text() -> String:
	return character_info_label.text


func get_character_unlock_button_text() -> String:
	if character_unlock_button == null:
		return ""
	return character_unlock_button.text


func is_character_unlock_button_disabled() -> bool:
	return character_unlock_button == null or character_unlock_button.disabled


func is_start_button_disabled() -> bool:
	return start_button.disabled


func is_training_button_disabled() -> bool:
	return training_button == null or training_button.disabled


func get_training_button_text() -> String:
	if training_button == null:
		return ""
	return training_button.text


func is_training_panel_visible() -> bool:
	return training_panel != null and training_panel.visible


func get_training_stats_text() -> String:
	if training_stats_label == null:
		return ""
	return training_stats_label.text


func get_training_drill_text() -> String:
	if training_drill_label == null:
		return ""
	return training_drill_label.text


func get_training_guide_text() -> String:
	if training_guide_label == null:
		return ""
	return training_guide_label.text


func get_training_goal_text() -> String:
	if training_goal_label == null:
		return ""
	return training_goal_label.text


func get_training_rating_text() -> String:
	if training_rating_label == null:
		return ""
	return training_rating_label.text


func get_training_badge_text() -> String:
	if training_badge_label == null:
		return ""
	return training_badge_label.text


func get_training_aim_assist_text() -> String:
	if training_aim_assist_label == null:
		return ""
	return training_aim_assist_label.text


func get_training_aim_assist_active_preset_text() -> String:
	for key in training_aim_assist_preset_buttons.keys():
		var button = training_aim_assist_preset_buttons[key]
		if button is Button and (button as Button).button_pressed:
			return (button as Button).text
	return ""


func choose_training_aim_assist_preset_for_test(band: String) -> void:
	_on_training_aim_assist_preset_button_pressed(band)


func is_training_reward_toast_visible_for_test() -> bool:
	return training_reward_panel != null and training_reward_panel.visible


func get_training_reward_title_text_for_test() -> String:
	if training_reward_title_label == null:
		return ""
	return training_reward_title_label.text


func get_training_reward_body_text_for_test() -> String:
	if training_reward_body_label == null:
		return ""
	return training_reward_body_label.text


func get_training_reward_toast_alpha_for_test() -> float:
	if training_reward_panel == null:
		return 0.0
	return training_reward_panel.modulate.a


func is_relic_choice_visible() -> bool:
	return relic_choice_panel.visible


func is_talent_choice_visible() -> bool:
	return relic_choice_panel.visible and _active_choice_kind == "talent"


func is_blessing_choice_visible() -> bool:
	return relic_choice_panel.visible and _active_choice_kind == "blessing"


func is_statue_choice_visible() -> bool:
	return relic_choice_panel.visible and _active_choice_kind == "statue"


func get_choice_panel_title_text() -> String:
	return relic_choice_title.text


func get_relic_choice_count() -> int:
	return _active_relic_choices.size()


func get_relic_choice_text(index: int) -> String:
	if index < 0 or index >= relic_choice_buttons.size():
		return ""
	return relic_choice_buttons[index].text


func get_relic_choice_font_color(index: int) -> Color:
	if index < 0 or index >= relic_choice_buttons.size():
		return Color.WHITE
	return relic_choice_buttons[index].get_theme_color("font_color")


func get_relic_choice_icon_key(index: int) -> String:
	return _get_relic_choice_icon_key_for_resource(_get_active_choice_resource(index), _active_choice_kind)


func get_relic_choice_icon_texture_path(index: int) -> String:
	if index < 0 or index >= _active_relic_choices.size():
		return ""
	var icon_key := get_relic_choice_icon_key(index)
	return CONTENT_ICON_REGISTRY.get_texture_path(icon_key, _get_choice_icon_page(_active_choice_kind))


func is_relic_choice_icon_visible(index: int) -> bool:
	if index < 0 or index >= relic_choice_buttons.size():
		return false
	return relic_choice_buttons[index].icon != null


func get_relic_choice_icon_tooltip_text(index: int) -> String:
	if index < 0 or index >= relic_choice_buttons.size():
		return ""
	return relic_choice_buttons[index].tooltip_text


func is_boss_health_visible() -> bool:
	return boss_panel.visible


func get_boss_health_value() -> float:
	return boss_health_bar.value


func get_boss_name_text() -> String:
	return boss_name_label.text


func is_completion_visible() -> bool:
	return completion_label.visible


func is_main_menu_visible() -> bool:
	return main_menu_panel.visible


func is_pause_menu_visible() -> bool:
	return pause_panel.visible


func is_settings_visible() -> bool:
	return settings_panel.visible


func is_hall_visible() -> bool:
	if lobby_screen != null:
		return bool(lobby_screen.get("visible"))
	return hall_panel != null and hall_panel.visible


func get_hall_summary_text() -> String:
	if lobby_screen != null:
		return str(lobby_screen.call("get_archive_text"))
	if hall_summary_label == null:
		return ""
	return hall_summary_label.text


func get_lobby_quick_stats_text() -> String:
	if lobby_screen == null:
		return ""
	return str(lobby_screen.call("get_quick_stats_text"))


func get_lobby_objective_board_text() -> String:
	if lobby_screen == null:
		return ""
	return str(lobby_screen.call("get_objective_board_text"))


func get_lobby_objective_progress_text() -> String:
	if lobby_screen == null:
		return ""
	return str(lobby_screen.call("get_objective_progress_text"))


func get_lobby_objective_progress_value() -> int:
	if lobby_screen == null:
		return 0
	return int(lobby_screen.call("get_objective_progress_value"))


func get_lobby_objective_progress_value_text() -> String:
	if lobby_screen == null:
		return ""
	return str(lobby_screen.call("get_objective_progress_value_text"))


func get_lobby_objective_progress_tooltip_text() -> String:
	if lobby_screen == null:
		return ""
	return str(lobby_screen.call("get_objective_progress_tooltip_text"))


func get_lobby_active_page() -> String:
	if lobby_screen == null:
		return ""
	return str(lobby_screen.call("get_active_page"))


func get_lobby_current_character_text() -> String:
	if lobby_screen == null:
		return ""
	return str(lobby_screen.call("get_current_character_text"))


func get_lobby_selected_status_text() -> String:
	if lobby_screen == null:
		return ""
	return str(lobby_screen.call("get_selected_status_text"))


func get_lobby_unlock_button_text() -> String:
	if lobby_screen == null:
		return ""
	return str(lobby_screen.call("get_unlock_button_text"))


func is_lobby_unlock_button_disabled() -> bool:
	return lobby_screen == null or bool(lobby_screen.call("is_unlock_button_disabled"))


func is_result_visible() -> bool:
	return result_panel.visible


func get_result_title_text() -> String:
	return result_title_label.text


func get_result_summary_text() -> String:
	return result_summary_label.text


func get_result_section_count() -> int:
	return _result_section_labels.size()


func get_result_section_text(section_name: String) -> String:
	var label = _result_section_labels.get(section_name.to_lower())
	if label is Label:
		return (label as Label).text
	return ""


func is_result_section_visible(section_name: String) -> bool:
	var label = _result_section_labels.get(section_name.to_lower())
	return label is Label and (label as Label).visible


func get_visible_result_section_count() -> int:
	var count := 0
	for label in _result_section_labels.values():
		if label is Label and (label as Label).visible:
			count += 1
	return count


func is_result_details_expanded() -> bool:
	return _result_details_expanded


func get_result_detail_toggle_text() -> String:
	if result_detail_toggle_button == null:
		return ""
	return result_detail_toggle_button.text


func toggle_result_detail_mode() -> void:
	_result_details_expanded = not _result_details_expanded
	_refresh_result_detail_mode()


func is_result_scroll_available() -> bool:
	return result_scroll != null and result_sections_grid != null and result_sections_grid.get_parent() == result_scroll


func get_result_scroll_child_name() -> String:
	if result_scroll == null or result_scroll.get_child_count() <= 0:
		return ""
	return result_scroll.get_child(0).name


func get_result_scroll_minimum_height() -> float:
	if result_scroll == null:
		return 0.0
	return result_scroll.custom_minimum_size.y


func get_settings_volume_value() -> float:
	return settings_volume_slider.value / 100.0


func get_settings_sfx_volume_value() -> float:
	return settings_sfx_volume_slider.value / 100.0


func get_settings_music_volume_value() -> float:
	return settings_music_volume_slider.value / 100.0


func get_settings_fullscreen_enabled() -> bool:
	return settings_fullscreen_check.button_pressed


func get_settings_resolution_index() -> int:
	return settings_resolution_option.selected


func get_settings_aim_assist_enabled() -> bool:
	return settings_aim_assist_check != null and settings_aim_assist_check.button_pressed


func get_settings_aim_assist_strength() -> float:
	if settings_aim_assist_slider == null:
		return 0.0
	return settings_aim_assist_slider.value / 100.0


func get_settings_aim_assist_band_text() -> String:
	if settings_aim_assist_band_label == null:
		return ""
	return settings_aim_assist_band_label.text


func get_settings_aim_assist_active_preset_text() -> String:
	for key in settings_aim_assist_preset_buttons.keys():
		var button = settings_aim_assist_preset_buttons[key]
		if button is Button and (button as Button).button_pressed:
			return (button as Button).text
	return ""


func choose_settings_aim_assist_preset_for_test(band: String) -> void:
	_apply_aim_assist_preset(band)


func get_settings_low_health_feedback_intensity() -> float:
	if settings_low_health_feedback_slider == null:
		return LOW_HEALTH_FEEDBACK.DEFAULT_FEEDBACK_INTENSITY
	return settings_low_health_feedback_slider.value / 100.0


func get_settings_screen_shake_intensity() -> float:
	if settings_screen_shake_slider == null:
		return 1.0
	return settings_screen_shake_slider.value / 100.0


func get_settings_damage_flash_intensity() -> float:
	if settings_damage_flash_slider == null:
		return 1.0
	return settings_damage_flash_slider.value / 100.0


func get_settings_combat_text_intensity() -> float:
	if settings_combat_text_slider == null:
		return 1.0
	return settings_combat_text_slider.value / 100.0


func get_settings_controller_aim_deadzone() -> float:
	if settings_controller_aim_deadzone_slider == null:
		return CONTROLLER_LAYOUT.get_aim_deadzone()
	return settings_controller_aim_deadzone_slider.value / 100.0


func get_settings_controller_input_switch_threshold() -> float:
	if settings_controller_input_switch_slider == null:
		return CONTROLLER_LAYOUT.get_input_switch_threshold()
	return settings_controller_input_switch_slider.value / 100.0


func get_settings_controller_aim_deadzone_text_for_test() -> String:
	if settings_controller_aim_deadzone_value_label == null:
		return ""
	return settings_controller_aim_deadzone_value_label.text


func get_settings_controller_input_switch_text_for_test() -> String:
	if settings_controller_input_switch_value_label == null:
		return ""
	return settings_controller_input_switch_value_label.text


func get_control_rebind_button_text(action_name: String) -> String:
	var button = _settings_control_buttons.get(action_name)
	if button is Button:
		return (button as Button).text
	return ""


func get_input_hint_text() -> String:
	return input_hint_label.text


func get_controller_layout_hint_for_test() -> String:
	return _format_controller_layout_hint()


func get_settings_controller_layout_text_for_test() -> String:
	if settings_controller_layout_label == null:
		return ""
	return settings_controller_layout_label.text


func get_input_hint_device_for_test() -> String:
	return _input_hint_device


func set_input_hint_device_for_test(device: String) -> void:
	_set_input_hint_device(device)


func simulate_input_hint_event_for_test(event: InputEvent) -> void:
	_update_input_hint_device_from_event(event)


func set_settings_for_test(master_volume: float, sfx_volume = null, music_volume = null, fullscreen = null, resolution_index = null, aim_assist_enabled = null, aim_assist_strength = null, low_health_feedback_intensity = null, screen_shake_intensity = null, damage_flash_intensity = null, combat_text_intensity = null, controller_aim_deadzone = null, controller_input_switch_threshold = null) -> void:
	update_settings_controls(master_volume, sfx_volume, music_volume, fullscreen, resolution_index, aim_assist_enabled, aim_assist_strength, low_health_feedback_intensity, screen_shake_intensity, damage_flash_intensity, combat_text_intensity, controller_aim_deadzone, controller_input_switch_threshold)


func choose_relic_for_test(index: int) -> void:
	_select_relic_choice(index)


func choose_talent_for_test(index: int) -> void:
	_select_relic_choice(index)


func choose_blessing_for_test(index: int) -> void:
	_select_relic_choice(index)


func choose_statue_for_test(index: int) -> void:
	_select_relic_choice(index)


func _update_responsive_layout() -> void:
	if not is_node_ready():
		return

	var viewport_size := get_viewport_rect().size
	_fit_centered_panel(main_menu_panel, MAIN_MENU_PANEL_SIZE, viewport_size)
	_fit_centered_panel(pause_panel, PAUSE_PANEL_SIZE, viewport_size)
	_fit_centered_panel(settings_panel, SETTINGS_PANEL_SIZE, viewport_size)
	_fit_centered_panel(result_panel, RESULT_PANEL_SIZE, viewport_size)
	_fit_centered_panel(relic_choice_panel, RELIC_CHOICE_PANEL_SIZE, viewport_size)
	_fit_centered_panel(debug_map_panel, DEBUG_MAP_PANEL_SIZE, viewport_size)
	if lobby_screen != null:
		lobby_screen.call("update_layout", viewport_size, UI_SAFE_MARGIN)
	elif hall_panel != null:
		_fit_centered_panel(hall_panel, HALL_PANEL_SIZE, viewport_size)
	_fit_input_hint_panel(viewport_size)


func _fit_centered_panel(panel: Control, preferred_size: Vector2, viewport_size: Vector2) -> void:
	var max_size := Vector2(
		maxf(viewport_size.x - UI_SAFE_MARGIN * 2.0, 1.0),
		maxf(viewport_size.y - UI_SAFE_MARGIN * 2.0, 1.0)
	)
	var fitted_size := Vector2(
		minf(preferred_size.x, max_size.x),
		minf(preferred_size.y, max_size.y)
	)
	panel.offset_left = -roundf(fitted_size.x * 0.5)
	panel.offset_right = roundf(fitted_size.x * 0.5)
	panel.offset_top = -roundf(fitted_size.y * 0.5)
	panel.offset_bottom = roundf(fitted_size.y * 0.5)


func _fit_input_hint_panel(viewport_size: Vector2) -> void:
	var width := clampf(viewport_size.x * 0.46, 360.0, 600.0)
	var height := 42.0
	if width < 430.0:
		height = 54.0
	input_hint_panel.offset_left = -width - 16.0
	input_hint_panel.offset_right = -16.0
	input_hint_panel.offset_top = -height - 14.0
	input_hint_panel.offset_bottom = -14.0


func _refresh_input_hint_panel_visibility() -> void:
	if not is_node_ready():
		return
	input_hint_panel.visible = not (
		main_menu_panel.visible
		or pause_panel.visible
		or settings_panel.visible
		or result_panel.visible
		or relic_choice_panel.visible
		or debug_map_panel.visible
		or (lobby_screen != null and bool(lobby_screen.get("visible")))
		or (lobby_screen == null and hall_panel != null and hall_panel.visible)
	)


func _make_minimap_marker(record: Dictionary, current_room_id: String) -> Control:
	var room_id := str(record.get("id", ""))
	var room_type := str(record.get("room_type", "combat"))
	var biome_index := int(record.get("biome_index", 1))
	var biome_name := str(record.get("biome_name", "Layer %d" % biome_index))
	var visited := bool(record.get("visited", false))
	var cleared := bool(record.get("cleared", false))
	var is_current := room_id == current_room_id

	var marker := PanelContainer.new()
	marker.set_meta("room_marker", true)
	var marker_icon := _get_room_marker_text(room_type)
	var marker_label := _get_room_marker_label(room_type)
	var marker_state := _get_room_marker_state_text(visited, cleared, is_current)
	var marker_icon_key := _get_room_marker_icon_key(room_type)
	var marker_icon_texture_path := CONTENT_ICON_REGISTRY.get_texture_path(marker_icon_key, "rooms")
	var marker_texture := _load_texture_2d(marker_icon_texture_path)
	var marker_color := _get_minimap_marker_color(room_type, visited, cleared, is_current)
	var marker_tooltip := "L%d %s\n%s | %s | %s" % [biome_index, biome_name, room_id, marker_label, marker_state]
	marker.set_meta("room_id", room_id)
	marker.set_meta("biome_index", biome_index)
	marker.set_meta("biome_name", biome_name)
	marker.set_meta("room_type", room_type)
	marker.set_meta("room_icon", marker_icon)
	marker.set_meta("room_icon_key", marker_icon_key)
	marker.set_meta("room_icon_texture_path", marker_icon_texture_path)
	marker.set_meta("room_icon_texture_visible", marker_texture != null)
	marker.set_meta("room_label", marker_label)
	marker.set_meta("room_state", marker_state)
	marker.set_meta("room_state_key", "%s|%s|%s" % [visited, cleared, is_current])
	marker.custom_minimum_size = Vector2(24, 22)
	marker.tooltip_text = marker_tooltip
	marker.mouse_filter = Control.MOUSE_FILTER_PASS
	_apply_minimap_marker_style(marker, marker_color, visited, cleared, is_current)

	var center := CenterContainer.new()
	center.name = "MinimapMarkerCenter"
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marker.add_child(center)

	var icon_texture := TextureRect.new()
	icon_texture.name = "MinimapMarkerTexture"
	icon_texture.custom_minimum_size = Vector2(18, 18)
	icon_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_texture.texture = marker_texture
	icon_texture.visible = marker_texture != null
	icon_texture.tooltip_text = marker_tooltip
	icon_texture.modulate = _get_minimap_marker_icon_modulate(visited, cleared, is_current)
	center.add_child(icon_texture)

	var fallback_label := Label.new()
	fallback_label.name = "MinimapMarkerFallback"
	fallback_label.text = marker_icon
	fallback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fallback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fallback_label.visible = marker_texture == null
	fallback_label.tooltip_text = marker_tooltip
	fallback_label.add_theme_font_size_override("font_size", 12 if marker_icon.length() > 1 else 13)
	fallback_label.add_theme_color_override("font_color", marker_color)
	center.add_child(fallback_label)

	return marker


func _update_minimap_marker(marker: PanelContainer, record: Dictionary, current_room_id: String) -> void:
	var room_id := str(record.get("id", ""))
	var visited := bool(record.get("visited", false))
	var cleared := bool(record.get("cleared", false))
	var is_current := room_id == current_room_id
	var state_key := "%s|%s|%s" % [visited, cleared, is_current]
	if str(marker.get_meta("room_state_key", "")) == state_key:
		return

	var room_type := str(record.get("room_type", marker.get_meta("room_type", "combat")))
	var biome_index := int(record.get("biome_index", marker.get_meta("biome_index", 1)))
	var biome_name := str(record.get("biome_name", marker.get_meta("biome_name", "Layer %d" % biome_index)))
	var marker_label := str(marker.get_meta("room_label", _get_room_marker_label(room_type)))
	var marker_state := _get_room_marker_state_text(visited, cleared, is_current)
	var marker_color := _get_minimap_marker_color(room_type, visited, cleared, is_current)
	var marker_tooltip := "L%d %s\n%s | %s | %s" % [biome_index, biome_name, room_id, marker_label, marker_state]
	marker.set_meta("room_state", marker_state)
	marker.set_meta("room_state_key", state_key)
	marker.tooltip_text = marker_tooltip
	_apply_minimap_marker_style(marker, marker_color, visited, cleared, is_current)

	var icon_texture := marker.get_node_or_null("MinimapMarkerCenter/MinimapMarkerTexture") as TextureRect
	if icon_texture != null:
		icon_texture.tooltip_text = marker_tooltip
		icon_texture.modulate = _get_minimap_marker_icon_modulate(visited, cleared, is_current)
	var fallback_label := marker.get_node_or_null("MinimapMarkerCenter/MinimapMarkerFallback") as Label
	if fallback_label != null:
		fallback_label.tooltip_text = marker_tooltip
		fallback_label.add_theme_color_override("font_color", marker_color)


func _make_minimap_biome_layer(record: Dictionary) -> VBoxContainer:
	var biome_index := int(record.get("biome_index", 1))
	var biome_name := str(record.get("biome_name", "Layer %d" % biome_index))
	var layer := VBoxContainer.new()
	layer.name = "MinimapLayer%d" % biome_index
	layer.set_meta("biome_layer", true)
	layer.set_meta("biome_index", biome_index)
	layer.set_meta("biome_name", biome_name)
	layer.set_meta("biome_layer_text", "L%d %s" % [biome_index, biome_name])
	layer.custom_minimum_size = Vector2(84, 44)
	layer.tooltip_text = "Layer %d\n%s" % [biome_index, biome_name]
	layer.add_theme_constant_override("separation", 1)

	var label := _make_minimap_biome_label(record)
	layer.add_child(label)

	var marker_row := HBoxContainer.new()
	marker_row.name = "MinimapLayerMarkers"
	marker_row.alignment = BoxContainer.ALIGNMENT_CENTER
	marker_row.add_theme_constant_override("separation", 2)
	layer.add_child(marker_row)

	return layer


func _make_minimap_biome_label(record: Dictionary) -> Label:
	var biome_index := int(record.get("biome_index", 1))
	var biome_name := str(record.get("biome_name", "Layer %d" % biome_index))
	var label := Label.new()
	label.text = "L%d %s" % [biome_index, biome_name]
	label.tooltip_text = biome_name
	label.custom_minimum_size = Vector2(84, 18)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.clip_text = true
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color(0.74, 0.78, 0.86, 1.0))
	return label


func _select_relic_choice(index: int) -> void:
	if index < 0 or index >= _active_relic_choices.size():
		return

	var choice_kind := _active_choice_kind
	hide_relic_choices()
	if choice_kind == "talent":
		_confirm_talent_choice(index)
		talent_choice_selected.emit(index)
	elif choice_kind == "blessing":
		_confirm_blessing_choice(index)
		blessing_choice_selected.emit(index)
	elif choice_kind == "statue":
		_confirm_statue_choice(index)
		statue_choice_selected.emit(index)
	else:
		_confirm_relic_choice(index)
		relic_choice_selected.emit(index)


func _confirm_relic_choice(index: int) -> void:
	var receivers := [
		relic_choice_receiver,
		get_tree().get_first_node_in_group("game_root"),
		get_tree().root.find_child("Main", true, false),
	]
	for receiver in receivers:
		if is_instance_valid(receiver) and receiver.has_method("choose_relic_reward"):
			receiver.call("choose_relic_reward", index)
			return


func _confirm_talent_choice(index: int) -> void:
	var receivers := [
		relic_choice_receiver,
		get_tree().get_first_node_in_group("game_root"),
		get_tree().root.find_child("Main", true, false),
	]
	for receiver in receivers:
		if is_instance_valid(receiver) and receiver.has_method("choose_talent_reward"):
			receiver.call("choose_talent_reward", index)
			return


func _confirm_blessing_choice(index: int) -> void:
	var receivers := [
		relic_choice_receiver,
		get_tree().get_first_node_in_group("game_root"),
		get_tree().root.find_child("Main", true, false),
	]
	for receiver in receivers:
		if is_instance_valid(receiver) and receiver.has_method("choose_blessing_reward"):
			receiver.call("choose_blessing_reward", index)
			return


func _confirm_statue_choice(index: int) -> void:
	var receivers := [
		relic_choice_receiver,
		get_tree().get_first_node_in_group("game_root"),
		get_tree().root.find_child("Main", true, false),
	]
	for receiver in receivers:
		if is_instance_valid(receiver) and receiver.has_method("choose_statue_reward"):
			receiver.call("choose_statue_reward", index)
			return


func _on_relic_choice_button_pressed(index: int) -> void:
	_select_relic_choice(index)


func _format_relic_choice(relic: Resource) -> String:
	if relic == null:
		return "Unknown Relic"

	var rarity := str(relic.get("rarity")).capitalize()
	var tags := _format_relic_tags(relic)
	return "%s [%s]\n%s\n%s" % [
		str(relic.get("display_name")),
		rarity,
		tags,
		str(relic.get("description")),
	]


func _format_relic_tooltip(relic: Resource) -> String:
	if relic == null:
		return "Unknown Relic"

	return "%s\nRarity: %s\nTags: %s\n%s" % [
		str(relic.get("display_name")),
		str(relic.get("rarity")).capitalize(),
		_format_relic_tags(relic),
		str(relic.get("description")),
	]


func _format_talent_choice(talent: Resource) -> String:
	if talent == null:
		return "Unknown Talent"

	var rarity := str(talent.get("rarity")).capitalize()
	var tags := _format_talent_tags(talent)
	return "%s [%s]\n%s\n%s" % [
		str(talent.get("display_name")),
		rarity,
		tags,
		str(talent.get("description")),
	]


func _format_talent_tooltip(talent: Resource) -> String:
	if talent == null:
		return "Unknown Talent"

	return "%s\nRarity: %s\nDuration: %s\nTags: %s\n%s" % [
		str(talent.get("display_name")),
		str(talent.get("rarity")).capitalize(),
		str(talent.get("duration_scope")).capitalize(),
		_format_talent_tags(talent),
		str(talent.get("description")),
	]


func _format_blessing_choice(blessing: Resource) -> String:
	if blessing == null:
		return "Unknown Blessing"

	var rarity := str(blessing.get("rarity")).capitalize()
	var tags := _format_blessing_tags(blessing)
	return "%s [%s]\n%s\n%s" % [
		str(blessing.get("display_name")),
		rarity,
		tags,
		str(blessing.get("description")),
	]


func _format_blessing_tooltip(blessing: Resource) -> String:
	if blessing == null:
		return "Unknown Blessing"

	return "%s\nRarity: %s\nDuration: %s\nTrigger: %s\nTags: %s\n%s" % [
		str(blessing.get("display_name")),
		str(blessing.get("rarity")).capitalize(),
		str(blessing.get("duration_scope")).capitalize(),
		str(blessing.get("trigger_event")).replace("_", " ").capitalize(),
		_format_blessing_tags(blessing),
		str(blessing.get("rule_text")),
	]


func _format_statue_choice(statue: Resource) -> String:
	if statue == null:
		return "Unknown Statue"

	var rarity := str(statue.get("rarity")).capitalize()
	var tags := _format_statue_tags(statue)
	return "%s [%s]\n%s\n%s" % [
		str(statue.get("display_name")),
		rarity,
		tags,
		str(statue.get("description")),
	]


func _format_statue_tooltip(statue: Resource) -> String:
	if statue == null:
		return "Unknown Statue"

	return "%s\nRarity: %s\nTrigger: %s\nInterval: %d\nTags: %s\n%s" % [
		str(statue.get("display_name")),
		str(statue.get("rarity")).capitalize(),
		str(statue.get("trigger_event")).replace("_", " ").capitalize(),
		maxi(int(statue.get("trigger_interval")), 1),
		_format_statue_tags(statue),
		str(statue.get("rule_text")),
	]


func _format_relic_tags(relic: Resource) -> String:
	if relic == null:
		return "Tags: None"

	var raw_tags = relic.get("tags")
	var formatted: PackedStringArray = []
	if raw_tags is PackedStringArray:
		for tag in raw_tags:
			formatted.append(str(tag).replace("_", " ").capitalize())
	elif raw_tags is Array:
		for tag in raw_tags:
			formatted.append(str(tag).replace("_", " ").capitalize())

	if formatted.is_empty():
		return "Tags: None"
	return "Tags: %s" % ", ".join(formatted)


func _format_talent_tags(talent: Resource) -> String:
	if talent == null:
		return "Tags: None"

	var raw_tags = talent.get("build_tags")
	var formatted: PackedStringArray = []
	if raw_tags is PackedStringArray:
		for tag in raw_tags:
			formatted.append(str(tag).replace("_", " ").capitalize())
	elif raw_tags is Array:
		for tag in raw_tags:
			formatted.append(str(tag).replace("_", " ").capitalize())

	if formatted.is_empty():
		return "Tags: None"
	return "Tags: %s" % ", ".join(formatted)


func _format_blessing_tags(blessing: Resource) -> String:
	if blessing == null:
		return "Tags: None"

	var raw_tags = blessing.get("build_tags")
	var formatted: PackedStringArray = []
	if raw_tags is PackedStringArray:
		for tag in raw_tags:
			formatted.append(str(tag).replace("_", " ").capitalize())
	elif raw_tags is Array:
		for tag in raw_tags:
			formatted.append(str(tag).replace("_", " ").capitalize())

	if formatted.is_empty():
		return "Tags: None"
	return "Tags: %s" % ", ".join(formatted)


func _format_statue_tags(statue: Resource) -> String:
	if statue == null:
		return "Tags: None"

	var raw_tags = statue.get("build_tags")
	var formatted: PackedStringArray = []
	if raw_tags is PackedStringArray:
		for tag in raw_tags:
			formatted.append(str(tag).replace("_", " ").capitalize())
	elif raw_tags is Array:
		for tag in raw_tags:
			formatted.append(str(tag).replace("_", " ").capitalize())

	if formatted.is_empty():
		return "Tags: None"
	return "Tags: %s" % ", ".join(formatted)


func _apply_relic_choice_style(button: Button, relic: Resource) -> void:
	var rarity := ""
	if relic != null:
		rarity = str(relic.get("rarity")).to_lower()
	var color: Color = _rarity_colors.get(rarity, Color.WHITE)
	button.add_theme_color_override("font_color", color)
	button.add_theme_color_override("font_hover_color", color.lightened(0.12))
	button.add_theme_color_override("font_pressed_color", color.darkened(0.1))
	button.add_theme_color_override("font_disabled_color", Color(0.45, 0.48, 0.52, 1.0))
	button.add_theme_color_override("font_outline_color", Color(0.02, 0.025, 0.03, 0.94))
	button.add_theme_constant_override("outline_size", 3)
	button.add_theme_font_size_override("font_size", 15)


func _apply_relic_choice_icon(button: Button, choice: Resource, choice_kind: String) -> void:
	var icon_key := _get_relic_choice_icon_key_for_resource(choice, choice_kind)
	var icon_page := _get_choice_icon_page(choice_kind)
	var texture_path := CONTENT_ICON_REGISTRY.get_texture_path(icon_key, icon_page)
	var loaded_texture: Texture2D = null
	if not texture_path.is_empty():
		var loaded_resource := load(texture_path)
		if loaded_resource is Texture2D:
			loaded_texture = loaded_resource

	button.icon = loaded_texture
	button.set("icon_alignment", HORIZONTAL_ALIGNMENT_LEFT)
	button.set("expand_icon", false)
	var display_name := str(choice.get("display_name")) if choice != null else "Choice"
	var icon_tooltip := CONTENT_ICON_REGISTRY.get_placeholder_tooltip(icon_key, display_name, icon_page)
	if button.tooltip_text.is_empty():
		button.tooltip_text = icon_tooltip
	elif not button.tooltip_text.contains(icon_key):
		button.tooltip_text = "%s\n%s" % [button.tooltip_text, icon_tooltip]


func _clear_relic_choice_button_icon(button: Button) -> void:
	button.icon = null
	button.tooltip_text = ""


func _get_active_choice_resource(index: int) -> Resource:
	if index < 0 or index >= _active_relic_choices.size():
		return null
	return _active_relic_choices[index] as Resource


func _get_relic_choice_icon_key_for_resource(choice: Resource, choice_kind: String) -> String:
	if choice == null:
		return ""

	var explicit_key := str(choice.get("icon_key")).strip_edges()
	if not explicit_key.is_empty():
		return explicit_key

	var choice_id := str(choice.get("id")).strip_edges()
	var content_type := _get_choice_content_type(choice_kind)
	if choice_id.is_empty() or content_type.is_empty():
		return ""
	return "%s_%s" % [content_type, choice_id]


func _get_choice_icon_page(choice_kind: String) -> String:
	match choice_kind.strip_edges().to_lower():
		"talent":
			return "talents"
		"blessing":
			return "blessings"
		"statue":
			return "statues"
	return "relics"


func _get_choice_content_type(choice_kind: String) -> String:
	match choice_kind.strip_edges().to_lower():
		"talent":
			return "talent"
		"blessing":
			return "blessing"
		"statue":
			return "statue"
	return "relic"


func _get_room_marker_text(room_type: String) -> String:
	match room_type:
		"start":
			return "S"
		"elite":
			return "EL"
		"challenge":
			return "CH"
		"trap":
			return "X"
		"reward":
			return "*"
		"event":
			return "!"
		"armory":
			return "W"
		"healing":
			return "+"
		"shop":
			return "$"
		"boss":
			return "B"
		"boss_placeholder":
			return "B"
	return "C"


func _get_room_marker_label(room_type: String) -> String:
	match room_type:
		"start":
			return "Start Room"
		"elite":
			return "Elite Room"
		"challenge":
			return "Challenge Room"
		"trap":
			return "Trap Room"
		"reward":
			return "Reward Room"
		"event":
			return "Event Room"
		"armory":
			return "Armory"
		"healing":
			return "Healing Room"
		"shop":
			return "Shop"
		"boss", "boss_placeholder":
			return "Boss Room"
	return "Combat Room"


func _get_room_marker_icon_key(room_type: String) -> String:
	match room_type:
		"start":
			return "room_start"
		"elite":
			return "room_elite"
		"challenge":
			return "room_challenge"
		"trap":
			return "room_trap"
		"reward":
			return "room_reward"
		"event":
			return "room_event"
		"armory":
			return "room_armory"
		"healing":
			return "room_healing"
		"shop":
			return "room_shop"
		"boss", "boss_placeholder":
			return "room_boss"
	return "room_combat"


func _get_room_marker_state_text(visited: bool, cleared: bool, is_current: bool) -> String:
	if is_current:
		return "Current"
	if cleared:
		return "Cleared"
	if visited:
		return "Visited"
	return "Unvisited"


func _get_minimap_marker_for_type(room_type: String) -> Control:
	for marker in _get_minimap_markers():
		if str(marker.get_meta("room_type", "")) == room_type:
			return marker as Control
	return null


func _get_minimap_markers() -> Array:
	if not _minimap_markers_by_room_id.is_empty():
		return _minimap_markers_by_room_id.values()
	return _collect_minimap_markers(minimap_row)


func _collect_minimap_markers(root: Node) -> Array:
	var markers := []
	for child in root.get_children():
		if child is Control and child.has_meta("room_marker") and bool(child.get_meta("room_marker")):
			markers.append(child)
		markers.append_array(_collect_minimap_markers(child))
	return markers


func _get_minimap_layer_for_biome(biome_index: int) -> Control:
	for child in minimap_row.get_children():
		if child is Control and child.has_meta("biome_layer") and bool(child.get_meta("biome_layer")) and int(child.get_meta("biome_index", 0)) == biome_index:
			return child as Control
	return null


func _apply_minimap_marker_style(marker: PanelContainer, marker_color: Color, visited: bool, cleared: bool, is_current: bool) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.08, 0.11, 0.68)
	style.border_color = marker_color
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	if is_current:
		style.bg_color = Color(0.18, 0.15, 0.06, 0.9)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
	elif cleared:
		style.bg_color = Color(0.06, 0.15, 0.1, 0.78)
	elif visited:
		style.bg_color = Color(0.07, 0.11, 0.16, 0.78)
	marker.add_theme_stylebox_override("panel", style)


func _get_minimap_marker_icon_modulate(visited: bool, cleared: bool, is_current: bool) -> Color:
	if is_current:
		return Color(1.0, 1.0, 1.0, 1.0)
	if cleared:
		return Color(0.92, 1.0, 0.94, 0.92)
	if visited:
		return Color(0.82, 0.9, 1.0, 0.86)
	return Color(0.72, 0.76, 0.82, 0.72)


func _get_minimap_marker_color(room_type: String, visited: bool, cleared: bool, is_current: bool) -> Color:
	if is_current:
		return Color(1.0, 0.86, 0.25, 1.0)
	if cleared:
		return Color(0.34, 1.0, 0.58, 1.0)
	if visited:
		return Color(0.5, 0.76, 1.0, 1.0)
	if room_type == "reward":
		return Color(1.0, 0.82, 0.28, 0.9)
	if room_type == "event":
		return Color(0.86, 0.42, 1.0, 0.9)
	if room_type == "armory":
		return Color(0.32, 0.72, 1.0, 0.9)
	if room_type == "healing":
		return Color(0.42, 1.0, 0.54, 0.9)
	if room_type == "shop":
		return Color(0.32, 1.0, 0.82, 0.9)
	if room_type == "boss" or room_type == "boss_placeholder":
		return Color(1.0, 0.3, 0.25, 0.85)
	if room_type == "elite":
		return Color(0.95, 0.5, 1.0, 0.85)
	if room_type == "challenge":
		return Color(1.0, 0.55, 0.28, 0.88)
	if room_type == "trap":
		return Color(1.0, 0.42, 0.16, 0.88)
	return Color(0.45, 0.48, 0.52, 0.8)


func _format_run_summary(summary: Dictionary) -> String:
	var history: Dictionary = summary.get("history", {})
	var meta: Dictionary = summary.get("meta_progression", {})
	var relic_names: Array = summary.get("relic_names", [])
	var talent_names: Array = summary.get("talent_names", [])
	var blessing_names: Array = summary.get("blessing_names", [])
	var statue_names: Array = summary.get("statue_names", [])
	var event_names: Array = summary.get("event_names", [])
	var loadout_names: Array = summary.get("loadout", [])
	var primary_build_routes: Array = summary.get("primary_build_routes", [])
	var defeated_boss_names: Array = summary.get("defeated_boss_names", [])
	var boss_route: Array = summary.get("boss_route", [])
	var special_room_count_text := str(summary.get("special_room_count_text", "None"))
	var boss_route_text := _format_boss_route(boss_route)
	var position_label := _get_run_position_label(summary)
	var position_text := str(summary.get("run_position_text", "Unknown"))
	var last_damage_text := str(summary.get("last_damage_text", "None"))
	var defeat_cause_text := str(summary.get("defeat_cause_text", "None"))
	return "Result: %s\nSeed: %d\nRooms: %d | Kills: %d | Time: %s\nBiomes: %d/%d (%s) | Bosses: %d\nRoute: %s\nBoss Route: %s\n%s: %s\nLast Hit: %s\nDefeat Cause: %s\nSpecial Rooms: %s\nGold: %d (earned %d / spent %d)\nCharacter: %s\nWeapon: %s\nLoadout: %s\nBuild Routes: %s\nRelics: %s\nTalents: %s\nBlessings: %s\nBlessing Triggers: %d\nStatues: %s\nStatue Triggers: %d | Attunes: %d\nRelic Stacks: %d\nSurvival: HP %d/%d | Shield %d | HP Damage %d\nCombat: Crits %d | Healing %d | Shield Blocked %d | Projectiles Blocked %d\nLoot: Rewards %d | Chests %d | Shop Buys %d | Events %d\nEvent Outcomes: %s\nBoss Defeated: %s (%s)\nRecord: Runs %d | Wins %d | Best Biome %d | Best Rooms %d | Best Kills %d | Best Gold %d | Best Guard Blocks %d\nMeta: +%d %s | Total %d | Mastery +%d XP" % [
		str(summary.get("result", "In Progress")),
		int(summary.get("dungeon_seed", 0)),
		int(summary.get("rooms_cleared", 0)),
		int(summary.get("kills", 0)),
		_format_seconds(int(summary.get("elapsed_seconds", 0))),
		int(summary.get("biomes_reached", 1)),
		int(summary.get("total_biomes", 1)),
		str(summary.get("reached_biome_name", "Layer 1")),
		int(summary.get("bosses_defeated", 0)),
		str(summary.get("route_signature", "Unvisited")),
		boss_route_text,
		position_label,
		position_text,
		last_damage_text,
		defeat_cause_text,
		special_room_count_text,
		int(summary.get("gold", 0)),
		int(summary.get("gold_earned", 0)),
		int(summary.get("gold_spent", 0)),
		str(summary.get("character", "Adventurer")),
		str(summary.get("weapon", "Unarmed")),
		_format_name_list(loadout_names),
		_format_name_list(primary_build_routes),
		_format_name_list(relic_names),
		_format_name_list(talent_names),
		_format_name_list(blessing_names),
		int(summary.get("blessing_trigger_count", 0)),
		_format_name_list(statue_names),
		int(summary.get("statue_trigger_count", 0)),
		int(summary.get("statue_attunement_count", 0)),
		int(summary.get("relic_stacks", relic_names.size())),
		int(summary.get("current_hp", 0)),
		int(summary.get("max_hp", 0)),
		int(summary.get("shield", 0)),
		int(summary.get("damage_taken", 0)),
		int(summary.get("critical_hits", 0)),
		int(summary.get("healing_received", 0)),
		int(summary.get("shield_absorbed", 0)),
		int(summary.get("projectiles_blocked", 0)),
		int(summary.get("rewards_collected", 0)),
		int(summary.get("chests_opened", 0)),
		int(summary.get("shop_purchases", 0)),
		int(summary.get("events_resolved", 0)),
		_format_name_list(event_names),
		"Yes" if summary.get("boss_defeated", false) == true else "No",
		_format_name_list(defeated_boss_names),
		int(history.get("runs", 0)),
		int(history.get("victories", 0)),
		int(history.get("best_biome", 0)),
		int(history.get("best_rooms", 0)),
		int(history.get("best_kills", 0)),
		int(history.get("best_gold", 0)),
		int(history.get("best_projectiles_blocked", 0)),
		int(summary.get("meta_currency_awarded", 0)),
		str(meta.get("currency_name", "Data Shards")),
		int(meta.get("currency", 0)),
		int(summary.get("character_mastery_xp_awarded", 0)),
	]


func _setup_hall_panel() -> void:
	if lobby_screen != null:
		return

	hall_button = Button.new()
	hall_button.name = "HallArchiveButton"
	hall_button.custom_minimum_size = Vector2(0, 34)
	hall_button.text = "Outpost / Records"
	hall_button.pressed.connect(_on_hall_button_pressed)
	main_menu_vbox.add_child(hall_button)
	main_menu_vbox.move_child(hall_button, main_settings_button.get_index())

	lobby_screen = LOBBY_SCREEN_SCENE.instantiate()
	lobby_screen.name = "LobbyScreen"
	lobby_screen.visible = false
	lobby_screen.connect("start_requested", Callable(self, "_on_lobby_start_requested"))
	lobby_screen.connect("training_requested", Callable(self, "_on_lobby_training_requested"))
	lobby_screen.connect("settings_requested", Callable(self, "_on_lobby_settings_requested"))
	lobby_screen.connect("previous_character_requested", Callable(self, "_on_lobby_previous_character_requested"))
	lobby_screen.connect("next_character_requested", Callable(self, "_on_lobby_next_character_requested"))
	lobby_screen.connect("unlock_character_requested", Callable(self, "_on_lobby_unlock_character_requested"))
	lobby_screen.connect("back_requested", Callable(self, "_on_hall_close_button_pressed"))
	add_child(lobby_screen)
	hall_panel = lobby_screen as Control
	hall_summary_label = lobby_screen.call("get_archive_label") as Label
	hall_close_button = lobby_screen.call("get_back_button") as Button


func _setup_character_unlock_button() -> void:
	if character_unlock_button != null:
		return

	character_unlock_button = Button.new()
	character_unlock_button.name = "UnlockCharacterButton"
	character_unlock_button.custom_minimum_size = Vector2(0, 34)
	character_unlock_button.text = "Unlocked"
	character_unlock_button.disabled = true
	character_unlock_button.pressed.connect(_on_unlock_character_button_pressed)
	main_menu_vbox.add_child(character_unlock_button)
	main_menu_vbox.move_child(character_unlock_button, start_button.get_index())


func _setup_training_button() -> void:
	if training_button != null:
		return

	training_button = Button.new()
	training_button.name = "TrainingRoomButton"
	training_button.custom_minimum_size = Vector2(0, 34)
	training_button.text = "Training Room"
	training_button.tooltip_text = "Practice the selected character without recording a run"
	training_button.pressed.connect(_on_training_button_pressed)
	main_menu_vbox.add_child(training_button)
	main_menu_vbox.move_child(training_button, main_settings_button.get_index())


func _setup_training_panel() -> void:
	if training_panel != null:
		return

	training_panel = PanelContainer.new()
	training_panel.name = "TrainingPanel"
	training_panel.visible = false
	training_panel.layout_mode = 1
	training_panel.anchor_left = 0.5
	training_panel.anchor_top = 0.0
	training_panel.anchor_right = 0.5
	training_panel.anchor_bottom = 0.0
	training_panel.offset_left = -216.0
	training_panel.offset_top = 12.0
	training_panel.offset_right = 216.0
	training_panel.offset_bottom = 212.0
	training_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(training_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	training_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "Training"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.28, 1.0))
	title.add_theme_font_size_override("font_size", 15)
	vbox.add_child(title)

	training_drill_label = Label.new()
	training_drill_label.text = "Basics"
	training_drill_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	training_drill_label.add_theme_color_override("font_color", Color(0.52, 0.82, 1.0, 1.0))
	training_drill_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(training_drill_label)

	training_guide_label = Label.new()
	training_guide_label.text = "Compare close, mid, and far target damage."
	training_guide_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	training_guide_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	training_guide_label.add_theme_color_override("font_color", Color(0.78, 0.86, 0.9, 1.0))
	training_guide_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(training_guide_label)

	training_goal_label = Label.new()
	training_goal_label.text = "Goal: Hit all targets 0/3"
	training_goal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	training_goal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	training_goal_label.add_theme_color_override("font_color", Color(0.78, 1.0, 0.86, 1.0))
	training_goal_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(training_goal_label)

	training_rating_label = Label.new()
	training_rating_label.text = "Rating: Practice"
	training_rating_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	training_rating_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.28, 1.0))
	training_rating_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(training_rating_label)

	training_badge_label = Label.new()
	training_badge_label.text = "Badge: None [--]"
	training_badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	training_badge_label.add_theme_color_override("font_color", Color(0.98, 0.86, 0.52, 1.0))
	training_badge_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(training_badge_label)

	training_aim_assist_label = Label.new()
	training_aim_assist_label.text = "Aim Assist: Off 35% | Band Off | Targets Training"
	training_aim_assist_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	training_aim_assist_label.add_theme_color_override("font_color", Color(0.62, 0.96, 0.9, 1.0))
	training_aim_assist_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(training_aim_assist_label)

	training_aim_assist_preset_row = _create_training_aim_assist_preset_row()
	vbox.add_child(training_aim_assist_preset_row)

	training_stats_label = Label.new()
	training_stats_label.text = "Targets 0 | Types None | Hits 0 | Damage 0 | Best 0"
	training_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	training_stats_label.add_theme_color_override("font_color", Color(0.86, 0.94, 1.0, 1.0))
	training_stats_label.add_theme_font_size_override("font_size", 13)
	vbox.add_child(training_stats_label)

	var button_row := HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 8)
	vbox.add_child(button_row)

	training_next_drill_button = Button.new()
	training_next_drill_button.custom_minimum_size = Vector2(0, 30)
	training_next_drill_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	training_next_drill_button.text = "Next Drill"
	training_next_drill_button.pressed.connect(_on_training_next_drill_button_pressed)
	button_row.add_child(training_next_drill_button)

	training_reset_button = Button.new()
	training_reset_button.custom_minimum_size = Vector2(0, 30)
	training_reset_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	training_reset_button.text = "Reset Training"
	training_reset_button.pressed.connect(_on_training_reset_button_pressed)
	button_row.add_child(training_reset_button)


func _setup_training_reward_panel() -> void:
	if training_reward_panel != null:
		return

	training_reward_panel = PanelContainer.new()
	training_reward_panel.name = "TrainingRewardToast"
	training_reward_panel.visible = false
	training_reward_panel.layout_mode = 1
	training_reward_panel.anchor_left = 0.5
	training_reward_panel.anchor_top = 0.0
	training_reward_panel.anchor_right = 0.5
	training_reward_panel.anchor_bottom = 0.0
	training_reward_panel.offset_left = -190.0
	training_reward_panel.offset_top = 224.0
	training_reward_panel.offset_right = 190.0
	training_reward_panel.offset_bottom = 292.0
	training_reward_panel.pivot_offset = Vector2(190.0, 34.0)
	training_reward_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	training_reward_panel.z_index = 12
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.1, 0.13, 0.94)
	panel_style.border_color = Color(1.0, 0.82, 0.28, 0.95)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.corner_radius_top_left = 6
	panel_style.corner_radius_top_right = 6
	panel_style.corner_radius_bottom_left = 6
	panel_style.corner_radius_bottom_right = 6
	training_reward_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(training_reward_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 8)
	training_reward_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	margin.add_child(vbox)

	training_reward_title_label = Label.new()
	training_reward_title_label.text = "TRAINING BADGE"
	training_reward_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	training_reward_title_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.32, 1.0))
	training_reward_title_label.add_theme_font_size_override("font_size", 13)
	vbox.add_child(training_reward_title_label)

	training_reward_body_label = Label.new()
	training_reward_body_label.text = "Basics | Clear [CL]"
	training_reward_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	training_reward_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	training_reward_body_label.add_theme_color_override("font_color", Color(0.9, 0.98, 1.0, 1.0))
	training_reward_body_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(training_reward_body_label)


func _setup_result_sections() -> void:
	result_summary_label.visible = false
	if result_detail_toggle_button == null:
		result_detail_toggle_button = result_vbox.get_node_or_null("ResultDetailToggleButton") as Button
	if result_detail_toggle_button == null:
		result_detail_toggle_button = Button.new()
		result_detail_toggle_button.name = "ResultDetailToggleButton"
		result_detail_toggle_button.custom_minimum_size = Vector2(0, 30)
		result_detail_toggle_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		result_detail_toggle_button.pressed.connect(_on_result_detail_toggle_button_pressed)
		result_vbox.add_child(result_detail_toggle_button)
		result_vbox.move_child(result_detail_toggle_button, result_summary_label.get_index() + 1)
	_refresh_result_detail_mode()

	if result_vbox.get_node_or_null("ResultScroll") != null:
		return

	result_scroll = ScrollContainer.new()
	result_scroll.name = "ResultScroll"
	result_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	result_scroll.custom_minimum_size = Vector2(0, 320)
	result_scroll.follow_focus = true
	result_vbox.add_child(result_scroll)
	result_vbox.move_child(result_scroll, result_detail_toggle_button.get_index() + 1)

	result_sections_grid = GridContainer.new()
	result_sections_grid.name = "ResultSections"
	result_sections_grid.columns = 2
	result_sections_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result_sections_grid.add_theme_constant_override("h_separation", 18)
	result_sections_grid.add_theme_constant_override("v_separation", 5)
	result_scroll.add_child(result_sections_grid)

	for section_name in RESULT_SECTION_NAMES:
		_add_result_section_row(result_sections_grid, section_name)
	_refresh_result_detail_mode()


func _setup_damage_flash_overlay() -> void:
	if _damage_flash_overlay != null:
		return

	_damage_flash_overlay = ColorRect.new()
	_damage_flash_overlay.name = "DamageFlashOverlay"
	_damage_flash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_damage_flash_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_damage_flash_overlay.offset_left = 0.0
	_damage_flash_overlay.offset_top = 0.0
	_damage_flash_overlay.offset_right = 0.0
	_damage_flash_overlay.offset_bottom = 0.0
	_damage_flash_overlay.z_index = 240
	_damage_flash_overlay.visible = false
	_damage_flash_overlay.color = Color(1.0, 0.08, 0.04, 0.0)
	add_child(_damage_flash_overlay)


func _refresh_damage_flash_overlay() -> void:
	if _damage_flash_overlay == null:
		_setup_damage_flash_overlay()
	if _damage_flash_overlay == null:
		return

	if _damage_flash_timer <= 0.0:
		_damage_flash_overlay.visible = false
		_damage_flash_overlay.color = Color(1.0, 0.08, 0.04, 0.0)
		return

	var progress := clampf(_damage_flash_timer / maxf(_damage_flash_duration, 0.05), 0.0, 1.0)
	_damage_flash_overlay.visible = true
	_damage_flash_overlay.color = Color(1.0, 0.08, 0.04, _damage_flash_alpha * progress)


func _setup_low_health_vignette() -> void:
	if not _low_health_vignette_edges.is_empty():
		return

	_low_health_vignette_edges.append(_create_low_health_vignette_edge("LowHealthVignetteTop", 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, LOW_HEALTH_VIGNETTE_EDGE_SIZE))
	_low_health_vignette_edges.append(_create_low_health_vignette_edge("LowHealthVignetteBottom", 0.0, 1.0, 1.0, 1.0, 0.0, -LOW_HEALTH_VIGNETTE_EDGE_SIZE, 0.0, 0.0))
	_low_health_vignette_edges.append(_create_low_health_vignette_edge("LowHealthVignetteLeft", 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, LOW_HEALTH_VIGNETTE_EDGE_SIZE, 0.0))
	_low_health_vignette_edges.append(_create_low_health_vignette_edge("LowHealthVignetteRight", 1.0, 0.0, 1.0, 1.0, -LOW_HEALTH_VIGNETTE_EDGE_SIZE, 0.0, 0.0, 0.0))
	_refresh_low_health_vignette()


func _create_low_health_vignette_edge(edge_name: String, anchor_left_value: float, anchor_top_value: float, anchor_right_value: float, anchor_bottom_value: float, offset_left_value: float, offset_top_value: float, offset_right_value: float, offset_bottom_value: float) -> ColorRect:
	var edge := ColorRect.new()
	edge.name = edge_name
	edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	edge.anchor_left = anchor_left_value
	edge.anchor_top = anchor_top_value
	edge.anchor_right = anchor_right_value
	edge.anchor_bottom = anchor_bottom_value
	edge.offset_left = offset_left_value
	edge.offset_top = offset_top_value
	edge.offset_right = offset_right_value
	edge.offset_bottom = offset_bottom_value
	edge.z_index = 220
	edge.visible = false
	edge.color = Color(1.0, 0.05, 0.04, 0.0)
	add_child(edge)
	return edge


func _update_low_health_vignette_state(was_low_health: bool, health_ratio: float) -> void:
	if _is_low_health:
		_low_health_vignette_target_alpha = _get_low_health_vignette_target_alpha(health_ratio)
		_low_health_vignette_pulse_speed = _get_low_health_vignette_pulse_speed(health_ratio)
		if not was_low_health or _low_health_vignette_alpha <= 0.01:
			_low_health_vignette_alpha = _low_health_vignette_target_alpha
			_low_health_vignette_pulse_timer = 0.0
	else:
		_low_health_vignette_target_alpha = 0.0
		_low_health_vignette_pulse_speed = LOW_HEALTH_VIGNETTE_PULSE_SPEED
	_refresh_low_health_vignette()


func _get_low_health_vignette_target_alpha(health_ratio: float) -> float:
	return LOW_HEALTH_FEEDBACK.interpolate_by_ratio(health_ratio, LOW_HEALTH_VIGNETTE_ALPHA, LOW_HEALTH_VIGNETTE_CRITICAL_ALPHA) * _low_health_feedback_intensity


func _get_low_health_vignette_pulse_speed(health_ratio: float) -> float:
	return LOW_HEALTH_FEEDBACK.interpolate_by_ratio(health_ratio, LOW_HEALTH_VIGNETTE_PULSE_SPEED, LOW_HEALTH_VIGNETTE_CRITICAL_PULSE_SPEED)


func _refresh_low_health_vignette() -> void:
	if _low_health_vignette_edges.is_empty():
		return

	var pulse := 0.0
	if _is_low_health and _low_health_vignette_alpha > 0.01:
		pulse = (sin(_low_health_vignette_pulse_timer) * 0.5 + 0.5) * LOW_HEALTH_VIGNETTE_PULSE_ALPHA * _low_health_feedback_intensity
	var max_display_alpha := (LOW_HEALTH_VIGNETTE_CRITICAL_ALPHA + LOW_HEALTH_VIGNETTE_PULSE_ALPHA) * _low_health_feedback_intensity
	_low_health_vignette_display_alpha = clampf(_low_health_vignette_alpha + pulse, 0.0, max_display_alpha)
	var visible := _low_health_vignette_display_alpha > 0.01
	for edge in _low_health_vignette_edges:
		if edge == null:
			continue
		edge.visible = visible
		edge.color = Color(1.0, 0.05, 0.04, _low_health_vignette_display_alpha)


func _has_visible_low_health_vignette_edge() -> bool:
	for edge in _low_health_vignette_edges:
		if edge != null and edge.visible:
			return true
	return false


func _add_result_section_row(parent: GridContainer, section_name: String) -> void:
	var title := Label.new()
	title.name = "%sTitle" % section_name
	title.custom_minimum_size = Vector2(82, 0)
	title.theme_type_variation = "HeaderSmall"
	title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.28, 1.0))
	title.add_theme_font_size_override("font_size", 13)
	title.text = section_name
	title.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	parent.add_child(title)
	_result_section_title_labels[section_name.to_lower()] = title

	var value := Label.new()
	value.name = "%sValue" % section_name
	value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	value.add_theme_color_override("font_color", Color(0.86, 0.94, 1.0, 1.0))
	value.add_theme_font_size_override("font_size", 13)
	value.text = "--"
	parent.add_child(value)
	_result_section_labels[section_name.to_lower()] = value


func _update_result_sections(summary: Dictionary) -> void:
	var history: Dictionary = summary.get("history", {})
	var meta: Dictionary = summary.get("meta_progression", {})
	var relic_names: Array = summary.get("relic_names", [])
	var talent_names: Array = summary.get("talent_names", [])
	var blessing_names: Array = summary.get("blessing_names", [])
	var statue_names: Array = summary.get("statue_names", [])
	var event_names: Array = summary.get("event_names", [])
	var loadout_names: Array = summary.get("loadout", [])
	var primary_build_routes: Array = summary.get("primary_build_routes", [])
	var defeated_boss_names: Array = summary.get("defeated_boss_names", [])
	var boss_route: Array = summary.get("boss_route", [])
	var special_room_count_text := str(summary.get("special_room_count_text", "None"))
	var boss_route_text := _format_boss_route(boss_route)
	var position_label := _get_run_position_label(summary)
	var position_text := str(summary.get("run_position_text", "Unknown"))
	var last_damage_text := str(summary.get("last_damage_text", "None"))
	var defeat_cause_text := str(summary.get("defeat_cause_text", "None"))
	_set_result_section(
		"overview",
		"Result: %s\nSeed %d\nRooms %d | Kills %d | Time %s\nBiomes %d/%d (%s) | Bosses %d\nRoute %s\nBoss Route %s\n%s %s\nLast Hit %s\nDefeat Cause %s\nSpecial Rooms %s" % [
			str(summary.get("result", "In Progress")),
			int(summary.get("dungeon_seed", 0)),
			int(summary.get("rooms_cleared", 0)),
			int(summary.get("kills", 0)),
			_format_seconds(int(summary.get("elapsed_seconds", 0))),
			int(summary.get("biomes_reached", 1)),
			int(summary.get("total_biomes", 1)),
			str(summary.get("reached_biome_name", "Layer 1")),
			int(summary.get("bosses_defeated", 0)),
			str(summary.get("route_signature", "Unvisited")),
			boss_route_text,
			position_label,
			position_text,
			last_damage_text,
			defeat_cause_text,
			special_room_count_text,
		]
	)
	_set_result_section(
		"build",
		"Character: %s\nWeapon: %s\nLoadout: %s\nBuild Routes: %s\nRelics: %s\nTalents: %s\nBlessings: %s\nBlessing Triggers: %d\nStatues: %s\nStatue Triggers: %d | Attunes: %d\nStacks: %d" % [
			str(summary.get("character", "Adventurer")),
			str(summary.get("weapon", "Unarmed")),
			_format_name_list(loadout_names),
			_format_name_list(primary_build_routes),
			_format_name_list(relic_names),
			_format_name_list(talent_names),
			_format_name_list(blessing_names),
			int(summary.get("blessing_trigger_count", 0)),
			_format_name_list(statue_names),
			int(summary.get("statue_trigger_count", 0)),
			int(summary.get("statue_attunement_count", 0)),
			int(summary.get("relic_stacks", relic_names.size())),
		]
	)
	_set_result_section(
		"survival",
		"HP %d/%d | Shield %d | HP Damage %d" % [
			int(summary.get("current_hp", 0)),
			int(summary.get("max_hp", 0)),
			int(summary.get("shield", 0)),
			int(summary.get("damage_taken", 0)),
		]
	)
	_set_result_section(
		"combat",
		"Crits %d | Healing %d | Shield Blocked %d | Projectiles Blocked %d" % [
			int(summary.get("critical_hits", 0)),
			int(summary.get("healing_received", 0)),
			int(summary.get("shield_absorbed", 0)),
			int(summary.get("projectiles_blocked", 0)),
		]
	)
	_set_result_section(
		"loot",
		"Gold %d (earned %d / spent %d)\nRewards %d | Chests %d | Shop Buys %d | Events %d | Boss %s\nEvent Outcomes: %s\nBosses: %s" % [
			int(summary.get("gold", 0)),
			int(summary.get("gold_earned", 0)),
			int(summary.get("gold_spent", 0)),
			int(summary.get("rewards_collected", 0)),
			int(summary.get("chests_opened", 0)),
			int(summary.get("shop_purchases", 0)),
			int(summary.get("events_resolved", 0)),
			"Yes" if summary.get("boss_defeated", false) == true else "No",
			_format_name_list(event_names),
			_format_name_list(defeated_boss_names),
		]
	)
	_set_result_section(
		"record",
		"Runs %d | Wins %d | Best Biome %d | Best Rooms %d | Best Kills %d | Best Gold %d | Best Guard Blocks %d\nMeta +%d %s | Total %d | Mastery +%d XP" % [
			int(history.get("runs", 0)),
			int(history.get("victories", 0)),
			int(history.get("best_biome", 0)),
			int(history.get("best_rooms", 0)),
			int(history.get("best_kills", 0)),
			int(history.get("best_gold", 0)),
			int(history.get("best_projectiles_blocked", 0)),
			int(summary.get("meta_currency_awarded", 0)),
			str(meta.get("currency_name", "Data Shards")),
			int(meta.get("currency", 0)),
			int(summary.get("character_mastery_xp_awarded", 0)),
		]
	)


func _set_result_section(section_name: String, text: String) -> void:
	var label = _result_section_labels.get(section_name)
	if label is Label:
		(label as Label).text = text


func _refresh_result_detail_mode() -> void:
	if result_detail_toggle_button != null:
		result_detail_toggle_button.text = "Compact" if _result_details_expanded else "Details"
	for key in _result_section_labels.keys():
		var visible := _result_details_expanded or RESULT_COMPACT_SECTION_KEYS.has(str(key))
		var title = _result_section_title_labels.get(key)
		if title is Label:
			(title as Label).visible = visible
		var label = _result_section_labels.get(key)
		if label is Label:
			(label as Label).visible = visible


func _format_boss_route(values: Array) -> String:
	var parts: PackedStringArray = []
	for value in values:
		if not value is Dictionary:
			continue
		var record := value as Dictionary
		var boss_name := str(record.get("boss_name", "")).strip_edges()
		if boss_name.is_empty():
			boss_name = "Boss"
		var biome_index := int(record.get("biome_index", parts.size() + 1))
		var state := "Cleared" if bool(record.get("cleared", false)) else "Seen" if bool(record.get("visited", false)) else "Pending"
		var final_suffix := " Final" if bool(record.get("is_final_boss", false)) else ""
		parts.append("L%d %s%s %s" % [biome_index, boss_name, final_suffix, state])
	return " | ".join(parts) if not parts.is_empty() else "None"


func _get_run_position_label(summary: Dictionary) -> String:
	return "Defeat Point" if str(summary.get("result", "")) == "Defeat" else "Run Position"


func _format_name_list(values: Array) -> String:
	if values.is_empty():
		return "None"

	var names: PackedStringArray = []
	for value in values:
		names.append(str(value))
	return ", ".join(names)


func _format_seconds(total_seconds: int) -> String:
	var seconds := maxi(total_seconds, 0)
	var minutes := seconds / 60
	var remainder := seconds % 60
	if minutes <= 0:
		return "%ds" % remainder
	return "%dm %02ds" % [
		minutes,
		remainder,
	]


func _format_hall_summary(summary: Dictionary) -> String:
	var history: Dictionary = summary.get("history", {})
	var meta: Dictionary = summary.get("meta_progression", {})
	var training_drills: Array = summary.get("training_drills", [])
	var characters: Array = summary.get("characters", [])
	var weapons: Array = summary.get("weapons", [])
	var relics: Array = summary.get("relics", [])
	var talents: Array = summary.get("talents", [])
	var blessings: Array = summary.get("blessings", [])
	var counts: Dictionary = summary.get("counts", {})
	var lines: PackedStringArray = []

	lines.append("Meta Progress")
	lines.append("%s: %d | Lifetime Earned: %d" % [
		str(meta.get("currency_name", "Data Shards")),
		int(meta.get("currency", 0)),
		int(meta.get("total_currency_earned", 0)),
	])
	lines.append("")
	lines.append("Records")
	lines.append("Runs %d | Wins %d | Defeats %d | Best Biome %d | Best Rooms %d | Best Kills %d | Best Gold %d | Best Time %s" % [
		int(history.get("runs", 0)),
		int(history.get("victories", 0)),
		int(history.get("defeats", 0)),
		int(history.get("best_biome", 0)),
		int(history.get("best_rooms", 0)),
		int(history.get("best_kills", 0)),
		int(history.get("best_gold", 0)),
		_format_seconds(int(history.get("best_time_seconds", 0))),
	])
	lines.append("")
	lines.append("Training Badges (%d/%d)" % [
		int(meta.get("training_badge_count", 0)),
		int(meta.get("training_badge_total", training_drills.size())),
	])
	for entry in training_drills:
		if entry is Dictionary:
			lines.append("- %s | Badge: %s %s | Goal: %s" % [
				str(entry.get("display_name", "Training")),
				str(entry.get("best_rating_text", "None")),
				str(entry.get("best_rating_token", "[--]")),
				str(entry.get("goal_text", "")),
			])
	lines.append("")
	lines.append("Characters (%d)" % int(counts.get("characters", characters.size())))
	for entry in characters:
		if entry is Dictionary:
			var unlock_text := "Unlocked" if bool(entry.get("unlocked", false)) else "Locked %d Data Shards" % int(entry.get("unlock_cost", 0))
			lines.append("- %s | %s | Mastery L%d (%d XP) | Bonus: %s | HP %d Armor %d Energy %d | Skill: %s | Tags: %s" % [
				str(entry.get("display_name", "Character")),
				unlock_text,
				int(entry.get("mastery_level", 1)),
				int(entry.get("mastery_xp", 0)),
				str(entry.get("mastery_bonus_text", "None")),
				int(entry.get("max_health", 0)),
				int(entry.get("max_armor", 0)),
				int(entry.get("max_energy", 0)),
				str(entry.get("skill_name", "Skill")),
				_join_display_values(entry.get("role_tags", [])),
			])
	lines.append("")
	lines.append("Weapons (%d)" % int(counts.get("weapons", weapons.size())))
	for entry in weapons:
		if entry is Dictionary:
			lines.append("- %s [%s] | %s / %s | Energy %d | %s" % [
				str(entry.get("display_name", "Weapon")),
				_format_label_token(entry.get("rarity", "")),
				_format_label_token(entry.get("weapon_class", "")),
				_format_label_token(entry.get("recommended_range", "")),
				int(entry.get("energy_cost", 0)),
				str(entry.get("description", "")),
			])
	lines.append("")
	lines.append("Relics (%d)" % int(counts.get("relics", relics.size())))
	for entry in relics:
		if entry is Dictionary:
			lines.append("- %s [%s] | %s | Tags: %s" % [
				str(entry.get("display_name", "Relic")),
				_format_label_token(entry.get("rarity", "")),
				str(entry.get("description", "")),
				_join_display_values(entry.get("build_tags", [])),
			])
	lines.append("")
	lines.append("Talents (%d)" % int(counts.get("talents", talents.size())))
	for entry in talents:
		if entry is Dictionary:
			lines.append("- %s [%s] | %s | Tags: %s" % [
				str(entry.get("display_name", "Talent")),
				_format_label_token(entry.get("rarity", "")),
				str(entry.get("description", "")),
				_join_display_values(entry.get("build_tags", [])),
			])
	lines.append("")
	lines.append("Blessings (%d)" % int(counts.get("blessings", blessings.size())))
	for entry in blessings:
		if entry is Dictionary:
			lines.append("- %s [%s] | %s | Tags: %s" % [
				str(entry.get("display_name", "Blessing")),
				_format_label_token(entry.get("rarity", "")),
				str(entry.get("description", "")),
				_join_display_values(entry.get("build_tags", [])),
			])

	return "\n".join(lines)


func _join_display_values(values) -> String:
	if not values is Array or values.is_empty():
		return "None"

	var strings: PackedStringArray = []
	for value in values:
		strings.append(_format_label_token(value))
	return ", ".join(strings)


func _format_label_token(value) -> String:
	var text := str(value).strip_edges()
	if text.is_empty():
		return "None"
	return text.replace("_", " ").capitalize()


func _call_flow(method_name: String) -> void:
	if is_instance_valid(flow_receiver) and flow_receiver.has_method(method_name):
		flow_receiver.call(method_name)


func _call_flow_with_settings(method_name: String) -> void:
	if is_instance_valid(flow_receiver) and flow_receiver.has_method(method_name):
		flow_receiver.call(
			method_name,
			settings_volume_slider.value / 100.0,
			settings_sfx_volume_slider.value / 100.0,
			settings_music_volume_slider.value / 100.0,
			settings_fullscreen_check.button_pressed,
			settings_resolution_option.selected,
			settings_aim_assist_check.button_pressed,
			settings_aim_assist_slider.value / 100.0,
			settings_low_health_feedback_slider.value / 100.0,
			settings_screen_shake_slider.value / 100.0,
			settings_damage_flash_slider.value / 100.0,
			settings_combat_text_slider.value / 100.0,
			settings_controller_aim_deadzone_slider.value / 100.0,
			settings_controller_input_switch_slider.value / 100.0
		)


func _update_volume_value_label() -> void:
	settings_volume_value_label.text = "Master: %d%%" % roundi(settings_volume_slider.value)
	settings_sfx_volume_value_label.text = "SFX: %d%%" % roundi(settings_sfx_volume_slider.value)
	settings_music_volume_value_label.text = "Music: %d%%" % roundi(settings_music_volume_slider.value)
	_update_aim_assist_value_label()
	_update_low_health_feedback_value_label()
	_update_screen_shake_value_label()
	_update_damage_flash_value_label()
	_update_combat_text_value_label()
	_update_controller_tuning_value_labels()


func _update_aim_assist_value_label() -> void:
	if settings_aim_assist_value_label == null or settings_aim_assist_slider == null:
		return

	var state_text := "On" if settings_aim_assist_check != null and settings_aim_assist_check.button_pressed else "Off"
	settings_aim_assist_value_label.text = "Aim Assist Strength: %d%% (%s)" % [roundi(settings_aim_assist_slider.value), state_text]
	settings_aim_assist_slider.editable = settings_aim_assist_check != null and settings_aim_assist_check.button_pressed
	if settings_aim_assist_band_label != null:
		settings_aim_assist_band_label.text = "Aim Assist Band: %s" % _get_settings_aim_assist_strength_band()
	_update_aim_assist_preset_buttons()


func _get_settings_aim_assist_strength_band() -> String:
	if settings_aim_assist_check == null or not settings_aim_assist_check.button_pressed:
		return "Off"
	if settings_aim_assist_slider == null:
		return "Off"
	var strength := clampf(settings_aim_assist_slider.value / 100.0, 0.0, 1.0)
	if strength <= 0.0:
		return "Off"
	if strength < 0.45:
		return "Light"
	if strength < 0.7:
		return "Balanced"
	return "Strong"


func _update_aim_assist_preset_buttons() -> void:
	if settings_aim_assist_preset_buttons.is_empty():
		return

	var active_band := _get_settings_aim_assist_strength_band().to_lower()
	for key in settings_aim_assist_preset_buttons.keys():
		var button = settings_aim_assist_preset_buttons[key]
		if button is Button:
			var preset_button := button as Button
			preset_button.button_pressed = str(key) == active_band


func _apply_aim_assist_preset(band: String) -> void:
	var normalized := band.strip_edges().to_lower()
	if settings_aim_assist_check == null or settings_aim_assist_slider == null:
		return

	match normalized:
		"off":
			settings_aim_assist_check.button_pressed = false
			settings_aim_assist_slider.value = 35.0
		"light":
			settings_aim_assist_check.button_pressed = true
			settings_aim_assist_slider.value = 35.0
		"balanced":
			settings_aim_assist_check.button_pressed = true
			settings_aim_assist_slider.value = 60.0
		"strong":
			settings_aim_assist_check.button_pressed = true
			settings_aim_assist_slider.value = 80.0
		_:
			return
	_update_aim_assist_value_label()


func _update_low_health_feedback_value_label() -> void:
	if settings_low_health_feedback_value_label == null or settings_low_health_feedback_slider == null:
		return

	settings_low_health_feedback_value_label.text = "Low-Health Feedback: %d%%" % roundi(settings_low_health_feedback_slider.value)


func _update_screen_shake_value_label() -> void:
	if settings_screen_shake_value_label == null or settings_screen_shake_slider == null:
		return

	settings_screen_shake_value_label.text = "Screen Shake: %d%%" % roundi(settings_screen_shake_slider.value)


func _update_damage_flash_value_label() -> void:
	if settings_damage_flash_value_label == null or settings_damage_flash_slider == null:
		return

	settings_damage_flash_value_label.text = "Damage Flash: %d%%" % roundi(settings_damage_flash_slider.value)


func _update_combat_text_value_label() -> void:
	if settings_combat_text_value_label == null or settings_combat_text_slider == null:
		return

	settings_combat_text_value_label.text = "Combat Text: %d%%" % roundi(settings_combat_text_slider.value)


func _update_controller_tuning_value_labels() -> void:
	if settings_controller_aim_deadzone_value_label != null and settings_controller_aim_deadzone_slider != null:
		settings_controller_aim_deadzone_value_label.text = "Right Stick Deadzone: %d%%" % roundi(settings_controller_aim_deadzone_slider.value)
	if settings_controller_input_switch_value_label != null and settings_controller_input_switch_slider != null:
		settings_controller_input_switch_value_label.text = "Gamepad Hint Switch: %d%%" % roundi(settings_controller_input_switch_slider.value)


func _setup_resolution_options() -> void:
	if settings_resolution_option.item_count > 0:
		return
	settings_resolution_option.add_item("1280 x 720", 0)
	settings_resolution_option.add_item("1600 x 900", 1)
	settings_resolution_option.add_item("1920 x 1080", 2)


func _setup_settings_scroll_container() -> void:
	if settings_panel.get_node_or_null("MarginContainer/SettingsScroll") != null:
		return

	var margin := settings_panel.get_node_or_null("MarginContainer") as MarginContainer
	if margin == null or settings_vbox == null:
		return

	margin.remove_child(settings_vbox)
	var scroll := ScrollContainer.new()
	scroll.name = "SettingsScroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.follow_focus = true
	margin.add_child(scroll)
	scroll.add_child(settings_vbox)
	settings_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_vbox.add_theme_constant_override("separation", 8)


func _setup_aim_assist_controls() -> void:
	var existing_check := settings_vbox.get_node_or_null("AimAssistCheck")
	var existing_slider := settings_vbox.get_node_or_null("AimAssistStrengthSlider")
	var existing_label := settings_vbox.get_node_or_null("AimAssistStrengthLabel")
	var existing_band_label := settings_vbox.get_node_or_null("AimAssistBandLabel")
	var existing_preset_row := settings_vbox.get_node_or_null("AimAssistPresetRow")
	if existing_check is CheckButton and existing_slider is HSlider and existing_label is Label:
		settings_aim_assist_check = existing_check as CheckButton
		settings_aim_assist_slider = existing_slider as HSlider
		settings_aim_assist_value_label = existing_label as Label
		if existing_band_label is Label:
			settings_aim_assist_band_label = existing_band_label as Label
		else:
			settings_aim_assist_band_label = _create_aim_assist_band_label()
			settings_vbox.add_child(settings_aim_assist_band_label)
			settings_vbox.move_child(settings_aim_assist_band_label, settings_aim_assist_value_label.get_index() + 1)
		if existing_preset_row is HBoxContainer:
			settings_aim_assist_preset_row = existing_preset_row as HBoxContainer
			_collect_aim_assist_preset_buttons()
		else:
			settings_aim_assist_preset_row = _create_aim_assist_preset_row()
			settings_vbox.add_child(settings_aim_assist_preset_row)
			settings_vbox.move_child(settings_aim_assist_preset_row, settings_aim_assist_band_label.get_index() + 1)
		_update_aim_assist_value_label()
		return

	var insert_index := settings_apply_button.get_index()
	settings_aim_assist_check = CheckButton.new()
	settings_aim_assist_check.name = "AimAssistCheck"
	settings_aim_assist_check.custom_minimum_size = Vector2(0, 32)
	settings_aim_assist_check.text = "Aim Assist"
	settings_aim_assist_check.tooltip_text = "Weakly bends shots toward nearby enemies while aiming"
	settings_vbox.add_child(settings_aim_assist_check)
	settings_vbox.move_child(settings_aim_assist_check, insert_index)

	settings_aim_assist_value_label = Label.new()
	settings_aim_assist_value_label.name = "AimAssistStrengthLabel"
	settings_aim_assist_value_label.text = "Aim Assist Strength: 35% (Off)"
	settings_aim_assist_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_aim_assist_value_label.add_theme_color_override("font_color", Color(0.86, 0.94, 1.0, 1.0))
	settings_vbox.add_child(settings_aim_assist_value_label)
	settings_vbox.move_child(settings_aim_assist_value_label, insert_index + 1)

	settings_aim_assist_band_label = _create_aim_assist_band_label()
	settings_vbox.add_child(settings_aim_assist_band_label)
	settings_vbox.move_child(settings_aim_assist_band_label, insert_index + 2)

	settings_aim_assist_preset_row = _create_aim_assist_preset_row()
	settings_vbox.add_child(settings_aim_assist_preset_row)
	settings_vbox.move_child(settings_aim_assist_preset_row, insert_index + 3)

	settings_aim_assist_slider = HSlider.new()
	settings_aim_assist_slider.name = "AimAssistStrengthSlider"
	settings_aim_assist_slider.min_value = 0.0
	settings_aim_assist_slider.max_value = 100.0
	settings_aim_assist_slider.step = 1.0
	settings_aim_assist_slider.value = 35.0
	settings_aim_assist_slider.custom_minimum_size = Vector2(0, 24)
	settings_aim_assist_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_vbox.add_child(settings_aim_assist_slider)
	settings_vbox.move_child(settings_aim_assist_slider, insert_index + 4)
	_update_aim_assist_value_label()


func _create_aim_assist_band_label() -> Label:
	var label := Label.new()
	label.name = "AimAssistBandLabel"
	label.text = "Aim Assist Band: Off"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color(0.62, 0.96, 0.9, 1.0))
	label.add_theme_font_size_override("font_size", 11)
	return label


func _create_aim_assist_preset_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "AimAssistPresetRow"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 6)
	settings_aim_assist_preset_buttons.clear()
	for band in ["Off", "Light", "Balanced", "Strong"]:
		var button := _create_aim_assist_preset_button(band)
		row.add_child(button)
		settings_aim_assist_preset_buttons[band.to_lower()] = button
	return row


func _create_aim_assist_preset_button(band: String) -> Button:
	var button := Button.new()
	button.name = "AimAssistPreset%s" % band
	button.text = band
	button.toggle_mode = true
	button.focus_mode = Control.FOCUS_ALL
	button.custom_minimum_size = Vector2(72, 28)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.tooltip_text = "Set Aim Assist to %s" % band
	button.pressed.connect(_on_aim_assist_preset_button_pressed.bind(band))
	return button


func _create_training_aim_assist_preset_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "TrainingAimAssistPresetRow"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 5)
	training_aim_assist_preset_buttons.clear()
	for band in ["Off", "Light", "Balanced", "Strong"]:
		var button := _create_training_aim_assist_preset_button(band)
		row.add_child(button)
		training_aim_assist_preset_buttons[band.to_lower()] = button
	return row


func _create_training_aim_assist_preset_button(band: String) -> Button:
	var button := Button.new()
	button.name = "TrainingAimAssistPreset%s" % band
	button.text = band
	button.toggle_mode = true
	button.focus_mode = Control.FOCUS_ALL
	button.custom_minimum_size = Vector2(68, 26)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.tooltip_text = "Apply Aim Assist %s in training" % band
	button.add_theme_font_size_override("font_size", 10)
	button.pressed.connect(_on_training_aim_assist_preset_button_pressed.bind(band))
	return button


func _update_training_aim_assist_preset_buttons(summary: Dictionary) -> void:
	if training_aim_assist_preset_buttons.is_empty():
		return

	var active_band := str(summary.get("aim_assist_strength_band", "Off")).strip_edges().to_lower()
	if active_band.is_empty():
		active_band = "off"
	for key in training_aim_assist_preset_buttons.keys():
		var button = training_aim_assist_preset_buttons[key]
		if button is Button:
			(button as Button).button_pressed = str(key) == active_band


func _collect_aim_assist_preset_buttons() -> void:
	settings_aim_assist_preset_buttons.clear()
	if settings_aim_assist_preset_row == null:
		return
	for child in settings_aim_assist_preset_row.get_children():
		if child is Button:
			var button := child as Button
			settings_aim_assist_preset_buttons[button.text.strip_edges().to_lower()] = button


func _setup_low_health_feedback_controls() -> void:
	var existing_slider := settings_vbox.get_node_or_null("LowHealthFeedbackSlider")
	var existing_label := settings_vbox.get_node_or_null("LowHealthFeedbackLabel")
	if existing_slider is HSlider and existing_label is Label:
		settings_low_health_feedback_slider = existing_slider as HSlider
		settings_low_health_feedback_value_label = existing_label as Label
		return

	var insert_index := settings_apply_button.get_index()
	settings_low_health_feedback_value_label = Label.new()
	settings_low_health_feedback_value_label.name = "LowHealthFeedbackLabel"
	settings_low_health_feedback_value_label.text = "Low-Health Feedback: 100%"
	settings_low_health_feedback_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_low_health_feedback_value_label.add_theme_color_override("font_color", Color(0.86, 0.94, 1.0, 1.0))
	settings_vbox.add_child(settings_low_health_feedback_value_label)
	settings_vbox.move_child(settings_low_health_feedback_value_label, insert_index)

	settings_low_health_feedback_slider = HSlider.new()
	settings_low_health_feedback_slider.name = "LowHealthFeedbackSlider"
	settings_low_health_feedback_slider.min_value = 0.0
	settings_low_health_feedback_slider.max_value = 100.0
	settings_low_health_feedback_slider.step = 1.0
	settings_low_health_feedback_slider.value = 100.0
	settings_low_health_feedback_slider.custom_minimum_size = Vector2(0, 24)
	settings_low_health_feedback_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_low_health_feedback_slider.tooltip_text = "Scales low-health edge pulse and heartbeat feedback"
	settings_vbox.add_child(settings_low_health_feedback_slider)
	settings_vbox.move_child(settings_low_health_feedback_slider, insert_index + 1)
	_update_low_health_feedback_value_label()


func _setup_screen_shake_controls() -> void:
	var existing_slider := settings_vbox.get_node_or_null("ScreenShakeSlider")
	var existing_label := settings_vbox.get_node_or_null("ScreenShakeLabel")
	if existing_slider is HSlider and existing_label is Label:
		settings_screen_shake_slider = existing_slider as HSlider
		settings_screen_shake_value_label = existing_label as Label
		return

	var insert_index := settings_apply_button.get_index()
	settings_screen_shake_value_label = Label.new()
	settings_screen_shake_value_label.name = "ScreenShakeLabel"
	settings_screen_shake_value_label.text = "Screen Shake: 100%"
	settings_screen_shake_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_screen_shake_value_label.add_theme_color_override("font_color", Color(0.86, 0.94, 1.0, 1.0))
	settings_vbox.add_child(settings_screen_shake_value_label)
	settings_vbox.move_child(settings_screen_shake_value_label, insert_index)

	settings_screen_shake_slider = HSlider.new()
	settings_screen_shake_slider.name = "ScreenShakeSlider"
	settings_screen_shake_slider.min_value = 0.0
	settings_screen_shake_slider.max_value = 100.0
	settings_screen_shake_slider.step = 1.0
	settings_screen_shake_slider.value = 100.0
	settings_screen_shake_slider.custom_minimum_size = Vector2(0, 24)
	settings_screen_shake_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_screen_shake_slider.tooltip_text = "Scales camera shake from hits, crits, room clears, and bosses"
	settings_vbox.add_child(settings_screen_shake_slider)
	settings_vbox.move_child(settings_screen_shake_slider, insert_index + 1)
	_update_screen_shake_value_label()


func _setup_damage_flash_controls() -> void:
	var existing_slider := settings_vbox.get_node_or_null("DamageFlashSlider")
	var existing_label := settings_vbox.get_node_or_null("DamageFlashLabel")
	if existing_slider is HSlider and existing_label is Label:
		settings_damage_flash_slider = existing_slider as HSlider
		settings_damage_flash_value_label = existing_label as Label
		return

	var insert_index := settings_apply_button.get_index()
	settings_damage_flash_value_label = Label.new()
	settings_damage_flash_value_label.name = "DamageFlashLabel"
	settings_damage_flash_value_label.text = "Damage Flash: 100%"
	settings_damage_flash_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_damage_flash_value_label.add_theme_color_override("font_color", Color(0.86, 0.94, 1.0, 1.0))
	settings_vbox.add_child(settings_damage_flash_value_label)
	settings_vbox.move_child(settings_damage_flash_value_label, insert_index)

	settings_damage_flash_slider = HSlider.new()
	settings_damage_flash_slider.name = "DamageFlashSlider"
	settings_damage_flash_slider.min_value = 0.0
	settings_damage_flash_slider.max_value = 100.0
	settings_damage_flash_slider.step = 1.0
	settings_damage_flash_slider.value = 100.0
	settings_damage_flash_slider.custom_minimum_size = Vector2(0, 24)
	settings_damage_flash_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_damage_flash_slider.tooltip_text = "Scales the red screen flash when HP damage is taken"
	settings_vbox.add_child(settings_damage_flash_slider)
	settings_vbox.move_child(settings_damage_flash_slider, insert_index + 1)
	_update_damage_flash_value_label()


func _setup_combat_text_controls() -> void:
	var existing_slider := settings_vbox.get_node_or_null("CombatTextSlider")
	var existing_label := settings_vbox.get_node_or_null("CombatTextLabel")
	if existing_slider is HSlider and existing_label is Label:
		settings_combat_text_slider = existing_slider as HSlider
		settings_combat_text_value_label = existing_label as Label
		return

	var insert_index := settings_apply_button.get_index()
	settings_combat_text_value_label = Label.new()
	settings_combat_text_value_label.name = "CombatTextLabel"
	settings_combat_text_value_label.text = "Combat Text: 100%"
	settings_combat_text_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_combat_text_value_label.add_theme_color_override("font_color", Color(0.86, 0.94, 1.0, 1.0))
	settings_vbox.add_child(settings_combat_text_value_label)
	settings_vbox.move_child(settings_combat_text_value_label, insert_index)

	settings_combat_text_slider = HSlider.new()
	settings_combat_text_slider.name = "CombatTextSlider"
	settings_combat_text_slider.min_value = 0.0
	settings_combat_text_slider.max_value = 100.0
	settings_combat_text_slider.step = 1.0
	settings_combat_text_slider.value = 100.0
	settings_combat_text_slider.custom_minimum_size = Vector2(0, 24)
	settings_combat_text_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_combat_text_slider.tooltip_text = "Scales floating damage, crit, healing, and armor text"
	settings_vbox.add_child(settings_combat_text_slider)
	settings_vbox.move_child(settings_combat_text_slider, insert_index + 1)
	_update_combat_text_value_label()


func _setup_control_rebind_buttons() -> void:
	if settings_vbox.get_node_or_null("ControlsGrid") != null:
		return

	var insert_index := settings_apply_button.get_index()
	var title := Label.new()
	title.name = "ControlsLabel"
	title.text = "Controls"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.86, 0.94, 1.0, 1.0))
	settings_vbox.add_child(title)
	settings_vbox.move_child(title, insert_index)

	var grid := GridContainer.new()
	grid.name = "ControlsGrid"
	grid.columns = 4
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	settings_vbox.add_child(grid)
	settings_vbox.move_child(grid, insert_index + 1)

	for action_info in CONTROL_REBIND_ACTIONS:
		var action_name := str(action_info.get("action", ""))
		var button := Button.new()
		button.custom_minimum_size = Vector2(98, 30)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(_on_control_rebind_button_pressed.bind(action_name))
		grid.add_child(button)
		_settings_control_buttons[action_name] = button

	var reset_button := Button.new()
	reset_button.name = "ResetControlsButton"
	reset_button.custom_minimum_size = Vector2(0, 32)
	reset_button.text = "Reset Controls"
	reset_button.pressed.connect(_on_reset_controls_button_pressed)
	settings_vbox.add_child(reset_button)
	settings_vbox.move_child(reset_button, insert_index + 2)
	_update_control_rebind_buttons()


func _setup_controller_layout_panel() -> void:
	var existing_label := settings_vbox.get_node_or_null("ControllerLayoutLabel")
	if existing_label is Label:
		settings_controller_layout_label = existing_label as Label
		settings_controller_layout_label.text = _format_controller_layout_hint()
		return

	var insert_index := settings_apply_button.get_index()
	var title := Label.new()
	title.name = "ControllerLayoutTitle"
	title.text = "Controller"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.86, 0.94, 1.0, 1.0))
	settings_vbox.add_child(title)
	settings_vbox.move_child(title, insert_index)

	settings_controller_layout_label = Label.new()
	settings_controller_layout_label.name = "ControllerLayoutLabel"
	settings_controller_layout_label.text = _format_controller_layout_hint()
	settings_controller_layout_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_controller_layout_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	settings_controller_layout_label.add_theme_font_size_override("font_size", 11)
	settings_controller_layout_label.add_theme_color_override("font_color", Color(0.64, 0.78, 0.92, 1.0))
	settings_vbox.add_child(settings_controller_layout_label)
	settings_vbox.move_child(settings_controller_layout_label, insert_index + 1)


func _setup_controller_tuning_controls() -> void:
	var existing_deadzone_slider := settings_vbox.get_node_or_null("ControllerAimDeadzoneSlider")
	var existing_deadzone_label := settings_vbox.get_node_or_null("ControllerAimDeadzoneLabel")
	var existing_switch_slider := settings_vbox.get_node_or_null("ControllerInputSwitchSlider")
	var existing_switch_label := settings_vbox.get_node_or_null("ControllerInputSwitchLabel")
	if existing_deadzone_slider is HSlider and existing_deadzone_label is Label and existing_switch_slider is HSlider and existing_switch_label is Label:
		settings_controller_aim_deadzone_slider = existing_deadzone_slider as HSlider
		settings_controller_aim_deadzone_value_label = existing_deadzone_label as Label
		settings_controller_input_switch_slider = existing_switch_slider as HSlider
		settings_controller_input_switch_value_label = existing_switch_label as Label
		_update_controller_tuning_value_labels()
		return

	var insert_index := settings_apply_button.get_index()
	settings_controller_aim_deadzone_value_label = Label.new()
	settings_controller_aim_deadzone_value_label.name = "ControllerAimDeadzoneLabel"
	settings_controller_aim_deadzone_value_label.text = "Right Stick Deadzone: 22%"
	settings_controller_aim_deadzone_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_controller_aim_deadzone_value_label.add_theme_color_override("font_color", Color(0.86, 0.94, 1.0, 1.0))
	settings_vbox.add_child(settings_controller_aim_deadzone_value_label)
	settings_vbox.move_child(settings_controller_aim_deadzone_value_label, insert_index)

	settings_controller_aim_deadzone_slider = HSlider.new()
	settings_controller_aim_deadzone_slider.name = "ControllerAimDeadzoneSlider"
	settings_controller_aim_deadzone_slider.min_value = 0.0
	settings_controller_aim_deadzone_slider.max_value = 60.0
	settings_controller_aim_deadzone_slider.step = 1.0
	settings_controller_aim_deadzone_slider.value = roundf(CONTROLLER_LAYOUT.get_aim_deadzone() * 100.0)
	settings_controller_aim_deadzone_slider.custom_minimum_size = Vector2(0, 24)
	settings_controller_aim_deadzone_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_controller_aim_deadzone_slider.tooltip_text = "Filters small right-stick drift before it counts as aim input"
	settings_vbox.add_child(settings_controller_aim_deadzone_slider)
	settings_vbox.move_child(settings_controller_aim_deadzone_slider, insert_index + 1)

	settings_controller_input_switch_value_label = Label.new()
	settings_controller_input_switch_value_label.name = "ControllerInputSwitchLabel"
	settings_controller_input_switch_value_label.text = "Gamepad Hint Switch: 45%"
	settings_controller_input_switch_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_controller_input_switch_value_label.add_theme_color_override("font_color", Color(0.86, 0.94, 1.0, 1.0))
	settings_vbox.add_child(settings_controller_input_switch_value_label)
	settings_vbox.move_child(settings_controller_input_switch_value_label, insert_index + 2)

	settings_controller_input_switch_slider = HSlider.new()
	settings_controller_input_switch_slider.name = "ControllerInputSwitchSlider"
	settings_controller_input_switch_slider.min_value = 0.0
	settings_controller_input_switch_slider.max_value = 90.0
	settings_controller_input_switch_slider.step = 1.0
	settings_controller_input_switch_slider.value = roundf(CONTROLLER_LAYOUT.get_input_switch_threshold() * 100.0)
	settings_controller_input_switch_slider.custom_minimum_size = Vector2(0, 24)
	settings_controller_input_switch_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_controller_input_switch_slider.tooltip_text = "Minimum stick movement needed before HUD switches to gamepad hints"
	settings_vbox.add_child(settings_controller_input_switch_slider)
	settings_vbox.move_child(settings_controller_input_switch_slider, insert_index + 3)
	_update_controller_tuning_value_labels()


func _update_input_hint() -> void:
	if _input_hint_device == INPUT_HINT_GAMEPAD:
		input_hint_label.text = _format_controller_layout_hint()
		return

	input_hint_label.text = "Move %s/%s/%s/%s | Aim Mouse | Shoot LMB | Reload %s | Skill %s | Weapons 1/2/3 | Interact %s | Pause %s | Debug %s" % [
		_get_action_key_label("move_up"),
		_get_action_key_label("move_left"),
		_get_action_key_label("move_down"),
		_get_action_key_label("move_right"),
		_get_action_key_label("reload"),
		_get_action_key_label("skill"),
		_get_action_key_label("interact"),
		_get_action_key_label("pause"),
		_get_action_key_label("debug_map"),
	]


func _update_input_hint_device_from_event(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		var button_event := event as InputEventJoypadButton
		if button_event.pressed:
			_set_input_hint_device(INPUT_HINT_GAMEPAD)
		return

	if event is InputEventJoypadMotion:
		var motion_event := event as InputEventJoypadMotion
		if absf(motion_event.axis_value) >= CONTROLLER_LAYOUT.get_input_switch_threshold():
			_set_input_hint_device(INPUT_HINT_GAMEPAD)
		return

	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo:
			_set_input_hint_device(INPUT_HINT_KEYBOARD_MOUSE)
		return

	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.pressed:
			_set_input_hint_device(INPUT_HINT_KEYBOARD_MOUSE)
		return

	if event is InputEventMouseMotion:
		var mouse_motion := event as InputEventMouseMotion
		if mouse_motion.relative.length() >= CONTROLLER_LAYOUT.get_mouse_return_threshold():
			_set_input_hint_device(INPUT_HINT_KEYBOARD_MOUSE)


func _set_input_hint_device(device: String) -> void:
	var normalized := device.strip_edges().to_lower()
	if normalized != INPUT_HINT_GAMEPAD:
		normalized = INPUT_HINT_KEYBOARD_MOUSE
	if _input_hint_device == normalized:
		return
	_input_hint_device = normalized
	_update_input_hint()


func _format_controller_layout_hint() -> String:
	return CONTROLLER_LAYOUT.format_hint()


func _refresh_debug_map_panel_text() -> void:
	if _minimap_debug_text.is_empty():
		debug_map_text.text = "No dungeon debug map available."
		return
	debug_map_text.text = _minimap_debug_text


func _update_control_rebind_buttons() -> void:
	for action_info in CONTROL_REBIND_ACTIONS:
		var action_name := str(action_info.get("action", ""))
		var button = _settings_control_buttons.get(action_name)
		if not button is Button:
			continue

		var label := Localization.text(action_info.get("label", action_name))
		if _pending_rebind_action == action_name:
			(button as Button).text = "%s: ..." % label
		else:
			(button as Button).text = "%s: %s" % [label, _get_action_key_label(action_name)]


func _get_action_key_label(action_name: String) -> String:
	for event in InputMap.action_get_events(StringName(action_name)):
		if event is InputEventKey:
			var key_event := event as InputEventKey
			var keycode := key_event.physical_keycode
			if keycode <= 0:
				keycode = key_event.keycode
			return _format_keycode_label(keycode)
	return "--"


func _format_keycode_label(keycode: int) -> String:
	if keycode == KEY_ESCAPE:
		return "Esc"
	if keycode <= 0:
		return "--"

	var label := OS.get_keycode_string(keycode)
	if label.is_empty():
		return str(keycode)
	return label


func _on_start_button_pressed() -> void:
	if is_instance_valid(flow_receiver) and flow_receiver.has_method("start_new_run_from_menu"):
		flow_receiver.call("start_new_run_from_menu", main_menu_seed_input.text)
		return
	_call_flow("start_new_run")


func _on_apply_seed_button_pressed() -> void:
	if is_instance_valid(flow_receiver) and flow_receiver.has_method("apply_dungeon_seed_text"):
		flow_receiver.call("apply_dungeon_seed_text", main_menu_seed_input.text)


func _on_random_seed_button_pressed() -> void:
	_call_flow("randomize_dungeon_seed")


func _on_previous_character_button_pressed() -> void:
	_call_flow("select_previous_character")


func _on_next_character_button_pressed() -> void:
	_call_flow("select_next_character")


func _on_unlock_character_button_pressed() -> void:
	_call_flow("unlock_selected_character")


func _on_training_button_pressed() -> void:
	_call_flow("start_training_room")


func _on_training_next_drill_button_pressed() -> void:
	_call_flow("cycle_training_drill")


func _on_training_reset_button_pressed() -> void:
	_call_flow("reset_training_room")


func _on_training_aim_assist_preset_button_pressed(band: String) -> void:
	if is_instance_valid(flow_receiver) and flow_receiver.has_method("apply_aim_assist_preset"):
		flow_receiver.call("apply_aim_assist_preset", band)


func _on_settings_button_pressed() -> void:
	_call_flow("open_settings_menu")


func _on_hall_button_pressed() -> void:
	_call_flow("open_hall_menu")


func _on_lobby_start_requested() -> void:
	_on_start_button_pressed()


func _on_lobby_training_requested(target_drill_id: String = "") -> void:
	if is_instance_valid(flow_receiver) and flow_receiver.has_method("start_training_room"):
		flow_receiver.call("start_training_room", target_drill_id)


func _on_lobby_settings_requested() -> void:
	_on_settings_button_pressed()


func _on_lobby_previous_character_requested() -> void:
	_call_flow("select_previous_character")
	_call_flow("refresh_hall_menu")


func _on_lobby_next_character_requested() -> void:
	_call_flow("select_next_character")
	_call_flow("refresh_hall_menu")


func _on_lobby_unlock_character_requested() -> void:
	_call_flow("unlock_selected_character")
	_call_flow("refresh_hall_menu")


func _on_hall_close_button_pressed() -> void:
	if is_instance_valid(flow_receiver) and flow_receiver.has_method("close_hall_menu"):
		flow_receiver.call("close_hall_menu")
		return
	show_main_menu(flow_receiver)


func _on_resume_button_pressed() -> void:
	_call_flow("resume_run")


func _on_restart_button_pressed() -> void:
	_call_flow("restart_run")


func _on_main_menu_button_pressed() -> void:
	_call_flow("return_to_main_menu")


func _on_settings_volume_changed(_value: float) -> void:
	_update_volume_value_label()


func _on_settings_aim_assist_toggled(_enabled: bool) -> void:
	_update_aim_assist_value_label()


func _on_aim_assist_preset_button_pressed(band: String) -> void:
	_apply_aim_assist_preset(band)


func _on_control_rebind_button_pressed(action_name: String) -> void:
	_pending_rebind_action = action_name
	_pending_rebind_button = _settings_control_buttons.get(action_name) as Button
	_update_control_rebind_buttons()


func _on_reset_controls_button_pressed() -> void:
	_pending_rebind_action = ""
	_pending_rebind_button = null
	if is_instance_valid(flow_receiver) and flow_receiver.has_method("reset_input_bindings"):
		flow_receiver.call("reset_input_bindings")


func _on_settings_apply_button_pressed() -> void:
	_call_flow_with_settings("apply_settings")


func _on_settings_back_button_pressed() -> void:
	_call_flow("close_settings_menu")


func _on_replay_seed_button_pressed() -> void:
	_call_flow("replay_current_seed")


func _on_result_detail_toggle_button_pressed() -> void:
	toggle_result_detail_mode()


func _on_debug_map_copy_button_pressed() -> void:
	if copy_debug_map_to_clipboard():
		show_message("Debug Map Copied")
	else:
		show_message("No Debug Map")


func _on_debug_map_close_button_pressed() -> void:
	hide_debug_map_panel()

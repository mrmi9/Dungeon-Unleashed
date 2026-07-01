extends Control
class_name PrototypeHUD

signal relic_choice_selected(index: int)

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
const MAIN_MENU_PANEL_SIZE := Vector2(440.0, 492.0)
const PAUSE_PANEL_SIZE := Vector2(340.0, 252.0)
const SETTINGS_PANEL_SIZE := Vector2(460.0, 660.0)
const RESULT_PANEL_SIZE := Vector2(580.0, 588.0)
const RELIC_CHOICE_PANEL_SIZE := Vector2(720.0, 356.0)
const DEBUG_MAP_PANEL_SIZE := Vector2(760.0, 560.0)

@onready var health_label: Label = $MarginContainer/VBoxContainer/HealthLabel
@onready var shield_label: Label = $MarginContainer/VBoxContainer/ShieldLabel
@onready var energy_label: Label = $MarginContainer/VBoxContainer/EnergyLabel
@onready var skill_label: Label = $MarginContainer/VBoxContainer/SkillLabel
@onready var weapon_label: Label = $MarginContainer/VBoxContainer/WeaponLabel
@onready var ammo_label: Label = $MarginContainer/VBoxContainer/AmmoLabel
@onready var gold_label: Label = $MarginContainer/VBoxContainer/GoldLabel
@onready var relic_label: Label = $MarginContainer/VBoxContainer/RelicLabel
@onready var enemy_label: Label = $MarginContainer/VBoxContainer/EnemyLabel
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
var _active_relic_choices: Array = []
var relic_choice_receiver: Node
var flow_receiver: Node
var _rarity_colors := {
	"common": Color(0.86, 0.9, 0.92, 1.0),
	"rare": Color(0.36, 0.72, 1.0, 1.0),
	"epic": Color(0.82, 0.48, 1.0, 1.0),
	"legendary": Color(1.0, 0.72, 0.24, 1.0),
}
var _result_section_labels: Dictionary = {}
var _settings_control_buttons: Dictionary = {}
var _pending_rebind_action := ""
var _pending_rebind_button: Button


func _ready() -> void:
	_setup_resolution_options()
	_setup_control_rebind_buttons()
	_setup_result_sections()
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
	health_label.text = "HP: %d / %d" % [current_hp, max_hp]


func update_shield(current_shield: int, max_shield: int = -1) -> void:
	if max_shield > 0:
		shield_label.text = "Armor: %d / %d" % [current_shield, max_shield]
	else:
		shield_label.text = "Armor: %d" % current_shield


func update_energy(current_energy: int, max_energy: int) -> void:
	energy_label.text = "Energy: %d / %d" % [current_energy, max_energy]


func update_skill_status(skill_name: String, cooldown_remaining: float, cooldown_duration: float, active_remaining: float) -> void:
	if active_remaining > 0.0:
		skill_label.text = "Skill: %s Active %.1fs" % [skill_name, active_remaining]
	elif cooldown_remaining > 0.0:
		skill_label.text = "Skill: %s CD %.1fs" % [skill_name, cooldown_remaining]
	elif cooldown_duration > 0.0:
		skill_label.text = "Skill: %s Ready" % skill_name
	else:
		skill_label.text = "Skill: Ready"


func update_character_selection(display_name: String, description: String, skill_name: String, skill_description: String, index: int, total: int) -> void:
	character_name_label.text = "Character %d/%d: %s" % [index + 1, maxi(total, 1), display_name]
	character_info_label.text = "%s\nSkill: %s - %s" % [description, skill_name, skill_description]


func set_weapon_name(display_name: String) -> void:
	weapon_label.text = "Weapon: %s" % display_name


func update_ammo(current_ammo: int, magazine_size: int, is_reloading: bool) -> void:
	if is_reloading:
		ammo_label.text = "Ammo: Reloading..."
	else:
		ammo_label.text = "Ammo: %d / %d" % [current_ammo, magazine_size]


func update_gold(current_gold: int) -> void:
	gold_label.text = "Gold: %d" % current_gold


func update_relics(relic_summaries: Array) -> void:
	if relic_summaries.is_empty():
		relic_label.text = "Relics: None"
		return

	var parts: PackedStringArray = []
	for summary in relic_summaries:
		if not summary is Dictionary:
			continue
		var name := str(summary.get("display_name", "Relic"))
		var stacks := int(summary.get("stacks", 1))
		if stacks > 1:
			parts.append("%s x%d" % [name, stacks])
		else:
			parts.append(name)

	relic_label.text = "Relics: %s" % ", ".join(parts)


func update_enemy_count(count: int) -> void:
	enemy_label.text = "Enemies: %d" % count


func update_room_state(state_name: String) -> void:
	room_state_label.text = "Room: %s" % state_name


func update_boss_health(display_name: String, current_hp: int, max_hp: int) -> void:
	boss_panel.visible = true
	boss_name_label.text = display_name
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


func show_settings_menu(master_volume: float, sfx_volume = null, music_volume = null, fullscreen = null, resolution_index = null, receiver: Node = null) -> void:
	if receiver != null:
		flow_receiver = receiver
	hide_flow_panels()
	update_settings_controls(master_volume, sfx_volume, music_volume, fullscreen, resolution_index)
	settings_panel.visible = true
	_refresh_input_hint_panel_visibility()


func update_settings_controls(master_volume: float, sfx_volume = null, music_volume = null, fullscreen = null, resolution_index = null) -> void:
	var resolved_sfx_volume := 1.0
	var resolved_music_volume := 0.8
	var resolved_fullscreen := false
	var resolved_resolution_index := 0

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

	settings_volume_slider.value = roundf(clampf(master_volume, 0.0, 1.0) * 100.0)
	settings_sfx_volume_slider.value = roundf(resolved_sfx_volume * 100.0)
	settings_music_volume_slider.value = roundf(resolved_music_volume * 100.0)
	settings_fullscreen_check.button_pressed = resolved_fullscreen
	settings_resolution_option.select(resolved_resolution_index)
	_update_volume_value_label()
	refresh_input_bindings()


func refresh_input_bindings() -> void:
	_update_control_rebind_buttons()
	_update_input_hint()


func show_run_result(victory: bool, summary: Dictionary, receiver: Node = null) -> void:
	if receiver != null:
		flow_receiver = receiver
	hide_flow_panels()
	result_panel.visible = true
	result_title_label.text = "Run Complete" if victory else "Run Failed"
	result_summary_label.text = _format_run_summary(summary)
	_update_result_sections(summary)
	_refresh_input_hint_panel_visibility()


func hide_flow_panels() -> void:
	main_menu_panel.visible = false
	pause_panel.visible = false
	settings_panel.visible = false
	result_panel.visible = false
	debug_map_panel.visible = false
	_refresh_input_hint_panel_visibility()


func update_minimap(room_records: Array, current_room_id: String = "") -> void:
	_minimap_current_room_id = current_room_id
	for child in minimap_row.get_children():
		minimap_row.remove_child(child)
		child.free()

	for record in room_records:
		if record is Dictionary:
			minimap_row.add_child(_make_minimap_marker(record, current_room_id))

	if current_room_id.is_empty():
		minimap_current_label.text = "Current: --"
	else:
		minimap_current_label.text = "Current: %s" % current_room_id


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
	if selection_receiver != null:
		relic_choice_receiver = selection_receiver
	relic_choice_panel.visible = true
	relic_choice_title.text = "Choose a Relic"

	for index in range(relic_choice_buttons.size()):
		var button := relic_choice_buttons[index]
		if index >= relic_choices.size():
			button.visible = false
			button.disabled = true
			continue

		var relic := relic_choices[index] as Resource
		button.visible = true
		button.disabled = false
		button.text = _format_relic_choice(relic)
		button.tooltip_text = _format_relic_tooltip(relic)
		_apply_relic_choice_style(button, relic)
	_refresh_input_hint_panel_visibility()


func hide_relic_choices() -> void:
	relic_choice_panel.visible = false
	_active_relic_choices.clear()
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
	return minimap_row.get_child_count()


func get_minimap_current_room_id() -> String:
	return _minimap_current_room_id


func get_minimap_seed_text() -> String:
	return minimap_seed_label.text


func get_minimap_debug_text() -> String:
	return _minimap_debug_text


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


func get_relic_label_text() -> String:
	return relic_label.text


func get_skill_label_text() -> String:
	return skill_label.text


func get_character_name_text() -> String:
	return character_name_label.text


func get_character_info_text() -> String:
	return character_info_label.text


func is_relic_choice_visible() -> bool:
	return relic_choice_panel.visible


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


func is_boss_health_visible() -> bool:
	return boss_panel.visible


func get_boss_health_value() -> float:
	return boss_health_bar.value


func is_completion_visible() -> bool:
	return completion_label.visible


func is_main_menu_visible() -> bool:
	return main_menu_panel.visible


func is_pause_menu_visible() -> bool:
	return pause_panel.visible


func is_settings_visible() -> bool:
	return settings_panel.visible


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


func get_control_rebind_button_text(action_name: String) -> String:
	var button = _settings_control_buttons.get(action_name)
	if button is Button:
		return (button as Button).text
	return ""


func get_input_hint_text() -> String:
	return input_hint_label.text


func set_settings_for_test(master_volume: float, sfx_volume = null, music_volume = null, fullscreen = null, resolution_index = null) -> void:
	update_settings_controls(master_volume, sfx_volume, music_volume, fullscreen, resolution_index)


func choose_relic_for_test(index: int) -> void:
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
	)


func _make_minimap_marker(record: Dictionary, current_room_id: String) -> Label:
	var room_id := str(record.get("id", ""))
	var room_type := str(record.get("room_type", "combat"))
	var visited := bool(record.get("visited", false))
	var cleared := bool(record.get("cleared", false))
	var is_current := room_id == current_room_id

	var marker := Label.new()
	marker.text = _get_room_marker_text(room_type)
	marker.custom_minimum_size = Vector2(24, 22)
	marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	marker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	marker.tooltip_text = "%s %s" % [room_id, room_type]
	marker.add_theme_font_size_override("font_size", 14)
	marker.add_theme_color_override("font_color", _get_minimap_marker_color(room_type, visited, cleared, is_current))
	if is_current:
		marker.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.05, 1.0))
		marker.add_theme_constant_override("outline_size", 4)

	return marker


func _select_relic_choice(index: int) -> void:
	if index < 0 or index >= _active_relic_choices.size():
		return

	hide_relic_choices()
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


func _get_room_marker_text(room_type: String) -> String:
	match room_type:
		"start":
			return "S"
		"elite":
			return "E"
		"reward":
			return "R"
		"shop":
			return "$"
		"boss":
			return "B"
		"boss_placeholder":
			return "B"
	return "C"


func _get_minimap_marker_color(room_type: String, visited: bool, cleared: bool, is_current: bool) -> Color:
	if is_current:
		return Color(1.0, 0.86, 0.25, 1.0)
	if cleared:
		return Color(0.34, 1.0, 0.58, 1.0)
	if visited:
		return Color(0.5, 0.76, 1.0, 1.0)
	if room_type == "reward":
		return Color(1.0, 0.82, 0.28, 0.9)
	if room_type == "shop":
		return Color(0.32, 1.0, 0.82, 0.9)
	if room_type == "boss" or room_type == "boss_placeholder":
		return Color(1.0, 0.3, 0.25, 0.85)
	if room_type == "elite":
		return Color(0.95, 0.5, 1.0, 0.85)
	return Color(0.45, 0.48, 0.52, 0.8)


func _format_run_summary(summary: Dictionary) -> String:
	var history: Dictionary = summary.get("history", {})
	var relic_names: Array = summary.get("relic_names", [])
	var loadout_names: Array = summary.get("loadout", [])
	return "Result: %s\nSeed: %d\nRooms: %d | Kills: %d | Time: %s\nGold: %d (earned %d / spent %d)\nCharacter: %s\nWeapon: %s\nLoadout: %s\nRelics: %s\nRelic Stacks: %d\nSurvival: HP %d/%d | Shield %d | HP Damage %d\nCombat: Crits %d | Healing %d | Shield Blocked %d\nLoot: Rewards %d | Chests %d | Shop Buys %d\nBoss Defeated: %s\nRecord: Runs %d | Wins %d | Best Rooms %d | Best Kills %d | Best Gold %d" % [
		str(summary.get("result", "In Progress")),
		int(summary.get("dungeon_seed", 0)),
		int(summary.get("rooms_cleared", 0)),
		int(summary.get("kills", 0)),
		_format_seconds(int(summary.get("elapsed_seconds", 0))),
		int(summary.get("gold", 0)),
		int(summary.get("gold_earned", 0)),
		int(summary.get("gold_spent", 0)),
		str(summary.get("character", "Adventurer")),
		str(summary.get("weapon", "Unarmed")),
		_format_name_list(loadout_names),
		_format_name_list(relic_names),
		int(summary.get("relic_stacks", relic_names.size())),
		int(summary.get("current_hp", 0)),
		int(summary.get("max_hp", 0)),
		int(summary.get("shield", 0)),
		int(summary.get("damage_taken", 0)),
		int(summary.get("critical_hits", 0)),
		int(summary.get("healing_received", 0)),
		int(summary.get("shield_absorbed", 0)),
		int(summary.get("rewards_collected", 0)),
		int(summary.get("chests_opened", 0)),
		int(summary.get("shop_purchases", 0)),
		"Yes" if summary.get("boss_defeated", false) == true else "No",
		int(history.get("runs", 0)),
		int(history.get("victories", 0)),
		int(history.get("best_rooms", 0)),
		int(history.get("best_kills", 0)),
		int(history.get("best_gold", 0)),
	]


func _setup_result_sections() -> void:
	result_summary_label.visible = false
	if result_vbox.get_node_or_null("ResultSections") != null:
		return

	var sections := GridContainer.new()
	sections.name = "ResultSections"
	sections.columns = 2
	sections.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sections.add_theme_constant_override("h_separation", 18)
	sections.add_theme_constant_override("v_separation", 8)
	result_vbox.add_child(sections)
	result_vbox.move_child(sections, result_summary_label.get_index() + 1)

	for section_name in ["Overview", "Build", "Survival", "Combat", "Loot", "Record"]:
		_add_result_section_row(sections, section_name)


func _add_result_section_row(parent: GridContainer, section_name: String) -> void:
	var title := Label.new()
	title.name = "%sTitle" % section_name
	title.custom_minimum_size = Vector2(82, 0)
	title.theme_type_variation = "HeaderSmall"
	title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.28, 1.0))
	title.add_theme_font_size_override("font_size", 14)
	title.text = section_name
	title.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	parent.add_child(title)

	var value := Label.new()
	value.name = "%sValue" % section_name
	value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	value.add_theme_color_override("font_color", Color(0.86, 0.94, 1.0, 1.0))
	value.add_theme_font_size_override("font_size", 14)
	value.text = "--"
	parent.add_child(value)
	_result_section_labels[section_name.to_lower()] = value


func _update_result_sections(summary: Dictionary) -> void:
	var history: Dictionary = summary.get("history", {})
	var relic_names: Array = summary.get("relic_names", [])
	var loadout_names: Array = summary.get("loadout", [])
	_set_result_section(
		"overview",
		"Result: %s\nSeed %d\nRooms %d | Kills %d | Time %s" % [
			str(summary.get("result", "In Progress")),
			int(summary.get("dungeon_seed", 0)),
			int(summary.get("rooms_cleared", 0)),
			int(summary.get("kills", 0)),
			_format_seconds(int(summary.get("elapsed_seconds", 0))),
		]
	)
	_set_result_section(
		"build",
		"Character: %s\nWeapon: %s\nLoadout: %s\nRelics: %s\nStacks: %d" % [
			str(summary.get("character", "Adventurer")),
			str(summary.get("weapon", "Unarmed")),
			_format_name_list(loadout_names),
			_format_name_list(relic_names),
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
		"Crits %d | Healing %d | Shield Blocked %d" % [
			int(summary.get("critical_hits", 0)),
			int(summary.get("healing_received", 0)),
			int(summary.get("shield_absorbed", 0)),
		]
	)
	_set_result_section(
		"loot",
		"Gold %d (earned %d / spent %d)\nRewards %d | Chests %d | Shop Buys %d | Boss %s" % [
			int(summary.get("gold", 0)),
			int(summary.get("gold_earned", 0)),
			int(summary.get("gold_spent", 0)),
			int(summary.get("rewards_collected", 0)),
			int(summary.get("chests_opened", 0)),
			int(summary.get("shop_purchases", 0)),
			"Yes" if summary.get("boss_defeated", false) == true else "No",
		]
	)
	_set_result_section(
		"record",
		"Runs %d | Wins %d | Best Rooms %d | Best Kills %d | Best Gold %d" % [
			int(history.get("runs", 0)),
			int(history.get("victories", 0)),
			int(history.get("best_rooms", 0)),
			int(history.get("best_kills", 0)),
			int(history.get("best_gold", 0)),
		]
	)


func _set_result_section(section_name: String, text: String) -> void:
	var label = _result_section_labels.get(section_name)
	if label is Label:
		(label as Label).text = text


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
			settings_resolution_option.selected
		)


func _update_volume_value_label() -> void:
	settings_volume_value_label.text = "Master: %d%%" % roundi(settings_volume_slider.value)
	settings_sfx_volume_value_label.text = "SFX: %d%%" % roundi(settings_sfx_volume_slider.value)
	settings_music_volume_value_label.text = "Music: %d%%" % roundi(settings_music_volume_slider.value)


func _setup_resolution_options() -> void:
	if settings_resolution_option.item_count > 0:
		return
	settings_resolution_option.add_item("1280 x 720", 0)
	settings_resolution_option.add_item("1600 x 900", 1)
	settings_resolution_option.add_item("1920 x 1080", 2)


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


func _update_input_hint() -> void:
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

		var label := str(action_info.get("label", action_name))
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


func _on_settings_button_pressed() -> void:
	_call_flow("open_settings_menu")


func _on_resume_button_pressed() -> void:
	_call_flow("resume_run")


func _on_restart_button_pressed() -> void:
	_call_flow("restart_run")


func _on_main_menu_button_pressed() -> void:
	_call_flow("return_to_main_menu")


func _on_settings_volume_changed(_value: float) -> void:
	_update_volume_value_label()


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


func _on_debug_map_copy_button_pressed() -> void:
	if copy_debug_map_to_clipboard():
		show_message("Debug Map Copied")
	else:
		show_message("No Debug Map")


func _on_debug_map_close_button_pressed() -> void:
	hide_debug_map_panel()

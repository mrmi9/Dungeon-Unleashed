extends Control
class_name LobbyScreen

signal start_requested
signal training_requested(target_drill_id: String)
signal settings_requested
signal back_requested
signal previous_character_requested
signal next_character_requested
signal unlock_character_requested

const PREFERRED_PANEL_SIZE := Vector2(820.0, 608.0)
const CONTENT_ICON_REGISTRY := preload("res://scripts/content/ContentIconRegistry.gd")
const RECORD_FILTER_OPTIONS := ["all", "types", "context", "sources"]
const RECORD_SOURCE_TYPE_FILTER_OPTIONS := ["all", "enemy", "boss", "hazard", "unknown"]
const COUNTER_ROUTE_DEFAULT_PAGE := "relics"
const COUNTER_ROUTE_PAGE_OPTIONS := ["relics", "weapons", "talents", "blessings", "statues"]

@onready var archive_panel: PanelContainer = $HallArchivePanel
@onready var current_character_label: Label = $HallArchivePanel/MarginContainer/VBoxContainer/CurrentCharacterLabel
@onready var current_character_icon_swatch: ColorRect = $HallArchivePanel/MarginContainer/VBoxContainer/CurrentCharacterIconRow/CurrentCharacterIconSwatch
@onready var current_character_icon_texture: TextureRect = $HallArchivePanel/MarginContainer/VBoxContainer/CurrentCharacterIconRow/CurrentCharacterIconTexture
@onready var current_character_icon_label: Label = $HallArchivePanel/MarginContainer/VBoxContainer/CurrentCharacterIconRow/CurrentCharacterIconLabel
@onready var previous_character_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/CharacterButtonRow/PreviousCharacterButton
@onready var next_character_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/CharacterButtonRow/NextCharacterButton
@onready var unlock_character_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/CharacterButtonRow/UnlockCharacterButton
@onready var selected_status_label: Label = $HallArchivePanel/MarginContainer/VBoxContainer/SelectedStatusLabel
@onready var quick_stats_label: Label = $HallArchivePanel/MarginContainer/VBoxContainer/QuickStatsLabel
@onready var start_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/ActionRow/StartButton
@onready var training_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/ActionRow/TrainingButton
@onready var settings_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/ActionRow/SettingsButton
@onready var all_tab_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/TabRow/AllTabButton
@onready var records_tab_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/TabRow/RecordsTabButton
@onready var characters_tab_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/TabRow/CharactersTabButton
@onready var weapons_tab_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/TabRow/WeaponsTabButton
@onready var relics_tab_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/TabRow/RelicsTabButton
@onready var talents_tab_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/TabRow/TalentsTabButton
@onready var blessings_tab_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/TabRow/BlessingsTabButton
@onready var statues_tab_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/TabRow/StatuesTabButton
@onready var codex_filter_row: HBoxContainer = $HallArchivePanel/MarginContainer/VBoxContainer/CodexFilterRow
@onready var previous_filter_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/CodexFilterRow/PreviousFilterButton
@onready var codex_filter_label: Label = $HallArchivePanel/MarginContainer/VBoxContainer/CodexFilterRow/CodexFilterLabel
@onready var next_filter_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/CodexFilterRow/NextFilterButton
@onready var clear_filter_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/CodexFilterRow/ClearFilterButton
@onready var codex_refinement_row: HBoxContainer = $HallArchivePanel/MarginContainer/VBoxContainer/CodexRefinementRow
@onready var codex_search_edit: LineEdit = $HallArchivePanel/MarginContainer/VBoxContainer/CodexRefinementRow/CodexSearchEdit
@onready var previous_sort_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/CodexRefinementRow/PreviousSortButton
@onready var codex_sort_label: Label = $HallArchivePanel/MarginContainer/VBoxContainer/CodexRefinementRow/CodexSortLabel
@onready var next_sort_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/CodexRefinementRow/NextSortButton
@onready var previous_rarity_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/CodexRefinementRow/PreviousRarityButton
@onready var codex_rarity_label: Label = $HallArchivePanel/MarginContainer/VBoxContainer/CodexRefinementRow/CodexRarityLabel
@onready var next_rarity_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/CodexRefinementRow/NextRarityButton
@onready var reset_refinement_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/CodexRefinementRow/ResetRefinementButton
@onready var archive_title_label: Label = $HallArchivePanel/MarginContainer/VBoxContainer/ArchiveTitleLabel
@onready var codex_detail_card: PanelContainer = $HallArchivePanel/MarginContainer/VBoxContainer/CodexDetailCard
@onready var codex_detail_rarity_strip: ColorRect = $HallArchivePanel/MarginContainer/VBoxContainer/CodexDetailCard/MarginContainer/VBoxContainer/CodexDetailVisualRow/CodexDetailRarityStrip
@onready var codex_detail_icon_swatch: ColorRect = $HallArchivePanel/MarginContainer/VBoxContainer/CodexDetailCard/MarginContainer/VBoxContainer/CodexDetailVisualRow/CodexDetailIconSwatch
@onready var codex_detail_icon_texture: TextureRect = $HallArchivePanel/MarginContainer/VBoxContainer/CodexDetailCard/MarginContainer/VBoxContainer/CodexDetailVisualRow/CodexDetailIconTexture
@onready var codex_detail_icon_label: Label = $HallArchivePanel/MarginContainer/VBoxContainer/CodexDetailCard/MarginContainer/VBoxContainer/CodexDetailVisualRow/CodexDetailIconLabel
@onready var codex_detail_rarity_label: Label = $HallArchivePanel/MarginContainer/VBoxContainer/CodexDetailCard/MarginContainer/VBoxContainer/CodexDetailVisualRow/CodexDetailRarityLabel
@onready var codex_detail_title_label: Label = $HallArchivePanel/MarginContainer/VBoxContainer/CodexDetailCard/MarginContainer/VBoxContainer/CodexDetailTitleLabel
@onready var codex_detail_meta_label: Label = $HallArchivePanel/MarginContainer/VBoxContainer/CodexDetailCard/MarginContainer/VBoxContainer/CodexDetailMetaLabel
@onready var codex_detail_body_label: Label = $HallArchivePanel/MarginContainer/VBoxContainer/CodexDetailCard/MarginContainer/VBoxContainer/CodexDetailBodyLabel
@onready var counter_route_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/CodexDetailCard/MarginContainer/VBoxContainer/CounterActionRow/CounterRouteButton
@onready var counter_pick_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/CodexDetailCard/MarginContainer/VBoxContainer/CounterActionRow/CounterPickButton
@onready var counter_pick_cycle_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/CodexDetailCard/MarginContainer/VBoxContainer/CounterCycleRow/CounterPickCycleButton
@onready var counter_pick_page_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/CodexDetailCard/MarginContainer/VBoxContainer/CounterCycleRow/CounterPickPageButton
@onready var counter_pick_type_row: HBoxContainer = $HallArchivePanel/MarginContainer/VBoxContainer/CodexDetailCard/MarginContainer/VBoxContainer/CounterPickTypeRow
@onready var counter_pick_type_weapons_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/CodexDetailCard/MarginContainer/VBoxContainer/CounterPickTypeRow/CounterPickTypeWeaponsButton
@onready var counter_pick_type_relics_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/CodexDetailCard/MarginContainer/VBoxContainer/CounterPickTypeRow/CounterPickTypeRelicsButton
@onready var counter_pick_type_talents_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/CodexDetailCard/MarginContainer/VBoxContainer/CounterPickTypeRow/CounterPickTypeTalentsButton
@onready var counter_pick_type_blessings_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/CodexDetailCard/MarginContainer/VBoxContainer/CounterPickTypeRow/CounterPickTypeBlessingsButton
@onready var counter_pick_type_statues_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/CodexDetailCard/MarginContainer/VBoxContainer/CounterPickTypeRow/CounterPickTypeStatuesButton
@onready var archive_label: Label = $HallArchivePanel/MarginContainer/VBoxContainer/ScrollContainer/ArchiveLabel
@onready var back_button: Button = $HallArchivePanel/MarginContainer/VBoxContainer/BackButton

const CODEX_SORT_OPTIONS := ["name", "rarity", "drop_weight"]
const COUNTER_PICK_TYPE_ACTIVE_COLOR := Color(1.0, 0.82, 0.28, 1.0)
const COUNTER_PICK_TYPE_INACTIVE_COLOR := Color(0.78, 0.86, 0.96, 1.0)

var _current_summary: Dictionary = {}
var _active_page := "all"
var _tab_buttons := {}
var _codex_filter_indexes := {}
var _codex_search_queries := {}
var _codex_sort_indexes := {}
var _codex_rarity_indexes := {}
var _records_filter_index := 0
var _records_source_type_filter_index := 0
var _counter_pick_focus_indexes := {}
var _counter_pick_page_focus_indexes := {}
var _objective_counter_pick_focus_indexes := {}
var _counter_pick_type_buttons := {}
var _current_character_icon_key := ""
var _current_character_icon_texture_path := ""
var _codex_detail_icon_key := ""
var _codex_detail_icon_texture_path := ""
var objective_board_row: HBoxContainer
var objective_progress_row: HBoxContainer
var objective_progress_label: Label
var objective_progress_bar: ProgressBar
var objective_progress_value_label: Label
var objective_progress_action_button: Button
var objective_board_action_row: HBoxContainer
var objective_board_label: Label
var objective_start_run_button: Button
var objective_counter_button: Button
var objective_build_route_button: Button
var objective_counter_pick_button: Button
var objective_counter_pick_cycle_button: Button
var objective_counter_pick_type_label: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_objective_board()
	previous_character_button.pressed.connect(_on_previous_character_button_pressed)
	next_character_button.pressed.connect(_on_next_character_button_pressed)
	unlock_character_button.pressed.connect(_on_unlock_character_button_pressed)
	start_button.pressed.connect(_on_start_button_pressed)
	training_button.pressed.connect(_on_training_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	_setup_tab_buttons()
	_setup_codex_filter_controls()
	_setup_counter_pick_type_buttons()
	if counter_route_button != null:
		counter_route_button.pressed.connect(_on_counter_route_button_pressed)
	if counter_pick_button != null:
		counter_pick_button.pressed.connect(_on_counter_pick_button_pressed)
	if counter_pick_cycle_button != null:
		counter_pick_cycle_button.pressed.connect(_on_counter_pick_cycle_button_pressed)
	if counter_pick_page_button != null:
		counter_pick_page_button.pressed.connect(_on_counter_pick_page_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	_update_layout_from_viewport()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_update_layout_from_viewport()


func show_summary(summary: Dictionary) -> void:
	_current_summary = summary.duplicate(true)
	quick_stats_label.text = _format_quick_stats(summary)
	if objective_board_label != null:
		objective_board_label.text = _format_objective_board(summary)
	_update_objective_progress(summary)
	_update_objective_buttons()
	_refresh_current_character_icon()
	_refresh_archive_page()
	visible = true
	_update_layout_from_viewport()


func hide_screen() -> void:
	visible = false


func update_character_selection(display_name: String, description: String, skill_name: String, skill_description: String, index: int, total: int) -> void:
	current_character_label.text = "Character %d/%d: %s\n%s\nSkill: %s - %s" % [
		index + 1,
		maxi(total, 1),
		display_name,
		description,
		skill_name,
		skill_description,
	]
	_sync_current_character_summary_selection(display_name, index)
	_refresh_current_character_icon()
	_update_objective_buttons()


func update_character_unlock_status(unlocked: bool, unlock_cost: int, currency: int) -> void:
	if unlocked:
		selected_status_label.text = "Selected: Ready"
		unlock_character_button.text = "Unlocked"
		unlock_character_button.disabled = true
		start_button.disabled = false
		training_button.disabled = false
		_update_objective_buttons()
		return

	selected_status_label.text = "Selected: Locked - %d Data Shards (%d owned)" % [
		maxi(unlock_cost, 0),
		maxi(currency, 0),
	]
	unlock_character_button.text = "Unlock %d" % maxi(unlock_cost, 0)
	unlock_character_button.disabled = currency < unlock_cost
	start_button.disabled = true
	training_button.disabled = true
	_update_objective_buttons()


func update_layout(viewport_size: Vector2, safe_margin: float) -> void:
	if archive_panel == null:
		return

	var max_size := Vector2(
		maxf(viewport_size.x - safe_margin * 2.0, 1.0),
		maxf(viewport_size.y - safe_margin * 2.0, 1.0)
	)
	var fitted_size := Vector2(
		minf(PREFERRED_PANEL_SIZE.x, max_size.x),
		minf(PREFERRED_PANEL_SIZE.y, max_size.y)
	)
	archive_panel.offset_left = -roundf(fitted_size.x * 0.5)
	archive_panel.offset_right = roundf(fitted_size.x * 0.5)
	archive_panel.offset_top = -roundf(fitted_size.y * 0.5)
	archive_panel.offset_bottom = roundf(fitted_size.y * 0.5)


func get_archive_text() -> String:
	return archive_label.text if archive_label != null else ""


func get_active_page() -> String:
	return _active_page


func get_quick_stats_text() -> String:
	return quick_stats_label.text if quick_stats_label != null else ""


func get_objective_board_text() -> String:
	return objective_board_label.text if objective_board_label != null else ""


func get_objective_progress_text() -> String:
	return objective_progress_label.text if objective_progress_label != null else ""


func get_objective_progress_tooltip_text() -> String:
	return objective_progress_bar.tooltip_text if objective_progress_bar != null else ""


func get_objective_progress_value_text() -> String:
	return objective_progress_value_label.text if objective_progress_value_label != null else ""


func get_objective_progress_action_button_text() -> String:
	return objective_progress_action_button.text if objective_progress_action_button != null else ""


func get_objective_progress_action_button_tooltip_text() -> String:
	return objective_progress_action_button.tooltip_text if objective_progress_action_button != null else ""


func is_objective_progress_action_button_visible() -> bool:
	return objective_progress_action_button != null and objective_progress_action_button.visible


func get_objective_progress_value() -> int:
	return roundi(objective_progress_bar.value) if objective_progress_bar != null else 0


func is_objective_progress_visible() -> bool:
	return objective_progress_row != null and objective_progress_row.visible


func is_objective_board_action_row_visible() -> bool:
	return objective_board_action_row != null and objective_board_action_row.visible


func is_objective_start_run_button_visible() -> bool:
	return objective_start_run_button != null and objective_start_run_button.visible


func get_objective_start_run_button_text() -> String:
	return objective_start_run_button.text if objective_start_run_button != null else ""


func get_objective_start_run_button_tooltip_text() -> String:
	return objective_start_run_button.tooltip_text if objective_start_run_button != null else ""


func is_objective_board_split_layout_enabled() -> bool:
	return (
		objective_board_row != null
		and objective_board_action_row != null
		and objective_board_label != null
		and objective_counter_button != null
		and objective_board_label.get_parent() == objective_board_row
		and objective_counter_button.get_parent() == objective_board_action_row
	)


func get_objective_counter_button_text() -> String:
	return objective_counter_button.text if objective_counter_button != null else ""


func is_objective_counter_button_visible() -> bool:
	return objective_counter_button != null and objective_counter_button.visible


func get_objective_build_route_button_text() -> String:
	return objective_build_route_button.text if objective_build_route_button != null else ""


func get_objective_build_route_button_tooltip_text() -> String:
	return objective_build_route_button.tooltip_text if objective_build_route_button != null else ""


func is_objective_build_route_button_visible() -> bool:
	return objective_build_route_button != null and objective_build_route_button.visible


func get_objective_counter_pick_button_text() -> String:
	return objective_counter_pick_button.text if objective_counter_pick_button != null else ""


func get_objective_counter_pick_button_tooltip_text() -> String:
	return objective_counter_pick_button.tooltip_text if objective_counter_pick_button != null else ""


func is_objective_counter_pick_button_visible() -> bool:
	return objective_counter_pick_button != null and objective_counter_pick_button.visible


func get_objective_counter_pick_cycle_button_text() -> String:
	return objective_counter_pick_cycle_button.text if objective_counter_pick_cycle_button != null else ""


func get_objective_counter_pick_cycle_button_tooltip_text() -> String:
	return objective_counter_pick_cycle_button.tooltip_text if objective_counter_pick_cycle_button != null else ""


func is_objective_counter_pick_cycle_button_visible() -> bool:
	return objective_counter_pick_cycle_button != null and objective_counter_pick_cycle_button.visible


func get_objective_counter_pick_type_label_text() -> String:
	return objective_counter_pick_type_label.text if objective_counter_pick_type_label != null else ""


func get_objective_counter_pick_type_label_tooltip_text() -> String:
	return objective_counter_pick_type_label.tooltip_text if objective_counter_pick_type_label != null else ""


func is_objective_counter_pick_type_label_visible() -> bool:
	return objective_counter_pick_type_label != null and objective_counter_pick_type_label.visible


func get_current_character_text() -> String:
	return current_character_label.text if current_character_label != null else ""


func get_current_character_icon_text() -> String:
	return current_character_icon_label.text if current_character_icon_label != null else ""


func get_current_character_icon_key() -> String:
	return _current_character_icon_key


func get_current_character_icon_swatch_color() -> Color:
	return current_character_icon_swatch.color if current_character_icon_swatch != null else Color(0.0, 0.0, 0.0, 0.0)


func get_current_character_icon_texture_path() -> String:
	return _current_character_icon_texture_path


func is_current_character_icon_texture_visible() -> bool:
	return current_character_icon_texture != null and current_character_icon_texture.visible


func get_current_character_icon_tooltip_text() -> String:
	if current_character_icon_texture != null and current_character_icon_texture.visible:
		return current_character_icon_texture.tooltip_text
	return current_character_icon_swatch.tooltip_text if current_character_icon_swatch != null else ""


func get_selected_status_text() -> String:
	return selected_status_label.text if selected_status_label != null else ""


func get_unlock_button_text() -> String:
	return unlock_character_button.text if unlock_character_button != null else ""


func get_codex_filter_text() -> String:
	return codex_filter_label.text if codex_filter_label != null else ""


func get_records_filter_text() -> String:
	return codex_filter_label.text if codex_filter_label != null and _active_page == "records" else ""


func get_records_source_type_filter_text() -> String:
	return codex_sort_label.text if codex_sort_label != null and _active_page == "records" else ""


func get_codex_search_text() -> String:
	return codex_search_edit.text if codex_search_edit != null else ""


func get_codex_sort_text() -> String:
	return codex_sort_label.text if codex_sort_label != null else ""


func get_codex_rarity_text() -> String:
	return codex_rarity_label.text if codex_rarity_label != null else ""


func is_codex_filter_visible() -> bool:
	return codex_filter_row != null and codex_filter_row.visible


func is_codex_refinement_visible() -> bool:
	return codex_refinement_row != null and codex_refinement_row.visible


func is_codex_detail_card_visible() -> bool:
	return codex_detail_card != null and codex_detail_card.visible


func get_codex_detail_title_text() -> String:
	return codex_detail_title_label.text if codex_detail_title_label != null else ""


func get_codex_detail_icon_text() -> String:
	return codex_detail_icon_label.text if codex_detail_icon_label != null else ""


func get_codex_detail_icon_key() -> String:
	return _codex_detail_icon_key


func get_codex_detail_icon_swatch_color() -> Color:
	return codex_detail_icon_swatch.color if codex_detail_icon_swatch != null else Color(0.0, 0.0, 0.0, 0.0)


func get_codex_detail_icon_texture_path() -> String:
	return _codex_detail_icon_texture_path


func is_codex_detail_icon_texture_visible() -> bool:
	return codex_detail_icon_texture != null and codex_detail_icon_texture.visible


func get_codex_detail_icon_tooltip_text() -> String:
	if codex_detail_icon_texture != null and codex_detail_icon_texture.visible:
		return codex_detail_icon_texture.tooltip_text
	return codex_detail_icon_swatch.tooltip_text if codex_detail_icon_swatch != null else ""


func get_codex_detail_rarity_badge_text() -> String:
	return codex_detail_rarity_label.text if codex_detail_rarity_label != null else ""


func get_codex_detail_meta_text() -> String:
	return codex_detail_meta_label.text if codex_detail_meta_label != null else ""


func get_codex_detail_body_text() -> String:
	return codex_detail_body_label.text if codex_detail_body_label != null else ""


func get_counter_route_button_text() -> String:
	return counter_route_button.text if counter_route_button != null else ""


func is_counter_route_button_visible() -> bool:
	return counter_route_button != null and counter_route_button.visible


func get_counter_pick_button_text() -> String:
	return counter_pick_button.text if counter_pick_button != null else ""


func is_counter_pick_button_visible() -> bool:
	return counter_pick_button != null and counter_pick_button.visible


func get_counter_pick_cycle_button_text() -> String:
	return counter_pick_cycle_button.text if counter_pick_cycle_button != null else ""


func is_counter_pick_cycle_button_visible() -> bool:
	return counter_pick_cycle_button != null and counter_pick_cycle_button.visible


func get_counter_pick_page_button_text() -> String:
	return counter_pick_page_button.text if counter_pick_page_button != null else ""


func is_counter_pick_page_button_visible() -> bool:
	return counter_pick_page_button != null and counter_pick_page_button.visible


func get_counter_pick_type_button_text(page: String) -> String:
	var button := _get_counter_pick_type_button(page)
	return button.text if button != null else ""


func get_counter_pick_type_button_tooltip_text(page: String) -> String:
	var button := _get_counter_pick_type_button(page)
	return button.tooltip_text if button != null else ""


func get_counter_pick_type_button_font_color_text(page: String) -> String:
	var button := _get_counter_pick_type_button(page)
	if button == null:
		return ""
	var color_name := "font_disabled_color" if button.disabled else "font_color"
	return _format_color_text(button.get_theme_color(color_name))


func is_counter_pick_type_button_visible(page: String) -> bool:
	var button := _get_counter_pick_type_button(page)
	return counter_pick_type_row != null and counter_pick_type_row.visible and button != null and button.visible


func is_counter_pick_type_button_pressed(page: String) -> bool:
	var button := _get_counter_pick_type_button(page)
	return button != null and button.button_pressed


func get_archive_label() -> Label:
	return archive_label


func get_back_button() -> Button:
	return back_button


func is_start_button_disabled() -> bool:
	return start_button == null or start_button.disabled


func is_training_button_disabled() -> bool:
	return training_button == null or training_button.disabled


func is_unlock_button_disabled() -> bool:
	return unlock_character_button == null or unlock_character_button.disabled


func select_tab_for_test(page: String) -> void:
	_set_active_page(page)


func request_previous_character_for_test() -> void:
	_on_previous_character_button_pressed()


func request_next_character_for_test() -> void:
	_on_next_character_button_pressed()


func request_unlock_for_test() -> void:
	_on_unlock_character_button_pressed()


func request_start_for_test() -> void:
	_on_start_button_pressed()


func request_training_for_test() -> void:
	_on_training_button_pressed()


func request_settings_for_test() -> void:
	_on_settings_button_pressed()


func request_back_for_test() -> void:
	_on_back_button_pressed()


func request_previous_codex_filter_for_test() -> void:
	_cycle_codex_filter(-1)


func request_next_codex_filter_for_test() -> void:
	_cycle_codex_filter(1)


func request_clear_codex_filter_for_test() -> void:
	_clear_codex_filter()


func request_previous_records_filter_for_test() -> void:
	_cycle_records_filter(-1)


func request_next_records_filter_for_test() -> void:
	_cycle_records_filter(1)


func request_clear_records_filter_for_test() -> void:
	_clear_records_filter()


func request_previous_records_source_type_for_test() -> void:
	_cycle_records_source_type_filter(-1)


func request_next_records_source_type_for_test() -> void:
	_cycle_records_source_type_filter(1)


func request_clear_records_source_type_for_test() -> void:
	_clear_records_source_type_filter()


func request_objective_counter_for_test() -> bool:
	return open_objective_counter()


func request_objective_build_route_for_test() -> bool:
	return open_objective_build_route()


func request_objective_counter_pick_for_test() -> bool:
	return open_objective_counter_pick()


func request_next_objective_counter_pick_for_test() -> bool:
	return cycle_objective_counter_pick()


func request_objective_progress_action_for_test() -> bool:
	return open_objective_progress_target()


func request_objective_start_run_for_test() -> void:
	_on_objective_start_run_button_pressed()


func request_next_counter_pick_for_test() -> void:
	_cycle_counter_pick_focus(1)


func request_next_counter_pick_page_for_test() -> void:
	_cycle_counter_pick_page_focus(1)


func request_counter_pick_page_for_test(page: String) -> bool:
	return _set_counter_pick_page_focus(page)


func set_codex_filter_for_test(tag: String) -> void:
	_set_codex_filter(tag)


func set_records_filter_for_test(filter_id: String) -> void:
	_set_records_filter(filter_id)


func set_records_source_type_for_test(source_type: String) -> void:
	_set_records_source_type_filter(source_type)


func set_codex_search_for_test(query: String) -> void:
	_set_codex_search_query(query)


func set_codex_sort_for_test(sort_key: String) -> void:
	_set_codex_sort(sort_key)


func set_codex_rarity_for_test(rarity: String) -> void:
	_set_codex_rarity_filter(rarity)


func reset_codex_refinements_for_test() -> void:
	_reset_codex_refinements()


func open_counter_route_for_test(page: String = COUNTER_ROUTE_DEFAULT_PAGE, tag: String = "") -> bool:
	return open_counter_route(page, tag)


func open_objective_counter() -> bool:
	var last_defeat: Dictionary = _current_summary.get("last_defeat", {})
	if not bool(last_defeat.get("has_record", false)):
		return false

	_active_page = "records"
	_refresh_tab_buttons()
	_set_records_filter("sources")
	_set_records_source_type_filter(str(last_defeat.get("source_type", "all")))
	return true


func open_objective_build_route() -> bool:
	var last_defeat: Dictionary = _current_summary.get("last_defeat", {})
	if not bool(last_defeat.get("has_record", false)):
		return false

	var target := _resolve_counter_route_target(last_defeat, COUNTER_ROUTE_DEFAULT_PAGE, "")
	if target.is_empty():
		return false

	var target_page := str(target.get("page", COUNTER_ROUTE_DEFAULT_PAGE)).strip_edges().to_lower()
	var target_tag := str(target.get("tag", "")).strip_edges().to_lower()
	var target_index := _get_codex_filter_index(target_page, target_tag)
	if target_index < 0:
		return false

	_active_page = target_page
	_codex_filter_indexes[target_page] = target_index
	_codex_search_queries[target_page] = ""
	_codex_sort_indexes[target_page] = 0
	_codex_rarity_indexes[target_page] = 0
	_refresh_tab_buttons()
	_refresh_archive_page()
	return true


func open_objective_counter_pick() -> bool:
	var last_defeat: Dictionary = _current_summary.get("last_defeat", {})
	if not bool(last_defeat.get("has_record", false)):
		return false
	return _open_counter_pick_target(_get_objective_counter_pick_target(last_defeat))


func open_objective_progress_target() -> bool:
	var progress := _get_objective_progress_summary(_current_summary)
	if progress.is_empty():
		return false
	match str(progress.get("action", "")):
		"page":
			var target_page := str(progress.get("target_page", "")).strip_edges().to_lower()
			if target_page.is_empty():
				return false
			_set_active_page(target_page)
			return true
		"training":
			training_requested.emit(str(progress.get("target_drill_id", "")))
			return true
	return false


func cycle_objective_counter_pick(delta: int = 1) -> bool:
	var last_defeat: Dictionary = _current_summary.get("last_defeat", {})
	if not bool(last_defeat.get("has_record", false)):
		return false

	var targets := _get_objective_counter_pick_targets(last_defeat)
	if targets.size() <= 1:
		return false

	var focus_key := _get_objective_counter_pick_focus_key(last_defeat)
	var current := clampi(int(_objective_counter_pick_focus_indexes.get(focus_key, 0)), 0, targets.size() - 1)
	var next_index := (current + delta) % targets.size()
	if next_index < 0:
		next_index += targets.size()
	_objective_counter_pick_focus_indexes[focus_key] = next_index
	if objective_board_label != null:
		objective_board_label.text = _format_objective_board(_current_summary)
	_update_objective_buttons()
	_refresh_archive_page()
	return true


func open_counter_route(page: String = COUNTER_ROUTE_DEFAULT_PAGE, tag: String = "") -> bool:
	var entry := _get_active_records_detail_source()
	if entry.is_empty():
		return false

	var target := _resolve_counter_route_target(entry, page, tag)
	if target.is_empty():
		return false

	var target_page := str(target.get("page", COUNTER_ROUTE_DEFAULT_PAGE)).strip_edges().to_lower()
	var target_tag := str(target.get("tag", "")).strip_edges().to_lower()
	var target_index := _get_codex_filter_index(target_page, target_tag)
	if target_index < 0:
		return false

	_active_page = target_page
	_codex_filter_indexes[target_page] = target_index
	_codex_search_queries[target_page] = ""
	_codex_sort_indexes[target_page] = 0
	_codex_rarity_indexes[target_page] = 0
	_refresh_tab_buttons()
	_refresh_archive_page()
	return true


func open_counter_pick_for_test(page: String = "", tag: String = "", display_name: String = "") -> bool:
	return open_counter_pick(page, tag, display_name)


func open_counter_pick(page: String = "", tag: String = "", display_name: String = "") -> bool:
	var entry := _get_active_records_detail_source()
	if entry.is_empty():
		return false

	var target := _get_focused_counter_pick_target(entry)
	if not page.strip_edges().is_empty() or not tag.strip_edges().is_empty() or not display_name.strip_edges().is_empty():
		target = _resolve_counter_pick_target(entry, page, tag, display_name)
	return _open_counter_pick_target(target)


func _open_counter_pick_target(target: Dictionary) -> bool:
	if target.is_empty():
		return false
	var target_page := str(target.get("page", COUNTER_ROUTE_DEFAULT_PAGE)).strip_edges().to_lower()
	var target_tag := str(target.get("tag", "")).strip_edges().to_lower()
	var target_name := str(target.get("display_name", "")).strip_edges()
	var target_index := _get_codex_filter_index(target_page, target_tag)
	if target_index < 0 or target_name.is_empty():
		return false

	_active_page = target_page
	_codex_filter_indexes[target_page] = target_index
	_codex_search_queries[target_page] = target_name
	_codex_sort_indexes[target_page] = 0
	_codex_rarity_indexes[target_page] = 0
	_refresh_tab_buttons()
	_refresh_archive_page()
	return true


func _update_layout_from_viewport() -> void:
	if not is_node_ready():
		return
	update_layout(get_viewport_rect().size, 18.0)


func _refresh_current_character_icon() -> void:
	if current_character_icon_swatch == null or current_character_icon_texture == null or current_character_icon_label == null:
		return

	var character_entry := _get_current_character_summary_entry()
	_set_current_character_icon_visuals(
		str(character_entry.get("icon_key", "")),
		str(character_entry.get("display_name", "Character"))
	)


func _get_current_character_summary_entry() -> Dictionary:
	var characters: Array = _current_summary.get("characters", [])
	var current_character_id := str(_current_summary.get("current_character_id", ""))
	if not current_character_id.is_empty():
		for entry in characters:
			if entry is Dictionary and str(entry.get("id", "")) == current_character_id:
				return entry

	for entry in characters:
		if entry is Dictionary:
			return entry
	return {}


func _sync_current_character_summary_selection(display_name: String, index: int) -> void:
	var characters: Array = _current_summary.get("characters", [])
	if index < 0 or index >= characters.size():
		return
	if not characters[index] is Dictionary:
		return

	var character_entry: Dictionary = characters[index]
	var character_id := str(character_entry.get("id", "")).strip_edges()
	if not character_id.is_empty():
		_current_summary["current_character_id"] = character_id
	var resolved_display_name := display_name.strip_edges()
	if not resolved_display_name.is_empty():
		character_entry["display_name"] = resolved_display_name
	characters[index] = character_entry
	_current_summary["characters"] = characters


func _get_objective_start_run_tooltip() -> String:
	var character_entry := _get_current_character_summary_entry()
	var display_name := str(character_entry.get("display_name", "")).strip_edges()
	if display_name.is_empty():
		display_name = "the selected character"
	if start_button != null and start_button.disabled:
		return "Unlock or select an available character before starting a run"
	return "Start a run with %s" % display_name


func _set_current_character_icon_visuals(icon_key: String, display_name: String) -> void:
	_current_character_icon_key = icon_key.strip_edges()
	_current_character_icon_texture_path = CONTENT_ICON_REGISTRY.get_texture_path(_current_character_icon_key, "characters")
	var tooltip_text := CONTENT_ICON_REGISTRY.get_placeholder_tooltip(_current_character_icon_key, display_name, "characters")
	current_character_icon_swatch.color = CONTENT_ICON_REGISTRY.get_placeholder_color(_current_character_icon_key, "characters")
	current_character_icon_swatch.tooltip_text = tooltip_text
	_update_current_character_icon_texture(_current_character_icon_texture_path, tooltip_text)
	current_character_icon_label.text = CONTENT_ICON_REGISTRY.get_type_token(_current_character_icon_key, "characters")
	current_character_icon_label.tooltip_text = tooltip_text


func _update_current_character_icon_texture(texture_path: String, tooltip_text: String) -> void:
	var loaded_texture: Texture2D = null
	var normalized_path := texture_path.strip_edges()
	if not normalized_path.is_empty():
		var loaded_resource := load(normalized_path)
		if loaded_resource is Texture2D:
			loaded_texture = loaded_resource

	current_character_icon_texture.texture = loaded_texture
	current_character_icon_texture.visible = loaded_texture != null
	current_character_icon_texture.tooltip_text = tooltip_text
	current_character_icon_swatch.visible = loaded_texture == null


func _format_quick_stats(summary: Dictionary) -> String:
	var history: Dictionary = summary.get("history", {})
	var meta: Dictionary = summary.get("meta_progression", {})
	var counts: Dictionary = summary.get("counts", {})
	return "%s %d | Runs %d | Wins %d | Badges %d/%d | Characters %d | Weapons %d | Relics %d | Talents %d | Blessings %d | Statues %d" % [
		str(meta.get("currency_name", "Data Shards")),
		int(meta.get("currency", 0)),
		int(history.get("runs", 0)),
		int(history.get("victories", 0)),
		int(meta.get("training_badge_count", 0)),
		int(meta.get("training_badge_total", int(counts.get("training_drills", 0)))),
		int(counts.get("characters", 0)),
		int(counts.get("weapons", 0)),
		int(counts.get("relics", 0)),
		int(counts.get("talents", 0)),
		int(counts.get("blessings", 0)),
		int(counts.get("statues", 0)),
	]


func _setup_objective_board() -> void:
	var parent := quick_stats_label.get_parent()
	if parent == null:
		return

	objective_board_row = archive_panel.get_node_or_null("MarginContainer/VBoxContainer/ObjectiveBoardRow") as HBoxContainer
	if objective_board_row == null:
		objective_board_row = HBoxContainer.new()
		objective_board_row.name = "ObjectiveBoardRow"
		objective_board_row.alignment = BoxContainer.ALIGNMENT_CENTER
		objective_board_row.add_theme_constant_override("separation", 8)
		parent.add_child(objective_board_row)

	var existing_label := objective_board_row.get_node_or_null("ObjectiveBoardLabel") as Label
	if existing_label != null:
		objective_board_label = existing_label
	else:
		objective_board_label = Label.new()
		objective_board_label.name = "ObjectiveBoardLabel"
		objective_board_label.custom_minimum_size = Vector2(0, 34)
		objective_board_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		objective_board_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		objective_board_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		objective_board_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		objective_board_label.add_theme_color_override("font_color", Color(0.78, 0.92, 1.0, 1.0))
		objective_board_label.add_theme_font_size_override("font_size", 12)
		objective_board_label.text = "Objectives: Preparing"
		objective_board_row.add_child(objective_board_label)

	objective_progress_row = archive_panel.get_node_or_null("MarginContainer/VBoxContainer/ObjectiveProgressRow") as HBoxContainer
	if objective_progress_row == null:
		objective_progress_row = HBoxContainer.new()
		objective_progress_row.name = "ObjectiveProgressRow"
		objective_progress_row.alignment = BoxContainer.ALIGNMENT_CENTER
		objective_progress_row.add_theme_constant_override("separation", 8)
		parent.add_child(objective_progress_row)

	var existing_progress_label := objective_progress_row.get_node_or_null("ObjectiveProgressLabel") as Label
	if existing_progress_label != null:
		objective_progress_label = existing_progress_label
	else:
		objective_progress_label = Label.new()
		objective_progress_label.name = "ObjectiveProgressLabel"
		objective_progress_label.custom_minimum_size = Vector2(188, 20)
		objective_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		objective_progress_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		objective_progress_label.add_theme_color_override("font_color", Color(0.78, 0.86, 0.96, 1.0))
		objective_progress_label.add_theme_font_size_override("font_size", 11)
		objective_progress_label.text = "Progress"
		objective_progress_row.add_child(objective_progress_label)

	var existing_progress_bar := objective_progress_row.get_node_or_null("ObjectiveProgressBar") as ProgressBar
	if existing_progress_bar != null:
		objective_progress_bar = existing_progress_bar
	else:
		objective_progress_bar = ProgressBar.new()
		objective_progress_bar.name = "ObjectiveProgressBar"
		objective_progress_bar.custom_minimum_size = Vector2(260, 16)
		objective_progress_bar.min_value = 0.0
		objective_progress_bar.max_value = 100.0
		objective_progress_bar.value = 0.0
		objective_progress_bar.show_percentage = false
		objective_progress_bar.tooltip_text = "Objective progress"
		objective_progress_row.add_child(objective_progress_bar)

	var existing_progress_value_label := objective_progress_row.get_node_or_null("ObjectiveProgressValueLabel") as Label
	if existing_progress_value_label != null:
		objective_progress_value_label = existing_progress_value_label
	else:
		objective_progress_value_label = Label.new()
		objective_progress_value_label.name = "ObjectiveProgressValueLabel"
		objective_progress_value_label.custom_minimum_size = Vector2(112, 20)
		objective_progress_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		objective_progress_value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		objective_progress_value_label.add_theme_color_override("font_color", Color(0.98, 0.86, 0.52, 1.0))
		objective_progress_value_label.add_theme_font_size_override("font_size", 11)
		objective_progress_value_label.text = "0/0"
		objective_progress_value_label.tooltip_text = "Objective progress value"
		objective_progress_row.add_child(objective_progress_value_label)

	var existing_progress_action_button := objective_progress_row.get_node_or_null("ObjectiveProgressActionButton") as Button
	if existing_progress_action_button != null:
		objective_progress_action_button = existing_progress_action_button
	else:
		objective_progress_action_button = Button.new()
		objective_progress_action_button.name = "ObjectiveProgressActionButton"
		objective_progress_action_button.custom_minimum_size = Vector2(78, 24)
		objective_progress_action_button.text = "Open"
		objective_progress_action_button.tooltip_text = "Open objective target"
		objective_progress_action_button.visible = false
		objective_progress_action_button.pressed.connect(_on_objective_progress_action_button_pressed)
		objective_progress_row.add_child(objective_progress_action_button)

	objective_board_action_row = archive_panel.get_node_or_null("MarginContainer/VBoxContainer/ObjectiveBoardActionRow") as HBoxContainer
	if objective_board_action_row == null:
		objective_board_action_row = HBoxContainer.new()
		objective_board_action_row.name = "ObjectiveBoardActionRow"
		objective_board_action_row.alignment = BoxContainer.ALIGNMENT_CENTER
		objective_board_action_row.add_theme_constant_override("separation", 6)
		parent.add_child(objective_board_action_row)

	parent.move_child(objective_board_row, quick_stats_label.get_index() + 1)
	parent.move_child(objective_progress_row, objective_board_row.get_index() + 1)
	parent.move_child(objective_board_action_row, objective_progress_row.get_index() + 1)

	var existing_start_button := _get_existing_objective_action_button("ObjectiveStartRunButton")
	if existing_start_button != null:
		objective_start_run_button = existing_start_button
	else:
		objective_start_run_button = Button.new()
		objective_start_run_button.name = "ObjectiveStartRunButton"
		objective_start_run_button.custom_minimum_size = Vector2(82, 30)
		objective_start_run_button.text = "Start"
		objective_start_run_button.tooltip_text = "Start a run with the selected character"
		objective_start_run_button.pressed.connect(_on_objective_start_run_button_pressed)
		objective_board_action_row.add_child(objective_start_run_button)

	var existing_button := _get_existing_objective_action_button("ObjectiveCounterButton")
	if existing_button != null:
		objective_counter_button = existing_button
	else:
		objective_counter_button = Button.new()
		objective_counter_button.name = "ObjectiveCounterButton"
		objective_counter_button.custom_minimum_size = Vector2(82, 30)
		objective_counter_button.text = "Review"
		objective_counter_button.tooltip_text = "Open Records Sources for the last defeat"
		objective_counter_button.pressed.connect(_on_objective_counter_button_pressed)
		objective_board_action_row.add_child(objective_counter_button)

	var existing_build_button := _get_existing_objective_action_button("ObjectiveBuildRouteButton")
	if existing_build_button != null:
		objective_build_route_button = existing_build_button
	else:
		objective_build_route_button = Button.new()
		objective_build_route_button.name = "ObjectiveBuildRouteButton"
		objective_build_route_button.custom_minimum_size = Vector2(72, 30)
		objective_build_route_button.text = "Build"
		objective_build_route_button.tooltip_text = "Open counter build route"
		objective_build_route_button.pressed.connect(_on_objective_build_route_button_pressed)
		objective_board_action_row.add_child(objective_build_route_button)

	var existing_pick_button := _get_existing_objective_action_button("ObjectiveCounterPickButton")
	if existing_pick_button != null:
		objective_counter_pick_button = existing_pick_button
	else:
		objective_counter_pick_button = Button.new()
		objective_counter_pick_button.name = "ObjectiveCounterPickButton"
		objective_counter_pick_button.custom_minimum_size = Vector2(68, 30)
		objective_counter_pick_button.text = "Pick"
		objective_counter_pick_button.tooltip_text = "Open counter pick"
		objective_counter_pick_button.pressed.connect(_on_objective_counter_pick_button_pressed)
		objective_board_action_row.add_child(objective_counter_pick_button)

	var existing_cycle_button := _get_existing_objective_action_button("ObjectiveCounterPickCycleButton")
	if existing_cycle_button != null:
		objective_counter_pick_cycle_button = existing_cycle_button
	else:
		objective_counter_pick_cycle_button = Button.new()
		objective_counter_pick_cycle_button.name = "ObjectiveCounterPickCycleButton"
		objective_counter_pick_cycle_button.custom_minimum_size = Vector2(74, 30)
		objective_counter_pick_cycle_button.text = "Next"
		objective_counter_pick_cycle_button.tooltip_text = "Cycle objective counter pick"
		objective_counter_pick_cycle_button.pressed.connect(_on_objective_counter_pick_cycle_button_pressed)
		objective_board_action_row.add_child(objective_counter_pick_cycle_button)

	var existing_type_label := _get_existing_objective_action_label("ObjectiveCounterPickTypeLabel")
	if existing_type_label != null:
		objective_counter_pick_type_label = existing_type_label
	else:
		objective_counter_pick_type_label = Label.new()
		objective_counter_pick_type_label.name = "ObjectiveCounterPickTypeLabel"
		objective_counter_pick_type_label.custom_minimum_size = Vector2(142, 30)
		objective_counter_pick_type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		objective_counter_pick_type_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		objective_counter_pick_type_label.add_theme_color_override("font_color", Color(0.86, 0.78, 0.52, 1.0))
		objective_counter_pick_type_label.add_theme_font_size_override("font_size", 11)
		objective_counter_pick_type_label.text = ""
		objective_counter_pick_type_label.tooltip_text = "Counter pick type legend"
		objective_counter_pick_type_label.visible = false
		objective_board_action_row.add_child(objective_counter_pick_type_label)
	_update_objective_buttons()


func _update_objective_progress(summary: Dictionary) -> void:
	if objective_progress_row == null or objective_progress_label == null or objective_progress_bar == null or objective_progress_value_label == null or objective_progress_action_button == null:
		return
	var progress := _get_objective_progress_summary(summary)
	objective_progress_row.visible = not progress.is_empty()
	if progress.is_empty():
		objective_progress_label.text = ""
		objective_progress_bar.value = 0.0
		objective_progress_bar.tooltip_text = "Objective progress"
		objective_progress_value_label.text = ""
		objective_progress_value_label.tooltip_text = "Objective progress value"
		objective_progress_action_button.visible = false
		objective_progress_action_button.disabled = true
		objective_progress_action_button.text = "Open"
		objective_progress_action_button.tooltip_text = "Open objective target"
		return
	objective_progress_label.text = str(progress.get("label", "Progress"))
	objective_progress_bar.value = clampf(float(progress.get("percent", 0.0)), 0.0, 100.0)
	objective_progress_bar.tooltip_text = str(progress.get("tooltip", "Objective progress"))
	objective_progress_value_label.text = str(progress.get("value_text", ""))
	objective_progress_value_label.tooltip_text = objective_progress_bar.tooltip_text
	objective_progress_action_button.visible = true
	objective_progress_action_button.disabled = false
	objective_progress_action_button.text = str(progress.get("action_text", "Open"))
	objective_progress_action_button.tooltip_text = str(progress.get("action_tooltip", progress.get("tooltip", "Open objective target")))


func _get_objective_progress_summary(summary: Dictionary) -> Dictionary:
	var unlock_progress := _get_next_unlock_progress(summary)
	if not unlock_progress.is_empty():
		return unlock_progress
	var mastery_progress := _get_current_mastery_progress(summary)
	if not mastery_progress.is_empty():
		return mastery_progress
	var training_progress := _get_training_badge_progress(summary)
	if not training_progress.is_empty():
		return training_progress
	return {}


func _get_next_unlock_progress(summary: Dictionary) -> Dictionary:
	var meta: Dictionary = summary.get("meta_progression", {})
	var currency_name := str(meta.get("currency_name", "Data Shards"))
	var currency := maxi(int(meta.get("currency", 0)), 0)
	for entry in summary.get("characters", []):
		if not (entry is Dictionary):
			continue
		var character: Dictionary = entry
		if bool(character.get("unlocked", false)):
			continue
		var cost := maxi(int(character.get("unlock_cost", 0)), 0)
		if cost <= 0:
			continue
		var current := mini(currency, cost)
		var percent := roundi(float(current) / float(cost) * 100.0)
		var display_name := str(character.get("display_name", "Character"))
		return {
			"label": "Unlock %s" % display_name,
			"percent": percent,
			"value_text": "%d/%d %s" % [
				current,
				cost,
				currency_name,
			],
			"action": "page",
			"target_page": "characters",
			"action_text": "Roster",
			"action_tooltip": "Open Characters to unlock %s" % display_name,
			"tooltip": "%s unlock progress: %d/%d %s" % [
				display_name,
				current,
				cost,
				currency_name,
			],
		}
	return {}


func _get_current_mastery_progress(summary: Dictionary) -> Dictionary:
	var character := _get_current_character_entry(summary)
	if character.is_empty():
		return {}
	var next_level := int(character.get("next_mastery_level", 0))
	if next_level <= 0:
		return {}
	var current := maxi(int(character.get("next_mastery_progress_current_xp", 0)), 0)
	var required := maxi(int(character.get("next_mastery_progress_required_xp", 1)), 1)
	var percent := clampi(int(character.get("next_mastery_progress_percent", roundi(float(current) / float(required) * 100.0))), 0, 100)
	var display_name := str(character.get("display_name", "Character"))
	return {
		"label": "Master %s" % display_name,
		"percent": percent,
		"value_text": "%d/%d XP" % [current, required],
		"action": "page",
		"target_page": "characters",
		"action_text": "Roster",
		"action_tooltip": "Open Characters to review %s mastery" % display_name,
		"tooltip": "%s mastery progress: %d/%d XP to L%d" % [
			display_name,
			current,
			required,
			next_level,
		],
	}


func _get_training_badge_progress(summary: Dictionary) -> Dictionary:
	var meta: Dictionary = summary.get("meta_progression", {})
	var badge_count := maxi(int(meta.get("training_badge_count", 0)), 0)
	var badge_total := maxi(int(meta.get("training_badge_total", 0)), 0)
	if badge_total <= 0:
		var training_drills: Array = summary.get("training_drills", [])
		badge_total = maxi(training_drills.size(), 0)
	if badge_total <= 0:
		return {}
	var current := mini(badge_count, badge_total)
	var percent := roundi(float(current) / float(badge_total) * 100.0)
	var target_drill := _get_next_training_drill_badge_target(summary)
	var training_drills: Array = summary.get("training_drills", [])
	if target_drill.is_empty() and not training_drills.is_empty() and current >= badge_total:
		return {}
	var target_drill_id := str(target_drill.get("id", ""))
	var target_drill_name := str(target_drill.get("display_name", "Training"))
	var target_goal := str(target_drill.get("goal_text", "")).strip_edges()
	var label_text := "Training Badges"
	var target_suffix := ""
	if not target_drill.is_empty():
		label_text = "Training: %s" % target_drill_name
		target_suffix = ": %s badge" % target_drill_name
		if not target_goal.is_empty():
			target_suffix = "%s - %s" % [target_suffix, target_goal]
	return {
		"label": label_text,
		"percent": percent,
		"value_text": "%d/%d badges" % [current, badge_total],
		"action": "training",
		"target_drill_id": target_drill_id,
		"target_drill_name": target_drill_name,
		"action_text": "Train",
		"action_tooltip": "Open Training%s" % target_suffix if not target_suffix.is_empty() else "Open Training to earn badges",
		"tooltip": "Training badge progress: %d/%d badges%s" % [current, badge_total, target_suffix],
	}


func _get_existing_objective_action_button(node_name: String) -> Button:
	var button := objective_board_action_row.get_node_or_null(node_name) as Button
	if button == null and objective_board_row != null:
		button = objective_board_row.get_node_or_null(node_name) as Button
	if button != null and button.get_parent() != objective_board_action_row:
		button.reparent(objective_board_action_row)
	return button


func _get_existing_objective_action_label(node_name: String) -> Label:
	var label := objective_board_action_row.get_node_or_null(node_name) as Label
	if label == null and objective_board_row != null:
		label = objective_board_row.get_node_or_null(node_name) as Label
	if label != null and label.get_parent() != objective_board_action_row:
		label.reparent(objective_board_action_row)
	return label


func _update_objective_buttons() -> void:
	var last_defeat: Dictionary = _current_summary.get("last_defeat", {})
	var has_defeat := bool(last_defeat.get("has_record", false))
	var has_start_run_action := _should_show_objective_start_run_action(_current_summary, has_defeat)

	if objective_board_action_row != null:
		objective_board_action_row.visible = has_defeat or has_start_run_action

	if objective_start_run_button != null:
		objective_start_run_button.visible = has_start_run_action
		objective_start_run_button.disabled = not has_start_run_action or start_button.disabled
		objective_start_run_button.text = "Start"
		objective_start_run_button.tooltip_text = _get_objective_start_run_tooltip()

	if objective_counter_button != null:
		objective_counter_button.visible = has_defeat
		objective_counter_button.disabled = not has_defeat

	var target := {}
	if has_defeat:
		target = _resolve_counter_route_target(last_defeat, COUNTER_ROUTE_DEFAULT_PAGE, "")
	var has_target := has_defeat and not target.is_empty()
	if objective_build_route_button != null:
		objective_build_route_button.visible = has_target
		objective_build_route_button.disabled = not has_target
		if has_target:
			objective_build_route_button.tooltip_text = "Open %s" % _format_counter_route_target(target)
		else:
			objective_build_route_button.tooltip_text = "Open counter build route"

	if objective_counter_pick_button == null:
		return

	var pick_target := {}
	if has_defeat:
		pick_target = _get_objective_counter_pick_target(last_defeat)
	var has_pick := has_defeat and not pick_target.is_empty()
	objective_counter_pick_button.visible = has_pick
	objective_counter_pick_button.disabled = not has_pick
	if has_pick:
		var pick_name := str(pick_target.get("display_name", "Pick")).strip_edges()
		var pick_route := _format_counter_route_target(pick_target)
		var pick_type_token := _format_counter_pick_type_token(str(pick_target.get("page", "")))
		objective_counter_pick_button.text = "Pick %s" % pick_type_token
		objective_counter_pick_button.tooltip_text = "Open counter pick: %s in %s" % [pick_name, pick_route]
	else:
		objective_counter_pick_button.text = "Pick"
		objective_counter_pick_button.tooltip_text = "Open counter pick"

	if objective_counter_pick_cycle_button == null:
		return

	var pick_targets := []
	if has_defeat:
		pick_targets = _get_objective_counter_pick_targets(last_defeat)
	var has_cycle := has_defeat and pick_targets.size() > 1
	var next_pick := {}
	objective_counter_pick_cycle_button.visible = has_cycle
	objective_counter_pick_cycle_button.disabled = not has_cycle
	if has_cycle:
		var pick_index := _get_objective_counter_pick_focus_index(last_defeat, pick_targets.size())
		next_pick = _get_counter_pick_target_at(pick_targets, (pick_index + 1) % pick_targets.size())
		var next_type_token := _format_counter_pick_type_token(str(next_pick.get("page", "")))
		objective_counter_pick_cycle_button.text = "Next %d/%d %s" % [
			pick_index + 1,
			pick_targets.size(),
			next_type_token,
		]
		var next_hint := _format_counter_pick_objective_hint(next_pick)
		if next_hint.is_empty():
			objective_counter_pick_cycle_button.tooltip_text = "Cycle objective counter picks for the last defeat"
		else:
			objective_counter_pick_cycle_button.tooltip_text = "Next pick: %s" % next_hint
	else:
		objective_counter_pick_cycle_button.text = "Next"
		objective_counter_pick_cycle_button.tooltip_text = "Cycle objective counter pick"

	_update_objective_counter_pick_type_label(has_pick, pick_target, next_pick)


func _should_show_objective_start_run_action(summary: Dictionary, has_defeat: bool) -> bool:
	if has_defeat or summary.is_empty():
		return false
	return (
		_format_next_unlock_goal(summary).is_empty()
		and _format_current_mastery_goal(summary).is_empty()
		and _format_next_training_goal(summary).is_empty()
	)


func _format_objective_board(summary: Dictionary) -> String:
	var goals := PackedStringArray()
	var counter_goal := _format_last_defeat_counter_goal(summary)
	if not counter_goal.is_empty():
		goals.append(counter_goal)
	var unlock_goal := _format_next_unlock_goal(summary)
	if not unlock_goal.is_empty():
		goals.append(unlock_goal)
	var mastery_goal := _format_current_mastery_goal(summary)
	if not mastery_goal.is_empty():
		goals.append(mastery_goal)
	var training_goal := _format_next_training_goal(summary)
	if not training_goal.is_empty():
		goals.append(training_goal)
	if goals.is_empty():
		return "Objectives: Start a run and test a new build"
	return "Objectives: %s" % " | ".join(goals)


func _format_last_defeat_counter_goal(summary: Dictionary) -> String:
	var last_defeat: Dictionary = summary.get("last_defeat", {})
	if not bool(last_defeat.get("has_record", false)):
		return ""

	var source_name := str(last_defeat.get("source_name", "")).strip_edges()
	if source_name.is_empty() or source_name.to_lower() == "unknown":
		source_name = _format_label_token(last_defeat.get("source_id", "Unknown"))

	var counter_text := _format_defeat_source_counter_build_tags(last_defeat).replace(", ", " / ")
	if counter_text.is_empty() or counter_text == "None":
		counter_text = "Safer Spacing"
	var pick_target := _get_objective_counter_pick_target(last_defeat)
	var pick_hint := _format_counter_pick_objective_hint(pick_target)
	if not pick_hint.is_empty():
		return "Counter %s: %s; %s" % [source_name, counter_text, pick_hint]
	return "Counter %s: %s" % [source_name, counter_text]


func _format_counter_pick_objective_hint(target: Dictionary) -> String:
	if target.is_empty():
		return ""
	var pick_name := str(target.get("display_name", "")).strip_edges()
	if pick_name.is_empty():
		return ""

	var route_parts := PackedStringArray()
	var page := str(target.get("page", "")).strip_edges()
	if not page.is_empty():
		route_parts.append(_format_label_token(page))
	var tag := str(target.get("tag", "")).strip_edges()
	if not tag.is_empty():
		route_parts.append(_format_label_token(tag))
	if route_parts.is_empty():
		return "Try %s" % pick_name
	return "Try %s [%s]" % [
		pick_name,
		"/".join(route_parts),
	]


func _update_objective_counter_pick_type_label(has_pick: bool, pick_target: Dictionary, next_pick: Dictionary) -> void:
	if objective_counter_pick_type_label == null:
		return
	objective_counter_pick_type_label.visible = has_pick
	if not has_pick:
		objective_counter_pick_type_label.text = ""
		objective_counter_pick_type_label.tooltip_text = "Counter pick type legend"
		return
	objective_counter_pick_type_label.text = _format_objective_counter_pick_type_hint(pick_target, next_pick)
	objective_counter_pick_type_label.tooltip_text = _format_objective_counter_pick_type_tooltip(pick_target, next_pick)


func _format_objective_counter_pick_type_hint(pick_target: Dictionary, next_pick: Dictionary) -> String:
	var current_label := _format_counter_pick_type_label(str(pick_target.get("page", "")))
	if next_pick.is_empty():
		return "Now %s" % current_label
	var next_label := _format_counter_pick_type_label(str(next_pick.get("page", "")))
	return "Now %s | Next %s" % [current_label, next_label]


func _format_objective_counter_pick_type_tooltip(pick_target: Dictionary, next_pick: Dictionary) -> String:
	var current_label := _format_counter_pick_type_label(str(pick_target.get("page", "")))
	var current_token := _format_counter_pick_type_token(str(pick_target.get("page", "")))
	if next_pick.is_empty():
		return "Current type: %s (%s)" % [current_label, current_token]
	var next_label := _format_counter_pick_type_label(str(next_pick.get("page", "")))
	var next_token := _format_counter_pick_type_token(str(next_pick.get("page", "")))
	return "Current type: %s (%s); Next type: %s (%s)" % [
		current_label,
		current_token,
		next_label,
		next_token,
	]


func _format_next_unlock_goal(summary: Dictionary) -> String:
	var meta: Dictionary = summary.get("meta_progression", {})
	var currency_name := str(meta.get("currency_name", "Data Shards"))
	var currency := maxi(int(meta.get("currency", 0)), 0)
	for entry in summary.get("characters", []):
		if not (entry is Dictionary):
			continue
		var character: Dictionary = entry
		if bool(character.get("unlocked", false)):
			continue
		var cost := maxi(int(character.get("unlock_cost", 0)), 0)
		if cost <= 0:
			continue
		return "Unlock %s %d/%d %s" % [
			str(character.get("display_name", "Character")),
			mini(currency, cost),
			cost,
			currency_name,
		]
	return ""


func _format_current_mastery_goal(summary: Dictionary) -> String:
	var character := _get_current_character_entry(summary)
	if character.is_empty():
		return ""
	var next_level := int(character.get("next_mastery_level", 0))
	var remaining := maxi(int(character.get("next_mastery_xp_remaining", 0)), 0)
	if next_level <= 0 or remaining <= 0:
		return ""
	return "Master %s %d XP to L%d" % [
		str(character.get("display_name", "Character")),
		remaining,
		next_level,
	]


func _format_next_training_goal(summary: Dictionary) -> String:
	var drill := _get_next_training_drill_badge_target(summary)
	if not drill.is_empty():
		return "Training %s badge: %s" % [
			str(drill.get("display_name", "Drill")),
			_first_non_empty([str(drill.get("goal_text", "")), "complete drill"]),
		]
	return ""


func _get_next_training_drill_badge_target(summary: Dictionary) -> Dictionary:
	for entry in summary.get("training_drills", []):
		if not (entry is Dictionary):
			continue
		var drill: Dictionary = entry
		if bool(drill.get("badge_unlocked", false)):
			continue
		return drill
	return {}


func _get_current_character_entry(summary: Dictionary) -> Dictionary:
	var current_character_id := str(summary.get("current_character_id", ""))
	for entry in summary.get("characters", []):
		if entry is Dictionary and str((entry as Dictionary).get("id", "")) == current_character_id:
			return entry as Dictionary
	return {}


func _setup_tab_buttons() -> void:
	_tab_buttons = {
		"all": all_tab_button,
		"records": records_tab_button,
		"characters": characters_tab_button,
		"weapons": weapons_tab_button,
		"relics": relics_tab_button,
		"talents": talents_tab_button,
		"blessings": blessings_tab_button,
		"statues": statues_tab_button,
	}
	all_tab_button.pressed.connect(_set_active_page.bind("all"))
	records_tab_button.pressed.connect(_set_active_page.bind("records"))
	characters_tab_button.pressed.connect(_set_active_page.bind("characters"))
	weapons_tab_button.pressed.connect(_set_active_page.bind("weapons"))
	relics_tab_button.pressed.connect(_set_active_page.bind("relics"))
	talents_tab_button.pressed.connect(_set_active_page.bind("talents"))
	blessings_tab_button.pressed.connect(_set_active_page.bind("blessings"))
	statues_tab_button.pressed.connect(_set_active_page.bind("statues"))
	_refresh_tab_buttons()


func _setup_codex_filter_controls() -> void:
	previous_filter_button.pressed.connect(_cycle_codex_filter.bind(-1))
	next_filter_button.pressed.connect(_cycle_codex_filter.bind(1))
	clear_filter_button.pressed.connect(_clear_codex_filter)
	codex_search_edit.text_changed.connect(_on_codex_search_text_changed)
	previous_sort_button.pressed.connect(_cycle_codex_sort.bind(-1))
	next_sort_button.pressed.connect(_cycle_codex_sort.bind(1))
	previous_rarity_button.pressed.connect(_cycle_codex_rarity.bind(-1))
	next_rarity_button.pressed.connect(_cycle_codex_rarity.bind(1))
	reset_refinement_button.pressed.connect(_reset_codex_refinements)
	_update_codex_filter_controls()
	_update_codex_refinement_controls()


func _setup_counter_pick_type_buttons() -> void:
	_counter_pick_type_buttons = {
		"weapons": counter_pick_type_weapons_button,
		"relics": counter_pick_type_relics_button,
		"talents": counter_pick_type_talents_button,
		"blessings": counter_pick_type_blessings_button,
		"statues": counter_pick_type_statues_button,
	}
	for page in _counter_pick_type_buttons.keys():
		var button := _counter_pick_type_buttons.get(page) as Button
		if button == null:
			continue
		button.pressed.connect(_on_counter_pick_type_button_pressed.bind(str(page)))


func _set_active_page(page: String) -> void:
	if not _tab_buttons.has(page):
		page = "all"
	_active_page = page
	_refresh_tab_buttons()
	_refresh_archive_page()


func _refresh_tab_buttons() -> void:
	for page in _tab_buttons.keys():
		var button := _tab_buttons.get(page) as Button
		if button == null:
			continue
		button.button_pressed = page == _active_page


func _refresh_archive_page() -> void:
	if archive_label == null:
		return
	archive_title_label.text = _get_page_title(_active_page)
	_update_codex_filter_controls()
	_update_codex_refinement_controls()
	_update_codex_detail_card()
	archive_label.text = _format_page(_current_summary, _active_page)


func _get_page_title(page: String) -> String:
	match page:
		"records":
			return "Records"
		"characters":
			return "Characters"
		"weapons":
			return "Weapons"
		"relics":
			return "Relics"
		"talents":
			return "Talents"
		"blessings":
			return "Blessings"
		"statues":
			return "Statues"
	return "All Records"


func _format_page(summary: Dictionary, page: String) -> String:
	match page:
		"records":
			return _format_records_page(summary, _get_active_records_filter(), true, _get_active_records_source_type_filter())
		"characters":
			return _format_characters_page(summary)
		"weapons":
			return _format_weapons_page(
				summary,
				_get_active_codex_filter_tag("weapons"),
				_get_active_codex_search_query("weapons"),
				_get_active_codex_rarity_filter("weapons"),
				_get_active_codex_sort_key("weapons")
			)
		"relics":
			return _format_relics_page(
				summary,
				_get_active_codex_filter_tag("relics"),
				_get_active_codex_search_query("relics"),
				_get_active_codex_rarity_filter("relics"),
				_get_active_codex_sort_key("relics")
			)
		"talents":
			return _format_talents_page(
				summary,
				_get_active_codex_filter_tag("talents"),
				_get_active_codex_search_query("talents"),
				_get_active_codex_rarity_filter("talents"),
				_get_active_codex_sort_key("talents")
			)
		"blessings":
			return _format_blessings_page(
				summary,
				_get_active_codex_filter_tag("blessings"),
				_get_active_codex_search_query("blessings"),
				_get_active_codex_rarity_filter("blessings"),
				_get_active_codex_sort_key("blessings")
			)
		"statues":
			return _format_statues_page(
				summary,
				_get_active_codex_filter_tag("statues"),
				_get_active_codex_search_query("statues"),
				_get_active_codex_rarity_filter("statues"),
				_get_active_codex_sort_key("statues")
			)
	return _format_hall_summary(summary)


func _format_hall_summary(summary: Dictionary) -> String:
	var history: Dictionary = summary.get("history", {})
	var meta: Dictionary = summary.get("meta_progression", {})
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
	lines.append(_format_records_page(summary))
	lines.append("")
	lines.append(_format_training_badges_page(summary))
	lines.append("")
	lines.append(_format_characters_page(summary))
	lines.append("")
	lines.append(_format_weapons_page(summary, "", "", "", "name", false))
	lines.append("")
	lines.append(_format_relics_page(summary, "", "", "", "name", false))
	lines.append("")
	lines.append(_format_talents_page(summary, "", "", "", "name", false))
	lines.append("")
	lines.append(_format_blessings_page(summary, "", "", "", "name", false))
	lines.append("")
	lines.append(_format_statues_page(summary, "", "", "", "name", false))

	return "\n".join(lines)


func _format_records_page(summary: Dictionary, death_view: String = "all", show_death_view_label: bool = false, source_type_filter: String = "all") -> String:
	var history: Dictionary = summary.get("history", {})
	var meta: Dictionary = summary.get("meta_progression", {})
	var last_defeat: Dictionary = summary.get("last_defeat", {})
	var defeat_sources: Array = summary.get("defeat_sources", [])
	var defeat_source_types: Dictionary = summary.get("defeat_source_types", {})
	var normalized_death_view := _normalize_records_filter(death_view)
	var normalized_source_type_filter := _normalize_records_source_type_filter(source_type_filter)
	var focused_defeat_sources := _get_records_defeat_sources(summary, normalized_death_view, normalized_source_type_filter)
	var lines: PackedStringArray = []
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
	lines.append("Defense: Best Guard Blocks %d" % int(history.get("best_projectiles_blocked", 0)))
	lines.append("%s: %d | Lifetime Earned: %d" % [
		str(meta.get("currency_name", "Data Shards")),
		int(meta.get("currency", 0)),
		int(meta.get("total_currency_earned", 0)),
	])
	if bool(last_defeat.get("has_record", false)):
		lines.append(_format_last_defeat_record(last_defeat))
	if not defeat_sources.is_empty():
		if show_death_view_label:
			lines.append("Death View: %s" % _format_records_filter_label(normalized_death_view))
		if _records_view_uses_source_type_filter(normalized_death_view) and normalized_source_type_filter != "all":
			lines.append("Source Type Filter: %s" % _format_records_source_type_filter_label(normalized_source_type_filter))
		var context_breakdown := _format_defeat_source_context_breakdown(focused_defeat_sources)
		match normalized_death_view:
			"types":
				lines.append(_format_defeat_source_type_counts(defeat_source_types))
			"context":
				if not context_breakdown.is_empty():
					lines.append(context_breakdown)
				else:
					lines.append("Death Context: None")
			"sources":
				lines.append(_format_defeat_source_records(focused_defeat_sources))
				var source_detail := _format_defeat_source_detail(focused_defeat_sources)
				if not source_detail.is_empty():
					lines.append(source_detail)
			_:
				lines.append(_format_defeat_source_type_counts(defeat_source_types))
				var full_context_breakdown := _format_defeat_source_context_breakdown(defeat_sources)
				if not full_context_breakdown.is_empty():
					lines.append(full_context_breakdown)
				lines.append(_format_defeat_source_records(defeat_sources))
	lines.append(_format_training_badges_page(summary))
	return "\n".join(lines)


func _get_records_defeat_sources(summary: Dictionary, death_view: String, source_type_filter: String) -> Array:
	var defeat_sources: Array = summary.get("defeat_sources", [])
	var normalized_death_view := _normalize_records_filter(death_view)
	var normalized_source_type_filter := _normalize_records_source_type_filter(source_type_filter)
	if _records_view_uses_source_type_filter(normalized_death_view):
		return _filter_defeat_source_records_by_type(defeat_sources, normalized_source_type_filter)
	return defeat_sources


func _format_last_defeat_record(record: Dictionary) -> String:
	return "Last Defeat: %s | Source %s%s | Seed %d | Biome %d | Rooms %d | Kills %d" % [
		str(record.get("text", "Unknown")),
		str(record.get("source_id", "unknown")),
		_format_defeat_source_context_suffix(record),
		int(record.get("dungeon_seed", 0)),
		int(record.get("biome_index", 0)),
		int(record.get("rooms_cleared", 0)),
		int(record.get("kills", 0)),
	]


func _format_defeat_source_type_counts(counts: Dictionary) -> String:
	return "Death Types: Enemy %d | Boss %d | Hazard %d | Unknown %d" % [
		int(counts.get("enemy", 0)),
		int(counts.get("boss", 0)),
		int(counts.get("hazard", 0)),
		int(counts.get("unknown", 0)),
	]


func _format_defeat_source_records(records: Array) -> String:
	if records.is_empty():
		return "Death Sources: None"
	var lines: PackedStringArray = []
	lines.append("Death Sources")
	var count := mini(records.size(), 3)
	for index in range(count):
		var entry: Dictionary = records[index] if records[index] is Dictionary else {}
		lines.append("- %s x%d | %s | Type %s | Last Seed %d | Last Biome %d%s" % [
			str(entry.get("source_id", "unknown")),
			int(entry.get("count", 0)),
			str(entry.get("source_name", "Unknown")),
			_format_defeat_source_type_context(entry),
			int(entry.get("last_seed", 0)),
			int(entry.get("last_biome_index", 0)),
			_format_defeat_source_context_suffix(entry),
		])
	return "\n".join(lines)


func _get_active_records_detail_source() -> Dictionary:
	if _active_page != "records":
		return {}
	if _get_active_records_filter() != "sources":
		return {}
	var records := _get_records_defeat_sources(_current_summary, "sources", _get_active_records_source_type_filter())
	if records.is_empty() or not records[0] is Dictionary:
		return {}
	return (records[0] as Dictionary).duplicate()


func _format_defeat_source_detail(records: Array) -> String:
	if records.is_empty():
		return ""
	var entry: Dictionary = records[0] if records[0] is Dictionary else {}
	if entry.is_empty():
		return ""

	var last_text := str(entry.get("last_text", "Unknown")).strip_edges()
	if last_text.is_empty():
		last_text = "Unknown"

	var lines := PackedStringArray()
	lines.append("Death Source Detail")
	lines.append("- %s | %s | Type %s | Count %d | Last Seed %d | Last Biome %d%s" % [
		str(entry.get("source_id", "unknown")),
		str(entry.get("source_name", "Unknown")),
		_format_defeat_source_type_context(entry),
		int(entry.get("count", 0)),
		int(entry.get("last_seed", 0)),
		int(entry.get("last_biome_index", 0)),
		_format_defeat_source_context_suffix(entry),
	])
	lines.append("- Last Cause: %s" % last_text)
	lines.append("- Threat Intel: %s" % _format_defeat_source_threat_intel(entry))
	lines.append("- Counter Build: %s" % _format_defeat_source_counter_build_tags(entry))
	lines.append("- Counter Route: %s" % _format_defeat_source_counter_route(entry))
	lines.append("- Counter Focus: %s" % _format_defeat_source_counter_pick_focus(entry))
	lines.append("- Counter Picks: %s" % _format_defeat_source_counter_picks(entry))
	lines.append("- Review: %s" % _format_defeat_source_review_tip(entry))
	return "\n".join(lines)


func _format_defeat_source_detail_meta(entry: Dictionary) -> String:
	return "Type %s | Count %d | Last Seed %d | Last Biome %d" % [
		_format_label_token(_format_defeat_source_type_context(entry)),
		int(entry.get("count", 0)),
		int(entry.get("last_seed", 0)),
		int(entry.get("last_biome_index", 0)),
	]


func _format_defeat_source_detail_body(entry: Dictionary) -> String:
	var last_text := str(entry.get("last_text", "Unknown")).strip_edges()
	if last_text.is_empty():
		last_text = "Unknown"

	var context_text := "None"
	var context_suffix := _format_defeat_source_context_suffix(entry)
	var context_prefix := " | Context "
	if context_suffix.begins_with(context_prefix):
		context_text = context_suffix.substr(context_prefix.length())

	return "Last Cause: %s\nContext: %s\nThreat Intel: %s\nCounter Build: %s\nCounter Route: %s\nCounter Focus: %s\nCounter Picks: %s\nReview: %s\nSource ID: %s" % [
		last_text,
		context_text,
		_format_defeat_source_threat_intel(entry),
		_format_defeat_source_counter_build_tags(entry),
		_format_defeat_source_counter_route(entry),
		_format_defeat_source_counter_pick_focus(entry),
		_format_defeat_source_counter_picks(entry),
		_format_defeat_source_review_tip(entry),
		str(entry.get("source_id", "unknown")),
	]


func _format_defeat_source_threat_intel(entry: Dictionary) -> String:
	var provided_intel := str(entry.get("source_threat_intel", "")).strip_edges()
	if not provided_intel.is_empty():
		return provided_intel

	var source_id := str(entry.get("source_id", "unknown")).strip_edges()
	if source_id.is_empty():
		source_id = "unknown"
	var source_name := str(entry.get("source_name", "Unknown")).strip_edges()
	if source_name.is_empty():
		source_name = _format_record_context_token(source_id)

	var source_type := str(entry.get("source_type", "unknown")).strip_edges().to_lower()
	var room_type := str(entry.get("source_room_type", "")).strip_edges().to_lower()
	match source_type:
		"hazard":
			var room_label := _format_record_context_token(room_type) if not room_type.is_empty() else "Room"
			match room_type:
				"trap":
					return "Room Hazard / %s | Tell warning lanes | Counter cross after pulse | Codex death_source_%s" % [
						room_label,
						source_id,
					]
				"challenge":
					return "Room Hazard / %s | Tell challenge warning zones | Counter finish rule before greed | Codex death_source_%s" % [
						room_label,
						source_id,
					]
				"boss":
					return "Arena Hazard / Boss | Tell overlapping floor warnings | Counter save armor recovery | Codex death_source_%s" % source_id
			return "Room Hazard | Tell floor warning zones | Counter keep movement lanes open | Codex death_source_%s" % source_id
		"boss":
			return "Boss Threat | Tell phase burst windows | Counter stop trading during tells | Codex death_source_%s" % source_id
		"enemy":
			return "Enemy Threat / %s | Tell movement or projectile pattern | Counter isolate before crossing open lanes | Codex death_source_%s" % [
				source_name,
				source_id,
			]
	return "Unknown Threat | Tell last room context | Counter rebuild for safer spacing | Codex death_source_%s" % source_id


func _format_defeat_source_counter_build_tags(entry: Dictionary) -> String:
	return _join_display_values(_get_defeat_source_counter_tags(entry))


func _format_defeat_source_counter_route(entry: Dictionary) -> String:
	return _format_counter_route_target(_resolve_counter_route_target(entry, COUNTER_ROUTE_DEFAULT_PAGE, ""))


func _format_defeat_source_counter_pick_focus(entry: Dictionary) -> String:
	var focused_page := _get_focused_counter_pick_page(entry)
	var targets := _collect_counter_pick_targets_for_page(entry, focused_page, "")
	if targets.is_empty():
		return "None"
	var focus_index := _get_counter_pick_focus_index(entry, targets.size())
	return _format_counter_pick_target(_get_counter_pick_target_at(targets, focus_index), focus_index, targets.size())


func _format_defeat_source_counter_picks(entry: Dictionary) -> String:
	var counter_tags := _get_defeat_source_counter_tags(entry)
	if counter_tags.is_empty():
		return "None"

	var sections := PackedStringArray()
	_add_counter_pick_section(sections, "Weapons", _current_summary.get("weapons", []), "tags", counter_tags, 2)
	_add_counter_pick_section(sections, "Relics", _current_summary.get("relics", []), "build_tags", counter_tags, 2)
	_add_counter_pick_section(sections, "Talents", _current_summary.get("talents", []), "build_tags", counter_tags, 2)
	_add_counter_pick_section(sections, "Blessings", _current_summary.get("blessings", []), "build_tags", counter_tags, 2)
	_add_counter_pick_section(sections, "Statues", _current_summary.get("statues", []), "build_tags", counter_tags, 1)
	if sections.is_empty():
		return "None"
	return " | ".join(sections)


func _add_counter_pick_section(sections: PackedStringArray, label: String, entries: Array, tag_key: String, counter_tags: Array, limit: int) -> void:
	var names := _collect_counter_pick_names(entries, tag_key, counter_tags, limit)
	if names.is_empty():
		return
	sections.append("%s %s" % [label, ", ".join(names)])


func _collect_counter_pick_names(entries: Array, tag_key: String, counter_tags: Array, limit: int) -> PackedStringArray:
	var names := PackedStringArray()
	if entries.is_empty() or counter_tags.is_empty() or limit <= 0:
		return names
	var normalized_tags := {}
	for tag in counter_tags:
		var normalized_tag := str(tag).strip_edges().to_lower()
		if not normalized_tag.is_empty():
			normalized_tags[normalized_tag] = true
	if normalized_tags.is_empty():
		return names

	for value in entries:
		if not value is Dictionary:
			continue
		var entry := value as Dictionary
		if not _entry_has_any_tag(entry, tag_key, normalized_tags):
			continue
		var display_name := str(entry.get("display_name", entry.get("id", ""))).strip_edges()
		if display_name.is_empty():
			continue
		names.append(display_name)
		if names.size() >= limit:
			break
	return names


func _entry_has_any_tag(entry: Dictionary, tag_key: String, normalized_tags: Dictionary) -> bool:
	for tag in _string_array_from_variant(entry.get(tag_key, [])):
		if normalized_tags.has(str(tag).strip_edges().to_lower()):
			return true
	return false


func _get_defeat_source_counter_tags(entry: Dictionary) -> Array:
	var provided_tags := _string_array_from_variant(entry.get("source_counter_tags", []))
	if not provided_tags.is_empty():
		return provided_tags

	var source_type := str(entry.get("source_type", "unknown")).strip_edges().to_lower()
	var room_type := str(entry.get("source_room_type", "")).strip_edges().to_lower()
	match source_type:
		"hazard":
			match room_type:
				"trap":
					return ["speed", "survival", "armor"]
				"challenge":
					return ["crowd_control", "damage", "survival"]
				"boss":
					return ["survival", "armor", "damage"]
			return ["speed", "survival"]
		"boss":
			return ["survival", "armor", "damage"]
		"enemy":
			return ["guard", "line_clear", "precision"]
	return ["survival", "damage"]


func _resolve_counter_route_target(entry: Dictionary, preferred_page: String, preferred_tag: String) -> Dictionary:
	var tag_order := _get_counter_route_tag_order(_get_defeat_source_counter_tags(entry), preferred_tag)
	if tag_order.is_empty():
		return {}

	for page in _get_counter_route_page_order(preferred_page):
		for tag in tag_order:
			if _get_codex_filter_index(str(page), str(tag)) >= 0:
				return {
					"page": str(page),
					"tag": str(tag),
				}
	return {}


func _resolve_counter_pick_target(entry: Dictionary, preferred_page: String, preferred_tag: String, preferred_name: String) -> Dictionary:
	var wanted_name := preferred_name.strip_edges().to_lower()
	var targets := _collect_counter_pick_targets(entry, preferred_page, preferred_tag)
	if targets.is_empty():
		return {}
	if wanted_name.is_empty():
		return (targets[0] as Dictionary).duplicate()
	for target_value in targets:
		if not target_value is Dictionary:
			continue
		var target := target_value as Dictionary
		if str(target.get("display_name", "")).strip_edges().to_lower() == wanted_name:
			return target.duplicate()
	return (targets[0] as Dictionary).duplicate()


func _get_focused_counter_pick_target(entry: Dictionary) -> Dictionary:
	var targets := _get_focused_counter_pick_targets(entry)
	if targets.is_empty():
		return {}
	var focus_index := _get_counter_pick_focus_index(entry, targets.size())
	return _get_counter_pick_target_at(targets, focus_index)


func _get_focused_counter_pick_targets(entry: Dictionary) -> Array:
	var focused_page := _get_focused_counter_pick_page(entry)
	return _collect_counter_pick_targets_for_page(entry, focused_page, "")


func _get_objective_counter_pick_target(entry: Dictionary) -> Dictionary:
	var targets := _get_objective_counter_pick_targets(entry)
	if targets.is_empty():
		return {}
	var focus_index := _get_objective_counter_pick_focus_index(entry, targets.size())
	return _get_counter_pick_target_at(targets, focus_index)


func _get_objective_counter_pick_targets(entry: Dictionary) -> Array:
	var page_targets: Array = []
	var max_targets := 0
	for page in _get_counter_route_page_order(COUNTER_ROUTE_DEFAULT_PAGE):
		var targets_for_page := _collect_counter_pick_targets_for_page(entry, str(page), "")
		if targets_for_page.is_empty():
			continue
		page_targets.append(targets_for_page)
		max_targets = maxi(max_targets, targets_for_page.size())

	var targets: Array = []
	var seen := {}
	for index in range(max_targets):
		for targets_for_page in page_targets:
			if index >= targets_for_page.size():
				continue
			var target := _get_counter_pick_target_at(targets_for_page, index)
			if target.is_empty():
				continue
			var target_key := "%s|%s" % [
				str(target.get("page", "")),
				str(target.get("display_name", "")).strip_edges().to_lower(),
			]
			if seen.has(target_key):
				continue
			seen[target_key] = true
			targets.append(target)
	return targets


func _get_counter_pick_focus_index(entry: Dictionary, target_count: int) -> int:
	if target_count <= 0:
		return 0
	var focus_key := _get_counter_pick_focus_key(entry)
	var focus_index := clampi(int(_counter_pick_focus_indexes.get(focus_key, 0)), 0, target_count - 1)
	_counter_pick_focus_indexes[focus_key] = focus_index
	return focus_index


func _get_objective_counter_pick_focus_index(entry: Dictionary, target_count: int) -> int:
	if target_count <= 0:
		return 0
	var focus_key := _get_objective_counter_pick_focus_key(entry)
	var focus_index := clampi(int(_objective_counter_pick_focus_indexes.get(focus_key, 0)), 0, target_count - 1)
	_objective_counter_pick_focus_indexes[focus_key] = focus_index
	return focus_index


func _get_counter_pick_target_at(targets: Array, index: int) -> Dictionary:
	if targets.is_empty():
		return {}
	var target_index := clampi(index, 0, targets.size() - 1)
	if not targets[target_index] is Dictionary:
		return {}
	return (targets[target_index] as Dictionary).duplicate()


func _get_focused_counter_pick_page(entry: Dictionary) -> String:
	var pages := _get_counter_pick_pages(entry)
	if pages.is_empty():
		return COUNTER_ROUTE_DEFAULT_PAGE
	var page_index := _get_counter_pick_page_focus_index(entry, pages.size())
	return str(pages[page_index])


func _get_counter_pick_pages(entry: Dictionary) -> Array:
	var pages: Array = []
	for page in COUNTER_ROUTE_PAGE_OPTIONS:
		if not _collect_counter_pick_targets_for_page(entry, str(page), "").is_empty():
			pages.append(str(page))
	return pages


func _get_counter_pick_page_focus_index(entry: Dictionary, page_count: int) -> int:
	if page_count <= 0:
		return 0
	var focus_key := _get_counter_pick_page_focus_key(entry)
	var focus_index := clampi(int(_counter_pick_page_focus_indexes.get(focus_key, 0)), 0, page_count - 1)
	_counter_pick_page_focus_indexes[focus_key] = focus_index
	return focus_index


func _get_counter_pick_page_focus_key(entry: Dictionary) -> String:
	var source_id := str(entry.get("source_id", "unknown")).strip_edges()
	if source_id.is_empty():
		source_id = "unknown"
	return "%s|%s" % [
		source_id,
		_get_active_records_source_type_filter(),
	]


func _get_counter_pick_type_button(page: String) -> Button:
	return _counter_pick_type_buttons.get(page.strip_edges().to_lower()) as Button


func _format_counter_pick_type_label(page: String) -> String:
	match page.strip_edges().to_lower():
		"weapons":
			return "Weapons"
		"relics":
			return "Relics"
		"talents":
			return "Talents"
		"blessings":
			return "Bless"
		"statues":
			return "Statues"
	return _format_label_token(page)


func _format_counter_pick_type_token(page: String) -> String:
	match page.strip_edges().to_lower():
		"weapons":
			return "W"
		"relics":
			return "R"
		"talents":
			return "T"
		"blessings":
			return "B"
		"statues":
			return "S"
	return _format_label_token(page).substr(0, 1).to_upper()


func _format_color_text(color: Color) -> String:
	return "%.2f,%.2f,%.2f,%.2f" % [
		color.r,
		color.g,
		color.b,
		color.a,
	]


func _collect_counter_pick_targets(entry: Dictionary, preferred_page: String, preferred_tag: String) -> Array:
	var targets: Array = []
	var seen := {}
	for page in _get_counter_route_page_order(preferred_page):
		for target_value in _collect_counter_pick_targets_for_page(entry, str(page), preferred_tag):
			if not target_value is Dictionary:
				continue
			var target := target_value as Dictionary
			var target_key := "%s|%s" % [
				str(target.get("page", page)),
				str(target.get("display_name", "")).strip_edges().to_lower(),
			]
			if seen.has(target_key):
				continue
			seen[target_key] = true
			targets.append(target.duplicate())
	return targets


func _collect_counter_pick_targets_for_page(entry: Dictionary, page: String, preferred_tag: String) -> Array:
	var tag_order := _get_counter_route_tag_order(_get_defeat_source_counter_tags(entry), preferred_tag)
	if tag_order.is_empty():
		return []
	var normalized_page := page.strip_edges().to_lower()
	if not _is_codex_filter_page(normalized_page):
		return []

	var targets: Array = []
	var seen := {}
	var tag_key := _get_codex_tag_key(normalized_page)
	for tag in tag_order:
		if _get_codex_filter_index(normalized_page, str(tag)) < 0:
			continue
		for pick in _collect_counter_pick_entries_for_tag(_get_codex_entries_for_page(normalized_page), tag_key, str(tag)):
			var display_name := str(pick.get("display_name", pick.get("id", ""))).strip_edges()
			if display_name.is_empty():
				continue
			var target_key := "%s|%s" % [normalized_page, display_name.to_lower()]
			if seen.has(target_key):
				continue
			seen[target_key] = true
			targets.append({
				"page": normalized_page,
				"tag": str(tag),
				"display_name": display_name,
			})
	return targets


func _get_counter_pick_focus_key(entry: Dictionary) -> String:
	var source_id := str(entry.get("source_id", "unknown")).strip_edges()
	if source_id.is_empty():
		source_id = "unknown"
	return "%s|%s" % [
		source_id,
		_get_active_records_source_type_filter(),
	]


func _get_objective_counter_pick_focus_key(entry: Dictionary) -> String:
	var source_id := str(entry.get("source_id", "unknown")).strip_edges()
	if source_id.is_empty():
		source_id = "unknown"
	var source_type := str(entry.get("source_type", "unknown")).strip_edges().to_lower()
	if source_type.is_empty():
		source_type = "unknown"
	return "%s|%s" % [
		source_id,
		source_type,
	]


func _get_counter_route_page_order(preferred_page: String) -> Array:
	var pages: Array = []
	var normalized_preferred := preferred_page.strip_edges().to_lower()
	if _is_codex_filter_page(normalized_preferred):
		pages.append(normalized_preferred)
	for page in COUNTER_ROUTE_PAGE_OPTIONS:
		if not pages.has(page):
			pages.append(page)
	return pages


func _get_counter_route_tag_order(tags: Array, preferred_tag: String) -> Array:
	var ordered_tags: Array = []
	var normalized_preferred := preferred_tag.strip_edges().to_lower()
	if not normalized_preferred.is_empty():
		ordered_tags.append(normalized_preferred)
	for tag in tags:
		var normalized_tag := str(tag).strip_edges().to_lower()
		if normalized_tag.is_empty() or ordered_tags.has(normalized_tag):
			continue
		ordered_tags.append(normalized_tag)
	return ordered_tags


func _get_codex_filter_index(page: String, tag: String) -> int:
	if not _is_codex_filter_page(page):
		return -1
	var wanted := tag.strip_edges().to_lower()
	if wanted.is_empty():
		return -1
	var options := _get_codex_filter_options(page)
	for index in range(options.size()):
		if str(options[index]).strip_edges().to_lower() == wanted:
			return index
	return -1


func _collect_counter_pick_entries_for_tag(entries: Array, tag_key: String, tag: String) -> Array:
	var matches: Array = []
	var normalized_tag := tag.strip_edges().to_lower()
	if normalized_tag.is_empty():
		return matches
	var normalized_tags := {normalized_tag: true}
	for value in entries:
		if not value is Dictionary:
			continue
		var entry := value as Dictionary
		if _entry_has_any_tag(entry, tag_key, normalized_tags):
			matches.append(entry)
	return matches


func _format_counter_route_target(target: Dictionary) -> String:
	if target.is_empty():
		return "None"
	return "%s -> %s" % [
		_format_label_token(str(target.get("page", COUNTER_ROUTE_DEFAULT_PAGE))),
		_format_label_token(str(target.get("tag", ""))),
	]


func _format_counter_pick_target(target: Dictionary, focus_index: int = -1, target_count: int = 0) -> String:
	if target.is_empty():
		return "None"
	var focus_prefix := ""
	if focus_index >= 0 and target_count > 1:
		focus_prefix = "%d/%d " % [focus_index + 1, target_count]
	return "%s%s -> %s (%s)" % [
		focus_prefix,
		_format_label_token(str(target.get("page", COUNTER_ROUTE_DEFAULT_PAGE))),
		str(target.get("display_name", "Pick")),
		_format_label_token(str(target.get("tag", ""))),
	]


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


func _format_defeat_source_review_tip(entry: Dictionary) -> String:
	var provided_tip := str(entry.get("source_review_tip", "")).strip_edges()
	if not provided_tip.is_empty():
		return provided_tip

	var source_type := str(entry.get("source_type", "unknown")).strip_edges().to_lower()
	var room_type := str(entry.get("source_room_type", "")).strip_edges().to_lower()
	match source_type:
		"hazard":
			match room_type:
				"trap":
					return "Treat warning zones as lanes, keep one escape route open, and cross after the pulse."
				"challenge":
					return "Clear the reward rule first, then avoid staying inside repeated warning zones."
				"boss":
					return "Respect arena tells before chasing damage and keep armor for overlapping hazards."
			return "Wait for readable hazard tells before committing to close-range damage."
		"boss":
			return "Save movement and armor recovery for boss tells instead of trading during burst windows."
		"enemy":
			return "Thin ranged pressure first, then isolate chargers before opening close-range trades."
	return "Check the last room context and rebuild around safer spacing before the next run."


func _format_defeat_source_type_context(entry: Dictionary) -> String:
	var source_type := str(entry.get("source_type", "unknown")).strip_edges()
	if source_type.is_empty():
		source_type = "unknown"
	var room_type := str(entry.get("source_room_type", "")).strip_edges()
	if not room_type.is_empty():
		return "%s/%s" % [source_type, room_type]
	return source_type


func _filter_defeat_source_records_by_type(records: Array, source_type_filter: String) -> Array:
	var normalized_filter := _normalize_records_source_type_filter(source_type_filter)
	if normalized_filter == "all":
		return records
	var filtered: Array = []
	for record_value in records:
		if not record_value is Dictionary:
			continue
		var record := record_value as Dictionary
		var source_type := str(record.get("source_type", "unknown")).strip_edges().to_lower()
		if source_type.is_empty() or not RECORD_SOURCE_TYPE_FILTER_OPTIONS.has(source_type):
			source_type = "unknown"
		if source_type == normalized_filter:
			filtered.append(record)
	return filtered


func _format_defeat_source_context_breakdown(records: Array) -> String:
	var room_counts := {}
	var biome_counts := {}
	var layout_counts := {}
	for record_value in records:
		if not record_value is Dictionary:
			continue
		var record := record_value as Dictionary
		var source_count := maxi(int(record.get("count", 0)), 0)
		if source_count <= 0:
			continue
		var room_type := str(record.get("source_room_type", "")).strip_edges()
		if not room_type.is_empty():
			_increment_context_count(room_counts, _format_record_context_token(room_type), source_count)
		var biome_name := str(record.get("source_biome_name", "")).strip_edges()
		var biome_id := str(record.get("source_biome_id", "")).strip_edges()
		if not biome_name.is_empty():
			_increment_context_count(biome_counts, biome_name, source_count)
		elif not biome_id.is_empty():
			_increment_context_count(biome_counts, _format_record_context_token(biome_id), source_count)
		var layout_profile := str(record.get("source_layout_profile", "")).strip_edges()
		if not layout_profile.is_empty():
			_increment_context_count(layout_counts, _format_record_context_token(layout_profile), source_count)

	var sections := PackedStringArray()
	if not room_counts.is_empty():
		sections.append("Rooms %s" % _format_context_count_entries(room_counts))
	if not biome_counts.is_empty():
		sections.append("Biomes %s" % _format_context_count_entries(biome_counts))
	if not layout_counts.is_empty():
		sections.append("Layouts %s" % _format_context_count_entries(layout_counts))
	if sections.is_empty():
		return ""
	return "Death Context: %s" % " | ".join(sections)


func _format_defeat_source_context_suffix(entry: Dictionary) -> String:
	var parts := PackedStringArray()
	var room_type := str(entry.get("source_room_type", "")).strip_edges()
	if not room_type.is_empty():
		parts.append("Room %s" % _format_record_context_token(room_type))
	var biome_name := str(entry.get("source_biome_name", "")).strip_edges()
	var biome_id := str(entry.get("source_biome_id", "")).strip_edges()
	if not biome_name.is_empty():
		parts.append("Biome %s" % biome_name)
	elif not biome_id.is_empty():
		parts.append("Biome %s" % _format_record_context_token(biome_id))
	var layout_profile := str(entry.get("source_layout_profile", "")).strip_edges()
	if not layout_profile.is_empty():
		parts.append("Layout %s" % _format_record_context_token(layout_profile))
	if parts.is_empty():
		return ""
	return " | Context %s" % " / ".join(parts)


func _increment_context_count(counts: Dictionary, label: String, amount: int) -> void:
	var normalized := label.strip_edges()
	if normalized.is_empty():
		return
	counts[normalized] = int(counts.get(normalized, 0)) + maxi(amount, 0)


func _format_context_count_entries(counts: Dictionary, max_entries: int = 3) -> String:
	if counts.is_empty():
		return "None"
	var entries: Array[Dictionary] = []
	for label_value in counts.keys():
		var label := str(label_value)
		entries.append({
			"label": label,
			"count": int(counts.get(label, 0)),
		})
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_count := int(a.get("count", 0))
		var b_count := int(b.get("count", 0))
		if a_count != b_count:
			return a_count > b_count
		return str(a.get("label", "")) < str(b.get("label", ""))
	)
	var parts := PackedStringArray()
	for index in range(mini(entries.size(), max_entries)):
		var entry := entries[index]
		parts.append("%s x%d" % [
			str(entry.get("label", "Unknown")),
			int(entry.get("count", 0)),
		])
	return ", ".join(parts)


func _format_record_context_token(value: String) -> String:
	var normalized := value.strip_edges().replace("_", " ")
	if normalized.is_empty():
		return ""
	return normalized.capitalize()


func _format_training_badges_page(summary: Dictionary) -> String:
	var meta: Dictionary = summary.get("meta_progression", {})
	var training_drills: Array = summary.get("training_drills", [])
	var lines: PackedStringArray = []
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
	return "\n".join(lines)


func _format_characters_page(summary: Dictionary) -> String:
	var characters: Array = summary.get("characters", [])
	var counts: Dictionary = summary.get("counts", {})
	var current_character_id := str(summary.get("current_character_id", ""))
	var lines: PackedStringArray = []
	lines.append("Characters (%d)" % int(counts.get("characters", characters.size())))
	for entry in characters:
		if entry is Dictionary:
			var unlock_text := "Unlocked" if bool(entry.get("unlocked", false)) else "Locked %d Data Shards" % int(entry.get("unlock_cost", 0))
			var selected_text := " | Selected" if str(entry.get("id", "")) == current_character_id else ""
			lines.append("- %s | %s | Mastery L%d (%d XP) | Bonus: %s | HP %d Armor %d Energy %d | Skill: %s | Tags: %s%s" % [
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
				selected_text,
			])
			lines.append("  Role: %s" % _first_non_empty([
				str(entry.get("hall_summary", "")),
				str(entry.get("description", "")),
			]))
			lines.append("  Starting Weapons: %s" % _join_display_values(entry.get("starting_weapon_names", [])))
			lines.append("  Passive: %s - %s" % [
				_format_label_token(entry.get("passive_id", "none")),
				_first_non_empty([str(entry.get("passive_description", "")), "None"]),
			])
			lines.append("  Skill Detail: Energy %d | Cooldown %.1fs | Duration %.1fs | %s" % [
				int(entry.get("skill_energy_cost", 0)),
				float(entry.get("skill_cooldown", 0.0)),
				float(entry.get("skill_duration", 0.0)),
				str(entry.get("skill_description", "")),
			])
			lines.append("  Mastery Progress: %s" % _format_mastery_progress(entry))
			lines.append("  Mastery Rewards: Current %s | Next %s" % [
				str(entry.get("mastery_bonus_text", "None")),
				str(entry.get("next_mastery_bonus_text", "Maxed")),
			])
			lines.append("  Next Mastery: %s" % _format_next_mastery(entry))
			lines.append("  Upgrade Slots: %d" % int(entry.get("upgrade_slots", 0)))
	return "\n".join(lines)


func _format_weapons_page(summary: Dictionary, filter_tag: String = "", search_query: String = "", rarity_filter: String = "", sort_key: String = "name", show_featured_card: bool = true) -> String:
	var all_weapons: Array = summary.get("weapons", [])
	var weapons: Array = _refine_codex_entries(all_weapons, "weapons", filter_tag, search_query, rarity_filter, sort_key)
	var counts: Dictionary = summary.get("counts", {})
	var lines: PackedStringArray = []
	var total_count := int(counts.get("weapons", all_weapons.size()))
	lines.append("Weapons (%s)" % _format_filtered_count(weapons.size(), total_count, filter_tag))
	lines.append("Build Routes: %s" % _format_tag_counts(_collect_tag_counts(all_weapons, "tags")))
	lines.append("Filter: %s" % _format_filter_summary(filter_tag, weapons.size(), total_count))
	lines.append("Refine: %s" % _format_refinement_summary(search_query, rarity_filter, sort_key))
	if show_featured_card:
		for line in _format_codex_featured_card("weapons", weapons):
			lines.append(line)
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
			lines.append("  Stats: Damage %d x%d | Fire %.1f/s | Mag %d | Reload %.1fs | Crit %d%% x%.1f" % [
				int(entry.get("damage", 0)),
				maxi(int(entry.get("projectile_count", 1)), 1),
				float(entry.get("fire_rate", 0.0)),
				int(entry.get("magazine_size", 0)),
				float(entry.get("reload_duration", 0.0)),
				roundi(float(entry.get("crit_chance", 0.0)) * 100.0),
				float(entry.get("crit_multiplier", 0.0)),
			])
			lines.append("  Traits: Mode %s | Pierce %d | Bounce %d | Homing %s | Chain %s | Explosion %.0f | Status %s | Guard %s | Charge %s | Deploy %s | Drop %.2f | Tags: %s" % [
				_format_label_token(entry.get("fire_mode", "")),
				int(entry.get("pierce_count", 0)),
				int(entry.get("bounce_count", 0)),
				_format_weapon_homing(entry),
				_format_weapon_chain(entry),
				float(entry.get("explosion_radius", 0.0)),
				_format_weapon_status(entry),
				_format_weapon_guard(entry),
				_format_weapon_charge(entry),
				_format_weapon_deployable(entry),
				float(entry.get("drop_weight", 0.0)),
				_join_display_values(entry.get("tags", [])),
			])
	return "\n".join(lines)


func _format_weapon_status(entry: Dictionary) -> String:
	var effect := str(entry.get("status_effect", "none"))
	if effect.is_empty() or effect == "none":
		return "None"

	var chance := roundi(float(entry.get("status_chance", 0.0)) * 100.0)
	var duration := float(entry.get("status_duration", 0.0))
	match effect:
		"burn":
			return "Burn %d%% %.1fs %d/tick" % [
				chance,
				duration,
				int(entry.get("status_damage_per_tick", 0)),
			]
		"slow":
			return "Slow %d%% %.1fs x%.2f" % [
				chance,
				duration,
				float(entry.get("status_slow_multiplier", 1.0)),
			]
	return "%s %d%% %.1fs" % [_format_label_token(effect), chance, duration]


func _format_weapon_homing(entry: Dictionary) -> String:
	var turn_rate := float(entry.get("homing_turn_rate", 0.0))
	var radius := float(entry.get("homing_radius", 0.0))
	if turn_rate <= 0.0 or radius <= 0.0:
		return "None"
	return "%.0fdeg/s %.0fr" % [turn_rate, radius]


func _format_weapon_chain(entry: Dictionary) -> String:
	var count := int(entry.get("chain_count", 0))
	var radius := float(entry.get("chain_radius", 0.0))
	if count <= 0 or radius <= 0.0:
		return "None"
	return "%dx %.0fr %d%%" % [
		count,
		radius,
		roundi(float(entry.get("chain_damage_multiplier", 0.65)) * 100.0),
	]


func _format_weapon_guard(entry: Dictionary) -> String:
	if not bool(entry.get("blocks_projectiles", false)):
		return "None"
	return "%.0fr %.0fdeg %d counter" % [
		float(entry.get("projectile_block_radius", 0.0)),
		float(entry.get("projectile_block_arc_degrees", 0.0)),
		int(entry.get("projectile_block_damage", 0)),
	]


func _format_weapon_charge(entry: Dictionary) -> String:
	if str(entry.get("fire_mode", "")) != "charge":
		return "None"
	return "%.1fs x%.1f dmg x%.1f spd +%d shots" % [
		float(entry.get("charge_duration", 0.0)),
		float(entry.get("charge_damage_multiplier", 1.0)),
		float(entry.get("charge_projectile_speed_multiplier", 1.0)),
		int(entry.get("charge_projectile_count_bonus", 0)),
	]


func _format_weapon_deployable(entry: Dictionary) -> String:
	if str(entry.get("fire_mode", "")) != "deployable":
		return "None"
	return "%s %.1fs %.0fr %.2fs tick x%.1f" % [
		_format_label_token(entry.get("deployable_behavior", "field")),
		float(entry.get("deployable_duration", 0.0)),
		float(entry.get("deployable_radius", 0.0)),
		float(entry.get("deployable_tick_interval", 0.0)),
		float(entry.get("deployable_damage_multiplier", 1.0)),
	]


func _format_relics_page(summary: Dictionary, filter_tag: String = "", search_query: String = "", rarity_filter: String = "", sort_key: String = "name", show_featured_card: bool = true) -> String:
	var all_relics: Array = summary.get("relics", [])
	var relics: Array = _refine_codex_entries(all_relics, "relics", filter_tag, search_query, rarity_filter, sort_key)
	var counts: Dictionary = summary.get("counts", {})
	var lines: PackedStringArray = []
	var total_count := int(counts.get("relics", all_relics.size()))
	lines.append("Relics (%s)" % _format_filtered_count(relics.size(), total_count, filter_tag))
	lines.append("Build Routes: %s" % _format_tag_counts(_collect_tag_counts(all_relics, "build_tags")))
	lines.append("Filter: %s" % _format_filter_summary(filter_tag, relics.size(), total_count))
	lines.append("Refine: %s" % _format_refinement_summary(search_query, rarity_filter, sort_key))
	if show_featured_card:
		for line in _format_codex_featured_card("relics", relics):
			lines.append(line)
	for entry in relics:
		if entry is Dictionary:
			lines.append("- %s [%s] | %s | Tags: %s" % [
				str(entry.get("display_name", "Relic")),
				_format_label_token(entry.get("rarity", "")),
				str(entry.get("description", "")),
				_join_display_values(entry.get("build_tags", [])),
			])
			lines.append("  Effect: %s on %s | Value %.2f | Duration %.1fs | Drop %.2f" % [
				_format_label_token(entry.get("effect_type", "")),
				_format_label_token(entry.get("trigger_event", "")),
				float(entry.get("effect_value", 0.0)),
				float(entry.get("effect_duration", 0.0)),
				float(entry.get("drop_weight", 0.0)),
			])
			lines.append("  Stacking: %s | Max %d | Conflicts: %s" % [
				"Stackable" if bool(entry.get("stackable", false)) else "Unique",
				int(entry.get("max_stacks", 1)),
				_join_display_values(entry.get("conflict_tags", [])),
			])
	return "\n".join(lines)


func _format_talents_page(summary: Dictionary, filter_tag: String = "", search_query: String = "", rarity_filter: String = "", sort_key: String = "name", show_featured_card: bool = true) -> String:
	var all_talents: Array = summary.get("talents", [])
	var talents: Array = _refine_codex_entries(all_talents, "talents", filter_tag, search_query, rarity_filter, sort_key)
	var counts: Dictionary = summary.get("counts", {})
	var lines: PackedStringArray = []
	var total_count := int(counts.get("talents", all_talents.size()))
	lines.append("Talents (%s)" % _format_filtered_count(talents.size(), total_count, filter_tag))
	lines.append("Build Routes: %s" % _format_tag_counts(_collect_tag_counts(all_talents, "build_tags")))
	lines.append("Filter: %s" % _format_filter_summary(filter_tag, talents.size(), total_count))
	lines.append("Refine: %s" % _format_refinement_summary(search_query, rarity_filter, sort_key))
	if show_featured_card:
		for line in _format_codex_featured_card("talents", talents):
			lines.append(line)
	for entry in talents:
		if entry is Dictionary:
			lines.append("- %s [%s] | %s | Tags: %s" % [
				str(entry.get("display_name", "Talent")),
				_format_label_token(entry.get("rarity", "")),
				str(entry.get("description", "")),
				_join_display_values(entry.get("build_tags", [])),
			])
			lines.append("  Effect: %s on %s | Scope %s | Value %.2f | Duration %.1fs | Drop %.2f" % [
				_format_label_token(entry.get("effect_type", "")),
				_format_label_token(entry.get("trigger_event", "")),
				_format_label_token(entry.get("duration_scope", "")),
				float(entry.get("effect_value", 0.0)),
				float(entry.get("effect_duration", 0.0)),
				float(entry.get("drop_weight", 0.0)),
			])
			lines.append("  Conflicts: %s" % _join_display_values(entry.get("conflict_tags", [])))
	return "\n".join(lines)


func _format_blessings_page(summary: Dictionary, filter_tag: String = "", search_query: String = "", rarity_filter: String = "", sort_key: String = "name", show_featured_card: bool = true) -> String:
	var all_blessings: Array = summary.get("blessings", [])
	var blessings: Array = _refine_codex_entries(all_blessings, "blessings", filter_tag, search_query, rarity_filter, sort_key)
	var counts: Dictionary = summary.get("counts", {})
	var lines: PackedStringArray = []
	var total_count := int(counts.get("blessings", all_blessings.size()))
	lines.append("Blessings (%s)" % _format_filtered_count(blessings.size(), total_count, filter_tag))
	lines.append("Build Routes: %s" % _format_tag_counts(_collect_tag_counts(all_blessings, "build_tags")))
	lines.append("Filter: %s" % _format_filter_summary(filter_tag, blessings.size(), total_count))
	lines.append("Refine: %s" % _format_refinement_summary(search_query, rarity_filter, sort_key))
	if show_featured_card:
		for line in _format_codex_featured_card("blessings", blessings):
			lines.append(line)
	for entry in blessings:
		if entry is Dictionary:
			lines.append("- %s [%s] | %s | Tags: %s" % [
				str(entry.get("display_name", "Blessing")),
				_format_label_token(entry.get("rarity", "")),
				str(entry.get("description", "")),
				_join_display_values(entry.get("build_tags", [])),
			])
			lines.append("  Effect: %s on %s | Scope %s | Value %.2f | Duration %.1fs | Drop %.2f" % [
				_format_label_token(entry.get("effect_type", "")),
				_format_label_token(entry.get("trigger_event", "")),
				_format_label_token(entry.get("duration_scope", "")),
				float(entry.get("effect_value", 0.0)),
				float(entry.get("effect_duration", 0.0)),
				float(entry.get("drop_weight", 0.0)),
			])
			lines.append("  Rule: %s | Conflicts: %s" % [
				str(entry.get("rule_text", "")),
				_join_display_values(entry.get("conflict_tags", [])),
			])
	return "\n".join(lines)


func _format_statues_page(summary: Dictionary, filter_tag: String = "", search_query: String = "", rarity_filter: String = "", sort_key: String = "name", show_featured_card: bool = true) -> String:
	var all_statues: Array = summary.get("statues", [])
	var statues: Array = _refine_codex_entries(all_statues, "statues", filter_tag, search_query, rarity_filter, sort_key)
	var counts: Dictionary = summary.get("counts", {})
	var lines: PackedStringArray = []
	var total_count := int(counts.get("statues", all_statues.size()))
	lines.append("Statues (%s)" % _format_filtered_count(statues.size(), total_count, filter_tag))
	lines.append("Build Routes: %s" % _format_tag_counts(_collect_tag_counts(all_statues, "build_tags")))
	lines.append("Filter: %s" % _format_filter_summary(filter_tag, statues.size(), total_count))
	lines.append("Refine: %s" % _format_refinement_summary(search_query, rarity_filter, sort_key))
	if show_featured_card:
		for line in _format_codex_featured_card("statues", statues):
			lines.append(line)
	for entry in statues:
		if entry is Dictionary:
			lines.append("- %s [%s] | %s | Tags: %s" % [
				str(entry.get("display_name", "Statue")),
				_format_label_token(entry.get("rarity", "")),
				str(entry.get("description", "")),
				_join_display_values(entry.get("build_tags", [])),
			])
			lines.append("  Effect: %s on %s | Every %d skill | Value %.2f | Duration %.1fs | Drop %.2f" % [
				_format_label_token(entry.get("effect_type", "")),
				_format_label_token(entry.get("trigger_event", "")),
				maxi(int(entry.get("trigger_interval", 1)), 1),
				float(entry.get("effect_value", 0.0)),
				float(entry.get("effect_duration", 0.0)),
				float(entry.get("drop_weight", 0.0)),
			])
			lines.append("  Rule: %s | Conflicts: %s" % [
				str(entry.get("rule_text", "")),
				_join_display_values(entry.get("conflict_tags", [])),
			])
	return "\n".join(lines)


func _format_codex_featured_card(page: String, entries: Array) -> PackedStringArray:
	var lines := PackedStringArray()
	if entries.is_empty():
		lines.append("Featured Card: No matching entry")
		lines.append("  Adjust route, rarity, search, or sort to inspect content.")
		return lines

	if not entries[0] is Dictionary:
		lines.append("Featured Card: No matching entry")
		return lines

	var entry: Dictionary = entries[0]
	var display_name := str(entry.get("display_name", "Entry"))
	var rarity := _format_label_token(entry.get("rarity", ""))
	lines.append("")
	lines.append("Featured Card: %s [%s]" % [display_name, rarity])
	match page:
		"weapons":
			lines.append("  Role: %s / %s | Tags: %s" % [
				_format_label_token(entry.get("weapon_class", "")),
				_format_label_token(entry.get("recommended_range", "")),
				_join_display_values(entry.get("tags", [])),
			])
			lines.append("  Core: Damage %d x%d | Energy %d | Fire %.1f/s | Drop %.2f" % [
				int(entry.get("damage", 0)),
				maxi(int(entry.get("projectile_count", 1)), 1),
				int(entry.get("energy_cost", 0)),
				float(entry.get("fire_rate", 0.0)),
				float(entry.get("drop_weight", 0.0)),
			])
			lines.append("  Special: Status %s | Guard %s | Charge %s | Deploy %s" % [
				_format_weapon_status(entry),
				_format_weapon_guard(entry),
				_format_weapon_charge(entry),
				_format_weapon_deployable(entry),
			])
		"relics":
			lines.append("  Role: Tags %s | Trigger %s | Drop %.2f" % [
				_join_display_values(entry.get("build_tags", [])),
				_format_label_token(entry.get("trigger_event", "")),
				float(entry.get("drop_weight", 0.0)),
			])
			lines.append("  Effect: %s | Value %.2f | Duration %.1fs" % [
				_format_label_token(entry.get("effect_type", "")),
				float(entry.get("effect_value", 0.0)),
				float(entry.get("effect_duration", 0.0)),
			])
			lines.append("  Rules: %s | Max %d | Conflicts %s" % [
				"Stackable" if bool(entry.get("stackable", false)) else "Unique",
				int(entry.get("max_stacks", 1)),
				_join_display_values(entry.get("conflict_tags", [])),
			])
		"talents":
			lines.append("  Role: Tags %s | Scope %s | Drop %.2f" % [
				_join_display_values(entry.get("build_tags", [])),
				_format_label_token(entry.get("duration_scope", "")),
				float(entry.get("drop_weight", 0.0)),
			])
			lines.append("  Effect: %s on %s | Value %.2f | Duration %.1fs" % [
				_format_label_token(entry.get("effect_type", "")),
				_format_label_token(entry.get("trigger_event", "")),
				float(entry.get("effect_value", 0.0)),
				float(entry.get("effect_duration", 0.0)),
			])
			lines.append("  Conflicts: %s" % _join_display_values(entry.get("conflict_tags", [])))
		"blessings":
			lines.append("  Role: Tags %s | Scope %s | Drop %.2f" % [
				_join_display_values(entry.get("build_tags", [])),
				_format_label_token(entry.get("duration_scope", "")),
				float(entry.get("drop_weight", 0.0)),
			])
			lines.append("  Effect: %s on %s | Value %.2f | Duration %.1fs" % [
				_format_label_token(entry.get("effect_type", "")),
				_format_label_token(entry.get("trigger_event", "")),
				float(entry.get("effect_value", 0.0)),
				float(entry.get("effect_duration", 0.0)),
			])
			lines.append("  Rule: %s | Conflicts %s" % [
				str(entry.get("rule_text", "")),
				_join_display_values(entry.get("conflict_tags", [])),
			])
		"statues":
			lines.append("  Role: Tags %s | Trigger %s | Drop %.2f" % [
				_join_display_values(entry.get("build_tags", [])),
				_format_label_token(entry.get("trigger_event", "")),
				float(entry.get("drop_weight", 0.0)),
			])
			lines.append("  Effect: %s | Every %d skill | Value %.2f | Duration %.1fs" % [
				_format_label_token(entry.get("effect_type", "")),
				maxi(int(entry.get("trigger_interval", 1)), 1),
				float(entry.get("effect_value", 0.0)),
				float(entry.get("effect_duration", 0.0)),
			])
			lines.append("  Rule: %s | Conflicts %s" % [
				str(entry.get("rule_text", "")),
				_join_display_values(entry.get("conflict_tags", [])),
			])
		_:
			lines.append("  %s" % str(entry.get("description", "")))
	return lines


func _update_codex_detail_card() -> void:
	if codex_detail_card == null:
		return
	if codex_detail_title_label == null or codex_detail_meta_label == null or codex_detail_body_label == null:
		codex_detail_card.visible = false
		return
	if codex_detail_rarity_strip == null or codex_detail_icon_swatch == null or codex_detail_icon_texture == null or codex_detail_icon_label == null or codex_detail_rarity_label == null:
		codex_detail_card.visible = false
		return
	if _active_page == "records":
		_update_records_source_detail_card()
		return
	_set_counter_route_button_target({})
	_set_counter_pick_button_target({})
	_set_counter_pick_cycle_button_state({}, 0, 0)
	_set_counter_pick_page_button_state({}, "", 0, 0)
	_set_counter_pick_type_row_state({}, [], "")
	if not _is_codex_filter_page(_active_page):
		codex_detail_card.visible = false
		return

	var entries := _refine_codex_entries(
		_get_codex_entries_for_page(_active_page),
		_active_page,
		_get_active_codex_filter_tag(_active_page),
		_get_active_codex_search_query(_active_page),
		_get_active_codex_rarity_filter(_active_page),
		_get_active_codex_sort_key(_active_page)
	)
	codex_detail_card.visible = true
	if entries.is_empty() or not entries[0] is Dictionary:
		_set_codex_detail_visuals("", "", "", "")
		codex_detail_title_label.text = "No Matching Entry"
		codex_detail_meta_label.text = "Adjust filters"
		codex_detail_body_label.text = "No codex entry matches the current route, rarity, search, and sort."
		return

	var entry: Dictionary = entries[0]
	_set_codex_detail_visuals(_active_page, str(entry.get("rarity", "")), str(entry.get("icon_key", "")), str(entry.get("display_name", "")))
	codex_detail_title_label.text = str(entry.get("display_name", "Entry"))
	codex_detail_meta_label.text = _format_codex_detail_meta(_active_page, entry)
	codex_detail_body_label.text = _format_codex_detail_body(_active_page, entry)


func _update_records_source_detail_card() -> void:
	var entry := _get_active_records_detail_source()
	if entry.is_empty():
		codex_detail_card.visible = false
		_set_counter_route_button_target({})
		_set_counter_pick_button_target({})
		_set_counter_pick_cycle_button_state({}, 0, 0)
		_set_counter_pick_page_button_state({}, "", 0, 0)
		_set_counter_pick_type_row_state({}, [], "")
		return

	var counter_pick_pages := _get_counter_pick_pages(entry)
	var counter_pick_page_index := _get_counter_pick_page_focus_index(entry, counter_pick_pages.size())
	var focused_counter_pick_page := COUNTER_ROUTE_DEFAULT_PAGE
	if not counter_pick_pages.is_empty():
		focused_counter_pick_page = str(counter_pick_pages[counter_pick_page_index])
	var counter_pick_targets := _collect_counter_pick_targets_for_page(entry, focused_counter_pick_page, "")
	var counter_pick_focus_index := _get_counter_pick_focus_index(entry, counter_pick_targets.size())
	codex_detail_card.visible = true
	_set_records_source_detail_visuals(entry)
	codex_detail_title_label.text = str(entry.get("source_name", "Unknown"))
	codex_detail_meta_label.text = _format_defeat_source_detail_meta(entry)
	codex_detail_body_label.text = _format_defeat_source_detail_body(entry)
	_set_counter_route_button_target(_resolve_counter_route_target(entry, COUNTER_ROUTE_DEFAULT_PAGE, ""))
	_set_counter_pick_button_target(_get_counter_pick_target_at(counter_pick_targets, counter_pick_focus_index))
	_set_counter_pick_cycle_button_state(entry, counter_pick_focus_index, counter_pick_targets.size())
	_set_counter_pick_page_button_state(entry, focused_counter_pick_page, counter_pick_page_index, counter_pick_pages.size())
	_set_counter_pick_type_row_state(entry, counter_pick_pages, focused_counter_pick_page)


func _set_counter_route_button_target(target: Dictionary) -> void:
	if counter_route_button == null:
		return
	if target.is_empty():
		counter_route_button.visible = false
		counter_route_button.disabled = true
		counter_route_button.text = "Route"
		counter_route_button.tooltip_text = ""
		return

	var route_label := _format_counter_route_target(target)
	counter_route_button.visible = true
	counter_route_button.disabled = false
	counter_route_button.text = "Route %s" % route_label
	counter_route_button.tooltip_text = "Open counter codex route: %s" % route_label


func _set_counter_pick_button_target(target: Dictionary) -> void:
	if counter_pick_button == null:
		return
	if target.is_empty():
		counter_pick_button.visible = false
		counter_pick_button.disabled = true
		counter_pick_button.text = "Pick"
		counter_pick_button.tooltip_text = ""
		return

	var pick_name := str(target.get("display_name", "Pick")).strip_edges()
	var route_label := _format_counter_route_target(target)
	counter_pick_button.visible = true
	counter_pick_button.disabled = false
	counter_pick_button.text = "Pick %s" % pick_name
	counter_pick_button.tooltip_text = "Open counter pick: %s in %s" % [pick_name, route_label]


func _set_counter_pick_cycle_button_state(entry: Dictionary, focus_index: int, target_count: int) -> void:
	if counter_pick_cycle_button == null:
		return
	if entry.is_empty() or target_count <= 1:
		counter_pick_cycle_button.visible = false
		counter_pick_cycle_button.disabled = true
		counter_pick_cycle_button.text = "Next Pick"
		counter_pick_cycle_button.tooltip_text = ""
		return

	counter_pick_cycle_button.visible = true
	counter_pick_cycle_button.disabled = false
	counter_pick_cycle_button.text = "Next Pick %d/%d" % [focus_index + 1, target_count]
	counter_pick_cycle_button.tooltip_text = "Cycle recommended counter picks for this death source."


func _set_counter_pick_page_button_state(entry: Dictionary, focused_page: String, page_index: int, page_count: int) -> void:
	if counter_pick_page_button == null:
		return
	if entry.is_empty() or page_count <= 1:
		counter_pick_page_button.visible = false
		counter_pick_page_button.disabled = true
		counter_pick_page_button.text = "Type"
		counter_pick_page_button.tooltip_text = ""
		return

	var page_label := _format_label_token(focused_page)
	counter_pick_page_button.visible = true
	counter_pick_page_button.disabled = false
	counter_pick_page_button.text = "Type %s %d/%d" % [page_label, page_index + 1, page_count]
	counter_pick_page_button.tooltip_text = "Cycle counter recommendation types for this death source."


func _set_counter_pick_type_row_state(entry: Dictionary, pages: Array, focused_page: String) -> void:
	if counter_pick_type_row == null:
		return
	var show_row := not entry.is_empty() and pages.size() > 1
	counter_pick_type_row.visible = show_row
	for page in COUNTER_ROUTE_PAGE_OPTIONS:
		var page_key := str(page)
		var button := _get_counter_pick_type_button(page_key)
		if button == null:
			continue
		var is_available := show_row and pages.has(page_key)
		var is_active := page_key == focused_page
		var label := _format_counter_pick_type_label(page_key)
		var token := _format_counter_pick_type_token(page_key)
		var font_color := COUNTER_PICK_TYPE_ACTIVE_COLOR if is_active else COUNTER_PICK_TYPE_INACTIVE_COLOR
		button.visible = is_available
		button.toggle_mode = true
		button.button_pressed = is_active
		button.disabled = is_active
		button.text = "[%s]" % token if is_active else token
		button.tooltip_text = "Current counter type: %s" % label if is_active else "Show counter picks for %s" % label
		button.add_theme_color_override("font_color", font_color)
		button.add_theme_color_override("font_hover_color", font_color)
		button.add_theme_color_override("font_pressed_color", font_color)
		button.add_theme_color_override("font_disabled_color", font_color)


func _set_records_source_detail_visuals(entry: Dictionary) -> void:
	var source_id := str(entry.get("source_id", "unknown")).strip_edges()
	if source_id.is_empty():
		source_id = "unknown"
	var source_name := str(entry.get("source_name", source_id.capitalize()))
	var source_type := _normalize_records_source_type_filter(str(entry.get("source_type", "unknown")))
	var source_color := _get_records_source_type_color(source_type)
	_codex_detail_icon_key = "death_source_%s" % source_id
	_codex_detail_icon_texture_path = ""
	var tooltip_text := "%s death source icon key: %s" % [source_name, _codex_detail_icon_key]
	codex_detail_icon_swatch.color = source_color
	codex_detail_icon_swatch.visible = true
	codex_detail_icon_swatch.tooltip_text = tooltip_text
	_update_codex_detail_icon_texture("", tooltip_text)
	codex_detail_icon_label.text = "SRC"
	codex_detail_icon_label.tooltip_text = tooltip_text
	codex_detail_rarity_label.text = _format_records_source_type_filter_label(source_type).to_upper()
	codex_detail_rarity_strip.color = source_color
	codex_detail_rarity_label.add_theme_color_override("font_color", source_color)
	codex_detail_title_label.add_theme_color_override("font_color", source_color)


func _set_codex_detail_visuals(page: String, rarity: String, icon_key: String, display_name: String) -> void:
	var rarity_color := _get_codex_rarity_color(rarity)
	_codex_detail_icon_key = icon_key.strip_edges()
	_codex_detail_icon_texture_path = CONTENT_ICON_REGISTRY.get_texture_path(_codex_detail_icon_key, page)
	var tooltip_text := CONTENT_ICON_REGISTRY.get_placeholder_tooltip(_codex_detail_icon_key, display_name, page)
	codex_detail_icon_swatch.color = CONTENT_ICON_REGISTRY.get_placeholder_color(_codex_detail_icon_key, page)
	codex_detail_icon_swatch.tooltip_text = tooltip_text
	_update_codex_detail_icon_texture(_codex_detail_icon_texture_path, tooltip_text)
	codex_detail_icon_label.text = CONTENT_ICON_REGISTRY.get_type_token(_codex_detail_icon_key, page)
	codex_detail_icon_label.tooltip_text = tooltip_text
	codex_detail_rarity_label.text = _format_label_token(rarity).to_upper()
	codex_detail_rarity_strip.color = rarity_color
	codex_detail_rarity_label.add_theme_color_override("font_color", rarity_color)
	codex_detail_title_label.add_theme_color_override("font_color", rarity_color)


func _update_codex_detail_icon_texture(texture_path: String, tooltip_text: String) -> void:
	var loaded_texture: Texture2D = null
	var normalized_path := texture_path.strip_edges()
	if not normalized_path.is_empty():
		var loaded_resource := load(normalized_path)
		if loaded_resource is Texture2D:
			loaded_texture = loaded_resource

	codex_detail_icon_texture.texture = loaded_texture
	codex_detail_icon_texture.visible = loaded_texture != null
	codex_detail_icon_texture.tooltip_text = tooltip_text
	codex_detail_icon_swatch.visible = loaded_texture == null


func _get_codex_rarity_color(rarity: String) -> Color:
	match rarity.strip_edges().to_lower():
		"common":
			return Color(0.62, 0.92, 0.72, 1.0)
		"rare":
			return Color(0.48, 0.78, 1.0, 1.0)
		"epic":
			return Color(0.78, 0.56, 1.0, 1.0)
		"legendary":
			return Color(1.0, 0.64, 0.22, 1.0)
	return Color(0.62, 0.68, 0.74, 1.0)


func _get_records_source_type_color(source_type: String) -> Color:
	match _normalize_records_source_type_filter(source_type):
		"enemy":
			return Color(0.95, 0.46, 0.36, 1.0)
		"boss":
			return Color(1.0, 0.32, 0.52, 1.0)
		"hazard":
			return Color(1.0, 0.74, 0.28, 1.0)
		"unknown":
			return Color(0.68, 0.72, 0.78, 1.0)
	return Color(0.74, 0.82, 0.94, 1.0)


func _format_codex_detail_meta(page: String, entry: Dictionary) -> String:
	var rarity := _format_label_token(entry.get("rarity", ""))
	match page:
		"weapons":
			return "%s | %s / %s | Tags %s" % [
				rarity,
				_format_label_token(entry.get("weapon_class", "")),
				_format_label_token(entry.get("recommended_range", "")),
				_join_display_values(entry.get("tags", [])),
			]
		"relics":
			return "%s | Trigger %s | Drop %.2f" % [
				rarity,
				_format_label_token(entry.get("trigger_event", "")),
				float(entry.get("drop_weight", 0.0)),
			]
		"talents", "blessings":
			return "%s | Scope %s | Drop %.2f" % [
				rarity,
				_format_label_token(entry.get("duration_scope", "")),
				float(entry.get("drop_weight", 0.0)),
			]
		"statues":
			return "%s | Trigger %s | Every %d skill | Drop %.2f" % [
				rarity,
				_format_label_token(entry.get("trigger_event", "")),
				maxi(int(entry.get("trigger_interval", 1)), 1),
				float(entry.get("drop_weight", 0.0)),
			]
	return "%s | Drop %.2f" % [rarity, float(entry.get("drop_weight", 0.0))]


func _format_codex_detail_body(page: String, entry: Dictionary) -> String:
	match page:
		"weapons":
			return "Damage %d x%d | Energy %d | Fire %.1f/s | Drop %.2f\nStatus %s | Guard %s | Charge %s | Deploy %s" % [
				int(entry.get("damage", 0)),
				maxi(int(entry.get("projectile_count", 1)), 1),
				int(entry.get("energy_cost", 0)),
				float(entry.get("fire_rate", 0.0)),
				float(entry.get("drop_weight", 0.0)),
				_format_weapon_status(entry),
				_format_weapon_guard(entry),
				_format_weapon_charge(entry),
				_format_weapon_deployable(entry),
			]
		"relics":
			return "Effect %s on %s | Value %.2f | Duration %.1fs\nRules %s | Max %d | Conflicts %s" % [
				_format_label_token(entry.get("effect_type", "")),
				_format_label_token(entry.get("trigger_event", "")),
				float(entry.get("effect_value", 0.0)),
				float(entry.get("effect_duration", 0.0)),
				"Stackable" if bool(entry.get("stackable", false)) else "Unique",
				int(entry.get("max_stacks", 1)),
				_join_display_values(entry.get("conflict_tags", [])),
			]
		"talents":
			return "Effect %s on %s | Value %.2f | Duration %.1fs\nConflicts %s" % [
				_format_label_token(entry.get("effect_type", "")),
				_format_label_token(entry.get("trigger_event", "")),
				float(entry.get("effect_value", 0.0)),
				float(entry.get("effect_duration", 0.0)),
				_join_display_values(entry.get("conflict_tags", [])),
			]
		"blessings":
			return "Effect %s on %s | Value %.2f | Duration %.1fs\nRule %s | Conflicts %s" % [
				_format_label_token(entry.get("effect_type", "")),
				_format_label_token(entry.get("trigger_event", "")),
				float(entry.get("effect_value", 0.0)),
				float(entry.get("effect_duration", 0.0)),
				str(entry.get("rule_text", "")),
				_join_display_values(entry.get("conflict_tags", [])),
			]
		"statues":
			return "Effect %s on %s | Every %d skill | Value %.2f | Duration %.1fs\nRule %s | Conflicts %s" % [
				_format_label_token(entry.get("effect_type", "")),
				_format_label_token(entry.get("trigger_event", "")),
				maxi(int(entry.get("trigger_interval", 1)), 1),
				float(entry.get("effect_value", 0.0)),
				float(entry.get("effect_duration", 0.0)),
				str(entry.get("rule_text", "")),
				_join_display_values(entry.get("conflict_tags", [])),
			]
	return str(entry.get("description", ""))


func _is_codex_filter_page(page: String) -> bool:
	return page == "weapons" or page == "relics" or page == "talents" or page == "blessings" or page == "statues"


func _get_codex_entries_for_page(page: String) -> Array:
	match page:
		"weapons":
			return _current_summary.get("weapons", [])
		"relics":
			return _current_summary.get("relics", [])
		"talents":
			return _current_summary.get("talents", [])
		"blessings":
			return _current_summary.get("blessings", [])
		"statues":
			return _current_summary.get("statues", [])
	return []


func _get_codex_tag_key(page: String) -> String:
	return "tags" if page == "weapons" else "build_tags"


func _get_codex_filter_options(page: String) -> Array:
	if not _is_codex_filter_page(page):
		return [""]

	var counts := _collect_tag_counts(_get_codex_entries_for_page(page), _get_codex_tag_key(page))
	var keys := counts.keys()
	keys.sort()
	var options: Array = [""]
	for key in keys:
		options.append(str(key))
	return options


func _get_codex_sort_options(page: String) -> Array:
	if not _is_codex_filter_page(page):
		return ["name"]
	return CODEX_SORT_OPTIONS.duplicate()


func _get_codex_rarity_options(page: String) -> Array:
	if not _is_codex_filter_page(page):
		return [""]

	var seen := {}
	for entry in _get_codex_entries_for_page(page):
		if not entry is Dictionary:
			continue
		var rarity := str((entry as Dictionary).get("rarity", "")).strip_edges().to_lower()
		if rarity.is_empty():
			continue
		seen[rarity] = true

	var keys := seen.keys()
	keys.sort_custom(func(a, b) -> bool:
		var a_rank := _rarity_option_rank(str(a))
		var b_rank := _rarity_option_rank(str(b))
		if a_rank == b_rank:
			return str(a) < str(b)
		return a_rank < b_rank
	)
	var options: Array = [""]
	for key in keys:
		options.append(str(key))
	return options


func _get_active_codex_filter_tag(page: String) -> String:
	var options := _get_codex_filter_options(page)
	var index := clampi(int(_codex_filter_indexes.get(page, 0)), 0, maxi(options.size() - 1, 0))
	_codex_filter_indexes[page] = index
	return str(options[index]) if not options.is_empty() else ""


func _get_active_codex_search_query(page: String) -> String:
	return str(_codex_search_queries.get(page, "")).strip_edges()


func _get_active_codex_sort_key(page: String) -> String:
	var options := _get_codex_sort_options(page)
	var index := clampi(int(_codex_sort_indexes.get(page, 0)), 0, maxi(options.size() - 1, 0))
	_codex_sort_indexes[page] = index
	return str(options[index]) if not options.is_empty() else "name"


func _get_active_codex_rarity_filter(page: String) -> String:
	var options := _get_codex_rarity_options(page)
	var index := clampi(int(_codex_rarity_indexes.get(page, 0)), 0, maxi(options.size() - 1, 0))
	_codex_rarity_indexes[page] = index
	return str(options[index]) if not options.is_empty() else ""


func _get_active_records_filter() -> String:
	_records_filter_index = clampi(_records_filter_index, 0, RECORD_FILTER_OPTIONS.size() - 1)
	return str(RECORD_FILTER_OPTIONS[_records_filter_index])


func _normalize_records_filter(filter_id: String) -> String:
	var wanted := filter_id.strip_edges().to_lower()
	if RECORD_FILTER_OPTIONS.has(wanted):
		return wanted
	return "all"


func _format_records_filter_label(filter_id: String) -> String:
	match _normalize_records_filter(filter_id):
		"types":
			return "Types"
		"context":
			return "Context"
		"sources":
			return "Sources"
	return "All"


func _get_active_records_source_type_filter() -> String:
	_records_source_type_filter_index = clampi(_records_source_type_filter_index, 0, RECORD_SOURCE_TYPE_FILTER_OPTIONS.size() - 1)
	return str(RECORD_SOURCE_TYPE_FILTER_OPTIONS[_records_source_type_filter_index])


func _normalize_records_source_type_filter(source_type: String) -> String:
	var wanted := source_type.strip_edges().to_lower()
	if RECORD_SOURCE_TYPE_FILTER_OPTIONS.has(wanted):
		return wanted
	return "all"


func _format_records_source_type_filter_label(source_type: String) -> String:
	match _normalize_records_source_type_filter(source_type):
		"enemy":
			return "Enemy"
		"boss":
			return "Boss"
		"hazard":
			return "Hazard"
		"unknown":
			return "Unknown"
	return "All"


func _records_view_uses_source_type_filter(death_view: String) -> bool:
	var normalized := _normalize_records_filter(death_view)
	return normalized == "context" or normalized == "sources"


func _set_records_filter(filter_id: String) -> void:
	if _active_page != "records":
		return

	var wanted := _normalize_records_filter(filter_id)
	for index in range(RECORD_FILTER_OPTIONS.size()):
		if str(RECORD_FILTER_OPTIONS[index]) == wanted:
			_records_filter_index = index
			_refresh_archive_page()
			return


func _set_records_source_type_filter(source_type: String) -> void:
	if _active_page != "records":
		return

	var wanted := _normalize_records_source_type_filter(source_type)
	for index in range(RECORD_SOURCE_TYPE_FILTER_OPTIONS.size()):
		if str(RECORD_SOURCE_TYPE_FILTER_OPTIONS[index]) == wanted:
			_records_source_type_filter_index = index
			_refresh_archive_page()
			return


func _set_codex_filter(tag: String) -> void:
	if not _is_codex_filter_page(_active_page):
		return

	var wanted := tag.strip_edges()
	var options := _get_codex_filter_options(_active_page)
	for index in range(options.size()):
		if str(options[index]) == wanted:
			_codex_filter_indexes[_active_page] = index
			_refresh_archive_page()
			return


func _set_codex_search_query(query: String) -> void:
	if not _is_codex_filter_page(_active_page):
		return
	_codex_search_queries[_active_page] = query.strip_edges()
	_refresh_archive_page()


func _set_codex_sort(sort_key: String) -> void:
	if not _is_codex_filter_page(_active_page):
		return

	var wanted := sort_key.strip_edges()
	var options := _get_codex_sort_options(_active_page)
	for index in range(options.size()):
		if str(options[index]) == wanted:
			_codex_sort_indexes[_active_page] = index
			_refresh_archive_page()
			return


func _set_codex_rarity_filter(rarity: String) -> void:
	if not _is_codex_filter_page(_active_page):
		return

	var wanted := rarity.strip_edges().to_lower()
	var options := _get_codex_rarity_options(_active_page)
	for index in range(options.size()):
		if str(options[index]) == wanted:
			_codex_rarity_indexes[_active_page] = index
			_refresh_archive_page()
			return


func _cycle_codex_filter(delta: int) -> void:
	if _active_page == "records":
		_cycle_records_filter(delta)
		return
	if not _is_codex_filter_page(_active_page):
		return

	var options := _get_codex_filter_options(_active_page)
	if options.size() <= 1:
		return
	var current := clampi(int(_codex_filter_indexes.get(_active_page, 0)), 0, options.size() - 1)
	var next_index := (current + delta) % options.size()
	if next_index < 0:
		next_index += options.size()
	_codex_filter_indexes[_active_page] = next_index
	_refresh_archive_page()


func _cycle_records_filter(delta: int) -> void:
	if _active_page != "records":
		return
	if RECORD_FILTER_OPTIONS.size() <= 1:
		return
	var next_index := (_records_filter_index + delta) % RECORD_FILTER_OPTIONS.size()
	if next_index < 0:
		next_index += RECORD_FILTER_OPTIONS.size()
	_records_filter_index = next_index
	_refresh_archive_page()


func _cycle_codex_sort(delta: int) -> void:
	if _active_page == "records":
		_cycle_records_source_type_filter(delta)
		return
	if not _is_codex_filter_page(_active_page):
		return

	var options := _get_codex_sort_options(_active_page)
	if options.size() <= 1:
		return
	var current := clampi(int(_codex_sort_indexes.get(_active_page, 0)), 0, options.size() - 1)
	var next_index := (current + delta) % options.size()
	if next_index < 0:
		next_index += options.size()
	_codex_sort_indexes[_active_page] = next_index
	_refresh_archive_page()


func _cycle_records_source_type_filter(delta: int) -> void:
	if _active_page != "records":
		return
	if RECORD_SOURCE_TYPE_FILTER_OPTIONS.size() <= 1:
		return
	var next_index := (_records_source_type_filter_index + delta) % RECORD_SOURCE_TYPE_FILTER_OPTIONS.size()
	if next_index < 0:
		next_index += RECORD_SOURCE_TYPE_FILTER_OPTIONS.size()
	_records_source_type_filter_index = next_index
	_refresh_archive_page()


func _cycle_counter_pick_focus(delta: int) -> void:
	var entry := _get_active_records_detail_source()
	if entry.is_empty():
		return
	var focused_page := _get_focused_counter_pick_page(entry)
	var targets := _collect_counter_pick_targets_for_page(entry, focused_page, "")
	if targets.size() <= 1:
		return
	var focus_key := _get_counter_pick_focus_key(entry)
	var current := clampi(int(_counter_pick_focus_indexes.get(focus_key, 0)), 0, targets.size() - 1)
	var next_index := (current + delta) % targets.size()
	if next_index < 0:
		next_index += targets.size()
	_counter_pick_focus_indexes[focus_key] = next_index
	_refresh_archive_page()


func _cycle_counter_pick_page_focus(delta: int) -> void:
	var entry := _get_active_records_detail_source()
	if entry.is_empty():
		return
	var pages := _get_counter_pick_pages(entry)
	if pages.size() <= 1:
		return
	var page_focus_key := _get_counter_pick_page_focus_key(entry)
	var current := clampi(int(_counter_pick_page_focus_indexes.get(page_focus_key, 0)), 0, pages.size() - 1)
	var next_index := (current + delta) % pages.size()
	if next_index < 0:
		next_index += pages.size()
	_set_counter_pick_page_focus(str(pages[next_index]))


func _set_counter_pick_page_focus(page: String) -> bool:
	var entry := _get_active_records_detail_source()
	if entry.is_empty():
		return false
	var normalized_page := page.strip_edges().to_lower()
	var pages := _get_counter_pick_pages(entry)
	var target_index := pages.find(normalized_page)
	if target_index < 0:
		return false
	_counter_pick_page_focus_indexes[_get_counter_pick_page_focus_key(entry)] = target_index
	_counter_pick_focus_indexes[_get_counter_pick_focus_key(entry)] = 0
	_refresh_archive_page()
	return true


func _cycle_codex_rarity(delta: int) -> void:
	if not _is_codex_filter_page(_active_page):
		return

	var options := _get_codex_rarity_options(_active_page)
	if options.size() <= 1:
		return
	var current := clampi(int(_codex_rarity_indexes.get(_active_page, 0)), 0, options.size() - 1)
	var next_index := (current + delta) % options.size()
	if next_index < 0:
		next_index += options.size()
	_codex_rarity_indexes[_active_page] = next_index
	_refresh_archive_page()


func _clear_codex_filter() -> void:
	if _active_page == "records":
		_clear_records_filter()
		return
	if not _is_codex_filter_page(_active_page):
		return
	_codex_filter_indexes[_active_page] = 0
	_refresh_archive_page()


func _clear_records_filter() -> void:
	if _active_page != "records":
		return
	_records_filter_index = 0
	_refresh_archive_page()


func _reset_codex_refinements() -> void:
	if _active_page == "records":
		_clear_records_source_type_filter()
		return
	if not _is_codex_filter_page(_active_page):
		return
	_codex_filter_indexes[_active_page] = 0
	_codex_search_queries[_active_page] = ""
	_codex_sort_indexes[_active_page] = 0
	_codex_rarity_indexes[_active_page] = 0
	_refresh_archive_page()


func _clear_records_source_type_filter() -> void:
	if _active_page != "records":
		return
	_records_source_type_filter_index = 0
	_refresh_archive_page()


func _on_codex_search_text_changed(new_text: String) -> void:
	if not _is_codex_filter_page(_active_page):
		return
	_codex_search_queries[_active_page] = new_text.strip_edges()
	_refresh_archive_page()


func _update_codex_filter_controls() -> void:
	if codex_filter_row == null:
		return

	var visible_filter := _active_page == "records" or _is_codex_filter_page(_active_page)
	codex_filter_row.visible = visible_filter
	if not visible_filter:
		return

	if _active_page == "records":
		var records_filter := _get_active_records_filter()
		codex_filter_label.text = "Death View: %s" % _format_records_filter_label(records_filter)
		previous_filter_button.disabled = RECORD_FILTER_OPTIONS.size() <= 1
		next_filter_button.disabled = RECORD_FILTER_OPTIONS.size() <= 1
		clear_filter_button.disabled = records_filter == "all"
		return

	var entries := _get_codex_entries_for_page(_active_page)
	var options := _get_codex_filter_options(_active_page)
	var index := clampi(int(_codex_filter_indexes.get(_active_page, 0)), 0, maxi(options.size() - 1, 0))
	_codex_filter_indexes[_active_page] = index
	var filter_tag := str(options[index]) if not options.is_empty() else ""
	var filtered_count := _refine_codex_entries(
		entries,
		_active_page,
		filter_tag,
		_get_active_codex_search_query(_active_page),
		_get_active_codex_rarity_filter(_active_page),
		_get_active_codex_sort_key(_active_page)
	).size()
	codex_filter_label.text = "Route: %s (%d/%d)" % [
		_format_label_token(filter_tag) if not filter_tag.is_empty() else "All",
		filtered_count,
		entries.size(),
	]
	previous_filter_button.disabled = options.size() <= 1
	next_filter_button.disabled = options.size() <= 1
	clear_filter_button.disabled = filter_tag.is_empty()


func _update_codex_refinement_controls() -> void:
	if codex_refinement_row == null:
		return

	var records_source_filter_visible := _active_page == "records" and _records_view_uses_source_type_filter(_get_active_records_filter())
	var visible_filter := records_source_filter_visible or _is_codex_filter_page(_active_page)
	codex_refinement_row.visible = visible_filter
	if not visible_filter:
		return

	if records_source_filter_visible:
		codex_search_edit.visible = false
		previous_sort_button.visible = true
		codex_sort_label.visible = true
		next_sort_button.visible = true
		previous_rarity_button.visible = false
		codex_rarity_label.visible = false
		next_rarity_button.visible = false
		reset_refinement_button.visible = true
		var source_type_filter := _get_active_records_source_type_filter()
		codex_sort_label.text = "Source Type: %s" % _format_records_source_type_filter_label(source_type_filter)
		previous_sort_button.disabled = RECORD_SOURCE_TYPE_FILTER_OPTIONS.size() <= 1
		next_sort_button.disabled = RECORD_SOURCE_TYPE_FILTER_OPTIONS.size() <= 1
		reset_refinement_button.disabled = source_type_filter == "all"
		return

	codex_search_edit.visible = true
	previous_sort_button.visible = true
	codex_sort_label.visible = true
	next_sort_button.visible = true
	previous_rarity_button.visible = true
	codex_rarity_label.visible = true
	next_rarity_button.visible = true
	reset_refinement_button.visible = true

	var search_query := _get_active_codex_search_query(_active_page)
	if codex_search_edit.text != search_query:
		codex_search_edit.text = search_query

	var sort_options := _get_codex_sort_options(_active_page)
	var sort_key := _get_active_codex_sort_key(_active_page)
	codex_sort_label.text = "Sort: %s" % _format_label_token(sort_key)
	previous_sort_button.disabled = sort_options.size() <= 1
	next_sort_button.disabled = sort_options.size() <= 1

	var rarity_options := _get_codex_rarity_options(_active_page)
	var rarity_filter := _get_active_codex_rarity_filter(_active_page)
	codex_rarity_label.text = "Rarity: %s" % (_format_label_token(rarity_filter) if not rarity_filter.is_empty() else "All")
	previous_rarity_button.disabled = rarity_options.size() <= 1
	next_rarity_button.disabled = rarity_options.size() <= 1
	reset_refinement_button.disabled = (
		_get_active_codex_filter_tag(_active_page).is_empty()
		and search_query.is_empty()
		and sort_key == "name"
		and rarity_filter.is_empty()
	)


func _refine_codex_entries(entries: Array, page: String, filter_tag: String, search_query: String, rarity_filter: String, sort_key: String) -> Array:
	var filtered := _filter_entries_by_tag(entries, _get_codex_tag_key(page), filter_tag)
	filtered = _filter_entries_by_rarity(filtered, rarity_filter)
	filtered = _filter_entries_by_search(filtered, search_query)
	return _sort_codex_entries(filtered, sort_key)


func _filter_entries_by_tag(entries: Array, key: String, tag: String) -> Array:
	var filtered: Array = []
	var wanted := tag.strip_edges()
	for entry in entries:
		if not entry is Dictionary:
			continue
		if wanted.is_empty() or _entry_has_tag(entry as Dictionary, key, wanted):
			filtered.append(entry)
	return filtered


func _filter_entries_by_rarity(entries: Array, rarity: String) -> Array:
	var wanted := rarity.strip_edges().to_lower()
	if wanted.is_empty():
		return entries

	var filtered: Array = []
	for entry in entries:
		if not entry is Dictionary:
			continue
		if str((entry as Dictionary).get("rarity", "")).strip_edges().to_lower() == wanted:
			filtered.append(entry)
	return filtered


func _filter_entries_by_search(entries: Array, query: String) -> Array:
	var wanted := query.strip_edges().to_lower()
	if wanted.is_empty():
		return entries

	var filtered: Array = []
	for entry in entries:
		if not entry is Dictionary:
			continue
		if _entry_matches_search(entry as Dictionary, wanted):
			filtered.append(entry)
	return filtered


func _sort_codex_entries(entries: Array, sort_key: String) -> Array:
	var sorted := entries.duplicate()
	match sort_key:
		"rarity":
			sorted.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
				var a_rank := _rarity_sort_rank(str(a.get("rarity", "")))
				var b_rank := _rarity_sort_rank(str(b.get("rarity", "")))
				if a_rank == b_rank:
					return _entry_sort_name(a) < _entry_sort_name(b)
				return a_rank > b_rank
			)
		"drop_weight":
			sorted.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
				var a_weight := float(a.get("drop_weight", 0.0))
				var b_weight := float(b.get("drop_weight", 0.0))
				if not is_equal_approx(a_weight, b_weight):
					return a_weight > b_weight
				return _entry_sort_name(a) < _entry_sort_name(b)
			)
		_:
			sorted.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
				return _entry_sort_name(a) < _entry_sort_name(b)
			)
	return sorted


func _entry_has_tag(entry: Dictionary, key: String, tag: String) -> bool:
	var values = entry.get(key, [])
	if not values is Array:
		return false
	for value in values:
		if str(value) == tag:
			return true
	return false


func _entry_matches_search(entry: Dictionary, query: String) -> bool:
	var fields := [
		"id",
		"display_name",
		"description",
		"rarity",
		"weapon_class",
		"recommended_range",
		"content_role",
		"fire_mode",
		"trigger_event",
		"effect_type",
		"duration_scope",
		"rule_text",
	]
	for field in fields:
		if str(entry.get(field, "")).to_lower().contains(query):
			return true

	for key in ["tags", "build_tags", "conflict_tags"]:
		var values = entry.get(key, [])
		if not values is Array:
			continue
		for value in values:
			if str(value).to_lower().contains(query):
				return true
	return false


func _entry_sort_name(entry: Dictionary) -> String:
	return str(entry.get("display_name", entry.get("id", ""))).to_lower()


func _rarity_option_rank(rarity: String) -> int:
	match rarity.strip_edges().to_lower():
		"starter":
			return 0
		"common":
			return 1
		"rare":
			return 2
		"epic":
			return 3
		"legendary":
			return 4
	return 100


func _rarity_sort_rank(rarity: String) -> int:
	match rarity.strip_edges().to_lower():
		"legendary":
			return 5
		"epic":
			return 4
		"rare":
			return 3
		"common":
			return 2
		"starter":
			return 1
	return 0


func _format_filtered_count(shown: int, total: int, filter_tag: String) -> String:
	if filter_tag.strip_edges().is_empty() and shown == total:
		return "%d" % total
	return "%d/%d" % [shown, total]


func _format_refinement_summary(search_query: String, rarity_filter: String, sort_key: String) -> String:
	return "Rarity %s | Search %s | Sort %s" % [
		_format_label_token(rarity_filter) if not rarity_filter.strip_edges().is_empty() else "All",
		("\"%s\"" % search_query) if not search_query.strip_edges().is_empty() else "None",
		_format_label_token(sort_key),
	]


func _format_filter_summary(filter_tag: String, shown: int, total: int) -> String:
	if filter_tag.strip_edges().is_empty():
		return "All (%d)" % total
	return "%s (%d/%d shown)" % [
		_format_label_token(filter_tag),
		shown,
		total,
	]


func _join_display_values(values) -> String:
	if not values is Array or values.is_empty():
		return "None"

	var strings: PackedStringArray = []
	for value in values:
		strings.append(_format_label_token(value))
	return ", ".join(strings)


func _collect_tag_counts(entries: Array, key: String) -> Dictionary:
	var counts := {}
	for entry in entries:
		if not entry is Dictionary:
			continue
		var values = (entry as Dictionary).get(key, [])
		if not values is Array:
			continue
		for value in values:
			var token := str(value).strip_edges()
			if token.is_empty():
				continue
			counts[token] = int(counts.get(token, 0)) + 1
	return counts


func _format_tag_counts(counts: Dictionary) -> String:
	if counts.is_empty():
		return "None"
	var keys := counts.keys()
	keys.sort()
	var parts: PackedStringArray = []
	for key in keys:
		parts.append("%s x%d" % [
			_format_label_token(key),
			int(counts.get(key, 0)),
		])
	return ", ".join(parts)


func _format_next_mastery(entry: Dictionary) -> String:
	var next_level := int(entry.get("next_mastery_level", 0))
	if next_level <= 0:
		return "Maxed"

	return "L%d at %d XP (%d remaining) | Reward: %s" % [
		next_level,
		int(entry.get("next_mastery_xp_required", 0)),
		int(entry.get("next_mastery_xp_remaining", 0)),
		str(entry.get("next_mastery_bonus_text", "None")),
	]


func _format_mastery_progress(entry: Dictionary) -> String:
	var next_level := int(entry.get("next_mastery_level", 0))
	if next_level <= 0:
		return "Maxed"

	var current := maxi(int(entry.get("next_mastery_progress_current_xp", 0)), 0)
	var required := maxi(int(entry.get("next_mastery_progress_required_xp", 1)), 1)
	var percent := clampi(int(entry.get("next_mastery_progress_percent", 0)), 0, 100)
	return "%s %d/%d XP to L%d (%d%%)" % [
		_build_progress_bar(current, required, 12),
		current,
		required,
		next_level,
		percent,
	]


func _build_progress_bar(current: int, required: int, width: int) -> String:
	var safe_width := maxi(width, 1)
	var safe_required := maxi(required, 1)
	var filled := clampi(roundi(float(clampi(current, 0, safe_required)) / float(safe_required) * float(safe_width)), 0, safe_width)
	var parts := "["
	for index in range(safe_width):
		parts += "#" if index < filled else "-"
	parts += "]"
	return parts


func _first_non_empty(values: Array) -> String:
	for value in values:
		var text := str(value).strip_edges()
		if not text.is_empty():
			return text
	return ""


func _format_label_token(value) -> String:
	var text := str(value).strip_edges()
	if text.is_empty():
		return "None"
	return text.replace("_", " ").capitalize()


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


func _on_start_button_pressed() -> void:
	start_requested.emit()


func _on_objective_start_run_button_pressed() -> void:
	if objective_start_run_button != null and objective_start_run_button.disabled:
		return
	start_requested.emit()


func _on_objective_counter_button_pressed() -> void:
	open_objective_counter()


func _on_objective_build_route_button_pressed() -> void:
	open_objective_build_route()


func _on_objective_counter_pick_button_pressed() -> void:
	open_objective_counter_pick()


func _on_objective_counter_pick_cycle_button_pressed() -> void:
	cycle_objective_counter_pick()


func _on_objective_progress_action_button_pressed() -> void:
	open_objective_progress_target()


func _on_training_button_pressed() -> void:
	training_requested.emit("")


func _on_settings_button_pressed() -> void:
	settings_requested.emit()


func _on_previous_character_button_pressed() -> void:
	previous_character_requested.emit()


func _on_next_character_button_pressed() -> void:
	next_character_requested.emit()


func _on_unlock_character_button_pressed() -> void:
	unlock_character_requested.emit()


func _on_counter_route_button_pressed() -> void:
	open_counter_route()


func _on_counter_pick_button_pressed() -> void:
	open_counter_pick()


func _on_counter_pick_cycle_button_pressed() -> void:
	_cycle_counter_pick_focus(1)


func _on_counter_pick_page_button_pressed() -> void:
	_cycle_counter_pick_page_focus(1)


func _on_counter_pick_type_button_pressed(page: String) -> void:
	_set_counter_pick_page_focus(page)


func _on_back_button_pressed() -> void:
	back_requested.emit()

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
	_expect(hud != null, "HUD should exist")
	_expect(hud != null and hud.has_method("get_lobby_quick_stats_text"), "HUD should expose lobby quick stats")
	_expect(hud != null and hud.has_method("get_lobby_objective_board_text"), "HUD should expose lobby objective board")
	_expect(hud != null and hud.has_method("get_lobby_objective_progress_text"), "HUD should expose lobby objective progress")
	_expect(hud != null and hud.has_method("get_lobby_objective_progress_value_text"), "HUD should expose lobby objective progress value text")
	_expect(hud != null and hud.has_method("get_lobby_selected_status_text"), "HUD should expose lobby selected status")
	var lobby = hud.get_node_or_null("LobbyScreen") if hud != null else null
	_expect(_is_lobby_screen(lobby), "HUD should instantiate the dedicated LobbyScreen scene")
	if hud == null or not _is_lobby_screen(lobby):
		_finish()
		return

	main.call("open_hall_menu")
	await get_tree().process_frame
	_expect(bool(hud.call("is_hall_visible")), "Opening hall should show LobbyScreen")
	_expect(not bool(hud.call("is_main_menu_visible")), "Opening hall should hide the old main menu panel")
	var archive_text := str(hud.call("get_hall_summary_text"))
	var quick_stats := str(hud.call("get_lobby_quick_stats_text"))
	var objective_board := str(hud.call("get_lobby_objective_board_text"))
	var objective_progress := str(hud.call("get_lobby_objective_progress_text"))
	_expect(str(hud.call("get_lobby_active_page")) == "all", "Lobby should open on the full archive page")
	_expect(archive_text.contains("Meta Progress"), "Lobby archive should include meta progress")
	_expect(archive_text.contains("Records"), "Lobby archive should include run records")
	_expect(archive_text.contains("Training Badges (0/4)"), "Lobby archive should include training badges")
	_expect(archive_text.contains("Basics | Badge: None [--]"), "Lobby archive should show locked badge token")
	_expect(archive_text.contains("Characters"), "Lobby archive should include characters")
	_expect(archive_text.contains("Weapons"), "Lobby archive should include weapons")
	_expect(archive_text.contains("Relics"), "Lobby archive should include relics")
	_expect(archive_text.contains("Talents"), "Lobby archive should include talents")
	_expect(archive_text.contains("Blessings"), "Lobby archive should include blessings")
	_expect(archive_text.contains("Statues"), "Lobby archive should include statues")
	_expect(quick_stats.contains("Data Shards 0"), "Lobby quick stats should show permanent currency")
	_expect(quick_stats.contains("Badges 0/4"), "Lobby quick stats should show training badge progress")
	_expect(quick_stats.contains("Characters"), "Lobby quick stats should show content counts")
	_expect(quick_stats.contains("Blessings"), "Lobby quick stats should show blessing count")
	_expect(quick_stats.contains("Statues"), "Lobby quick stats should show statue count")
	_expect(objective_board.contains("Objectives:"), "Lobby objective board should label active goals")
	_expect(objective_board.contains("Unlock Rift Runner 0/10 Data Shards"), "Lobby objective board should surface next character unlock")
	_expect(objective_board.contains("Master Wanderer 40 XP to L2"), "Lobby objective board should surface current character mastery target")
	_expect(objective_board.contains("Training Basics badge: Hit all targets"), "Lobby objective board should surface next training badge target")
	_expect(bool(lobby.call("is_objective_progress_visible")), "Lobby objective progress should show while a meta goal exists")
	_expect(objective_progress == "Unlock Rift Runner", "Lobby objective progress should prioritize the next character unlock")
	_expect(int(hud.call("get_lobby_objective_progress_value")) == 0, "Lobby objective progress should expose the unlock progress percentage")
	_expect(str(hud.call("get_lobby_objective_progress_value_text")) == "0/10 Data Shards", "Lobby objective progress should show the unlock value without hover")
	_expect(str(hud.call("get_lobby_objective_progress_tooltip_text")).contains("0/10 Data Shards"), "Lobby objective progress tooltip should show unlock currency progress")
	_expect(bool(lobby.call("is_objective_progress_action_button_visible")), "Lobby objective progress action should show when a target exists")
	_expect(str(lobby.call("get_objective_progress_action_button_text")) == "Roster", "Lobby objective progress action should route unlock targets to the roster")
	_expect(str(lobby.call("get_objective_progress_action_button_tooltip_text")).contains("Rift Runner"), "Lobby objective progress action should preview the unlock target")
	_expect(bool(lobby.call("request_objective_progress_action_for_test")), "Lobby objective progress action should open the routed target")
	await get_tree().process_frame
	_expect(str(hud.call("get_lobby_active_page")) == "characters", "Lobby objective progress action should open the characters page")
	_expect(str(hud.call("get_hall_summary_text")).contains("Rift Runner"), "Lobby objective progress action should show the unlock target on the characters page")
	lobby.call("select_tab_for_test", "all")
	await get_tree().process_frame
	_expect(bool(lobby.call("is_objective_board_split_layout_enabled")), "Lobby objective board should split text and actions into separate rows")
	_expect(not bool(lobby.call("is_objective_board_action_row_visible")), "Lobby objective action row should stay hidden without a defeat record")
	_expect(not bool(lobby.call("is_objective_counter_button_visible")), "Lobby objective counter route should stay hidden without a defeat record")
	_expect(not bool(lobby.call("is_objective_build_route_button_visible")), "Lobby objective build route should stay hidden without a defeat record")
	_expect(not bool(lobby.call("is_objective_counter_pick_button_visible")), "Lobby objective counter pick should stay hidden without a defeat record")
	_expect(not bool(lobby.call("is_objective_counter_pick_type_label_visible")), "Lobby objective counter pick type hint should stay hidden without a defeat record")
	var defeat_summary: Dictionary = main.call("get_hall_summary")
	defeat_summary["last_defeat"] = {
		"has_record": true,
		"source_id": "spike_trap",
		"source_name": "Spike Trap",
		"source_type": "hazard",
		"source_room_type": "trap",
		"source_counter_tags": [],
	}
	defeat_summary["defeat_sources"] = [{
		"source_id": "spike_trap",
		"source_name": "Spike Trap",
		"source_type": "hazard",
		"source_room_type": "trap",
		"source_counter_tags": [],
		"count": 1,
		"last_run_index": 1,
		"last_seed": 424242,
		"last_biome_index": 1,
		"last_room_id": "trap_01",
		"last_text": "Hazard Spike Trap for 2 at Layer 1",
	}]
	defeat_summary["defeat_source_types"] = {
		"enemy": 0,
		"boss": 0,
		"hazard": 1,
		"unknown": 0,
	}
	lobby.call("show_summary", defeat_summary)
	await get_tree().process_frame
	var counter_objective_board := str(hud.call("get_lobby_objective_board_text"))
	_expect(counter_objective_board.contains("Counter Spike Trap: Speed / Survival / Armor"), "Lobby objective board should surface last-defeat counter tags")
	_expect(counter_objective_board.contains("Try Adrenaline Charm [Relics/Speed]"), "Lobby objective board should surface a routed concrete counter pick")
	_expect(bool(lobby.call("is_objective_board_split_layout_enabled")), "Lobby objective board should keep actions separate after a defeat record")
	_expect(bool(lobby.call("is_objective_board_action_row_visible")), "Lobby objective action row should show when a defeat record exists")
	_expect(not bool(lobby.call("is_objective_start_run_button_visible")), "Lobby objective start action should hide while a defeat counter objective is active")
	_expect(bool(lobby.call("is_objective_counter_button_visible")), "Lobby objective counter route should show when a defeat record exists")
	_expect(str(lobby.call("get_objective_counter_button_text")) == "Review", "Lobby objective counter route should expose a review action")
	_expect(bool(lobby.call("is_objective_build_route_button_visible")), "Lobby objective build route should show when a route target exists")
	_expect(str(lobby.call("get_objective_build_route_button_text")) == "Build", "Lobby objective build route should expose a build action")
	_expect(str(lobby.call("get_objective_build_route_button_tooltip_text")).contains("Relics -> Speed"), "Lobby objective build route should preview the resolved route")
	_expect(bool(lobby.call("is_objective_counter_pick_button_visible")), "Lobby objective counter pick should show when a pick target exists")
	_expect(str(lobby.call("get_objective_counter_pick_button_text")) == "Pick R", "Lobby objective counter pick should expose the current recommendation type token")
	_expect(str(lobby.call("get_objective_counter_pick_button_tooltip_text")).contains("Adrenaline Charm"), "Lobby objective counter pick should preview the recommended item")
	_expect(str(lobby.call("get_objective_counter_pick_button_tooltip_text")).contains("Relics -> Speed"), "Lobby objective counter pick should preview the item route")
	_expect(bool(lobby.call("is_objective_counter_pick_cycle_button_visible")), "Lobby objective counter pick cycle should show when multiple picks exist")
	_expect(str(lobby.call("get_objective_counter_pick_cycle_button_text")).contains("Next 1/"), "Lobby objective counter pick cycle should show the initial pick position")
	_expect(_has_counter_type_token(str(lobby.call("get_objective_counter_pick_cycle_button_text"))), "Lobby objective counter pick cycle should expose the next recommendation type token")
	_expect(bool(lobby.call("is_objective_counter_pick_type_label_visible")), "Lobby objective counter pick type hint should show when a pick target exists")
	var initial_type_hint := str(lobby.call("get_objective_counter_pick_type_label_text"))
	_expect(initial_type_hint.contains("Now Relics"), "Lobby objective counter pick type hint should explain the current token")
	_expect(initial_type_hint.contains("Next "), "Lobby objective counter pick type hint should explain the next token")
	_expect(str(lobby.call("get_objective_counter_pick_type_label_tooltip_text")).contains("Current type: Relics (R)"), "Lobby objective counter pick type hint tooltip should include the current token legend")
	_expect(str(lobby.call("get_objective_counter_pick_type_label_tooltip_text")).contains("Next type:"), "Lobby objective counter pick type hint tooltip should include the next token legend")
	var initial_cycle_tooltip := str(lobby.call("get_objective_counter_pick_cycle_button_tooltip_text"))
	_expect(initial_cycle_tooltip.contains("Next pick:"), "Lobby objective counter pick cycle should preview the next recommendation")
	_expect(initial_cycle_tooltip.contains("["), "Lobby objective counter pick cycle preview should include a route marker")
	_expect(bool(lobby.call("request_objective_counter_for_test")), "Lobby objective counter route should open records source view")
	await get_tree().process_frame
	var counter_records_text := str(hud.call("get_hall_summary_text"))
	_expect(str(hud.call("get_lobby_active_page")) == "records", "Objective counter route should switch to records page")
	_expect(str(lobby.call("get_records_filter_text")).contains("Sources"), "Objective counter route should select Sources death view")
	_expect(str(lobby.call("get_records_source_type_filter_text")).contains("Hazard"), "Objective counter route should select matching hazard source type")
	_expect(counter_records_text.contains("Death Source Detail"), "Objective counter route should show death source details")
	_expect(counter_records_text.contains("spike_trap"), "Objective counter route should show the focused death source")
	_expect(bool(lobby.call("request_objective_build_route_for_test")), "Lobby objective build route should open the resolved codex route")
	await get_tree().process_frame
	var objective_build_route_text := str(hud.call("get_hall_summary_text"))
	_expect(str(hud.call("get_lobby_active_page")) == "relics", "Objective build route should switch to relics page")
	_expect(str(lobby.call("get_codex_filter_text")).contains("Speed"), "Objective build route should select the speed route")
	_expect(objective_build_route_text.contains("Filter: Speed"), "Objective build route should show the selected route summary")
	_expect(objective_build_route_text.contains("Adrenaline Charm"), "Objective build route should list a speed counter relic")
	_expect(bool(lobby.call("request_objective_counter_pick_for_test")), "Lobby objective counter pick should open the resolved recommendation")
	await get_tree().process_frame
	var objective_pick_text := str(hud.call("get_hall_summary_text"))
	_expect(str(hud.call("get_lobby_active_page")) == "relics", "Objective counter pick should stay on the recommendation page")
	_expect(str(lobby.call("get_codex_filter_text")).contains("Speed"), "Objective counter pick should keep the recommendation route filter")
	_expect(str(lobby.call("get_codex_search_text")) == "Adrenaline Charm", "Objective counter pick should search for the recommended item")
	_expect(str(lobby.call("get_codex_detail_title_text")) == "Adrenaline Charm", "Objective counter pick should focus the recommended detail card")
	_expect(objective_pick_text.contains("Search \"Adrenaline Charm\""), "Objective counter pick should summarize the focused recommendation search")
	_expect(bool(lobby.call("request_next_objective_counter_pick_for_test")), "Lobby objective counter pick cycle should advance to another recommendation")
	await get_tree().process_frame
	var cycled_objective_board := str(hud.call("get_lobby_objective_board_text"))
	_expect(cycled_objective_board.contains("Try "), "Cycling objective counter pick should keep a concrete recommendation visible")
	_expect(not cycled_objective_board.contains("Try Adrenaline Charm [Relics/Speed]"), "Cycling objective counter pick should move away from the first recommendation")
	_expect(str(lobby.call("get_objective_counter_pick_button_text")).begins_with("Pick "), "Cycling objective counter pick should keep the pick action compact")
	_expect(_has_counter_type_token(str(lobby.call("get_objective_counter_pick_button_text"))), "Cycling objective counter pick should update the current type token")
	_expect(str(lobby.call("get_objective_counter_pick_type_label_text")).contains("Now "), "Cycling objective counter pick should keep the current type hint visible")
	_expect(str(lobby.call("get_objective_counter_pick_type_label_text")) != initial_type_hint, "Cycling objective counter pick should update the type hint")
	_expect(str(lobby.call("get_objective_counter_pick_cycle_button_text")).contains("Next 2/"), "Cycling objective counter pick should update the visible pick position")
	_expect(_has_counter_type_token(str(lobby.call("get_objective_counter_pick_cycle_button_text"))), "Cycling objective counter pick should keep the next type token visible")
	_expect(str(lobby.call("get_objective_counter_pick_cycle_button_tooltip_text")).contains("Next pick:"), "Cycling objective counter pick should keep previewing the next recommendation")
	_expect(str(lobby.call("get_objective_counter_pick_cycle_button_tooltip_text")) != initial_cycle_tooltip, "Cycling objective counter pick should update the next recommendation preview")
	var saw_cross_type_objective_pick := not cycled_objective_board.contains("[Relics/")
	for _cycle_index in range(8):
		if saw_cross_type_objective_pick:
			break
		_expect(bool(lobby.call("request_next_objective_counter_pick_for_test")), "Objective counter pick cycle should keep advancing through the cross-type pool")
		await get_tree().process_frame
		var cross_type_objective_board := str(hud.call("get_lobby_objective_board_text"))
		saw_cross_type_objective_pick = cross_type_objective_board.contains("Try ") and not cross_type_objective_board.contains("[Relics/")
	_expect(saw_cross_type_objective_pick, "Objective counter pick cycle should eventually surface a non-relic recommendation type")
	lobby.call("reset_codex_refinements_for_test")
	await get_tree().process_frame
	lobby.call("show_summary", main.call("get_hall_summary"))
	await get_tree().process_frame
	_expect(str(hud.call("get_lobby_selected_status_text")).contains("Ready"), "Default character should be ready in lobby")
	_expect(str(lobby.call("get_current_character_icon_text")) == "CHR", "Current character icon should show character badge")
	_expect(str(lobby.call("get_current_character_icon_key")) == "character_wanderer", "Current character icon should expose Wanderer icon key")
	_expect(lobby.call("get_current_character_icon_swatch_color") == CONTENT_ICON_REGISTRY.get_placeholder_color("character_wanderer", "characters"), "Current character icon swatch should use registry color")
	_expect(str(lobby.call("get_current_character_icon_texture_path")) == CONTENT_ICON_REGISTRY.get_texture_path("character_wanderer", "characters"), "Current character icon should expose registry texture path")
	_expect(str(lobby.call("get_current_character_icon_texture_path")).ends_with("wanderer.svg"), "Current character icon should use the Wanderer character icon")
	_expect(bool(lobby.call("is_current_character_icon_texture_visible")), "Current character icon texture should be visible when available")
	_expect(str(lobby.call("get_current_character_icon_tooltip_text")).contains("character_wanderer"), "Current character icon tooltip should expose its icon key")
	_expect(not bool(lobby.call("is_start_button_disabled")), "Lobby start action should be enabled for an unlocked character")
	_expect(not bool(lobby.call("is_training_button_disabled")), "Lobby training action should be enabled for an unlocked character")

	lobby.call("select_tab_for_test", "records")
	await get_tree().process_frame
	var records_text := str(hud.call("get_hall_summary_text"))
	_expect(str(hud.call("get_lobby_active_page")) == "records", "Lobby should switch to records page")
	_expect(records_text.contains("Records"), "Records page should include records heading")
	_expect(records_text.contains("Data Shards"), "Records page should include permanent currency")
	_expect(records_text.contains("Best Guard Blocks 0"), "Records page should include projectile block record")
	_expect(records_text.contains("Training Badges (0/4)"), "Records page should include training badge progress")
	lobby.call("select_tab_for_test", "characters")
	await get_tree().process_frame
	var characters_text := str(hud.call("get_hall_summary_text"))
	_expect(str(hud.call("get_lobby_objective_board_text")).contains("Master Wanderer 40 XP to L2"), "Lobby objective board should remain visible while browsing character page")
	_expect(str(hud.call("get_lobby_active_page")) == "characters", "Lobby should switch to characters page")
	_expect(not bool(lobby.call("is_codex_filter_visible")), "Characters page should hide codex route filter")
	_expect(not bool(lobby.call("is_codex_refinement_visible")), "Characters page should hide codex refinement controls")
	_expect(not bool(lobby.call("is_codex_detail_card_visible")), "Characters page should hide codex detail card")
	_expect(characters_text.contains("Wanderer"), "Characters page should list Wanderer")
	_expect(characters_text.contains("Rift Runner"), "Characters page should list Rift Runner")
	_expect(characters_text.contains("Selected"), "Characters page should mark the selected character")
	_expect(characters_text.contains("Starting Weapons: Basic Pistol, Shotgun, Energy Staff"), "Characters page should show starting weapons")
	_expect(characters_text.contains("Passive: Steady Hands"), "Characters page should show passive details")
	_expect(characters_text.contains("Mastery Progress: [------------] 0/40 XP to L2 (0%)"), "Characters page should show mastery progress bar")
	_expect(characters_text.contains("Mastery Rewards: Current None | Next +1 Energy"), "Characters page should compare current and next mastery rewards")
	_expect(characters_text.contains("Next Mastery: L2 at 40 XP"), "Characters page should show next mastery XP")
	_expect(characters_text.contains("Reward: +1 Energy"), "Characters page should show next mastery reward")
	_expect(characters_text.contains("Upgrade Slots: 3"), "Characters page should show upgrade slot count")
	lobby.call("select_tab_for_test", "weapons")
	await get_tree().process_frame
	var weapons_text := str(hud.call("get_hall_summary_text"))
	_expect(str(hud.call("get_lobby_active_page")) == "weapons", "Lobby should switch to weapons page")
	_expect(weapons_text.contains("Basic Pistol"), "Weapons page should list Basic Pistol")
	_expect(weapons_text.contains("Featured Card:"), "Weapons page should show a featured weapon card")
	_expect(weapons_text.contains("Core: Damage"), "Weapon featured card should summarize core stats")
	_expect(weapons_text.contains("Special: Status"), "Weapon featured card should summarize special mechanics")
	_expect(weapons_text.contains("Build Routes:"), "Weapons page should summarize build routes")
	_expect(weapons_text.contains("Stats: Damage"), "Weapons page should show weapon stat details")
	_expect(weapons_text.contains("Traits: Mode"), "Weapons page should show weapon trait details")
	_expect(weapons_text.contains("Status"), "Weapons page should show weapon status details")
	_expect(weapons_text.contains("Guard"), "Weapons page should show projectile guard details")
	_expect(weapons_text.contains("Charge"), "Weapons page should show charge weapon details")
	_expect(weapons_text.contains("Deploy"), "Weapons page should show deployable weapon details")
	_expect(weapons_text.contains("Deploy Field"), "Weapons page should identify field deployables")
	_expect(weapons_text.contains("Deploy Mine"), "Weapons page should identify mine deployables")
	_expect(weapons_text.contains("Deploy Sentry"), "Weapons page should identify sentry deployables")
	_expect(weapons_text.contains("Ember Sprayer"), "Weapons page should list status weapon additions")
	_expect(weapons_text.contains("Guard Cleaver"), "Weapons page should list projectile-blocking weapon additions")
	_expect(weapons_text.contains("Coil Bow"), "Weapons page should list charge weapon additions")
	_expect(weapons_text.contains("Snare Beacon"), "Weapons page should list deployable weapon additions")
	_expect(weapons_text.contains("Compass Needle"), "Weapons page should list homing weapon additions")
	_expect(weapons_text.contains("Homing 210deg/s 300r"), "Weapons page should show homing turn and acquisition stats")
	_expect(weapons_text.contains("Relay Arc"), "Weapons page should list chain weapon additions")
	_expect(weapons_text.contains("Chain 2x 150r 65%"), "Weapons page should show chain target, radius, and damage stats")
	_expect(bool(lobby.call("is_codex_filter_visible")), "Weapons page should show codex route filter")
	_expect(bool(lobby.call("is_codex_refinement_visible")), "Weapons page should show codex search and sort controls")
	_expect(bool(lobby.call("is_codex_detail_card_visible")), "Weapons page should show codex detail card")
	_expect(not str(lobby.call("get_codex_detail_title_text")).is_empty(), "Weapon detail card should show a title")
	_expect(str(lobby.call("get_codex_detail_icon_text")) == "WPN", "Weapon detail card should show weapon badge")
	_expect(str(lobby.call("get_codex_detail_icon_key")).begins_with("weapon_"), "Weapon detail card should expose weapon icon key")
	_expect(lobby.call("get_codex_detail_icon_swatch_color") == CONTENT_ICON_REGISTRY.get_placeholder_color(str(lobby.call("get_codex_detail_icon_key")), "weapons"), "Weapon detail card should color the icon swatch from the icon registry")
	_expect(str(lobby.call("get_codex_detail_icon_texture_path")) == CONTENT_ICON_REGISTRY.get_texture_path(str(lobby.call("get_codex_detail_icon_key")), "weapons"), "Weapon detail card should expose the registry texture path")
	_expect(not str(lobby.call("get_codex_detail_icon_texture_path")).ends_with("default_weapon.svg"), "Weapon detail card should use an item-specific icon when available")
	_expect(bool(lobby.call("is_codex_detail_icon_texture_visible")), "Weapon detail card should show the default icon texture when available")
	_expect(str(lobby.call("get_codex_detail_icon_tooltip_text")).contains(str(lobby.call("get_codex_detail_icon_key"))), "Weapon detail icon swatch should expose its icon key in tooltip")
	_expect(str(lobby.call("get_codex_detail_rarity_badge_text")) == "COMMON", "Weapon detail card should show common rarity badge")
	_expect(str(lobby.call("get_codex_detail_meta_text")).contains("Tags"), "Weapon detail card should show tag metadata")
	_expect(str(lobby.call("get_codex_detail_body_text")).contains("Damage"), "Weapon detail card should show damage")
	_expect(str(lobby.call("get_codex_detail_body_text")).contains("Status"), "Weapon detail card should show status mechanics")
	_expect(str(lobby.call("get_codex_filter_text")).contains("Route: All"), "Weapons route filter should default to all")
	_expect(str(lobby.call("get_codex_sort_text")).contains("Sort: Name"), "Weapons sort should default to name")
	_expect(str(lobby.call("get_codex_rarity_text")).contains("Rarity: All"), "Weapons rarity filter should default to all")
	_expect(str(lobby.call("get_codex_search_text")).is_empty(), "Weapons search should default to empty")
	_expect(not weapons_text.contains("Sharp Rounds"), "Weapons page should not include relic entries")
	lobby.call("set_codex_filter_for_test", "close_range")
	await get_tree().process_frame
	var close_range_weapons_text := str(hud.call("get_hall_summary_text"))
	_expect(str(lobby.call("get_codex_filter_text")).contains("Close Range"), "Weapons route filter should show selected route")
	_expect(close_range_weapons_text.contains("Filter: Close Range"), "Weapons page should show selected route summary")
	_expect(close_range_weapons_text.contains("Featured Card: Arc Blade"), "Weapon featured card should follow route filter")
	_expect(str(lobby.call("get_codex_detail_title_text")) == "Arc Blade", "Weapon detail card should follow route filter")
	_expect(str(lobby.call("get_codex_detail_icon_key")) == "weapon_arc_blade", "Weapon detail icon key should follow route filter")
	_expect(str(lobby.call("get_codex_detail_icon_texture_path")).ends_with("arc_blade.svg"), "Weapon detail icon texture should follow route filter")
	_expect(str(lobby.call("get_codex_detail_icon_tooltip_text")).contains("weapon_arc_blade"), "Weapon detail icon tooltip should follow route filter")
	_expect(close_range_weapons_text.contains("Arc Blade"), "Close range weapon filter should include Arc Blade")
	_expect(close_range_weapons_text.contains("Shotgun"), "Close range weapon filter should include Shotgun")
	_expect(not close_range_weapons_text.contains("Basic Pistol"), "Close range weapon filter should hide unrelated weapons")
	lobby.call("request_clear_codex_filter_for_test")
	await get_tree().process_frame
	_expect(str(hud.call("get_hall_summary_text")).contains("Basic Pistol"), "Clearing weapon filter should restore all weapons")
	lobby.call("set_codex_filter_for_test", "elemental")
	await get_tree().process_frame
	var elemental_weapons_text := str(hud.call("get_hall_summary_text"))
	_expect(str(lobby.call("get_codex_filter_text")).contains("Elemental"), "Weapons route filter should support elemental status route")
	_expect(elemental_weapons_text.contains("Ember Sprayer"), "Elemental weapon filter should include Ember Sprayer")
	_expect(elemental_weapons_text.contains("Slag Comet"), "Elemental weapon filter should include Slag Comet")
	_expect(not elemental_weapons_text.contains("Arc Blade"), "Elemental weapon filter should hide unrelated weapons")
	lobby.call("request_clear_codex_filter_for_test")
	await get_tree().process_frame
	lobby.call("set_codex_filter_for_test", "guard")
	await get_tree().process_frame
	var guard_weapons_text := str(hud.call("get_hall_summary_text"))
	_expect(str(lobby.call("get_codex_filter_text")).contains("Guard"), "Weapons route filter should support guard route")
	_expect(guard_weapons_text.contains("Guard Cleaver"), "Guard weapon filter should include Guard Cleaver")
	_expect(guard_weapons_text.contains("Riposte Saber"), "Guard weapon filter should include Riposte Saber")
	_expect(not guard_weapons_text.contains("Ember Sprayer"), "Guard weapon filter should hide unrelated status weapons")
	lobby.call("request_clear_codex_filter_for_test")
	await get_tree().process_frame
	lobby.call("set_codex_filter_for_test", "charge")
	await get_tree().process_frame
	var charge_weapons_text := str(hud.call("get_hall_summary_text"))
	_expect(str(lobby.call("get_codex_filter_text")).contains("Charge"), "Weapons route filter should support charge route")
	_expect(charge_weapons_text.contains("Coil Bow"), "Charge weapon filter should include Coil Bow")
	_expect(charge_weapons_text.contains("Storm Capacitor"), "Charge weapon filter should include Storm Capacitor")
	_expect(not charge_weapons_text.contains("Basic Pistol"), "Charge weapon filter should hide unrelated weapons")
	lobby.call("request_clear_codex_filter_for_test")
	await get_tree().process_frame
	lobby.call("set_codex_filter_for_test", "deployable")
	await get_tree().process_frame
	var deployable_weapons_text := str(hud.call("get_hall_summary_text"))
	_expect(str(lobby.call("get_codex_filter_text")).contains("Deployable"), "Weapons route filter should support deployable route")
	_expect(deployable_weapons_text.contains("Snare Beacon"), "Deployable weapon filter should include Snare Beacon")
	_expect(deployable_weapons_text.contains("Sentry Seed"), "Deployable weapon filter should include Sentry Seed")
	_expect(not deployable_weapons_text.contains("Basic Pistol"), "Deployable weapon filter should hide unrelated weapons")
	lobby.call("set_codex_sort_for_test", "drop_weight")
	await get_tree().process_frame
	var drop_sorted_weapons_text := str(hud.call("get_hall_summary_text"))
	var snare_index := drop_sorted_weapons_text.find("Snare Beacon")
	var ember_mine_index := drop_sorted_weapons_text.find("Ember Mine")
	var sentry_index := drop_sorted_weapons_text.find("Sentry Seed")
	_expect(str(lobby.call("get_codex_sort_text")).contains("Drop Weight"), "Weapons sort control should show drop-weight sort")
	_expect(snare_index >= 0 and ember_mine_index >= 0 and sentry_index >= 0 and snare_index < ember_mine_index and ember_mine_index < sentry_index, "Drop-weight sort should order deployable weapons by configured weight")
	lobby.call("set_codex_rarity_for_test", "epic")
	await get_tree().process_frame
	var epic_deployable_weapons_text := str(hud.call("get_hall_summary_text"))
	_expect(str(lobby.call("get_codex_rarity_text")).contains("Epic"), "Weapons rarity filter should show selected rarity")
	_expect(epic_deployable_weapons_text.contains("Sentry Seed"), "Epic deployable filter should include Sentry Seed")
	_expect(not epic_deployable_weapons_text.contains("Snare Beacon"), "Epic deployable filter should hide rare deployable weapons")
	_expect(str(lobby.call("get_codex_detail_title_text")) == "Sentry Seed", "Weapon detail card should follow rarity filter")
	_expect(str(lobby.call("get_codex_detail_rarity_badge_text")) == "EPIC", "Weapon detail card rarity badge should follow rarity filter")
	lobby.call("reset_codex_refinements_for_test")
	await get_tree().process_frame
	lobby.call("set_codex_search_for_test", "snare")
	await get_tree().process_frame
	var search_weapons_text := str(hud.call("get_hall_summary_text"))
	_expect(str(lobby.call("get_codex_search_text")) == "snare", "Weapons search field should retain query")
	_expect(search_weapons_text.contains("Search \"snare\""), "Weapons page should summarize active search query")
	_expect(search_weapons_text.contains("Featured Card: Snare Beacon"), "Weapon featured card should follow active search")
	_expect(str(lobby.call("get_codex_detail_title_text")) == "Snare Beacon", "Weapon detail card should follow active search")
	_expect(str(lobby.call("get_codex_detail_icon_key")) == "weapon_snare_beacon", "Weapon detail icon key should follow active search")
	_expect(str(lobby.call("get_codex_detail_icon_texture_path")).ends_with("snare_beacon.svg"), "Weapon detail icon texture should follow active search")
	_expect(str(lobby.call("get_codex_detail_body_text")).contains("Deploy"), "Weapon detail card should summarize deployable mechanics")
	_expect(search_weapons_text.contains("Snare Beacon"), "Weapon search should include matching weapon")
	_expect(not search_weapons_text.contains("Basic Pistol"), "Weapon search should hide non-matching weapons")
	lobby.call("request_clear_codex_filter_for_test")
	lobby.call("reset_codex_refinements_for_test")
	await get_tree().process_frame
	lobby.call("set_codex_filter_for_test", "homing")
	await get_tree().process_frame
	var homing_weapons_text := str(hud.call("get_hall_summary_text"))
	_expect(homing_weapons_text.contains("Compass Needle") and homing_weapons_text.contains("Lantern Swarm"), "Homing route filter should include dedicated guidance weapons")
	_expect(not homing_weapons_text.contains("Basic Pistol"), "Homing route filter should hide unsupported weapons")
	lobby.call("set_codex_filter_for_test", "chain")
	await get_tree().process_frame
	var chain_weapons_text := str(hud.call("get_hall_summary_text"))
	_expect(chain_weapons_text.contains("Relay Arc") and chain_weapons_text.contains("Stormglass Rail"), "Chain route filter should include dedicated relay weapons")
	_expect(not chain_weapons_text.contains("Basic Pistol"), "Chain route filter should hide unsupported weapons")
	lobby.call("request_clear_codex_filter_for_test")
	await get_tree().process_frame
	lobby.call("select_tab_for_test", "relics")
	await get_tree().process_frame
	var relics_text := str(hud.call("get_hall_summary_text"))
	_expect(str(hud.call("get_lobby_active_page")) == "relics", "Lobby should switch to relics page")
	_expect(relics_text.contains("Sharp Rounds"), "Relics page should list Sharp Rounds")
	_expect(relics_text.contains("Featured Card:"), "Relics page should show a featured relic card")
	_expect(relics_text.contains("Rules:"), "Relic featured card should summarize stacking rules")
	_expect(relics_text.contains("Build Routes:"), "Relics page should summarize build routes")
	_expect(relics_text.contains("Effect:"), "Relics page should show effect details")
	_expect(relics_text.contains("Stacking:"), "Relics page should show stacking and conflict details")
	_expect(relics_text.contains("Draw Weight"), "Relics page should list charge relic additions")
	_expect(relics_text.contains("Anchor Spool"), "Relics page should list deployable relic additions")
	_expect(relics_text.contains("Tracking Vane"), "Relics page should list homing relic additions")
	_expect(relics_text.contains("Forked Bus"), "Relics page should list chain relic additions")
	_expect(bool(lobby.call("is_codex_refinement_visible")), "Relics page should show codex search and sort controls")
	_expect(bool(lobby.call("is_codex_detail_card_visible")), "Relics page should show codex detail card")
	_expect(str(lobby.call("get_codex_detail_icon_text")) == "REL", "Relic detail card should show relic badge")
	_expect(str(lobby.call("get_codex_detail_icon_key")).begins_with("relic_"), "Relic detail card should expose relic icon key")
	_expect(lobby.call("get_codex_detail_icon_swatch_color") == CONTENT_ICON_REGISTRY.get_placeholder_color(str(lobby.call("get_codex_detail_icon_key")), "relics"), "Relic detail card should color the icon swatch from the icon registry")
	_expect(str(lobby.call("get_codex_detail_icon_texture_path")) == CONTENT_ICON_REGISTRY.get_texture_path(str(lobby.call("get_codex_detail_icon_key")), "relics"), "Relic detail card should expose the registry texture path")
	_expect(not str(lobby.call("get_codex_detail_icon_texture_path")).ends_with("default_relic.svg"), "Relic detail card should use an item-specific icon when available")
	_expect(str(lobby.call("get_codex_detail_body_text")).contains("Effect"), "Relic detail card should show effect")
	_expect(str(lobby.call("get_codex_detail_body_text")).contains("Rules"), "Relic detail card should show stacking rules")
	_expect(str(lobby.call("get_codex_filter_text")).contains("Route: All"), "Relics route filter should default to all")
	_expect(not relics_text.contains("Basic Pistol"), "Relics page should not include weapon entries")
	lobby.call("set_codex_filter_for_test", "projectile")
	await get_tree().process_frame
	var projectile_relics_text := str(hud.call("get_hall_summary_text"))
	_expect(str(lobby.call("get_codex_filter_text")).contains("Projectile"), "Relics route filter should show selected route")
	_expect(projectile_relics_text.contains("Filter: Projectile"), "Relics page should show selected route summary")
	_expect(projectile_relics_text.contains("Sharp Rounds"), "Projectile relic filter should include Sharp Rounds")
	_expect(not projectile_relics_text.contains("Guardian Ward"), "Projectile relic filter should hide unrelated relics")
	lobby.call("set_codex_filter_for_test", "status")
	await get_tree().process_frame
	var status_relics_text := str(hud.call("get_hall_summary_text"))
	_expect(str(lobby.call("get_codex_filter_text")).contains("Status"), "Relics route filter should support status route")
	_expect(status_relics_text.contains("Volatile Oil"), "Status relic filter should include Volatile Oil")
	_expect(status_relics_text.contains("Lingering Ash"), "Status relic filter should include Lingering Ash")
	_expect(not status_relics_text.contains("Guardian Ward"), "Status relic filter should hide unrelated relics")
	lobby.call("set_codex_filter_for_test", "guard")
	await get_tree().process_frame
	var guard_relics_text := str(hud.call("get_hall_summary_text"))
	_expect(str(lobby.call("get_codex_filter_text")).contains("Guard"), "Relics route filter should support guard route")
	_expect(guard_relics_text.contains("Parry Grip"), "Guard relic filter should include Parry Grip")
	_expect(guard_relics_text.contains("Warding Hinge"), "Guard relic filter should include Warding Hinge")
	_expect(not guard_relics_text.contains("Sharp Rounds"), "Guard relic filter should hide unrelated projectile relics")
	lobby.call("set_codex_filter_for_test", "charge")
	await get_tree().process_frame
	var charge_relics_text := str(hud.call("get_hall_summary_text"))
	_expect(str(lobby.call("get_codex_filter_text")).contains("Charge"), "Relics route filter should support charge route")
	_expect(charge_relics_text.contains("Draw Weight"), "Charge relic filter should include Draw Weight")
	_expect(charge_relics_text.contains("Quick Windup"), "Charge relic filter should include Quick Windup")
	_expect(charge_relics_text.contains("Stored Spark"), "Charge relic filter should include Stored Spark")
	_expect(not charge_relics_text.contains("Guardian Ward"), "Charge relic filter should hide unrelated relics")
	lobby.call("set_codex_filter_for_test", "deployable")
	await get_tree().process_frame
	var deployable_relics_text := str(hud.call("get_hall_summary_text"))
	_expect(str(lobby.call("get_codex_filter_text")).contains("Deployable"), "Relics route filter should support deployable route")
	_expect(deployable_relics_text.contains("Featured Card: Anchor Spool"), "Relic featured card should follow route filter")
	_expect(str(lobby.call("get_codex_detail_title_text")) == "Anchor Spool", "Relic detail card should follow route filter")
	_expect(str(lobby.call("get_codex_detail_icon_key")) == "relic_anchor_spool", "Relic detail icon key should follow route filter")
	_expect(str(lobby.call("get_codex_detail_icon_texture_path")).ends_with("anchor_spool.svg"), "Relic detail icon texture should follow route filter")
	_expect(deployable_relics_text.contains("Tripwire Amplifier"), "Deployable relic filter should include Tripwire Amplifier")
	_expect(deployable_relics_text.contains("Anchor Spool"), "Deployable relic filter should include Anchor Spool")
	_expect(not deployable_relics_text.contains("Guardian Ward"), "Deployable relic filter should hide unrelated relics")
	lobby.call("set_codex_rarity_for_test", "rare")
	await get_tree().process_frame
	var rare_deployable_relics_text := str(hud.call("get_hall_summary_text"))
	_expect(str(lobby.call("get_codex_rarity_text")).contains("Rare"), "Relics rarity filter should show selected rarity")
	_expect(rare_deployable_relics_text.contains("Tripwire Amplifier"), "Rare deployable relic filter should include Tripwire Amplifier")
	_expect(not rare_deployable_relics_text.contains("Anchor Spool"), "Rare deployable relic filter should hide common deployable relics")
	_expect(str(lobby.call("get_codex_detail_title_text")) == "Tripwire Amplifier", "Relic detail card should follow rarity filter")
	_expect(str(lobby.call("get_codex_detail_rarity_badge_text")) == "RARE", "Relic detail card rarity badge should follow rarity filter")
	lobby.call("reset_codex_refinements_for_test")
	await get_tree().process_frame
	lobby.call("set_codex_search_for_test", "anchor")
	await get_tree().process_frame
	var search_relics_text := str(hud.call("get_hall_summary_text"))
	_expect(search_relics_text.contains("Search \"anchor\""), "Relics page should summarize active search query")
	_expect(str(lobby.call("get_codex_detail_title_text")) == "Anchor Spool", "Relic detail card should follow active search")
	_expect(search_relics_text.contains("Anchor Spool"), "Relic search should include matching relic")
	_expect(not search_relics_text.contains("Guardian Ward"), "Relic search should hide non-matching relics")
	lobby.call("reset_codex_refinements_for_test")
	await get_tree().process_frame
	lobby.call("select_tab_for_test", "talents")
	await get_tree().process_frame
	var talents_text := str(hud.call("get_hall_summary_text"))
	_expect(str(hud.call("get_lobby_active_page")) == "talents", "Lobby should switch to talents page")
	_expect(talents_text.contains("Steady Hands"), "Talents page should list Steady Hands")
	_expect(talents_text.contains("Featured Card:"), "Talents page should show a featured talent card")
	_expect(talents_text.contains("Build Routes:"), "Talents page should summarize build routes")
	_expect(talents_text.contains("Effect:"), "Talents page should show effect details")
	_expect(talents_text.contains("Conflicts:"), "Talents page should show conflict details")
	_expect(bool(lobby.call("is_codex_detail_card_visible")), "Talents page should show codex detail card")
	_expect(str(lobby.call("get_codex_detail_icon_text")) == "TAL", "Talent detail card should show talent badge")
	_expect(str(lobby.call("get_codex_detail_icon_key")).begins_with("talent_"), "Talent detail card should expose talent icon key")
	_expect(lobby.call("get_codex_detail_icon_swatch_color") == CONTENT_ICON_REGISTRY.get_placeholder_color(str(lobby.call("get_codex_detail_icon_key")), "talents"), "Talent detail card should color the icon swatch from the icon registry")
	_expect(str(lobby.call("get_codex_detail_icon_texture_path")) == CONTENT_ICON_REGISTRY.get_texture_path(str(lobby.call("get_codex_detail_icon_key")), "talents"), "Talent detail card should expose the registry texture path")
	_expect(not str(lobby.call("get_codex_detail_icon_texture_path")).ends_with("default_talent.svg"), "Talent detail card should use an item-specific icon when available")
	_expect(str(lobby.call("get_codex_detail_body_text")).contains("Effect"), "Talent detail card should show effect")
	_expect(str(lobby.call("get_codex_filter_text")).contains("Route: All"), "Talents route filter should default to all")
	lobby.call("set_codex_filter_for_test", "survival")
	await get_tree().process_frame
	var survival_talents_text := str(hud.call("get_hall_summary_text"))
	_expect(str(lobby.call("get_codex_filter_text")).contains("Survival"), "Talents route filter should show selected route")
	_expect(survival_talents_text.contains("Filter: Survival"), "Talents page should show selected route summary")
	_expect(survival_talents_text.contains("Iron Vow"), "Survival talent filter should include Iron Vow")
	_expect(str(lobby.call("get_codex_detail_title_text")) == "Iron Vow", "Talent detail card should follow survival route filter")
	_expect(str(lobby.call("get_codex_detail_icon_key")) == "talent_iron_vow", "Talent detail icon key should follow survival route filter")
	_expect(str(lobby.call("get_codex_detail_icon_texture_path")).ends_with("iron_vow.svg"), "Talent detail icon texture should follow survival route filter")
	_expect(not survival_talents_text.contains("Steady Hands"), "Survival talent filter should hide unrelated talents")
	lobby.call("select_tab_for_test", "blessings")
	await get_tree().process_frame
	var blessings_text := str(hud.call("get_hall_summary_text"))
	_expect(str(hud.call("get_lobby_active_page")) == "blessings", "Lobby should switch to blessings page")
	_expect(blessings_text.contains("Afterglow Circuit"), "Blessings page should list event-driven room clear blessing")
	_expect(blessings_text.contains("Deep Cell"), "Blessings page should list Deep Cell")
	_expect(blessings_text.contains("Featured Card: Afterglow Circuit"), "Blessings page should show a featured blessing card")
	_expect(blessings_text.contains("Build Routes:"), "Blessings page should summarize build routes")
	_expect(blessings_text.contains("Effect:"), "Blessings page should show effect details")
	_expect(blessings_text.contains("Rule:"), "Blessings page should show rule text")
	_expect(bool(lobby.call("is_codex_detail_card_visible")), "Blessings page should show codex detail card")
	_expect(str(lobby.call("get_codex_detail_title_text")) == "Afterglow Circuit", "Blessing detail card should default to first blessing")
	_expect(str(lobby.call("get_codex_detail_icon_text")) == "BLS", "Blessing detail card should show blessing badge")
	_expect(str(lobby.call("get_codex_detail_icon_key")) == "blessing_afterglow_circuit", "Blessing detail card should expose blessing icon key")
	_expect(lobby.call("get_codex_detail_icon_swatch_color") == CONTENT_ICON_REGISTRY.get_placeholder_color("blessing_afterglow_circuit", "blessings"), "Blessing detail card should color the icon swatch from the icon registry")
	_expect(str(lobby.call("get_codex_detail_icon_texture_path")) == CONTENT_ICON_REGISTRY.get_texture_path("blessing_afterglow_circuit", "blessings"), "Blessing detail card should expose the registry texture path")
	_expect(str(lobby.call("get_codex_detail_icon_texture_path")).ends_with("afterglow_circuit.svg"), "Blessing detail card should use the Afterglow Circuit item icon when available")
	_expect(str(lobby.call("get_codex_detail_rarity_badge_text")) == "RARE", "Blessing detail card should show rare rarity badge")
	_expect(str(lobby.call("get_codex_detail_body_text")).contains("Rule"), "Blessing detail card should show rule text")
	_expect(str(lobby.call("get_codex_filter_text")).contains("Route: All"), "Blessings route filter should default to all")
	lobby.call("set_codex_filter_for_test", "survival")
	await get_tree().process_frame
	var survival_blessings_text := str(hud.call("get_hall_summary_text"))
	_expect(str(lobby.call("get_codex_filter_text")).contains("Survival"), "Blessings route filter should show selected route")
	_expect(survival_blessings_text.contains("Filter: Survival"), "Blessings page should show selected route summary")
	_expect(survival_blessings_text.contains("Brace Current"), "Survival blessing filter should include Brace Current")
	_expect(survival_blessings_text.contains("Quiet Plate"), "Survival blessing filter should include Quiet Plate")
	_expect(str(lobby.call("get_codex_detail_title_text")) == "Brace Current", "Blessing detail card should follow survival route filter")
	_expect(str(lobby.call("get_codex_detail_icon_key")) == "blessing_brace_current", "Blessing detail icon key should follow survival route filter")
	_expect(str(lobby.call("get_codex_detail_icon_texture_path")).ends_with("brace_current.svg"), "Blessing detail icon texture should follow survival route filter")
	_expect(not survival_blessings_text.contains("Deep Cell"), "Survival blessing filter should hide unrelated blessings")

	lobby.call("select_tab_for_test", "statues")
	await get_tree().process_frame
	var statues_text := str(hud.call("get_hall_summary_text"))
	_expect(str(hud.call("get_lobby_active_page")) == "statues", "Lobby should switch to statues page")
	_expect(statues_text.contains("Bulwark Idol"), "Statues page should list Bulwark Idol")
	_expect(statues_text.contains("Echo Reservoir"), "Statues page should list Echo Reservoir")
	_expect(statues_text.contains("Featured Card: Bulwark Idol"), "Statues page should show a featured statue card")
	_expect(statues_text.contains("Build Routes:"), "Statues page should summarize build routes")
	_expect(statues_text.contains("Effect:"), "Statues page should show effect details")
	_expect(statues_text.contains("Rule:"), "Statues page should show rule text")
	_expect(bool(lobby.call("is_codex_detail_card_visible")), "Statues page should show codex detail card")
	_expect(str(lobby.call("get_codex_detail_title_text")) == "Bulwark Idol", "Statue detail card should default to first statue")
	_expect(str(lobby.call("get_codex_detail_icon_text")) == "STU", "Statue detail card should show statue badge")
	_expect(str(lobby.call("get_codex_detail_icon_key")) == "statue_bulwark_idol", "Statue detail card should expose statue icon key")
	_expect(lobby.call("get_codex_detail_icon_swatch_color") == CONTENT_ICON_REGISTRY.get_placeholder_color("statue_bulwark_idol", "statues"), "Statue detail card should color the icon swatch from the icon registry")
	_expect(str(lobby.call("get_codex_detail_icon_texture_path")) == CONTENT_ICON_REGISTRY.get_texture_path("statue_bulwark_idol", "statues"), "Statue detail card should expose the registry texture path")
	_expect(str(lobby.call("get_codex_detail_icon_texture_path")).ends_with("bulwark_idol.svg"), "Statue detail card should use the Bulwark Idol item icon when available")
	_expect(str(lobby.call("get_codex_detail_rarity_badge_text")) == "COMMON", "Statue detail card should show common rarity badge")
	_expect(str(lobby.call("get_codex_detail_body_text")).contains("Every"), "Statue detail card should show skill trigger interval")
	_expect(str(lobby.call("get_codex_filter_text")).contains("Route: All"), "Statues route filter should default to all")
	lobby.call("set_codex_filter_for_test", "survival")
	await get_tree().process_frame
	var survival_statues_text := str(hud.call("get_hall_summary_text"))
	_expect(str(lobby.call("get_codex_filter_text")).contains("Survival"), "Statues route filter should show selected route")
	_expect(survival_statues_text.contains("Filter: Survival"), "Statues page should show selected route summary")
	_expect(survival_statues_text.contains("Bulwark Idol"), "Survival statue filter should include Bulwark Idol")
	_expect(not survival_statues_text.contains("Cinder Focus"), "Survival statue filter should hide unrelated statues")
	_expect(str(lobby.call("get_codex_detail_title_text")) == "Bulwark Idol", "Statue detail card should follow survival route filter")
	lobby.call("reset_codex_refinements_for_test")
	await get_tree().process_frame
	lobby.call("set_codex_search_for_test", "echo")
	await get_tree().process_frame
	var search_statues_text := str(hud.call("get_hall_summary_text"))
	_expect(search_statues_text.contains("Search \"echo\""), "Statues page should summarize active search query")
	_expect(str(lobby.call("get_codex_detail_title_text")) == "Echo Reservoir", "Statue detail card should follow active search")
	_expect(str(lobby.call("get_codex_detail_icon_key")) == "statue_echo_reservoir", "Statue detail icon key should follow active search")
	_expect(str(lobby.call("get_codex_detail_icon_texture_path")).ends_with("echo_reservoir.svg"), "Statue detail icon texture should follow active search")
	_expect(search_statues_text.contains("Echo Reservoir"), "Statue search should include matching statue")
	_expect(not search_statues_text.contains("Bulwark Idol"), "Statue search should hide non-matching statues")
	lobby.call("reset_codex_refinements_for_test")
	await get_tree().process_frame

	lobby.call("request_back_for_test")
	await get_tree().process_frame
	_expect(not bool(hud.call("is_hall_visible")), "Lobby back action should hide LobbyScreen")
	_expect(bool(hud.call("is_main_menu_visible")), "Lobby back action should return to main menu")

	main.call("open_hall_menu")
	await get_tree().process_frame
	lobby.call("request_next_character_for_test")
	lobby.call("request_next_character_for_test")
	lobby.call("request_next_character_for_test")
	await get_tree().process_frame
	_expect(str(hud.call("get_lobby_current_character_text")).contains("Rift Runner"), "Lobby next action should select Rift Runner")
	_expect(str(lobby.call("get_current_character_icon_key")) == "character_rift_runner", "Lobby next action should update the current character icon key")
	_expect(str(lobby.call("get_current_character_icon_texture_path")).ends_with("rift_runner.svg"), "Lobby next action should update the current character icon texture")
	_expect(bool(lobby.call("is_current_character_icon_texture_visible")), "Rift Runner character icon texture should be visible")
	_expect(str(hud.call("get_lobby_selected_status_text")).contains("Locked - 10 Data Shards"), "Lobby should show selected locked character cost")
	_expect(bool(lobby.call("is_start_button_disabled")), "Lobby start action should disable for locked character")
	_expect(bool(lobby.call("is_training_button_disabled")), "Lobby training action should disable for locked character")
	_expect(str(hud.call("get_lobby_unlock_button_text")).contains("Unlock 10"), "Lobby should show selected character unlock cost")
	_expect(bool(hud.call("is_lobby_unlock_button_disabled")), "Lobby unlock action should be disabled without currency")
	lobby.call("request_back_for_test")
	await get_tree().process_frame

	main.call("select_next_character")
	await get_tree().process_frame
	main.call("open_hall_menu")
	await get_tree().process_frame
	lobby.call("request_settings_for_test")
	await get_tree().process_frame
	_expect(not bool(hud.call("is_hall_visible")), "Lobby settings action should leave LobbyScreen")
	_expect(bool(hud.call("is_settings_visible")), "Lobby settings action should open settings")
	main.call("close_settings_menu")
	await get_tree().process_frame

	for _character_index in range(6):
		if str(main.call("get_character_selection_summary").get("display_name", "")) == "Wanderer":
			break
		main.call("select_next_character")
		await get_tree().process_frame
	main.call("open_hall_menu")
	await get_tree().process_frame
	var training_progress_summary: Dictionary = main.call("get_hall_summary")
	var progress_characters: Array = training_progress_summary.get("characters", [])
	for character_index in range(progress_characters.size()):
		if not progress_characters[character_index] is Dictionary:
			continue
		var character: Dictionary = progress_characters[character_index]
		character["unlocked"] = true
		character["next_mastery_level"] = 0
		character["next_mastery_progress_percent"] = 100
		progress_characters[character_index] = character
	training_progress_summary["characters"] = progress_characters
	var progress_meta: Dictionary = training_progress_summary.get("meta_progression", {})
	progress_meta["training_badge_count"] = 4
	progress_meta["training_badge_total"] = 4
	training_progress_summary["meta_progression"] = progress_meta
	var progress_training_drills: Array = training_progress_summary.get("training_drills", [])
	for drill_index in range(progress_training_drills.size()):
		if not progress_training_drills[drill_index] is Dictionary:
			continue
		var completed_drill: Dictionary = progress_training_drills[drill_index]
		completed_drill["badge_unlocked"] = true
		completed_drill["best_rating_rank"] = "clean"
		completed_drill["best_rating_text"] = "Clean"
		completed_drill["best_rating_token"] = "[CN]"
		progress_training_drills[drill_index] = completed_drill
	training_progress_summary["training_drills"] = progress_training_drills
	lobby.call("show_summary", training_progress_summary)
	await get_tree().process_frame
	var completed_objective_board := str(hud.call("get_lobby_objective_board_text"))
	_expect(completed_objective_board == "Objectives: Start a run and test a new build", "Lobby objective board should fall back to run guidance when all meta goals are complete")
	_expect(not completed_objective_board.contains("complete"), "Lobby objective board should not list completed meta goals as active objectives")
	_expect(not completed_objective_board.contains("maxed"), "Lobby objective board should not list maxed mastery as an active objective")
	_expect(bool(lobby.call("is_objective_board_action_row_visible")), "Lobby objective action row should show a start action when all meta goals are complete")
	_expect(bool(lobby.call("is_objective_start_run_button_visible")), "Lobby objective start action should show when run guidance is the active objective")
	_expect(str(lobby.call("get_objective_start_run_button_text")) == "Start", "Lobby objective start action should use compact text")
	var completed_start_tooltip := str(lobby.call("get_objective_start_run_button_tooltip_text"))
	_expect(completed_start_tooltip.contains("Start a run"), "Lobby objective start action should preview run entry")
	_expect(completed_start_tooltip.contains("Wanderer"), "Lobby objective start action should name the selected character")
	var rift_runner_index := -1
	for character_index in range(progress_characters.size()):
		if progress_characters[character_index] is Dictionary and str(progress_characters[character_index].get("display_name", "")) == "Rift Runner":
			rift_runner_index = character_index
			break
	_expect(rift_runner_index >= 0, "Complete-state tooltip regression needs Rift Runner in the roster")
	if rift_runner_index >= 0:
		lobby.call("update_character_selection", "Rift Runner", "Phase specialist", "Phase Step", "Dash through danger", rift_runner_index, progress_characters.size())
		lobby.call("update_character_unlock_status", true, 0, 0)
		await get_tree().process_frame
		_expect(str(lobby.call("get_objective_start_run_button_tooltip_text")).contains("Rift Runner"), "Lobby objective start action should refresh when the selected character changes")
	_expect(not bool(lobby.call("is_objective_counter_button_visible")), "Lobby objective counter action should stay hidden on complete-state run guidance")
	_expect(not bool(lobby.call("is_objective_progress_visible")), "Lobby objective progress should hide when unlock, mastery, and training goals are complete")
	_expect(not bool(lobby.call("is_objective_progress_action_button_visible")), "Lobby objective progress action should hide when no meta objective remains")

	progress_meta["training_badge_count"] = 1
	training_progress_summary["meta_progression"] = progress_meta
	for drill_index in range(progress_training_drills.size()):
		if not progress_training_drills[drill_index] is Dictionary:
			continue
		var drill: Dictionary = progress_training_drills[drill_index]
		drill["badge_unlocked"] = drill_index == 0
		drill["best_rating_rank"] = "clean" if drill_index == 0 else ""
		drill["best_rating_text"] = "Clean" if drill_index == 0 else "None"
		drill["best_rating_token"] = "[CN]" if drill_index == 0 else "[--]"
		progress_training_drills[drill_index] = drill
	training_progress_summary["training_drills"] = progress_training_drills
	lobby.call("show_summary", training_progress_summary)
	await get_tree().process_frame
	_expect(not bool(lobby.call("is_objective_board_action_row_visible")), "Lobby objective action row should hide again when training progress is the active objective")
	_expect(not bool(lobby.call("is_objective_start_run_button_visible")), "Lobby objective start action should hide when a training objective is active")
	_expect(str(hud.call("get_lobby_objective_progress_text")) == "Training: Movement", "Lobby objective progress should show the next missing training drill without hover")
	_expect(str(hud.call("get_lobby_objective_progress_value_text")) == "1/4 badges", "Lobby objective training progress should show badge value without hover")
	_expect(str(lobby.call("get_objective_progress_action_button_text")) == "Train", "Lobby objective training progress should expose a training action")
	_expect(str(lobby.call("get_objective_progress_action_button_tooltip_text")).contains("Movement"), "Lobby objective training progress action should preview the next missing drill")
	_expect(bool(lobby.call("request_objective_progress_action_for_test")), "Lobby objective training progress action should enter training")
	await get_tree().process_frame
	_expect(str(main.call("get_run_state_name")) == "Training", "Lobby objective training action should enter training room")
	_expect(str(hud.call("get_training_drill_text")) == "Movement", "Lobby objective training action should target the next missing drill")
	_expect(not bool(hud.call("is_hall_visible")), "Lobby should hide after entering training from objective progress")

	get_tree().paused = false
	main.queue_free()
	await get_tree().process_frame

	var progress_main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(progress_main)
	await get_tree().process_frame
	progress_main.call("start_new_run")
	await get_tree().process_frame
	var progress_player := progress_main.get_node_or_null("Player") as Player
	if progress_player != null:
		progress_player.add_gold(50)
	Events.run_completed.emit()
	await get_tree().process_frame
	get_tree().paused = false
	progress_main.queue_free()
	await get_tree().process_frame

	var unlock_main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(unlock_main)
	await get_tree().process_frame
	var unlock_hud = unlock_main.get_node_or_null("CanvasLayer/HUD")
	var unlock_lobby = unlock_hud.get_node_or_null("LobbyScreen") if unlock_hud != null else null
	unlock_main.call("open_hall_menu")
	await get_tree().process_frame
	if _is_lobby_screen(unlock_lobby):
		unlock_lobby.call("request_next_character_for_test")
		unlock_lobby.call("request_next_character_for_test")
		unlock_lobby.call("request_next_character_for_test")
	await get_tree().process_frame
	_expect(unlock_hud != null and not bool(unlock_hud.call("is_lobby_unlock_button_disabled")), "Lobby unlock action should enable with enough currency")
	if _is_lobby_screen(unlock_lobby):
		unlock_lobby.call("request_unlock_for_test")
	await get_tree().process_frame
	_expect(unlock_hud != null and str(unlock_hud.call("get_lobby_unlock_button_text")) == "Unlocked", "Lobby unlock action should mark character unlocked")
	_expect(unlock_hud != null and str(unlock_hud.call("get_lobby_selected_status_text")).contains("Ready"), "Unlocked character should become ready in lobby")
	_expect(unlock_hud != null and str(unlock_hud.call("get_hall_summary_text")).contains("Rift Runner | Unlocked"), "Lobby archive should refresh after unlocking Rift Runner")
	get_tree().paused = false
	unlock_main.queue_free()
	await get_tree().process_frame

	_delete_settings_file()
	for _index in range(4):
		var mastery_main := MAIN_SCENE.instantiate()
		get_tree().root.add_child(mastery_main)
		await get_tree().process_frame
		mastery_main.call("start_new_run")
		await get_tree().process_frame
		Events.run_completed.emit()
		await get_tree().process_frame
		get_tree().paused = false
		mastery_main.queue_free()
		await get_tree().process_frame

	var maxed_main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(maxed_main)
	await get_tree().process_frame
	var maxed_hud = maxed_main.get_node_or_null("CanvasLayer/HUD")
	var maxed_lobby = maxed_hud.get_node_or_null("LobbyScreen") if maxed_hud != null else null
	maxed_main.call("open_hall_menu")
	await get_tree().process_frame
	if _is_lobby_screen(maxed_lobby):
		maxed_lobby.call("select_tab_for_test", "characters")
	await get_tree().process_frame
	var maxed_text := str(maxed_hud.call("get_hall_summary_text")) if maxed_hud != null else ""
	_expect(maxed_text.contains("Wanderer | Unlocked | Mastery L3"), "Maxed mastery check should reach Wanderer L3")
	_expect(maxed_text.contains("Mastery Progress: Maxed"), "Characters page should show maxed mastery progress")
	_expect(maxed_text.contains("Mastery Rewards: Current +1 Armor, +1 Energy | Next Maxed") or maxed_text.contains("Mastery Rewards: Current +1 Energy, +1 Armor | Next Maxed"), "Characters page should show maxed reward state")
	_expect(maxed_text.contains("Next Mastery: Maxed"), "Characters page should show maxed next mastery state")
	get_tree().paused = false
	maxed_main.queue_free()
	await get_tree().process_frame

	var run_main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(run_main)
	await get_tree().process_frame
	var run_hud = run_main.get_node_or_null("CanvasLayer/HUD")
	var run_lobby = run_hud.get_node_or_null("LobbyScreen") if run_hud != null else null
	run_main.call("open_hall_menu")
	await get_tree().process_frame
	if _is_lobby_screen(run_lobby):
		run_lobby.call("request_start_for_test")
	await get_tree().process_frame
	_expect(str(run_main.call("get_run_state_name")) == "Running", "Lobby start action should enter a run")
	_expect(run_hud != null and not bool(run_hud.call("is_hall_visible")), "Lobby should hide after starting a run")

	get_tree().paused = false
	run_main.queue_free()
	await get_tree().process_frame

	var objective_start_main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(objective_start_main)
	await get_tree().process_frame
	var objective_start_hud = objective_start_main.get_node_or_null("CanvasLayer/HUD")
	var objective_start_lobby = objective_start_hud.get_node_or_null("LobbyScreen") if objective_start_hud != null else null
	objective_start_main.call("open_hall_menu")
	await get_tree().process_frame
	if _is_lobby_screen(objective_start_lobby):
		var objective_start_summary: Dictionary = objective_start_main.call("get_hall_summary")
		var objective_start_characters: Array = objective_start_summary.get("characters", [])
		for character_index in range(objective_start_characters.size()):
			if not objective_start_characters[character_index] is Dictionary:
				continue
			var objective_start_character: Dictionary = objective_start_characters[character_index]
			objective_start_character["unlocked"] = true
			objective_start_character["next_mastery_level"] = 0
			objective_start_character["next_mastery_xp_remaining"] = 0
			objective_start_character["next_mastery_progress_percent"] = 100
			objective_start_characters[character_index] = objective_start_character
		objective_start_summary["characters"] = objective_start_characters
		var objective_start_meta: Dictionary = objective_start_summary.get("meta_progression", {})
		objective_start_meta["training_badge_count"] = 4
		objective_start_meta["training_badge_total"] = 4
		objective_start_summary["meta_progression"] = objective_start_meta
		var objective_start_drills: Array = objective_start_summary.get("training_drills", [])
		for drill_index in range(objective_start_drills.size()):
			if not objective_start_drills[drill_index] is Dictionary:
				continue
			var objective_start_drill: Dictionary = objective_start_drills[drill_index]
			objective_start_drill["badge_unlocked"] = true
			objective_start_drill["best_rating_rank"] = "clean"
			objective_start_drill["best_rating_text"] = "Clean"
			objective_start_drill["best_rating_token"] = "[CN]"
			objective_start_drills[drill_index] = objective_start_drill
		objective_start_summary["training_drills"] = objective_start_drills
		objective_start_lobby.call("show_summary", objective_start_summary)
		await get_tree().process_frame
		_expect(bool(objective_start_lobby.call("is_objective_start_run_button_visible")), "Objective start action should be visible before activation")
		_expect(str(objective_start_lobby.call("get_objective_start_run_button_tooltip_text")).contains("Wanderer"), "Objective start action tooltip should name the current character before activation")
		objective_start_lobby.call("request_objective_start_run_for_test")
	await get_tree().process_frame
	_expect(str(objective_start_main.call("get_run_state_name")) == "Running", "Objective start action should enter a run")
	_expect(objective_start_hud != null and not bool(objective_start_hud.call("is_hall_visible")), "Lobby should hide after objective start action")

	get_tree().paused = false
	objective_start_main.queue_free()
	await get_tree().process_frame
	_delete_settings_file()
	_finish()


func _delete_settings_file() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var dir := DirAccess.open("user://")
	if dir != null:
		dir.remove(SETTINGS_FILE)


func _is_lobby_screen(node) -> bool:
	return node != null and node.has_method("show_summary") and node.has_method("request_start_for_test")


func _has_counter_type_token(text: String) -> bool:
	for token in [" W", " R", " T", " B", " S"]:
		if text.contains(token):
			return true
	return false


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	get_tree().paused = false
	if _failures.is_empty():
		print("LobbyScreenSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

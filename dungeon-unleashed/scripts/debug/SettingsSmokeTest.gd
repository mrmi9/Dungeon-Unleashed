extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
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
	_expect(main.has_method("get_settings_summary"), "Main should expose settings summary")
	if hud == null or not main.has_method("get_settings_summary"):
		_finish()
		return

	var summary: Dictionary = main.call("get_settings_summary")
	_expect(is_equal_approx(float(summary.get("master_volume", -1.0)), 1.0), "Default master volume should be 1.0")
	_expect(is_equal_approx(float(summary.get("sfx_volume", -1.0)), 1.0), "Default SFX volume should be 1.0")
	_expect(is_equal_approx(float(summary.get("music_volume", -1.0)), 0.8), "Default music volume should be 0.8")
	_expect(summary.get("fullscreen", true) != true, "Default fullscreen should be false")
	_expect(int(summary.get("resolution_width", 0)) == 1280, "Default resolution width should be 1280")
	_expect(int(summary.get("resolution_height", 0)) == 720, "Default resolution height should be 720")
	_expect(summary.get("aim_assist_enabled", true) != true, "Default aim assist should be false")
	_expect(is_equal_approx(float(summary.get("aim_assist_strength", -1.0)), 0.35), "Default aim assist strength should be 0.35")
	_expect(str(summary.get("aim_assist_strength_band", "")) == "Off", "Default aim assist strength band should be Off")
	_expect(is_equal_approx(float(summary.get("low_health_feedback_intensity", -1.0)), 1.0), "Default low-health feedback intensity should be 1.0")
	_expect(is_equal_approx(float(summary.get("screen_shake_intensity", -1.0)), 1.0), "Default screen shake intensity should be 1.0")
	_expect(is_equal_approx(float(summary.get("damage_flash_intensity", -1.0)), 1.0), "Default damage flash intensity should be 1.0")
	_expect(is_equal_approx(float(summary.get("combat_text_intensity", -1.0)), 1.0), "Default combat text intensity should be 1.0")
	_expect(is_equal_approx(float(summary.get("controller_aim_deadzone", -1.0)), 0.22), "Default controller aim deadzone should be 0.22")
	_expect(is_equal_approx(float(summary.get("controller_input_switch_threshold", -1.0)), 0.45), "Default controller input switch threshold should be 0.45")
	var default_input_bindings: Dictionary = summary.get("input_bindings", {})
	_expect(not default_input_bindings.has("aim_left"), "Right-stick aim should stay outside keyboard rebind settings")
	_expect(_action_has_joy_axis("move_left", JOY_AXIS_LEFT_X, -1.0), "InputMap should bind left-stick left movement")
	_expect(_action_has_joy_axis("move_right", JOY_AXIS_LEFT_X, 1.0), "InputMap should bind left-stick right movement")
	_expect(_action_has_joy_axis("move_up", JOY_AXIS_LEFT_Y, -1.0), "InputMap should bind left-stick up movement")
	_expect(_action_has_joy_axis("move_down", JOY_AXIS_LEFT_Y, 1.0), "InputMap should bind left-stick down movement")
	_expect(_action_has_joy_axis("shoot", JOY_AXIS_TRIGGER_RIGHT, 1.0), "InputMap should bind right trigger shooting")
	_expect(_action_has_joy_button("shoot", JOY_BUTTON_RIGHT_SHOULDER), "InputMap should bind right shoulder shooting fallback")
	_expect(_action_has_joy_button("reload", JOY_BUTTON_X), "InputMap should bind gamepad reload")
	_expect(_action_has_joy_button("skill", JOY_BUTTON_A), "InputMap should bind gamepad skill")
	_expect(_action_has_joy_button("interact", JOY_BUTTON_Y), "InputMap should bind gamepad interact")
	_expect(_action_has_joy_button("pause", JOY_BUTTON_START), "InputMap should bind gamepad pause")
	_expect(_action_has_joy_button("weapon_slot_1", JOY_BUTTON_DPAD_LEFT), "InputMap should bind D-pad weapon slot 1")
	_expect(_action_has_joy_button("weapon_slot_2", JOY_BUTTON_DPAD_UP), "InputMap should bind D-pad weapon slot 2")
	_expect(_action_has_joy_button("weapon_slot_3", JOY_BUTTON_DPAD_RIGHT), "InputMap should bind D-pad weapon slot 3")
	_expect(_action_has_joy_axis("aim_left", JOY_AXIS_RIGHT_X, -1.0), "InputMap should bind right-stick left aim")
	_expect(_action_has_joy_axis("aim_right", JOY_AXIS_RIGHT_X, 1.0), "InputMap should bind right-stick right aim")
	_expect(_action_has_joy_axis("aim_up", JOY_AXIS_RIGHT_Y, -1.0), "InputMap should bind right-stick up aim")
	_expect(_action_has_joy_axis("aim_down", JOY_AXIS_RIGHT_Y, 1.0), "InputMap should bind right-stick down aim")
	var controller_layout := str(hud.call("get_controller_layout_hint_for_test"))
	var controller_summary: Dictionary = summary.get("controller_layout", {})
	var controller_items: Array = controller_summary.get("items", [])
	var controller_tuning: Dictionary = controller_summary.get("tuning", {})
	_expect(str(controller_summary.get("scheme", "")) == "default_gamepad", "Settings summary should expose default gamepad layout scheme")
	_expect(str(controller_summary.get("hint", "")) == controller_layout, "Settings summary should expose the shared controller layout hint")
	_expect(controller_items.size() >= 8, "Settings summary should expose controller layout items")
	_expect(is_equal_approx(float(controller_tuning.get("aim_deadzone", -1.0)), 0.22), "Controller tuning should expose aim deadzone")
	_expect(is_equal_approx(float(controller_tuning.get("aim_target_distance", -1.0)), 900.0), "Controller tuning should expose aim target distance")
	_expect(is_equal_approx(float(controller_tuning.get("input_switch_threshold", -1.0)), 0.45), "Controller tuning should expose input switch threshold")
	_expect(is_equal_approx(float(controller_tuning.get("mouse_return_threshold", -1.0)), 2.0), "Controller tuning should expose mouse return threshold")
	_expect(_controller_layout_actions_are_bound(controller_items), "Controller layout actions should map to real gamepad InputMap events")
	_expect(controller_layout.contains("Move LS"), "Controller layout should include left-stick movement")
	_expect(controller_layout.contains("Aim RS"), "Controller layout should include right-stick aiming")
	_expect(controller_layout.contains("Shoot RT/RB"), "Controller layout should include trigger and shoulder shooting")
	_expect(controller_layout.contains("Weapons D-Pad"), "Controller layout should include D-pad weapon switching")
	_expect(str(hud.call("get_input_hint_device_for_test")) == "keyboard_mouse", "Input hint should default to keyboard/mouse")
	_expect(str(hud.call("get_input_hint_text")).contains("Move W/A/S/D"), "Keyboard input hint should show movement keys")
	_expect(str(hud.call("get_input_hint_text")).contains("Aim Mouse"), "Keyboard input hint should show mouse aiming")
	_expect(str(hud.call("get_input_hint_text")).contains("Shoot LMB"), "Keyboard input hint should show mouse shooting")
	var quiet_gamepad_motion := InputEventJoypadMotion.new()
	quiet_gamepad_motion.axis = JOY_AXIS_LEFT_X
	quiet_gamepad_motion.axis_value = maxf(float(controller_tuning.get("input_switch_threshold", 0.45)) - 0.05, 0.0)
	hud.call("simulate_input_hint_event_for_test", quiet_gamepad_motion)
	_expect(str(hud.call("get_input_hint_device_for_test")) == "keyboard_mouse", "Gamepad drift below the configured threshold should not switch hint mode")
	hud.call("set_input_hint_device_for_test", "gamepad")
	_expect(str(hud.call("get_input_hint_device_for_test")) == "gamepad", "Input hint should switch to gamepad mode")
	_expect(str(hud.call("get_input_hint_text")) == controller_layout, "Gamepad input hint should use the shared controller layout")
	_expect(str(hud.call("get_input_hint_text")).contains("Move LS"), "Gamepad input hint should show left-stick movement")
	_expect(str(hud.call("get_input_hint_text")).contains("Aim RS"), "Gamepad input hint should show right-stick aiming")
	_expect(str(hud.call("get_input_hint_text")).contains("Shoot RT/RB"), "Gamepad input hint should show trigger and shoulder shooting")
	_expect(str(hud.call("get_input_hint_text")).contains("Weapons D-Pad"), "Gamepad input hint should show D-pad weapon switching")
	var quiet_mouse_motion := InputEventMouseMotion.new()
	quiet_mouse_motion.relative = Vector2(float(controller_tuning.get("mouse_return_threshold", 2.0)) - 0.25, 0.0)
	hud.call("simulate_input_hint_event_for_test", quiet_mouse_motion)
	_expect(str(hud.call("get_input_hint_device_for_test")) == "gamepad", "Mouse motion below the configured threshold should not switch hint mode")
	var mouse_motion := InputEventMouseMotion.new()
	mouse_motion.relative = Vector2(float(controller_tuning.get("mouse_return_threshold", 2.0)) + 0.5, 0.0)
	hud.call("simulate_input_hint_event_for_test", mouse_motion)
	_expect(str(hud.call("get_input_hint_device_for_test")) == "keyboard_mouse", "Input hint should switch back to keyboard/mouse mode")
	var active_gamepad_motion := InputEventJoypadMotion.new()
	active_gamepad_motion.axis = JOY_AXIS_LEFT_X
	active_gamepad_motion.axis_value = minf(float(controller_tuning.get("input_switch_threshold", 0.45)) + 0.1, 1.0)
	hud.call("simulate_input_hint_event_for_test", active_gamepad_motion)
	_expect(str(hud.call("get_input_hint_device_for_test")) == "gamepad", "Gamepad motion above the configured threshold should switch hint mode")
	hud.call("set_input_hint_device_for_test", "keyboard_mouse")
	var gamepad_button := InputEventJoypadButton.new()
	gamepad_button.button_index = JOY_BUTTON_A
	gamepad_button.pressed = true
	hud.call("simulate_input_hint_event_for_test", gamepad_button)
	_expect(str(hud.call("get_input_hint_device_for_test")) == "gamepad", "Gamepad button input should switch hint mode")
	hud.call("set_input_hint_device_for_test", "keyboard_mouse")

	main.call("open_settings_menu")
	await get_tree().process_frame
	_expect(bool(hud.call("is_settings_visible")), "Settings panel should open from main menu")
	_expect(str(hud.call("get_settings_controller_layout_text_for_test")) == controller_layout, "Settings panel should show the shared controller layout")
	_expect(is_equal_approx(float(hud.call("get_settings_controller_aim_deadzone")), 0.22), "Settings panel should show default controller aim deadzone")
	_expect(is_equal_approx(float(hud.call("get_settings_controller_input_switch_threshold")), 0.45), "Settings panel should show default controller input switch threshold")
	_expect(str(hud.call("get_settings_controller_aim_deadzone_text_for_test")).contains("22%"), "Settings panel should label default controller aim deadzone")
	_expect(str(hud.call("get_settings_controller_input_switch_text_for_test")).contains("45%"), "Settings panel should label default controller input switch threshold")
	_expect(str(hud.call("get_settings_aim_assist_band_text")).contains("Aim Assist Band: Off"), "Settings panel should show default aim assist band")
	_expect(str(hud.call("get_settings_aim_assist_active_preset_text")) == "Off", "Settings panel should highlight the default aim assist preset")

	hud.call("choose_settings_aim_assist_preset_for_test", "strong")
	_expect(hud.call("get_settings_aim_assist_enabled") == true, "Strong preset should enable aim assist")
	_expect(is_equal_approx(float(hud.call("get_settings_aim_assist_strength")), 0.8), "Strong preset should set aim assist strength")
	_expect(str(hud.call("get_settings_aim_assist_band_text")).contains("Aim Assist Band: Strong"), "Strong preset should preview strong aim assist band")
	_expect(str(hud.call("get_settings_aim_assist_active_preset_text")) == "Strong", "Strong preset should highlight the matching preset button")

	hud.call("set_settings_for_test", 0.35, 0.45, 0.55, true, 2, true, 0.6, 0.4, 0.25, 0.3, 0.2, 0.33, 0.52)
	_expect(str(hud.call("get_settings_aim_assist_band_text")).contains("Aim Assist Band: Balanced"), "Settings panel should preview updated aim assist band")
	_expect(str(hud.call("get_settings_aim_assist_active_preset_text")) == "Balanced", "Settings panel should highlight the balanced preset")
	_expect(is_equal_approx(float(hud.call("get_settings_controller_aim_deadzone")), 0.33), "Settings panel should preview controller aim deadzone")
	_expect(is_equal_approx(float(hud.call("get_settings_controller_input_switch_threshold")), 0.52), "Settings panel should preview controller input switch threshold")
	main.call(
		"apply_settings",
		float(hud.call("get_settings_volume_value")),
		float(hud.call("get_settings_sfx_volume_value")),
		float(hud.call("get_settings_music_volume_value")),
		hud.call("get_settings_fullscreen_enabled") == true,
		int(hud.call("get_settings_resolution_index")),
		hud.call("get_settings_aim_assist_enabled") == true,
		float(hud.call("get_settings_aim_assist_strength")),
		float(hud.call("get_settings_low_health_feedback_intensity")),
		float(hud.call("get_settings_screen_shake_intensity")),
		float(hud.call("get_settings_damage_flash_intensity")),
		float(hud.call("get_settings_combat_text_intensity")),
		float(hud.call("get_settings_controller_aim_deadzone")),
		float(hud.call("get_settings_controller_input_switch_threshold"))
	)
	await get_tree().process_frame

	summary = main.call("get_settings_summary")
	_expect(is_equal_approx(float(summary.get("master_volume", -1.0)), 0.35), "Applied master volume should be stored in Main")
	_expect(is_equal_approx(float(summary.get("sfx_volume", -1.0)), 0.45), "Applied SFX volume should be stored in Main")
	_expect(is_equal_approx(float(summary.get("music_volume", -1.0)), 0.55), "Applied music volume should be stored in Main")
	_expect(summary.get("fullscreen", false) == true, "Applied fullscreen should be stored in Main")
	_expect(int(summary.get("resolution_width", 0)) == 1920, "Applied resolution width should be stored in Main")
	_expect(int(summary.get("resolution_height", 0)) == 1080, "Applied resolution height should be stored in Main")
	_expect(summary.get("aim_assist_enabled", false) == true, "Applied aim assist should be stored in Main")
	_expect(is_equal_approx(float(summary.get("aim_assist_strength", -1.0)), 0.6), "Applied aim assist strength should be stored in Main")
	_expect(str(summary.get("aim_assist_strength_band", "")) == "Balanced", "Applied aim assist strength band should be stored in Main")
	_expect(is_equal_approx(float(summary.get("low_health_feedback_intensity", -1.0)), 0.4), "Applied low-health feedback intensity should be stored in Main")
	_expect(is_equal_approx(float(summary.get("screen_shake_intensity", -1.0)), 0.25), "Applied screen shake intensity should be stored in Main")
	_expect(is_equal_approx(float(summary.get("damage_flash_intensity", -1.0)), 0.3), "Applied damage flash intensity should be stored in Main")
	_expect(is_equal_approx(float(summary.get("combat_text_intensity", -1.0)), 0.2), "Applied combat text intensity should be stored in Main")
	_expect(is_equal_approx(float(summary.get("controller_aim_deadzone", -1.0)), 0.33), "Applied controller aim deadzone should be stored in Main")
	_expect(is_equal_approx(float(summary.get("controller_input_switch_threshold", -1.0)), 0.52), "Applied controller input switch threshold should be stored in Main")
	controller_summary = summary.get("controller_layout", {})
	controller_tuning = controller_summary.get("tuning", {})
	_expect(is_equal_approx(float(controller_tuning.get("aim_deadzone", -1.0)), 0.33), "Applied settings summary should expose overridden controller aim deadzone")
	_expect(is_equal_approx(float(controller_tuning.get("input_switch_threshold", -1.0)), 0.52), "Applied settings summary should expose overridden controller input switch threshold")
	var player = main.get_node_or_null("Player")
	if player != null:
		_expect(player.call("is_aim_assist_enabled") == true, "Player should receive enabled aim assist setting")
		_expect(is_equal_approx(float(player.call("get_aim_assist_strength")), 0.6), "Player should receive aim assist strength")
		if player.has_method("get_controller_aim_deadzone_for_test"):
			_expect(is_equal_approx(float(player.call("get_controller_aim_deadzone_for_test")), float(controller_tuning.get("aim_deadzone", -1.0))), "Player should use the controller tuning aim deadzone")
		if player.has_method("get_controller_aim_target_distance_for_test"):
			_expect(is_equal_approx(float(player.call("get_controller_aim_target_distance_for_test")), float(controller_tuning.get("aim_target_distance", -1.0))), "Player should use the controller tuning aim target distance")
		Input.action_press("aim_right")
		Input.action_press("aim_down")
		await get_tree().process_frame
		if player.has_method("get_controller_aim_vector_for_test"):
			var controller_aim: Vector2 = player.call("get_controller_aim_vector_for_test")
			_expect(controller_aim.x > 0.6 and controller_aim.y > 0.6, "Player should read right-stick aim actions as a normalized aim vector")
		Input.action_release("aim_right")
		Input.action_release("aim_down")
		if player.has_method("get_aim_assist_candidate_groups_for_test"):
			var aim_groups: PackedStringArray = player.call("get_aim_assist_candidate_groups_for_test")
			_expect(aim_groups.has("enemies"), "Player should keep enemy aim-assist targets outside training")
			_expect(not aim_groups.has("training_dummy"), "Player should not use training targets outside training")
	var audio_feedback = main.get_node_or_null("AudioFeedback")
	if audio_feedback != null and audio_feedback.has_method("get_low_health_feedback_intensity_for_test"):
		_expect(is_equal_approx(float(audio_feedback.call("get_low_health_feedback_intensity_for_test")), 0.4), "Audio feedback should receive low-health feedback intensity")
	if hud.has_method("get_low_health_feedback_intensity_for_test"):
		_expect(is_equal_approx(float(hud.call("get_low_health_feedback_intensity_for_test")), 0.4), "HUD should receive low-health feedback intensity")
	if main.has_method("get_screen_shake_intensity_for_test"):
		_expect(is_equal_approx(float(main.call("get_screen_shake_intensity_for_test")), 0.25), "Main should apply screen shake intensity")
	if main.has_method("get_combat_text_intensity_for_test"):
		_expect(is_equal_approx(float(main.call("get_combat_text_intensity_for_test")), 0.2), "Main should apply combat text intensity")
	if hud.has_method("get_damage_flash_intensity_for_test"):
		_expect(is_equal_approx(float(hud.call("get_damage_flash_intensity_for_test")), 0.3), "HUD should receive damage flash intensity")

	_expect(bool(main.call("rebind_input_action", "reload", KEY_T)), "Reload key should be rebindable")
	await get_tree().process_frame
	summary = main.call("get_settings_summary")
	var input_bindings: Dictionary = summary.get("input_bindings", {})
	var reload_binding: Dictionary = input_bindings.get("reload", {})
	_expect(int(reload_binding.get("keycode", 0)) == KEY_T, "Settings summary should expose rebound reload key")
	_expect(_action_has_physical_key("reload", KEY_T), "InputMap should use rebound reload key")
	_expect(not _action_has_physical_key("reload", KEY_R), "InputMap should remove old reload key")
	_expect(str(hud.call("get_control_rebind_button_text", "reload")).contains("T"), "Settings UI should show rebound reload key")
	_expect(str(hud.call("get_input_hint_text")).contains("Reload T"), "Input hint should show rebound reload key")
	_expect(_settings_file_has(0.35, 0.45, 0.55, true, 1920, 1080, true, 0.6, 0.4, 0.25, 0.3, 0.2, 0.33, 0.52, KEY_T), "Settings file should persist applied values, controller tuning, and rebound controls")

	get_tree().paused = false
	main.queue_free()
	await get_tree().process_frame

	var reloaded_main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(reloaded_main)
	await get_tree().process_frame
	var reloaded_hud = reloaded_main.get_node_or_null("CanvasLayer/HUD")
	var reloaded_summary: Dictionary = reloaded_main.call("get_settings_summary")
	_expect(is_equal_approx(float(reloaded_summary.get("master_volume", -1.0)), 0.35), "Reloaded main should read saved master volume")
	_expect(is_equal_approx(float(reloaded_summary.get("sfx_volume", -1.0)), 0.45), "Reloaded main should read saved SFX volume")
	_expect(is_equal_approx(float(reloaded_summary.get("music_volume", -1.0)), 0.55), "Reloaded main should read saved music volume")
	_expect(reloaded_summary.get("fullscreen", false) == true, "Reloaded main should read saved fullscreen")
	_expect(int(reloaded_summary.get("resolution_width", 0)) == 1920, "Reloaded main should read saved resolution width")
	_expect(int(reloaded_summary.get("resolution_height", 0)) == 1080, "Reloaded main should read saved resolution height")
	_expect(reloaded_summary.get("aim_assist_enabled", false) == true, "Reloaded main should read saved aim assist")
	_expect(is_equal_approx(float(reloaded_summary.get("aim_assist_strength", -1.0)), 0.6), "Reloaded main should read saved aim assist strength")
	_expect(str(reloaded_summary.get("aim_assist_strength_band", "")) == "Balanced", "Reloaded main should read saved aim assist strength band")
	_expect(is_equal_approx(float(reloaded_summary.get("low_health_feedback_intensity", -1.0)), 0.4), "Reloaded main should read saved low-health feedback intensity")
	_expect(is_equal_approx(float(reloaded_summary.get("screen_shake_intensity", -1.0)), 0.25), "Reloaded main should read saved screen shake intensity")
	_expect(is_equal_approx(float(reloaded_summary.get("damage_flash_intensity", -1.0)), 0.3), "Reloaded main should read saved damage flash intensity")
	_expect(is_equal_approx(float(reloaded_summary.get("combat_text_intensity", -1.0)), 0.2), "Reloaded main should read saved combat text intensity")
	_expect(is_equal_approx(float(reloaded_summary.get("controller_aim_deadzone", -1.0)), 0.33), "Reloaded main should read saved controller aim deadzone")
	_expect(is_equal_approx(float(reloaded_summary.get("controller_input_switch_threshold", -1.0)), 0.52), "Reloaded main should read saved controller input switch threshold")
	var reloaded_controller_layout: Dictionary = reloaded_summary.get("controller_layout", {})
	var reloaded_controller_tuning: Dictionary = reloaded_controller_layout.get("tuning", {})
	_expect(is_equal_approx(float(reloaded_controller_tuning.get("aim_deadzone", -1.0)), 0.33), "Reloaded controller layout summary should expose saved aim deadzone")
	_expect(is_equal_approx(float(reloaded_controller_tuning.get("input_switch_threshold", -1.0)), 0.52), "Reloaded controller layout summary should expose saved input switch threshold")
	var reloaded_bindings: Dictionary = reloaded_summary.get("input_bindings", {})
	var reloaded_reload_binding: Dictionary = reloaded_bindings.get("reload", {})
	_expect(int(reloaded_reload_binding.get("keycode", 0)) == KEY_T, "Reloaded main should read saved reload key")
	_expect(_action_has_physical_key("reload", KEY_T), "Reloaded InputMap should use saved reload key")
	var reloaded_player = reloaded_main.get_node_or_null("Player")
	if reloaded_player != null:
		_expect(reloaded_player.call("is_aim_assist_enabled") == true, "Reloaded player should receive saved aim assist setting")
		_expect(is_equal_approx(float(reloaded_player.call("get_aim_assist_strength")), 0.6), "Reloaded player should receive saved aim assist strength")
		if reloaded_player.has_method("get_controller_aim_deadzone_for_test"):
			_expect(is_equal_approx(float(reloaded_player.call("get_controller_aim_deadzone_for_test")), 0.33), "Reloaded player should use saved controller aim deadzone")
	var reloaded_audio_feedback = reloaded_main.get_node_or_null("AudioFeedback")
	if reloaded_audio_feedback != null and reloaded_audio_feedback.has_method("get_low_health_feedback_intensity_for_test"):
		_expect(is_equal_approx(float(reloaded_audio_feedback.call("get_low_health_feedback_intensity_for_test")), 0.4), "Reloaded audio feedback should receive saved low-health feedback intensity")
	if reloaded_main.has_method("get_screen_shake_intensity_for_test"):
		_expect(is_equal_approx(float(reloaded_main.call("get_screen_shake_intensity_for_test")), 0.25), "Reloaded main should apply saved screen shake intensity")
	if reloaded_main.has_method("get_combat_text_intensity_for_test"):
		_expect(is_equal_approx(float(reloaded_main.call("get_combat_text_intensity_for_test")), 0.2), "Reloaded main should apply saved combat text intensity")
	if reloaded_hud != null and reloaded_hud.has_method("get_damage_flash_intensity_for_test"):
		_expect(is_equal_approx(float(reloaded_hud.call("get_damage_flash_intensity_for_test")), 0.3), "Reloaded HUD should receive saved damage flash intensity")
	if reloaded_hud != null:
		reloaded_main.call("open_settings_menu")
		await get_tree().process_frame
		_expect(is_equal_approx(float(reloaded_hud.call("get_settings_volume_value")), 0.35), "Settings UI should show saved master volume")
		_expect(is_equal_approx(float(reloaded_hud.call("get_settings_sfx_volume_value")), 0.45), "Settings UI should show saved SFX volume")
		_expect(is_equal_approx(float(reloaded_hud.call("get_settings_music_volume_value")), 0.55), "Settings UI should show saved music volume")
		_expect(reloaded_hud.call("get_settings_fullscreen_enabled") == true, "Settings UI should show saved fullscreen")
		_expect(int(reloaded_hud.call("get_settings_resolution_index")) == 2, "Settings UI should show saved resolution")
		_expect(reloaded_hud.call("get_settings_aim_assist_enabled") == true, "Settings UI should show saved aim assist")
		_expect(is_equal_approx(float(reloaded_hud.call("get_settings_aim_assist_strength")), 0.6), "Settings UI should show saved aim assist strength")
		_expect(str(reloaded_hud.call("get_settings_aim_assist_band_text")).contains("Aim Assist Band: Balanced"), "Settings UI should show saved aim assist strength band")
		_expect(str(reloaded_hud.call("get_settings_aim_assist_active_preset_text")) == "Balanced", "Settings UI should highlight saved aim assist preset")
		_expect(is_equal_approx(float(reloaded_hud.call("get_settings_low_health_feedback_intensity")), 0.4), "Settings UI should show saved low-health feedback intensity")
		_expect(is_equal_approx(float(reloaded_hud.call("get_settings_screen_shake_intensity")), 0.25), "Settings UI should show saved screen shake intensity")
		_expect(is_equal_approx(float(reloaded_hud.call("get_settings_damage_flash_intensity")), 0.3), "Settings UI should show saved damage flash intensity")
		_expect(is_equal_approx(float(reloaded_hud.call("get_settings_combat_text_intensity")), 0.2), "Settings UI should show saved combat text intensity")
		_expect(is_equal_approx(float(reloaded_hud.call("get_settings_controller_aim_deadzone")), 0.33), "Settings UI should show saved controller aim deadzone")
		_expect(is_equal_approx(float(reloaded_hud.call("get_settings_controller_input_switch_threshold")), 0.52), "Settings UI should show saved controller input switch threshold")
		_expect(str(reloaded_hud.call("get_control_rebind_button_text", "reload")).contains("T"), "Settings UI should show saved rebound reload key")

	get_tree().paused = false
	reloaded_main.queue_free()
	await get_tree().process_frame
	_delete_settings_file()
	_finish()


func _settings_file_has(expected_volume: float, expected_sfx_volume: float, expected_music_volume: float, expected_fullscreen: bool, expected_width: int, expected_height: int, expected_aim_assist_enabled: bool, expected_aim_assist_strength: float, expected_low_health_feedback_intensity: float, expected_screen_shake_intensity: float, expected_damage_flash_intensity: float, expected_combat_text_intensity: float, expected_controller_aim_deadzone: float, expected_controller_input_switch_threshold: float, expected_reload_key: int) -> bool:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return false
	var volume := float(config.get_value("audio", "master_volume", -1.0))
	var sfx_volume := float(config.get_value("audio", "sfx_volume", -1.0))
	var music_volume := float(config.get_value("audio", "music_volume", -1.0))
	var fullscreen: bool = config.get_value("display", "fullscreen", not expected_fullscreen) == true
	var width := int(config.get_value("display", "resolution_width", 0))
	var height := int(config.get_value("display", "resolution_height", 0))
	var aim_assist_enabled: bool = config.get_value("gameplay", "aim_assist_enabled", not expected_aim_assist_enabled) == true
	var aim_assist_strength := float(config.get_value("gameplay", "aim_assist_strength", -1.0))
	var low_health_feedback_intensity := float(config.get_value("gameplay", "low_health_feedback_intensity", -1.0))
	var screen_shake_intensity := float(config.get_value("gameplay", "screen_shake_intensity", -1.0))
	var damage_flash_intensity := float(config.get_value("gameplay", "damage_flash_intensity", -1.0))
	var combat_text_intensity := float(config.get_value("gameplay", "combat_text_intensity", -1.0))
	var controller_aim_deadzone := float(config.get_value("controls", "controller_aim_deadzone", -1.0))
	var controller_input_switch_threshold := float(config.get_value("controls", "controller_input_switch_threshold", -1.0))
	var reload_key := int(config.get_value("controls", "reload", 0))
	return (
		is_equal_approx(volume, expected_volume)
		and is_equal_approx(sfx_volume, expected_sfx_volume)
		and is_equal_approx(music_volume, expected_music_volume)
		and fullscreen == expected_fullscreen
		and width == expected_width
		and height == expected_height
		and aim_assist_enabled == expected_aim_assist_enabled
		and is_equal_approx(aim_assist_strength, expected_aim_assist_strength)
		and is_equal_approx(low_health_feedback_intensity, expected_low_health_feedback_intensity)
		and is_equal_approx(screen_shake_intensity, expected_screen_shake_intensity)
		and is_equal_approx(damage_flash_intensity, expected_damage_flash_intensity)
		and is_equal_approx(combat_text_intensity, expected_combat_text_intensity)
		and is_equal_approx(controller_aim_deadzone, expected_controller_aim_deadzone)
		and is_equal_approx(controller_input_switch_threshold, expected_controller_input_switch_threshold)
		and reload_key == expected_reload_key
	)


func _action_has_physical_key(action_name: String, expected_keycode: int) -> bool:
	for event in InputMap.action_get_events(StringName(action_name)):
		if event is InputEventKey and (event as InputEventKey).physical_keycode == expected_keycode:
			return true
	return false


func _action_has_joy_axis(action_name: String, expected_axis: JoyAxis, expected_axis_value: float) -> bool:
	for event in InputMap.action_get_events(StringName(action_name)):
		if event is InputEventJoypadMotion:
			var joy_event := event as InputEventJoypadMotion
			if joy_event.axis == expected_axis and joy_event.axis_value * expected_axis_value > 0.0:
				return true
	return false


func _action_has_joy_button(action_name: String, expected_button: JoyButton) -> bool:
	for event in InputMap.action_get_events(StringName(action_name)):
		if event is InputEventJoypadButton and (event as InputEventJoypadButton).button_index == expected_button:
			return true
	return false


func _controller_layout_actions_are_bound(items: Array) -> bool:
	for item in items:
		if not (item is Dictionary):
			return false
		var item_data: Dictionary = item
		var actions = item_data.get("actions", PackedStringArray())
		if not (actions is PackedStringArray) or (actions as PackedStringArray).is_empty():
			return false
		for action_name in actions:
			if not _action_has_joy_input(str(action_name)):
				return false
	return true


func _action_has_joy_input(action_name: String) -> bool:
	if not InputMap.has_action(StringName(action_name)):
		return false
	for event in InputMap.action_get_events(StringName(action_name)):
		if event is InputEventJoypadMotion or event is InputEventJoypadButton:
			return true
	return false


func _delete_settings_file() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var dir := DirAccess.open("user://")
	if dir != null:
		dir.remove(SETTINGS_FILE)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	get_tree().paused = false
	if _failures.is_empty():
		print("SettingsSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

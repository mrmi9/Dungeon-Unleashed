extends Node
class_name AudioFeedback

const SFX_BUS := "SFX"
const MUSIC_BUS := "Music"
const LOW_HEALTH_FEEDBACK := preload("res://scripts/core/LowHealthFeedback.gd")
const SFX_LIBRARY := preload("res://scripts/audio/SfxLibrary.gd")
const MUSIC_LIBRARY := preload("res://scripts/audio/MusicLibrary.gd")
const SAMPLE_RATE := 22050.0
const MAX_ACTIVE_SFX := 16
const MUSIC_CROSSFADE_DURATION := 0.45
const DANGER_WARNING_SFX_COOLDOWN := 0.18
const ENEMY_ACTION_WINDUP_SFX_COOLDOWN := 0.12
const DANGER_WARNING_HEAVY_DAMAGE_THRESHOLD := 3
const DANGER_WARNING_HEAVY_DURATION_THRESHOLD := 0.8
const LOW_HEALTH_HEARTBEAT_INTERVAL := 0.72
const LOW_HEALTH_HEARTBEAT_CRITICAL_INTERVAL := 0.42

var _rng := RandomNumberGenerator.new()
var _active_sfx: Array[Dictionary] = []
var _sfx_player_pool: Array[AudioStreamPlayer] = []
var _available_sfx_players: Array[AudioStreamPlayer] = []
var _sfx_player_creation_count := 0
var _authored_sfx_streams := {}
var _sfx_play_count := 0
var _sfx_play_counts_by_id := {}
var _procedural_fallback_count := 0
var _music_streams := {}
var _music_players: Array[AudioStreamPlayer] = []
var _active_music_player_index := -1
var _music_fade_from_index := -1
var _music_crossfade_elapsed := 0.0
var _music_mode := "menu"
var _music_source := ""
var _last_music_track_id := ""
var _missing_music_count := 0
var _suppress_playback := false
var _last_sfx_id := ""
var _last_sfx_source := ""
var _last_resolved_sample_id := ""
var _danger_warning_sfx_cooldown := 0.0
var _enemy_action_windup_sfx_cooldown := 0.0
var _low_health_heartbeat_active := false
var _low_health_heartbeat_timer := 0.0
var _low_health_heartbeat_interval := LOW_HEALTH_HEARTBEAT_INTERVAL
var _low_health_feedback_intensity := LOW_HEALTH_FEEDBACK.DEFAULT_FEEDBACK_INTENSITY


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("audio_feedback")
	_rng.randomize()
	_suppress_playback = DisplayServer.get_name() == "headless"
	_ensure_audio_bus(SFX_BUS)
	_ensure_audio_bus(MUSIC_BUS)
	_load_authored_sfx()
	_load_authored_music()
	_ensure_sfx_player_pool()
	_connect_events()
	start_music("menu")


func _process(delta: float) -> void:
	if _danger_warning_sfx_cooldown > 0.0:
		_danger_warning_sfx_cooldown = maxf(_danger_warning_sfx_cooldown - delta, 0.0)
	if _enemy_action_windup_sfx_cooldown > 0.0:
		_enemy_action_windup_sfx_cooldown = maxf(_enemy_action_windup_sfx_cooldown - delta, 0.0)
	if _low_health_heartbeat_active and _low_health_feedback_intensity > 0.0:
		_low_health_heartbeat_timer = maxf(_low_health_heartbeat_timer - delta, 0.0)
		if _low_health_heartbeat_timer <= 0.0:
			play_sfx("low_health_heartbeat")
			_low_health_heartbeat_timer = _low_health_heartbeat_interval
	_tick_sfx(delta)
	_tick_music_crossfade(delta)


func _exit_tree() -> void:
	for music_player in _music_players:
		if is_instance_valid(music_player):
			music_player.stop()
			music_player.free()
	_music_players.clear()
	_active_music_player_index = -1
	_music_fade_from_index = -1
	for index in range(_active_sfx.size() - 1, -1, -1):
		_finish_sfx_at(index)
	_active_sfx.clear()
	for player in _sfx_player_pool:
		if is_instance_valid(player):
			player.stop()
	_sfx_player_pool.clear()
	_available_sfx_players.clear()


func play_sfx(sound_id: String) -> void:
	if _is_low_health_sfx(sound_id) and _low_health_feedback_intensity <= 0.0:
		return

	_last_sfx_id = sound_id
	_sfx_play_counts_by_id[sound_id] = int(_sfx_play_counts_by_id.get(sound_id, 0)) + 1
	if _try_play_authored_sfx(sound_id):
		return

	_last_sfx_source = "procedural_fallback"
	_last_resolved_sample_id = ""
	_procedural_fallback_count += 1
	if _try_play_weapon_fire_sfx(sound_id):
		return

	match sound_id:
		"shoot":
			_play_tone(680.0, 0.055, 0.13, "square", -160.0)
		"hit":
			_play_tone(260.0, 0.07, 0.16, "noise", 0.0)
		"crit":
			_play_tone(920.0, 0.11, 0.18, "square", -260.0)
		"kill":
			_play_tone(190.0, 0.14, 0.18, "sine", -90.0)
		"hurt":
			_play_tone(95.0, 0.18, 0.22, "square", -30.0)
		"hp_heal":
			_play_tone(620.0, 0.16, 0.14, "sine", 220.0)
		"low_health":
			_play_tone(150.0, 0.22, 0.16 * _low_health_feedback_intensity, "square", 70.0)
		"low_health_heartbeat":
			_play_tone(118.0, 0.12, 0.12 * _low_health_feedback_intensity, "sine", 36.0)
		"low_health_recover":
			_play_tone(480.0, 0.13, 0.13 * _low_health_feedback_intensity, "sine", 170.0)
		"clear":
			_play_tone(440.0, 0.17, 0.18, "sine", 220.0)
		"chest":
			_play_tone(520.0, 0.18, 0.18, "sine", 260.0)
		"reward":
			_play_tone(700.0, 0.12, 0.14, "sine", 180.0)
		"buy":
			_play_tone(620.0, 0.12, 0.14, "sine", 160.0)
		"fail":
			_play_tone(120.0, 0.16, 0.18, "square", -35.0)
		"energy_empty":
			_play_tone(155.0, 0.18, 0.16, "square", -110.0)
		"reload_ready":
			_play_tone(760.0, 0.13, 0.15, "sine", 180.0)
		"skill_fail":
			_play_tone(220.0, 0.14, 0.16, "square", -90.0)
		"skill_ready":
			_play_tone(880.0, 0.14, 0.14, "sine", 220.0)
		"passive_focus":
			_play_tone(940.0, 0.16, 0.16, "sine", 260.0)
		"passive_guard":
			_play_tone(360.0, 0.18, 0.18, "square", -120.0)
		"passive_energy":
			_play_tone(720.0, 0.16, 0.16, "square", 280.0)
		"passive_speed":
			_play_tone(1040.0, 0.12, 0.14, "sine", -360.0)
		"passive_burst":
			_play_tone(180.0, 0.2, 0.19, "noise", -30.0)
		"passive_support":
			_play_tone(560.0, 0.18, 0.16, "sine", 240.0)
		"passive_trigger":
			_play_tone(620.0, 0.15, 0.15, "sine", 160.0)
		"blessing_clear":
			_play_tone(680.0, 0.17, 0.16, "sine", 260.0)
		"blessing_kill":
			_play_tone(420.0, 0.16, 0.17, "square", -220.0)
		"blessing_guard":
			_play_tone(300.0, 0.18, 0.17, "square", 130.0)
		"blessing_resonance":
			_play_tone(760.0, 0.18, 0.16, "sine", 320.0)
		"blessing_trigger":
			_play_tone(600.0, 0.15, 0.15, "sine", 180.0)
		"statue_skill":
			_play_tone(500.0, 0.2, 0.17, "square", 210.0)
		"statue_trigger":
			_play_tone(460.0, 0.18, 0.16, "sine", 160.0)
		"statue_attune":
			_play_tone(820.0, 0.2, 0.17, "sine", 260.0)
		"armor_gain":
			_play_tone(540.0, 0.13, 0.14, "sine", 140.0)
		"armor_block":
			_play_tone(330.0, 0.1, 0.16, "square", -80.0)
		"projectile_block":
			_play_tone(620.0, 0.09, 0.15, "square", -240.0)
		"armor_break":
			_play_tone(210.0, 0.18, 0.19, "square", -140.0)
		"danger_warning":
			_play_tone(410.0, 0.11, 0.15, "square", 90.0)
		"danger_warning_line":
			_play_tone(520.0, 0.095, 0.14, "square", -180.0)
		"danger_warning_heavy":
			_play_tone(260.0, 0.18, 0.18, "square", 120.0)
		"enemy_summon_windup":
			_play_tone(320.0, 0.22, 0.16, "square", 340.0)
		"enemy_support_windup":
			_play_tone(560.0, 0.2, 0.15, "sine", 260.0)
		"enemy_shield_bash_windup":
			_play_tone(190.0, 0.16, 0.18, "square", -90.0)
		"enemy_action_windup":
			_play_tone(430.0, 0.15, 0.15, "square", 80.0)
		"boss_phase":
			_play_tone(120.0, 0.26, 0.22, "square", 80.0)
		"boss_died":
			_play_tone(90.0, 0.34, 0.22, "sine", -45.0)
		"victory":
			_play_tone(660.0, 0.26, 0.18, "sine", 330.0)
		"defeat":
			_play_tone(140.0, 0.34, 0.2, "sine", -80.0)
		_:
			_play_tone(360.0, 0.08, 0.12, "sine", 0.0)


func start_music(mode: String) -> void:
	_music_mode = mode
	var track_id := MUSIC_LIBRARY.resolve_track_id(mode)
	_last_music_track_id = track_id
	if track_id.is_empty() or not _music_streams.has(track_id):
		_music_source = "missing"
		_missing_music_count += 1
		return

	_music_source = "authored"
	if _suppress_playback:
		return

	_ensure_music_players()
	var stream := _music_streams[track_id] as AudioStream
	if _active_music_player_index >= 0:
		var active_player := _music_players[_active_music_player_index]
		if active_player.stream == stream and active_player.playing:
			return

	var next_index := 0 if _active_music_player_index < 0 else 1 - _active_music_player_index
	var next_player := _music_players[next_index]
	next_player.stop()
	next_player.stream = stream
	next_player.volume_db = 0.0 if _active_music_player_index < 0 else -60.0
	next_player.play()

	if _active_music_player_index < 0:
		_active_music_player_index = next_index
		_music_fade_from_index = -1
		return

	_music_fade_from_index = _active_music_player_index
	_active_music_player_index = next_index
	_music_crossfade_elapsed = 0.0


func get_sfx_play_count() -> int:
	return _sfx_play_count


func get_sfx_play_count_for_id_for_test(sound_id: String) -> int:
	return int(_sfx_play_counts_by_id.get(sound_id, 0))


func get_sfx_player_pool_size_for_test() -> int:
	return _sfx_player_pool.size()


func get_sfx_player_creation_count_for_test() -> int:
	return _sfx_player_creation_count


func get_active_sfx_count_for_test() -> int:
	return _active_sfx.size()


func get_music_mode() -> String:
	return _music_mode


func get_music_source_for_test() -> String:
	return _music_source


func get_last_music_track_id_for_test() -> String:
	return _last_music_track_id


func get_authored_music_path_for_test(music_key: String) -> String:
	return MUSIC_LIBRARY.get_asset_path(music_key)


func has_authored_music_for_test(music_key: String) -> bool:
	var track_id := MUSIC_LIBRARY.resolve_track_id(music_key)
	return not track_id.is_empty() and _music_streams.has(track_id)


func get_authored_music_track_count_for_test() -> int:
	return _music_streams.size()


func get_required_authored_music_track_count_for_test() -> int:
	return MUSIC_LIBRARY.get_required_track_ids().size()


func get_missing_authored_music_ids_for_test() -> Array[String]:
	var missing_ids: Array[String] = []
	for track_id_value in MUSIC_LIBRARY.get_required_track_ids():
		var track_id := str(track_id_value)
		if not _music_streams.has(track_id):
			missing_ids.append(track_id)
	return missing_ids


func get_missing_music_count_for_test() -> int:
	return _missing_music_count


func get_music_player_count_for_test() -> int:
	return _music_players.size()


func get_active_music_loop_mode_for_test() -> int:
	if _active_music_player_index < 0 or _active_music_player_index >= _music_players.size():
		return -1
	var stream := _music_players[_active_music_player_index].stream as AudioStreamWAV
	if stream == null:
		return -1
	return int(stream.loop_mode)


func get_music_loop_mode_for_test(music_key: String) -> int:
	var track_id := MUSIC_LIBRARY.resolve_track_id(music_key)
	var stream := _music_streams.get(track_id) as AudioStreamWAV
	if stream == null:
		return -1
	return int(stream.loop_mode)


func get_last_sfx_id_for_test() -> String:
	return _last_sfx_id


func get_last_sfx_source_for_test() -> String:
	return _last_sfx_source


func get_last_resolved_sample_id_for_test() -> String:
	return _last_resolved_sample_id


func get_authored_sfx_path_for_test(sound_id: String) -> String:
	return SFX_LIBRARY.get_asset_path(sound_id)


func has_authored_sfx_for_test(sound_id: String) -> bool:
	var sample_id := SFX_LIBRARY.resolve_sample_id(sound_id)
	return not sample_id.is_empty() and _authored_sfx_streams.has(sample_id)


func get_authored_sfx_sample_count_for_test() -> int:
	return _authored_sfx_streams.size()


func get_required_authored_sfx_sample_count_for_test() -> int:
	return SFX_LIBRARY.get_required_sample_ids().size()


func get_missing_authored_sfx_ids_for_test() -> Array[String]:
	var missing_ids: Array[String] = []
	for sample_id_value in SFX_LIBRARY.get_required_sample_ids():
		var sample_id := str(sample_id_value)
		if not _authored_sfx_streams.has(sample_id):
			missing_ids.append(sample_id)
	return missing_ids


func get_procedural_fallback_count_for_test() -> int:
	return _procedural_fallback_count


func get_danger_warning_sfx_id_for_test(shape_name: String, duration: float, damage: int) -> String:
	return _resolve_danger_warning_sfx_id(shape_name, duration, damage)


func get_enemy_action_windup_sfx_id_for_test(action_id: String) -> String:
	return _resolve_enemy_action_windup_sfx_id(action_id)


func get_passive_trigger_sfx_id_for_test(passive_id: String) -> String:
	return _resolve_passive_trigger_sfx_id(passive_id)


func get_blessing_trigger_sfx_id_for_test(trigger_event: String) -> String:
	return _resolve_blessing_trigger_sfx_id(trigger_event)


func get_statue_trigger_sfx_id_for_test(trigger_event: String) -> String:
	return _resolve_statue_trigger_sfx_id(trigger_event)


func reset_danger_warning_sfx_cooldown_for_test() -> void:
	_danger_warning_sfx_cooldown = 0.0


func reset_enemy_action_windup_sfx_cooldown_for_test() -> void:
	_enemy_action_windup_sfx_cooldown = 0.0


func get_danger_warning_sfx_cooldown_for_test() -> float:
	return _danger_warning_sfx_cooldown


func is_low_health_heartbeat_active_for_test() -> bool:
	return _low_health_heartbeat_active


func get_low_health_heartbeat_timer_for_test() -> float:
	return _low_health_heartbeat_timer


func get_low_health_heartbeat_interval_for_test() -> float:
	return _low_health_heartbeat_interval


func set_low_health_feedback_intensity(value: float) -> void:
	_low_health_feedback_intensity = LOW_HEALTH_FEEDBACK.clamp_feedback_intensity(value)
	if _low_health_feedback_intensity <= 0.0:
		_low_health_heartbeat_active = false
		_low_health_heartbeat_timer = 0.0
		_low_health_heartbeat_interval = LOW_HEALTH_HEARTBEAT_INTERVAL


func get_low_health_feedback_intensity_for_test() -> float:
	return _low_health_feedback_intensity


func has_audio_bus(bus_name: String) -> bool:
	return AudioServer.get_bus_index(bus_name) >= 0


func _connect_events() -> void:
	Events.player_fired.connect(_on_player_fired)
	Events.player_weapon_reloaded.connect(_on_player_weapon_reloaded)
	Events.player_projectile_blocked.connect(_on_player_projectile_blocked)
	Events.projectile_hit.connect(_on_projectile_hit)
	Events.projectile_critical_hit.connect(_on_projectile_critical_hit)
	Events.enemy_died.connect(_on_enemy_died)
	Events.player_damaged.connect(_on_player_damaged)
	Events.player_healed.connect(_on_player_healed)
	Events.player_low_health_warning.connect(_on_player_low_health_warning)
	Events.player_low_health_updated.connect(_on_player_low_health_updated)
	Events.player_low_health_recovered.connect(_on_player_low_health_recovered)
	Events.player_shield_gained.connect(_on_player_shield_gained)
	Events.player_shield_absorbed.connect(_on_player_shield_absorbed)
	Events.player_shield_broken.connect(_on_player_shield_broken)
	Events.player_died.connect(_on_player_died)
	Events.player_energy_insufficient.connect(_on_player_energy_insufficient)
	Events.player_skill_unavailable.connect(_on_player_skill_unavailable)
	Events.player_skill_ready.connect(_on_player_skill_ready)
	Events.player_passive_triggered.connect(_on_player_passive_triggered)
	Events.room_started.connect(_on_room_started)
	Events.room_cleared.connect(_on_room_cleared)
	Events.reward_collected.connect(_on_reward_collected)
	Events.chest_opened.connect(_on_chest_opened)
	Events.shop_item_purchased.connect(_on_shop_item_purchased)
	Events.shop_purchase_failed.connect(_on_shop_purchase_failed)
	Events.blessing_triggered.connect(_on_blessing_triggered)
	Events.statue_triggered.connect(_on_statue_triggered)
	Events.statue_attuned.connect(_on_statue_attuned)
	Events.danger_warning_started.connect(_on_danger_warning_started)
	Events.enemy_action_windup_started.connect(_on_enemy_action_windup_started)
	Events.boss_health_changed.connect(_on_boss_health_changed)
	Events.boss_phase_changed.connect(_on_boss_phase_changed)
	Events.boss_died.connect(_on_boss_died)
	Events.run_completed.connect(_on_run_completed)


func _load_authored_sfx() -> void:
	_authored_sfx_streams.clear()
	for sample_id_value in SFX_LIBRARY.get_required_sample_ids():
		var sample_id := str(sample_id_value)
		var asset_path := SFX_LIBRARY.get_asset_path(sample_id)
		if asset_path.is_empty() or not ResourceLoader.exists(asset_path):
			continue
		var stream := ResourceLoader.load(asset_path) as AudioStream
		if stream != null:
			_authored_sfx_streams[sample_id] = stream


func _load_authored_music() -> void:
	_music_streams.clear()
	for track_id_value in MUSIC_LIBRARY.get_required_track_ids():
		var track_id := str(track_id_value)
		var asset_path := MUSIC_LIBRARY.get_asset_path(track_id)
		if asset_path.is_empty() or not ResourceLoader.exists(asset_path):
			continue
		var imported_stream := ResourceLoader.load(asset_path) as AudioStreamWAV
		if imported_stream == null:
			continue
		var stream := imported_stream.duplicate(true) as AudioStreamWAV
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if MUSIC_LIBRARY.should_loop(track_id) else AudioStreamWAV.LOOP_DISABLED
		stream.loop_begin = 0
		stream.loop_end = roundi(stream.get_length() * float(stream.mix_rate))
		_music_streams[track_id] = stream


func _ensure_music_players() -> void:
	if _music_players.size() == 2:
		return
	for index in range(2):
		var player := AudioStreamPlayer.new()
		player.name = "AuthoredMusicPlayer%d" % (index + 1)
		player.bus = MUSIC_BUS
		add_child(player)
		_music_players.append(player)


func _tick_music_crossfade(delta: float) -> void:
	if _music_fade_from_index < 0 or _active_music_player_index < 0:
		return
	if _music_fade_from_index >= _music_players.size() or _active_music_player_index >= _music_players.size():
		_music_fade_from_index = -1
		return

	_music_crossfade_elapsed += delta
	var progress := clampf(_music_crossfade_elapsed / MUSIC_CROSSFADE_DURATION, 0.0, 1.0)
	var from_player := _music_players[_music_fade_from_index]
	var to_player := _music_players[_active_music_player_index]
	from_player.volume_db = linear_to_db(maxf(1.0 - progress, 0.001))
	to_player.volume_db = linear_to_db(maxf(progress, 0.001))
	if progress < 1.0:
		return

	from_player.stop()
	from_player.volume_db = 0.0
	to_player.volume_db = 0.0
	_music_fade_from_index = -1
	_music_crossfade_elapsed = 0.0


func _try_play_authored_sfx(sound_id: String) -> bool:
	var sample_id := SFX_LIBRARY.resolve_sample_id(sound_id)
	if sample_id.is_empty():
		return false

	var stream := _authored_sfx_streams.get(sample_id) as AudioStream
	if stream == null:
		return false

	_last_sfx_source = "authored"
	_last_resolved_sample_id = sample_id
	_play_authored_stream(stream)
	return true


func _play_authored_stream(stream: AudioStream) -> void:
	if _suppress_playback:
		_sfx_play_count += 1
		return

	while _active_sfx.size() >= MAX_ACTIVE_SFX:
		_finish_sfx_at(0)

	var player := _acquire_sfx_player()
	if player == null:
		return
	player.stream = stream
	player.play()

	_sfx_play_count += 1
	_active_sfx.append({
		"player": player,
		"remaining": maxf(stream.get_length() + 0.12, 0.16),
	})


func _play_tone(frequency: float, duration: float, volume: float, wave: String, slide: float) -> void:
	if _suppress_playback:
		_sfx_play_count += 1
		return

	while _active_sfx.size() >= MAX_ACTIVE_SFX:
		_finish_sfx_at(0)

	var stream := AudioStreamGenerator.new()
	stream.mix_rate = SAMPLE_RATE
	stream.buffer_length = maxf(duration + 0.04, 0.08)

	var player := _acquire_sfx_player()
	if player == null:
		return
	player.stream = stream
	player.play()

	var playback := player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback != null:
		var frame_count := maxi(roundi(duration * SAMPLE_RATE), 1)
		for frame in range(frame_count):
			var progress := float(frame) / float(maxi(frame_count - 1, 1))
			var tone_frequency := maxf(frequency + slide * progress, 20.0)
			var sample := _sample_wave(wave, float(frame) / SAMPLE_RATE, tone_frequency)
			sample *= volume * _envelope(progress)
			playback.push_frame(Vector2(sample, sample))

	_sfx_play_count += 1
	_active_sfx.append({
		"player": player,
		"remaining": duration + 0.12,
	})


func _tick_sfx(delta: float) -> void:
	for index in range(_active_sfx.size() - 1, -1, -1):
		var entry: Dictionary = _active_sfx[index]
		var remaining := float(entry.get("remaining", 0.0)) - delta
		entry["remaining"] = remaining
		_active_sfx[index] = entry
		if remaining <= 0.0:
			_finish_sfx_at(index)


func _finish_sfx_at(index: int) -> void:
	if index < 0 or index >= _active_sfx.size():
		return

	var entry: Dictionary = _active_sfx[index]
	var player := entry.get("player") as AudioStreamPlayer
	_active_sfx.remove_at(index)
	if is_instance_valid(player):
		player.stop()
		player.stream = null
		if _sfx_player_pool.has(player) and not _available_sfx_players.has(player):
			_available_sfx_players.append(player)


func _ensure_sfx_player_pool() -> void:
	if _suppress_playback or _sfx_player_pool.size() >= MAX_ACTIVE_SFX:
		return
	while _sfx_player_pool.size() < MAX_ACTIVE_SFX:
		var player := AudioStreamPlayer.new()
		player.name = "SfxPlayer%d" % (_sfx_player_pool.size() + 1)
		player.bus = SFX_BUS
		add_child(player)
		_sfx_player_pool.append(player)
		_available_sfx_players.append(player)
		_sfx_player_creation_count += 1


func _acquire_sfx_player() -> AudioStreamPlayer:
	_ensure_sfx_player_pool()
	if _available_sfx_players.is_empty() and not _active_sfx.is_empty():
		_finish_sfx_at(0)
	if _available_sfx_players.is_empty():
		return null
	return _available_sfx_players.pop_back()


func _sample_wave(wave: String, time: float, frequency: float) -> float:
	match wave:
		"square":
			return 1.0 if sin(TAU * frequency * time) >= 0.0 else -1.0
		"noise":
			return _rng.randf_range(-1.0, 1.0)
	return sin(TAU * frequency * time)


func _envelope(progress: float) -> float:
	var attack := clampf(progress / 0.12, 0.0, 1.0)
	var release := clampf((1.0 - progress) / 0.2, 0.0, 1.0)
	return attack * release


func _try_play_weapon_fire_sfx(sound_id: String) -> bool:
	match sound_id:
		"weapon_sidearm_fire", "pistol_fire", "carbine_fire", "needler_fire", "ricochet_fire":
			_play_tone(720.0, 0.055, 0.13, "square", -180.0)
		"weapon_shotgun_fire", "shotgun_fire", "fan_burst", "storm_fan_fire":
			_play_tone(310.0, 0.09, 0.18, "noise", -25.0)
		"weapon_launcher_fire", "launcher_fire", "mortar_fire", "slag_launch", "mine_arm":
			_play_tone(150.0, 0.15, 0.2, "square", -55.0)
		"weapon_laser_fire", "laser_fire", "prism_fire", "vault_lance_fire":
			_play_tone(980.0, 0.105, 0.14, "sine", 240.0)
		"weapon_melee_fire", "melee_swing", "frost_swing", "guard_cleave", "spear_thrust", "sickle_swing", "riposte_swing", "bulwark_fan":
			_play_tone(250.0, 0.085, 0.16, "noise", 120.0)
		"weapon_staff_fire", "staff_fire", "ember_spray", "deploy_beacon":
			_play_tone(520.0, 0.1, 0.15, "sine", 180.0)
		"weapon_core_fire", "nova_fire", "halo_fire", "orbit_fire", "sentry_seed", "storm_charge_fire", "charge_bolt_fire":
			_play_tone(460.0, 0.13, 0.17, "square", 260.0)
		_:
			return false
	return true


func _ensure_audio_bus(bus_name: String) -> int:
	var index := AudioServer.get_bus_index(bus_name)
	if index >= 0:
		return index

	AudioServer.add_bus(AudioServer.get_bus_count())
	index = AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, "Master")
	return index


func _on_player_fired(weapon_data: Resource, _origin: Vector2, _direction: Vector2) -> void:
	play_sfx(_resolve_weapon_fire_sfx_id(weapon_data))


func _on_player_weapon_reloaded(_weapon_data: Resource) -> void:
	play_sfx("reload_ready")


func _on_player_projectile_blocked(_player: Node, _weapon_data: Resource, blocked_count: int, _block_position: Vector2) -> void:
	if blocked_count <= 0:
		return
	play_sfx("projectile_block")


func _resolve_weapon_fire_sfx_id(weapon_data: Resource) -> String:
	if weapon_data == null:
		return "shoot"

	var configured_value = weapon_data.get("fire_sfx_key")
	if configured_value != null:
		var configured_key := str(configured_value).strip_edges()
		if not configured_key.is_empty():
			return configured_key

	var class_value = weapon_data.get("weapon_class")
	if class_value != null:
		var weapon_class := str(class_value).strip_edges()
		match weapon_class:
			"sidearm", "shotgun", "launcher", "laser", "melee", "staff", "core":
				return "weapon_%s_fire" % weapon_class
	return "shoot"


func _is_low_health_sfx(sound_id: String) -> bool:
	return sound_id == "low_health" or sound_id == "low_health_heartbeat" or sound_id == "low_health_recover"


func _on_projectile_hit(_projectile: Node, _target: Node, _damage: int) -> void:
	play_sfx("hit")


func _on_projectile_critical_hit(_projectile: Node, _target: Node, _damage: int) -> void:
	play_sfx("crit")


func _on_enemy_died(_enemy: Node) -> void:
	play_sfx("kill")


func _on_player_damaged(_amount: int, _current_hp: int) -> void:
	if _amount <= 0:
		return
	play_sfx("hurt")


func _on_player_healed(amount: int, _current_hp: int) -> void:
	if amount <= 0:
		return
	play_sfx("hp_heal")


func _on_player_low_health_warning(current_hp: int, _max_hp: int) -> void:
	if current_hp <= 0 or _low_health_feedback_intensity <= 0.0:
		_low_health_heartbeat_active = false
		_low_health_heartbeat_timer = 0.0
		return
	_sync_low_health_heartbeat_interval(current_hp, _max_hp)
	_low_health_heartbeat_active = true
	_low_health_heartbeat_timer = _low_health_heartbeat_interval
	play_sfx("low_health")


func _on_player_low_health_updated(current_hp: int, max_hp: int) -> void:
	if current_hp <= 0 or not _low_health_heartbeat_active:
		return
	_sync_low_health_heartbeat_interval(current_hp, max_hp)


func _on_player_low_health_recovered(current_hp: int, _max_hp: int) -> void:
	_low_health_heartbeat_active = false
	_low_health_heartbeat_timer = 0.0
	_low_health_heartbeat_interval = LOW_HEALTH_HEARTBEAT_INTERVAL
	if current_hp <= 0 or _low_health_feedback_intensity <= 0.0:
		return
	play_sfx("low_health_recover")


func _sync_low_health_heartbeat_interval(current_hp: int, max_hp: int) -> void:
	var next_interval := _get_low_health_heartbeat_interval(current_hp, max_hp)
	_low_health_heartbeat_interval = next_interval
	if _low_health_heartbeat_active:
		_low_health_heartbeat_timer = minf(_low_health_heartbeat_timer, _low_health_heartbeat_interval)


func _get_low_health_heartbeat_interval(current_hp: int, max_hp: int) -> float:
	return LOW_HEALTH_FEEDBACK.interpolate_by_health(current_hp, max_hp, LOW_HEALTH_HEARTBEAT_INTERVAL, LOW_HEALTH_HEARTBEAT_CRITICAL_INTERVAL)


func _on_player_shield_gained(amount: int, _current_shield: int) -> void:
	if amount <= 0:
		return
	play_sfx("armor_gain")


func _on_player_shield_absorbed(amount: int, _current_shield: int) -> void:
	if amount <= 0:
		return
	play_sfx("armor_block")


func _on_player_shield_broken(absorbed_amount: int, _current_shield: int) -> void:
	if absorbed_amount <= 0:
		return
	play_sfx("armor_break")


func _on_danger_warning_started(shape_name: String, duration: float, damage: int) -> void:
	if _danger_warning_sfx_cooldown > 0.0:
		return
	_danger_warning_sfx_cooldown = DANGER_WARNING_SFX_COOLDOWN
	play_sfx(_resolve_danger_warning_sfx_id(shape_name, duration, damage))


func _resolve_danger_warning_sfx_id(shape_name: String, duration: float, damage: int) -> String:
	var normalized_shape := shape_name.strip_edges().to_lower()
	if normalized_shape == "line":
		return "danger_warning_line"
	if damage >= DANGER_WARNING_HEAVY_DAMAGE_THRESHOLD:
		return "danger_warning_heavy"
	if duration >= DANGER_WARNING_HEAVY_DURATION_THRESHOLD:
		return "danger_warning_heavy"
	return "danger_warning"


func _on_enemy_action_windup_started(_enemy: Node, action_id: String, _duration: float) -> void:
	if _enemy_action_windup_sfx_cooldown > 0.0:
		return
	_enemy_action_windup_sfx_cooldown = ENEMY_ACTION_WINDUP_SFX_COOLDOWN
	play_sfx(_resolve_enemy_action_windup_sfx_id(action_id))


func _resolve_enemy_action_windup_sfx_id(action_id: String) -> String:
	match action_id.strip_edges().to_lower():
		"summon":
			return "enemy_summon_windup"
		"support":
			return "enemy_support_windup"
		"shield_bash":
			return "enemy_shield_bash_windup"
	return "enemy_action_windup"


func _on_player_died() -> void:
	_low_health_heartbeat_active = false
	_low_health_heartbeat_timer = 0.0
	_low_health_heartbeat_interval = LOW_HEALTH_HEARTBEAT_INTERVAL
	start_music("defeat")
	play_sfx("defeat")


func _on_player_energy_insufficient(_current_energy: int, _required_energy: int, _source_data: Resource) -> void:
	play_sfx("energy_empty")


func _on_player_skill_unavailable(_skill_name: String, _reason: String, _cooldown_remaining: float) -> void:
	play_sfx("skill_fail")


func _on_player_skill_ready(_skill_name: String) -> void:
	play_sfx("skill_ready")


func _on_player_passive_triggered(_player: Node, passive_id: String, _effect_name: String, _duration: float) -> void:
	play_sfx(_resolve_passive_trigger_sfx_id(passive_id))


func _resolve_passive_trigger_sfx_id(passive_id: String) -> String:
	match passive_id.strip_edges():
		"steady_hands":
			return "passive_focus"
		"armored_core":
			return "passive_guard"
		"energy_focus":
			return "passive_energy"
		"phase_footing":
			return "passive_speed"
		"volatile_focus":
			return "passive_burst"
		"triage_kit":
			return "passive_support"
	return "passive_trigger"


func _on_blessing_triggered(_blessing_data: Resource, trigger_event: String, _effect_type: String, _effect_value: float) -> void:
	play_sfx(_resolve_blessing_trigger_sfx_id(trigger_event))


func _resolve_blessing_trigger_sfx_id(trigger_event: String) -> String:
	match trigger_event.strip_edges():
		"on_room_clear":
			return "blessing_clear"
		"on_kill":
			return "blessing_kill"
		"on_hurt":
			return "blessing_guard"
		"on_statue_triggered":
			return "blessing_resonance"
	return "blessing_trigger"


func _on_statue_triggered(_statue_data: Resource, trigger_event: String, _effect_type: String, _effect_value: float) -> void:
	play_sfx(_resolve_statue_trigger_sfx_id(trigger_event))


func _resolve_statue_trigger_sfx_id(trigger_event: String) -> String:
	match trigger_event.strip_edges():
		"on_skill_used":
			return "statue_skill"
	return "statue_trigger"


func _on_statue_attuned(_statue_data: Resource, _attunement_count: int) -> void:
	play_sfx("statue_attune")


func _on_room_started(room: Node) -> void:
	if room != null and str(room.get("room_type")) == "boss":
		start_music("boss")
		return
	var biome_music_key := str(room.get("biome_music_key")).strip_edges() if room != null else ""
	start_music(biome_music_key if not biome_music_key.is_empty() else "combat")


func _on_room_cleared(_room: Node) -> void:
	play_sfx("clear")


func _on_reward_collected(_reward: Node, _collector: Node) -> void:
	play_sfx("reward")


func _on_chest_opened(_chest: Node, _opener: Node, _chest_type: String) -> void:
	play_sfx("chest")


func _on_shop_item_purchased(_shop_item: Node, _buyer: Node, _price: int, _item_type: String) -> void:
	play_sfx("buy")


func _on_shop_purchase_failed(_shop_item: Node, _buyer: Node, _price: int, _reason: String) -> void:
	play_sfx("fail")


func _on_boss_health_changed(_boss: Node, _current_hp: int, _max_hp: int) -> void:
	start_music("boss")


func _on_boss_phase_changed(_boss: Node, _phase: int) -> void:
	play_sfx("boss_phase")


func _on_boss_died(_boss: Node) -> void:
	play_sfx("boss_died")


func _on_run_completed() -> void:
	start_music("victory")
	play_sfx("victory")

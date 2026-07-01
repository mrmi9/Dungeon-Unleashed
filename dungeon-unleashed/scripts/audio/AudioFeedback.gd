extends Node
class_name AudioFeedback

const SFX_BUS := "SFX"
const MUSIC_BUS := "Music"
const SAMPLE_RATE := 22050.0
const MAX_ACTIVE_SFX := 16

var _rng := RandomNumberGenerator.new()
var _active_sfx: Array[Dictionary] = []
var _sfx_play_count := 0
var _music_player: AudioStreamPlayer
var _music_playback: AudioStreamGeneratorPlayback
var _music_time := 0.0
var _music_mode := "menu"
var _suppress_playback := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("audio_feedback")
	_rng.randomize()
	_suppress_playback = DisplayServer.get_name() == "headless"
	_ensure_audio_bus(SFX_BUS)
	_ensure_audio_bus(MUSIC_BUS)
	_connect_events()
	start_music("menu")


func _process(delta: float) -> void:
	_tick_sfx(delta)
	_fill_music_buffer()


func _exit_tree() -> void:
	_music_playback = null
	if is_instance_valid(_music_player):
		_music_player.stop()
		_music_player.free()
	_music_player = null
	for index in range(_active_sfx.size() - 1, -1, -1):
		_finish_sfx_at(index)
	_active_sfx.clear()


func play_sfx(sound_id: String) -> void:
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
	if _suppress_playback:
		return

	if _music_player == null:
		_music_player = AudioStreamPlayer.new()
		_music_player.name = "ProceduralMusicPlayer"
		_music_player.bus = MUSIC_BUS
		var stream := AudioStreamGenerator.new()
		stream.mix_rate = SAMPLE_RATE
		stream.buffer_length = 0.6
		_music_player.stream = stream
		add_child(_music_player)

	if not _music_player.playing:
		_music_player.play()

	_music_playback = _music_player.get_stream_playback() as AudioStreamGeneratorPlayback


func get_sfx_play_count() -> int:
	return _sfx_play_count


func get_music_mode() -> String:
	return _music_mode


func has_audio_bus(bus_name: String) -> bool:
	return AudioServer.get_bus_index(bus_name) >= 0


func _connect_events() -> void:
	Events.player_fired.connect(_on_player_fired)
	Events.projectile_hit.connect(_on_projectile_hit)
	Events.projectile_critical_hit.connect(_on_projectile_critical_hit)
	Events.enemy_died.connect(_on_enemy_died)
	Events.player_damaged.connect(_on_player_damaged)
	Events.player_died.connect(_on_player_died)
	Events.room_started.connect(_on_room_started)
	Events.room_cleared.connect(_on_room_cleared)
	Events.reward_collected.connect(_on_reward_collected)
	Events.chest_opened.connect(_on_chest_opened)
	Events.shop_item_purchased.connect(_on_shop_item_purchased)
	Events.shop_purchase_failed.connect(_on_shop_purchase_failed)
	Events.boss_health_changed.connect(_on_boss_health_changed)
	Events.boss_phase_changed.connect(_on_boss_phase_changed)
	Events.boss_died.connect(_on_boss_died)
	Events.run_completed.connect(_on_run_completed)


func _play_tone(frequency: float, duration: float, volume: float, wave: String, slide: float) -> void:
	if _suppress_playback:
		_sfx_play_count += 1
		return

	while _active_sfx.size() >= MAX_ACTIVE_SFX:
		_finish_sfx_at(0)

	var stream := AudioStreamGenerator.new()
	stream.mix_rate = SAMPLE_RATE
	stream.buffer_length = maxf(duration + 0.04, 0.08)

	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = SFX_BUS
	add_child(player)
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
		player.free()


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


func _fill_music_buffer() -> void:
	if _music_playback == null:
		return

	var frames := _music_playback.get_frames_available()
	for _index in range(frames):
		var sample := _music_sample(_music_time)
		_music_playback.push_frame(Vector2(sample, sample))
		_music_time += 1.0 / SAMPLE_RATE


func _music_sample(time: float) -> float:
	var notes := _get_music_notes()
	var beat := 0.42 if _music_mode == "boss" else 0.58
	var note_index := int(floor(time / beat)) % notes.size()
	var frequency := float(notes[note_index])
	var pulse := 0.5 + 0.5 * sin(TAU * (time / beat))
	var base := sin(TAU * frequency * time) * 0.045
	var harmonic := sin(TAU * frequency * 2.0 * time) * 0.018
	var bass := sin(TAU * (frequency * 0.5) * time) * 0.026
	return (base + harmonic + bass) * (0.65 + 0.35 * pulse)


func _get_music_notes() -> Array:
	match _music_mode:
		"boss":
			return [110.0, 130.81, 146.83, 164.81, 146.83, 130.81]
		"victory":
			return [261.63, 329.63, 392.0, 523.25]
		"defeat":
			return [196.0, 174.61, 146.83, 130.81]
		"combat":
			return [146.83, 174.61, 196.0, 220.0, 196.0, 174.61]
	return [130.81, 146.83, 174.61, 196.0]


func _ensure_audio_bus(bus_name: String) -> int:
	var index := AudioServer.get_bus_index(bus_name)
	if index >= 0:
		return index

	AudioServer.add_bus(AudioServer.get_bus_count())
	index = AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, "Master")
	return index


func _on_player_fired(_weapon_data: Resource, _origin: Vector2, _direction: Vector2) -> void:
	play_sfx("shoot")


func _on_projectile_hit(_projectile: Node, _target: Node, _damage: int) -> void:
	play_sfx("hit")


func _on_projectile_critical_hit(_projectile: Node, _target: Node, _damage: int) -> void:
	play_sfx("crit")


func _on_enemy_died(_enemy: Node) -> void:
	play_sfx("kill")


func _on_player_damaged(_amount: int, _current_hp: int) -> void:
	play_sfx("hurt")


func _on_player_died() -> void:
	start_music("defeat")
	play_sfx("defeat")


func _on_room_started(room: Node) -> void:
	if room != null and str(room.get("room_type")) == "boss":
		start_music("boss")
	else:
		start_music("combat")


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

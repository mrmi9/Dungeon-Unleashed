extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const BASIC_PISTOL := preload("res://resources/weapons/basic_pistol.tres")
const SAMPLE_COUNT := 96

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	await get_tree().physics_frame

	var audio_feedback := main.get_node_or_null("AudioFeedback")
	var player := main.get_node_or_null("Player") as Player
	_expect(audio_feedback != null, "Main should include AudioFeedback")
	_expect(player != null, "Main should include Player")
	if audio_feedback == null or player == null:
		_finish()
		return

	audio_feedback.set("_suppress_playback", false)
	var audio_total_usec := 0
	var audio_max_usec := 0
	for _index in range(SAMPLE_COUNT):
		var started_usec := Time.get_ticks_usec()
		audio_feedback.call("play_sfx", BASIC_PISTOL.fire_sfx_key)
		var elapsed_usec := int(Time.get_ticks_usec() - started_usec)
		audio_total_usec += elapsed_usec
		audio_max_usec = maxi(audio_max_usec, elapsed_usec)
	var pooled_player_count := int(audio_feedback.call("get_sfx_player_pool_size_for_test"))
	var player_creation_count := int(audio_feedback.call("get_sfx_player_creation_count_for_test"))
	_expect(pooled_player_count == 16, "AudioFeedback should preallocate the fixed SFX voice pool")
	_expect(player_creation_count == pooled_player_count, "AudioFeedback should create each pooled SFX voice exactly once")

	var weapon := player.weapon
	player.current_energy = player.max_energy
	weapon.set_weapon_data(BASIC_PISTOL)
	weapon.set("_current_ammo", SAMPLE_COUNT + 1)
	var component_metrics := _measure_fire_components(player, weapon, audio_feedback)
	var fire_total_usec := 0
	var fire_max_usec := 0
	for _index in range(SAMPLE_COUNT):
		weapon.set("_cooldown", 0.0)
		var started_usec := Time.get_ticks_usec()
		var fired := weapon.try_fire(weapon.muzzle.global_position + Vector2.RIGHT * 420.0, player)
		var elapsed_usec := int(Time.get_ticks_usec() - started_usec)
		_expect(fired, "Basic Pistol should fire during the performance sample")
		fire_total_usec += elapsed_usec
		fire_max_usec = maxi(fire_max_usec, elapsed_usec)
		await get_tree().process_frame

	_expect(int(audio_feedback.call("get_sfx_player_creation_count_for_test")) == player_creation_count, "Continuous fire should reuse SFX players without creating more nodes")
	_expect(int(audio_feedback.call("get_active_sfx_count_for_test")) <= pooled_player_count, "Active SFX voices should stay within the fixed pool")
	_expect(audio_max_usec < 10000, "Pooled authored SFX should avoid a 10 ms synchronous spike")
	_expect(int(component_metrics.get("ammo", 0)) < 5000, "Ammo HUD updates should avoid rebuilding the full weapon loadout row")
	_expect(fire_total_usec / SAMPLE_COUNT < 8000, "Average synchronous fire work should remain below 8 ms")
	_expect(fire_max_usec < 20000, "A single synchronous fire call should remain below one 50 FPS frame")

	print(
		"FirePerformanceSmokeTest metrics: audio_avg_us=%d audio_max_us=%d projectile_avg_us=%d muzzle_avg_us=%d event_avg_us=%d ammo_avg_us=%d fire_avg_us=%d fire_max_us=%d" % [
			audio_total_usec / SAMPLE_COUNT,
			audio_max_usec,
			int(component_metrics.get("projectile", 0)),
			int(component_metrics.get("muzzle", 0)),
			int(component_metrics.get("event", 0)),
			int(component_metrics.get("ammo", 0)),
			fire_total_usec / SAMPLE_COUNT,
			fire_max_usec,
		]
	)
	_finish()


func _measure_fire_components(player: Player, weapon: Weapon, audio_feedback: Node) -> Dictionary:
	const COMPONENT_SAMPLES := 16
	var totals := {
		"projectile": 0,
		"muzzle": 0,
		"event": 0,
		"ammo": 0,
	}
	var origin := weapon.muzzle.global_position
	for _index in range(COMPONENT_SAMPLES):
		var started_usec := Time.get_ticks_usec()
		weapon.call("_spawn_single_projectile", origin, Vector2.RIGHT, player, 0.0)
		totals["projectile"] += int(Time.get_ticks_usec() - started_usec)

		started_usec = Time.get_ticks_usec()
		weapon.call("_spawn_muzzle_flash", Vector2.RIGHT)
		totals["muzzle"] += int(Time.get_ticks_usec() - started_usec)

		started_usec = Time.get_ticks_usec()
		Events.player_fired.emit(BASIC_PISTOL, origin, Vector2.RIGHT)
		totals["event"] += int(Time.get_ticks_usec() - started_usec)

		started_usec = Time.get_ticks_usec()
		weapon.call("_emit_ammo_changed")
		totals["ammo"] += int(Time.get_ticks_usec() - started_usec)

	for key in totals.keys():
		totals[key] = int(totals[key]) / COMPONENT_SAMPLES
	audio_feedback.call("_tick_sfx", 60.0)
	return totals


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("FirePerformanceSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

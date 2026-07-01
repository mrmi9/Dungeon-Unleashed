extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")

var _failures: Array[String] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_run")


func _run() -> void:
	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame

	var audio_feedback := main.get_node_or_null("AudioFeedback")
	_expect(audio_feedback != null, "Main scene should include AudioFeedback")
	if audio_feedback == null:
		_finish()
		return

	_expect(audio_feedback.has_method("has_audio_bus"), "AudioFeedback should expose audio bus checks")
	_expect(audio_feedback.call("has_audio_bus", "SFX") == true, "SFX bus should exist")
	_expect(audio_feedback.call("has_audio_bus", "Music") == true, "Music bus should exist")
	_expect(str(audio_feedback.call("get_music_mode")) == "menu", "AudioFeedback should start menu music")

	var count_before := int(audio_feedback.call("get_sfx_play_count"))
	Events.player_fired.emit(null, Vector2.ZERO, Vector2.RIGHT)
	Events.projectile_hit.emit(null, null, 1)
	Events.projectile_critical_hit.emit(null, null, 3)
	Events.enemy_died.emit(null)
	Events.player_damaged.emit(1, 5)
	await get_tree().process_frame
	var count_after := int(audio_feedback.call("get_sfx_play_count"))
	_expect(count_after >= count_before + 5, "Combat events should trigger SFX")

	Events.boss_health_changed.emit(null, 10, 20)
	await get_tree().process_frame
	_expect(str(audio_feedback.call("get_music_mode")) == "boss", "Boss health event should switch to boss music")

	Events.run_completed.emit()
	await get_tree().process_frame
	_expect(str(audio_feedback.call("get_music_mode")) == "victory", "Run completion should switch to victory music")
	_expect(int(audio_feedback.call("get_sfx_play_count")) > count_after, "Run completion should trigger victory SFX")
	await get_tree().create_timer(0.5, true).timeout

	get_tree().paused = false
	main.queue_free()
	await get_tree().process_frame
	_finish()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	get_tree().paused = false
	if _failures.is_empty():
		print("AudioFeedbackSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

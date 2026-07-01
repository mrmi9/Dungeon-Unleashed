extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	if main.has_method("start_new_run"):
		main.call("start_new_run")

	await get_tree().process_frame
	await get_tree().physics_frame

	var player := main.get_node_or_null("Player") as Player
	_expect(player != null, "Player should exist")
	_expect(main.has_method("get_floating_text_count"), "Main should expose floating text count")
	if player == null:
		_finish()
		return

	var count_before := int(main.call("get_floating_text_count"))
	Events.projectile_hit.emit(null, player, 2)
	Events.projectile_critical_hit.emit(null, player, 6)

	player.current_health = maxi(player.max_health - 2, 1)
	player.health_changed.emit(player.current_health, player.max_health)
	player.heal(1)
	player.add_shield(2)
	player.set("_invulnerability_timer", 0.0)
	player.take_damage(3, null)

	await get_tree().process_frame
	var texts := _collect_floating_texts()
	_expect(int(main.call("get_floating_text_count")) >= count_before + 6, "Combat feedback should spawn floating text for damage, crit, heal, shield, shield block, and hurt")
	_expect(_has_text_containing(texts, "-2"), "Normal projectile hit should show damage text")
	_expect(_has_text_containing(texts, "CRIT 6"), "Critical hit should show crit damage text")
	_expect(_has_text_containing(texts, "+1 HP"), "Healing should show HP floating text")
	_expect(_has_text_containing(texts, "+2 SH"), "Shield gain should show shield floating text")
	_expect(_has_text_containing(texts, "-2 SH"), "Shield absorption should show blocked shield floating text")
	_expect(_has_text_containing(texts, "-1"), "Player damage should show hurt floating text")

	await get_tree().create_timer(1.25).timeout
	await get_tree().process_frame
	var count_after_cleanup := int(main.call("get_floating_text_count"))
	_expect(count_after_cleanup <= count_before, "Floating text should clean itself up after its duration, expected at most %d got %d" % [count_before, count_after_cleanup])

	get_tree().paused = false
	main.queue_free()
	await get_tree().process_frame
	_finish()


func _collect_floating_texts() -> Array[String]:
	var texts: Array[String] = []
	for node in get_tree().get_nodes_in_group("floating_text"):
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		if node.has_method("get_text"):
			texts.append(str(node.call("get_text")))
	return texts


func _has_text_containing(texts: Array[String], needle: String) -> bool:
	for text in texts:
		if text.contains(needle):
			return true
	return false


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	get_tree().paused = false
	if _failures.is_empty():
		print("CombatFeedbackSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

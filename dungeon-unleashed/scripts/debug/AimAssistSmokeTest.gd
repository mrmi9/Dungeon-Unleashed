extends Node

const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PLAYER_SCENE.instantiate()
	get_tree().root.add_child(player)
	await get_tree().process_frame
	player.global_position = Vector2.ZERO

	player.call("configure_aim_assist", false, 1.0, 400.0, 45.0)
	var disabled_direction: Vector2 = player.call("get_assisted_aim_direction_for_test", Vector2.ZERO, Vector2.RIGHT)
	_expect(disabled_direction.distance_to(Vector2.RIGHT) < 0.001, "Disabled aim assist should keep the raw aim direction")

	var valid_target := Node2D.new()
	valid_target.name = "ValidAimAssistTarget"
	get_tree().root.add_child(valid_target)
	valid_target.add_to_group("enemies")
	valid_target.global_position = Vector2(160.0, 80.0)

	player.call("configure_aim_assist", true, 1.0, 400.0, 45.0)
	var picked = player.call("get_aim_assist_target_for_test", Vector2.ZERO, Vector2.RIGHT)
	_expect(picked == valid_target, "Player aim assist should select a valid enemy candidate")
	var assisted_direction: Vector2 = player.call("get_assisted_aim_direction_for_test", Vector2.ZERO, Vector2.RIGHT)
	_expect(assisted_direction.x > 0.7 and assisted_direction.y > 0.2, "Player aim assist should bend aim toward a valid target")

	valid_target.remove_from_group("enemies")
	valid_target.queue_free()

	var off_angle_target := Node2D.new()
	off_angle_target.name = "OffAngleAimAssistTarget"
	get_tree().root.add_child(off_angle_target)
	off_angle_target.add_to_group("enemies")
	off_angle_target.global_position = Vector2(0.0, 160.0)

	picked = player.call("get_aim_assist_target_for_test", Vector2.ZERO, Vector2.RIGHT)
	_expect(picked == null, "Player aim assist should ignore targets outside the assist cone")
	var off_angle_direction: Vector2 = player.call("get_assisted_aim_direction_for_test", Vector2.ZERO, Vector2.RIGHT)
	_expect(off_angle_direction.distance_to(Vector2.RIGHT) < 0.001, "Aim assist should preserve raw aim when no target is valid")

	off_angle_target.queue_free()

	var direct_target := Node2D.new()
	direct_target.name = "DirectAimAssistTarget"
	get_tree().root.add_child(direct_target)
	direct_target.add_to_group("enemies")
	direct_target.global_position = Vector2(180.0, 0.0)

	var locked_target := Node2D.new()
	locked_target.name = "LockedAimAssistTarget"
	get_tree().root.add_child(locked_target)
	locked_target.add_to_group("enemies")
	locked_target.global_position = Vector2(180.0, 70.0)

	player.call("configure_aim_assist", true, 1.0, 400.0, 45.0, 2.0)
	_expect(is_equal_approx(float(player.call("get_aim_assist_lock_weight_for_test")), 2.0), "Player should pass lock weight into AimAssistController")
	picked = player.call("get_aim_assist_target_for_test", Vector2.ZERO, Vector2.RIGHT)
	_expect(picked == direct_target, "Aim assist should prefer the best angle target before a lock is set")
	player.call("set_aim_assist_locked_target_for_test", locked_target)
	picked = player.call("get_aim_assist_target_for_test", Vector2.ZERO, Vector2.RIGHT)
	_expect(picked == locked_target, "Aim assist lock weight should preserve a nearby locked target")
	var locked_direction: Vector2 = player.call("get_assisted_aim_direction_for_test", Vector2.ZERO, Vector2.RIGHT)
	_expect(locked_direction.y > 0.05, "Aim assist should bend toward the weighted locked target")
	player.call("clear_aim_assist_lock_for_test")
	picked = player.call("get_aim_assist_target_for_test", Vector2.ZERO, Vector2.RIGHT)
	_expect(picked == direct_target, "Clearing aim assist lock should restore score-only target selection")

	var training_target := Node2D.new()
	training_target.name = "TrainingAimAssistTarget"
	get_tree().root.add_child(training_target)
	training_target.add_to_group("training_dummy")
	training_target.global_position = Vector2(140.0, 28.0)

	player.call("configure_aim_assist_candidate_groups", ["training_dummy"])
	var candidate_groups: PackedStringArray = player.call("get_aim_assist_candidate_groups_for_test")
	_expect(candidate_groups.has("training_dummy") and not candidate_groups.has("enemies"), "Player should pass custom aim-assist candidate groups into the controller")
	picked = player.call("get_aim_assist_target_for_test", Vector2.ZERO, Vector2.RIGHT)
	_expect(picked == training_target, "Aim assist should support non-enemy candidate groups for training targets")
	var training_direction: Vector2 = player.call("get_assisted_aim_direction_for_test", Vector2.ZERO, Vector2.RIGHT)
	_expect(training_direction.x > 0.85 and training_direction.y > 0.05, "Aim assist should bend toward the configured training target group")
	player.call("configure_aim_assist_candidate_groups", ["enemies"])

	training_target.queue_free()
	direct_target.queue_free()
	locked_target.queue_free()
	player.queue_free()
	await get_tree().process_frame
	_finish()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("AimAssistSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

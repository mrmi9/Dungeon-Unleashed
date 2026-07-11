extends Node2D

const CHASER_SCENE := preload("res://scenes/enemies/ChaserEnemy.tscn")
const PROFILE_CASES := [
	{"path": "res://resources/elite_modifiers/blazing.tres", "pattern": "flame"},
	{"path": "res://resources/elite_modifiers/bulwark.tres", "pattern": "shield"},
	{"path": "res://resources/elite_modifiers/quickened.tres", "pattern": "velocity"},
	{"path": "res://resources/elite_modifiers/volatile.tres", "pattern": "blast"},
	{"path": "res://resources/elite_modifiers/sharpshot.tres", "pattern": "reticle"},
	{"path": "res://resources/elite_modifiers/titan.tres", "pattern": "mass"},
]

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var seen_patterns := {}
	for index in range(PROFILE_CASES.size()):
		var profile_case: Dictionary = PROFILE_CASES[index]
		var profile := load(str(profile_case.get("path", ""))) as Resource
		_expect(profile != null, "Elite visual profile should load")
		if profile == null:
			continue
		var enemy := CHASER_SCENE.instantiate() as Enemy
		add_child(enemy)
		enemy.position = Vector2(150.0 + float(index % 3) * 260.0, 160.0 + float(index / 3) * 300.0)
		enemy.set_physics_process(false)
		var action_sprite := enemy.get_node_or_null("ActionSprite") as Sprite2D
		var base_modulate := action_sprite.modulate if action_sprite != null else Color.WHITE
		enemy.apply_elite_profile(profile)
		var summary := enemy.get_elite_visual_summary()
		var expected_pattern := str(profile_case.get("pattern", ""))
		_expect(bool(summary.get("enabled", false)), "%s elite should enable its aura" % profile.get("display_name"))
		_expect(str(summary.get("pattern", "")) == expected_pattern, "%s elite should use its dedicated pattern" % profile.get("display_name"))
		_expect(not seen_patterns.has(expected_pattern), "Elite aura patterns should remain unique: %s" % expected_pattern)
		seen_patterns[expected_pattern] = true
		_expect(float(summary.get("radius", 0.0)) >= 28.0, "%s elite aura should remain readable around the sprite" % profile.get("display_name"))
		_expect(float(summary.get("pulse_speed", 0.0)) > 0.0, "%s elite aura should animate" % profile.get("display_name"))
		_expect(int(summary.get("motif_count", 0)) >= 3, "%s elite aura should expose repeated geometry" % profile.get("display_name"))
		_expect(bool(summary.get("behind_parent", false)), "%s elite aura should render behind the enemy body" % profile.get("display_name"))
		_expect(action_sprite != null and action_sprite.modulate != base_modulate, "%s elite should tint the visible action sprite" % profile.get("display_name"))
		var aura := enemy.get_node_or_null("EliteAura")
		var phase_before := float(summary.get("phase", 0.0))
		if aura != null:
			aura.call("_process", 0.25)
		var animated_summary := enemy.get_elite_visual_summary()
		_expect(float(animated_summary.get("phase", 0.0)) > phase_before, "%s elite aura phase should advance" % profile.get("display_name"))
		enemy.queue_free()
		await get_tree().process_frame
	_expect(seen_patterns.size() == PROFILE_CASES.size(), "All six elite profiles should expose unique visual patterns")
	_finish()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("EliteVisualSmokeTest passed.")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

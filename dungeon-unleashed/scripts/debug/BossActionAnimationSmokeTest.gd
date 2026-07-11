extends Node2D

const BOSS_CASES := [
	{
		"scene": "res://scenes/enemies/WarrensGatekeeper.tscn",
		"atlas": "res://art/enemies/warrens_gatekeeper_action_atlas.png",
	},
	{
		"scene": "res://scenes/enemies/IronBulwark.tscn",
		"atlas": "res://art/enemies/iron_bulwark_action_atlas.png",
	},
	{
		"scene": "res://scenes/enemies/VoidFoundryHeart.tscn",
		"atlas": "res://art/enemies/void_foundry_heart_action_atlas.png",
	},
]

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	for boss_case in BOSS_CASES:
		_verify_atlas(str(boss_case.get("atlas", "")))
		await _verify_boss(str(boss_case.get("scene", "")))
	_finish()


func _verify_atlas(atlas_path: String) -> void:
	var texture := load(atlas_path) as Texture2D
	_expect(texture != null, "Boss action atlas should load: %s" % atlas_path)
	if texture != null:
		_expect(texture.get_size() == Vector2(1254.0, 1254.0), "Boss action atlas should preserve the generated square source: %s" % atlas_path)


func _verify_boss(scene_path: String) -> void:
	var scene := load(scene_path) as PackedScene
	_expect(scene != null, "Animated boss scene should load: %s" % scene_path)
	if scene == null:
		return
	var boss := scene.instantiate() as BossEnemy
	_expect(boss != null, "Animated boss scene should instantiate: %s" % scene_path)
	if boss == null:
		return
	add_child(boss)
	boss.position = Vector2(-500.0, -500.0)
	boss.set_physics_process(false)
	var summary := boss.get_action_sprite_summary()
	_expect(bool(summary.get("enabled", false)), "%s should enable its action sprite" % scene_path)
	_expect(int(summary.get("hframes", 0)) == 2 and int(summary.get("vframes", 0)) == 2, "%s should use a two-by-two boss atlas" % scene_path)
	_expect(bool(summary.get("fallback_hidden", false)), "%s should hide its body Polygon fallback" % scene_path)
	_expect(bool(summary.get("core_hidden", false)), "%s should hide its core Polygon fallback" % scene_path)
	_expect(float(summary.get("world_frame_size", 0.0)) >= 120.0 and float(summary.get("world_frame_size", 0.0)) <= 130.0, "%s should render near the shared 128px boss-frame contract" % scene_path)
	_expect(int(summary.get("frame", -1)) == 0, "%s should begin in phase-one idle" % scene_path)

	boss.call("_start_boss_action_animation", 1.0, false)
	boss.call("_tick_boss_action_sprite", 0.0)
	_expect(int(boss.get_action_sprite_summary().get("frame", -1)) == 1, "%s ordinary attacks should use the windup frame" % scene_path)
	boss.call("_start_boss_action_animation", 1.0, true)
	boss.call("_tick_boss_action_sprite", 0.0)
	_expect(int(boss.get_action_sprite_summary().get("frame", -1)) == 2, "%s signature attacks should use the peak frame" % scene_path)
	boss.set("_boss_action_timer", 0.0)
	boss.set("_phase", 2)
	boss.call("_tick_boss_action_sprite", 0.0)
	_expect(int(boss.get_action_sprite_summary().get("frame", -1)) == 3, "%s should use the enraged frame in phase two" % scene_path)
	boss.set("_phase_transition_timer", 0.5)
	boss.call("_tick_boss_action_sprite", 0.0)
	_expect(int(boss.get_action_sprite_summary().get("frame", -1)) == 2, "%s phase transition should override with the transformation frame" % scene_path)
	boss.queue_free()
	await get_tree().process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("BossActionAnimationSmokeTest passed.")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

extends Node2D

const ATLAS_PATHS := [
	"res://art/enemies/rift_summoner_action_atlas.svg",
	"res://art/enemies/grave_mender_action_atlas.svg",
	"res://art/enemies/shield_sentinel_action_atlas.svg",
	"res://art/enemies/marksman_action_atlas.png",
	"res://art/enemies/ram_charger_action_atlas.png",
	"res://art/enemies/volatile_vessel_action_atlas.png",
	"res://art/enemies/terrain_conduit_action_atlas.png",
	"res://art/enemies/chaser_stride_atlas.png",
	"res://art/enemies/barrage_totem_action_atlas.png",
	"res://art/enemies/needle_skater_action_atlas.png",
]
const ANIMATION_CASES := [
	{"scene": "res://scenes/enemies/SummonerEnemy.tscn", "mode": "utility", "action": "summon"},
	{"scene": "res://scenes/enemies/GraveMender.tscn", "mode": "utility", "action": "support"},
	{"scene": "res://scenes/enemies/ShieldEnemy.tscn", "mode": "utility", "action": "shield_bash"},
	{"scene": "res://scenes/enemies/ShooterEnemy.tscn", "mode": "projectile", "action": "projectile"},
	{"scene": "res://scenes/enemies/BarrageTotem.tscn", "mode": "projectile", "action": "barrage_totem"},
	{"scene": "res://scenes/enemies/NeedleSkater.tscn", "mode": "projectile", "action": "needle_skater"},
	{"scene": "res://scenes/enemies/ChargerEnemy.tscn", "mode": "charge", "action": "charge"},
	{"scene": "res://scenes/enemies/BomberEnemy.tscn", "mode": "bomber", "action": "self_destruct"},
	{"scene": "res://scenes/enemies/MireConduit.tscn", "mode": "zone", "action": "zone"},
]
const DEDICATED_SCENE_ATLASES := {
	"res://scenes/enemies/BarrageTotem.tscn": "res://art/enemies/barrage_totem_action_atlas.png",
	"res://scenes/enemies/NeedleSkater.tscn": "res://art/enemies/needle_skater_action_atlas.png",
}
const REQUIRED_SCENES := [
	"res://scenes/enemies/SummonerEnemy.tscn",
	"res://scenes/enemies/RiftCaller.tscn",
	"res://scenes/enemies/GraveMender.tscn",
	"res://scenes/enemies/ShieldEnemy.tscn",
	"res://scenes/enemies/AegisDrone.tscn",
	"res://scenes/enemies/ShooterEnemy.tscn",
	"res://scenes/enemies/EmberMarksman.tscn",
	"res://scenes/enemies/BarrageTotem.tscn",
	"res://scenes/enemies/NeedleSkater.tscn",
	"res://scenes/enemies/ChargerEnemy.tscn",
	"res://scenes/enemies/IronBreaker.tscn",
	"res://scenes/enemies/BomberEnemy.tscn",
	"res://scenes/enemies/VolatileVessel.tscn",
	"res://scenes/enemies/MireConduit.tscn",
	"res://scenes/enemies/NullAcolyte.tscn",
	"res://scenes/enemies/ChaserEnemy.tscn",
	"res://scenes/enemies/RustSkirmisher.tscn",
	"res://scenes/enemies/SootSplitter.tscn",
]
var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	_build_preview()
	_verify_required_scenes()
	for animation_case in ANIMATION_CASES:
		await _verify_animation_case(
			str(animation_case.get("scene", "")),
			str(animation_case.get("mode", "")),
			str(animation_case.get("action", ""))
		)
	await _verify_chaser_animation()

	_finish()


func _build_preview() -> void:
	for row in range(ATLAS_PATHS.size()):
		var texture := load(ATLAS_PATHS[row]) as Texture2D
		_expect(texture != null, "Action atlas should load: %s" % ATLAS_PATHS[row])
		if texture == null:
			continue
		var expected_size := Vector2(1254.0, 1254.0) if ATLAS_PATHS[row].ends_with(".png") else Vector2(128.0, 128.0)
		_expect(texture.get_size() == expected_size, "Action atlas should use its expected two-by-two source size: %s" % ATLAS_PATHS[row])
		for frame_index in range(4):
			var sprite := Sprite2D.new()
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			sprite.texture = texture
			sprite.hframes = 2
			sprite.vframes = 2
			sprite.frame = frame_index
			var preview_scale := 2.4 * 128.0 / maxf(texture.get_size().x, 1.0)
			sprite.scale = Vector2.ONE * preview_scale
			sprite.position = Vector2(220.0 + float(frame_index) * 260.0, 130.0 + float(row) * 225.0)
			add_child(sprite)


func _verify_required_scenes() -> void:
	for scene_path in REQUIRED_SCENES:
		var scene := load(scene_path) as PackedScene
		_expect(scene != null, "Animated enemy scene should load: %s" % scene_path)
		if scene == null:
			continue
		var enemy := scene.instantiate() as Enemy
		_expect(enemy != null, "Animated enemy scene should instantiate: %s" % scene_path)
		if enemy == null:
			continue
		add_child(enemy)
		enemy.position = Vector2(-300.0, -300.0)
		var summary := enemy.get_action_sprite_summary()
		_expect(bool(summary.get("enabled", false)), "%s should enable its action sprite" % scene_path)
		_expect(int(summary.get("hframes", 0)) == 2 and int(summary.get("vframes", 0)) == 2, "%s should use a two-by-two action atlas" % scene_path)
		_expect(bool(summary.get("fallback_hidden", false)), "%s should hide its Polygon fallback when the atlas is present" % scene_path)
		if DEDICATED_SCENE_ATLASES.has(scene_path):
			var action_sprite := enemy.get_node_or_null("ActionSprite") as Sprite2D
			_expect(action_sprite != null and action_sprite.texture.resource_path == str(DEDICATED_SCENE_ATLASES[scene_path]), "%s should use its dedicated action atlas" % scene_path)
		if enemy.behavior_type == Enemy.BehaviorType.SHIELDED:
			_expect(bool(summary.get("shield_fallback_hidden", false)), "%s should hide its legacy shield Polygon" % scene_path)
		enemy.queue_free()


func _verify_animation_case(scene_path: String, mode: String, action_id: String) -> void:
	var scene := load(scene_path) as PackedScene
	if scene == null:
		return
	var enemy := scene.instantiate() as Enemy
	if enemy == null:
		return
	add_child(enemy)
	enemy.position = Vector2(-300.0, -300.0)
	await get_tree().process_frame

	_expect(int(enemy.get_action_sprite_summary().get("frame", -1)) == 0, "%s should begin on its idle frame" % action_id)
	_set_animation_stage(enemy, mode, action_id, 1)
	_expect(int(enemy.get_action_sprite_summary().get("frame", -1)) == 1, "%s should enter its anticipation frame" % action_id)
	_set_animation_stage(enemy, mode, action_id, 2)
	_expect(int(enemy.get_action_sprite_summary().get("frame", -1)) == 2, "%s should enter its action-peak frame" % action_id)
	_set_animation_stage(enemy, mode, action_id, 3)
	_expect(int(enemy.get_action_sprite_summary().get("frame", -1)) == 3, "%s should enter its recovery frame" % action_id)
	_reset_animation_state(enemy)
	enemy.call("_tick_action_sprite", 0.25)
	_expect(int(enemy.get_action_sprite_summary().get("frame", -1)) == 0, "%s should return to idle after recovery" % action_id)
	enemy.queue_free()
	await get_tree().process_frame


func _verify_chaser_animation() -> void:
	var scene := load("res://scenes/enemies/ChaserEnemy.tscn") as PackedScene
	if scene == null:
		return
	var enemy := scene.instantiate() as Enemy
	if enemy == null:
		return
	var chase_target := Node2D.new()
	add_child(chase_target)
	add_child(enemy)
	enemy.position = Vector2(-300.0, -300.0)
	chase_target.position = Vector2(300.0, -300.0)
	enemy.target = chase_target
	enemy.set_physics_process(false)
	enemy.velocity = Vector2.RIGHT * enemy.move_speed
	enemy.call("_tick_action_sprite", 0.3)
	_expect(int(enemy.get_action_sprite_summary().get("frame", -1)) == 1, "Chaser movement should enter its left-step frame")
	enemy.call("_tick_action_sprite", 0.3)
	_expect(int(enemy.get_action_sprite_summary().get("frame", -1)) == 2, "Chaser movement should alternate to its right-step frame")
	chase_target.global_position = enemy.global_position + Vector2.RIGHT * 36.0
	enemy.call("_tick_action_sprite", 0.0)
	_expect(int(enemy.get_action_sprite_summary().get("frame", -1)) == 3, "Chaser contact range should use its lunge frame")
	enemy.queue_free()
	chase_target.queue_free()
	await get_tree().process_frame


func _set_animation_stage(enemy: Enemy, mode: String, action_id: String, stage: int) -> void:
	_reset_animation_state(enemy)
	match mode:
		"utility":
			enemy.set("_utility_action", action_id)
			enemy.set("_utility_windup_duration", 1.0)
			enemy.set("_utility_windup_timer", 1.0 if stage == 1 else 0.4 if stage == 2 else 0.0)
		"projectile":
			enemy.set("_projectile_windup_duration", 1.0)
			enemy.set("_projectile_windup_timer", 1.0 if stage == 1 else 0.4 if stage == 2 else 0.0)
		"charge":
			enemy.set("_charge_state", 1 if stage <= 2 else 3)
			enemy.set("_charge_timer", enemy.charge_windup if stage == 1 else enemy.charge_windup * 0.2)
		"bomber":
			enemy.set("_is_self_destructing", stage <= 2)
			enemy.set("_self_destruct_timer", enemy.self_destruct_windup if stage == 1 else enemy.self_destruct_windup * 0.2)
		"zone":
			enemy.set("_visual_action_duration", 1.0)
			enemy.set("_visual_action_timer", 1.0 if stage == 1 else 0.4 if stage == 2 else 0.0)
	if stage == 3:
		enemy.set("_action_sprite_recovery_timer", 0.2)
	enemy.call("_tick_action_sprite", 0.0)


func _reset_animation_state(enemy: Enemy) -> void:
	enemy.set("_utility_action", "")
	enemy.set("_utility_windup_timer", 0.0)
	enemy.set("_utility_windup_duration", 0.0)
	enemy.set("_projectile_windup_timer", 0.0)
	enemy.set("_projectile_windup_duration", 0.0)
	enemy.set("_charge_state", 0)
	enemy.set("_is_self_destructing", false)
	enemy.set("_visual_action_timer", 0.0)
	enemy.set("_visual_action_duration", 0.0)
	enemy.set("_action_sprite_recovery_timer", 0.0)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("EnemyActionAnimationSmokeTest passed.")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

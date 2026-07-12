extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const PROJECTILE_SCENE := preload("res://scenes/projectiles/Projectile.tscn")
const ENEMY_PROJECTILE_SCENE := preload("res://scenes/projectiles/EnemyProjectile.tscn")
const CHASER_SCENE := preload("res://scenes/enemies/ChaserEnemy.tscn")
const SHOOTER_SCENE := preload("res://scenes/enemies/ShooterEnemy.tscn")

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
	var hud := main.get_node_or_null("CanvasLayer/HUD")
	var audio_feedback = main.get_node_or_null("AudioFeedback")
	_expect(player != null, "Player should exist")
	_expect(hud != null, "HUD should exist")
	_expect(main.has_method("get_floating_text_count"), "Main should expose floating text count")
	if player == null or hud == null:
		_finish()
		return

	var count_before := int(main.call("get_floating_text_count"))
	Events.projectile_hit.emit(null, player, 2)
	Events.projectile_critical_hit.emit(null, player, 6)

	player.max_health = maxi(player.max_health, 3)
	player.current_health = maxi(player.max_health - 2, 1)
	player.health_changed.emit(player.current_health, player.max_health)
	player.heal(1)
	player.current_shield = 0
	player.shield_changed.emit(player.current_shield)
	player.add_shield(2)
	player.set("_invulnerability_timer", 0.0)
	player.take_damage(3, null)
	_expect(player.current_health > 0, "Combat feedback setup should keep player alive after shield and HP damage")
	_expect(not get_tree().paused, "Combat feedback setup should not pause the scene tree")

	await get_tree().process_frame
	var texts := _collect_floating_texts()
	_expect(int(main.call("get_floating_text_count")) >= count_before + 7, "Combat feedback should spawn floating text for damage, crit, heal, shield, shield block, armor break, and hurt")
	_expect(_has_text_containing(texts, "-2"), "Normal projectile hit should show damage text")
	_expect(_has_text_containing(texts, "CRIT 6"), "Critical hit should show crit damage text")
	_expect(_has_text_containing(texts, "+1 HP"), "Healing should show HP floating text")
	_expect(_has_text_containing(texts, "+2 SH"), "Shield gain should show shield floating text")
	_expect(_has_text_containing(texts, "-2 SH"), "Shield absorption should show blocked shield floating text")
	_expect(_has_text_containing(texts, "ARMOR BREAK"), "Armor break should show a dedicated floating text")
	_expect(_has_text_containing(texts, "-1"), "Player damage should show hurt floating text")
	if hud.has_method("is_armor_break_pulse_active"):
		_expect(bool(hud.call("is_armor_break_pulse_active")), "Armor break should trigger a HUD Armor pulse")
	if hud.has_method("is_damage_flash_visible"):
		_expect(bool(hud.call("is_damage_flash_visible")), "Player damage should trigger a HUD damage flash")
	if hud.has_method("get_damage_flash_alpha_for_test"):
		_expect(float(hud.call("get_damage_flash_alpha_for_test")) > 0.0, "HUD damage flash should expose visible alpha while active")
	if hud.has_method("set_damage_flash_intensity") and hud.has_method("show_damage_flash") and hud.has_method("is_damage_flash_visible") and hud.has_method("get_damage_flash_alpha_for_test"):
		hud.call("set_damage_flash_intensity", 0.0)
		hud.call("show_damage_flash", 3)
		_expect(not bool(hud.call("is_damage_flash_visible")), "Zero damage flash intensity should suppress the HUD damage flash")
		hud.call("set_damage_flash_intensity", 0.5)
		hud.call("show_damage_flash", 3)
		_expect(is_equal_approx(float(hud.call("get_damage_flash_alpha_for_test")), 0.14), "Damage flash intensity should scale damage flash alpha")
		hud.call("set_damage_flash_intensity", 1.0)
	if main.has_method("set_screen_shake_intensity_for_test") and main.has_method("add_screen_shake_for_test") and main.has_method("get_screen_shake_strength_for_test"):
		main.call("set_screen_shake_intensity_for_test", 0.0)
		main.call("add_screen_shake_for_test", 12.0)
		_expect(is_equal_approx(float(main.call("get_screen_shake_strength_for_test")), 0.0), "Zero screen shake intensity should suppress camera shake")
		main.call("set_screen_shake_intensity_for_test", 0.5)
		main.call("add_screen_shake_for_test", 12.0)
		_expect(is_equal_approx(float(main.call("get_screen_shake_strength_for_test")), 6.0), "Screen shake intensity should scale camera shake strength")
		main.call("set_screen_shake_intensity_for_test", 1.0)
	if main.has_method("set_combat_text_intensity_for_test") and main.has_method("get_combat_text_intensity_for_test") and main.has_method("get_floating_text_snapshots"):
		_clear_floating_texts()
		await get_tree().process_frame
		main.call("set_combat_text_intensity_for_test", 0.0)
		var muted_text_count := int(main.call("get_floating_text_count"))
		Events.projectile_hit.emit(null, player, 4)
		await get_tree().process_frame
		_expect(int(main.call("get_floating_text_count")) == muted_text_count, "Zero combat text intensity should suppress floating combat text")

		main.call("set_combat_text_intensity_for_test", 0.5)
		Events.projectile_hit.emit(null, player, 4)
		await get_tree().process_frame
		var half_intensity_snapshots: Array = main.call("get_floating_text_snapshots")
		var found_half_intensity_text := false
		for snapshot in half_intensity_snapshots:
			if not (snapshot is Dictionary):
				continue
			if not str(snapshot.get("text", "")).contains("-4"):
				continue
			var text_color: Color = snapshot.get("color", Color.WHITE)
			if is_equal_approx(text_color.a, 0.5):
				found_half_intensity_text = true
				break
		_expect(found_half_intensity_text, "Combat text intensity should scale floating text alpha")
		main.call("set_combat_text_intensity_for_test", 1.0)
		_clear_floating_texts()
		await get_tree().process_frame
	if hud.has_method("get_health_label_text"):
		var low_health_sfx_count_before := int(audio_feedback.call("get_sfx_play_count")) if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count") else -1
		var low_health_id_count_before := int(audio_feedback.call("get_sfx_play_count_for_id_for_test", "low_health")) if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count_for_id_for_test") else -1
		var low_health_entry_hp := maxi(1, ceili(float(player.max_health) * 0.35))
		player.current_health = low_health_entry_hp
		player.health_changed.emit(player.current_health, player.max_health)
		await get_tree().process_frame
		_expect(str(hud.call("get_health_label_text")).contains("!"), "Compact HUD should flag low HP while player is near defeat")
		if hud.has_method("is_low_health_vignette_visible"):
			_expect(bool(hud.call("is_low_health_vignette_visible")), "HUD should show low-health vignette while HP is low")
		if hud.has_method("get_low_health_vignette_alpha_for_test"):
			_expect(float(hud.call("get_low_health_vignette_alpha_for_test")) > 0.0, "HUD low-health vignette should expose visible alpha while HP is low")
		var low_health_entry_target_alpha := float(hud.call("get_low_health_vignette_target_alpha_for_test")) if hud.has_method("get_low_health_vignette_target_alpha_for_test") else 0.0
		if hud.has_method("set_low_health_feedback_intensity") and hud.has_method("is_low_health_vignette_visible"):
			hud.call("set_low_health_feedback_intensity", 0.0)
			_expect(not bool(hud.call("is_low_health_vignette_visible")), "Zero low-health feedback intensity should hide the HUD vignette")
			hud.call("set_low_health_feedback_intensity", 1.0)
			if hud.has_method("get_low_health_vignette_target_alpha_for_test"):
				low_health_entry_target_alpha = float(hud.call("get_low_health_vignette_target_alpha_for_test"))
		var low_health_entry_pulse_speed := float(hud.call("get_low_health_vignette_pulse_speed_for_test")) if hud.has_method("get_low_health_vignette_pulse_speed_for_test") else 0.0
		var low_health_entry_heartbeat_interval := float(audio_feedback.call("get_low_health_heartbeat_interval_for_test")) if audio_feedback != null and audio_feedback.has_method("get_low_health_heartbeat_interval_for_test") else 0.0
		player.current_health = 1
		player.health_changed.emit(player.current_health, player.max_health)
		await get_tree().process_frame
		if hud.has_method("get_low_health_vignette_target_alpha_for_test") and low_health_entry_hp > 1:
			_expect(float(hud.call("get_low_health_vignette_target_alpha_for_test")) > low_health_entry_target_alpha, "Critical HP should intensify low-health vignette target alpha")
		if hud.has_method("get_low_health_vignette_pulse_speed_for_test") and low_health_entry_hp > 1:
			_expect(float(hud.call("get_low_health_vignette_pulse_speed_for_test")) > low_health_entry_pulse_speed, "Critical HP should accelerate low-health vignette pulse speed")
		if audio_feedback != null and audio_feedback.has_method("get_low_health_heartbeat_interval_for_test") and low_health_entry_hp > 1:
			_expect(float(audio_feedback.call("get_low_health_heartbeat_interval_for_test")) < low_health_entry_heartbeat_interval, "Critical HP should shorten low-health heartbeat interval")
		if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count") and low_health_sfx_count_before >= 0:
			_expect(int(audio_feedback.call("get_sfx_play_count")) > low_health_sfx_count_before, "Entering low HP should trigger low-health SFX")
		if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count_for_id_for_test") and low_health_id_count_before >= 0:
			_expect(int(audio_feedback.call("get_sfx_play_count_for_id_for_test", "low_health")) > low_health_id_count_before, "Entering low HP should use the low_health SFX")
	if hud.has_method("is_low_health_active"):
		_expect(bool(hud.call("is_low_health_active")), "HUD should expose active low-health state for tests")
	if hud.has_method("get_health_label_text"):
		var low_health_recover_sfx_count_before := int(audio_feedback.call("get_sfx_play_count")) if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count") else -1
		var low_health_recover_id_count_before := int(audio_feedback.call("get_sfx_play_count_for_id_for_test", "low_health_recover")) if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count_for_id_for_test") else -1
		player.current_health = player.max_health
		player.health_changed.emit(player.current_health, player.max_health)
		await get_tree().process_frame
		_expect(not str(hud.call("get_health_label_text")).contains("!"), "Compact HUD should clear the low HP marker after recovery")
		if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count") and low_health_recover_sfx_count_before >= 0:
			_expect(int(audio_feedback.call("get_sfx_play_count")) > low_health_recover_sfx_count_before, "Leaving low HP should trigger low-health recovery SFX")
		if audio_feedback != null and audio_feedback.has_method("get_sfx_play_count_for_id_for_test") and low_health_recover_id_count_before >= 0:
			_expect(int(audio_feedback.call("get_sfx_play_count_for_id_for_test", "low_health_recover")) > low_health_recover_id_count_before, "Leaving low HP should use the low_health_recover SFX")

	await _wait_for_feedback_cleanup(main, hud, count_before, 2.5)
	var count_after_cleanup := int(main.call("get_floating_text_count"))
	_expect(count_after_cleanup <= count_before, "Floating text should clean itself up after its duration, expected at most %d got %d" % [count_before, count_after_cleanup])
	if hud.has_method("is_damage_flash_visible"):
		_expect(not bool(hud.call("is_damage_flash_visible")), "HUD damage flash should fade out after its duration")
	if hud.has_method("is_low_health_vignette_visible"):
		_expect(not bool(hud.call("is_low_health_vignette_visible")), "HUD low-health vignette should fade out after HP recovery")
	if hud.has_method("get_low_health_vignette_alpha_for_test"):
		_expect(float(hud.call("get_low_health_vignette_alpha_for_test")) <= 0.01, "HUD low-health vignette alpha should settle after HP recovery")
	if hud.has_method("is_armor_break_pulse_active"):
		_expect(not bool(hud.call("is_armor_break_pulse_active")), "HUD Armor break pulse should fade out after its duration")

	await _verify_projectile_hit_feedback_position(main)
	await _verify_projectile_block_feedback_position(main, player, hud)
	await _verify_enemy_projectile_after_owner_death(player)

	get_tree().paused = false
	main.queue_free()
	await get_tree().process_frame
	_finish()


func _wait_for_feedback_cleanup(main: Node, hud: Node, baseline_text_count: int, timeout_seconds: float) -> void:
	var deadline := Time.get_ticks_msec() + int(maxf(timeout_seconds, 0.1) * 1000.0)
	while Time.get_ticks_msec() < deadline:
		var text_clean := int(main.call("get_floating_text_count")) <= baseline_text_count
		var damage_flash_clean := not hud.has_method("is_damage_flash_visible") or not bool(hud.call("is_damage_flash_visible"))
		var low_health_clean := not hud.has_method("is_low_health_vignette_visible") or not bool(hud.call("is_low_health_vignette_visible"))
		var armor_pulse_clean := not hud.has_method("is_armor_break_pulse_active") or not bool(hud.call("is_armor_break_pulse_active"))
		if text_clean and damage_flash_clean and low_health_clean and armor_pulse_clean:
			return
		await get_tree().process_frame


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


func _verify_projectile_hit_feedback_position(main: Node) -> void:
	_clear_floating_texts()
	var hit_position := Vector2(420, -180)
	var enemy := CHASER_SCENE.instantiate()
	get_tree().root.add_child(enemy)
	enemy.global_position = hit_position + Vector2(12, 0)
	await get_tree().process_frame

	var projectile := PROJECTILE_SCENE.instantiate() as Projectile
	get_tree().root.add_child(projectile)
	projectile.global_position = hit_position
	projectile.damage = 5
	projectile.knockback = 0.0
	projectile.crit_chance = 0.0
	projectile.call("_handle_collision", enemy)
	await get_tree().process_frame

	var snapshots: Array = main.call("get_floating_text_snapshots")
	var found_near_hit := false
	for snapshot in snapshots:
		if not (snapshot is Dictionary):
			continue
		if not str(snapshot.get("text", "")).contains("-5"):
			continue
		var position: Vector2 = snapshot.get("position", Vector2.ZERO)
		if position.distance_to(hit_position) <= 28.0:
			found_near_hit = true
			break
	_expect(found_near_hit, "Enemy damage floating text should appear near the projectile hit position")

	if is_instance_valid(enemy):
		enemy.queue_free()
	if is_instance_valid(projectile):
		projectile.queue_free()
	_clear_floating_texts()


func _verify_projectile_block_feedback_position(main: Node, player: Player, hud: Node) -> void:
	_clear_floating_texts()
	await get_tree().process_frame

	var block_position := player.global_position + Vector2(92, -28)
	var weapon_label_color_before := Color.TRANSPARENT
	var loadout_color_before := Color.TRANSPARENT
	if hud.has_method("get_weapon_label_color_for_test"):
		weapon_label_color_before = hud.call("get_weapon_label_color_for_test")
	if hud.has_method("get_weapon_slot_active_loadout_color_for_test"):
		loadout_color_before = hud.call("get_weapon_slot_active_loadout_color_for_test")
	Events.player_projectile_blocked.emit(player, null, 2, block_position)
	await get_tree().process_frame

	var snapshots: Array = main.call("get_floating_text_snapshots")
	var found_near_block := false
	for snapshot in snapshots:
		if not (snapshot is Dictionary):
			continue
		if not str(snapshot.get("text", "")).contains("BLOCK x2"):
			continue
		var position: Vector2 = snapshot.get("position", Vector2.ZERO)
		if position.distance_to(block_position) <= 32.0:
			found_near_block = true
			break
	_expect(found_near_block, "Projectile block floating text should appear near the blocked projectile position")
	_expect(_has_projectile_block_spark_near(block_position, 2), "Projectile block spark should appear near the blocked projectile position")
	if hud.has_method("is_weapon_block_pulse_active"):
		_expect(bool(hud.call("is_weapon_block_pulse_active")), "Projectile block should trigger a HUD weapon block pulse")
	if hud.has_method("get_weapon_label_color_for_test"):
		var weapon_label_color_after: Color = hud.call("get_weapon_label_color_for_test")
		_expect(_color_delta(weapon_label_color_before, weapon_label_color_after) > 0.03, "Projectile block should tint the weapon label during block pulse")
	if hud.has_method("get_weapon_slot_active_loadout_color_for_test"):
		var loadout_color_after: Color = hud.call("get_weapon_slot_active_loadout_color_for_test")
		_expect(_color_delta(loadout_color_before, loadout_color_after) > 0.03, "Projectile block should tint the active weapon loadout slot during block pulse")

	await get_tree().create_timer(0.24).timeout
	await get_tree().process_frame
	_expect(_get_projectile_block_spark_count() == 0, "Projectile block spark should clean itself up after its duration")
	_clear_floating_texts()


func _verify_enemy_projectile_after_owner_death(player: Player) -> void:
	_clear_enemy_projectiles()
	_clear_enemies()
	player.set("_is_dead", false)
	player.current_health = player.max_health
	player.current_shield = 0
	player.set("_invulnerability_timer", 0.0)
	player.global_position = Vector2(-1200, -760)
	await get_tree().physics_frame
	await get_tree().process_frame

	var shooter := SHOOTER_SCENE.instantiate()
	get_tree().root.add_child(shooter)
	shooter.global_position = player.global_position + Vector2(-220, 0)
	await get_tree().process_frame
	_expect(shooter.has_method("get_damage_source_summary"), "Enemy should expose a damage source summary")
	var shooter_source: Dictionary = shooter.call("get_damage_source_summary")
	_expect(str(shooter_source.get("source_id", "")) == "shooter_enemy", "Enemy source summary should expose stable scene id")
	_expect(str(shooter_source.get("source_type", "")) == "enemy", "Enemy source summary should classify enemy source")
	_expect(str(shooter_source.get("source_threat_intel", "")).contains("Ranged Pressure"), "Enemy source summary should expose behavior threat intel")
	_expect((shooter_source.get("source_counter_tags", []) as Array).has("guard"), "Enemy source summary should expose counter build tags")

	var projectile := ENEMY_PROJECTILE_SCENE.instantiate() as EnemyProjectile
	get_tree().root.add_child(projectile)
	projectile.global_position = player.global_position + Vector2(-96, 0)
	projectile.call("launch", Vector2.RIGHT, 720.0, 1, shooter)
	shooter.call("apply_damage", 9999, null, Vector2.ZERO, 0.0)
	await get_tree().process_frame

	var start_health := player.current_health
	player.set("_invulnerability_timer", 0.0)
	for index in range(8):
		await get_tree().physics_frame
		await get_tree().process_frame
	_expect(player.current_health == start_health - 1, "Enemy projectile should safely damage player after its owner dies")
	var last_damage: Dictionary = player.call("get_last_damage_summary")
	_expect(str(last_damage.get("source_name", "")) == "Shooter", "Enemy projectile should preserve owner display name after owner death")
	_expect(str(last_damage.get("source_type", "")) == "enemy", "Enemy projectile should preserve owner source type after owner death")
	_expect(str(last_damage.get("source_id", "")) == "shooter_enemy", "Enemy projectile should preserve stable owner source id after owner death")
	_expect(str(last_damage.get("source_scene", "")).ends_with("ShooterEnemy.tscn"), "Enemy projectile should preserve owner scene path after owner death")

	_clear_enemy_projectiles()
	_clear_enemies()


func _clear_floating_texts() -> void:
	for node in get_tree().get_nodes_in_group("floating_text"):
		if is_instance_valid(node):
			node.queue_free()


func _has_projectile_block_spark_near(position: Vector2, expected_blocked_count: int) -> bool:
	for node in get_tree().get_nodes_in_group("projectile_block_spark"):
		var spark := node as Node2D
		if spark == null or not is_instance_valid(spark) or spark.is_queued_for_deletion():
			continue
		if spark.global_position.distance_to(position) > 12.0:
			continue
		if spark.has_method("get_blocked_count_for_test") and int(spark.call("get_blocked_count_for_test")) != expected_blocked_count:
			continue
		if spark.has_method("get_visual_alpha_for_test") and float(spark.call("get_visual_alpha_for_test")) <= 0.0:
			continue
		return true
	return false


func _get_projectile_block_spark_count() -> int:
	var count := 0
	for node in get_tree().get_nodes_in_group("projectile_block_spark"):
		if is_instance_valid(node) and not node.is_queued_for_deletion():
			count += 1
	return count


func _color_delta(a: Color, b: Color) -> float:
	return absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) + absf(a.a - b.a)


func _clear_enemy_projectiles() -> void:
	for projectile in get_tree().get_nodes_in_group("enemy_projectiles"):
		if is_instance_valid(projectile):
			projectile.queue_free()


func _clear_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy):
			enemy.queue_free()


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

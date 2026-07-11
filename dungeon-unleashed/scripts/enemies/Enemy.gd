extends CharacterBody2D
class_name Enemy

signal died(enemy: Enemy)

const DEATH_BURST_SCENE := preload("res://scenes/effects/DeathBurst.tscn")
const DANGER_WARNING_SCENE := preload("res://scenes/effects/DangerWarning.tscn")
const ENEMY_ACTION_CUE_SCRIPT := preload("res://scripts/effects/EnemyActionCue.gd")
const ELITE_AURA_SCRIPT := preload("res://scripts/effects/EliteAura.gd")
const PLAYER_BODY_COLLISION_BIT := 1

enum BehaviorType {
	CHASER,
	SHOOTER,
	CHARGER,
	BOMBER,
	SUMMONER,
	SHIELDED,
	STRAFER,
	ZONER,
	SUPPORT,
}

@export var display_name: String = "Chaser"
@export var source_id: StringName = &""
@export var behavior_type: BehaviorType = BehaviorType.CHASER
@export var max_health: int = 3
@export var move_speed: float = 95.0
@export var contact_damage: int = 1
@export var knockback_decay: float = 900.0
@export var attack_damage: int = 1
@export var attack_cooldown: float = 1.4
@export var attack_range: float = 280.0
@export var preferred_range: float = 210.0
@export var projectile_scene: PackedScene = preload("res://scenes/projectiles/EnemyProjectile.tscn")
@export var projectile_speed: float = 340.0
@export var projectile_count: int = 1
@export var projectile_spread_degrees: float = 0.0
@export var projectile_attack_windup: float = 0.18
@export var charge_speed: float = 360.0
@export var charge_windup: float = 0.35
@export var charge_duration: float = 0.38
@export var charge_recover: float = 0.55
@export var self_destruct_radius: float = 86.0
@export var self_destruct_windup: float = 0.7
@export var summon_scene: PackedScene
@export var summon_count: int = 2
@export var summon_spacing: float = 34.0
@export var max_active_summons: int = 4
@export var min_summon_distance_from_player: float = 145.0
@export var utility_action_windup: float = 0.5
@export var summon_warning_radius: float = 28.0
@export var spawn_contact_grace_duration: float = 0.45
@export var shield_front_arc_degrees: float = 120.0
@export_range(0.0, 1.0, 0.05) var shield_front_damage_multiplier: float = 0.25
@export var shield_bash_range: float = 105.0
@export var shield_bash_speed: float = 285.0
@export var shield_bash_windup: float = 0.38
@export var shield_bash_duration: float = 0.24
@export var shield_bash_recover: float = 0.46
@export var strafe_clockwise: bool = true
@export var zone_warning_radius: float = 84.0
@export var zone_warning_duration: float = 0.65
@export var support_range: float = 260.0
@export var support_heal_amount: int = 1
@export var death_spawn_scene: PackedScene
@export var death_spawn_count: int = 0
@export var death_spawn_spacing: float = 42.0

@onready var visual: CanvasItem = $Visual
@onready var action_sprite: Sprite2D = get_node_or_null("ActionSprite") as Sprite2D
@onready var shield_visual: CanvasItem = get_node_or_null("ShieldVisual") as CanvasItem

var current_health: int
var is_elite := false
var elite_modifier_id: StringName = &""
var elite_modifier_display_name := ""
var elite_combat_trait: StringName = &"none"
var elite_death_explosion_radius := 0.0
var elite_death_explosion_damage := 0
var _elite_aura: Node2D
var _elite_trait_interval := 0.0
var _elite_trait_timer := 0.0
var _elite_trait_windup := 0.0
var _elite_trait_windup_timer := 0.0
var _elite_trait_duration := 0.0
var _elite_trait_active_timer := 0.0
var _elite_trait_radius := 0.0
var _elite_trait_strength := 1.0
var _elite_trait_color := Color.WHITE
var _elite_damage_taken_multiplier := 1.0
var _elite_knockback_multiplier := 1.0
var _elite_volatile_triggered := false
var target: Node2D
var _dead := false
var _knockback_velocity := Vector2.ZERO
var _attack_timer := 0.0
var _charge_state := 0
var _charge_timer := 0.0
var _charge_direction := Vector2.ZERO
var _projectile_windup_timer := 0.0
var _projectile_windup_duration := 0.0
var _projectile_windup_direction := Vector2.ZERO
var _utility_windup_timer := 0.0
var _utility_windup_duration := 0.0
var _utility_action := ""
var _utility_direction := Vector2.ZERO
var _pending_summon_positions := PackedVector2Array()
var _shield_bash_timer := 0.0
var _shield_bash_recover_timer := 0.0
var _shield_bash_direction := Vector2.ZERO
var _action_sprite_recovery_timer := 0.0
var _visual_action_timer := 0.0
var _visual_action_duration := 0.0
var _movement_animation_time := 0.0
var _is_self_destructing := false
var _self_destruct_timer := 0.0
var _spawn_contact_grace_timer := 0.0
var _summoned_minions: Array[Node] = []
var _active_status_effects: Dictionary = {}


func _ready() -> void:
	add_to_group("enemies")
	add_to_group("enemy_%s" % display_name.to_snake_case())
	collision_mask = collision_mask & ~PLAYER_BODY_COLLISION_BIT
	current_health = max_health
	_attack_timer = randf_range(0.25, attack_cooldown)
	_spawn_contact_grace_timer = maxf(spawn_contact_grace_duration, 0.0)
	_configure_action_sprite()
	_find_target()


func _physics_process(delta: float) -> void:
	if _dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	_tick_status_effects(delta)
	if _dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	_tick_elite_trait(delta)

	if target == null or not is_instance_valid(target):
		_find_target()

	_tick_attack_timer(delta)
	_tick_action_sprite(delta)

	var behavior_velocity := Vector2.ZERO
	if _tick_projectile_windup(delta):
		behavior_velocity = Vector2.ZERO
	elif _tick_utility_windup(delta):
		behavior_velocity = Vector2.ZERO
	elif _can_chase_target():
		match behavior_type:
			BehaviorType.SHOOTER:
				behavior_velocity = _update_shooter()
			BehaviorType.CHARGER:
				behavior_velocity = _update_charger(delta)
			BehaviorType.BOMBER:
				behavior_velocity = _update_bomber(delta)
			BehaviorType.SUMMONER:
				behavior_velocity = _update_summoner()
			BehaviorType.SHIELDED:
				behavior_velocity = _update_shielded(delta)
			BehaviorType.STRAFER:
				behavior_velocity = _update_strafer()
			BehaviorType.ZONER:
				behavior_velocity = _update_zoner()
			BehaviorType.SUPPORT:
				behavior_velocity = _update_support()
			_:
				behavior_velocity = _update_chaser()

	velocity = behavior_velocity * get_status_move_speed_multiplier() * get_elite_move_speed_multiplier() + _knockback_velocity
	_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
	move_and_slide()


func is_dead() -> bool:
	return _dead


func can_deal_contact_damage() -> bool:
	return not _dead and _spawn_contact_grace_timer <= 0.0


func get_damage_source_summary() -> Dictionary:
	return {
		"source_id": _get_damage_source_id(),
		"source_name": display_name,
		"source_type": "enemy",
		"source_scene": scene_file_path,
		"elite_modifier_id": str(elite_modifier_id),
		"elite_modifier_name": elite_modifier_display_name,
		"elite_combat_trait": str(elite_combat_trait),
		"source_review_tip": _get_damage_source_review_tip(),
		"source_threat_intel": _get_damage_source_threat_intel(),
		"source_counter_tags": _get_damage_source_counter_tags(),
	}


func get_attack_telegraph_summary() -> Dictionary:
	return {
		"behavior": str(BehaviorType.keys()[behavior_type]).to_lower(),
		"utility_action": _utility_action,
		"utility_windup_remaining": _utility_windup_timer,
		"projectile_windup_remaining": _projectile_windup_timer,
		"pending_summon_positions": _pending_summon_positions.duplicate(),
		"shield_bash_active": _shield_bash_timer > 0.0,
		"shield_bash_recovering": _shield_bash_recover_timer > 0.0,
		"action_sprite": get_action_sprite_summary(),
	}


func get_action_sprite_summary() -> Dictionary:
	return {
		"enabled": action_sprite != null and action_sprite.texture != null,
		"frame": action_sprite.frame if action_sprite != null else -1,
		"hframes": action_sprite.hframes if action_sprite != null else 0,
		"vframes": action_sprite.vframes if action_sprite != null else 0,
		"fallback_hidden": visual != null and not visual.visible,
		"shield_fallback_hidden": shield_visual == null or not shield_visual.visible,
	}


func _get_damage_source_review_tip() -> String:
	match behavior_type:
		BehaviorType.SHOOTER, BehaviorType.STRAFER, BehaviorType.ZONER:
			return "Break line of sight first, then clear ranged pressure before crossing open lanes."
		BehaviorType.CHARGER:
			return "Bait the charge windup sideways, then punish during the recovery window."
		BehaviorType.BOMBER:
			return "Respect the explosion tell and leave space before finishing close-range trades."
		BehaviorType.SUMMONER, BehaviorType.SUPPORT:
			return "Remove support units before they multiply pressure or extend the fight."
		BehaviorType.SHIELDED:
			return "Bait the short shield bash sideways, then flank the guarded arc or use piercing and splash damage."
	return "Thin ranged pressure first, then isolate chargers before opening close-range trades."


func _get_damage_source_threat_intel() -> String:
	var source_id := _get_damage_source_id()
	match behavior_type:
		BehaviorType.SHOOTER, BehaviorType.STRAFER, BehaviorType.ZONER:
			return "Enemy Threat / Ranged Pressure | Tell projectile lanes | Counter break line of sight | Codex death_source_%s" % source_id
		BehaviorType.CHARGER:
			return "Enemy Threat / Charger | Tell windup line | Counter sidestep then punish recovery | Codex death_source_%s" % source_id
		BehaviorType.BOMBER:
			return "Enemy Threat / Explosion | Tell blast windup | Counter leave space before trading | Codex death_source_%s" % source_id
		BehaviorType.SUMMONER, BehaviorType.SUPPORT:
			return "Enemy Threat / Support | Tell reinforcement pressure | Counter remove support first | Codex death_source_%s" % source_id
		BehaviorType.SHIELDED:
			return "Enemy Threat / Shield | Tell blue bash lane and guarded front arc | Counter sidestep then flank or pierce | Codex death_source_%s" % source_id
	return "Enemy Threat / Contact | Tell chase path | Counter isolate before crossing open lanes | Codex death_source_%s" % source_id


func _get_damage_source_counter_tags() -> Array:
	match behavior_type:
		BehaviorType.SHOOTER, BehaviorType.STRAFER, BehaviorType.ZONER:
			return ["guard", "line_clear", "precision"]
		BehaviorType.CHARGER:
			return ["speed", "crowd_control", "close_range"]
		BehaviorType.BOMBER:
			return ["speed", "survival", "precision"]
		BehaviorType.SUMMONER, BehaviorType.SUPPORT:
			return ["line_clear", "crowd_control", "damage"]
		BehaviorType.SHIELDED:
			return ["piercing", "guard", "melee"]
	return ["survival", "damage"]


func _get_damage_source_id() -> String:
	var explicit_id := str(source_id).strip_edges()
	if not explicit_id.is_empty():
		return explicit_id.to_snake_case()

	var scene_path := scene_file_path.strip_edges()
	if not scene_path.is_empty():
		return scene_path.get_file().get_basename().to_snake_case()

	var resolved_name := display_name.strip_edges()
	if not resolved_name.is_empty():
		return resolved_name.to_snake_case()

	if not name.is_empty():
		return name.to_snake_case()
	return "enemy"


func heal(amount: int) -> void:
	if _dead:
		return

	var heal_amount := maxi(amount, 0)
	if heal_amount <= 0 or current_health >= max_health:
		return

	current_health = mini(current_health + heal_amount, max_health)
	_flash(Color(0.28, 1.0, 0.58, 1.0), 0.14)


func apply_status_effect(
	effect_id: String,
	duration: float,
	damage_per_tick: int = 0,
	tick_interval: float = 1.0,
	slow_multiplier: float = 1.0,
	source: Node = null
) -> void:
	if _dead or effect_id.is_empty() or effect_id == "none" or duration <= 0.0:
		return

	var raw_entry = _active_status_effects.get(effect_id, {})
	var entry: Dictionary = raw_entry if raw_entry is Dictionary else {}
	var resolved_interval := maxf(tick_interval, 0.1)
	entry["remaining"] = maxf(float(entry.get("remaining", 0.0)), duration)
	entry["damage_per_tick"] = maxi(int(entry.get("damage_per_tick", 0)), damage_per_tick)
	entry["tick_interval"] = resolved_interval
	entry["tick_timer"] = minf(float(entry.get("tick_timer", resolved_interval)), resolved_interval)
	entry["slow_multiplier"] = minf(float(entry.get("slow_multiplier", 1.0)), clampf(slow_multiplier, 0.1, 1.0))
	entry["source"] = source
	_active_status_effects[effect_id] = entry

	match effect_id:
		"burn":
			_flash(Color(1.0, 0.38, 0.12, 1.0), 0.12)
		"slow":
			_flash(Color(0.35, 0.72, 1.0, 1.0), 0.12)


func has_status_effect(effect_id: String) -> bool:
	return _active_status_effects.has(effect_id)


func get_status_remaining(effect_id: String) -> float:
	if not _active_status_effects.has(effect_id):
		return 0.0
	var raw_entry = _active_status_effects.get(effect_id, {})
	var entry: Dictionary = raw_entry if raw_entry is Dictionary else {}
	return maxf(float(entry.get("remaining", 0.0)), 0.0)


func get_status_move_speed_multiplier() -> float:
	var multiplier := 1.0
	for entry in _active_status_effects.values():
		if entry is Dictionary:
			multiplier = minf(multiplier, float((entry as Dictionary).get("slow_multiplier", 1.0)))
	return clampf(multiplier, 0.1, 1.0)


func _tick_status_effects(delta: float) -> void:
	if _active_status_effects.is_empty():
		return

	var expired: Array[String] = []
	for effect_id in _active_status_effects.keys():
		var raw_entry = _active_status_effects.get(effect_id, {})
		var entry: Dictionary = raw_entry if raw_entry is Dictionary else {}
		var remaining := maxf(float(entry.get("remaining", 0.0)) - delta, 0.0)
		entry["remaining"] = remaining

		var tick_damage := maxi(int(entry.get("damage_per_tick", 0)), 0)
		if tick_damage > 0:
			var interval := maxf(float(entry.get("tick_interval", 1.0)), 0.1)
			var tick_timer := maxf(float(entry.get("tick_timer", interval)) - delta, 0.0)
			if tick_timer <= 0.0:
				apply_damage(tick_damage, _get_safe_status_source(entry), Vector2.ZERO, 0.0)
				if _dead:
					return
				tick_timer = interval
			entry["tick_timer"] = tick_timer

		if remaining <= 0.0:
			expired.append(str(effect_id))
		else:
			_active_status_effects[effect_id] = entry

	for effect_id in expired:
		_active_status_effects.erase(effect_id)


func _get_safe_status_source(entry: Dictionary) -> Node:
	var source = entry.get("source", null)
	if source is Node and is_instance_valid(source) and not (source as Node).is_queued_for_deletion():
		return source
	return null


func apply_elite_modifiers(health_multiplier: float, damage_multiplier: float, death_explosion_radius: float, death_explosion_damage: int) -> void:
	_apply_elite_values(
		"Elite",
		&"default",
		"Elite",
		health_multiplier,
		damage_multiplier,
		1.0,
		1.0,
		1.0,
		death_explosion_radius,
		death_explosion_damage,
		Color(1.0, 0.62, 0.18, 1.0),
		"ring",
		30.0,
		2.0,
		"none",
		0.0,
		0.5,
		0.8,
		90.0,
		1.0,
		1.18
	)


func apply_elite_profile(profile: Resource) -> void:
	if profile == null:
		return

	var display := _get_profile_string(profile, "display_name", "Elite")
	var prefix := _get_profile_string(profile, "name_prefix", display)
	_apply_elite_values(
		prefix,
		StringName(_get_profile_string(profile, "id", "elite")),
		display,
		_get_profile_float(profile, "health_multiplier", 1.5),
		_get_profile_float(profile, "damage_multiplier", 1.2),
		_get_profile_float(profile, "move_speed_multiplier", 1.0),
		_get_profile_float(profile, "attack_cooldown_multiplier", 1.0),
		_get_profile_float(profile, "projectile_speed_multiplier", 1.0),
		_get_profile_float(profile, "death_explosion_radius", 0.0),
		_get_profile_int(profile, "death_explosion_damage", 0),
		_get_profile_color(profile, "visual_color", Color(1.0, 0.62, 0.18, 1.0)),
		_get_profile_string(profile, "visual_pattern", "ring"),
		_get_profile_float(profile, "aura_radius", 30.0),
		_get_profile_float(profile, "pulse_speed", 2.0),
		_get_profile_string(profile, "combat_trait", "none"),
		_get_profile_float(profile, "trait_interval", 0.0),
		_get_profile_float(profile, "trait_windup", 0.5),
		_get_profile_float(profile, "trait_duration", 0.8),
		_get_profile_float(profile, "trait_radius", 90.0),
		_get_profile_float(profile, "trait_strength", 1.0),
		_get_profile_float(profile, "scale_multiplier", 1.18)
	)


func _apply_elite_values(
	name_prefix: String,
	modifier_id: StringName,
	modifier_display_name: String,
	health_multiplier: float,
	damage_multiplier: float,
	move_speed_multiplier: float,
	attack_cooldown_multiplier: float,
	projectile_speed_multiplier: float,
	death_explosion_radius: float,
	death_explosion_damage: int,
	visual_color: Color,
	visual_pattern: String,
	aura_radius: float,
	pulse_speed: float,
	combat_trait: String,
	trait_interval: float,
	trait_windup: float,
	trait_duration: float,
	trait_radius: float,
	trait_strength: float,
	scale_multiplier: float
) -> void:
	if is_elite:
		return

	is_elite = true
	elite_modifier_id = modifier_id
	elite_modifier_display_name = modifier_display_name
	var prefix := name_prefix if not name_prefix.is_empty() else "Elite"
	display_name = "%s %s" % [prefix, display_name]
	max_health = maxi(roundi(float(max_health) * maxf(health_multiplier, 1.0)), max_health + 1)
	current_health = max_health
	contact_damage = maxi(roundi(float(contact_damage) * maxf(damage_multiplier, 1.0)), contact_damage)
	attack_damage = maxi(roundi(float(attack_damage) * maxf(damage_multiplier, 1.0)), attack_damage)
	move_speed *= maxf(move_speed_multiplier, 0.0)
	attack_cooldown = maxf(attack_cooldown * maxf(attack_cooldown_multiplier, 0.05), 0.05)
	projectile_speed *= maxf(projectile_speed_multiplier, 0.0)
	elite_death_explosion_radius = maxf(death_explosion_radius, 0.0)
	elite_death_explosion_damage = maxi(death_explosion_damage, 0)
	scale *= maxf(scale_multiplier, 1.0)
	if action_sprite != null and action_sprite.texture != null:
		action_sprite.modulate = action_sprite.modulate.lerp(visual_color, 0.32)
	elif visual != null:
		visual.modulate = visual_color
	_configure_elite_aura(visual_pattern, visual_color, aura_radius, pulse_speed)
	_configure_elite_combat_trait(combat_trait, trait_interval, trait_windup, trait_duration, trait_radius, trait_strength, visual_color)


func _configure_elite_aura(visual_pattern: String, visual_color: Color, aura_radius: float, pulse_speed: float) -> void:
	if _elite_aura == null or not is_instance_valid(_elite_aura):
		_elite_aura = ELITE_AURA_SCRIPT.new() as Node2D
		_elite_aura.name = "EliteAura"
		add_child(_elite_aura)
		move_child(_elite_aura, 0)
	_elite_aura.call("configure", visual_pattern, visual_color, aura_radius, pulse_speed)


func get_elite_visual_summary() -> Dictionary:
	if _elite_aura == null or not is_instance_valid(_elite_aura) or not _elite_aura.has_method("get_visual_summary"):
		return {
			"enabled": false,
			"pattern": "",
		}
	return _elite_aura.call("get_visual_summary") as Dictionary


func _configure_elite_combat_trait(
	combat_trait: String,
	trait_interval: float,
	trait_windup: float,
	trait_duration: float,
	trait_radius: float,
	trait_strength: float,
	visual_color: Color
) -> void:
	elite_combat_trait = StringName(combat_trait if not combat_trait.is_empty() else "none")
	_elite_trait_interval = maxf(trait_interval, 0.0)
	_elite_trait_timer = _elite_trait_interval
	_elite_trait_windup = maxf(trait_windup, 0.05)
	_elite_trait_duration = maxf(trait_duration, 0.0)
	_elite_trait_radius = maxf(trait_radius, 24.0)
	_elite_trait_strength = maxf(trait_strength, 0.0)
	_elite_trait_color = visual_color
	match str(elite_combat_trait):
		"guarded_core":
			_elite_damage_taken_multiplier = clampf(_elite_trait_strength, 0.1, 1.0)
		"focused_fire":
			var projectile_bonus := maxi(roundi(_elite_trait_strength), 1)
			projectile_count += projectile_bonus
			projectile_spread_degrees = maxf(projectile_spread_degrees, 8.0 * float(projectile_bonus))
			projectile_attack_windup = maxf(projectile_attack_windup, 0.28)
		"unstoppable":
			_elite_knockback_multiplier = clampf(_elite_trait_strength, 0.0, 1.0)
			contact_damage += 1


func get_elite_trait_summary() -> Dictionary:
	return {
		"enabled": is_elite and str(elite_combat_trait) != "none",
		"id": str(elite_combat_trait),
		"interval": _elite_trait_interval,
		"timer": _elite_trait_timer,
		"windup": _elite_trait_windup,
		"windup_remaining": _elite_trait_windup_timer,
		"duration": _elite_trait_duration,
		"active_remaining": _elite_trait_active_timer,
		"radius": _elite_trait_radius,
		"strength": _elite_trait_strength,
		"damage_taken_multiplier": _elite_damage_taken_multiplier,
		"knockback_multiplier": _elite_knockback_multiplier,
		"volatile_triggered": _elite_volatile_triggered,
		"projectile_count": projectile_count,
	}


func get_elite_move_speed_multiplier() -> float:
	if str(elite_combat_trait) == "overclock" and _elite_trait_active_timer > 0.0:
		return maxf(_elite_trait_strength, 1.0)
	return 1.0


func _tick_elite_trait(delta: float) -> void:
	if not is_elite or str(elite_combat_trait) == "none":
		return
	if _elite_trait_active_timer > 0.0:
		_elite_trait_active_timer = maxf(_elite_trait_active_timer - delta, 0.0)
		return
	if _elite_trait_windup_timer > 0.0:
		_elite_trait_windup_timer = maxf(_elite_trait_windup_timer - delta, 0.0)
		if _elite_trait_windup_timer <= 0.0 and str(elite_combat_trait) == "overclock":
			_elite_trait_active_timer = maxf(_elite_trait_duration, 0.1)
		return
	if _elite_trait_interval <= 0.0:
		return
	_elite_trait_timer = maxf(_elite_trait_timer - delta, 0.0)
	if _elite_trait_timer > 0.0:
		return
	_elite_trait_timer = _elite_trait_interval
	match str(elite_combat_trait):
		"scorch_pulse":
			_spawn_elite_trait_warning(&"elite_scorch", maxi(roundi(_elite_trait_strength), 1))
		"overclock":
			_elite_trait_windup_timer = _elite_trait_windup
			_spawn_elite_trait_warning(&"elite_overclock", 0)


func _spawn_elite_trait_warning(purpose: StringName, warning_damage: int) -> void:
	var warning := DANGER_WARNING_SCENE.instantiate() as Node2D
	if warning == null:
		return
	get_tree().current_scene.add_child(warning)
	warning.global_position = global_position
	warning.call(
		"configure_circle",
		_elite_trait_radius,
		_elite_trait_windup,
		Color(_elite_trait_color.r, _elite_trait_color.g, _elite_trait_color.b, 0.34),
		maxi(warning_damage, 0),
		self,
		purpose
	)


func _update_elite_health_trait() -> void:
	if str(elite_combat_trait) != "volatile_core" or _elite_volatile_triggered or current_health <= 0:
		return
	if current_health > ceili(float(max_health) * 0.5):
		return
	_elite_volatile_triggered = true
	attack_cooldown = maxf(attack_cooldown * clampf(_elite_trait_strength, 0.35, 0.95), 0.05)
	move_speed *= 1.15
	_attack_timer = minf(_attack_timer, attack_cooldown)
	_spawn_elite_trait_warning(&"elite_volatile_core", 0)


func _get_profile_string(profile: Resource, property_name: String, fallback: String) -> String:
	var value = profile.get(property_name)
	if value == null:
		return fallback
	var text := str(value)
	if text.is_empty():
		return fallback
	return text


func _get_profile_float(profile: Resource, property_name: String, fallback: float) -> float:
	var value = profile.get(property_name)
	if value == null:
		return fallback
	return float(value)


func _get_profile_int(profile: Resource, property_name: String, fallback: int) -> int:
	var value = profile.get(property_name)
	if value == null:
		return fallback
	return int(value)


func _get_profile_color(profile: Resource, property_name: String, fallback: Color) -> Color:
	var value = profile.get(property_name)
	if value is Color:
		return value
	return fallback


func apply_damage(amount: int, source: Node = null, knockback_direction: Vector2 = Vector2.ZERO, knockback_force: float = 0.0) -> void:
	if _dead:
		return

	var final_amount := _calculate_damage_after_defense(amount, knockback_direction)
	if final_amount > 0 and _elite_damage_taken_multiplier < 1.0:
		final_amount = maxi(roundi(float(final_amount) * _elite_damage_taken_multiplier), 1)
	if final_amount <= 0:
		_flash(Color(0.35, 0.72, 1.0, 1.0), 0.12)
		return

	current_health = maxi(current_health - final_amount, 0)
	if knockback_direction.length_squared() > 0.001 and knockback_force > 0.0:
		_knockback_velocity += knockback_direction.normalized() * knockback_force * _elite_knockback_multiplier

	Events.enemy_damaged.emit(self, final_amount)
	_flash(Color(1.0, 0.92, 0.45, 1.0), 0.1)
	_update_elite_health_trait()

	if current_health <= 0:
		_die()


func _find_target() -> void:
	target = get_tree().get_first_node_in_group("player") as Node2D


func _can_chase_target() -> bool:
	if target == null or not is_instance_valid(target):
		return false

	if target.has_method("is_alive") and not target.call("is_alive"):
		return false

	return true


func _tick_attack_timer(delta: float) -> void:
	if _attack_timer > 0.0:
		_attack_timer = maxf(_attack_timer - delta, 0.0)
	if _spawn_contact_grace_timer > 0.0:
		_spawn_contact_grace_timer = maxf(_spawn_contact_grace_timer - delta, 0.0)


func _update_chaser() -> Vector2:
	var direction := _direction_to_target()
	if direction.length_squared() > 0.001:
		rotation = direction.angle()
	return direction * move_speed


func _update_shooter() -> Vector2:
	var offset := target.global_position - global_position
	var distance := offset.length()
	var direction := offset.normalized() if distance > 0.001 else Vector2.RIGHT
	rotation = direction.angle()

	if distance <= attack_range and _attack_timer <= 0.0:
		_start_projectile_windup(direction)

	if distance < preferred_range * 0.75:
		return -direction * move_speed * 0.75
	if distance > preferred_range * 1.2:
		return direction * move_speed * 0.65
	return Vector2.ZERO


func _update_charger(delta: float) -> Vector2:
	var direction := _direction_to_target()
	var distance := global_position.distance_to(target.global_position)
	if direction.length_squared() > 0.001:
		rotation = direction.angle()

	match _charge_state:
		0:
			if distance <= attack_range and _attack_timer <= 0.0:
				_charge_state = 1
				_charge_timer = charge_windup
				_charge_direction = direction
				_attack_timer = attack_cooldown
				_spawn_charge_warning(_charge_direction)
				_flash(Color(1.0, 0.55, 0.2, 1.0), charge_windup)
				return Vector2.ZERO
			return direction * move_speed * 0.8
		1:
			_charge_timer -= delta
			if _charge_timer <= 0.0:
				_charge_state = 2
				_charge_timer = charge_duration
			return Vector2.ZERO
		2:
			_charge_timer -= delta
			if _charge_timer <= 0.0:
				_charge_state = 3
				_charge_timer = charge_recover
			return _charge_direction * charge_speed
		3:
			_charge_timer -= delta
			if _charge_timer <= 0.0:
				_charge_state = 0
			return Vector2.ZERO

	return Vector2.ZERO


func _update_bomber(delta: float) -> Vector2:
	var direction := _direction_to_target()
	var distance := global_position.distance_to(target.global_position)
	if direction.length_squared() > 0.001:
		rotation = direction.angle()

	if _is_self_destructing:
		_self_destruct_timer -= delta
		var pulse_target: CanvasItem = visual
		if action_sprite != null and action_sprite.visible:
			pulse_target = action_sprite
		if pulse_target != null:
			pulse_target.modulate = Color(1.0, 0.28 + sin(Time.get_ticks_msec() * 0.02) * 0.18, 0.12, 1.0)
		if _self_destruct_timer <= 0.0:
			_self_destruct()
		return Vector2.ZERO

	if distance <= attack_range:
		_is_self_destructing = true
		_self_destruct_timer = self_destruct_windup
		_spawn_self_destruct_warning()
		_flash(Color(1.0, 0.16, 0.08, 1.0), self_destruct_windup)
		return Vector2.ZERO

	return direction * move_speed


func _update_summoner() -> Vector2:
	var offset := target.global_position - global_position
	var distance := offset.length()
	var direction := offset.normalized() if distance > 0.001 else Vector2.RIGHT
	rotation = direction.angle()

	if _attack_timer <= 0.0:
		if _start_summon_windup():
			return Vector2.ZERO
		_attack_timer = 0.25

	if distance < preferred_range:
		return -direction * move_speed * 0.55
	if distance > preferred_range * 1.35:
		return direction * move_speed * 0.45
	return Vector2.ZERO


func _update_shielded(delta: float) -> Vector2:
	var direction := _direction_to_target()
	var distance := global_position.distance_to(target.global_position)
	if direction.length_squared() > 0.001:
		rotation = direction.angle()

	if _shield_bash_timer > 0.0:
		_shield_bash_timer = maxf(_shield_bash_timer - delta, 0.0)
		if _shield_bash_timer <= 0.0:
			_shield_bash_recover_timer = maxf(shield_bash_recover, 0.0)
			return Vector2.ZERO
		return _shield_bash_direction * shield_bash_speed

	if _shield_bash_recover_timer > 0.0:
		_shield_bash_recover_timer = maxf(_shield_bash_recover_timer - delta, 0.0)
		return Vector2.ZERO

	if distance <= shield_bash_range and _attack_timer <= 0.0:
		_start_utility_windup("shield_bash", shield_bash_windup, direction)
		_attack_timer = attack_cooldown + maxf(shield_bash_windup, 0.05)
		_spawn_shield_bash_warning(direction)
		_flash(Color(0.42, 0.82, 1.0, 1.0), maxf(shield_bash_windup, 0.05))
		return Vector2.ZERO
	return direction * move_speed * 0.72


func _update_strafer() -> Vector2:
	var offset := target.global_position - global_position
	var distance := offset.length()
	var direction := offset.normalized() if distance > 0.001 else Vector2.RIGHT
	rotation = direction.angle()

	if distance <= attack_range and _attack_timer <= 0.0:
		_start_projectile_windup(direction)

	var tangent := Vector2(-direction.y, direction.x)
	if not strafe_clockwise:
		tangent = -tangent

	var range_adjust := Vector2.ZERO
	if distance < preferred_range * 0.78:
		range_adjust = -direction * move_speed * 0.7
	elif distance > preferred_range * 1.18:
		range_adjust = direction * move_speed * 0.55

	return tangent * move_speed + range_adjust


func _update_zoner() -> Vector2:
	var offset := target.global_position - global_position
	var distance := offset.length()
	var direction := offset.normalized() if distance > 0.001 else Vector2.RIGHT
	rotation = direction.angle()

	if distance <= attack_range and _attack_timer <= 0.0:
		_spawn_zone_warning(target.global_position)
		_attack_timer = attack_cooldown
		_start_visual_action(zone_warning_duration)
		_flash(Color(0.54, 0.9, 1.0, 1.0), minf(zone_warning_duration, 0.32))

	if distance < preferred_range:
		return -direction * move_speed * 0.55
	if distance > attack_range * 0.92:
		return direction * move_speed * 0.4
	return Vector2.ZERO


func _update_support() -> Vector2:
	var offset := target.global_position - global_position
	var distance := offset.length()
	var direction := offset.normalized() if distance > 0.001 else Vector2.RIGHT
	rotation = direction.angle()

	if _attack_timer <= 0.0:
		if _has_support_target():
			_start_utility_windup("support", utility_action_windup, Vector2.ZERO)
			_attack_timer = attack_cooldown + maxf(utility_action_windup, 0.05)
			_spawn_support_warning()
			_flash(Color(0.3, 1.0, 0.62, 1.0), maxf(utility_action_windup, 0.05))
			return Vector2.ZERO
		_attack_timer = 0.25

	if distance < preferred_range:
		return -direction * move_speed * 0.5
	if distance > preferred_range * 1.35:
		return direction * move_speed * 0.45
	return Vector2.ZERO


func _direction_to_target() -> Vector2:
	if target == null or not is_instance_valid(target):
		return Vector2.ZERO
	var offset := target.global_position - global_position
	if offset.length_squared() <= 0.001:
		return Vector2.ZERO
	return offset.normalized()


func _start_projectile_windup(direction: Vector2) -> void:
	if projectile_scene == null:
		return

	var normalized_direction := direction.normalized() if direction.length_squared() > 0.001 else Vector2.RIGHT
	_projectile_windup_direction = normalized_direction
	_projectile_windup_timer = maxf(projectile_attack_windup, 0.05)
	_projectile_windup_duration = _projectile_windup_timer
	_attack_timer = attack_cooldown + _projectile_windup_timer
	rotation = normalized_direction.angle()
	_spawn_projectile_warnings(normalized_direction)
	_flash(Color(1.0, 0.62, 0.18, 1.0), _projectile_windup_timer)


func _tick_projectile_windup(delta: float) -> bool:
	if _projectile_windup_timer <= 0.0:
		return false

	_projectile_windup_timer = maxf(_projectile_windup_timer - delta, 0.0)
	if _projectile_windup_direction.length_squared() > 0.001:
		rotation = _projectile_windup_direction.angle()

	if _projectile_windup_timer <= 0.0:
		_fire_projectile(_projectile_windup_direction)
		_projectile_windup_direction = Vector2.ZERO
		_projectile_windup_duration = 0.0
		_action_sprite_recovery_timer = maxf(_action_sprite_recovery_timer, 0.16)
	return true


func _start_visual_action(duration: float) -> void:
	_visual_action_duration = maxf(duration, 0.05)
	_visual_action_timer = _visual_action_duration


func _start_utility_windup(action: String, duration: float, direction: Vector2) -> void:
	_utility_action = action
	_utility_windup_timer = maxf(duration, 0.05)
	_utility_windup_duration = _utility_windup_timer
	_utility_direction = direction.normalized() if direction.length_squared() > 0.001 else Vector2.ZERO
	if _utility_direction.length_squared() > 0.001:
		rotation = _utility_direction.angle()
	_spawn_action_cue(action, _utility_windup_timer)
	Events.enemy_action_windup_started.emit(self, action, _utility_windup_timer)


func _spawn_action_cue(action: String, cue_duration: float) -> void:
	var cue := ENEMY_ACTION_CUE_SCRIPT.new() as Node2D
	if cue == null:
		return
	var cue_parent := get_tree().current_scene as Node
	if cue_parent == null:
		cue_parent = get_tree().root
	cue_parent.add_child(cue)
	cue.call("configure", action, cue_duration, self)


func _tick_utility_windup(delta: float) -> bool:
	if _utility_windup_timer <= 0.0 or _utility_action.is_empty():
		return false

	_utility_windup_timer = maxf(_utility_windup_timer - delta, 0.0)
	if _utility_direction.length_squared() > 0.001:
		rotation = _utility_direction.angle()
	if _utility_windup_timer > 0.0:
		return true

	var completed_action := _utility_action
	var completed_direction := _utility_direction
	_utility_action = ""
	_utility_windup_duration = 0.0
	_utility_direction = Vector2.ZERO
	_action_sprite_recovery_timer = 0.2
	match completed_action:
		"summon":
			_summon_minions()
		"support":
			_support_nearby_allies()
		"shield_bash":
			_shield_bash_direction = completed_direction if completed_direction.length_squared() > 0.001 else Vector2.RIGHT.rotated(rotation)
			_shield_bash_timer = maxf(shield_bash_duration, 0.05)
	return true


func _start_summon_windup() -> bool:
	_prune_summons()
	_pending_summon_positions.clear()
	if summon_scene == null or max_active_summons <= 0 or _summoned_minions.size() >= max_active_summons:
		return false

	var remaining_slots := max_active_summons - _summoned_minions.size()
	var count := mini(maxi(summon_count, 1), remaining_slots)
	for index in range(count):
		var angle := TAU * float(index) / float(maxi(count, 1))
		_pending_summon_positions.append(_get_safe_summon_position(angle))
	if _pending_summon_positions.is_empty():
		return false

	_start_utility_windup("summon", utility_action_windup, Vector2.ZERO)
	_attack_timer = attack_cooldown + maxf(utility_action_windup, 0.05)
	_spawn_summon_warnings()
	_flash(Color(0.64, 0.4, 1.0, 1.0), maxf(utility_action_windup, 0.05))
	return true


func _spawn_summon_warnings() -> void:
	for spawn_position in _pending_summon_positions:
		_spawn_utility_circle_warning(
			spawn_position,
			maxf(summon_warning_radius, 12.0),
			maxf(utility_action_windup, 0.05),
			Color(0.62, 0.32, 1.0, 0.34),
			&"summon"
		)


func _spawn_support_warning() -> void:
	_spawn_utility_circle_warning(
		global_position,
		maxf(support_range, 24.0),
		maxf(utility_action_windup, 0.05),
		Color(0.24, 1.0, 0.56, 0.24),
		&"support"
	)


func _spawn_utility_circle_warning(
	position: Vector2,
	warning_radius: float,
	warning_duration: float,
	warning_color: Color,
	purpose: StringName
) -> void:
	if DANGER_WARNING_SCENE == null:
		return
	var warning := DANGER_WARNING_SCENE.instantiate() as Node2D
	if warning == null:
		return
	get_tree().current_scene.add_child(warning)
	warning.global_position = position
	warning.set("target_group", &"")
	warning.call(
		"configure_circle",
		warning_radius,
		warning_duration,
		warning_color,
		0,
		self,
		purpose
	)


func _spawn_shield_bash_warning(direction: Vector2) -> void:
	if DANGER_WARNING_SCENE == null:
		return
	var warning := DANGER_WARNING_SCENE.instantiate() as Node2D
	if warning == null:
		return
	var normalized_direction := direction.normalized() if direction.length_squared() > 0.001 else Vector2.RIGHT
	var warning_length := maxf(shield_bash_speed * shield_bash_duration + 42.0, shield_bash_range)
	get_tree().current_scene.add_child(warning)
	warning.global_position = global_position + normalized_direction * 16.0
	warning.set("target_group", &"")
	warning.call(
		"configure_line",
		warning_length,
		48.0,
		maxf(shield_bash_windup, 0.05),
		normalized_direction.angle(),
		Color(0.3, 0.72, 1.0, 0.34),
		0,
		self,
		&"shield_bash"
	)


func _spawn_projectile_warnings(direction: Vector2) -> void:
	if DANGER_WARNING_SCENE == null:
		return

	var count := maxi(projectile_count, 1)
	var spread := deg_to_rad(maxf(projectile_spread_degrees, 0.0))
	for index in range(count):
		var angle_offset := 0.0
		if count > 1:
			angle_offset = lerpf(-spread * 0.5, spread * 0.5, float(index) / float(count - 1))
		_spawn_projectile_warning(direction.rotated(angle_offset))


func _spawn_projectile_warning(direction: Vector2) -> void:
	var warning := DANGER_WARNING_SCENE.instantiate() as Node2D
	if warning == null:
		return

	var normalized_direction := direction.normalized() if direction.length_squared() > 0.001 else Vector2.RIGHT
	get_tree().current_scene.add_child(warning)
	warning.global_position = global_position + normalized_direction * 22.0
	warning.call(
		"configure_line",
		minf(maxf(attack_range, 180.0), 620.0),
		18.0 if projectile_count <= 1 else 14.0,
		maxf(projectile_attack_windup, 0.05),
		normalized_direction.angle(),
		Color(1.0, 0.5, 0.12, 0.28),
		attack_damage,
		self,
		&"projectile"
	)


func _spawn_charge_warning(direction: Vector2) -> void:
	if DANGER_WARNING_SCENE == null:
		return

	var warning := DANGER_WARNING_SCENE.instantiate() as Node2D
	if warning == null:
		return

	var normalized_direction := direction.normalized() if direction.length_squared() > 0.001 else Vector2.RIGHT
	var warning_length := minf(maxf(charge_speed * charge_duration + 48.0, 160.0), maxf(attack_range, 160.0))
	get_tree().current_scene.add_child(warning)
	warning.global_position = global_position + normalized_direction * 18.0
	warning.call(
		"configure_line",
		warning_length,
		42.0,
		maxf(charge_windup, 0.05),
		normalized_direction.angle(),
		Color(1.0, 0.26, 0.1, 0.34),
		attack_damage,
		self,
		&"charge"
	)


func _fire_projectile(direction: Vector2) -> void:
	if projectile_scene == null:
		return

	var count := maxi(projectile_count, 1)
	var spread := deg_to_rad(maxf(projectile_spread_degrees, 0.0))
	for index in range(count):
		var angle_offset := 0.0
		if count > 1:
			angle_offset = lerpf(-spread * 0.5, spread * 0.5, float(index) / float(count - 1))
		_spawn_projectile(direction.rotated(angle_offset))


func _spawn_projectile(direction: Vector2) -> void:
	var projectile := projectile_scene.instantiate() as Node2D
	if projectile == null:
		return

	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position + direction * 22.0
	projectile.call("launch", direction, projectile_speed, attack_damage, self)


func _spawn_zone_warning(position: Vector2) -> void:
	var warning := DANGER_WARNING_SCENE.instantiate() as Node2D
	if warning == null:
		return

	get_tree().current_scene.add_child(warning)
	warning.global_position = position
	warning.call(
		"configure_circle",
		zone_warning_radius,
		zone_warning_duration,
		Color(0.72, 0.24, 1.0, 0.36),
		attack_damage,
		self,
		&"zone"
	)


func _spawn_self_destruct_warning() -> void:
	if DANGER_WARNING_SCENE == null:
		return

	var warning := DANGER_WARNING_SCENE.instantiate() as Node2D
	if warning == null:
		return

	get_tree().current_scene.add_child(warning)
	warning.global_position = global_position
	warning.set("target_group", &"")
	warning.call(
		"configure_circle",
		self_destruct_radius,
		maxf(self_destruct_windup, 0.05),
		Color(1.0, 0.18, 0.08, 0.44),
		attack_damage,
		self,
		&"self_destruct"
	)


func _support_nearby_allies() -> void:
	var supported := false
	for ally_node in get_tree().get_nodes_in_group("enemies"):
		if ally_node == self or not is_instance_valid(ally_node) or ally_node.is_queued_for_deletion():
			continue
		var ally := ally_node as Enemy
		if ally == null or ally.is_dead():
			continue
		if global_position.distance_to(ally.global_position) > support_range:
			continue
		var before := ally.current_health
		ally.heal(support_heal_amount)
		if ally.current_health > before:
			supported = true

	if supported:
		_flash(Color(0.26, 1.0, 0.62, 1.0), 0.18)


func _has_support_target() -> bool:
	for ally_node in get_tree().get_nodes_in_group("enemies"):
		if ally_node == self or not is_instance_valid(ally_node) or ally_node.is_queued_for_deletion():
			continue
		var ally := ally_node as Enemy
		if ally == null or ally.is_dead() or ally.current_health >= ally.max_health:
			continue
		if global_position.distance_to(ally.global_position) <= support_range:
			return true
	return false


func _summon_minions() -> void:
	_prune_summons()
	if summon_scene == null or max_active_summons <= 0 or _summoned_minions.size() >= max_active_summons:
		_pending_summon_positions.clear()
		return

	var remaining_slots := max_active_summons - _summoned_minions.size()
	var count := mini(maxi(summon_count, 1), remaining_slots)
	for index in range(count):
		var angle := TAU * float(index) / float(maxi(count, 1))
		var minion := summon_scene.instantiate() as Node2D
		if minion == null:
			continue

		get_tree().current_scene.add_child(minion)
		minion.global_position = _pending_summon_positions[index] if index < _pending_summon_positions.size() else _get_safe_summon_position(angle)
		_summoned_minions.append(minion)
		Events.enemy_spawned.emit(minion)
	_pending_summon_positions.clear()


func _get_safe_summon_position(angle: float) -> Vector2:
	var position := global_position + Vector2.RIGHT.rotated(angle) * summon_spacing
	var player := target
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null or not is_instance_valid(player):
		return position

	var minimum_distance := maxf(min_summon_distance_from_player, summon_spacing)
	if position.distance_to(player.global_position) >= minimum_distance:
		return position

	var away := position - player.global_position
	if away.length_squared() <= 0.001:
		away = Vector2.RIGHT.rotated(angle + PI)
	return player.global_position + away.normalized() * minimum_distance


func _prune_summons() -> void:
	var alive: Array[Node] = []
	for minion in _summoned_minions:
		if is_instance_valid(minion) and not minion.is_queued_for_deletion():
			alive.append(minion)
	_summoned_minions = alive


func _self_destruct() -> void:
	if _dead:
		return

	if target != null and is_instance_valid(target):
		var distance := global_position.distance_to(target.global_position)
		if distance <= self_destruct_radius and target.has_method("take_damage"):
			target.call("take_damage", attack_damage, self)

	_spawn_death_effect()
	_apply_elite_death_explosion()
	_spawn_death_minions()
	Events.enemy_died.emit(self)
	died.emit(self)
	_dead = true
	queue_free()


func _calculate_damage_after_defense(amount: int, knockback_direction: Vector2) -> int:
	if behavior_type != BehaviorType.SHIELDED or knockback_direction.length_squared() <= 0.001:
		return amount

	var forward := Vector2.RIGHT.rotated(rotation)
	var incoming_dot := knockback_direction.normalized().dot(forward)
	var front_threshold := -cos(deg_to_rad(shield_front_arc_degrees * 0.5))
	if incoming_dot <= front_threshold:
		return maxi(ceili(float(amount) * shield_front_damage_multiplier), 1)

	return amount


func _flash(color: Color, duration: float) -> void:
	var flash_target: CanvasItem = visual
	if action_sprite != null and action_sprite.visible:
		flash_target = action_sprite
	if flash_target == null:
		return
	var restore_modulate := flash_target.modulate
	flash_target.modulate = color
	var tween := create_tween()
	tween.tween_property(flash_target, "modulate", restore_modulate, duration)


func _configure_action_sprite() -> void:
	if action_sprite == null or action_sprite.texture == null:
		return
	action_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	action_sprite.frame = 0
	action_sprite.visible = true
	if visual != null:
		visual.visible = false
	if shield_visual != null:
		shield_visual.visible = false


func _tick_action_sprite(delta: float) -> void:
	_action_sprite_recovery_timer = maxf(_action_sprite_recovery_timer - delta, 0.0)
	var visual_action_was_active := _visual_action_timer > 0.0
	_visual_action_timer = maxf(_visual_action_timer - delta, 0.0)
	if visual_action_was_active and _visual_action_timer <= 0.0:
		_visual_action_duration = 0.0
		_action_sprite_recovery_timer = maxf(_action_sprite_recovery_timer, 0.2)
	if action_sprite == null or action_sprite.texture == null:
		return
	var next_frame := 0
	if _utility_windup_timer > 0.0 and _utility_windup_duration > 0.0:
		next_frame = _get_windup_action_frame(_utility_windup_timer, _utility_windup_duration)
	elif _projectile_windup_timer > 0.0 and _projectile_windup_duration > 0.0:
		next_frame = _get_windup_action_frame(_projectile_windup_timer, _projectile_windup_duration)
	elif _charge_state == 1:
		next_frame = _get_windup_action_frame(_charge_timer, maxf(charge_windup, 0.05))
	elif _charge_state == 2:
		next_frame = 2
	elif _charge_state == 3:
		next_frame = 3
	elif _is_self_destructing:
		next_frame = _get_windup_action_frame(_self_destruct_timer, maxf(self_destruct_windup, 0.05))
	elif _visual_action_timer > 0.0 and _visual_action_duration > 0.0:
		next_frame = _get_windup_action_frame(_visual_action_timer, _visual_action_duration)
	elif _shield_bash_timer > 0.0:
		next_frame = 2
	elif _shield_bash_recover_timer > 0.0 or _action_sprite_recovery_timer > 0.0:
		next_frame = 3
	elif behavior_type == BehaviorType.CHASER:
		if target != null and is_instance_valid(target) and global_position.distance_to(target.global_position) <= 48.0:
			next_frame = 3
		elif velocity.length_squared() > 16.0:
			_movement_animation_time = fmod(_movement_animation_time + delta * maxf(move_speed / 80.0, 0.75), 1.0)
			next_frame = 1 if _movement_animation_time < 0.5 else 2
		else:
			_movement_animation_time = 0.0
	action_sprite.frame = next_frame


func _get_windup_action_frame(remaining: float, total: float) -> int:
	var progress := 1.0 - clampf(remaining / maxf(total, 0.001), 0.0, 1.0)
	return 1 if progress < 0.55 else 2


func _die() -> void:
	_dead = true
	_spawn_death_effect()
	_apply_elite_death_explosion()
	_spawn_death_minions()
	Events.enemy_died.emit(self)
	died.emit(self)
	queue_free()


func _spawn_death_effect() -> void:
	var effect := DEATH_BURST_SCENE.instantiate() as Node2D
	if effect == null:
		return

	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position


func _spawn_death_minions() -> void:
	if death_spawn_scene == null or death_spawn_count <= 0:
		return

	for index in range(death_spawn_count):
		var angle := TAU * float(index) / float(maxi(death_spawn_count, 1))
		var minion := death_spawn_scene.instantiate() as Node2D
		if minion == null:
			continue

		get_tree().current_scene.add_child(minion)
		minion.global_position = _get_death_spawn_position(angle)
		Events.enemy_spawned.emit(minion)


func _get_death_spawn_position(angle: float) -> Vector2:
	var position := global_position + Vector2.RIGHT.rotated(angle) * death_spawn_spacing
	var player := target
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null or not is_instance_valid(player):
		return position

	var minimum_distance := maxf(min_summon_distance_from_player, death_spawn_spacing)
	if position.distance_to(player.global_position) >= minimum_distance:
		return position

	var away := position - player.global_position
	if away.length_squared() <= 0.001:
		away = Vector2.RIGHT.rotated(angle + PI)
	return player.global_position + away.normalized() * minimum_distance


func _apply_elite_death_explosion() -> void:
	if not is_elite or elite_death_explosion_radius <= 0.0 or elite_death_explosion_damage <= 0:
		return

	var warning := DANGER_WARNING_SCENE.instantiate() as Node2D
	if warning == null:
		return

	get_tree().current_scene.add_child(warning)
	warning.global_position = global_position
	warning.call(
		"configure_circle",
		elite_death_explosion_radius,
		0.45,
		Color(1.0, 0.36, 0.08, 0.48),
		elite_death_explosion_damage,
		self,
		&"elite_death"
	)

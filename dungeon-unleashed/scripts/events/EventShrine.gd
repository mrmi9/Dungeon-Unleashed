extends Area2D
class_name EventShrine

const WEAPON_REWARD_PICKER := preload("res://scripts/weapons/WeaponRewardPicker.gd")

@export var event_id := "blood_pact"
@export var outcome_id := "sacrifice_for_blessing"
@export var display_name := "Blood Pact"
@export var health_cost := 1
@export var gold_min := 18
@export var gold_max := 26
@export_enum("manual", "blood_pact", "merchant_oath", "cursed_weapon", "overclock_trial", "resonant_statue", "statue_attunement", "random") var event_variant: String = "manual"
@export_enum("blessing_choice", "relic_choice", "statue_choice", "statue_attunement", "shop_discount", "cursed_weapon", "temporary_rule") var reward_mode: String = "blessing_choice"
@export var blessing_choice_count := 3
@export var blessing_source := "event"
@export var statue_choice_count := 3
@export var statue_source := "event"
@export var statue_attunement_target_id := ""
@export var relic_choice_count := 3
@export var relic_source := "reward"
@export var shop_discount_multiplier: float = 0.75
@export var shop_discount_charges: int = 1
@export var cursed_weapon_max_health_penalty: int = 1
@export var temporary_rule_id := "overclock_trial"
@export var temporary_rule_damage_multiplier_bonus := 0.2
@export var temporary_rule_fire_rate_multiplier_bonus := 0.18
@export var temporary_rule_duration := 18.0
@export var cursed_weapon_pool: Array[Resource] = []
@export var cursed_weapon_drop_table: Resource = preload("res://resources/weapon_drop_tables/cursed_event.tres")
@export var biome_id: String = "prototype_depths"
@export var biome_name: String = "Prototype Depths"
@export var biome_reward_weight_multiplier: float = 1.0
@export var random_seed: int = 0

@onready var visual: CanvasItem = $Visual
@onready var label: Label = $Label

var _claimed := false
var _nearby_player: Node
var _rng := RandomNumberGenerator.new()
var _resolved_event_variant := ""


func _ready() -> void:
	add_to_group("rewards")
	add_to_group("event_shrines")
	_prepare_random_seed()
	_resolved_event_variant = _resolve_event_variant()
	_apply_event_variant(_resolved_event_variant)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	set_process_unhandled_input(true)
	_refresh_label()


func claim_for_player(player: Node) -> bool:
	return activate_for_player(player)


func activate_for_player(player: Node) -> bool:
	if _claimed or player == null or not player.is_in_group("player"):
		return false
	if not player.has_method("sacrifice_health") or not bool(player.call("sacrifice_health", health_cost)):
		_flash(Color(1.0, 0.18, 0.12, 1.0), 0.16)
		return false

	_claimed = true
	_nearby_player = null
	_grant_gold(player)
	Events.special_event_resolved.emit(self, player, event_id, outcome_id)

	match reward_mode:
		"shop_discount":
			_grant_shop_discount(player)
			Events.reward_collected.emit(self, player)
			remove_from_group("rewards")
			_set_collision_enabled(false)
			_refresh_label()
			_flash(Color(0.5, 1.0, 0.64, 1.0), 0.18)
			return true
		"cursed_weapon":
			if _grant_cursed_weapon(player):
				Events.reward_collected.emit(self, player)
				remove_from_group("rewards")
				_set_collision_enabled(false)
				_refresh_label()
				_flash(Color(0.5, 1.0, 0.64, 1.0), 0.18)
				return true
		"temporary_rule":
			if _grant_temporary_rule(player):
				Events.reward_collected.emit(self, player)
				remove_from_group("rewards")
				_set_collision_enabled(false)
				_refresh_label()
				_flash(Color(0.5, 1.0, 0.64, 1.0), 0.18)
				return true
		"relic_choice":
			if _request_relic_choice(player):
				remove_from_group("rewards")
				_set_collision_enabled(false)
				visible = false
				return true
		"statue_choice":
			if _request_statue_choice(player):
				remove_from_group("rewards")
				_set_collision_enabled(false)
				visible = false
				return true
		"statue_attunement":
			if _grant_statue_attunement(player):
				Events.reward_collected.emit(self, player)
				remove_from_group("rewards")
				_set_collision_enabled(false)
				_refresh_label()
				_flash(Color(0.5, 1.0, 0.64, 1.0), 0.18)
				return true
			if _request_statue_choice(player):
				remove_from_group("rewards")
				_set_collision_enabled(false)
				visible = false
				return true
		_:
			if _request_blessing_choice(player):
				remove_from_group("rewards")
				_set_collision_enabled(false)
				visible = false
				return true
			if _request_relic_choice(player):
				remove_from_group("rewards")
				_set_collision_enabled(false)
				visible = false
				return true

	Events.reward_collected.emit(self, player)
	remove_from_group("rewards")
	_set_collision_enabled(false)
	_refresh_label()
	_flash(Color(0.5, 1.0, 0.64, 1.0), 0.18)
	return true


func is_claimed() -> bool:
	return _claimed


func get_biome_reward_summary() -> Dictionary:
	return {
		"biome_id": biome_id,
		"biome_name": biome_name,
		"reward_weight_multiplier": biome_reward_weight_multiplier,
		"random_seed": random_seed,
	}


func get_event_summary() -> Dictionary:
	return {
		"event_variant": _get_resolved_event_variant(),
		"event_id": event_id,
		"outcome_id": outcome_id,
		"display_name": display_name,
		"reward_mode": reward_mode,
		"health_cost": health_cost,
		"gold_min": gold_min,
		"gold_max": gold_max,
		"biome_id": biome_id,
		"biome_name": biome_name,
		"statue_choice_count": statue_choice_count,
		"statue_attunement_target_id": statue_attunement_target_id,
		"shop_discount_multiplier": shop_discount_multiplier,
		"shop_discount_charges": shop_discount_charges,
		"cursed_weapon_max_health_penalty": cursed_weapon_max_health_penalty,
		"cursed_weapon_pool_size": cursed_weapon_pool.size(),
		"temporary_rule_id": temporary_rule_id,
		"temporary_rule_damage_multiplier_bonus": temporary_rule_damage_multiplier_bonus,
		"temporary_rule_fire_rate_multiplier_bonus": temporary_rule_fire_rate_multiplier_bonus,
		"temporary_rule_duration": temporary_rule_duration,
		"random_seed": random_seed,
	}


func set_random_seed(seed: int) -> void:
	random_seed = seed
	_rng.seed = seed


func get_random_seed() -> int:
	return random_seed


func _prepare_random_seed() -> void:
	if random_seed != 0:
		_rng.seed = random_seed
		return
	_rng.randomize()
	random_seed = int(_rng.seed)


func _unhandled_input(event: InputEvent) -> void:
	if _nearby_player == null or _claimed:
		return
	if event.is_action_pressed("interact"):
		activate_for_player(_nearby_player)
		get_viewport().set_input_as_handled()


func _on_body_entered(body: Node) -> void:
	if _claimed or not body.is_in_group("player"):
		return

	_nearby_player = body
	_refresh_label()


func _on_body_exited(body: Node) -> void:
	if body == _nearby_player:
		_nearby_player = null
		_refresh_label()


func _grant_gold(player: Node) -> void:
	if not player.has_method("add_gold"):
		return
	var low := mini(gold_min, gold_max)
	var high := maxi(gold_min, gold_max)
	if high <= 0:
		return
	player.call("add_gold", maxi(0, roundi(float(_rng.randi_range(low, high)) * _get_reward_value_multiplier())))


func _grant_shop_discount(player: Node) -> void:
	if not player.has_method("add_shop_discount"):
		return
	player.call("add_shop_discount", clampf(shop_discount_multiplier, 0.05, 1.0), maxi(shop_discount_charges, 1))


func _grant_cursed_weapon(player: Node) -> bool:
	if player.has_method("apply_event_curse"):
		player.call("apply_event_curse", "cursed_weapon", maxi(cursed_weapon_max_health_penalty, 0))

	if not player.has_method("buy_weapon"):
		return false

	var weapon_data := _pick_cursed_weapon()
	if weapon_data == null:
		return false
	return bool(player.call("buy_weapon", weapon_data))


func get_cursed_weapon_reward_source_id() -> String:
	if cursed_weapon_drop_table == null:
		return "fallback"
	return str(cursed_weapon_drop_table.get("source_id"))


func get_cursed_weapon_reward_pool_ids() -> PackedStringArray:
	if cursed_weapon_drop_table != null:
		return WEAPON_REWARD_PICKER.get_pool_ids(cursed_weapon_drop_table)
	var ids := PackedStringArray()
	for weapon in cursed_weapon_pool:
		if weapon != null:
			ids.append(str(weapon.get("id")))
	return ids


func _pick_cursed_weapon() -> Resource:
	if cursed_weapon_drop_table != null:
		var weapon: Resource = WEAPON_REWARD_PICKER.pick_weapon(cursed_weapon_drop_table, _rng, biome_reward_weight_multiplier)
		if weapon != null:
			return weapon
	return _pick_resource(cursed_weapon_pool, biome_reward_weight_multiplier)


func _grant_temporary_rule(player: Node) -> bool:
	if not player.has_method("apply_temporary_combat_rule"):
		return false

	return bool(player.call(
		"apply_temporary_combat_rule",
		temporary_rule_id,
		maxf(temporary_rule_damage_multiplier_bonus, 0.0),
		maxf(temporary_rule_fire_rate_multiplier_bonus, 0.0),
		maxf(temporary_rule_duration, 0.0)
	))


func _request_relic_choice(player: Node) -> bool:
	var relic_system := get_tree().get_first_node_in_group("relic_system")
	if relic_system == null or not relic_system.has_method("get_reward_choices"):
		return false

	var choices: Array = relic_system.call("get_reward_choices", relic_choice_count, relic_source, biome_reward_weight_multiplier)
	if choices.is_empty():
		return false

	Events.relic_choice_requested.emit(choices, self, player)
	return true


func _request_blessing_choice(player: Node) -> bool:
	var system := get_tree().get_first_node_in_group("blessing_system")
	if system == null or not system.has_method("get_reward_choices"):
		return false

	var choices: Array = system.call("get_reward_choices", blessing_choice_count, blessing_source, biome_reward_weight_multiplier)
	if choices.is_empty():
		return false

	Events.blessing_choice_requested.emit(choices, self, player)
	return true


func _request_statue_choice(player: Node) -> bool:
	var system := get_tree().get_first_node_in_group("statue_system")
	if system == null or not system.has_method("get_reward_choices"):
		return false

	var choices: Array = system.call("get_reward_choices", statue_choice_count, statue_source, biome_reward_weight_multiplier)
	if choices.is_empty():
		return false

	Events.statue_choice_requested.emit(choices, self, player)
	return true


func _grant_statue_attunement(_player: Node) -> bool:
	var system := get_tree().get_first_node_in_group("statue_system")
	if system == null or not system.has_method("attune_statue"):
		return false
	return bool(system.call("attune_statue", statue_attunement_target_id))


func _get_reward_value_multiplier() -> float:
	return maxf(biome_reward_weight_multiplier, 0.1)


func _resolve_event_variant() -> String:
	if event_variant != "random":
		return event_variant

	var variants := PackedStringArray(["blood_pact", "merchant_oath", "cursed_weapon", "overclock_trial", "resonant_statue", "statue_attunement"])
	return variants[_rng.randi_range(0, variants.size() - 1)]


func _get_resolved_event_variant() -> String:
	if not _resolved_event_variant.is_empty():
		return _resolved_event_variant
	return event_variant


func _apply_event_variant(variant: String) -> void:
	match variant:
		"blood_pact":
			event_id = "blood_pact"
			outcome_id = "sacrifice_for_blessing"
			display_name = "Blood Pact"
			health_cost = 1
			gold_min = 18
			gold_max = 26
			reward_mode = "blessing_choice"
		"merchant_oath":
			event_id = "merchant_oath"
			outcome_id = "shop_discount"
			display_name = "Merchant Oath"
			health_cost = 1
			gold_min = 0
			gold_max = 0
			reward_mode = "shop_discount"
			shop_discount_multiplier = 0.75
			shop_discount_charges = 1
		"cursed_weapon":
			event_id = "cursed_armory"
			outcome_id = "curse_for_weapon"
			display_name = "Cursed Armory"
			health_cost = 1
			gold_min = 0
			gold_max = 0
			reward_mode = "cursed_weapon"
			cursed_weapon_max_health_penalty = maxi(cursed_weapon_max_health_penalty, 1)
		"overclock_trial":
			event_id = "overclock_trial"
			outcome_id = "temporary_overclock"
			display_name = "Overclock Trial"
			health_cost = 1
			gold_min = 8
			gold_max = 12
			reward_mode = "temporary_rule"
			temporary_rule_id = "overclock_trial"
			temporary_rule_damage_multiplier_bonus = maxf(temporary_rule_damage_multiplier_bonus, 0.2)
			temporary_rule_fire_rate_multiplier_bonus = maxf(temporary_rule_fire_rate_multiplier_bonus, 0.18)
			temporary_rule_duration = maxf(temporary_rule_duration, 18.0)
		"resonant_statue":
			event_id = "resonant_statue"
			outcome_id = "sacrifice_for_statue"
			display_name = "Resonant Statue"
			health_cost = 1
			gold_min = 10
			gold_max = 16
			reward_mode = "statue_choice"
		"statue_attunement":
			event_id = "resonance_tuning"
			outcome_id = "attune_statue"
			display_name = "Resonance Tuning"
			health_cost = 1
			gold_min = 6
			gold_max = 12
			reward_mode = "statue_attunement"
		_:
			pass


func _pick_resource(pool: Array[Resource], weight_multiplier: float = 1.0) -> Resource:
	var candidates: Array[Resource] = []
	for resource in pool:
		if resource != null:
			candidates.append(resource)
	if candidates.is_empty():
		return null

	var total_weight := 0.0
	for resource in candidates:
		total_weight += _get_resource_weight(resource, weight_multiplier)
	if total_weight <= 0.0:
		return candidates[_rng.randi_range(0, candidates.size() - 1)]

	var roll := _rng.randf_range(0.0, total_weight)
	for resource in candidates:
		roll -= _get_resource_weight(resource, weight_multiplier)
		if roll <= 0.0:
			return resource
	return candidates[candidates.size() - 1]


func _get_resource_weight(resource: Resource, weight_multiplier: float = 1.0) -> float:
	if resource == null:
		return 0.0
	var drop_weight := 1.0
	var drop_weight_value = resource.get("drop_weight")
	if drop_weight_value != null:
		drop_weight = float(drop_weight_value)
	return maxf(drop_weight, 0.0) * _get_rarity_multiplier(str(resource.get("rarity")), weight_multiplier)


func _get_rarity_multiplier(rarity: String, weight_multiplier: float) -> float:
	var multiplier := maxf(weight_multiplier, 0.0)
	match rarity:
		"rare":
			return 1.0 + 0.35 * multiplier
		"epic":
			return 1.0 + 0.7 * multiplier
		"legendary":
			return 1.0 + 1.1 * multiplier
	return 1.0


func _set_collision_enabled(enabled: bool) -> void:
	for child in get_children():
		if child is CollisionShape2D:
			(child as CollisionShape2D).set_deferred("disabled", not enabled)


func _refresh_label() -> void:
	if label == null:
		return
	var reward_label := _get_reward_mode_label()
	if _claimed:
		label.text = "Resolved"
	elif _nearby_player != null:
		label.text = "%s\n-%d HP\n%s\nPress E" % [display_name, health_cost, reward_label]
	else:
		label.text = "%s\n-%d HP\n%s" % [display_name, health_cost, reward_label]


func _get_reward_mode_label() -> String:
	match reward_mode:
		"shop_discount":
			var discount_percent := roundi((1.0 - clampf(shop_discount_multiplier, 0.05, 1.0)) * 100.0)
			return "Shop -%d%% x%d" % [discount_percent, maxi(shop_discount_charges, 1)]
		"cursed_weapon":
			return "Weapon, -%d Max HP" % maxi(cursed_weapon_max_health_penalty, 1)
		"temporary_rule":
			return "+%d%% DMG / +%d%% Rate, %.0fs" % [
				roundi(maxf(temporary_rule_damage_multiplier_bonus, 0.0) * 100.0),
				roundi(maxf(temporary_rule_fire_rate_multiplier_bonus, 0.0) * 100.0),
				maxf(temporary_rule_duration, 0.0),
			]
		"relic_choice":
			return "Relic Choice"
		"statue_choice":
			return "Statue Choice"
		"statue_attunement":
			return "Statue Attune"
	return "Blessing Choice"


func _flash(color: Color, duration: float) -> void:
	if visual == null:
		return
	var final_color := visual.modulate
	visual.modulate = color
	var tween := create_tween()
	tween.tween_property(visual, "modulate", final_color, duration)

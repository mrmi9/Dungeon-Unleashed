extends CharacterBody2D
class_name Player

const ENEMY_BODY_COLLISION_BIT := 2
const AIM_ASSIST_CONTROLLER_SCRIPT := preload("res://scripts/combat/AimAssistController.gd")
const CONTROLLER_LAYOUT := preload("res://scripts/input/ControllerLayout.gd")

signal health_changed(current_hp: int, max_hp: int)
signal shield_changed(current_shield: int)
signal gold_changed(current_gold: int)
signal weapon_changed(display_name: String, slot_index: int, slot_total: int)
signal weapon_loadout_stats_changed()
signal ammo_changed(current_ammo: int, magazine_size: int, is_reloading: bool)
signal energy_changed(current_energy: int, max_energy: int)
signal character_changed(display_name: String, description: String, skill_name: String, skill_description: String, index: int, total: int)
signal skill_state_changed(skill_name: String, cooldown_remaining: float, cooldown_duration: float, active_remaining: float)

@export var max_health: int = 6
@export var move_speed: float = 260.0
@export var invulnerability_duration: float = 0.7
@export var contact_damage_interval: float = 0.65
@export var max_shield: int = 6
@export var shield_recharge_delay: float = 2.4
@export var shield_recharge_rate: float = 1.6
@export var max_energy: int = 120
@export var energy_regen_delay: float = 0.6
@export var energy_regen_rate: float = 10.0
@export var energy_insufficient_feedback_interval: float = 0.45
@export var skill_unavailable_feedback_interval: float = 0.35
@export var available_characters: Array[Resource] = [
	preload("res://resources/characters/wanderer.tres"),
	preload("res://resources/characters/warden.tres"),
	preload("res://resources/characters/arcanist.tres"),
	preload("res://resources/characters/rift_runner.tres"),
	preload("res://resources/characters/emberwright.tres"),
	preload("res://resources/characters/field_medic.tres"),
]
@export var weapon_loadout: Array[WeaponData] = [
	preload("res://resources/weapons/basic_pistol.tres"),
	preload("res://resources/weapons/shotgun.tres"),
	preload("res://resources/weapons/energy_staff.tres"),
]

@onready var weapon: Weapon = $Weapon
@onready var visual: CanvasItem = $Visual
@onready var hurtbox: Area2D = $Hurtbox

var current_health: int
var current_shield: int = 0
var current_energy: int = 0
var current_gold: int = 0
var current_character_index: int = 0
var current_weapon_index: int = 0
var _shop_discount_multiplier := 1.0
var _shop_discount_charges := 0
var _event_curse_ids: Array[String] = []
var _event_curse_max_health_penalty := 0
var relic_damage_multiplier_bonus := 0.0
var relic_fire_rate_multiplier_bonus := 0.0
var relic_projectile_count_bonus := 0
var relic_pierce_bonus := 0
var relic_bounce_count_bonus := 0
var relic_homing_turn_rate_bonus := 0.0
var relic_homing_radius_bonus := 0.0
var relic_chain_count_bonus := 0
var relic_chain_radius_bonus := 0.0
var relic_chain_damage_multiplier_bonus := 0.0
var relic_explosion_radius_bonus := 0.0
var relic_knockback_multiplier_bonus := 0.0
var relic_magazine_size_bonus := 0
var relic_crit_chance_bonus := 0.0
var relic_reload_speed_multiplier_bonus := 0.0
var relic_status_chance_bonus := 0.0
var relic_status_damage_multiplier_bonus := 0.0
var relic_status_duration_multiplier_bonus := 0.0
var relic_projectile_block_radius_bonus := 0.0
var relic_projectile_block_arc_bonus := 0.0
var relic_projectile_block_damage_bonus := 0
var relic_charge_damage_multiplier_bonus := 0.0
var relic_charge_speed_multiplier_bonus := 0.0
var relic_charge_projectile_count_bonus := 0
var relic_deployable_damage_multiplier_bonus := 0.0
var relic_deployable_duration_multiplier_bonus := 0.0
var _character_passive_id := ""
var _passive_damage_multiplier_bonus := 0.0
var _passive_fire_rate_multiplier_bonus := 0.0
var _passive_crit_chance_bonus := 0.0
var _passive_reload_speed_multiplier_bonus := 0.0
var _passive_speed_multiplier_bonus := 0.0
var _passive_projectile_block_radius_bonus := 0.0
var _passive_projectile_block_arc_bonus := 0.0
var _passive_projectile_block_damage_bonus := 0
var _passive_shield_recharge_rate_bonus := 0.0
var _passive_shield_break_guard_duration := 0.0
var _passive_shield_break_guard_timer := 0.0
var _passive_shield_break_guard_radius_bonus := 0.0
var _passive_shield_break_guard_arc_bonus := 0.0
var _passive_shield_break_guard_damage_bonus := 0
var _passive_room_clear_speed_multiplier_bonus := 0.0
var _passive_room_clear_speed_duration := 0.0
var _passive_energy_spend_focus_duration := 0.0
var _passive_energy_spend_focus_timer := 0.0
var _passive_energy_spend_focus_fire_rate_multiplier_bonus := 0.0
var _passive_energy_spend_focus_reload_speed_multiplier_bonus := 0.0
var _passive_critical_focus_duration := 0.0
var _passive_critical_focus_timer := 0.0
var _passive_critical_focus_fire_rate_multiplier_bonus := 0.0
var _passive_critical_focus_reload_speed_multiplier_bonus := 0.0
var _passive_kill_burst_duration := 0.0
var _passive_kill_burst_timer := 0.0
var _passive_kill_burst_damage_multiplier_bonus := 0.0
var _passive_kill_burst_fire_rate_multiplier_bonus := 0.0
var _passive_room_clear_heal_amount := 0
var _passive_room_clear_shield_amount := 0
var _skill_damage_multiplier_bonus := 0.0
var _skill_fire_rate_multiplier_bonus := 0.0
var _temporary_rule_id := ""
var _temporary_rule_damage_multiplier_bonus := 0.0
var _temporary_rule_fire_rate_multiplier_bonus := 0.0
var _temporary_rule_duration := 0.0
var _temporary_rule_timer := 0.0
var _temporary_speed_multiplier := 1.0
var _speed_boost_timer := 0.0
var _is_dead := false
var _invulnerability_timer := 0.0
var _contact_damage_timer := 0.0
var _shield_recharge_delay_timer := 0.0
var _shield_recharge_accumulator := 0.0
var _energy_regen_delay_timer := 0.0
var _energy_regen_accumulator := 0.0
var _energy_insufficient_feedback_timer := 0.0
var _skill_cooldown_timer := 0.0
var _skill_active_timer := 0.0
var _skill_unavailable_feedback_timer := 0.0
var _touching_enemies: Array[Node] = []
var _aim_assist: AimAssistController
var _aim_assist_configured_strength := 0.35
var _last_damage_summary: Dictionary = {}


func _ready() -> void:
	add_to_group("player")
	_aim_assist = AIM_ASSIST_CONTROLLER_SCRIPT.new()
	_aim_assist.name = "AimAssistController"
	add_child(_aim_assist)
	collision_mask = collision_mask & ~ENEMY_BODY_COLLISION_BIT
	_apply_character_stats(current_character_index, true)
	weapon.ammo_changed.connect(_on_weapon_ammo_changed)
	_equip_weapon(0)
	health_changed.emit(current_health, max_health)
	shield_changed.emit(current_shield)
	energy_changed.emit(current_energy, max_energy)
	_emit_character_changed()
	_emit_skill_state_changed()
	gold_changed.emit(current_gold)
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)
	hurtbox.body_exited.connect(_on_hurtbox_body_exited)
	Events.enemy_died.connect(_on_enemy_died_for_passive)
	Events.player_shield_broken.connect(_on_player_shield_broken_for_passive)
	Events.room_cleared.connect(_on_room_cleared_for_passive)
	Events.projectile_critical_hit.connect(_on_projectile_critical_hit_for_passive)


func _physics_process(delta: float) -> void:
	_tick_timers(delta)

	if _is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	_aim_at_current_target()
	_handle_weapon_switch_input()
	if Input.is_action_just_pressed("reload"):
		weapon.start_reload()
	if Input.is_action_just_pressed("skill"):
		try_use_skill()

	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * move_speed * get_current_speed_multiplier()
	move_and_slide()

	if Input.is_action_pressed("shoot"):
		weapon.try_fire(_get_assisted_aim_target(), self)
	if Input.is_action_just_released("shoot"):
		weapon.release_charge(_get_assisted_aim_target(), self)

	_try_contact_damage()


func is_alive() -> bool:
	return not _is_dead


func get_weapon_display_name() -> String:
	if weapon == null:
		return "Unarmed"
	return weapon.get_display_name()


func get_weapon_loadout_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for weapon_data_entry in weapon_loadout:
		if weapon_data_entry == null:
			continue
		ids.append(str(weapon_data_entry.get("id")))
	return ids


func get_character_display_name() -> String:
	var data := get_current_character_data()
	if data == null:
		return "Adventurer"
	return str(data.get("display_name"))


func get_current_character_data() -> Resource:
	if available_characters.is_empty():
		return null
	current_character_index = clampi(current_character_index, 0, available_characters.size() - 1)
	return available_characters[current_character_index]


func get_character_summary() -> Dictionary:
	var data := get_current_character_data()
	if data == null:
		return {
			"display_name": "Adventurer",
			"description": "",
			"skill_name": "Skill",
			"skill_description": "",
			"index": current_character_index,
			"total": available_characters.size(),
		}

	return {
		"id": data.get("id"),
		"display_name": str(data.get("display_name")),
		"description": str(data.get("description")),
		"skill_id": str(data.get("skill_id")),
		"skill_name": str(data.get("skill_name")),
		"skill_description": str(data.get("skill_description")),
		"skill_cooldown": float(data.get("skill_cooldown")),
		"skill_energy_cost": int(data.get("skill_energy_cost")),
		"index": current_character_index,
		"total": available_characters.size(),
	}


func select_character(index: int) -> bool:
	if available_characters.is_empty():
		return false
	if index < 0 or index >= available_characters.size():
		return false

	current_character_index = index
	_apply_character_stats(current_character_index, true)
	health_changed.emit(current_health, max_health)
	shield_changed.emit(current_shield)
	energy_changed.emit(current_energy, max_energy)
	Events.player_energy_changed.emit(current_energy, max_energy)
	_emit_character_changed()
	_emit_skill_state_changed()
	return true


func select_next_character() -> bool:
	if available_characters.is_empty():
		return false
	return select_character((current_character_index + 1) % available_characters.size())


func select_previous_character() -> bool:
	if available_characters.is_empty():
		return false
	return select_character(posmod(current_character_index - 1, available_characters.size()))


func apply_meta_stat_bonus(health_bonus: int, armor_bonus: int, energy_bonus: int, refill_resources: bool = true) -> void:
	var resolved_health_bonus := maxi(health_bonus, 0)
	var resolved_armor_bonus := maxi(armor_bonus, 0)
	var resolved_energy_bonus := maxi(energy_bonus, 0)
	if resolved_health_bonus <= 0 and resolved_armor_bonus <= 0 and resolved_energy_bonus <= 0:
		return

	max_health += resolved_health_bonus
	max_shield += resolved_armor_bonus
	max_energy += resolved_energy_bonus
	if refill_resources:
		current_health = max_health
		current_shield = max_shield
		current_energy = max_energy
	else:
		current_health = mini(current_health + resolved_health_bonus, max_health)
		current_shield = mini(current_shield + resolved_armor_bonus, max_shield)
		current_energy = mini(current_energy + resolved_energy_bonus, max_energy)

	health_changed.emit(current_health, max_health)
	shield_changed.emit(current_shield)
	energy_changed.emit(current_energy, max_energy)
	Events.player_energy_changed.emit(current_energy, max_energy)


func add_gold(amount: int) -> void:
	if _is_dead:
		return

	current_gold = maxi(current_gold + amount, 0)
	gold_changed.emit(current_gold)
	Events.gold_changed.emit(current_gold)


func can_afford(amount: int) -> bool:
	return current_gold >= maxi(amount, 0)


func spend_gold(amount: int) -> bool:
	var cost := maxi(amount, 0)
	if _is_dead or current_gold < cost:
		return false

	current_gold -= cost
	gold_changed.emit(current_gold)
	Events.gold_changed.emit(current_gold)
	return true


func add_shop_discount(multiplier: float, charges: int = 1) -> void:
	var resolved_charges := maxi(charges, 0)
	if resolved_charges <= 0:
		return

	var resolved_multiplier := clampf(multiplier, 0.05, 1.0)
	if _shop_discount_charges <= 0:
		_shop_discount_multiplier = resolved_multiplier
	else:
		_shop_discount_multiplier = minf(_shop_discount_multiplier, resolved_multiplier)
	_shop_discount_charges += resolved_charges


func has_shop_discount() -> bool:
	return _shop_discount_charges > 0 and _shop_discount_multiplier < 1.0


func get_shop_purchase_price(base_price: int) -> int:
	var safe_price := maxi(base_price, 0)
	if safe_price <= 0 or not has_shop_discount():
		return safe_price
	return maxi(1, roundi(float(safe_price) * _shop_discount_multiplier))


func consume_shop_discount() -> bool:
	if _shop_discount_charges <= 0:
		return false

	_shop_discount_charges -= 1
	if _shop_discount_charges <= 0:
		_shop_discount_charges = 0
		_shop_discount_multiplier = 1.0
	return true


func get_shop_discount_summary() -> Dictionary:
	return {
		"active": has_shop_discount(),
		"multiplier": _shop_discount_multiplier,
		"charges": _shop_discount_charges,
	}


func apply_event_curse(curse_id: String, max_health_penalty: int = 1) -> bool:
	if _is_dead:
		return false

	var resolved_id := curse_id.strip_edges()
	var penalty := maxi(max_health_penalty, 0)
	if resolved_id.is_empty() and penalty <= 0:
		return false

	if not resolved_id.is_empty():
		_event_curse_ids.append(resolved_id)

	if penalty > 0:
		var previous_max_health := max_health
		max_health = maxi(max_health - penalty, 1)
		var applied_penalty := previous_max_health - max_health
		_event_curse_max_health_penalty += applied_penalty
		current_health = mini(current_health, max_health)
		health_changed.emit(current_health, max_health)

	return true


func get_event_curse_summary() -> Dictionary:
	return {
		"ids": _event_curse_ids.duplicate(),
		"count": _event_curse_ids.size(),
		"max_health_penalty": _event_curse_max_health_penalty,
	}


func apply_temporary_combat_rule(rule_id: String, damage_multiplier_bonus: float, fire_rate_multiplier_bonus: float, duration: float) -> bool:
	if _is_dead:
		return false

	var resolved_duration := maxf(duration, 0.0)
	if resolved_duration <= 0.0:
		return false

	_temporary_rule_id = rule_id if not rule_id.strip_edges().is_empty() else "temporary_rule"
	_temporary_rule_damage_multiplier_bonus = maxf(_temporary_rule_damage_multiplier_bonus, damage_multiplier_bonus)
	_temporary_rule_fire_rate_multiplier_bonus = maxf(_temporary_rule_fire_rate_multiplier_bonus, fire_rate_multiplier_bonus)
	_temporary_rule_duration = maxf(_temporary_rule_duration, resolved_duration)
	_temporary_rule_timer = maxf(_temporary_rule_timer, resolved_duration)
	return true


func get_temporary_rule_summary() -> Dictionary:
	return {
		"active": _temporary_rule_timer > 0.0,
		"id": _temporary_rule_id,
		"damage_multiplier_bonus": _temporary_rule_damage_multiplier_bonus,
		"fire_rate_multiplier_bonus": _temporary_rule_fire_rate_multiplier_bonus,
		"duration": _temporary_rule_duration,
		"remaining": _temporary_rule_timer,
	}


func get_last_damage_summary() -> Dictionary:
	return _last_damage_summary.duplicate()


func buy_weapon(weapon_data: Resource) -> bool:
	if _is_dead or weapon_data == null:
		return false

	var typed_weapon := weapon_data as WeaponData
	if typed_weapon == null:
		return false

	if weapon_loadout.is_empty():
		weapon_loadout.append(typed_weapon)
		current_weapon_index = 0
	else:
		current_weapon_index = clampi(current_weapon_index, 0, weapon_loadout.size() - 1)
		weapon_loadout[current_weapon_index] = typed_weapon

	_equip_weapon(current_weapon_index)
	return true


func apply_relic_effect(effect_type: String, effect_value: float) -> void:
	match effect_type:
		"damage_multiplier":
			relic_damage_multiplier_bonus += effect_value
		"fire_rate_multiplier":
			relic_fire_rate_multiplier_bonus += effect_value
		"projectile_count":
			relic_projectile_count_bonus += roundi(effect_value)
		"pierce":
			relic_pierce_bonus += roundi(effect_value)
		"bounce_count_bonus":
			relic_bounce_count_bonus += roundi(effect_value)
		"homing_turn_rate_bonus":
			relic_homing_turn_rate_bonus += effect_value
		"homing_radius_bonus":
			relic_homing_radius_bonus += effect_value
		"chain_count_bonus":
			relic_chain_count_bonus += roundi(effect_value)
		"chain_radius_bonus":
			relic_chain_radius_bonus += effect_value
		"chain_damage_multiplier":
			relic_chain_damage_multiplier_bonus += effect_value
		"explosion_radius_bonus":
			relic_explosion_radius_bonus += effect_value
		"knockback_multiplier":
			relic_knockback_multiplier_bonus += effect_value
		"magazine_size_bonus":
			var previous_magazine_size := weapon.get_magazine_size() if weapon != null else 0
			relic_magazine_size_bonus += roundi(effect_value)
			if weapon != null and weapon.has_method("refresh_magazine_size"):
				weapon.call("refresh_magazine_size", previous_magazine_size)
			weapon_loadout_stats_changed.emit()
		"crit_chance_bonus":
			relic_crit_chance_bonus += effect_value
		"reload_speed_multiplier":
			relic_reload_speed_multiplier_bonus += effect_value
		"status_chance_bonus":
			relic_status_chance_bonus += effect_value
		"status_damage_multiplier":
			relic_status_damage_multiplier_bonus += effect_value
		"status_duration_multiplier":
			relic_status_duration_multiplier_bonus += effect_value
		"projectile_block_radius_bonus":
			relic_projectile_block_radius_bonus += effect_value
		"projectile_block_arc_bonus":
			relic_projectile_block_arc_bonus += effect_value
		"projectile_block_damage_bonus":
			relic_projectile_block_damage_bonus += roundi(effect_value)
		"charge_damage_multiplier":
			relic_charge_damage_multiplier_bonus += effect_value
		"charge_speed_multiplier":
			relic_charge_speed_multiplier_bonus += effect_value
		"charge_projectile_count_bonus":
			relic_charge_projectile_count_bonus += roundi(effect_value)
		"deployable_damage_multiplier":
			relic_deployable_damage_multiplier_bonus += effect_value
		"deployable_duration_multiplier":
			relic_deployable_duration_multiplier_bonus += effect_value
		"max_health":
			var health_bonus := maxi(roundi(effect_value), 1)
			max_health += health_bonus
			current_health = mini(current_health + health_bonus, max_health)
			health_changed.emit(current_health, max_health)
			Events.player_healed.emit(health_bonus, current_health)
		"max_energy":
			var energy_bonus := maxi(roundi(effect_value), 1)
			max_energy += energy_bonus
			current_energy = mini(current_energy + energy_bonus, max_energy)
			energy_changed.emit(current_energy, max_energy)
			Events.player_energy_changed.emit(current_energy, max_energy)
		"max_shield":
			var shield_bonus := maxi(roundi(effect_value), 1)
			max_shield += shield_bonus
			current_shield = mini(current_shield + shield_bonus, max_shield)
			shield_changed.emit(current_shield)
			Events.player_shield_gained.emit(shield_bonus, current_shield)


func heal(amount: int) -> void:
	if _is_dead or amount <= 0:
		return

	var previous_health := current_health
	current_health = mini(current_health + amount, max_health)
	if current_health != previous_health:
		var healed_amount := current_health - previous_health
		health_changed.emit(current_health, max_health)
		Events.player_healed.emit(healed_amount, current_health)


func can_sacrifice_health(amount: int) -> bool:
	var cost := maxi(amount, 0)
	if _is_dead or cost <= 0:
		return false
	return current_health > cost


func sacrifice_health(amount: int) -> bool:
	var cost := maxi(amount, 0)
	if cost <= 0:
		return true
	if not can_sacrifice_health(cost):
		return false

	current_health = maxi(current_health - cost, 1)
	health_changed.emit(current_health, max_health)
	Events.player_damaged.emit(cost, current_health)
	_flash(Color(0.72, 0.18, 0.88, 1.0), 0.18)
	return true


func add_shield(amount: int) -> void:
	if _is_dead or amount <= 0:
		return

	var previous_shield := current_shield
	current_shield = mini(current_shield + amount, max_shield)
	if current_shield != previous_shield:
		var gained_amount := current_shield - previous_shield
		shield_changed.emit(current_shield)
		Events.player_shield_gained.emit(gained_amount, current_shield)


func get_shield() -> int:
	return current_shield


func get_shield_recharge_summary() -> Dictionary:
	var recharge_rate := _get_shield_recharge_rate()
	if _is_dead or max_shield <= 0 or current_shield >= max_shield:
		return {
			"state": "full",
			"delay_remaining": 0.0,
			"progress": 0.0,
			"rate": recharge_rate,
		}

	if _shield_recharge_delay_timer > 0.0:
		return {
			"state": "delayed",
			"delay_remaining": _shield_recharge_delay_timer,
			"progress": 0.0,
			"rate": recharge_rate,
		}

	if recharge_rate <= 0.0:
		return {
			"state": "stalled",
			"delay_remaining": 0.0,
			"progress": 0.0,
			"rate": recharge_rate,
		}

	return {
		"state": "recovering",
		"delay_remaining": 0.0,
		"progress": clampf(_shield_recharge_accumulator, 0.0, 0.99),
		"rate": recharge_rate,
	}


func get_energy() -> int:
	return current_energy


func can_spend_energy_for_weapon(weapon_data: Resource) -> bool:
	var cost := _get_weapon_energy_cost(weapon_data)
	if current_energy >= cost:
		return true
	_emit_energy_insufficient_feedback(cost, weapon_data)
	return false


func spend_energy_for_weapon(weapon_data: Resource) -> bool:
	var cost := _get_weapon_energy_cost(weapon_data)
	if cost <= 0:
		return true
	if current_energy < cost:
		_emit_energy_insufficient_feedback(cost, weapon_data)
		return false

	current_energy -= cost
	_energy_regen_delay_timer = energy_regen_delay
	_energy_regen_accumulator = 0.0
	energy_changed.emit(current_energy, max_energy)
	Events.player_energy_changed.emit(current_energy, max_energy)
	_trigger_energy_spend_focus_for_passive(cost)
	return true


func recover_energy(amount: int) -> void:
	if amount <= 0:
		return

	var previous_energy := current_energy
	current_energy = mini(current_energy + amount, max_energy)
	if current_energy != previous_energy:
		energy_changed.emit(current_energy, max_energy)
		Events.player_energy_changed.emit(current_energy, max_energy)


func try_use_skill() -> bool:
	if _is_dead:
		return false
	if _skill_cooldown_timer > 0.0:
		_emit_skill_unavailable_feedback("cooldown", _skill_cooldown_timer)
		return false

	var data := get_current_character_data()
	if data == null:
		return false

	var cost := maxi(int(data.get("skill_energy_cost")), 0)
	if current_energy < cost:
		_emit_energy_insufficient_feedback(cost, data)
		return false
	if cost > 0:
		current_energy -= cost
		_energy_regen_delay_timer = energy_regen_delay
		_energy_regen_accumulator = 0.0
		energy_changed.emit(current_energy, max_energy)
		Events.player_energy_changed.emit(current_energy, max_energy)

	_skill_cooldown_timer = maxf(float(data.get("skill_cooldown")), 0.05)
	_skill_active_timer = maxf(float(data.get("skill_duration")), 0.0)
	_apply_skill_effect(data)
	_emit_skill_state_changed()
	Events.player_skill_used.emit(self, str(data.get("skill_id")), str(data.get("skill_name")))
	return true


func get_skill_summary() -> Dictionary:
	var data := get_current_character_data()
	if data == null:
		return {
			"skill_name": "Skill",
			"cooldown_remaining": 0.0,
			"cooldown_duration": 0.0,
			"active_remaining": 0.0,
		}

	return {
		"skill_id": str(data.get("skill_id")),
		"skill_name": str(data.get("skill_name")),
		"cooldown_remaining": _skill_cooldown_timer,
		"cooldown_duration": float(data.get("skill_cooldown")),
		"active_remaining": _skill_active_timer,
		"energy_cost": int(data.get("skill_energy_cost")),
	}


func get_character_passive_summary() -> Dictionary:
	var data := get_current_character_data()
	var character_id := ""
	var display_name := ""
	var passive_description := ""
	var icon_key := ""
	if data != null:
		character_id = str(data.get("id"))
		display_name = str(data.get("display_name"))
		passive_description = str(data.get("passive_description"))
		icon_key = str(data.get("icon_key")).strip_edges()
	if icon_key.is_empty() and not character_id.strip_edges().is_empty():
		icon_key = "character_%s" % character_id.strip_edges()
	return {
		"character_id": character_id,
		"display_name": display_name,
		"icon_key": icon_key,
		"passive_id": _character_passive_id,
		"passive_description": passive_description,
		"damage_multiplier_bonus": _passive_damage_multiplier_bonus,
		"fire_rate_multiplier_bonus": _passive_fire_rate_multiplier_bonus,
		"crit_chance_bonus": _passive_crit_chance_bonus,
		"reload_speed_multiplier_bonus": _passive_reload_speed_multiplier_bonus,
		"speed_multiplier_bonus": _passive_speed_multiplier_bonus,
		"projectile_block_radius_bonus": _passive_projectile_block_radius_bonus,
		"projectile_block_arc_bonus": _passive_projectile_block_arc_bonus,
		"projectile_block_damage_bonus": _passive_projectile_block_damage_bonus,
		"shield_recharge_rate_bonus": _passive_shield_recharge_rate_bonus,
		"shield_break_guard_duration": _passive_shield_break_guard_duration,
		"shield_break_guard_remaining": _passive_shield_break_guard_timer,
		"shield_break_guard_active": _passive_shield_break_guard_timer > 0.0,
		"shield_break_guard_radius_bonus": _passive_shield_break_guard_radius_bonus,
		"shield_break_guard_arc_bonus": _passive_shield_break_guard_arc_bonus,
		"shield_break_guard_damage_bonus": _passive_shield_break_guard_damage_bonus,
		"room_clear_speed_multiplier_bonus": _passive_room_clear_speed_multiplier_bonus,
		"room_clear_speed_duration": _passive_room_clear_speed_duration,
		"room_clear_speed_active": _is_passive_room_clear_speed_active(),
		"speed_boost_remaining": _speed_boost_timer,
		"energy_spend_focus_duration": _passive_energy_spend_focus_duration,
		"energy_spend_focus_remaining": _passive_energy_spend_focus_timer,
		"energy_spend_focus_active": _passive_energy_spend_focus_timer > 0.0,
		"energy_spend_focus_fire_rate_multiplier_bonus": _passive_energy_spend_focus_fire_rate_multiplier_bonus,
		"energy_spend_focus_reload_speed_multiplier_bonus": _passive_energy_spend_focus_reload_speed_multiplier_bonus,
		"critical_focus_duration": _passive_critical_focus_duration,
		"critical_focus_remaining": _passive_critical_focus_timer,
		"critical_focus_active": _passive_critical_focus_timer > 0.0,
		"critical_focus_fire_rate_multiplier_bonus": _passive_critical_focus_fire_rate_multiplier_bonus,
		"critical_focus_reload_speed_multiplier_bonus": _passive_critical_focus_reload_speed_multiplier_bonus,
		"kill_burst_duration": _passive_kill_burst_duration,
		"kill_burst_remaining": _passive_kill_burst_timer,
		"kill_burst_active": _passive_kill_burst_timer > 0.0,
		"kill_burst_damage_multiplier_bonus": _passive_kill_burst_damage_multiplier_bonus,
		"kill_burst_fire_rate_multiplier_bonus": _passive_kill_burst_fire_rate_multiplier_bonus,
		"room_clear_heal_amount": _passive_room_clear_heal_amount,
		"room_clear_shield_amount": _passive_room_clear_shield_amount,
	}


func apply_temporary_speed_boost(multiplier_bonus: float, duration: float) -> void:
	if _is_dead:
		return

	_temporary_speed_multiplier = maxf(_temporary_speed_multiplier, 1.0 + multiplier_bonus)
	_speed_boost_timer = maxf(_speed_boost_timer, duration)


func get_current_speed_multiplier() -> float:
	return maxf(_temporary_speed_multiplier + _passive_speed_multiplier_bonus, 0.1)


func _is_passive_room_clear_speed_active() -> bool:
	return (
		_character_passive_id == "phase_footing"
		and _speed_boost_timer > 0.0
		and _passive_room_clear_speed_multiplier_bonus > 0.0
		and _temporary_speed_multiplier >= 1.0 + _passive_room_clear_speed_multiplier_bonus
	)


func _get_passive_kill_burst_damage_multiplier_bonus() -> float:
	return _passive_kill_burst_damage_multiplier_bonus if _passive_kill_burst_timer > 0.0 else 0.0


func _get_passive_kill_burst_fire_rate_multiplier_bonus() -> float:
	return _passive_kill_burst_fire_rate_multiplier_bonus if _passive_kill_burst_timer > 0.0 else 0.0


func _get_passive_energy_spend_focus_fire_rate_multiplier_bonus() -> float:
	return _passive_energy_spend_focus_fire_rate_multiplier_bonus if _passive_energy_spend_focus_timer > 0.0 else 0.0


func _get_passive_energy_spend_focus_reload_speed_multiplier_bonus() -> float:
	return _passive_energy_spend_focus_reload_speed_multiplier_bonus if _passive_energy_spend_focus_timer > 0.0 else 0.0


func _get_passive_critical_focus_fire_rate_multiplier_bonus() -> float:
	return _passive_critical_focus_fire_rate_multiplier_bonus if _passive_critical_focus_timer > 0.0 else 0.0


func _get_passive_critical_focus_reload_speed_multiplier_bonus() -> float:
	return _passive_critical_focus_reload_speed_multiplier_bonus if _passive_critical_focus_timer > 0.0 else 0.0


func get_damage_multiplier() -> float:
	return maxf(1.0 + relic_damage_multiplier_bonus + _passive_damage_multiplier_bonus + _get_passive_kill_burst_damage_multiplier_bonus() + _skill_damage_multiplier_bonus + _temporary_rule_damage_multiplier_bonus, 0.1)


func get_fire_rate_multiplier() -> float:
	return maxf(1.0 + relic_fire_rate_multiplier_bonus + _passive_fire_rate_multiplier_bonus + _get_passive_energy_spend_focus_fire_rate_multiplier_bonus() + _get_passive_critical_focus_fire_rate_multiplier_bonus() + _get_passive_kill_burst_fire_rate_multiplier_bonus() + _skill_fire_rate_multiplier_bonus + _temporary_rule_fire_rate_multiplier_bonus, 0.1)


func get_projectile_count_bonus() -> int:
	return maxi(relic_projectile_count_bonus, 0)


func get_pierce_bonus() -> int:
	return maxi(relic_pierce_bonus, 0)


func get_bounce_count_bonus() -> int:
	return maxi(relic_bounce_count_bonus, 0)


func get_homing_turn_rate_bonus() -> float:
	return maxf(relic_homing_turn_rate_bonus, 0.0)


func get_homing_radius_bonus() -> float:
	return maxf(relic_homing_radius_bonus, 0.0)


func get_chain_count_bonus() -> int:
	return maxi(relic_chain_count_bonus, 0)


func get_chain_radius_bonus() -> float:
	return maxf(relic_chain_radius_bonus, 0.0)


func get_chain_damage_multiplier() -> float:
	return maxf(1.0 + relic_chain_damage_multiplier_bonus, 0.1)


func get_explosion_radius_bonus() -> float:
	return maxf(relic_explosion_radius_bonus, 0.0)


func get_knockback_multiplier() -> float:
	return maxf(1.0 + relic_knockback_multiplier_bonus, 0.1)


func get_magazine_size_bonus() -> int:
	return maxi(relic_magazine_size_bonus, 0)


func get_crit_chance_bonus() -> float:
	return clampf(relic_crit_chance_bonus + _passive_crit_chance_bonus, 0.0, 1.0)


func get_reload_speed_multiplier() -> float:
	return maxf(1.0 + relic_reload_speed_multiplier_bonus + _passive_reload_speed_multiplier_bonus + _get_passive_energy_spend_focus_reload_speed_multiplier_bonus() + _get_passive_critical_focus_reload_speed_multiplier_bonus(), 0.1)


func get_status_chance_bonus() -> float:
	return clampf(relic_status_chance_bonus, 0.0, 1.0)


func get_status_damage_multiplier() -> float:
	return maxf(1.0 + relic_status_damage_multiplier_bonus, 0.1)


func get_status_duration_multiplier() -> float:
	return maxf(1.0 + relic_status_duration_multiplier_bonus, 0.1)


func get_projectile_block_radius_bonus() -> float:
	return maxf(relic_projectile_block_radius_bonus + _passive_projectile_block_radius_bonus + _get_passive_shield_break_guard_radius_bonus(), 0.0)


func get_projectile_block_arc_bonus() -> float:
	return maxf(relic_projectile_block_arc_bonus + _passive_projectile_block_arc_bonus + _get_passive_shield_break_guard_arc_bonus(), 0.0)


func get_projectile_block_damage_bonus() -> int:
	return maxi(relic_projectile_block_damage_bonus + _passive_projectile_block_damage_bonus + _get_passive_shield_break_guard_damage_bonus(), 0)


func _get_passive_shield_break_guard_radius_bonus() -> float:
	return _passive_shield_break_guard_radius_bonus if _passive_shield_break_guard_timer > 0.0 else 0.0


func _get_passive_shield_break_guard_arc_bonus() -> float:
	return _passive_shield_break_guard_arc_bonus if _passive_shield_break_guard_timer > 0.0 else 0.0


func _get_passive_shield_break_guard_damage_bonus() -> int:
	return _passive_shield_break_guard_damage_bonus if _passive_shield_break_guard_timer > 0.0 else 0


func get_charge_damage_multiplier() -> float:
	return maxf(1.0 + relic_charge_damage_multiplier_bonus, 0.1)


func get_charge_speed_multiplier() -> float:
	return maxf(1.0 + relic_charge_speed_multiplier_bonus, 0.1)


func get_charge_projectile_count_bonus() -> int:
	return maxi(relic_charge_projectile_count_bonus, 0)


func get_deployable_damage_multiplier() -> float:
	return maxf(1.0 + relic_deployable_damage_multiplier_bonus, 0.1)


func get_deployable_duration_multiplier() -> float:
	return maxf(1.0 + relic_deployable_duration_multiplier_bonus, 0.1)


func get_deployable_radius_bonus() -> float:
	return 0.0


func configure_aim_assist(enabled: bool, strength: float, max_distance: float = 520.0, max_angle_degrees: float = 35.0, lock_weight: float = 0.65) -> void:
	if _aim_assist == null:
		return

	_aim_assist.enabled = enabled
	_aim_assist_configured_strength = clampf(strength, 0.0, 1.0)
	_aim_assist.max_distance = maxf(max_distance, 1.0)
	_aim_assist.max_angle_degrees = clampf(max_angle_degrees, 0.0, 180.0)
	_aim_assist.lock_weight = maxf(lock_weight, 0.0)
	_refresh_aim_assist_strength()


func is_aim_assist_enabled() -> bool:
	return _aim_assist != null and _aim_assist.enabled


func get_aim_assist_strength() -> float:
	return _aim_assist_configured_strength


func get_effective_aim_assist_strength_for_test() -> float:
	if _aim_assist == null:
		return 0.0
	return _aim_assist.strength


func get_aim_assist_lock_weight_for_test() -> float:
	if _aim_assist == null:
		return 0.0
	return _aim_assist.lock_weight


func configure_aim_assist_candidate_groups(groups: Array) -> void:
	if _aim_assist == null:
		return
	_aim_assist.set_candidate_groups(groups)


func get_aim_assist_candidate_groups_for_test() -> PackedStringArray:
	if _aim_assist == null:
		return PackedStringArray()
	return _aim_assist.get_candidate_groups()


func set_aim_assist_locked_target_for_test(target: Node2D) -> void:
	if _aim_assist == null:
		return
	_aim_assist.set_locked_target(target)


func clear_aim_assist_lock_for_test() -> void:
	if _aim_assist == null:
		return
	_aim_assist.clear_lock()


func get_aim_assist_target_for_test(origin: Vector2, raw_direction: Vector2) -> Node2D:
	if _aim_assist == null:
		return null
	return _aim_assist.pick_target(origin, raw_direction, _get_aim_assist_candidates())


func get_assisted_aim_direction_for_test(origin: Vector2, raw_direction: Vector2) -> Vector2:
	if _aim_assist == null:
		return raw_direction
	return _aim_assist.get_assisted_direction(origin, raw_direction, _get_aim_assist_candidates())


func get_raw_aim_target_for_test() -> Vector2:
	return _get_raw_aim_target()


func get_controller_aim_vector_for_test() -> Vector2:
	return _get_controller_aim_vector()


func get_controller_aim_deadzone_for_test() -> float:
	return CONTROLLER_LAYOUT.get_aim_deadzone()


func get_controller_aim_target_distance_for_test() -> float:
	return CONTROLLER_LAYOUT.get_aim_target_distance()


func _handle_weapon_switch_input() -> void:
	if Input.is_action_just_pressed("weapon_slot_1"):
		_equip_weapon(0)
	elif Input.is_action_just_pressed("weapon_slot_2"):
		_equip_weapon(1)
	elif Input.is_action_just_pressed("weapon_slot_3"):
		_equip_weapon(2)


func _equip_weapon(index: int) -> void:
	if index < 0 or index >= weapon_loadout.size():
		return

	var data := weapon_loadout[index]
	if data == null:
		return

	current_weapon_index = index
	weapon.set_weapon_data(data)
	_refresh_aim_assist_strength()
	weapon_changed.emit(weapon.get_display_name(), current_weapon_index + 1, weapon_loadout.size())


func take_damage(amount: int, source: Node = null) -> void:
	if _is_dead or _invulnerability_timer > 0.0:
		return

	var remaining_damage := maxi(amount, 0)
	if remaining_damage > 0:
		_shield_recharge_delay_timer = shield_recharge_delay
		_shield_recharge_accumulator = 0.0
	if current_shield > 0 and remaining_damage > 0:
		var absorbed := mini(current_shield, remaining_damage)
		current_shield -= absorbed
		remaining_damage -= absorbed
		shield_changed.emit(current_shield)
		Events.player_shield_absorbed.emit(absorbed, current_shield)
		if current_shield <= 0:
			Events.player_shield_broken.emit(absorbed, current_shield)

	current_health = maxi(current_health - remaining_damage, 0)
	_invulnerability_timer = invulnerability_duration
	if remaining_damage > 0:
		_last_damage_summary = _build_damage_source_summary(remaining_damage, source)
	health_changed.emit(current_health, max_health)
	Events.player_damaged.emit(remaining_damage, current_health)
	_flash(Color(1.0, 0.35, 0.35, 1.0), 0.16)

	if current_health <= 0:
		_die()


func _tick_timers(delta: float) -> void:
	var was_skill_ready := _skill_cooldown_timer <= 0.0 and _skill_active_timer <= 0.0

	if _invulnerability_timer > 0.0:
		_invulnerability_timer = maxf(_invulnerability_timer - delta, 0.0)

	if _contact_damage_timer > 0.0:
		_contact_damage_timer = maxf(_contact_damage_timer - delta, 0.0)

	if _energy_insufficient_feedback_timer > 0.0:
		_energy_insufficient_feedback_timer = maxf(_energy_insufficient_feedback_timer - delta, 0.0)

	if _skill_unavailable_feedback_timer > 0.0:
		_skill_unavailable_feedback_timer = maxf(_skill_unavailable_feedback_timer - delta, 0.0)

	if _passive_shield_break_guard_timer > 0.0:
		_passive_shield_break_guard_timer = maxf(_passive_shield_break_guard_timer - delta, 0.0)

	if _passive_energy_spend_focus_timer > 0.0:
		_passive_energy_spend_focus_timer = maxf(_passive_energy_spend_focus_timer - delta, 0.0)

	if _passive_critical_focus_timer > 0.0:
		_passive_critical_focus_timer = maxf(_passive_critical_focus_timer - delta, 0.0)

	if _passive_kill_burst_timer > 0.0:
		_passive_kill_burst_timer = maxf(_passive_kill_burst_timer - delta, 0.0)

	if _speed_boost_timer > 0.0:
		_speed_boost_timer = maxf(_speed_boost_timer - delta, 0.0)
		if _speed_boost_timer <= 0.0:
			_temporary_speed_multiplier = 1.0

	if _temporary_rule_timer > 0.0:
		_temporary_rule_timer = maxf(_temporary_rule_timer - delta, 0.0)
		if _temporary_rule_timer <= 0.0:
			_clear_temporary_combat_rule()

	if _skill_cooldown_timer > 0.0:
		_skill_cooldown_timer = maxf(_skill_cooldown_timer - delta, 0.0)
		_emit_skill_state_changed()

	if _skill_active_timer > 0.0:
		_skill_active_timer = maxf(_skill_active_timer - delta, 0.0)
		if _skill_active_timer <= 0.0:
			_clear_skill_modifiers()
		_emit_skill_state_changed()

	if not was_skill_ready and _skill_cooldown_timer <= 0.0 and _skill_active_timer <= 0.0:
		var skill_summary := get_skill_summary()
		if float(skill_summary.get("cooldown_duration", 0.0)) > 0.0:
			Events.player_skill_ready.emit(str(skill_summary.get("skill_name", "Skill")))

	_tick_shield_recharge(delta)
	_tick_energy_regen(delta)


func _aim_at_current_target() -> void:
	var direction := _get_assisted_aim_target() - global_position
	if direction.length_squared() > 0.001:
		global_rotation = direction.angle()


func _get_assisted_aim_target() -> Vector2:
	var raw_target := _get_raw_aim_target()
	var origin := _get_aim_origin()
	var raw_direction := raw_target - origin
	if raw_direction.length_squared() <= 0.001:
		return raw_target
	if _aim_assist == null or not _aim_assist.enabled:
		return raw_target

	var assisted_direction := _aim_assist.get_assisted_direction(origin, raw_direction, _get_aim_assist_candidates())
	return origin + assisted_direction * raw_direction.length()


func _get_raw_aim_target() -> Vector2:
	var origin := _get_aim_origin()
	var controller_aim := _get_controller_aim_vector()
	if controller_aim.length_squared() > 0.001:
		return origin + controller_aim * CONTROLLER_LAYOUT.get_aim_target_distance()
	return get_global_mouse_position()


func _get_controller_aim_vector() -> Vector2:
	if not _has_controller_aim_actions():
		return Vector2.ZERO
	var aim_vector := Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down", CONTROLLER_LAYOUT.get_aim_deadzone())
	if aim_vector.length_squared() <= 0.001:
		return Vector2.ZERO
	return aim_vector.normalized()


func _has_controller_aim_actions() -> bool:
	return (
		InputMap.has_action(&"aim_left")
		and InputMap.has_action(&"aim_right")
		and InputMap.has_action(&"aim_up")
		and InputMap.has_action(&"aim_down")
	)


func _get_aim_origin() -> Vector2:
	if weapon != null and weapon.muzzle != null:
		return weapon.muzzle.global_position
	return global_position


func _get_aim_assist_candidates() -> Array:
	if _aim_assist == null:
		return []
	return _aim_assist.collect_candidates(get_tree())


func _refresh_aim_assist_strength() -> void:
	if _aim_assist == null:
		return

	var weapon_priority := 1.0
	if weapon != null and weapon.weapon_data != null:
		weapon_priority = maxf(float(weapon.weapon_data.get("aim_assist_priority")), 0.0)
	_aim_assist.strength = clampf(_aim_assist_configured_strength * weapon_priority, 0.0, 1.0)


func _try_contact_damage() -> void:
	if _contact_damage_timer > 0.0:
		return

	for enemy in _touching_enemies.duplicate():
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			_touching_enemies.erase(enemy)
			continue

		if enemy.has_method("is_dead") and enemy.call("is_dead"):
			continue

		if enemy.has_method("can_deal_contact_damage") and not bool(enemy.call("can_deal_contact_damage")):
			continue

		var amount := 1
		var damage_property = enemy.get("contact_damage")
		if damage_property != null:
			amount = int(damage_property)

		take_damage(amount, enemy)
		_contact_damage_timer = contact_damage_interval
		return


func _build_damage_source_summary(amount: int, source: Node = null) -> Dictionary:
	var source_data := _get_damage_source_data(source)
	var source_name := str(source_data.get("source_name", "Unknown"))
	var source_type := str(source_data.get("source_type", "unknown"))
	var source_id := str(source_data.get("source_id", "unknown"))
	var source_scene := str(source_data.get("source_scene", ""))
	var source_room_type := str(source_data.get("source_room_type", ""))
	var source_biome_id := str(source_data.get("source_biome_id", ""))
	var source_biome_name := str(source_data.get("source_biome_name", ""))
	var source_layout_profile := str(source_data.get("source_layout_profile", ""))
	var source_review_tip := str(source_data.get("source_review_tip", ""))
	var source_threat_intel := str(source_data.get("source_threat_intel", ""))
	var source_counter_tags := _string_array_from_variant(source_data.get("source_counter_tags", []))
	return {
		"amount": maxi(amount, 0),
		"source_id": source_id,
		"source_name": source_name,
		"source_type": source_type,
		"source_scene": source_scene,
		"source_room_type": source_room_type,
		"source_biome_id": source_biome_id,
		"source_biome_name": source_biome_name,
		"source_layout_profile": source_layout_profile,
		"source_review_tip": source_review_tip,
		"source_threat_intel": source_threat_intel,
		"source_counter_tags": source_counter_tags,
		"text": "%s %d" % [source_name, maxi(amount, 0)],
	}


func _get_damage_source_data(source: Node = null) -> Dictionary:
	var source_name := "Unknown"
	var source_type := "unknown"
	var source_scene := ""
	var source_room_type := ""
	var source_biome_id := ""
	var source_biome_name := ""
	var source_layout_profile := ""
	var source_review_tip := ""
	var source_threat_intel := ""
	var source_counter_tags: Array = []
	if source != null and is_instance_valid(source):
		if source.has_method("get_damage_source_summary"):
			var provided = source.call("get_damage_source_summary")
			if provided is Dictionary and not (provided as Dictionary).is_empty():
				var provided_summary := provided as Dictionary
				source_name = str(provided_summary.get("source_name", source_name)).strip_edges()
				source_type = str(provided_summary.get("source_type", source_type)).strip_edges()
				source_scene = str(provided_summary.get("source_scene", source_scene)).strip_edges()
				source_room_type = str(provided_summary.get("room_type", provided_summary.get("source_room_type", source_room_type))).strip_edges()
				source_biome_id = str(provided_summary.get("biome_id", provided_summary.get("source_biome_id", source_biome_id))).strip_edges()
				source_biome_name = str(provided_summary.get("biome_name", provided_summary.get("source_biome_name", source_biome_name))).strip_edges()
				source_layout_profile = str(provided_summary.get("layout_profile", provided_summary.get("source_layout_profile", source_layout_profile))).strip_edges()
				source_review_tip = str(provided_summary.get("review_tip", provided_summary.get("source_review_tip", source_review_tip))).strip_edges()
				source_threat_intel = str(provided_summary.get("threat_intel", provided_summary.get("source_threat_intel", source_threat_intel))).strip_edges()
				source_counter_tags = _string_array_from_variant(provided_summary.get("counter_tags", provided_summary.get("source_counter_tags", source_counter_tags)))
				var provided_id := str(provided_summary.get("source_id", "")).strip_edges()
				if source_name.is_empty():
					source_name = "Unknown"
				if source_type.is_empty():
					source_type = "unknown"
				if provided_id.is_empty():
					provided_id = _get_damage_source_id(source, source_name)
				return {
					"source_id": provided_id,
					"source_name": source_name,
					"source_type": source_type,
					"source_scene": source_scene,
					"source_room_type": source_room_type,
					"source_biome_id": source_biome_id,
					"source_biome_name": source_biome_name,
					"source_layout_profile": source_layout_profile,
					"source_review_tip": source_review_tip,
					"source_threat_intel": source_threat_intel,
					"source_counter_tags": source_counter_tags,
				}

		var display_value = source.get("display_name")
		if display_value != null and not str(display_value).strip_edges().is_empty():
			source_name = str(display_value).strip_edges()
		elif not source.name.is_empty():
			source_name = source.name
		source_scene = source.scene_file_path
		if source.is_in_group("bosses"):
			source_type = "boss"
		elif source.is_in_group("enemies"):
			source_type = "enemy"
		elif source.is_in_group("enemy_projectiles"):
			source_type = "enemy"
		else:
			source_type = "hazard"
	return {
		"source_id": _get_damage_source_id(source, source_name),
		"source_name": source_name,
		"source_type": source_type,
		"source_scene": source_scene,
		"source_room_type": source_room_type,
		"source_biome_id": source_biome_id,
		"source_biome_name": source_biome_name,
		"source_layout_profile": source_layout_profile,
		"source_review_tip": source_review_tip,
		"source_threat_intel": source_threat_intel,
		"source_counter_tags": source_counter_tags,
	}


func _string_array_from_variant(value) -> Array:
	var strings: Array = []
	if value is PackedStringArray:
		for item in value:
			strings.append(str(item))
	elif value is Array:
		for item in value:
			strings.append(str(item))
	elif value is String:
		for item in str(value).split(",", false):
			var token := str(item).strip_edges()
			if not token.is_empty():
				strings.append(token)
	return strings


func _get_damage_source_id(source: Node, source_name: String) -> String:
	if source != null and is_instance_valid(source):
		for property_name in ["source_id", "enemy_id", "id"]:
			var value = source.get(property_name)
			if value != null and not str(value).strip_edges().is_empty():
				return str(value).strip_edges().to_snake_case()

		var scene_path := source.scene_file_path.strip_edges()
		if not scene_path.is_empty():
			return scene_path.get_file().get_basename().to_snake_case()

	if not source_name.strip_edges().is_empty() and source_name != "Unknown":
		return source_name.strip_edges().to_snake_case()
	return "unknown"


func _flash(color: Color, duration: float) -> void:
	visual.modulate = color
	var tween := create_tween()
	tween.tween_property(visual, "modulate", Color.WHITE, duration)


func _die() -> void:
	_is_dead = true
	velocity = Vector2.ZERO
	visual.modulate = Color(0.35, 0.35, 0.35, 1.0)
	Events.player_died.emit()


func _tick_shield_recharge(delta: float) -> void:
	if current_shield >= max_shield:
		_shield_recharge_accumulator = 0.0
		return
	if _shield_recharge_delay_timer > 0.0:
		_shield_recharge_delay_timer = maxf(_shield_recharge_delay_timer - delta, 0.0)
		return

	_shield_recharge_accumulator += _get_shield_recharge_rate() * delta
	var gained := floori(_shield_recharge_accumulator)
	if gained <= 0:
		return

	_shield_recharge_accumulator -= gained
	add_shield(gained)


func _get_shield_recharge_rate() -> float:
	return maxf(shield_recharge_rate + _passive_shield_recharge_rate_bonus, 0.0)


func _tick_energy_regen(delta: float) -> void:
	if current_energy >= max_energy:
		_energy_regen_accumulator = 0.0
		return
	if _energy_regen_delay_timer > 0.0:
		_energy_regen_delay_timer = maxf(_energy_regen_delay_timer - delta, 0.0)
		return

	_energy_regen_accumulator += maxf(energy_regen_rate, 0.0) * delta
	var gained := floori(_energy_regen_accumulator)
	if gained <= 0:
		return

	_energy_regen_accumulator -= gained
	recover_energy(gained)


func _emit_energy_insufficient_feedback(required_energy: int, source_data: Resource) -> void:
	if _energy_insufficient_feedback_timer > 0.0:
		return

	_energy_insufficient_feedback_timer = maxf(energy_insufficient_feedback_interval, 0.0)
	Events.player_energy_insufficient.emit(current_energy, maxi(required_energy, 0), source_data)


func _emit_skill_unavailable_feedback(reason: String, cooldown_remaining: float) -> void:
	if _skill_unavailable_feedback_timer > 0.0:
		return

	_skill_unavailable_feedback_timer = maxf(skill_unavailable_feedback_interval, 0.0)
	var summary := get_skill_summary()
	Events.player_skill_unavailable.emit(
		str(summary.get("skill_name", "Skill")),
		reason,
		maxf(cooldown_remaining, 0.0)
	)


func _get_weapon_energy_cost(weapon_data: Resource) -> int:
	if weapon_data == null:
		return 0
	return maxi(int(weapon_data.get("energy_cost")), 0)


func _apply_character_starting_loadout(data: Resource) -> void:
	if data == null:
		return

	var starting_weapon_ids_value = data.get("starting_weapon_ids")
	if not (starting_weapon_ids_value is PackedStringArray):
		return

	var starting_weapon_ids := starting_weapon_ids_value as PackedStringArray
	if starting_weapon_ids.is_empty():
		return

	var resolved_loadout: Array[WeaponData] = []
	for weapon_id_value in starting_weapon_ids:
		var weapon_id := str(weapon_id_value).strip_edges()
		if weapon_id.is_empty():
			continue
		var weapon_resource := load("res://resources/weapons/%s.tres" % weapon_id)
		if weapon_resource is WeaponData:
			resolved_loadout.append(weapon_resource)

	if resolved_loadout.is_empty():
		return

	weapon_loadout = resolved_loadout
	current_weapon_index = 0
	if weapon != null:
		_equip_weapon(0)


func _apply_character_stats(index: int, refill_resources: bool) -> void:
	if available_characters.is_empty():
		current_character_index = 0
		_clear_character_passive_bonuses()
		current_health = max_health
		current_shield = max_shield
		current_energy = max_energy
		return

	current_character_index = clampi(index, 0, available_characters.size() - 1)
	var data := available_characters[current_character_index]
	if data == null:
		_clear_character_passive_bonuses()
		return

	max_health = maxi(int(data.get("max_health")), 1)
	max_shield = maxi(int(data.get("max_armor")), 0)
	max_energy = maxi(int(data.get("max_energy")), 1)
	move_speed = maxf(float(data.get("move_speed")), 80.0)
	_skill_cooldown_timer = 0.0
	_skill_active_timer = 0.0
	_clear_skill_modifiers()
	_clear_temporary_combat_rule()
	_clear_temporary_speed_boost()
	_reset_event_curses()
	_apply_character_passive(data)
	if refill_resources:
		current_health = max_health
		current_shield = max_shield
		current_energy = max_energy
	else:
		current_health = mini(current_health, max_health)
		current_shield = mini(current_shield, max_shield)
		current_energy = mini(current_energy, max_energy)
	_apply_character_starting_loadout(data)


func _apply_character_passive(data: Resource) -> void:
	_clear_character_passive_bonuses()
	if data == null:
		return

	_character_passive_id = str(data.get("passive_id")).strip_edges()
	match _character_passive_id:
		"steady_hands":
			_passive_crit_chance_bonus = 0.03
			_passive_reload_speed_multiplier_bonus = 0.05
			_passive_critical_focus_duration = 2.0
			_passive_critical_focus_fire_rate_multiplier_bonus = 0.06
			_passive_critical_focus_reload_speed_multiplier_bonus = 0.06
		"armored_core":
			_passive_projectile_block_radius_bonus = 12.0
			_passive_projectile_block_arc_bonus = 8.0
			_passive_projectile_block_damage_bonus = 1
			_passive_shield_break_guard_duration = 2.5
			_passive_shield_break_guard_radius_bonus = 18.0
			_passive_shield_break_guard_arc_bonus = 12.0
			_passive_shield_break_guard_damage_bonus = 1
		"energy_focus":
			_passive_fire_rate_multiplier_bonus = 0.03
			_passive_reload_speed_multiplier_bonus = 0.08
			_passive_energy_spend_focus_duration = 2.0
			_passive_energy_spend_focus_fire_rate_multiplier_bonus = 0.08
			_passive_energy_spend_focus_reload_speed_multiplier_bonus = 0.10
		"phase_footing":
			_passive_speed_multiplier_bonus = 0.06
			_passive_room_clear_speed_multiplier_bonus = 0.14
			_passive_room_clear_speed_duration = 2.5
		"volatile_focus":
			_passive_damage_multiplier_bonus = 0.05
			_passive_kill_burst_duration = 2.5
			_passive_kill_burst_damage_multiplier_bonus = 0.08
			_passive_kill_burst_fire_rate_multiplier_bonus = 0.06
		"triage_kit":
			_passive_shield_recharge_rate_bonus = 0.5
			_passive_room_clear_heal_amount = 1
			_passive_room_clear_shield_amount = 1


func _clear_character_passive_bonuses() -> void:
	_character_passive_id = ""
	_passive_damage_multiplier_bonus = 0.0
	_passive_fire_rate_multiplier_bonus = 0.0
	_passive_crit_chance_bonus = 0.0
	_passive_reload_speed_multiplier_bonus = 0.0
	_passive_speed_multiplier_bonus = 0.0
	_passive_projectile_block_radius_bonus = 0.0
	_passive_projectile_block_arc_bonus = 0.0
	_passive_projectile_block_damage_bonus = 0
	_passive_shield_recharge_rate_bonus = 0.0
	_passive_shield_break_guard_duration = 0.0
	_passive_shield_break_guard_timer = 0.0
	_passive_shield_break_guard_radius_bonus = 0.0
	_passive_shield_break_guard_arc_bonus = 0.0
	_passive_shield_break_guard_damage_bonus = 0
	_passive_room_clear_speed_multiplier_bonus = 0.0
	_passive_room_clear_speed_duration = 0.0
	_passive_energy_spend_focus_duration = 0.0
	_passive_energy_spend_focus_timer = 0.0
	_passive_energy_spend_focus_fire_rate_multiplier_bonus = 0.0
	_passive_energy_spend_focus_reload_speed_multiplier_bonus = 0.0
	_passive_critical_focus_duration = 0.0
	_passive_critical_focus_timer = 0.0
	_passive_critical_focus_fire_rate_multiplier_bonus = 0.0
	_passive_critical_focus_reload_speed_multiplier_bonus = 0.0
	_passive_kill_burst_duration = 0.0
	_passive_kill_burst_timer = 0.0
	_passive_kill_burst_damage_multiplier_bonus = 0.0
	_passive_kill_burst_fire_rate_multiplier_bonus = 0.0
	_passive_room_clear_heal_amount = 0
	_passive_room_clear_shield_amount = 0


func _apply_skill_effect(data: Resource) -> void:
	var skill_duration := maxf(float(data.get("skill_duration")), 0.0)
	var skill_power := float(data.get("skill_power"))
	match str(data.get("skill_id")):
		"dash":
			_invulnerability_timer = maxf(_invulnerability_timer, skill_duration)
			apply_temporary_speed_boost(maxf(skill_power, 0.1), skill_duration)
		"guard":
			_invulnerability_timer = maxf(_invulnerability_timer, skill_duration)
			add_shield(maxi(roundi(skill_power), 1))
		"surge":
			recover_energy(maxi(roundi(skill_power), 1))
			_skill_fire_rate_multiplier_bonus = 0.35
		"overdrive":
			_skill_damage_multiplier_bonus = maxf(skill_power, 0.1)
			_skill_fire_rate_multiplier_bonus = maxf(skill_power * 0.5, 0.05)
		"stabilize":
			var heal_amount := maxi(roundi(skill_power), 1)
			heal(heal_amount)
			add_shield(maxi(heal_amount - 1, 1))
		_:
			apply_temporary_speed_boost(0.35, skill_duration)


func _clear_skill_modifiers() -> void:
	_skill_damage_multiplier_bonus = 0.0
	_skill_fire_rate_multiplier_bonus = 0.0


func _clear_temporary_combat_rule() -> void:
	_temporary_rule_id = ""
	_temporary_rule_damage_multiplier_bonus = 0.0
	_temporary_rule_fire_rate_multiplier_bonus = 0.0
	_temporary_rule_duration = 0.0
	_temporary_rule_timer = 0.0


func _clear_temporary_speed_boost() -> void:
	_temporary_speed_multiplier = 1.0
	_speed_boost_timer = 0.0


func _trigger_energy_spend_focus_for_passive(spent_energy: int) -> void:
	if _is_dead or _character_passive_id != "energy_focus":
		return
	if spent_energy <= 0 or _passive_energy_spend_focus_duration <= 0.0:
		return

	var was_active := _passive_energy_spend_focus_timer > 0.0
	_passive_energy_spend_focus_timer = _passive_energy_spend_focus_duration
	if not was_active:
		_emit_passive_triggered("Energy Flow", _passive_energy_spend_focus_duration)


func _trigger_critical_focus_for_passive() -> void:
	if _is_dead or _character_passive_id != "steady_hands":
		return
	if _passive_critical_focus_duration <= 0.0:
		return

	var was_active := _passive_critical_focus_timer > 0.0
	_passive_critical_focus_timer = _passive_critical_focus_duration
	if not was_active:
		_emit_passive_triggered("Crit Focus", _passive_critical_focus_duration)


func _emit_passive_triggered(effect_name: String, duration: float = 0.0) -> void:
	Events.player_passive_triggered.emit(self, _character_passive_id, effect_name, maxf(duration, 0.0))


func _reset_event_curses() -> void:
	_event_curse_ids.clear()
	_event_curse_max_health_penalty = 0


func _emit_character_changed() -> void:
	var summary := get_character_summary()
	character_changed.emit(
		str(summary.get("display_name", "Adventurer")),
		str(summary.get("description", "")),
		str(summary.get("skill_name", "Skill")),
		str(summary.get("skill_description", "")),
		int(summary.get("index", current_character_index)),
		int(summary.get("total", available_characters.size()))
	)


func _emit_skill_state_changed() -> void:
	var summary := get_skill_summary()
	skill_state_changed.emit(
		str(summary.get("skill_name", "Skill")),
		float(summary.get("cooldown_remaining", 0.0)),
		float(summary.get("cooldown_duration", 0.0)),
		float(summary.get("active_remaining", 0.0))
	)


func _on_hurtbox_body_entered(body: Node) -> void:
	if body.is_in_group("enemies") and not _touching_enemies.has(body):
		_touching_enemies.append(body)


func _on_hurtbox_body_exited(body: Node) -> void:
	_touching_enemies.erase(body)


func _on_weapon_ammo_changed(current_ammo: int, magazine_size: int, is_reloading: bool) -> void:
	ammo_changed.emit(current_ammo, magazine_size, is_reloading)


func _on_enemy_died_for_passive(_enemy: Node) -> void:
	if _is_dead or _character_passive_id != "volatile_focus":
		return
	if _passive_kill_burst_duration <= 0.0:
		return

	var was_active := _passive_kill_burst_timer > 0.0
	_passive_kill_burst_timer = _passive_kill_burst_duration
	if not was_active:
		_emit_passive_triggered("Kill Burst", _passive_kill_burst_duration)


func _on_projectile_critical_hit_for_passive(_projectile: Node, _target: Node, _damage: int) -> void:
	if _target != null and is_instance_valid(_target) and _target.is_in_group("player"):
		return

	_trigger_critical_focus_for_passive()


func _on_player_shield_broken_for_passive(_absorbed_amount: int, _current_shield: int) -> void:
	if _is_dead or _character_passive_id != "armored_core":
		return
	if _passive_shield_break_guard_duration <= 0.0:
		return

	var was_active := _passive_shield_break_guard_timer > 0.0
	_passive_shield_break_guard_timer = _passive_shield_break_guard_duration
	if not was_active:
		_emit_passive_triggered("Guard Stance", _passive_shield_break_guard_duration)


func _on_room_cleared_for_passive(_room: Node) -> void:
	if _is_dead:
		return

	match _character_passive_id:
		"phase_footing":
			if _passive_room_clear_speed_multiplier_bonus > 0.0 and _passive_room_clear_speed_duration > 0.0:
				apply_temporary_speed_boost(_passive_room_clear_speed_multiplier_bonus, _passive_room_clear_speed_duration)
				_emit_passive_triggered("Speed Surge", _passive_room_clear_speed_duration)
		"triage_kit":
			var should_trigger_triage := (
				(_passive_room_clear_heal_amount > 0 and current_health < max_health)
				or (_passive_room_clear_shield_amount > 0 and current_shield < max_shield)
			)
			if _passive_room_clear_heal_amount > 0 and current_health < max_health:
				heal(_passive_room_clear_heal_amount)
			if _passive_room_clear_shield_amount > 0 and current_shield < max_shield:
				add_shield(_passive_room_clear_shield_amount)
			if should_trigger_triage:
				_emit_passive_triggered("Triage Kit")

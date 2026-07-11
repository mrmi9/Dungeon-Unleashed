extends Area2D
class_name RewardChest

@export var chest_type: String = "normal"
@export var reward_count: int = 1
@export var drop_pool: PackedStringArray = PackedStringArray(["gold"])
@export var gold_min: int = 8
@export var gold_max: int = 16
@export var heal_amount: int = 2
@export var biome_id: String = "prototype_depths"
@export var biome_name: String = "Prototype Depths"
@export var biome_reward_weight_multiplier: float = 1.0
@export var relic_pool: Array[Resource] = [
	preload("res://resources/relics/sharp_rounds.tres"),
	preload("res://resources/relics/quick_trigger.tres"),
	preload("res://resources/relics/split_chamber.tres"),
	preload("res://resources/relics/phase_tip.tres"),
	preload("res://resources/relics/keen_sights.tres"),
	preload("res://resources/relics/hollow_needle.tres"),
	preload("res://resources/relics/momentum_coil.tres"),
	preload("res://resources/relics/field_rations.tres"),
	preload("res://resources/relics/steady_capacitor.tres"),
	preload("res://resources/relics/gilded_tip.tres"),
	preload("res://resources/relics/echo_chamber.tres"),
	preload("res://resources/relics/breakwater_guard.tres"),
	preload("res://resources/relics/siphon_clasp.tres"),
	preload("res://resources/relics/kinetic_ram.tres"),
	preload("res://resources/relics/volatile_oil.tres"),
	preload("res://resources/relics/ember_catalyst.tres"),
	preload("res://resources/relics/lingering_ash.tres"),
	preload("res://resources/relics/parry_grip.tres"),
	preload("res://resources/relics/warding_hinge.tres"),
	preload("res://resources/relics/counterweight_core.tres"),
	preload("res://resources/relics/draw_weight.tres"),
	preload("res://resources/relics/quick_windup.tres"),
	preload("res://resources/relics/stored_spark.tres"),
	preload("res://resources/relics/tripwire_amplifier.tres"),
	preload("res://resources/relics/anchor_spool.tres"),
	preload("res://resources/relics/ricochet_gyro.tres"),
	preload("res://resources/relics/blast_radius_gauge.tres"),
	preload("res://resources/relics/kinetic_bridle.tres"),
	preload("res://resources/relics/reserve_drum.tres"),
	preload("res://resources/relics/flux_reservoir.tres"),
	preload("res://resources/relics/tracking_vane.tres"),
	preload("res://resources/relics/longview_array.tres"),
	preload("res://resources/relics/forked_bus.tres"),
	preload("res://resources/relics/conduction_mesh.tres"),
	preload("res://resources/relics/stormglass_filament.tres"),
]
@export var weapon_pool: Array[Resource] = [
	preload("res://resources/weapons/ricochet_blaster.tres"),
	preload("res://resources/weapons/shotgun.tres"),
	preload("res://resources/weapons/energy_staff.tres"),
	preload("res://resources/weapons/arc_blade.tres"),
	preload("res://resources/weapons/nova_core.tres"),
	preload("res://resources/weapons/blast_launcher.tres"),
	preload("res://resources/weapons/laser_lance.tres"),
	preload("res://resources/weapons/coil_carbine.tres"),
	preload("res://resources/weapons/shatter_fan.tres"),
	preload("res://resources/weapons/rift_spear.tres"),
	preload("res://resources/weapons/orbit_sower.tres"),
	preload("res://resources/weapons/pulse_needler.tres"),
	preload("res://resources/weapons/cinder_mortar.tres"),
	preload("res://resources/weapons/mirror_sickle.tres"),
	preload("res://resources/weapons/storm_fan.tres"),
	preload("res://resources/weapons/prism_ray.tres"),
	preload("res://resources/weapons/halo_kernel.tres"),
	preload("res://resources/weapons/ember_sprayer.tres"),
	preload("res://resources/weapons/frost_sickle.tres"),
	preload("res://resources/weapons/slag_comet.tres"),
	preload("res://resources/weapons/guard_cleaver.tres"),
	preload("res://resources/weapons/riposte_saber.tres"),
	preload("res://resources/weapons/bulwark_fan.tres"),
	preload("res://resources/weapons/coil_bow.tres"),
	preload("res://resources/weapons/storm_capacitor.tres"),
	preload("res://resources/weapons/vault_lance.tres"),
	preload("res://resources/weapons/snare_beacon.tres"),
	preload("res://resources/weapons/ember_mine.tres"),
	preload("res://resources/weapons/sentry_seed.tres"),
	preload("res://resources/weapons/quench_repeater.tres"),
	preload("res://resources/weapons/furnace_scattergun.tres"),
	preload("res://resources/weapons/bastion_saw.tres"),
	preload("res://resources/weapons/rift_bloom.tres"),
	preload("res://resources/weapons/thunder_nest.tres"),
	preload("res://resources/weapons/compass_needle.tres"),
	preload("res://resources/weapons/relay_arc.tres"),
	preload("res://resources/weapons/lantern_swarm.tres"),
	preload("res://resources/weapons/undertow_volley.tres"),
	preload("res://resources/weapons/stormglass_rail.tres"),
]
@export var complete_run_on_open: bool = false

@onready var visual: CanvasItem = $Visual
@onready var lid: CanvasItem = $Lid
@onready var label: Label = $Label

var _opened := false
var _rng := RandomNumberGenerator.new()
var _nearby_player: Node


func _ready() -> void:
	add_to_group("rewards")
	add_to_group("chests")
	_rng.randomize()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	set_process_unhandled_input(true)
	_update_visual()


func open_for_player(player: Node) -> bool:
	if _opened or player == null or not player.is_in_group("player"):
		return false

	_opened = true
	remove_from_group("rewards")
	_set_collision_enabled(false)
	for index in range(maxi(reward_count, 1)):
		_apply_drop(_pick_drop_kind(index), player)

	Events.chest_opened.emit(self, player, chest_type)
	Events.reward_collected.emit(self, player)
	_update_visual()

	if complete_run_on_open:
		Events.run_completed.emit()

	return true


func is_opened() -> bool:
	return _opened


func get_chest_type() -> String:
	return chest_type


func get_biome_reward_summary() -> Dictionary:
	return {
		"biome_id": biome_id,
		"biome_name": biome_name,
		"reward_weight_multiplier": biome_reward_weight_multiplier,
	}


func _unhandled_input(event: InputEvent) -> void:
	if _nearby_player == null or _opened:
		return
	if event.is_action_pressed("interact"):
		open_for_player(_nearby_player)
		get_viewport().set_input_as_handled()


func _on_body_entered(body: Node) -> void:
	if _opened or not body.is_in_group("player"):
		return

	_nearby_player = body
	_update_visual()


func _on_body_exited(body: Node) -> void:
	if body == _nearby_player:
		_nearby_player = null
		_update_visual()


func _apply_drop(kind: String, player: Node) -> void:
	match kind:
		"heal":
			if player.has_method("heal"):
				player.call("heal", heal_amount)
		"relic":
			_grant_relic()
		"weapon":
			if player.has_method("buy_weapon"):
				player.call("buy_weapon", _pick_resource(weapon_pool, biome_reward_weight_multiplier))
		_:
			if player.has_method("add_gold"):
				player.call("add_gold", _roll_gold())


func _grant_relic() -> void:
	var relic_system := get_tree().get_first_node_in_group("relic_system")
	if relic_system == null or not relic_system.has_method("obtain_relic"):
		return

	if relic_system.has_method("choose_reward_relic"):
		var source := _get_relic_source_name()
		var source_relic: Resource = relic_system.call("choose_reward_relic", source, biome_reward_weight_multiplier)
		if source_relic != null and bool(relic_system.call("obtain_relic", source_relic)):
			return

	var relic := _pick_resource(relic_pool, biome_reward_weight_multiplier)
	if relic != null:
		relic_system.call("obtain_relic", relic)


func _pick_drop_kind(index: int) -> String:
	if drop_pool.is_empty():
		return "gold"

	if reward_count > 1:
		return str(drop_pool[index % drop_pool.size()])

	return str(drop_pool[_rng.randi_range(0, drop_pool.size() - 1)])


func _roll_gold() -> int:
	var low := mini(gold_min, gold_max)
	var high := maxi(gold_min, gold_max)
	return maxi(1, roundi(float(_rng.randi_range(low, high)) * _get_reward_value_multiplier()))


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
			return multiplier
		"epic":
			return multiplier * multiplier
		"legendary":
			return multiplier * multiplier * multiplier
	return 1.0


func _get_reward_value_multiplier() -> float:
	return maxf(biome_reward_weight_multiplier, 0.1)


func _set_collision_enabled(enabled: bool) -> void:
	for child in get_children():
		if child is CollisionShape2D:
			(child as CollisionShape2D).set_deferred("disabled", not enabled)


func _update_visual() -> void:
	if label != null:
		if _opened:
			label.text = "Opened"
		elif _nearby_player != null:
			label.text = "%s\nPress E" % _get_label_text()
		else:
			label.text = _get_label_text()

	if lid != null:
		lid.visible = not _opened

	if visual != null:
		if _opened:
			visual.modulate = Color(0.42, 0.45, 0.48, 1.0)
		elif chest_type == "premium":
			visual.modulate = Color(0.78, 0.46, 1.0, 1.0)
		elif chest_type == "weapon":
			visual.modulate = Color(0.24, 0.58, 0.92, 1.0)
		elif chest_type == "healing":
			visual.modulate = Color(0.24, 0.74, 0.42, 1.0)
		elif chest_type == "boss":
			visual.modulate = Color(1.0, 0.72, 0.22, 1.0)
		else:
			visual.modulate = Color(0.74, 0.48, 0.22, 1.0)


func _get_label_text() -> String:
	match chest_type:
		"premium":
			return "Premium Chest"
		"weapon":
			return "Weapon Chest"
		"healing":
			return "Healing Cache"
		"boss":
			return "Boss Chest"
	return "Chest"


func _get_relic_source_name() -> String:
	match chest_type:
		"premium":
			return "premium_chest"
		"boss":
			return "boss_chest"
	return "normal_chest"

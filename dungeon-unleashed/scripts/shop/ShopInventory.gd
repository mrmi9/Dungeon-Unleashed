extends Node2D
class_name ShopInventory

const SHOP_ITEM_SCENE := preload("res://scenes/shop/ShopItem.tscn")
const ITEM_TYPE_HEAL := 0
const ITEM_TYPE_RELIC := 1
const ITEM_TYPE_WEAPON := 2

@export var heal_price: int = 30
@export var relic_price: int = 110
@export var weapon_price: int = 160
@export var heal_amount: int = 2
@export var biome_id: String = "prototype_depths"
@export var biome_name: String = "Prototype Depths"
@export var biome_reward_weight_multiplier: float = 1.0
@export var random_seed: int = 0
@export var relic_pool: Array[Resource] = [
	preload("res://resources/relics/sharp_rounds.tres"),
	preload("res://resources/relics/quick_trigger.tres"),
	preload("res://resources/relics/split_chamber.tres"),
	preload("res://resources/relics/vampire_fang.tres"),
	preload("res://resources/relics/guardian_ward.tres"),
	preload("res://resources/relics/keen_sights.tres"),
	preload("res://resources/relics/hollow_needle.tres"),
	preload("res://resources/relics/scatter_lens.tres"),
	preload("res://resources/relics/momentum_coil.tres"),
	preload("res://resources/relics/steady_capacitor.tres"),
	preload("res://resources/relics/gilded_tip.tres"),
	preload("res://resources/relics/echo_chamber.tres"),
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

@onready var slots: Array[Marker2D] = [
	$Slots/HealSlot,
	$Slots/RelicSlot,
	$Slots/WeaponSlot,
]

var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	add_to_group("rewards")
	add_to_group("shop_inventories")
	_prepare_random_seed()
	_spawn_inventory()


func get_shop_items() -> Array:
	var items: Array = []
	for child in get_children():
		if child.has_method("get_item_type_name"):
			items.append(child)
	return items


func get_biome_reward_summary() -> Dictionary:
	return {
		"biome_id": biome_id,
		"biome_name": biome_name,
		"reward_weight_multiplier": biome_reward_weight_multiplier,
		"random_seed": random_seed,
	}


func set_random_seed(seed: int) -> void:
	random_seed = seed
	_rng.seed = seed


func get_random_seed() -> int:
	return random_seed


func get_inventory_signature() -> String:
	var entries: Array[String] = []
	for item in get_shop_items():
		entries.append("%s:%s:%d" % [str(item.call("get_item_type_name")), str(item.call("get_payload_id")), int(item.call("get_price"))])
	return "|".join(entries)


func _prepare_random_seed() -> void:
	if random_seed != 0:
		_rng.seed = random_seed
		return
	_rng.randomize()
	random_seed = int(_rng.seed)


func _spawn_inventory() -> void:
	_spawn_item(slots[0], ITEM_TYPE_HEAL, heal_price, null, heal_amount)
	_spawn_item(slots[1], ITEM_TYPE_RELIC, relic_price, _pick_relic_for_shop())
	_spawn_item(slots[2], ITEM_TYPE_WEAPON, weapon_price, _pick_resource(weapon_pool, biome_reward_weight_multiplier))


func _spawn_item(slot: Marker2D, item_type: int, item_price: int, payload: Resource = null, item_heal_amount: int = 2) -> void:
	var item := SHOP_ITEM_SCENE.instantiate()
	if item == null:
		return

	add_child(item)
	item.position = slot.position
	item.configure(item_type, item_price, payload, item_heal_amount)


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


func _pick_relic_for_shop() -> Resource:
	var relic_system := get_tree().get_first_node_in_group("relic_system")
	if relic_system != null and relic_system.has_method("choose_reward_relic"):
		var relic: Resource = relic_system.call("choose_reward_relic", "shop", biome_reward_weight_multiplier)
		if relic != null:
			return relic
	return _pick_resource(relic_pool, biome_reward_weight_multiplier)

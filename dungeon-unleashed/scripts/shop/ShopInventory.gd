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
@export var relic_pool: Array[Resource] = [
	preload("res://resources/relics/sharp_rounds.tres"),
	preload("res://resources/relics/quick_trigger.tres"),
	preload("res://resources/relics/split_chamber.tres"),
	preload("res://resources/relics/vampire_fang.tres"),
	preload("res://resources/relics/guardian_ward.tres"),
]
@export var weapon_pool: Array[Resource] = [
	preload("res://resources/weapons/ricochet_blaster.tres"),
	preload("res://resources/weapons/shotgun.tres"),
	preload("res://resources/weapons/energy_staff.tres"),
	preload("res://resources/weapons/arc_blade.tres"),
	preload("res://resources/weapons/nova_core.tres"),
	preload("res://resources/weapons/blast_launcher.tres"),
	preload("res://resources/weapons/laser_lance.tres"),
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
	_rng.randomize()
	_spawn_inventory()


func get_shop_items() -> Array:
	var items: Array = []
	for child in get_children():
		if child.has_method("get_item_type_name"):
			items.append(child)
	return items


func _spawn_inventory() -> void:
	_spawn_item(slots[0], ITEM_TYPE_HEAL, heal_price, null, heal_amount)
	_spawn_item(slots[1], ITEM_TYPE_RELIC, relic_price, _pick_relic_for_shop())
	_spawn_item(slots[2], ITEM_TYPE_WEAPON, weapon_price, _pick_resource(weapon_pool))


func _spawn_item(slot: Marker2D, item_type: int, item_price: int, payload: Resource = null, item_heal_amount: int = 2) -> void:
	var item := SHOP_ITEM_SCENE.instantiate()
	if item == null:
		return

	add_child(item)
	item.position = slot.position
	item.configure(item_type, item_price, payload, item_heal_amount)


func _pick_resource(pool: Array[Resource]) -> Resource:
	var candidates: Array[Resource] = []
	for resource in pool:
		if resource != null:
			candidates.append(resource)
	if candidates.is_empty():
		return null
	return candidates[_rng.randi_range(0, candidates.size() - 1)]


func _pick_relic_for_shop() -> Resource:
	var relic_system := get_tree().get_first_node_in_group("relic_system")
	if relic_system != null and relic_system.has_method("choose_reward_relic"):
		var relic: Resource = relic_system.call("choose_reward_relic", "shop")
		if relic != null:
			return relic
	return _pick_resource(relic_pool)

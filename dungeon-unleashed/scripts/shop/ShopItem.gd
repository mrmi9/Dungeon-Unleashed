extends Area2D
class_name ShopItem

enum ItemType {
	HEAL,
	RELIC,
	WEAPON,
}

@export var item_type: ItemType = ItemType.HEAL
@export var price: int = 12
@export var heal_amount: int = 2
@export var relic_data: Resource
@export var weapon_data: Resource

@onready var visual: CanvasItem = $Visual
@onready var label: Label = $Label

var _sold_out := false
var _nearby_player: Node


func _ready() -> void:
	add_to_group("shop_items")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	set_process_unhandled_input(true)
	_refresh_label()


func configure(new_item_type: int, new_price: int, payload: Resource = null, new_heal_amount: int = 2) -> void:
	item_type = new_item_type
	price = maxi(new_price, 0)
	heal_amount = maxi(new_heal_amount, 1)
	match item_type:
		ItemType.RELIC:
			relic_data = payload
		ItemType.WEAPON:
			weapon_data = payload
		_:
			pass
	if is_inside_tree():
		_refresh_label()


func get_item_type_name() -> String:
	match item_type:
		ItemType.HEAL:
			return "Heal"
		ItemType.RELIC:
			return "Relic"
		ItemType.WEAPON:
			return "Weapon"
	return "Unknown"


func get_price() -> int:
	return price


func get_purchase_price_for_player(buyer: Node) -> int:
	if buyer != null and buyer.has_method("get_shop_purchase_price"):
		return maxi(int(buyer.call("get_shop_purchase_price", price)), 0)
	return price


func get_display_name() -> String:
	match item_type:
		ItemType.HEAL:
			return "Heal +%d" % heal_amount
		ItemType.RELIC:
			return _resource_display_name(relic_data, "Relic")
		ItemType.WEAPON:
			return _resource_display_name(weapon_data, "Weapon")
	return "Unknown"


func get_payload_id() -> String:
	match item_type:
		ItemType.RELIC:
			return _resource_id(relic_data)
		ItemType.WEAPON:
			return _resource_id(weapon_data)
	return ""


func is_sold_out() -> bool:
	return _sold_out


func purchase_for_player(buyer: Node) -> bool:
	if _sold_out or buyer == null or not buyer.is_in_group("player"):
		return false

	var purchase_price := get_purchase_price_for_player(buyer)
	if not buyer.has_method("spend_gold") or not bool(buyer.call("spend_gold", purchase_price)):
		Events.shop_purchase_failed.emit(self, buyer, purchase_price, "not_enough_gold")
		_flash(Color(1.0, 0.18, 0.12, 1.0), 0.16)
		return false

	if not _apply_purchase(buyer):
		if buyer.has_method("add_gold"):
			buyer.call("add_gold", purchase_price)
		Events.shop_purchase_failed.emit(self, buyer, purchase_price, "cannot_apply_item")
		_flash(Color(1.0, 0.18, 0.12, 1.0), 0.16)
		return false

	if buyer.has_method("has_shop_discount") and bool(buyer.call("has_shop_discount")) and buyer.has_method("consume_shop_discount"):
		buyer.call("consume_shop_discount")

	_sold_out = true
	_nearby_player = null
	Events.shop_item_purchased.emit(self, buyer, purchase_price, get_item_type_name())
	Events.reward_collected.emit(self, buyer)
	_refresh_label()
	_set_collision_enabled(false)
	_flash(Color(0.45, 1.0, 0.48, 1.0), 0.18)
	return true


func _unhandled_input(event: InputEvent) -> void:
	if _nearby_player == null or _sold_out:
		return
	if event.is_action_pressed("interact"):
		purchase_for_player(_nearby_player)
		get_viewport().set_input_as_handled()


func _on_body_entered(body: Node) -> void:
	if _sold_out or not body.is_in_group("player"):
		return

	_nearby_player = body
	_refresh_label()


func _on_body_exited(body: Node) -> void:
	if body == _nearby_player:
		_nearby_player = null
		_refresh_label()


func _apply_purchase(buyer: Node) -> bool:
	match item_type:
		ItemType.HEAL:
			if buyer.has_method("heal"):
				buyer.call("heal", heal_amount)
				return true
		ItemType.RELIC:
			var relic_system := get_tree().get_first_node_in_group("relic_system")
			if relic_system != null and relic_system.has_method("obtain_relic") and relic_data != null:
				return bool(relic_system.call("obtain_relic", relic_data))
		ItemType.WEAPON:
			if buyer.has_method("buy_weapon") and weapon_data != null:
				return bool(buyer.call("buy_weapon", weapon_data))
	return false


func _refresh_label() -> void:
	if label == null:
		return

	if _sold_out:
		label.text = "SOLD OUT"
		if visual != null:
			visual.modulate = Color(0.32, 0.34, 0.38, 1.0)
		return

	var display_price := get_purchase_price_for_player(_nearby_player)
	var price_text := "%d Gold" % display_price
	if display_price < price:
		price_text = "%d Gold (was %d)" % [display_price, price]
	if _nearby_player != null:
		label.text = "%s\n%s\nPress E" % [get_display_name(), price_text]
	else:
		label.text = "%s\n%s" % [get_display_name(), price_text]
	if visual != null:
		match item_type:
			ItemType.HEAL:
				visual.modulate = Color(0.28, 1.0, 0.48, 1.0)
			ItemType.RELIC:
				visual.modulate = Color(0.78, 0.42, 1.0, 1.0)
			ItemType.WEAPON:
				visual.modulate = Color(0.38, 0.76, 1.0, 1.0)


func _set_collision_enabled(enabled: bool) -> void:
	for child in get_children():
		if child is CollisionShape2D:
			(child as CollisionShape2D).set_deferred("disabled", not enabled)


func _flash(color: Color, duration: float) -> void:
	if visual == null:
		return

	var final_color := visual.modulate
	visual.modulate = color
	var tween := create_tween()
	tween.tween_property(visual, "modulate", final_color, duration)


func _resource_display_name(resource: Resource, fallback: String) -> String:
	if resource == null:
		return fallback
	var value = resource.get("display_name")
	if value == null:
		return fallback
	return str(value)


func _resource_id(resource: Resource) -> String:
	if resource == null:
		return ""
	var value = resource.get("id")
	if value == null:
		return ""
	return str(value)

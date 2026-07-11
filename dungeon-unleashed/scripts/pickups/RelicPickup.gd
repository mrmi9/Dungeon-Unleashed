extends Area2D
class_name RelicPickup

@export var relic_data: Resource = preload("res://resources/relics/sharp_rounds.tres")
@export var choice_count: int = 3
@export var biome_id: String = "prototype_depths"
@export var biome_name: String = "Prototype Depths"
@export var biome_reward_weight_multiplier: float = 1.0

@onready var visual: Polygon2D = $Visual
@onready var label: Label = $Label

var _claimed := false
var _pulse_time := 0.0


func _ready() -> void:
	add_to_group("rewards")
	body_entered.connect(_on_body_entered)
	_update_label()


func _process(delta: float) -> void:
	_pulse_time += delta
	var scale_amount := 1.0 + sin(_pulse_time * 5.5) * 0.06
	visual.scale = Vector2.ONE * scale_amount


func _on_body_entered(body: Node) -> void:
	claim_for_player(body)


func claim_for_player(body: Node) -> bool:
	if _claimed or not body.is_in_group("player"):
		return false

	var relic_system := get_tree().get_first_node_in_group("relic_system")
	if relic_system == null or not relic_system.has_method("get_reward_choices"):
		return false

	var choices: Array = relic_system.call("get_reward_choices", choice_count, "reward", biome_reward_weight_multiplier)
	if choices.is_empty():
		return false

	_claimed = true
	remove_from_group("rewards")
	set_deferred("monitoring", false)
	visible = false
	Events.relic_choice_requested.emit(choices, self, body)
	return true


func is_claimed() -> bool:
	return _claimed


func get_biome_reward_summary() -> Dictionary:
	return {
		"biome_id": biome_id,
		"biome_name": biome_name,
		"reward_weight_multiplier": biome_reward_weight_multiplier,
	}


func _update_label() -> void:
	if relic_data == null:
		label.text = "Relic"
		return

	label.text = "Choose Relic"

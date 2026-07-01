extends Area2D
class_name CoinPickup

@export var gold_value: int = 10

@onready var visual: CanvasItem = $Visual

var _claimed := false
var _pulse_time := 0.0


func _ready() -> void:
	add_to_group("rewards")
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_pulse_time += delta
	var scale_amount := 1.0 + sin(_pulse_time * 7.0) * 0.08
	visual.scale = Vector2.ONE * scale_amount


func _on_body_entered(body: Node) -> void:
	claim_for_player(body)


func claim_for_player(body: Node) -> bool:
	if _claimed or not body.is_in_group("player"):
		return false

	_claimed = true
	if body.has_method("add_gold"):
		body.call("add_gold", gold_value)

	Events.reward_collected.emit(self, body)
	queue_free()
	return true

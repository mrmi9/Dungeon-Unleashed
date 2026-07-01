extends Area2D
class_name RewardChest

@export var chest_type: String = "normal"
@export var reward_count: int = 1
@export var drop_pool: PackedStringArray = PackedStringArray(["gold"])
@export var gold_min: int = 8
@export var gold_max: int = 16
@export var heal_amount: int = 2
@export var relic_pool: Array[Resource] = [
	preload("res://resources/relics/sharp_rounds.tres"),
	preload("res://resources/relics/quick_trigger.tres"),
	preload("res://resources/relics/split_chamber.tres"),
	preload("res://resources/relics/phase_tip.tres"),
]
@export var weapon_pool: Array[Resource] = [
	preload("res://resources/weapons/ricochet_blaster.tres"),
	preload("res://resources/weapons/shotgun.tres"),
	preload("res://resources/weapons/energy_staff.tres"),
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
				player.call("buy_weapon", _pick_resource(weapon_pool))
		_:
			if player.has_method("add_gold"):
				player.call("add_gold", _roll_gold())


func _grant_relic() -> void:
	var relic_system := get_tree().get_first_node_in_group("relic_system")
	if relic_system == null or not relic_system.has_method("obtain_relic"):
		return

	if relic_system.has_method("choose_reward_relic"):
		var source := _get_relic_source_name()
		var source_relic: Resource = relic_system.call("choose_reward_relic", source)
		if source_relic != null and bool(relic_system.call("obtain_relic", source_relic)):
			return

	var relic := _pick_resource(relic_pool)
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
	return _rng.randi_range(low, high)


func _pick_resource(pool: Array[Resource]) -> Resource:
	var candidates: Array[Resource] = []
	for resource in pool:
		if resource != null:
			candidates.append(resource)
	if candidates.is_empty():
		return null
	return candidates[_rng.randi_range(0, candidates.size() - 1)]


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
		elif chest_type == "boss":
			visual.modulate = Color(1.0, 0.72, 0.22, 1.0)
		else:
			visual.modulate = Color(0.74, 0.48, 0.22, 1.0)


func _get_label_text() -> String:
	match chest_type:
		"premium":
			return "Premium Chest"
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

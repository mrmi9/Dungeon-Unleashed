extends StaticBody2D
class_name TrainingDummy

@export var display_name := "Training Dummy"
@export var max_health := 9999
@export var target_type := "standard"
@export var movement_axis := Vector2.ZERO
@export var movement_distance := 0.0
@export var movement_speed := 0.0
@export_range(0.1, 1.0, 0.05) var armored_damage_multiplier := 0.5
@export_range(0.1, 3.0, 0.05) var burst_chain_window := 0.8

@onready var visual: CanvasItem = $Visual
@onready var core: CanvasItem = $Core
@onready var label: Label = $Label

var current_health := 0
var hit_count := 0
var total_damage_taken := 0
var highest_hit := 0
var last_applied_damage := 0
var mitigated_damage := 0
var burst_chain := 0
var best_burst_chain := 0
var _origin_position := Vector2.ZERO
var _movement_time := 0.0
var _last_burst_hit_msec := -1


func _ready() -> void:
	add_to_group("enemies")
	add_to_group("training_dummy")
	_origin_position = global_position
	current_health = max_health
	_apply_target_visuals()
	_update_label()


func _process(delta: float) -> void:
	if movement_distance <= 0.0 or movement_speed <= 0.0 or movement_axis == Vector2.ZERO:
		return

	_movement_time += delta * movement_speed
	global_position = _origin_position + movement_axis.normalized() * sin(_movement_time) * movement_distance


func configure(config: Dictionary) -> void:
	display_name = str(config.get("display_name", display_name))
	target_type = str(config.get("target_type", target_type)).strip_edges().to_lower()
	max_health = int(config.get("max_health", max_health))
	movement_axis = config.get("movement_axis", movement_axis)
	movement_distance = float(config.get("movement_distance", movement_distance))
	movement_speed = float(config.get("movement_speed", movement_speed))
	armored_damage_multiplier = float(config.get("armored_damage_multiplier", armored_damage_multiplier))
	burst_chain_window = float(config.get("burst_chain_window", burst_chain_window))
	current_health = max_health
	if is_node_ready():
		_origin_position = global_position
		_apply_target_visuals()
		_update_label()


func apply_damage(amount: int, _source: Node = null, _knockback_direction: Vector2 = Vector2.ZERO, _knockback_force: float = 0.0) -> void:
	var raw_amount := maxi(amount, 0)
	var final_amount := _get_effective_damage(raw_amount)
	if final_amount <= 0:
		return

	hit_count += 1
	total_damage_taken += final_amount
	highest_hit = maxi(highest_hit, final_amount)
	last_applied_damage = final_amount
	mitigated_damage += maxi(raw_amount - final_amount, 0)
	_record_burst_hit()
	current_health = maxi(current_health - final_amount, 0)
	if current_health <= 0:
		current_health = max_health

	Events.enemy_damaged.emit(self, final_amount)
	_flash(Color(1.0, 0.88, 0.34, 1.0), 0.1)
	_update_label()


func reset_dummy() -> void:
	current_health = max_health
	hit_count = 0
	total_damage_taken = 0
	highest_hit = 0
	last_applied_damage = 0
	mitigated_damage = 0
	burst_chain = 0
	best_burst_chain = 0
	_last_burst_hit_msec = -1
	_apply_target_visuals()
	_update_label()


func is_dead() -> bool:
	return false


func can_deal_contact_damage() -> bool:
	return false


func get_training_summary() -> Dictionary:
	return {
		"target_type": target_type,
		"hits": hit_count,
		"damage": total_damage_taken,
		"best_hit": highest_hit,
		"last_applied_damage": last_applied_damage,
		"mitigated_damage": mitigated_damage,
		"burst_chain": burst_chain,
		"best_burst_chain": best_burst_chain,
	}


func get_target_type() -> String:
	return target_type


func get_last_applied_damage() -> int:
	return last_applied_damage


func get_mitigated_damage() -> int:
	return mitigated_damage


func get_best_burst_chain() -> int:
	return best_burst_chain


func _flash(color: Color, duration: float) -> void:
	visual.modulate = color
	var tween := create_tween()
	tween.tween_property(visual, "modulate", _get_target_color(), duration)


func _apply_target_visuals() -> void:
	if visual != null:
		visual.modulate = _get_target_color()
	if core != null:
		core.modulate = _get_target_core_color()


func _update_label() -> void:
	label.text = "%s\nType %s | Hits %d | Damage %d | Best %d%s%s" % [
		display_name,
		_format_target_type(),
		hit_count,
		total_damage_taken,
		highest_hit,
		(" | Guard %d" % mitigated_damage) if mitigated_damage > 0 else "",
		(" | Chain x%d" % best_burst_chain) if best_burst_chain > 0 else "",
	]


func _format_target_type() -> String:
	var text := target_type.strip_edges()
	if text.is_empty():
		return "Standard"
	return text.replace("_", " ").capitalize()


func _get_target_color() -> Color:
	match target_type:
		"mobile":
			return Color(0.32, 0.86, 1.0, 1.0)
		"armored":
			return Color(0.72, 0.82, 0.94, 1.0)
		"burst":
			return Color(1.0, 0.55, 0.24, 1.0)
		"assist":
			return Color(0.82, 0.54, 1.0, 1.0)
	return Color(0.25, 0.7, 1.0, 1.0)


func _get_effective_damage(raw_amount: int) -> int:
	if target_type == "armored":
		return maxi(roundi(float(raw_amount) * clampf(armored_damage_multiplier, 0.1, 1.0)), 1)
	return raw_amount


func _record_burst_hit() -> void:
	if target_type != "burst":
		return

	var now_msec := Time.get_ticks_msec()
	var window_msec := roundi(clampf(burst_chain_window, 0.1, 3.0) * 1000.0)
	if _last_burst_hit_msec >= 0 and now_msec - _last_burst_hit_msec <= window_msec:
		burst_chain += 1
	else:
		burst_chain = 1
	_last_burst_hit_msec = now_msec
	best_burst_chain = maxi(best_burst_chain, burst_chain)


func _get_target_core_color() -> Color:
	match target_type:
		"mobile":
			return Color(0.36, 1.0, 0.72, 1.0)
		"armored":
			return Color(0.92, 0.96, 1.0, 1.0)
		"burst":
			return Color(1.0, 0.86, 0.34, 1.0)
		"assist":
			return Color(0.52, 0.9, 1.0, 1.0)
	return Color(1.0, 0.82, 0.28, 1.0)

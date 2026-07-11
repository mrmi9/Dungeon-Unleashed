extends RefCounted
class_name ControllerLayout

const DEFAULT_LAYOUT := preload("res://resources/input/default_controller_layout.tres")

static var _aim_deadzone_override := -1.0
static var _aim_target_distance_override := -1.0
static var _input_switch_threshold_override := -1.0
static var _mouse_return_threshold_override := -1.0


static func get_items() -> Array:
	return DEFAULT_LAYOUT.get_items()


static func format_hint() -> String:
	return DEFAULT_LAYOUT.format_hint()


static func get_summary() -> Dictionary:
	var summary := DEFAULT_LAYOUT.get_summary()
	summary["tuning"] = get_tuning_summary()
	return summary


static func get_tuning_summary() -> Dictionary:
	return {
		"aim_deadzone": get_aim_deadzone(),
		"aim_target_distance": get_aim_target_distance(),
		"input_switch_threshold": get_input_switch_threshold(),
		"mouse_return_threshold": get_mouse_return_threshold(),
		"defaults": DEFAULT_LAYOUT.get_tuning_summary(),
	}


static func configure_tuning(aim_deadzone = null, input_switch_threshold = null, aim_target_distance = null, mouse_return_threshold = null) -> void:
	if aim_deadzone != null:
		_aim_deadzone_override = clamp_aim_deadzone(float(aim_deadzone))
	if input_switch_threshold != null:
		_input_switch_threshold_override = clamp_input_switch_threshold(float(input_switch_threshold))
	if aim_target_distance != null:
		_aim_target_distance_override = clamp_aim_target_distance(float(aim_target_distance))
	if mouse_return_threshold != null:
		_mouse_return_threshold_override = clamp_mouse_return_threshold(float(mouse_return_threshold))


static func reset_tuning_overrides() -> void:
	_aim_deadzone_override = -1.0
	_aim_target_distance_override = -1.0
	_input_switch_threshold_override = -1.0
	_mouse_return_threshold_override = -1.0


static func get_default_aim_deadzone() -> float:
	return DEFAULT_LAYOUT.aim_deadzone


static func get_default_aim_target_distance() -> float:
	return DEFAULT_LAYOUT.aim_target_distance


static func get_default_input_switch_threshold() -> float:
	return DEFAULT_LAYOUT.input_switch_threshold


static func get_default_mouse_return_threshold() -> float:
	return DEFAULT_LAYOUT.mouse_return_threshold


static func get_aim_deadzone() -> float:
	if _aim_deadzone_override >= 0.0:
		return _aim_deadzone_override
	return get_default_aim_deadzone()


static func get_aim_target_distance() -> float:
	if _aim_target_distance_override >= 0.0:
		return _aim_target_distance_override
	return get_default_aim_target_distance()


static func get_input_switch_threshold() -> float:
	if _input_switch_threshold_override >= 0.0:
		return _input_switch_threshold_override
	return get_default_input_switch_threshold()


static func get_mouse_return_threshold() -> float:
	if _mouse_return_threshold_override >= 0.0:
		return _mouse_return_threshold_override
	return get_default_mouse_return_threshold()


static func clamp_aim_deadzone(value: float) -> float:
	return clampf(value, 0.0, 0.95)


static func clamp_aim_target_distance(value: float) -> float:
	return maxf(value, 1.0)


static func clamp_input_switch_threshold(value: float) -> float:
	return clampf(value, 0.0, 1.0)


static func clamp_mouse_return_threshold(value: float) -> float:
	return maxf(value, 0.0)

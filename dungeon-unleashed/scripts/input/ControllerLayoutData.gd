extends Resource
class_name ControllerLayoutData

@export var scheme: String = "default_gamepad"
@export var item_ids: PackedStringArray = []
@export var item_labels: PackedStringArray = []
@export var item_controls: PackedStringArray = []
@export var item_actions: PackedStringArray = []
@export_range(0.0, 0.95, 0.01) var aim_deadzone: float = 0.22
@export var aim_target_distance: float = 900.0
@export_range(0.0, 1.0, 0.01) var input_switch_threshold: float = 0.45
@export var mouse_return_threshold: float = 2.0


func get_items() -> Array:
	var items := []
	var item_count := mini(item_ids.size(), mini(item_labels.size(), item_controls.size()))
	for index in range(item_count):
		items.append({
			"id": item_ids[index],
			"label": item_labels[index],
			"control": item_controls[index],
			"actions": _get_item_actions(index),
		})
	return items


func format_hint() -> String:
	var parts: Array[String] = []
	for item in get_items():
		var label := str(item.get("label", ""))
		var control := str(item.get("control", ""))
		if label.is_empty() or control.is_empty():
			continue
		parts.append("%s %s" % [label, control])
	return " | ".join(parts)


func get_summary() -> Dictionary:
	return {
		"scheme": scheme,
		"hint": format_hint(),
		"items": get_items(),
		"tuning": get_tuning_summary(),
	}


func get_tuning_summary() -> Dictionary:
	return {
		"aim_deadzone": aim_deadzone,
		"aim_target_distance": aim_target_distance,
		"input_switch_threshold": input_switch_threshold,
		"mouse_return_threshold": mouse_return_threshold,
	}


func _get_item_actions(index: int) -> PackedStringArray:
	if index < 0 or index >= item_actions.size():
		return PackedStringArray()

	var actions := PackedStringArray()
	for action_name in item_actions[index].split(",", false):
		var normalized := action_name.strip_edges()
		if normalized.is_empty():
			continue
		actions.append(normalized)
	return actions

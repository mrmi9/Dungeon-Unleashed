extends Node
class_name BlessingSystem

const RARITY_WEIGHTS := {
	"common": 100.0,
	"rare": 48.0,
	"epic": 18.0,
	"legendary": 6.0,
}

@export var player_path: NodePath = ^"../Player"
@export var available_blessings: Array[Resource] = [
	preload("res://resources/blessings/deep_cell.tres"),
	preload("res://resources/blessings/quiet_plate.tres"),
	preload("res://resources/blessings/ember_tithe.tres"),
	preload("res://resources/blessings/afterglow_circuit.tres"),
	preload("res://resources/blessings/spark_dividend.tres"),
	preload("res://resources/blessings/brace_current.tres"),
	preload("res://resources/blessings/resonance_battery.tres"),
]

var _player: Node
var _owned_blessings: Array[Resource] = []
var _stacks_by_id: Dictionary = {}
var _trigger_counts_by_id: Dictionary = {}
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	add_to_group("blessing_system")
	_rng.randomize()
	Events.enemy_died.connect(_on_enemy_died)
	Events.room_cleared.connect(_on_room_cleared)
	Events.player_damaged.connect(_on_player_damaged)
	Events.statue_triggered.connect(_on_statue_triggered)
	call_deferred("_resolve_player")


func reset_run() -> void:
	_owned_blessings.clear()
	_stacks_by_id.clear()
	_trigger_counts_by_id.clear()
	Events.blessings_changed.emit(get_blessing_summaries())


func set_random_seed(seed: int) -> void:
	_rng.seed = seed


func get_reward_choices(choice_count: int = 3, _source: String = "event", weight_multiplier: float = 1.0) -> Array:
	var choices: Array = []
	var candidates := _get_obtainable_blessings()
	while choices.size() < choice_count and not candidates.is_empty():
		var blessing := _pick_weighted_blessing(candidates, weight_multiplier)
		if blessing == null:
			break
		choices.append(blessing)
		candidates.erase(blessing)
	return choices


func obtain_blessing(blessing_data: Resource) -> bool:
	if blessing_data == null or not _can_obtain(blessing_data):
		return false

	var blessing_id := _get_blessing_id(blessing_data)
	var stack_count := int(_stacks_by_id.get(blessing_id, 0)) + 1
	_stacks_by_id[blessing_id] = stack_count
	if not _owned_blessings.has(blessing_data):
		_owned_blessings.append(blessing_data)

	_apply_blessing_effect(blessing_data)
	Events.blessing_collected.emit(blessing_data, stack_count)
	Events.blessings_changed.emit(get_blessing_summaries())
	return true


func get_blessing_summaries() -> Array:
	var summaries: Array = []
	for blessing in _owned_blessings:
		var blessing_id := _get_blessing_id(blessing)
		summaries.append({
			"id": blessing_id,
			"display_name": str(blessing.get("display_name")),
			"description": str(blessing.get("description")),
			"rarity": str(blessing.get("rarity")),
			"duration_scope": str(blessing.get("duration_scope")),
			"trigger_event": str(blessing.get("trigger_event")),
			"trigger_interval": _get_trigger_interval(blessing),
			"effect_type": str(blessing.get("effect_type")),
			"effect_value": float(blessing.get("effect_value")),
			"effect_duration": float(blessing.get("effect_duration")),
			"rule_text": str(blessing.get("rule_text")),
			"build_tags": blessing.get("build_tags"),
			"stacks": int(_stacks_by_id.get(blessing_id, 0)),
		})
	return summaries


func get_blessing_count() -> int:
	return _owned_blessings.size()


func get_stack_count(blessing_id: String) -> int:
	return int(_stacks_by_id.get(blessing_id, 0))


func _resolve_player() -> void:
	_player = get_node_or_null(player_path)


func _get_obtainable_blessings() -> Array[Resource]:
	var candidates: Array[Resource] = []
	for blessing in available_blessings:
		if blessing is Resource and _can_obtain(blessing):
			candidates.append(blessing)
	return candidates


func _can_obtain(blessing_data: Resource) -> bool:
	if blessing_data == null:
		return false

	var blessing_id := _get_blessing_id(blessing_data)
	if blessing_id.is_empty() or int(_stacks_by_id.get(blessing_id, 0)) > 0:
		return false

	var new_conflicts := _get_string_set(blessing_data.get("conflict_tags"))
	if new_conflicts.is_empty():
		return true

	for owned in _owned_blessings:
		var owned_conflicts := _get_string_set(owned.get("conflict_tags"))
		for tag in new_conflicts.keys():
			if owned_conflicts.has(tag):
				return false
	return true


func _pick_weighted_blessing(candidates: Array[Resource], weight_multiplier: float = 1.0) -> Resource:
	if candidates.is_empty():
		return null

	var total_weight := 0.0
	for blessing in candidates:
		total_weight += maxf(_get_blessing_weight(blessing, weight_multiplier), 0.0)

	if total_weight <= 0.0:
		return candidates[_rng.randi_range(0, candidates.size() - 1)]

	var roll := _rng.randf_range(0.0, total_weight)
	for blessing in candidates:
		roll -= maxf(_get_blessing_weight(blessing, weight_multiplier), 0.0)
		if roll <= 0.0:
			return blessing
	return candidates[candidates.size() - 1]


func _get_blessing_weight(blessing_data: Resource, weight_multiplier: float = 1.0) -> float:
	if blessing_data == null:
		return 0.0
	var rarity_weight := float(RARITY_WEIGHTS.get(str(blessing_data.get("rarity")), 1.0))
	return rarity_weight * maxf(float(blessing_data.get("drop_weight")), 0.0) * _get_rarity_multiplier(str(blessing_data.get("rarity")), weight_multiplier)


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


func _apply_blessing_effect(blessing_data: Resource) -> void:
	if str(blessing_data.get("trigger_event")) != "passive":
		return

	_apply_player_blessing_effect(blessing_data)


func _on_room_cleared(_room: Node) -> void:
	_apply_triggered_blessing_effect("on_room_clear")


func _on_enemy_died(_enemy: Node) -> void:
	_apply_triggered_blessing_effect("on_kill")


func _on_player_damaged(_amount: int, _current_hp: int) -> void:
	_apply_triggered_blessing_effect("on_hurt")


func _on_statue_triggered(_statue_data: Resource, _trigger_event: String, _effect_type: String, _effect_value: float) -> void:
	_apply_triggered_blessing_effect("on_statue_triggered")


func _apply_triggered_blessing_effect(trigger_event: String) -> void:
	for blessing in _owned_blessings:
		if str(blessing.get("trigger_event")) == trigger_event and _should_apply_triggered_blessing(blessing):
			if _apply_player_blessing_effect(blessing):
				Events.blessing_triggered.emit(
					blessing,
					trigger_event,
					str(blessing.get("effect_type")),
					float(blessing.get("effect_value"))
				)


func _should_apply_triggered_blessing(blessing_data: Resource) -> bool:
	var blessing_id := _get_blessing_id(blessing_data)
	if blessing_id.is_empty():
		return false

	var trigger_interval := _get_trigger_interval(blessing_data)
	var count := int(_trigger_counts_by_id.get(blessing_id, 0)) + 1
	_trigger_counts_by_id[blessing_id] = count
	return count % trigger_interval == 0


func _apply_player_blessing_effect(blessing_data: Resource) -> bool:
	if _player == null:
		_resolve_player()
	if _player == null:
		return false

	var effect_type := str(blessing_data.get("effect_type"))
	var effect_value := float(blessing_data.get("effect_value"))
	match effect_type:
		"recover_energy":
			return _apply_player_method("recover_energy", maxi(roundi(effect_value), 1))
		"heal":
			return _apply_player_method("heal", maxi(roundi(effect_value), 1))
		"gain_shield":
			return _apply_player_method("add_shield", maxi(roundi(effect_value), 1))
		"temporary_combat_rule":
			return _apply_player_method(
				"apply_temporary_combat_rule",
				_get_blessing_id(blessing_data),
				maxf(effect_value, 0.0),
				0.0,
				maxf(float(blessing_data.get("effect_duration")), 0.1)
			)
		_:
			return _apply_player_method("apply_relic_effect", effect_type, effect_value)


func _apply_player_method(method_name: String, value_1, value_2 = null, value_3 = null, value_4 = null) -> bool:
	if _player == null:
		_resolve_player()
	if _player == null or not _player.has_method(method_name):
		return false

	if value_4 != null:
		_player.call(method_name, value_1, value_2, value_3, value_4)
	elif value_3 != null:
		_player.call(method_name, value_1, value_2, value_3)
	elif value_2 != null:
		_player.call(method_name, value_1, value_2)
	else:
		_player.call(method_name, value_1)
	return true


func _get_blessing_id(blessing_data: Resource) -> String:
	var value = blessing_data.get("id")
	if value == null:
		return ""
	return str(value)


func _get_trigger_interval(blessing_data: Resource) -> int:
	if blessing_data == null:
		return 1
	var value = blessing_data.get("trigger_interval")
	if value == null:
		return 1
	return maxi(int(value), 1)


func _get_string_set(value) -> Dictionary:
	var result := {}
	if value is PackedStringArray:
		for item in value:
			var tag := str(item)
			if not tag.is_empty():
				result[tag] = true
	elif value is Array:
		for item in value:
			var tag := str(item)
			if not tag.is_empty():
				result[tag] = true
	return result

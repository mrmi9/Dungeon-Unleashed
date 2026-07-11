extends Node
class_name StatueSystem

const RARITY_WEIGHTS := {
	"common": 100.0,
	"rare": 48.0,
	"epic": 18.0,
	"legendary": 6.0,
}

@export var player_path: NodePath = ^"../Player"
@export var available_statues: Array[Resource] = [
	preload("res://resources/statues/bulwark_idol.tres"),
	preload("res://resources/statues/cinder_focus.tres"),
	preload("res://resources/statues/echo_reservoir.tres"),
]

var _player: Node
var _owned_statues: Array[Resource] = []
var _stacks_by_id: Dictionary = {}
var _trigger_counts_by_id: Dictionary = {}
var _attunements_by_id: Dictionary = {}
var _rng := RandomNumberGenerator.new()
var _configured_random_seed := 0


func _ready() -> void:
	add_to_group("statue_system")
	_prepare_random_seed()
	Events.player_skill_used.connect(_on_player_skill_used)
	call_deferred("_resolve_player")


func reset_run() -> void:
	_owned_statues.clear()
	_stacks_by_id.clear()
	_trigger_counts_by_id.clear()
	_attunements_by_id.clear()
	if _configured_random_seed != 0:
		_rng.seed = _configured_random_seed
	Events.statues_changed.emit(get_statue_summaries())


func set_random_seed(seed: int) -> void:
	_configured_random_seed = seed
	_rng.seed = seed


func get_random_seed() -> int:
	return _configured_random_seed


func _prepare_random_seed() -> void:
	if _configured_random_seed != 0:
		_rng.seed = _configured_random_seed
		return
	_rng.randomize()
	_configured_random_seed = int(_rng.seed)


func get_reward_choices(choice_count: int = 3, _source: String = "event", weight_multiplier: float = 1.0) -> Array:
	var choices: Array = []
	var candidates := _get_obtainable_statues()
	while choices.size() < choice_count and not candidates.is_empty():
		var statue := _pick_weighted_statue(candidates, weight_multiplier)
		if statue == null:
			break
		choices.append(statue)
		candidates.erase(statue)
	return choices


func obtain_statue(statue_data: Resource) -> bool:
	if statue_data == null or not _can_obtain(statue_data):
		return false

	var statue_id := _get_statue_id(statue_data)
	var stack_count := int(_stacks_by_id.get(statue_id, 0)) + 1
	_stacks_by_id[statue_id] = stack_count
	if not _owned_statues.has(statue_data):
		_owned_statues.append(statue_data)

	Events.statue_collected.emit(statue_data, stack_count)
	Events.statues_changed.emit(get_statue_summaries())
	return true


func attune_statue(statue_id: String = "") -> bool:
	var statue := _get_owned_statue_by_id(statue_id)
	if statue == null:
		statue = _pick_owned_statue_for_attunement()
	if statue == null:
		return false

	var resolved_id := _get_statue_id(statue)
	var attunement_count := int(_attunements_by_id.get(resolved_id, 0)) + 1
	_attunements_by_id[resolved_id] = attunement_count
	Events.statue_attuned.emit(statue, attunement_count)
	Events.statues_changed.emit(get_statue_summaries())
	return true


func get_statue_summaries() -> Array:
	var summaries: Array = []
	for statue in _owned_statues:
		var statue_id := _get_statue_id(statue)
		var attunement_count := int(_attunements_by_id.get(statue_id, 0))
		summaries.append({
			"id": statue_id,
			"display_name": str(statue.get("display_name")),
			"description": str(statue.get("description")),
			"rarity": str(statue.get("rarity")),
			"duration_scope": str(statue.get("duration_scope")),
			"trigger_event": str(statue.get("trigger_event")),
			"trigger_interval": _get_trigger_interval(statue),
			"effective_trigger_interval": _get_effective_trigger_interval(statue),
			"effect_type": str(statue.get("effect_type")),
			"effect_value": float(statue.get("effect_value")),
			"effective_effect_value": _get_effective_effect_value(statue),
			"effect_duration": float(statue.get("effect_duration")),
			"rule_text": str(statue.get("rule_text")),
			"build_tags": statue.get("build_tags"),
			"attunements": attunement_count,
			"stacks": int(_stacks_by_id.get(statue_id, 0)),
		})
	return summaries


func get_statue_count() -> int:
	return _owned_statues.size()


func get_stack_count(statue_id: String) -> int:
	return int(_stacks_by_id.get(statue_id, 0))


func get_attunement_count(statue_id: String) -> int:
	return int(_attunements_by_id.get(statue_id, 0))


func _resolve_player() -> void:
	_player = get_node_or_null(player_path)


func _get_obtainable_statues() -> Array[Resource]:
	var candidates: Array[Resource] = []
	for statue in available_statues:
		if statue is Resource and _can_obtain(statue):
			candidates.append(statue)
	return candidates


func _can_obtain(statue_data: Resource) -> bool:
	if statue_data == null:
		return false

	var statue_id := _get_statue_id(statue_data)
	if statue_id.is_empty() or int(_stacks_by_id.get(statue_id, 0)) > 0:
		return false

	var new_conflicts := _get_string_set(statue_data.get("conflict_tags"))
	if new_conflicts.is_empty():
		return true

	for owned in _owned_statues:
		var owned_conflicts := _get_string_set(owned.get("conflict_tags"))
		for tag in new_conflicts.keys():
			if owned_conflicts.has(tag):
				return false
	return true


func _pick_weighted_statue(candidates: Array[Resource], weight_multiplier: float = 1.0) -> Resource:
	if candidates.is_empty():
		return null

	var total_weight := 0.0
	for statue in candidates:
		total_weight += maxf(_get_statue_weight(statue, weight_multiplier), 0.0)

	if total_weight <= 0.0:
		return candidates[_rng.randi_range(0, candidates.size() - 1)]

	var roll := _rng.randf_range(0.0, total_weight)
	for statue in candidates:
		roll -= maxf(_get_statue_weight(statue, weight_multiplier), 0.0)
		if roll <= 0.0:
			return statue
	return candidates[candidates.size() - 1]


func _get_statue_weight(statue_data: Resource, weight_multiplier: float = 1.0) -> float:
	if statue_data == null:
		return 0.0
	var rarity_weight := float(RARITY_WEIGHTS.get(str(statue_data.get("rarity")), 1.0))
	return rarity_weight * maxf(float(statue_data.get("drop_weight")), 0.0) * _get_rarity_multiplier(str(statue_data.get("rarity")), weight_multiplier)


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


func _get_owned_statue_by_id(statue_id: String) -> Resource:
	if statue_id.is_empty():
		return null
	for statue in _owned_statues:
		if _get_statue_id(statue) == statue_id:
			return statue
	return null


func _pick_owned_statue_for_attunement() -> Resource:
	if _owned_statues.is_empty():
		return null

	var candidates: Array[Resource] = []
	for statue in _owned_statues:
		if statue is Resource:
			candidates.append(statue)
	if candidates.is_empty():
		return null

	candidates.sort_custom(func(a: Resource, b: Resource) -> bool:
		var a_interval := _get_effective_trigger_interval(a)
		var b_interval := _get_effective_trigger_interval(b)
		if a_interval == b_interval:
			return _get_statue_id(a) < _get_statue_id(b)
		return a_interval > b_interval
	)
	return candidates[0]


func _on_player_skill_used(_player_node: Node, _skill_id: String, _skill_name: String) -> void:
	for statue in _owned_statues:
		if str(statue.get("trigger_event")) == "on_skill_used" and _should_apply_triggered_statue(statue):
			if _apply_player_statue_effect(statue):
				Events.statue_triggered.emit(
					statue,
					str(statue.get("trigger_event")),
					str(statue.get("effect_type")),
					_get_effective_effect_value(statue)
				)


func _should_apply_triggered_statue(statue_data: Resource) -> bool:
	var statue_id := _get_statue_id(statue_data)
	if statue_id.is_empty():
		return false

	var trigger_interval := _get_effective_trigger_interval(statue_data)
	var count := int(_trigger_counts_by_id.get(statue_id, 0)) + 1
	_trigger_counts_by_id[statue_id] = count
	return count % trigger_interval == 0


func _apply_player_statue_effect(statue_data: Resource) -> bool:
	if _player == null:
		_resolve_player()
	if _player == null:
		return false

	var effect_type := str(statue_data.get("effect_type"))
	var effect_value := _get_effective_effect_value(statue_data)
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
				_get_statue_id(statue_data),
				maxf(effect_value, 0.0),
				0.0,
				maxf(float(statue_data.get("effect_duration")), 0.1)
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


func _get_statue_id(statue_data: Resource) -> String:
	var value = statue_data.get("id")
	if value == null:
		return ""
	return str(value)


func _get_trigger_interval(statue_data: Resource) -> int:
	if statue_data == null:
		return 1
	var value = statue_data.get("trigger_interval")
	if value == null:
		return 1
	return maxi(int(value), 1)


func _get_effective_trigger_interval(statue_data: Resource) -> int:
	var statue_id := _get_statue_id(statue_data)
	var attunement_count := int(_attunements_by_id.get(statue_id, 0))
	return maxi(_get_trigger_interval(statue_data) - attunement_count, 1)


func _get_effective_effect_value(statue_data: Resource) -> float:
	if statue_data == null:
		return 0.0
	var statue_id := _get_statue_id(statue_data)
	var attunement_count := int(_attunements_by_id.get(statue_id, 0))
	var base_value := float(statue_data.get("effect_value"))
	match str(statue_data.get("effect_type")):
		"recover_energy", "heal", "gain_shield":
			return base_value + float(attunement_count)
		"temporary_combat_rule":
			return base_value + float(attunement_count) * 0.04
	return base_value


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

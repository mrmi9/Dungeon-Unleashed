extends Node
class_name TalentSystem

const RARITY_WEIGHTS := {
	"common": 100.0,
	"rare": 48.0,
	"epic": 18.0,
	"legendary": 6.0,
}

@export var player_path: NodePath = ^"../Player"
@export var available_talents: Array[Resource] = [
	preload("res://resources/talents/steady_hands.tres"),
	preload("res://resources/talents/kinetic_rounds.tres"),
	preload("res://resources/talents/iron_vow.tres"),
]

var _player: Node
var _owned_talents: Array[Resource] = []
var _stacks_by_id: Dictionary = {}
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	add_to_group("talent_system")
	_rng.randomize()
	call_deferred("_resolve_player")


func reset_run() -> void:
	_owned_talents.clear()
	_stacks_by_id.clear()
	Events.talents_changed.emit(get_talent_summaries())


func set_random_seed(seed: int) -> void:
	_rng.seed = seed


func get_reward_choices(choice_count: int = 3, _source: String = "boss") -> Array:
	var choices: Array = []
	var candidates := _get_obtainable_talents()
	while choices.size() < choice_count and not candidates.is_empty():
		var talent := _pick_weighted_talent(candidates)
		if talent == null:
			break
		choices.append(talent)
		candidates.erase(talent)
	return choices


func obtain_talent(talent_data: Resource) -> bool:
	if talent_data == null or not _can_obtain(talent_data):
		return false

	var talent_id := _get_talent_id(talent_data)
	var stack_count := int(_stacks_by_id.get(talent_id, 0)) + 1
	_stacks_by_id[talent_id] = stack_count
	if not _owned_talents.has(talent_data):
		_owned_talents.append(talent_data)

	_apply_talent_effect(talent_data)
	Events.talent_collected.emit(talent_data, stack_count)
	Events.talents_changed.emit(get_talent_summaries())
	return true


func get_talent_summaries() -> Array:
	var summaries: Array = []
	for talent in _owned_talents:
		var talent_id := _get_talent_id(talent)
		summaries.append({
			"id": talent_id,
			"display_name": str(talent.get("display_name")),
			"description": str(talent.get("description")),
			"rarity": str(talent.get("rarity")),
			"duration_scope": str(talent.get("duration_scope")),
			"build_tags": talent.get("build_tags"),
			"stacks": int(_stacks_by_id.get(talent_id, 0)),
		})
	return summaries


func get_talent_count() -> int:
	return _owned_talents.size()


func get_stack_count(talent_id: String) -> int:
	return int(_stacks_by_id.get(talent_id, 0))


func _resolve_player() -> void:
	_player = get_node_or_null(player_path)


func _get_obtainable_talents() -> Array[Resource]:
	var candidates: Array[Resource] = []
	for talent in available_talents:
		if talent is Resource and _can_obtain(talent):
			candidates.append(talent)
	return candidates


func _can_obtain(talent_data: Resource) -> bool:
	if talent_data == null:
		return false

	var talent_id := _get_talent_id(talent_data)
	if talent_id.is_empty() or int(_stacks_by_id.get(talent_id, 0)) > 0:
		return false

	var new_conflicts := _get_string_set(talent_data.get("conflict_tags"))
	if new_conflicts.is_empty():
		return true

	for owned in _owned_talents:
		var owned_conflicts := _get_string_set(owned.get("conflict_tags"))
		for tag in new_conflicts.keys():
			if owned_conflicts.has(tag):
				return false
	return true


func _pick_weighted_talent(candidates: Array[Resource]) -> Resource:
	if candidates.is_empty():
		return null

	var total_weight := 0.0
	for talent in candidates:
		total_weight += maxf(_get_talent_weight(talent), 0.0)

	if total_weight <= 0.0:
		return candidates[_rng.randi_range(0, candidates.size() - 1)]

	var roll := _rng.randf_range(0.0, total_weight)
	for talent in candidates:
		roll -= maxf(_get_talent_weight(talent), 0.0)
		if roll <= 0.0:
			return talent
	return candidates[candidates.size() - 1]


func _get_talent_weight(talent_data: Resource) -> float:
	if talent_data == null:
		return 0.0
	var rarity_weight := float(RARITY_WEIGHTS.get(str(talent_data.get("rarity")), 1.0))
	return rarity_weight * maxf(float(talent_data.get("drop_weight")), 0.0)


func _apply_talent_effect(talent_data: Resource) -> void:
	if str(talent_data.get("trigger_event")) != "passive":
		return

	if _player == null:
		_resolve_player()
	if _player == null or not _player.has_method("apply_relic_effect"):
		return

	_player.call(
		"apply_relic_effect",
		str(talent_data.get("effect_type")),
		float(talent_data.get("effect_value"))
	)


func _get_talent_id(talent_data: Resource) -> String:
	var value = talent_data.get("id")
	if value == null:
		return ""
	return str(value)


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

extends Node
class_name RelicSystem

const RARITY_WEIGHTS := {
	"common": 100.0,
	"rare": 45.0,
	"epic": 18.0,
	"legendary": 6.0,
}

@export var player_path: NodePath = ^"../Player"
@export var available_relics: Array[Resource] = [
	preload("res://resources/relics/sharp_rounds.tres"),
	preload("res://resources/relics/quick_trigger.tres"),
	preload("res://resources/relics/split_chamber.tres"),
	preload("res://resources/relics/phase_tip.tres"),
	preload("res://resources/relics/vampire_fang.tres"),
	preload("res://resources/relics/guardian_ward.tres"),
	preload("res://resources/relics/adrenaline_charm.tres"),
	preload("res://resources/relics/lucky_primer.tres"),
	preload("res://resources/relics/swift_loader.tres"),
	preload("res://resources/relics/heart_core.tres"),
	preload("res://resources/relics/keen_sights.tres"),
	preload("res://resources/relics/hollow_needle.tres"),
	preload("res://resources/relics/scatter_lens.tres"),
	preload("res://resources/relics/field_rations.tres"),
	preload("res://resources/relics/bulwark_plate.tres"),
	preload("res://resources/relics/redline_boots.tres"),
	preload("res://resources/relics/breach_powder.tres"),
	preload("res://resources/relics/momentum_coil.tres"),
	preload("res://resources/relics/steady_capacitor.tres"),
	preload("res://resources/relics/gilded_tip.tres"),
	preload("res://resources/relics/echo_chamber.tres"),
	preload("res://resources/relics/breakwater_guard.tres"),
	preload("res://resources/relics/siphon_clasp.tres"),
	preload("res://resources/relics/kinetic_ram.tres"),
	preload("res://resources/relics/volatile_oil.tres"),
	preload("res://resources/relics/ember_catalyst.tres"),
	preload("res://resources/relics/lingering_ash.tres"),
	preload("res://resources/relics/parry_grip.tres"),
	preload("res://resources/relics/warding_hinge.tres"),
	preload("res://resources/relics/counterweight_core.tres"),
	preload("res://resources/relics/draw_weight.tres"),
	preload("res://resources/relics/quick_windup.tres"),
	preload("res://resources/relics/stored_spark.tres"),
	preload("res://resources/relics/tripwire_amplifier.tres"),
	preload("res://resources/relics/anchor_spool.tres"),
	preload("res://resources/relics/ricochet_gyro.tres"),
	preload("res://resources/relics/blast_radius_gauge.tres"),
	preload("res://resources/relics/kinetic_bridle.tres"),
	preload("res://resources/relics/reserve_drum.tres"),
	preload("res://resources/relics/flux_reservoir.tres"),
	preload("res://resources/relics/tracking_vane.tres"),
	preload("res://resources/relics/longview_array.tres"),
	preload("res://resources/relics/forked_bus.tres"),
	preload("res://resources/relics/conduction_mesh.tres"),
	preload("res://resources/relics/stormglass_filament.tres"),
]
@export var drop_tables: Array[Resource] = [
	preload("res://resources/relic_drop_tables/reward.tres"),
	preload("res://resources/relic_drop_tables/shop.tres"),
	preload("res://resources/relic_drop_tables/normal_chest.tres"),
	preload("res://resources/relic_drop_tables/premium_chest.tres"),
	preload("res://resources/relic_drop_tables/boss_chest.tres"),
]

var _player: Node
var _owned_relics: Array[Resource] = []
var _stacks_by_id: Dictionary = {}
var _kill_count := 0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	add_to_group("relic_system")
	_rng.randomize()
	Events.enemy_died.connect(_on_enemy_died)
	Events.room_cleared.connect(_on_room_cleared)
	Events.player_damaged.connect(_on_player_damaged)
	call_deferred("_resolve_player")


func choose_reward_relic(source: String = "reward", weight_multiplier: float = 1.0) -> Resource:
	return _pick_weighted_relic(_get_obtainable_relics(source), source, weight_multiplier)


func get_reward_choices(choice_count: int = 3, source: String = "reward", weight_multiplier: float = 1.0) -> Array:
	var choices: Array = []
	var candidates := _get_obtainable_relics(source)
	while choices.size() < choice_count and not candidates.is_empty():
		var relic := _pick_weighted_relic(candidates, source, weight_multiplier)
		if relic == null:
			break
		choices.append(relic)
		candidates.erase(relic)
	return choices


func set_random_seed(seed: int) -> void:
	_rng.seed = seed


func get_rarity_weight(rarity: String) -> float:
	return float(RARITY_WEIGHTS.get(rarity, 1.0))


func get_source_rarity_weight(source: String, rarity: String) -> float:
	var table := _get_drop_table_for_source(source)
	if table != null and table.has_method("get_rarity_weight"):
		return float(table.call("get_rarity_weight", rarity))
	return get_rarity_weight(rarity)


func get_source_pool_ids(source: String = "reward") -> Array[String]:
	var ids: Array[String] = []
	for relic in _get_relic_pool_for_source(source):
		if relic is Resource:
			ids.append(_get_relic_id(relic))
	return ids


func get_weighted_relic_score_for_test(relic_data: Resource, source: String = "reward", weight_multiplier: float = 1.0) -> float:
	return _get_relic_weight(relic_data, source, weight_multiplier)


func get_configured_drop_source_ids() -> Array[String]:
	var ids: Array[String] = []
	for table in drop_tables:
		if table == null:
			continue
		var source_id := _canonical_source(str(table.get("source_id")))
		if not source_id.is_empty() and not ids.has(source_id):
			ids.append(source_id)
	return ids


func get_drop_table_resource_path(source: String) -> String:
	var table := _get_drop_table_for_source(source)
	if table == null:
		return ""
	return table.resource_path


func _get_obtainable_relics(source: String = "reward") -> Array[Resource]:
	var candidates: Array[Resource] = []
	for relic in _get_relic_pool_for_source(source):
		if relic is Resource and _can_obtain(relic):
			candidates.append(relic)
	return candidates


func _pick_weighted_relic(candidates: Array[Resource], source: String = "reward", weight_multiplier: float = 1.0) -> Resource:
	if candidates.is_empty():
		return null

	var total_weight := 0.0
	for relic in candidates:
		total_weight += maxf(_get_relic_weight(relic, source, weight_multiplier), 0.0)

	if total_weight <= 0.0:
		return candidates[_rng.randi_range(0, candidates.size() - 1)]

	var roll := _rng.randf_range(0.0, total_weight)
	for relic in candidates:
		roll -= maxf(_get_relic_weight(relic, source, weight_multiplier), 0.0)
		if roll <= 0.0:
			return relic

	return candidates[candidates.size() - 1]


func _get_relic_weight(relic_data: Resource, source: String = "reward", weight_multiplier: float = 1.0) -> float:
	if relic_data == null:
		return 0.0
	var drop_weight := 1.0
	var drop_weight_value = relic_data.get("drop_weight")
	if drop_weight_value != null:
		drop_weight = float(drop_weight_value)
	return get_source_rarity_weight(source, str(relic_data.get("rarity"))) * maxf(drop_weight, 0.0) * _get_rarity_multiplier(str(relic_data.get("rarity")), weight_multiplier)


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


func _get_relic_pool_for_source(source: String) -> Array[Resource]:
	var table := _get_drop_table_for_source(source)
	if table != null:
		var pool: Array[Resource] = _get_resource_pool_from_table(table)
		if not pool.is_empty():
			return pool

	if _canonical_source(source) != "reward":
		return _get_relic_pool_for_source("reward")
	return available_relics


func _get_drop_table_for_source(source: String) -> Resource:
	var canonical_source := _canonical_source(source)
	for table in drop_tables:
		if table == null:
			continue
		if _canonical_source(str(table.get("source_id"))) == canonical_source:
			return table
	if canonical_source != "reward":
		return _get_drop_table_for_source("reward")
	return null


func _get_resource_pool_from_table(table: Resource) -> Array[Resource]:
	var pool: Array[Resource] = []
	var raw_pool = table.get("relic_pool")
	if not raw_pool is Array:
		return pool
	for relic in raw_pool:
		if relic is Resource:
			pool.append(relic)
	return pool


func _canonical_source(source: String) -> String:
	if source == "boss":
		return "boss_chest"
	return source


func obtain_relic(relic_data: Resource) -> bool:
	if relic_data == null or not _can_obtain(relic_data):
		return false

	var relic_id := _get_relic_id(relic_data)
	var stack_count := int(_stacks_by_id.get(relic_id, 0)) + 1
	_stacks_by_id[relic_id] = stack_count
	if not _owned_relics.has(relic_data):
		_owned_relics.append(relic_data)

	_apply_relic_effect(relic_data)
	Events.relic_collected.emit(relic_data, stack_count)
	Events.relics_changed.emit(get_relic_summaries())
	return true


func get_relic_summaries() -> Array:
	var summaries: Array = []
	for relic in _owned_relics:
		var relic_id := _get_relic_id(relic)
		summaries.append({
			"id": relic_id,
			"display_name": str(relic.get("display_name")),
			"description": str(relic.get("description")),
			"rarity": str(relic.get("rarity")),
			"build_tags": relic.get("build_tags"),
			"conflict_tags": relic.get("conflict_tags"),
			"tags": relic.get("tags"),
			"stacks": int(_stacks_by_id.get(relic_id, 0)),
		})
	return summaries


func get_relic_count() -> int:
	return _owned_relics.size()


func get_stack_count(relic_id: String) -> int:
	return int(_stacks_by_id.get(relic_id, 0))


func _resolve_player() -> void:
	_player = get_node_or_null(player_path)


func _can_obtain(relic_data: Resource) -> bool:
	if relic_data == null:
		return false

	var relic_id := _get_relic_id(relic_data)
	var current_stacks := int(_stacks_by_id.get(relic_id, 0))
	if current_stacks <= 0:
		return true

	if not bool(relic_data.get("stackable")):
		return false

	return current_stacks < maxi(int(relic_data.get("max_stacks")), 1)


func _apply_relic_effect(relic_data: Resource) -> void:
	var effect_type := str(relic_data.get("effect_type"))
	if not _is_passive_effect(effect_type):
		return

	if _player == null:
		_resolve_player()
	if _player == null or not _player.has_method("apply_relic_effect"):
		return

	_player.call(
		"apply_relic_effect",
		effect_type,
		float(relic_data.get("effect_value"))
	)


func _get_relic_id(relic_data: Resource) -> String:
	var value = relic_data.get("id")
	if value == null:
		return ""
	return str(value)


func _is_passive_effect(effect_type: String) -> bool:
	return effect_type in [
		"damage_multiplier",
		"fire_rate_multiplier",
		"projectile_count",
		"pierce",
		"bounce_count_bonus",
		"homing_turn_rate_bonus",
		"homing_radius_bonus",
		"chain_count_bonus",
		"chain_radius_bonus",
		"chain_damage_multiplier",
		"explosion_radius_bonus",
		"knockback_multiplier",
		"magazine_size_bonus",
		"crit_chance_bonus",
		"reload_speed_multiplier",
		"max_health",
		"max_energy",
		"status_chance_bonus",
		"status_damage_multiplier",
		"status_duration_multiplier",
		"projectile_block_radius_bonus",
		"projectile_block_arc_bonus",
		"projectile_block_damage_bonus",
		"charge_damage_multiplier",
		"charge_speed_multiplier",
		"charge_projectile_count_bonus",
		"deployable_damage_multiplier",
		"deployable_duration_multiplier",
	]


func _on_enemy_died(_enemy: Node) -> void:
	_kill_count += 1
	for relic in _owned_relics:
		if str(relic.get("effect_type")) != "kill_heal":
			continue
		if _kill_count % 3 != 0:
			continue
		_apply_player_method("heal", int(roundf(float(relic.get("effect_value")))))


func _on_room_cleared(_room: Node) -> void:
	for relic in _owned_relics:
		if str(relic.get("effect_type")) != "room_clear_shield":
			continue
		_apply_player_method("add_shield", int(roundf(float(relic.get("effect_value")))))


func _on_player_damaged(_amount: int, _current_hp: int) -> void:
	for relic in _owned_relics:
		if str(relic.get("effect_type")) != "hurt_speed_boost":
			continue
		_apply_player_method(
			"apply_temporary_speed_boost",
			float(relic.get("effect_value")),
			maxf(float(relic.get("effect_duration")), 0.1)
		)


func _apply_player_method(method_name: String, value, duration = null) -> void:
	if _player == null:
		_resolve_player()
	if _player == null or not _player.has_method(method_name):
		return

	if duration == null:
		_player.call(method_name, value)
	else:
		_player.call(method_name, value, duration)

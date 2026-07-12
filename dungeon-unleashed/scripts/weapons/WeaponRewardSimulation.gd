extends RefCounted
class_name WeaponRewardSimulation

const PICKER := preload("res://scripts/weapons/WeaponRewardPicker.gd")
const RUN_SEED_STREAMS := preload("res://scripts/dungeon/RunSeedStreams.gd")
const TABLES := {
	"armory": preload("res://resources/weapon_drop_tables/armory.tres"),
	"shop": preload("res://resources/weapon_drop_tables/shop.tres"),
	"boss_chest": preload("res://resources/weapon_drop_tables/boss_chest.tres"),
	"cursed_event": preload("res://resources/weapon_drop_tables/cursed_event.tres"),
}
const RARITIES := ["common", "rare", "epic", "legendary"]
const BIOME_REWARD_MULTIPLIERS := [1.0, 1.08, 1.16]
const EVENT_VARIANT_COUNT := 6


static func simulate(run_count: int = 3000, base_seed: int = 161803) -> Dictionary:
	var resolved_run_count := maxi(run_count, 1)
	var summary := {
		"run_count": resolved_run_count,
		"base_seed": base_seed,
		"sources": {},
		"strategies": {
			"guaranteed": _new_strategy_metrics(),
			"weapon_buyer": _new_strategy_metrics(),
		},
		"plan": {
			"biomes": BIOME_REWARD_MULTIPLIERS.size(),
			"armory_offers_per_run": 3,
			"boss_offers_per_run": 3,
			"shop_listings_per_run": 3,
			"cursed_event_probability": 1.0 / float(EVENT_VARIANT_COUNT),
		},
	}

	for run_index in range(resolved_run_count):
		var run_seed := base_seed + run_index * 104729
		var run_metrics := {
			"guaranteed": _new_run_metrics(),
			"weapon_buyer": _new_run_metrics(),
		}
		for biome_index in range(BIOME_REWARD_MULTIPLIERS.size()):
			var multiplier := float(BIOME_REWARD_MULTIPLIERS[biome_index])
			var armory := _pick_source_weapon("armory", run_seed, biome_index, multiplier)
			_record_source_offer(summary, "armory", armory)
			_record_run_pick(run_metrics, "guaranteed", armory)
			_record_run_pick(run_metrics, "weapon_buyer", armory)

			var boss := _pick_source_weapon("boss_chest", run_seed, biome_index, multiplier)
			_record_source_offer(summary, "boss_chest", boss)
			_record_run_pick(run_metrics, "guaranteed", boss)
			_record_run_pick(run_metrics, "weapon_buyer", boss)

			var shop := _pick_source_weapon("shop", run_seed, biome_index, multiplier)
			_record_source_offer(summary, "shop", shop)
			_record_run_pick(run_metrics, "weapon_buyer", shop)

			var event_rng := _source_rng(run_seed, "event_variant", biome_index)
			if event_rng.randi_range(0, EVENT_VARIANT_COUNT - 1) == 0:
				var cursed := PICKER.pick_weapon(TABLES["cursed_event"], event_rng, multiplier)
				_record_source_offer(summary, "cursed_event", cursed)
				_record_run_pick(run_metrics, "guaranteed", cursed)
				_record_run_pick(run_metrics, "weapon_buyer", cursed)
		_finish_run(summary, run_metrics)

	_finalize(summary)
	return summary


static func format_report(summary: Dictionary) -> String:
	var lines := PackedStringArray()
	lines.append("武器奖励模拟：%d 局，基础种子 %d" % [int(summary.get("run_count", 0)), int(summary.get("base_seed", 0))])
	var sources: Dictionary = summary.get("sources", {})
	for source in ["armory", "boss_chest", "shop", "cursed_event"]:
		var metrics: Dictionary = sources.get(source, {})
		lines.append("%s：%d 次，Rare+ %.1f%%，Epic+ %.1f%%，传说 %.2f%%" % [
			_source_label(source),
			int(metrics.get("offers", 0)),
			float(metrics.get("rare_plus_rate", 0.0)) * 100.0,
			float(metrics.get("epic_plus_rate", 0.0)) * 100.0,
			float(metrics.get("legendary_rate", 0.0)) * 100.0,
		])
	var strategies: Dictionary = summary.get("strategies", {})
	for strategy in ["guaranteed", "weapon_buyer"]:
		var metrics: Dictionary = strategies.get(strategy, {})
		lines.append("%s：每局 %.2f 把，Epic+ %.2f，把传说带入局内 %.1f%%，平均 %.2f 类武器 / %.2f 种模式" % [
			_strategy_label(strategy),
			float(metrics.get("picks_per_run", 0.0)),
			float(metrics.get("epic_plus_per_run", 0.0)),
			float(metrics.get("legendary_run_rate", 0.0)) * 100.0,
			float(metrics.get("average_distinct_classes", 0.0)),
			float(metrics.get("average_distinct_modes", 0.0)),
		])
		lines.append("  形态局占比：近战 %.1f%%，环形 %.1f%%，蓄力 %.1f%%，部署 %.1f%%" % [
			float(metrics.get("melee_run_rate", 0.0)) * 100.0,
			float(metrics.get("radial_run_rate", 0.0)) * 100.0,
			float(metrics.get("charge_run_rate", 0.0)) * 100.0,
			float(metrics.get("deployable_run_rate", 0.0)) * 100.0,
		])
	return "\n".join(lines)


static func get_distribution_signature(summary: Dictionary) -> String:
	var parts := PackedStringArray()
	var sources: Dictionary = summary.get("sources", {})
	for source in ["armory", "boss_chest", "shop", "cursed_event"]:
		var metrics: Dictionary = sources.get(source, {})
		parts.append("%s:%d:%s:%s:%s" % [
			source,
			int(metrics.get("offers", 0)),
			_count_signature(metrics.get("rarity_counts", {})),
			_count_signature(metrics.get("class_counts", {})),
			_count_signature(metrics.get("mode_counts", {})),
		])
	var strategies: Dictionary = summary.get("strategies", {})
	for strategy in ["guaranteed", "weapon_buyer"]:
		var metrics: Dictionary = strategies.get(strategy, {})
		parts.append("%s:%d:%d:%d" % [
			strategy,
			int(metrics.get("picks", 0)),
			int(metrics.get("runs_with_epic_plus", 0)),
			int(metrics.get("runs_with_legendary", 0)),
		])
	return "|".join(parts)


static func get_tables() -> Dictionary:
	return TABLES.duplicate()


static func _pick_source_weapon(source: String, run_seed: int, biome_index: int, multiplier: float) -> Resource:
	return PICKER.pick_weapon(TABLES[source], _source_rng(run_seed, source, biome_index), multiplier)


static func _source_rng(run_seed: int, source: String, biome_index: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = RUN_SEED_STREAMS.derive_seed(run_seed, "weapon_reward:%s:%d" % [source, biome_index + 1])
	return rng


static func _record_source_offer(summary: Dictionary, source: String, weapon: Resource) -> void:
	var sources: Dictionary = summary.get("sources", {})
	var metrics: Dictionary = sources.get(source, _new_source_metrics())
	metrics["offers"] = int(metrics.get("offers", 0)) + 1
	if weapon == null:
		metrics["invalid_offers"] = int(metrics.get("invalid_offers", 0)) + 1
		sources[source] = metrics
		summary["sources"] = sources
		return
	var rarity := str(weapon.get("rarity")).to_lower()
	var weapon_class := str(weapon.get("weapon_class")).to_lower()
	var fire_mode := str(weapon.get("fire_mode")).to_lower()
	_increment(metrics.get("rarity_counts", {}) as Dictionary, rarity)
	_increment(metrics.get("class_counts", {}) as Dictionary, weapon_class)
	_increment(metrics.get("mode_counts", {}) as Dictionary, fire_mode)
	var minimum_rarity := str((TABLES[source] as Resource).get("minimum_rarity"))
	if _rarity_rank(rarity) < _rarity_rank(minimum_rarity):
		metrics["minimum_rarity_failures"] = int(metrics.get("minimum_rarity_failures", 0)) + 1
	sources[source] = metrics
	summary["sources"] = sources


static func _record_run_pick(run_metrics: Dictionary, strategy: String, weapon: Resource) -> void:
	if weapon == null:
		return
	var metrics: Dictionary = run_metrics.get(strategy, _new_run_metrics())
	metrics["picks"] = int(metrics.get("picks", 0)) + 1
	var rarity := str(weapon.get("rarity")).to_lower()
	var rank := _rarity_rank(rarity)
	if rank >= _rarity_rank("rare"):
		metrics["rare_plus"] = int(metrics.get("rare_plus", 0)) + 1
	if rank >= _rarity_rank("epic"):
		metrics["epic_plus"] = int(metrics.get("epic_plus", 0)) + 1
	if rank >= _rarity_rank("legendary"):
		metrics["legendary"] = int(metrics.get("legendary", 0)) + 1
	(metrics.get("classes", {}) as Dictionary)[str(weapon.get("weapon_class"))] = true
	(metrics.get("modes", {}) as Dictionary)[str(weapon.get("fire_mode"))] = true
	run_metrics[strategy] = metrics


static func _finish_run(summary: Dictionary, run_metrics: Dictionary) -> void:
	var strategies: Dictionary = summary.get("strategies", {})
	for strategy in ["guaranteed", "weapon_buyer"]:
		var totals: Dictionary = strategies.get(strategy, _new_strategy_metrics())
		var current: Dictionary = run_metrics.get(strategy, _new_run_metrics())
		totals["picks"] = int(totals.get("picks", 0)) + int(current.get("picks", 0))
		totals["rare_plus_total"] = int(totals.get("rare_plus_total", 0)) + int(current.get("rare_plus", 0))
		totals["epic_plus_total"] = int(totals.get("epic_plus_total", 0)) + int(current.get("epic_plus", 0))
		totals["legendary_total"] = int(totals.get("legendary_total", 0)) + int(current.get("legendary", 0))
		if int(current.get("epic_plus", 0)) > 0:
			totals["runs_with_epic_plus"] = int(totals.get("runs_with_epic_plus", 0)) + 1
		if int(current.get("legendary", 0)) > 0:
			totals["runs_with_legendary"] = int(totals.get("runs_with_legendary", 0)) + 1
		var classes: Dictionary = current.get("classes", {})
		var modes: Dictionary = current.get("modes", {})
		totals["distinct_class_total"] = int(totals.get("distinct_class_total", 0)) + classes.size()
		totals["distinct_mode_total"] = int(totals.get("distinct_mode_total", 0)) + modes.size()
		for mode in ["melee", "radial", "charge", "deployable"]:
			if modes.has(mode):
				totals["runs_with_%s" % mode] = int(totals.get("runs_with_%s" % mode, 0)) + 1
		strategies[strategy] = totals
	summary["strategies"] = strategies


static func _finalize(summary: Dictionary) -> void:
	var sources: Dictionary = summary.get("sources", {})
	for source in sources:
		var metrics: Dictionary = sources[source]
		var offers := maxi(int(metrics.get("offers", 0)), 1)
		var rarity_counts: Dictionary = metrics.get("rarity_counts", {})
		metrics["rare_plus_rate"] = float(int(rarity_counts.get("rare", 0)) + int(rarity_counts.get("epic", 0)) + int(rarity_counts.get("legendary", 0))) / float(offers)
		metrics["epic_plus_rate"] = float(int(rarity_counts.get("epic", 0)) + int(rarity_counts.get("legendary", 0))) / float(offers)
		metrics["legendary_rate"] = float(rarity_counts.get("legendary", 0)) / float(offers)
		sources[source] = metrics
	summary["sources"] = sources

	var run_count := maxi(int(summary.get("run_count", 0)), 1)
	var strategies: Dictionary = summary.get("strategies", {})
	for strategy in strategies:
		var metrics: Dictionary = strategies[strategy]
		metrics["picks_per_run"] = float(metrics.get("picks", 0)) / float(run_count)
		metrics["rare_plus_per_run"] = float(metrics.get("rare_plus_total", 0)) / float(run_count)
		metrics["epic_plus_per_run"] = float(metrics.get("epic_plus_total", 0)) / float(run_count)
		metrics["legendary_per_run"] = float(metrics.get("legendary_total", 0)) / float(run_count)
		metrics["epic_plus_run_rate"] = float(metrics.get("runs_with_epic_plus", 0)) / float(run_count)
		metrics["legendary_run_rate"] = float(metrics.get("runs_with_legendary", 0)) / float(run_count)
		metrics["average_distinct_classes"] = float(metrics.get("distinct_class_total", 0)) / float(run_count)
		metrics["average_distinct_modes"] = float(metrics.get("distinct_mode_total", 0)) / float(run_count)
		for mode in ["melee", "radial", "charge", "deployable"]:
			metrics["%s_run_rate" % mode] = float(metrics.get("runs_with_%s" % mode, 0)) / float(run_count)
		strategies[strategy] = metrics
	summary["strategies"] = strategies


static func _new_source_metrics() -> Dictionary:
	return {
		"offers": 0,
		"invalid_offers": 0,
		"minimum_rarity_failures": 0,
		"rarity_counts": _new_rarity_counts(),
		"class_counts": {},
		"mode_counts": {},
	}


static func _new_run_metrics() -> Dictionary:
	return {"picks": 0, "rare_plus": 0, "epic_plus": 0, "legendary": 0, "classes": {}, "modes": {}}


static func _new_strategy_metrics() -> Dictionary:
	return {
		"picks": 0,
		"rare_plus_total": 0,
		"epic_plus_total": 0,
		"legendary_total": 0,
		"runs_with_epic_plus": 0,
		"runs_with_legendary": 0,
		"distinct_class_total": 0,
		"distinct_mode_total": 0,
		"runs_with_melee": 0,
		"runs_with_radial": 0,
		"runs_with_charge": 0,
		"runs_with_deployable": 0,
	}


static func _new_rarity_counts() -> Dictionary:
	return {"common": 0, "rare": 0, "epic": 0, "legendary": 0}


static func _increment(counts: Dictionary, key: String) -> void:
	counts[key] = int(counts.get(key, 0)) + 1


static func _rarity_rank(rarity: String) -> int:
	match rarity.strip_edges().to_lower():
		"common":
			return 0
		"rare":
			return 1
		"epic":
			return 2
		"legendary":
			return 3
	return -1


static func _count_signature(counts_variant) -> String:
	if not counts_variant is Dictionary:
		return ""
	var counts: Dictionary = counts_variant
	var keys := counts.keys()
	keys.sort()
	var parts := PackedStringArray()
	for key in keys:
		parts.append("%s=%d" % [str(key), int(counts[key])])
	return ",".join(parts)


static func _source_label(source: String) -> String:
	match source:
		"armory":
			return "军械库"
		"boss_chest":
			return "首领箱"
		"shop":
			return "商店展示"
		"cursed_event":
			return "诅咒事件"
	return source


static func _strategy_label(strategy: String) -> String:
	return "武器优先购买" if strategy == "weapon_buyer" else "保证奖励"

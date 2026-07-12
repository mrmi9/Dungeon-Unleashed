extends RefCounted
class_name RelicRewardSimulation

const RELIC_SYSTEM_SCRIPT := preload("res://scripts/relics/RelicSystem.gd")
const RARITIES := ["common", "rare", "epic", "legendary"]
const BIOME_REWARD_MULTIPLIERS := [1.0, 1.08, 1.16]
const OFFERS_PER_BIOME := [
	{"source": "reward", "choice_count": 3, "acquired": true},
	{"source": "shop", "choice_count": 1, "acquired": false},
	{"source": "premium_chest", "choice_count": 1, "acquired": true},
	{"source": "boss_chest", "choice_count": 1, "acquired": true},
]
const PITY_STRESS_OFFERS_PER_RUN := 12


static func simulate(run_count: int = 2000, base_seed: int = 271828) -> Dictionary:
	var resolved_run_count := maxi(run_count, 1)
	var pick_rng := RandomNumberGenerator.new()
	var summary := {
		"run_count": resolved_run_count,
		"base_seed": base_seed,
		"sources": {},
		"pick_strategies": {
			"random": _new_pick_metrics(),
			"highest_rarity": _new_pick_metrics(),
		},
		"plan": {
			"biomes": BIOME_REWARD_MULTIPLIERS.size(),
			"reward_offers_per_run": 3,
			"premium_offers_per_run": 4,
			"boss_offers_per_run": 3,
			"shop_offers_per_run": 3,
		},
	}

	for run_index in range(resolved_run_count):
		var run_seed := base_seed + run_index * 104729
		for strategy in ["random", "highest_rarity"]:
			var system := RELIC_SYSTEM_SCRIPT.new()
			system.call("set_random_seed", run_seed)
			pick_rng.seed = run_seed ^ 0x5F3759DF
			var run_pick_counts := {
				strategy: {"rare_plus": 0, "epic_plus": 0, "legendary": 0},
			}

			for biome_index in range(BIOME_REWARD_MULTIPLIERS.size()):
				var multiplier := float(BIOME_REWARD_MULTIPLIERS[biome_index])
				for offer in OFFERS_PER_BIOME:
					_simulate_offer(system, str(offer.source), int(offer.choice_count), multiplier, bool(offer.acquired), summary, run_pick_counts, pick_rng, strategy, strategy == "random")
				if biome_index == 1:
					_simulate_offer(system, "premium_chest", 1, multiplier, true, summary, run_pick_counts, pick_rng, strategy, strategy == "random")

			_finish_pick_run(summary, run_pick_counts, strategy)
			system.free()

	summary["pity_stress"] = _simulate_shared_pity(maxi(resolved_run_count / 2, 500), base_seed + 7919)
	_finalize_summary(summary)
	return summary


static func format_report(summary: Dictionary) -> String:
	var lines := PackedStringArray()
	lines.append("遗物奖励模拟：%d 局，基础种子 %d" % [int(summary.get("run_count", 0)), int(summary.get("base_seed", 0))])
	var sources: Dictionary = summary.get("sources", {})
	for source in ["reward", "premium_chest", "boss_chest", "shop"]:
		var metrics: Dictionary = sources.get(source, {})
		lines.append("%s：Rare+ 出现 %.1f%%，Epic+ 出现 %.1f%%，传奇槽位 %.2f%%" % [
			_source_label(source),
			float(metrics.get("rare_plus_offer_rate", 0.0)) * 100.0,
			float(metrics.get("epic_plus_offer_rate", 0.0)) * 100.0,
			float(metrics.get("legendary_slot_rate", 0.0)) * 100.0,
		])
	var random_pick: Dictionary = (summary.get("pick_strategies", {}) as Dictionary).get("random", {})
	var highest_pick: Dictionary = (summary.get("pick_strategies", {}) as Dictionary).get("highest_rarity", {})
	lines.append("随机选择：每局 Rare+ %.2f，Epic+ %.2f，传奇局占比 %.1f%%" % [
		float(random_pick.get("rare_plus_per_run", 0.0)),
		float(random_pick.get("epic_plus_per_run", 0.0)),
		float(random_pick.get("legendary_run_rate", 0.0)) * 100.0,
	])
	lines.append("高稀有度选择：每局 Rare+ %.2f，Epic+ %.2f，传奇局占比 %.1f%%" % [
		float(highest_pick.get("rare_plus_per_run", 0.0)),
		float(highest_pick.get("epic_plus_per_run", 0.0)),
		float(highest_pick.get("legendary_run_rate", 0.0)) * 100.0,
	])
	var pity: Dictionary = summary.get("pity_stress", {})
	lines.append("共享保底压力：最长连续未出 Rare+ %d 次，触发保底 %d 次，失败 %d 次" % [
		int(pity.get("max_consecutive_misses", 0)),
		int(pity.get("guarantee_due_offers", 0)),
		int(pity.get("guarantee_failures", 0)),
	])
	return "\n".join(lines)


static func get_distribution_signature(summary: Dictionary) -> String:
	var parts := PackedStringArray()
	var sources: Dictionary = summary.get("sources", {})
	for source in ["reward", "normal_chest", "premium_chest", "boss_chest", "shop"]:
		var metrics: Dictionary = sources.get(source, {})
		parts.append("%s:%s:%d" % [source, _rarity_signature(metrics.get("rarity_counts", {})), int(metrics.get("rare_plus_offers", 0))])
	var strategies: Dictionary = summary.get("pick_strategies", {})
	for strategy in ["random", "highest_rarity"]:
		var metrics: Dictionary = strategies.get(strategy, {})
		parts.append("%s:%s" % [strategy, _rarity_signature(metrics.get("rarity_counts", {}))])
	var pity: Dictionary = summary.get("pity_stress", {})
	parts.append("pity:%d:%d:%d" % [int(pity.get("rare_plus_offers", 0)), int(pity.get("guarantee_due_offers", 0)), int(pity.get("max_consecutive_misses", 0))])
	return "|".join(parts)


static func _simulate_offer(system: Node, source: String, choice_count: int, multiplier: float, acquired: bool, summary: Dictionary, run_pick_counts: Dictionary, pick_rng: RandomNumberGenerator, strategy: String, record_source_metrics: bool) -> void:
	var pacing_before: Dictionary = system.call("get_source_reward_pacing_summary", source)
	var pity_due_before := bool(pacing_before.get("pity_due", false))
	var choices: Array = system.call("get_reward_choices", choice_count, source, multiplier)
	if record_source_metrics:
		var source_metrics := _get_source_metrics(summary, source)
		_record_offer_metrics(source_metrics, choices, pity_due_before, str(pacing_before.get("minimum_rarity", "")))
		(summary.get("sources", {}) as Dictionary)[source] = source_metrics
	if not acquired or choices.is_empty():
		return

	var selected_choice := choices[pick_rng.randi_range(0, choices.size() - 1)] as Resource if strategy == "random" else _highest_rarity_choice(choices)
	if not bool(system.call("obtain_relic", selected_choice)):
		var strategies: Dictionary = summary.get("pick_strategies", {})
		var metrics: Dictionary = strategies.get(strategy, _new_pick_metrics())
		metrics["acquisition_failures"] = int(metrics.get("acquisition_failures", 0)) + 1
		strategies[strategy] = metrics
		summary["pick_strategies"] = strategies
		return
	_record_strategy_pick(summary, strategy, selected_choice, run_pick_counts)


static func _get_source_metrics(summary: Dictionary, source: String) -> Dictionary:
	var sources: Dictionary = summary.get("sources", {})
	if sources.has(source):
		return sources[source] as Dictionary
	var metrics := {
		"offers": 0,
		"choice_slots": 0,
		"rarity_counts": _new_rarity_counts(),
		"rare_plus_offers": 0,
		"epic_plus_offers": 0,
		"legendary_offers": 0,
		"pity_due_offers": 0,
		"pity_guarantee_failures": 0,
		"hard_floor_failures": 0,
		"duplicate_choice_offers": 0,
	}
	sources[source] = metrics
	summary["sources"] = sources
	return metrics


static func _record_offer_metrics(metrics: Dictionary, choices: Array, pity_due_before: bool, hard_minimum_rarity: String) -> void:
	metrics["offers"] = int(metrics.get("offers", 0)) + 1
	metrics["choice_slots"] = int(metrics.get("choice_slots", 0)) + choices.size()
	var rarity_counts: Dictionary = metrics.get("rarity_counts", {})
	var ids: Dictionary = {}
	var highest_rank := -1
	for choice in choices:
		if not choice is Resource:
			continue
		var relic := choice as Resource
		var rarity := str(relic.get("rarity")).to_lower()
		rarity_counts[rarity] = int(rarity_counts.get(rarity, 0)) + 1
		highest_rank = maxi(highest_rank, _rarity_rank(rarity))
		ids[str(relic.get("id"))] = true
	metrics["rarity_counts"] = rarity_counts
	if highest_rank >= _rarity_rank("rare"):
		metrics["rare_plus_offers"] = int(metrics.get("rare_plus_offers", 0)) + 1
	if highest_rank >= _rarity_rank("epic"):
		metrics["epic_plus_offers"] = int(metrics.get("epic_plus_offers", 0)) + 1
	if highest_rank >= _rarity_rank("legendary"):
		metrics["legendary_offers"] = int(metrics.get("legendary_offers", 0)) + 1
	if pity_due_before:
		metrics["pity_due_offers"] = int(metrics.get("pity_due_offers", 0)) + 1
		if highest_rank < _rarity_rank("rare"):
			metrics["pity_guarantee_failures"] = int(metrics.get("pity_guarantee_failures", 0)) + 1
	if not hard_minimum_rarity.is_empty() and highest_rank < _rarity_rank(hard_minimum_rarity):
		metrics["hard_floor_failures"] = int(metrics.get("hard_floor_failures", 0)) + 1
	if ids.size() != choices.size():
		metrics["duplicate_choice_offers"] = int(metrics.get("duplicate_choice_offers", 0)) + 1


static func _record_strategy_pick(summary: Dictionary, strategy: String, relic: Resource, run_pick_counts: Dictionary) -> void:
	if relic == null:
		return
	var strategies: Dictionary = summary.get("pick_strategies", {})
	var metrics: Dictionary = strategies.get(strategy, _new_pick_metrics())
	var rarity := str(relic.get("rarity")).to_lower()
	var rarity_counts: Dictionary = metrics.get("rarity_counts", {})
	rarity_counts[rarity] = int(rarity_counts.get(rarity, 0)) + 1
	metrics["rarity_counts"] = rarity_counts
	metrics["picks"] = int(metrics.get("picks", 0)) + 1
	strategies[strategy] = metrics
	summary["pick_strategies"] = strategies

	var run_counts: Dictionary = run_pick_counts.get(strategy, {})
	var rank := _rarity_rank(rarity)
	if rank >= _rarity_rank("rare"):
		run_counts["rare_plus"] = int(run_counts.get("rare_plus", 0)) + 1
	if rank >= _rarity_rank("epic"):
		run_counts["epic_plus"] = int(run_counts.get("epic_plus", 0)) + 1
	if rank >= _rarity_rank("legendary"):
		run_counts["legendary"] = int(run_counts.get("legendary", 0)) + 1
	run_pick_counts[strategy] = run_counts


static func _finish_pick_run(summary: Dictionary, run_pick_counts: Dictionary, strategy: String) -> void:
	var strategies: Dictionary = summary.get("pick_strategies", {})
	var metrics: Dictionary = strategies.get(strategy, _new_pick_metrics())
	var run_counts: Dictionary = run_pick_counts.get(strategy, {})
	metrics["rare_plus_total"] = int(metrics.get("rare_plus_total", 0)) + int(run_counts.get("rare_plus", 0))
	metrics["epic_plus_total"] = int(metrics.get("epic_plus_total", 0)) + int(run_counts.get("epic_plus", 0))
	if int(run_counts.get("epic_plus", 0)) > 0:
		metrics["runs_with_epic_plus"] = int(metrics.get("runs_with_epic_plus", 0)) + 1
	if int(run_counts.get("legendary", 0)) > 0:
		metrics["runs_with_legendary"] = int(metrics.get("runs_with_legendary", 0)) + 1
	strategies[strategy] = metrics
	summary["pick_strategies"] = strategies


static func _simulate_shared_pity(run_count: int, base_seed: int) -> Dictionary:
	var system := RELIC_SYSTEM_SCRIPT.new()
	var max_consecutive_misses := 0
	var rare_plus_offers := 0
	var total_offers := 0
	var guarantee_due_offers := 0
	var guarantee_failures := 0
	for run_index in range(run_count):
		system.call("reset_run")
		system.call("set_random_seed", base_seed + run_index * 65537)
		var consecutive_misses := 0
		for offer_index in range(PITY_STRESS_OFFERS_PER_RUN):
			var source := "reward" if offer_index % 2 == 0 else "normal_chest"
			var pacing: Dictionary = system.call("get_source_reward_pacing_summary", source)
			var pity_due := bool(pacing.get("pity_due", false))
			var choices: Array = system.call("get_reward_choices", 1, source, 1.0)
			var hit := _choices_contain_rarity(choices, "rare")
			total_offers += 1
			if pity_due:
				guarantee_due_offers += 1
				if not hit:
					guarantee_failures += 1
			if hit:
				rare_plus_offers += 1
				consecutive_misses = 0
			else:
				consecutive_misses += 1
				max_consecutive_misses = maxi(max_consecutive_misses, consecutive_misses)
	system.free()
	return {
		"run_count": run_count,
		"offers_per_run": PITY_STRESS_OFFERS_PER_RUN,
		"total_offers": total_offers,
		"rare_plus_offers": rare_plus_offers,
		"rare_plus_offer_rate": float(rare_plus_offers) / float(maxi(total_offers, 1)),
		"max_consecutive_misses": max_consecutive_misses,
		"guarantee_due_offers": guarantee_due_offers,
		"guarantee_failures": guarantee_failures,
	}


static func _finalize_summary(summary: Dictionary) -> void:
	var sources: Dictionary = summary.get("sources", {})
	for source in sources:
		var metrics: Dictionary = sources[source]
		var offers := maxi(int(metrics.get("offers", 0)), 1)
		var slots := maxi(int(metrics.get("choice_slots", 0)), 1)
		var rarity_counts: Dictionary = metrics.get("rarity_counts", {})
		metrics["rare_plus_offer_rate"] = float(metrics.get("rare_plus_offers", 0)) / float(offers)
		metrics["epic_plus_offer_rate"] = float(metrics.get("epic_plus_offers", 0)) / float(offers)
		metrics["legendary_offer_rate"] = float(metrics.get("legendary_offers", 0)) / float(offers)
		metrics["legendary_slot_rate"] = float(rarity_counts.get("legendary", 0)) / float(slots)
		sources[source] = metrics
	summary["sources"] = sources

	var run_count := maxi(int(summary.get("run_count", 0)), 1)
	var strategies: Dictionary = summary.get("pick_strategies", {})
	for strategy in strategies:
		var metrics: Dictionary = strategies[strategy]
		metrics["rare_plus_per_run"] = float(metrics.get("rare_plus_total", 0)) / float(run_count)
		metrics["epic_plus_per_run"] = float(metrics.get("epic_plus_total", 0)) / float(run_count)
		metrics["epic_plus_run_rate"] = float(metrics.get("runs_with_epic_plus", 0)) / float(run_count)
		metrics["legendary_run_rate"] = float(metrics.get("runs_with_legendary", 0)) / float(run_count)
		strategies[strategy] = metrics
	summary["pick_strategies"] = strategies


static func _new_pick_metrics() -> Dictionary:
	return {
		"picks": 0,
		"rarity_counts": _new_rarity_counts(),
		"rare_plus_total": 0,
		"epic_plus_total": 0,
		"runs_with_epic_plus": 0,
		"runs_with_legendary": 0,
		"acquisition_failures": 0,
	}


static func _new_rarity_counts() -> Dictionary:
	return {"common": 0, "rare": 0, "epic": 0, "legendary": 0}


static func _highest_rarity_choice(choices: Array) -> Resource:
	var best: Resource
	var best_rank := -1
	for choice in choices:
		if choice is Resource:
			var rank := _rarity_rank(str(choice.get("rarity")))
			if rank > best_rank:
				best = choice
				best_rank = rank
	return best


static func _choices_contain_rarity(choices: Array, minimum_rarity: String) -> bool:
	var minimum_rank := _rarity_rank(minimum_rarity)
	for choice in choices:
		if choice is Resource and _rarity_rank(str(choice.get("rarity"))) >= minimum_rank:
			return true
	return false


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


static func _rarity_signature(counts_value: Variant) -> String:
	var counts: Dictionary = counts_value if counts_value is Dictionary else {}
	var parts := PackedStringArray()
	for rarity in RARITIES:
		parts.append("%s=%d" % [rarity, int(counts.get(rarity, 0))])
	return ",".join(parts)


static func _source_label(source: String) -> String:
	match source:
		"reward":
			return "奖励房"
		"normal_chest":
			return "普通宝箱"
		"premium_chest":
			return "优质宝箱"
		"boss_chest":
			return "首领宝箱"
		"shop":
			return "商店"
	return source

extends Node

const SIMULATION := preload("res://scripts/relics/RelicRewardSimulation.gd")
const RELIC_SYSTEM_SCRIPT := preload("res://scripts/relics/RelicSystem.gd")
const DROP_TABLES := [
	preload("res://resources/relic_drop_tables/reward.tres"),
	preload("res://resources/relic_drop_tables/normal_chest.tres"),
	preload("res://resources/relic_drop_tables/premium_chest.tres"),
	preload("res://resources/relic_drop_tables/boss_chest.tres"),
	preload("res://resources/relic_drop_tables/shop.tres"),
]
const LEGENDARY_IDS := ["refraction_crown", "perpetual_dynamo", "blackstar_relay"]
const RUN_COUNT := 1500
const DETERMINISM_RUN_COUNT := 300
const BASE_SEED := 314159

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var summary: Dictionary = SIMULATION.simulate(RUN_COUNT, BASE_SEED)
	print(SIMULATION.format_report(summary))
	_verify_configuration()
	_verify_structure(summary)
	_verify_hard_guarantees(summary)
	_verify_distribution_bounds(summary)
	_finish()


func _verify_configuration() -> void:
	var system := RELIC_SYSTEM_SCRIPT.new()
	var available_relics: Array = system.get("available_relics")
	_expect(available_relics.size() >= 48, "RelicSystem should expose the complete 48-relic library")
	var available_legendary_ids := {}
	for relic in available_relics:
		if relic is Resource and str(relic.get("rarity")) == "legendary":
			available_legendary_ids[str(relic.get("id"))] = true
	for legendary_id in LEGENDARY_IDS:
		_expect(available_legendary_ids.has(legendary_id), "RelicSystem should expose legendary relic %s" % legendary_id)
	for table in DROP_TABLES:
		var source_id := str(table.get("source_id"))
		var table_legendary_ids := {}
		for relic in table.get("relic_pool") as Array:
			if relic is Resource and str(relic.get("rarity")) == "legendary":
				table_legendary_ids[str(relic.get("id"))] = true
		_expect(float(table.get("legendary_weight")) > 0.0, "%s should define a positive legendary rarity weight" % source_id)
		for legendary_id in LEGENDARY_IDS:
			_expect(table_legendary_ids.has(legendary_id), "%s should include legendary relic %s" % [source_id, legendary_id])
	system.free()


func _verify_structure(summary: Dictionary) -> void:
	_expect(int(summary.get("run_count", 0)) == RUN_COUNT, "Simulation should preserve the requested run count")
	var sources: Dictionary = summary.get("sources", {})
	_expect(int((sources.get("reward", {}) as Dictionary).get("offers", 0)) == RUN_COUNT * 3, "Simulation should include three reward-room offers per run")
	_expect(int((sources.get("premium_chest", {}) as Dictionary).get("offers", 0)) == RUN_COUNT * 4, "Simulation should include three elite and one challenge premium offer per run")
	_expect(int((sources.get("boss_chest", {}) as Dictionary).get("offers", 0)) == RUN_COUNT * 3, "Simulation should include three boss-chest offers per run")
	_expect(int((sources.get("shop", {}) as Dictionary).get("offers", 0)) == RUN_COUNT * 3, "Simulation should include three shop relic listings per run")
	var deterministic_a: Dictionary = SIMULATION.simulate(DETERMINISM_RUN_COUNT, BASE_SEED)
	var deterministic_b: Dictionary = SIMULATION.simulate(DETERMINISM_RUN_COUNT, BASE_SEED)
	_expect(SIMULATION.get_distribution_signature(deterministic_a) == SIMULATION.get_distribution_signature(deterministic_b), "The same simulation seed should reproduce the full rarity distribution")
	var changed: Dictionary = SIMULATION.simulate(DETERMINISM_RUN_COUNT, BASE_SEED + 1)
	_expect(SIMULATION.get_distribution_signature(deterministic_a) != SIMULATION.get_distribution_signature(changed), "A different simulation seed should change the rarity distribution")


func _verify_hard_guarantees(summary: Dictionary) -> void:
	var sources: Dictionary = summary.get("sources", {})
	for source in sources:
		var metrics: Dictionary = sources[source]
		_expect(int(metrics.get("duplicate_choice_offers", 0)) == 0, "%s offers should not contain duplicate relic ids" % source)
		_expect(int(metrics.get("pity_guarantee_failures", 0)) == 0, "%s should never miss a due pity guarantee" % source)
		_expect(int(metrics.get("hard_floor_failures", 0)) == 0, "%s should never violate its hard rarity floor" % source)
		_expect(int((metrics.get("rarity_counts", {}) as Dictionary).get("legendary", 0)) > 0, "%s should expose at least one legendary slot across the simulation" % source)
	for source in ["premium_chest", "boss_chest"]:
		var metrics: Dictionary = sources.get(source, {})
		_expect(is_equal_approx(float(metrics.get("rare_plus_offer_rate", 0.0)), 1.0), "%s should produce Rare+ in every offer" % source)
	var pity: Dictionary = summary.get("pity_stress", {})
	_expect(int(pity.get("max_consecutive_misses", 99)) <= 3, "Shared reward pity should cap the Rare+ drought at three offers")
	_expect(int(pity.get("guarantee_due_offers", 0)) > 0, "Pity stress simulation should exercise guaranteed offers")
	_expect(int(pity.get("guarantee_failures", 0)) == 0, "Shared reward pity should never fail when due")
	var strategies: Dictionary = summary.get("pick_strategies", {})
	for strategy in strategies:
		_expect(int((strategies[strategy] as Dictionary).get("acquisition_failures", 0)) == 0, "%s strategy should acquire every selected relic" % strategy)


func _verify_distribution_bounds(summary: Dictionary) -> void:
	var sources: Dictionary = summary.get("sources", {})
	_expect_between(_metric(sources, "reward", "rare_plus_offer_rate"), 0.60, 0.72, "Reward-room Rare+ offer rate")
	_expect_between(_metric(sources, "reward", "epic_plus_offer_rate"), 0.055, 0.105, "Reward-room Epic+ offer rate")
	_expect_between(_metric(sources, "reward", "legendary_slot_rate"), 0.0005, 0.0045, "Reward-room legendary slot rate")
	_expect_between(_metric(sources, "premium_chest", "epic_plus_offer_rate"), 0.08, 0.14, "Premium-chest Epic+ offer rate")
	_expect_between(_metric(sources, "premium_chest", "legendary_slot_rate"), 0.003, 0.012, "Premium-chest legendary slot rate")
	_expect_between(_metric(sources, "boss_chest", "epic_plus_offer_rate"), 0.12, 0.19, "Boss-chest Epic+ offer rate")
	_expect_between(_metric(sources, "boss_chest", "legendary_slot_rate"), 0.005, 0.017, "Boss-chest legendary slot rate")
	_expect_between(_metric(sources, "shop", "rare_plus_offer_rate"), 0.36, 0.48, "Shop Rare+ offer rate")
	_expect_between(_metric(sources, "shop", "epic_plus_offer_rate"), 0.025, 0.075, "Shop Epic+ offer rate")
	_expect_between(_metric(sources, "shop", "legendary_slot_rate"), 0.0008, 0.007, "Shop legendary slot rate")

	var strategies: Dictionary = summary.get("pick_strategies", {})
	var random_pick: Dictionary = strategies.get("random", {})
	var highest_pick: Dictionary = strategies.get("highest_rarity", {})
	_expect_between(float(random_pick.get("rare_plus_per_run", 0.0)), 7.5, 8.25, "Random strategy Rare+ picks per run")
	_expect_between(float(random_pick.get("epic_plus_per_run", 0.0)), 0.75, 1.20, "Random strategy Epic+ picks per run")
	_expect_between(float(random_pick.get("legendary_run_rate", 0.0)), 0.03, 0.09, "Random strategy legendary run rate")
	_expect_between(float(highest_pick.get("rare_plus_per_run", 0.0)), 8.6, 9.35, "Highest-rarity strategy Rare+ picks per run")
	_expect_between(float(highest_pick.get("epic_plus_per_run", 0.0)), 0.85, 1.35, "Highest-rarity strategy Epic+ picks per run")
	_expect_between(float(highest_pick.get("legendary_run_rate", 0.0)), 0.04, 0.11, "Highest-rarity strategy legendary run rate")


func _metric(sources: Dictionary, source: String, key: String) -> float:
	return float((sources.get(source, {}) as Dictionary).get(key, 0.0))


func _expect_between(value: float, minimum: float, maximum: float, label: String) -> void:
	_expect(value >= minimum and value <= maximum, "%s should stay between %.4f and %.4f, got %.4f" % [label, minimum, maximum, value])


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("RewardDistributionSmokeTest passed.")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

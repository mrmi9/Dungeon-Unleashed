extends Node

const SIMULATION := preload("res://scripts/weapons/WeaponRewardSimulation.gd")
const PICKER := preload("res://scripts/weapons/WeaponRewardPicker.gd")
const RUN_COUNT := 3000
const DETERMINISM_RUN_COUNT := 500
const BASE_SEED := 161803

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var summary: Dictionary = SIMULATION.simulate(RUN_COUNT, BASE_SEED)
	print(SIMULATION.format_report(summary))
	_verify_configuration()
	_verify_structure(summary)
	_verify_guarantees(summary)
	_verify_distribution_bounds(summary)
	_finish()


func _verify_configuration() -> void:
	var tables: Dictionary = SIMULATION.get_tables()
	_expect(PICKER.get_pool_ids(tables["armory"]).size() == 39, "Armory table should include all 39 non-starter weapons")
	_expect(PICKER.get_pool_ids(tables["shop"]).size() == 39, "Shop table should include all 39 non-starter weapons")
	_expect(PICKER.get_pool_ids(tables["boss_chest"]).size() == 32, "Boss table should include all 32 Rare+ weapons")
	_expect(PICKER.get_pool_ids(tables["cursed_event"]).size() == 15, "Cursed event table should include all 15 Epic+ weapons")
	for source in tables:
		var table: Resource = tables[source]
		var ids := PICKER.get_pool_ids(table)
		_expect(not ids.has("basic_pistol"), "%s should never include the starter pistol" % source)
		_expect(ids.size() == _unique_count(ids), "%s should not contain duplicate weapon ids" % source)
	_expect(str((tables["boss_chest"] as Resource).get("minimum_rarity")) == "rare", "Boss table should enforce a Rare+ floor")
	_expect(str((tables["cursed_event"] as Resource).get("minimum_rarity")) == "epic", "Cursed event table should enforce an Epic+ floor")


func _verify_structure(summary: Dictionary) -> void:
	var sources: Dictionary = summary.get("sources", {})
	_expect(int((sources.get("armory", {}) as Dictionary).get("offers", 0)) == RUN_COUNT * 3, "Simulation should include three armory offers per run")
	_expect(int((sources.get("boss_chest", {}) as Dictionary).get("offers", 0)) == RUN_COUNT * 3, "Simulation should include three boss weapon offers per run")
	_expect(int((sources.get("shop", {}) as Dictionary).get("offers", 0)) == RUN_COUNT * 3, "Simulation should include three shop weapon listings per run")
	var cursed_offers := int((sources.get("cursed_event", {}) as Dictionary).get("offers", 0))
	_expect(cursed_offers > RUN_COUNT * 0.40 and cursed_offers < RUN_COUNT * 0.60, "Cursed weapon events should remain near three one-in-six event rolls per run")
	var deterministic_a := SIMULATION.simulate(DETERMINISM_RUN_COUNT, BASE_SEED)
	var deterministic_b := SIMULATION.simulate(DETERMINISM_RUN_COUNT, BASE_SEED)
	var changed := SIMULATION.simulate(DETERMINISM_RUN_COUNT, BASE_SEED + 1)
	_expect(SIMULATION.get_distribution_signature(deterministic_a) == SIMULATION.get_distribution_signature(deterministic_b), "The same seed should reproduce weapon reward distributions")
	_expect(SIMULATION.get_distribution_signature(deterministic_a) != SIMULATION.get_distribution_signature(changed), "A different seed should change weapon reward distributions")


func _verify_guarantees(summary: Dictionary) -> void:
	var sources: Dictionary = summary.get("sources", {})
	for source in sources:
		var metrics: Dictionary = sources[source]
		_expect(int(metrics.get("invalid_offers", 0)) == 0, "%s should always produce a weapon" % source)
		_expect(int(metrics.get("minimum_rarity_failures", 0)) == 0, "%s should respect its minimum rarity" % source)
		_expect(int((metrics.get("rarity_counts", {}) as Dictionary).get("legendary", 0)) > 0, "%s should expose legendary weapons across the simulation" % source)
	_expect(is_equal_approx(float((sources.get("boss_chest", {}) as Dictionary).get("rare_plus_rate", 0.0)), 1.0), "Boss weapon chests should always produce Rare+")
	_expect(is_equal_approx(float((sources.get("cursed_event", {}) as Dictionary).get("epic_plus_rate", 0.0)), 1.0), "Cursed weapon events should always produce Epic+")
	var armory_classes: Dictionary = (sources.get("armory", {}) as Dictionary).get("class_counts", {})
	var armory_modes: Dictionary = (sources.get("armory", {}) as Dictionary).get("mode_counts", {})
	_expect(armory_classes.size() == 7, "Armory simulation should cover all seven weapon classes")
	_expect(armory_modes.size() == 5, "Armory simulation should cover all five fire modes")


func _verify_distribution_bounds(summary: Dictionary) -> void:
	var sources: Dictionary = summary.get("sources", {})
	_expect_between(_source_metric(sources, "armory", "rare_plus_rate"), 0.44, 0.52, "Armory Rare+ rate")
	_expect_between(_source_metric(sources, "armory", "epic_plus_rate"), 0.11, 0.17, "Armory Epic+ rate")
	_expect_between(_source_metric(sources, "armory", "legendary_rate"), 0.01, 0.03, "Armory legendary rate")
	_expect_between(_source_metric(sources, "boss_chest", "epic_plus_rate"), 0.23, 0.31, "Boss chest Epic+ rate")
	_expect_between(_source_metric(sources, "boss_chest", "legendary_rate"), 0.02, 0.055, "Boss chest legendary rate")
	_expect_between(_source_metric(sources, "shop", "rare_plus_rate"), 0.57, 0.66, "Shop Rare+ rate")
	_expect_between(_source_metric(sources, "shop", "epic_plus_rate"), 0.16, 0.23, "Shop Epic+ rate")
	_expect_between(_source_metric(sources, "shop", "legendary_rate"), 0.018, 0.045, "Shop legendary rate")
	_expect_between(_source_metric(sources, "cursed_event", "legendary_rate"), 0.09, 0.18, "Cursed event legendary rate")

	var strategies: Dictionary = summary.get("strategies", {})
	var guaranteed: Dictionary = strategies.get("guaranteed", {})
	var buyer: Dictionary = strategies.get("weapon_buyer", {})
	_verify_strategy_bounds(guaranteed, 6.4, 6.6, 4.7, 5.15, 1.5, 1.9, 0.16, 0.24, 4.1, 4.5, 2.9, 3.2, "Guaranteed")
	_verify_strategy_bounds(buyer, 9.4, 9.6, 6.5, 7.05, 2.05, 2.5, 0.23, 0.31, 4.9, 5.3, 3.35, 3.65, "Weapon-buyer")
	_expect_between(float(guaranteed.get("melee_run_rate", 0.0)), 0.76, 0.85, "Guaranteed melee run coverage")
	_expect_between(float(guaranteed.get("radial_run_rate", 0.0)), 0.44, 0.54, "Guaranteed radial run coverage")
	_expect_between(float(guaranteed.get("charge_run_rate", 0.0)), 0.32, 0.41, "Guaranteed charge run coverage")
	_expect_between(float(guaranteed.get("deployable_run_rate", 0.0)), 0.36, 0.46, "Guaranteed deployable run coverage")
	_expect_between(float(buyer.get("melee_run_rate", 0.0)), 0.88, 0.95, "Weapon-buyer melee run coverage")
	_expect_between(float(buyer.get("radial_run_rate", 0.0)), 0.55, 0.66, "Weapon-buyer radial run coverage")
	_expect_between(float(buyer.get("charge_run_rate", 0.0)), 0.41, 0.52, "Weapon-buyer charge run coverage")
	_expect_between(float(buyer.get("deployable_run_rate", 0.0)), 0.47, 0.57, "Weapon-buyer deployable run coverage")


func _verify_strategy_bounds(metrics: Dictionary, picks_min: float, picks_max: float, rare_min: float, rare_max: float, epic_min: float, epic_max: float, legendary_min: float, legendary_max: float, classes_min: float, classes_max: float, modes_min: float, modes_max: float, label: String) -> void:
	_expect_between(float(metrics.get("picks_per_run", 0.0)), picks_min, picks_max, "%s picks per run" % label)
	_expect_between(float(metrics.get("rare_plus_per_run", 0.0)), rare_min, rare_max, "%s Rare+ picks per run" % label)
	_expect_between(float(metrics.get("epic_plus_per_run", 0.0)), epic_min, epic_max, "%s Epic+ picks per run" % label)
	_expect_between(float(metrics.get("legendary_run_rate", 0.0)), legendary_min, legendary_max, "%s legendary run rate" % label)
	_expect_between(float(metrics.get("average_distinct_classes", 0.0)), classes_min, classes_max, "%s distinct classes" % label)
	_expect_between(float(metrics.get("average_distinct_modes", 0.0)), modes_min, modes_max, "%s distinct modes" % label)


func _source_metric(sources: Dictionary, source: String, key: String) -> float:
	return float((sources.get(source, {}) as Dictionary).get(key, 0.0))


func _expect_between(value: float, minimum: float, maximum: float, label: String) -> void:
	_expect(value >= minimum and value <= maximum, "%s should stay between %.4f and %.4f, got %.4f" % [label, minimum, maximum, value])


func _unique_count(values: PackedStringArray) -> int:
	var unique := {}
	for value in values:
		unique[value] = true
	return unique.size()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("WeaponRewardPacingSmokeTest passed.")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

extends Node

const RELIC_SYSTEM_SCRIPT := preload("res://scripts/relics/RelicSystem.gd")
const DROP_TABLE_SCRIPT := preload("res://scripts/relics/RelicDropTableData.gd")
const SHARP_ROUNDS := preload("res://resources/relics/sharp_rounds.tres")
const QUICK_TRIGGER := preload("res://resources/relics/quick_trigger.tres")
const SWIFT_LOADER := preload("res://resources/relics/swift_loader.tres")
const HEART_CORE := preload("res://resources/relics/heart_core.tres")
const STORED_SPARK := preload("res://resources/relics/stored_spark.tres")
const REWARD_TABLE := preload("res://resources/relic_drop_tables/reward.tres")
const SHOP_TABLE := preload("res://resources/relic_drop_tables/shop.tres")
const NORMAL_CHEST_TABLE := preload("res://resources/relic_drop_tables/normal_chest.tres")
const PREMIUM_CHEST_TABLE := preload("res://resources/relic_drop_tables/premium_chest.tres")
const BOSS_CHEST_TABLE := preload("res://resources/relic_drop_tables/boss_chest.tres")

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	_verify_production_configuration()
	await _verify_shared_pity_and_choice_guarantee()
	_finish()


func _verify_production_configuration() -> void:
	_expect(str(REWARD_TABLE.get("pity_group")) == "relic_reward", "Reward room should join the shared relic reward pity group")
	_expect(str(NORMAL_CHEST_TABLE.get("pity_group")) == "relic_reward", "Normal chest should join the shared relic reward pity group")
	_expect(int(REWARD_TABLE.get("pity_misses_before_guarantee")) == 3, "Reward room should guarantee after three misses")
	_expect(int(NORMAL_CHEST_TABLE.get("pity_misses_before_guarantee")) == 3, "Normal chest should guarantee after three misses")
	_expect(str(REWARD_TABLE.get("pity_minimum_rarity")) == "rare", "Reward room pity should target rare or better")
	_expect(str(NORMAL_CHEST_TABLE.get("pity_minimum_rarity")) == "rare", "Normal chest pity should target rare or better")
	_expect(str(PREMIUM_CHEST_TABLE.get("minimum_rarity")) == "rare", "Premium chest should enforce a rare minimum")
	_expect(str(BOSS_CHEST_TABLE.get("minimum_rarity")) == "rare", "Boss chest should enforce a rare minimum")
	_expect(_table_has_relic_at_or_above(PREMIUM_CHEST_TABLE, "rare"), "Premium chest pool should contain candidates that satisfy its hard floor")
	_expect(_table_has_relic_at_or_above(BOSS_CHEST_TABLE, "rare"), "Boss chest pool should contain candidates that satisfy its hard floor")
	_expect(str(SHOP_TABLE.get("pity_group")).is_empty(), "Shop inventory should not consume reward pity")
	_expect(str(SHOP_TABLE.get("minimum_rarity")).is_empty(), "Shop inventory should continue using its weighted rarity curve")


func _verify_shared_pity_and_choice_guarantee() -> void:
	var reward_table := _make_table("reward", "", "relic_reward", 2)
	var normal_table := _make_table("normal_chest", "", "relic_reward", 2)
	var premium_table := _make_table("premium_chest", "rare", "", 0)
	var shop_table := _make_table("shop", "", "", 0)
	var system := RELIC_SYSTEM_SCRIPT.new()
	system.available_relics = _test_pool()
	system.drop_tables = [reward_table, normal_table, premium_table, shop_table]
	add_child(system)
	await get_tree().process_frame
	system.call("set_random_seed", 264001)

	var first: Resource = system.call("choose_reward_relic", "reward", 1.0)
	_expect(_rarity_rank(str(first.get("rarity"))) == 0, "First forced reward offer should be common")
	var first_summary: Dictionary = system.call("get_source_reward_pacing_summary", "reward")
	_expect(int(first_summary.get("pity_misses", -1)) == 1, "First common reward offer should record one miss")
	_expect(not bool(first_summary.get("pity_due", true)), "Pity should not be due after one miss")

	var second: Resource = system.call("choose_reward_relic", "normal_chest", 1.0)
	_expect(_rarity_rank(str(second.get("rarity"))) == 0, "Second forced normal chest offer should be common")
	var due_summary: Dictionary = system.call("get_source_reward_pacing_summary", "reward")
	_expect(int(due_summary.get("pity_misses", -1)) == 2, "Reward room and normal chest should share misses")
	_expect(bool(due_summary.get("pity_due", false)), "Pity should become due after the configured miss count")

	var guaranteed_choices: Array = system.call("get_reward_choices", 3, "reward", 1.0)
	_expect(guaranteed_choices.size() == 3, "Pity reward offer should preserve the three-choice contract")
	_expect(_unique_relic_count(guaranteed_choices) == 3, "Pity reward offer should keep choices unique")
	_expect(_count_at_or_above_rarity(guaranteed_choices, "rare") == 1, "Pity should inject one rare-or-better choice without upgrading the full offer")
	var reset_summary: Dictionary = system.call("get_source_reward_pacing_summary", "normal_chest")
	_expect(int(reset_summary.get("pity_misses", -1)) == 0, "A qualifying offer should reset the shared pity count")
	_expect(not bool(reset_summary.get("pity_due", true)), "Pity should no longer be due after a qualifying offer")

	var premium: Resource = system.call("choose_reward_relic", "premium_chest", 1.0)
	_expect(_rarity_rank(str(premium.get("rarity"))) >= _rarity_rank("rare"), "Premium chest hard floor should override zero high-rarity weights")
	var after_premium: Dictionary = system.call("get_source_reward_pacing_summary", "reward")
	_expect(int(after_premium.get("pity_misses", -1)) == 0, "Guaranteed premium sources should not consume or alter ordinary reward pity")

	var shop: Resource = system.call("choose_reward_relic", "shop", 1.0)
	_expect(_rarity_rank(str(shop.get("rarity"))) == 0, "Shop should retain its weighted common result when no hard floor is configured")
	var pacing: Dictionary = system.call("get_reward_pacing_summary")
	var last_offer: Dictionary = pacing.get("last_offer", {})
	_expect(str(last_offer.get("source", "")) == "shop", "Reward pacing diagnostics should expose the latest source")
	_expect((last_offer.get("relic_ids", []) as Array).size() == 1, "Reward pacing diagnostics should expose offered relic ids")

	system.call("reset_run")
	var cleared: Dictionary = system.call("get_reward_pacing_summary")
	_expect((cleared.get("pity_misses_by_group", {}) as Dictionary).is_empty(), "Run reset should clear pity misses")
	_expect((cleared.get("offer_count_by_source", {}) as Dictionary).is_empty(), "Run reset should clear reward offer counts")
	_expect((cleared.get("last_offer", {}) as Dictionary).is_empty(), "Run reset should clear last-offer diagnostics")
	var no_choices: Array = system.call("get_reward_choices", 0, "reward", 1.0)
	_expect(no_choices.is_empty(), "Zero-sized reward requests should return no choices")
	var after_empty_request: Dictionary = system.call("get_reward_pacing_summary")
	_expect((after_empty_request.get("offer_count_by_source", {}) as Dictionary).is_empty(), "Empty reward requests should not advance offer counters")
	system.queue_free()
	await get_tree().process_frame


func _make_table(source: String, minimum_rarity: String, pity_group: String, pity_threshold: int) -> Resource:
	var table := DROP_TABLE_SCRIPT.new()
	table.source_id = StringName(source)
	table.display_name = source.capitalize()
	table.relic_pool = _test_pool()
	table.common_weight = 100.0
	table.rare_weight = 0.0
	table.epic_weight = 0.0
	table.legendary_weight = 0.0
	table.minimum_rarity = minimum_rarity
	table.pity_group = StringName(pity_group)
	table.pity_misses_before_guarantee = pity_threshold
	table.pity_minimum_rarity = "rare"
	return table


func _test_pool() -> Array[Resource]:
	return [SHARP_ROUNDS, QUICK_TRIGGER, SWIFT_LOADER, HEART_CORE, STORED_SPARK]


func _count_at_or_above_rarity(relics: Array, minimum_rarity: String) -> int:
	var count := 0
	var minimum_rank := _rarity_rank(minimum_rarity)
	for relic in relics:
		if relic is Resource and _rarity_rank(str(relic.get("rarity"))) >= minimum_rank:
			count += 1
	return count


func _table_has_relic_at_or_above(table: Resource, minimum_rarity: String) -> bool:
	var pool = table.get("relic_pool")
	if not pool is Array:
		return false
	for relic in pool:
		if relic is Resource and _rarity_rank(str(relic.get("rarity"))) >= _rarity_rank(minimum_rarity):
			return true
	return false


func _unique_relic_count(relics: Array) -> int:
	var ids: Dictionary = {}
	for relic in relics:
		if relic is Resource:
			ids[str(relic.get("id"))] = true
	return ids.size()


func _rarity_rank(rarity: String) -> int:
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


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("RewardPacingSmokeTest passed.")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

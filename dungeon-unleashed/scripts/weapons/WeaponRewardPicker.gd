extends RefCounted
class_name WeaponRewardPicker

const RARITIES := ["common", "rare", "epic", "legendary"]


static func pick_weapon(drop_table: Resource, rng: RandomNumberGenerator, biome_multiplier: float = 1.0) -> Resource:
	if drop_table == null or rng == null:
		return null

	var candidates_by_rarity := _eligible_candidates_by_rarity(drop_table)
	var rarity_weights := {}
	var total_rarity_weight := 0.0
	for rarity in RARITIES:
		var candidates: Array = candidates_by_rarity.get(rarity, [])
		if candidates.is_empty():
			continue
		var weight := _scaled_rarity_weight(drop_table, rarity, biome_multiplier)
		if weight <= 0.0:
			continue
		rarity_weights[rarity] = weight
		total_rarity_weight += weight

	if total_rarity_weight <= 0.0:
		return _pick_weighted_weapon(_flatten_candidates(candidates_by_rarity), rng)

	var rarity_roll := rng.randf_range(0.0, total_rarity_weight)
	var last_weighted_rarity := ""
	for rarity in RARITIES:
		if not rarity_weights.has(rarity):
			continue
		last_weighted_rarity = rarity
		rarity_roll -= float(rarity_weights[rarity])
		if rarity_roll <= 0.0:
			return _pick_weighted_weapon(candidates_by_rarity[rarity] as Array, rng)
	return _pick_weighted_weapon(candidates_by_rarity.get(last_weighted_rarity, []) as Array, rng)


static func get_pool_ids(drop_table: Resource) -> PackedStringArray:
	var ids := PackedStringArray()
	if drop_table == null:
		return ids
	var raw_pool = drop_table.get("weapon_pool")
	if not raw_pool is Array:
		return ids
	for weapon in raw_pool:
		if weapon is Resource:
			ids.append(str(weapon.get("id")))
	return ids


static func get_source_summary(drop_table: Resource, biome_multiplier: float = 1.0) -> Dictionary:
	if drop_table == null:
		return {}
	var candidates_by_rarity := _eligible_candidates_by_rarity(drop_table)
	var pool_counts := {}
	var scaled_weights := {}
	for rarity in RARITIES:
		pool_counts[rarity] = (candidates_by_rarity.get(rarity, []) as Array).size()
		scaled_weights[rarity] = _scaled_rarity_weight(drop_table, rarity, biome_multiplier)
	return {
		"source_id": str(drop_table.get("source_id")),
		"minimum_rarity": str(drop_table.get("minimum_rarity")),
		"pool_counts": pool_counts,
		"scaled_rarity_weights": scaled_weights,
	}


static func _eligible_candidates_by_rarity(drop_table: Resource) -> Dictionary:
	var grouped := {}
	for rarity in RARITIES:
		grouped[rarity] = []
	var minimum_rank := _rarity_rank(str(drop_table.get("minimum_rarity")))
	var raw_pool = drop_table.get("weapon_pool")
	if not raw_pool is Array:
		return grouped
	for weapon in raw_pool:
		if not weapon is Resource:
			continue
		var rarity := str(weapon.get("rarity")).strip_edges().to_lower()
		if not rarity in RARITIES or _rarity_rank(rarity) < minimum_rank:
			continue
		(grouped[rarity] as Array).append(weapon)
	return grouped


static func _flatten_candidates(grouped: Dictionary) -> Array:
	var candidates: Array = []
	for rarity in RARITIES:
		candidates.append_array(grouped.get(rarity, []) as Array)
	return candidates


static func _pick_weighted_weapon(candidates: Array, rng: RandomNumberGenerator) -> Resource:
	if candidates.is_empty():
		return null
	var total_weight := 0.0
	for weapon in candidates:
		if weapon is Resource:
			total_weight += maxf(float(weapon.get("drop_weight")), 0.0)
	if total_weight <= 0.0:
		return candidates[rng.randi_range(0, candidates.size() - 1)] as Resource
	var roll := rng.randf_range(0.0, total_weight)
	for weapon in candidates:
		if not weapon is Resource:
			continue
		roll -= maxf(float(weapon.get("drop_weight")), 0.0)
		if roll <= 0.0:
			return weapon as Resource
	return candidates.back() as Resource


static func _scaled_rarity_weight(drop_table: Resource, rarity: String, biome_multiplier: float) -> float:
	var base_weight := maxf(float(drop_table.get("%s_weight" % rarity)), 0.0)
	var multiplier := maxf(biome_multiplier, 0.0)
	match rarity:
		"rare":
			return base_weight * multiplier
		"epic":
			return base_weight * multiplier * multiplier
		"legendary":
			return base_weight * multiplier * multiplier * multiplier
	return base_weight


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

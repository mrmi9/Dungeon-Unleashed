extends Resource
class_name RelicDropTableData

@export var source_id: StringName = &"reward"
@export var display_name: String = "Reward"
@export var relic_pool: Array[Resource] = []
@export var common_weight: float = 100.0
@export var rare_weight: float = 45.0
@export var epic_weight: float = 18.0
@export var legendary_weight: float = 6.0
@export_group("Reward Pacing")
@export var minimum_rarity: String = ""
@export var pity_group: StringName = &""
@export_range(0, 20, 1) var pity_misses_before_guarantee: int = 0
@export var pity_minimum_rarity: String = "rare"


func get_rarity_weight(rarity: String) -> float:
	match rarity:
		"common":
			return common_weight
		"rare":
			return rare_weight
		"epic":
			return epic_weight
		"legendary":
			return legendary_weight
	return 1.0


func get_reward_pacing_summary() -> Dictionary:
	return {
		"minimum_rarity": minimum_rarity,
		"pity_group": str(pity_group),
		"pity_misses_before_guarantee": pity_misses_before_guarantee,
		"pity_minimum_rarity": pity_minimum_rarity,
	}

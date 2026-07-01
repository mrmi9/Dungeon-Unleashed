extends Resource
class_name RelicDropTableData

@export var source_id: StringName = &"reward"
@export var display_name: String = "Reward"
@export var relic_pool: Array[Resource] = []
@export var common_weight: float = 100.0
@export var rare_weight: float = 45.0
@export var epic_weight: float = 18.0
@export var legendary_weight: float = 6.0


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

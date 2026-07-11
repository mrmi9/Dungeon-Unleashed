extends Resource
class_name UnlockData

@export var id: String = "unlock_placeholder"
@export_enum("character", "weapon", "relic", "talent", "biome") var target_type: String = "weapon"
@export var target_id: String = "target_placeholder"
@export var display_name: String = ""
@export_multiline var description: String = ""
@export_enum("default", "run_count", "boss_clear", "currency", "stat", "achievement") var condition_type: String = "default"
@export var condition_key: String = ""
@export var condition_value: int = 0
@export var currency_cost: int = 0
@export var unlocked_by_default: bool = false

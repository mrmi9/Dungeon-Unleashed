extends Resource
class_name WeaponDropTableData

@export var source_id: StringName = &"armory"
@export var display_name: String = "Armory"
@export var weapon_pool: Array[Resource] = []
@export var common_weight: float = 100.0
@export var rare_weight: float = 45.0
@export var epic_weight: float = 15.0
@export var legendary_weight: float = 3.0
@export_enum("none", "common", "rare", "epic", "legendary") var minimum_rarity: String = "none"

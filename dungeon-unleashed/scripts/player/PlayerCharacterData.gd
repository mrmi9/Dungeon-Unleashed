extends Resource
class_name PlayerCharacterData

@export var id: StringName = &"wanderer"
@export var display_name: String = "Wanderer"
@export_multiline var description: String = "Balanced adventurer with reliable stats."
@export var sort_order: int = 0
@export var icon_key: String = ""
@export var unlock_id: String = ""
@export var unlock_condition: String = "default"
@export var meta_currency_unlock_cost: int = 0
@export var starting_weapon_ids: PackedStringArray = []
@export var passive_id: String = "none"
@export_multiline var passive_description: String = ""
@export var role_tags: PackedStringArray = []
@export_multiline var hall_summary: String = ""
@export var upgrade_slots: int = 3
@export var mastery_level_2_xp: int = 40
@export var mastery_level_3_xp: int = 100
@export var max_health: int = 6
@export var max_armor: int = 6
@export var max_energy: int = 120
@export var move_speed: float = 260.0
@export_enum("dash", "guard", "surge", "overdrive", "stabilize") var skill_id: String = "dash"
@export var skill_name: String = "Phase Dash"
@export_multiline var skill_description: String = "Briefly boosts speed and avoids damage."
@export var skill_cooldown: float = 8.0
@export var skill_duration: float = 1.2
@export var skill_energy_cost: int = 8
@export var skill_power: float = 1.0

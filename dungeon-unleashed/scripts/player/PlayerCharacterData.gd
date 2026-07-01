extends Resource
class_name PlayerCharacterData

@export var id: StringName = &"wanderer"
@export var display_name: String = "Wanderer"
@export_multiline var description: String = "Balanced adventurer with reliable stats."
@export var max_health: int = 6
@export var max_armor: int = 6
@export var max_energy: int = 120
@export var move_speed: float = 260.0
@export_enum("dash", "guard", "surge") var skill_id: String = "dash"
@export var skill_name: String = "Phase Dash"
@export_multiline var skill_description: String = "Briefly boosts speed and avoids damage."
@export var skill_cooldown: float = 8.0
@export var skill_duration: float = 1.2
@export var skill_energy_cost: int = 8
@export var skill_power: float = 1.0

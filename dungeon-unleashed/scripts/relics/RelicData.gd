extends Resource
class_name RelicData

@export var id: StringName = &"sharp_rounds"
@export var display_name: String = "Sharp Rounds"
@export_multiline var description: String = "Increase projectile damage."
@export_enum("common", "rare", "epic", "legendary") var rarity: String = "common"
@export_enum("damage_multiplier", "fire_rate_multiplier", "projectile_count", "pierce", "crit_chance_bonus", "reload_speed_multiplier", "max_health", "kill_heal", "room_clear_shield", "hurt_speed_boost") var effect_type: String = "damage_multiplier"
@export var effect_value: float = 0.2
@export var effect_duration: float = 0.0
@export var stackable: bool = true
@export var max_stacks: int = 3
@export var tags: PackedStringArray = []

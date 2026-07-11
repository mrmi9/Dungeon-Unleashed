extends Resource
class_name RelicData

@export var id: StringName = &"sharp_rounds"
@export var display_name: String = "Sharp Rounds"
@export_multiline var description: String = "Increase projectile damage."
@export_enum("common", "rare", "epic", "legendary") var rarity: String = "common"
@export_enum("passive", "on_fire", "on_projectile_spawned", "on_hit", "on_kill", "on_room_clear", "on_hurt", "on_gold_changed", "on_low_health") var trigger_event: String = "passive"
@export_enum("damage_multiplier", "fire_rate_multiplier", "projectile_count", "pierce", "bounce_count_bonus", "homing_turn_rate_bonus", "homing_radius_bonus", "chain_count_bonus", "chain_radius_bonus", "chain_damage_multiplier", "explosion_radius_bonus", "knockback_multiplier", "magazine_size_bonus", "crit_chance_bonus", "reload_speed_multiplier", "max_health", "max_energy", "kill_heal", "room_clear_shield", "hurt_speed_boost", "status_chance_bonus", "status_damage_multiplier", "status_duration_multiplier", "projectile_block_radius_bonus", "projectile_block_arc_bonus", "projectile_block_damage_bonus", "charge_damage_multiplier", "charge_speed_multiplier", "charge_projectile_count_bonus", "deployable_damage_multiplier", "deployable_duration_multiplier") var effect_type: String = "damage_multiplier"
@export var effect_value: float = 0.2
@export var effect_duration: float = 0.0
@export var drop_weight: float = 1.0
@export var unlock_id: String = ""
@export var icon_key: String = ""
@export var description_value_template: String = ""
@export var stackable: bool = true
@export var max_stacks: int = 3
@export var build_tags: PackedStringArray = []
@export var conflict_tags: PackedStringArray = []
@export var tags: PackedStringArray = []

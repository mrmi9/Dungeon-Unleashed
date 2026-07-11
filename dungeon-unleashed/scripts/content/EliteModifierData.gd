extends Resource
class_name EliteModifierData

@export var id: StringName = &"elite"
@export var display_name: String = "Elite"
@export var name_prefix: String = "Elite"
@export_multiline var description: String = ""
@export var role_tags: PackedStringArray = PackedStringArray()
@export var health_multiplier: float = 1.5
@export var damage_multiplier: float = 1.2
@export var move_speed_multiplier: float = 1.0
@export var attack_cooldown_multiplier: float = 1.0
@export var projectile_speed_multiplier: float = 1.0
@export var death_explosion_radius: float = 0.0
@export var death_explosion_damage: int = 0
@export var visual_color: Color = Color(1.0, 0.62, 0.18, 1.0)
@export_enum("ring", "flame", "shield", "velocity", "blast", "reticle", "mass") var visual_pattern: String = "ring"
@export var aura_radius: float = 30.0
@export var pulse_speed: float = 2.0
@export_enum("none", "scorch_pulse", "guarded_core", "overclock", "volatile_core", "focused_fire", "unstoppable") var combat_trait: String = "none"
@export var trait_interval: float = 0.0
@export var trait_windup: float = 0.5
@export var trait_duration: float = 0.8
@export var trait_radius: float = 90.0
@export var trait_strength: float = 1.0
@export var scale_multiplier: float = 1.18

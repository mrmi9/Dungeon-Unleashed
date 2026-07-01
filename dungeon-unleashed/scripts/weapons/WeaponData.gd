extends Resource
class_name WeaponData

@export var id: StringName = &"basic_pistol"
@export var display_name: String = "Basic Pistol"
@export_multiline var description: String = "Reliable sidearm."
@export var damage: int = 1
@export var fire_rate: float = 6.0
@export var projectile_speed: float = 720.0
@export var projectile_range: float = 720.0
@export var projectile_count: int = 1
@export var spread_angle: float = 0.0
@export var energy_cost: int = 0
@export var magazine_size: int = 12
@export var reload_duration: float = 1.0
@export var knockback: float = 120.0
@export_range(0.0, 1.0, 0.01) var crit_chance: float = 0.05
@export var crit_multiplier: float = 2.0
@export var pierce_count: int = 0
@export var bounce_count: int = 0
@export var explosion_radius: float = 0.0
@export var tags: PackedStringArray = []

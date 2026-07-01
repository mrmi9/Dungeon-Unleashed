extends Resource
class_name RoomData

@export var id: StringName = &"combat_room"
@export_enum("start", "combat", "reward", "elite", "shop", "boss", "boss_placeholder") var room_type: String = "combat"
@export var template_id: String = "prototype_combat_room"
@export_enum("training", "crossfire", "reward_cache", "pillars", "market", "boss_arena") var layout_profile: String = "crossfire"
@export var layout_data: Resource
@export var room_scene: PackedScene = preload("res://scenes/rooms/PrototypeCombatRoom.tscn")
@export var enemy_scenes: Array[PackedScene] = []
@export var enemy_names: PackedStringArray = []
@export var wave_enemy_counts: PackedInt32Array = []
@export var reward_scene: PackedScene = preload("res://scenes/pickups/CoinPickup.tscn")
@export var lock_doors_during_combat: bool = true
@export var auto_clear_on_enter: bool = false
@export var elite_enemies: bool = false
@export var elite_health_multiplier: float = 1.8
@export var elite_damage_multiplier: float = 1.35
@export var elite_death_explosion_radius: float = 120.0
@export var elite_death_explosion_damage: int = 1

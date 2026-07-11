extends Resource
class_name RoomData

@export var id: StringName = &"combat_room"
@export_enum("start", "combat", "challenge", "trap", "reward", "event", "armory", "healing", "elite", "shop", "boss", "boss_placeholder") var room_type: String = "combat"
@export var template_id: String = "prototype_combat_room"
@export_enum("training", "crossfire", "reward_cache", "shrine", "open_cross", "pillars", "market", "boss_arena", "gauntlet", "split_cover", "center_ring", "ambush_corners", "boss_cross", "box_maze", "bunker", "corner_nests", "crescent", "diagonal_blocks", "long_lane", "narrow_gap", "twin_islands", "wide_arena") var layout_profile: String = "crossfire"
@export var layout_data: Resource
@export var room_scene: PackedScene = preload("res://scenes/rooms/PrototypeCombatRoom.tscn")
@export var enemy_scenes: Array[PackedScene] = []
@export var enemy_names: PackedStringArray = []
@export var wave_enemy_counts: PackedInt32Array = []
@export var reward_scene: PackedScene = preload("res://scenes/pickups/CoinPickup.tscn")
@export var lock_doors_during_combat: bool = true
@export var auto_clear_on_enter: bool = false
@export_multiline var hazard_review_tip: String = ""
@export_multiline var hazard_threat_intel: String = ""
@export var hazard_counter_tags: PackedStringArray = []
@export_enum("gauntlet", "hazard_rush", "random") var challenge_variant: String = "gauntlet"
@export var challenge_variant_label: String = "Elite Gauntlet"
@export var elite_enemies: bool = false
@export var elite_health_multiplier: float = 1.8
@export var elite_damage_multiplier: float = 1.35
@export var elite_death_explosion_radius: float = 120.0
@export var elite_death_explosion_damage: int = 1
@export var elite_modifier_profiles: Array[Resource] = []

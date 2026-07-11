extends Resource
class_name BiomeData

@export var id: StringName = &"prototype_depths"
@export var display_name: String = "Prototype Depths"
@export_multiline var description: String = ""
@export var biome_index: int = 1
@export var room_count_min: int = 7
@export var room_count_max: int = 9
@export var branch_count_min: int = 5
@export var branch_count_max: int = 6
@export var room_data_pool: Array[Resource] = []
@export var layout_pool: Array[Resource] = []
@export var enemy_pool: Array[PackedScene] = []
@export var boss_scene: PackedScene
@export var music_key: String = ""
@export var color_key: String = ""
@export var visual_floor_tint: Color = Color(0.095, 0.105, 0.12, 1.0)
@export_file("*.png") var visual_floor_texture_path: String = ""
@export var visual_floor_texture_modulate: Color = Color.WHITE
@export_range(0.0, 1.0, 0.01) var visual_floor_texture_opacity: float = 0.8
@export var visual_wall_color: Color = Color(0.22, 0.24, 0.27, 1.0)
@export var visual_obstacle_tint: Color = Color(0.24, 0.26, 0.29, 1.0)
@export_file var visual_surface_atlas_path: String = ""
@export var visual_wall_texture_modulate: Color = Color.WHITE
@export_range(0.0, 1.0, 0.01) var visual_wall_texture_opacity: float = 0.9
@export var visual_obstacle_texture_modulate: Color = Color.WHITE
@export_range(0.0, 1.0, 0.01) var visual_obstacle_texture_opacity: float = 0.9
@export var visual_accent_color: Color = Color(0.74, 0.82, 0.94, 1.0)
@export_range(0.0, 1.0, 0.01) var visual_tint_strength: float = 0.0
@export var reward_weight_multiplier: float = 1.0

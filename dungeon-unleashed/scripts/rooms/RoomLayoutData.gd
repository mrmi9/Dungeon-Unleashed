extends Resource
class_name RoomLayoutData

@export var id: StringName = &"crossfire"
@export var display_name: String = "Crossfire"
@export var floor_color: Color = Color(0.095, 0.105, 0.12, 1.0)
@export var spawn_positions: PackedVector2Array = [
	Vector2(370, -210),
	Vector2(-370, -190),
	Vector2(390, 205),
	Vector2(-390, 185),
]
@export var reward_position: Vector2 = Vector2(0, -40)
@export var obstacle_names: PackedStringArray = []
@export var obstacle_positions: PackedVector2Array = []
@export var obstacle_sizes: PackedVector2Array = []
@export var obstacle_colors: PackedColorArray = []


func get_obstacle_count() -> int:
	return mini(obstacle_positions.size(), obstacle_sizes.size())

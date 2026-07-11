extends Resource
class_name RunGraphData

@export var id: StringName = &"standard_three_biome_run"
@export var display_name: String = "Standard Run"
@export var generation_seed: int = 0
@export var biome_sequence: Array[Resource] = []
@export var rooms_per_biome_min: int = 7
@export var rooms_per_biome_max: int = 9
@export var branch_rooms_per_biome_min: int = 5
@export var branch_rooms_per_biome_max: int = 6
@export var required_room_types: PackedStringArray = PackedStringArray(["start", "event", "challenge", "trap", "shop", "elite", "boss"])
@export var allow_seed_replay: bool = true

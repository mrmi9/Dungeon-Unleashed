extends Resource
class_name TalentData

@export var id: String = "talent_placeholder"
@export var display_name: String = ""
@export_multiline var description: String = ""
@export_enum("common", "rare", "epic", "legendary") var rarity: String = "common"
@export var icon_key: String = ""
@export_enum("run", "biome", "room", "timed") var duration_scope: String = "run"
@export_enum("passive", "on_fire", "on_projectile_spawned", "on_hit", "on_kill", "on_room_clear", "on_hurt", "on_gold_changed", "on_low_health") var trigger_event: String = "passive"
@export var effect_type: String = ""
@export var effect_value: float = 0.0
@export var effect_duration: float = 0.0
@export var drop_weight: float = 1.0
@export var build_tags: PackedStringArray = []
@export var conflict_tags: PackedStringArray = []

extends Resource
class_name StatueData

@export var id: String = "statue_placeholder"
@export var display_name: String = ""
@export_multiline var description: String = ""
@export_enum("common", "rare", "epic", "legendary") var rarity: String = "common"
@export var icon_key: String = ""
@export_enum("run", "biome", "room", "timed") var duration_scope: String = "run"
@export_enum("on_skill_used") var trigger_event: String = "on_skill_used"
@export var trigger_interval: int = 1
@export var effect_type: String = ""
@export var effect_value: float = 0.0
@export var effect_duration: float = 0.0
@export var drop_weight: float = 1.0
@export var build_tags: PackedStringArray = []
@export var conflict_tags: PackedStringArray = []
@export_multiline var rule_text: String = ""

extends Resource
class_name ContentIconDefinitionData

@export var icon_key: String = ""
@export_enum("weapon", "relic", "talent", "blessing", "statue", "character", "room") var content_type: String = "weapon"
@export var token: String = ""
@export var placeholder_color: Color = Color(0.24, 0.28, 0.34, 1.0)
@export var accessibility_label: String = ""
@export var texture_path: String = ""
@export var atlas_region: Rect2i = Rect2i(0, 0, 0, 0)

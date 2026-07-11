extends RefCounted
class_name ContentIconRegistry

const DEFAULT_REGISTRY_PATH := "res://resources/ui/content_icon_registry.tres"
const FALLBACK_COLOR := Color(0.24, 0.28, 0.34, 1.0)
const TYPE_COLORS := {
	"weapon": Color(0.48, 0.78, 1.0, 1.0),
	"relic": Color(0.78, 0.56, 1.0, 1.0),
	"talent": Color(0.62, 0.92, 0.72, 1.0),
	"blessing": Color(1.0, 0.64, 0.22, 1.0),
	"statue": Color(0.58, 0.78, 1.0, 1.0),
	"character": Color(0.86, 0.94, 1.0, 1.0),
	"room": Color(0.74, 0.82, 0.94, 1.0),
}


static func get_icon_type(icon_key: String, page: String = "") -> String:
	var definition := get_icon_definition(icon_key, page)
	if definition != null:
		var defined_type := str(definition.get("content_type")).strip_edges().to_lower()
		if TYPE_COLORS.has(defined_type):
			return defined_type
	return _infer_icon_type(icon_key, page)


static func get_type_token(icon_key: String, page: String = "") -> String:
	var definition := get_icon_definition(icon_key, page)
	if definition != null:
		var token := str(definition.get("token")).strip_edges()
		if not token.is_empty():
			return token

	match get_icon_type(icon_key, page):
		"weapon":
			return "WPN"
		"relic":
			return "REL"
		"talent":
			return "TAL"
		"blessing":
			return "BLS"
		"statue":
			return "STU"
		"character":
			return "CHR"
		"room":
			return "RM"
	return "N/A"


static func get_placeholder_color(icon_key: String, page: String = "") -> Color:
	var definition := get_icon_definition(icon_key, page)
	if definition != null and definition.get("placeholder_color") is Color:
		return definition.get("placeholder_color")

	var icon_type := get_icon_type(icon_key, page)
	if TYPE_COLORS.has(icon_type):
		return TYPE_COLORS[icon_type]
	return _get_registry_fallback_color()


static func get_placeholder_tooltip(icon_key: String, display_name: String = "", page: String = "") -> String:
	var key := icon_key.strip_edges()
	var label := display_name.strip_edges()
	var definition := get_icon_definition(key, page)
	var icon_type := get_icon_type(key, page)
	var accessibility_label := ""
	if definition != null:
		accessibility_label = str(definition.get("accessibility_label")).strip_edges()
	if key.is_empty():
		return "No icon key"
	if label.is_empty():
		label = key
	if not accessibility_label.is_empty():
		return "%s %s: %s" % [label, accessibility_label, key]
	if icon_type.is_empty():
		return "%s icon key: %s" % [label, key]
	return "%s %s icon key: %s" % [label, icon_type, key]


static func has_placeholder_icon(icon_key: String, page: String = "") -> bool:
	return not icon_key.strip_edges().is_empty() and not get_icon_type(icon_key, page).is_empty()


static func get_texture_path(icon_key: String, page: String = "") -> String:
	var definition := get_icon_definition(icon_key, page)
	if definition == null:
		return ""
	return str(definition.get("texture_path")).strip_edges()


static func get_atlas_region(icon_key: String, page: String = "") -> Rect2i:
	var definition := get_icon_definition(icon_key, page)
	if definition != null and definition.get("atlas_region") is Rect2i:
		return definition.get("atlas_region")
	return Rect2i(0, 0, 0, 0)


static func get_registered_icon_count() -> int:
	return _get_registry_definitions().size()


static func has_definition_for_type(content_type: String) -> bool:
	var normalized_type := content_type.strip_edges().to_lower()
	for definition in _get_registry_definitions():
		if str(definition.get("content_type")).strip_edges().to_lower() == normalized_type:
			return true
	return false


static func get_icon_definition(icon_key: String, page: String = "") -> Resource:
	var normalized_key := icon_key.strip_edges().to_lower()
	var inferred_type := _infer_icon_type(normalized_key, page)
	var fallback_definition: Resource = null
	for definition in _get_registry_definitions():
		var definition_key := str(definition.get("icon_key")).strip_edges().to_lower()
		var definition_type := str(definition.get("content_type")).strip_edges().to_lower()
		if not normalized_key.is_empty() and definition_key == normalized_key:
			return definition
		if fallback_definition == null and not inferred_type.is_empty() and definition_type == inferred_type:
			fallback_definition = definition
		if not inferred_type.is_empty() and definition_type == inferred_type and definition_key == inferred_type:
			fallback_definition = definition
	return fallback_definition


static func _infer_icon_type(icon_key: String, page: String = "") -> String:
	var normalized_key := icon_key.strip_edges().to_lower()
	if not normalized_key.is_empty():
		var key_parts := normalized_key.split("_", false)
		if key_parts.size() > 0:
			var prefix := str(key_parts[0])
			if TYPE_COLORS.has(prefix):
				return prefix

	match page.strip_edges().to_lower():
		"weapons":
			return "weapon"
		"relics":
			return "relic"
		"talents":
			return "talent"
		"blessings":
			return "blessing"
		"statues":
			return "statue"
		"characters":
			return "character"
		"rooms":
			return "room"
	return ""


static func _get_registry_definitions() -> Array:
	var registry := load(DEFAULT_REGISTRY_PATH)
	if not (registry is Resource):
		return []
	var definitions_value = registry.get("definitions")
	if not (definitions_value is Array):
		return []

	var definitions: Array = []
	for definition in definitions_value:
		if definition is Resource:
			definitions.append(definition)
	return definitions


static func _get_registry_fallback_color() -> Color:
	var registry := load(DEFAULT_REGISTRY_PATH)
	if registry is Resource and registry.get("fallback_color") is Color:
		return registry.get("fallback_color")
	return FALLBACK_COLOR

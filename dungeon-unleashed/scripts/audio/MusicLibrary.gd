extends RefCounted
class_name MusicLibrary

const TRACK_ROOT := "res://audio/music/authored/"

const TRACK_IDS := [
	"menu",
	"biome_outer_warrens",
	"biome_iron_catacombs",
	"biome_void_foundry",
	"boss",
	"victory",
	"defeat",
]

const LOOPING_TRACK_IDS := [
	"menu",
	"biome_outer_warrens",
	"biome_iron_catacombs",
	"biome_void_foundry",
	"boss",
]

const TRACK_ALIASES := {
	"combat": "biome_outer_warrens",
}


static func resolve_track_id(music_key: String) -> String:
	var normalized_key := music_key.strip_edges()
	if normalized_key in TRACK_IDS:
		return normalized_key
	return str(TRACK_ALIASES.get(normalized_key, ""))


static func get_asset_path(music_key: String) -> String:
	var track_id := resolve_track_id(music_key)
	if track_id.is_empty():
		return ""
	return "%s%s.wav" % [TRACK_ROOT, track_id]


static func has_mapping(music_key: String) -> bool:
	return not resolve_track_id(music_key).is_empty()


static func should_loop(music_key: String) -> bool:
	return resolve_track_id(music_key) in LOOPING_TRACK_IDS


static func get_required_track_ids() -> Array:
	return TRACK_IDS.duplicate()

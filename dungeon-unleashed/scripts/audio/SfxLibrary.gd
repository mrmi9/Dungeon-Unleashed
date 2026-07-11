extends RefCounted
class_name SfxLibrary

const SAMPLE_ROOT := "res://audio/sfx/authored/"

const SAMPLE_IDS := [
	"weapon_sidearm",
	"weapon_shotgun",
	"weapon_launcher",
	"weapon_laser",
	"weapon_melee",
	"weapon_staff",
	"weapon_core",
	"hit",
	"crit",
	"kill",
	"hurt",
	"hp_heal",
	"low_health",
	"low_health_heartbeat",
	"low_health_recover",
	"clear",
	"chest",
	"reward",
	"buy",
	"fail",
	"energy_empty",
	"reload_ready",
	"skill_fail",
	"skill_ready",
	"passive_focus",
	"passive_guard",
	"passive_energy",
	"passive_speed",
	"passive_burst",
	"passive_support",
	"passive_trigger",
	"blessing_clear",
	"blessing_kill",
	"blessing_guard",
	"blessing_resonance",
	"blessing_trigger",
	"statue_skill",
	"statue_trigger",
	"statue_attune",
	"armor_gain",
	"armor_block",
	"projectile_block",
	"armor_break",
	"danger_warning",
	"danger_warning_line",
	"danger_warning_heavy",
	"enemy_summon_windup",
	"enemy_support_windup",
	"enemy_shield_bash_windup",
	"enemy_action_windup",
	"boss_phase",
	"boss_died",
	"victory",
	"defeat",
]

const SOUND_ALIASES := {
	"shoot": "weapon_sidearm",
	"weapon_sidearm_fire": "weapon_sidearm",
	"pistol_fire": "weapon_sidearm",
	"carbine_fire": "weapon_sidearm",
	"needler_fire": "weapon_sidearm",
	"ricochet_fire": "weapon_sidearm",
	"compass_needle_fire": "weapon_sidearm",
	"quench_repeater_fire": "weapon_sidearm",
	"undertow_volley_fire": "weapon_sidearm",
	"weapon_shotgun_fire": "weapon_shotgun",
	"shotgun_fire": "weapon_shotgun",
	"fan_burst": "weapon_shotgun",
	"storm_fan_fire": "weapon_shotgun",
	"furnace_scatter_fire": "weapon_shotgun",
	"weapon_launcher_fire": "weapon_launcher",
	"launcher_fire": "weapon_launcher",
	"mortar_fire": "weapon_launcher",
	"slag_launch": "weapon_launcher",
	"mine_arm": "weapon_launcher",
	"weapon_laser_fire": "weapon_laser",
	"laser_fire": "weapon_laser",
	"prism_fire": "weapon_laser",
	"vault_lance_fire": "weapon_laser",
	"stormglass_rail_fire": "weapon_laser",
	"weapon_melee_fire": "weapon_melee",
	"melee_swing": "weapon_melee",
	"frost_swing": "weapon_melee",
	"guard_cleave": "weapon_melee",
	"spear_thrust": "weapon_melee",
	"sickle_swing": "weapon_melee",
	"riposte_swing": "weapon_melee",
	"bulwark_fan": "weapon_melee",
	"bastion_saw_swing": "weapon_melee",
	"weapon_staff_fire": "weapon_staff",
	"staff_fire": "weapon_staff",
	"ember_spray": "weapon_staff",
	"deploy_beacon": "weapon_staff",
	"relay_arc_fire": "weapon_staff",
	"rift_bloom_fire": "weapon_staff",
	"lantern_swarm_fire": "weapon_staff",
	"weapon_core_fire": "weapon_core",
	"nova_fire": "weapon_core",
	"halo_fire": "weapon_core",
	"orbit_fire": "weapon_core",
	"sentry_seed": "weapon_core",
	"storm_charge_fire": "weapon_core",
	"charge_bolt_fire": "weapon_core",
	"thunder_nest_deploy": "weapon_core",
}


static func resolve_sample_id(sound_id: String) -> String:
	var normalized_id := sound_id.strip_edges()
	if normalized_id in SAMPLE_IDS:
		return normalized_id
	return str(SOUND_ALIASES.get(normalized_id, ""))


static func get_asset_path(sound_id: String) -> String:
	var sample_id := resolve_sample_id(sound_id)
	if sample_id.is_empty():
		return ""
	return "%s%s.wav" % [SAMPLE_ROOT, sample_id]


static func has_mapping(sound_id: String) -> bool:
	return not resolve_sample_id(sound_id).is_empty()


static func get_required_sample_ids() -> Array:
	return SAMPLE_IDS.duplicate()


static func get_supported_sound_ids() -> Array:
	var sound_ids := SAMPLE_IDS.duplicate()
	for sound_id in SOUND_ALIASES.keys():
		sound_ids.append(str(sound_id))
	return sound_ids

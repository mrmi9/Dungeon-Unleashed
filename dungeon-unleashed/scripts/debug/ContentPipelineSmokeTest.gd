extends Node

const WEAPON_DIR := "res://resources/weapons"
const RELIC_DIR := "res://resources/relics"
const CHARACTER_DIR := "res://resources/characters"
const TALENT_DIR := "res://resources/talents"
const BLESSING_DIR := "res://resources/blessings"
const STATUE_DIR := "res://resources/statues"
const BIOME_DIR := "res://resources/biomes"
const ENEMY_SCENE_DIR := "res://scenes/enemies"
const ELITE_MODIFIER_DIR := "res://resources/elite_modifiers"
const REQUIRED_WEAPON_IDS := [
	"coil_carbine",
	"shatter_fan",
	"rift_spear",
	"orbit_sower",
	"pulse_needler",
	"cinder_mortar",
	"mirror_sickle",
	"storm_fan",
	"prism_ray",
	"halo_kernel",
	"ember_sprayer",
	"frost_sickle",
	"slag_comet",
	"guard_cleaver",
	"riposte_saber",
	"bulwark_fan",
	"coil_bow",
	"storm_capacitor",
	"vault_lance",
	"snare_beacon",
	"ember_mine",
	"sentry_seed",
	"quench_repeater",
	"furnace_scattergun",
	"bastion_saw",
	"rift_bloom",
	"thunder_nest",
	"compass_needle",
	"relay_arc",
	"lantern_swarm",
	"undertow_volley",
	"stormglass_rail",
]
const REQUIRED_RELIC_IDS := [
	"keen_sights",
	"hollow_needle",
	"scatter_lens",
	"field_rations",
	"bulwark_plate",
	"redline_boots",
	"breach_powder",
	"momentum_coil",
	"steady_capacitor",
	"gilded_tip",
	"echo_chamber",
	"breakwater_guard",
	"siphon_clasp",
	"kinetic_ram",
	"volatile_oil",
	"ember_catalyst",
	"lingering_ash",
	"parry_grip",
	"warding_hinge",
	"counterweight_core",
	"draw_weight",
	"quick_windup",
	"stored_spark",
	"tripwire_amplifier",
	"anchor_spool",
	"ricochet_gyro",
	"blast_radius_gauge",
	"kinetic_bridle",
	"reserve_drum",
	"flux_reservoir",
	"tracking_vane",
	"longview_array",
	"forked_bus",
	"conduction_mesh",
	"stormglass_filament",
]
const SUPPORTED_STATUS_EFFECTS := ["none", "burn", "slow"]
const SUPPORTED_FIRE_MODES := ["projectile", "radial", "melee", "charge", "deployable"]
const SUPPORTED_DEPLOYABLE_BEHAVIORS := ["field", "mine", "sentry"]
const REQUIRED_CHARACTER_IDS := [
	"wanderer",
	"warden",
	"arcanist",
	"rift_runner",
	"emberwright",
	"field_medic",
]
const REQUIRED_ENEMY_DISPLAY_NAMES := [
	"Chaser",
	"Shooter",
	"Charger",
	"Bomber",
	"Summoner",
	"Shielded",
	"Rust Skirmisher",
	"Ember Marksman",
	"Iron Breaker",
	"Volatile Vessel",
	"Aegis Drone",
	"Rift Caller",
	"Needle Skater",
	"Soot Splitter",
	"Mire Conduit",
	"Grave Mender",
	"Barrage Totem",
	"Null Acolyte",
]
const REQUIRED_ELITE_MODIFIER_IDS := [
	"blazing",
	"bulwark",
	"quickened",
	"volatile",
	"sharpshot",
	"titan",
]
const REQUIRED_BLESSING_IDS := [
	"deep_cell",
	"quiet_plate",
	"ember_tithe",
	"afterglow_circuit",
	"spark_dividend",
	"brace_current",
	"resonance_battery",
]
const REQUIRED_STATUE_IDS := [
	"bulwark_idol",
	"cinder_focus",
	"echo_reservoir",
]

const RUN_GRAPH_SCRIPT := preload("res://scripts/content/RunGraphData.gd")
const BIOME_SCRIPT := preload("res://scripts/content/BiomeData.gd")
const UNLOCK_SCRIPT := preload("res://scripts/content/UnlockData.gd")
const WEAPON_SCRIPT := preload("res://scripts/weapons/WeaponData.gd")
const RELIC_SCRIPT := preload("res://scripts/relics/RelicData.gd")
const CHARACTER_SCRIPT := preload("res://scripts/player/PlayerCharacterData.gd")
const CONTENT_ICON_REGISTRY := preload("res://scripts/content/ContentIconRegistry.gd")
const CONTENT_ICON_REGISTRY_RESOURCE := preload("res://resources/ui/content_icon_registry.tres")
const TALENT_SCRIPT := preload("res://scripts/content/TalentData.gd")
const BLESSING_SCRIPT := preload("res://scripts/content/BlessingData.gd")
const STATUE_SCRIPT := preload("res://scripts/content/StatueData.gd")
const ELITE_MODIFIER_SCRIPT := preload("res://scripts/content/EliteModifierData.gd")
const AIM_ASSIST_SCRIPT := preload("res://scripts/combat/AimAssistController.gd")
const ROOM_DATA_SCRIPT := preload("res://scripts/rooms/RoomData.gd")
const EVENT_SHRINE_SCRIPT := preload("res://scripts/events/EventShrine.gd")

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	_verify_content_interface_scripts()
	_verify_weapons()
	_verify_relics()
	_verify_characters()
	_verify_talents()
	_verify_blessings()
	_verify_statues()
	_verify_enemy_scenes()
	_verify_elite_modifiers()
	_verify_biomes()
	_verify_aim_assist_contract()
	_finish()


func _verify_content_interface_scripts() -> void:
	var run_graph := RUN_GRAPH_SCRIPT.new()
	var biome := BIOME_SCRIPT.new()
	var unlock := UNLOCK_SCRIPT.new()
	var weapon := WEAPON_SCRIPT.new()
	var relic := RELIC_SCRIPT.new()
	var character := CHARACTER_SCRIPT.new()
	var talent := TALENT_SCRIPT.new()
	var blessing := BLESSING_SCRIPT.new()
	var statue := STATUE_SCRIPT.new()
	var elite_modifier := ELITE_MODIFIER_SCRIPT.new()
	var room_data := ROOM_DATA_SCRIPT.new()
	var event_shrine := EVENT_SHRINE_SCRIPT.new()

	_expect(run_graph.get("required_room_types") is PackedStringArray, "RunGraphData should declare required room types")
	if run_graph.get("required_room_types") is PackedStringArray:
		_expect((run_graph.get("required_room_types") as PackedStringArray).has("event"), "RunGraphData should include event rooms in required room types")
		_expect((run_graph.get("required_room_types") as PackedStringArray).has("challenge"), "RunGraphData should include challenge rooms in required room types")
		_expect((run_graph.get("required_room_types") as PackedStringArray).has("trap"), "RunGraphData should include trap rooms in required room types")
	_expect(run_graph.get("allow_seed_replay"), "RunGraphData should keep seed replay enabled by default")
	_expect(int(biome.get("room_count_min")) <= int(biome.get("room_count_max")), "BiomeData room count bounds should be valid")
	_expect(int(biome.get("branch_count_min")) <= int(biome.get("branch_count_max")), "BiomeData branch count bounds should be valid")
	_expect(str(unlock.get("condition_type")) == "default", "UnlockData should support default unlocks")
	_expect(str(room_data.get("challenge_variant")) in ["gauntlet", "hazard_rush", "random"], "RoomData should expose challenge variant configuration")
	_expect(room_data.get("challenge_variant_label") != null, "RoomData should expose challenge variant label configuration")
	event_shrine.set("event_variant", "overclock_trial")
	event_shrine.set("reward_mode", "temporary_rule")
	_expect(str(event_shrine.get("event_variant")) == "overclock_trial", "EventShrine should expose the Overclock Trial event variant")
	_expect(str(event_shrine.get("reward_mode")) == "temporary_rule", "EventShrine should expose temporary rule rewards")
	event_shrine.set("event_variant", "resonant_statue")
	event_shrine.set("reward_mode", "statue_choice")
	_expect(str(event_shrine.get("event_variant")) == "resonant_statue", "EventShrine should expose the Resonant Statue event variant")
	_expect(str(event_shrine.get("reward_mode")) == "statue_choice", "EventShrine should expose statue choice rewards")
	event_shrine.set("event_variant", "statue_attunement")
	event_shrine.set("reward_mode", "statue_attunement")
	event_shrine.set("statue_attunement_target_id", "echo_reservoir")
	_expect(str(event_shrine.get("event_variant")) == "statue_attunement", "EventShrine should expose the Statue Attunement event variant")
	_expect(str(event_shrine.get("reward_mode")) == "statue_attunement", "EventShrine should expose statue attunement rewards")
	_expect(str(event_shrine.get("statue_attunement_target_id")) == "echo_reservoir", "EventShrine should expose a statue attunement target id")
	_expect(float(event_shrine.get("temporary_rule_duration")) > 0.0, "EventShrine should configure temporary rule duration")
	_expect(float(event_shrine.get("temporary_rule_damage_multiplier_bonus")) > 0.0, "EventShrine should configure temporary rule damage bonus")
	_expect(float(event_shrine.get("temporary_rule_fire_rate_multiplier_bonus")) > 0.0, "EventShrine should configure temporary rule fire-rate bonus")
	_expect(weapon.get("icon_key") != null, "WeaponData should expose an icon key field")
	_expect(relic.get("icon_key") != null, "RelicData should expose an icon key field")
	_expect(character.get("icon_key") != null, "PlayerCharacterData should expose an icon key field")
	_expect(talent.get("icon_key") != null, "TalentData should expose an icon key field")
	_expect(blessing.get("icon_key") != null, "BlessingData should expose an icon key field")
	_expect(int(blessing.get("trigger_interval")) >= 1, "BlessingData should expose a trigger interval field")
	_expect(statue.get("icon_key") != null, "StatueData should expose an icon key field")
	_expect(str(statue.get("trigger_event")) == "on_skill_used", "StatueData should default to skill-use triggers")
	_expect(int(statue.get("trigger_interval")) >= 1, "StatueData should expose a trigger interval field")
	_expect(CONTENT_ICON_REGISTRY_RESOURCE is Resource, "Content icon registry resource should load")
	_expect(CONTENT_ICON_REGISTRY_RESOURCE.get("definitions") is Array, "Content icon registry should expose definition resources")
	_expect(CONTENT_ICON_REGISTRY.get_registered_icon_count() >= 122, "Content icon registry should cover the 40-weapon and 45-relic libraries plus shared content icons")
	for content_type in ["weapon", "relic", "talent", "blessing", "statue", "character", "room"]:
		_expect(CONTENT_ICON_REGISTRY.has_definition_for_type(content_type), "Content icon registry should define %s icons" % content_type)
	_expect(CONTENT_ICON_REGISTRY.get_type_token("weapon_basic_pistol", "weapons") == "WPN", "ContentIconRegistry should resolve weapon icon tokens")
	_expect(CONTENT_ICON_REGISTRY.get_type_token("relic_sharp_rounds", "relics") == "REL", "ContentIconRegistry should resolve relic icon tokens")
	_expect(CONTENT_ICON_REGISTRY.get_type_token("room_reward", "rooms") == "*", "ContentIconRegistry should resolve room icon tokens")
	_expect(CONTENT_ICON_REGISTRY.has_placeholder_icon("talent_steady_hands", "talents"), "ContentIconRegistry should recognize talent placeholder icons")
	_expect(CONTENT_ICON_REGISTRY.get_placeholder_color("blessing_deep_cell", "blessings") != CONTENT_ICON_REGISTRY.FALLBACK_COLOR, "ContentIconRegistry should color known content icon types")
	_expect(CONTENT_ICON_REGISTRY.get_type_token("statue_bulwark_idol", "statues") == "STU", "ContentIconRegistry should resolve statue icon tokens")
	var weapon_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_basic_pistol", "weapons")
	var shotgun_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_shotgun", "weapons")
	var energy_staff_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_energy_staff", "weapons")
	var ricochet_blaster_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_ricochet_blaster", "weapons")
	var arc_blade_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_arc_blade", "weapons")
	var nova_core_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_nova_core", "weapons")
	var blast_launcher_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_blast_launcher", "weapons")
	var laser_lance_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_laser_lance", "weapons")
	var coil_carbine_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_coil_carbine", "weapons")
	var shatter_fan_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_shatter_fan", "weapons")
	var storm_fan_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_storm_fan", "weapons")
	var prism_ray_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_prism_ray", "weapons")
	var halo_kernel_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_halo_kernel", "weapons")
	var ember_sprayer_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_ember_sprayer", "weapons")
	var frost_sickle_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_frost_sickle", "weapons")
	var slag_comet_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_slag_comet", "weapons")
	var guard_cleaver_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_guard_cleaver", "weapons")
	var riposte_saber_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_riposte_saber", "weapons")
	var bulwark_fan_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_bulwark_fan", "weapons")
	var cinder_mortar_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_cinder_mortar", "weapons")
	var coil_bow_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_coil_bow", "weapons")
	var ember_mine_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_ember_mine", "weapons")
	var mirror_sickle_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_mirror_sickle", "weapons")
	var orbit_sower_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_orbit_sower", "weapons")
	var pulse_needler_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_pulse_needler", "weapons")
	var rift_spear_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_rift_spear", "weapons")
	var sentry_seed_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_sentry_seed", "weapons")
	var storm_capacitor_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_storm_capacitor", "weapons")
	var vault_lance_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_vault_lance", "weapons")
	var snare_beacon_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("weapon_snare_beacon", "weapons")
	var relic_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_sharp_rounds", "relics")
	var anchor_spool_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_anchor_spool", "relics")
	var quick_trigger_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_quick_trigger", "relics")
	var split_chamber_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_split_chamber", "relics")
	var phase_tip_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_phase_tip", "relics")
	var vampire_fang_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_vampire_fang", "relics")
	var guardian_ward_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_guardian_ward", "relics")
	var adrenaline_charm_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_adrenaline_charm", "relics")
	var lucky_primer_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_lucky_primer", "relics")
	var swift_loader_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_swift_loader", "relics")
	var keen_sights_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_keen_sights", "relics")
	var hollow_needle_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_hollow_needle", "relics")
	var scatter_lens_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_scatter_lens", "relics")
	var field_rations_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_field_rations", "relics")
	var bulwark_plate_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_bulwark_plate", "relics")
	var redline_boots_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_redline_boots", "relics")
	var breach_powder_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_breach_powder", "relics")
	var momentum_coil_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_momentum_coil", "relics")
	var steady_capacitor_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_steady_capacitor", "relics")
	var gilded_tip_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_gilded_tip", "relics")
	var echo_chamber_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_echo_chamber", "relics")
	var breakwater_guard_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_breakwater_guard", "relics")
	var siphon_clasp_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_siphon_clasp", "relics")
	var kinetic_ram_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_kinetic_ram", "relics")
	var volatile_oil_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_volatile_oil", "relics")
	var ember_catalyst_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_ember_catalyst", "relics")
	var lingering_ash_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_lingering_ash", "relics")
	var parry_grip_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_parry_grip", "relics")
	var warding_hinge_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_warding_hinge", "relics")
	var counterweight_core_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_counterweight_core", "relics")
	var draw_weight_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_draw_weight", "relics")
	var quick_windup_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_quick_windup", "relics")
	var stored_spark_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_stored_spark", "relics")
	var tripwire_amplifier_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_tripwire_amplifier", "relics")
	var heart_core_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("relic_heart_core", "relics")
	var talent_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("talent_steady_hands", "talents")
	var iron_vow_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("talent_iron_vow", "talents")
	var kinetic_rounds_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("talent_kinetic_rounds", "talents")
	var blessing_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("blessing_deep_cell", "blessings")
	var quiet_plate_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("blessing_quiet_plate", "blessings")
	var ember_tithe_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("blessing_ember_tithe", "blessings")
	var afterglow_circuit_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("blessing_afterglow_circuit", "blessings")
	var spark_dividend_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("blessing_spark_dividend", "blessings")
	var brace_current_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("blessing_brace_current", "blessings")
	var resonance_battery_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("blessing_resonance_battery", "blessings")
	var character_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("character_wanderer", "characters")
	var warden_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("character_warden", "characters")
	var arcanist_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("character_arcanist", "characters")
	var rift_runner_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("character_rift_runner", "characters")
	var emberwright_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("character_emberwright", "characters")
	var field_medic_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("character_field_medic", "characters")
	var room_start_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("room_start", "rooms")
	var room_combat_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("room_combat", "rooms")
	var room_elite_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("room_elite", "rooms")
	var room_challenge_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("room_challenge", "rooms")
	var room_trap_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("room_trap", "rooms")
	var room_reward_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("room_reward", "rooms")
	var room_event_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("room_event", "rooms")
	var room_armory_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("room_armory", "rooms")
	var room_healing_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("room_healing", "rooms")
	var room_shop_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("room_shop", "rooms")
	var room_boss_icon_path := CONTENT_ICON_REGISTRY.get_texture_path("room_boss", "rooms")
	var default_icon_prefix := "res:" + "//art/ui/content_icons/default_"
	var item_icon_paths := {
		"weapon_basic_pistol": weapon_icon_path,
		"weapon_shotgun": shotgun_icon_path,
		"weapon_energy_staff": energy_staff_icon_path,
		"weapon_ricochet_blaster": ricochet_blaster_icon_path,
		"weapon_arc_blade": arc_blade_icon_path,
		"weapon_nova_core": nova_core_icon_path,
		"weapon_blast_launcher": blast_launcher_icon_path,
		"weapon_laser_lance": laser_lance_icon_path,
		"weapon_coil_carbine": coil_carbine_icon_path,
		"weapon_shatter_fan": shatter_fan_icon_path,
		"weapon_storm_fan": storm_fan_icon_path,
		"weapon_prism_ray": prism_ray_icon_path,
		"weapon_halo_kernel": halo_kernel_icon_path,
		"weapon_ember_sprayer": ember_sprayer_icon_path,
		"weapon_frost_sickle": frost_sickle_icon_path,
		"weapon_slag_comet": slag_comet_icon_path,
		"weapon_guard_cleaver": guard_cleaver_icon_path,
		"weapon_riposte_saber": riposte_saber_icon_path,
		"weapon_bulwark_fan": bulwark_fan_icon_path,
		"weapon_cinder_mortar": cinder_mortar_icon_path,
		"weapon_coil_bow": coil_bow_icon_path,
		"weapon_ember_mine": ember_mine_icon_path,
		"weapon_mirror_sickle": mirror_sickle_icon_path,
		"weapon_orbit_sower": orbit_sower_icon_path,
		"weapon_pulse_needler": pulse_needler_icon_path,
		"weapon_rift_spear": rift_spear_icon_path,
		"weapon_sentry_seed": sentry_seed_icon_path,
		"weapon_storm_capacitor": storm_capacitor_icon_path,
		"weapon_vault_lance": vault_lance_icon_path,
		"weapon_snare_beacon": snare_beacon_icon_path,
		"relic_sharp_rounds": relic_icon_path,
		"relic_anchor_spool": anchor_spool_icon_path,
		"relic_quick_trigger": quick_trigger_icon_path,
		"relic_split_chamber": split_chamber_icon_path,
		"relic_phase_tip": phase_tip_icon_path,
		"relic_vampire_fang": vampire_fang_icon_path,
		"relic_guardian_ward": guardian_ward_icon_path,
		"relic_adrenaline_charm": adrenaline_charm_icon_path,
		"relic_lucky_primer": lucky_primer_icon_path,
		"relic_swift_loader": swift_loader_icon_path,
		"relic_keen_sights": keen_sights_icon_path,
		"relic_hollow_needle": hollow_needle_icon_path,
		"relic_scatter_lens": scatter_lens_icon_path,
		"relic_field_rations": field_rations_icon_path,
		"relic_bulwark_plate": bulwark_plate_icon_path,
		"relic_redline_boots": redline_boots_icon_path,
		"relic_breach_powder": breach_powder_icon_path,
		"relic_momentum_coil": momentum_coil_icon_path,
		"relic_steady_capacitor": steady_capacitor_icon_path,
		"relic_gilded_tip": gilded_tip_icon_path,
		"relic_echo_chamber": echo_chamber_icon_path,
		"relic_breakwater_guard": breakwater_guard_icon_path,
		"relic_siphon_clasp": siphon_clasp_icon_path,
		"relic_kinetic_ram": kinetic_ram_icon_path,
		"relic_volatile_oil": volatile_oil_icon_path,
		"relic_ember_catalyst": ember_catalyst_icon_path,
		"relic_lingering_ash": lingering_ash_icon_path,
		"relic_parry_grip": parry_grip_icon_path,
		"relic_warding_hinge": warding_hinge_icon_path,
		"relic_counterweight_core": counterweight_core_icon_path,
		"relic_draw_weight": draw_weight_icon_path,
		"relic_quick_windup": quick_windup_icon_path,
		"relic_stored_spark": stored_spark_icon_path,
		"relic_tripwire_amplifier": tripwire_amplifier_icon_path,
		"relic_heart_core": heart_core_icon_path,
		"talent_steady_hands": talent_icon_path,
		"talent_iron_vow": iron_vow_icon_path,
		"talent_kinetic_rounds": kinetic_rounds_icon_path,
		"blessing_deep_cell": blessing_icon_path,
		"blessing_quiet_plate": quiet_plate_icon_path,
		"blessing_ember_tithe": ember_tithe_icon_path,
		"blessing_afterglow_circuit": afterglow_circuit_icon_path,
		"blessing_spark_dividend": spark_dividend_icon_path,
		"blessing_brace_current": brace_current_icon_path,
		"blessing_resonance_battery": resonance_battery_icon_path,
		"character_wanderer": character_icon_path,
		"character_warden": warden_icon_path,
		"character_arcanist": arcanist_icon_path,
		"character_rift_runner": rift_runner_icon_path,
		"character_emberwright": emberwright_icon_path,
		"character_field_medic": field_medic_icon_path,
		"room_start": room_start_icon_path,
		"room_combat": room_combat_icon_path,
		"room_elite": room_elite_icon_path,
		"room_challenge": room_challenge_icon_path,
		"room_trap": room_trap_icon_path,
		"room_reward": room_reward_icon_path,
		"room_event": room_event_icon_path,
		"room_armory": room_armory_icon_path,
		"room_healing": room_healing_icon_path,
		"room_shop": room_shop_icon_path,
		"room_boss": room_boss_icon_path,
	}
	for icon_key in [
		"weapon_quench_repeater",
		"weapon_furnace_scattergun",
		"weapon_bastion_saw",
		"weapon_rift_bloom",
		"weapon_thunder_nest",
		"weapon_compass_needle",
		"weapon_relay_arc",
		"weapon_lantern_swarm",
		"weapon_undertow_volley",
		"weapon_stormglass_rail",
	]:
		item_icon_paths[icon_key] = CONTENT_ICON_REGISTRY.get_texture_path(icon_key, "weapons")
	for icon_key in [
		"relic_ricochet_gyro",
		"relic_blast_radius_gauge",
		"relic_kinetic_bridle",
		"relic_reserve_drum",
		"relic_flux_reservoir",
		"relic_tracking_vane",
		"relic_longview_array",
		"relic_forked_bus",
		"relic_conduction_mesh",
		"relic_stormglass_filament",
	]:
		item_icon_paths[icon_key] = CONTENT_ICON_REGISTRY.get_texture_path(icon_key, "relics")
	for icon_key in item_icon_paths.keys():
		var icon_path := str(item_icon_paths.get(icon_key, ""))
		_expect(icon_path.begins_with("res:" + "//art/ui/content_icons/"), "Content icon registry should point item icons at art/ui/content_icons: %s" % icon_path)
		_expect(not icon_path.begins_with(default_icon_prefix), "Content icon registry should use an item-specific icon for %s" % icon_key)
		_expect(ResourceLoader.exists(icon_path), "Content item icon texture path should resolve: %s" % icon_path)
	for icon_path in [
		CONTENT_ICON_REGISTRY.get_texture_path("character_unmapped_probe", "characters"),
		CONTENT_ICON_REGISTRY.get_texture_path("relic_unmapped_probe", "relics"),
		CONTENT_ICON_REGISTRY.get_texture_path("weapon_unmapped_probe", "weapons"),
		CONTENT_ICON_REGISTRY.get_texture_path("room_unmapped_probe", "rooms"),
	]:
		_expect(str(icon_path).begins_with(default_icon_prefix), "Content icon registry should point default icons at art/ui/content_icons: %s" % str(icon_path))
		_expect(ResourceLoader.exists(str(icon_path)), "Content icon texture path should resolve: %s" % str(icon_path))
	_expect(CONTENT_ICON_REGISTRY.get_atlas_region("weapon_basic_pistol", "weapons") == Rect2i(0, 0, 0, 0), "Content icon registry should expose atlas region placeholders")
	_expect(str(talent.get("duration_scope")) == "run", "TalentData should default to run-scoped effects")
	_expect(str(blessing.get("duration_scope")) == "run", "BlessingData should default to run-scoped effects")
	_expect(float(elite_modifier.get("health_multiplier")) >= 1.0, "EliteModifierData should support health multipliers")


func _verify_weapons() -> void:
	var weapons := _load_resources(WEAPON_DIR)
	var ids := {}
	_expect(weapons.size() >= 40, "Weapon library should reach the 40-weapon v1 content target")
	for weapon in weapons:
		var id := str(weapon.get("id"))
		_expect(not id.is_empty(), "Weapon should define id")
		_expect(not ids.has(id), "Weapon id should be unique: %s" % id)
		ids[id] = true
		_expect(_resolve_content_icon_key(weapon, "weapon").begins_with("weapon_"), "Weapon %s should resolve a weapon icon key" % id)
		var weapon_tags := weapon.get("tags") as PackedStringArray
		_expect(not str(weapon.get("display_name")).is_empty(), "Weapon %s should define display name" % id)
		_expect(not str(weapon.get("description")).is_empty(), "Weapon %s should define description" % id)
		_expect(not str(weapon.get("rarity")).is_empty(), "Weapon %s should define rarity" % id)
		_expect(not str(weapon.get("weapon_class")).is_empty(), "Weapon %s should define weapon class" % id)
		_expect(not str(weapon.get("recommended_range")).is_empty(), "Weapon %s should define recommended range" % id)
		_expect(float(weapon.get("drop_weight")) >= 0.0, "Weapon %s should define non-negative drop weight" % id)
		_expect(float(weapon.get("aim_assist_priority")) > 0.0, "Weapon %s should define aim-assist priority" % id)
		_expect(not str(weapon.get("content_role")).is_empty(), "Weapon %s should define content role" % id)
		_expect(weapon_tags.size() >= 2, "Weapon %s should keep at least two tags" % id)
		var fire_mode := str(weapon.get("fire_mode"))
		var status_effect := str(weapon.get("status_effect"))
		var status_chance := float(weapon.get("status_chance"))
		var status_duration := float(weapon.get("status_duration"))
		var status_damage_per_tick := int(weapon.get("status_damage_per_tick"))
		var status_tick_interval := float(weapon.get("status_tick_interval"))
		var status_slow_multiplier := float(weapon.get("status_slow_multiplier"))
		var blocks_projectiles := bool(weapon.get("blocks_projectiles"))
		var block_radius := float(weapon.get("projectile_block_radius"))
		var block_arc := float(weapon.get("projectile_block_arc_degrees"))
		var block_damage := int(weapon.get("projectile_block_damage"))
		var charge_duration := float(weapon.get("charge_duration"))
		var charge_damage_multiplier := float(weapon.get("charge_damage_multiplier"))
		var charge_projectile_speed_multiplier := float(weapon.get("charge_projectile_speed_multiplier"))
		var charge_projectile_count_bonus := int(weapon.get("charge_projectile_count_bonus"))
		var homing_turn_rate := float(weapon.get("homing_turn_rate"))
		var homing_radius := float(weapon.get("homing_radius"))
		var chain_count := int(weapon.get("chain_count"))
		var chain_radius := float(weapon.get("chain_radius"))
		var chain_damage_multiplier := float(weapon.get("chain_damage_multiplier"))
		var deployable_duration := float(weapon.get("deployable_duration"))
		var deployable_radius := float(weapon.get("deployable_radius"))
		var deployable_tick_interval := float(weapon.get("deployable_tick_interval"))
		var deployable_damage_multiplier := float(weapon.get("deployable_damage_multiplier"))
		var deployable_behavior := str(weapon.get("deployable_behavior"))
		_expect(SUPPORTED_FIRE_MODES.has(fire_mode), "Weapon %s should use a supported fire mode" % id)
		_expect(SUPPORTED_STATUS_EFFECTS.has(status_effect), "Weapon %s should use a supported status effect" % id)
		_expect(status_chance >= 0.0 and status_chance <= 1.0, "Weapon %s should keep status chance in range" % id)
		if status_effect != "none":
			_expect(status_chance > 0.0, "Weapon %s status effect should have positive chance" % id)
			_expect(status_duration > 0.0, "Weapon %s status effect should have positive duration" % id)
			_expect(weapon_tags.has(status_effect) or weapon_tags.has("elemental"), "Weapon %s status effect should be represented in tags" % id)
			match status_effect:
				"burn":
					_expect(status_damage_per_tick > 0, "Burn weapon %s should define tick damage" % id)
					_expect(status_tick_interval > 0.0, "Burn weapon %s should define tick interval" % id)
				"slow":
					_expect(status_slow_multiplier > 0.0 and status_slow_multiplier < 1.0, "Slow weapon %s should define a movement slow" % id)
		if blocks_projectiles:
			_expect(fire_mode == "melee", "Projectile-blocking weapon %s should currently use melee mode" % id)
			_expect(block_radius > 0.0, "Projectile-blocking weapon %s should define block radius" % id)
			_expect(block_arc > 0.0 and block_arc <= 360.0, "Projectile-blocking weapon %s should define valid block arc" % id)
			_expect(block_damage >= 0, "Projectile-blocking weapon %s should define non-negative counter damage" % id)
			_expect(weapon_tags.has("guard"), "Projectile-blocking weapon %s should expose guard tag" % id)
		if fire_mode == "charge":
			_expect(charge_duration > 0.0, "Charge weapon %s should define charge duration" % id)
			_expect(charge_damage_multiplier >= 1.0, "Charge weapon %s should not reduce charged damage" % id)
			_expect(charge_projectile_speed_multiplier > 0.0, "Charge weapon %s should define projectile speed multiplier" % id)
			_expect(charge_projectile_count_bonus >= 0, "Charge weapon %s should define non-negative charge projectile bonus" % id)
			_expect(weapon_tags.has("charge"), "Charge weapon %s should expose charge tag" % id)
		if homing_turn_rate > 0.0 or homing_radius > 0.0:
			_expect(homing_turn_rate > 0.0, "Homing weapon %s should define positive turn rate" % id)
			_expect(homing_radius > 0.0, "Homing weapon %s should define positive acquisition radius" % id)
			_expect(weapon_tags.has("homing"), "Homing weapon %s should expose homing tag" % id)
		if chain_count > 0 or chain_radius > 0.0:
			_expect(chain_count > 0, "Chain weapon %s should define at least one extra target" % id)
			_expect(chain_radius > 0.0, "Chain weapon %s should define positive bridge radius" % id)
			_expect(chain_damage_multiplier > 0.0, "Chain weapon %s should define positive chained damage" % id)
			_expect(weapon_tags.has("chain"), "Chain weapon %s should expose chain tag" % id)
		if fire_mode == "deployable":
			_expect(SUPPORTED_DEPLOYABLE_BEHAVIORS.has(deployable_behavior), "Deployable weapon %s should use a supported behavior" % id)
			_expect(deployable_duration > 0.0, "Deployable weapon %s should define duration" % id)
			_expect(deployable_radius > 0.0, "Deployable weapon %s should define radius" % id)
			_expect(deployable_tick_interval > 0.0, "Deployable weapon %s should define tick interval" % id)
			_expect(deployable_damage_multiplier > 0.0, "Deployable weapon %s should define damage multiplier" % id)
			_expect(weapon_tags.has("deployable"), "Deployable weapon %s should expose deployable tag" % id)
			match deployable_behavior:
				"mine":
					_expect(weapon_tags.has("trap"), "Mine weapon %s should expose trap tag" % id)
				"sentry":
					_expect(weapon_tags.has("summon"), "Sentry weapon %s should expose summon tag" % id)
				"field":
					_expect(weapon_tags.has("control"), "Field weapon %s should expose control tag" % id)
	for required_id in REQUIRED_WEAPON_IDS:
		_expect(ids.has(required_id), "Weapon library should include %s" % required_id)


func _verify_relics() -> void:
	var relics := _load_resources(RELIC_DIR)
	var ids := {}
	_expect(relics.size() >= 45, "Relic library should reach the 45-relic v1 content target")
	for relic in relics:
		var id := str(relic.get("id"))
		_expect(not id.is_empty(), "Relic should define id")
		_expect(not ids.has(id), "Relic id should be unique: %s" % id)
		ids[id] = true
		_expect(_resolve_content_icon_key(relic, "relic").begins_with("relic_"), "Relic %s should resolve a relic icon key" % id)
		_expect(not str(relic.get("display_name")).is_empty(), "Relic %s should define display name" % id)
		_expect(not str(relic.get("description")).is_empty(), "Relic %s should define description" % id)
		_expect(not str(relic.get("rarity")).is_empty(), "Relic %s should define rarity" % id)
		_expect(not str(relic.get("trigger_event")).is_empty(), "Relic %s should define trigger event" % id)
		_expect(not str(relic.get("effect_type")).is_empty(), "Relic %s should define effect type" % id)
		_expect(float(relic.get("drop_weight")) > 0.0, "Relic %s should define positive drop weight" % id)
		_expect(not str(relic.get("description_value_template")).is_empty(), "Relic %s should define description value template" % id)
		var build_tags := relic.get("build_tags") as PackedStringArray
		_expect(build_tags.size() >= 1, "Relic %s should define build tags" % id)
		_expect((relic.get("tags") as PackedStringArray).size() >= 2, "Relic %s should keep at least two display tags" % id)
		if str(relic.get("effect_type")).begins_with("charge_"):
			_expect(build_tags.has("charge"), "Charge relic %s should expose charge build tag" % id)
		if str(relic.get("effect_type")).begins_with("deployable_"):
			_expect(build_tags.has("deployable"), "Deployable relic %s should expose deployable build tag" % id)
		match str(relic.get("effect_type")):
			"bounce_count_bonus":
				_expect(build_tags.has("bounce"), "Bounce relic %s should expose bounce build tag" % id)
			"explosion_radius_bonus":
				_expect(build_tags.has("explosive"), "Explosion relic %s should expose explosive build tag" % id)
			"knockback_multiplier":
				_expect(build_tags.has("control"), "Knockback relic %s should expose control build tag" % id)
			"magazine_size_bonus":
				_expect(build_tags.has("ammo"), "Magazine relic %s should expose ammo build tag" % id)
			"max_energy":
				_expect(build_tags.has("energy"), "Maximum-energy relic %s should expose energy build tag" % id)
			"homing_turn_rate_bonus", "homing_radius_bonus":
				_expect(build_tags.has("homing"), "Homing relic %s should expose homing build tag" % id)
			"chain_count_bonus", "chain_radius_bonus", "chain_damage_multiplier":
				_expect(build_tags.has("chain"), "Chain relic %s should expose chain build tag" % id)
	for required_id in REQUIRED_RELIC_IDS:
		_expect(ids.has(required_id), "Relic library should include %s" % required_id)


func _verify_characters() -> void:
	var characters := _load_resources(CHARACTER_DIR)
	var weapon_ids := _resource_id_lookup(_load_resources(WEAPON_DIR))
	var ids := {}
	_expect(characters.size() >= 6, "Character library should include Alpha-facing character pool")
	for character in characters:
		var id := str(character.get("id"))
		_expect(not id.is_empty(), "Character should define id")
		_expect(not ids.has(id), "Character id should be unique: %s" % id)
		ids[id] = true
		_expect(_resolve_content_icon_key(character, "character").begins_with("character_"), "Character %s should resolve a character icon key" % id)
		_expect(not str(character.get("display_name")).is_empty(), "Character %s should define display name" % id)
		_expect(not str(character.get("description")).is_empty(), "Character %s should define description" % id)
		_expect(not str(character.get("unlock_condition")).is_empty(), "Character %s should define unlock condition" % id)
		_expect(int(character.get("meta_currency_unlock_cost")) >= 0, "Character %s should define non-negative meta unlock cost" % id)
		var starting_weapon_ids := character.get("starting_weapon_ids") as PackedStringArray
		var unique_starting_weapon_ids := {}
		_expect(starting_weapon_ids.size() >= 1, "Character %s should define starting weapon ids" % id)
		for weapon_id in starting_weapon_ids:
			var weapon_id_text := str(weapon_id).strip_edges()
			_expect(not weapon_id_text.is_empty(), "Character %s starting weapon id should not be empty" % id)
			_expect(not unique_starting_weapon_ids.has(weapon_id_text), "Character %s should not duplicate starting weapon %s" % [id, weapon_id_text])
			unique_starting_weapon_ids[weapon_id_text] = true
			_expect(weapon_ids.has(weapon_id_text), "Character %s starting weapon should exist: %s" % [id, weapon_id_text])
		_expect(not str(character.get("passive_id")).is_empty(), "Character %s should define passive id" % id)
		_expect(not str(character.get("passive_description")).is_empty(), "Character %s should define passive description" % id)
		_expect((character.get("role_tags") as PackedStringArray).size() >= 2, "Character %s should define role tags" % id)
		_expect(not str(character.get("hall_summary")).is_empty(), "Character %s should define hall summary" % id)
		_expect(int(character.get("upgrade_slots")) >= 1, "Character %s should expose upgrade slots" % id)
		_expect(int(character.get("mastery_level_2_xp")) > 0, "Character %s should define mastery level 2 threshold" % id)
		_expect(int(character.get("mastery_level_3_xp")) > int(character.get("mastery_level_2_xp")), "Character %s should define increasing mastery thresholds" % id)
	for required_id in REQUIRED_CHARACTER_IDS:
		_expect(ids.has(required_id), "Character library should include %s" % required_id)


func _verify_talents() -> void:
	var talents := _load_resources(TALENT_DIR)
	var ids := {}
	_expect(talents.size() >= 3, "Talent library should include current first-pass talent pool")
	for talent in talents:
		var id := str(talent.get("id"))
		_expect(not id.is_empty(), "Talent should define id")
		_expect(not ids.has(id), "Talent id should be unique: %s" % id)
		ids[id] = true
		_expect(_resolve_content_icon_key(talent, "talent").begins_with("talent_"), "Talent %s should resolve a talent icon key" % id)
		_expect(not str(talent.get("display_name")).is_empty(), "Talent %s should define display name" % id)
		_expect(not str(talent.get("description")).is_empty(), "Talent %s should define description" % id)
		_expect(not str(talent.get("rarity")).is_empty(), "Talent %s should define rarity" % id)
		_expect(str(talent.get("duration_scope")) == "run", "Talent %s should currently be run-scoped" % id)
		_expect(str(talent.get("trigger_event")) == "passive", "Talent %s should use passive first-pass effects" % id)
		_expect(not str(talent.get("effect_type")).is_empty(), "Talent %s should define effect type" % id)
		_expect(float(talent.get("drop_weight")) > 0.0, "Talent %s should define positive drop weight" % id)
		_expect((talent.get("build_tags") as PackedStringArray).size() >= 1, "Talent %s should define build tags" % id)


func _verify_blessings() -> void:
	var blessings := _load_resources(BLESSING_DIR)
	var ids := {}
	var event_driven_count := 0
	_expect(blessings.size() >= 7, "Blessing library should include passive, event-driven, and statue-linked blessing pool")
	for blessing in blessings:
		var id := str(blessing.get("id"))
		_expect(not id.is_empty(), "Blessing should define id")
		_expect(not ids.has(id), "Blessing id should be unique: %s" % id)
		ids[id] = true
		_expect(_resolve_content_icon_key(blessing, "blessing").begins_with("blessing_"), "Blessing %s should resolve a blessing icon key" % id)
		_expect(not str(blessing.get("display_name")).is_empty(), "Blessing %s should define display name" % id)
		_expect(not str(blessing.get("description")).is_empty(), "Blessing %s should define description" % id)
		_expect(not str(blessing.get("rarity")).is_empty(), "Blessing %s should define rarity" % id)
		_expect(str(blessing.get("duration_scope")) == "run", "Blessing %s should currently be run-scoped" % id)
		var trigger_event := str(blessing.get("trigger_event"))
		_expect(trigger_event in ["passive", "on_room_clear", "on_kill", "on_hurt", "on_statue_triggered"], "Blessing %s should use a supported first-pass trigger event" % id)
		if trigger_event != "passive":
			event_driven_count += 1
		_expect(int(blessing.get("trigger_interval")) >= 1, "Blessing %s should define a positive trigger interval" % id)
		_expect(not str(blessing.get("effect_type")).is_empty(), "Blessing %s should define effect type" % id)
		_expect(float(blessing.get("drop_weight")) > 0.0, "Blessing %s should define positive drop weight" % id)
		_expect((blessing.get("build_tags") as PackedStringArray).size() >= 1, "Blessing %s should define build tags" % id)
		_expect(not str(blessing.get("rule_text")).is_empty(), "Blessing %s should define rule text" % id)
	for required_id in REQUIRED_BLESSING_IDS:
		_expect(ids.has(required_id), "Blessing library should include %s" % required_id)
	_expect(event_driven_count >= 1, "Blessing library should include at least one event-driven blessing")


func _verify_statues() -> void:
	var statues := _load_resources(STATUE_DIR)
	var ids := {}
	_expect(statues.size() >= 3, "Statue library should include a first-pass skill-linked statue pool")
	for statue in statues:
		var id := str(statue.get("id"))
		_expect(not id.is_empty(), "Statue should define id")
		_expect(not ids.has(id), "Statue id should be unique: %s" % id)
		ids[id] = true
		_expect(_resolve_content_icon_key(statue, "statue").begins_with("statue_"), "Statue %s should resolve a statue icon key" % id)
		_expect(not str(statue.get("display_name")).is_empty(), "Statue %s should define display name" % id)
		_expect(not str(statue.get("description")).is_empty(), "Statue %s should define description" % id)
		_expect(not str(statue.get("rarity")).is_empty(), "Statue %s should define rarity" % id)
		_expect(str(statue.get("duration_scope")) == "run", "Statue %s should currently be run-scoped" % id)
		_expect(str(statue.get("trigger_event")) == "on_skill_used", "Statue %s should trigger on skill use" % id)
		_expect(int(statue.get("trigger_interval")) >= 1, "Statue %s should define a positive trigger interval" % id)
		_expect(not str(statue.get("effect_type")).is_empty(), "Statue %s should define effect type" % id)
		_expect(float(statue.get("drop_weight")) > 0.0, "Statue %s should define positive drop weight" % id)
		_expect((statue.get("build_tags") as PackedStringArray).size() >= 1, "Statue %s should define build tags" % id)
		_expect(not str(statue.get("rule_text")).is_empty(), "Statue %s should define rule text" % id)
	for required_id in REQUIRED_STATUE_IDS:
		_expect(ids.has(required_id), "Statue library should include %s" % required_id)


func _verify_enemy_scenes() -> void:
	var scenes := _load_scenes(ENEMY_SCENE_DIR)
	var display_names := {}
	var ordinary_enemy_count := 0
	for scene in scenes:
		if scene.resource_path.get_file().get_basename() == "Enemy":
			continue
		var instance := scene.instantiate()
		_expect(instance != null, "%s should instantiate" % scene.resource_path)
		if instance == null:
			continue

		if instance is Enemy:
			ordinary_enemy_count += 1
			var display_name := str(instance.get("display_name"))
			_expect(not display_name.is_empty(), "%s should define display name" % scene.resource_path)
			_expect(not display_names.has(display_name), "Enemy display name should be unique: %s" % display_name)
			display_names[display_name] = true
			_expect(int(instance.get("max_health")) > 0, "%s should define positive health" % display_name)
			_expect(float(instance.get("move_speed")) >= 0.0, "%s should define non-negative move speed" % display_name)
			_expect(int(instance.get("contact_damage")) >= 0, "%s should define non-negative contact damage" % display_name)
			var behavior_type := int(instance.get("behavior_type"))
			_expect(behavior_type >= 0 and behavior_type <= 8, "%s should use a supported behavior type" % display_name)
			if behavior_type == 1 or behavior_type == 6:
				_expect(instance.get("projectile_scene") is PackedScene, "%s shooter behavior should define projectile scene" % display_name)
				_expect(int(instance.get("projectile_count")) >= 1, "%s projectile behavior should define projectile count" % display_name)
			if behavior_type == 3:
				_expect(float(instance.get("self_destruct_radius")) > 0.0, "%s bomber behavior should define blast radius" % display_name)
			if behavior_type == 4:
				_expect(instance.get("summon_scene") is PackedScene, "%s summoner behavior should define summon scene" % display_name)
			if behavior_type >= 0:
				var action_sprite := instance.get_node_or_null("ActionSprite") as Sprite2D
				_expect(action_sprite != null and action_sprite.texture != null, "%s key-action enemy should define an action sprite atlas" % display_name)
				if action_sprite != null and action_sprite.texture != null:
					_expect(action_sprite.hframes == 2 and action_sprite.vframes == 2, "%s action atlas should expose four equal frames" % display_name)
					_expect(action_sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "%s action atlas should use nearest-neighbor filtering" % display_name)
					var texture_size := action_sprite.texture.get_size()
					_expect(texture_size.x == texture_size.y and int(texture_size.x) % 2 == 0, "%s action atlas should be an even square texture" % display_name)
					var world_frame_size := texture_size.x * absf(action_sprite.scale.x) * 0.5
					_expect(world_frame_size >= 60.0 and world_frame_size <= 65.0, "%s action atlas should render near the shared 64px frame contract" % display_name)
			if behavior_type == 7:
				_expect(float(instance.get("zone_warning_radius")) > 0.0, "%s zoner behavior should define warning radius" % display_name)
				_expect(float(instance.get("zone_warning_duration")) > 0.0, "%s zoner behavior should define warning duration" % display_name)
			if behavior_type == 8:
				_expect(float(instance.get("support_range")) > 0.0, "%s support behavior should define support range" % display_name)
				_expect(int(instance.get("support_heal_amount")) > 0, "%s support behavior should define heal amount" % display_name)
			if int(instance.get("death_spawn_count")) > 0:
				_expect(instance.get("death_spawn_scene") is PackedScene, "%s death spawn should define spawn scene" % display_name)

		instance.free()

	_expect(ordinary_enemy_count >= 18, "Enemy scene library should reach the Alpha lower-bound ordinary enemy count")
	for required_name in REQUIRED_ENEMY_DISPLAY_NAMES:
		_expect(display_names.has(required_name), "Enemy scene library should include %s" % required_name)


func _verify_elite_modifiers() -> void:
	var profiles := _load_resources(ELITE_MODIFIER_DIR)
	var ids := {}
	var visual_patterns := {}
	var combat_traits := {}
	_expect(profiles.size() >= 6, "Elite modifier library should include the Alpha lower-bound modifier pool")
	for profile in profiles:
		var id := str(profile.get("id"))
		_expect(not id.is_empty(), "Elite modifier should define id")
		_expect(not ids.has(id), "Elite modifier id should be unique: %s" % id)
		ids[id] = true
		_expect(not str(profile.get("display_name")).is_empty(), "Elite modifier %s should define display name" % id)
		_expect(not str(profile.get("name_prefix")).is_empty(), "Elite modifier %s should define name prefix" % id)
		_expect(not str(profile.get("description")).is_empty(), "Elite modifier %s should define description" % id)
		_expect((profile.get("role_tags") as PackedStringArray).size() >= 1, "Elite modifier %s should define role tags" % id)
		_expect(float(profile.get("health_multiplier")) > 1.0, "Elite modifier %s should increase health" % id)
		_expect(float(profile.get("damage_multiplier")) >= 1.0, "Elite modifier %s should define damage multiplier" % id)
		_expect(float(profile.get("move_speed_multiplier")) > 0.0, "Elite modifier %s should define movement multiplier" % id)
		_expect(float(profile.get("attack_cooldown_multiplier")) > 0.0, "Elite modifier %s should define attack cooldown multiplier" % id)
		_expect(float(profile.get("projectile_speed_multiplier")) > 0.0, "Elite modifier %s should define projectile speed multiplier" % id)
		_expect(int(profile.get("death_explosion_damage")) >= 0, "Elite modifier %s should define non-negative death damage" % id)
		_expect(profile.get("visual_color") is Color, "Elite modifier %s should define visual color" % id)
		var visual_pattern := str(profile.get("visual_pattern"))
		_expect(not visual_pattern.is_empty() and visual_pattern != "ring", "Elite modifier %s should define a dedicated visual pattern" % id)
		_expect(not visual_patterns.has(visual_pattern), "Elite visual pattern should be unique: %s" % visual_pattern)
		visual_patterns[visual_pattern] = true
		_expect(float(profile.get("aura_radius")) >= 28.0, "Elite modifier %s should define a readable aura radius" % id)
		_expect(float(profile.get("pulse_speed")) > 0.0, "Elite modifier %s should define animated pulse speed" % id)
		var combat_trait := str(profile.get("combat_trait"))
		_expect(not combat_trait.is_empty() and combat_trait != "none", "Elite modifier %s should define a combat trait" % id)
		_expect(not combat_traits.has(combat_trait), "Elite combat trait should be unique: %s" % combat_trait)
		combat_traits[combat_trait] = true
		_expect(float(profile.get("trait_windup")) >= 0.25, "Elite modifier %s should define readable trait windup" % id)
		_expect(float(profile.get("trait_radius")) >= 72.0, "Elite modifier %s should define readable trait radius" % id)
		_expect(float(profile.get("trait_strength")) > 0.0, "Elite modifier %s should define positive trait strength" % id)
		if combat_trait == "scorch_pulse" or combat_trait == "overclock":
			_expect(float(profile.get("trait_interval")) >= 3.0, "Elite modifier %s active trait should define a safe repeat interval" % id)
		if combat_trait == "overclock":
			_expect(float(profile.get("trait_duration")) >= 0.8, "Quickened overclock should define an observable active window")
		_expect(float(profile.get("scale_multiplier")) >= 1.0, "Elite modifier %s should define scale multiplier" % id)
	for required_id in REQUIRED_ELITE_MODIFIER_IDS:
		_expect(ids.has(required_id), "Elite modifier library should include %s" % required_id)


func _verify_biomes() -> void:
	var biomes := _load_resources(BIOME_DIR)
	var boss_names := {}
	var expected_boss_names := {
		"outer_warrens": "Warrens Gatekeeper",
		"iron_catacombs": "Iron Bulwark",
		"void_foundry": "Void Foundry Heart",
	}
	var expected_boss_signatures := {
		"outer_warrens": "pincer_gates",
		"iron_catacombs": "bastion_lock",
		"void_foundry": "void_bloom",
	}
	var expected_phase_two_attacks := {
		"outer_warrens": "warren_sweep",
		"iron_catacombs": "iron_quake",
		"void_foundry": "rift_cross",
	}
	var expected_layout_ids := {
		"outer_warrens": ["crossfire", "open_cross", "corner_nests", "wide_arena"],
		"iron_catacombs": ["bunker", "narrow_gap", "split_cover", "center_ring"],
		"void_foundry": ["ambush_corners", "box_maze", "long_lane", "twin_islands"],
	}
	var expected_reward_multipliers := {
		"outer_warrens": 1.0,
		"iron_catacombs": 1.08,
		"void_foundry": 1.16,
	}
	var color_keys := {}
	var floor_texture_paths := {}
	var surface_atlas_paths := {}
	var reward_multiplier_by_index := {}
	_expect(biomes.size() >= 3, "Biome library should include three Alpha-facing biome resources")
	for biome in biomes:
		var id := str(biome.get("id"))
		_expect(expected_boss_names.has(id), "Biome %s should be part of the standard three-biome route" % id)
		_expect(not str(biome.get("display_name")).is_empty(), "Biome %s should define display name" % id)
		_expect(not str(biome.get("description")).is_empty(), "Biome %s should define description" % id)
		var color_key := str(biome.get("color_key"))
		_expect(not color_key.is_empty(), "Biome %s should define a visual color key" % id)
		_expect(not color_keys.has(color_key), "Biome visual color key should be unique: %s" % color_key)
		color_keys[color_key] = true
		_expect(biome.get("visual_floor_tint") is Color, "Biome %s should define a floor visual tint" % id)
		var floor_texture_path := str(biome.get("visual_floor_texture_path"))
		_expect(floor_texture_path.begins_with("res://art/terrain/") and floor_texture_path.ends_with(".png"), "Biome %s should define a project terrain PNG" % id)
		_expect(not floor_texture_paths.has(floor_texture_path), "Biome floor texture should be unique: %s" % floor_texture_path)
		floor_texture_paths[floor_texture_path] = true
		_expect(ResourceLoader.exists(floor_texture_path), "Biome %s floor texture should load" % id)
		var floor_texture := load(floor_texture_path) as Texture2D
		_expect(floor_texture != null and floor_texture.get_size() == Vector2(512.0, 512.0), "Biome %s floor texture should use the optimized 512px source" % id)
		_expect(biome.get("visual_floor_texture_modulate") is Color, "Biome %s should define floor texture modulation" % id)
		var floor_texture_opacity := float(biome.get("visual_floor_texture_opacity"))
		_expect(floor_texture_opacity > 0.0 and floor_texture_opacity <= 1.0, "Biome %s should define visible floor texture opacity" % id)
		_expect(biome.get("visual_wall_color") is Color, "Biome %s should define a wall visual color" % id)
		_expect(biome.get("visual_obstacle_tint") is Color, "Biome %s should define an obstacle visual tint" % id)
		var surface_atlas_path := str(biome.get("visual_surface_atlas_path"))
		_expect(surface_atlas_path.begins_with("res://art/terrain/") and surface_atlas_path.ends_with("_surface_atlas.svg"), "Biome %s should define a project surface atlas" % id)
		_expect(not surface_atlas_paths.has(surface_atlas_path), "Biome surface atlas should be unique: %s" % surface_atlas_path)
		surface_atlas_paths[surface_atlas_path] = true
		_expect(ResourceLoader.exists(surface_atlas_path), "Biome %s surface atlas should load" % id)
		var surface_atlas := load(surface_atlas_path) as Texture2D
		_expect(surface_atlas != null and surface_atlas.get_size() == Vector2(512.0, 256.0), "Biome %s surface atlas should expose two 256px regions" % id)
		_expect(biome.get("visual_wall_texture_modulate") is Color, "Biome %s should define wall texture modulation" % id)
		_expect(biome.get("visual_obstacle_texture_modulate") is Color, "Biome %s should define obstacle texture modulation" % id)
		var wall_texture_opacity := float(biome.get("visual_wall_texture_opacity"))
		var obstacle_texture_opacity := float(biome.get("visual_obstacle_texture_opacity"))
		_expect(wall_texture_opacity > 0.0 and wall_texture_opacity <= 1.0, "Biome %s should define visible wall texture opacity" % id)
		_expect(obstacle_texture_opacity > 0.0 and obstacle_texture_opacity <= 1.0, "Biome %s should define visible obstacle texture opacity" % id)
		_expect(biome.get("visual_accent_color") is Color, "Biome %s should define an accent visual color" % id)
		var tint_strength := float(biome.get("visual_tint_strength"))
		_expect(tint_strength > 0.0 and tint_strength <= 1.0, "Biome %s should define an active visual tint strength" % id)
		var reward_multiplier := float(biome.get("reward_weight_multiplier"))
		_expect(reward_multiplier >= 1.0, "Biome %s should define an active reward weight multiplier" % id)
		if expected_reward_multipliers.has(id):
			_expect(is_equal_approx(reward_multiplier, float(expected_reward_multipliers[id])), "Biome %s reward weight multiplier should match its tuning target" % id)
		reward_multiplier_by_index[int(biome.get("biome_index"))] = reward_multiplier
		var layout_pool: Array = []
		var layout_pool_value = biome.get("layout_pool")
		if layout_pool_value is Array:
			layout_pool = layout_pool_value
		_expect(layout_pool.size() >= 4, "Biome %s should define an Alpha-facing layout pool" % id)
		var layout_ids := _layout_resource_ids(layout_pool)
		var unique_layout_ids := {}
		for layout_id in layout_ids:
			_expect(not unique_layout_ids.has(layout_id), "Biome %s layout pool should not duplicate %s" % [id, layout_id])
			unique_layout_ids[layout_id] = true
		if expected_layout_ids.has(id):
			for expected_layout_id in expected_layout_ids[id]:
				_expect(layout_ids.has(expected_layout_id), "Biome %s layout pool should include %s" % [id, expected_layout_id])
		_expect(int(biome.get("room_count_min")) <= int(biome.get("room_count_max")), "Biome %s room bounds should be valid" % id)
		_expect(int(biome.get("branch_count_min")) <= int(biome.get("branch_count_max")), "Biome %s branch bounds should be valid" % id)
		var enemy_pool: Array = []
		var enemy_pool_value = biome.get("enemy_pool")
		if enemy_pool_value is Array:
			enemy_pool = enemy_pool_value
		_expect(enemy_pool.size() >= 7, "Biome %s should define an Alpha-facing enemy pool" % id)
		var enemy_names := _scene_display_names(enemy_pool)
		match id:
			"outer_warrens":
				_expect(enemy_names.has("Rust Skirmisher"), "Outer Warrens should include Rust Skirmisher")
				_expect(enemy_names.has("Ember Marksman"), "Outer Warrens should include Ember Marksman")
				_expect(enemy_names.has("Needle Skater"), "Outer Warrens should include Needle Skater")
				_expect(enemy_names.has("Soot Splitter"), "Outer Warrens should include Soot Splitter")
			"iron_catacombs":
				_expect(enemy_names.has("Iron Breaker"), "Iron Catacombs should include Iron Breaker")
				_expect(enemy_names.has("Aegis Drone"), "Iron Catacombs should include Aegis Drone")
				_expect(enemy_names.has("Mire Conduit"), "Iron Catacombs should include Mire Conduit")
				_expect(enemy_names.has("Grave Mender"), "Iron Catacombs should include Grave Mender")
			"void_foundry":
				_expect(enemy_names.has("Volatile Vessel"), "Void Foundry should include Volatile Vessel")
				_expect(enemy_names.has("Rift Caller"), "Void Foundry should include Rift Caller")
				_expect(enemy_names.has("Needle Skater"), "Void Foundry should include Needle Skater")
				_expect(enemy_names.has("Barrage Totem"), "Void Foundry should include Barrage Totem")
				_expect(enemy_names.has("Null Acolyte"), "Void Foundry should include Null Acolyte")
		var boss_scene = biome.get("boss_scene")
		_expect(boss_scene is PackedScene, "Biome %s should define a boss scene" % id)
		if boss_scene is PackedScene:
			var boss := (boss_scene as PackedScene).instantiate()
			_expect(boss != null, "Biome %s boss scene should instantiate" % id)
			if boss != null:
				var boss_name := str(boss.get("display_name"))
				_expect(not boss_name.is_empty(), "Biome %s boss should define display name" % id)
				_expect(expected_boss_names.get(id, "") == boss_name, "Biome %s should use its configured boss identity" % id)
				_expect(not boss_names.has(boss_name), "Boss display name should be unique: %s" % boss_name)
				boss_names[boss_name] = true
				_expect(int(boss.get("max_health")) > 0, "Boss %s should define positive health" % boss_name)
				_expect(float(boss.get("attack_cooldown")) > 0.0, "Boss %s should define attack cooldown" % boss_name)
				var signature_attack := str(boss.get("signature_attack"))
				_expect(signature_attack == str(expected_boss_signatures.get(id, "")), "Boss %s should define its biome-specific signature attack" % boss_name)
				_expect(float(boss.get("signature_windup")) > 0.0, "Boss %s signature should define a readable windup" % boss_name)
				_expect(int(boss.get("signature_projectile_count")) >= 6, "Boss %s signature should define a projectile pattern" % boss_name)
				_expect(float(boss.get("signature_radius")) > 0.0, "Boss %s signature should define an active radius" % boss_name)
				var phase_two_attack := str(boss.get("phase_two_attack"))
				_expect(phase_two_attack == str(expected_phase_two_attacks.get(id, "")), "Boss %s should define its biome-specific phase-two attack" % boss_name)
				_expect(float(boss.get("phase_two_attack_windup")) >= 0.4, "Boss %s phase-two attack should define a readable windup" % boss_name)
				_expect(int(boss.get("phase_two_attack_projectile_count")) >= 8, "Boss %s phase-two attack should define a projectile pattern" % boss_name)
				_expect(float(boss.get("phase_two_attack_radius")) > 0.0, "Boss %s phase-two attack should define an active radius" % boss_name)
				_expect(boss.has_method("get_signature_attack_summary"), "Boss %s should expose signature summary" % boss_name)
				_expect(boss.has_method("get_phase_two_attack_summary"), "Boss %s should expose phase-two attack summary" % boss_name)
				if boss.has_method("get_signature_attack_summary"):
					var signature_summary: Dictionary = boss.call("get_signature_attack_summary")
					_expect(str(signature_summary.get("id", "")) == signature_attack, "Boss %s signature summary should match scene configuration" % boss_name)
					_expect(not str(signature_summary.get("display_name", "")).is_empty(), "Boss %s signature summary should expose a display name" % boss_name)
				if boss.has_method("get_phase_two_attack_summary"):
					var phase_two_summary: Dictionary = boss.call("get_phase_two_attack_summary")
					_expect(str(phase_two_summary.get("id", "")) == phase_two_attack, "Boss %s phase-two summary should match scene configuration" % boss_name)
					_expect(not str(phase_two_summary.get("display_name", "")).is_empty(), "Boss %s phase-two summary should expose a display name" % boss_name)
				if signature_attack == "bastion_lock":
					_expect(float(boss.get("signature_guard_damage_multiplier")) < 1.0, "Iron Bulwark signature should reduce incoming damage during guard")
				boss.free()
	for expected_id in expected_boss_names.keys():
		_expect(_resource_id_exists(biomes, expected_id), "Biome library should include %s" % expected_id)
	for biome_index in range(2, 4):
		_expect(float(reward_multiplier_by_index.get(biome_index, 0.0)) >= float(reward_multiplier_by_index.get(biome_index - 1, 0.0)), "Biome reward weight multipliers should not decrease across the three-biome route")


func _verify_aim_assist_contract() -> void:
	var assist := AIM_ASSIST_SCRIPT.new()
	add_child(assist)
	assist.enabled = true
	assist.max_distance = 400.0
	assist.max_angle_degrees = 45.0
	assist.strength = 0.5

	var direct_target := Node2D.new()
	var side_target := Node2D.new()
	add_child(direct_target)
	add_child(side_target)
	direct_target.global_position = Vector2(180, 0)
	side_target.global_position = Vector2(180, 120)

	var picked := assist.pick_target(Vector2.ZERO, Vector2.RIGHT, [side_target, direct_target])
	_expect(picked == direct_target, "AimAssistController should prefer the target closest to aim direction")
	var assisted := assist.get_assisted_direction(Vector2.ZERO, Vector2.RIGHT, [side_target])
	_expect(assisted.x > 0.0 and assisted.y > 0.0, "AimAssistController should blend toward valid target")
	_expect(assist.get_candidate_score(Vector2.ZERO, Vector2.RIGHT, direct_target) > assist.get_candidate_score(Vector2.ZERO, Vector2.RIGHT, side_target), "AimAssistController should expose score differences for target candidates")
	assist.lock_weight = 2.0
	assist.set_locked_target(side_target)
	picked = assist.pick_target(Vector2.ZERO, Vector2.RIGHT, [direct_target, side_target])
	_expect(picked == side_target, "AimAssistController lock weight should preserve a valid locked target")
	_expect(assist.get_locked_target() == side_target, "AimAssistController should expose the current locked target")
	assist.clear_lock()
	picked = assist.pick_target(Vector2.ZERO, Vector2.RIGHT, [direct_target, side_target])
	_expect(picked == direct_target, "AimAssistController clear_lock should restore score-only target selection")
	var training_target := Node2D.new()
	add_child(training_target)
	training_target.add_to_group("training_dummy")
	training_target.global_position = Vector2(140, 24)
	assist.set_candidate_groups(["training_dummy"])
	var candidate_groups := assist.get_candidate_groups()
	_expect(candidate_groups.has("training_dummy") and not candidate_groups.has("enemies"), "AimAssistController should expose custom candidate groups")
	var collected_candidates := assist.collect_candidates(get_tree())
	_expect(collected_candidates.has(training_target), "AimAssistController should collect targets from configured groups")
	picked = assist.pick_target_from_tree(Vector2.ZERO, Vector2.RIGHT, get_tree())
	_expect(picked == training_target, "AimAssistController should pick targets from configured scene-tree groups")
	assist.set_candidate_groups(["enemies"])
	assist.enabled = false
	_expect(assist.pick_target(Vector2.ZERO, Vector2.RIGHT, [direct_target]) == null, "AimAssistController should return no target while disabled")

	training_target.queue_free()
	assist.queue_free()
	direct_target.queue_free()
	side_target.queue_free()


func _load_resources(path: String) -> Array[Resource]:
	var resources: Array[Resource] = []
	var dir := DirAccess.open(path)
	_expect(dir != null, "%s should exist" % path)
	if dir == null:
		return resources

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var resource := load("%s/%s" % [path, file_name])
			_expect(resource is Resource, "%s/%s should load as a resource" % [path, file_name])
			if resource is Resource:
				resources.append(resource)
		file_name = dir.get_next()
	dir.list_dir_end()
	return resources


func _load_scenes(path: String) -> Array[PackedScene]:
	var scenes: Array[PackedScene] = []
	var dir := DirAccess.open(path)
	_expect(dir != null, "%s should exist" % path)
	if dir == null:
		return scenes

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			var scene := load("%s/%s" % [path, file_name])
			_expect(scene is PackedScene, "%s/%s should load as a scene" % [path, file_name])
			if scene is PackedScene:
				scenes.append(scene)
		file_name = dir.get_next()
	dir.list_dir_end()
	return scenes


func _scene_display_names(scenes: Array) -> PackedStringArray:
	var names := PackedStringArray()
	for scene in scenes:
		if not (scene is PackedScene):
			continue
		var instance := (scene as PackedScene).instantiate()
		if instance == null:
			continue
		var display_name = instance.get("display_name")
		if display_name != null:
			names.append(str(display_name))
		instance.free()
	return names


func _layout_resource_ids(layouts: Array) -> PackedStringArray:
	var ids := PackedStringArray()
	for layout in layouts:
		if not (layout is Resource):
			continue
		var layout_id := str((layout as Resource).get("id")).strip_edges()
		if not layout_id.is_empty():
			ids.append(layout_id)
	return ids


func _resource_id_exists(resources: Array[Resource], id: String) -> bool:
	for resource in resources:
		if str(resource.get("id")) == id:
			return true
	return false


func _resource_id_lookup(resources: Array[Resource]) -> Dictionary:
	var ids := {}
	for resource in resources:
		var id := str(resource.get("id")).strip_edges()
		if not id.is_empty():
			ids[id] = true
	return ids


func _resolve_content_icon_key(resource: Resource, content_prefix: String) -> String:
	if resource == null:
		return ""

	var explicit_value = resource.get("icon_key")
	if explicit_value != null:
		var explicit_key := str(explicit_value).strip_edges()
		if not explicit_key.is_empty():
			return explicit_key

	var resource_id := str(resource.get("id")).strip_edges()
	if resource_id.is_empty():
		return ""
	return "%s_%s" % [content_prefix, resource_id]


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("ContentPipelineSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

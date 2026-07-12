extends Node

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const CONTENT_ICON_REGISTRY := preload("res://scripts/content/ContentIconRegistry.gd")
const SHARP_ROUNDS := preload("res://resources/relics/sharp_rounds.tres")
const QUICK_TRIGGER := preload("res://resources/relics/quick_trigger.tres")
const SPLIT_CHAMBER := preload("res://resources/relics/split_chamber.tres")
const PHASE_TIP := preload("res://resources/relics/phase_tip.tres")
const VAMPIRE_FANG := preload("res://resources/relics/vampire_fang.tres")
const GUARDIAN_WARD := preload("res://resources/relics/guardian_ward.tres")
const ADRENALINE_CHARM := preload("res://resources/relics/adrenaline_charm.tres")
const LUCKY_PRIMER := preload("res://resources/relics/lucky_primer.tres")
const SWIFT_LOADER := preload("res://resources/relics/swift_loader.tres")
const HEART_CORE := preload("res://resources/relics/heart_core.tres")
const VOLATILE_OIL := preload("res://resources/relics/volatile_oil.tres")
const EMBER_CATALYST := preload("res://resources/relics/ember_catalyst.tres")
const LINGERING_ASH := preload("res://resources/relics/lingering_ash.tres")
const PARRY_GRIP := preload("res://resources/relics/parry_grip.tres")
const WARDING_HINGE := preload("res://resources/relics/warding_hinge.tres")
const COUNTERWEIGHT_CORE := preload("res://resources/relics/counterweight_core.tres")
const DRAW_WEIGHT := preload("res://resources/relics/draw_weight.tres")
const QUICK_WINDUP := preload("res://resources/relics/quick_windup.tres")
const STORED_SPARK := preload("res://resources/relics/stored_spark.tres")
const TRIPWIRE_AMPLIFIER := preload("res://resources/relics/tripwire_amplifier.tres")
const ANCHOR_SPOOL := preload("res://resources/relics/anchor_spool.tres")
const RICOCHET_GYRO := preload("res://resources/relics/ricochet_gyro.tres")
const BLAST_RADIUS_GAUGE := preload("res://resources/relics/blast_radius_gauge.tres")
const KINETIC_BRIDLE := preload("res://resources/relics/kinetic_bridle.tres")
const RESERVE_DRUM := preload("res://resources/relics/reserve_drum.tres")
const FLUX_RESERVOIR := preload("res://resources/relics/flux_reservoir.tres")
const TRACKING_VANE := preload("res://resources/relics/tracking_vane.tres")
const LONGVIEW_ARRAY := preload("res://resources/relics/longview_array.tres")
const FORKED_BUS := preload("res://resources/relics/forked_bus.tres")
const CONDUCTION_MESH := preload("res://resources/relics/conduction_mesh.tres")
const STORMGLASS_FILAMENT := preload("res://resources/relics/stormglass_filament.tres")
const REFRACTION_CROWN := preload("res://resources/relics/refraction_crown.tres")
const PERPETUAL_DYNAMO := preload("res://resources/relics/perpetual_dynamo.tres")
const BLACKSTAR_RELAY := preload("res://resources/relics/blackstar_relay.tres")
const RICOCHET_BLASTER := preload("res://resources/weapons/ricochet_blaster.tres")
const BLAST_LAUNCHER := preload("res://resources/weapons/blast_launcher.tres")
const COMPASS_NEEDLE := preload("res://resources/weapons/compass_needle.tres")
const RELAY_ARC := preload("res://resources/weapons/relay_arc.tres")

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	if main.has_method("start_new_run"):
		main.call("start_new_run")

	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().create_timer(0.15).timeout

	var player := main.get_node("Player") as Player
	var relic_system := main.get_node_or_null("RelicSystem")
	var hud = main.get_node_or_null("CanvasLayer/HUD")
	_expect(player != null, "Player should exist")
	_expect(relic_system != null, "RelicSystem should exist")
	if player == null or relic_system == null:
		_finish()
		return

	_expect(relic_system.call("get_relic_count") == 0, "RelicSystem should start empty")
	_expect((relic_system.get("available_relics") as Array).size() >= 10, "RelicSystem should expose at least 10 relics")
	_verify_relic_choice_randomization(relic_system)
	_verify_source_drop_pools(relic_system)
	_expect(bool(relic_system.call("obtain_relic", SHARP_ROUNDS)), "Should obtain Sharp Rounds")
	_expect(player.get_damage_multiplier() > 1.0, "Sharp Rounds should increase player damage multiplier")
	if hud != null and hud.has_method("get_relic_label_tooltip_text"):
		_expect(str(hud.call("get_relic_label_text")).contains("1"), "Compact HUD should show the collected relic count")
		_expect(str(hud.call("get_relic_label_tooltip_text")).contains(Localization.text("Sharp Rounds")), "Compact HUD relic tooltip should identify the collected relic")

	_expect(bool(relic_system.call("obtain_relic", QUICK_TRIGGER)), "Should obtain Quick Trigger")
	_expect(player.get_fire_rate_multiplier() > 1.0, "Quick Trigger should increase fire rate multiplier")
	_expect(bool(relic_system.call("obtain_relic", SPLIT_CHAMBER)), "Should obtain Split Chamber")
	_expect(player.get_projectile_count_bonus() == 1, "Split Chamber should add one projectile")
	_expect(bool(relic_system.call("obtain_relic", PHASE_TIP)), "Should obtain Phase Tip")
	_expect(player.get_pierce_bonus() == 1, "Phase Tip should add one pierce")
	_expect(bool(relic_system.call("obtain_relic", VAMPIRE_FANG)), "Should obtain Vampire Fang")
	_expect(bool(relic_system.call("obtain_relic", GUARDIAN_WARD)), "Should obtain Guardian Ward")
	_expect(bool(relic_system.call("obtain_relic", ADRENALINE_CHARM)), "Should obtain Adrenaline Charm")
	_expect(bool(relic_system.call("obtain_relic", LUCKY_PRIMER)), "Should obtain Lucky Primer")
	_expect(player.get_crit_chance_bonus() > 0.0, "Lucky Primer should increase crit chance bonus")
	_expect(bool(relic_system.call("obtain_relic", SWIFT_LOADER)), "Should obtain Swift Loader")
	_expect(player.get_reload_speed_multiplier() > 1.0, "Swift Loader should increase reload speed multiplier")
	var max_health_before := player.max_health
	var health_before := player.current_health
	_expect(bool(relic_system.call("obtain_relic", HEART_CORE)), "Should obtain Heart Core")
	_expect(player.max_health == max_health_before + 1, "Heart Core should increase max health by 1")
	_expect(player.current_health == mini(health_before + 1, player.max_health), "Heart Core should heal by 1")
	_expect(bool(relic_system.call("obtain_relic", VOLATILE_OIL)), "Should obtain Volatile Oil")
	_expect(player.get_status_chance_bonus() > 0.0, "Volatile Oil should increase status chance bonus")
	_expect(bool(relic_system.call("obtain_relic", EMBER_CATALYST)), "Should obtain Ember Catalyst")
	_expect(player.get_status_damage_multiplier() > 1.0, "Ember Catalyst should increase status damage multiplier")
	_expect(bool(relic_system.call("obtain_relic", LINGERING_ASH)), "Should obtain Lingering Ash")
	_expect(player.get_status_duration_multiplier() > 1.0, "Lingering Ash should increase status duration multiplier")
	_expect(bool(relic_system.call("obtain_relic", PARRY_GRIP)), "Should obtain Parry Grip")
	_expect(player.get_projectile_block_radius_bonus() > 0.0, "Parry Grip should increase projectile block radius")
	_expect(bool(relic_system.call("obtain_relic", WARDING_HINGE)), "Should obtain Warding Hinge")
	_expect(player.get_projectile_block_arc_bonus() > 0.0, "Warding Hinge should increase projectile block arc")
	_expect(bool(relic_system.call("obtain_relic", COUNTERWEIGHT_CORE)), "Should obtain Counterweight Core")
	_expect(player.get_projectile_block_damage_bonus() > 0, "Counterweight Core should increase projectile block counter damage")
	_expect(bool(relic_system.call("obtain_relic", DRAW_WEIGHT)), "Should obtain Draw Weight")
	_expect(player.get_charge_damage_multiplier() > 1.0, "Draw Weight should increase charge damage multiplier")
	_expect(bool(relic_system.call("obtain_relic", QUICK_WINDUP)), "Should obtain Quick Windup")
	_expect(player.get_charge_speed_multiplier() > 1.0, "Quick Windup should increase charge speed multiplier")
	_expect(bool(relic_system.call("obtain_relic", STORED_SPARK)), "Should obtain Stored Spark")
	_expect(player.get_charge_projectile_count_bonus() > 0, "Stored Spark should add charge projectile count bonus")
	_expect(bool(relic_system.call("obtain_relic", TRIPWIRE_AMPLIFIER)), "Should obtain Tripwire Amplifier")
	_expect(player.get_deployable_damage_multiplier() > 1.0, "Tripwire Amplifier should increase deployable damage multiplier")
	_expect(bool(relic_system.call("obtain_relic", ANCHOR_SPOOL)), "Should obtain Anchor Spool")
	_expect(player.get_deployable_duration_multiplier() > 1.0, "Anchor Spool should increase deployable duration multiplier")
	_expect(bool(relic_system.call("obtain_relic", RICOCHET_GYRO)), "Should obtain Ricochet Gyro")
	_expect(player.get_bounce_count_bonus() == 1, "Ricochet Gyro should add one projectile bounce")
	_expect(bool(relic_system.call("obtain_relic", BLAST_RADIUS_GAUGE)), "Should obtain Blast Radius Gauge")
	_expect(player.get_explosion_radius_bonus() > 0.0, "Blast Radius Gauge should increase explosion radius")
	_expect(bool(relic_system.call("obtain_relic", KINETIC_BRIDLE)), "Should obtain Kinetic Bridle")
	_expect(player.get_knockback_multiplier() > 1.0, "Kinetic Bridle should increase knockback multiplier")
	var magazine_size_before := player.weapon.get_magazine_size()
	var magazine_ammo_before := player.weapon.get_current_ammo()
	_expect(bool(relic_system.call("obtain_relic", RESERVE_DRUM)), "Should obtain Reserve Drum")
	_expect(player.get_magazine_size_bonus() == 3, "Reserve Drum should add three magazine slots")
	_expect(player.weapon.get_magazine_size() == magazine_size_before + 3, "Reserve Drum should expand the equipped weapon magazine immediately")
	_expect(player.weapon.get_current_ammo() == magazine_ammo_before + 3, "Reserve Drum should fill newly added magazine slots")
	if hud != null and hud.has_method("get_weapon_slot_loadout_summary_for_test"):
		var expanded_loadout: Dictionary = hud.call("get_weapon_slot_loadout_summary_for_test")
		var expanded_entries: Array = expanded_loadout.get("entries", [])
		_expect(expanded_entries.size() == player.weapon_loadout.size(), "Reserve Drum should keep every HUD loadout slot visible")
		for index in range(mini(expanded_entries.size(), player.weapon_loadout.size())):
			_expect(int(expanded_entries[index].get("magazine_size", 0)) == int(player.weapon_loadout[index].magazine_size) + 3, "Reserve Drum should update magazine capacity for HUD loadout slot %d" % (index + 1))
	var max_energy_before := player.max_energy
	var current_energy_before := player.current_energy
	_expect(bool(relic_system.call("obtain_relic", FLUX_RESERVOIR)), "Should obtain Flux Reservoir")
	_expect(player.max_energy == max_energy_before + 3, "Flux Reservoir should add three maximum energy")
	_expect(player.current_energy == mini(current_energy_before + 3, player.max_energy), "Flux Reservoir should restore its added energy capacity")
	_expect(bool(relic_system.call("obtain_relic", TRACKING_VANE)), "Should obtain Tracking Vane")
	_expect(player.get_homing_turn_rate_bonus() == 90.0, "Tracking Vane should increase homing turn rate")
	_expect(bool(relic_system.call("obtain_relic", LONGVIEW_ARRAY)), "Should obtain Longview Array")
	_expect(player.get_homing_radius_bonus() == 100.0, "Longview Array should increase homing acquisition radius")
	_expect(bool(relic_system.call("obtain_relic", FORKED_BUS)), "Should obtain Forked Bus")
	_expect(player.get_chain_count_bonus() == 1, "Forked Bus should add one chain target")
	_expect(bool(relic_system.call("obtain_relic", CONDUCTION_MESH)), "Should obtain Conduction Mesh")
	_expect(player.get_chain_radius_bonus() == 55.0, "Conduction Mesh should increase chain bridge radius")
	_expect(bool(relic_system.call("obtain_relic", STORMGLASS_FILAMENT)), "Should obtain Stormglass Filament")
	_expect(player.get_chain_damage_multiplier() > 1.0, "Stormglass Filament should increase chained damage")
	var projectile_count_before := player.get_projectile_count_bonus()
	_expect(bool(relic_system.call("obtain_relic", REFRACTION_CROWN)), "Should obtain Refraction Crown")
	_expect(player.get_projectile_count_bonus() == projectile_count_before + 2, "Refraction Crown should add two projectiles")
	var legendary_energy_before := player.max_energy
	var legendary_current_energy_before := player.current_energy
	_expect(bool(relic_system.call("obtain_relic", PERPETUAL_DYNAMO)), "Should obtain Perpetual Dynamo")
	_expect(player.max_energy == legendary_energy_before + 7, "Perpetual Dynamo should add seven maximum energy")
	_expect(player.current_energy == mini(legendary_current_energy_before + 7, player.max_energy), "Perpetual Dynamo should restore its added energy capacity")
	var chain_count_before := player.get_chain_count_bonus()
	_expect(bool(relic_system.call("obtain_relic", BLACKSTAR_RELAY)), "Should obtain Blackstar Relay")
	_expect(player.get_chain_count_bonus() == chain_count_before + 2, "Blackstar Relay should add two chain targets")

	await _verify_projectile_modifiers(player)
	await _verify_route_specific_modifiers(player)
	await _verify_triggered_relics(player)
	await _verify_reward_room_relic_pickup(main, player, relic_system)
	_finish()


func _verify_projectile_modifiers(player: Player) -> void:
	player.call("_equip_weapon", 0)
	await get_tree().process_frame

	var weapon := player.weapon
	var weapon_data := weapon.weapon_data
	_clear_projectiles()
	weapon.set("_cooldown", 0.0)
	var fired := weapon.try_fire(player.global_position + Vector2(320, 0), player)
	await get_tree().process_frame

	var expected_projectiles := weapon_data.projectile_count + player.get_projectile_count_bonus()
	_expect(fired, "Weapon should fire after relic modifiers")
	_expect(_projectile_count() == expected_projectiles, "Split Chamber should increase projectile count")
	_expect(float(weapon.get("_cooldown")) < 1.0 / weapon_data.fire_rate, "Quick Trigger should reduce cooldown")

	var projectile := get_tree().get_first_node_in_group("projectiles")
	_expect(projectile != null, "Projectile should exist for relic modifier checks")
	if projectile != null:
		var expected_damage := maxi(roundi(float(weapon_data.damage) * player.get_damage_multiplier()), 1)
		_expect(projectile.get("damage") == expected_damage, "Sharp Rounds should increase projectile damage")
		_expect(projectile.get("_remaining_pierce") == weapon_data.pierce_count + player.get_pierce_bonus(), "Phase Tip should increase projectile pierce")
		_expect(is_equal_approx(float(projectile.get("crit_chance")), clampf(weapon_data.crit_chance + player.get_crit_chance_bonus(), 0.0, 1.0)), "Lucky Primer should increase projectile crit chance")
		_expect(float(projectile.get("homing_turn_rate")) == 0.0 and int(projectile.get("chain_count")) == 0, "Route relics should not add homing or chain behavior to unsupported weapons")

	_expect(weapon.start_reload(), "Weapon should start manual reload after spending ammo")
	_expect(weapon.is_reloading(), "Weapon should be reloading after start_reload")
	_expect(float(weapon.get("_reload_timer")) < weapon_data.reload_duration, "Swift Loader should reduce reload timer")

	_clear_projectiles()


func _verify_route_specific_modifiers(player: Player) -> void:
	var weapon := player.weapon
	player.recover_energy(player.max_energy)
	weapon.set_weapon_data(RICOCHET_BLASTER)
	weapon.set("_cooldown", 0.0)
	_clear_projectiles()
	_expect(weapon.try_fire(player.global_position + Vector2(320, 0), player), "Ricochet Blaster should fire for bounce modifier checks")
	await get_tree().process_frame
	var ricochet_projectile := get_tree().get_first_node_in_group("projectiles")
	_expect(ricochet_projectile != null, "Ricochet projectile should exist for route modifier checks")
	if ricochet_projectile != null:
		_expect(int(ricochet_projectile.get("_remaining_bounces")) == RICOCHET_BLASTER.bounce_count + player.get_bounce_count_bonus(), "Ricochet Gyro should extend projectile bounce count")
		_expect(is_equal_approx(float(ricochet_projectile.get("knockback")), RICOCHET_BLASTER.knockback * player.get_knockback_multiplier()), "Kinetic Bridle should scale projectile knockback")

	player.recover_energy(player.max_energy)
	weapon.set_weapon_data(BLAST_LAUNCHER)
	weapon.set("_cooldown", 0.0)
	_clear_projectiles()
	_expect(weapon.try_fire(player.global_position + Vector2(320, 0), player), "Blast Launcher should fire for explosion modifier checks")
	await get_tree().process_frame
	var explosive_projectile := get_tree().get_first_node_in_group("projectiles")
	_expect(explosive_projectile != null, "Explosive projectile should exist for route modifier checks")
	if explosive_projectile != null:
		_expect(is_equal_approx(float(explosive_projectile.get("explosion_radius")), BLAST_LAUNCHER.explosion_radius + player.get_explosion_radius_bonus()), "Blast Radius Gauge should expand explosive projectiles")

	player.recover_energy(player.max_energy)
	weapon.set_weapon_data(COMPASS_NEEDLE)
	weapon.set("_cooldown", 0.0)
	_clear_projectiles()
	_expect(weapon.try_fire(player.global_position + Vector2(320, 0), player), "Compass Needle should fire for homing relic checks")
	await get_tree().process_frame
	var homing_projectile := get_tree().get_first_node_in_group("projectiles")
	_expect(homing_projectile != null, "Homing projectile should exist for route modifier checks")
	if homing_projectile != null:
		_expect(is_equal_approx(float(homing_projectile.get("homing_turn_rate")), COMPASS_NEEDLE.homing_turn_rate + player.get_homing_turn_rate_bonus()), "Tracking Vane should increase homing turn rate on supported weapons")
		_expect(is_equal_approx(float(homing_projectile.get("homing_radius")), COMPASS_NEEDLE.homing_radius + player.get_homing_radius_bonus()), "Longview Array should increase homing radius on supported weapons")

	player.recover_energy(player.max_energy)
	weapon.set_weapon_data(RELAY_ARC)
	weapon.set("_cooldown", 0.0)
	_clear_projectiles()
	_expect(weapon.try_fire(player.global_position + Vector2(320, 0), player), "Relay Arc should fire for chain relic checks")
	await get_tree().process_frame
	var chain_projectile := get_tree().get_first_node_in_group("projectiles")
	_expect(chain_projectile != null, "Chain projectile should exist for route modifier checks")
	if chain_projectile != null:
		_expect(int(chain_projectile.get("chain_count")) == RELAY_ARC.chain_count + player.get_chain_count_bonus(), "Forked Bus should increase chain target count on supported weapons")
		_expect(is_equal_approx(float(chain_projectile.get("chain_radius")), RELAY_ARC.chain_radius + player.get_chain_radius_bonus()), "Conduction Mesh should increase chain radius on supported weapons")
		_expect(is_equal_approx(float(chain_projectile.get("chain_damage_multiplier")), RELAY_ARC.chain_damage_multiplier * player.get_chain_damage_multiplier()), "Stormglass Filament should increase chained damage on supported weapons")
	_clear_projectiles()


func _verify_relic_choice_randomization(relic_system: Node) -> void:
	_expect(float(relic_system.call("get_rarity_weight", "common")) > float(relic_system.call("get_rarity_weight", "rare")), "Common relics should have higher weight than rare relics")
	_expect(float(relic_system.call("get_rarity_weight", "rare")) > float(relic_system.call("get_rarity_weight", "epic")), "Rare relics should have higher weight than epic relics")
	_expect(float(relic_system.call("get_rarity_weight", "epic")) > float(relic_system.call("get_rarity_weight", "legendary")), "Epic relics should have higher weight than legendary relics")
	relic_system.call("set_random_seed", 123456)
	var first_choices: Array = relic_system.call("get_reward_choices", 3)
	relic_system.call("set_random_seed", 123456)
	var repeat_choices: Array = relic_system.call("get_reward_choices", 3)
	_expect(first_choices.size() == 3, "Weighted reward choices should return 3 candidates")
	_expect(_unique_choice_count(first_choices) == first_choices.size(), "Weighted reward choices should not repeat relics")
	_expect(_choice_id_signature(first_choices) == _choice_id_signature(repeat_choices), "Weighted reward choices should be reproducible with the same seed")
	_expect(relic_system.has_method("get_weighted_relic_score_for_test"), "RelicSystem should expose weighted relic score for content contract checks")
	if relic_system.has_method("get_weighted_relic_score_for_test"):
		var sharp_expected := float(relic_system.call("get_source_rarity_weight", "reward", str(SHARP_ROUNDS.get("rarity")))) * float(SHARP_ROUNDS.get("drop_weight"))
		var sharp_score := float(relic_system.call("get_weighted_relic_score_for_test", SHARP_ROUNDS, "reward", 1.0))
		var heart_default_score := float(relic_system.call("get_weighted_relic_score_for_test", HEART_CORE, "reward", 1.0))
		var heart_biome_score := float(relic_system.call("get_weighted_relic_score_for_test", HEART_CORE, "reward", 1.16))
		var stored_default_score := float(relic_system.call("get_weighted_relic_score_for_test", STORED_SPARK, "reward", 1.0))
		var stored_biome_score := float(relic_system.call("get_weighted_relic_score_for_test", STORED_SPARK, "reward", 1.16))
		_expect(is_equal_approx(sharp_score, sharp_expected), "Relic weighted score should multiply rarity source weight by relic drop_weight")
		_expect(heart_biome_score > heart_default_score, "Biome reward multiplier should raise rare relic score")
		_expect(stored_biome_score > stored_default_score and stored_biome_score / stored_default_score > heart_biome_score / heart_default_score, "Biome reward multiplier should scale epic relics more than rare relics")


func _verify_source_drop_pools(relic_system: Node) -> void:
	_expect(relic_system.has_method("get_source_pool_ids"), "RelicSystem should expose source pool ids")
	_expect(relic_system.has_method("get_source_rarity_weight"), "RelicSystem should expose source rarity weights")
	_expect(relic_system.has_method("get_configured_drop_source_ids"), "RelicSystem should expose configured drop source ids")
	_expect(relic_system.has_method("get_drop_table_resource_path"), "RelicSystem should expose drop table resource paths")
	_expect(relic_system.has_method("get_source_reward_pacing_summary"), "RelicSystem should expose source reward pacing summaries")
	if not relic_system.has_method("get_source_pool_ids") or not relic_system.has_method("get_source_rarity_weight"):
		return

	var configured_sources: Array = relic_system.call("get_configured_drop_source_ids")
	var reward_ids: Array = relic_system.call("get_source_pool_ids", "reward")
	var shop_ids: Array = relic_system.call("get_source_pool_ids", "shop")
	var normal_chest_ids: Array = relic_system.call("get_source_pool_ids", "normal_chest")
	var premium_chest_ids: Array = relic_system.call("get_source_pool_ids", "premium_chest")
	var boss_chest_ids: Array = relic_system.call("get_source_pool_ids", "boss_chest")
	_expect(configured_sources.has("reward"), "Reward source should be configured by a drop table resource")
	_expect(configured_sources.has("shop"), "Shop source should be configured by a drop table resource")
	_expect(configured_sources.has("normal_chest"), "Normal chest source should be configured by a drop table resource")
	_expect(configured_sources.has("premium_chest"), "Premium chest source should be configured by a drop table resource")
	_expect(configured_sources.has("boss_chest"), "Boss chest source should be configured by a drop table resource")
	_expect(str(relic_system.call("get_drop_table_resource_path", "shop")).begins_with("res://resources/relic_drop_tables/"), "Shop drop table should live in resource configuration")
	_expect(reward_ids.size() >= 10, "Reward source should include the full first-version relic pool")
	_expect(shop_ids.size() < reward_ids.size(), "Shop source should use a narrower relic pool than reward room")
	_expect(normal_chest_ids.has("guardian_ward"), "Normal chest source should include survival relics")
	_expect(normal_chest_ids.has("quick_windup"), "Normal chest source should include common charge relics")
	_expect(normal_chest_ids.has("anchor_spool"), "Normal chest source should include common deployable relics")
	_expect(not normal_chest_ids.has("heart_core"), "Normal chest source should exclude higher-value rare health relic")
	_expect(premium_chest_ids.has("heart_core"), "Premium chest source should include Heart Core")
	_expect(premium_chest_ids.has("stored_spark"), "Premium chest source should include high-impact charge relics")
	_expect(premium_chest_ids.has("tripwire_amplifier"), "Premium chest source should include high-impact deployable relics")
	_expect(boss_chest_ids.has("lucky_primer"), "Boss chest source should include higher-impact rare relics")
	_expect(boss_chest_ids.has("stored_spark"), "Boss chest source should include premium charge relics")
	_expect(boss_chest_ids.has("tripwire_amplifier"), "Boss chest source should include premium deployable relics")
	_expect(reward_ids.has("ricochet_gyro"), "Reward source should include bounce-route relics")
	_expect(reward_ids.has("blast_radius_gauge"), "Reward source should include explosive-route relics")
	_expect(shop_ids.has("reserve_drum"), "Shop source should include ammo-route relics")
	_expect(premium_chest_ids.has("flux_reservoir"), "Premium chest source should include high-impact energy relics")
	_expect(boss_chest_ids.has("flux_reservoir"), "Boss chest source should include high-impact energy relics")
	_expect(reward_ids.has("tracking_vane") and reward_ids.has("forked_bus"), "Reward source should include homing and chain route relics")
	_expect(shop_ids.has("longview_array") and shop_ids.has("conduction_mesh"), "Shop source should include homing and chain range relics")
	_expect(premium_chest_ids.has("stormglass_filament") and boss_chest_ids.has("stormglass_filament"), "Premium reward sources should include chain damage relics")
	_expect(float(relic_system.call("get_source_rarity_weight", "normal_chest", "common")) > float(relic_system.call("get_source_rarity_weight", "normal_chest", "rare")), "Normal chest should favor common relics")
	_expect(float(relic_system.call("get_source_rarity_weight", "premium_chest", "rare")) > float(relic_system.call("get_source_rarity_weight", "premium_chest", "common")), "Premium chest should favor rare relics over common relics")
	_expect(float(relic_system.call("get_source_rarity_weight", "boss_chest", "epic")) > float(relic_system.call("get_source_rarity_weight", "boss_chest", "common")), "Boss chest should favor high-impact rarities over common relics")
	if relic_system.has_method("get_source_reward_pacing_summary"):
		var reward_pacing: Dictionary = relic_system.call("get_source_reward_pacing_summary", "reward")
		var normal_pacing: Dictionary = relic_system.call("get_source_reward_pacing_summary", "normal_chest")
		var premium_pacing: Dictionary = relic_system.call("get_source_reward_pacing_summary", "premium_chest")
		var boss_pacing: Dictionary = relic_system.call("get_source_reward_pacing_summary", "boss_chest")
		var shop_pacing: Dictionary = relic_system.call("get_source_reward_pacing_summary", "shop")
		_expect(str(reward_pacing.get("pity_group", "")) == "relic_reward", "Reward room should participate in shared relic pity")
		_expect(str(normal_pacing.get("pity_group", "")) == "relic_reward", "Normal chest should participate in shared relic pity")
		_expect(int(reward_pacing.get("pity_misses_before_guarantee", 0)) == 3, "Reward room should guarantee rare-or-better after three misses")
		_expect(str(premium_pacing.get("minimum_rarity", "")) == "rare", "Premium chest should enforce a rare-or-better floor")
		_expect(str(boss_pacing.get("minimum_rarity", "")) == "rare", "Boss chest should enforce a rare-or-better floor")
		_expect(str(shop_pacing.get("pity_group", "")).is_empty(), "Shop should not consume shared reward pity")


func _verify_triggered_relics(player: Player) -> void:
	player.current_health = player.max_health - 2
	player.health_changed.emit(player.current_health, player.max_health)
	var damaged_health := player.current_health
	for index in range(3):
		Events.enemy_died.emit(null)
		await get_tree().process_frame
	_expect(player.current_health > damaged_health, "Vampire Fang should heal after 3 kills")

	player.current_shield = maxi(player.max_shield - 1, 0)
	player.shield_changed.emit(player.current_shield)
	var shield_before := player.get_shield()
	Events.room_cleared.emit(null)
	await get_tree().process_frame
	_expect(player.get_shield() > shield_before, "Guardian Ward should add shield on room clear")

	player.set("_invulnerability_timer", 0.0)
	var health_before_shield_hit := player.current_health
	var shield_before_hit := player.get_shield()
	player.take_damage(1, null)
	await get_tree().process_frame
	_expect(player.current_health == health_before_shield_hit, "Shield should absorb damage before health")
	_expect(player.get_shield() < shield_before_hit, "Shield should decrease after absorbing damage")
	var shield_after_hit := player.get_shield()
	player.call("_tick_timers", player.shield_recharge_delay + 0.1)
	player.call("_tick_timers", 1.0)
	await get_tree().process_frame
	_expect(player.get_shield() > shield_after_hit, "Armor should recharge after avoiding damage")

	player.current_shield = 0
	player.shield_changed.emit(player.current_shield)
	player.set("_invulnerability_timer", 0.0)
	player.set("_temporary_speed_multiplier", 1.0)
	player.set("_speed_boost_timer", 0.0)
	var speed_before := player.get_current_speed_multiplier()
	player.take_damage(1, null)
	await get_tree().process_frame
	_expect(player.get_current_speed_multiplier() > speed_before, "Adrenaline Charm should increase speed after damage")
	player.call("_tick_timers", 2.2)
	await get_tree().process_frame
	_expect(is_equal_approx(player.get_current_speed_multiplier(), 1.0), "Adrenaline Charm speed boost should expire")


func _verify_reward_room_relic_pickup(main: Node, player: Player, relic_system: Node) -> void:
	var hud = main.get_node_or_null("CanvasLayer/HUD")
	relic_system.call("set_random_seed", 91011)
	var rooms := _get_rooms(main)
	var room := _first_room_by_type(rooms, "reward")
	if room != null:

		await _enter_room(room, player)
		var reward := _find_reward_near(room.global_position)
		if reward != null:
			_expect(reward.has_method("_update_label"), "Reward room reward should be RelicPickup")
			if reward.has_method("claim_for_player"):
				reward.call("claim_for_player", player)
				await get_tree().process_frame
			else:
				player.global_position = reward.global_position
				for index in range(4):
					await get_tree().physics_frame
					await get_tree().process_frame
		else:
			_expect(hud != null and hud.has_method("is_relic_choice_visible") and bool(hud.call("is_relic_choice_visible")), "Reward room should spawn a relic pickup or open relic choice panel")

		_expect(hud != null and hud.has_method("is_relic_choice_visible") and hud.call("is_relic_choice_visible"), "Reward room pickup should open relic choice panel")
		_expect(hud != null and hud.has_method("get_relic_choice_count") and hud.call("get_relic_choice_count") == 3, "Relic choice panel should show 3 choices")
		_expect(room.state == 3, "Reward room should stay CLEARED while waiting for relic choice")
		var pending_choices: Array = main.get("_pending_relic_choices")
		_expect(pending_choices.size() == 3, "Main should store 3 pending relic choices")
		var selected_id := ""
		var selected_stack_before := 0
		if pending_choices.size() > 0:
			_expect(pending_choices[0] is Resource, "First pending relic choice should be a Resource")
			_expect(_unique_choice_count(pending_choices) == pending_choices.size(), "Pending relic choices should not repeat relics")
			_verify_relic_choice_ui(hud, pending_choices)
			selected_id = str(pending_choices[0].get("id"))
			selected_stack_before = int(relic_system.call("get_stack_count", selected_id))
		_expect(hud != null and hud.has_method("choose_relic_for_test"), "HUD should expose test relic choice method")
		if hud != null and hud.has_method("choose_relic_for_test"):
			hud.call("choose_relic_for_test", 0)
		for index in range(3):
			await get_tree().physics_frame
			await get_tree().process_frame

		if selected_id != "":
			_expect(int(relic_system.call("get_stack_count", selected_id)) == selected_stack_before + 1, "Choosing first reward should add the selected relic stack")
		_expect(hud != null and not bool(hud.call("is_relic_choice_visible")), "Relic choice panel should hide after choosing")
		_expect(room.state == 4, "Choosing a relic should mark reward room REWARD_CLAIMED")
		return

	_expect(false, "Generated route should include a reward room")


func _verify_relic_choice_ui(hud: Node, pending_choices: Array) -> void:
	if hud == null:
		_failures.append("HUD should exist for relic choice UI checks")
		return
	if not hud.has_method("get_relic_choice_text") or not hud.has_method("get_relic_choice_font_color"):
		_failures.append("HUD should expose relic choice text and color for tests")
		return
	if not hud.has_method("get_relic_choice_icon_key") or not hud.has_method("get_relic_choice_icon_texture_path") or not hud.has_method("is_relic_choice_icon_visible"):
		_failures.append("HUD should expose relic choice icon state for tests")
		return

	for index in range(mini(pending_choices.size(), 3)):
		var relic := pending_choices[index] as Resource
		if relic == null:
			continue
		var choice_text := str(hud.call("get_relic_choice_text", index))
		var rarity := str(relic.get("rarity"))
		_expect(choice_text.contains(str(relic.get("display_name"))), "Relic choice text should include display name")
		_expect(choice_text.contains(rarity.capitalize()), "Relic choice text should include rarity")
		_expect(choice_text.contains("Tags:"), "Relic choice text should include tags")
		for tag in _get_relic_tag_names(relic):
			_expect(choice_text.contains(tag), "Relic choice text should include tag %s" % tag)

		var actual_color: Color = hud.call("get_relic_choice_font_color", index)
		var expected_color := _expected_rarity_color(rarity)
		_expect(actual_color.is_equal_approx(expected_color), "Relic choice color should match rarity %s" % rarity)
		var expected_icon_key := _resolve_choice_icon_key(relic, "relic")
		var icon_key := str(hud.call("get_relic_choice_icon_key", index))
		var icon_path := str(hud.call("get_relic_choice_icon_texture_path", index))
		_expect(icon_key == expected_icon_key, "Relic choice icon key should resolve from relic data")
		_expect(icon_path == CONTENT_ICON_REGISTRY.get_texture_path(icon_key, "relics"), "Relic choice icon texture should come from the content icon registry")
		_expect(not icon_path.is_empty(), "Relic choice icon texture path should not be empty")
		_expect(bool(hud.call("is_relic_choice_icon_visible", index)), "Relic choice icon should be visible when registry texture exists")
		if hud.has_method("get_relic_choice_icon_tooltip_text"):
			_expect(str(hud.call("get_relic_choice_icon_tooltip_text", index)).contains(icon_key), "Relic choice icon tooltip should include icon key")


func _get_relic_tag_names(relic: Resource) -> PackedStringArray:
	var tags := PackedStringArray()
	var raw_tags = relic.get("tags")
	if raw_tags is PackedStringArray:
		for tag in raw_tags:
			tags.append(str(tag).replace("_", " ").capitalize())
	elif raw_tags is Array:
		for tag in raw_tags:
			tags.append(str(tag).replace("_", " ").capitalize())
	return tags


func _expected_rarity_color(rarity: String) -> Color:
	match rarity.to_lower():
		"common":
			return Color(0.86, 0.9, 0.92, 1.0)
		"rare":
			return Color(0.36, 0.72, 1.0, 1.0)
		"epic":
			return Color(0.82, 0.48, 1.0, 1.0)
		"legendary":
			return Color(1.0, 0.72, 0.24, 1.0)
	return Color.WHITE


func _resolve_choice_icon_key(choice: Resource, content_type: String) -> String:
	var explicit_key := str(choice.get("icon_key")).strip_edges()
	if not explicit_key.is_empty():
		return explicit_key
	return "%s_%s" % [content_type, str(choice.get("id")).strip_edges()]


func _get_rooms(main: Node) -> Array:
	var controller := main.get_node_or_null("DungeonController")
	if controller != null and controller.has_method("get_combat_rooms"):
		return controller.call("get_combat_rooms")

	var rooms: Array = []
	for room in get_tree().get_nodes_in_group("combat_rooms"):
		if is_instance_valid(room):
			rooms.append(room)
	return rooms


func _first_room_by_type(rooms: Array, room_type: String) -> Node:
	for room in rooms:
		if is_instance_valid(room) and str(room.get("room_type")) == room_type:
			return room
	return null


func _enter_room(room: Node, player: Player) -> void:
	player.global_position = room.global_position + Vector2(-660, 0)
	await get_tree().physics_frame
	await get_tree().process_frame
	player.global_position = room.global_position
	for index in range(4):
		await get_tree().physics_frame
		await get_tree().process_frame


func _find_reward_near(position: Vector2) -> Node2D:
	for reward in get_tree().get_nodes_in_group("rewards"):
		if not is_instance_valid(reward) or reward.is_queued_for_deletion():
			continue
		var reward_node := reward as Node2D
		if reward_node != null and reward_node.global_position.distance_to(position) < 500.0:
			return reward_node
	return null


func _clear_projectiles() -> void:
	for projectile in get_tree().get_nodes_in_group("projectiles"):
		if is_instance_valid(projectile):
			projectile.queue_free()


func _projectile_count() -> int:
	var count := 0
	for projectile in get_tree().get_nodes_in_group("projectiles"):
		if is_instance_valid(projectile) and not projectile.is_queued_for_deletion():
			count += 1
	return count


func _choice_id_signature(choices: Array) -> String:
	var parts: PackedStringArray = []
	for choice in choices:
		if choice is Resource:
			parts.append(str(choice.get("id")))
	return "|".join(parts)


func _unique_choice_count(choices: Array) -> int:
	var seen := {}
	for choice in choices:
		if choice is Resource:
			seen[str(choice.get("id"))] = true
	return seen.size()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("RelicSmokeTest passed.")
		get_tree().quit(0)
		return

	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)

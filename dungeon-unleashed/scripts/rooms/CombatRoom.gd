extends Node2D
class_name CombatRoom

enum RoomState {
	UNENTERED,
	ENTERED,
	COMBAT,
	CLEARED,
	REWARD_CLAIMED,
}

const DANGER_WARNING_SCENE := preload("res://scenes/effects/DangerWarning.tscn")
const BIOME_SURFACE_VISUAL_SCRIPT := preload("res://scripts/rooms/BiomeSurfaceVisual.gd")
const SAFE_PLAYER_SPAWN_DISTANCE := 180.0
const SPAWN_STAGGER_RADIUS := 28.0
const ROOM_SAFE_SPAWN_EXTENTS := Vector2(540, 300)
const TRAP_HAZARD_POSITIONS := [
	Vector2(-330, 0),
	Vector2(0, -215),
	Vector2(330, 0),
	Vector2(0, 215),
	Vector2(-210, -155),
	Vector2(210, 155),
]
const BOSS_ARENA_HAZARD_POSITIONS := [
	Vector2(-360, -220),
	Vector2(360, -220),
	Vector2(0, 0),
	Vector2(-360, 220),
	Vector2(360, 220),
]

@export var enemy_scene: PackedScene = preload("res://scenes/enemies/Enemy.tscn")
@export var room_type: String = "combat"
@export var biome_id: String = "prototype_depths"
@export var biome_name: String = "Prototype Depths"
@export var biome_color_key: String = ""
@export var biome_visual_floor_tint: Color = Color(0.095, 0.105, 0.12, 1.0)
@export var biome_visual_floor_texture_path: String = ""
@export var biome_visual_floor_texture_modulate: Color = Color.WHITE
@export_range(0.0, 1.0, 0.01) var biome_visual_floor_texture_opacity: float = 0.8
@export var biome_visual_wall_color: Color = Color(0.22, 0.24, 0.27, 1.0)
@export var biome_visual_obstacle_tint: Color = Color(0.24, 0.26, 0.29, 1.0)
@export var biome_visual_surface_atlas_path: String = ""
@export var biome_visual_wall_texture_modulate: Color = Color.WHITE
@export_range(0.0, 1.0, 0.01) var biome_visual_wall_texture_opacity: float = 0.9
@export var biome_visual_obstacle_texture_modulate: Color = Color.WHITE
@export_range(0.0, 1.0, 0.01) var biome_visual_obstacle_texture_opacity: float = 0.9
@export var biome_visual_accent_color: Color = Color(0.74, 0.82, 0.94, 1.0)
@export_range(0.0, 1.0, 0.01) var biome_visual_tint_strength: float = 0.0
@export var biome_reward_weight_multiplier: float = 1.0
@export_enum("training", "crossfire", "reward_cache", "shrine", "open_cross", "pillars", "market", "boss_arena", "gauntlet", "split_cover", "center_ring", "ambush_corners", "boss_cross", "box_maze", "bunker", "corner_nests", "crescent", "diagonal_blocks", "long_lane", "narrow_gap", "twin_islands", "wide_arena") var layout_profile: String = "crossfire"
@export var layout_data: Resource
@export var connected_directions: PackedStringArray = PackedStringArray(["west", "east"])
@export var enemy_scenes: Array[PackedScene] = [
	preload("res://scenes/enemies/ChaserEnemy.tscn"),
]
@export var reward_scene: PackedScene = preload("res://scenes/pickups/CoinPickup.tscn")
@export var wave_enemy_counts: PackedInt32Array = [3, 4]
@export var time_between_waves: float = 0.8
@export var lock_doors_during_combat: bool = true
@export var auto_clear_on_enter: bool = false
@export_multiline var hazard_review_tip: String = ""
@export_multiline var hazard_threat_intel: String = ""
@export var hazard_counter_tags: PackedStringArray = []
@export_enum("gauntlet", "hazard_rush") var challenge_variant: String = "gauntlet"
@export var challenge_variant_label: String = "Elite Gauntlet"
@export var elite_enemies: bool = false
@export var elite_health_multiplier: float = 1.8
@export var elite_damage_multiplier: float = 1.35
@export var elite_death_explosion_radius: float = 120.0
@export var elite_death_explosion_damage: int = 1
@export var elite_modifier_profiles: Array[Resource] = []
@export var trap_hazards_enabled: bool = true
@export var trap_survival_duration: float = 2.4
@export var trap_hazard_radius: float = 92.0
@export var trap_hazard_warning_duration: float = 0.62
@export var trap_hazard_interval: float = 0.72
@export var trap_hazard_damage: int = 1
@export var trap_hazard_cycle_size: int = 2
@export var boss_arena_hazards_enabled: bool = true
@export var boss_arena_hazard_radius: float = 104.0
@export var boss_arena_hazard_warning_duration: float = 0.75
@export var boss_arena_hazard_interval: float = 1.55
@export var boss_arena_hazard_damage: int = 1
@export var boss_arena_hazard_cycle_size: int = 2
@export var complete_run_on_reward: bool = true

@onready var entry_area: Area2D = $EntryArea
@onready var enemy_spawns: Node2D = $EnemySpawns
@onready var reward_spawn: Marker2D = $RewardSpawn

var state: RoomState = RoomState.UNENTERED

var _doors: Array[StaticBody2D] = []
var _current_wave_index := -1
var _living_enemies: Array[Node] = []
var _reward_spawned := false
var _spawned_reward: Node
var _room_stopped := false
var _trap_active := false
var _trap_timer := 0.0
var _trap_hazard_timer := 0.0
var _trap_cycle_index := 0
var _trap_warnings: Array[Node] = []
var _challenge_hazards_active := false
var _challenge_hazard_timer := 0.0
var _boss_arena_active := false
var _boss_arena_hazard_timer := 0.0
var _boss_arena_cycle_index := 0
var _boss_arena_markers: Array[Polygon2D] = []
var _boss_arena_warnings: Array[Node] = []
var _wave_transition_pending := false


func _ready() -> void:
	add_to_group("combat_rooms")
	_apply_layout_profile()
	_apply_biome_terrain_visual()
	_apply_biome_wall_visuals()
	_configure_directional_boundaries()
	_doors = _get_doors()
	entry_area.body_entered.connect(_on_entry_area_body_entered)
	Events.enemy_died.connect(_on_enemy_died)
	Events.enemy_spawned.connect(_on_enemy_spawned)
	Events.reward_collected.connect(_on_reward_collected)
	Events.player_died.connect(_on_player_died)
	Events.boss_phase_changed.connect(_on_boss_phase_changed)
	Events.boss_died.connect(_on_boss_died)
	_set_exit_locked(false)
	_emit_state()
	get_tree().create_timer(0.05).timeout.connect(_check_initial_overlap)


func _process(delta: float) -> void:
	if _room_stopped or state != RoomState.COMBAT:
		return

	if _trap_active:
		_tick_trap_room(delta)

	if _challenge_hazards_active:
		_tick_challenge_hazards(delta)

	if _boss_arena_active:
		_boss_arena_hazard_timer = maxf(_boss_arena_hazard_timer - delta, 0.0)
		if _boss_arena_hazard_timer > 0.0:
			return

		_spawn_boss_arena_hazard_cycle()
		_boss_arena_hazard_timer = boss_arena_hazard_interval


func _physics_process(_delta: float) -> void:
	if _room_stopped or state != RoomState.UNENTERED:
		return

	_check_initial_overlap()


func get_state_name() -> String:
	match state:
		RoomState.UNENTERED:
			return "Unentered"
		RoomState.ENTERED:
			return "Entered"
		RoomState.COMBAT:
			return "Combat"
		RoomState.CLEARED:
			return "Cleared"
		RoomState.REWARD_CLAIMED:
			return "Reward Claimed"
	return "Unknown"


func get_biome_visual_summary() -> Dictionary:
	return {
		"biome_id": biome_id,
		"biome_name": biome_name,
		"color_key": biome_color_key,
		"floor_tint": biome_visual_floor_tint,
		"floor_texture_path": biome_visual_floor_texture_path,
		"floor_texture_modulate": biome_visual_floor_texture_modulate,
		"floor_texture_opacity": biome_visual_floor_texture_opacity,
		"terrain_layer": _get_terrain_layer_summary(),
		"wall_color": biome_visual_wall_color,
		"obstacle_tint": biome_visual_obstacle_tint,
		"surface_atlas_path": biome_visual_surface_atlas_path,
		"wall_texture_modulate": biome_visual_wall_texture_modulate,
		"wall_texture_opacity": biome_visual_wall_texture_opacity,
		"obstacle_texture_modulate": biome_visual_obstacle_texture_modulate,
		"obstacle_texture_opacity": biome_visual_obstacle_texture_opacity,
		"wall_surface": _get_first_wall_surface_summary(),
		"obstacle_surface": _get_first_obstacle_surface_summary(),
		"accent_color": biome_visual_accent_color,
		"tint_strength": biome_visual_tint_strength,
		"floor_color": _get_floor_color(),
		"first_wall_color": _get_first_wall_color(),
	}


func get_biome_reward_summary() -> Dictionary:
	return {
		"biome_id": biome_id,
		"biome_name": biome_name,
		"reward_weight_multiplier": biome_reward_weight_multiplier,
	}


func get_living_enemy_count() -> int:
	_prune_living_enemies()
	return _living_enemies.size()


func doors_are_unlocked() -> bool:
	for door in _doors:
		if not _is_connected_door(door):
			continue
		for child in door.get_children():
			if child is CollisionShape2D and not (child as CollisionShape2D).disabled:
				return false
	return true


func is_boss_arena_active() -> bool:
	return _boss_arena_active


func get_boss_arena_marker_count() -> int:
	return _boss_arena_markers.size()


func get_boss_arena_warning_count() -> int:
	_prune_boss_arena_warnings()
	return _boss_arena_warnings.size()


func get_trap_warning_count() -> int:
	_prune_trap_warnings()
	return _trap_warnings.size()


func is_trap_active() -> bool:
	return _trap_active


func is_challenge_hazard_active() -> bool:
	return _challenge_hazards_active


func get_challenge_summary() -> Dictionary:
	return {
		"variant": challenge_variant,
		"label": challenge_variant_label,
		"hazards_active": _challenge_hazards_active,
		"hazard_interval": trap_hazard_interval,
		"hazard_cycle_size": trap_hazard_cycle_size,
		"wave_counts": wave_enemy_counts,
		"elite_enemies": elite_enemies,
	}


func get_damage_source_summary() -> Dictionary:
	return {
		"source_id": _get_hazard_source_id(),
		"source_name": _get_hazard_source_name(),
		"source_type": "hazard",
		"source_scene": scene_file_path,
		"room_type": room_type,
		"biome_id": biome_id,
		"biome_name": biome_name,
		"layout_profile": layout_profile,
		"source_review_tip": _get_hazard_review_tip(),
		"source_threat_intel": _get_hazard_threat_intel(),
		"source_counter_tags": _get_hazard_counter_tags(),
	}


func _get_hazard_source_id() -> String:
	if _boss_arena_active or _is_boss_room():
		return "boss_arena_hazard"
	if _trap_active or _is_trap_room():
		return "trap_room_hazard"
	if _challenge_hazards_active or _is_challenge_hazard_variant():
		return "challenge_room_hazard"
	return "%s_hazard" % room_type.to_snake_case()


func _get_hazard_source_name() -> String:
	if _boss_arena_active or _is_boss_room():
		return "Boss Arena Hazard"
	if _trap_active or _is_trap_room():
		return "Trap Room Hazard"
	if _challenge_hazards_active or _is_challenge_hazard_variant():
		return "Challenge Room Hazard"
	return "%s Hazard" % room_type.capitalize()


func _get_hazard_review_tip() -> String:
	var configured_tip := hazard_review_tip.strip_edges()
	if not configured_tip.is_empty():
		return configured_tip
	if _boss_arena_active or _is_boss_room():
		return "Respect arena tells before chasing damage and keep armor for overlapping hazards."
	if _trap_active or _is_trap_room():
		return "Treat warning zones as lanes, keep one escape route open, and cross after the pulse."
	if _challenge_hazards_active or _is_challenge_hazard_variant():
		return "Clear the reward rule first, then avoid staying inside repeated warning zones."
	return "Wait for readable hazard tells before committing to close-range damage."


func _get_hazard_threat_intel() -> String:
	var configured_intel := hazard_threat_intel.strip_edges()
	if not configured_intel.is_empty():
		return configured_intel
	if _boss_arena_active or _is_boss_room():
		return "Arena Hazard / Boss | Tell overlapping floor warnings | Counter save armor recovery | Codex death_source_boss_arena_hazard"
	if _trap_active or _is_trap_room():
		return "Room Hazard / Trap | Tell warning lanes | Counter cross after pulse | Codex death_source_trap_room_hazard"
	if _challenge_hazards_active or _is_challenge_hazard_variant():
		return "Room Hazard / Challenge | Tell challenge warning zones | Counter finish rule before greed | Codex death_source_challenge_room_hazard"
	return "Room Hazard | Tell floor warning zones | Counter keep movement lanes open | Codex death_source_%s" % _get_hazard_source_id()


func _get_hazard_counter_tags() -> Array:
	if not hazard_counter_tags.is_empty():
		var configured: Array = []
		for tag in hazard_counter_tags:
			configured.append(str(tag))
		return configured
	if _boss_arena_active or _is_boss_room():
		return ["survival", "armor", "damage"]
	if _trap_active or _is_trap_room():
		return ["speed", "survival", "armor"]
	if _challenge_hazards_active or _is_challenge_hazard_variant():
		return ["crowd_control", "damage", "survival"]
	return ["speed", "survival"]


func _on_entry_area_body_entered(body: Node) -> void:
	if _room_stopped or state != RoomState.UNENTERED or not body.is_in_group("player"):
		return

	state = RoomState.ENTERED
	_emit_state()
	if auto_clear_on_enter:
		call_deferred("_clear_room")
	else:
		call_deferred("_begin_combat")


func _check_initial_overlap() -> void:
	if state != RoomState.UNENTERED:
		return

	for body in entry_area.get_overlapping_bodies():
		_on_entry_area_body_entered(body)


func _begin_combat() -> void:
	state = RoomState.COMBAT
	_current_wave_index = -1
	_wave_transition_pending = false
	_set_exit_locked(lock_doors_during_combat)
	if _is_boss_room():
		_setup_boss_arena()
	_emit_state()
	Events.room_started.emit(self)
	if _is_trap_room():
		_begin_trap_room()
		return
	if _is_challenge_hazard_variant():
		_begin_challenge_hazards()
	_start_next_wave()


func _start_next_wave() -> void:
	_wave_transition_pending = false
	if _room_stopped or state != RoomState.COMBAT:
		return

	_current_wave_index += 1
	if _current_wave_index >= wave_enemy_counts.size():
		_clear_room()
		return

	_spawn_wave(wave_enemy_counts[_current_wave_index])


func _spawn_wave(enemy_count: int) -> void:
	var spawn_points := _get_spawn_points()
	if spawn_points.is_empty() or enemy_scene == null:
		_clear_room()
		return

	var player := get_tree().get_first_node_in_group("player") as Node2D
	for index in range(enemy_count):
		var scene := _get_enemy_scene_for_spawn(index)
		var enemy := scene.instantiate() as Node2D
		if enemy == null:
			continue

		get_tree().current_scene.add_child(enemy)
		enemy.global_position = _get_safe_spawn_position(spawn_points, index, player)
		_apply_spawn_modifiers(enemy)
		_living_enemies.append(enemy)


func _on_enemy_died(enemy: Node) -> void:
	if state != RoomState.COMBAT:
		return

	_living_enemies.erase(enemy)
	_prune_living_enemies()
	if _living_enemies.is_empty() and not _wave_transition_pending:
		_wave_transition_pending = true
		var timer := get_tree().create_timer(time_between_waves)
		timer.timeout.connect(_start_next_wave)


func _on_enemy_spawned(enemy: Node) -> void:
	if state != RoomState.COMBAT or _living_enemies.has(enemy):
		return
	_living_enemies.append(enemy)


func _clear_room() -> void:
	if _room_stopped:
		return

	_wave_transition_pending = false
	_deactivate_trap_room()
	_deactivate_challenge_hazards()
	_deactivate_boss_arena()
	state = RoomState.CLEARED
	_set_exit_locked(false)
	_emit_state()
	Events.room_cleared.emit(self)
	_spawn_reward_once()


func _spawn_reward_once() -> void:
	if _reward_spawned or reward_scene == null:
		return

	_reward_spawned = true
	var reward := reward_scene.instantiate() as Node2D
	if reward == null:
		return

	_spawned_reward = reward
	_apply_reward_biome_config(reward)
	get_tree().current_scene.add_child(reward)
	reward.global_position = reward_spawn.global_position
	if _is_boss_room():
		reward.set("complete_run_on_open", complete_run_on_reward)
	Events.reward_spawned.emit(reward)


func _apply_reward_biome_config(reward: Node) -> void:
	_set_property_if_present(reward, "biome_id", biome_id)
	_set_property_if_present(reward, "biome_name", biome_name)
	_set_property_if_present(reward, "biome_reward_weight_multiplier", biome_reward_weight_multiplier)


func _set_property_if_present(target: Object, property_name: String, value) -> void:
	if target == null:
		return
	for property in target.get_property_list():
		if str(property.get("name", "")) == property_name:
			target.set(property_name, value)
			return


func _on_reward_collected(reward: Node, _collector: Node) -> void:
	if state != RoomState.CLEARED:
		return
	if not _is_own_reward(reward):
		return

	state = RoomState.REWARD_CLAIMED
	_emit_state()


func _is_own_reward(reward: Node) -> bool:
	if reward == null or not is_instance_valid(reward):
		return false
	if _spawned_reward == null or not is_instance_valid(_spawned_reward):
		return false
	return reward == _spawned_reward or _spawned_reward.is_ancestor_of(reward)


func _on_player_died() -> void:
	_room_stopped = true
	_deactivate_trap_room()
	_deactivate_challenge_hazards()
	_deactivate_boss_arena()


func _on_boss_phase_changed(boss: Node, phase: int) -> void:
	if phase < 2 or state != RoomState.COMBAT or not _is_boss_room():
		return
	if not _living_enemies.has(boss):
		return
	_activate_boss_arena(boss)


func _on_boss_died(boss: Node) -> void:
	if not _is_boss_room():
		return
	_deactivate_boss_arena()
	if state != RoomState.COMBAT:
		return

	_living_enemies.erase(boss)
	for enemy in _living_enemies:
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			enemy.queue_free()
	_living_enemies.clear()
	call_deferred("_clear_room")


func _set_exit_locked(locked: bool) -> void:
	for door in _doors:
		var connected := _is_connected_door(door)
		var should_block := locked if connected else true
		for child in door.get_children():
			if child is CollisionShape2D:
				(child as CollisionShape2D).set_deferred("disabled", not should_block)

		var visual := door.get_node_or_null("Visual") as CanvasItem
		if visual == null:
			continue

		visual.visible = true
		if not connected:
			visual.modulate = Color(0.35, 0.38, 0.42, 0.9)
		elif locked:
			visual.modulate = Color(0.9, 0.18, 0.15, 1.0)
		else:
			visual.modulate = Color(0.2, 0.95, 0.45, 0.55)


func _emit_state() -> void:
	Events.room_state_changed.emit(self, get_state_name())


func _get_spawn_points() -> Array[Marker2D]:
	var points: Array[Marker2D] = []
	for child in enemy_spawns.get_children():
		if child is Marker2D:
			points.append(child)
	return points


func _get_safe_spawn_position(spawn_points: Array[Marker2D], spawn_index: int, player: Node2D) -> Vector2:
	var fallback := spawn_points[spawn_index % spawn_points.size()].global_position + _get_spawn_stagger(spawn_index)
	if player == null or not is_instance_valid(player):
		return _clamp_to_room_spawn_bounds(fallback)

	var player_position := player.global_position
	var selected := spawn_points[spawn_index % spawn_points.size()]
	var selected_score := -1.0
	for offset in range(spawn_points.size()):
		var point := spawn_points[(spawn_index + offset) % spawn_points.size()]
		var distance := point.global_position.distance_to(player_position)
		var score := distance
		if distance >= SAFE_PLAYER_SPAWN_DISTANCE:
			score += 10000.0 - float(offset)
		if score > selected_score:
			selected = point
			selected_score = score

	var position := _clamp_to_room_spawn_bounds(selected.global_position + _get_spawn_stagger(spawn_index))
	if position.distance_to(player_position) >= SAFE_PLAYER_SPAWN_DISTANCE:
		return position

	var away := position - player_position
	if away.length_squared() <= 0.001:
		away = Vector2.RIGHT.rotated(TAU * float(spawn_index) / 8.0)
	position = player_position + away.normalized() * SAFE_PLAYER_SPAWN_DISTANCE
	return _clamp_to_room_spawn_bounds(position)


func _get_spawn_stagger(spawn_index: int) -> Vector2:
	if SPAWN_STAGGER_RADIUS <= 0.0:
		return Vector2.ZERO

	var angle := TAU * float(spawn_index % 8) / 8.0
	var ring := 1.0 + floorf(float(spawn_index) / 8.0) * 0.35
	return Vector2.RIGHT.rotated(angle) * SPAWN_STAGGER_RADIUS * ring


func _clamp_to_room_spawn_bounds(position: Vector2) -> Vector2:
	return Vector2(
		clampf(position.x, global_position.x - ROOM_SAFE_SPAWN_EXTENTS.x, global_position.x + ROOM_SAFE_SPAWN_EXTENTS.x),
		clampf(position.y, global_position.y - ROOM_SAFE_SPAWN_EXTENTS.y, global_position.y + ROOM_SAFE_SPAWN_EXTENTS.y)
	)


func _get_doors() -> Array[StaticBody2D]:
	var doors: Array[StaticBody2D] = []

	if has_node("Doors"):
		for child in get_node("Doors").get_children():
			if child is StaticBody2D:
				doors.append(child)

	for door_name in [&"EntranceDoor", &"ExitDoor"]:
		if has_node(NodePath(door_name)):
			var door := get_node(NodePath(door_name))
			if door is StaticBody2D and not doors.has(door):
				doors.append(door)

	return doors


func _configure_directional_boundaries() -> void:
	if _has_connection("north"):
		_set_arena_wall_enabled("WallTop", false)
		_ensure_directional_door("NorthDoor", "north", Vector2(0, -380), Vector2(1260, 42))
	if _has_connection("south"):
		_set_arena_wall_enabled("WallBottom", false)
		_ensure_directional_door("SouthDoor", "south", Vector2(0, 380), Vector2(1260, 42))


func _set_arena_wall_enabled(wall_name: String, enabled: bool) -> void:
	if get_parent() == null:
		return
	var wall := get_parent().get_node_or_null("Arena/%s" % wall_name) as StaticBody2D
	if wall == null:
		return
	for child in wall.get_children():
		if child is CollisionShape2D:
			(child as CollisionShape2D).disabled = not enabled
		elif child is CanvasItem:
			(child as CanvasItem).visible = enabled


func _ensure_directional_door(door_name: String, direction: String, door_position: Vector2, size: Vector2) -> void:
	var parent := get_node_or_null("Doors") as Node2D
	if parent == null:
		parent = Node2D.new()
		parent.name = "Doors"
		add_child(parent)
	if parent.get_node_or_null(door_name) != null:
		return

	var door := StaticBody2D.new()
	door.name = door_name
	door.position = door_position
	door.collision_layer = 8
	door.collision_mask = 0
	door.set_meta("direction", direction)
	parent.add_child(door)

	var visual := Polygon2D.new()
	visual.name = "Visual"
	visual.color = Color(0.2, 0.95, 0.45, 0.55)
	visual.polygon = PackedVector2Array([
		Vector2(-size.x * 0.5, -size.y * 0.5),
		Vector2(size.x * 0.5, -size.y * 0.5),
		Vector2(size.x * 0.5, size.y * 0.5),
		Vector2(-size.x * 0.5, size.y * 0.5),
	])
	door.add_child(visual)

	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.disabled = true
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	door.add_child(collision)


func _is_connected_door(door: StaticBody2D) -> bool:
	return _has_connection(_get_door_direction(door))


func _has_connection(direction: String) -> bool:
	return connected_directions.has(direction)


func _get_door_direction(door: StaticBody2D) -> String:
	if door.has_meta("direction"):
		return str(door.get_meta("direction"))
	match String(door.name):
		"EntranceDoor":
			return "west"
		"ExitDoor":
			return "east"
		"NorthDoor":
			return "north"
		"SouthDoor":
			return "south"
	return ""


func _prune_living_enemies() -> void:
	var valid_enemies: Array[Node] = []
	for enemy in _living_enemies:
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			valid_enemies.append(enemy)
	_living_enemies = valid_enemies


func _get_enemy_scene_for_spawn(index: int) -> PackedScene:
	if not enemy_scenes.is_empty():
		return enemy_scenes[(index + maxi(_current_wave_index, 0)) % enemy_scenes.size()]
	return enemy_scene


func _apply_spawn_modifiers(enemy: Node2D) -> void:
	if not elite_enemies:
		return

	if not elite_modifier_profiles.is_empty() and enemy.has_method("apply_elite_profile"):
		var profile_index := maxi(_current_wave_index, 0) + _living_enemies.size()
		var profile := elite_modifier_profiles[profile_index % elite_modifier_profiles.size()]
		if profile is Resource:
			enemy.call("apply_elite_profile", profile)
			return

	if enemy.has_method("apply_elite_modifiers"):
		enemy.call(
			"apply_elite_modifiers",
			elite_health_multiplier,
			elite_damage_multiplier,
			elite_death_explosion_radius,
			elite_death_explosion_damage
		)


func _apply_layout_profile() -> void:
	_clear_layout_obstacles()
	if _apply_layout_data(layout_data):
		return

	match layout_profile:
		"training":
			_set_floor_color(Color(0.095, 0.105, 0.12, 1.0))
			_set_spawn_positions([
				Vector2(250, -105),
				Vector2(-250, -85),
				Vector2(285, 145),
				Vector2(-225, 165),
			])
			reward_spawn.position = Vector2(0, -80)
		"reward_cache":
			_set_floor_color(Color(0.08, 0.12, 0.105, 1.0))
			_set_spawn_positions([
				Vector2(300, -130),
				Vector2(-300, -130),
				Vector2(300, 150),
				Vector2(-300, 150),
			])
			reward_spawn.position = Vector2(0, -20)
		"pillars":
			_set_floor_color(Color(0.105, 0.095, 0.125, 1.0))
			_set_spawn_positions([
				Vector2(390, -205),
				Vector2(-390, -205),
				Vector2(390, 205),
				Vector2(-390, 205),
			])
			reward_spawn.position = Vector2(0, -35)
			_add_layout_obstacle("PillarNW", Vector2(-245, -145), Vector2(74, 74))
			_add_layout_obstacle("PillarNE", Vector2(245, -145), Vector2(74, 74))
			_add_layout_obstacle("PillarSW", Vector2(-245, 145), Vector2(74, 74))
			_add_layout_obstacle("PillarSE", Vector2(245, 145), Vector2(74, 74))
		"market":
			_set_floor_color(Color(0.105, 0.105, 0.085, 1.0))
			_set_spawn_positions([
				Vector2(360, -165),
				Vector2(-360, -165),
				Vector2(360, 165),
				Vector2(-360, 165),
			])
			reward_spawn.position = Vector2(0, -25)
			_add_layout_obstacle("MarketStallNW", Vector2(-310, -190), Vector2(176, 58), Color(0.24, 0.2, 0.13, 1.0))
			_add_layout_obstacle("MarketStallNE", Vector2(310, -190), Vector2(176, 58), Color(0.24, 0.2, 0.13, 1.0))
			_add_layout_obstacle("MarketStallSW", Vector2(-310, 190), Vector2(176, 58), Color(0.24, 0.2, 0.13, 1.0))
			_add_layout_obstacle("MarketStallSE", Vector2(310, 190), Vector2(176, 58), Color(0.24, 0.2, 0.13, 1.0))
		"boss_arena":
			_set_floor_color(Color(0.12, 0.085, 0.095, 1.0))
			_set_spawn_positions([
				Vector2(0, -90),
				Vector2(-300, 150),
				Vector2(300, 150),
				Vector2(0, 210),
			])
			reward_spawn.position = Vector2(0, -30)
			_add_layout_obstacle("BossLeftCover", Vector2(-500, 0), Vector2(72, 180), Color(0.28, 0.16, 0.18, 1.0))
			_add_layout_obstacle("BossRightCover", Vector2(500, 0), Vector2(72, 180), Color(0.28, 0.16, 0.18, 1.0))
		_:
			layout_profile = "crossfire"
			_set_floor_color(Color(0.095, 0.105, 0.12, 1.0))
			_set_spawn_positions([
				Vector2(370, -210),
				Vector2(-370, -190),
				Vector2(390, 205),
				Vector2(-390, 185),
			])
			reward_spawn.position = Vector2(0, -40)
			_add_layout_obstacle("CrossfireNorth", Vector2(0, -150), Vector2(92, 92))
			_add_layout_obstacle("CrossfireSouth", Vector2(0, 150), Vector2(92, 92))


func _apply_layout_data(data: Resource) -> bool:
	if data == null:
		return false

	var layout := data as RoomLayoutData
	if layout == null:
		return false

	if not str(layout.id).is_empty():
		layout_profile = str(layout.id)

	_set_floor_color(layout.floor_color)
	if layout.spawn_positions.size() > 0:
		_set_spawn_positions(layout.spawn_positions)

	reward_spawn.position = layout.reward_position

	var obstacle_count: int = layout.get_obstacle_count()
	for index in range(obstacle_count):
		var obstacle_name := "%sObstacle%d" % [layout_profile.capitalize().replace(" ", ""), index + 1]
		if index < layout.obstacle_names.size():
			obstacle_name = str(layout.obstacle_names[index])

		var obstacle_color := Color(0.24, 0.26, 0.29, 1.0)
		if index < layout.obstacle_colors.size():
			obstacle_color = layout.obstacle_colors[index]

		_add_layout_obstacle(
			obstacle_name,
			layout.obstacle_positions[index],
			layout.obstacle_sizes[index],
			obstacle_color
		)

	return true


func _set_spawn_positions(positions) -> void:
	var spawn_points := _get_spawn_points()
	if spawn_points.is_empty():
		return
	if positions == null or positions.size() <= 0:
		return

	for index in range(spawn_points.size()):
		spawn_points[index].position = positions[index % positions.size()]


func _set_floor_color(color: Color) -> void:
	if get_parent() == null:
		return
	var floor := get_parent().get_node_or_null("Arena/Floor") as Polygon2D
	if floor != null:
		floor.color = _get_biome_tinted_color(color, biome_visual_floor_tint, biome_visual_tint_strength)


func _get_floor_color() -> Color:
	if get_parent() == null:
		return Color(0.0, 0.0, 0.0, 0.0)
	var floor := get_parent().get_node_or_null("Arena/Floor") as Polygon2D
	if floor == null:
		return Color(0.0, 0.0, 0.0, 0.0)
	return floor.color


func _apply_biome_wall_visuals() -> void:
	if get_parent() == null:
		return
	var wall_names := [
		"WallTop",
		"WallBottom",
		"WallLeftTop",
		"WallLeftBottom",
		"WallRightTop",
		"WallRightBottom",
	]
	for wall_name in wall_names:
		var wall := get_parent().get_node_or_null("Arena/%s" % wall_name) as StaticBody2D
		if wall == null:
			continue
		var visual := wall.get_node_or_null("Visual") as Polygon2D
		if visual != null:
			visual.color = biome_visual_wall_color
		_configure_surface_visual(
			wall,
			0,
			_get_static_body_size(wall),
			biome_visual_wall_texture_modulate,
			biome_visual_wall_texture_opacity
		)


func _apply_biome_terrain_visual() -> void:
	if get_parent() == null:
		return
	var terrain_layer := get_parent().get_node_or_null("Arena/TerrainLayer")
	if terrain_layer != null and terrain_layer.has_method("configure"):
		terrain_layer.call(
			"configure",
			biome_visual_floor_texture_path,
			biome_visual_floor_texture_modulate,
			biome_visual_floor_texture_opacity
		)


func _get_terrain_layer_summary() -> Dictionary:
	if get_parent() == null:
		return {}
	var terrain_layer := get_parent().get_node_or_null("Arena/TerrainLayer")
	if terrain_layer != null and terrain_layer.has_method("get_terrain_summary"):
		return terrain_layer.call("get_terrain_summary")
	return {}


func _get_first_wall_color() -> Color:
	if get_parent() == null:
		return Color(0.0, 0.0, 0.0, 0.0)
	var visual := get_parent().get_node_or_null("Arena/WallTop/Visual") as Polygon2D
	if visual == null:
		return Color(0.0, 0.0, 0.0, 0.0)
	return visual.color


func _get_first_wall_surface_summary() -> Dictionary:
	if get_parent() == null:
		return {}
	var surface := get_parent().get_node_or_null("Arena/WallTop/SurfaceVisual")
	return _get_surface_visual_summary(surface)


func _get_first_obstacle_surface_summary() -> Dictionary:
	var obstacles := get_node_or_null("LayoutObstacles")
	if obstacles == null:
		return {}
	for obstacle in obstacles.get_children():
		var surface := obstacle.get_node_or_null("SurfaceVisual")
		if surface != null:
			return _get_surface_visual_summary(surface)
	return {}


func _get_surface_visual_summary(surface: Node) -> Dictionary:
	if surface != null and surface.has_method("get_surface_summary"):
		return surface.call("get_surface_summary")
	return {}


func _get_static_body_size(body: StaticBody2D) -> Vector2:
	var collision := body.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision != null and collision.shape is RectangleShape2D:
		return (collision.shape as RectangleShape2D).size
	return Vector2.ZERO


func _configure_surface_visual(
	parent: Node2D,
	surface_kind: int,
	surface_size: Vector2,
	color_modulate: Color,
	opacity: float
) -> void:
	var surface := parent.get_node_or_null("SurfaceVisual")
	if surface == null:
		surface = BIOME_SURFACE_VISUAL_SCRIPT.new()
		surface.name = "SurfaceVisual"
		parent.add_child(surface)
	if surface.has_method("configure"):
		surface.call(
			"configure",
			biome_visual_surface_atlas_path,
			surface_kind,
			surface_size,
			color_modulate,
			opacity
		)


func _get_biome_tinted_color(base_color: Color, tint_color: Color, strength: float) -> Color:
	var tint_amount := clampf(strength, 0.0, 1.0)
	var color := base_color.lerp(tint_color, tint_amount)
	color.a = base_color.a
	return color


func _clear_layout_obstacles() -> void:
	var existing := get_node_or_null("LayoutObstacles")
	if existing != null:
		remove_child(existing)
		existing.free()


func _add_layout_obstacle(obstacle_name: String, obstacle_position: Vector2, size: Vector2, color: Color = Color(0.24, 0.26, 0.29, 1.0)) -> void:
	var parent := get_node_or_null("LayoutObstacles") as Node2D
	if parent == null:
		parent = Node2D.new()
		parent.name = "LayoutObstacles"
		add_child(parent)

	var body := StaticBody2D.new()
	body.name = obstacle_name
	body.position = obstacle_position
	body.collision_layer = 8
	body.collision_mask = 0
	parent.add_child(body)

	var visual := Polygon2D.new()
	visual.name = "Visual"
	visual.color = _get_biome_tinted_color(color, biome_visual_obstacle_tint, biome_visual_tint_strength)
	visual.polygon = PackedVector2Array([
		Vector2(-size.x * 0.5, -size.y * 0.5),
		Vector2(size.x * 0.5, -size.y * 0.5),
		Vector2(size.x * 0.5, size.y * 0.5),
		Vector2(-size.x * 0.5, size.y * 0.5),
	])
	body.add_child(visual)
	_configure_surface_visual(
		body,
		1,
		size,
		biome_visual_obstacle_texture_modulate,
		biome_visual_obstacle_texture_opacity
	)

	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)


func _is_boss_room() -> bool:
	return room_type == "boss" or room_type == "boss_placeholder"


func _is_trap_room() -> bool:
	return room_type == "trap"


func _is_challenge_hazard_variant() -> bool:
	return room_type == "challenge" and challenge_variant == "hazard_rush" and trap_hazards_enabled


func _begin_trap_room() -> void:
	if not trap_hazards_enabled:
		_clear_room()
		return

	_trap_active = true
	_trap_timer = maxf(trap_survival_duration, trap_hazard_warning_duration + 0.1)
	_trap_hazard_timer = 0.1
	_trap_cycle_index = 0
	_prune_trap_warnings()


func _begin_challenge_hazards() -> void:
	_challenge_hazards_active = true
	_challenge_hazard_timer = 0.1
	_trap_cycle_index = 0
	_prune_trap_warnings()


func _tick_challenge_hazards(delta: float) -> void:
	if not _challenge_hazards_active:
		return

	_challenge_hazard_timer = maxf(_challenge_hazard_timer - delta, 0.0)
	if _challenge_hazard_timer > 0.0:
		return

	_spawn_trap_hazard_cycle()
	_challenge_hazard_timer = maxf(trap_hazard_interval, trap_hazard_warning_duration * 0.5)


func _deactivate_challenge_hazards() -> void:
	_challenge_hazards_active = false
	_challenge_hazard_timer = 0.0


func _tick_trap_room(delta: float) -> void:
	if not _trap_active:
		return

	_trap_timer = maxf(_trap_timer - delta, 0.0)
	_trap_hazard_timer = maxf(_trap_hazard_timer - delta, 0.0)
	if _trap_hazard_timer <= 0.0:
		_spawn_trap_hazard_cycle()
		_trap_hazard_timer = maxf(trap_hazard_interval, trap_hazard_warning_duration * 0.5)

	if _trap_timer <= 0.0:
		_clear_room()


func _deactivate_trap_room() -> void:
	_trap_active = false
	_trap_timer = 0.0
	_trap_hazard_timer = 0.0
	for warning in _trap_warnings:
		if is_instance_valid(warning) and not warning.is_queued_for_deletion():
			warning.queue_free()
	_trap_warnings.clear()


func _spawn_trap_hazard_cycle() -> void:
	if DANGER_WARNING_SCENE == null:
		return

	var count := mini(maxi(trap_hazard_cycle_size, 1), TRAP_HAZARD_POSITIONS.size())
	for step in range(count):
		var index := (_trap_cycle_index + step * 2) % TRAP_HAZARD_POSITIONS.size()
		var warning := DANGER_WARNING_SCENE.instantiate() as Node2D
		if warning == null:
			continue

		get_tree().current_scene.add_child(warning)
		warning.global_position = global_position + TRAP_HAZARD_POSITIONS[index]
		warning.call(
			"configure_circle",
			trap_hazard_radius,
			trap_hazard_warning_duration,
			Color(1.0, 0.38, 0.1, 0.34),
			trap_hazard_damage,
			self
		)
		_trap_warnings.append(warning)
	_trap_cycle_index = (_trap_cycle_index + 1) % TRAP_HAZARD_POSITIONS.size()
	_prune_trap_warnings()


func _prune_trap_warnings() -> void:
	var valid_warnings: Array[Node] = []
	for warning in _trap_warnings:
		if is_instance_valid(warning) and not warning.is_queued_for_deletion():
			valid_warnings.append(warning)
	_trap_warnings = valid_warnings


func _setup_boss_arena() -> void:
	if not boss_arena_hazards_enabled or not _boss_arena_markers.is_empty():
		return

	for position in BOSS_ARENA_HAZARD_POSITIONS:
		var marker := Polygon2D.new()
		marker.name = "BossArenaHazardMarker"
		marker.z_index = -1
		marker.position = position
		marker.polygon = _build_circle_polygon(boss_arena_hazard_radius * 0.82, 28)
		marker.color = Color(0.95, 0.12, 0.18, 0.12)
		marker.add_to_group("boss_arena_hazard_markers")
		add_child(marker)
		_boss_arena_markers.append(marker)


func _activate_boss_arena(boss: Node = null) -> void:
	if _boss_arena_active or not boss_arena_hazards_enabled:
		return

	_setup_boss_arena()
	_boss_arena_active = true
	_boss_arena_hazard_timer = 0.15
	if boss != null and boss.has_method("get_phase_transition_remaining"):
		_boss_arena_hazard_timer = maxf(float(boss.call("get_phase_transition_remaining")) + 0.2, _boss_arena_hazard_timer)
	_boss_arena_cycle_index = 0
	_set_boss_arena_marker_colors(PackedInt32Array())


func _deactivate_boss_arena() -> void:
	_boss_arena_active = false
	_boss_arena_hazard_timer = 0.0
	_set_boss_arena_marker_colors(PackedInt32Array())
	for warning in _boss_arena_warnings:
		if is_instance_valid(warning) and not warning.is_queued_for_deletion():
			warning.queue_free()
	_boss_arena_warnings.clear()


func _spawn_boss_arena_hazard_cycle() -> void:
	if DANGER_WARNING_SCENE == null:
		return

	var selected_indexes := PackedInt32Array()
	var count := mini(maxi(boss_arena_hazard_cycle_size, 1), BOSS_ARENA_HAZARD_POSITIONS.size())
	for step in range(count):
		selected_indexes.append((_boss_arena_cycle_index + step * 2) % BOSS_ARENA_HAZARD_POSITIONS.size())
	_boss_arena_cycle_index = (_boss_arena_cycle_index + 1) % BOSS_ARENA_HAZARD_POSITIONS.size()
	_set_boss_arena_marker_colors(selected_indexes)

	for index in selected_indexes:
		var warning := DANGER_WARNING_SCENE.instantiate() as Node2D
		if warning == null:
			continue

		get_tree().current_scene.add_child(warning)
		warning.global_position = global_position + BOSS_ARENA_HAZARD_POSITIONS[index]
		warning.call(
			"configure_circle",
			boss_arena_hazard_radius,
			boss_arena_hazard_warning_duration,
			Color(1.0, 0.08, 0.16, 0.36),
			boss_arena_hazard_damage,
			self
		)
		_boss_arena_warnings.append(warning)
	_prune_boss_arena_warnings()


func _set_boss_arena_marker_colors(active_indexes: PackedInt32Array) -> void:
	for index in range(_boss_arena_markers.size()):
		var marker := _boss_arena_markers[index]
		if not is_instance_valid(marker):
			continue
		if active_indexes.has(index):
			marker.color = Color(1.0, 0.08, 0.16, 0.28)
		else:
			marker.color = Color(0.95, 0.12, 0.18, 0.12)


func _prune_boss_arena_warnings() -> void:
	var valid_warnings: Array[Node] = []
	for warning in _boss_arena_warnings:
		if is_instance_valid(warning) and not warning.is_queued_for_deletion():
			valid_warnings.append(warning)
	_boss_arena_warnings = valid_warnings


func _build_circle_polygon(radius: float, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	var segment_count := maxi(segments, 8)
	for index in range(segment_count):
		var angle := TAU * float(index) / float(segment_count)
		points.append(Vector2.RIGHT.rotated(angle) * radius)
	return points

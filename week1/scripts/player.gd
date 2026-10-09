extends CharacterBody2D

signal health_changed(health: int)
signal died

## How far either side of the player's centre there must be ground for a spot to count as safe to respawn on.
const SAFE_GROUND_REACH := 12.0
## Where the player appears relative to the level's campfire (its base on the ground): just to its right.
const SPAWN_OFFSET := Vector2(16, -11)
## Distance from the player's origin down to their feet (bottom of the collision box).
const FEET_Y := 12.0
## Real-time seconds the game freezes on a big hit (the mushroom's headbutt), to sell the impact.
const HIT_STOP_TIME := 0.12

## 6 health = 3 hearts (each heart is 2 health, so 1 damage = half a heart).
@export var max_health := 6
## Seconds of invincibility after being hit.
@export var invincible_time := 1.0

## How far (in pixels) below the bottom of the level's tiles the player can fall before
## counting as out of bounds.
@export var fall_death_margin := 48.0
## Damage taken for falling out of the level (2 = one full heart).
@export var fall_damage := 2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var health := 0
## -1 or 1: which way the last hit knocked the player (read by the Hurt state).
var knockback_direction := 1.0
var _invincible_until_msec := 0
var _kill_y := INF
## Last position where the player stood on the ground; where they respawn after falling out.
var _safe_position := Vector2.ZERO

func _ready() -> void:
	health = max_health
	_move_to_spawn_point()
	_safe_position = global_position
	Inventory.begin_level()
	Tutorial.on_level_started(get_parent().scene_file_path)
	# Deferred: the level is still adding its own children right now.
	Graveyard.on_level_started.call_deferred(get_parent())
	var tilemap := get_parent().get_node_or_null("TileMapLayer") as TileMapLayer
	if tilemap:
		var bottom_row := tilemap.get_used_rect().end.y
		var bottom := tilemap.to_global(tilemap.map_to_local(Vector2i(0, bottom_row))).y
		_kill_y = bottom + fall_death_margin
	if Transition.closed:
		_open_iris()

## Start next to this level's campfire, facing right.
func _move_to_spawn_point() -> void:
	for spawn in get_tree().get_nodes_in_group("spawn_point"):
		if get_parent().is_ancestor_of(spawn):
			global_position = spawn.global_position + SPAWN_OFFSET
			sprite.flip_h = false
			return

## After a respawn, open the iris back up around the player.
func _open_iris() -> void:
	# Wait a frame so the camera has moved to the player.
	await get_tree().process_frame
	Transition.iris_in(get_global_transform_with_canvas().origin)

func _physics_process(_delta: float) -> void:
	if health <= 0:
		return
	if is_on_floor() and _has_ground_both_sides():
		_safe_position = global_position
	if global_position.y > _kill_y:
		fall_out()

## True when there's ground a little past both of the player's feet, so a respawn
## here won't leave them teetering on (and walking straight off) a ledge.
func _has_ground_both_sides() -> bool:
	var space := get_world_2d().direct_space_state
	for side in [-SAFE_GROUND_REACH, SAFE_GROUND_REACH]:
		var from := global_position + Vector2(side, 0)
		var query := PhysicsRayQueryParameters2D.create(from, from + Vector2(0, 24), collision_mask, [get_rid()])
		if space.intersect_ray(query).is_empty():
			return false
	return true

## Fell out of the level: take fall_damage (ignoring invincibility) and respawn at
## the last safe spot, or die if that empties the hearts.
func fall_out() -> void:
	health = maxi(health - fall_damage, 0)
	_invincible_until_msec = Time.get_ticks_msec() + int(invincible_time * 1000.0)
	health_changed.emit(health)
	if health == 0:
		_die(true)
		return
	global_position = _safe_position
	velocity = Vector2.ZERO
	_flash()

func is_invincible() -> bool:
	return Time.get_ticks_msec() < _invincible_until_msec

## `from_position` is where the hit came from; if given, the player is knocked away from it.
## `big_hit` adds a brief freeze before the knockback (e.g. the mushroom's headbutt).
func take_damage(amount: int, from_position := Vector2.INF, big_hit := false) -> void:
	if health <= 0 or is_invincible():
		return
	health = maxi(health - amount, 0)
	_invincible_until_msec = Time.get_ticks_msec() + int(invincible_time * 1000.0)
	health_changed.emit(health)
	if big_hit:
		_hit_stop()
	if health == 0:
		_die()
		return
	_flash()
	if from_position != Vector2.INF:
		var away := signf(global_position.x - from_position.x)
		# Directly on top of the source: knock back opposite to the way we're facing.
		knockback_direction = away if away != 0.0 else (1.0 if sprite.flip_h else -1.0)
		$StateMachine.change_state(&"hurt")

## Restores health, capped at max_health. Returns false if already full (nothing healed).
func heal(amount: int) -> bool:
	if health <= 0 or health >= max_health:
		return false
	health = mini(health + amount, max_health)
	health_changed.emit(health)
	return true

## Freeze the whole game for a split second, then resume (the knockback plays after).
func _hit_stop() -> void:
	Engine.time_scale = 0.0
	# A real-time timer (ignores time scale). Resuming goes through Engine directly so it
	# still happens even if the player is freed in the meantime (e.g. the level changes).
	var timer := get_tree().create_timer(HIT_STOP_TIME, true, false, true)
	timer.timeout.connect(Engine.set_time_scale.bind(1.0))

func _flash() -> void:
	var tween := create_tween().set_loops(int(invincible_time / 0.2))
	tween.tween_property(sprite, "modulate:a", 0.3, 0.1)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.1)

## Where the tombstone goes: the ground under the player, or the last safe spot
## if they fell out of the level (the pit bottom is off-screen).
func _tombstone_position(fell: bool) -> Vector2:
	if not fell:
		var query := PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(0, 200), collision_mask, [get_rid()])
		var hit := get_world_2d().direct_space_state.intersect_ray(query)
		if not hit.is_empty():
			return hit.position
	return _safe_position + Vector2(0, FEET_Y)

func _die(fell := false) -> void:
	died.emit()
	Graveyard.add_tombstone(get_parent(), _tombstone_position(fell))
	$StateMachine.process_mode = Node.PROCESS_MODE_DISABLED
	sprite.play("fall")
	sprite.modulate = Color(1, 0.4, 0.4)
	await get_tree().create_timer(0.5).timeout
	# Close the screen in on the player, then restart the level (back at the campfire).
	await Transition.iris_out(get_global_transform_with_canvas().origin)
	Inventory.restore_level_start()
	get_tree().reload_current_scene()

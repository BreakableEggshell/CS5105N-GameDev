extends CharacterBody2D

signal health_changed(health: int)
signal died

## How far either side of the player's centre there must be ground for a spot to count as safe to respawn on.
const SAFE_GROUND_REACH := 12.0

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
var _invincible_until_msec := 0
var _kill_y := INF
## Last position where the player stood on the ground; where they respawn after falling out.
var _safe_position := Vector2.ZERO

func _ready() -> void:
	health = max_health
	_safe_position = global_position
	var tilemap := get_parent().get_node_or_null("TileMapLayer") as TileMapLayer
	if tilemap:
		var bottom_row := tilemap.get_used_rect().end.y
		var bottom := tilemap.to_global(tilemap.map_to_local(Vector2i(0, bottom_row))).y
		_kill_y = bottom + fall_death_margin

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
		_die()
		return
	global_position = _safe_position
	velocity = Vector2.ZERO
	_flash()

func is_invincible() -> bool:
	return Time.get_ticks_msec() < _invincible_until_msec

func take_damage(amount: int) -> void:
	if health <= 0 or is_invincible():
		return
	health = maxi(health - amount, 0)
	_invincible_until_msec = Time.get_ticks_msec() + int(invincible_time * 1000.0)
	health_changed.emit(health)
	if health == 0:
		_die()
	else:
		_flash()

## Restores health, capped at max_health. Returns false if already full (nothing healed).
func heal(amount: int) -> bool:
	if health <= 0 or health >= max_health:
		return false
	health = mini(health + amount, max_health)
	health_changed.emit(health)
	return true

func _flash() -> void:
	var tween := create_tween().set_loops(int(invincible_time / 0.2))
	tween.tween_property(sprite, "modulate:a", 0.3, 0.1)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.1)

func _die() -> void:
	died.emit()
	$StateMachine.process_mode = Node.PROCESS_MODE_DISABLED
	sprite.modulate = Color(1, 0.4, 0.4)
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

extends CharacterBody2D

signal health_changed(health: int)
signal died

## 6 health = 3 hearts (each heart is 2 health, so 1 damage = half a heart).
@export var max_health := 6
## Seconds of invincibility after being hit.
@export var invincible_time := 1.0

## How far (in pixels) below the bottom of the level's tiles the player can fall before dying.
@export var fall_death_margin := 48.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var health := 0
var _invincible_until_msec := 0
var _kill_y := INF

func _ready() -> void:
	health = max_health
	var tilemap := get_parent().get_node_or_null("TileMapLayer") as TileMapLayer
	if tilemap:
		var bottom_row := tilemap.get_used_rect().end.y
		var bottom := tilemap.to_global(tilemap.map_to_local(Vector2i(0, bottom_row))).y
		_kill_y = bottom + fall_death_margin

func _physics_process(_delta: float) -> void:
	if health > 0 and global_position.y > _kill_y:
		fall_out()

## Instantly lose all health (e.g. fell out of the level).
func fall_out() -> void:
	health = 0
	health_changed.emit(health)
	_die()

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

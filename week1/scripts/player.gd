extends CharacterBody2D

signal health_changed(health: int)
signal died

## 10 health = 5 hearts (each heart is 2 health, so 1 damage = half a heart).
@export var max_health := 10
## Seconds of invincibility after being hit.
@export var invincible_time := 1.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var health := 0
var _invincible_until_msec := 0

func _ready() -> void:
	health = max_health

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

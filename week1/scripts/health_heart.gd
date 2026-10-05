extends Node2D

## 2 = full, 1 = half, 0 = gone.
var value := 2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.play("full")

func set_value(new_value: int) -> void:
	if new_value == value:
		return
	var lost := new_value < value
	value = new_value
	if lost:
		sprite.play("hurt")
		await sprite.animation_finished
	_show_value()

func _show_value() -> void:
	match value:
		2: sprite.play("full")
		1: sprite.play("half")
		_: queue_free()

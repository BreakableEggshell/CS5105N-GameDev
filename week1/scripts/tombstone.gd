extends Node2D
## A tombstone marking where the player died. Its origin is its base on the ground.

@onready var sprite: Sprite2D = $Sprite2D

## Falls in from above and bounces as it lands.
func drop() -> void:
	var rest_y := sprite.position.y
	sprite.position.y = rest_y - 40.0
	var tween := create_tween()
	tween.tween_property(sprite, "position:y", rest_y, 0.45).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

extends Area2D
## Heals the player when touched. Stays in place if the player is already at full health.

const HEAL_SOUND := preload("res://assets/music_sfx/hp_recovery.mp3")

## Health restored (1 = half a heart).
@export var heal_amount := 1

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	# Gentle bobbing so it reads as a pickup.
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "position:y", -2.0, 0.6)
	tween.tween_property(sprite, "position:y", 2.0, 0.6)

func _physics_process(_delta: float) -> void:
	# Checked every frame (not just on enter) so a player standing on it
	# at full health still picks it up after taking damage.
	for body in get_overlapping_bodies():
		if body.is_in_group("player") and body.heal(heal_amount):
			Sfx.play(HEAL_SOUND)
			queue_free()
			return

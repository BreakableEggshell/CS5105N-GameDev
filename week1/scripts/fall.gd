extends State

## Air movement speed comes from walk.gd (AIR_SPEED, a bit faster than walking).
const Walk := preload("res://scripts/walk.gd")
const LANDING_DUST := preload("res://scene/landing_dust.tscn")
## Offset from the player's origin to their feet.
const FEET_OFFSET := Vector2(0, 12)

func enter() -> void:
	print("Fall State")
	sprite.play("fall")

func physics_update(delta: float) -> void:
	var dir := Input.get_axis("move_left", "move_right")
	face(dir)
	
	actor.velocity.y += gravity * delta
	actor.velocity.x = Input.get_axis("move_left", "move_right") * Walk.AIR_SPEED
	actor.move_and_slide()
	
	if wants_throw():
		transitioned.emit("throw")
	elif actor.is_on_floor():
		_spawn_landing_dust()
		if Input.get_axis("move_left", "move_right") != 0.0:
			transitioned.emit("walk")
		else:
			transitioned.emit("idle")

func _spawn_landing_dust() -> void:
	var dust := LANDING_DUST.instantiate()
	# Position before adding: the particles fire as soon as the node enters the tree.
	dust.position = actor.position + FEET_OFFSET  # same parent as the player
	actor.get_parent().add_child(dust)

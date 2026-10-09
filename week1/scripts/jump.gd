extends State

const JUMP_VELOCITY := -350.0
## Air movement speed comes from walk.gd (AIR_SPEED, a bit faster than walking).
const Walk := preload("res://scripts/walk.gd")

func enter() -> void:
	print("Jump State")
	sprite.play("jump")
	actor.velocity.y = JUMP_VELOCITY

func physics_update(delta: float) -> void:
	var dir := Input.get_axis("move_left", "move_right")
	face(dir)
	
	actor.velocity.y += gravity * delta
	actor.velocity.x = Input.get_axis("move_left", "move_right") * Walk.AIR_SPEED
	
	if Input.is_action_just_pressed("move_jump") and actor.velocity.y < 0.0:
		actor.velocity.y *= 0.4
	
	actor.move_and_slide()
	
	if wants_throw():
		transitioned.emit("throw")
	elif actor.velocity.y >= 0.0:
		transitioned.emit("fall")

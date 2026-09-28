extends State

const JUMP_VELOCITY := -450.0
const AIR_SPEED := 200.0

func enter() -> void:
	print("Jump State")
	actor.velocity.y = JUMP_VELOCITY

func physics_update(delta: float) -> void:
	actor.velocity.y += gravity * delta
	actor.velocity.x = Input.get_axis("move_left", "move_right") * AIR_SPEED
	
	if Input.is_action_just_pressed("move_jump") and actor.velocity.y < 0.0:
		actor.velocity.y *= 0.4
	
	actor.move_and_slide()
	
	if actor.velocity.y >= 0.0:
		transitioned.emit("fall")

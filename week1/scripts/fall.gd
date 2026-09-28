extends State

const AIR_SPEED := 200.0

func enter() -> void:
	print("Fall State")

func physics_update(delta: float) -> void:
	actor.velocity.y += gravity * delta
	actor.velocity.x = Input.get_axis("move_left", "move_right") * AIR_SPEED
	actor.move_and_slide()
	
	if actor.is_on_floor():
		if Input.get_axis("move_left", "move_right") != 0.0:
			transitioned.emit("walk")
		else:
			transitioned.emit("idle")

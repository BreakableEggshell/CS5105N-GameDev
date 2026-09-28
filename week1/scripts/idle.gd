extends State

func enter() -> void:
	print("Idle State")

func physics_update(delta: float) -> void:
	actor.velocity.x = move_toward(actor.velocity.x, 0.0, 1000.0 * delta)
	actor.move_and_slide()
	
	if actor.is_on_floor() and Input.get_axis("move_left", "move_right") != 0.0:
		transitioned.emit("walk")
	elif not actor.is_on_floor():
		transitioned.emit("fall")
	elif Input.is_action_just_pressed("move_jump"):
		transitioned.emit("jump")

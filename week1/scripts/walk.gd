extends State

const SPEED := 150.0

func enter() -> void:
	print("Walk State")
	sprite.play("walk")

func physics_update(delta: float) -> void:
	var dir:= Input.get_axis("move_left", "move_right")
	face(dir)
	
	actor.velocity.y += gravity * delta
	actor.velocity.x = dir * SPEED
	actor.move_and_slide()
	if not actor.is_on_floor():
		transitioned.emit("fall")
	elif Input.is_action_just_pressed("move_jump"):
		transitioned.emit("jump")
	elif wants_throw():
		transitioned.emit("throw")
	elif dir == 0.0:
		transitioned.emit("idle")

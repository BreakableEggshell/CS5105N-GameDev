extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -400.0
var current_speed = 0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("move_left", "move_right")
	if Input.is_action_pressed("move_sprint"):
		current_speed = SPEED + 100
	else:
		current_speed = SPEED
	if direction:
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		

	move_and_slide()

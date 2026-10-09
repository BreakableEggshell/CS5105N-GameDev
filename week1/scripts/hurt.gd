extends State
## Knocked back after taking a hit: a short hop away from the damage source,
## with no player control until landing.

## Horizontal speed of the knockback.
@export var knockback_speed := 120.0
## Upward speed of the knockback hop.
@export var knockback_jump := 220.0
## Minimum time in this state, so a hit on the ground still shows the hop.
@export var min_time := 0.15

var _time := 0.0

func enter() -> void:
	print("Hurt State")
	_time = 0.0
	# Knock away from whatever hit us; the player faces it while flying back.
	var away: float = actor.knockback_direction
	actor.velocity = Vector2(away * knockback_speed, -knockback_jump)
	face(-away)
	sprite.play("hurt")

func physics_update(delta: float) -> void:
	_time += delta
	actor.velocity.y += gravity * delta
	actor.move_and_slide()

	if _time >= min_time and actor.is_on_floor():
		if Input.get_axis("move_left", "move_right") != 0.0:
			transitioned.emit("walk")
		else:
			transitioned.emit("idle")

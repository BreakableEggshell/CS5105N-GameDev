extends State

const POTION := preload("res://scene/potion.tscn")
const SPAWN_OFFSET := Vector2(10.0, 0.0)
const THROW_SOUND := preload("res://assets/music_sfx/throw.mp3")

## Seconds before another potion can be thrown.
@export var cooldown := 0.5

var _ready_at_msec := 0

func is_off_cooldown() -> bool:
	return Time.get_ticks_msec() >= _ready_at_msec

## Seconds left until the next throw (0 when ready).
func cooldown_remaining() -> float:
	return maxf(_ready_at_msec - Time.get_ticks_msec(), 0) / 1000.0

func enter() -> void:
	print("Throw State")
	_ready_at_msec = Time.get_ticks_msec() + int(cooldown * 1000.0)
	var dir := -1.0 if sprite.flip_h else 1.0
	var potion := POTION.instantiate()
	potion.direction = dir
	# Add to the level, not the player, so the potion doesn't move with the player.
	actor.get_parent().add_child(potion)
	potion.global_position = actor.global_position + SPAWN_OFFSET * dir
	Inventory.use_potion()
	Sfx.play(THROW_SOUND)
	Tutorial.register_throw()

func physics_update(delta: float) -> void:
	actor.velocity.y += gravity * delta
	actor.move_and_slide()

	if not actor.is_on_floor():
		transitioned.emit("fall")
	elif Input.get_axis("move_left", "move_right") != 0.0:
		transitioned.emit("walk")
	else:
		transitioned.emit("idle")

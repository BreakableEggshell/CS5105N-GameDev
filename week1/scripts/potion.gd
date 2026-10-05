extends Area2D

const SMASH := preload("res://scene/potion_smash.tscn")

## Forward speed of the throw.
@export var speed := 200.0
## Seconds it flies straight forward before gravity starts pulling it down.
@export var hang_time := 0.15
## Multiplier on world gravity. Lower = floatier, slower fall.
@export var gravity_scale := 0.5
## Fraction of horizontal speed kept per second (1 = no air drag).
@export_range(0.0, 1.0) var air_drag := 0.8
## Safety net: free the potion if it never hits anything (e.g. falls off the map).
@export var max_lifetime := 5.0

var direction := 1.0
var velocity := Vector2.ZERO
var age := 0.0
var smashed := false
var fall_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	scale.x = absf(scale.x) * direction
	velocity = Vector2(direction * speed, 0.0)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	age += delta
	if age > hang_time:
		velocity.y += fall_gravity * gravity_scale * delta
	velocity.x *= pow(air_drag, delta)
	position += velocity * delta
	if age >= max_lifetime:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if smashed or body.is_in_group("player"):
		return
	smash()

func smash() -> void:
	smashed = true
	var particles := SMASH.instantiate()
	particles.position = position  # same parent as the potion
	get_parent().add_child.call_deferred(particles)
	queue_free()

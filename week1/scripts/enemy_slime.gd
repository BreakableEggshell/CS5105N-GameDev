extends CharacterBody2D

const DEATH_PARTICLES := preload("res://scene/slime_death.tscn")

@export var speed := 30.0
@export var max_health := 3
## Damage dealt to the player on touch (1 = half a heart).
@export var contact_damage := 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var edge_ray: RayCast2D = $EdgeRay
@onready var hitbox: Area2D = $Hitbox

var direction := 1.0
var health := 0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	health = max_health
	# Walk through the player instead of bumping into them; the hitbox handles touching.
	for player in get_tree().get_nodes_in_group("player"):
		add_collision_exception_with(player)
	_apply_direction()

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.x = direction * speed
	move_and_slide()

	var hit_wall := is_on_wall() and signf(get_wall_normal().x) == -direction
	var at_edge := is_on_floor() and not edge_ray.is_colliding()
	if hit_wall or at_edge:
		direction = -direction
		_apply_direction()

	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(contact_damage)

func _apply_direction() -> void:
	sprite.flip_h = direction < 0.0
	edge_ray.position.x = absf(edge_ray.position.x) * direction

func take_damage(amount: int) -> void:
	if health <= 0:
		return
	health -= amount
	if health <= 0:
		_die()
		return
	var tween := create_tween()
	sprite.modulate = Color(1, 0.3, 0.3)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.25)

func _die() -> void:
	# Stop moving, hurting, and being hit while the death animation plays.
	set_physics_process(false)
	set_deferred("collision_layer", 0)
	hitbox.set_deferred("monitoring", false)
	sprite.modulate = Color.WHITE
	var particles := DEATH_PARTICLES.instantiate()
	particles.position = position + Vector2(0, 8)  # same parent as the slime
	get_parent().add_child.call_deferred(particles)
	sprite.play("death")
	await sprite.animation_finished
	queue_free()

extends CharacterBody2D
## Mushroom enemy. Patrols like the slime; when it spots the player ahead of it,
## it winds up and launches itself forward, then is stunned for a moment before
## patrolling again.

const DEATH_PARTICLES := preload("res://scene/mushroom_death.tscn")
const DEATH_SOUND := preload("res://assets/music_sfx/enemy_death_sfx.mp3")
## Attack animation frames where the mushroom is lunging forward (frames 0-3 are the wind-up).
const LAUNCH_FRAMES := [4, 5, 6, 7, 8]
## Last wind-up frame (leaning back); the animation holds here before launching.
const WINDUP_HOLD_FRAME := 3
## Vertical offsets from origin to the centre of the mushroom's and player's collision boxes.
const BODY_CENTER_Y := 5.0
const PLAYER_CENTER_Y := 6.5

enum Mode { PATROL, ATTACK, STUN, DEAD }

@export var speed := 30.0
@export var max_health := 3
## Damage dealt to the player on touch (1 = half a heart).
@export var contact_damage := 1
## How far ahead (in pixels) the mushroom can spot the player.
@export var sight_range := 96.0
## Extra seconds spent leaning back before launching, so the player can react.
@export var windup_hold := 0.4
## Horizontal speed while launching.
@export var launch_speed := 200.0
## Seconds stunned after a launch.
@export var stun_time := 0.5
## Seconds after recovering from the stun before it can spot the player again.
@export var attack_cooldown := 1.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var edge_ray: RayCast2D = $EdgeRay
@onready var hitbox: Area2D = $Hitbox

## -1 = left, 1 = right. The sprite art faces left.
var direction := -1.0
var health := 0
var mode := Mode.PATROL
var _can_attack_at_msec := 0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	health = max_health
	for player in get_tree().get_nodes_in_group("player"):
		add_collision_exception_with(player)
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.frame_changed.connect(_on_frame_changed)
	_apply_direction()

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	var at_edge := is_on_floor() and not edge_ray.is_colliding()

	match mode:
		Mode.PATROL:
			velocity.x = direction * speed
			var hit_wall := is_on_wall() and signf(get_wall_normal().x) == -direction
			if hit_wall or at_edge:
				direction = -direction
				_apply_direction()
			elif Time.get_ticks_msec() >= _can_attack_at_msec and _sees_player():
				_start_attack()
		Mode.ATTACK:
			var launching: bool = sprite.frame in LAUNCH_FRAMES
			# Don't launch off a ledge.
			velocity.x = direction * launch_speed if launching and not at_edge else 0.0
		Mode.STUN:
			velocity.x = 0.0

	move_and_slide()

	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(contact_damage, global_position)

## True if the player is ahead of us, close, roughly level, and not behind a wall.
func _sees_player() -> bool:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null or player.health <= 0:
		return false
	var to_player := player.global_position - global_position
	if absf(to_player.x) > sight_range or absf(to_player.y) > 20.0:
		return false
	if signf(to_player.x) != direction:
		return false
	# Aim between body centres: both collision boxes sit a few pixels below their origins.
	var from := global_position + Vector2(0, BODY_CENTER_Y)
	var to := player.global_position + Vector2(0, PLAYER_CENTER_Y)
	var query := PhysicsRayQueryParameters2D.create(from, to, 1, [get_rid()])
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	return not hit.is_empty() and hit.collider == player

func _start_attack() -> void:
	mode = Mode.ATTACK
	velocity.x = 0.0
	sprite.play("attack")

## Hold the leaned-back wind-up pose for a moment before launching.
func _on_frame_changed() -> void:
	if mode == Mode.ATTACK and sprite.animation == &"attack" and sprite.frame == WINDUP_HOLD_FRAME:
		sprite.pause()
		await get_tree().create_timer(windup_hold, false).timeout
		if mode == Mode.ATTACK:
			sprite.play()

func _on_animation_finished() -> void:
	if mode == Mode.ATTACK:
		mode = Mode.STUN
		sprite.play("stun")
		await get_tree().create_timer(stun_time, false).timeout
		if mode == Mode.STUN:
			mode = Mode.PATROL
			sprite.play("run")
			_can_attack_at_msec = Time.get_ticks_msec() + int(attack_cooldown * 1000.0)

func _apply_direction() -> void:
	sprite.flip_h = direction > 0.0
	edge_ray.position.x = absf(edge_ray.position.x) * direction

## `from_position` is where the hit came from; if it's behind us, turn to face it.
func take_damage(amount: int, from_position := Vector2.INF) -> void:
	if mode == Mode.DEAD:
		return
	health -= amount
	if health <= 0:
		_die()
		return
	if from_position != Vector2.INF and mode != Mode.ATTACK:
		var toward := signf(from_position.x - global_position.x)
		if toward != 0.0 and toward != direction:
			direction = toward
			_apply_direction()
	var tween := create_tween()
	sprite.modulate = Color(1, 0.3, 0.3)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.25)

func _die() -> void:
	mode = Mode.DEAD
	# Stop moving, hurting, and being hit while the death animation plays.
	set_physics_process(false)
	set_deferred("collision_layer", 0)
	hitbox.set_deferred("monitoring", false)
	sprite.modulate = Color.WHITE
	Sfx.play(DEATH_SOUND)
	sprite.play("die")
	await sprite.animation_finished
	# Then crumble into dust as it disappears.
	var particles := DEATH_PARTICLES.instantiate()
	particles.position = position + Vector2(0, 6)  # same parent as the mushroom
	get_parent().add_child(particles)
	queue_free()

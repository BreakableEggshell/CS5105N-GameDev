class_name State
extends Node

signal transitioned(new_state_name: StringName)

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var actor: CharacterBody2D
var sprite: AnimatedSprite2D

func enter() -> void: pass
func exit() -> void: pass
func handle_input(_event: InputEvent) -> void: pass
func update(_delta: float) -> void: pass
func physics_update(_delta: float) -> void: pass

## True when throw was just pressed, the player has a potion, and the Throw state's cooldown has passed.
func wants_throw() -> bool:
	if not Input.is_action_just_pressed("throw"):
		return false
	if not Inventory.has_potion():
		Inventory.empty_throw_attempted.emit()
		return false
	var throw_state = get_parent().get_node_or_null("Throw")
	return throw_state != null and throw_state.is_off_cooldown()

func face(dir: float) -> void:
	if dir != 0.0:
		sprite.flip_h = dir < 0.0

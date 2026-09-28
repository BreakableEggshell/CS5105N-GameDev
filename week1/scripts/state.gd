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

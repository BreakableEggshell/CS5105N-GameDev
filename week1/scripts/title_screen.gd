extends Node2D

const FIRST_LEVEL := "res://scene/main.tscn"
const HOVER_TINT := Color(1.2, 1.2, 1.2)
const PRESSED_TINT := Color(0.8, 0.8, 0.8)

@onready var continue_button: BaseButton = %ContinueButton
@onready var start_button: TextureButton = %StartButton
@onready var options_button: TextureButton = %OptionsButton
@onready var exit_button: TextureButton = %ExitButton
@onready var menu: Control = $UI/Menu
@onready var options_menu: Control = $UI/OptionsMenu

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_on_options_pressed)
	options_menu.closed.connect(_on_options_closed)
	exit_button.pressed.connect(get_tree().quit)
	for button in [continue_button, start_button, options_button, exit_button]:
		button.mouse_entered.connect(_set_tint.bind(button, HOVER_TINT))
		button.mouse_exited.connect(_set_tint.bind(button, Color.WHITE))
		button.focus_entered.connect(_set_tint.bind(button, HOVER_TINT))
		button.focus_exited.connect(_set_tint.bind(button, Color.WHITE))
		button.button_down.connect(_set_tint.bind(button, PRESSED_TINT))
		button.button_up.connect(_set_tint.bind(button, HOVER_TINT))
	# Continue only appears when there's saved progress.
	continue_button.visible = SaveGame.has_save()
	# Lets keyboard players press Enter/Space right away.
	if continue_button.visible:
		continue_button.grab_focus()
	else:
		start_button.grab_focus()
	# Safety nets in case we arrived mid-hit-stop or mid-iris (e.g. Exit from the pause menu).
	Engine.time_scale = 1.0
	if Transition.closed:
		Transition.iris_in(get_viewport().get_visible_rect().size / 2.0)

func _set_tint(button: BaseButton, tint: Color) -> void:
	button.modulate = tint

## Pick up at the saved level (fresh hearts and 0 potions, like any level start).
func _on_continue_pressed() -> void:
	Inventory.reset()
	Graveyard.clear()
	get_tree().change_scene_to_file(SaveGame.saved_level)

## New game from level 1 (this becomes the save once the level starts).
func _on_start_pressed() -> void:
	Inventory.reset()
	Graveyard.clear()
	Tutorial.arm()
	get_tree().change_scene_to_file(FIRST_LEVEL)

func _on_options_pressed() -> void:
	menu.hide()
	options_menu.open()

func _on_options_closed() -> void:
	menu.show()
	options_button.grab_focus()

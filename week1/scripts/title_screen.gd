extends Node2D

const FIRST_LEVEL := "res://scene/main.tscn"
const HOVER_TINT := Color(1.2, 1.2, 1.2)
const PRESSED_TINT := Color(0.8, 0.8, 0.8)

@onready var start_button: TextureButton = %StartButton
@onready var options_button: TextureButton = %OptionsButton
@onready var exit_button: TextureButton = %ExitButton
@onready var menu: Control = $UI/Menu
@onready var options_menu: Control = $UI/OptionsMenu

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_on_options_pressed)
	options_menu.closed.connect(_on_options_closed)
	exit_button.pressed.connect(get_tree().quit)
	for button in [start_button, options_button, exit_button]:
		button.mouse_entered.connect(_set_tint.bind(button, HOVER_TINT))
		button.mouse_exited.connect(_set_tint.bind(button, Color.WHITE))
		button.focus_entered.connect(_set_tint.bind(button, HOVER_TINT))
		button.focus_exited.connect(_set_tint.bind(button, Color.WHITE))
		button.button_down.connect(_set_tint.bind(button, PRESSED_TINT))
		button.button_up.connect(_set_tint.bind(button, HOVER_TINT))
	# Lets keyboard players press Enter/Space right away.
	start_button.grab_focus()

func _set_tint(button: TextureButton, tint: Color) -> void:
	button.modulate = tint

func _on_start_pressed() -> void:
	Inventory.reset()
	Tutorial.arm()
	get_tree().change_scene_to_file(FIRST_LEVEL)

func _on_options_pressed() -> void:
	menu.hide()
	options_menu.open()

func _on_options_closed() -> void:
	menu.show()
	options_button.grab_focus()

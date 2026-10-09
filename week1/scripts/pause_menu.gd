extends CanvasLayer
## Pause button (top right) + pause menu. Esc or the button toggles pause.

const TITLE_SCREEN := "res://scene/title_screen.tscn"
const HOVER_TINT := Color(1.2, 1.2, 1.2)
const PRESSED_TINT := Color(0.8, 0.8, 0.8)

@export var pause_icon: Texture2D
@export var play_icon: Texture2D

@onready var toggle_button: TextureButton = %ToggleButton
@onready var menu: Control = %Menu
@onready var options_button: TextureButton = %OptionsButton
@onready var restart_button: BaseButton = %RestartButton
@onready var exit_button: TextureButton = %ExitButton
@onready var options_menu: Control = $OptionsMenu

func _ready() -> void:
	# Keep working while the game is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	# A new level should never start paused (e.g. if the level restarted while paused).
	get_tree().paused = false
	toggle_button.pressed.connect(toggle_pause)
	exit_button.pressed.connect(_on_exit_pressed)
	restart_button.pressed.connect(restart_level)
	options_button.pressed.connect(_on_options_pressed)
	options_menu.closed.connect(_on_options_closed)
	for button in [toggle_button, options_button, restart_button, exit_button]:
		button.mouse_entered.connect(_set_tint.bind(button, HOVER_TINT))
		button.mouse_exited.connect(_set_tint.bind(button, Color.WHITE))
		button.focus_entered.connect(_set_tint.bind(button, HOVER_TINT))
		button.focus_exited.connect(_set_tint.bind(button, Color.WHITE))
		button.button_down.connect(_set_tint.bind(button, PRESSED_TINT))
		button.button_up.connect(_set_tint.bind(button, HOVER_TINT))
	_update()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("restart") and not options_menu.visible:
		# Mark handled first: restarting removes this menu from the tree.
		get_viewport().set_input_as_handled()
		restart_level()

## Restart the current level with the potions the player had when it began.
func restart_level() -> void:
	get_tree().paused = false
	Inventory.restore_level_start()
	get_tree().reload_current_scene()

func toggle_pause() -> void:
	if options_menu.visible:
		options_menu.close()
	get_tree().paused = not get_tree().paused
	_update()

func _update() -> void:
	var paused := get_tree().paused
	menu.visible = paused
	toggle_button.texture_normal = play_icon if paused else pause_icon
	if paused:
		options_button.grab_focus()
	else:
		get_viewport().gui_release_focus()

func _set_tint(button: BaseButton, tint: Color) -> void:
	button.modulate = tint

func _on_options_pressed() -> void:
	menu.hide()
	options_menu.open()

func _on_options_closed() -> void:
	# Only return to the pause menu if we're still paused (the play button may have closed options).
	if get_tree().paused:
		menu.show()
		options_button.grab_focus()

func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(TITLE_SCREEN)

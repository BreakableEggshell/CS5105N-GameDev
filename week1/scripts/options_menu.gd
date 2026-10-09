extends Control
## Options panel shared by the title screen and the pause menu.

signal closed

const PREVIEW_SOUND := preload("res://assets/music_sfx/hp_recovery.mp3")
const WAITING_TEXT := "Press a key..."

@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SfxSlider
@onready var fullscreen_check: CheckButton = %FullscreenCheck
@onready var controls_grid: GridContainer = %ControlsGrid
@onready var reset_button: Button = %ResetButton
@onready var back_button: Button = %BackButton

## action -> the Button showing its key.
var _key_buttons := {}
## Action waiting for a new key, or &"" when not rebinding.
var _waiting_action: StringName = &""

func _ready() -> void:
	hide()
	music_slider.value_changed.connect(Settings.set_music_volume)
	sfx_slider.value_changed.connect(Settings.set_sfx_volume)
	# Let the player hear the new SFX volume once they let go of the slider.
	sfx_slider.drag_ended.connect(func(_changed: bool) -> void: Sfx.play(PREVIEW_SOUND))
	fullscreen_check.toggled.connect(Settings.set_fullscreen)
	reset_button.pressed.connect(_on_reset_pressed)
	back_button.pressed.connect(close)
	_build_controls()

func _build_controls() -> void:
	for action in Settings.REBINDABLE:
		var label := Label.new()
		label.text = Settings.REBINDABLE[action]
		controls_grid.add_child(label)
		var button := Button.new()
		button.custom_minimum_size = Vector2(190, 0)
		button.pressed.connect(_start_rebind.bind(action))
		controls_grid.add_child(button)
		_key_buttons[action] = button
	_refresh_keys()

func _refresh_keys() -> void:
	for action in _key_buttons:
		var names := Settings.get_keys(action).map(Settings.key_name)
		_key_buttons[action].text = " / ".join(names) if not names.is_empty() else "(none)"

func open() -> void:
	music_slider.set_value_no_signal(Settings.music_volume)
	sfx_slider.set_value_no_signal(Settings.sfx_volume)
	fullscreen_check.set_pressed_no_signal(Settings.fullscreen)
	_refresh_keys()
	show()
	music_slider.grab_focus()

func close() -> void:
	_cancel_rebind()
	hide()
	Settings.save_settings()
	closed.emit()

func _start_rebind(action: StringName) -> void:
	_cancel_rebind()
	_waiting_action = action
	_key_buttons[action].text = WAITING_TEXT

func _cancel_rebind() -> void:
	if _waiting_action != &"":
		_waiting_action = &""
		_refresh_keys()

func _on_reset_pressed() -> void:
	_cancel_rebind()
	Settings.reset_controls()
	_refresh_keys()

func _input(event: InputEvent) -> void:
	# While waiting for a key, capture it before buttons or the game can react to it.
	if _waiting_action == &"" or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	get_viewport().set_input_as_handled()
	var key: int = event.physical_keycode
	var action := _waiting_action
	if key == KEY_ESCAPE:
		_cancel_rebind()
		return
	_waiting_action = &""
	Settings.rebind(action, key)
	_refresh_keys()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

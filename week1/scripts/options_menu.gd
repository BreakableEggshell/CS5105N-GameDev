extends Control
## Options panel shared by the title screen and the pause menu.

signal closed

const PREVIEW_SOUND := preload("res://assets/music_sfx/hp_recovery.mp3")

@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SfxSlider
@onready var fullscreen_check: CheckButton = %FullscreenCheck
@onready var back_button: Button = %BackButton

func _ready() -> void:
	hide()
	music_slider.value_changed.connect(Settings.set_music_volume)
	sfx_slider.value_changed.connect(Settings.set_sfx_volume)
	# Let the player hear the new SFX volume once they let go of the slider.
	sfx_slider.drag_ended.connect(func(_changed: bool) -> void: Sfx.play(PREVIEW_SOUND))
	fullscreen_check.toggled.connect(Settings.set_fullscreen)
	back_button.pressed.connect(close)

func open() -> void:
	music_slider.set_value_no_signal(Settings.music_volume)
	sfx_slider.set_value_no_signal(Settings.sfx_volume)
	fullscreen_check.set_pressed_no_signal(Settings.fullscreen)
	show()
	music_slider.grab_focus()

func close() -> void:
	hide()
	Settings.save_settings()
	closed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

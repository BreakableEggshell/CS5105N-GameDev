extends Area2D

const OPEN_SOUND := preload("res://assets/music_sfx/chest_open.mp3")

## Scene to load when the player touches the chest.
@export_file("*.tscn") var next_level: String

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var opened := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if opened or not body.is_in_group("player"):
		return
	opened = true
	# Freeze the player while the chest opens.
	body.get_node("StateMachine").process_mode = Node.PROCESS_MODE_DISABLED
	Sfx.play(OPEN_SOUND)
	sprite.play("open")
	await sprite.animation_finished
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file(next_level)

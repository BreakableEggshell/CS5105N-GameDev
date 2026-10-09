extends Area2D
## A sack of potions. Floats up and down; touching it adds its potions to the inventory.

const POPUP := preload("res://scene/pickup_popup.tscn")
const PICKUP_SOUND := preload("res://assets/music_sfx/hp_recovery.mp3")

## Potions in the sack.
@export var amount := 3
## If above 0, the sack instead holds this many potions for each enemy in the level.
@export var potions_per_enemy := 0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if potions_per_enemy > 0:
		# Wait a frame so every enemy in the level has been added.
		await get_tree().process_frame
		amount = potions_per_enemy * get_tree().get_nodes_in_group("enemy").size()
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "position:y", -3.0, 0.7)
	tween.tween_property(sprite, "position:y", 3.0, 0.7)

func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if not body.is_in_group("player"):
			continue
		var added := Inventory.add(amount)
		if added > 0:
			_show_popup(added)
			Sfx.play(PICKUP_SOUND, 0.0, 1.3)
			Tutorial.on_potions_collected()
			queue_free()
		return

func _show_popup(added: int) -> void:
	var popup := POPUP.instantiate()
	popup.text = "+%d" % added
	popup.position = position + Vector2(-6, -14)  # same parent as the sack
	get_parent().add_child(popup)

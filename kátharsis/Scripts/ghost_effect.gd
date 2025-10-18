extends Sprite2D
const PLAYER = preload("res://Actors/player.tscn")
@onready var ghost_effect: Sprite2D = $"."

func _ready() -> void:
	texture = PLAYER.texture
	ghosting()

func set_property(tx_pos, tx_scale):
	position = tx_pos
	scale = tx_scale

func ghosting():
	var tween_fade = get_tree().create_tween()
	tween_fade.tween_property(self, "self_modulate",Color(1.0, 1.0, 1.0, 0.0), 0.75)
	await tween_fade.finished
	queue_free()

extends RigidBody2D

const EXPLOSION = preload("res://Prefarbs/explosion.tscn")
@onready var collision: CollisionShape2D = $collision


func _on_body_entered(_body: Node) -> void:
	visible = false
	var explosion_instance = EXPLOSION.instantiate()
	get_parent().add_child(explosion_instance)
	explosion_instance.global_position = global_position
	collision.set_deferred("disabled", true)
	await explosion_instance.animation_finished
	queue_free()


func _on_colisior_detector_area_entered(area: Area2D) -> void:
	if area.name == "hurtbox":
		visible = false
		var explosion_instance = EXPLOSION.instantiate()
		get_parent().add_child(explosion_instance)
		explosion_instance.global_position = global_position
		collision.set_deferred("disabled", true)
		await explosion_instance.animation_finished
		queue_free()

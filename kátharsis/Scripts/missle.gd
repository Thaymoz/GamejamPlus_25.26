extends AnimatableBody2D

const SPEED := 900
const EXPLOSION = preload("res://Prefarbs/explosion.tscn")
var velocity := Vector2.ZERO
var direction 
@onready var sprite: Sprite2D = $sprite
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var collision: CollisionShape2D = $collision_detector/collision


func _process(delta: float) -> void:
	velocity.x = SPEED * direction * delta
	move_and_collide(velocity)


func set_direction(dir):
	direction = dir 
	if direction == 1:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func _on_collision_detector_body_entered(body: Node2D) -> void:
	visible = false
	var explosion_instance = EXPLOSION.instantiate()
	get_parent().add_child(explosion_instance)
	explosion_instance.global_position = global_position
	collision.set_deferred("disabled", true)
	collision_shape_2d.set_deferred("disabled", true)
	await explosion_instance.animation_finished
	queue_free()


func _on_collision_detector_area_entered(area: Area2D) -> void:
	if area.name == "hurtbox":
		visible = false
		var explosion_instance = EXPLOSION.instantiate()
		get_parent().add_child(explosion_instance)
		explosion_instance.global_position = global_position
		collision.set_deferred("disabled", true)
		collision_shape_2d.set_deferred("disabled", true)
		await explosion_instance.animation_finished
		queue_free()

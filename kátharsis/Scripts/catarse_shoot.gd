extends AnimatableBody2D


const SPEED := 1000
var velocity := Vector2.ZERO
var direction 

@onready var colision: CollisionShape2D = $colision
@onready var anim: AnimationPlayer = $anim
@onready var sprite: Sprite2D = $sprite



func _process(delta: float) -> void:
	velocity.x = SPEED * direction * delta
	move_and_collide(velocity)


func set_direction(dir):
	direction = dir 
	if direction == 1:
		sprite.flip_h = true
	else:
		sprite.flip_h = false


func _on_collisior_detector_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		queue_free()

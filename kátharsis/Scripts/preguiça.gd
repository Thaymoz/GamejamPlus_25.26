extends CharacterBody2D

const SPEED = 10000.0

@onready var wall_detector: RayCast2D = $wall_detector

var direction = -1

func _physics_process(delta: float) -> void:
	if wall_detector.is_colliding():
		direction *= -1
		wall_detector.scale.x *= -1
	if direction == 1:
		velocity.x = SPEED * delta
	else:
		velocity.x = -SPEED * delta

	move_and_slide()

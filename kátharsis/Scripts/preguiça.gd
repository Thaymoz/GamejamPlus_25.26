extends CharacterBody2D

const SPEED = 10000.0
const BOMB = preload("res://Prefarbs/bomb.tscn")
const MISSLE = preload("res://Prefarbs/missle.tscn")

@onready var wall_detector: RayCast2D = $wall_detector
@onready var sprite: Sprite2D = $sprite
@onready var missle_point: Marker2D = %missle_point
@onready var bomb_point: Marker2D = %bomb_point

var direction = -1

func _physics_process(delta: float) -> void:
	if wall_detector.is_colliding():
		direction *= -1
		wall_detector.scale.x *= -1
		sprite.scale.x *= -1

	if direction == 1:
		velocity.x = SPEED * delta
	else:
		velocity.x = -SPEED * delta

	move_and_slide()

func throw_bomb():
	var bomb_insntance = BOMB.instantiate()
	add_sibling(bomb_insntance)
	bomb_insntance.global_position = bomb_point.global_position
	bomb_insntance.apply_impulse(Vector2(randi_range (direction * 400, direction * 800) , randi_range(-400,-800) ))

func _on_bomb_cd_timeout() -> void:
	throw_bomb()

func lunch_missle():
	var missle_instance = MISSLE.instantiate()
	add_sibling(missle_instance)
	missle_instance.global_position = missle_point.global_position
	missle_instance.set_direction(direction)

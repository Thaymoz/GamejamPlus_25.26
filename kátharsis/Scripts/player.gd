extends CharacterBody2D

const SPEED = 500.0
const AIR_FRICTION := 0.65

@onready var texture: Sprite2D = $texture



#Variaveis do pulo
@export var jump_height := 128
@export var max_time_to_peak := 0.5
var jump_velocity
var gravity
var fall_gravity
var number_jumps

func _ready() -> void:
	jump_velocity = (jump_height * 2) / max_time_to_peak
	gravity = (jump_height * 2) / pow(max_time_to_peak, 2)
	fall_gravity = gravity * 2


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.x = 0
	if is_on_floor():
		number_jumps = 2
#pulo
	if Input.is_action_just_pressed("ui_up") and number_jumps > 0:
		velocity.y = -jump_velocity 
		number_jumps -= 1
	if velocity.y > 0 or not Input.is_action_pressed("ui_up"):
		velocity.y += fall_gravity * delta
	else:
		velocity.y += gravity * delta

#Andar
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = lerp(velocity.x, direction * SPEED, AIR_FRICTION)
		texture.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		

	move_and_slide()

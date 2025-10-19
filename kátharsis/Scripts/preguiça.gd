extends CharacterBody2D

const SPEED = 10000.0
const BOMB = preload("res://Prefarbs/bomb.tscn")
const MISSLE = preload("res://Prefarbs/missle.tscn")

@onready var wall_detector: RayCast2D = $wall_detector
@onready var sprite: Sprite2D = $sprite
@onready var missle_point: Marker2D = %missle_point
@onready var bomb_point: Marker2D = %bomb_point

@onready var anim_tree: AnimationTree = $anim_tree
@onready var state_machine = anim_tree["parameters/playback"]

#flags para o boss
var turn_count := 0
var missle_count :=0 
var bomb_count := 0
var can_lunch_missle : bool = true
var can_lunch_bomb : bool = true
var player_can_hit : bool = false

var direction = -1

func _ready() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	if wall_detector.is_colliding():
		direction *= -1
		wall_detector.scale.x *= -1
		sprite.scale.x *= -1
		turn_count += 1

		"moving":
			if direction == 1:
				velocity.x = SPEED * delta
			else:
				velocity.x = -SPEED * delta
		"missle_atack":
			velocity.x = 0
			await get_tree().create_timer(2.0).timeout
			if can_lunch_missle:
				lunch_missle()
				can_lunch_missle = false
				
		"hide_bomb":
			velocity.x = 0
			await get_tree().create_timer(2.0).timeout
			if can_lunch_bomb:
				throw_bomb()
				can_lunch_bomb = false
		"vunerable":
			can_lunch_bomb = false
			can_lunch_missle = false
			await get_tree().create_timer(2.0).timeout
			player_can_hit = true
	if turn_count <= 2:
		anim_tree.set("parameters/conditions/can_move", true)
		anim_tree.set("parameters/conditions/time_missle", false)
	elif missle_count >= 4:
		anim_tree.set("parameters/conditions/time_bomb", true)
		missle_count = 0
	elif bomb_count >= 3:
		anim_tree.set("parameters/conditions/is_vunerable", true)
		bomb_count = 0
	else:
		anim_tree.set("parameters/conditions/can_move", true)
		anim_tree.set("parameters/conditions/can_move", false)
		anim_tree.set("parameters/conditions/is_vunerable", false)
		anim_tree.set("parameters/conditions/time_bomb", false)
		anim_tree.set("parameters/conditions/time_missle", true)

	move_and_slide()

func throw_bomb():
	if bomb_count <= 3:
		var bomb_insntance = BOMB.instantiate()
		add_sibling(bomb_insntance)
		bomb_insntance.global_position = bomb_point.global_position
		bomb_insntance.apply_impulse(Vector2(randi_range (direction * 400, direction * 800) , randi_range(-400,-800) ))
		bomb_count += 1

func _on_bomb_cd_timeout() -> void:
	can_lunch_bomb = true

func lunch_missle():
	if missle_count <= 5:
		var missle_instance = MISSLE.instantiate()
		add_sibling(missle_instance)
		missle_instance.global_position = missle_point.global_position
		missle_instance.set_direction(direction)
		missle_count += 1


func _on_missle_cd_timeout() -> void:
	can_lunch_missle = true


func _on_player_detector_body_entered(body: Node2D) -> void:
	set_physics_process(true)


func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	set_physics_process(true)

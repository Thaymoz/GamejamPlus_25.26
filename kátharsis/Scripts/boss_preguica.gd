extends CharacterBody2D

const BOMB = preload("res://Prefarbs/bomb.tscn")
const MISSLE = preload("res://Prefarbs/missle.tscn")
const SPEED = 30000.0

var direction = -1 

@onready var wall_detector: RayCast2D = $wall_detector
@onready var sprite: Sprite2D = $sprite
@onready var bomb_point: Marker2D = %bomb_point
@onready var missel_point: Marker2D = %missel_point

@onready var anim_tree: AnimationTree = $anim_tree
@onready var state_machine = anim_tree["parameters/playback"]


#outra maneira de inves de usar o preload arrastando
@export var boss_instance : PackedScene

#flags para o estado do boss
var turn_count := 0 
var missle_count := 0 
var bomb_count := 0
var can_launch_missle := true
var can_launch_bomb := true
var player_hit := false
var boss_life := 100

func _ready() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	if wall_detector.is_colliding():
		direction *= -1
		wall_detector.scale.x *= -1
		sprite.scale.x *= -1
		turn_count += 1

	match state_machine.get_current_node():
		"mooving":
			wall_detector.enabled = true
			$hurtbox/collision.set_deferred("disabled",true)
			set_collision_layer_value(8,true)
			set_collision_layer_value(3,false)
			if direction == 1:
				velocity.x =  SPEED * delta
			else:
				velocity.x =  -SPEED * delta
		"missle_atack":
			wall_detector.enabled = false
			velocity.x = 0
			await get_tree().create_timer(2.0).timeout
			if can_launch_missle:
				launch_missle()
				can_launch_missle = false
		"hide_bomb":
			velocity.x = 0
			await get_tree().create_timer(2.0).timeout
			if can_launch_bomb:
				throw_bomb()
				can_launch_bomb = false
		"vunerable":
			can_launch_missle = false
			can_launch_bomb = false
			await get_tree().create_timer(2.0).timeout
			set_collision_layer_value(7,false)
			set_collision_layer_value(3,true)
			player_hit = false
			$hurtbox/collision.set_deferred("disabled",false)
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
		anim_tree.set("parameters/conditions/can_move", false)
		anim_tree.set("parameters/conditions/is_vunerable", false)
		anim_tree.set("parameters/conditions/time_bomb", false)
		anim_tree.set("parameters/conditions/time_missle", true)

	if boss_life <=0:
		state_machine.travel("death")
		$hurtbox/collision.set_deferred("disabled",true)

	move_and_slide()

func throw_bomb():
	if bomb_count <= 3:
		var bomb_instance = BOMB.instantiate()
		add_sibling(bomb_instance)
		bomb_instance.global_position = bomb_point.global_position
		bomb_instance.apply_impulse(Vector2(randi_range(direction*400,direction*800),randi_range(-400, -800)))
		$bomb_cooldown.start()
		bomb_count += 1

func launch_missle():
	if missle_count <= 4:
		var missle_instance = MISSLE.instantiate()
		add_sibling(missle_instance)
		missle_instance.global_position = missel_point.global_position
		missle_instance.set_direction(direction)
		$missle_cooldown.start()
		missle_count += 1

func _on_bomb_cooldown_timeout() -> void:
	can_launch_bomb = true
	


func _on_missle_cooldown_timeout() -> void:
	can_launch_missle = true 


func _on_player_detector_body_entered(_body):
	set_physics_process(true)


func _on_hurtbox_body_entered(body: Node2D) -> void:
	print(boss_life)
	body.velocity = Vector2(50, -300)
	player_hit = true
	#turn_count = 0 
	boss_life -= 1
	#if boss_life <= 0:
		#Globals.boss_defeated.emit()

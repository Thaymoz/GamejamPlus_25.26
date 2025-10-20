extends CharacterBody2D

var SPEED = 500.0
const AIR_FRICTION := 0.65
const DASH_DISTANCE = 300
const CATARSE_SHOOT = preload("res://Prefarbs/catarse_shoot.tscn")
#referencia de nos
@onready var player: CharacterBody2D = $"."
@onready var texture: Sprite2D = $texture
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision: CollisionShape2D = $collision
@onready var ghost_timer: Timer = $ghost_timer
@onready var dash_particles: GPUParticles2D = $dash_particles
@onready var dash_cd: Timer = $dash_cd
@onready var hurt_collision: CollisionShape2D = $texture/hurtbox/hurt_collision
@onready var txt_catarse: Label = %txt_catarse
@onready var catarse_drain: Timer = $catarse_drain
@onready var point_shoot: Marker2D = %point_shoot


#Variaveis do pulo
@export var jump_height := 128
@export var max_time_to_peak := 0.5
var jump_velocity
var gravity
var fall_gravity
var number_jumps = 2


@export var ghost_node : PackedScene
var direction
var is_attacking : bool = false
var can_dash : bool = true

#catarse
var catarse : int = 0
const CATARSE_MAX := 100
var is_catarse_mode : bool = false
var direction2 : float = -1

#tomar dano
var knockback_vector := Vector2.ZERO
var is_hurted : bool = false
var knockback_power := 20 

func _ready() -> void:
	jump_velocity = (jump_height * 2) / max_time_to_peak
	gravity = (jump_height * 2) / pow(max_time_to_peak, 2)
	fall_gravity = gravity * 2

signal players_has_died()

func _process(_delta: float) -> void:
	handle_animation()
	if Input.is_action_just_pressed("catarse_mode") and catarse >= 100:
		is_catarse_mode = true
		catarse_drain.start()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.x = 0
	if is_on_floor():
		number_jumps = 2

#pulo
	if Input.is_action_just_pressed("ui_up") and number_jumps > 0:
		is_attacking = false
		velocity.y = -jump_velocity 
		number_jumps -= 1
	if velocity.y > 0 or not Input.is_action_pressed("ui_up"):
		velocity.y += fall_gravity * delta
	else:
		velocity.y += gravity * delta

#Andar
	direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		is_attacking = false
		velocity.x = lerp(velocity.x, direction * SPEED, AIR_FRICTION)
		texture.scale.x = direction 
		direction2 = direction2 * direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
#Attack
	if Input.is_action_just_pressed("attack") and is_on_floor():
		is_attacking = true
		if is_catarse_mode:
			catarse_attack()

#Dash
	if Input.is_action_just_pressed("dash"):
		if can_dash:
			dash()

#dano
	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector
	move_and_slide()


func handle_animation():
	var anim = "idle"
	if not is_on_floor():
		anim = "jump"
	if velocity.y > 0:
		anim = "fall"
	if is_attacking:
		anim = "attack"
	if is_hurted:
		anim = "hurt"
	if direction and is_on_floor():
		anim = "walk"

	if animation_player.name != anim:
		animation_player.play(anim)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		is_attacking = false
		


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		print("player bateu:", body.name, "e ganhou tantos pontos de catarse", catarse)
		if catarse < CATARSE_MAX and is_catarse_mode == false:
			catarse += randi_range(2,7)
			txt_catarse.text = str(min(catarse, CATARSE_MAX), "%")
			print("player bateu:", body.name, "e ganhou tantos pontos de catarse", catarse)

func add_ghost():
	var ghost = ghost_node.instantiate()
	ghost.set_property(position, (texture.scale*4))
	get_tree().current_scene.add_child(ghost)

func _on_ghost_timer_timeout() -> void:
	add_ghost()
	
func dash():
	can_dash = false
	dash_cd.start()
	ghost_timer.start()
	dash_particles.emitting = true
	hurt_collision.disabled = true
	SPEED = SPEED*3.5
	await get_tree().create_timer(0.3).timeout
	hurt_collision.disabled = false
	SPEED = 500
	ghost_timer.stop()
	dash_particles.emitting = false

func _on_dash_cd_timeout() -> void:
	
	can_dash = true


func _on_catarse_drain_timeout() -> void:
	if catarse > 0:
		catarse -= 1
		txt_catarse.text = str(catarse)
		if catarse == 0:
			is_catarse_mode = false
			catarse_drain.stop()

func catarse_attack():
	if is_catarse_mode and is_attacking:
		var shoot_catarse_instance = CATARSE_SHOOT.instantiate()
		add_sibling(shoot_catarse_instance)
		shoot_catarse_instance.global_position = point_shoot.global_position
		shoot_catarse_instance.set_direction(texture.scale.x)
		

func take_damage(knockback_force := Vector2.ZERO,duration := 0.25):#aula 10
	if Globals.player_life > 0:
		Globals.player_life -= 1
	else:
		get_tree().change_scene_to_file.call_deferred("res://Scenes/derrota.tscn")
		return
	if knockback_force != Vector2.ZERO:
		knockback_vector = knockback_force
		var knockback_tween := get_tree().create_tween()
		knockback_tween.parallel().tween_property(self, "knockback_vector", Vector2.ZERO, duration)
		texture.modulate = Color(1,0,0,1)
		knockback_tween.parallel().tween_property(texture,"modulate",Color(1,1,1,1),duration)
	is_hurted = true
	await get_tree().create_timer(.3).timeout
	is_hurted = false

func _on_hurtbox_body_entered(body: Node2D) -> void:
	print("tocou")
	var knockback = Vector2((global_position.x - body.global_position.x)*knockback_power, -200)
	take_damage(knockback)

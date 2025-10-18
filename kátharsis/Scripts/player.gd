extends CharacterBody2D

const SPEED = 500.0
const AIR_FRICTION := 0.65
const DASH_DISTANCE = 300

#referencia de nos
@onready var player: CharacterBody2D = $"."
@onready var texture: Sprite2D = $texture
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision: CollisionShape2D = $collision
@onready var ghost_timer: Timer = $ghost_timer
@onready var dash_particles: GPUParticles2D = $dash_particles
@onready var dash_cd: Timer = $dash_cd

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

func _ready() -> void:
	jump_velocity = (jump_height * 2) / max_time_to_peak
	gravity = (jump_height * 2) / pow(max_time_to_peak, 2)
	fall_gravity = gravity * 2


func _process(_delta: float) -> void:
	handle_animation()

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
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
#Attack
	if Input.is_action_pressed("attack") and is_on_floor():
		is_attacking = true

#Dash
	if Input.is_action_just_pressed("dash"):
		if can_dash:
			dash()

	move_and_slide()


func handle_animation():
	var anim = "idle"
	if not is_on_floor():
		anim = "jump"
	if velocity.y > 0:
		anim = "fall"
	if is_attacking:
		anim = "attack"
	if direction and is_on_floor():
		anim = "walk"

	if animation_player.name != anim:
		animation_player.play(anim)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		is_attacking = false


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		print(body.name)

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
	var dash_direction = texture.scale.x
	var target_position = position + Vector2(dash_direction * DASH_DISTANCE, 0)
	var tween = get_tree().create_tween()
	#tween.tween_property(self, "position", position + velocity * 1.5, 0.2)
	tween.tween_property(self, "position", target_position, 0.3)
	await tween.finished
	ghost_timer.stop()
	dash_particles.emitting = false

func _on_dash_cd_timeout() -> void:
	can_dash = true

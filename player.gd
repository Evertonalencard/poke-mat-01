extends CharacterBody2D

@export var walk_speed = 4.0
@onready var anim := $AnimatedSprite2D 
@onready var ray_cast_2d: RayCast2D = $RayCast2D

signal player_moving_signal
signal player_stopped_signal


var last_direction = Vector2.DOWN
var input_direction = Vector2(0,0)
var is_moving = false
var percent_moved_to_next_tile = 0.0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	process_player_input()
	move_and_slide()

func process_player_input():
	input_direction = Vector2.ZERO
	

	
	input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))

	# Evita diagonal (como Pokémon)
	if input_direction != Vector2.ZERO:
		ray_cast_2d.target_position = input_direction.normalized() * 8
		ray_cast_2d.force_raycast_update()
		
		if not ray_cast_2d.is_colliding(): 
			emit_signal("player_moving_signal")
			input_direction.normalized()
			velocity = input_direction * walk_speed
			update_animation(input_direction)
			last_direction = input_direction
			emit_signal("player_stopped_signal")
		else:
			velocity = Vector2.ZERO
			get_idle_animation()
	else:
		velocity = Vector2.ZERO
		get_idle_animation()

func update_animation(input_direction: Vector2):
	if abs(input_direction.x) > abs(input_direction.y):
		anim.play("walk_side")
		if input_direction.x < 0:
			anim.flip_h = false
		else:
			anim.flip_h = true
	elif input_direction.y > 0:
		anim.play("walk_down")
	else:
		anim.play("walk_up")

func get_idle_animation():
	if abs(last_direction.x) > abs(last_direction.y):
		anim.play("idle_side")
		anim.flip_h = last_direction.x > 0
	elif last_direction.y > 0:
		anim.play("idle_down")
	else:
		anim.play("idle_up")

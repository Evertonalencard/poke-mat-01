extends CharacterBody2D

signal player_moving_signal
signal player_stopped_signal

signal player_entering_door_signal
signal player_entered_door_signal

const LaundingDustEffect = preload("res://cenas/Scenes/landing_dust_effect.tscn")

@export var walk_speed = 4.0
@export var jump_speed = 4.0
const TILE_SIZE = 16

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var anim_state = animation_tree.get("parameters/playback")
@onready var ray_cast_2d: RayCast2D = $BlockingRayCast2D
@onready var ledge_ray_cast_2d_2: RayCast2D = $LedgeRayCast2D2
@onready var door_ray_cast_2d: RayCast2D = $DoorRayCast2D
@onready var vitoria: AudioStreamPlayer = $vitoria as AudioStreamPlayer


@onready var shadow: Sprite2D = $Shadow

var jumping_over_ledge:bool = false

enum PlayerState{IDLE, TURNING, WALKING}
enum FacingDirection{LEFT, RIGHT, UP, DOWN}

var player_state = PlayerState.IDLE
var facing_direction = FacingDirection.DOWN

var initial_position = Vector2(0,0)
var input_direction = Vector2(0,1)
var is_moving = false
var stop_input: bool = false
var percent_moved_to_next_tile = 0.0

func _ready() -> void:
	add_to_group("player")
	$MaleSpritesheet.visible = true
	initial_position = position
	animation_tree.active = true
	shadow.visible = false
	animation_tree.set("parameters/Idle/blend_position", input_direction)
	animation_tree.set("parameters/Walk/blend_position", input_direction)
	animation_tree.set("parameters/Turn/blend_position", input_direction)
	

func set_spawn(location: Vector2, direction: Vector2):
	animation_tree.set("parameters/Idle/blend_position", direction)
	animation_tree.set("parameters/Walk/blend_position", direction)
	animation_tree.set("parameters/Turn/blend_position", direction)
	position = location

func _physics_process(delta: float) -> void:
	
	if player_state == PlayerState.TURNING or stop_input:
		return
	elif is_moving == false:
		process_player_input()
	elif input_direction != Vector2.ZERO:
		anim_state.travel("Walk")
		move(delta)
	else: 
		anim_state.travel("Idle")
		is_moving = false

func process_player_input():
	input_direction = Vector2.ZERO
	
	if input_direction.y == 0:
		input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if input_direction.x == 0:
		input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	
	
	
	if input_direction == Vector2.ZERO:
		anim_state.travel("Idle")
		return
	
	if input_direction != Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", input_direction)
		animation_tree.set("parameters/Walk/blend_position", input_direction)
		animation_tree.set("parameters/Turn/blend_position", input_direction)
		
		if need_to_turn():
			player_state = PlayerState.TURNING
			anim_state.travel("Turn")
		else:
			initial_position = position
			is_moving = true
			
	
func need_to_turn():
	var new_facing_direction
	if input_direction.x < 0:
		new_facing_direction = FacingDirection.LEFT
	elif input_direction.x > 0:
		new_facing_direction = FacingDirection.RIGHT
	elif input_direction.y < 0:
		new_facing_direction = FacingDirection.UP
	elif input_direction.y > 0:
		new_facing_direction = FacingDirection.DOWN
	
	if facing_direction != new_facing_direction:
		facing_direction = new_facing_direction
		return true
	facing_direction = new_facing_direction  
	return false

func finished_turning():
	player_state = PlayerState.IDLE
	

func entered_door():
	emit_signal("player_entered_door_signal")
	position = position

func move(delta):
	
	var desired_step: Vector2 = input_direction * TILE_SIZE / 2
	ray_cast_2d.target_position = desired_step
	ray_cast_2d.force_raycast_update()
	
	ledge_ray_cast_2d_2.target_position = desired_step
	ledge_ray_cast_2d_2.force_raycast_update()
	
	door_ray_cast_2d.target_position = desired_step
	door_ray_cast_2d.force_raycast_update()
	
	if door_ray_cast_2d.is_colliding():
		if percent_moved_to_next_tile == 0.0:
			emit_signal("player_entering_door_signal")
		percent_moved_to_next_tile += walk_speed * delta
		if percent_moved_to_next_tile >= 1.0:
			position = initial_position + (input_direction * TILE_SIZE)
			percent_moved_to_next_tile = 0.0
			
			is_moving = false
			stop_input = true
			$AnimationPlayer.play("Disappear")
		else:
			position = initial_position + (input_direction * TILE_SIZE * percent_moved_to_next_tile)
	
	elif (ledge_ray_cast_2d_2.is_colliding() and input_direction == Vector2(0, 1)) or jumping_over_ledge:
		percent_moved_to_next_tile += jump_speed * delta
		if percent_moved_to_next_tile >= 2.0:
			position = initial_position + (input_direction * TILE_SIZE * 2)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			jumping_over_ledge = false
			shadow.visible = false
			
			var dust_effect = LaundingDustEffect.instantiate()
			dust_effect.position = position
			get_tree().current_scene.add_child(dust_effect)
		else:
			shadow.visible = true
			jumping_over_ledge = true
			var input = input_direction.y * TILE_SIZE * percent_moved_to_next_tile
			position.y = initial_position.y + (-0.96 - 0.53 * input + 0.05 * pow(input, 2))

			
	
	elif !ray_cast_2d.is_colliding():
		if percent_moved_to_next_tile == 0:
			emit_signal("player_moving_signal")
		percent_moved_to_next_tile += walk_speed * delta
		if percent_moved_to_next_tile >= 1.0:
			position = initial_position + (TILE_SIZE * input_direction)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			input_direction = Vector2.ZERO
			emit_signal("player_stopped_signal")
		else:
			position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)
			animation_tree.set("parameters/Walk/blend_position", input_direction)
	else:
		is_moving = false

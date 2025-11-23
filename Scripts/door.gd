extends Area2D
@export var next_scene_path: String
@export var is_invisible: bool = false

@export var spawn_location = Vector2.ZERO
@export var spawn_direction = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var player_entered = false

func _ready() -> void:
	if is_invisible:
		$Sprite.texture = null
	sprite.visible = false

	await get_tree().process_frame  # garante que tudo foi instanciado

	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		
		return

	

	if not player.player_entering_door_signal.is_connected(enter_door):
		player.player_entering_door_signal.connect(enter_door)

	if not player.player_entered_door_signal.is_connected(close_door):
		player.player_entered_door_signal.connect(close_door)

	


func enter_door():
	if not player_entered:
		return
	print("opendoor")
	animation_player.play("OpenDoor")

func close_door():
	if not player_entered:
		return
	print("closedoor")
	animation_player.play("CloseDoor")

func door_closed():
	if not player_entered:
		return
	print("DEBUG: door_closed chamado")
	get_node("/root/SceneManager").transition_to_scene(next_scene_path, spawn_location, spawn_direction)

func _on_body_entered(body: Node2D) -> void:
	player_entered = true

func _on_body_exited(body: Node2D) -> void:
	player_entered = false

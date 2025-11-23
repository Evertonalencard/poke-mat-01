extends Node2D

@onready var musicafundo: AudioStreamPlayer = $musicafundo

var next_scene = null
@onready var color_rect: ColorRect = $ScreenTransition/ColorRect

var player_location = Vector2.ZERO
var player_direction = Vector2.ZERO

func _ready() -> void:
	color_rect.color = Color(0,0,0,0)

	# --- Música de fundo ---
	if musicafundo.stream:
		musicafundo.stream.set_loop(true)
	musicafundo.play()
	# ------------------------


func transition_to_scene(new_scene: String, spawn_location, spawn_direction):
	next_scene = new_scene
	player_location = spawn_location
	player_direction = spawn_direction
	print("chamado transitio")
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")
	
	
func finished_fading():
	print("DEBUG: finished_fading CHAMADO")
	$CurrentScene.get_child(0).queue_free()
	$CurrentScene.add_child(load(next_scene).instantiate())
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	player.set_spawn(player_location, player_direction)
	
	$ScreenTransition/AnimationPlayer.play("FadeToNormal")

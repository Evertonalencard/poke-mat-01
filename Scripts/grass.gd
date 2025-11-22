extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
const grass_overlay_texture = preload("res://assets/Assets/Grass/stepped_tall_grass.png")
const GrassStepEffect = preload("res://cenas/Scenes/grass_step_effect.tscn")
var grass_overlay: TextureRect = null

var player_inside: bool = false
var effect_is_active: bool = false

func _enter_tree():
	await get_tree().process_frame
	
	var player = get_tree().get_first_node_in_group("player")

	if player:
		if player.has_signal("player_moving_signal"):
			if not player.player_moving_signal.is_connected(player_exiting_grass):
				player.player_moving_signal.connect(player_exiting_grass)

		if player.has_signal("player_stopped_signal"):
			if not player.player_stopped_signal.is_connected(player_in_grass):
				player.player_stopped_signal.connect(player_in_grass) 
	
	

func player_exiting_grass():
	player_inside = false
	if is_instance_valid(grass_overlay):
		grass_overlay.queue_free()
		grass_overlay = null
		

func player_in_grass():
	if player_inside == true:
		var grass_step_effect = GrassStepEffect.instantiate()
		grass_step_effect.position = position
		get_tree().current_scene.add_child(grass_step_effect)
		
		grass_overlay = TextureRect.new()
		grass_overlay.texture = grass_overlay_texture
		grass_overlay.position = position
		get_tree().current_scene.add_child(grass_overlay)

@warning_ignore("unused_parameter")
func _on_area_2d_body_entered(body: Node2D) -> void:
	player_inside = true
	animation_player.play("Stepped")

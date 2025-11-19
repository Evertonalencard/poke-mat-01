extends Node2D


func _ready():
	$Player.position = GlobalData.player_pos
	get_tree().root.print_tree_pretty()
	# Restaura posição do player se necessári
	$Player.position = GlobalData.player_pos

func find_inimigo_by_id(id):
	for inimigo in get_tree().get_nodes_in_group("inimigos"):
		if inimigo.get_instance_id() == id:
			return inimigo
	return null

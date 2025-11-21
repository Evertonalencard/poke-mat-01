extends Area2D

# Caminho da cena que deve ser carregada
const HOME_SCENE := "res://playerhome.tscn"

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "player":  # nome do nó do seu player
		get_tree().change_scene_to_file(HOME_SCENE)

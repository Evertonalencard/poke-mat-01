extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_sair_pressed() -> void:
	get_tree().quit() # Replace with function body.


func _on_jogar_pressed() -> void:
	LoadManeger.load_scene("res://cenas/Scenes/scene_manager.tscn")


func _on_ajuda_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/ajuda.tscn")
	
	


func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/tela_inicial.tscn")


func _on_menu_principal_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/tela_inicial.tscn")

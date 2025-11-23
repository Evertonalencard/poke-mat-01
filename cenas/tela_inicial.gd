extends CanvasLayer

@onready var sominicial: AudioStreamPlayer = $sominicial

func _ready() -> void:
	if sominicial.stream:
		sominicial.stream.set_loop(true)
	sominicial.play()


func _process(delta: float) -> void:
	pass


func _on_sair_pressed() -> void:
	get_tree().quit()


func _on_jogar_pressed() -> void:
	LoadManeger.load_scene("res://cenas/main.tscn")


func _on_ajuda_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/ajuda.tscn")


func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/tela_inicial.tscn")


func _on_menu_principal_pressed() -> void:
	get_tree().change_scene_to_file("res://tela_inicial.tscn")

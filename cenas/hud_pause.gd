extends CanvasLayer


# Called when the node enters the scene tree for the first time.
signal continuar
signal menu_principal

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS  # O próprio menu
	visible = false
	
	for child in get_children():
		print(child.name, " - Process Mode: ", child.process_mode)
		child.process_mode = Node.PROCESS_MODE_ALWAYS

func mostrar():
	visible = true
	get_tree().paused = true

func esconder():
	visible = false
	get_tree().paused = false





func _on_continuar_pressed() -> void:
	print("BOTÃO CONTINUAR CLICADO!")  # Debug
	esconder()
	emit_signal("continuar")




func _on_menu_principal_2_pressed() -> void:
	print("BOTÃO menu CLICADO!")  # Debug
	var alerta := ConfirmationDialog.new()
	alerta.process_mode = Node.PROCESS_MODE_ALWAYS
	alerta.dialog_text = "Você perderá seu progresso não salvo. Tem certeza de que deseja voltar ao menu principal?"
	alerta.get_ok_button().text = "Sim"
	alerta.get_cancel_button().text = "Cancelar"
	alerta.connect("confirmed", Callable(self, "_voltar_menu_principal"))
	add_child(alerta)
	alerta.popup_centered()

func _voltar_menu_principal():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://cenas/tela_inicial.tscn")  # ajuste o caminho se necessário

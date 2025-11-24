extends CanvasLayer

@export var botoes: Array[Button]

var selecao_atual := 0
var last_dir := "IDLE"
var last_sw := false

@onready var sominicial: AudioStreamPlayer = $sominicial


func _ready():
	if sominicial.stream:
		sominicial.stream.set_loop(true)
	sominicial.play()

	# Espera o SW soltar ao trocar de cena
	await get_tree().create_timer(0.3).timeout
	last_sw = Gdserial.button_pressed
	
	# Marca o primeiro botão como selecionado
	atualizar_selecao()


func _process(delta):
	if botoes.size() == 0:
		return  # segurança

	var dir = Gdserial.direction
	var sw = Gdserial.button_pressed

	# 🟩 Navegação apenas quando a direção muda
	if dir != last_dir:
		if dir == "DOWN":
			selecao_atual = (selecao_atual + 1) % botoes.size()
			atualizar_selecao()

		elif dir == "UP":
			selecao_atual = (selecao_atual - 1 + botoes.size()) % botoes.size()
			atualizar_selecao()

	# 🟩 Clique apenas quando SW passa de 0 → 1 (não repetição)
	if sw and not last_sw:
		botoes[selecao_atual].emit_signal("pressed")

	# Atualiza buffers
	last_dir = dir
	last_sw = sw


func atualizar_selecao():
	for i in range(botoes.size()):
		if botoes[i]:
			if i == selecao_atual:
				botoes[i].grab_focus()
				botoes[i].modulate = Color(1, 1, 1)        # botão selecionado
			else:
				botoes[i].modulate = Color(0.7, 0.7, 0.7)  # botões não selecionados


# === Seus sinais continuam funcionando ===

func _on_sair_pressed() -> void:
	get_tree().quit()


func _on_jogar_pressed() -> void:
	LoadManeger.load_scene("res://cenas/Scenes/scene_manager.tscn")

func _on_ajuda_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/ajuda.tscn")


func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/tela_inicial.tscn")

func _on_menu_principal_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/tela_inicial.tscn")

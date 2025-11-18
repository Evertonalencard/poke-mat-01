extends HBoxContainer

# Caminho correto para os elementos
@onready var equacao_label = $Equacao/Label
@onready var botoes = [
	$VBoxContainer/Resposta1,
	$VBoxContainer/Resposta2,
	$VBoxContainer/Resposta3,
	$VBoxContainer/Resposta4,
	$VBoxContainer/Resposta5,
]

var selecao_atual: int = 0
var resposta_certa: int = -1
var respondido: bool = false  # Evita múltiplas respostas

func _ready():
	atualizar_selecao()
	carregar_dados_batalha()

func carregar_dados_batalha():
	# Busca os dados do inimigo que iniciou a batalha
	if GlobalData.equacao != "":
		set_dialogo(
			GlobalData.equacao,
			GlobalData.alternativas,
			GlobalData.correta
		)
	else:
		# Fallback: se não houver dados, usa exemplo de teste
		set_dialogo(
			"Qual o resultado de 7 x 3?",
			["10", "21", "14", "18", "25"],
			1
		)

func _input(event):
	# Bloqueia input após responder
	if respondido:
		return
		
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_DOWN:
			selecao_atual = (selecao_atual + 1) % botoes.size()
			atualizar_selecao()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_UP:
			selecao_atual = (selecao_atual - 1) % botoes.size()
			atualizar_selecao()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			checar_resposta(selecao_atual)
			get_viewport().set_input_as_handled()

func atualizar_selecao():
	for i in range(botoes.size()):
		if botoes[i]:
			if i == selecao_atual:
				botoes[i].modulate = Color(1, 1, 1, 1) # Destaque selecionado
			else:
				botoes[i].modulate = Color(0.7, 0.7, 0.7, 1) # Normal

func set_dialogo(equacao: String, alternativas: Array, correta: int):
	if equacao_label:
		equacao_label.text = equacao
	for i in range(botoes.size()):
		if i < alternativas.size() and botoes[i]:
			botoes[i].text = alternativas[i]
			botoes[i].visible = true
		elif botoes[i]:
			# Esconde botões extras se houver menos de 5 alternativas
			botoes[i].visible = false
	resposta_certa = correta

func checar_resposta(indice: int):
	if respondido:
		return
	
	respondido = true
	
	if indice == resposta_certa:
		botoes[indice].modulate = Color(0, 1, 0, 1) # Verde para correto
		# Aqui você pode adicionar som de acerto, aumentar pontuação, etc.
		await get_tree().create_timer(1.5).timeout
		vitoria()
	else:
		botoes[indice].modulate = Color(1, 0, 0, 1) # Vermelho para errado
		# Aqui você pode adicionar som de erro, perder vida, etc.
		await get_tree().create_timer(1.5).timeout
		derrota()

func vitoria():
	# Lógica de vitória - pode adicionar pontos, experiência, etc.
	print("Resposta correta! Voltando ao mapa...")
	limpar_dados_batalha()
	get_tree().change_scene_to_file("res://cenas/mundo.tscn")  # Ajuste o caminho

func derrota():
	# Lógica de derrota - pode diminuir vida, tentar novamente, etc.
	print("Resposta errada! Voltando ao mapa...")
	limpar_dados_batalha()
	get_tree().change_scene_to_file("res://cenas/mundo.tscn")  # Ajuste o caminho

func limpar_dados_batalha():
	# Limpa os dados para a próxima batalha
	GlobalData.equacao = ""
	GlobalData.alternativas = []
	GlobalData.correta = -1

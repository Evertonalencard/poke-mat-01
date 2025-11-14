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
var resposta_certa: int = -1   # índice da resposta correta

func _ready():
	atualizar_selecao()
	# Adiciona strings fictícias para testar a interface (5 alternativas!)
	set_dialogo(
		"Qual o resultado de 7 x 3?",
		["10", "21", "14", "18", "25"],
		1 # índice da resposta certa ("21")
	)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_DOWN:
			selecao_atual = (selecao_atual + 1) % botoes.size()
			atualizar_selecao()
		elif event.keycode == KEY_UP:
			selecao_atual = (selecao_atual - 1) % botoes.size()
			atualizar_selecao()
		elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			checar_resposta(selecao_atual)

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
		if botoes[i]:
			botoes[i].text = alternativas[i]
	resposta_certa = correta

func checar_resposta(indice: int):
	if indice == resposta_certa:
		botoes[indice].modulate = Color(0, 1, 0, 1) # Verde para correto
	else:
		botoes[indice].modulate = Color(1, 0, 0, 1) # Vermelho para errado

# Para testar outras perguntas:
# set_dialogo("5 + 4 = ?", ["3", "9", "8", "7", "10"], 1)

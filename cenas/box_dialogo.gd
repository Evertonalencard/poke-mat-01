extends HBoxContainer

signal batalha_finalizada(vitoria: bool)

@onready var equacao_label = $Equacao/Label
@onready var botoes = [
	$VBoxContainer/Resposta1,
	$VBoxContainer/Resposta2,
	$VBoxContainer/Resposta3,
	$VBoxContainer/Resposta4,
	$VBoxContainer/Resposta5,
]

# CORRETO (nome real do nó):
@onready var barra_vida_player = $"../../battleBoxPlayer/StausPlayer/VBoxContainer/ProgressBar"
@onready var barra_vida_inimigo = $"../../battleBoxInimogo/StausPlayer/VBoxContainer/ProgressBar"

var selecao_atual: int = 0
var resposta_certa: int = -1
var respondido: bool = false
var vida_player: int = 5
var vida_inimigo: int = 5
var perguntas = []
var idx_pergunta_atual := 0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func carregar_batalha(perguntas_array: Array, eq: String, alts: Array, corr: int):
	vida_player = 5
	vida_inimigo = 5
	idx_pergunta_atual = 0
	respondido = false
	
	if perguntas_array.size() > 0:
		perguntas = perguntas_array
	else:
		perguntas = [{"eq": eq, "alts": alts, "correta": corr}]
	
	if barra_vida_player:
		barra_vida_player.max_value = 5
		barra_vida_player.value = vida_player
	if barra_vida_inimigo:
		barra_vida_inimigo.max_value = 5
		barra_vida_inimigo.value = vida_inimigo
	
	atualizar_selecao()
	proxima_pergunta()

func proxima_pergunta():
	respondido = false
	if idx_pergunta_atual < perguntas.size():
		var q = perguntas[idx_pergunta_atual]
		set_dialogo(q["eq"], q["alts"], q["correta"])
	else:
		finalizar_batalha()

func set_dialogo(equacao: String, alternativas: Array, correta: int):
	if equacao_label:
		equacao_label.text = equacao
	for i in range(botoes.size()):
		if i < alternativas.size() and botoes[i]:
			botoes[i].text = alternativas[i]
			botoes[i].visible = true
		elif botoes[i]:
			botoes[i].visible = false
	resposta_certa = correta

func _input(event):
	# Verifica se o HudBatalha pai está visível
	if not get_parent().get_parent().visible or respondido:
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
				botoes[i].modulate = Color(1, 1, 1, 1)
			else:
				botoes[i].modulate = Color(0.7, 0.7, 0.7, 1)

func checar_resposta(indice: int):
	if respondido:
		return
	respondido = true
	if indice == resposta_certa:
		botoes[indice].modulate = Color(0, 1, 0, 1)
		vida_inimigo -= 1
	else:
		botoes[indice].modulate = Color(1, 0, 0, 1)
		vida_player -= 1
	await get_tree().create_timer(1.2).timeout
	update_barras_vida()
	if vida_inimigo == 0:
		await get_tree().create_timer(0.5).timeout
		emit_signal("batalha_finalizada", true)
	elif vida_player == 0:
		await get_tree().create_timer(0.5).timeout
		emit_signal("batalha_finalizada", false)
	else:
		idx_pergunta_atual += 1
		proxima_pergunta()

func update_barras_vida():
	if barra_vida_player:
		barra_vida_player.value = vida_player
	if barra_vida_inimigo:
		barra_vida_inimigo.value = vida_inimigo

func finalizar_batalha():
	if vida_inimigo <= 0:
		emit_signal("batalha_finalizada", true)
	else:
		emit_signal("batalha_finalizada", false)

extends HBoxContainer

@onready var equacao_label = $Equacao/Label
@onready var botoes = [
	$VBoxContainer/Resposta1,
	$VBoxContainer/Resposta2,
	$VBoxContainer/Resposta3,
	$VBoxContainer/Resposta4,
	$VBoxContainer/Resposta5,
]

@onready var barra_vida_player = $"../../battleBoxPlayer/StausPlayer/VBoxContainer/ProgressBar"
@onready var barra_vida_inimigo = $"../../battleBoxInimogo/StausPlayer/VBoxContainer/ProgressBar"

var selecao_atual: int = 0
var resposta_certa: int = -1
var respondido: bool = false
var vida_player: int = 5
var vida_inimigo: int = 5

# Para armazenar perguntas vindas do inimigo:
var perguntas = []
var idx_pergunta_atual := 0

func _ready():
	atualizar_selecao()
	# Você pode ajustar o max_value se for necessário
	barra_vida_player.max_value = 5
	barra_vida_inimigo.max_value = 5
	barra_vida_player.value = vida_player
	barra_vida_inimigo.value = vida_inimigo

	carregar_perguntas_do_inimigo()
	update_barras_vida()
	proxima_pergunta()

func carregar_perguntas_do_inimigo():
	# Recebe os dados do inimigo via GlobalData
	perguntas = []
	# Suporta tanto array de perguntas, quanto só uma questão
	if typeof(GlobalData.perguntas) == TYPE_ARRAY and GlobalData.perguntas.size() > 0:
		perguntas = GlobalData.perguntas
	elif GlobalData.equacao != "":
		perguntas.append({
			"eq": GlobalData.equacao,
			"alts": GlobalData.alternativas,
			"correta": GlobalData.correta
		})
	else:
		# fallback: demo perguntas
		perguntas = [
			{"eq": "2+2=?", "alts": ["3","4","5","6","7"], "correta": 1},
			{"eq": "3+5=?", "alts": ["7","8","9","10","6"], "correta": 1}
		]

	idx_pergunta_atual = 0

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
		inimigo_derrotado()
	elif vida_player == 0:
		await get_tree().create_timer(0.5).timeout
		player_derrotado()
	else:
		idx_pergunta_atual += 1
		proxima_pergunta()

func update_barras_vida():
	if barra_vida_player:
		barra_vida_player.value = vida_player
	if barra_vida_inimigo:
		barra_vida_inimigo.value = vida_inimigo

func inimigo_derrotado():
	# Sinaliza ao mapa para remover este inimigo:
	GlobalData.inimigos_derrotados.append(GlobalData.inimigo_para_remover)
	GlobalData.player_pos = get_tree().get_root().get_node(".").position
	get_tree().change_scene_to_file("res://cenas/main.tscn") # ajuste para o caminho correto do seu mapa
	
	
func player_derrotado():
	GlobalData.remover_inimigo_ao_voltar = false
	get_tree().change_scene_to_file("res://cenas/morte.tscn") # ajuste para sua tela de derrota

func finalizar_batalha():
	get_tree().change_scene_to_file("res://cenas/main.tscn")
	
	

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

@onready var barra_vida_player = $"../../battleBoxPlayer/StausPlayer/VBoxContainer/ProgressBar"
@onready var barra_vida_inimigo = $"../../battleBoxInimogo/StausPlayer/VBoxContainer/ProgressBar"
@onready var nome_inimigo_label = $"../../battleBoxInimogo/StausPlayer/VBoxContainer/Nome"
@onready var sprite_inimigo = $"../../SpriteInimigo"

var resposta_certa: int = -1
var respondido: bool = false
var vida_player: int = 3
var vida_inimigo: int = 3
var perguntas = []
var idx_pergunta_atual := 0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Conecta o sinal de clique de cada botão
	for i in range(botoes.size()):
		if botoes[i]:
			botoes[i].connect("pressed", Callable(self, "_on_botao_clicado").bind(i))

func carregar_batalha(perguntas_array: Array, eq: String, alts: Array, corr: int, nome_inimigo: String, sprite_inimigo_tex: Texture2D):
	vida_player = 3
	vida_inimigo = 3
	idx_pergunta_atual = 0
	respondido = false
	
	# Atualiza nome do inimigo
	if nome_inimigo_label:
		nome_inimigo_label.text = nome_inimigo
	
	# Atualiza sprite do inimigo com escala ajustada
	if sprite_inimigo and sprite_inimigo_tex:
		sprite_inimigo.texture = sprite_inimigo_tex
		var tamanho_desejado = Vector2(500, 500)
		var tamanho_original = sprite_inimigo_tex.get_size()
		var escala = min(
			tamanho_desejado.x / tamanho_original.x,
			tamanho_desejado.y / tamanho_original.y
		)
		sprite_inimigo.scale = Vector2(escala, escala)
	
	# Carrega perguntas
	if perguntas_array.size() > 0:
		perguntas = perguntas_array
	else:
		perguntas = [{"eq": eq, "alts": alts, "correta": corr}]
	
	# Configura barras de vida
	if barra_vida_player:
		barra_vida_player.max_value = 3
		barra_vida_player.value = vida_player
	if barra_vida_inimigo:
		barra_vida_inimigo.max_value = 3
		barra_vida_inimigo.value = vida_inimigo
	
	# Inicia primeira pergunta
	proxima_pergunta()

func proxima_pergunta():
	respondido = false
	
	# Reseta cores dos botões
	resetar_cores_botoes()
	
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
			botoes[i].disabled = false  # Habilita o botão
		elif botoes[i]:
			botoes[i].visible = false
	
	resposta_certa = correta

func resetar_cores_botoes():
	for botao in botoes:
		if botao:
			botao.modulate = Color(1, 1, 1, 1)  # Cor normal

func _on_botao_clicado(indice: int):
	if respondido:
		return
	checar_resposta(indice)

func checar_resposta(indice: int):
	if respondido:
		return
	
	respondido = true
	
	# Desabilita todos os botões para evitar múltiplos cliques
	for botao in botoes:
		if botao:
			botao.disabled = true
	
	# Feedback visual: verde = acerto, vermelho = erro
	if indice == resposta_certa:
		botoes[indice].modulate = Color(0, 1, 0, 1)  # Verde
		vida_inimigo -= 1
	else:
		botoes[indice].modulate = Color(1, 0, 0, 1)  # Vermelho
		# Mostra também qual era a resposta correta
		if resposta_certa >= 0 and resposta_certa < botoes.size():
			botoes[resposta_certa].modulate = Color(0, 1, 0, 1)  # Verde
		vida_player -= 1
	
	await get_tree().create_timer(1.5).timeout
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

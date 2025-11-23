extends Node2D

var next_scene = null
var mostrar_batalha = false
var inimigo_atual = null

var player_location = Vector2.ZERO
var player_direction = Vector2.ZERO

@onready var color_rect: ColorRect = $ScreenTransition/ColorRect
@onready var musicafundo: AudioStreamPlayer = $musicafundo

# NÃO use @onready para esses, pois vão mudar de cena
var pause_menu = null
var hud_batalha = null
var player = null

func _ready() -> void:
	add_to_group("scene_manager")
	color_rect.color = Color(0,0,0,0)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Busca os nós dinamicamente
	atualizar_referencias()
	
	# Remove inimigos derrotados ao iniciar
	remover_inimigos_derrotados()
	
	# Conecta sinais
	conectar_sinais()

	# --- Música de fundo ---
	if musicafundo and musicafundo.stream:
		musicafundo.stream.set_loop(true)
		musicafundo.play()

func atualizar_referencias():
	# Busca player por grupo
	player = get_tree().get_first_node_in_group("player")
	
	# Busca HUD Batalha e Pause por grupo
	hud_batalha = get_tree().get_first_node_in_group("hud_batalha")
	pause_menu = get_tree().get_first_node_in_group("hud_pause")
	
	# Se não achou por grupo, tenta achar como filho do player
	if not hud_batalha and player:
		hud_batalha = player.get_node_or_null("HudBatalha")
	
	if not pause_menu and player:
		pause_menu = player.get_node_or_null("HudPause")
	
	# Configura visibilidade
	if is_instance_valid(hud_batalha):
		hud_batalha.visible = false


func conectar_sinais():
	if is_instance_valid(hud_batalha) and not hud_batalha.is_connected("batalha_finalizada", Callable(self, "_on_batalha_finalizada")):
		hud_batalha.connect("batalha_finalizada", Callable(self, "_on_batalha_finalizada"))
	
	if is_instance_valid(pause_menu):
		if not pause_menu.is_connected("continuar", Callable(self, "_on_pause_continuar")):
			pause_menu.connect("continuar", Callable(self, "_on_pause_continuar"))
		if not pause_menu.is_connected("menu_principal", Callable(self, "_on_pause_menu_principal")):
			pause_menu.connect("menu_principal", Callable(self, "_on_pause_menu_principal"))

func transition_to_scene(new_scene: String, spawn_location, spawn_direction):
	next_scene = new_scene
	player_location = spawn_location
	player_direction = spawn_direction
	
	if is_instance_valid(hud_batalha):
		hud_batalha.visible = false
	get_tree().paused = false
	mostrar_batalha = false
	inimigo_atual = null
	
	GlobalData.player_pos = spawn_location
	
	print("chamado transitio")
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")

func finished_fading():
	print("DEBUG: finished_fading CHAMADO")
	$CurrentScene.get_child(0).queue_free()
	$CurrentScene.add_child(load(next_scene).instantiate())
	await get_tree().process_frame
	
	# Atualiza todas as referências na nova cena
	atualizar_referencias()
	
	# Busca o player e faz spawn
	if player and is_instance_valid(player):
		player.set_spawn(player_location, player_direction)
	
	# Remove inimigos derrotados
	remover_inimigos_derrotados()
	
	# Reconecta sinais
	conectar_sinais()
	
	$ScreenTransition/AnimationPlayer.play("FadeToNormal")

func iniciar_batalha(inimigo):
	if not is_instance_valid(hud_batalha):
		print("ERRO: HudBatalha não encontrado!")
		atualizar_referencias()  # Tenta encontrar novamente
		if not is_instance_valid(hud_batalha):
			return
	
	mostrar_batalha = true
	inimigo_atual = inimigo
	get_tree().paused = true
	hud_batalha.visible = true
	
	hud_batalha.carregar_batalha(
		inimigo.perguntas, 
		inimigo.equacao, 
		inimigo.alternativas, 
		inimigo.correta,
		inimigo.nome_exibicao,
		inimigo.sprite_batalha
	)

func _on_batalha_finalizada(vitoria: bool):
	mostrar_batalha = false
	
	if is_instance_valid(hud_batalha):
		hud_batalha.visible = false
	
	get_tree().paused = false
	
	if vitoria and is_instance_valid(inimigo_atual):
		if inimigo_atual.unique_name not in GlobalData.inimigos_derrotados:
			GlobalData.inimigos_derrotados.append(inimigo_atual.unique_name)
		
		print("Inimigo derrotado: ", inimigo_atual.unique_name)
		print("Total derrotados: ", GlobalData.inimigos_derrotados)
		
		inimigo_atual.queue_free()
		inimigo_atual = null
		
		if GlobalData.verificar_vitoria():
			print("TODOS OS INIMIGOS CHAVE DERROTADOS! VOCÊ VENCEU!")
			await get_tree().create_timer(1.0).timeout
			GlobalData.resetar_progresso()
			get_tree().change_scene_to_file("res://cenas/ganhou.tscn")
	
	elif not vitoria:
		get_tree().change_scene_to_file("res://cenas/morte.tscn")

func _input(event):
	# Verifica se pause_menu existe antes de usar
	if not is_instance_valid(pause_menu):
		atualizar_referencias()  # Tenta encontrar novamente
		if not is_instance_valid(pause_menu):
			return
	
	if event.is_action_pressed("ui_cancel") and not get_tree().paused:
		pause_menu.mostrar()
	elif event.is_action_pressed("ui_cancel") and get_tree().paused and pause_menu.visible:
		pause_menu.esconder()

func _on_pause_continuar():
	pass

func _on_pause_menu_principal():
	pass

func remover_inimigos_derrotados():
	await get_tree().process_frame
	for inimigo in get_tree().get_nodes_in_group("inimigos"):
		if is_instance_valid(inimigo) and inimigo.unique_name in GlobalData.inimigos_derrotados:
			print("Removendo inimigo derrotado: ", inimigo.unique_name)
			inimigo.queue_free()

extends Node2D

var next_scene = null
@onready var pause_menu = $CurrentScene/Town/Node2D/Player/HudPause
@onready var hud_batalha = $CurrentScene/Town/Node2D/Player/HudBatalha
@onready var player = $CurrentScene/Town/Node2D/Player
@onready var color_rect: ColorRect = $ScreenTransition/ColorRect

var mostrar_batalha = false
var inimigo_atual = null
var player_location = Vector2.ZERO
var player_direction = Vector2.ZERO

func _ready() -> void:
	add_to_group("scene_manager")
	color_rect.color = Color(0,0,0,0)
	process_mode = Node.PROCESS_MODE_ALWAYS
	hud_batalha.visible = false
	hud_batalha.connect("batalha_finalizada", Callable(self, "_on_batalha_finalizada"))
	pause_menu.connect("continuar", Callable(self, "_on_pause_continuar"))
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
	
	print("chamado transitio")
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")
	
	
func finished_fading():
	print("DEBUG: finished_fading CHAMADO")
	$CurrentScene.get_child(0).queue_free()
	$CurrentScene.add_child(load(next_scene).instantiate())
	await get_tree().process_frame
	
	# Busca o novo player
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node and is_instance_valid(player_node):
		player_node.set_spawn(player_location, player_direction)
	
	# REMOVA ESTA LINHA:
	# player.set_spawn(player_location, player_direction)  ❌
	
	# Atualiza as referências para os novos nós
	player = player_node  # Atualiza a referência
	hud_batalha = $CurrentScene.get_node_or_null("Town/Node2D/Player/HudBatalha")
	pause_menu = $CurrentScene.get_node_or_null("Town/Node2D/Player/HudPause")
	
	# Reconecta sinais
	if is_instance_valid(hud_batalha) and not hud_batalha.is_connected("batalha_finalizada", Callable(self, "_on_batalha_finalizada")):
		hud_batalha.connect("batalha_finalizada", Callable(self, "_on_batalha_finalizada"))
		
	if is_instance_valid(pause_menu):
		if not pause_menu.is_connected("continuar", Callable(self, "_on_pause_continuar")):
			pause_menu.connect("continuar", Callable(self, "_on_pause_continuar"))
		if not pause_menu.is_connected("menu_principal", Callable(self, "_on_pause_menu_principal")):
			pause_menu.connect("menu_principal", Callable(self, "_on_pause_menu_principal"))
	
	$ScreenTransition/AnimationPlayer.play("FadeToNormal")




func iniciar_batalha(inimigo):
	mostrar_batalha = true
	inimigo_atual = inimigo
	get_tree().paused = true
	hud_batalha.visible = true
	
	# Passa também o nome e sprite do inimigo
	hud_batalha.carregar_batalha(
		inimigo.perguntas, 
		inimigo.equacao, 
		inimigo.alternativas, 
		inimigo.correta,
		inimigo.nome_exibicao,  # Novo parâmetro
		inimigo.sprite_batalha   # Novo parâmetro
	)

func _on_batalha_finalizada(vitoria: bool):
	mostrar_batalha = false
	hud_batalha.visible = false
	get_tree().paused = false
	
	if vitoria and inimigo_atual:
		# Adiciona o inimigo derrotado à lista
		if inimigo_atual.unique_name not in GlobalData.inimigos_derrotados:
			GlobalData.inimigos_derrotados.append(inimigo_atual.unique_name)
		
		print("Inimigo derrotado: ", inimigo_atual.unique_name)
		print("Total derrotados: ", GlobalData.inimigos_derrotados)
		
		inimigo_atual.queue_free()
		inimigo_atual = null
		
		# Verifica se todos os inimigos chave foram derrotados
		if GlobalData.verificar_vitoria():
			print("TODOS OS INIMIGOS CHAVE DERROTADOS! VOCÊ VENCEU!")
			await get_tree().create_timer(1.0).timeout
			GlobalData.resetar_progresso()
			get_tree().change_scene_to_file("res://cenas/ganhou.tscn")
		
	elif not vitoria:
		get_tree().change_scene_to_file("res://cenas/morte.tscn")
		
func _input(event):
	if event.is_action_pressed("ui_cancel") and not get_tree().paused:
		pause_menu.mostrar()
	elif event.is_action_pressed("ui_cancel") and get_tree().paused and pause_menu.visible:
		pause_menu.esconder()

func _on_pause_continuar():
	# Código extra se quiser quando sair do pause
	pass

func _on_pause_menu_principal():
	# Não precisa implementar aqui a saída, já está na tela de pause
	pass

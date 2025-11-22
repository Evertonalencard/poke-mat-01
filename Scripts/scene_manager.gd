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
	print("chamado transitio")
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")
	
	
func finished_fading():
	print("DEBUG: finished_fading CHAMADO")
	$CurrentScene.get_child(0).queue_free()
	$CurrentScene.add_child(load(next_scene).instantiate())
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	player.set_spawn(player_location, player_direction)
	
	$ScreenTransition/AnimationPlayer.play("FadeToNormal")




func iniciar_batalha(inimigo):
	
	mostrar_batalha = true
	inimigo_atual = inimigo
	
	# Pausa o jogo (player para de se mover)
	get_tree().paused = true
	
	# Mostra o HUD
	hud_batalha.visible = true
	hud_batalha.carregar_batalha(inimigo.perguntas, inimigo.equacao, inimigo.alternativas, inimigo.correta)

func _on_batalha_finalizada(vitoria: bool):
	mostrar_batalha = false
	hud_batalha.visible = false
	get_tree().paused = false
	
	if vitoria and inimigo_atual:
		inimigo_atual.queue_free()
		inimigo_atual = null
	elif not vitoria:
		# Player perdeu - pode ir para tela de morte
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

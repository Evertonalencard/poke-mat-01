extends Node2D

@onready var pause_menu = $Player/HudPause
@onready var hud_batalha = $Player/HudBatalha
@onready var player = $Player

var mostrar_batalha = false
var inimigo_atual = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	hud_batalha.visible = false
	hud_batalha.connect("batalha_finalizada", Callable(self, "_on_batalha_finalizada"))
	pause_menu.connect("continuar", Callable(self, "_on_pause_continuar"))
	pause_menu.connect("menu_principal", Callable(self, "_on_pause_menu_principal"))


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

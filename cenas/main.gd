extends Node2D

@onready var hud_batalha = $Player/HudBatalha
@onready var player = $Player

var mostrar_batalha = false
var inimigo_atual = null

func _ready():
	hud_batalha.visible = false
	hud_batalha.connect("batalha_finalizada", Callable(self, "_on_batalha_finalizada"))


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

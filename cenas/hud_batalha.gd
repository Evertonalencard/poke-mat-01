# Script: hud_batalha.gd (anexado ao nó root HudBatalha)
extends CanvasLayer  # ou Control, dependendo do tipo do nó

signal batalha_finalizada(vitoria: bool)

@onready var box_dialogo = $fundoResposta/boxDialogo

func _ready():
	add_to_group("hud_batalha")
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func carregar_batalha(perguntas_array: Array, eq: String, alts: Array, corr: int, nome_inimigo: String, sprite_inimigo: Texture2D):	# Repassa para o boxDialogo
	box_dialogo.carregar_batalha(perguntas_array, eq, alts, corr, nome_inimigo, sprite_inimigo)
	# Conecta o sinal do boxDialogo
	if not box_dialogo.is_connected("batalha_finalizada", Callable(self, "_on_box_batalha_finalizada")):
		box_dialogo.connect("batalha_finalizada", Callable(self, "_on_box_batalha_finalizada"))

func _on_box_batalha_finalizada(vitoria: bool):
	# Repassa o sinal para o Main
	emit_signal("batalha_finalizada", vitoria)

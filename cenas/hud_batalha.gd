# Script: hud_batalha.gd (anexado ao nó root HudBatalha)
extends CanvasLayer  # ou Control, dependendo do tipo do nó

signal batalha_finalizada(vitoria: bool)

@onready var box_dialogo = $fundoResposta/boxDialogo

func _ready():
	print("Tentando achar barras...")
	print("Player bar: ", get_node_or_null("../../battleBoxPlayer/StatusPlayer/VBoxContainer/ProgressBar"))
	print("Enemy bar: ", get_node_or_null("../../battleBoxInimogo/StatusPlayer/VBoxContainer/ProgressBar"))
	get_tree().get_root().print_tree_pretty()
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func carregar_batalha(perguntas_array: Array, eq: String, alts: Array, corr: int):
	# Repassa para o boxDialogo
	box_dialogo.carregar_batalha(perguntas_array, eq, alts, corr)
	# Conecta o sinal do boxDialogo
	if not box_dialogo.is_connected("batalha_finalizada", Callable(self, "_on_box_batalha_finalizada")):
		box_dialogo.connect("batalha_finalizada", Callable(self, "_on_box_batalha_finalizada"))

func _on_box_batalha_finalizada(vitoria: bool):
	# Repassa o sinal para o Main
	emit_signal("batalha_finalizada", vitoria)

extends CanvasLayer

signal batalha_finalizada(vitoria: bool)

@onready var box_dialogo = $fundoResposta/boxDialogo
@onready var sombatalha: AudioStreamPlayer = $sombatalha

var _musicas_antes_da_batalha: Array[AudioStreamPlayer] = []


func _ready() -> void:
	add_to_group("hud_batalha")
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	


func carregar_batalha(perguntas_array: Array, eq: String, alts: Array, corr: int, nome_inimigo: String, sprite_inimigo: Texture2D):
	box_dialogo.carregar_batalha(perguntas_array, eq, alts, corr, nome_inimigo, sprite_inimigo)

	if not box_dialogo.is_connected("batalha_finalizada", Callable(self, "_on_box_batalha_finalizada")):
		box_dialogo.connect("batalha_finalizada", Callable(self, "_on_box_batalha_finalizada"))

	_musicas_antes_da_batalha.clear()
	for player in get_tree().get_nodes_in_group("musica_fundo"):
		if player is AudioStreamPlayer:
			if player.playing:
				_musicas_antes_da_batalha.append(player)
				player.stop()

	


func _on_box_batalha_finalizada(vitoria: bool):
	if sombatalha.playing:
		sombatalha.stop()

	for player in _musicas_antes_da_batalha:
		if is_instance_valid(player) and player is AudioStreamPlayer:
			if player.stream:
				player.play()

	_musicas_antes_da_batalha.clear()

	emit_signal("batalha_finalizada",vitoria)

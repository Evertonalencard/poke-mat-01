extends Area2D

@export var unique_name: String = "inimigo1"
@export var nome_exibicao: String = "Inimigo Teste"  # Nome que aparece na batalha
@export var sprite_batalha: Texture2D  # Sprite do inimigo na batalha

# Array genérico (não tipado) - aceita Dictionaries
@export var perguntas: Array = []

# Ou, alternativa com valores padrão:
@export var equacao: String = ""
@export var alternativas: Array[String] = []
@export var correta: int = 0

var batalha_iniciada = false

func _ready():
	add_to_group("inimigos")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player") and not batalha_iniciada:
		batalha_iniciada = true
		await get_tree().process_frame
		get_node("/root/SceneManager").iniciar_batalha(self)

			

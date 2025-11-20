extends Area2D

@export var unique_name: String = "inimigo1"

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
		get_parent().iniciar_batalha(self)

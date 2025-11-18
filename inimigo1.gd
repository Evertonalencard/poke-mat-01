# Script do inimigo (em Area2D)
extends Area2D
# Script: inimigo.gd


# Variáveis exportadas - cada instância terá valores diferentes
@export var equacao: String = ""
@export var alternativas: Array[String] = []
@export var correta: int = 0

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))


func _on_body_entered(body):
	if body.is_in_group("player"):
		# Salva os dados deste inimigo no GlobalData
		GlobalData.equacao = equacao
		GlobalData.alternativas = alternativas
		GlobalData.correta = correta
		# Abre a tela de batalha
		get_tree().change_scene_to_file("res://cenas/hud_batalha.tscn")

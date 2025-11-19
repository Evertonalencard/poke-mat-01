extends Area2D

@export var unique_name: String = "inimigo01"
@export var equacao: String = ""
@export var alternativas: Array[String] = []
@export var correta: int = 0
@export var perguntas: Array = [
	{"eq": "2+2=?", "alts": ["3","4","5","6","7"], "correta": 1},
	{"eq": "3+5=?", "alts": ["7","8","9","10","6"], "correta": 1},
	{"eq": "7-2=?", "alts": ["4","5","6","3","2"], "correta": 1},
	{"eq": "6/2=?", "alts": ["2","3","4","5","6"], "correta": 1},
	{"eq": "10-8=?", "alts": ["1","2","3","4","5"], "correta": 1}
	] # opcional: para batalhas com várias perguntas

func _ready():
	add_to_group("inimigos")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		GlobalData.equacao = equacao
		GlobalData.alternativas = alternativas
		GlobalData.correta = correta
		GlobalData.perguntas = perguntas # se quiser várias perguntas do inimigo
		GlobalData.inimigo_para_remover = get_instance_id()
		get_tree().change_scene_to_file("res://cenas/hud_batalha.tscn")

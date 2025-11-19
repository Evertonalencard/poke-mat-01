extends Node

# Dados da operação matemática
var equacao: String = ""
var alternativas: Array = []
var correta: int = -1

var perguntas = []
var inimigo_para_remover = 0 # recebe o instance_id do inimigo que começou a luta
var remover_inimigo_ao_voltar = false  # controla se o inimigo deve sumir ao voltar

# Exemplo: GlobalData.gd
var inimigos_derrotados = [] # Lista de IDs ou nomes
var player_pos = Vector2()   # Posição do player
var vida_player = 5

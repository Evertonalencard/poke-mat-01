extends Node

# Dados da operação matemática
var equacao: String = ""
var alternativas: Array = []
var correta: int = -1
var perguntas = []
var inimigo_para_remover = 0 # recebe o instance_id do inimigo que começou a luta
var remover_inimigo_ao_voltar = false  # controla se o inimigo deve sumir ao voltar

# Controle de inimigos derrotados
var inimigos_derrotados = [] # Lista de IDs ou nomes
var player_pos = Vector2()   # Posição do player
var vida_player = 3

# Lista dos inimigos "chave" que precisam ser derrotados para vencer
var inimigos_chave = ["inimigo4", "inimigo5", "inimigo6", "inimigo7", "inimigo8"]

# Função para verificar se todos os inimigos chave foram derrotados
func verificar_vitoria() -> bool:
	for inimigo in inimigos_chave:
		if inimigo not in inimigos_derrotados:
			return false
	return true

# Função para resetar o progresso
func resetar_progresso():
	inimigos_derrotados.clear()
	player_pos = Vector2()
	vida_player = 3

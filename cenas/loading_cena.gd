extends CanvasLayer

@onready var progress_bar = $VBoxContainer/ProgressBar
@onready var label = $VBoxContainer/Label

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Inicializa a barra
	progress_bar.value = 0

func update_progress(value: float):
	# Atualiza o progresso (value está entre 0 e 1)
	progress_bar.value = value * 100
	label.text = "Carregando... " + str(int(value * 100)) + "%"

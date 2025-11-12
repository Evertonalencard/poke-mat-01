extends Node

# Referências
var loading_screen_scene = preload("res://cenas/loading_cena.tscn")
var loading_screen_instance = null

# Controle de carregamento
var scene_path: String = ""
var progress: Array = []

func load_scene(path: String):
	scene_path = path
	
	# Instancia e adiciona a tela de loading
	loading_screen_instance = loading_screen_scene.instantiate()
	get_tree().root.add_child(loading_screen_instance)
	
	# Move a loading screen para frente
	loading_screen_instance.show()
	
	# Inicia o carregamento em background
	# use_sub_threads = true usa múltiplas threads para carregar mais rápido
	ResourceLoader.load_threaded_request(scene_path, "", true)

func _process(_delta):
	# Se não há cena sendo carregada, não faz nada
	if scene_path == "":
		return
	
	# Verifica o status do carregamento
	var status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	
	# Atualiza o progresso na tela de loading
	if loading_screen_instance != null and progress.size() > 0:
		loading_screen_instance.update_progress(progress[0])
	
	# Quando terminar
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		# Obtém a cena carregada
		var packed_scene = ResourceLoader.load_threaded_get(scene_path)
		
		# Muda para a nova cena
		get_tree().change_scene_to_packed(packed_scene)
		
		# Remove a tela de loading
		if loading_screen_instance != null:
			loading_screen_instance.queue_free()
			loading_screen_instance = null
		
		# Reseta o caminho
		scene_path = ""
	
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		push_error("Falha ao carregar cena: " + scene_path)
		scene_path = ""

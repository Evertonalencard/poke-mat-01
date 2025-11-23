extends Area2D

@export var target_position: Vector2 = Vector2.ZERO
@export var lock_time: float = 0.3   # evita teleporte duplo

var is_locked: bool = false

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	# Só teleporta o player
	if not body is CharacterBody2D:
		return

	if is_locked:
		return

	is_locked = true

	# Teleporta o player
	body.global_position = target_position

	# Pequeno delay para não reentrar no portal ao chegar no destino
	await get_tree().create_timer(lock_time).timeout
	is_locked = false

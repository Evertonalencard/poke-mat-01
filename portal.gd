extends Area2D

@export var portal_id: int = 0
var portal_is_locked: bool = false

func lock_portal() -> void:
	portal_is_locked = true
	await get_tree().create_timer(0.5).timeout
	portal_is_locked = false

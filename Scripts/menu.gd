extends CanvasLayer

@onready var select_arrow: TextureRect = $Control/NinePatchRect/TextureRect
@onready var menu: Control = $Control

enum ScreenLoaded {NOTHING, JUST_MENU, PARTY_SCREEN,}
var screen_loaded = ScreenLoaded.NOTHING

var selected_option = 0

func _ready() -> void:
	menu.visible = false
	select_arrow.position.y = 6 + (selected_option % 6) * 14

func _unhandled_input(event: InputEvent) -> void:
	match screen_loaded:
		ScreenLoaded.NOTHING:
			if event.is_action_pressed("menu"):
				menu.visible = true
				screen_loaded = ScreenLoaded.JUST_MENU
		ScreenLoaded.JUST_MENU:
			if event.is_action_pressed("menu") or event.is_action_pressed("x"):
				menu.visible = false
				screen_loaded = ScreenLoaded.NOTHING
			elif event.is_action("ui_down"):
				selected_option += 1 
				select_arrow.position.y = 6 + (selected_option % 6) * 14
			elif event.is_action("ui_up"):
				if selected_option == 0:
					selected_option = 5
				else:
					selected_option -= 1
				select_arrow.position.y = 6 + (selected_option % 6) * 14
		ScreenLoaded.PARTY_SCREEN:
			pass

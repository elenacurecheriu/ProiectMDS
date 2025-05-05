extends Node2D
@onready var pause_menu = $Camera2D/Pause_menu
var paused = false
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		pause_menu_()

func pause_menu_():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
		
	paused = ! paused	

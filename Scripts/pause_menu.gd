extends Control
@onready var main = $"../../.."
@onready var resume_button = $PanelContainer/HBoxContainer/VBoxContainer/Resume as Button
@onready var main_menu_button = $PanelContainer/HBoxContainer/VBoxContainer/Main_Menu as Button
@onready var start_level = preload("res://Menus/pause_menu.tscn")

func _ready():
	hide()
	resume_button.button_down.connect(on_resume_pressed)
	main_menu_button.button_down.connect(on_main_menu_pressed)
	
	
func on_resume_pressed()	-> void:
	
	main.pause_menu_()

func on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")

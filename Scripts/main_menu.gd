class_name Main_menu
extends Control

@onready var play_button = $PanelContainer/HBoxContainer/VBoxContainer/Play as Button
@onready var exit_button = $"PanelContainer/HBoxContainer/VBoxContainer/HBoxContainer2/VBoxContainer2/Exit" as Button
@onready var start_level = preload("res://Menus/main_menu.tscn")

func _ready():
	play_button.button_down.connect(on_start_pressed)
	exit_button.button_down.connect(on_exit_pressed)
	
	
func on_start_pressed()	-> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	
func on_exit_pressed() -> void:
	get_tree().quit()

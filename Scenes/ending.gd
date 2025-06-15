extends Node2D

var endDialogue = load("res://Dialogues/end.dialogue")

func _ready():
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.show_dialogue_balloon(endDialogue, "start")

func _on_dialogue_ended(resource):
	if resource == endDialogue:
		get_tree().change_scene_to_file("res://Menus/main_menu.tscn")

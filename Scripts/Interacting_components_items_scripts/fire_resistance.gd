
extends Node2D
@onready var interactable: Area2D = $Interactable
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	interactable.interact = _on_interact
	
func _find_player(node):
	for child in node.get_children():
		if child is CharacterBody2D:
			return child
		var found = _find_player(child)
		if found:
			return found
	return null

func _on_interact():
	var player_node = get_tree().get_first_node_in_group("player")
	var player = _find_player(player_node)
		
	player.increase_stat("fire_resistance")
	var new_value = player.get_stat("fire_resistance")
	print("Gained 1 fire. New fire_resistance: " + str(new_value))
	

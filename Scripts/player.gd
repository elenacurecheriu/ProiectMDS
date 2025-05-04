
extends CharacterBody2D

@export var speed = 350

var activeInteractions = []

func _ready() -> void:
	print("player.gd initialised")
	pass
	
func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _physics_process(delta):
	get_input()
	move_and_slide()
	
	if Input.is_action_just_pressed("Interact"):
		handleInteractions()


func _on_interaction_area_area_entered(area: Area2D) -> void:
	activeInteractions.insert(0, area)
	print("Interaction Entered")


func _on_interaction_area_area_exited(area: Area2D) -> void:
	activeInteractions.erase(area)
	print("Interaction Left")
	
func handleInteractions() -> void:
	if !activeInteractions:
		return
		
	activeInteractions[0].ActivateInteraction()

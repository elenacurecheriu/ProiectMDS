extends Area2D

var firstDialogue = load("res://Dialogues/butterfly.dialogue")

var player

var in_interaction_area = false
var dialogue_started = false
var finished_first_part = false
var has_flower = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if in_interaction_area and Input.is_action_pressed("Interact") and not dialogue_started:
		dialogue_started = true
		start_dialogue()
	pass

func start_dialogue():
	print("starting dialogue")
	if not finished_first_part:
		DialogueManager.show_dialogue_balloon(firstDialogue, "start")

		get_node("../../../blue_flower").visible = true

		return
	if finished_first_part and not has_flower:
		DialogueManager.show_dialogue_balloon(firstDialogue, "colorful")
		return
	if has_flower:
		DialogueManager.show_dialogue_balloon(firstDialogue, "has_flower")
		return
	DialogueManager.show_dialogue_balloon(firstDialogue, "end_loop")

func gave_the_flower():
	print("change scene")
	

func _on_body_entered(body: Node2D) -> void:
	if name == "DialogueInteractionArea":
		if body.is_in_group("player"):

			player = body
			in_interaction_area = true
			

func _on_dialogue_ended(resource):
	dialogue_started = false
	if not finished_first_part:
		finished_first_part = true
	if has_flower:
		get_tree().change_scene_to_file("res://Scenes/levels/village_2.tscn")

func _on_body_exited(body: Node2D) -> void:
	if name == "DialogueInteractionArea":
		if body.is_in_group("player"):
			in_interaction_area = false
			has_flower = true
	

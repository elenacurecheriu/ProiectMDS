extends Area2D

var firstDialogue = load("res://Dialogues/butterfly.dialogue")

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
	DialogueManager.show_dialogue_balloon(firstDialogue, "end_loop")

func gave_the_flower():
	print("change scene")
	

func _on_body_entered(body: Node2D) -> void:
	if name == "DialogueInteractionArea":
		if body.is_in_group("player"):
			in_interaction_area = true


func _on_dialogue_ended(resource):
	dialogue_started = false

func _on_body_exited(body: Node2D) -> void:
	if name == "DialogueInteractionArea":
		if body.is_in_group("player"):
			in_interaction_area = false
	

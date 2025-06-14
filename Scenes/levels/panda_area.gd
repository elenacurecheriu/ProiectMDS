extends Area2D

var pandaDialogue = load("res://Dialogues/panda.dialogue")

var in_interaction_area = false
var dialogue_started = false
var has_beer = false
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
	if not has_beer:
		DialogueManager.show_dialogue_balloon(pandaDialogue, "inside")
	else:
		DialogueManager.show_dialogue_balloon(pandaDialogue, "end_loop")

var player 
func _on_body_entered(body: Node2D) -> void:
	if name == "InteractionAreaPanda":
		if body.is_in_group("player"):
			in_interaction_area = true
			player = body


func _on_dialogue_ended(resource):
	if resource == pandaDialogue:
		dialogue_started = false
		if not has_beer:
			#functia de adaugat bere
			get_node("../").texture = load("res://assets/character_art/original/darius_af.png")
			has_beer = true
			player.has_beer = true

func _on_body_exited(body: Node2D) -> void:
	if name == "InteractionAreaPanda":
		if body.is_in_group("player"):
			in_interaction_area = false
	

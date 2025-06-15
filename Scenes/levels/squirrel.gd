extends Area2D

var squirrelDialogue = load("res://Dialogues/squirrel.dialogue")
var squirrelAfter = load("res://Dialogues/squirrel_after.dialogue")

var in_interaction_area = false
var dialogue_started = false
var has_glasses = false

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
	if not has_glasses:
		DialogueManager.show_dialogue_balloon(squirrelDialogue, "start")
	else:
		DialogueManager.show_dialogue_balloon(squirrelAfter, "end_loop")

var player
func _on_body_entered(body: Node2D) -> void:
	if name == "SquirrelArea":
		if body.is_in_group("player"):
			in_interaction_area = true
			player = body


func _on_dialogue_ended(resource):
	if resource == squirrelDialogue:
		dialogue_started = false
		if not has_glasses:
			#functia de adaugat ochelarii

			player.increase_stat("pink_glasses")

			get_node("../").texture = load("res://assets/character_art/original/ovidiu_af.png")
			DialogueManager.show_dialogue_balloon(squirrelAfter, "after_transformation")
			has_glasses = true
			player.has_glasses = true
	if resource == squirrelAfter:
		dialogue_started = false
		pass
		
func _on_body_exited(body: Node2D) -> void:
	if name == "SquirrelArea":
		if body.is_in_group("player"):
			in_interaction_area = false
	

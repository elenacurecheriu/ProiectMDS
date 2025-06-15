extends Area2D

var lambDialogue = load("res://Dialogues/lamb.dialogue")
signal blackscreen
var player 
var in_interaction_area = false
var dialogue_started = false
var has_eye = false

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
	if not has_eye:
		DialogueManager.show_dialogue_balloon(lambDialogue, "start")
	else:
		DialogueManager.show_dialogue_balloon(lambDialogue, "end_loop")


func _on_body_entered(body: Node2D) -> void:
	
	if name == "AreaLamb":
		if body.is_in_group("player"):
			player = body
			emit_signal("blackscreen")
			body.dialogue_active = true
			body.position = Vector2(2926,2655)
			dialogue_started = true
			start_dialogue()
			in_interaction_area = true

#
func _on_dialogue_ended(resource):
	if resource == lambDialogue:
		dialogue_started = false
		if not has_eye:
			#functia de adaugat ochelarii

			player.increase_stat("eye")

			
			DialogueManager.show_dialogue_balloon(lambDialogue, "end_loop")
			has_eye = true
			player.has_eye = true
		player.dialogue_active = false
		
func _on_body_exited(body: Node2D) -> void:
	if name == "AreaLamb":
		if body.is_in_group("player"):
			in_interaction_area = false
			get_node("../").texture = load("res://assets/character_art/original/luca_af.png")

extends Area2D

var pandaDialoguetoHouse = load("res://Dialogues/door.dialogue")

var in_interaction_area = false
var dialogue_started = false
var finished_first_part = false
var has_flower = false
var already_knocked = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if in_interaction_area and Input.is_action_pressed("Interact") and not dialogue_started:
		if already_knocked: 
			get_node("../").fadingBlack()
			get_node("../Player").position = Vector2(-2610, 1207)
		else:
			dialogue_started = true
			start_dialogue()
	pass

func start_dialogue():
	DialogueManager.show_dialogue_balloon(pandaDialoguetoHouse, "at_the_door")

func _on_body_entered(body: Node2D) -> void:
	if name == "to_panda_house":
		if body.is_in_group("player"):
			in_interaction_area = true


func _on_dialogue_ended(resource):
	if resource == pandaDialoguetoHouse:
		dialogue_started = false
		already_knocked = true
		
		get_node("../Player").position = Vector2(-2610, 1207)
		get_node("../").fadingBlack()
		get_node("../Player").z_index = 1

func _on_body_exited(body: Node2D) -> void:
	if name == "to_panda_house":
		if body.is_in_group("player"):
			in_interaction_area = false
	

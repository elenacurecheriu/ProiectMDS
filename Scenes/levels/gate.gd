extends Area2D

var gate = load("res://Dialogues/gate.dialogue")
signal blackscreen
var player 
var in_interaction_area = false
var dialogue_started = false
var has_eye = false
var forcefield = true
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
	if player.has_eye and player.has_beer and player.has_glasses:
		DialogueManager.show_dialogue_balloon(gate, "pleased")
	else:
		DialogueManager.show_dialogue_balloon(gate, "not_pleased")


func _on_body_entered(body: Node2D) -> void:
	
	if name == "GateArea":
		if body.is_in_group("player"):
			player = body
			#debug
			#player.has_eye = true
			#player.has_beer = true 
			#player.has_glasses = true
			if forcefield:
				body.position -= Vector2(50,50)
				emit_signal("blackscreen")
				body.dialogue_active = true
				dialogue_started = true
				start_dialogue()
				in_interaction_area = true

#
func _on_dialogue_ended(resource):
	if resource == gate:
		dialogue_started = false
		if player.has_eye and player.has_beer and player.has_glasses:
			emit_signal("blackscreen")
			get_node("../").texture = load("res://assets/levels_art/gateopen.png")
			forcefield = false
		player.dialogue_active = false
		
func _on_body_exited(body: Node2D) -> void:
	if name == "GateArea":
		if body.is_in_group("player"):
			in_interaction_area = false

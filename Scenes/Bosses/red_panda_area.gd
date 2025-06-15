extends Area2D

var bossstart = load("res://Dialogues/redpanda.dialogue")

var in_interaction_area = false
var dialogue_started = false
var has_glasses = false
signal startboss 

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
	DialogueManager.show_dialogue_balloon(bossstart, "start")

var player

func _on_body_entered(body: Node2D) -> void:
	if name == "redPandaArea":
		if body.is_in_group("player"):
			in_interaction_area = true
			player = body


func _on_dialogue_ended(resource):
	if resource == bossstart:
		dialogue_started = false
		player.start_boss = true
		emit_signal("startboss")
	pass
		
func _on_body_exited(body: Node2D) -> void:
	if name == "redPandaArea":
		if body.is_in_group("player"):
			in_interaction_area = false
	pass
	

extends Area2D

var catDialogue = load("res://Dialogues/cat.dialogue")
var catWithMirror = load("res://Dialogues/cat_with_mirror.dialogue")

var player
var in_interaction_area = false
var dialogue_started = false
var already_talked = false
var random_timer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	random_timer = Timer.new()
	random_timer.wait_time = randf_range(1.0, 5.0)  
	random_timer.one_shot = true
	random_timer.timeout.connect(_on_random_timer_timeout)
	add_child(random_timer)
	
	random_timer.start()
func _on_random_timer_timeout() -> void:
	var random_bit = randi_range(0, 1)
	if random_bit:
		get_node("../").texture = load("res://assets/character_art/original/elena_af.png")
	else:
		get_node("../").texture = load("res://assets/character_art/original/elena_bf.png")
	random_timer.wait_time = randf_range(0.2, 1.0)
	random_timer.start()

		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if in_interaction_area and Input.is_action_pressed("Interact") and not dialogue_started:
		dialogue_started = true
		start_dialogue()
	pass

func start_dialogue():
	print("starting dialogue")
	player.dialogue_active = true
	if not already_talked:
		DialogueManager.show_dialogue_balloon(catDialogue, "start")
	else:
		DialogueManager.show_dialogue_balloon(catWithMirror, "end_loop")

func _on_body_entered(body: Node2D) -> void:
	if name == "CatArea":
		if body.is_in_group("player"):
			player = body
			in_interaction_area = true

#
func _on_dialogue_ended(resource):
	if resource == catDialogue:
		dialogue_started = false
		player.position = Vector2(334.379,1423.127)
		DialogueManager.show_dialogue_balloon(catWithMirror, "start")
		already_talked = true
		player.dialogue_active = false
		get_node("../../to_village_3").talkedToCat = true
	if resource == catWithMirror:
		player.dialogue_active = false
		
func _on_body_exited(body: Node2D) -> void:
	if name == "CatArea":
		if body.is_in_group("player"):
			in_interaction_area = false

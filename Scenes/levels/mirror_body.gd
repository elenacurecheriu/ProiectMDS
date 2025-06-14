extends CharacterBody2D

@export var speed = 350
var player_node: Node2D  # or CharacterBody2D, depending on the actual type

var activeInteractions = []
var lastDirection = Vector2.RIGHT
var last_player_position: Vector2
var offset = Vector2(40,40)

func _ready() -> void:
	print("mirror initialised")

	player_node = get_node("../Player") 
	print(player_node)

	if player_node == null:
		push_error("Player node not found!")
	else:
		last_player_position = player_node.position






func _process(delta: float) -> void:
	position = player_node.position + offset
	print(position)
	print(player_node.position)
	#if player_node == null:
		#return  # fallback safety
#
	## Check if the player moved this frame
	#var current_player_position = player_node.global_position
	#if current_player_position != last_player_position:
		#move_and_slide()
		#last_player_position = current_player_position  # update for next frame
#
	#if Input.is_action_just_pressed("Interact"):
		#handleInteractions()

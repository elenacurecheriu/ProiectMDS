extends Node2D


@onready var interactable: Area2D = $Interactable
@onready var sprite: CharacterBody2D = $CharacterBody2D


#levitare:
var levitate_speed = 2.0  
var levitate_amount = 20.0  
var start_y  
var time = 0.0


var is_moving_to_player: bool = false
var original_scale: Vector2
var move_speed: float = 300.0
var shrink_speed: float = 3.0
var min_scale: float = 0.1

func _ready() -> void:
	start_y = position.y
	interactable.interact = _on_interact
	original_scale = scale
	
func _process(delta: float) -> void:
	if is_moving_to_player:				#cand playerul interactioneaza cu itemul acesta incepe procesul de animatie catre el
		animate_to_player(delta)	
	time += delta
	position.y = start_y + sin(time * levitate_speed) * levitate_amount
		
		
func _find_player(node):
	if node is CharacterBody2D:
		return node
	var found = _find_player(node)
	if found:
		return found
	return null

func _on_interact():
	var player_node = get_tree().get_first_node_in_group("player")
	var player = _find_player(player_node)
		
	player.increase_stat("cake")
	var new_value = player.get_stat("cake")
	player.speed = 600
	
	#opresc colisiunile ca sa nu mai detecteze itemul
	interactable.monitoring = false
	interactable.set_deferred("collision_layer", 0)
	interactable.set_deferred("collision_mask", 0)
	
	start_move_to_player(player)


func start_move_to_player(player: Node2D):# aici da enable ca itemul sa umrareasca player-ul in functia _process
	is_moving_to_player = true

func animate_to_player(delta: float):
	var player_node = get_tree().get_first_node_in_group("player")
	var player = _find_player(player_node)
	
	if not player:
		queue_free()
		return
	
	var distance = global_position.distance_to(player.global_position)
	
	
	#Se mmisca catre player
	var direction = (player.global_position - global_position).normalized()
	global_position += direction * move_speed * delta
	
	#Se miscoreaza
	var shrink_factor = 1.0 - (shrink_speed * delta)
	scale *= shrink_factor
	#Regula sa nu se micsoreze mai mult decat limita
	if scale.x < min_scale:
		scale = Vector2(min_scale, min_scale)
	await get_tree().create_timer(1.0).timeout

	hide()	
	

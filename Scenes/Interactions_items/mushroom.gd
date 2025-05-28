
extends Node2D

@onready var interactable: Area2D = $Interactable
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


var is_moving_to_player: bool = false
var original_scale: Vector2
var move_speed: float = 300.0
var shrink_speed: float = 3.0
var min_scale: float = 0.1

func _ready() -> void:
	interactable.interact = _on_interact
	sprite.play("Idle")
	original_scale = scale

func _process(delta: float) -> void:
	if is_moving_to_player:
		animate_to_player(delta)
	
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
		
	player.increase_stat("mushroom")
	var new_value = player.get_stat("mushroom")
	print("Gained 1 mushroom. New mushroom: " + str(new_value))
	
	#opresc colisiunile ca sa nu mai detecteze itemul
	interactable.monitoring = false
	interactable.set_deferred("collision_layer", 0)
	interactable.set_deferred("collision_mask", 0)
	
	start_move_to_player(player)

func start_move_to_player(player: Node2D):
	is_moving_to_player = true

func animate_to_player(delta: float):
	var player_node = get_tree().get_first_node_in_group("player")
	var player = _find_player(player_node)
	
	if not player:
		queue_free()
		return
	
	var distance = global_position.distance_to(player.global_position)
	
	# If close enough to player, collect the item
	if distance < 20:
		queue_free()
		return
	
	# Move toward player
	var direction = (player.global_position - global_position).normalized()
	global_position += direction * move_speed * delta
	
	# Shrink the item
	var shrink_factor = 1.0 - (shrink_speed * delta)
	scale *= shrink_factor
	
	# Ensure we don't shrink below minimum
	if scale.x < min_scale:
		scale = Vector2(min_scale, min_scale)

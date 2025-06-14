extends CharacterBody2D

@export var speed = 350
@export var attackScene: PackedScene

@export var stats = {
	"fire_resistance": 0,
	"mushroom": 0,
	"cake": 0,
	"pink_glasses": 0,
	"eye": 0,
	"beer":0,
	"blue_flower":0
	
}
var test1 = 0
var test2 = 0
var max_health = 374
var current_health = 100

var health_bar

var attackComponent

func _ready() -> void:
	print("player.gd initialised")
	current_health = max_health
	
	add_to_group("player")
	
	if attackScene:
		attackComponent = attackScene.instantiate()
		attackComponent
		add_child(attackComponent)
	
	
	var hotbar = preload("res://Scenes/Interactions_items/Hotbar.tscn").instantiate()
	add_child(hotbar) 
	hotbar.position = Vector2(173,-97)

	
func set_health_component(_health_bar):
	self.health_bar = _health_bar
	health_bar.set_max_health(max_health)
	

	

func get_health_values():
	print("get_health_values()")
	return [current_health, max_health]

var activeInteractions = []


var lastDirection = Vector2.RIGHT
func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	if input_direction != Vector2.ZERO:
		lastDirection = input_direction.normalized()

	
	velocity = input_direction * speed

func _physics_process(delta):
	get_input()
	move_and_slide()
	update_animation()

	if Input.is_action_just_pressed("Interact"):
		handleInteractions()
		
	if Input.is_action_just_pressed("attack"):
		if attackComponent:
			attackComponent.attack(lastDirection.x, lastDirection.y, self.global_position)

func take_damage(amount):
	current_health -= amount
	current_health = max(0, current_health)
	health_bar.update_health(current_health)

	if current_health <= 0:
		die()
		

func heal(amount):
	current_health += amount
	
	current_health = min(current_health, max_health)
	
	health_bar.update_health(current_health)

	
	
func die():
	get_tree().change_scene_to_file("res://Scenes/levels/village.tscn")
	

func _on_interaction_area_area_entered(area: Area2D) -> void:
	if test1 == 0:
		test1 += 1
		##SE INSTANTIAZA PROST, SE PUNE IN CENTRU SI DUPA I SE MUTA POZITIA !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		return
	print("Interasfmk;masl;fmsamkl;f,")
	activeInteractions.insert(0, area)
	print("Interaction Entered")

func _on_interaction_area_area_exited(area: Area2D) -> void:
	activeInteractions.erase(area)
	print("Interaction Left")
	
func handleInteractions() -> void:
	if activeInteractions.size() == 0:
		return
	activeInteractions[0].ActivateInteraction(self)

func increase_stat(stat_name: String) -> void:
	if stats.has(stat_name):
		stats[stat_name] += 1
	else:
		print("Error: Stat '" + stat_name + "' does not exist")

func get_stat(stat_name: String) -> int:
	if stats.has(stat_name):
		return stats[stat_name]
	else:
		print("Error: Stat '" + stat_name + "' does not exist")
		return 0			


func _on_to_dungeon_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
	
	
#animation state machine
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
var animation_locked : bool = false
var facing = "front"

func update_animation():
	var direction = Input.get_vector("left", "right", "up", "down")

	
	if direction != Vector2.ZERO:
		if direction.y < 0:
			animated_sprite.play("run_back")
			facing = "back"
		elif direction.y > 0:
			animated_sprite.play("run_front")
			facing = "front"
		elif direction.x < 0:
			animated_sprite.play("run_left")
			facing = "left"
		elif direction.x > 0:
			animated_sprite.play("run_right")
			facing = "right"
	else:
		match facing:
			"back":
				animated_sprite.play("idle_back")
			"front":
				animated_sprite.play("idle_front")
			"left":
				animated_sprite.play("idle_left")
			"right":
				animated_sprite.play("idle_right")
		

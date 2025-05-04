extends CharacterBody2D

@export var speed = 350

var max_health = 100
var current_health = 100

func _ready() -> void:
	print("player.gd initialised")
	current_health = max_health

func get_health_values():
	return [current_health, max_health]
	

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _physics_process(delta):
	get_input()
	move_and_slide()

func take_damage(amount):
	current_health -= amount
	current_health = max(0, current_health)

	$HealthComponent.emit_signal("health_changed", current_health, max_health)
	
	if current_health <= 0:
		die()
		

func heal(amount):
	current_health += amount
	current_health = min(current_health, max_health)
	
	$HealthComponent.emit_signal("health_changed", current_health, max_health)

func die():
	print("Player died!")

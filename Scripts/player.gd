extends CharacterBody2D

@export var speed = 350

@export var stats = {
	"fire_resistance": 0,
	"mushroom": 0,
	"beer": 0
}

var max_health = 100
var current_health = 100

func _ready() -> void:
	print("player.gd initialised")
	current_health = max_health
	
	add_to_group("player")

func get_health_values():
	return [current_health, max_health]

var activeInteractions = []

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _physics_process(delta):
	get_input()
	move_and_slide()
	if Input.is_action_just_pressed("Interact"):
		handleInteractions()

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
	

func _on_interaction_area_area_entered(area: Area2D) -> void:
	activeInteractions.insert(0, area)
	print("Interaction Entered")

func _on_interaction_area_area_exited(area: Area2D) -> void:
	activeInteractions.erase(area)
	print("Interaction Left")
	
func handleInteractions() -> void:
	if !activeInteractions:
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

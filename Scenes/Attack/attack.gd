extends Node2D
class_name Attack

@export var attackDamage = 10.0
@export var attackCooldown = 1.0 # secunde

func attack(directionX, directionY, startPosition: Vector2):
	push_error("attack() not implemented")

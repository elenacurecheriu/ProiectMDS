extends Node2D
class_name Attack

@export var attackDamage = 10.0
@export var attackCooldown = 1000 # ms

var canAttack: bool = true

func attackLogic(directionX, directionY, startPosition: Vector2):
	push_error("attack() not implemented")
	
func attack(directionX, directionY, startPosition: Vector2):
	if canAttack:
		attackLogic(directionX, directionY, startPosition)

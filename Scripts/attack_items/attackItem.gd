# Interfata pentru attack items

class_name attackItem extends Node2D

var bulletScene: PackedScene
var spawnNode = null

@export var damage: int
@export var bulletSpeed: int

func attack(directionX: int, directionY: int) -> void:
	pass

class_name defaultAttackItem extends attackItem

func _init() -> void:
	bulletScene = preload("res://assets/attack_bullets/basic_bullet.tscn")
	
func _ready() -> void:
	spawnNode = get_tree().root.find_child("Player", true, true)
	
func attack(directionX: int, directionY: int) -> void:
	var bullet: attackBullet = bulletScene.instantiate()
	bullet.damage = damage
	bullet.speed = bulletSpeed
	bullet.directionX = directionX
	bullet.directionY = directionY
	
	spawnNode.addChild(attackBullet)

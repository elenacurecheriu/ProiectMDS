extends Attack

@export var bulletScene: PackedScene
@export var bulletSpeed = 10.0
@export var bulletDistance = 10.0

@onready var timer: Timer = $Timer

func attackLogic(directionX, directionY, startPosition: Vector2):
	canAttack = false
	
	
	var bullet = bulletScene.instantiate() as attackBullet
	bullet.damage = attackDamage
	bullet.speed = bulletSpeed
	bullet.distance = bulletDistance
	bullet.directionX = directionX
	bullet.directionY = directionY
	
	bullet.global_position.x = startPosition.x
	bullet.global_position.y = startPosition.y
	
	bullet.startPosition = startPosition
	
	get_tree().current_scene.get_parent().add_child(bullet)
	timer.start()

func _on_timer_timeout() -> void:
	canAttack = true

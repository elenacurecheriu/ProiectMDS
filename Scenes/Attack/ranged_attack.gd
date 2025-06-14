extends Attack

@export var bulletScene: PackedScene
@export var bulletSpeed = 10.0
@export var bulletDistance = 10.0
@export var bulletSpawnOffset = 50.0  # Distance from player to spawn bullet

@onready var timer: Timer = $Timer

func attackLogic(directionX, directionY, startPosition: Vector2):
	canAttack = false
	
	var bullet = bulletScene.instantiate() as attackBullet
	bullet.damage = attackDamage
	bullet.speed = bulletSpeed
	bullet.distance = bulletDistance
	bullet.directionX = directionX
	bullet.directionY = directionY
	
	# Set the shooter reference to the player (parent of this attack component)
	bullet.shooter = get_parent()
	
	# Calculate spawn position offset from player
	var direction = Vector2(directionX, directionY).normalized()
	var spawn_position = startPosition + (direction * bulletSpawnOffset)
	
	bullet.global_position = spawn_position
	bullet.startPosition = spawn_position
	
	get_tree().current_scene.add_child(bullet)
	timer.start()

func _on_timer_timeout() -> void:
	canAttack = true

#class_name attackBullet extends Area2D
#
## Viteza cu care va zbura bulletul
#var speed
#
## Se intelege
#var damage
#
#var distance
#
## Daca e pozitiv atunci o sa mearga spre dreapta, invers pt negativ
#var directionX
#
## Daca e 
#var directionY
#
## Pozitia de la care incepe sa zboare bulletul
#var startPosition: Vector2
#
#func _physics_process(delta: float) -> void:
	#if abs(position.distance_to(startPosition)) > distance:
		#self.queue_free()
	#
	#position.x += speed * delta * directionX
	#position.y += speed * delta * directionY
#
#
#func _on_area_entered(area: Area2D) -> void:
	#if area.has_method("damage"):
		#area.damage(damage)
	#if area.is_in_group("player"):
		#area.take_damage(damage)
	#self.queue_free()
#
#
#func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	#self.queue_free()

class_name attackBullet extends Area2D

# Viteza cu care va zbura bulletul
var speed
# Se intelege
var damage
var distance
# Daca e pozitiv atunci o sa mearga spre dreapta, invers pt negativ
var directionX
# Daca e 
var directionY
# Pozitia de la care incepe sa zboare bulletul
var startPosition: Vector2

# Who shot this bullet ("player" or "enemy")
var shooter_type: String = "enemy"

func _ready():
	# Connect signals if not connected in editor
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	# Set collision layers based on who shot the bullet
	if shooter_type == "player":
		collision_layer = 1 << 11  # Layer 12 (PlayerBullet) = 2^11 = 2048
		collision_mask = 1 << 10   # Layer 11 (Enemy) = 2^10 = 1024
	else:  # enemy bullet
		collision_layer = 1 << 12  # Layer 13 (EnemyBullet) = 2^12 = 4096
		collision_mask = 1 << 9    # Layer 10 (Player) = 2^9 = 512

func _physics_process(delta: float) -> void:
	if abs(position.distance_to(startPosition)) > distance:
		queue_free()
	
	position.x += speed * delta * directionX
	position.y += speed * delta * directionY

func _on_area_entered(area: Area2D) -> void:
	# Ignore detection areas
	if area.name.contains("Detection") or area.is_in_group("detection_area"):
		return
	
	# Check if we hit our target
	var parent = area.get_parent()
	if not parent:
		return
		
	if shooter_type == "player" and parent.is_in_group("enemy"):
		if area.has_method("damage"):
			area.damage(damage)
		elif parent.has_method("take_damage"):
			parent.take_damage(damage)
		queue_free()
	elif shooter_type == "enemy" and parent.is_in_group("player"):
		if area.has_method("damage"):
			area.damage(damage)
		elif parent.has_method("take_damage"):
			parent.take_damage(damage)
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	# Check if we hit our target
	if shooter_type == "player" and body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		elif body.has_method("damage"):
			body.damage(damage)
		queue_free()
	elif shooter_type == "enemy" and body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		elif body.has_method("damage"):
			body.damage(damage)
		queue_free()

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()

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

# Cine a lansat bulletul
var shooter: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	# Coliziuni
	set_collision_layer_value(3, true)  # Bullet-ul este pe layer 3
	set_collision_mask_value(1, true)   # Poate lovi layer 1 (player)
	set_collision_mask_value(2, true)   # Poate lovi layer 2 (enemy)

func _physics_process(delta: float) -> void:
	if abs(position.distance_to(startPosition)) > distance:
		self.queue_free()
	
	position.x += speed * delta * directionX
	position.y += speed * delta * directionY


func _on_body_entered(body: Node2D) -> void:
	# ignora coliziunea cu shooter-ul
	if body == shooter:
		return
		
	print("Bullet hit body: ", body.name, " in groups: ", body.get_groups())
	if body.is_in_group("player") or body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			print("Damaged ", body.name, " for ", damage, " damage")
		elif body.has_method("damage"):
			body.damage(damage)
			print("Damaged ", body.name, " for ", damage, " damage")
		# Distruge bullet-ul
		self.queue_free()


func _on_area_entered(area: Area2D) -> void:
	print("Bullet hit area: ", area.name)
	if area.has_method("damage"):
		area.damage(damage)
		self.queue_free()
	elif area.has_method("take_damage"):
		area.take_damage(damage)
		self.queue_free()

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	self.queue_free()

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

func _physics_process(delta: float) -> void:
	if abs(position.distance_to(startPosition)) > distance:
		self.queue_free()
	
	position.x += speed * delta * directionX
	position.y += speed * delta * directionY


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("damage"):
		area.damage(damage)
	self.queue_free()


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	self.queue_free()

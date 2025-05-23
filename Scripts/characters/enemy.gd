extends CharacterBody2D

var speed = 100
var distance = 1000
var player_chase = false
var player = null

var patrol_origin: Vector2
var patrol_direction := 1  # 1 = right; -1 = left
var patrol_distance = 100

func _ready():
	patrol_origin = global_position
	
func _physics_process(delta: float) -> void:
	$AnimatedSprite2D.play("walk_right")
	if player_chase:
		position += (player.position - position)/speed
		if (player.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		position.x += patrol_direction * speed * delta
		$AnimatedSprite2D.flip_h = patrol_direction < 0
		# Reverse direction if too far from patrol_origin
		if abs(position.x - patrol_origin.x) > patrol_distance:
			patrol_direction *= -1
		
		
func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false

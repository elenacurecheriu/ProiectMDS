extends CharacterBody2D

var speed = 250
var distance = 1000
var player_chase = false
var player = null

var patrol_origin: Vector2
var patrol_direction := 1  # 1 = right; -1 = left
var patrol_distance = 100
var patrol_mode: String = "horizontal"


func _ready():
	patrol_origin = global_position
	
func _physics_process(delta: float) -> void:
	if player_chase: #to fix: enemy speed when chasing is way too slow
		$AnimatedSprite2D.play("walk_right")
		speed = 250
		position += (player.position - position)/speed #issue
		if (player.position.x - position.x) < 0 or is_on_wall():
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		if patrol_mode == "horizontal":
			$AnimatedSprite2D.play("walk_right")
			position.x += patrol_direction * speed * delta
			$AnimatedSprite2D.flip_h = patrol_direction < 0
			#reverse direction if too far from patrol_origin
			if abs(position.x - patrol_origin.x) > patrol_distance or is_on_wall():
				patrol_direction *= -1
		elif patrol_mode == "vertical":
			$AnimatedSprite2D.play("walk_right")
			position.y += patrol_direction * speed * delta
			if abs(position.y - patrol_origin.y) > patrol_distance or is_on_wall():
				patrol_direction *= -1
	move_and_slide()



func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false

#var can_damage := true
#
#func _on_Collision_body_entered(body: Node) -> void:
	#if body.is_in_group("player") and can_damage:
		#can_damage = false
		#body.take_damage(10)
		#await get_tree().create_timer(1.0).timeout #cooldown
		#can_damage = true 

func _on_Collision_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_damage(10)

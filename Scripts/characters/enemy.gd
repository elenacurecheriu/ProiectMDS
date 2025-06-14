extends CharacterBody2D

@export var speed := 250
@export var patrol_distance := 100
@export var patrol_switch_time := 3.0  # Time in seconds before switching patrol direction
@export var stop_distance := 32.0
@export var wall_stuck_timeout := 0.5
@export var chase_range := 200.0  # Maximum chase distance
@export var max_health := 30
@export var damage_amount := 10  # Damage dealt to player

var current_health: int
var player_chase := false
var player: Node2D = null
var patrol_origin: Vector2
var patrol_direction := 1
var stuck_timer := 0.0
var last_position: Vector2
var position_stuck_timer := 0.0
var min_movement_threshold := 5.0  # Minimum movement to not be considered stuck

# New variables for alternating patrol
var current_patrol_mode := "horizontal"
var patrol_timer := 0.0

@onready var sprite := $AnimatedSprite2D
@onready var health_bar := $HealthBar  # Reference to ProgressBar node

func _ready():
	patrol_origin = global_position
	last_position = global_position
	add_to_group("enemy")
	
	# Initialize health
	current_health = max_health
	
	# Set collision layers
	set_collision_layer_value(2, true)  # Enemy layer
	set_collision_layer_value(3, true)  # Damageable layer
	
	# Set collision masks
	set_collision_mask_value(1, true)  # Can collide with player
	set_collision_mask_value(3, true)  # Can collide with bullets
	
	# Setup health bar if it exists
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
		health_bar.visible = false  # Hide until damaged

func _physics_process(delta: float) -> void:
	# Check if actually moving (position-based stuck detection)
	if global_position.distance_to(last_position) < min_movement_threshold * delta:
		position_stuck_timer += delta
	else:
		position_stuck_timer = 0.0
		last_position = global_position
	
	velocity = Vector2.ZERO
	
	if player_chase and player:
		chase_player()
	else:
		# Update patrol timer and switch modes when not chasing
		patrol_timer += delta
		if patrol_timer >= patrol_switch_time:
			switch_patrol_mode()
			patrol_timer = 0.0
		
		patrol()
	
	# Handle being stuck based on actual movement
	if position_stuck_timer > wall_stuck_timeout:
		handle_stuck_situation()
		position_stuck_timer = 0.0
	
	move_and_slide()
	
	# Check for player collision damage (most reliable method)
	check_player_collision()

func chase_player():
	var to_player = player.global_position - global_position
	var distance = to_player.length()
	
	# Stop chasing if player is too far away
	if distance > chase_range:
		player_chase = false
		player = null
		patrol_origin = global_position
		return
	
	# Use a larger minimum distance to prevent sticking
	var min_distance = stop_distance * 0.7  # Minimum distance before backing away
	var ideal_distance = stop_distance  # Target distance
	var max_distance = stop_distance * 1.3  # Start moving when farther than this
	
	if distance > max_distance:
		# Far enough - move toward player
		var direction = to_player.normalized()
		velocity = direction * speed
		
		sprite.play("walk_right")
		sprite.flip_h = direction.x < 0
		
		# If we can't reach the player directly, try to navigate around obstacles
		if is_on_wall():
			var perpendicular = Vector2(-direction.y, direction.x)
			if randf() > 0.5:
				perpendicular = -perpendicular
			velocity = perpendicular * speed * 0.7
			
	elif distance < min_distance:
		# Too close - actively back away with more force
		var direction = to_player.normalized()
		velocity = -direction * speed * 0.6  # Stronger backing away
		
		sprite.play("walk_right")
		sprite.flip_h = direction.x > 0
		
		# Add some randomness to prevent getting stuck in corners
		var random_perpendicular = Vector2(-direction.y, direction.x)
		if randf() > 0.5:
			random_perpendicular = -random_perpendicular
		velocity += random_perpendicular * speed * 0.2
		
	else:
		# In the acceptable range - use stable positioning
		var direction = to_player.normalized()
		
		# Check if we're mostly above/below the player (avoid left-right jittering)
		if abs(direction.y) > 0.7:  # Mostly vertical alignment
			# Stay put when directly above/below to avoid oscillation
			velocity = Vector2.ZERO
			sprite.flip_h = direction.x < 0  # Face the player
			
			if sprite.sprite_frames.has_animation("idle"):
				sprite.play("idle")
			else:
				sprite.stop()
		else:
			# Side positioning - gentle circling movement
			var perpendicular = Vector2(-direction.y, direction.x)
			
			# Choose circling direction based on position relative to player
			if to_player.x * to_player.y > 0:
				perpendicular = -perpendicular
			
			velocity = perpendicular * speed * 0.2  # Very slow circling movement
			sprite.play("walk_right")
			sprite.flip_h = velocity.x < 0

func patrol():
	sprite.play("walk_right")
	
	match current_patrol_mode:
		"horizontal":
			velocity.x = patrol_direction * speed
			sprite.flip_h = patrol_direction < 0
			
			# Check patrol bounds
			if abs(global_position.x - patrol_origin.x) >= patrol_distance:
				patrol_direction *= -1
				velocity.x = patrol_direction * speed  # Immediately apply new direction
				
		"vertical":
			velocity.y = patrol_direction * speed
			
			# Check patrol bounds
			if abs(global_position.y - patrol_origin.y) >= patrol_distance:
				patrol_direction *= -1
				velocity.y = patrol_direction * speed  # Immediately apply new direction

func switch_patrol_mode():
	# Switch between horizontal and vertical patrol
	if current_patrol_mode == "horizontal":
		current_patrol_mode = "vertical"
	else:
		current_patrol_mode = "horizontal"
	
	# Reset patrol origin to current position when switching
	patrol_origin = global_position
	# Keep the same direction, or optionally randomize it
	# patrol_direction = 1 if randf() > 0.5 else -1

func handle_stuck_situation():
	# Multiple strategies to get unstuck
	patrol_direction *= -1
	
	# Add a small random offset to break out of exact collision loops
	var random_offset = Vector2(
		randf_range(-20, 20),
		randf_range(-20, 20)
	)
	
	if player_chase and player:
		# When chasing, try to go around the obstacle
		var to_player = (player.global_position - global_position).normalized()
		var perpendicular = Vector2(-to_player.y, to_player.x)
		if randf() > 0.5:
			perpendicular = -perpendicular
		velocity = perpendicular * speed * 0.5
	else:
		# When patrolling, just reverse and add slight random movement
		match current_patrol_mode:
			"horizontal":
				velocity.x = patrol_direction * speed
				velocity.y = random_offset.y * 0.1
			"vertical":
				velocity.y = patrol_direction * speed
				velocity.x = random_offset.x * 0.1

# Detection area signals
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		# Don't immediately stop chasing, add some buffer with null check
		if get_tree():
			await get_tree().create_timer(0.2).timeout
			if player and is_instance_valid(player) and global_position.distance_to(player.global_position) > chase_range:
				player = null
				player_chase = false
				patrol_origin = global_position  # Resume patrol from current position

# Damage collision with cooldown
var can_damage := true

func _on_collision_body_entered(body: Node) -> void:
	if body.is_in_group("player") and can_damage:
		print("Enemy touching player - dealing damage!")  # Debug print
		if body.has_method("take_damage"):
			body.take_damage(damage_amount)
		can_damage = false
		# Use a safer timer approach
		if get_tree():
			await get_tree().create_timer(1.0).timeout
			can_damage = true
		else:
			# Fallback if get_tree() is null
			can_damage = true

# Alternative damage detection using Area2D (more reliable for damage)
func _on_damage_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and can_damage:
		print("Enemy damage area touching player!")  # Debug print
		if body.has_method("take_damage"):
			body.take_damage(damage_amount)
		can_damage = false
		# Use a safer timer approach
		if get_tree():
			await get_tree().create_timer(1.0).timeout
			can_damage = true
		else:
			# Fallback if get_tree() is null
			can_damage = true

# Continuous damage check in physics process (most reliable)
func check_player_collision():
	if not can_damage:
		return
		
	# Get all bodies colliding with this enemy
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider and collider.is_in_group("player"):
			print("Physics collision with player - dealing damage!")  # Debug print
			if collider.has_method("take_damage"):
				collider.take_damage(damage_amount)
			can_damage = false
			# Use a safer timer approach
			if get_tree():
				await get_tree().create_timer(1.0).timeout
				can_damage = true
			else:
				# Fallback if get_tree() is null
				can_damage = true
			break

func take_damage(damage: int):
	current_health -= damage
	print("Enemy took ", damage, " damage. Health: ", current_health, "/", max_health)
	
	# Update health bar
	if health_bar:
		health_bar.visible = true
		health_bar.value = current_health
		
		# Optional: Change health bar color based on health percentage
		var health_percentage = float(current_health) / float(max_health)
		var fill_style = health_bar.get_theme_stylebox("fill")
		if fill_style and fill_style is StyleBoxFlat:
			if health_percentage > 0.6:
				fill_style.bg_color = Color.GREEN
			elif health_percentage > 0.3:
				fill_style.bg_color = Color.YELLOW
			else:
				fill_style.bg_color = Color.RED
	
	# Visual feedback - flash red
	if sprite:
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(self):  # Check if still exists after wait
			sprite.modulate = Color.WHITE
	
	# Check if dead
	if current_health <= 0:
		die()

func die():
	print("Enemy died!")
	var room_id = get_meta("room_id", -1)
	if room_id != -1:
		var game_nodes = get_tree().get_nodes_in_group("dungeon_generator")
		if game_nodes.size() > 0:
			var game = game_nodes[0]
			game.enemy_counts[room_id] -= 1
			print("Room ", room_id, " enemies remaining: ", game.enemy_counts[room_id])
	queue_free()

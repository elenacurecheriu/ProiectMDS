extends CharacterBody2D

@export var speed := 150
@export var patrol_distance := 100
@export var patrol_switch_time := 3.0
@export var wall_stuck_timeout := 0.5
@export var chase_range := 300.0
@export var optimal_range := 150.0
@export var min_range := 80.0
@export var max_range := 200.0
@export var enemy_repel_force := 150.0
@export var enemy_detection_radius := 40.0

# Health
@export var max_health := 50
var current_health: int

# Shooting
@export var shoot_range := 250.0
@export var shoot_cooldown := 2.0
@export var bullet_scene: PackedScene
@export var bullet_speed := 300.0  # Increased for better visibility
@export var bullet_distance := 400.0
@export var attack_damage := 10
@export var bullet_spawn_offset := 40.0  # Distance from enemy center to spawn bullet

var can_shoot := true
var shoot_timer := 0.0

var player_chase := false
var player: Node2D = null
var patrol_origin: Vector2
var patrol_direction := 1
var stuck_timer := 0.0
var last_position: Vector2
var position_stuck_timer := 0.0
var min_movement_threshold := 5.0

var current_patrol_mode := "horizontal"
var patrol_timer := 0.0

var repel_velocity := Vector2.ZERO
var is_being_repelled := false

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
	
	# Verify bullet scene is set
	if not bullet_scene:
		push_warning("Bullet scene not set for ranged enemy!")

func _process(delta):
	if not can_shoot:
		shoot_timer += delta
		if shoot_timer >= shoot_cooldown:
			can_shoot = true
			shoot_timer = 0.0

func _physics_process(delta: float) -> void:
	if global_position.distance_to(last_position) < min_movement_threshold * delta:
		position_stuck_timer += delta
	else:
		position_stuck_timer = 0.0
		last_position = global_position

	velocity = Vector2.ZERO
	handle_enemy_repulsion()

	if not is_being_repelled:
		if player_chase and player:
			handle_player_interaction()
		else:
			patrol_timer += delta
			if patrol_timer >= patrol_switch_time:
				switch_patrol_mode()
				patrol_timer = 0.0
			patrol()

	velocity += repel_velocity

	if position_stuck_timer > wall_stuck_timeout:
		handle_stuck_situation()
		position_stuck_timer = 0.0

	move_and_slide()
	repel_velocity *= 0.8

func handle_player_interaction():
	if not player or not is_instance_valid(player):
		player_chase = false
		return

	var to_player = player.global_position - global_position
	var distance = to_player.length()

	if distance > chase_range:
		player_chase = false
		player = null
		patrol_origin = global_position
		return

	# Shoot at player if in range and can shoot
	if distance <= shoot_range and can_shoot and has_clear_shot_to_player():
		shoot_at_player()

	# Movement behavior based on distance
	if distance < min_range:
		# Too close - back away
		var direction = to_player.normalized()
		velocity = -direction * speed * 0.8
		sprite.play("walk_right")
		sprite.flip_h = direction.x > 0
	elif distance > max_range:
		# Too far - move closer
		var direction = to_player.normalized()
		velocity = direction * speed * 0.6
		sprite.play("walk_right")
		sprite.flip_h = direction.x < 0
	else:
		# Optimal range - strafe around player
		var direction = to_player.normalized()
		var perpendicular = Vector2(-direction.y, direction.x)
		if to_player.x * to_player.y > 0:
			perpendicular = -perpendicular
		velocity = perpendicular * speed * 0.4
		sprite.play("walk_right")
		sprite.flip_h = direction.x < 0
		
		# Sometimes stop to shoot
		if randf() < 0.3:
			velocity = Vector2.ZERO
			if sprite.sprite_frames.has_animation("idle"):
				sprite.play("idle")

func shoot_at_player():
	if not bullet_scene:
		print("ERROR: No bullet scene assigned!")
		return
	if not player:
		print("ERROR: No player reference!")
		return

	print("Shooting at player!")
	var direction = (player.global_position - global_position).normalized()
	
	# Create bullet instance
	var bullet = bullet_scene.instantiate()
	
	# Set bullet properties
	bullet.damage = attack_damage
	bullet.speed = bullet_speed
	bullet.distance = bullet_distance
	bullet.directionX = direction.x
	bullet.directionY = direction.y
	
	# Set the shooter so bullet ignores collision with us
	bullet.shooter = self
	
	# Spawn bullet slightly in front of enemy
	var spawn_position = global_position + direction * bullet_spawn_offset
	bullet.startPosition = spawn_position
	bullet.global_position = spawn_position
	
	# Add bullet to scene
	get_tree().current_scene.add_child(bullet)
	
	# Play shooting animation if available
	if sprite.sprite_frames.has_animation("shoot"):
		sprite.play("shoot")
	
	# Reset shooting cooldown
	can_shoot = false
	shoot_timer = 0.0

func has_clear_shot_to_player() -> bool:
	if not player:
		return false

	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		player.global_position,
		collision_mask
	)
	query.exclude = [self]

	var result = space_state.intersect_ray(query)
	
	# If we hit the player or nothing, we have a clear shot
	if not result or (result and result.collider == player):
		return true
	
	return false

func handle_enemy_repulsion():
	var repel_force = Vector2.ZERO
	var enemy_count = 0
	is_being_repelled = false

	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy == self or not is_instance_valid(enemy):
			continue

		var distance = global_position.distance_to(enemy.global_position)
		if distance < enemy_detection_radius and distance > 0:
			var away_vector = (global_position - enemy.global_position).normalized()
			var repel_strength = enemy_repel_force * (1.0 - distance / enemy_detection_radius)
			repel_force += away_vector * repel_strength
			enemy_count += 1

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var other = collision.get_collider()

		if other and other != self and other.is_in_group("enemy"):
			var away_vector = (global_position - other.global_position).normalized()
			repel_force += away_vector * enemy_repel_force * 2.0
			enemy_count += 1
			is_being_repelled = true

	if enemy_count > 0:
		repel_velocity += repel_force
		var max_repel_speed = speed * 1.5
		if repel_velocity.length() > max_repel_speed:
			repel_velocity = repel_velocity.normalized() * max_repel_speed

		if repel_force.length() > enemy_repel_force:
			is_being_repelled = true

func patrol():
	sprite.play("walk_right")

	match current_patrol_mode:
		"horizontal":
			velocity.x = patrol_direction * speed
			sprite.flip_h = patrol_direction < 0
			if abs(global_position.x - patrol_origin.x) >= patrol_distance:
				patrol_direction *= -1
		"vertical":
			velocity.y = patrol_direction * speed
			if abs(global_position.y - patrol_origin.y) >= patrol_distance:
				patrol_direction *= -1

func switch_patrol_mode():
	if current_patrol_mode == "horizontal":
		current_patrol_mode = "vertical"
	else:
		current_patrol_mode = "horizontal"
	patrol_origin = global_position

func handle_stuck_situation():
	patrol_direction *= -1
	var random_offset = Vector2(
		randf_range(-20, 20),
		randf_range(-20, 20)
	)

	if player_chase and player:
		var to_player = (player.global_position - global_position).normalized()
		var perpendicular = Vector2(-to_player.y, to_player.x)
		if randf() > 0.5:
			perpendicular = -perpendicular
		velocity = perpendicular * speed * 0.5
	else:
		match current_patrol_mode:
			"horizontal":
				velocity.x = patrol_direction * speed
				velocity.y = random_offset.y * 0.1
			"vertical":
				velocity.y = patrol_direction * speed
				velocity.x = random_offset.x * 0.1

func _on_detection_area_body_entered(body: Node2D) -> void:
	print("Body entered detection area: ", body.name)
	if body.is_in_group("player"):
		print("Player detected!")
		player = body
		player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	print("Body exited detection area: ", body.name)
	if body == player:
		if get_tree():
			await get_tree().create_timer(0.5).timeout
			if player and is_instance_valid(player) and global_position.distance_to(player.global_position) > chase_range:
				player = null
				player_chase = false
				patrol_origin = global_position

func take_damage(damage: int):
	current_health -= damage
	print("Ranged enemy took ", damage, " damage. Health: ", current_health, "/", max_health)
	
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
	
	# Get the room ID stored when the enemy was created
	var room_id = get_meta("room_id", -1)
	if room_id != -1:
		# Get reference to the game node (which is in dungeon_generator group)
		var game_nodes = get_tree().get_nodes_in_group("dungeon_generator")
		if game_nodes.size() > 0:
			var game = game_nodes[0]
			game.enemy_counts[room_id] -= 1
			print("Room ", room_id, " enemies remaining: ", game.enemy_counts[room_id])
			if room_id == game.current_room_id and game.enemy_counts[room_id] == 0:
				print("Current room cleared!")

	
	queue_free()

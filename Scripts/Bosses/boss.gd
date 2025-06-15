extends CharacterBody2D

@export var speed: float = 100.0
@export var detection_radius: float = 200.0
@export var attack_distance: float = 10
@export var melee_attack_damage: float = 100
@export var melee_radius: float = 50.0
@export var melee_cooldown: float = 2.0

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var detection_area: Area2D = $Attack/follow 
@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var melee_timer: Timer = $MeleeTimer
@onready var melee_area: Area2D = $MeleeArea
@onready var melee_collision: CollisionShape2D = $MeleeArea/CollisionShape2D
@export var projectile_scene = preload("res://Scenes/Bosses/projectile.tscn")

var player: CharacterBody2D = null
var is_following: bool = false
var is_attacking: bool = false
var can_melee_attack: bool = true
var players_in_melee_range: Array[Node2D] = []

#Machine state boss
enum EnemyState {
	IDLE,
	FOLLOWING,
	ATTACKING,
	MELEE
}

var current_state: EnemyState = EnemyState.IDLE

func _ready():
	if attack_timer:
		attack_timer.timeout.connect(_throw_projectile)
	
	# Setup melee timer
	if not melee_timer:
		melee_timer = Timer.new()
		add_child(melee_timer)
	melee_timer.wait_time = melee_cooldown
	melee_timer.one_shot = true
	melee_timer.timeout.connect(_on_melee_cooldown_finished)
	
	# Setup melee area
	if not melee_area:
		_create_melee_area()
	else:
		melee_area.body_entered.connect(_on_melee_area_entered)
		melee_area.body_exited.connect(_on_melee_area_exited)
	
	# Connect the detection area signals
	if detection_area:
		detection_area.body_entered.connect(_on_follow_area_entered)
		detection_area.body_exited.connect(_on_follow_area_exited)
	else:
		print("eroare")

func _create_melee_area():
	melee_area = Area2D.new()
	melee_collision = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = melee_radius
	
	melee_collision.shape = circle_shape
	melee_area.add_child(melee_collision)
	add_child(melee_area)
	
	melee_area.body_entered.connect(_on_melee_area_entered)
	melee_area.body_exited.connect(_on_melee_area_exited)

func _on_follow_area_entered(body: Node2D):
	#verific daca e player ul
	if body.name == "Player" or body.is_in_group("player") or body.get_class() == "CharacterBody2D":
		player = body
		is_following = true
		current_state = EnemyState.FOLLOWING
		print("player detectat")
	else:
		print("Nu e player")

func _on_follow_area_exited(body: Node2D):
	# verific daca e playe -ul
	if body == player:
		is_following = false
		current_state = EnemyState.IDLE
		player = null

func _on_melee_area_entered(body: Node2D):
	if body.name == "Player" or body.is_in_group("player"):
		players_in_melee_range.append(body)
		if current_state == EnemyState.FOLLOWING and can_melee_attack:
			current_state = EnemyState.MELEE

func _on_melee_area_exited(body: Node2D):
	if body in players_in_melee_range:
		players_in_melee_range.erase(body)
		if players_in_melee_range.is_empty() and current_state == EnemyState.MELEE:
			current_state = EnemyState.FOLLOWING

func _physics_process(delta):
	match current_state:
		EnemyState.IDLE:
			_handle_idle_state()
		EnemyState.FOLLOWING:
			_handle_following_state()
		EnemyState.ATTACKING:
			_handle_attacking_state()
		EnemyState.MELEE:
			_handle_melee_state()	

func _handle_idle_state():
	velocity = Vector2.ZERO
	move_and_slide()

func _handle_following_state():
	if not player or not is_following:
		current_state = EnemyState.IDLE
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	print("distance", distance_to_player)
	
	# Check if player is in melee range and we can attack
	if not players_in_melee_range.is_empty() and can_melee_attack:
		current_state = EnemyState.MELEE
		return
	
	# Check for ranged attack
	if distance_to_player <= attack_distance:
		current_state = EnemyState.ATTACKING
		return
	
	var direction = (player.global_position - global_position).normalized()
	
	_face_direction(direction)
	velocity = direction * speed
	move_and_slide()

func _handle_melee_state():
	if not player:
		current_state = EnemyState.IDLE
		return
	
	# Stop moving
	velocity = Vector2.ZERO
	move_and_slide()
	
	# Face the player
	var direction_to_player = (player.global_position - global_position).normalized()
	_face_direction(direction_to_player)
	
	# Perform melee attack if we can
	if can_melee_attack and not players_in_melee_range.is_empty():
		_perform_melee_attack()
	
	# Check if we should switch states
	if players_in_melee_range.is_empty():
		current_state = EnemyState.FOLLOWING

func _handle_attacking_state():
	if not player:
		current_state = EnemyState.IDLE
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Check if player moved into melee range
	if not players_in_melee_range.is_empty() and can_melee_attack:
		current_state = EnemyState.MELEE
		return
	
	# If player moved too far, go back to following
	if distance_to_player > attack_distance * 1.5:
		current_state = EnemyState.FOLLOWING
		return
	
	# Face the player
	var direction_to_player = (player.global_position - global_position).normalized()
	_face_direction(direction_to_player)
	
	velocity = Vector2.ZERO
	move_and_slide()
	
	_perform_attack()

func _perform_melee_attack():
	if not can_melee_attack:
		return
		
	can_melee_attack = false
	melee_timer.start()
	
	# Create visual effect (optional)
	_create_melee_visual_effect()
	
	# Damage all players in melee range
	for player_body in players_in_melee_range:
		if player_body and player_body.has_method("take_damage"):
			player_body.take_damage(melee_attack_damage)
			print("Melee attack hit player for ", melee_attack_damage, " damage")

func _create_melee_visual_effect():
	var circle = Node2D.new()
	circle.global_position = global_position
	get_tree().current_scene.add_child(circle)
	
	# Custom draw function
	var draw_func = func():
		circle.draw_circle(Vector2.ZERO, melee_radius * circle.scale.x, Color(1.0, 0.0, 0.0, 0.3))
		circle.draw_arc(Vector2.ZERO, melee_radius * circle.scale.x, 0, TAU, 32, Color(1.0, 0.0, 0.0, 0.8), 3.0)
	
	circle.draw.connect(draw_func)
	
	# Animate the circle
	var tween = create_tween()
	tween.parallel().tween_property(circle, "scale", Vector2(3.0, 3.0), 0.5)
	tween.parallel().tween_property(circle, "modulate:a", 0.0, 0.5)
	tween.tween_callback(circle.queue_free)

func _on_melee_cooldown_finished():
	can_melee_attack = true

func _face_direction(direction: Vector2):
	if direction.x < 0:
		sprite.flip_h = true
	elif direction.x > 0:
		sprite.flip_h = false

func _perform_attack():
	if not attack_timer.is_stopped():
		return  
	attack_timer.start()

func _throw_projectile():
	if not player:
		return
	
	var projectile = projectile_scene.instantiate()
	var direction = (player.global_position - global_position).normalized()
	projectile.global_position = global_position
	projectile.direction = direction

	projectile.hit_player.connect(_on_projectile_hit)

	get_tree().current_scene.add_child(projectile) 

func _on_projectile_hit(player_node):
	player_node.take_damage(10) 

func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()

func set_player_reference(player_node: CharacterBody2D):
	player = player_node

func get_current_state() -> String:
	match current_state:
		EnemyState.IDLE:
			return "IDLE"
		EnemyState.FOLLOWING:
			return "FOLLOWING"
		EnemyState.ATTACKING:
			return "ATTACKING"
		EnemyState.MELEE:
			return "MELEE"
		_:
			return "UNKNOWN"

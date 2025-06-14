extends CharacterBody2D

@export var speed: float = 100.0
@export var detection_radius: float = 200.0
@export var attack_distance: float = 50

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var detection_area: Area2D = $Attack/follow  # Try this path first
@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_timer: Timer = $AttackTimer
@export var projectile_scene = preload("res://Scenes/Bosses/projectile.tscn")

# State variables
var player: CharacterBody2D = null
var is_following: bool = false
var is_attacking: bool = false

#Machine state boss
enum EnemyState {
	IDLE,
	FOLLOWING,
	ATTACKING
}

var current_state: EnemyState = EnemyState.IDLE

func _ready():
	if attack_timer:
		attack_timer.timeout.connect(_throw_projectile)
	
	# Connect the detection area signals
	if detection_area:
		detection_area.body_entered.connect(_on_follow_area_entered)
		detection_area.body_exited.connect(_on_follow_area_exited)
	else:
		print("eroare")
	
	


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

func _physics_process(delta):
	match current_state:
		EnemyState.IDLE:
			_handle_idle_state()
		EnemyState.FOLLOWING:
			_handle_following_state()
		EnemyState.ATTACKING:
			_handle_attacking_state()

func _handle_idle_state():
	velocity = Vector2.ZERO
	move_and_slide()

func _handle_following_state():
	if not player or not is_following:
		current_state = EnemyState.IDLE
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	print("Distance to player: ", distance_to_player)
	
	if distance_to_player <= attack_distance:
		current_state = EnemyState.ATTACKING
		return
	
	var direction = (player.global_position - global_position).normalized()
	print("Direction to player: ", direction)
	
	_face_direction(direction)
	velocity = direction * speed
	move_and_slide()
	

func _handle_attacking_state():
	if not player:
		current_state = EnemyState.IDLE
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	#
	if distance_to_player > attack_distance * 1.5:
		current_state = EnemyState.FOLLOWING
		return
	
	# Face the player
	var direction_to_player = (player.global_position - global_position).normalized()
	_face_direction(direction_to_player)
	
	velocity = Vector2.ZERO
	move_and_slide()
	
	_perform_attack()

func _face_direction(direction: Vector2):
	if direction.x < 0:
		sprite.flip_h = true
	elif direction.x > 0:
		sprite.flip_h = false

func _perform_attack():
	if not attack_timer.is_stopped():
		return  

	attack_timer.start()
	print("Attacking player!")
	print("Attacking player!")
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
		_:
			return "UNKNOWN"

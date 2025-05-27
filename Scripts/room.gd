extends Node2D
@onready var main = $".."
@onready var minimap = $"../Camera2D/CanvasLayer/Minimap"
var roomID = 0
var test = 0 

@export var enemy_spawn_points: Array[NodePath] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setRoomID(_roomID):
	roomID = _roomID

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if test > 0:
		print("Entered room", roomID)
		main.changeRoomOnMinimap(roomID)
	else:
		test +=1
		
		
func get_random_spawn_point() -> Vector2:
	var spawns: Array[Vector2] = []
	for path in enemy_spawn_points:
		if not has_node(path):
			print("Invalid path: ", path)
		else:
			var point = get_node(path)
			spawns.append(point.global_position)
			print ("s-a spawnat regele")
	if spawns.is_empty():
		print ("inamici nespawnati")
		return Vector2.ZERO
	return spawns.pick_random()

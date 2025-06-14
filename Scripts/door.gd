extends Node2D  # Or Node2D, depending on what your door scene uses
@onready var main = $"../.."
var direction = ""
var adjacentRooms = ""
var size_of_door = 100
var directionName = ""
func initialize(dir: String) -> void:
	direction = dir

var dungeon_generators
var camera

func setAdjacentRooms(_adjacentRooms):
	adjacentRooms = _adjacentRooms
	
func getAdjacentRooms():
	return adjacentRooms
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dungeon_generators = get_tree().get_nodes_in_group("dungeon_generator")
	if dungeon_generators.size() > 0:
		camera = dungeon_generators[0].get_camera()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func move_camera_and_player():
	if not camera or dungeon_generators.size() == 0:
		return
	
	var room_size = Vector2(1150, 650)
	var dg = dungeon_generators[0]
	var current_coords = dg.get_current_room_coords()
	var pos = position
	
	var dir = ""
	var xoffset = 0
	var yoffset = 0
	
	if current_coords.x - pos.x >0:
		dir = "east"
		xoffset = -1150
	if current_coords.x - pos.x <0:
		dir = "west"
		xoffset = 1150
	if current_coords.y - pos.y >0:
		dir = "south"
		yoffset = -650
	if current_coords.y - pos.y <0:
		dir = "north"
		yoffset = 650

	print("Door the connects rooms: " + adjacentRooms + " Direction: " + dir)

	var new_coords = Vector2(current_coords.x + xoffset, current_coords.y + yoffset)

	dg.set_current_room_coords(new_coords)
#
	## Move camera to center of new room
	camera.position = new_coords

#
	## Move player to entrance (opposite side of the door)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var offset_from_center = {
			"north": Vector2(0,size_of_door + 30 ),
			"south": Vector2(0,-size_of_door - 30),
			
			"west": Vector2(size_of_door + 100, 0),
			"east": Vector2(-size_of_door - 100, 0),
			"" : Vector2(0,0)
		}
		print(dir)
		player.position += offset_from_center[dir]
		
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.get_class() == "CharacterBody2D":
		var _roomID = main.get_node("game").currentRoomID
		var roomInstance = main.get_node("game").roomsWithId[_roomID]
		var is_the_room_cleared = roomInstance.room_cleared
		
		if is_the_room_cleared:
			print("Debug character touched the " + adjacentRooms + " door!")
			move_camera_and_player()

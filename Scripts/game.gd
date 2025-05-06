extends Node2D
var RoomScene = preload("res://Scenes/Room.tscn")
var DoorScene = preload("res://Scenes/door.tscn")
var CameraScene = preload("res://Scenes/camera.tscn")
var CharacterScene = preload("res://Scenes/debug_character.tscn")
var SpikesScene = preload("res://Scenes/spikes.tscn")
var PauseScene = preload("res://Menus/pause_menu.tscn")
var CanvasLayerScene  = preload("res://Scenes/canvas_layer.tscn")

var canvas = CanvasLayerScene.instantiate()

const M_SIZE = 5
const MAX_CAMERE = 7
var current_room_coords = Vector2(0, 0)  # Starting room

var matrix = generate_dungeon()
var room_size = Vector2(1150, 650)
var rooms = {}
var paused = false
var pause_menu 
var camera = CameraScene.instantiate()

func get_current_room_coords():
	return current_room_coords
	
func set_current_room_coords(pos: Vector2):
	current_room_coords = pos

func get_camera():
	return camera
	
	
func pause_menu_():
	print("PAUSE MENU SELECTED")
	if paused:
		pause_menu.hide()
	else:
		pause_menu.show()
		
	paused = ! paused	
	
	
func _ready()	:

	add_to_group("dungeon_generator")
	add_child(camera)

	
	camera.position = Vector2(0,0)
	camera.zoom.x = 1
	camera.zoom.y = 1
	
	#debug purposes
	camera.zoom.x = 0.7
	camera.zoom.y = 0.7
	
	
	instantiate_rooms()
	var player = CharacterScene.instantiate()
	add_child(player)
	player.position = Vector2 (0,0)
	player.add_to_group("player")
	print("Added player in the tree")
	add_doors()
	
	
	pause_menu = PauseScene.instantiate()
	camera.add_child(canvas)
	canvas.add_child(pause_menu)
	
	pause_menu.set_script(load("res://Scripts/pause_menu.gd"))
	
	var hotbar = preload("res://Scenes/Interactions_items/Hotbar.tscn").instantiate()
	camera.add_child(canvas)
	canvas.add_child(hotbar)
	hotbar.z_index = 100

	
	print_tree_pretty()
	
	
	
	
	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause_menu_()

	
func instantiate_rooms():
	
	
	print_matrix(matrix)
		
	for x in range(matrix.size()):
		for y in range(matrix[x].size()):
			var cell_value = matrix[x][y]
			# Instantiate rooms for non-zero values (1s and 2s)
			if cell_value > 0:
				var room = RoomScene.instantiate()
				room.setRoomID(cell_value)
				add_child(room)

				#(y-2) * room_size.x , (2-x) * room_size.y
				# Position the room based on its coordinates in the matrix
				room.position = Vector2((y-2) * room_size.x , -(2-x) * room_size.y)
				# Store the room in the dictionary for easy access later
				rooms[Vector2(x, y)] = room
				
				# 1 -> starting_room
				# 2 -> spike_room
				# 7 -> boss_room
				
				if cell_value == 2:
					# Center of the room: room.position = Vector2((y-2) * room_size.x , -(2-x) * room_size.y)
					var spikes = SpikesScene.instantiate()
					add_child(spikes)
					spikes.position = Vector2((y-2) * room_size.x , -(2-x) * room_size.y)
					pass
					# If your Room has properties like is_starting_room, you can set them here
	


func add_doors():
	var directions = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]
	var direction_names = ["west", "east", "north", "south"]

	for room_pos in rooms.keys():
		var x = int(room_pos.x)
		var y = int(room_pos.y)
		var cell_value_current = matrix[x][y]
		for i in range(directions.size()):
			# Only create doors in one direction (e.g., east and south)
			if direction_names[i] in ["east", "south"]:
				var dir = directions[i]
				var neighbor_pos = Vector2(x + dir.x, y + dir.y)
				#debug purposes !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				if neighbor_pos.x > 5 or neighbor_pos.y >5:
					pass
				var cell_value_neighbour =  matrix[neighbor_pos.x][neighbor_pos.y]
				if is_valid_position(neighbor_pos) and cell_value_neighbour > 0:
					var door = DoorScene.instantiate()
					door.setAdjacentRooms(str(cell_value_current) + " " + str(cell_value_neighbour))
					add_child(door)

					var current_room_pos = Vector2((y-2) * room_size.x, -(2-x) * room_size.y)
					var neighbor_room_pos = Vector2((neighbor_pos.y-2) * room_size.x, -(2-neighbor_pos.x) * room_size.y)
					var door_position = current_room_pos.lerp(neighbor_room_pos, 0.5)
					door.position = door_position

					if dir.x != 0:
						door.rotation_degrees = 0
					else:
						door.rotation_degrees = 90

				
# Helper function to check if a position is within the matrix bounds
func is_valid_position(pos):
	return pos.y >= 0 and pos.y < matrix.size() and pos.x >= 0 and pos.x < matrix[0].size()

func generate_dungeon():
	randomize()
	
	var _matrix = []
	for i in range(M_SIZE):
		_matrix.append([])
		for j in range(M_SIZE):
			_matrix[i].append(0)

	var queue = []
	var camere = 1
	
	# Start from the center
	var start = Vector2(2, 2)
	_matrix[start.y][start.x] = camere
	queue.append(start)
	
	while camere < MAX_CAMERE and queue.size() > 0:
		var current = queue.pop_front()
		var directions = [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]
		directions.shuffle()
		
		for dir in directions:
			var new_pos = current + dir
			if new_pos.x >= 0 and new_pos.x < M_SIZE and new_pos.y >= 0 and new_pos.y < M_SIZE:
				if _matrix[new_pos.y][new_pos.x] == 0:
					camere += 1
					_matrix[new_pos.y][new_pos.x] = camere
					queue.append(new_pos)
					
					if camere >= MAX_CAMERE:
						break
	

	return _matrix

func print_matrix(_matrix):
	print("Dungeon Layout:")
	for i in range(M_SIZE):
		var row = ""
		for j in range(M_SIZE):
			row += str(_matrix[i][j]) + " "
		print(row)

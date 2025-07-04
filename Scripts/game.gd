extends Node2D
var RoomScene = preload("res://Scenes/Room.tscn")
var DoorScene = preload("res://Scenes/door.tscn")
var CameraScene = preload("res://Scenes/camera.tscn")
var CharacterScene = preload("res://Scenes/Attack/debug_character.tscn")
var SpikesScene = preload("res://Scenes/spikes.tscn")
var PauseScene = preload("res://Menus/pause_menu.tscn")
var CanvasLayerScene  = preload("res://Scenes/canvas_layer.tscn")

#var MinimapScene = preload("res://Scenes/minimap.tscn")

var player = CharacterScene.instantiate()

 
#Bosses:
var bossScene = preload("res://Scenes/Bosses/boss.tscn")
var redPandaScene = preload("res://Scenes/Bosses/redPanda.tscn")
var boss


#ITEMS:
var FireResistanceScene = preload("res://Scenes/Interactions_items/fire_resistance.tscn")
var MushroomScene = preload("res://Scenes/Interactions_items/mushroom.tscn")
var CakeScene = preload("res://Scenes/Interactions_items/cake.tscn")
var pedestal = preload("res://Scenes/Interactions_items/pedestal.tscn")

var GUIScene = preload("res://Scenes/Gui.tscn")
#test
var canvas = CanvasLayerScene.instantiate()
var canvasMinimap = CanvasLayerScene.instantiate()
var gui = GUIScene.instantiate()
const M_SIZE = 5
const MAX_CAMERE = 7
var current_room_coords = Vector2(0, 0)  # Starting room

var minimap

var currentRoomID = 1

var matrix = generate_dungeon()
var room_size = Vector2(1150, 650)
var rooms = {}
var doors = {}
var roomsWithId = {}
var paused = false
var pause_menu 
var camera = CameraScene.instantiate()
#var minimap = MinimapScene.instantiate()


var enemy_counts = [] #enemy_counts[i] == cati inamici sunt in camera cu roomID == i
var current_room_id = 1

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
	var player_node = get_tree().get_first_node_in_group("player")
	
	player.add_to_group("player")
	add_child(canvasMinimap)
	
	add_to_group("dungeon_generator")
	add_child(camera)
	
	camera.position = Vector2(0,0)
	camera.zoom.x = 1
	camera.zoom.y = 1
	camera.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	#debug purposes
	#camera.zoom.x = 0.7
	#camera.zoom.y = 0.7
	
	for i in range(MAX_CAMERE + 1):
		enemy_counts.append(0) # cate camere am atatea elemente sa aiba vectorul
		
	instantiate_rooms()
	
	canvas.add_child(gui)

	#var player = CharacterScene.instantiate() !!
	
	player.set_health_component(gui.get_node("HealthBar"))
	player.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	player.scale.x = 1.64
	player.scale.y = 1.64
	player.z_index = 1
	
	var streamPlayer: AudioStreamPlayer =  AudioStreamPlayer.new()
	var music: AudioStreamMP3 = load("res://assets/music/Azteca - EUL 4 (Official Visualizer) [music].mp3")
	
	streamPlayer.stream = music
	streamPlayer.autoplay = true
	
	player.add_child(streamPlayer)
	
	add_child(player)
	var hotbar_delete = $Player/Hotbar
	if hotbar_delete:
		hotbar_delete.queue_free()
	player.position = Vector2 (0,0)
	
	print("Added player in the tree")
	add_doors()
	
	
	
	pause_menu = PauseScene.instantiate()
	camera.add_child(canvas)
	canvas.add_child(pause_menu)
	
	pause_menu.set_script(load("res://Scripts/pause_menu.gd"))
	
	#Adaug hotbarul in GUI
	var hotbar = preload("res://Scenes/Interactions_items/Hotbar.tscn").instantiate()
	gui.add_child(hotbar) 
	 
	
	
	
	#minimap.generateMinimap(matrix)
	minimap = get_node("Camera2D/CanvasLayer/Gui/AspectRatioContainer/Minimap")
	minimap.generateMinimap(matrix)
	#canvas.add_child(minimap)
	#minimap.scale = Vector2(0.5,0.5)wa
	#minimap.position += Vector2(1025,75)
	

	
	#print_tree_pretty()



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
				
				roomsWithId[cell_value] = room
				#(y-2) * room_size.x , (2-x) * room_size.y
				# Position the room based on its coordinates in the matrix
				room.position = Vector2((y-2) * room_size.x , -(2-x) * room_size.y)
				
				#the position is the center of the room
				
				
				# Store the room in the dictionary for easy access later
				rooms[Vector2(x, y)] = room
				
				# 1 -> starting_room
				# 2 -> spike_room
				# 3 -> item_room
				# 7 -> boss_room
				var centerx = (y-2) * room_size.x
				var centery =  -(2-x) * room_size.y
				
				var room_size_inside = Vector2(1150, 650)
				var room_center = Vector2((y - 2) * room_size_inside.x, -(2 - x) * room_size_inside.y)
				var piedestal_position =  Vector2((y - 2) * room_size_inside.x, -(2 - x) * room_size_inside.y+48)
				
				if cell_value == 2:
					#TEST OF A SPIKE ROOM, NOT FINAL
					# Center of the room: room.position = Vector2((y-2) * room_size.x , -(2-x) * room_size.y)
					var offsetGrid = Vector2(0,0)
					var spikesSize
					var temp = 0
					for spike_index1 in range(4):
						temp += 1
						for spike_index in range(6):
							var spikes = SpikesScene.instantiate()
							spikesSize =  spikes.get_node("Area2D/CollisionShape2D").shape.size #Vector2
							spikes.position = Vector2(centerx - 575 - 8 , centery - 325) + spikesSize + offsetGrid
							offsetGrid += Vector2(2 * spikesSize.x,0)
							add_child(spikes)
						if temp == 2: 
							offsetGrid += Vector2(0, 2 * spikesSize.y)

						offsetGrid.x = 0
						offsetGrid += Vector2(0, 2 * spikesSize.y)
					pass
					
			
					
				if cell_value == 3:
					var cake = CakeScene.instantiate()
					var pedestal = pedestal.instantiate()
					pedestal.position = piedestal_position
					add_child(pedestal)
					cake.position = room_center 
					add_child(cake)		
					
					
				if cell_value == 4:
					#FIRE RESISTANCE
					var fireResistance = FireResistanceScene.instantiate()
					var pedestal = pedestal.instantiate()
					pedestal.position = piedestal_position
					add_child(pedestal)
					fireResistance.position = room_center 
					add_child(fireResistance)
					
				if cell_value == 5:		
					#MUSHROOM:
					var mushroom = MushroomScene.instantiate()
					var pedestal = pedestal.instantiate()
					pedestal.position = piedestal_position
					add_child(pedestal)
					mushroom.position = room_center 
					add_child(mushroom)
						
					#Cake
					var cake = CakeScene.instantiate()
					var random_position = Vector2(
						randf() * room_size_inside.x - room_size_inside.x / 2,
						randf() * room_size_inside.y - room_size_inside.y / 2
					)
					cake.position = room_center + random_position
					add_child(cake)
				if cell_value  == 7:
					#DIALOGUE SPRITE
					var red_panda = redPandaScene.instantiate()
					red_panda.position = Vector2((y-2) * room_size.x + 200 , -(2-x) * room_size.y)
					add_child(red_panda)
					red_panda.startBossRelay.connect(_on_red_panda_startBossRelay)
					boss = bossScene.instantiate()
					boss.position =  Vector2((y-2) * room_size.x + 200 , -(2-x) * room_size.y)
	

				if cell_value != 1 and cell_value != 2 and cell_value != 7:
					var total_enemies = 0

					
					# spawn melee enemies
					var num_enemies = randi() % 5 + 1  # spawn 1 to 5 enemies
					for i in range(num_enemies):
						var enemy = preload("res://Scenes/enemy.tscn").instantiate()
						var spawn_offset = Vector2(
							randf_range(-room_size.x * 0.3, room_size.x * 0.3),
							randf_range(-room_size.y * 0.3, room_size.y * 0.3)
						)
						var spawn_pos = Vector2(centerx, centery) + spawn_offset
						enemy.global_position = spawn_pos
						
						enemy.patrol_distance = randf_range(200, 400)
						enemy.speed = randf_range(100, 200)
						enemy.patrol_switch_time = randf_range(2.0, 5.0)
						
						# store reference to the room this enemy belongs to
						enemy.set_meta("room_id", cell_value)
						
						add_child(enemy)
						
						enemy_counts[cell_value] += 1
					
					# spawn ranged enemies
					var num_ranged_enemies = randi() % 3 + 1  # spawn 1 to 3 enemies
					for i in range(num_ranged_enemies):
						var ranged_enemy = preload("res://Scenes/ranged_enemy.tscn").instantiate()
						var spawn_offset = Vector2(
							randf_range(-room_size.x * 0.3, room_size.x * 0.3),
							randf_range(-room_size.y * 0.3, room_size.y * 0.3)
						)
						var spawn_pos = Vector2(centerx, centery) + spawn_offset
						ranged_enemy.global_position = spawn_pos
						
						ranged_enemy.patrol_distance = randf_range(200, 400)
						ranged_enemy.speed = randf_range(100, 200)
						ranged_enemy.patrol_switch_time = randf_range(2.0, 5.0)
						
						# store reference to the room this enemy belongs to
						ranged_enemy.set_meta("room_id", cell_value)
						
						add_child(ranged_enemy)
						
						# Increment enemy count for this room
						enemy_counts[cell_value] += 1
					
				for i in range(MAX_CAMERE + 1):
					print("Inamici in camera " + str(i) + ": " + str(enemy_counts[i]))
						 
					# If your Room has properties like is_starting_room, you can set them here
	
func _on_red_panda_startBossRelay() -> void:
	get_node("RedPanda").queue_free()
	#BOSS FIGHT ITSELF	
	add_child(boss)
					

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
				if not is_valid_position(neighbor_pos):
					continue
				var cell_value_neighbour =  matrix[neighbor_pos.x][neighbor_pos.y]
				if is_valid_position(neighbor_pos) and cell_value_neighbour > 0:
					var door = DoorScene.instantiate()
					#door.setAdjacentRooms(str(cell_value_current) + " " + str(cell_value_neighbour))
					door.name = "Door " + (str(cell_value_current) + " -> " + str(cell_value_neighbour))
					doors[door] = [cell_value_current, cell_value_neighbour]
					door.direction = dir
					door.directionName = direction_names[i]
					add_child(door)
					#in x si y sunt pozitiile din matrice, ex (2.0, 1.0)
					var current_room_pos = Vector2(rooms[room_pos].position)
					var neighbor_room_pos = Vector2(rooms[neighbor_pos].position)
					var door_position = current_room_pos.lerp(neighbor_room_pos, 0.5)
					door.position = door_position

					#if dir.x != 0:
						#door.rotation_degrees = 0
					#else:
						#door.rotation_degrees = 90

func set_current_room(room_id: int):
	current_room_id = room_id
	print("Entered room ", room_id, " with ", enemy_counts[room_id], " enemies")
	
func changeRoomOnMinimap(_roomID):
	minimap.changeRoom(_roomID)
	set_current_room(_roomID)
				
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

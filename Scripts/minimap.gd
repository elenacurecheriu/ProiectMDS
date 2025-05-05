extends Node2D

var VisitedScene = preload("res://Scenes/MinimapScenes/visited.tscn")
var UnvisitedScene = preload("res://Scenes/MinimapScenes/unvisited.tscn")
var mroomSize = Vector2(150, 75)
var minimapOffset = Vector2(5, 5)  # Padding from the edge of the screen
var minimapSize
var rooms_container
var camera_position = Vector2(0,0)
var rooms = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass
	# Position the entire minimap node in the top right corner
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func changeRoom(_roomID):
	for room in rooms:
		if room.roomID == _roomID:
			print(_roomID)
			room.markVisited()
		else:
			room.markUnvisited()
		
				
func generateMinimap(matrix):
	# Create a container node for all rooms to make positioning easier
	var rooms_container = Node2D.new()
	rooms_container.name = "Container"
	add_child(rooms_container)
	
	for i in range(len(matrix)):
		for j in range(len(matrix)):
			var cell_value = matrix[i][j]
			if cell_value > 0:
				var room = UnvisitedScene.instantiate()
				room.setRoomID(cell_value)
				rooms_container.add_child(room)
				room.scale = Vector2(0.5, 0.5)
				room.position = Vector2((j-2) * mroomSize.x/2, -(2-i) * mroomSize.y/2)
				rooms.append(room)
	
	# Center the rooms container (optional)
	# This will center the minimap rooms relative to the top-right corner
	minimapSize = getMinimapSize(matrix)
	
	

# Helper function to calculate the size of the minimap based on the matrix
func getMinimapSize(matrix):
	
	var rows = matrix.size()
	var cols = matrix[0].size()
	var zero_rows = 0
	var zero_cols = 0
	
	for i in range(rows):
		var is_zero_row = true
		for j in range(cols):
			if matrix[i][j] != 0:
				is_zero_row= false
				break
		if is_zero_row:
			zero_rows += 1
	
	for j in range(cols):
		var is_zero_col = true
		for i in range(rows):
			if matrix[i][j] != 0:
				is_zero_col = false
				break
		if is_zero_col:
			zero_cols += 1

	var width = 0.5 * mroomSize.x * (cols - zero_cols)
	var height = 0.5 * mroomSize.y * (rows - zero_rows)
	
	return Vector2(width, height)

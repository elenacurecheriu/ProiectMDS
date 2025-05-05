extends Sprite2D

var roomID
var visited = false
var visitedTexture = load("res://Textures/MinimapTextures/visited.png")
var unvisitedTexture = load("res://Textures/MinimapTextures/unvisited.png")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setRoomID(_roomID):
	roomID = _roomID

func markVisited():
	visited = true
	texture = visitedTexture

func markUnvisited():
	visited = false
	texture = unvisitedTexture

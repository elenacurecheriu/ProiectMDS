extends Node2D
@onready var main = $".."
@onready var minimap = $"../Camera2D/CanvasLayer/Minimap"
var roomID = 0
var test = 0 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setRoomID(_roomID):
	roomID = _roomID

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func rotate_doors():
	for door in main.doors:
			if roomID in main.doors[door]:
				var thisX = position.x
				var thisY = position.y
				var doorX = door.position.x
				var doorY = door.position.y
				if doorX > thisX: #inseamna ca e in dreapta
					door.rotation_degrees = 90
				if doorX < thisX: #inseamna ca e in stanga
					door.rotation_degrees = -90
				if doorY > thisY: #inseamna ca e jos
					door.rotation_degrees = 180
				if doorY < thisY: #inseamna ca e sus nu se intampla nimic
					door.rotation_degrees = 0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if test > 1:
		print("Entered room", roomID)
		rotate_doors()
		main.changeRoomOnMinimap(roomID)
	else:
		test +=1

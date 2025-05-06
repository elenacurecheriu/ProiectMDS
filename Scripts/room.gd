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


func _on_area_2d_body_entered(body: Node2D) -> void:
	if test > 0:
		print("Entered room", roomID)
		main.changeRoomOnMinimap(roomID)
	else:
		test +=1

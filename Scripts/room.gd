extends Node2D

var roomID = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.

func setRoomID(_roomID):
	roomID = _roomID

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Entered room", roomID)
	pass # Replace with function body.

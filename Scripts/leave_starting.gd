extends Area2D

var test = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if test == 0:
		test+= 1
	#imi pare rau mihai, dar merge
	else: 
		get_tree().change_scene_to_file("res://Scenes/levels/village.tscn")
	pass # Replace with function body.

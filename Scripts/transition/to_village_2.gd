extends Area2D
var in_interaction = false
signal blackscreen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if in_interaction and Input.is_action_pressed("Interact"):
		get_node("../../Player").position = Vector2(-809, 1300)
		emit_signal("blackscreen")
	pass


func _on_body_entered(body: Node2D) -> void:
	in_interaction = true
	
	pass # Replace with function body.


func _on_body_exited(body: Node2D) -> void:
	in_interaction = false
	pass # Replace with function body.

extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	
	
	get_node("Player").position = Vector2(7825.029,1508.59)#debug purposese!!!!!!!!!!
	
	
	
	fadingBlack()
	pass # Replace with function body.



func fadingBlack():
	get_node("blackscreen").position = get_node("Player").position + Vector2(-575/2.5, -325/2.5)
	var i = 1.0
	while i >= 0.0:
		i -= 0.01
		get_node("blackscreen").material.set_shader_parameter("opacity", i)
		await get_tree().process_frame


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_panda_house_blackscreen_relay() -> void:
	fadingBlack()
	pass # Replace with function body.


func _on_area_lamb_blackscreen() -> void:
	fadingBlack()
	pass # Replace with function body.


func _on_gate_area_blackscreen() -> void:
	fadingBlack()
	pass # Replace with function body.

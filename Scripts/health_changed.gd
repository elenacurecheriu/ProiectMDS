extends Node

signal health_changed(new_health, max_health)

func _ready():
	add_to_group("health_components")
	call_deferred("emit_initial_values")
	
func emit_initial_values():
	print("emit_initial_values")
	var player = get_node("Player")
	if player != null && player.has_method("get_health_values"):
		var values = player.get_health_values()
		print("health changed")
		emit_signal("health_changed", values[0], values[1])

func test():
	print("weirufhweuhrifwiurwebrbwerw")

func _on_health_changed(new_health: Variant, max_health: Variant) -> void:
	pass # Replace with function body.

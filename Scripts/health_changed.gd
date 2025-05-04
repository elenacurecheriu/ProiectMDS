extends Node

signal health_changed(new_health, max_health)

func _ready():
	add_to_group("health_components")
	call_deferred("emit_initial_values")
	
func emit_initial_values():
	var player = get_parent()
	if player != null && player.has_method("get_health_values"):
		var values = player.get_health_values()
		emit_signal("health_changed", values[0], values[1])

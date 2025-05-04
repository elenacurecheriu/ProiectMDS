extends ProgressBar

func _ready():
	max_value = 300
	value = 0 

	await get_tree().process_frame

	var health_components = get_tree().get_nodes_in_group("health_components")
	
	if health_components.size() > 0:
		var health_component = health_components[0]
		health_component.connect("health_changed", Callable(self, "_on_health_changed"))
	else:
		print("ERROR: Didn't find HealthComponent!")

func _on_health_changed(new_health, max_health):
	self.max_value = max_health
	self.value = new_health
	print("Health Bar has changed: ", new_health, "/", max_health)

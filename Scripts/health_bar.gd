extends TextureProgressBar

func _ready():
	pass

func set_max_health(_max_health):
	max_value = _max_health 
	update_health(_max_health)

func update_health(_current_health):
	value = _current_health
	$HealthLabel.text = str(_current_health) + "/" + str(int(max_value))

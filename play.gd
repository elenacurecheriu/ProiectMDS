class_name Play
extends Button

var fonts = []  
var random_timer

func _ready() -> void:
	fonts = [
		preload("res://Fonts/Pixel Game.otf"),
		preload("res://Fonts/NewGlitchDemoRegular.ttf"),
		preload("res://Fonts/Glitchdemo-lxgGq.ttf"),
	]
	
	random_timer = Timer.new()
	random_timer.wait_time = randf_range(1.0, 5.0)  
	random_timer.one_shot = true
	random_timer.timeout.connect(_on_random_timer_timeout)
	add_child(random_timer)
	
	random_timer.start()

func _on_mouse_entered() -> void:
	add_theme_font_override("font", fonts[1])
	random_timer.stop()  

	
func _on_mouse_exited() -> void:
	random_timer.start()

func _on_random_timer_timeout() -> void:
	var random_font = fonts[randi() % fonts.size()]
	add_theme_font_override("font", random_font)
	
	random_timer.wait_time = randf_range(0.2, 1.0)
	random_timer.start()

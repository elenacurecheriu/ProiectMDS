extends Area2D

var target_node: Node2D
@export var fade_duration: float = 1.0

var current_tween: Tween  #variabila ca sa tion cont de tween-urile faucte
# si cand ies/intru in AREA 2D  sa sterg tween ul respectiv ca sa nu se suprapuna


func _ready():
	var scene = preload("res://Scenes/Tutorial/WASD_buttons.tscn")
	target_node = scene.instantiate()
	
	body_entered.connect(_on_wasd_body_entered)
	body_exited.connect(_on_wasd_body_exited)
	
	#ma asigut ca e invizibil la inceput
	if target_node:
		target_node.modulate.a = 0.0
		target_node.visible = false
		
func _on_wasd_body_entered(body: Node2D) -> void:
	print("Entered ATTACK area: ", self.name, " Body: ", body.name)

	if target_node:
		#il scot pe ala de dinainte
		if current_tween:
			current_tween.kill()
			
		if target_node.get_parent():
			target_node.get_parent().remove_child(target_node)
		
			
			
		target_node.position = Vector2(187, 80)
		self.add_child(target_node)
		
		#animatii	
		target_node.visible = true
		fade_in_node()
		start_animated_sprites()


func _on_wasd_body_exited(body: Node2D) -> void:
	if target_node:
		if current_tween:
			current_tween.kill()
		
		fade_out_node()
		stop_animated_sprites()
		
		

func fade_in_node():
	current_tween = create_tween()
	current_tween.tween_property(target_node, "modulate:a", 1.0, fade_duration)

func fade_out_node():
	current_tween = create_tween()
	current_tween.tween_property(target_node, "modulate:a", 0.0, fade_duration)
	# Da hide la nod
	current_tween.tween_callback(func(): target_node.visible = false)

func start_animated_sprites():
	#dau play la animatii
	if target_node:
		for child in target_node.get_children():
			if child is AnimatedSprite2D:
				child.visible = true
				child.play()  

func stop_animated_sprites():
	if target_node:
		for child in target_node.get_children():
			if child is AnimatedSprite2D:
				child.stop()

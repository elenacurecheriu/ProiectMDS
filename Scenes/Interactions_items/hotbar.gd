extends VBoxContainer

@onready var player

func _ready():
	# Set position in top left and don't move
	self.position = Vector2(10, 10)
	
	# Find the player in the scene
	await get_tree().process_frame
	var player_ = get_tree().get_first_node_in_group("player")
	player = find_player(player_)
	if player:
		update_hotbar()
		
		var timer = Timer.new()
		add_child(timer)
		timer.wait_time = 0.5
		timer.timeout.connect(update_hotbar)
		timer.start()

func find_player(node):
	for child in node.get_children():
		if child is CharacterBody2D:
			return child
		var found = find_player(child)
		if found:
			return found
	return null

func update_hotbar():
	if not player:
		return
		
	# Clear existing displays
	for child in get_children():
		if not child is Timer:
			child.queue_free()
	
	# Get player stats
	var stats = player.stats
	
	# Create a texture frame for each non-zero stat
	for stat_name in stats:
		var stat_value = stats[stat_name]
		if stat_value > 0:
			# Create container for the item
			var hbox = HBoxContainer.new()
			add_child(hbox)
			
			# Create texture rectangle with brown border
			var texture_rect = TextureRect.new()
			texture_rect.custom_minimum_size = Vector2(40, 40)  # Small fixed size
			
			# Try to load texture from textures folder
			var texture_path = "res://textures/" + stat_name.to_lower() + ".png"
			var texture = ResourceLoader.load(texture_path)
			texture_rect.texture = texture
			texture_rect.expand = true
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			
			# Add brown border
			var style = StyleBoxFlat.new()
			style.border_width_left = 2
			style.border_width_top = 2
			style.border_width_right = 2
			style.border_width_bottom = 2
			style.border_color = Color(0.65, 0.4, 0.2)  # Brown color
			texture_rect.add_theme_stylebox_override("panel", style)
			
			hbox.add_child(texture_rect)
			
			# Add stat value label
			var label = Label.new()
			label.text = str(stat_value)
			label.add_theme_color_override("font_color", Color(1, 1, 1))
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			hbox.add_child(label)

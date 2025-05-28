extends GridContainer

@onready var player

const ITEM_SIZE = 30  #marimea containaerului unde se afla itemele


func _ready():
	
	
	columns = 2 # How many items per row (adjust as needed)
	add_theme_constant_override("h_separation", 5)  # Horizontal spacing between items
	add_theme_constant_override("v_separation", 5)  # Vertical spacing between itemsd
	#pozitionare hotbar dreapta sus sub minimap
	
	anchor_left = 1.0   
	anchor_right = 0.99   # cu cat se apropie de 1 cu atat se misca mai mult spre dreapta
	anchor_top = 0.5     
	anchor_bottom = 0.0  
	
	offset_left = -80  #cu cat cresc cu atat se misca spre stanga
	offset_right = -40  #cu cat scad cu atat se misca spre dreapta
	offset_top = 150    #cu cat scad cu atat urca mai sus
	offset_bottom = 110  # 100 pixtallels 
		

	
	# Wait for the player to be ready
	await get_tree().process_frame
	
	#verific daca playerul exista
	player = get_tree().get_first_node_in_group("player")
	
	if player:
		update_hotbar()
		var timer = Timer.new()
		add_child(timer)
		timer.wait_time = 0.5
		timer.timeout.connect(update_hotbar)
		timer.start()
	else:
		push_error("Player not found in 'player' group")

func find_player(node):  #caut playerul in fisierele jocului
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
	
	#Extrag stats urile playerului , itemele
	var stats = player.stats
	
	#pentru orice item care are mai mult de 0 , creez in hotbar o instanta a lui cu valoarea acestuia
	for stat_name in stats:
		var stat_value = stats[stat_name]
		if stat_value > 0:
		
			var item_box = Panel.new()
			add_child(item_box)
			item_box.custom_minimum_size = Vector2(ITEM_SIZE, ITEM_SIZE)

			var box_style = StyleBoxFlat.new()
			box_style.bg_color = Color(0.1, 0.1, 0.1, 0.7)
			box_style.set_border_width_all(2)
			box_style.border_color = Color(0.65, 0.4, 0.2)
			item_box.add_theme_stylebox_override("panel", box_style)

		
			var item_container = Control.new()
			item_container.anchor_left = 0
			item_container.anchor_top = 0
			item_container.anchor_right = 1
			item_container.anchor_bottom = 1
			item_container.offset_left = 0
			item_container.offset_top = 0
			item_container.offset_right = 0
			item_container.offset_bottom = 0
			item_box.add_child(item_container)

			#Imagine itemului (in centru )
			var texture_rect = TextureRect.new()
			texture_rect.custom_minimum_size = Vector2(ITEM_SIZE, ITEM_SIZE)
			texture_rect.texture = ResourceLoader.load("res://Textures/Items/" + stat_name.to_lower() + ".png")
			texture_rect.expand = true
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			texture_rect.anchor_left = 0
			texture_rect.anchor_top = 0
			texture_rect.anchor_right = 1
			texture_rect.anchor_bottom = 1
			texture_rect.offset_left = 0
			texture_rect.offset_top = 0
			texture_rect.offset_right = 0
			texture_rect.offset_bottom = 0
			
			item_container.add_child(texture_rect)

			

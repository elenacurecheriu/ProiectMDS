extends GutTest

var interacting_component
var InteractingScene = preload("res://Scenes/Interactions_items/interacting_component_items.tscn")

func before_each():
	interacting_component = InteractingScene.instantiate()
	add_child_autofree(interacting_component)

func test_initial_state():
	assert_eq(interacting_component.available_interactions.size(), 0, "Should start with no interactions")
	assert_true(interacting_component.able_to_interact, "Should be able to interact initially")

func test_sorting_by_distance():
	# Creează obiecte mock pentru test
	var area1 = Area2D.new()
	var area2 = Area2D.new()
	
	area1.global_position = Vector2(100, 100)
	area2.global_position = Vector2(200, 200)
	
	interacting_component.global_position = Vector2(0, 0)
	
	# area1 ar trebui să fie mai aproape
	var is_area1_closer = interacting_component.sorting_by_nearest(area1, area2)
	assert_true(is_area1_closer, "Area1 should be closer than Area2")
	
	area1.queue_free()
	area2.queue_free()

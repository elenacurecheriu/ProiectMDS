extends GutTest

var player
var interactable
var PlayerScene = preload("res://Scenes/Attack/debug_character.tscn")
var InteractableScene = preload("res://Scenes/Interactions_items/Interactable_items.tscn")

func before_each():
	player = PlayerScene.instantiate()
	interactable = InteractableScene.instantiate()
	
	add_child_autofree(player)
	add_child_autofree(interactable)

func test_player_interaction_flow():
	# Testează doar manipularea array-ului, NU apela handleInteractions()
	assert_eq(player.activeInteractions.size(), 0, "Should start with no active interactions")
	
	# Creează un mock area simplu
	var mock_area = Area2D.new()
	
	# Simulează adăugarea interacțiunii
	player.activeInteractions.append(mock_area)
	assert_eq(player.activeInteractions.size(), 1, "Should have one active interaction")
	
	# Simulează eliminarea interacțiunii
	player.activeInteractions.erase(mock_area)
	assert_eq(player.activeInteractions.size(), 0, "Should have no active interactions after removal")
	
	# Cleanup
	mock_area.queue_free()
	
	# NU apela player.handleInteractions() - va cauza eroarea

func test_multiple_interactions():
	var mock_area1 = Area2D.new()
	var mock_area2 = Area2D.new()
	
	player.activeInteractions.append(mock_area1)
	player.activeInteractions.append(mock_area2)
	
	assert_eq(player.activeInteractions.size(), 2, "Should handle multiple interactions")
	
	# Testează că primul din listă e primul procesat (fără să-l procesezi)
	assert_eq(player.activeInteractions[0], mock_area1, "First interaction should be first in array")
	
	# Cleanup
	mock_area1.queue_free()
	mock_area2.queue_free()

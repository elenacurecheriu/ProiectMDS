extends GutTest

var game
var GameScene = preload("res://Scenes/game.tscn")

func before_each():
	game = GameScene.instantiate()
	add_child_autofree(game)

func test_matrix_generation():
	var matrix = game.generate_dungeon()
	
	# Verifică că matricea are dimensiunea corectă
	assert_eq(matrix.size(), game.M_SIZE, "Matrix should have correct height")
	assert_eq(matrix[0].size(), game.M_SIZE, "Matrix should have correct width")
	
	# Verifică că există cameră în centru
	assert_gt(matrix[2][2], 0, "Center should have a room")

func test_valid_position():
	# Pozițiile valide
	assert_true(game.is_valid_position(Vector2(0, 0)), "Top-left should be valid")
	assert_true(game.is_valid_position(Vector2(2, 2)), "Center should be valid")
	assert_true(game.is_valid_position(Vector2(4, 4)), "Bottom-right should be valid")
	
	# Pozițiile invalide
	assert_false(game.is_valid_position(Vector2(-1, 0)), "Negative x should be invalid")
	assert_false(game.is_valid_position(Vector2(0, -1)), "Negative y should be invalid")
	assert_false(game.is_valid_position(Vector2(5, 0)), "Out of bounds x should be invalid")
	assert_false(game.is_valid_position(Vector2(0, 5)), "Out of bounds y should be invalid")

func test_room_count():
	var matrix = game.generate_dungeon()
	var room_count = 0
	
	for i in range(game.M_SIZE):
		for j in range(game.M_SIZE):
			if matrix[i][j] > 0:
				room_count += 1
	
	assert_true(room_count <= game.MAX_CAMERE, "Should not exceed maximum rooms: %d <= %d" % [room_count, game.MAX_CAMERE])
	assert_true(room_count > 0, "Should have at least one room")

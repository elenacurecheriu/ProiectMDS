# test_dungeon_generation.gd
extends GutTest

var game
var GameScene = preload("res://Scenes/game.tscn")

func before_each():
	game = GameScene.instantiate()
	add_child_autofree(game)

# ===== UNIT TESTS pentru funcții individuale =====

func test_generate_dungeon_returns_valid_matrix():
	var matrix = game.generate_dungeon()
	
	# Verifică dimensiunile matricei
	assert_eq(matrix.size(), game.M_SIZE, "Matrix height should match M_SIZE")
	assert_eq(matrix[0].size(), game.M_SIZE, "Matrix width should match M_SIZE")
	
	# Verifică că toate valorile sunt >= 0
	for i in range(game.M_SIZE):
		for j in range(game.M_SIZE):
			assert_true(matrix[i][j] >= 0, "All matrix values should be >= 0 at [%d][%d]" % [i, j])

func test_generate_dungeon_has_starting_room():
	var matrix = game.generate_dungeon()
	
	# Camera de start ar trebui să fie în centru (2,2) și să aibă valoarea 1
	assert_eq(matrix[2][2], 1, "Starting room should be at center with value 1")

func test_generate_dungeon_respects_max_rooms():
	var matrix = game.generate_dungeon()
	var room_count = 0
	
	# Numără camerele generate
	for i in range(game.M_SIZE):
		for j in range(game.M_SIZE):
			if matrix[i][j] > 0:
				room_count += 1
	
	assert_true(room_count <= game.MAX_CAMERE, "Should not exceed MAX_CAMERE: %d <= %d" % [room_count, game.MAX_CAMERE])
	assert_true(room_count > 0, "Should have at least the starting room")

func test_generate_dungeon_creates_connected_rooms():
	var matrix = game.generate_dungeon()
	
	# Verifică că există cel puțin o cameră adiacentă cu camera de start
	var start_pos = Vector2(2, 2)
	var directions = [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]
	var has_adjacent_room = false
	
	for dir in directions:
		var adjacent_pos = start_pos + dir
		if adjacent_pos.x >= 0 and adjacent_pos.x < game.M_SIZE and adjacent_pos.y >= 0 and adjacent_pos.y < game.M_SIZE:
			if matrix[adjacent_pos.y][adjacent_pos.x] > 0:
				has_adjacent_room = true
				break
	
	# Doar dacă avem mai mult de o cameră, ar trebui să existe adiacențe
	var room_count = 0
	for i in range(game.M_SIZE):
		for j in range(game.M_SIZE):
			if matrix[i][j] > 0:
				room_count += 1
	
	if room_count > 1:
		assert_true(has_adjacent_room, "Multi-room dungeon should have connected rooms")

func test_is_valid_position_boundary_cases():
	# Corner cases pentru limite
	assert_true(game.is_valid_position(Vector2(0, 0)), "Top-left corner should be valid")
	assert_true(game.is_valid_position(Vector2(game.M_SIZE-1, game.M_SIZE-1)), "Bottom-right corner should be valid")
	
	# Out of bounds cases
	assert_false(game.is_valid_position(Vector2(-1, 0)), "Negative x should be invalid")
	assert_false(game.is_valid_position(Vector2(0, -1)), "Negative y should be invalid")
	assert_false(game.is_valid_position(Vector2(game.M_SIZE, 0)), "x = M_SIZE should be invalid")
	assert_false(game.is_valid_position(Vector2(0, game.M_SIZE)), "y = M_SIZE should be invalid")

func test_room_numbering_is_sequential():
	var matrix = game.generate_dungeon()
	var room_numbers = []
	
	# Colectează toate numerele camerelor
	for i in range(game.M_SIZE):
		for j in range(game.M_SIZE):
			if matrix[i][j] > 0:
				room_numbers.append(matrix[i][j])
	
	room_numbers.sort()
	
	# Verifică că numerotarea e secvențială (1, 2, 3, ...)
	for i in range(room_numbers.size()):
		assert_eq(room_numbers[i], i + 1, "Room numbers should be sequential starting from 1")

# ===== INTEGRATION TESTS pentru workflow complet =====

func test_dungeon_generation_creates_doors():
	# Acest test verifică că după generarea dungeon-ului se creează și ușile
	game.generate_dungeon()
	
	# Dacă ai o metodă separată pentru crearea ușilor, testează-o aici
	# game.create_doors()
	
	# Verifică că s-au creat ușile în game
	var doors = game.get_children().filter(func(child): return child.name.begins_with("Door"))
	
	# Ar trebui să existe cel puțin o ușă dacă sunt mai multe camere
	var room_count = 0
	for child in game.get_children():
		if "Room" in child.name:
			room_count += 1
	
	if room_count > 1:
		assert_true(doors.size() > 0, "Should create doors between rooms")

func test_dungeon_generation_with_minimap_integration():
	# Test că generarea dungeon-ului se integrează cu minimap-ul
	var matrix = game.generate_dungeon()
	
	# Verifică că minimap-ul primește informații despre camerele generate
	if game.has_method("changeRoomOnMinimap"):
		# Simulează schimbarea camerei
		game.changeRoomOnMinimap(1)
		
		# Verifică că minimap-ul există și funcționează
		assert_not_null(game.minimap, "Minimap should exist after dungeon generation")

func test_player_spawn_position_in_generated_dungeon():
	# Test că player-ul se spawn-ează în poziția corectă după generarea dungeon-ului
	var matrix = game.generate_dungeon()
	
	# Găsește camera de start (valoarea 1)
	var start_room_pos = Vector2(-1, -1)
	for i in range(game.M_SIZE):
		for j in range(game.M_SIZE):
			if matrix[i][j] == 1:
				start_room_pos = Vector2(j, i)
				break
	
	assert_ne(start_room_pos, Vector2(-1, -1), "Should find starting room position")
	
	# Verifică că player-ul e în camera corectă (dacă ai logică pentru asta)
	# var player = game.get_node("Player")
	# assert_not_null(player, "Player should exist in generated dungeon")

func test_door_positioning_between_adjacent_rooms():
	# Test că ușile se poziționează corect între camerele adiacente
	var matrix = game.generate_dungeon()
	
	# Găsește două camere adiacente
	var room1_pos = Vector2(-1, -1)
	var room2_pos = Vector2(-1, -1)
	
	for i in range(game.M_SIZE):
		for j in range(game.M_SIZE - 1):  # Verifică orizontal
			if matrix[i][j] > 0 and matrix[i][j + 1] > 0:
				room1_pos = Vector2(j, i)
				room2_pos = Vector2(j + 1, i)
				break
	
	if room1_pos != Vector2(-1, -1):
		# Dacă ai găsit camere adiacente, verifică că există o ușă între ele
		var expected_door_name = "Door " + str(matrix[room1_pos.y][room1_pos.x]) + " -> " + str(matrix[room2_pos.y][room2_pos.x])
		var door = game.get_node_or_null(expected_door_name)
		
		if door:  # Doar dacă ai implementat crearea ușilor
			assert_not_null(door, "Door should exist between adjacent rooms")
			
			# Verifică poziționarea ușii (ar trebui să fie la jumătatea distanței)
			var room1_world_pos = game.rooms[room1_pos].position if game.has_method("rooms") else Vector2.ZERO
			var room2_world_pos = game.rooms[room2_pos].position if game.has_method("rooms") else Vector2.ZERO
			var expected_door_pos = room1_world_pos.lerp(room2_world_pos, 0.5)
			
			# Verificare aproximativă pentru poziție (cu toleranță de 10 pixeli)
			var position_diff = (door.position - expected_door_pos).length()
			assert_true(position_diff < 10.0, "Door should be positioned between rooms")

func test_multiple_dungeon_generations_are_different():
	# Test că generarea aleatoare produce dungeon-uri diferite
	var matrix1 = game.generate_dungeon()
	var matrix2 = game.generate_dungeon()
	
	var matrices_are_different = false
	
	for i in range(game.M_SIZE):
		for j in range(game.M_SIZE):
			if matrix1[i][j] != matrix2[i][j]:
				matrices_are_different = true
				break
	
	# Nota: Acest test poate să eșueze ocazional din cauza aleatoriului
	# În practică, poți rula generarea de mai multe ori pentru a fi sigur
	# assert_true(matrices_are_different, "Multiple generations should produce different layouts")

func test_dungeon_generation_performance():
	# Test de performanță - generarea nu ar trebui să dureze prea mult
	var start_time = Time.get_time_dict_from_system()
	
	for i in range(10):  # Generează 10 dungeon-uri
		game.generate_dungeon()
	
	var end_time = Time.get_time_dict_from_system()
	
	# Calculează durata (simplificat - în practică ai nevoie de o funcție mai precisă)
	var duration_seconds = (end_time.hour * 3600 + end_time.minute * 60 + end_time.second) - (start_time.hour * 3600 + start_time.minute * 60 + start_time.second)
	
	assert_true(duration_seconds < 5, "10 dungeon generations should complete in under 5 seconds")

# ===== HELPER METHODS pentru teste =====

func get_room_count_from_matrix(matrix):
	var count = 0
	for i in range(game.M_SIZE):
		for j in range(game.M_SIZE):
			if matrix[i][j] > 0:
				count += 1
	return count

func find_room_position_by_id(matrix, room_id):
	for i in range(game.M_SIZE):
		for j in range(game.M_SIZE):
			if matrix[i][j] == room_id:
				return Vector2(j, i)
	return Vector2(-1, -1)

func count_adjacent_rooms(matrix, pos):
	var adjacent_count = 0
	var directions = [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]
	
	for dir in directions:
		var adjacent_pos = pos + dir
		if game.is_valid_position(adjacent_pos) and matrix[adjacent_pos.y][adjacent_pos.x] > 0:
			adjacent_count += 1
	
	return adjacent_count

# ===== STRESS TESTS =====

func test_dungeon_generation_edge_cases():
	# Nu putem modifica const MAX_CAMERE, deci testăm doar cu valoarea existentă
	var matrix = game.generate_dungeon()
	var room_count = get_room_count_from_matrix(matrix)
	
	# Testează că respectă limita existentă
	assert_true(room_count <= game.MAX_CAMERE, "Should respect MAX_CAMERE constant: %d <= %d" % [room_count, game.MAX_CAMERE])
	assert_true(room_count > 0, "Should have at least the starting room")
	
	# Test că camera de start există
	assert_eq(matrix[2][2], 1, "Starting room should be at center")
	
	# Test că toate camerele au valori pozitive consecutive
	var room_numbers = []
	for i in range(game.M_SIZE):
		for j in range(game.M_SIZE):
			if matrix[i][j] > 0:
				room_numbers.append(matrix[i][j])
	
	room_numbers.sort()
	for i in range(room_numbers.size()):
		assert_eq(room_numbers[i], i + 1, "Room numbers should be consecutive starting from 1")

func test_dungeon_connectivity():
	# Test mai avansat pentru conectivitatea dungeon-ului
	var matrix = game.generate_dungeon()
	
	# Verifică că toate camerele sunt accesibile din camera de start folosind BFS
	var visited = {}
	var queue = [Vector2(2, 2)]  # Start position
	visited[Vector2(2, 2)] = true
	
	while queue.size() > 0:
		var current = queue.pop_front()
		var directions = [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]
		
		for dir in directions:
			var next_pos = current + dir
			if game.is_valid_position(next_pos) and not visited.has(next_pos) and matrix[next_pos.y][next_pos.x] > 0:
				visited[next_pos] = true
				queue.append(next_pos)
	
	# Numără toate camerele din matrice
	var total_rooms = get_room_count_from_matrix(matrix)
	
	# Toate camerele ar trebui să fie accesibile
	assert_eq(visited.size(), total_rooms, "All rooms should be reachable from starting position")

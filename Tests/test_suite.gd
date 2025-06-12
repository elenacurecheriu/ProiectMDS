extends GutTest

func run_all_tests():
	# Configurează și rulează toate testele
	var gut = preload("res://addons/gut/gut.gd").new()
	
	# Adaugă directoarele cu teste
	gut.add_directory("res://Tests/Unice/")
	gut.add_directory("res://Tests/Integration/")
	
	# Rulează testele
	gut.test_scripts()

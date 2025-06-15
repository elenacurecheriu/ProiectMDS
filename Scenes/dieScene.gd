extends Node2D

var village = preload("res://Scenes/levels/village_3.tscn")

func _on_timer_timeout() -> void:
	Fade_Transition.transition()
	await Fade_Transition.on_transition_finished
	get_tree().change_scene_to_packed(village)

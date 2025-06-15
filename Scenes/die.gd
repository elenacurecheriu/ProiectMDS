extends Node2D

var village = preload("res://Scenes/levels/village_2.tscn")

func _on_timer_timeout() -> void:
	FadeTransition.transition()
	await FadeTransition.on_transition_finished
	get_tree().change_scene_to_packed(village)

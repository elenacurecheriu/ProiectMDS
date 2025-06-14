extends Node2D

const villageScene = preload("res://Scenes/levels/village.tscn")

func _on_timer_timeout() -> void:
	FadeTransition.transition()
	await FadeTransition.on_transition_finished
	get_tree().change_scene_to_packed(villageScene)

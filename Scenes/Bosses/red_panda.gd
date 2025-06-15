extends CharacterBody2D

signal startBossRelay

func _on_red_panda_area_startboss() -> void:
	emit_signal("startBossRelay")

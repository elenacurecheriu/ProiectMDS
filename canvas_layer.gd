extends CanvasLayer

@onready var colorRect = $ColorRect
@onready var animationPlayer = $AnimationPlayer

#signal on_transition_finished

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_to_black":
		#on_transition_finished.emit()
		animationPlayer.play("fade_to_normal")
	elif anim_name == "fade_to_normal":
		colorRect.visible = false

func transition():
	colorRect.visible = true
	animationPlayer.play("fade_to_black")

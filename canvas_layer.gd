extends CanvasLayer
class_name FadeTransition

signal on_transition_finished

@onready var colorRect = $ColorRect
@onready var animationPlayer = $AnimationPlayer

func _ready() -> void:
	colorRect.visible = false
	animationPlayer.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_to_black":
		on_transition_finished.emit()
		animationPlayer.play("fade_to_normal")
	elif anim_name == "fade_to_normal":
		colorRect.visible = false

func transition():
	colorRect.visible = true
	animationPlayer.play("fade_to_black")

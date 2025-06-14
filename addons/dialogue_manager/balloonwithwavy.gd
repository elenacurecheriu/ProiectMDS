extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$DialogueLabel.bbcode_enabled = true
	var wavy = preload("res://addons/dialogue_manager/wavy_effect.gd").new()
	$DialogueLabel.add_custom_effect(wavy)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

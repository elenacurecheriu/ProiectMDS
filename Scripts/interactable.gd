class_name Iteractable extends Area2D

enum InteractionTypes {DIALOGUE, HEAL}

@export var InteractionType = InteractionTypes.DIALOGUE

@onready var InteractIcon = $Sprite2D

func _ready() -> void:
	InteractIcon.hide()

func _on_area_entered(area: Area2D) -> void:
	InteractIcon.show()


func _on_area_exited(area: Area2D) -> void:
	InteractIcon.hide()

func ActivateInteraction(player) -> void:
	pass

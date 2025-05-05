extends Node2D

@export var damage_amount = 10

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage_amount)
		print("Player took " + str(damage_amount) + " damage")
	pass

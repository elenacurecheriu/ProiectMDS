extends Iteractable

@export var heal_amount = 10

func ActivateInteraction(player) -> void:
	if player.has_method("heal"):
		player.heal(heal_amount)
		print("Player healed " + str(heal_amount) + " health")
	pass

extends Iteractable

@export var heal_amount = 10
@export var dialogueScript: DialogueResource

func ActivateInteraction(player) -> void:
	match InteractionType:
		Iteractable.InteractionTypes.HEAL:
			player.heal(heal_amount)
			print("Player healed " + str(heal_amount) + " health")
		Iteractable.InteractionTypes.DIALOGUE:
			DialogueManager.show_example_dialogue_balloon(dialogueScript, "start")
	


func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

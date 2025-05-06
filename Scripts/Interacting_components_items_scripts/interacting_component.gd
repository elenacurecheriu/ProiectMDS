extends Node2D
@onready var interact_label = $Area2D/Label
var available_interactions = []
var able_to_interact = true

func _input(event: InputEvent) -> void:  #Cand apasa pe R sa selectez item-ul
	if event.is_action_pressed("Collect") and able_to_interact:
		if available_interactions and available_interactions.size() > 0:
			var interactable = available_interactions[0]
			
			if interactable.has_method("interact") or interactable.get("interact") != null:
				able_to_interact = false
				interact_label.hide()
				
				await interactable.interact.call()
				
				able_to_interact = true

func _process(delta: float) -> void: #pe tot parcursul jocului cat timp un player se afla in collision layer-ul itemului un text custom va aparea
	if available_interactions.size() > 0 and able_to_interact:  #daca exista macar un obiect si e valid
		available_interactions.sort_custom(sorting_by_nearest)
		
		var interactable = available_interactions[0]
		if interactable.get("is_interactable") == true: #daca atributul is_interactable din obiect este true
			interact_label.text = interactable.get("interact_name")  #pun numele in label
			interact_label.show()
		else:
			interact_label.hide()
	else:
		interact_label.hide()

func sorting_by_nearest(area1, area2):  #sortez vectorul de collectables astefel incat sa apara cel mai arpopiat obiect relativ to the player
	var area1_dist = global_position.distance_to(area1.global_position)
	var area2_dist = global_position.distance_to(area2.global_position)  
	return area1_dist < area2_dist

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get("interact") != null:
		available_interactions.push_back(area)

func _on_area_2d_area_exited(area: Area2D) -> void:
	available_interactions.erase(area)

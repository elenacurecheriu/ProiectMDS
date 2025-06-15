extends Area2D


@export var speed: float = 300.0
var direction: Vector2 = Vector2.ZERO

signal hit_player

func _ready():
	connect("body_entered", _on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		emit_signal("hit_player", body)
		queue_free() 
	elif body is TileMapLayer or body.is_in_group("walls"):
		queue_free()  

extends Node2D

@export var sound: AudioStreamMP3
@onready var player = $AudioStreamPlayer2D

func _ready() -> void:
	player.stream = sound
	player.play()

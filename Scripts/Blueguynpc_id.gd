extends CharacterBody2D

@export var id: String = "blueguynpc"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$inter.visible = false

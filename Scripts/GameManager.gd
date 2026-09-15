extends Node2D


@onready var trigger_area: Area2D = $blueguy/Area2D
@onready var blueguy: CharacterBody2D = $blueguy
@onready var player: CharacterBody2D = $Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trigger_area.body_entered.connect(_on_trigger_entered)


func _on_trigger_entered(body: Node2D) -> void:
	
	if body.is_in_group("player"):
		get_tree().call_group("enemy", "set_physics_process", false)
		player.set_physics_process(false)
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/fight.tscn")
		
		
	

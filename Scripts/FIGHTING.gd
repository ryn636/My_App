extends Node2D



@onready var player: CharacterBody2D = $Player





@onready var pop: Control = $CanvasLayer/pop


func _ready() -> void:

	$fightingplayer/AnimatedSprite2D.play("idle")

func _physics_process(delta: float) -> void:
	if GlobalData.lives <= 0:
		get_tree().change_scene_to_file("res://Scenes/World.tscn")
		print("game over")
	


func _on_button_pressed() -> void:
	pop.visible = true

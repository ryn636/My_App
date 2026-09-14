extends Node2D

@onready var player: CharacterBody2D = $player


func _ready() -> void:
	$fightingplayer/AnimatedSprite2D.play("idle")

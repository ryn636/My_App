extends Node2D


@onready var trigger_area: Area2D = $blueguy/Area2D



@onready var blueguy: CharacterBody2D = $blueguy
@onready var player: CharacterBody2D = $Player






# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GlobalData.has_return_position:
		player.global_position = GlobalData.lastpos
	for e in get_tree().get_nodes_in_group("enemy"):
		var trigger = e.get_node("Area2D")
		trigger.body_entered.connect(_on_trigger_entered.bind(e))
	
	for e in get_tree().get_nodes_in_group("enemy"):
		if e.enemy_id in GlobalData.defeated_enemies:
			e.queue_free()
	
func _on_trigger_entered(body: Node2D, enemy: CharacterBody2D) -> void: # knight 1 trigger
	
	if body.is_in_group("player"):
		GlobalData.lastpos = body.global_position
		GlobalData.has_return_position = true
		get_tree().call_group("enemy", "set_physics_process", false)
		player.set_physics_process(false)
		GlobalData.current_enemy_data = {
			"enemy_id": enemy.enemy_id,
			"fight_scene": enemy.fight_scene,
			"enemy_hp": enemy.enemy_hp
		}
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/fight.tscn")
		
		
		
		
	

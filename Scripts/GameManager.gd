extends Node2D




@onready var player: CharacterBody2D = $Player
@export_file("*.json") var d_file
@onready var dialogue_display: Control = $dialogue_display/CanvasLayer/diagpop
@onready var textLabel: Label = $dialogue_display/CanvasLayer/diagpop/dial


var dialogue = []
var curr_diag_index: int = 0
var in_area: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GlobalData.has_return_position:
		player.global_position = GlobalData.lastpos
	
	dialogue_display.visible = false
	
	for e in get_tree().get_nodes_in_group("enemy"):
		var trigger = e.get_node("Area2D")
		trigger.body_entered.connect(_on_trigger_entered.bind(e))
	
	for e in get_tree().get_nodes_in_group("npc"):
		var npc_area = e.get_node("Area2D")
		npc_area.body_entered.connect(_on_npc_area_entered.bind(e))
		npc_area.body_exited.connect(_on_npc_area_exited.bind(e))
	
	for e in get_tree().get_nodes_in_group("enemy"):
		if e.enemy_id in GlobalData.defeated_enemies:
			e.queue_free()
	curr_diag_index = -1
	
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
		
		
func _on_npc_area_entered(body: Node2D, enemy: CharacterBody2D) -> void:
	if body.is_in_group("player"):
		in_area = true
		print("NPC id is: '", enemy.id, "'")
		dialogue = load_dialogue(enemy.id) # json file must be named blueguynpc
		

func _on_npc_area_exited(body: Node2D, enemy: CharacterBody2D) -> void:
	if body.is_in_group("player"):
		in_area = false
		
func load_dialogue(npc_name: String) -> Array:
	var path = "res://Assets/npc_diag/%s.json" % npc_name
	print("Trying to open: ", path)
	print(ProjectSettings.globalize_path("res://Assets/npc_diag/blueguynpc.json"))
	var file = FileAccess.open(path, FileAccess.READ)
	print("File exists check: ", FileAccess.file_exists(path))
	if file == null:
		push_error("Could not open dialogue file for %s" % npc_name)
		return []
	var data = JSON.parse_string(file.get_as_text())
	if data == null:
		push_error("Invalid JSON in dialogue file for %s" % npc_name)
		return []
	var line = JSON.parse_string(file.get_as_text())
	return data

func _input(event: InputEvent) -> void:
	if not in_area:
		return
	if event is InputEventKey:
		if event.physical_keycode == KEY_E and in_area:  # single press
				dialogue_display.visible = true
	
	if event.is_action_pressed("ui_accept") and dialogue_display.visible == true and in_area:
		next_line()
		
		
func next_line() ->void:
	curr_diag_index += 1
	if curr_diag_index >= len(dialogue):
		dialogue_display.visible = false
		return
		
	$textLabel.text = dialogue[curr_diag_index]
	

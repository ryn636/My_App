extends Node2D




@export_file("*.json") var d_file
@onready var dialogue_display: Control = $dialogue_display/CanvasLayer/diagpop
@onready var textLabel: Label = $dialogue_display/CanvasLayer/diagpop/dial


@onready var player: CharacterBody2D = $Player


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
		dialogue = load_dialogue(enemy.id) # json file must be named blueguynpc
		

func _on_npc_area_exited(body: Node2D, enemy: CharacterBody2D) -> void:
	if body.is_in_group("player"):
		in_area = false
		dialogue_display.visible = false
		
func load_dialogue(npc_name: String) -> Array:
	var path = "res://npc_diag/%s.json" % npc_name
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open dialogue file for %s" % npc_name)
		return []
	var data = JSON.parse_string(file.get_as_text())
	if data == null:
		push_error("Invalid JSON in dialogue file for %s" % npc_name)
		return []
	file.close()
	return data["dialogue"]

func _input(event: InputEvent) -> void:
	if not in_area:
		return
	if event is InputEventKey and in_area:
		if event.physical_keycode == KEY_E and not event.is_echo():  # single press
			dialogue_display.visible = true
			curr_diag_index = -1 
			next_line()
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if dialogue_display.visible:
				next_line()
		
		
func next_line() ->void:
	curr_diag_index += 1
	if curr_diag_index >= len(dialogue):
		dialogue_display.visible = false
		return
		
	textLabel.text = dialogue[curr_diag_index]
		
	

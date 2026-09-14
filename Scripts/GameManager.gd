extends Node2D


var math_problems: Array[Dictionary] = []

var mathIndex: int

@onready var trigger_area: Area2D = $blueguy/Area2D

@onready var button: Button = $popup/CanvasLayer/pop/enter
@onready var pop: Control = $popup/CanvasLayer/pop
@onready var blueguy: CharacterBody2D = $blueguy
@onready var player: CharacterBody2D = $Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trigger_area.body_entered.connect(_on_trigger_entered)
	button.pressed.connect(_on_enter_pressed)
	pop.visible = false

func _on_enter_pressed() -> void:
	_answer(mathIndex, math_problems, GlobalData.entry)
	#show right answer
	#blueguy.set_physics_process(true)
	#player.set_physics_process(true)
	pop.visible = false
	

func _on_trigger_entered(body: Node2D) -> void:
	
	if body.is_in_group("player"):
		load_problems("res://Assets/math/math_problems.csv")
		blueguy.set_physics_process(false)
		player.set_physics_process(false)
		$popup/CanvasLayer/pop/ansbox.text = ""
		#change to unload everything but script main scene for better performance
		get_tree().change_scene_to_file("res://Scenes/fight.tscn")
		mathIndex = randi_range(0, 29)
		show_problem(mathIndex, math_problems)
		
		
	

func load_problems(path: String) -> void: 
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open %s" % path)
		return
	
	var headers = file.get_csv_line()  # ["id", "a", "op", "b", "answer", "difficulty"]

	while not file.eof_reached():
		var row = file.get_csv_line()
		if row.size() < headers.size():
			continue  # skip trailing blank line
		var entry = {}
		for i in range(headers.size()):
			entry[headers[i]] = row[i]
		math_problems.append({
			"id": int(entry["id"]),
			"a": int(entry["a"]),
			"op": entry["op"],
			"b": int(entry["b"]),
			"answer": int(entry["answer"]),
			"difficulty": int(entry["difficulty"]),
		})

	file.close()
	
func show_problem(index: int, prob: Array[Dictionary]) -> void:
	var p = prob[index]
	$popup/CanvasLayer/pop/Label.text = "%d %s %d = ?" % [p.a, p.op, p.b]
	
func get_by_difficulty(level: int, arr: Array[Dictionary]) -> Array[Dictionary]:
	var probs: Array[Dictionary] = []
	for p in arr:
		if p.difficulty == level:
			probs.append(p)
	return probs
	
func _answer(index: int, prob: Array[Dictionary], ans: int)  -> bool:
	if prob[index].answer == ans:
		print("gj")
		return true
	else:
		print("u suck")
		GlobalData.lives -= GlobalData.lives
		return false





func _on_tree_exited() -> void:
	GlobalData.fighting = true
	



func _on_tree_entered() -> void:
	if GlobalData.fighting == true:
		GlobalData.fighting = false

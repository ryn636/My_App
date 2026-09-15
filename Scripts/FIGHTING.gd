extends Node2D

@onready var player: CharacterBody2D = $CharacterBody2D
@onready var anim: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D
@onready var camera: Camera2D = $CharacterBody2D/Camera2D
@onready var enemy_spawn_point: Marker2D = $Marker2D

@onready var pop: Control = $popup/CanvasLayer/pop
@onready var button: Button = $popup/CanvasLayer/pop/enter

var math_problems: Array[Dictionary] = []

var mathIndex: int

var problemtype: int
var action: String = ""

func _ready() -> void:
	
	pop.visible = false
	player.set_physics_process(false)
	camera.enabled = false
	
	var data = GlobalData.current_enemy_data
	spawn_enemy(data.fight_scene)
	
	anim.play("idle")
	button.pressed.connect(_on_enter_pressed)


func load_problems(path: String) -> void: # load array
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

func show_problem(index: int, prob: Array[Dictionary]) -> void: # update label
	var p = prob[index]
	$popup/CanvasLayer/pop/Label.text = "%d %s %d = ?" % [p.a, p.op, p.b]


func spawn_enemy(enemy_scene: PackedScene) -> void:
	if enemy_scene == null:
		push_error("No fight_scene set on the enemy that triggered this fight")
		return
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.position = enemy_spawn_point.position
	add_child(enemy_instance)

func _answer(index: int, prob: Array[Dictionary], ans: int)  -> void: # check answer and update lives
	if action == "attack":
		if prob[index].answer == ans:
			print("gj")
			pop.visible = false
			get_tree().change_scene_to_file("res://Scenes/World.tscn")
		else:
			GlobalData.lives = GlobalData.lives - 1
			pop.visible = false
			print(GlobalData.lives)
			if GlobalData.lives <= 0:
				print("game over")
				get_tree().quit()
	elif action == "heal":
		if prob[index].answer == ans:
			print("gj")
			GlobalData.lives = GlobalData.lives + 1
			print(GlobalData.lives)
			pop.visible = false
		else:
			pop.visible = false

func _on_enter_pressed() -> void: #submit
	_answer(mathIndex, math_problems, GlobalData.entry)


func _on_heal_pressed() -> void: # heal
	action = "heal"
	$popup/CanvasLayer/pop/ansbox.text = ""
	if GlobalData.lives >= 3:
		return
	problemtype = randi_range(1,1)
	if problemtype == 1:
		load_problems("res://Assets/math/math_problems.csv")
		mathIndex = randi_range(0, 29)
		show_problem(mathIndex, math_problems)
		pop.visible = true
		
func _on_button_pressed() -> void: # attack
	action = "attack"
	$popup/CanvasLayer/pop/ansbox.text = ""
	problemtype = randi_range(1,1)
	if problemtype == 1:
		load_problems("res://Assets/math/math_problems.csv")
		mathIndex = randi_range(0, 29)
		show_problem(mathIndex, math_problems)
		pop.visible = true

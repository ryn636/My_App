extends Node2D


var math_problems: Array[Dictionary] = []

var mathIndex: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_open_pressed() -> void:
	load_problems("res://Assets/math/math_problems.csv")
	$popup/CanvasLayer/pop.visible = true
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
	

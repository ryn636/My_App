extends Area2D

const DIALOGUE_PATH = "res://dialogue/%s.txt"
var line: Array[String]

@onready var diagpop: Control = $dialogue/CanvasLayer/diagpop

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	diagpop.visible = false
	for e in get_tree().get_nodes_in_group("npc"):
		var trigger = e.get_node("Area2D")
		trigger.body_entered.connect(_on_trigger_entered.bind(e))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_dialouge(npc: String) -> Array:
	var path = DIALOGUE_PATH % npc
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open %s" % path)
		return []
	
	var lines = []
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line != "":
			lines = line.split("|")
	file.close()
	return lines
	
func _on_trigger_entered(body: Node2D, npc: CharacterBody2D) -> void:
	if body.is_in_group("player"):
		load_dialouge(npc.id)
		if Input.is_action_just_pressed("interact"):  # single press
			diagpop.visible = true

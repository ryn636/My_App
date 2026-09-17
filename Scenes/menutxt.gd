extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$author.text = "[wave amp=10 freq=4]By: Ryan Tran[/wave]"
	$title.text = "[wave amp=100 freq=3][rainbow freq = 0.2 sat=0.8 val = 0.8]Super Cool Project[/rainbow]"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_stop_pressed() -> void:
	get_tree().quit()
	


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/World.tscn")

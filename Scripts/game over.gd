extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Control/over.text = "[wave amp=20 freq=1]You Died[/wave]"



func _on_quit_pressed() -> void:
	#get_tree().quit()
	GlobalData.lives = 8
	GlobalData.lastpos = GlobalData.checkpoint
	get_tree().change_scene_to_file("res://Scenes/World.scn")

extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Control/over.text = "[wave amp=20 freq=1]Game Over[/wave]"


func _on_button_pressed() -> void:
	get_tree().quit()
	

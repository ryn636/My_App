extends Control

@onready var ans: Label = $ans

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


func _unhandled_key_input(event: InputEvent) -> void:
	if visible:
		if event is InputEventKey and event.pressed:
			if event.keycode == KEY_BACKSPACE:
				ans.text = ans.text.substr(0, ans.text.length() - 1)
				GlobalData.spelling_entry = ans.text
			elif event.keycode >= KEY_A and event.keycode <= KEY_Z:
				var letter := char(event.unicode)
				if letter.strip_edges() != "":
					ans.text += letter
					GlobalData.spelling_entry = ans.text


func _on_texture_button_pressed() -> void:
	if $AudioStreamPlayer.playing:
		return
	else:
		$AudioStreamPlayer.play()

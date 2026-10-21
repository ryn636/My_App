extends Control

@onready var ans: Label = $ans
@onready var one: AudioStreamPlayer = $"../../audio/cat"
@onready var two: AudioStreamPlayer = $"../../audio/beautiful"
@onready var three: AudioStreamPlayer = $"../../audio/jump"
@onready var four: AudioStreamPlayer = $"../../audio/forest"
@onready var five: AudioStreamPlayer = $"../../audio/run"



var curraudio: AudioStreamPlayer

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

func changeAudio(numb: int) -> void:
	if numb == 0:
		curraudio = one
	elif numb == 1:
		curraudio = two
	elif numb == 2:
		curraudio = three
	elif numb == 3:
		curraudio = four	
	elif numb == 4:
		curraudio = five

func _on_texture_button_pressed() -> void:
	if curraudio.playing:
		return
	else:
		curraudio.play()

extends Control

@onready var ansbox: Label = $ansbox



func _ready() -> void:
	visible = false



func _on_button_1_pressed() -> void:
	if ansbox.text.length() >= 10:
		return
	ansbox.text = ansbox.text + "1"
	GlobalData.entry = int(ansbox.text)

func _on_button_2_pressed() -> void:
	if ansbox.text.length() >= 10:
		return
	ansbox.text = ansbox.text + "2"
	GlobalData.entry = int(ansbox.text)

func _on_button_3_pressed() -> void:
	if ansbox.text.length() >= 10:
		return
	ansbox.text = ansbox.text + "3"
	GlobalData.entry = int(ansbox.text)

func _on_button_4_pressed() -> void:
	if ansbox.text.length() >= 10:
		return
	ansbox.text = ansbox.text + "4"
	GlobalData.entry = int(ansbox.text)

func _on_button_5_pressed() -> void:
	if ansbox.text.length() >= 10:
		return
	ansbox.text = ansbox.text + "5"
	GlobalData.entry = int(ansbox.text)

func _on_button_6_pressed() -> void:
	if ansbox.text.length() >= 10:
		return
	ansbox.text = ansbox.text + "6"
	GlobalData.entry = int(ansbox.text)

func _on_button_7_pressed() -> void:
	if ansbox.text.length() >= 10:
		return
	ansbox.text = ansbox.text + "7"
	GlobalData.entry = int(ansbox.text)
func _on_button_8_pressed() -> void:
	if ansbox.text.length() >= 10:
		return
	ansbox.text = ansbox.text + "8"
	GlobalData.entry = int(ansbox.text)

func _on_button_9_pressed() -> void:
	if ansbox.text.length() >= 10:
		return
	ansbox.text = ansbox.text + "9"
	GlobalData.entry = int(ansbox.text)

func _on_button_0_pressed() -> void:
	if ansbox.text.length() == 0:
		return
	elif ansbox.text.length() >= 10:
		return
	ansbox.text = ansbox.text + "0"
	GlobalData.entry = int(ansbox.text)

func _on_buttonx_pressed() -> void:
	ansbox.text = ansbox.text.substr(0, ansbox.text.length()-1)
	GlobalData.entry = int(ansbox.text)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_0 and event.keycode <= KEY_9:
			var number = event.keycode - KEY_0
			if ansbox.text.length() < 10:
				ansbox.text += str(number)
				GlobalData.entry = int(ansbox.text)
		elif event.keycode == KEY_BACKSPACE:
			if ansbox.text.length() > 0:
				ansbox.text = ansbox.text.left(ansbox.text.length() - 1)
			GlobalData.entry = int(ansbox.text) if ansbox.text != "" else 0

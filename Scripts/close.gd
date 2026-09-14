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

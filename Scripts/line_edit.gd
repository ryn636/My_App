extends LineEdit




func _on_text_submitted(new_text: String) -> void:
	GlobalData.player_name = new_text

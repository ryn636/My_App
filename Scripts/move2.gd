extends CharacterBody2D




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var direction = Vector2(
	Input.get_axis("move_left", "move_right"),
	Input.get_axis("move_up", "move_down")
).normalized()
	

	
	if direction:	
		if direction.x > 0:
			$AnimatedSprite2D.flip_h = false
		elif direction.x < 0:
			$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("run")
		velocity = direction * GlobalData.player_speed
	else:
		velocity.x = move_toward(velocity.x, 0, GlobalData.player_speed)
		velocity.y = move_toward(velocity.y, 0, GlobalData.player_speed)
		$AnimatedSprite2D.play("idle")

	move_and_slide()

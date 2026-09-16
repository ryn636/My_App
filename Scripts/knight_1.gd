extends CharacterBody2D


#@export var enemy_id: String = "knight1"

var hp: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GlobalData.is_anim == true:
		$AnimatedSprite2D.play("take_damage")



func _on_animated_sprite_2d_animation_finished() -> void:
	$AnimatedSprite2D.play("idle")

extends Node2D

@export var player: CharacterBody2D
@export var speed: float = 200

@onready var ray_cast_2d: RayCast2D = $CharacterBody2D/Sprite2D/RayCast2D
@onready var timer: Timer = $Timer
@onready var animation: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D
@onready var enemy: CharacterBody2D = $CharacterBody2D

var direction: Vector2 = Vector2.RIGHT


enum States {
	IDLE,
	CHASE
}

var curr_state = States.IDLE

func _ready() -> void:
	

func _physics_process(delta: float) -> void:
	look_for_player()
	change_direction()
	wander(delta)

func look_for_player() -> void:
	if ray_cast_2d.is_colliding():
		var collider = ray_cast_2d.get_collider()
		if collider == player:
			chase_player()
		elif curr_state == States.CHASE:
			stop_chase()
	elif curr_state == States.CHASE:
		stop_chase()

func chase_player() -> void:
	timer.stop()
	curr_state = States.CHASE

func stop_chase() -> void:
	if timer.time_left <= 0:
		timer.start()

func wander(delta: float) -> void:
	animation.play("run")
	var target_speed = speed if curr_state == States.WANDER else chase_speed
	enemy.velocity = enemy.velocity.move_toward(direction * target_speed, acceleration * delta)
	enemy.move_and_slide()

func face_direction(dir: Vector2) -> void:
	if dir.x > 0:
		animation.flip_h = false
		ray_cast_2d.target_position = Vector2(125, 0)
	elif dir.x < 0:
		animation.flip_h = true
		ray_cast_2d.target_position = Vector2(-125, 0)

func change_direction() -> void:
	if curr_state == States.WANDER:
		if direction.x > 0 and enemy.position.x >= max_x_bound:
			direction = Vector2(-1, 0)
			face_direction(direction)
		elif direction.x < 0 and enemy.position.x <= min_x_bound:
			direction = Vector2(1, 0)
			face_direction(direction)
	else:
		direction = Vector2(sign(player.position.x - enemy.position.x), 0)
		face_direction(direction)

func _on_timer_timeout() -> void:
	curr_state = States.WANDER

extends Node2D



@export var player: CharacterBody2D
@export var speed: float = 200
@export var chase_speed: float = 450

@onready var ray_cast_2d: RayCast2D = $CharacterBody2D/Sprite2D/RayCast2D
@onready var timer: Timer = $Timer
@onready var animation: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D
@onready var enemy: CharacterBody2D = $CharacterBody2D

var direction: Vector2 = Vector2.RIGHT
#wandering left - right 125
var right_bounds: Vector2
var left_bounds: Vector2
var acceleration: float = 100

enum States{
	Wander, 
	Chase
}

var currState = States.Wander

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	right_bounds = enemy.position + Vector2(-125, 0)
	left_bounds = enemy.position + Vector2(125, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	wander(delta)
	change_direction()
	look_for_player()

func look_for_player() -> void:
	if ray_cast_2d.is_colliding():
		var collider = ray_cast_2d.get_collider()
		if collider == player:
			chase_player()
		elif currState == States.Chase:
			stop_chase()
	elif currState == States.Chase:
			stop_chase()
		
func chase_player() -> void:	
	timer.stop()
	currState = States.Chase
	
	
func stop_chase() -> void:
	if timer.time_left <= 0:
		timer.start()
	
func wander(delta: float) -> void:
	if currState == States.Wander:
		enemy.velocity = enemy.velocity.move_toward(direction * speed, acceleration * delta )
	else:
		enemy.velocity = enemy.velocity.move_toward(direction * chase_speed, acceleration * delta )
		
	enemy.move_and_slide()
	
func change_direction() -> void:
	if currState == States.Wander:
		if animation.flip_h:
			if enemy.position.x <= right_bounds.x:
				direction = Vector2(1,0)
			else:
				animation.flip_h = true
				ray_cast_2d.target_position = Vector2(-125, 0)
		else:
			if enemy.position.x >= left_bounds.x:
				direction = Vector2(-1,0)
			else:
				animation.flip_h = false
				ray_cast_2d.target_position = Vector2(125, 0)
				
	else:
		direction = (player.position - enemy.position).normalized()
		direction = sign(direction)
		if(direction.x == 1):
			animation.flip_h = false
			ray_cast_2d.target_position = Vector2(125, 0)
		else:
			animation.flip_h = true
			ray_cast_2d.target_position = Vector2(-125, 0)




func _on_timer_timeout() -> void:
	currState = States.Wander

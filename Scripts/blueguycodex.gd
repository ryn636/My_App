extends CharacterBody2D
## Top-down wandering and timed pursuit. Attach to the blueguy scene root.

@export var player: CharacterBody2D
@export var wander_radius: float = 256.0
@export var detection_radius: float = 276.0
@export var wander_speed: float = 50.0
@export var chase_speed: float = 200.0
@export var acceleration: float = 50.0
@export var chase_duration: float = 6.0
@export var avoidance_distance: float = 48.0

@onready var animation: AnimatedSprite2D = $knight
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var ray_pivot: Sprite2D = $Sprite2D
@onready var ray_cast: RayCast2D = $Sprite2D/RayCast2D

enum State { WANDER, CHASE }
var state: State = State.WANDER
var spawn_position: Vector2
var wander_target: Vector2
var returning_home: bool = false
var chase_time_left: float = 0.0
var current_speed: float = 200.0
var target_time_left: float = 0.0
var last_direction: Vector2 = Vector2.RIGHT
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	spawn_position = global_position
	current_speed = wander_speed
	rng.randomize()
	# The ray is a grandchild, so explicitly exclude this body.
	ray_cast.add_exception(self)
	ray_cast.enabled = true
	ray_cast.collide_with_bodies = true
	ray_cast.collide_with_areas = false
	_find_player()
	_pick_wander_target()


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		_find_player()
	if state == State.CHASE:
		chase_time_left -= delta
		if chase_time_left <= 0.0 or not is_instance_valid(player):
			state = State.WANDER
			returning_home = true
	elif not returning_home and _can_see_player():
		state = State.CHASE
		chase_time_left = chase_duration

	var target := spawn_position
	if state == State.CHASE:
		target = player.global_position
		current_speed = move_toward(current_speed, chase_speed, acceleration * delta)
	else:
		current_speed = wander_speed
		if returning_home and global_position.distance_to(spawn_position) <= 4.0:
			returning_home = false
			_pick_wander_target()
		if not returning_home:
			target_time_left -= delta
			if global_position.distance_to(wander_target) <= 8.0 or target_time_left <= 0.0:
				_pick_wander_target()
			target = wander_target

	var offset := target - global_position
	var direction := _avoid_obstacles(offset.normalized(), delta)
	# Limit the final step so that returning home cannot overshoot.
	velocity = direction * minf(current_speed, offset.length() / maxf(delta, 0.0001))
	move_and_slide()
	var actual_velocity := get_real_velocity()
	if absf(actual_velocity.x) > 0.1:
		animation.flip_h = actual_velocity.x < 0.0
	animation.play("run" if actual_velocity.length_squared() > 1.0 else "idle")
	if actual_velocity.length_squared() > 1.0:
		last_direction = actual_velocity.normalized()


func _find_player() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	# Supports the existing World scene without changing its player script.
	if player == null and get_tree().current_scene != null:
		player = get_tree().current_scene.get_node_or_null("Player") as CharacterBody2D


func _can_see_player() -> bool:
	if not is_instance_valid(player):
		return false
	if global_position.distance_squared_to(player.global_position) > detection_radius * detection_radius:
		return false
	ray_cast.collision_mask = collision_mask | player.collision_layer
	ray_cast.target_position = ray_cast.to_local(player.global_position)
	ray_cast.force_raycast_update()
	return ray_cast.is_colliding() and ray_cast.get_collider() == player


func _pick_wander_target() -> void:
	# sqrt gives an even distribution of destinations inside the spawn circle.
	var angle := rng.randf_range(-PI, PI)
	wander_target = spawn_position + Vector2.from_angle(angle) * sqrt(rng.randf()) * wander_radius
	target_time_left = rng.randf_range(2.0, 4.0)


func _avoid_obstacles(desired: Vector2, delta: float) -> Vector2:
	if desired.is_zero_approx():
		return Vector2.ZERO
	var best_direction := Vector2.ZERO
	var best_score := -INF
	var step := current_speed * delta
	var probe_distance := maxf(avoidance_distance, step + 4.0)
	# Sweep the actual collision shape, rather than a thin obstacle ray.
	# Score alternate headings to slide around nearby collision objects.
	for index in range(16):
		var candidate := desired.rotated(TAU * float(index) / 16.0)
		if state == State.WANDER and not returning_home:
			var next_position := global_position + candidate * step
			if next_position.distance_to(spawn_position) > wander_radius:
				continue
		if test_move(global_transform, candidate * probe_distance):
			continue
		var score := candidate.dot(desired) + 0.25 * candidate.dot(last_direction)
		if score > best_score:
			best_score = score
			best_direction = candidate
	return best_direction

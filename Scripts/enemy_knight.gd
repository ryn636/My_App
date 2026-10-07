extends CharacterBody2D
## Shared basic enemy controller: idle -> alert -> pursuit -> return home.
## Uses world collisions for sight and pathfinding; no navigation bake required.

@export_group("Nodes")
## Assign the enemy's main sprite, not its alert icon.
@export var enemy_sprite: AnimatedSprite2D
## Optional. Leave unassigned to chase immediately without an alert animation.
@export var alert_player: AnimationPlayer
@export var sight: RayCast2D
@export var body_shape: CollisionShape2D
@export var player: CharacterBody2D

@export_group("Animations")
@export var idle_animation: StringName = &"idle"
@export var move_animation: StringName = &"run"
## Use a non-looping AnimationPlayer clip, or leave empty to skip the alert.
@export var alert_animation: StringName = &"alert2"
## Direction the artwork faces when Flip H is disabled.
@export var sprite_faces_right: bool = true

@export_group("Movement")
@export var detection_radius: float = 276.0
@export var chase_speed: float = 200.0
@export var return_speed: float = 100.0
@export var chase_duration: float = 5.0

@export_group("Pathfinding")
@export var path_cell_size: float = 24.0
@export var path_search_margin: float = 384.0
@export var repath_interval: float = 0.4

@export_group("Battle")
@export var enemy_id: String = ""
@export var fight_scene: PackedScene
@export var enemy_hp: int = 3


enum State { IDLE, ALERT, CHASE, RETURN_HOME }
var state: State = State.IDLE
var home_position: Vector2
var last_seen_position: Vector2
var chase_time_left: float = 0.0
var _path := PackedVector2Array()
var _repath_left: float = 0.0


func _ready() -> void:
	if enemy_sprite == null or sight == null or body_shape == null or body_shape.shape == null:
		push_error("%s: assign Enemy Sprite, Sight, and Body Shape (with a shape) in the Inspector." % name)
		set_physics_process(false)
		return
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	home_position = global_position
	_play_sprite_animation(idle_animation)
	sight.add_exception(self)
	sight.enabled = true
	sight.collide_with_bodies = true
	sight.collide_with_areas = false
	if alert_player != null:
		alert_player.animation_finished.connect(_on_alert_finished)
	_find_player()


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		_find_player()
	_repath_left -= delta
	velocity = Vector2.ZERO
	match state:
		State.IDLE:
			if _can_see_player():
				_begin_alert()
		State.ALERT:
			if _can_see_player(false):
				last_seen_position = player.global_position
		State.CHASE:
			chase_time_left -= delta
			if chase_time_left <= 0.0 or not is_instance_valid(player):
				_begin_return()
			else:
				if _can_see_player(false):
					last_seen_position = player.global_position
				_move_toward_target(last_seen_position, chase_speed, delta)
		State.RETURN_HOME:
			if global_position.distance_to(home_position) <= 1.0:
				state = State.IDLE
				_path.clear()
			else:
				_move_toward_target(home_position, return_speed, delta)
	move_and_slide()
	var movement := get_real_velocity()
	if absf(movement.x) > 0.1:
		enemy_sprite.flip_h = (movement.x < 0.0) == sprite_faces_right
	_play_sprite_animation(move_animation if movement.length_squared() > 1.0 else idle_animation)


func _play_sprite_animation(animation_name: StringName) -> void:
	if enemy_sprite.sprite_frames != null and enemy_sprite.sprite_frames.has_animation(animation_name):
		enemy_sprite.play(animation_name)


func _find_player() -> void:
	if is_instance_valid(player):
		return
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player == null and get_tree().current_scene != null:
		player = get_tree().current_scene.get_node_or_null("Player") as CharacterBody2D


func _can_see_player(check_radius: bool = true) -> bool:
	if not is_instance_valid(player):
		return false
	if check_radius and global_position.distance_squared_to(player.global_position) > detection_radius * detection_radius:
		return false
	# Cast from the feet/collision center, including both walls and the player.
	sight.global_position = body_shape.global_position
	sight.collision_mask = collision_mask | player.collision_layer
	sight.target_position = sight.to_local(player.global_position)
	sight.force_raycast_update()
	return sight.is_colliding() and sight.get_collider() == player


func _begin_alert() -> void:
	state = State.ALERT
	last_seen_position = player.global_position
	if alert_player != null and alert_animation != &"" and alert_player.has_animation(alert_animation):
		if alert_player.get_animation(alert_animation).loop_mode == Animation.LOOP_NONE:
			alert_player.play(alert_animation)
			return
	# Missing or looping alert clips must not leave the enemy stuck in ALERT.
	_begin_chase()


func _on_alert_finished(animation_name: StringName) -> void:
	if animation_name != alert_animation or state != State.ALERT:
		return
	_begin_chase()


func _begin_chase() -> void:
	if not is_instance_valid(player):
		_begin_return()
		return
	state = State.CHASE
	chase_time_left = chase_duration
	_path.clear()
	_repath_left = 0.0


func _begin_return() -> void:
	state = State.RETURN_HOME
	_path.clear()
	_repath_left = 0.0


func _move_toward_target(target: Vector2, speed: float, delta: float) -> void:
	var destination := target
	# Sweep the entire body so an open sight ray cannot lead us into a wall.
	if test_move(global_transform, target - global_position):
		if _repath_left <= 0.0:
			_build_path(target)
			_repath_left = maxf(repath_interval, 0.1)
		while not _path.is_empty() and global_position.distance_to(_path[0]) <= 1.0:
			_path.remove_at(0)
		if _path.is_empty():
			return
		# Skip visible waypoints to smooth the grid path.
		for index in range(_path.size() - 1, -1, -1):
			if not test_move(global_transform, _path[index] - global_position):
				for skipped in range(index):
					_path.remove_at(0)
				break
		destination = _path[0]
	else:
		_path.clear()
	var offset := destination - global_position
	velocity = offset.normalized() * minf(maxf(speed, 0.0), offset.length() / maxf(delta, 0.0001))
	if test_move(global_transform, velocity * delta):
		velocity = Vector2.ZERO
		_repath_left = 0.0


func _build_path(target: Vector2) -> void:
	_path.clear()
	var cell := maxf(path_cell_size, 8.0)
	var padding := maxf(path_search_margin, cell * 2.0)
	var lower := global_position.min(target) - Vector2.ONE * padding
	var upper := global_position.max(target) + Vector2.ONE * padding
	# Bound query cost for unusually distant targets.
	var extent := upper - lower
	cell = maxf(cell, maxf(extent.x, extent.y) / 100.0)
	var start_id := Vector2i.ZERO
	var end_id := Vector2i(((target - global_position) / cell).round())
	var min_id := Vector2i(((lower - global_position) / cell).floor())
	var max_id := Vector2i(((upper - global_position) / cell).ceil())
	var grid := AStarGrid2D.new()
	grid.region = Rect2i(min_id, max_id - min_id + Vector2i.ONE)
	grid.cell_size = Vector2.ONE * cell
	grid.offset = global_position
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.update()

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = body_shape.shape
	query.collision_mask = collision_mask
	query.collide_with_areas = false
	var exclusions: Array[RID] = [get_rid()]
	if is_instance_valid(player):
		exclusions.append(player.get_rid())
	query.exclude = exclusions
	# Extra clearance protects the space between neighboring grid samples.
	query.margin = cell * 0.5
	var space := get_world_2d().direct_space_state
	for y in range(grid.region.position.y, grid.region.end.y):
		for x in range(grid.region.position.x, grid.region.end.x):
			var point := Vector2i(x, y)
			var shape_transform := body_shape.global_transform
			shape_transform.origin += grid.get_point_position(point) - global_position
			query.transform = shape_transform
			grid.set_point_solid(point, not space.intersect_shape(query, 1).is_empty())
	grid.set_point_solid(start_id, false)
	_path = grid.get_point_path(start_id, end_id, true)
	if not _path.is_empty():
		_path.remove_at(0)
		

extends CharacterBody2D
## Idle -> alert -> four-second pursuit -> return to the spawn position.
## Uses world collisions for sight and pathfinding; no navigation bake required.

@export var player: CharacterBody2D
@export var detection_radius: float = 276.0
@export var chase_speed: float = 200.0
@export var return_speed: float = 100.0
@export var chase_duration: float = 5.0
@export var path_cell_size: float = 24.0
@export var path_search_margin: float = 384.0
@export var repath_interval: float = 0.4

@onready var knight: AnimatedSprite2D = $knight
@onready var alert_sprite: AnimatedSprite2D = get_node("knight/!")
@onready var alert_player: AnimationPlayer = $knight/AnimationPlayer
@onready var sight: RayCast2D = $Sprite2D/RayCast2D
@onready var body_shape: CollisionShape2D = $CollisionShape2D



enum State { IDLE, ALERT, CHASE, RETURN_HOME }
var state: State = State.IDLE
var home_position: Vector2
var last_seen_position: Vector2
var chase_time_left: float = 0.0
var _path := PackedVector2Array()
var _repath_left: float = 0.0


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	home_position = global_position
	alert_sprite.hide()
	knight.offset = Vector2.ZERO
	knight.play(&"idle")
	sight.add_exception(self)
	sight.enabled = true
	sight.collide_with_bodies = true
	sight.collide_with_areas = false
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
		knight.flip_h = movement.x < 0.0
	knight.play(&"run" if movement.length_squared() > 1.0 else &"idle")


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
	alert_sprite.show()
	alert_sprite.stop()
	alert_sprite.play(&"uhoh")
	alert_player.play(&"alert")


func _on_alert_finished(animation_name: StringName) -> void:
	if animation_name != &"alert" or state != State.ALERT:
		return
	# The icon stays visible for the whole AnimationPlayer clip, even if
	# its own shorter sprite animation has already finished.
	alert_sprite.hide()
	alert_sprite.stop()
	if not is_instance_valid(player):
		_begin_return()
		return
	state = State.CHASE
	chase_time_left = chase_duration
	_path.clear()
	_repath_left = 0.0


func _begin_return() -> void:
	state = State.RETURN_HOME
	alert_sprite.hide()
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
		

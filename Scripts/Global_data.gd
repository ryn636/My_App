extends Node

var player_speed: float = 550.0
var lives = 3
var entry: int = 0
var fighting: bool = false

var current_enemy_data: Dictionary = {}
var lastpos: Vector2
var has_return_position: bool = false
var defeated_enemies: Array[String] = []
var is_anim: bool = false

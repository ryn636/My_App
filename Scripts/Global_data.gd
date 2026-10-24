extends Node

var player_speed: float = 550.0
var lives: int = 8
var max_lives: int = 8
var entry: int = 0 # math
var spelling_entry: String
var fighting: bool = false
var player_name: String

var current_enemy_data: Dictionary = {}
var lastpos: Vector2
var checkpoint: Vector2
var has_return_position: bool = false
var defeated_enemies: Array[String] = []

var enemy_dmg: int

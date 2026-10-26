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
var checkpoint: Vector2 = Vector2(704.0, 3920.0)
var has_return_position: bool = false
var defeated_enemies: Array[String] = []

var enemy_dmg: int

var math_problems: Array[Dictionary] = [
	{"id": 1, "a": 15, "op": "-", "b": 7, "answer": 8, "difficulty": 1},
	{"id": 2, "a": 8, "op": "*", "b": 4, "answer": 32, "difficulty": 1},
	{"id": 3, "a": 27, "op": "/", "b": 9, "answer": 3, "difficulty": 1},
	{"id": 4, "a": 2, "op": "+", "b": 10, "answer": 12, "difficulty": 1},
	{"id": 5, "a": 10, "op": "*", "b": 7, "answer": 70, "difficulty": 1},
	{"id": 6, "a": 3, "op": "+", "b": 4, "answer": 7, "difficulty": 1},
	{"id": 7, "a": 7, "op": "-", "b": 1, "answer": 6, "difficulty": 1},
	{"id": 8, "a": 80, "op": "/", "b": 10, "answer": 8, "difficulty": 1},
	{"id": 9, "a": 6, "op": "+", "b": 9, "answer": 15, "difficulty": 1},
	{"id": 10, "a": 24, "op": "/", "b": 12, "answer": 2, "difficulty": 1},
	{"id": 11, "a": 1, "op": "*", "b": 3, "answer": 3, "difficulty": 1},
	{"id": 12, "a": 2, "op": "+", "b": 1, "answer": 3, "difficulty": 1},
	{"id": 13, "a": 27, "op": "/", "b": 3, "answer": 9, "difficulty": 1},
	{"id": 14, "a": 7, "op": "*", "b": 8, "answer": 56, "difficulty": 1},
	{"id": 15, "a": 3, "op": "-", "b": 1, "answer": 2, "difficulty": 1},
	{"id": 16, "a": 8, "op": "/", "b": 4, "answer": 2, "difficulty": 2},
	{"id": 17, "a": 11, "op": "-", "b": 7, "answer": 4, "difficulty": 2},
	{"id": 18, "a": 20, "op": "+", "b": 17, "answer": 37, "difficulty": 2},
	{"id": 19, "a": 15, "op": "-", "b": 9, "answer": 6, "difficulty": 2},
	{"id": 20, "a": 30, "op": "/", "b": 5, "answer": 6, "difficulty": 2},
	{"id": 21, "a": 63, "op": "/", "b": 9, "answer": 7, "difficulty": 2},
	{"id": 22, "a": 8, "op": "*", "b": 7, "answer": 56, "difficulty": 2},
	{"id": 23, "a": 1, "op": "*", "b": 2, "answer": 2, "difficulty": 2},
	{"id": 24, "a": 20, "op": "-", "b": 5, "answer": 15, "difficulty": 2},
	{"id": 25, "a": 18, "op": "/", "b": 2, "answer": 9, "difficulty": 2},
	{"id": 26, "a": 15, "op": "-", "b": 8, "answer": 7, "difficulty": 2},
	{"id": 27, "a": 16, "op": "-", "b": 10, "answer": 6, "difficulty": 2},
	{"id": 28, "a": 6, "op": "*", "b": 10, "answer": 60, "difficulty": 2},
	{"id": 29, "a": 4, "op": "*", "b": 2, "answer": 8, "difficulty": 2},
	{"id": 30, "a": 10, "op": "-", "b": 7, "answer": 3, "difficulty": 2},
	{"id": 31, "a": 18, "op": "/", "b": 6, "answer": 3, "difficulty": 3},
	{"id": 32, "a": 43, "op": "+", "b": 25, "answer": 68, "difficulty": 3},
	{"id": 33, "a": 36, "op": "/", "b": 3, "answer": 12, "difficulty": 3},
	{"id": 34, "a": 32, "op": "+", "b": 41, "answer": 73, "difficulty": 3},
	{"id": 35, "a": 44, "op": "/", "b": 11, "answer": 4, "difficulty": 3},
	{"id": 36, "a": 45, "op": "-", "b": 20, "answer": 25, "difficulty": 3},
	{"id": 37, "a": 38, "op": "+", "b": 36, "answer": 74, "difficulty": 3},
	{"id": 38, "a": 5, "op": "/", "b": 1, "answer": 5, "difficulty": 3},
	{"id": 39, "a": 26, "op": "+", "b": 28, "answer": 54, "difficulty": 3},
	{"id": 40, "a": 36, "op": "+", "b": 25, "answer": 61, "difficulty": 3},
	{"id": 41, "a": 35, "op": "-", "b": 14, "answer": 21, "difficulty": 3},
	{"id": 42, "a": 11, "op": "*", "b": 3, "answer": 33, "difficulty": 3},
	{"id": 43, "a": 40, "op": "-", "b": 13, "answer": 27, "difficulty": 3},
	{"id": 44, "a": 3, "op": "*", "b": 11, "answer": 33, "difficulty": 3},
	{"id": 45, "a": 4, "op": "/", "b": 1, "answer": 4, "difficulty": 3},
]

var spelling_probs: Array[Dictionary] = [
	{"id": 1, "word": "cat", "answer": "cat", "difficulty": "easy"},
	{"id": 2, "word": "beautiful", "answer": "beautiful", "difficulty": "easy"},
	{"id": 3, "word": "jump", "answer": "jump", "difficulty": "easy"},
	{"id": 4, "word": "forest", "answer": "forest", "difficulty": "easy"},
	{"id": 5, "word": "run", "answer": "run", "difficulty": "easy"},
]

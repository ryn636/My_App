extends Node2D

@onready var player: CharacterBody2D = $player
@onready var anim: AnimatedSprite2D = $player/AnimatedSprite2D
@onready var camera: Camera2D = $player/Camera2D
@onready var enemy_spawn_point: Marker2D = $Marker2D

@onready var pop: Control = $popup/CanvasLayer/pop
@onready var spelling_popup: Control = $"spelling_popup/CanvasLayer/spellingpop"


@onready var button: Button = $popup/CanvasLayer/pop/enter
@onready var grid_container: GridContainer = $popup/CanvasLayer/pop/GridContainer
@onready var healthbar: ProgressBar = $healthbar
@onready var timer: Timer = $Timer
@onready var combometer: ProgressBar = $CanvasLayer/combometer

@onready var enter: TextureButton = $spelling_popup/CanvasLayer/spellingpop/enter



var math_problems: Array[Dictionary] = []
var spelling_probs: Array[Dictionary] = []


var mathIndex: int
var spellIndex: int

var problemtype: int
var action: String = ""
var curr_popup: Control
var in_problem: bool = false

var enemy_instance: CharacterBody2D
var enemy_anim: AnimatedSprite2D
var enemy_health: ProgressBar

var correct: int = 0
var damageMult: int
var inCombo: bool = false

func _ready() -> void:
	# healthbar.max_value = player health
	healthbar.value = healthbar.max_value
	
	curr_popup = pop
	pop.visible = false
	spelling_popup.visible = false
	
	player.set_physics_process(false)
	camera.enabled = false
	
	combometer.visible = false
	damageMult = 1
	
	var data = GlobalData.current_enemy_data
	spawn_enemy(data.fight_scene)
	
	
	
	anim.play("idle")
	button.pressed.connect(_on_enter_button_pressed)
	enter.pressed.connect(_on_enter_spelling_button_pressed)
	anim.animation_finished.connect(_on_player_anim_finished)




func load_problems(path: String) -> void: # load array
	var file = FileAccess.open("res://Assets/math/math_problems_arithmetic.csv", FileAccess.READ)
	if file == null:
		push_error("Could not open %s" % path)
		return
	
	var headers = file.get_csv_line()  # ["id", "a", "op", "b", "answer", "difficulty"]

	while not file.eof_reached():
		var row = file.get_csv_line()
		if row.size() < headers.size():
			continue  # skip trailing blank line
		var entry = {}
		for i in range(headers.size()):
			entry[headers[i]] = row[i]
		math_problems.append({
			"id": int(entry["id"]),
			"a": int(entry["a"]),
			"op": entry["op"],
			"b": int(entry["b"]),
			"answer": int(entry["answer"]),
			"difficulty": int(entry["difficulty"]),
		})

	file.close()

func load_spelling(path: String) -> void: 
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open %s" % path)
		return
	
	var headers = file.get_csv_line()  # ["id", "word", "answer", "difficulty"]

	while not file.eof_reached():
		var row = file.get_csv_line()
		if row.size() < headers.size():
			continue  # skip trailing blank line
		var entry = {}
		for i in range(headers.size()):
			entry[headers[i]] = row[i]
		spelling_probs.append({
			"id": int(entry["id"]),
			"a": String(entry["word"]),
			"answer": String(entry["answer"]),
			"difficulty": String(entry["difficulty"]),
		})
	file.close()
	
func show_math_problem(index: int, prob: Array[Dictionary]) -> void: # update label
	var p = prob[index]
	$popup/CanvasLayer/pop/Label.text = "%d %s %d = ?" % [p.a, p.op, p.b]


func spawn_enemy(enemy_scene: PackedScene) -> void:
	if enemy_scene == null:
		push_error("No fight_scene set on the enemy that triggered this fight")
		return
	enemy_instance = enemy_scene.instantiate()
	enemy_instance.position = enemy_spawn_point.position
	add_child(enemy_instance)
	enemy_anim = enemy_instance.get_node("AnimatedSprite2D")
	enemy_health = enemy_instance.get_node("enemyheal") # all henemy healthbars have to be named enemyheal
	enemy_anim.animation_finished.connect(_on_enemy_animation_finished)
	enemy_health.max_value = GlobalData.current_enemy_data.enemy_hp
	enemy_health.value = GlobalData.current_enemy_data.enemy_hp
	
func _answer(index: int, prob: Array[Dictionary], ans: Variant)  -> void: # check answer and update lives
	in_problem = false
	if action == "attack":
		if prob[index].answer == ans: 				# success
			correct += 1
			startCombo()
			GlobalData.current_enemy_data.enemy_hp = GlobalData.current_enemy_data.enemy_hp -(1 * damageMult)
			curr_popup.visible = false
			
			enemy_health.value = GlobalData.current_enemy_data.enemy_hp
			anim.play("attack")
			play_locked_animation("enemy")
		else: 										# fail
			GlobalData.lives -= 1
			healthbar.value = GlobalData.lives
			curr_popup.visible = false
			print(GlobalData.lives)
			correct = 0
			damageMult = 1
			combometer.visible = false
			inCombo = false
			play_locked_animation("player") # parameter doesnt do jack
		
	elif action == "heal":
		if prob[index].answer == ans:				# success
			GlobalData.lives = GlobalData.lives + 1
			healthbar.value = GlobalData.lives
			curr_popup.visible = false
		else:										# fail
			curr_popup.visible = false
			GlobalData.lives = GlobalData.lives - 1
			healthbar.value = GlobalData.lives
			play_locked_animation("player")
			

func _on_enter_button_pressed() -> void: #submit
	
	if curr_popup == pop:
		if not GlobalData.entry == 0:
			$popup/CanvasLayer/pop/ansbox.text = ""
			_answer(mathIndex, math_problems, GlobalData.entry)

func _on_enter_spelling_button_pressed() -> void:
	if curr_popup == spelling_popup:
		if not GlobalData.spelling_entry == "":
			$spelling_popup/CanvasLayer/spellingpop/ans.text = ""
			_answer(spellIndex, spelling_probs, GlobalData.spelling_entry)

func _on_heal_pressed() -> void: # heal
	$heal.release_focus()
	in_problem = true
	action = "heal"
	$popup/CanvasLayer/pop/ansbox.text = ""
	if GlobalData.lives >= 3:
		return
	problemtype = randi_range(1,1)
	if problemtype == 1:
		load_problems("res://Assets/math/math_problems_mixed.csv")
		mathIndex = randi_range(0, 29)
		show_math_problem(mathIndex, math_problems)
		curr_popup.visible = true
		
func _on_button_pressed() -> void: # attack
	$attack.release_focus()
	in_problem = true
	action = "attack"
	$popup/CanvasLayer/pop/ansbox.text = ""
	problemtype = randi_range(1,2)
	if problemtype == 1:
		load_problems("res://Assets/math/math_problems.csv")
		mathIndex = randi_range(0, len(math_problems)-1)
		curr_popup = pop
		show_math_problem(mathIndex, math_problems)
		curr_popup.visible = true
	elif problemtype == 2:
		load_spelling("res://Assets/spelling/spelling_words.csv")
		spellIndex = randi_range(0, len(spelling_probs)-1)
		spellIndex = 0 # temp
		
		curr_popup = spelling_popup
		curr_popup.visible = true
		
func on_win() -> void:
	GlobalData.lives = 3
	GlobalData.defeated_enemies.append(GlobalData.current_enemy_data.enemy_id)
	get_tree().change_scene_to_file("res://Scenes/World.tscn")
	

func set_buttons_disabled(value: bool) -> void:
	for child in grid_container.get_children():
		if child is Button:
			child.disabled = value
	$attack.disabled = value
	$heal.disabled = value

func play_locked_animation(character: String) -> void: # death and damage
	set_buttons_disabled(true)
	if character == "player":
		if GlobalData.lives > 0:
			enemy_anim.play("attack")
			anim.play("take_dmg")
		elif GlobalData.lives <= 0:
			get_tree().change_scene_to_file("res://Scenes/game_over.tscn")
	else: 
		if GlobalData.current_enemy_data.enemy_hp > 0:
			anim.play("attack")
			enemy_anim.play("take_damage")
		elif GlobalData.current_enemy_data.enemy_hp <= 0:
			enemy_anim.play("death")

func _on_enemy_animation_finished() -> void:
	if GlobalData.current_enemy_data.enemy_hp > 0:
		enemy_anim.play("idle")
	else:
		on_win()
	set_buttons_disabled(false)

func _on_player_anim_finished()-> void:
	anim.play("idle")
	set_buttons_disabled(false)
	
func startCombo() ->void:
	inCombo = true
	timer.wait_time = 16.0 * pow(0.75, correct - 1)
	combometer.max_value = timer.wait_time  # this should now match
	combometer.value = timer.wait_time
	timer.start()
	combometer.visible = true
	damageMult += 1
	
func _process(_delta: float) -> void:
	if inCombo == true:
		combometer.value = timer.time_left
	
func _input(event: InputEvent) -> void:
	if in_problem:
		if event.is_action_pressed("enter") and curr_popup.visible:
			if GlobalData.entry == 0:
				return
			if GlobalData.spelling_entry == "":
				return
			if curr_popup == pop and not GlobalData.entry == 0:
				$popup/CanvasLayer/pop/ansbox.text = ""
				_answer(mathIndex, math_problems, GlobalData.entry)
			elif curr_popup == spelling_popup and not GlobalData.spelling_entry == "":
				$spelling_popup/CanvasLayer/spellingpop/ans.text = ""
				_answer(spellIndex, spelling_probs, GlobalData.spelling_entry)


func _on_timer_timeout() -> void:
	correct = 0
	damageMult = 1
	combometer.visible = false
	inCombo = false

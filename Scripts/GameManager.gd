extends Node

signal level_complete()
signal time_update()
signal level_start()
signal level_loose()

var levels = [
	"res://Levels/Level1.tscn",
	"res://Levels/Level2.tscn",
	"res://Levels/Level3.tscn",
	"res://Levels/Level4.tscn",
	"res://Levels/Level5.tscn",
]

var current_level_index = 0
var level_time_est = [
	20,
	38,
	47,
	57,
	73,
]

var level_timer: Timer
var timer_active = false
var time = 0
var restarted = false
var canMove = false
var game_started = false

# Called when the node enters the scene tree for the first time.
func _ready():
	level_complete.connect(_on_level_complete)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("restart"):
		if game_started:
			restart_level()
		
	if timer_active:
		emit_time_update(delta)
	pass

func _on_level_complete():
	stop_level()
	current_level_index += 1
	if current_level_index < 5:
		load_level(current_level_index)
	else:
		game_started = false
		get_tree().change_scene_to_file("res://Levels/Final.tscn")
	pass
	
func start_game():
	game_started = true
	load_level(current_level_index)
	pass

func stop_level():
	stop_timer()
	
	self.time = 0
	timer_active = false	
	restarted = false
	canMove = false	

func stop_timer():
	if level_timer:		
		level_timer.paused = true
		level_timer.stop()			

func restart_level():
	restarted = true
	canMove = true	
	
	stop_timer()		
	load_level(current_level_index)
	start_level()
	pass
	
func start_level():	
	canMove = true
	start_timer(level_time_est[current_level_index])	
	emit_signal("level_start")
	pass	
	
func load_level(index: int):
	get_tree().change_scene_to_file(levels[index])	
	pass
	
func start_timer(time: int):		
	stop_timer()
		
	timer_active = false
	self.time = 0
	level_timer = Timer.new()
	add_child(level_timer)
	level_timer.one_shot = true
	level_timer.connect("timeout", _on_timer_end)	
		
	level_timer.start(time)
	timer_active = true
	
func _on_timer_end():
	stop_level()
	emit_signal("level_loose")	
	await get_tree().create_timer(2.0).timeout
	restart_level()
	pass

func emit_time_update(delta):
	time += delta
	time_update.emit(level_time_est[current_level_index] - time)
	pass
	

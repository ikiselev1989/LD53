extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.time_update.connect(_on_time_update)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_time_update(time):
	var formated_time = floor(time * 100) / 100
	
	var sec = floor(formated_time)
	var ms = floor((formated_time - sec) * 100)
	text = "%02d : %02d" % [sec, ms]
	pass

extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.level_start.connect(_on_level_start)
	GameManager.level_loose.connect(_on_level_loose)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_level_start():
	$StartSound.play()
	pass

func _on_level_loose():
	$LooseSound.play()
	pass

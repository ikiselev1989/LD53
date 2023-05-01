extends Control

@export_multiline var radio_text: String = ''
@export_multiline var player_text: String = ''

var step = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if GameManager.restarted:
		hide()
		GameManager.start_level()
	
	$Radio/Label.text = radio_text
	$Sergey/Label.text = player_text
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("accept"):
		if step == 0:
			step +=1
			$Radio.hide()
			$Sergey.show()
		else:
			hide()
			GameManager.start_level()
			pass		
		
	pass

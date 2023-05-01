extends CharacterBody2D

@export var lights: bool = false

const WHEEL_BASE = 32
const STEERING_ANGLE = 25
const ENGINE_POWER = 600
const FRICTION = -0.9
const DRAG = -0.001
const BRAKING = -450
const MAX_SPEED = 200
const MAX_REVERSE_SPEED = 100
const SLIP_SPEED = 400
const TRACTION_FAST = 0.1
const TRACTION_SLOW = 0.7

var acceleration = Vector2.ZERO

var steer_direction
var max_speed_multiplier = 1

func _ready():
	GameManager.level_loose.connect(_on_loose_level)
	velocity = Vector2.ZERO
	
	if lights:
		$PointLight2D.show()
	else:
		$PointLight2D.hide()
	
func _physics_process(delta):
	if !GameManager.canMove:
		return
	
	get_input()
	apply_friction()
	calculate_steering(delta)
	velocity += acceleration * delta
	move_and_slide()
	
	print(get_slide_collision_count())


func apply_friction():
	if velocity.length() < 5:
		velocity = Vector2.ZERO
		$AnimatedSprite2D.play("idle")
		$IdleSound.stop()
		$MoveSound.stop()
	else:
		$AnimatedSprite2D.play("move")
		#$Move.play()
		
	var friction_force = velocity * FRICTION
	var drag_force = velocity * velocity.length() * DRAG
	
	if velocity.length() < 100:
		friction_force *= 3    
		
	acceleration +=  drag_force + friction_force
	
func get_input():
	var turn = 0
	
	if Input.is_action_pressed("steer_right"):
		turn += 1		
	if Input.is_action_pressed("steer_left"):
		turn -= 1		
		
	steer_direction = turn * deg_to_rad(STEERING_ANGLE)
	
	acceleration = Vector2.ZERO
	
	if Input.is_action_pressed("accelerate"):
		acceleration = transform.x * ENGINE_POWER
		$IdleSound.stop()
		$MoveSound.play()
	elif Input.is_action_pressed("brake"):
		acceleration = transform.x * BRAKING
		$MoveSound.stop()
		$IdleSound.play()
	else:
		$MoveSound.stop()
		$IdleSound.play()
	
func calculate_steering(delta):
	var rear_wheel = position - transform.x * WHEEL_BASE / 2
	var front_wheel = position + transform.x * WHEEL_BASE / 2
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	
	var new_heading = (front_wheel - rear_wheel).normalized()	
	var traction = TRACTION_SLOW
	
	if	velocity.length() > SLIP_SPEED:
		traction = TRACTION_FAST
		
	var d = new_heading.dot(velocity.normalized())
	var heading_dir = 1
	var max_speed_by_dir = MAX_SPEED
	
	if	d > 0:
		heading_dir = 1
		max_speed_by_dir = MAX_SPEED		
	if d < 0:
		heading_dir = -1	
		max_speed_by_dir = MAX_REVERSE_SPEED		
	
	velocity = velocity.lerp(new_heading * heading_dir * min(velocity.length(), MAX_SPEED * max_speed_multiplier), traction)	
		
	rotation = new_heading.angle()


func _on_terrain_handler_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):	
	if body is TileMap:	
		var new_max_speed_multiplier = 1
	
		for index in body.get_layers_count():
			var tileData = body.get_cell_tile_data(index, body.get_coords_for_body_rid(body_rid))
			
			if tileData is TileData:			
				if tileData.get_custom_data("is_water"):
					$WaterSound.play()
					pass
				new_max_speed_multiplier = tileData.get_custom_data("max_speed_multiplier")
	
		max_speed_multiplier = new_max_speed_multiplier
	
	

func _on_terrain_handler_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	pass

func _on_loose_level():
	$MoveSound.stop()
	$IdleSound.stop()

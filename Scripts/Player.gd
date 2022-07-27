extends KinematicBody2D
class_name Player

onready var movement = $"PlayerMovement"
onready var display = $"PlayerDisplay"
onready var camera = $"Stick/PlayerCamera"
onready var tw = $"Tween"

export(float, 0.0, 1.0) var tail_lerp:float

var prev_vel:Vector2 = Vector2.ZERO

func get_speed():
	return clamp(pow(movement.vel.length()/30000.0, 0.6), 0.0, 1.0)

func get_accel():
	return clamp(pow(movement.get_acceleration().length()/500.0, 0.25), 0.0, 1.0)

func _process(delta):
	display.set_facing(
		display.FACING.RIGHT 
		if movement.vel.x<0 else 
		display.FACING.LEFT
	)
	display.set_heading(-movement.vel)
	display.wing_open(movement.glide_dive)
	display.set_feet(clamp(get_speed()*2.0, 0.0, 1.0))
	display.set_tail_dir(-prev_vel)
	prev_vel = lerp(prev_vel, movement.vel, tail_lerp)
	
	tw.interpolate_property($"Stick", "position", 
		$"Stick".position, movement.vel.normalized()*(get_speed()*480), 
		3.0, Tween.TRANS_QUART, Tween.EASE_OUT)
	tw.start()
	camera.zoom_to(1+get_speed()*2)


func _on_PlayerMovement_flap(dir):
	display.set_looking(int(-dir))
	display.wing_flap()

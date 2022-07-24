extends Node2D

export(float, 0.0, 1.0) var ground_friction:float
export(float, 0.0, 1.0) var hori_friction:float
export var jump_halt:Vector2
export var accel:float
export var flapforce:float
export var gravity:float
export(float, 0.0, 1.0) var air_friction:float
export var glide_amp:float
export(float, 0.0, 1.0) var glide_conversion_rate:float
export var body_path:NodePath

export(float, 1.0, 10.0) var flap_facing_n:float
export(float, -0.9999, 0.9999) var flap_facing_cutoff:float

var body:KinematicBody2D
var prev_vel:Vector2 = Vector2.ZERO
var vel:Vector2 = Vector2.ZERO
var gliding:bool = true
var air_friction_scale:float = 1.0

var fall_from:float = 0

var attack_angle:float = 0

signal flap(dir)

func _ready():
	body = get_node(body_path)
	fall_from = global_position.y
#
#func range_morph(x:float, n:float, dir:float)->float:
#	return (x+dir-(dir/n))*n
#
#func flap_facing_morph(x:float)->float:
#	if x<flap_facing_cutoff:
#		return pow(
#			range_morph(x, 1.0/(1.0+flap_facing_cutoff), 1.0)+1.0
#			, flap_facing_n)-1.0
#	else:
#		return 1.0-pow(
#			-range_morph(x, 1.0/(1.0-flap_facing_cutoff), -1.0)+1.0
#			, flap_facing_n) 
#
#func flap_facing()->float:
#	return flap_facing_morph(vel.normalized().dot(Vector2.UP))
#
#func commit_flap(dir=1, amp=1):
#	vel.y += -flapforce*amp * flap_facing()
#	vel.x += dir*accel*amp * (1.0-abs(flap_facing()/2.0))
#	emit_signal("flap", dir)

func flap():
	if body.is_on_floor()||body.is_on_ceiling():
		vel.y = 0.0
	if body.is_on_wall():
		vel.x = 0.0
	if body.is_on_floor():
		vel.x *= 1.0-ground_friction

func tilt():
	if Input.is_action_pressed("Up"):
		attack_angle += TAU/32.0
	if Input.is_action_pressed("Down"):
		attack_angle -= TAU/32.0
	attack_angle = clamp(attack_angle, 0.0, 0.349066)

func vert_fric():
	if Input.is_action_pressed("Glide"):
		air_friction_scale = glide_amp
		gliding = true
	else:
		air_friction_scale = 1.0
		gliding = false
	
	if Input.is_action_just_released("Glide"):
		fall_from = global_position.y

func is_glide_dive_held():
	return air_friction_scale != 1.0

func get_fall_distance()->float:
	return fall_from-global_position.y

func fall():
	vert_fric()
	
	if gliding:
		vel.x = sign(vel.x+0.0001)*sqrt(gravity*2.0)*get_fall_distance()
	
	vel.y+=gravity
	if vel.y>0: vel.y*=pow((1.0-air_friction), 1.0/air_friction_scale)

func move():
	flap()
	tilt()
	fall()
	vel.x *= 1.0-hori_friction

func get_acceleration()->Vector2:
	return vel-prev_vel

func _physics_process(delta):
	prev_vel = vel
	
	move()
	
	body.move_and_slide(vel, Vector2.UP)

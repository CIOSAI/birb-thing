extends Node2D

export(float, 0.0, 1.0) var ground_friction:float
export(float, 0.0, 1.0) var hori_friction:float
export var gravity:float
export(float, 0.0, 1.0) var air_friction:float
export var glide_amp:float
export var lambda:float
export var kappa:float
export var psi:float
export var max_angle:float = 0.349066
export var LC_function:Curve
export var body_path:NodePath

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

func flap():
	pass

func lift_coefficient()->float:
	return LC_function.interpolate(attack_angle/max_angle)*lambda

func lift():
	vel.y = -pow(abs(vel.x), 2.0)*lift_coefficient()*kappa

func tilt():
	if Input.is_action_pressed("Up"):
		attack_angle += TAU/32.0
	if Input.is_action_pressed("Down"):
		attack_angle -= TAU/32.0
	attack_angle = clamp(attack_angle, 0.0, max_angle)

func vert_fric():
	if Input.is_action_pressed("Glide"):
		air_friction_scale = glide_amp
		gliding = true
	else:
		air_friction_scale = 1.0
		gliding = false

func is_glide_dive_held():
	return air_friction_scale != 1.0

func get_fall_distance()->float:
	return clamp(-fall_from+global_position.y, 0.0, 10000.0)

func fall():
	vert_fric()
	
	if Input.is_action_pressed("Glide"):
		vel.x = sqrt(gravity)*get_fall_distance()*psi
	
	fall_from = global_position.y
	
	vel.y+=gravity
	if vel.y>0: vel.y*=pow((1.0-air_friction), 1.0/air_friction_scale)

func move():
	if body.is_on_floor()||body.is_on_ceiling():
		vel.y = 0.0
	if body.is_on_wall():
		vel.x = 0.0
	if body.is_on_floor():
		vel.x *= 1.0-ground_friction
	else:
		vel.x *= 1.0-hori_friction
	
	lift()
	tilt()
	fall()

func get_acceleration()->Vector2:
	return vel-prev_vel

func _physics_process(delta):
	prev_vel = vel
	
	move()
	
	body.move_and_slide(vel, Vector2.UP)

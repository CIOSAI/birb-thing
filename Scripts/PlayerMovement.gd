extends Node2D

onready var tw = $"Tween"

export(float, 0.0, 1.0) var ground_friction:float
export(float, 0.0, 1.0) var hori_friction:float
export var accel:float
export var flapforce:float
export var gravity:float
export(float, 0.0, 1.0) var air_friction:float
export var glide_amp:float
export(float, 0.0, 1.0) var glide_conversion_rate:float
export(float, 0.0, 2.0) var turn_dur:float
export var body_path:NodePath

export var xmod:Curve
export var ymod:Curve

var body:KinematicBody2D
var prev_vel:Vector2 = Vector2.ZERO
var vel:Vector2 = Vector2.ZERO
var glide_dive:bool = false
var flapping:bool = false
var air_friction_scale:float = 1.0

signal flap(dir)

func _ready():
	body = get_node(body_path)

func commit_flap(dir=1, amp=1):
	var dotted:float = vel.normalized().dot(Vector2.UP)
	var interpolated:Vector2 = Vector2(
		xmod.interpolate(0.5+dotted/2.0),
		-ymod.interpolate(0.5+dotted/2.0)
	)
	vel += interpolated*Vector2(sign(vel.x), 1.0)*Vector2(accel, flapforce)

func flap():
	if Input.is_action_pressed("Flap"):
		commit_flap(sign(vel.x))
		flapping = true
	else:
		flapping = false

func vert_fric():
	if Input.is_action_pressed("Glide"):
		glide_dive = true
	else:
		glide_dive = false
	
	air_friction_scale = glide_amp if glide_dive else 1.0

func fall():
	vert_fric()
	
	if Input.is_action_pressed("Glide"):
		vel.x += sign(vel.x+0.0001)*max(vel.y, 0.0)*glide_conversion_rate
	
	vel.y+=gravity
	if vel.y>0: vel.y*=pow((1.0-air_friction), 1.0/air_friction_scale)

func tween_about_done()->bool:
	return (!tw.is_active())||(tw.tell() / turn_dur > 0.7)

func flip():
	if Input.is_action_just_pressed("Down")&&tween_about_done():
		tw.stop_all()
		tw.interpolate_property(
			self, "vel:x",
			vel.x, -vel.x,
			turn_dur, Tween.TRANS_CIRC, Tween.EASE_OUT
		)
		tw.start()
	if Input.is_action_just_pressed("Glide"):
		tw.stop_all()

func move():
	if body.is_on_floor()||body.is_on_ceiling():
		vel.y = 0.0
	if body.is_on_wall():
		vel.x = 0.0
	
	flap()
	fall()
	flip()
	
	if body.is_on_floor():
		vel.x *= 1.0-ground_friction
	else:
		vel.x *= 1.0-hori_friction

func get_acceleration()->Vector2:
	return vel-prev_vel

func _physics_process(delta):
	prev_vel = vel
	
	move()
	
	body.move_and_slide(vel, Vector2.UP)

extends Node2D

enum FACING {RIGHT = 1, LEFT = -1}

onready var tw = $"Tween"
onready var flap_timer = $"FlapTimer"
onready var model = $"Model"
onready var model_trans = $"Model/ModelTransform"
onready var body = $"Model/ModelTransform/AnchorBody"
onready var head = $"Model/ModelTransform/AnchorBody/Body/AnchorHead"
onready var wings = $"Model/ModelTransform/AnchorBody/Body/AnchorWings"
onready var feet = $"Model/ModelTransform/AnchorBody/Body/AnchorFeet"
onready var tail = $"Model/ModelTransform/AnchorBody/Body/AnchorTail"
onready var chain = $"Chain"

export var flap_down_dur:float
export var flap_up_dur:float
export var open_tuck_dur:float
export var feet_dur:float

var facing:int = FACING.RIGHT
var looking:int = FACING.RIGHT
var flap_amp:float = 0.0
var feet_tuck_angle:float = 1.12399
var feet_stretch_angle:float = -0.71384

func _ready():
	flap_timer.wait_time = flap_up_dur+flap_down_dur

func set_facing(n:int):
	facing = n

func set_heading(v:Vector2):
	body.look_at(body.global_position+v)

func set_looking(dir:float):
	looking = dir

func wing_flap():
	tw.interpolate_property(
		wings, "scale:x",
		1, -1,
		flap_down_dur, Tween.TRANS_CIRC, Tween.EASE_OUT
	)
	tw.interpolate_property(
		wings, "scale:x",
		-1, 1,
		flap_up_dur, Tween.TRANS_CIRC, Tween.EASE_IN,
		flap_down_dur
	)
	tw.start()
	flap_timer.start()

func wing_open(b:bool):
	flap_amp = 1.0 if b else 0.0

func set_feet(n:float):
	tw.interpolate_property(
		feet, "rotation", 
		feet.rotation, lerp(feet_tuck_angle, feet_stretch_angle, n),
		feet_dur, Tween.TRANS_SINE, Tween.EASE_OUT
	)
	tw.start()

func set_tail_dir(dir:Vector2):
	tail.look_at(tail.global_position+dir)

func _process(delta):
	scale.x = facing
	head.look_at(head.global_position+Vector2(looking, 0))
	
	if flap_timer.time_left==0.0:
		tw.interpolate_property(
			wings, "scale:x",
			wings.scale.x, flap_amp,
			open_tuck_dur, Tween.TRANS_CIRC, Tween.EASE_OUT
		)
		tw.start()
	
	chain.append_point(global_position)

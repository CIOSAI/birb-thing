extends Node2D

onready var line = $"Line2D"

export var max_points:int = 64

func _ready():
	line.set_as_toplevel(true)

func append_point(v:Vector2):
	line.add_point(v)
	if line.points.size()>max_points:
		line.remove_point(0)

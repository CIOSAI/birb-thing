extends Area2D

onready var confetti:PackedScene = preload("res://Scenes/ConfettiParticle.tscn")

var world:Node2D

signal collect

func _on_Collectable_body_entered(body):
	var n:Particles2D = confetti.instance()
	n.emitting = true
	n.global_position = global_position
	world.add_child(n)
	queue_free()
	emit_signal("collect")

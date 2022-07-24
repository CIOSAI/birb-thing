extends Node2D

onready var collectable_scene:PackedScene = preload("res://Scenes/Collectable.tscn")
onready var player:Player = $"Player"


func spawn_collectable():
	var n = collectable_scene.instance()
	n.world = self
	n.global_position = (
		player.global_position+
		Vector2.ZERO.move_toward(
			Vector2(rand_range(-20000, 20000), rand_range(-20000, 20000)), 1000
		)
	)
	n.connect("collect", self, "spawn_collectable")
	add_child(n)
	

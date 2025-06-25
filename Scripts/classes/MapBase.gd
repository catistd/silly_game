extends Node3D
class_name MapBase

@export var player_scene: PackedScene
@export var spawns: Node3D

func _ready() -> void:
	pass
	# StartGame() # TODO remove this and allow player to start game from the menus when they are ready

# !!! major changes will happen here when multiplayer is added
func StartGame():
	var spawn_points = spawns.get_children()
	
	var player1 = player_scene.instantiate()
	player1.position = spawn_points.pick_random().position
	add_child(player1)

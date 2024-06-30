extends Node

@export var main_scene: PackedScene

func reset():
	get_tree().change_scene_to_packed(main_scene)
	multiplayer.multiplayer_peer = null


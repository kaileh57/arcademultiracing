extends Node3D
@onready var light_1 = $Light1
@onready var light_2 = $Light2


@onready var cd1 = $lightColored
@onready var cd2 = $lightColored2
@onready var cd3 = $lightColored3
@onready var cd4 = $lightColored4


@onready var top = get_parent().get_parent().get_parent().get_parent()
@onready var cd = top.countdown
@onready var txt = cd.get_child(0, true)


func _ready():
	pass

func go():
	txt.text = "Get Ready!"

	await get_tree().create_timer(2.0).timeout
	light_1.mesh.material.emission = Color.DARK_RED
	txt.text = "3"
	cd3.get_child(1).show()
	cd4.get_child(1).show()
	await get_tree().create_timer(1.0).timeout
	light_1.mesh.material.emission = Color.RED
	txt.text = "2"
	cd1.get_child(1).show()
	cd2.get_child(1).show()
	
	await get_tree().create_timer(1.0).timeout
	light_1.mesh.material.emission = Color.DARK_ORANGE
	txt.text = "1"
	cd1.get_child(2).show()
	cd2.get_child(2).show()
	
	await get_tree().create_timer(1.0).timeout
	light_1.mesh.material.emission = Color.FOREST_GREEN
	txt.text = "go!"
	cd1.get_child(3).show()
	cd2.get_child(3).show()
	top.enable.rpc(top.multiplayer.multiplayer_peer.get_unique_id())
	await get_tree().create_timer(1.0).timeout
	txt.hide()

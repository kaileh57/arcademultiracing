extends Node3D
@onready var light_1 = $Light1
@onready var light_2 = $Light2




func _ready():
	go()

func go():
	light_1.mesh.material.emission = Color.RED
	await get_tree().create_timer(2.0).timeout
	light_1.mesh.material.emission = Color.DARK_ORANGE
	await get_tree().create_timer(2.0).timeout
	light_1.mesh.material.emission = Color.FOREST_GREEN

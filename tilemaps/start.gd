extends Node3D
@onready var light_1 = $Light1
@onready var light_2 = $Light2
@onready var countdown = $Countdown
@onready var txt = $Countdown/Txt




func _ready():
	await get_tree().create_timer(5.0).timeout
	go()

func go():
	countdown.show
	light_1.show
	light_2.show
	light_1.mesh.material.emission = Color.DARK_RED
	
	await get_tree().create_timer(1.0).timeout
	light_1.mesh.material.emission = Color.RED
	txt.text = "3"
	
	await get_tree().create_timer(1.0).timeout
	light_1.mesh.material.emission = Color.DARK_ORANGE
	txt.text = "2"
	
	await get_tree().create_timer(1.0).timeout
	light_1.mesh.material.emission = Color.FOREST_GREEN

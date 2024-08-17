extends XRController3D

var started := false

@export var cont : Node3D
@onready var wheel = $"right quest 2 controller highpoly bones/Wheel"

func _on_button_pressed(name):
	if name == "start" && !started:
		Input.action_press("start")
		started = true

func _process(delta):
	cont.lrinput = wheel.global_rotation.y/180*PI
	print(wheel.global_rotation.y/180*PI)

func _on_input_float_changed(name, value):
	#print(name)
	if name == "trigger":
		cont.gas = value


func _on_input_vector_2_changed(name, value):
	if name == "primary":
		cont.lrinput = -value.x
		#if value.x <= -0.5:
		#	Input.action_press("left")
		#	print("left")
		#if value.x >= 0.5:
		#	Input.action_press("right")
		#	print("right")
		
		#Input.action_press("right", value.X)
		

extends XRController3D

var started := false

@export var cont : Node3D
@export var left : Node3D

@onready var wheel = $"../Wheel"
@onready var mesh_instance_3d = $"../Wheel/MeshInstance3D"

func _on_button_pressed(name):
	if name == "start" && !started:
		Input.action_press("start")
		started = true

func _process(delta):

	var direction = left.position - position
	var angle = -atan2(direction.y, direction.z)
	
	#print(angle)
	var rot = rad_to_deg(angle)
	rot /= 2
	rot += 90
	rot = deg_to_rad(rot)
	wheel.rotation.x= rot
	if rot >= 0:
		wheel.rotation.y = deg_to_rad(-90)
		wheel.rotation.z = deg_to_rad(-90)
	elif rot < 0:
		wheel.rotation.z = deg_to_rad(-90)
		wheel.rotation.y = deg_to_rad(-90)
	
	
	wheel.global_position = (left.global_position + global_position) / 2
	#var input = mesh_instance_3d.global_transform.basis.x.y
	cont.lrinput = angle/10#mesh_instance_3d.global_transform.basis.x.y/10
	print(cont.lrinput)
	if abs(cont.lrinput) <= .1: cont.lrinput = 0
	#if abs(cont.lrinput) >= .8: cont.lrinput *= 1.2
	print(cont.lrinput)
	#print(wheel.global_transform.basis.x.y)


func _on_input_float_changed(name, value):
	#print(name)
	if name == "trigger":
		cont.gas = value


func _on_input_vector_2_changed(name, value):
	pass#if name == "primary":
	#	cont.lrinput = -value.x
		#if value.x <= -0.5:
		#	Input.action_press("left")
		#	print("left")
		#if value.x >= 0.5:
		#	Input.action_press("right")
		#	print("right")
		
		#Input.action_press("right", value.X)
		

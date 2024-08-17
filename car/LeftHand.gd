extends XRController3D


@export var cont : Node3D

func _on_button_pressed(name):
	pass#print(name)


func _on_input_float_changed(name, value):
	if name == "trigger":
		cont.brake = value

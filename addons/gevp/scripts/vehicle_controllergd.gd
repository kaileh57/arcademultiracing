extends Node3D

@export var vehicle_node : Vehicle

@export var sens := 1.0
@onready var cam = $VehicleRigidBody/Pivot/Camera3D


func _ready():
	#If we are in control of this player, we'll use this camera
	cam.current = is_multiplayer_authority()
	

func _enter_tree():
	#Sets the person in control of this player to it's id/the id of the person controlling
	set_multiplayer_authority(name.to_int())
	print(is_multiplayer_authority())
	#	print(multiplayer.get_unique_id())


func _physics_process(delta):
	if is_multiplayer_authority():
		vehicle_node.brake_input = Input.get_action_strength("brakes")
		vehicle_node.steering_input = Input.get_action_strength("left") - Input.get_action_strength("right") * sens
		vehicle_node.throttle_input = pow(Input.get_action_strength("forward"), 2.0)
		vehicle_node.handbrake_input = Input.get_action_strength("handbrake")
		#vehicle_node.clutch_input = clampf(Input.get_action_strength("Clutch") + Input.get_action_strength("Handbrake"), 0.0, 1.0)
		if Input.is_action_pressed("consolemode"): sens = 0.2
		#if Input.is_action_just_pressed("Toggle Transmission"):
		#	vehicle_node.automatic_transmission = !vehicle_node.automatic_transmission
		
		#if Input.is_action_just_pressed("Shift Up"):
		#	vehicle_node.manual_shift(1)
		
		#if Input.is_action_just_pressed("Shift Down"):
		#	vehicle_node.manual_shift(-1)
		
		#if vehicle_node.current_gear == -1:
		#	vehicle_node.brake_input = Input.get_action_strength("Throttle")
		#	vehicle_node.throttle_input = Input.get_action_strength("Brakes")

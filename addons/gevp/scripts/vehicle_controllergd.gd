extends Node3D

@export var vehicle_node : Vehicle

@export var sens := 1.0
@onready var cam = $VehicleRigidBody/Pivot/Camera3D
var disabled = true

func _ready():
	#If we are in control of this player, we'll use this camera
	cam.current = is_multiplayer_authority()



@rpc("authority", "call_remote", "unreliable")
func update_pos(pos, tran):
	if !is_multiplayer_authority():
		vehicle_node.transform = tran
		vehicle_node.position = pos
	


func _enter_tree():
	#Sets the person in control of this player to it's id/the id of the person controlling
	multiplayer.multiplayer_peer = get_parent().peer
	set_multiplayer_authority(name.to_int())
	$VehicleRigidBody.freeze = !is_multiplayer_authority()
	#	print(multiplayer.get_unique_id())


func _physics_process(delta):
	if is_multiplayer_authority():
		update_pos.rpc(vehicle_node.position, vehicle_node.transform)
		vehicle_node.brake_input = Input.get_action_strength("brakes")
		vehicle_node.steering_input = Input.get_action_strength("left") - Input.get_action_strength("right") * sens
		vehicle_node.throttle_input = pow(Input.get_action_strength("forward"), 2.0)
		vehicle_node.handbrake_input = Input.get_action_strength("handbrake")
		if disabled: 
			vehicle_node.handbrake_input = 10
		
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

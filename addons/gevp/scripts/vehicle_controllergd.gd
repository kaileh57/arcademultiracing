extends Node3D

@onready var death_detector = $DeathDetector
@onready var lap_detector = $LapDetector

var points: int = 0
var nm: String

@export var vehicle_node : Vehicle
@onready var username = $Username
@onready var usernametxt = $Username/Username

@export var sens := 1.0
@onready var cam = $VehicleRigidBody/Pivot/XROrigin3D/XRCamera3D
var disabled = true

var deathbox = false

var readyforlap = false

func die():
	if deathbox && is_multiplayer_authority():
		print("actually died")
		vehicle_node.position = get_parent().pos1.position
		vehicle_node.rotation = Vector3(0, PI, 0)
		vehicle_node.linear_velocity = Vector3.ZERO
		await get_tree().create_timer(0.5).timeout
		vehicle_node.position = get_parent().pos1.position
		vehicle_node.rotation = Vector3(0, PI, 0)
		vehicle_node.linear_velocity = Vector3.ZERO
		await get_tree().create_timer(0.5).timeout
		vehicle_node.position = get_parent().pos1.position
		vehicle_node.rotation = Vector3(0, PI, 0)
		vehicle_node.linear_velocity = Vector3.ZERO
	

func _on_death_detector_area_entered(_area):
	print(str(name) + " died")
	die()

func _on_lap_detector_area_entered(area):
	if readyforlap and area.name == "Start":
		points += 1
		readyforlap = false
	elif area.name == "Checkpoint":
		readyforlap = true



func _ready():
	#If we are in control of this player, we'll use this camera
	cam.current = is_multiplayer_authority()
	$Username.visible = !is_multiplayer_authority()
	$VehicleRigidBody/EngineSound.playing = is_multiplayer_authority()
	await get_tree().create_timer(5.0).timeout
	deathbox = true


func name_pivot():
	username.position = vehicle_node.position
	death_detector.position = vehicle_node.position
	lap_detector.position = vehicle_node.position
	
	
	#username.look_at(get_parent().find_child(str(1), true, false).cam.position)


func change_color(color: Color = Color.BISQUE, username := "username"):
	if color != Color.BISQUE: vehicle_node.change_color(color)
	if username != "username": 
		usernametxt.text = username
		nm = username


@rpc("authority", "call_remote", "unreliable")
func update_pos(pos, tran):
	if !is_multiplayer_authority():
		vehicle_node.transform = tran
		vehicle_node.position = pos

func _input(_event):
	if Input.is_action_pressed("reset"):
		print(str(name) + " reset")
		die()


func _enter_tree():
	#Sets the person in control of this player to it's id/the id of the person controlling
	multiplayer.multiplayer_peer = get_parent().peer
	set_multiplayer_authority(name.to_int())
	$VehicleRigidBody.freeze = !is_multiplayer_authority()
	#	print(multiplayer.get_unique_id())


func _physics_process(delta):
	name_pivot()
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








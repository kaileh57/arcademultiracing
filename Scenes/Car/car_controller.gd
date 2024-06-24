extends Node3D

# car model
@onready var rig = $Rig
@onready var container = $Container
@onready var model = $Container/Model
@onready var sphere = $Sphere
@onready var raycast = $Container/Model/RayCast3D
@onready var body = $Container/Model/body
@onready var front_wheel_right = $Container/Model/wheelFrontRight
@onready var front_wheel_left = $Container/Model/wheelFrontLeft
@onready var rear_wheel_right = $Container/Model/wheelRearRight
@onready var rear_wheel_left = $Container/Model/wheelRearLeft
@onready var smoke_left = $Container/Model/SmokeLeft
@onready var smoke_right = $Container/Model/SmokeRight
@onready var left_skid_pos = $Container/Model/LeftSkidPos
@onready var right_skid_pos = $Container/Model/RightSkidPos
@onready var skidmarks = preload("res://Scenes/Car/skids.tscn")
@onready var engine_sound = $EngineSFX
@onready var skid_sound = $SkidSFX
@onready var bump_sound = $BumpSFX
@onready var front_lights = $Container/Model/body/FrontLights
@onready var rear_lights = $Container/Model/body/RearLights
@onready var cam = $Rig/Camera3D

# CPU or human
@export var is_AI = false

# car settings
@export var max_speed = 200
@export var brake_force = 0.15 # value between 0 - 1
@export var turn_strength = 120
@export var acceleration = 0.7 # value between 0 - 1
@export var body_height = 0.67
@export var body_pos = -0.074
@export var is_lights_on = true
@export var car_name = "car"
var speed_target : float = 0.0
var speed : float = 0.0
var torque_velocity : float = 0.0
var skid_threshold = 0.028
var was_accelerating = false

var normal = Vector3(0, 1, 0)
var raycast_normal = Vector3(0, 1, 0)
var body_position = Vector3(0, 0, 0)
var model_rotation = Vector3(0, 0, 0)

# waypoints system
var waypoints = []  # List to store the waypoints
var current_waypoint = 0  # Index of the current waypoint

# how accurate is the ai car reaching the next waypoint
# if this value is equal to zero, it means that the car will reach the exact
# spot of the next waypoint
@export var target_variance = 1.0  
var rng = RandomNumberGenerator.new()

# car race values
var race_position = 0
var player_position = 0
var current_lap = 1
var current_lap_time = 0.0
var best_lap_time = 0.0
var race_time = 0.0
var lap_times = []
var distance_to_next_waypoint = 0
var total_checked = 0
var checked = 0
var is_countdown_finished = false
var is_race_finished = false
var is_final_pos_set = false

func _ready():
	# initialize waypoints
	# IMPORTANT ! For a more accurate race positions, add more waypoints to the track
	waypoints = get_tree().get_nodes_in_group("check")
	
	# Load engine sound
	engine_sound.stream = preload("res://Assets/SFX/Motor.wav")
	engine_sound.pitch_scale = 0.85  # Adjust pitch scale as needed
	
	# Load skid sound
	skid_sound.stream = preload("res://Assets/SFX/Car Brakes.wav")
	skid_sound.pitch_scale = 0.7  # Adjust pitch scale as needed
	
	# lights
	if not is_lights_on:
		front_lights.visible = false
	else:
		front_lights.visible = true
		
	if not is_AI:
		cam.current = true
		car_name = "player"
	else:
		cam.current = false
		car_name = name

	#print(car_name)



func _physics_process(delta):
	# Set model position to sphere position
	container.transform.origin = sphere.transform.origin - Vector3(0, 1, 0)
	
	# Set model rotation based on 'modelRotation'	
	model.rotation_degrees = model.rotation_degrees.lerp(model_rotation, delta * 5)

	
	if Input.is_action_just_pressed("lights"):
		is_lights_on = !is_lights_on





		# Accelerate and brake based on distance to the waypoint
		var distance_to_waypoint = (model.global_transform.origin - waypoints[current_waypoint].global_transform.origin).length()
		if distance_to_waypoint > 15:
			speed = max_speed
		elif distance_to_waypoint > 10:
			speed = max_speed * 0.9
		else:
			speed = max_speed * 0.75
	else:
		# Rotate model using keys
		if Input.is_action_pressed("left") and abs(speed) > 0 and raycast.is_colliding():
			model_rotation.y += turn_strength * delta
		elif Input.is_action_pressed("right") and abs(speed) > 0 and raycast.is_colliding():
			model_rotation.y -= turn_strength * delta
	
	speed_target = lerp(speed_target, speed, 4 * delta)
	var forward = model.get_global_transform().basis.z
	
	
	sphere.apply_force(forward * speed_target * 1.25, model.transform.origin)
	#print(speedTarget)
	
	if not is_AI:
		# lights
		if not is_lights_on:
			front_lights.visible = false
			rear_lights.visible = false
		else:
			front_lights.visible = true
			rear_lights.visible = true
		
		if not engine_sound.playing:
				engine_sound.play()
				engine_sound.volume_db = -10
		if Input.is_action_pressed("forward"):
			if raycast.is_colliding():
				speed += max_speed * acceleration * delta * 0.85
				was_accelerating = true
			else:
				was_accelerating = false
			
			# Clamp the speed to the maximum speed
			speed = min(speed, max_speed)
		elif Input.is_action_pressed("back") and raycast.is_colliding():
			if speed > 0:
				# Apply brake force until the speed is zero
				speed -= max_speed * brake_force * delta
			else:
				# If already moving backward, set speed to zero
				speed = 0
							
			$Container/Model/body/RearLights/Left/StopLightLeft.light_energy = 10
			$Container/Model/body/RearLights/Right/StopLightRight.light_energy = 10

		elif not raycast.is_colliding():
			# If the forward button is not pressed and the car is in the air, maintain or slightly decrease speed
			speed = max(0, speed - max_speed * 0.4 * delta)
		
		elif Input.is_action_just_released("back"):
			$Container/Model/body/RearLights/Left/StopLightLeft.light_energy = 1
			$Container/Model/body/RearLights/Right/StopLightRight.light_energy = 1
		
		else:
			# If no input, gradually decrease speed
			speed = max(0, speed - max_speed * 0.2 * delta)
			
		# If the forward button was released and the car is in the air, maintain the current speed
		if not was_accelerating and not raycast.is_colliding():
			speed = max(speed, speed_target)
				
		# Adjust pitch engine sound based on speed
		if speed == 0:
			engine_sound.pitch_scale = 1
		else:
			engine_sound.pitch_scale = lerp(0.85, 1.5, speed / max_speed)
	
	# Effects (body tilt, wheel turning)
	var rotation_velocity = (model_rotation - model.rotation_degrees).y
	
	# turn wheels
	front_wheel_left.rotation_degrees.y  = rotation_velocity * 1.3
	front_wheel_right.rotation_degrees.y = rotation_velocity * 1.3
	
	front_wheel_left.rotation.x += 0.05 * speed * delta
	front_wheel_right.rotation.x += 0.05 * speed * delta
	
	# rotate wheels
	rear_wheel_left.rotate_x(0.05 * speed * delta)
	rear_wheel_right.rotate_x(0.05 * speed * delta)
		
	# Body position
	body_position = Vector3(0, body_height, body_pos)
	if !raycast.is_colliding(): body_position += Vector3(0, 0.1, 0)
	body.transform.origin = body.transform.origin.lerp(body_position, delta * 15)
	
	# Body rotation
	var torque = (speed / 20) - sphere.linear_velocity.length()
	torque_velocity = clamp( lerp(torque_velocity, torque, 2 * delta), -5, 5)
	body.rotation_degrees = Vector3((torque_velocity * 0.9), 0, 0)
	body.rotate_object_local(Vector3(0, 0, 1), rotation_velocity / 200)
		
	# Skidding
	var velocity = sphere.linear_velocity
	var lateral_velocity = velocity - forward * velocity.dot(forward)
	var lateral_speed = lateral_velocity.length()
	var slip_angle = atan2(lateral_speed, speed_target)
	if (abs(slip_angle) > skid_threshold) and lateral_speed > 1.0 and raycast.is_colliding():
		# Car is skidding
		add_tire_tracks()
		smoke_left.emitting  = true
		smoke_right.emitting = true
		if not skid_sound.playing and not is_AI:
			skid_sound.play()
	else:
		skid_sound.stop()
		smoke_left.emitting  = false
		smoke_right.emitting = false
	
	# Camera
	rig.transform.origin = rig.transform.origin.lerp(container.transform.origin, delta * 5)
	
	# Ground raycast
	normal = normal.lerp(raycast_normal, delta * 8)
	container.global_transform = alignNormal(container.global_transform, normal)
	
	if raycast.is_colliding():
		raycast_normal = raycast.get_collision_normal()
	else:
		raycast_normal = raycast_normal.lerp(Vector3(0, 1, 0) + (model.get_transform().basis.z / 2), delta * 4)
	pass
	
		
func alignNormal(_container, _normal):
		_container.basis.y = _normal
		_container.basis.x = -_container.basis.z.cross(_normal)
		_container.basis = _container.basis.orthonormalized()
		return _container
		
func add_tire_tracks():
	# skidmarks
	var left_skidmarks_instance = skidmarks.instantiate()
	var right_skidmarks_instance = skidmarks.instantiate()
	get_parent().add_child(left_skidmarks_instance)
	get_parent().add_child(right_skidmarks_instance)
	left_skidmarks_instance.global_transform.origin = left_skid_pos.global_transform.origin
	right_skidmarks_instance.global_transform.origin = right_skid_pos.global_transform.origin
	
	var r = get_rotation()
	left_skidmarks_instance.set_rotation(r)
	right_skidmarks_instance.set_rotation(r)
		
func _on_area_3d_area_entered(area):
	pass
		
	
func check_best_lap():
	if not is_race_finished:
		if current_lap_time <= best_lap_time and current_lap_time > 0:
			# new lap record!
			best_lap_time = current_lap_time
		
func set_next_target():
	# update next checkpoint
	if current_waypoint == waypoints.size() - 1:
		current_waypoint = 0
	else:
		current_waypoint +=1
		
	randomize_ai_target()

func randomize_ai_target():
	waypoints[current_waypoint].global_transform.origin += Vector3(rng.randf_range(-target_variance, target_variance), 0 , rng.randf_range(-target_variance, target_variance))


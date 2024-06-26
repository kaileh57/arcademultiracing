extends CharacterBody3D

##STANDARD GODOT MOVEMENT CONTROLLER


##IMPORTANT
#This handles both the person controlling this player, and syncronizing with other versions of the same player


const SPEED = 10.0
const JUMP_VELOCITY = 4.5
@onready var pivot = $CameraOrigin
@export var sens = 0.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	#If we are in control of this player, we'll use this camera
	cam.current = is_multiplayer_authority()

@onready var cam = $CameraOrigin/SpringArm3D/Camera3D

func _enter_tree():
	#Sets the person in control of this player to it's id/the id of the person controlling
	set_multiplayer_authority(name.to_int())

func _input(event):
	#3rd person camera movement, kinda ass
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))


func _physics_process(delta):
	#If we are the person in control of this character, check for movement/do physics
	if is_multiplayer_authority():
		if not is_on_floor():
			velocity.y -= gravity * delta

		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		if Input.is_action_just_pressed("esc") and is_on_floor():
			#Quit game and disconnect smoothly
			$"../".exit_game(name.to_int())
			get_tree().quit()
		

		# Get the input direction and handle the movement/deceleration.
		var input_dir = Input.get_vector("d", "a", "s", "w")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

		move_and_slide()

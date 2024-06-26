extends AudioStreamPlayer3D

@export var vehicle : Vehicle
@export var sample_rpm := 4000.0

@onready var auth = get_parent().get_parent()

func _physics_process(delta):
	if auth. is_multiplayer_authority():
		pitch_scale = vehicle.motor_rpm / sample_rpm
		volume_db = linear_to_db((vehicle.throttle_amount * 0.5) + 0.5)

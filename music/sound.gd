extends AudioStreamPlayer

const ARCADE_STOCK = preload("res://music/ArcadeStock.mp3")
const FREE_WILL = preload("res://music/FreeWill.mp3")

@onready var label = $CanvasLayer/Label
@onready var animation_player = $CanvasLayer/AnimationPlayer


var cycle = 0

func toggle_track():
	cycle += 1
	if cycle == 1:
		stream = ARCADE_STOCK
		playing = true
		label.text = "Now playing: Random stock track"
	elif cycle == 2:
		stream = FREE_WILL
		playing = true
		label.text = "Now playing: Music I stole from Kurzgesagt"
	elif cycle == 3:
		cycle = 0
		playing = false
		label.text = "Now playing: Nothing :("
	animation_player.play("fade")

func _ready():
	pass#toggle_track()

func _input(_event):
	if Input.is_action_just_pressed("music"):
		toggle_track()


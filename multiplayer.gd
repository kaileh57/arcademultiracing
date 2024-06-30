extends Node3D

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene

@onready var fresh_player_scene: PackedScene = player_scene

@onready var countdown = $Countdown


var local_player: Node3D

var pos1

@onready var track1 = preload("res://tracks/track.tscn")
@onready var track2 = preload("res://tracks/track2.tscn")
@onready var track3 = preload("res://tracks/track3.tscn")
@onready var track4 = preload("res://tracks/track4.tscn")

@onready var option_button: OptionButton = $CanvasLayer/OptionButton


var mycolor = Color.WHITE
var myname = ""


@onready var ip: LineEdit = $CanvasLayer/IP
@onready var port: LineEdit = $CanvasLayer/Port
var tracknode

var map_number = 1
var pos = 0
var startpos

@rpc("any_peer", "call_local", "reliable")
func start_sequence(id_sender):
	if id_sender == 1: 
		find_child("Track", true, false).start.go()


@rpc("any_peer", "call_local", "reliable")
func poll_colors(id_sender):
	if id_sender == 1:
		for i in get_children():
			if i.name != "CanvasLayer" and i.name != "Track" and i.name != "MultiplayerSpawner" and i.name != "Countdown":
				ask_my_color.rpc_id(int(str(i.name)), int(str(i.name)))

@rpc("any_peer", "call_local", "reliable")
func poll_names(id_sender):
	if id_sender == 1:
		for i in get_children():
			if i.name != "CanvasLayer" and i.name != "Track" and i.name != "MultiplayerSpawner" and i.name != "Countdown":
				ask_my_name.rpc_id(int(str(i.name)), int(str(i.name)))


@rpc("any_peer", "call_local", "reliable")
func set_my_color(color, sender):
	if sender == 1: mycolor = color

@rpc("any_peer", "call_local", "reliable")
func set_my_name(nm, sender):
	if sender == 1: myname = nm


@rpc("any_peer", "call_local", "reliable")
func ask_my_color(id):
	update_color.rpc(mycolor, id, 1)

@rpc("any_peer", "call_local", "reliable")
func ask_my_name(id):
	update_name.rpc(myname, id, 1)




@rpc("any_peer", "call_local", "reliable")
func request_colors(id):
	if multiplayer.multiplayer_peer.get_unique_id() == 1:
		var c = get_next_color()
		set_my_color.rpc_id(id, c, 1)
		update_color.rpc(c, id, multiplayer.multiplayer_peer.get_unique_id())

@rpc("any_peer", "call_local", "reliable")
func update_color(color: Color, id, id_sender):
	var child = find_child(str(id), true, false)
	if id_sender == 1:# or child.get_multiplayer_authority() == id_sender:
		child.change_color(color)

@rpc("any_peer", "call_local", "reliable")
func update_name(nm: String, id, id_sender):
	var child = find_child(str(id), true, false)
	if id_sender == 1:# or child.get_multiplayer_authority() == id_sender:
		child.change_color(Color.BISQUE, nm)# Change_color is used for both colors and names





@rpc("any_peer", "call_remote", "reliable")
func request_map(id_sender):
	set_map.rpc_id(id_sender, multiplayer.multiplayer_peer.get_unique_id(), map_number)

@rpc("any_peer", "call_remote", "reliable")
func set_map(id_sender, mapn):
	if id_sender == 1:
		var map
		if mapn == 1: map = track1.instantiate()
		elif mapn == 2: map = track2.instantiate()
		elif mapn == 3: map = track3.instantiate()
		elif mapn == 4: map = track4.instantiate()
		add_child(map)
		tracknode = map
		pos1 = map.pos1



@rpc("any_peer", "call_local", "reliable")
func enable(id_sender, id = multiplayer.multiplayer_peer.get_unique_id()):
	if id_sender == 1:
		find_child(str(id), true, false).disabled = false

#Called from client to host for starter pos
@rpc("any_peer", "call_remote", "reliable")
func request_new_pos(id):
	update_car_pos.rpc_id(id, id, get_next_pos(id), 1, true, true)

#called from host to client
@rpc("any_peer", "call_local", "reliable")
func update_car_pos(id, posn, id_sender, dis = true, double = false):
	if id_sender == 1: 
		find_child(str(id), true, false).get_child(0).position = posn
		find_child(str(id), true, false).disabled = dis
		if double:
			await get_tree().create_timer(0.5).timeout
			find_child(str(id), true, false).get_child(0).position = posn
			await get_tree().create_timer(0.5).timeout
			find_child(str(id), true, false).get_child(0).position = posn
			find_child(str(id), true, false).get_child(0).rotation = Vector3(0, PI, 0)

func get_next_color() -> Color:
	if pos == 1: return Color.RED
	if pos == 2: return Color.BLUE
	if pos == 3: return Color.GREEN
	if pos == 4: return Color.YELLOW
	if pos == 5: return Color.PURPLE
	if pos == 6: return Color.ORANGE
	if pos == 7: return Color.BLACK
	if pos == 8: return Color.CHOCOLATE
	return Color.WHITE


##NOTE: This doesn't work cuz this logic is just called on the host, gonna need to add a get_next_color funciton tommorow

func get_next_pos(_id = 1) -> Vector3:
	pos += 1
	if pos == 1: 
		return tracknode.pos1.position
	if pos == 2: 
		return tracknode.pos2.position
	if pos == 3: 
		return tracknode.pos3.position
	if pos == 4: 
		return tracknode.pos4.position
	if pos == 5: 
		return tracknode.pos5.position
	if pos == 6: 
		return tracknode.pos6.position
	if pos == 7: 
		return tracknode.pos7.position
	if pos == 8: 
		return tracknode.pos8.position
	return Vector3.ZERO


func _input(_event):
	if Input.is_action_just_pressed("reseteverything") && Input.is_action_pressed("reseteverything2"):
		Resetter.reset()
	if Input.is_action_just_pressed("screenshot"):
		print("Screenshotted")
		var capture = get_viewport().get_texture().get_image()
		var _time = Time.get_unix_time_from_system()
		var filename = "C:\\Users\\kellen\\Downloads\\Screenshot" + str(_time) + ".png"
		capture.save_png(filename)
	if Input.is_action_pressed("start"):
		start_sequence.rpc(multiplayer.multiplayer_peer.get_unique_id())


func _on_host_pressed():
	#Change this port to whatever you want
	myname = $CanvasLayer/Name.text
	if myname != "":
		peer.create_server(int(port.text))
		#set the peer we use to the peer we made
		multiplayer.multiplayer_peer = peer
		#whenever someone joins we run add_player
		multiplayer.peer_connected.connect(add_player)
		
		map_number = option_button.get_selected_id()
		
		set_map(1, map_number)
		await get_tree().create_timer(0.1).timeout
		#add ourselves
		add_player()
		#hide buttons and capture mouse
		$CanvasLayer.hide()
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		await get_tree().create_timer(0.5).timeout
		update_car_pos(1, get_next_pos(1), 1)
		request_colors(multiplayer.multiplayer_peer.get_unique_id())
		poll_names(1)
	else:
		$CanvasLayer/Host.text = "Please add name"
		await get_tree().create_timer(0.5).timeout
		$CanvasLayer/Host.text = "Host"
	


func _on_join_pressed():
	#Change this port and ip to whatever you want, 127.0.0.1 is on the same machine
	myname = $CanvasLayer/Name.text
	if myname != "":
		peer.create_client(ip.text, int(port.text))
		#sets the peer to the peer we just made
		multiplayer.multiplayer_peer = peer

		#hide buttons and capture mouse
		$CanvasLayer.hide()
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		await get_tree().create_timer(0.2).timeout
		request_map.rpc_id(1, multiplayer.multiplayer_peer.get_unique_id())
		await get_tree().create_timer(0.2).timeout
		request_new_pos.rpc_id(1, multiplayer.multiplayer_peer.get_unique_id())
		request_colors.rpc_id(1, multiplayer.multiplayer_peer.get_unique_id())
	else:
		$CanvasLayer/Join.text = "Please add name"
		await get_tree().create_timer(0.5).timeout
		$CanvasLayer/Join.text = "Join"
	


func add_player(id = 1):
	#instances the player, names it the id of the connecting person, and adds them to the scene
	fresh_player_scene = load("res://car/carmulti.tscn")
	if multiplayer.multiplayer_peer.get_unique_id() == 1: print("added with ID of " + str(id))
	var player = fresh_player_scene.instantiate()
	player.name = str(id)
	add_child(player)
	await get_tree().create_timer(0.1).timeout
	poll_colors.rpc(multiplayer.multiplayer_peer.get_unique_id())
	poll_names.rpc(multiplayer.multiplayer_peer.get_unique_id())
	

func exit_game(id):
	#disconnect smoothly and delete the player for everyone
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)


func del_player(id):
	#remotley delete the player from everyones game
	_del_player.rpc(id)

#let anyone call this and also call it here
@rpc("any_peer","call_local")
func _del_player(id):
	#queue free the node
	find_child(str(id), true, false).queue_free()

extends Node3D

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene

@onready var track1 = preload("res://tracks/track.tscn")
@onready var track2 = preload("res://tracks/track2.tscn")
@onready var track3 = preload("res://tracks/track3.tscn")
@onready var track4 = preload("res://tracks/track4.tscn")

@onready var option_button: OptionButton = $CanvasLayer/OptionButton


@onready var ip: LineEdit = $CanvasLayer/IP
@onready var port: LineEdit = $CanvasLayer/Port
var tracknode

var map_number = 1
var pos = 0
var startpos


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



@rpc("any_peer", "call_local", "reliable")
func enable(id_sender, id = multiplayer.multiplayer_peer.get_unique_id()):
	if id_sender == 1:
		find_child(str(id), true, false).disabled = false

#Called from client to host for starter pos
@rpc("any_peer", "call_remote", "reliable")
func request_new_pos(id):
	update_car_pos.rpc_id(id, id, get_next_pos(), 1, true, true)

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
			
			


func get_next_pos() -> Vector3:
	pos += 1
	if pos == 1: return tracknode.pos1.position
	if pos == 2: return tracknode.pos2.position
	if pos == 3: return tracknode.pos3.position
	if pos == 4: return tracknode.pos4.position
	if pos == 5: return tracknode.pos5.position
	if pos == 6: return tracknode.pos6.position
	if pos == 7: return tracknode.pos7.position
	if pos == 8: return tracknode.pos8.position
	return Vector3.ZERO


func _input(_event):
	if Input.is_action_pressed("start"):
		enable.rpc(multiplayer.multiplayer_peer.get_unique_id())


func _on_host_pressed():
	#Change this port to whatever you want
	peer.create_server(57570)
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
	update_car_pos(1, get_next_pos(), 1)


func _on_join_pressed():
	#Change this port and ip to whatever you want, 127.0.0.1 is on the same machine
	peer.create_client(ip.text, 57570)
	#sets the peer to the peer we just made
	multiplayer.multiplayer_peer = peer

	#hide buttons and capture mouse
	$CanvasLayer.hide()
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	await get_tree().create_timer(0.2).timeout
	request_map.rpc_id(1, multiplayer.multiplayer_peer.get_unique_id())
	await get_tree().create_timer(0.2).timeout
	request_new_pos.rpc_id(1, multiplayer.multiplayer_peer.get_unique_id())


func add_player(id = 1):
	#instances the player, names it the id of the connecting person, and adds them to the scene
	if multiplayer.multiplayer_peer.get_unique_id() == 1: print("added with ID of " + str(id))
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child",player)
	
	

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

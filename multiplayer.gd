extends Node3D

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene

@onready var ip = $CanvasLayer/IP
@onready var port = $CanvasLayer/Port
@onready var track = $Track


var pos = 0
var startpos





func join_logic(id):
	if multiplayer.multiplayer_peer.get_unique_id() == 1:
		var posforclient = get_start_pos()
		set_start_pos.rpc_id(id, posforclient, multiplayer.multiplayer_peer.get_unique_id())


@rpc("any_peer", "call_local", "reliable")
func set_start_pos(pos, id):
	if id == 1: startpos = pos


func get_start_pos() -> Vector3:
	if multiplayer.multiplayer_peer.get_unique_id() == 1:
		print(pos)
		pos += 1
		if pos == 1: return track.pos1.global_position
		elif pos == 2: return track.pos2.global_position
		elif pos == 3: return track.pos3.global_position
		elif pos == 4: return track.pos4.global_position
		elif pos == 5: return track.pos5.global_position
		elif pos == 6: return track.pos6.global_position
		elif pos == 7: return track.pos7.global_position
		elif pos == 8: 
			pos = 0
			return track.pos8.global_position
	return Vector3.ZERO
		


func _on_host_pressed():
	#Change this port to whatever you want
	peer.create_server(57570)
	#set the peer we use to the peer we made
	multiplayer.multiplayer_peer = peer
	#whenever someone joins we run add_player
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_connected.connect(join_logic)
	
	#add ourselves
	add_player()
	join_logic(1)
	#hide buttons and capture mouse
	$CanvasLayer.hide()
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_join_pressed():
	#Change this port and ip to whatever you want, 127.0.0.1 is on the same machine
	peer.create_client("127.0.0.1", 57570)
	#sets the peer to the peer we just made
	multiplayer.multiplayer_peer = peer
	print(multiplayer.multiplayer_peer.get_unique_id())
	
	#hide buttons and capture mouse
	$CanvasLayer.hide()
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Camera3D.current = true
	await get_tree().create_timer(0.5).timeout
	find_child(str(multiplayer.multiplayer_peer.get_unique_id())).position = startpos
	

func add_player(id = 1):
	#instances the player, names it the id of the connecting person, and adds them to the scene
	print("added with ID of " + str(id))
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child",player)
	
	

func exit_game(id):
	#disconnect smoothly and delete the player for everyone
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)


func del_player(id):
	#remotley delete the player from everyones game
	rpc("_del_player", id)

#let anyone call this and also call it here
@rpc("any_peer","call_local")
func _del_player(id):
	#queue free the node
	get_node(str(id)).queue_free()

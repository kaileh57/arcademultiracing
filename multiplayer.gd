extends Node3D

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene

@onready var ip = $CanvasLayer/IP
@onready var port = $CanvasLayer/Port






func _on_host_pressed():
	#Change this port to whatever you want
	peer.create_server(int(port.text))
	#set the peer we use to the peer we made
	multiplayer.multiplayer_peer = peer
	#whenever someone joins we run add_player
	multiplayer.peer_connected.connect(add_player)
	#add ourselves
	add_player()
	#hide buttons and capture mouse
	$CanvasLayer.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_join_pressed():
	#Change this port and ip to whatever you want, 127.0.0.1 is on the same machine
	peer.create_client(str(ip.text), int(port.text))
	#sets the peer to the peer we just made
	multiplayer.multiplayer_peer = peer
	#hide buttons and capture mouse
	$CanvasLayer.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func add_player(id = 1):
	#instances the player, names it the id of the connecting person, and adds them to the scene
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
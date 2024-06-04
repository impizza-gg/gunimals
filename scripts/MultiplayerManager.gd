extends Node

signal player_added(id: int, playerName: String, admin: bool)
signal player_disconnected_signal(id: int)

@onready var MainMenu := %MainMenu
@onready var WaitingRoom := %WaitingRoom

var peer := ENetMultiplayerPeer.new()
var connected_players := {}

func _on_main_menu_create_room(playerName: String) -> void:
	var ip : String
	if OS.has_feature("windows"):
		ip = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")), IP.TYPE_IPV4)
	else:
		ip = IP.resolve_hostname(str(OS.get_environment("HOSTNAME")), IP.TYPE_IPV4)
	var port := 135
		
	var HOST_ERROR = peer.create_server(int(port))
	
	if HOST_ERROR != OK:
		print("NETWORK: HOST ERROR")
		return
		
	connected_players.clear()
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_disconnected.connect(player_disconnected)
	add_player(peer.get_unique_id(), playerName, true)
	MainMenu.hide()
	
	WaitingRoom.ip = ip + ":" + str(port)
	WaitingRoom.StartButton.visible = true
	WaitingRoom.show()


# botando isso aqui porque eu esqueci como funcionava algumas vezes
# essa função é chamada pelos clients quando se conectam no server
# usando rpc_id(1, ...)
@rpc("any_peer", "call_remote")
func add_player(id: int, playerName: String, admin := false):
	print("Adding player: " + playerName + " id: " + str(id))
	
	player_added.emit(id, playerName, admin)
	connected_players[id] = {
		"name": playerName,
	}
	
	
func _on_main_menu_join_room(playerName: String, ipPort: String) -> void:
	var ip := ipPort.split(":")[0]
	var port := int(ipPort.split(":")[1])
	
	var JOIN_ERROR := peer.create_client(ip, port)
	if JOIN_ERROR != OK:
		print("NETWORK: JOIN ERROR")
		return
		
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(connected_to_server.bind(playerName))
	multiplayer.server_disconnected.connect(back)
	
	MainMenu.hide()
	WaitingRoom.ip = ipPort
	# acho péssimo isso estar aqui, mas foi o jeito pq se não ele achava q era o server 
	# pq a waitingroom ja vem alocada e ele acha que é server por padrão sei lá pq
	# e instanciar ela nesse momento ia dar mto mais trabalho
	WaitingRoom.StartButton.visible = false
	WaitingRoom.show()


func connected_to_server(playerName: String):
	var error = rpc_id(1, "add_player", peer.get_unique_id(), playerName)
	if error: 
		print("error: " + str(error))


func _on_waiting_room_leave_room() -> void:
	back()


func back() -> void:
	# TODO: alert popup: Connection closed by host
	WaitingRoom.clear_player_list()
	
	# tá dando um "erro" porque o cliente tenta fechar a conexão que o servidor já fechou
	# mas funciona igual
	multiplayer.multiplayer_peer.close()
	multiplayer.peer_disconnected.disconnect(player_disconnected)
	WaitingRoom.hide()
	MainMenu.show()


func player_disconnected(id: int) -> void:
	print("Player disconnected: " + str(id))
	player_disconnected_signal.emit(id)
	if multiplayer.is_server():
		connected_players.erase(id)



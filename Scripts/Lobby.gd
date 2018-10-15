extends Node2D

var playerName = "Lazy"
var bufferDict = {}
var playerInfoArray = []
#var playerInfoArrayRefference = [name, location, job]
#dictionary {id = refferenceArray, id2 = refferenceArray}

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("connected_to_server", self, "connected_to_server")


func _player_connected(id):
	pass


master func recieve_player(playerArray, bufferId): #called when a player con
	Globals.playersDic[bufferId] = playerArray
	$List/PlayerList.clear()
	bufferDict = Globals.playersDic
#	rset(str(Globals.playersDic), bufferDic)
	rpc("update_list", bufferDict) #tell everybody to update their list


func _on_buttonHoste_pressed():
	print("Hosting network")
	
	_get_network_info()
	var host = NetworkedMultiplayerENet.new()
	var res = host.create_server(Globals.port, 12)
	var bufferId
	
	if res != OK:
		print("Error: Unable to hoste")
		return
	
	#set this machine as a peer under ENet
	get_tree().set_network_peer(host)
	
	bufferId = get_tree().get_network_unique_id() #add to player dictionary
	playerInfoArray.clear()
	playerInfoArray.append($PlayerName.text)
	Globals.playersDic[bufferId] = playerInfoArray
	update_list(bufferDict)
	
	_get_ip()
	
	Globals.playerName = $PlayerName.text
	
	print(Globals.hostIP)
	
	$List.set_network_master(1)
	_hide_all_nodes()
	$List.show()
	 
	$List/Ip.set_text(str(Globals.hostIP))
	$List/Port.set_text(str(Globals.port))
	$Back.show()
	$buttonJoin.hide()
	$buttonHoste.hide()


func _on_buttonJoin_pressed():
	print("Joining network")
	
	_get_network_info()
	var host = NetworkedMultiplayerENet.new()
	host.create_client(Globals.ip, Globals.port)
	
	#set this machine as a per under ENet
	get_tree().set_network_peer(host)
	Globals.playerName = $PlayerName.text
	
	_hide_all_nodes()
	$Back.show()
	$List.show()
	$List/StartGame.hide()
	$buttonJoin.hide()
	$buttonHoste.hide()


func connected_to_server():
	var playerArray = []
	var bufferId
	playerName = $PlayerName.text #index: 1=name, 2=location, 3=job
	playerInfoArray.clear()
	playerInfoArray.append(playerName)
	bufferId = int(get_tree().get_network_unique_id())
	
	Globals.playerName = playerName
#	$List/PlayerList.clear()
#	for players in Globals.playersDic:
#		$List/PlayerList.add_item(Globals.playersDic[players])
	
	rpc_id(1, "recieve_player", playerInfoArray, bufferId)


func _get_network_info():
	playerName = $PlayerName.text
	Globals.ip = $IpInput.text
	Globals.port = int($Port.text)
	Globals.maxPlayers = int($maxPlayers.text)


func _on_Back_pressed():
	#reset gui
	_hide_all_nodes()
	$Intro.show()
	#close all network functions
	NetworkedMultiplayerENet.new().close_connection()
	get_tree().set_network_peer(null)
	#let users press buttons aggain
	$buttonJoin.disabled = false
	$buttonHoste.disabled = false

func _hide_all_nodes():
	var nodes = get_children()
	for node in nodes:
		node.hide()

func _get_ip():
	var ipAddresses = []
	var filteredIpAddresses = 0
	
	ipAddresses = IP.get_local_addresses()
	for addres in ipAddresses:
		if addres.begins_with("192."):
			filteredIpAddresses = addres
	
	if filteredIpAddresses !=  null:
		Globals.hostIP = filteredIpAddresses


sync func update_list(bufferDict):
	if is_network_master() == false:
		Globals.playersDic = bufferDict
	$List/PlayerList.clear()
	for playerId in Globals.playersDic:
		$List/PlayerList.add_item(str(Globals.playersDic[playerId][0]), null, false)
#	for key in Globals.playersDic:
#		$List/PlayerList.add_item(str(Globals.playersDic[key]), null, false)

func _on_StartGame_pressed():
	rpc("load_game")

sync func load_game():
	get_tree().change_scene("res://Scenes/Game.tscn")


func _on_Rules_pressed():
	get_tree().change_scene("res://Scenes/Rules.tscn")

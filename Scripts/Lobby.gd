extends Control

var playerName = "Lazy"
var bufferDict = {}
var playerInfoArray = []
#var playerInfoArrayRefference = [client name, location, job]
#dictionary {id = refferenceArray, id2 = refferenceArray}

func _ready():
	get_tree().connect("connected_to_server", self, "connected_to_server")
	if Globals.numOfPlayersConnected > 1:
		reinitialize_list()

func _on_buttonHost_pressed():
	print("Hosting network")
	
	_get_network_info()
	var host = NetworkedMultiplayerENet.new()
	var res = host.create_server(Globals.port, 12)
	var bufferId
	
	if res != OK:
		print("Error: Unable to host")
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
	$buttonHost.hide()

func _on_buttonJoin_pressed():
	print("Joining network")
	
	_get_network_info()
	var host = NetworkedMultiplayerENet.new()
	var res = host.create_client(Globals.ip, Globals.port)
	
	#set this machine as a peer under ENet
	get_tree().set_network_peer(host)
	Globals.playerName = $PlayerName.text
	
	_hide_all_nodes()
	$Back.show()
	$List.show()
	$List/StartGame.hide()
	$buttonJoin.hide()
	$buttonHost.hide()
	_get_ip()
	$List/Ip.set_text(str(Globals.hostIP))
	$List/Port.set_text(str(Globals.port))

func connected_to_server(): #clients call this when they connect to server
	var playerArray = []
	var bufferId
	playerName = $PlayerName.text #index: 0=name, 1=location, 2=job
	playerInfoArray.clear()
	playerInfoArray.append(playerName)
	bufferId = int(get_tree().get_network_unique_id())
	
	Globals.playerName = playerName
	rpc_id(1, "recieve_player", playerInfoArray, bufferId) #player sends his info to master

master func recieve_player(playerArray, bufferId): #called by connecting player
	Globals.playersDic[bufferId] = playerArray
	$List/PlayerList.clear()
	bufferDict = Globals.playersDic
	Globals.numOfPlayersConnected += 1
	rpc("noOfPlayersRefresh", Globals.numOfPlayersConnected)
#	print(str(Globals.numOfPlayersConnected))
	rpc("update_list", bufferDict) #tell everybody to update their list

sync func update_list(bufferDict):
	$List/PlayerList.clear()
	if is_network_master() == false: #server already has correct data
		Globals.playersDic = bufferDict
	for playerId in Globals.playersDic:
		$List/PlayerList.add_item(str(Globals.playersDic[playerId][0]), null, false)

func _get_network_info(): #Used when creating server
	playerName = $PlayerName.text
	Globals.ip = $IpInput.text
	Globals.port = int($Port.text)
	Globals.maxPlayers = int($maxPlayers.text)

func _on_Back_pressed():
	if is_network_master():
		rpc("host_cancel")
	else:
		var clientID = get_tree().get_network_unique_id()
		client_cancel(clientID)
		#reset gui
		_hide_all_nodes()
		$Intro.show()
		#let users press buttons aggain
		$buttonJoin.disabled = false
		$buttonHost.disabled = false

sync func host_cancel():
	get_tree().set_network_peer(null)
	#reset gui
	_hide_all_nodes()
	$Intro.show()
	#let users press buttons aggain
	$buttonJoin.disabled = false
	$buttonHost.disabled = false

func client_cancel(clientID):
	get_tree().set_network_peer(null)


sync func reinitialize_list():
	_hide_all_nodes()
	$List.show()
	$Back.show()
	
	if get_tree().get_network_unique_id() != 1:
		get_node("List/StartGame").hide()
	else:
		var IDs = Array(get_tree().get_network_connected_peers())
#		print(IDs)
		var BadIds = []
		for id in Globals.playersDic:
			if IDs.has(int(id)) == false and id != 1:
				BadIds.append(id)
		for id in BadIds: #extra loop to avoid iterating dictionary and deleting at the same time
			Globals.playersDic.erase(id)
		bufferDict = Globals.playersDic
#		print(bufferDict)
		rpc("update_list", bufferDict)

func _hide_all_nodes():
	var nodes = get_children()
	for node in nodes:
		if node.has_method("hide"):
			node.hide()

func _get_ip():
	var ipAddresses = []
	var filteredIpAddresses = ""
	
	ipAddresses = IP.get_local_addresses()
	for addres in ipAddresses:
		if addres.begins_with("127.0.0."):
			filteredIpAddresses = addres
		if addres.begins_with("192."):
			filteredIpAddresses = addres
	
	if filteredIpAddresses !=  null:
		Globals.hostIP = filteredIpAddresses

remote func noOfPlayersRefresh(var NumbOfPlayers):
	Globals.numOfPlayersConnected = NumbOfPlayers

func _on_StartGame_pressed():
	rpc("load_game")

sync func load_game():
	get_tree().change_scene("res://Scenes/Game.tscn")

func _on_Rules_pressed():
	get_tree().change_scene("res://Scenes/Rules.tscn")

func _on_ReinitTimer_timeout():
	if Globals.numOfPlayersConnected > 1 && is_network_master():
		reinitialize_list()

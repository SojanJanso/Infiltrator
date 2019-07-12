extends Node2D

var locationIndex

var playerArray = []
var infiltrator #id of infiltrator
var Location

var launching = true

var playersConected = 0


func _ready():
	var randNum = 0
	var arraySize
	
	randomize() #makes the random number actualy random (latter)
	
	$Name.set_text(Globals.playerName)
	
	#remove underscores on location names in GUI (does not modify the locations array)
	for Locations in Arrays.locations:
		var placeHolderString = ""
		placeHolderString = Locations.replace("_", " ")
		$LabelLocationsList.add_text(placeHolderString + "\n")
	
	if is_network_master():
		$Restart.show() #show restart button
		$Lobby.show()
	else:
		$Restart.hide()
		$Lobby.hide()

func _process(delta):
	if launching:
		$TimerLabel.set_text("") #clear previous text
		$TimerLabel.set_text(str("starting in: "+str(round($TimerLabel/Timer.get_time_left())) + " seconds"))
	else:
		$TimerLabel.set_text("") #clear previous text
		$TimerLabel.set_text(str(str(round($TimerLabel/EndTimer.get_time_left())) + " seconds left"))

sync func set_location(Location):
	var bufferLocation
	bufferLocation = Location.replace("_", " ")
	$Location.set_text(bufferLocation)

remote func set_job(Job):
	$Job.set_text(str(Job))

remote func set_infiltrator():
	$Location.set_text("Find our location!")
	$Job.set_text("Infiltrator")
	$Job.set_self_modulate(Color(250,0,0))

func _on_Restart_pressed():
	rpc("restart_game")

sync func restart_game():
	print(Globals.playersDic)
	get_tree().change_scene("res://Scenes/Game.tscn")

func _on_EndTimer_timeout():
	rpc("end")

sync func end():
	var nodes = get_children()
	
	if is_network_master():
		for node in nodes:
			if node != $Restart:
				 node.hide()
		$Winner.show()
	
	for node in nodes:
		if node != $Restart:
				 node.hide()
	$Winner.show()

func _on_Timer_timeout():
	var randNum = 0
	var arraySize
	
	if is_network_master():
		
		arraySize = Arrays.locations.size() #get size of locations array (for easy updating)
		locationIndex = randi()%arraySize+0 #returns a random number from num2 to num1+num2
		Location = Arrays.locations[locationIndex]
		$Location.set_text(str(Location))
		rpc("set_location", Location)
		
		for playerId in Globals.playersDic:
			var Job
			arraySize = Arrays.get(Location).size()
			randNum = randi()%arraySize+0
			Job = Arrays.get(Location)[randNum]
			if playerId == 1:
				$Job.set_text(Job)
			else:
				rpc_id(playerId, "set_job", Job)
		
		playerArray = Globals.playersDic.keys()
		arraySize = playerArray.size()
		randNum = randi()%arraySize+0
		infiltrator = playerArray[randNum]
		
		if infiltrator == 1:
			$Location.set_text("Find our location!")
			$Job.set_text("Infiltrator")
			$Job.set_self_modulate(Color(250,0,0))
		else:
			rpc_id(infiltrator, "set_infiltrator")
	
	$TimerLabel/EndTimer.start()
	launching = false

func _on_Lobby_pressed():
	rpc("return_to_lobby")

remotesync func return_to_lobby():
	get_tree().change_scene("res://Scenes/Lobby.tscn")

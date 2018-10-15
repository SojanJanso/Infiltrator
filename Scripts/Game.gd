extends Node2D

var playerName
var locationIndex

var playerArray = []
var infiltrator #infiltrator player in id value
var Location

var timer = 0


func _ready():
	var randNum = 0
	var arraySize
	
	randomize()
	
	$Name.set_text(Globals.playerName)
	
	for Locations in Arrays.locations:
		$LocationList.add_item(str(Locations), null, true)
	
	if is_network_master():
		$Restart.show() #show restart button

func _process(delta):
	if timer == 0:
		$TimerLabel.set_text("")
		$TimerLabel.set_text(str("starting in: "+str(round($TimerLabel/Timer.get_time_left())) + " seconds"))
	else:
		$TimerLabel.set_text("")
		$TimerLabel.set_text(str(str(round($TimerLabel/EndTimer.get_time_left())) + " seconds left"))


sync func set_location(Location):
	$Location.set_text(Location)

remote func set_job(Job):
	$Job.set_text(str(Job))

remote func set_infiltrator():
	$Job.set_text("Infiltrator")
	$Job.set_self_modulate(Color(250,0,0))

func _on_Restart_pressed():
	rpc("restart_game")

sync func restart_game():
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
			$Job.set_text("Infiltrator")
			$Job.set_self_modulate(Color(250,0,0))
		else:
			rpc_id(infiltrator, "set_infiltrator")
	
	$TimerLabel/EndTimer.start()
	timer = 1

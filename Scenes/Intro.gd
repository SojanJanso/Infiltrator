extends Node2D

#simply some GUI stuff where we hide things to show the right interface

func _on_Server_pressed():
	$".".hide()
	$"../Back".show()
	
	$"../buttonHoste".show()
	$"../Port".show()
	$"../maxPlayers".show()
	$"../PlayerName".show()


func _on_Client_pressed():
	$".".hide()
	$"../Back".show()
	
	$"../buttonJoin".show()
	$"../IpInput".show()
	$"../Port".show()
	$"../PlayerName".show()

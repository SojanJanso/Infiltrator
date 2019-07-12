extends Node

var hostIP = "No valid IP available"

var ip = "127.0.0.1"
var port = 2424
var maxPlayers = 12

var playerName = "" #name of this machines player


var playersDic = {}
#dictionary {id = refferenceArray, id2 = refferenceArray}

var numOfPlayersConnected = 1 #quick "not alone" check
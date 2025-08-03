extends Node

var music_player: AudioStreamPlayer

func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.stream = preload("res://sounds/music/music.mp3")
	music_player.volume_db = -6  # Set your desired volume
	#music_player.loop = true
	music_player.autoplay = true
	add_child(music_player)
	music_player.play()

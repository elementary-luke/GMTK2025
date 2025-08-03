extends Node2D

var t = 0.0
var mag = 0.15
var f = 1.0
var scale_mag = 0.05 # Max scale change from original
const p = 10

func _ready() -> void:
	var remaining = int(Global.time_lived)
	var hours = remaining / (60 * 60)
	remaining = remaining % (60 * 60)
	var minutes = remaining / 60
	remaining = remaining % 60
	var seconds =  remaining
	$StatsText/Score.text = "SCORE: %s" % int(Global.score)
	$StatsText/RopeUsed.text = "ROPE USED: %s" % int(Global.rope_used) + "M"
	$StatsText/TimeAlive.text = "TIME LIVED: " + "%02d : %02d : %02d" % [hours, minutes, seconds]

func _process(delta: float) -> void:
	var scale_factor = 1.0 + scale_mag * sin(f * t)
	
	t += delta
	
	$PlayButtonHolder.rotation = mag / 5 * cos(f * t)
	$PlayButtonHolder.position.y += 2 * mag * sin(5 * f * t)
	$PlayButtonHolder.scale = Vector2.ONE * (scale_factor * 2)

	$MenuButtonHolder.rotation = mag / 5 * sin(f * t)
	$MenuButtonHolder.position.y += 2 * mag * cos(5 * f * t)
	$MenuButtonHolder.scale = Vector2.ONE * (scale_factor * 2)
	
	$YouDied.rotation = mag / 5 * sin(f * t)
	$YouDied.position.y += 2 * mag * cos(5 * f * t)
	$YouDied.scale = Vector2.ONE * (scale_factor * 2)
	
	$StatsText.position.y += 2 * mag * sin(5 * f * t + p)
	$StatsText.rotation = mag / 10 * cos(f * t + p)

func _on_button_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_play_button_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

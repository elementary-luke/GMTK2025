extends Node2D

var mag = 0.15
var f = 1.0
var scale_mag = 0.05

func _ready() -> void:
	var remaining = int(Global.time_lived)
	var hours = remaining / (60 * 60)
	remaining = remaining % (60 * 60)
	var minutes = remaining / 60
	remaining = remaining % 60
	var seconds =  remaining
	$Score.text = "SCORE: %s" % int(Global.score)
	$RopeUsed.text = "ROPE USED: %s" % int(Global.rope_used) + "M"
	$TimeAlive.text = "TIME LIVED: " + "%02d : %02d : %02d" % [hours, minutes, seconds]

func _process(delta: float) -> void:
	pass

func _on_button_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

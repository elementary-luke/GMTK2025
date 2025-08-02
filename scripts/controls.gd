extends Node2D

var mag = 0.15
var f = 1.0
var scale_mag = 0.05

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_button_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

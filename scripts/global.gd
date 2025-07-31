extends Node

var Root
var Player
var Rope

var player_position : Vector2

var cut_line = preload("res://scenes/cut_line.tscn")

func show_cut_line(points):
	var inst = cut_line.instantiate()
	inst.points = points
	Root.add_child(inst)
